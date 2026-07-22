&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Изменение строки счета-фактуры

Автор: Чернова Светлана Александровна
Дата создания: 11/11/05
Author: Svetlana Chernova
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
define input         parameter parparentproc as handle no-undo .
define input-output  parameter gds-name   as character no-undo .
define input-output  parameter unit-base  as character no-undo .
define input-output  parameter fact-qnty  as decimal   no-undo .
define input-output  parameter price-rubl as decimal   no-undo .
define input-output  parameter sum-rubl   as decimal   no-undo .
define input-output  parameter excise     as decimal   no-undo .
define input-output  parameter VAT-pc     as decimal   no-undo .
define input-output  parameter VAT-rubl   as decimal   no-undo .
define input-output  parameter sum-rubl-VAT as decimal   no-undo .
define input-output  parameter country    as character no-undo .
define input-output  parameter gtd        as character no-undo .
define input-output  parameter res        as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Изменение строки счета-фактуры".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.schet-fact-line

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH ub.schet-fact-line SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.schet-fact-line SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.schet-fact-line
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.schet-fact-line


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-OK RECT-1 b-exit b-calc B-Help ~
FILL-IN_gds-name FILL-IN_unit-base FILL-IN_fact-qnty r-units ~
FILL-IN_price-rubl FILL-IN_sum-rubl FILL-IN_VAT-pc FILL-IN_VAT-rubl ~
FILL-IN_excise FILL-IN_sum-rubl-VAT FILL-IN_country r-contry FILL-IN_gtd
&Scoped-Define DISPLAYED-OBJECTS FILL-IN_gds-name FILL-IN_unit-base ~
FILL-IN_fact-qnty FILL-IN_price-rubl FILL-IN_sum-rubl FILL-IN_VAT-pc ~
FILL-IN_VAT-rubl FILL-IN_excise FILL-IN_sum-rubl-VAT FILL-IN_country ~
FILL-IN_gtd

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-calc
     LABEL "&Расчет":L
     SIZE 10 BY 1 TOOLTIP "Пересчитать суммы по цене , количеству и НДС".

DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-OK AUTO-GO
     LABEL "&Ввод ":L
     SIZE 10 BY 1.

DEFINE BUTTON r-contry
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON r-units
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-units"
     SIZE 3 BY .88.

DEFINE VARIABLE FILL-IN_country AS CHARACTER FORMAT "X(25)"
     LABEL "Страна"
     VIEW-AS FILL-IN
     SIZE 22.5 BY 1.

DEFINE VARIABLE FILL-IN_excise AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Акциз"
     VIEW-AS FILL-IN
     SIZE 16 BY 1.

DEFINE VARIABLE FILL-IN_fact-qnty AS DECIMAL FORMAT ">>,>>>,>>9.<<<" INITIAL 0
     LABEL "Кол-во"
     VIEW-AS FILL-IN
     SIZE 23.5 BY 1.

DEFINE VARIABLE FILL-IN_gds-name AS CHARACTER FORMAT "X(48)"
     LABEL "Название"
     VIEW-AS FILL-IN
     SIZE 50 BY 1.

DEFINE VARIABLE FILL-IN_gtd AS CHARACTER FORMAT "X(25)"
     LABEL "ГТД"
     VIEW-AS FILL-IN
     SIZE 22.5 BY 1.

DEFINE VARIABLE FILL-IN_price-rubl AS DECIMAL FORMAT ">,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Цена"
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1
     FGCOLOR 4 .

DEFINE VARIABLE FILL-IN_sum-rubl AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 21.5 BY 1
     FGCOLOR 4 .

DEFINE VARIABLE FILL-IN_sum-rubl-VAT AS DECIMAL FORMAT ">,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма с налогами"
     VIEW-AS FILL-IN
     SIZE 41.38 BY 1.

DEFINE VARIABLE FILL-IN_unit-base AS CHARACTER FORMAT "X(3)"
     LABEL "Ед.изм."
     VIEW-AS FILL-IN
     SIZE 5.13 BY 1.

DEFINE VARIABLE FILL-IN_VAT-pc AS DECIMAL FORMAT ">9.9<%" INITIAL 0
     LABEL "НДС"
     VIEW-AS FILL-IN
     SIZE 6 BY 1.

DEFINE VARIABLE FILL-IN_VAT-rubl AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма НДС"
     VIEW-AS FILL-IN
     SIZE 16 BY 1.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 69 BY 1.75.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      ub.schet-fact-line SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-OK AT ROW 1 COL 1
     b-exit AT ROW 1 COL 11
     b-calc AT ROW 1 COL 21
     B-Help AT ROW 1 COL 60.5
     FILL-IN_gds-name AT ROW 2.08 COL 2
     FILL-IN_unit-base AT ROW 3.21 COL 54.88 COLON-ALIGNED
     FILL-IN_fact-qnty AT ROW 3.25 COL 10 COLON-ALIGNED
     r-units AT ROW 3.25 COL 62.5 WIDGET-ID 4
     FILL-IN_price-rubl AT ROW 5.38 COL 18.5 COLON-ALIGNED
     FILL-IN_sum-rubl AT ROW 5.38 COL 42.5 COLON-ALIGNED
     FILL-IN_VAT-pc AT ROW 6.75 COL 18.5 COLON-ALIGNED
     FILL-IN_VAT-rubl AT ROW 8 COL 18.5 COLON-ALIGNED
     FILL-IN_excise AT ROW 9.5 COL 18.5 COLON-ALIGNED
     FILL-IN_sum-rubl-VAT AT ROW 10.75 COL 2.5
     FILL-IN_country AT ROW 12 COL 18.5 COLON-ALIGNED
     r-contry AT ROW 12 COL 43.5 WIDGET-ID 6
     FILL-IN_gtd AT ROW 13.17 COL 18.5 COLON-ALIGNED
     " Без НДС" VIEW-AS TEXT
          SIZE 9 BY 1 AT ROW 4.75 COL 2.5
          FGCOLOR 4
     RECT-1 AT ROW 5 COL 1 WIDGET-ID 2
     SPACE(0.62) SKIP(8.91)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Строка счета-фактуры".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN_gds-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN_sum-rubl-VAT IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.schet-fact-line"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Строка счета-фактуры */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-calc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-calc Dialog-Frame
ON CHOOSE OF b-calc IN FRAME Dialog-Frame /* Расчет */
DO:
  assign FILL-IN_fact-qnty FILL-IN_price-rubl  FILL-IN_sum-rubl FILL-IN_excise  FILL-IN_VAT-pc  FILL-IN_VAT-rubl FILL-IN_sum-rubl-VAT .
  IF FILL-IN_fact-qnty = 0 then do:
    message  "Кол-во 0 - расчет невозможен!"  view-as alert-box.
    return.
  end.
  IF FILL-IN_price-rubl = 0 and FILL-IN_sum-rubl-VAT = 0 then do:
    message  "Цена без НДС 0 и общая сумма 0 - оба варианта расчета невозможны расчет невозможен!"  view-as alert-box.
    return.
  end.
  if FILL-IN_price-rubl > 0 then do:
    assign
      FILL-IN_sum-rubl = FILL-IN_price-rubl * FILL-IN_fact-qnty
      FILL-IN_VAT-rubl = FILL-IN_sum-rubl * FILL-IN_VAT-pc / 100
      FILL-IN_sum-rubl-VAT = FILL-IN_sum-rubl + FILL-IN_VAT-rubl
    .
  end.
  else do:
    assign
      FILL-IN_VAT-rubl = FILL-IN_sum-rubl-VAT * FILL-IN_VAT-pc / ( 100 + FILL-IN_VAT-pc )
      FILL-IN_sum-rubl = FILL-IN_sum-rubl-VAT - FILL-IN_VAT-rubl
      FILL-IN_price-rubl = FILL-IN_sum-rubl / FILL-IN_fact-qnty
    .
  end.
  DISPLAY FILL-IN_price-rubl FILL-IN_sum-rubl  FILL-IN_VAT-rubl FILL-IN_sum-rubl-VAT   WITH FRAME Dialog-Frame.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Отмена */
DO:  /* отказ - выход  */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-OK Dialog-Frame
ON CHOOSE OF b-OK IN FRAME Dialog-Frame /* Ввод  */
DO:
  assign FILL-IN_gds-name   FILL-IN_unit-base  FILL-IN_fact-qnty  FILL-IN_price-rubl    FILL-IN_sum-rubl
         FILL-IN_excise     FILL-IN_VAT-pc     FILL-IN_VAT-rubl   FILL-IN_sum-rubl-VAT  FILL-IN_country   FILL-IN_gtd .
  if FILL-IN_gds-name = "" then do:
     message "Не заполнено наименование!" view-as alert-box.
     return no-apply.
  end.
  IF FILL-IN_fact-qnty = 0 then do:
    message  "Кол-во 0!"  view-as alert-box.
    return no-apply.
  end.
  IF FILL-IN_price-rubl = 0 and FILL-IN_sum-rubl-VAT = 0 then do:
    message  "Цена без НДС 0 и/или общая сумма 0!"  view-as alert-box.
    return no-apply.
  end.
  assign
    gds-name     = FILL-IN_gds-name
    unit-base    = FILL-IN_unit-base
    fact-qnty    = FILL-IN_fact-qnty
    price-rubl   = FILL-IN_price-rubl
    sum-rubl     = FILL-IN_sum-rubl
    excise       = FILL-IN_excise
    VAT-pc       = FILL-IN_VAT-pc
    VAT-rubl     = FILL-IN_VAT-rubl
    sum-rubl-VAT = FILL-IN_sum-rubl-VAT
    country      = FILL-IN_country
    gtd          = FILL-IN_gtd
    res          = yes
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-contry
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-contry Dialog-Frame
ON CHOOSE OF r-contry IN FRAME Dialog-Frame
DO:
  /**/
define variable varrid-list as character no-undo.
define variable varrecid    as recid     no-undo.

define buffer bf_country for ub.country.

run ref/countris.w
    (  input parparentproc
      , input "b-sel"
      , input-output varrid-list ) no-error.
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
             error-status :get-message( 1 )
     view-as alert-box.
     return no-apply .
     end.
if varrid-list = '' then return no-apply.
assign
  varrecid = integer(entry(1, varrid-list)).
find first bf_country no-lock where recid(bf_country) = varrecid no-error.
if available bf_country then do:
  assign
      FILL-IN_country   = bf_country.short-name
      .
  display
     FILL-IN_country
     with frame {&frame-name}.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-units
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-units Dialog-Frame
ON CHOOSE OF r-units IN FRAME Dialog-Frame /* r-units */
DO:
define buffer bf-r-units for ub.units.
define variable ref-rec as recid no-undo.

run ref/units.w (input parparentproc, input yes, output ref-rec).
if ref-rec = ? then return no-apply.

find bf-r-units where recid (bf-r-units) = ref-rec no-lock.
assign FILL-IN_unit-base  = bf-r-units.unit-name.
release bf-r-units.
display FILL-IN_unit-base with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


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
  assign
    FILL-IN_gds-name     = gds-name
    FILL-IN_unit-base    = unit-base
    FILL-IN_fact-qnty    = fact-qnty
    FILL-IN_price-rubl   = price-rubl
    FILL-IN_sum-rubl     = sum-rubl
    FILL-IN_excise       = excise
    FILL-IN_VAT-pc       = VAT-pc
    FILL-IN_VAT-rubl     = VAT-rubl
    FILL-IN_sum-rubl-VAT = sum-rubl-VAT
    FILL-IN_country      = country
    FILL-IN_gtd          = gtd
  .

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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY FILL-IN_gds-name FILL-IN_unit-base FILL-IN_fact-qnty
          FILL-IN_price-rubl FILL-IN_sum-rubl FILL-IN_VAT-pc FILL-IN_VAT-rubl
          FILL-IN_excise FILL-IN_sum-rubl-VAT FILL-IN_country FILL-IN_gtd
      WITH FRAME Dialog-Frame.
  ENABLE b-OK RECT-1 b-exit b-calc B-Help FILL-IN_gds-name FILL-IN_unit-base
         FILL-IN_fact-qnty r-units FILL-IN_price-rubl FILL-IN_sum-rubl
         FILL-IN_VAT-pc FILL-IN_VAT-rubl FILL-IN_excise FILL-IN_sum-rubl-VAT
         FILL-IN_country r-contry FILL-IN_gtd
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME