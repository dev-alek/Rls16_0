&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
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

Основной экран просмотра в учете документа

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create1: Суслов Алексей Юрьевич


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as handle no-undo.
define input parameter pardoc-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
{ str/d-supp.i new }
{ cmp/str-glbl.i }
{ gbl/tax-name.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/getcntxt.i def }

define variable varr-b-value      as character no-undo.
define variable varroad-tax-label as character no-undo.
define variable varuse-table-list as character no-undo.
define variable varfin-table-list as character no-undo.
define variable varlog            as logical   no-undo.

{ gbl/curr-r-b.i
  varr-b-value
}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME b-d-supp

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES d-supp d-supp-grp tt-title

/* Definitions for BROWSE b-d-supp                                      */
&Scoped-define FIELDS-IN-QUERY-b-d-supp d-supp.supp-name d-supp.supp-type d-supp.supp-code d-supp.purch-name d-supp.fact-qnty d-supp.acc-base d-supp.acc-rubl d-supp.acc-vat-base d-supp.acc-vat-rubl d-supp.pay-base d-supp.pay-rubl d-supp.no-vat-base d-supp.no-vat-rubl d-supp.vat-base d-supp.vat-rubl d-supp.slt-base d-supp.slt-rubl d-supp.sale-base d-supp.ov-base d-supp.ov-vat d-supp.road-tax d-supp.excise
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-d-supp
&Scoped-define SELF-NAME b-d-supp
&Scoped-define QUERY-STRING-b-d-supp FOR EACH d-supp
&Scoped-define OPEN-QUERY-b-d-supp OPEN QUERY {&SELF-NAME} FOR EACH d-supp.
&Scoped-define TABLES-IN-QUERY-b-d-supp d-supp
&Scoped-define FIRST-TABLE-IN-QUERY-b-d-supp d-supp


/* Definitions for BROWSE b-d-supp-grp                                  */
&Scoped-define FIELDS-IN-QUERY-b-d-supp-grp d-supp-grp.supp-name d-supp-grp.supp-type d-supp-grp.supp-code d-supp-grp.purch-name d-supp-grp.grp-name d-supp-grp.fact-qnty d-supp-grp.acc-base d-supp-grp.acc-rubl d-supp-grp.acc-vat-base d-supp-grp.acc-vat-rubl d-supp-grp.pay-base d-supp-grp.pay-rubl d-supp-grp.no-vat-base d-supp-grp.no-vat-rubl d-supp-grp.vat-base d-supp-grp.vat-rubl d-supp-grp.slt-base d-supp-grp.slt-rubl d-supp-grp.sale-base d-supp-grp.ov-base d-supp-grp.ov-vat d-supp-grp.road-tax d-supp-grp.excise
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-d-supp-grp
&Scoped-define SELF-NAME b-d-supp-grp
&Scoped-define QUERY-STRING-b-d-supp-grp FOR EACH d-supp-grp
&Scoped-define OPEN-QUERY-b-d-supp-grp OPEN QUERY {&SELF-NAME} FOR EACH d-supp-grp.
&Scoped-define TABLES-IN-QUERY-b-d-supp-grp d-supp-grp
&Scoped-define FIRST-TABLE-IN-QUERY-b-d-supp-grp d-supp-grp


/* Definitions for BROWSE b-title                                       */
&Scoped-define FIELDS-IN-QUERY-b-title tt-title.purch-name tt-title.fact-qnty tt-title.acc-base tt-title.acc-rubl tt-title.acc-vat-base tt-title.acc-vat-rubl tt-title.pay-base tt-title.pay-rubl tt-title.no-vat-base tt-title.no-vat-rubl tt-title.vat-base tt-title.vat-rubl tt-title.slt-base tt-title.slt-rubl tt-title.sale-base tt-title.ov-base tt-title.ov-vat tt-title.road-tax tt-title.excise
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-title
&Scoped-define SELF-NAME b-title
&Scoped-define QUERY-STRING-b-title FOR EACH tt-title
&Scoped-define OPEN-QUERY-b-title OPEN QUERY {&SELF-NAME} FOR EACH tt-title.
&Scoped-define TABLES-IN-QUERY-b-title tt-title
&Scoped-define FIRST-TABLE-IN-QUERY-b-title tt-title


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-b-d-supp}~
    ~{&OPEN-QUERY-b-d-supp-grp}~
    ~{&OPEN-QUERY-b-title}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-add b-sp b-cont b-help b-title ~
b-d-supp b-d-supp-grp FILL-rub
&Scoped-Define DISPLAYED-OBJECTS varacc-base varacc-rubl varsale-base ~
varvat-acc-base varvat-acc-rubl varov-base varpay-base varpay-rubl ~
varov-vat varno-vat-base varno-vat-rubl varexcise varvat-base varvat-rubl ~
varroad-tax FILL-rub

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "НДС &док-та"
     SIZE 12.5 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-cont
     LABEL "Договор&ы"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO
     LABEL "Вы&ход"
     SIZE 8 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 8 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sp
     LABEL "НДС &пост-ка"
     SIZE 12.5 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE FILL-rub AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE varacc-base AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Учет. цены"
     VIEW-AS FILL-IN NATIVE
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varacc-rubl AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varexcise AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Акциз"
     VIEW-AS FILL-IN NATIVE
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varno-vat-base AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Без НДС"
     VIEW-AS FILL-IN NATIVE
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varno-vat-rubl AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varov-base AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Переоценка"
     VIEW-AS FILL-IN NATIVE
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varov-vat AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "НДС по переоц"
     VIEW-AS FILL-IN NATIVE
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varpay-base AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "К оплате"
     VIEW-AS FILL-IN NATIVE
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varpay-rubl AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varroad-tax AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN NATIVE
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varsale-base AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Продажные цены"
     VIEW-AS FILL-IN NATIVE
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varvat-acc-base AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "НДС уч.цены"
     VIEW-AS FILL-IN NATIVE
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varvat-acc-rubl AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varvat-base AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "НДС"
     VIEW-AS FILL-IN NATIVE
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE varvat-rubl AS DECIMAL FORMAT "->,>>>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE inv-type AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&Все строки", 1,
"&Излишки", 2,
"&Недостача", 3
     SIZE 35.25 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b-d-supp FOR
      d-supp SCROLLING.

DEFINE QUERY b-d-supp-grp FOR
      d-supp-grp SCROLLING.

DEFINE QUERY b-title FOR
      tt-title SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-d-supp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-d-supp Dialog-Frame _FREEFORM
  QUERY b-d-supp DISPLAY
      d-supp.supp-name format "x(20)"
d-supp.supp-type   format "x(3)"
d-supp.supp-code
d-supp.purch-name format "x(11)"
d-supp.fact-qnty
d-supp.acc-base
d-supp.acc-rubl
d-supp.acc-vat-base
d-supp.acc-vat-rubl
d-supp.pay-base
d-supp.pay-rubl
d-supp.no-vat-base
d-supp.no-vat-rubl
d-supp.vat-base
d-supp.vat-rubl
d-supp.slt-base
d-supp.slt-rubl
d-supp.sale-base
d-supp.ov-base
d-supp.ov-vat
d-supp.road-tax
d-supp.excise
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.13 BY 5.33
         TITLE "Поставщик-Тип приобретения" ROW-HEIGHT-CHARS .58.

DEFINE BROWSE b-d-supp-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-d-supp-grp Dialog-Frame _FREEFORM
  QUERY b-d-supp-grp DISPLAY
      d-supp-grp.supp-name format "x(20)"
d-supp-grp.supp-type format "x(3)"
d-supp-grp.supp-code
d-supp-grp.purch-name format "x(7)"
d-supp-grp.grp-name format "x(30)"
d-supp-grp.fact-qnty
d-supp-grp.acc-base
d-supp-grp.acc-rubl
d-supp-grp.acc-vat-base
d-supp-grp.acc-vat-rubl
d-supp-grp.pay-base
d-supp-grp.pay-rubl
d-supp-grp.no-vat-base
d-supp-grp.no-vat-rubl
d-supp-grp.vat-base
d-supp-grp.vat-rubl
d-supp-grp.slt-base
d-supp-grp.slt-rubl
d-supp-grp.sale-base
d-supp-grp.ov-base
d-supp-grp.ov-vat
d-supp-grp.road-tax
d-supp-grp.excise
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.13 BY 5.71
         TITLE "Поставщик-Тип приобретения-Группа товаров" ROW-HEIGHT-CHARS .58.

DEFINE BROWSE b-title
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-title Dialog-Frame _FREEFORM
  QUERY b-title DISPLAY
      tt-title.purch-name format "x(11)"
tt-title.fact-qnty
tt-title.acc-base
tt-title.acc-rubl
tt-title.acc-vat-base
tt-title.acc-vat-rubl
tt-title.pay-base
tt-title.pay-rubl
tt-title.no-vat-base
tt-title.no-vat-rubl
tt-title.vat-base
tt-title.vat-rubl
tt-title.slt-base
tt-title.slt-rubl
tt-title.sale-base
tt-title.ov-base
tt-title.ov-vat
tt-title.road-tax
tt-title.excise
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.13 BY 4.79
         TITLE "Тип приобретения" ROW-HEIGHT-CHARS .58.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-add AT ROW 1 COL 9
     b-sp AT ROW 1 COL 21.5
     b-cont AT ROW 1 COL 34
     inv-type AT ROW 1 COL 46 NO-LABEL
     b-help AT ROW 1 COL 91
     varacc-base AT ROW 2.79 COL 12 COLON-ALIGNED
     varacc-rubl AT ROW 2.79 COL 29.5 COLON-ALIGNED NO-LABEL
     varsale-base AT ROW 2.79 COL 81.25 COLON-ALIGNED
     varvat-acc-base AT ROW 3.71 COL 12 COLON-ALIGNED
     varvat-acc-rubl AT ROW 3.71 COL 29.5 COLON-ALIGNED NO-LABEL
     varov-base AT ROW 3.71 COL 81.25 COLON-ALIGNED
     varpay-base AT ROW 4.67 COL 12 COLON-ALIGNED
     varpay-rubl AT ROW 4.67 COL 29.5 COLON-ALIGNED NO-LABEL
     varov-vat AT ROW 4.67 COL 81.25 COLON-ALIGNED
     varno-vat-base AT ROW 5.67 COL 12 COLON-ALIGNED
     varno-vat-rubl AT ROW 5.67 COL 29.5 COLON-ALIGNED NO-LABEL
     varexcise AT ROW 5.67 COL 81.25 COLON-ALIGNED
     varvat-base AT ROW 6.67 COL 12 COLON-ALIGNED
     varvat-rubl AT ROW 6.67 COL 29.5 COLON-ALIGNED NO-LABEL
     varroad-tax AT ROW 6.67 COL 81.25 COLON-ALIGNED
     b-title AT ROW 7.83 COL 1
     b-d-supp AT ROW 12.67 COL 1
     b-d-supp-grp AT ROW 18.04 COL 1
     FILL-rub AT ROW 2.13 COL 29.88 COLON-ALIGNED NO-LABEL
     "Валюта" VIEW-AS TEXT
          SIZE 6.63 BY .67 AT ROW 2.13 COL 14.5
          BGCOLOR 3 FGCOLOR 15
     SPACE(78.24) SKIP(21.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Учет"
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
   FRAME-NAME                                                           */
/* BROWSE-TAB b-title varroad-tax Dialog-Frame */
/* BROWSE-TAB b-d-supp b-title Dialog-Frame */
/* BROWSE-TAB b-d-supp-grp b-d-supp Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-d-supp:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 4.

ASSIGN
       b-d-supp-grp:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 5.

ASSIGN
       b-title:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.

/* SETTINGS FOR RADIO-SET inv-type IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN varacc-base IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varacc-rubl IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varexcise IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varno-vat-base IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varno-vat-rubl IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varov-base IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varov-vat IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varpay-base IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varpay-rubl IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varroad-tax IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varsale-base IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varvat-acc-base IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varvat-acc-rubl IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varvat-base IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varvat-rubl IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-d-supp
/* Query rebuild information for BROWSE b-d-supp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH d-supp.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-d-supp */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-d-supp-grp
/* Query rebuild information for BROWSE b-d-supp-grp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH d-supp-grp.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-d-supp-grp */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-title
/* Query rebuild information for BROWSE b-title
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-title.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-title */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Учет */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* НДС док-та */
DO:
  run str/docspadd.w .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cont
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cont Dialog-Frame
ON CHOOSE OF b-cont IN FRAME Dialog-Frame /* Договоры */
DO:
  run str/calc-sup.p ( INPUT pardoc-rec, INPUT varfin-table-list, INPUT YES, INPUT ?, INPUT YES ) NO-ERROR.
  IF ERROR-STATUS :ERROR THEN DO:
    MESSAGE "Ошибка в расчетах." VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.
  run str/docspcon.w .
  run str/calc-sup.p ( INPUT pardoc-rec, INPUT varuse-table-list, INPUT YES, INPUT ?, INPUT YES ) NO-ERROR.
  IF ERROR-STATUS :ERROR THEN DO: MESSAGE "Ошибка в расчетах." VIEW-AS ALERT-BOX ERROR. END.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  RUN calc-title IN THIS-PROCEDURE.
  DISPLAY varacc-base
          varacc-rubl
          varvat-acc-base
          varvat-acc-rubl
          varno-vat-base
          varno-vat-rubl
          varov-base
          varov-vat
          varpay-base
          varpay-rubl
          varsale-base
          varvat-base
          varvat-rubl
          varroad-tax
          varexcise
  WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sp Dialog-Frame
ON CHOOSE OF b-sp IN FRAME Dialog-Frame /* НДС пост-ка */
DO:
  run str/docspprt.w .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME inv-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL inv-type Dialog-Frame
ON VALUE-CHANGED OF inv-type IN FRAME Dialog-Frame
DO:
  for each d-supp :
    delete d-supp .
  end.
  for each d-slt-vat :
    delete d-slt-vat .
  end.
  for each d-slt-vat-cons :
    delete d-slt-vat-cons .
  end.
  assign inv-type.
  run str/calc-sup.p ( input pardoc-rec, input varuse-table-list, input yes, input inv-type, input yes ) no-error.
  if error-status :error then do: message "Ошибка в расчетах." view-as alert-box error. end.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  run calc-title in this-procedure.
  display varacc-base
          varacc-rubl
          varvat-acc-base
          varvat-acc-rubl
          varno-vat-base
          varno-vat-rubl
          varov-base
          varov-vat
          varpay-base
          varpay-rubl
          varsale-base
          varvat-base
          varvat-rubl
          varroad-tax
          varexcise
  with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-d-supp
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/hot-key.i b-help }

{ gbl/app_help.i &disable_diasize=true }

{ gbl/diasize.i &browse-name=b-title }

run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse b-d-supp :handle
  ) .
run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse b-d-supp-grp :handle
  ) .
run diasize_init in this-procedure .

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

assign varuse-table-list = "d-supp,d-slt-vat,d-slt-vat-cons,d-supp-grp,d-slt-vat-cons-grp,d-supp-slts-vats-cons,d-slts-vats,d-slts-vats-cons,d-slts-vats-cons-grp"
       varfin-table-list = "d-supp-fin,d-supp-grp-fin,d-supp-slts-vats-cons-fin,d-slt-vat-cons-fin,d-slt-vat-cons-grp-fin,d-slts-vats-cons-fin,d-slts-vats-cons-grp-fin,tt-title-fin".

assign
fill-rub = "{&abbr_rubli_firstshift}"
tt-title.fact-qnty:label in browse b-title = "Факт. кол-во"
tt-title.purch-name:label in browse b-title  = "Тип приобр"
tt-title.acc-base:label  in browse b-title= "Учетные цены (вал)"
tt-title.acc-rubl:label in browse b-title = "Учетные цены ({&abbr_rub})"
tt-title.acc-vat-base:label  in browse b-title= "НДС уч.цены (вал)"
tt-title.acc-vat-rubl:label in browse b-title = "НДС уч. цены ({&abbr_rub})"
tt-title.no-vat-base:label in browse b-title = "Без НДС (вал)"
tt-title.no-vat-rubl:label in browse b-title = "Без НДС ({&abbr_rub})"
tt-title.vat-base:label in browse b-title = "НДС (вал)"
tt-title.vat-rubl:label in browse b-title = "НДС ({&abbr_rub})"
tt-title.slt-base:label in browse b-title = "НП (вал)"
tt-title.slt-rubl:label in browse b-title = "НП ({&abbr_rub})"
tt-title.pay-base:label in browse b-title = "К оплате (вал)"
tt-title.pay-rubl:label in browse b-title = "К оплате ({&abbr_rub})"
tt-title.sale-base:label in browse b-title = "Продаж. цены"
tt-title.ov-base:label in browse b-title = "Переоценка"
tt-title.ov-vat:label in browse b-title = "НДС по переоценке"
tt-title.excise:label  in browse b-title= "Акциз ({&abbr_rub})".
run tax-name (input {&road-tax}, output varroad-tax-label) no-error.
assign
  tt-title.road-tax:label in browse b-title = varroad-tax-label
  varroad-tax:label in frame {&frame-name} = substring(varroad-tax-label,1,12).
assign
d-supp.supp-name:label in browse b-d-supp = "Поставщик"
d-supp.supp-type:label in browse b-d-supp = " "
d-supp.supp-code:label in browse b-d-supp = " "
d-supp.purch-name:label in browse b-d-supp = "Тип приобр"
d-supp.fact-qnty:label in browse b-d-supp = "Факт. кол-во"
d-supp.acc-base:label in browse b-d-supp = "Учет.цены (вал)"
d-supp.acc-rubl:label in browse b-d-supp = "Учет. цены ({&abbr_rub})"
d-supp.acc-vat-base:label  in browse b-d-supp= "НДС уч.цены (вал)"
d-supp.acc-vat-rubl:label in browse b-d-supp = "НДС уч. цены ({&abbr_rub})"
d-supp.sale-base:label in browse b-d-supp  = "Продаж.цены"
d-supp.ov-base:label in browse b-d-supp = "Переоценка"
d-supp.ov-vat:label in browse b-d-supp = "НДС по переоценке"
d-supp.pay-base:label in browse b-d-supp = "К оплате (вал)"
d-supp.pay-rubl:label in browse b-d-supp = "К оплате ({&abbr_rub})"
d-supp.no-vat-base:label in browse b-d-supp = "Без НДС (вал)"
d-supp.no-vat-rubl:label in browse b-d-supp = "Без НДС ({&abbr_rub})"
d-supp.vat-base:label in browse b-d-supp = "НДС (вал)"
d-supp.vat-rubl:label in browse b-d-supp = "НДС({&abbr_rub})"
d-supp.slt-base:label in browse b-d-supp = "НП (вал)"
d-supp.slt-rubl:label in browse b-d-supp = "НП ({&abbr_rub})"
d-supp.excise:label in browse b-d-supp = "Акциз"
.
assign
  d-supp.road-tax:label in browse b-d-supp = varroad-tax-label.
assign
d-supp-grp.supp-name:label in browse b-d-supp-grp = "Поставщик"
d-supp-grp.supp-type:label in browse b-d-supp-grp = " "
d-supp-grp.supp-code:label in browse b-d-supp-grp = " "
d-supp-grp.purch-name:label in browse b-d-supp-grp = "Тип пр"
d-supp-grp.fact-qnty:label in browse b-d-supp-grp = "Факт. кол-во"
d-supp-grp.acc-base:label in browse b-d-supp-grp = "Учет.цены (вал)"
d-supp-grp.acc-rubl:label in browse b-d-supp-grp = "Учет. цены ({&abbr_rub})"
d-supp-grp.acc-vat-base:label  in browse b-d-supp-grp= "НДС уч.цены (вал)"
d-supp-grp.acc-vat-rubl:label in browse b-d-supp-grp = "НДС уч. цены ({&abbr_rub})"
d-supp-grp.sale-base:label in browse b-d-supp-grp  = "Продаж.цены"
d-supp-grp.ov-base:label in browse b-d-supp-grp = "Переоценка"
d-supp-grp.ov-vat:label in browse b-d-supp-grp = "НДС по переоценке"
d-supp-grp.pay-base:label in browse b-d-supp-grp = "К оплате (вал)"
d-supp-grp.pay-rubl:label in browse b-d-supp-grp = "К оплате ({&abbr_rub})"
d-supp-grp.no-vat-base:label in browse b-d-supp-grp = "Без НДС (вал)"
d-supp-grp.no-vat-rubl:label in browse b-d-supp-grp = "Без НДС ({&abbr_rub})"
d-supp-grp.vat-base:label in browse b-d-supp-grp = "НДС (вал)"
d-supp-grp.vat-rubl:label in browse b-d-supp-grp = "НДС({&abbr_rub})"
d-supp-grp.slt-base:label in browse b-d-supp-grp = "НП (вал)"
d-supp-grp.slt-rubl:label in browse b-d-supp-grp = "НП ({&abbr_rub})"
d-supp-grp.excise:label in browse b-d-supp-grp = "Акциз"
d-supp-grp.grp-name:label in browse b-d-supp-grp = "Группа товаров"
.
assign
  d-supp-grp.road-tax:label in browse b-d-supp-grp = varroad-tax-label
.
assign
  d-supp-grp.supp-name:RESIZABLE in browse b-d-supp-grp = true
  d-supp-grp.supp-type:RESIZABLE in browse b-d-supp-grp = true
  d-supp-grp.purch-name:RESIZABLE in browse b-d-supp-grp = true
  d-supp-grp.grp-name:RESIZABLE in browse b-d-supp-grp = true
  d-supp.supp-name:RESIZABLE in browse b-d-supp = true
  d-supp.supp-type:RESIZABLE in browse b-d-supp = true
  d-supp.purch-name:RESIZABLE in browse b-d-supp = true
  tt-title.purch-name:RESIZABLE in browse b-title  = true
.
run str/calc-sup.p ( input pardoc-rec, input varuse-table-list, input yes, input ?, input yes ).
run calc-title in this-procedure.

  RUN enable_UI.
  find first trn-doc where recid(trn-doc) = pardoc-rec no-lock.

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_archive_cost':U
    {&cntxt-object}
    trn-doc.host-code
    trn-doc.obj-type
    trn-doc.obj-code
    0
    0
    0
    true
    varlog
  }

  if not varlog then return error.
  if trn-doc.doc-type = {&inventory} then do:
      assign inv-type:sensitive = yes
                inv-type:visible = yes.
    end.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-title Dialog-Frame
PROCEDURE calc-title :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
varacc-base = 0.00
varacc-rubl = 0.00
varvat-acc-base = 0.00
varvat-acc-rubl = 0.00
varno-vat-base = 0.00
varno-vat-rubl = 0.00
varov-base = 0.00
varov-vat = 0.00
varpay-base = 0.00
varpay-rubl = 0.00
varsale-base = 0.00
varvat-base = 0.00
varvat-rubl = 0.00
varroad-tax = 0.00
varexcise = 0.00
.
define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}

for each tt-title:
assign
varacc-base = varacc-base + tt-title.acc-base
varacc-rubl = varacc-rubl + tt-title.acc-rubl
varvat-acc-base = varvat-acc-base + tt-title.acc-vat-base
varvat-acc-rubl = varvat-acc-rubl + tt-title.acc-vat-rubl
varno-vat-base = varno-vat-base + tt-title.no-vat-base
varno-vat-rubl = varno-vat-rubl + tt-title.no-vat-rubl
varov-base = varov-base + tt-title.ov-base
varov-vat = varov-vat + tt-title.ov-vat
varpay-base = varpay-base + tt-title.pay-base
varpay-rubl = varpay-rubl + tt-title.pay-rubl

varvat-base = varvat-base + tt-title.vat-base
varvat-rubl = varvat-rubl + tt-title.vat-rubl
varroad-tax = varroad-tax + tt-title.road-tax
varexcise = varexcise + tt-title.excise
.

if v-curr-r-b = {&r-b-base} then
    assign
        varsale-base = varsale-base + tt-title.sale-base
        .
else
  assign
    varsale-base = varsale-base + tt-title.sale-rubl
    .
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY varacc-base varacc-rubl varsale-base varvat-acc-base varvat-acc-rubl
          varov-base varpay-base varpay-rubl varov-vat varno-vat-base
          varno-vat-rubl varexcise varvat-base varvat-rubl varroad-tax FILL-rub
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-add b-sp b-cont b-help b-title b-d-supp b-d-supp-grp FILL-rub
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME