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

Изменение Товарной спецификации к договору

Автор: Чернова Светлана Александровна
Дата создания: 03/23/06
Author: Svetlana Chernova
Creation date: 03/23/06

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-mode  as character no-undo .  /* {&update}, {&lookup} */
define input  parameter p-gds   as integer no-undo .
define input  parameter p-artic as character no-undo .
define input  parameter p-prod  as character no-undo .
define input  parameter p-NAME  as character no-undo .
define input  parameter p-unit-base as character no-undo .
define input-output parameter p-price as decimal   no-undo .
define input-output parameter p-prc   as decimal   no-undo .
define input-output parameter p-prc-2   as decimal   no-undo .
define input-output parameter p-vat-type   as character   no-undo .
define input-output parameter p-qnty   as decimal   no-undo .
define input-output parameter p-cli-base-rate as decimal   no-undo .
define input-output parameter p-vat-pc   as decimal   no-undo .
define input-output parameter p-unit-cli  as character no-undo .
define input-output parameter p-unit-cli-ord  as character no-undo .
define input-output parameter p-cli-base-rate-ord as decimal   no-undo .
define input-output parameter p-unit-cli-rcv  as character no-undo .
define input-output parameter p-cli-base-rate-rcv as decimal   no-undo .
define input-output parameter p-bonus        as decimal   no-undo .
define input-output parameter p-retro-bonus   as character no-undo .
define output parameter p-res   as logical   no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Изменение Товарной спецификации к договору" .
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }
{ gbl/getcntxt.i def }
{ cmp/library.i  }

define variable g-log      as logical   no-undo .
define buffer buf_goods for ub.goods  .
assign p-res = no .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ext-artic

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH ext-artic SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ext-artic SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ext-artic
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ext-artic


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-bonus b-help FILL-prc FILL-prc-2 ~
FILL-bonus vat-type FILL-VAT-pc fi-unit-cli b-units FILL-cli-base-rate ~
FILL-price FILL-qnty fi-unit-cli-ord b-units-ord fi-cli-base-rate-ord ~
fi-unit-cli-rcv b-units-rcv fi-cli-base-rate-rcv FILL-1 FILL-2 FILL-3 ~
FILL-unit-base
&Scoped-Define DISPLAYED-OBJECTS FILL-prc FILL-prc-2 FILL-bonus vat-type ~
FILL-VAT-pc fi-unit-cli FILL-cli-base-rate FILL-price FILL-qnty ~
fi-unit-cli-ord fi-cli-base-rate-ord fi-unit-cli-rcv fi-cli-base-rate-rcv ~
FILL-1 FILL-2 FILL-3 FILL-unit-base v-qnty-ord v-price-cli-ord v-qnty-rcv ~
v-price-cli-rcv

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-bonus
     LABEL "&Бонусы"
     SIZE 10 BY 1 TOOLTIP "Параметры расчета ретро-бонусов"
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-units
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-units"
     SIZE 3 BY 1.

DEFINE BUTTON b-units-ord
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-units"
     SIZE 3 BY 1.

DEFINE BUTTON b-units-rcv
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-units"
     SIZE 3 BY 1.

DEFINE VARIABLE vat-type AS CHARACTER FORMAT "x(8)"
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEMS "нет НДС","с НДС","без НДС"
     DROP-DOWN-LIST
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE fi-cli-base-rate-ord LIKE ext-artic.cli-base-rate
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE fi-cli-base-rate-rcv LIKE ext-artic.cli-base-rate
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE fi-unit-cli AS CHARACTER FORMAT "X(3)"
     LABEL "Ед.изм в накладной"
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     FGCOLOR 4 .

DEFINE VARIABLE fi-unit-cli-ord AS CHARACTER FORMAT "X(3)"
     LABEL "Ед.изм в заказе"
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     FGCOLOR 4 .

DEFINE VARIABLE fi-unit-cli-rcv AS CHARACTER FORMAT "X(3)"
     LABEL "Ед.изм в поставке"
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     FGCOLOR 4 .

DEFINE VARIABLE FILL-1 AS CHARACTER FORMAT "X(256)":U
     LABEL "Артикул"
      VIEW-AS TEXT
     SIZE 15.5 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-2 AS CHARACTER FORMAT "X(256)":U
     LABEL "Производитель"
      VIEW-AS TEXT
     SIZE 40 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-3 AS CHARACTER FORMAT "X(256)":U
     LABEL "Наименование"
      VIEW-AS TEXT
     SIZE 65.38 BY .83 NO-UNDO.

DEFINE VARIABLE FILL-bonus AS DECIMAL FORMAT "->>9.99":U INITIAL 0
     LABEL "Бонус %"
     VIEW-AS FILL-IN
     SIZE 13.25 BY 1 TOOLTIP "Бонус - для ценообразования по Контрагенту" NO-UNDO.

DEFINE VARIABLE FILL-cli-base-rate AS DECIMAL FORMAT ">>,>>9.<<<<":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Коэффициент" NO-UNDO.

DEFINE VARIABLE FILL-prc AS DECIMAL FORMAT "->>9.99":U INITIAL 0
     LABEL "Допустиммый % отклонения от спецификации в большую сторону"
     VIEW-AS FILL-IN
     SIZE 13.25 BY 1 TOOLTIP "Допустиммый % отклонения от суммы спецификации" NO-UNDO.

DEFINE VARIABLE FILL-prc-2 AS DECIMAL FORMAT "->>9.99":U INITIAL 0
     LABEL "Допустиммый % отклонения от спецификации в меньшую сторону"
     VIEW-AS FILL-IN
     SIZE 13.25 BY 1 TOOLTIP "Допустиммый % отклонения от суммы спецификации" NO-UNDO.

DEFINE VARIABLE FILL-price AS DECIMAL FORMAT ">,>>>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 21 BY 1 TOOLTIP "Цена поставщика за ед.изм.накладной в валюте договора" NO-UNDO.

DEFINE VARIABLE FILL-qnty AS DECIMAL FORMAT ">>>,>>>,>>9.<<<":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 18.5 BY 1 TOOLTIP "Количество по накладной в едизм Поставщика" NO-UNDO.

DEFINE VARIABLE FILL-unit-base AS CHARACTER FORMAT "X(3)":U
     LABEL "Базовая"
      VIEW-AS TEXT
     SIZE 7 BY .67 TOOLTIP "Единица измерения из карточки товара"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-VAT-pc AS DECIMAL FORMAT ">9.9":U INITIAL 0
     LABEL "НДС"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE v-price-cli-ord AS DECIMAL FORMAT ">,>>>,>>>,>>9.99":U INITIAL 0
      VIEW-AS TEXT
     SIZE 21 BY .67 TOOLTIP "Цена поставщика за ед.изм. в заказе в валюте договора" NO-UNDO.

DEFINE VARIABLE v-price-cli-rcv AS DECIMAL FORMAT ">,>>>,>>>,>>9.99":U INITIAL 0
      VIEW-AS TEXT
     SIZE 21 BY .67 TOOLTIP "Цена поставщика за ед.изм. в поставке в валюте договора" NO-UNDO.

DEFINE VARIABLE v-qnty-ord AS DECIMAL FORMAT ">>>,>>>,>>9.<<<":U INITIAL 0
      VIEW-AS TEXT
     SIZE 18.5 BY .67 TOOLTIP "Количество в заказе в едизм Поставщика" NO-UNDO.

DEFINE VARIABLE v-qnty-rcv AS DECIMAL FORMAT ">>>,>>>,>>9.<<<":U INITIAL 0
      VIEW-AS TEXT
     SIZE 18.5 BY .67 TOOLTIP "Количество в поставке в едизм Поставщика" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      ext-artic SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-bonus AT ROW 1 COL 21 WIDGET-ID 10
     b-help AT ROW 1 COL 73
     FILL-prc AT ROW 4.5 COL 1
     FILL-prc-2 AT ROW 6 COL 1 WIDGET-ID 74
     FILL-bonus AT ROW 7 COL 1.88 WIDGET-ID 72
     vat-type AT ROW 8.21 COL 14.88 COLON-ALIGNED NO-LABEL
     FILL-VAT-pc AT ROW 8.25 COL 5.13 COLON-ALIGNED
     fi-unit-cli AT ROW 11.92 COL 20.38 COLON-ALIGNED WIDGET-ID 32
     b-units AT ROW 11.92 COL 29.5 WIDGET-ID 30
     FILL-cli-base-rate AT ROW 11.92 COL 30.63 COLON-ALIGNED NO-LABEL
     FILL-price AT ROW 11.92 COL 39.13 COLON-ALIGNED NO-LABEL
     FILL-qnty AT ROW 11.92 COL 61.63 COLON-ALIGNED NO-LABEL
     fi-unit-cli-ord AT ROW 13.04 COL 20.38 COLON-ALIGNED WIDGET-ID 44
     b-units-ord AT ROW 13.04 COL 29.5 WIDGET-ID 40
     fi-cli-base-rate-ord AT ROW 13.04 COL 30.63 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 42
     fi-unit-cli-rcv AT ROW 14.21 COL 20.38 COLON-ALIGNED WIDGET-ID 54
     b-units-rcv AT ROW 14.21 COL 29.5 WIDGET-ID 50
     fi-cli-base-rate-rcv AT ROW 14.21 COL 30.63 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 52
     FILL-1 AT ROW 2.21 COL 8.88 COLON-ALIGNED
     FILL-2 AT ROW 2.21 COL 27
     FILL-3 AT ROW 3.42 COL 14.63 COLON-ALIGNED
     FILL-unit-base AT ROW 10.92 COL 20.38 COLON-ALIGNED WIDGET-ID 6
     v-qnty-ord AT ROW 13.13 COL 61.75 COLON-ALIGNED NO-LABEL WIDGET-ID 66
     v-price-cli-ord AT ROW 13.17 COL 39.25 COLON-ALIGNED NO-LABEL WIDGET-ID 64
     v-qnty-rcv AT ROW 14.25 COL 61.75 COLON-ALIGNED NO-LABEL WIDGET-ID 70
     v-price-cli-rcv AT ROW 14.29 COL 39.25 COLON-ALIGNED NO-LABEL WIDGET-ID 68
     "%" VIEW-AS TEXT
          SIZE 1.75 BY .67 AT ROW 8.38 COL 14.63
     "Единицы измерения                      Цена                  Количество" VIEW-AS TEXT
          SIZE 79 BY 1 AT ROW 9.58 COL 3 WIDGET-ID 4
          BGCOLOR 3 FGCOLOR 15
     SPACE(2.12) SKIP(7.54)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Изменение спецификации"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


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

/* SETTINGS FOR FILL-IN fi-cli-base-rate-ord IN FRAME Dialog-Frame
   LIKE = ub.ext-artic.cli-base-rate EXP-SIZE                           */
/* SETTINGS FOR FILL-IN fi-cli-base-rate-rcv IN FRAME Dialog-Frame
   LIKE = ub.ext-artic.cli-base-rate EXP-SIZE                           */
/* SETTINGS FOR FILL-IN FILL-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-bonus IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-prc IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-prc-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       FILL-unit-base:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-price-cli-ord IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-price-cli-rcv IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-qnty-ord IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-qnty-rcv IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.ext-artic"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Изменение спецификации */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:  /* отказ - выход  */
  if p-mode = {&update} then do:
    assign FILL-price FILL-prc FILL-prc-2 vat-type FILL-qnty FILL-vat-pc FILL-cli-base-rate fi-unit-cli  fi-unit-cli-ord fi-unit-cli-rcv fi-cli-base-rate-ord fi-cli-base-rate-rcv  FILL-bonus .

    assign
      p-res   = yes
      p-price = FILL-price
      p-prc   = FILL-prc
      p-prc-2   = FILL-prc-2
      p-vat-type = vat-type
      p-qnty     = FILL-qnty
      p-cli-base-rate = FILL-cli-base-rate
      p-vat-pc = FILL-vat-pc
      p-unit-cli = fi-unit-cli
      p-unit-cli-ord      = fi-unit-cli-ord
      p-unit-cli-rcv      = fi-unit-cli-rcv
      p-cli-base-rate-ord = fi-cli-base-rate-ord
      p-cli-base-rate-rcv = fi-cli-base-rate-rcv
      p-bonus = FILL-bonus
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-units
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-units Dialog-Frame
ON choose OF b-units IN FRAME Dialog-Frame /* b-units */
do:
  { gbl/stdbtn.i }

  define buffer buf_units for ub.units.
  define variable v-ret-unit-name  as character no-undo .
  define variable v-ret-unit-coeff as decimal no-undo .  
  run ref/alt-units.w (input parparentproc,
                       input {&select},
                       input p-gds,
                       input "", /* ограничение списка выбора */
                       output v-ret-unit-name,
                       output v-ret-unit-coeff) . 
  if v-ret-unit-name > "" then do :
    if can-find (first buf_units where buf_units.unit-name = v-ret-unit-name) then do :
      assign
      fi-unit-cli        = v-ret-unit-name
      FILL-cli-base-rate = v-ret-unit-coeff
      .
      display fi-unit-cli FILL-cli-base-rate with FRAME Dialog-Frame.
      apply "entry":U to FILL-cli-base-rate .
    end .
  end .
  else return no-apply .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-units-ord
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-units-ord Dialog-Frame
ON choose OF b-units-ord IN FRAME Dialog-Frame /* b-units */
do:
  { gbl/stdbtn.i }

  define buffer buf_units for ub.units.
  define variable ref-rec as recid no-undo.
  run ref/units.w (input parparentproc, input yes, output ref-rec).
  if ref-rec = ? then return no-apply.
  find buf_units where recid (buf_units) = ref-rec no-lock.
  assign fi-unit-cli-ord  = buf_units.unit-name.
  display fi-unit-cli-ord with FRAME Dialog-Frame.
  apply "entry":U to fi-cli-base-rate-ord .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-units-rcv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-units-rcv Dialog-Frame
ON choose OF b-units-rcv IN FRAME Dialog-Frame /* b-units */
do:
  { gbl/stdbtn.i }

  define buffer buf_units for ub.units.
  define variable ref-rec as recid no-undo.
  run ref/units.w (input parparentproc, input yes, output ref-rec).
  if ref-rec = ? then return no-apply.
  find buf_units where recid (buf_units) = ref-rec no-lock.
  assign fi-unit-cli-rcv  = buf_units.unit-name.
  display fi-unit-cli-rcv with FRAME Dialog-Frame.
  apply "entry":U to fi-cli-base-rate-rcv .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-unit-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-unit-cli Dialog-Frame
ON leave OF fi-unit-cli IN FRAME Dialog-Frame /* Ед.изм в накладной */
do:
find ub.units where ub.units.unit-name = input frame Dialog-Frame fi-unit-cli no-lock no-error.
  if not available ub.units then do:
    message "Неправильная единица измерения поставщика." view-as alert-box.
    display fi-unit-cli with FRAME Dialog-Frame.
    apply "choose" to b-units.
    return no-apply.
  end.
  assign frame Dialog-Frame fi-unit-cli.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-unit-cli Dialog-Frame
ON return OF fi-unit-cli IN FRAME Dialog-Frame /* Ед.изм в накладной */
do:
  apply "entry" to FILL-cli-base-rate in frame Dialog-Frame.
  return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-unit-cli-ord
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-unit-cli-ord Dialog-Frame
ON leave OF fi-unit-cli-ord IN FRAME Dialog-Frame /* Ед.изм в заказе */
do:
  find ub.units where ub.units.unit-name = input frame Dialog-Frame fi-unit-cli-ord no-lock no-error.
  if not available ub.units then do:
    message "Неправильная единица измерения поставщика." view-as alert-box.
    display fi-unit-cli-ord with FRAME Dialog-Frame.
    apply "choose" to b-units-ord.
    return no-apply.
  end.
  assign frame Dialog-Frame fi-unit-cli-ord.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-unit-cli-ord Dialog-Frame
ON return OF fi-unit-cli-ord IN FRAME Dialog-Frame /* Ед.изм в заказе */
do:
  apply "entry" to fi-cli-base-rate-ord in frame Dialog-Frame.
  return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-bonus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-bonus Dialog-Frame
ON CHOOSE OF b-bonus IN FRAME Dialog-Frame /* b-bonus */
DO:

   run str\cont-bns.w
     ( input parParentProc,
       input 0,
       input 0,
       input 0,
       input-output p-retro-bonus
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-unit-cli-rcv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-unit-cli-rcv Dialog-Frame
ON leave OF fi-unit-cli-rcv IN FRAME Dialog-Frame /* Ед.изм в поставке */
do:
  find ub.units where ub.units.unit-name = input frame Dialog-Frame fi-unit-cli-rcv no-lock no-error.
  if not available ub.units then do:
    message "Неправильная единица измерения поставщика." view-as alert-box.
    display fi-unit-cli-rcv with FRAME Dialog-Frame.
    apply "choose" to b-units-rcv.
    return no-apply.
  end.
  assign frame Dialog-Frame fi-unit-cli-rcv.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-unit-cli-rcv Dialog-Frame
ON return OF fi-unit-cli-rcv IN FRAME Dialog-Frame /* Ед.изм в поставке */
do:
  apply "entry" to fi-cli-base-rate-rcv in frame Dialog-Frame.
  return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME vat-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL vat-type Dialog-Frame
ON VALUE-CHANGED OF vat-type IN FRAME Dialog-Frame
DO:
  assign vat-type .
  if vat-type = {&without-vat} then do:
    assign FILL-vat-pc = 0 .
    DISABLE FILL-VAT-pc WITH FRAME Dialog-Frame.
    display FILL-vat-pc WITH FRAME Dialog-Frame.
  end.
  else do:
    ENABLE FILL-VAT-pc WITH FRAME Dialog-Frame.
    display FILL-vat-pc WITH FRAME Dialog-Frame.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

   VAT-type:LIST-ITEMS in frame {&frame-name} =  {&no-vat} + "," + {&inc-vat} + "," + {&without-vat} .
  assign
     FILL-price = p-price
     FILL-prc   = p-prc
     FILL-prc-2   = p-prc-2
     FILL-1     = p-artic
     FILL-2     = p-prod
     FILL-3     = p-NAME
     vat-type   = p-vat-type
     FILL-qnty  = p-qnty
     FILL-cli-base-rate = p-cli-base-rate
     FILL-vat-pc = p-vat-pc
     FILL-bonus = p-bonus
     fi-unit-cli = p-unit-cli
     FILL-unit-base = p-unit-base
     fi-unit-cli-ord = p-unit-cli-ord
     fi-unit-cli-rcv = p-unit-cli-rcv
     fi-cli-base-rate-ord = p-cli-base-rate-ord
     fi-cli-base-rate-rcv = p-cli-base-rate-rcv
  .
  RUN my_enable_UI.
  if vat-type = {&without-vat} then  DISABLE FILL-VAT-pc WITH FRAME Dialog-Frame.

  WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS FILL-price .
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my_enable_UI Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE my_enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
{ gbl/getcntxt.i get }
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-bonus_work':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  false
  g-log
}
  if g-log then enable b-bonus WITH FRAME Dialog-Frame.
  else hide b-bonus in FRAME Dialog-Frame.

  b-units:visible = (p-gds > 0) .

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY FILL-prc FILL-prc-2 FILL-bonus vat-type FILL-VAT-pc fi-unit-cli
          FILL-cli-base-rate FILL-price FILL-qnty fi-unit-cli-ord
          fi-cli-base-rate-ord fi-unit-cli-rcv fi-cli-base-rate-rcv FILL-1
          FILL-2 FILL-3 FILL-unit-base v-qnty-ord v-price-cli-ord v-qnty-rcv
          v-price-cli-rcv
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help FILL-prc FILL-prc-2 FILL-bonus vat-type
         FILL-VAT-pc FILL-cli-base-rate FILL-price
         FILL-qnty
         fi-unit-cli when b-units:visible
         b-units     when b-units:visible
         fi-unit-cli-ord b-units-ord fi-cli-base-rate-ord
         fi-unit-cli-rcv b-units-rcv fi-cli-base-rate-rcv FILL-1 FILL-2 FILL-3
         FILL-unit-base
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PROC-DISP Dialog-Frame
PROCEDURE PROC-DISP :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

/* display v-price with FRAME page-1 . */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME