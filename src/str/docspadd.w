&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Дополнительный экран просмотра в учете НДС документа-НП документа

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Дополнительный экран просмотра в учете".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ str/d-supp.i   }
{ cmp/str-glbl.i }
{ gbl/tax-name.i }
{ cmp/library.i  }

define variable varr-b-value as character no-undo.
define variable varroad-tax-label as character no-undo.

{ gbl/curr-r-b.i
  varr-b-value
}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME b-slt-vat

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES d-slt-vat d-slt-vat-cons d-slt-vat-cons-grp

/* Definitions for BROWSE b-slt-vat                                     */
&Scoped-define FIELDS-IN-QUERY-b-slt-vat d-slt-vat.vat-pc d-slt-vat.slt-pc d-slt-vat.fact-qnty d-slt-vat.acc-base d-slt-vat.acc-rubl d-slt-vat.acc-vat-base d-slt-vat.acc-vat-rubl d-slt-vat.pay-base d-slt-vat.pay-rubl d-slt-vat.no-vat-base d-slt-vat.no-vat-rubl d-slt-vat.vat-base d-slt-vat.vat-rubl d-slt-vat.slt-base d-slt-vat.slt-rubl d-slt-vat.sale-base d-slt-vat.ov-base d-slt-vat.ov-vat d-slt-vat.road-tax d-slt-vat.excise
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-slt-vat
&Scoped-define SELF-NAME b-slt-vat
&Scoped-define QUERY-STRING-b-slt-vat FOR EACH d-slt-vat
&Scoped-define OPEN-QUERY-b-slt-vat OPEN QUERY {&SELF-NAME} FOR EACH d-slt-vat.
&Scoped-define TABLES-IN-QUERY-b-slt-vat d-slt-vat
&Scoped-define FIRST-TABLE-IN-QUERY-b-slt-vat d-slt-vat


/* Definitions for BROWSE b-slt-vat-cons                                */
&Scoped-define FIELDS-IN-QUERY-b-slt-vat-cons d-slt-vat-cons.vat-pc d-slt-vat-cons.slt-pc d-slt-vat-cons.purch-name d-slt-vat-cons.fact-qnty d-slt-vat-cons.acc-base d-slt-vat-cons.acc-rubl d-slt-vat-cons.acc-vat-base d-slt-vat-cons.acc-vat-rubl d-slt-vat-cons.pay-base d-slt-vat-cons.pay-rubl d-slt-vat-cons.no-vat-base d-slt-vat-cons.no-vat-rubl d-slt-vat-cons.vat-base d-slt-vat-cons.vat-rubl d-slt-vat-cons.slt-base d-slt-vat-cons.slt-rubl d-slt-vat-cons.sale-base d-slt-vat-cons.ov-base d-slt-vat-cons.ov-vat d-slt-vat-cons.road-tax d-slt-vat-cons.excise
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-slt-vat-cons
&Scoped-define SELF-NAME b-slt-vat-cons
&Scoped-define QUERY-STRING-b-slt-vat-cons FOR EACH d-slt-vat-cons
&Scoped-define OPEN-QUERY-b-slt-vat-cons OPEN QUERY {&SELF-NAME} FOR EACH d-slt-vat-cons.
&Scoped-define TABLES-IN-QUERY-b-slt-vat-cons d-slt-vat-cons
&Scoped-define FIRST-TABLE-IN-QUERY-b-slt-vat-cons d-slt-vat-cons


/* Definitions for BROWSE b-slt-vat-cons-grp                            */
&Scoped-define FIELDS-IN-QUERY-b-slt-vat-cons-grp d-slt-vat-cons-grp.vat-pc d-slt-vat-cons-grp.slt-pc d-slt-vat-cons-grp.purch-name d-slt-vat-cons-grp.grp-name d-slt-vat-cons-grp.fact-qnty d-slt-vat-cons-grp.acc-base d-slt-vat-cons-grp.acc-rubl d-slt-vat-cons-grp.acc-vat-base d-slt-vat-cons-grp.acc-vat-rubl d-slt-vat-cons-grp.pay-base d-slt-vat-cons-grp.pay-rubl d-slt-vat-cons-grp.no-vat-base d-slt-vat-cons-grp.no-vat-rubl d-slt-vat-cons-grp.vat-base d-slt-vat-cons-grp.vat-rubl d-slt-vat-cons-grp.slt-base d-slt-vat-cons-grp.slt-rubl d-slt-vat-cons-grp.sale-base d-slt-vat-cons-grp.ov-base d-slt-vat-cons-grp.ov-vat d-slt-vat-cons-grp.road-tax d-slt-vat-cons-grp.excise
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-slt-vat-cons-grp
&Scoped-define SELF-NAME b-slt-vat-cons-grp
&Scoped-define QUERY-STRING-b-slt-vat-cons-grp FOR EACH d-slt-vat-cons-grp
&Scoped-define OPEN-QUERY-b-slt-vat-cons-grp OPEN QUERY {&SELF-NAME} FOR EACH d-slt-vat-cons-grp.
&Scoped-define TABLES-IN-QUERY-b-slt-vat-cons-grp d-slt-vat-cons-grp
&Scoped-define FIRST-TABLE-IN-QUERY-b-slt-vat-cons-grp d-slt-vat-cons-grp


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-b-slt-vat}~
    ~{&OPEN-QUERY-b-slt-vat-cons}~
    ~{&OPEN-QUERY-b-slt-vat-cons-grp}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help b-slt-vat b-slt-vat-cons ~
b-slt-vat-cons-grp

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b-slt-vat FOR
      d-slt-vat SCROLLING.

DEFINE QUERY b-slt-vat-cons FOR
      d-slt-vat-cons SCROLLING.

DEFINE QUERY b-slt-vat-cons-grp FOR
      d-slt-vat-cons-grp SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-slt-vat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-slt-vat Dialog-Frame _FREEFORM
  QUERY b-slt-vat DISPLAY
      d-slt-vat.vat-pc
d-slt-vat.slt-pc
d-slt-vat.fact-qnty
d-slt-vat.acc-base
d-slt-vat.acc-rubl
d-slt-vat.acc-vat-base
d-slt-vat.acc-vat-rubl
d-slt-vat.pay-base
d-slt-vat.pay-rubl
d-slt-vat.no-vat-base
d-slt-vat.no-vat-rubl
d-slt-vat.vat-base
d-slt-vat.vat-rubl
d-slt-vat.slt-base
d-slt-vat.slt-rubl
d-slt-vat.sale-base
d-slt-vat.ov-base
d-slt-vat.ov-vat
d-slt-vat.road-tax
d-slt-vat.excise
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.13 BY 6.5
         TITLE "НДС документа-НП документа".

DEFINE BROWSE b-slt-vat-cons
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-slt-vat-cons Dialog-Frame _FREEFORM
  QUERY b-slt-vat-cons DISPLAY
      d-slt-vat-cons.vat-pc
d-slt-vat-cons.slt-pc
d-slt-vat-cons.purch-name format "x(7)"
d-slt-vat-cons.fact-qnty
d-slt-vat-cons.acc-base
d-slt-vat-cons.acc-rubl
d-slt-vat-cons.acc-vat-base
d-slt-vat-cons.acc-vat-rubl
d-slt-vat-cons.pay-base
d-slt-vat-cons.pay-rubl
d-slt-vat-cons.no-vat-base
d-slt-vat-cons.no-vat-rubl
d-slt-vat-cons.vat-base
d-slt-vat-cons.vat-rubl
d-slt-vat-cons.slt-base
d-slt-vat-cons.slt-rubl
d-slt-vat-cons.sale-base
d-slt-vat-cons.ov-base
d-slt-vat-cons.ov-vat
d-slt-vat-cons.road-tax
d-slt-vat-cons.excise
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.13 BY 6.5
         TITLE "НДС документа-НП документа-Тип приобретения".

DEFINE BROWSE b-slt-vat-cons-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-slt-vat-cons-grp Dialog-Frame _FREEFORM
  QUERY b-slt-vat-cons-grp DISPLAY
      d-slt-vat-cons-grp.vat-pc
d-slt-vat-cons-grp.slt-pc
d-slt-vat-cons-grp.purch-name format "x(7)"
d-slt-vat-cons-grp.grp-name format "x(30)"
d-slt-vat-cons-grp.fact-qnty
d-slt-vat-cons-grp.acc-base
d-slt-vat-cons-grp.acc-rubl
d-slt-vat-cons-grp.acc-vat-base
d-slt-vat-cons-grp.acc-vat-rubl
d-slt-vat-cons-grp.pay-base
d-slt-vat-cons-grp.pay-rubl
d-slt-vat-cons-grp.no-vat-base
d-slt-vat-cons-grp.no-vat-rubl
d-slt-vat-cons-grp.vat-base
d-slt-vat-cons-grp.vat-rubl
d-slt-vat-cons-grp.slt-base
d-slt-vat-cons-grp.slt-rubl
d-slt-vat-cons-grp.sale-base
d-slt-vat-cons-grp.ov-base
d-slt-vat-cons-grp.ov-vat
d-slt-vat-cons-grp.road-tax
d-slt-vat-cons-grp.excise
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.13 BY 6.5
         TITLE "НДС документа-НП документа-Тип приобретения-Группа товаров".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-help AT ROW 1 COL 11
     b-slt-vat AT ROW 2.04 COL 1
     b-slt-vat-cons AT ROW 9.5 COL 1
     b-slt-vat-cons-grp AT ROW 16.5 COL 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Учет (НДС документа)"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB b-slt-vat b-help Dialog-Frame */
/* BROWSE-TAB b-slt-vat-cons b-slt-vat Dialog-Frame */
/* BROWSE-TAB b-slt-vat-cons-grp b-slt-vat-cons Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-slt-vat:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 2.

ASSIGN
       b-slt-vat-cons:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.

ASSIGN
       b-slt-vat-cons-grp:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 4.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-slt-vat
/* Query rebuild information for BROWSE b-slt-vat
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH d-slt-vat.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-slt-vat */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-slt-vat-cons
/* Query rebuild information for BROWSE b-slt-vat-cons
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH d-slt-vat-cons.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-slt-vat-cons */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-slt-vat-cons-grp
/* Query rebuild information for BROWSE b-slt-vat-cons-grp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH d-slt-vat-cons-grp.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-slt-vat-cons-grp */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Учет (НДС документа) */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-slt-vat
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i &disable_diasize=true }

{ gbl/diasize.i &browse-name=b-slt-vat }

run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse b-slt-vat-cons :handle
  ) .
run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse b-slt-vat-cons-grp :handle
  ) .
run diasize_init in this-procedure .


run tax-name (input {&road-tax}, output varroad-tax-label) no-error.
assign
d-slt-vat.vat-pc:label in browse b-slt-vat = "НДС"
d-slt-vat.slt-pc:label in browse b-slt-vat = "НП"
d-slt-vat.fact-qnty:label in browse b-slt-vat = "Факт. кол-во"
d-slt-vat.acc-base:label in browse b-slt-vat = "Учет. цены (вал)"
d-slt-vat.acc-rubl:label in browse b-slt-vat = "Учет. цены ({&abbr_rub})"
d-slt-vat.acc-vat-base:label in browse b-slt-vat = "НДС уч. цены (вал)"
d-slt-vat.acc-vat-rubl:label in browse b-slt-vat = "НДС уч. цены ({&abbr_rub})"
d-slt-vat.sale-base:label in browse b-slt-vat  = "Продаж.цены"
d-slt-vat.ov-base:label in browse b-slt-vat = "Переоценка"
d-slt-vat.ov-vat:label in browse b-slt-vat = "НДС по переоценке"
d-slt-vat.pay-base:label in browse b-slt-vat = "К оплате (вал)"
d-slt-vat.pay-rubl:label in browse b-slt-vat = "К оплате ({&abbr_rub})"
d-slt-vat.no-vat-base:label in browse b-slt-vat = "Без НДС (вал)"
d-slt-vat.no-vat-rubl:label in browse b-slt-vat = "Без НДС ({&abbr_rub})"
d-slt-vat.vat-base:label in browse b-slt-vat = "НДС (вал)"
d-slt-vat.vat-rubl:label in browse b-slt-vat = "НДС({&abbr_rub})"
d-slt-vat.slt-base:label in browse b-slt-vat = "НП (вал)"
d-slt-vat.slt-rubl:label in browse b-slt-vat = "НП ({&abbr_rub})"
d-slt-vat.excise:label in browse b-slt-vat = "Акциз"
.
assign
  d-slt-vat.road-tax:label in browse b-slt-vat = varroad-tax-label.
assign
d-slt-vat-cons.vat-pc:label in browse b-slt-vat-cons = "НДС"
d-slt-vat-cons.slt-pc:label in browse b-slt-vat-cons = "НП"
d-slt-vat-cons.purch-name:label in browse b-slt-vat-cons = "Тип пр"
d-slt-vat-cons.fact-qnty:label in browse b-slt-vat-cons = "Факт. кол-во"
d-slt-vat-cons.acc-base:label in browse b-slt-vat-cons = "Учет. цены (вал)"
d-slt-vat-cons.acc-rubl:label in browse b-slt-vat-cons = "Учет. цены ({&abbr_rub})"
d-slt-vat-cons.acc-vat-base:label in browse b-slt-vat-cons = "НДС уч. цены (вал)"
d-slt-vat-cons.acc-vat-rubl:label in browse b-slt-vat-cons = "НДС уч. цены ({&abbr_rub})"
d-slt-vat-cons.sale-base:label in browse b-slt-vat-cons  = "Продаж.цены"
d-slt-vat-cons.ov-base:label in browse b-slt-vat-cons = "Переоценка"
d-slt-vat-cons.ov-vat:label in browse b-slt-vat-cons = "НДС по переоценке"
d-slt-vat-cons.pay-base:label in browse b-slt-vat-cons = "К оплате (вал)"
d-slt-vat-cons.pay-rubl:label in browse b-slt-vat-cons = "К оплате ({&abbr_rub})"
d-slt-vat-cons.no-vat-base:label in browse b-slt-vat-cons = "Без НДС (вал)"
d-slt-vat-cons.no-vat-rubl:label in browse b-slt-vat-cons = "Без НДС ({&abbr_rub})"
d-slt-vat-cons.vat-base:label in browse b-slt-vat-cons = "НДС (вал)"
d-slt-vat-cons.vat-rubl:label in browse b-slt-vat-cons = "НДС({&abbr_rub})"
d-slt-vat-cons.slt-base:label in browse b-slt-vat-cons = "НП (вал)"
d-slt-vat-cons.slt-rubl:label in browse b-slt-vat-cons = "НП ({&abbr_rub})"
d-slt-vat-cons.excise:label in browse b-slt-vat-cons = "Акциз"
.
assign
  d-slt-vat-cons.road-tax:label in browse b-slt-vat-cons = varroad-tax-label.
assign
d-slt-vat-cons-grp.vat-pc:label in browse b-slt-vat-cons-grp = "НДС"
d-slt-vat-cons-grp.slt-pc:label in browse b-slt-vat-cons-grp = "НП"
d-slt-vat-cons-grp.purch-name:label in browse b-slt-vat-cons-grp = "Тип пр"
d-slt-vat-cons-grp.fact-qnty:label in browse b-slt-vat-cons-grp = "Факт. кол-во"
d-slt-vat-cons-grp.acc-base:label in browse b-slt-vat-cons-grp = "Учет. цены (вал)"
d-slt-vat-cons-grp.acc-rubl:label in browse b-slt-vat-cons-grp = "Учет. цены ({&abbr_rub})"
d-slt-vat-cons-grp.acc-vat-base:label in browse b-slt-vat-cons-grp = "НДС уч. цены (вал)"
d-slt-vat-cons-grp.acc-vat-rubl:label in browse b-slt-vat-cons-grp = "НДС уч. цены ({&abbr_rub})"
d-slt-vat-cons-grp.sale-base:label in browse b-slt-vat-cons-grp  = "Продаж.цены"
d-slt-vat-cons-grp.ov-base:label in browse b-slt-vat-cons-grp = "Переоценка"
d-slt-vat-cons-grp.ov-vat:label in browse b-slt-vat-cons-grp = "НДС по переоценке"
d-slt-vat-cons-grp.pay-base:label in browse b-slt-vat-cons-grp = "К оплате (вал)"
d-slt-vat-cons-grp.pay-rubl:label in browse b-slt-vat-cons-grp = "К оплате ({&abbr_rub})"
d-slt-vat-cons-grp.no-vat-base:label in browse b-slt-vat-cons-grp = "Без НДС (вал)"
d-slt-vat-cons-grp.no-vat-rubl:label in browse b-slt-vat-cons-grp = "Без НДС ({&abbr_rub})"
d-slt-vat-cons-grp.vat-base:label in browse b-slt-vat-cons-grp = "НДС (вал)"
d-slt-vat-cons-grp.vat-rubl:label in browse b-slt-vat-cons-grp = "НДС({&abbr_rub})"
d-slt-vat-cons-grp.slt-base:label in browse b-slt-vat-cons-grp = "НП (вал)"
d-slt-vat-cons-grp.slt-rubl:label in browse b-slt-vat-cons-grp = "НП ({&abbr_rub})"
d-slt-vat-cons-grp.excise:label in browse b-slt-vat-cons-grp = "Акциз"
d-slt-vat-cons-grp.grp-name:label in browse b-slt-vat-cons-grp = "Группа товаров"
.
assign
  d-slt-vat-cons-grp.road-tax:label in browse b-slt-vat-cons-grp = varroad-tax-label.
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
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
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
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
  ENABLE b-exit b-help b-slt-vat b-slt-vat-cons b-slt-vat-cons-grp
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME