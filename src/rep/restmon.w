&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
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

Мониторинг остатков резервуаров и прогноз реализации

Автор: Белоусов Илья Александрович
Дата создания: 09/26/07
Author: Ilia Belousov
Creation date: 09/26/07

Input:

Output:
*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---         */
define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Мониторинг остатков резервуаров и прогноз реализации".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ trg/factord.i    }

DEFINE TEMP-TABLE tt-place NO-UNDO
   field gds-code           like ub.goods.gds-code
   field pl-code            like ub.place.pl-code
   field loc1               like ub.place.loc1
   field gds-name           like ub.goods.gds-name
   field max-qnty           like ub.place.max-qnty

   field curr-qnty          like ub.rvs-line.state-measure-qnty /* из последней сверки текущей смены */
   field curr-qnty-start    like ub.rvs-line.state-measure-qnty /* из последней сверки текущей смены */
   field curr-fact-order    like ub.rvs-doc.fact-order          /* из последней сверки текущей смены */
   field curr-rvs-code      like ub.rvs-doc.rvs-code            /* из последней сверки текущей смены */
   field free-qnty          like ub.rvs-line.state-measure-qnty /* из последней сверки текущей смены */
   field curr-fill          as logical                          /* остаток найден в контрольной сверке */

   field sale-qnty-curr     like ub.rvs-line.state-measure-qnty /* продажи текущей смены на время измерения, по счетчикам ТРК */
   field sale-start-qnty    like ub.rvs-line.state-measure-qnty /* из сменной сверки предыдущей смены, по счетчикам ТРК */
   field sale-fact-order    like ub.rvs-doc.fact-order          /* из последней сверки текущей смены */
   field sale-time          as   integer                        /* из последней сверки текущей смены */
   field sale-rvs-code      like ub.rvs-doc.rvs-code            /* из последней сверки текущей смены */
   field sale-fill            as logical                       /* измерение найдено в контрольной сверке */

   field sale-qnty-prev       like ub.rvs-line.state-measure-qnty /* продажи на конечную точку для смены прогноза, по счетчикам ТРК */
   field sale-start-qnty-prev like ub.rvs-line.state-measure-qnty /* продажи на стартовую точку для смены прогноза, по счетчикам ТРК */
   field sale-end-qnty-prev   like ub.rvs-line.state-measure-qnty /* продажи на стартовую точку для смены прогноза, по счетчикам ТРК */
   field sale-time-prev       as   integer     INITIAL 999999     /* из последней сверки текущей смены */
   field sale-time-prev-end   as   integer     INITIAL 999999     /* из последней сверки текущей смены */


   field hnd                as   HANDLE
   field hnd-top            as   HANDLE
   field hnd-name           as   HANDLE
   field hnd-max-qnty       as   HANDLE
   field hnd-free-qnty      as   HANDLE
   field hnd-qnty           as   HANDLE
index pu as primary unique
      gds-code
      pl-code
index by-fill-sale
      sale-fill
index by-fill-curr
      curr-fill
.

DEFINE TEMP-TABLE tt-gds-pred NO-UNDO
   field gds-code           like ub.goods.gds-code
   field gds-name           like ub.goods.gds-name

   field start-qnty         like ub.rvs-line.state-measure-qnty
   field sale-qnty          like ub.rvs-line.state-measure-qnty
   field curr-qnty          like ub.rvs-line.state-measure-qnty
   field prediction-qnty    like ub.rvs-line.state-measure-qnty
   FIELD delta-time         AS INTEGER
   field count-pl           as integer
   field hnd                as   HANDLE
   field hnd-name           as   HANDLE
   field hnd-sale-qnty      as   HANDLE
   field hnd-qnty           as   HANDLE
   field hnd-pred-qnty      as   HANDLE
   field hnd-total-qnty     as   HANDLE
   field hnd-sale-qnty-l    as   HANDLE
   field hnd-qnty-l         as   HANDLE
   field hnd-pred-qnty-l    as   HANDLE
   field hnd-total-qnty-l   as   HANDLE
   field sale-time          as   integer                        /* из последней сверки текущей смены */
index pu as primary unique
      gds-code
.

define buffer buf_shift-obj   for ub.shift-obj.
define buffer br_tt-place     for tt-place.
define buffer br_tt-gds-pred  for tt-gds-pred.

define variable v-obj-code        as integer      no-undo.
define variable v-obj-type        as character    no-undo.

define variable v-shift-on        as logical no-undo .
define variable v-count-place     as integer      no-undo.
define variable v-max-qnty        as decimal      no-undo.
define variable v-rid-list        as character    no-undo.

/* текущая смена */
DEFINE VARIABLE v-shift-date      AS DATE NO-UNDO.
DEFINE VARIABLE v-shift-num       AS INTEGER NO-UNDO.
define variable v-meas-time       as integer      no-undo.
define variable v-meas-date       as date      no-undo.

/* смена предыдущая текущей */
DEFINE VARIABLE v-shift-date-prev AS DATE NO-UNDO.
DEFINE VARIABLE v-shift-num-prev  AS INTEGER NO-UNDO.

/* смена для прогноза */
DEFINE VARIABLE v-shift-date-prediction AS DATE    NO-UNDO.
DEFINE VARIABLE v-end-time-prediction   AS integer NO-UNDO.
DEFINE VARIABLE v-end-time-prediction-shift   AS integer NO-UNDO.
DEFINE VARIABLE v-start-time-prediction AS integer NO-UNDO.
define variable v-curr-date             as date    no-undo.


define variable v-browser    as logical      no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-3

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES br_tt-place br_tt-gds-pred

/* Definitions for BROWSE BROWSE-3                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-3 br_tt-place.gds-name br_tt-place.loc1 br_tt-place.max-qnty br_tt-place.curr-qnty (br_tt-place.max-qnty - br_tt-place.curr-qnty)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-3
&Scoped-define SELF-NAME BROWSE-3
&Scoped-define QUERY-STRING-BROWSE-3 FOR EACH br_tt-place
&Scoped-define OPEN-QUERY-BROWSE-3 OPEN QUERY {&SELF-NAME} FOR EACH br_tt-place.
&Scoped-define TABLES-IN-QUERY-BROWSE-3 br_tt-place
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-3 br_tt-place


/* Definitions for BROWSE BROWSE-4                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-4 br_tt-gds-pred.gds-name br_tt-gds-pred.curr-qnty br_tt-gds-pred.sale-qnty br_tt-gds-pred.prediction-qnty STRING(br_tt-gds-pred.sale-time, "HH:MM") br_tt-gds-pred.delta-time
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-4
&Scoped-define SELF-NAME BROWSE-4
&Scoped-define QUERY-STRING-BROWSE-4 FOR EACH br_tt-gds-pred
&Scoped-define OPEN-QUERY-BROWSE-4 OPEN QUERY {&SELF-NAME} FOR EACH br_tt-gds-pred.
&Scoped-define TABLES-IN-QUERY-BROWSE-4 br_tt-gds-pred
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-4 br_tt-gds-pred


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-3}~
    ~{&OPEN-QUERY-BROWSE-4}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-help RECT-1 RECT-2 BROWSE-3 ~
v-date-prediction b-sale rs-prediction b-shift BROWSE-4
&Scoped-Define DISPLAYED-OBJECTS v-date-prediction rs-prediction ~
v-hour-prediction v-minute-prediction v-shift-num-prediction

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sale
     LABEL "&Реализация"
     SIZE 12 BY 1.

DEFINE BUTTON b-shift
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Button 2"
     SIZE 3 BY 1.

DEFINE VARIABLE v-date-prediction AS DATE FORMAT "99/99/99":U
     LABEL "Сменная дата для прогноза"
     VIEW-AS FILL-IN
     SIZE 9.5 BY 1 DROP-TARGET NO-UNDO.

DEFINE VARIABLE v-hour-prediction AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE v-minute-prediction AS INTEGER FORMAT "99":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE v-shift-num-prediction AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Порядок смены прогноза"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE rs-prediction AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "На конец смены", 1,
"На конкретное время", 2
     SIZE 21.5 BY 1.5 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 94 BY 10.75.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 94 BY 7.5.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-3 FOR
      br_tt-place SCROLLING.

DEFINE QUERY BROWSE-4 FOR
      br_tt-gds-pred SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-3 Dialog-Frame _FREEFORM
  QUERY BROWSE-3 DISPLAY
      br_tt-place.gds-name FORMAT "x(40)" COLUMN-LABEL "Топливо"
 br_tt-place.loc1                        COLUMN-LABEL "Резервуар"
 br_tt-place.max-qnty
 br_tt-place.curr-qnty             COLUMN-LABEL "Текущее количество"
 (br_tt-place.max-qnty - br_tt-place.curr-qnty)             COLUMN-LABEL "Свободно"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 94 BY 10.5 EXPANDABLE.

DEFINE BROWSE BROWSE-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-4 Dialog-Frame _FREEFORM
  QUERY BROWSE-4 DISPLAY
      br_tt-gds-pred.gds-name FORMAT "x(40)" COLUMN-LABEL "Топливо"
br_tt-gds-pred.curr-qnty COLUMN-LABEL "Остаток"
br_tt-gds-pred.sale-qnty COLUMN-LABEL "Реализация"
br_tt-gds-pred.prediction-qnty COLUMN-LABEL "Прогноз"
STRING(br_tt-gds-pred.sale-time, "HH:MM") FORMAT "x(6)" COLUMN-LABEL "измер.":C6
br_tt-gds-pred.delta-time FORMAT ">>>>9" COLUMN-LABEL "мин+/-"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS NO-TAB-STOP SIZE 94 BY 7.25 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-help AT ROW 1 COL 89
     BROWSE-3 AT ROW 2.5 COL 2.5
     v-date-prediction AT ROW 13.25 COL 27.5 COLON-ALIGNED
     b-sale AT ROW 13.25 COL 84.5
     rs-prediction AT ROW 13.5 COL 53 NO-LABEL
     v-hour-prediction AT ROW 14.08 COL 73.5 COLON-ALIGNED NO-LABEL
     v-minute-prediction AT ROW 14.08 COL 79 COLON-ALIGNED
     v-shift-num-prediction AT ROW 14.25 COL 27.5 COLON-ALIGNED
     b-shift AT ROW 14.25 COL 36
     BROWSE-4 AT ROW 15.5 COL 2.5
     "Тип прогноза:" VIEW-AS TEXT
          SIZE 13.5 BY .67 AT ROW 13.5 COL 39.5
     RECT-1 AT ROW 2.5 COL 2.5
     RECT-2 AT ROW 15.5 COL 2.5
     SPACE(2.50) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Мониторинг остатков резервуаров и прогноз реализации"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-3 RECT-2 Dialog-Frame */
/* BROWSE-TAB BROWSE-4 b-shift Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN v-hour-prediction IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-minute-prediction IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-shift-num-prediction IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-3
/* Query rebuild information for BROWSE BROWSE-3
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH br_tt-place.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-3 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-4
/* Query rebuild information for BROWSE BROWSE-4
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH br_tt-gds-pred.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-4 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Мониторинг остатков резервуаров и прогноз реализации */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&Scoped-define SELF-NAME b-sale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sale Dialog-Frame
ON CHOOSE OF b-sale IN FRAME Dialog-Frame /* Реализация */
DO:
   define variable v-shift-list    as character    no-undo.
   define buffer buf_shift-obj      for ub.shift-obj.

   run rep/restsale.w ( parparentproc
                  , v-obj-type
                  , v-obj-code
                  , v-date-prediction
                  , v-start-time-prediction
                  , v-date-prediction
                  , v-end-time-prediction
                  ) NO-ERROR.
   if error-status :error
   then do:
      message
         vss-workfile vss-revision vss-description skip
         "Ошибка при вызове процедуры расчета продаж за интервал restsale.w" skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-shift
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-shift Dialog-Frame
ON CHOOSE OF b-shift IN FRAME Dialog-Frame /* Button 2 */
DO:
   run select-shift in this-procedure .

   run del-prediction in this-procedure .
   run fill-prediction in this-procedure .
   run draw-pred in this-procedure .
   run enable_UI IN THIS-PROCEDURE.
   IF v-browser then do:
      run show-browser  in this-procedure.
   end.
   else do:
      run show-histogramm in this-procedure.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-3
&Scoped-define SELF-NAME BROWSE-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-3 Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BROWSE-3 IN FRAME Dialog-Frame
DO:
   run show-histogramm in this-procedure.
   assign
      v-browser = FALSE
   .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-4
&Scoped-define SELF-NAME BROWSE-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-4 Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BROWSE-4 IN FRAME Dialog-Frame
DO:
   run show-histogramm in this-procedure.
   assign
      v-browser = FALSE
   .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RECT-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RECT-1 Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF RECT-1 IN FRAME Dialog-Frame
DO:
  run show-browser  in this-procedure.
   assign
      v-browser = TRUE
   .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RECT-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RECT-2 Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF RECT-2 IN FRAME Dialog-Frame
DO:
  run show-browser  in this-procedure.
   assign
      v-browser = TRUE
   .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-prediction
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-prediction Dialog-Frame
ON VALUE-CHANGED OF rs-prediction IN FRAME Dialog-Frame
DO:
   ASSIGN
     rs-prediction
   .
   CASE rs-prediction:
      WHEN 1 THEN DO:
         DISABLE v-hour-prediction
               v-minute-prediction
         with frame {&frame-name}.
         assign
            v-end-time-prediction = v-end-time-prediction-shift
         .

         /* !!! */
      END.
      OTHERWISE DO:
         ENABLE v-hour-prediction
               v-minute-prediction
         with frame {&frame-name}.
         ASSIGN
            v-end-time-prediction = v-hour-prediction * 60 * 60 + v-minute-prediction * 60
         .
      END.
   END CASE.

   run del-prediction   in this-procedure .
   run fill-prediction  in this-procedure .
   run draw-pred        in this-procedure .

   run enable_UI IN THIS-PROCEDURE.

   IF v-browser then do:
      run show-browser  in this-procedure.
   end.
   else do:
      run show-histogramm in this-procedure.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-date-prediction
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-date-prediction Dialog-Frame
ON LEAVE OF v-date-prediction IN FRAME Dialog-Frame /* Сменная дата для прогноза */
DO:
  ASSIGN
      v-date-prediction
  .
  run find-date-shift in this-procedure
      ( input v-obj-type
      , input v-obj-code
      , input v-date-prediction
      , input v-start-time-prediction
      , output v-shift-date-prediction
      , output v-shift-num-prediction
      ) .

   run del-prediction   in this-procedure .
   run fill-prediction  in this-procedure .
   run draw-pred        in this-procedure .

   run enable_UI IN THIS-PROCEDURE.
   IF v-browser then do:
      run show-browser  in this-procedure.
   end.
   else do:
      run show-histogramm in this-procedure.
   end.
   DISPLAY v-shift-num-prediction
   WITH FRAME Dialog-Frame.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-hour-prediction
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-hour-prediction Dialog-Frame
ON LEAVE OF v-hour-prediction IN FRAME Dialog-Frame
DO:
   ASSIGN
      v-hour-prediction
   .
   run mandatory-24 IN THIS-PROCEDURE
      (INPUT-OUTPUT v-hour-prediction ) .
   ASSIGN
       v-end-time-prediction = v-hour-prediction * 60 * 60 + v-minute-prediction * 60
   .

   run del-prediction   in this-procedure .
   run fill-prediction in this-procedure .
   run draw-pred in this-procedure .

   run enable_UI IN THIS-PROCEDURE.
   IF v-browser then do:
      run show-browser  in this-procedure.
   end.
   else do:
      run show-histogramm in this-procedure.
   end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-minute-prediction
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-minute-prediction Dialog-Frame
ON LEAVE OF v-minute-prediction IN FRAME Dialog-Frame
DO:
   ASSIGN
      v-minute-prediction
   .
   run mandatory-60 IN THIS-PROCEDURE
      (INPUT-OUTPUT v-minute-prediction ) .
   ASSIGN
         v-end-time-prediction = v-hour-prediction * 60 * 60 + v-minute-prediction * 60
   .

   run del-prediction   in this-procedure .
   run fill-prediction in this-procedure .
   run draw-pred in this-procedure .

   run enable_UI IN THIS-PROCEDURE.
   IF v-browser then do:
      run show-browser  in this-procedure.
   end.
   else do:
      run show-histogramm in this-procedure.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-3
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/getcntxt.i GET }

{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

   assign
      v-browser = TRUE
   .
   IF v-cntxt-db-num = 0 then do:
      define buffer buf_clients     for ub.clients.

    define variable v-ok    as logical      no-undo.
    run gbl/userobjs.w
      (input  parparentproc          /* parparentproc        */
      ,input  this-procedure :handle /* p-callback-handle    */
      ,input  v-cntxt-db-num               /* p-db-num             */
      ,input  v-cntxt-userid              /* p-user-id            */
      ,input  v-cntxt-host-code-obj        /* p-curr-host-code-obj */
      ,input  v-cntxt-obj-type             /* p-curr-obj-type      */
      ,input  v-cntxt-obj-code             /* p-curr-obj-code      */
      ,INPUT  "b-sel"                /* p-bttn               */
      ,output v-ok          /* p-user-select        */
      ,output v-obj-type      /* p-select-obj-type    */
      ,output v-obj-code      /* p-select-obj-code    */
      ) NO-ERROR.
      if error-status :error
      then do:
         message
            vss-workfile vss-revision vss-description skip
            "Ошибка при выборе объекта" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
         return.
      end.
      IF NOT v-ok THEN dO:
         message
            "Пользователь отказался от выбора объекта" skip
            view-as alert-box error .
         return.
      end.
   end.
   else do:
      assign
            v-obj-type = v-cntxt-obj-type
            v-obj-code = v-cntxt-obj-code
      .
   end.

   { gbl/objat.i
   v-obj-type
   v-obj-code
   "'shift-on=request'"
   v-shift-on
   no-error
   }

   if error-status :error then do:
      message
         vss-workfile vss-revision vss-description skip
         "Ошибка при запуске процедуры objat" skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
      return.
   end.

   if not v-shift-on then do:
      message
         vss-workfile vss-revision vss-description skip
         "На объекте выключены смены." skip
         "Работа со сменами невозможна." skip
         "Объект:" v-obj-type v-obj-code skip
         view-as alert-box error .
      return.
   end.

   find first buf_shift-obj
        where buf_shift-obj.obj-type = v-obj-type
          and buf_shift-obj.obj-code = v-obj-code
          and buf_shift-obj.status_  = {&sht-current}
        no-lock
        no-error
        .
   IF not available buf_shift-obj then do:
      message
         "На объекте" v-obj-type v-obj-code skip
         "Не найдена текущая смена" skip
         view-as alert-box error .
      return.
   end.

   { gbl/curobjdt.i
     v-obj-type
     v-obj-code
     v-curr-date
   }

   assign
      v-date-prediction = v-curr-date - 7
      v-shift-date      = buf_shift-obj.shift-date
      v-shift-num       = buf_shift-obj.shift-num
   .
   release buf_shift-obj.
   FIND LAST  buf_shift-obj
        WHERE buf_shift-obj.obj-type = v-obj-type
          AND buf_shift-obj.obj-code = v-obj-code
          AND buf_shift-obj.shift-date = v-date-prediction
          AND buf_shift-obj.shift-num  = v-shift-num
   no-lock
   no-error.
   IF AVAILABLE buf_shift-obj then do:
      assign
         v-shift-num-prediction = v-shift-num
      .
   end.

   release buf_shift-obj.
   FIND LAST  buf_shift-obj
        WHERE buf_shift-obj.obj-type = v-obj-type
          AND buf_shift-obj.obj-code = v-obj-code
          AND ((    buf_shift-obj.shift-date = v-shift-date
                AND buf_shift-obj.shift-num  < v-shift-num
               )
               OR   buf_shift-obj.shift-date < v-shift-date
              )
        use-index pi
        no-lock
        NO-ERROR.
   if available buf_shift-obj then do:
      assign
         v-shift-date-prev = buf_shift-obj.shift-date
         v-shift-num-prev  = buf_shift-obj.shift-num
      .
   end.
   else do:
      message
         "На объекте" v-obj-type v-obj-code skip
         "Нет закрытых смен" skip
         view-as alert-box error .
      return.
   end.
   release buf_shift-obj.

   run fill-place in this-procedure .
   run fill-sale in this-procedure .
   RUN find-date-shift in this-procedure
         ( input v-obj-type
         , input v-obj-code
         , input v-date-prediction
         , input v-start-time-prediction
         , output v-shift-date-prediction
         , output v-shift-num-prediction
         ) .

   define variable v-sec    as integer      no-undo.
   assign
      v-sec = v-start-time-prediction MOD 60
      v-minute-prediction = ((v-start-time-prediction - v-sec) / 60) mod 60
      v-hour-prediction   = (((v-start-time-prediction - v-sec) / 60) - v-minute-prediction) / 60
   .
   IF v-shift-num-prediction = 0
   THEN DO:
      message
         "Не существует смены недельной давности, требуемой для прогноза."
         skip "Выберите смену для прогноза."
      view-as alert-box information.
      run select-shift in this-procedure .
   END.

   run fill-prediction in this-procedure .
   run draw-place in this-procedure .
   run draw-pred in this-procedure .

   run enable_UI.
   WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE del-prediction Dialog-Frame
PROCEDURE del-prediction :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_tt-place    for tt-place.
define buffer buf_tt-gds-pred for tt-gds-pred.

do
on error undo, return error
:
   for each buf_tt-place
      :
      assign
         buf_tt-place.sale-start-qnty-prev = 0.0
         buf_tt-place.sale-end-qnty-prev   = 0.0
         buf_tt-place.sale-qnty-prev       = 0.0
         buf_tt-place.sale-time-prev       = 999999
         buf_tt-place.sale-time-prev-end   = 999999
      .
   end. /* each buf_tt-place */

   FOR EACH buf_tt-gds-pred
       :

      assign
         buf_tt-gds-pred.prediction-qnty  = 0.0
      .
      DELETE OBJECT buf_tt-gds-pred.hnd .
      DELETE OBJECT buf_tt-gds-pred.hnd-name .
      DELETE OBJECT buf_tt-gds-pred.hnd-sale-qnty .
      DELETE OBJECT buf_tt-gds-pred.hnd-qnty .
      DELETE OBJECT buf_tt-gds-pred.hnd-pred-qnty .
      DELETE OBJECT buf_tt-gds-pred.hnd-total-qnty .
      DELETE OBJECT buf_tt-gds-pred.hnd-sale-qnty-l .
      DELETE OBJECT buf_tt-gds-pred.hnd-qnty-l .
      DELETE OBJECT buf_tt-gds-pred.hnd-pred-qnty-l .
      DELETE OBJECT buf_tt-gds-pred.hnd-total-qnty-l .

   end. /* last-of */
end.
END PROCEDURE. /* del-prediction */

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE draw-place Dialog-Frame
PROCEDURE draw-place :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-frame-width    as integer      no-undo.
define variable v-frame-left     as integer      no-undo.
define variable v-frame-bottom   as integer      no-undo.
define variable v-frame-top   as integer      no-undo.
define variable v-step    as integer      no-undo.

define variable v-rect-width    as integer      no-undo.
define variable v-c    as integer      no-undo.
DEFINE VARIABLE  but1  AS HANDLE.

define buffer buf_tt-place    for tt-place.

do
on error undo, return error
:
   assign
      v-frame-width  = RECT-1:width IN FRAME Dialog-Frame
      v-frame-left   = 0.5 + RECT-1:column   IN FRAME Dialog-Frame
      v-frame-top    = 2 + RECT-1:row      IN FRAME Dialog-Frame
      v-rect-width   = (v-frame-width - 2 ) / v-count-place
      v-frame-bottom = RECT-1:row          IN FRAME Dialog-Frame + RECT-1:height   IN FRAME Dialog-Frame
      v-step         = DECIMAL( v-max-qnty / (RECT-1:height IN FRAME Dialog-Frame - 3))
   .

   FOR EACH buf_tt-place:
      assign
         v-c = v-c + 1
      .
      /* !!! max и qnty ед. изм  */
      /* empty-qnty */
      CREATE RECTANGLE buf_tt-place.hnd-top
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - 1)
             ROW           = v-frame-top + DECIMAL(( v-max-qnty - buf_tt-place.max-qnty) / v-step)
             WIDTH         = v-rect-width
             HEIGHT        = IF DECIMAL((buf_tt-place.max-qnty) / v-step ) <= 0 THEN 0.1 ELSE DECIMAL((buf_tt-place.max-qnty) / v-step )
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             FILLED        = TRUE
      .
      CREATE RECTANGLE buf_tt-place.hnd
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - 1)
             ROW           = v-frame-top + DECIMAL(( v-max-qnty - buf_tt-place.curr-qnty) / v-step)
             WIDTH         = v-rect-width
             HEIGHT        = IF DECIMAL((buf_tt-place.curr-qnty) / v-step ) <= 0.1 THEN 0.1 ELSE DECIMAL((buf_tt-place.curr-qnty) / v-step )
             BGCOLOR       = (v-c - 1)
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
      .

      CREATE TEXT buf_tt-place.hnd-name
      ASSIGN COLUMN             = v-frame-left + v-rect-width * (v-c - 1)
             row           = RECT-1:ROW + 0.2
             FGCOLOR       = (v-c - 1)
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 15
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = buf_tt-place.gds-name
      .
      CREATE TEXT buf_tt-place.hnd-max-qnty
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - 1) + 1
             ROW           = MINIMUM( buf_tt-place.hnd-top:ROW - 0.7, buf_tt-place.hnd:ROW - 1.4)
             FGCOLOR       = (v-c - 1)
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 9
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = SUBSTITUTE("Max &1", buf_tt-place.max-qnty)
      .
      CREATE TEXT buf_tt-place.hnd-qnty
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - 1) + 1
             ROW           = buf_tt-place.hnd:ROW - 0.7
             FGCOLOR       = (v-c - 1)
             BGCOLOR       = 15
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 9
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = SUBSTITUTE("Тек &1", buf_tt-place.curr-qnty)
      .
   end.
end. /* do on error */
END PROCEDURE. /* draw-place */



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE draw-pred Dialog-Frame
PROCEDURE draw-pred :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-frame-width    as integer      no-undo.
define variable v-frame-left     as integer      no-undo.
define variable v-frame-top   as integer      no-undo.

define variable v-rect-width    as integer      no-undo.
define variable v-c    as integer      no-undo.
DEFINE VARIABLE  but1  AS HANDLE.

define buffer buf_tt-place    for tt-place.
define buffer buf_tt-gds-pred     for tt-gds-pred.

do
on error undo, return error
:
   assign
      v-frame-width  = RECT-2:width IN FRAME Dialog-Frame
      v-frame-left   = 0.5 + RECT-2:column   IN FRAME Dialog-Frame
      v-frame-top    = RECT-2:row      IN FRAME Dialog-Frame
      v-rect-width   = (v-frame-width - 2 ) / v-count-place
   .
   FOR EACH buf_tt-gds-pred:
      assign
         v-c = v-c + buf_tt-gds-pred.count-pl
      .
      CREATE RECTANGLE buf_tt-gds-pred.hnd
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - buf_tt-gds-pred.count-pl)
             ROW           = v-frame-top - 0.25
             WIDTH         = v-rect-width * count-pl
             HEIGHT        = RECT-2:height - 0.5
             BGCOLOR       = (v-c - buf_tt-gds-pred.count-pl)
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
      .

      CREATE TEXT buf_tt-gds-pred.hnd-name
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - buf_tt-gds-pred.count-pl) + 1
             row           = RECT-2:ROW + 0.7
             FGCOLOR       = (v-c - buf_tt-gds-pred.count-pl)
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 15
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = buf_tt-gds-pred.gds-name
      .
      CREATE TEXT buf_tt-gds-pred.hnd-sale-qnty-l
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - buf_tt-gds-pred.count-pl) + 1
             ROW           = RECT-2:ROW + 1.4
             FGCOLOR       = (v-c - buf_tt-gds-pred.count-pl)
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 15
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = "Реализация"
      .
      CREATE TEXT buf_tt-gds-pred.hnd-sale-qnty
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - buf_tt-gds-pred.count-pl) + 1
             ROW           = RECT-2:ROW + 2.1
             FGCOLOR       = (v-c - buf_tt-gds-pred.count-pl)
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 15
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = STRING( buf_tt-gds-pred.sale-qnty)
      .

      CREATE TEXT buf_tt-gds-pred.hnd-qnty-l
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - buf_tt-gds-pred.count-pl) + 1
             ROW           = RECT-2:ROW + 2.85
             FGCOLOR       = (v-c - buf_tt-gds-pred.count-pl)
             BGCOLOR       = 15
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 15
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = "Остаток"
      .
      CREATE TEXT buf_tt-gds-pred.hnd-qnty
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - buf_tt-gds-pred.count-pl) + 1
             ROW           = RECT-2:ROW + 3.5
             FGCOLOR       = (v-c - buf_tt-gds-pred.count-pl)
             BGCOLOR       = 15
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 15
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = STRING(buf_tt-gds-pred.curr-qnty)
      .
      CREATE TEXT buf_tt-gds-pred.hnd-pred-qnty-l
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - buf_tt-gds-pred.count-pl) + 1
             ROW           = RECT-2:ROW + 4.25
             FGCOLOR       = (v-c - buf_tt-gds-pred.count-pl)
             BGCOLOR       = 15
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 15
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = "Прогноз"
      .
      CREATE TEXT buf_tt-gds-pred.hnd-pred-qnty
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - buf_tt-gds-pred.count-pl) + 1
             ROW           = RECT-2:ROW + 4.9
             FGCOLOR       = (v-c - buf_tt-gds-pred.count-pl)
             BGCOLOR       = 15
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 15
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = STRING(buf_tt-gds-pred.prediction-qnty)
      .
      CREATE TEXT buf_tt-gds-pred.hnd-total-qnty-l
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - buf_tt-gds-pred.count-pl) + 1
             ROW           = RECT-2:ROW + 5.65
             FGCOLOR       = (v-c - buf_tt-gds-pred.count-pl)
             BGCOLOR       = 15
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 15
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = "Итого"
      .
      CREATE TEXT buf_tt-gds-pred.hnd-total-qnty
      ASSIGN COLUMN        = v-frame-left + v-rect-width * (v-c - buf_tt-gds-pred.count-pl) + 1
             ROW           = RECT-2:ROW + 6.3
             FGCOLOR       = (v-c - buf_tt-gds-pred.count-pl)
             BGCOLOR       = 15
             FRAME         = FRAME Dialog-Frame:HANDLE
             SENSITIVE     = FALSE
             VISIBLE       = FALSE
             width         = 15
             data-type     = "character"
             format        = "x(16)"
             SCREEN-VALUE  = SUBSTITUTE("&1", (IF (rs-prediction = 1)
                                                THEN (buf_tt-gds-pred.curr-qnty - buf_tt-gds-pred.prediction-qnty + buf_tt-gds-pred.sale-qnty)
                                                ELSE (buf_tt-gds-pred.curr-qnty - buf_tt-gds-pred.prediction-qnty))
                                                )
      .
   end.
end. /* do on error */
END PROCEDURE. /* draw-pred */

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
  DISPLAY v-date-prediction rs-prediction v-hour-prediction v-minute-prediction
          v-shift-num-prediction
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-help RECT-1 RECT-2 BROWSE-3 v-date-prediction b-sale
         rs-prediction b-shift BROWSE-4
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-place Dialog-Frame
PROCEDURE fill-place :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE BUFFER buf_place       FOR ub.place.
define buffer buf_rvs-doc     for ub.rvs-doc.
define buffer buf_rvs-line    for ub.rvs-line.
define buffer buf_rvs-line-pump     for ub.rvs-line-pump .
define buffer buf_goods       for ub.goods.
define buffer buf_pl-gds      for ub.pl-gds .

define buffer buf_tt-place    for tt-place.

define variable v-start-sale-qnty    as decimal      no-undo.
define variable v-found    as logical      no-undo.
define variable v-fill               as logical      no-undo.

do
on error undo, return error:

   /* Сменная сверка последней закрытой смены,
      чтобы снять показания счетчиков на начало смены
      */
   find first buf_rvs-doc
      where  buf_rvs-doc.obj-type   = v-obj-type
         and buf_rvs-doc.obj-code   = v-obj-code
         and buf_rvs-doc.shift-date = v-shift-date-prev
         and buf_rvs-doc.shift-num  = v-shift-num-prev
         and buf_rvs-doc.status_    = {&fact}
         and buf_rvs-doc.rvs-type   = {&rvs-shift}
      no-lock
      no-error
      .

   _place:
   FOR EACH buf_place
       WHERE buf_place.obj-type = v-obj-type
         and buf_place.obj-code = v-obj-code
       no-lock
       :

      find first buf_pl-gds
           where buf_pl-gds.pl-code = buf_place.pl-code
           no-lock
           no-error
           .
      IF NOT AVAILABLE buf_pl-gds THEN do:
         message
            "Не найдена привязка товара к резервуару:" buf_place.pl-code
            skip
         view-as alert-box information.
         NEXT _place.
      end.

      find first buf_goods
         where buf_goods.gds-code = buf_pl-gds.gds-code
         no-lock
         no-error
         .

      IF NOT AVAILABLE buf_goods THEN do:
         message
            "Не найден товар " buf_pl-gds.gds-code
            "для резервуара "  buf_place.pl-code
            skip
         view-as alert-box information.
         NEXT _place.
      end.

      CREATE buf_tt-place.
      assign
         buf_tt-place.gds-code   = buf_goods.gds-code
         buf_tt-place.pl-code    = buf_place.pl-code
         buf_tt-place.max-qnty   = buf_place.max-qnty
         buf_tt-place.loc1       = buf_place.loc1
         buf_tt-place.gds-name   = buf_goods.gds-name
         v-count-place           = v-count-place + 1
         v-max-qnty             = IF v-max-qnty > buf_place.max-qnty THEN v-max-qnty ELSE buf_place.max-qnty
      .

      assign
         v-start-sale-qnty = 0.0
      .
      FOR EACH   buf_rvs-line-pump
           WHERE buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
             and buf_rvs-line-pump.obj-type = buf_rvs-doc.obj-type
             and buf_rvs-line-pump.obj-code = buf_rvs-doc.obj-code
             and buf_rvs-line-pump.pl-code  = buf_place.pl-code
             and buf_rvs-line-pump.gds-code = buf_goods.gds-code
           NO-LOCK
           :

           ASSIGN
               v-start-sale-qnty = v-start-sale-qnty + buf_rvs-line-pump.state-mh-cnt
           .
      END.
      ASSIGN
         buf_tt-place.sale-start-qnty = v-start-sale-qnty
         buf_tt-place.sale-qnty-curr  = buf_tt-place.sale-qnty-curr - v-start-sale-qnty
      .

      FIND FIRST buf_rvs-line
            WHERE buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
               and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
               and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
               and buf_rvs-line.pl-code  = buf_tt-place.pl-code
               and buf_rvs-line.gds-code = buf_tt-place.gds-code
         NO-LOCK
         no-error
         .

      IF  AVAILABLE buf_rvs-line
      then do:
         assign
            buf_tt-place.curr-qnty-start        = buf_rvs-line.state-measure-qnty
         .
      end.

   END. /* EACH buf_place */


   IF NOT CAN-FIND( FIRST buf_rvs-doc
      where buf_rvs-doc.obj-type   = v-obj-type
        and buf_rvs-doc.obj-code   = v-obj-code
        and buf_rvs-doc.shift-date = v-shift-date
        and buf_rvs-doc.shift-num  = v-shift-num
        and buf_rvs-doc.status_    = {&fact}
        and buf_rvs-doc.rvs-type   = {&rvs-control}
        )
   THEN DO:
      message
         "В текущей смене нет контрольных сверок"
         skip
      view-as alert-box error.
      return error.
   END.

   /* находим сверку ближайшую к текущему времени
      эта сверка - текущие продажи и время прогноза */
   FOR each buf_rvs-doc
      where buf_rvs-doc.obj-type   = v-obj-type
        and buf_rvs-doc.obj-code   = v-obj-code
        and buf_rvs-doc.shift-date = v-shift-date
        and buf_rvs-doc.shift-num  = v-shift-num
        and buf_rvs-doc.status_    = {&fact}
        and buf_rvs-doc.rvs-type   = {&rvs-control}
        use-index shift
      no-lock
      :

      FOR EACH  buf_tt-place
          :

          IF  buf_tt-place.sale-fact-order < buf_rvs-doc.fact-order THEN DO:
               assign
                  v-found = FALSE
               .
               FOR EACH buf_rvs-line-pump
                     WHERE   buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
                        and  buf_rvs-line-pump.obj-type = buf_rvs-doc.obj-type
                        and  buf_rvs-line-pump.obj-code = buf_rvs-doc.obj-code
                        and  buf_rvs-line-pump.pl-code  = buf_tt-place.pl-code
                        and  buf_rvs-line-pump.gds-code = buf_tt-place.gds-code
               :
                  IF v-found = FALSE THEN DO:
                     assign
                        v-found = TRUE
                        buf_tt-place.sale-qnty-curr = 0
                     .
                  END.
                  assign
                     buf_tt-place.sale-fact-order  = buf_rvs-doc.fact-order
                     buf_tt-place.sale-qnty-curr   = buf_tt-place.sale-qnty-curr + buf_rvs-line-pump.state-mh-cnt
                     buf_tt-place.sale-time        = buf_rvs-doc.fact-time
                     buf_tt-place.sale-fill        = TRUE

                  .
               END.
               IF v-found = TRUE THEN DO:
                     assign
                        buf_tt-place.sale-qnty-curr = buf_tt-place.sale-qnty-curr - buf_tt-place.sale-start-qnty
                     .
               END.
          END.
      end.
      FOR EACH  buf_tt-place
          where buf_tt-place.curr-fill     = FALSE
           :

            FIND FIRST buf_rvs-line
                 WHERE buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                   and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                   and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
                   and buf_rvs-line.pl-code  = buf_tt-place.pl-code
                   and buf_rvs-line.gds-code = buf_tt-place.gds-code
               NO-LOCK
               no-error
               .

            IF  AVAILABLE buf_rvs-line
            AND buf_tt-place.curr-fact-order < buf_rvs-doc.fact-order
            then do:
               assign
                  buf_tt-place.curr-qnty        = buf_rvs-line.state-measure-qnty
                  buf_tt-place.curr-fact-order  = buf_rvs-doc.fact-order
                  buf_tt-place.free-qnty        = buf_tt-place.max-qnty - buf_rvs-line.state-measure-qnty
                  buf_tt-place.curr-fill        = TRUE
                  v-max-qnty                    = IF v-max-qnty > buf_tt-place.curr-qnty THEN v-max-qnty ELSE buf_tt-place.curr-qnty
               .
            end.
      end.

   END.
   IF can-find(FIRST buf_tt-place
               WHERE buf_tt-place.sale-fill = FALSE
               )
   OR can-find(FIRST buf_tt-place
               WHERE buf_tt-place.curr-fill = FALSE
               )
   THEN DO:
      message
              "Не все топливные товары,"
         skip "привязанные к резервуарам и ТРК,"
         skip "присутствуют в сверках текущей смены."
      view-as alert-box information.
   end.
   FOR EACH  buf_tt-place
       WHERE buf_tt-place.sale-fill = FALSE
       :
       assign
         buf_tt-place.sale-qnty-curr = 0.0
       .

   end.
   FOR EACH  buf_tt-place
       WHERE buf_tt-place.curr-fill = FALSE
       :
         assign
            buf_tt-place.curr-qnty        = buf_tt-place.curr-qnty-start
         .
   end.

END. /* do on error */
END PROCEDURE. /* fill-place */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-prediction Dialog-Frame
PROCEDURE fill-prediction :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_rvs-doc     for ub.rvs-doc.
define buffer buf_rvs-line    for ub.rvs-line.
define buffer buf_rvs-line-pump    for ub.rvs-line-pump.
define buffer buf_tt-place    for tt-place.
define buffer buf_tt-gds-pred for tt-gds-pred.
define buffer buf_shift-obj      for ub.shift-obj .

define variable v-end-qnty-prev  as decimal      no-undo.
define variable v-sale-qnty-prev   as decimal      no-undo.

define variable v-meas-date-pred   as date         no-undo.
define variable v-meas-time-pred   as integer      no-undo.
define variable v-time             as integer init 999999     no-undo.
define variable v-delta-time       as integer      no-undo.
define variable v-delta-time-end       as integer      no-undo.
define variable v-rvs-code         as character    no-undo.
define variable v-found    as logical      no-undo.
define variable v-found-control    as logical      no-undo.
define variable v-found-control-end    as logical      no-undo.


do
on error undo, return error
:

   /* смена предыдущая смене прогноза */
   FIND LAST  buf_shift-obj
        WHERE buf_shift-obj.obj-type = v-obj-type
          AND buf_shift-obj.obj-code = v-obj-code
          AND ((    buf_shift-obj.shift-date = v-shift-date-prediction
                AND buf_shift-obj.shift-num  < v-shift-num-prediction
               )
               OR   buf_shift-obj.shift-date < v-shift-date-prediction
              )
        use-index pi
        no-lock
        NO-ERROR.
   if available buf_shift-obj then do:
      find first buf_rvs-doc
         where buf_rvs-doc.obj-type = v-obj-type
         and buf_rvs-doc.obj-code   = v-obj-code
         and buf_rvs-doc.shift-date = buf_shift-obj.shift-date
         and buf_rvs-doc.shift-num  = buf_shift-obj.shift-num
         and buf_rvs-doc.status_    = {&fact}
         and buf_rvs-doc.rvs-type   = {&rvs-shift}
         no-lock
         .
      FOR EACH   buf_tt-place,
          each   buf_rvs-line-pump
           WHERE buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
             and buf_rvs-line-pump.obj-type = buf_rvs-doc.obj-type
             and buf_rvs-line-pump.obj-code = buf_rvs-doc.obj-code
             and buf_rvs-line-pump.pl-code  = buf_tt-place.pl-code
             and buf_rvs-line-pump.gds-code = buf_tt-place.gds-code
           NO-LOCK
           :

            assign
               buf_tt-place.sale-start-qnty-prev = buf_tt-place.sale-start-qnty-prev + buf_rvs-line-pump.state-mh-cnt
            .
      END.

   end.
   /* если предыдущей смены нет, то количества на начало пустые,
      а они и так пустые
   ELSE DO:

   END.
   */


   /* находим сверку ближайшую ко времени старта прогноза (точка измерения) */
   FOR each buf_rvs-doc
      where buf_rvs-doc.obj-type   = v-obj-type
        and buf_rvs-doc.obj-code   = v-obj-code
        and buf_rvs-doc.shift-date = v-shift-date-prediction
        and buf_rvs-doc.shift-num  = v-shift-num-prediction
        and buf_rvs-doc.status_    = {&fact}
        and (buf_rvs-doc.rvs-type   = {&rvs-control}
         OR buf_rvs-doc.rvs-type   = {&rvs-shift})
        /*
        and buf_rvs-doc.rvs-type   = {&rvs-control}
        */

      no-lock
      :

      IF NOT v-found-control THEN DO:
         assign
            v-found-control = TRUE
         .
      END.

      FOR EACH  buf_tt-place
          :

          IF  /*1800 > ABS(buf_tt-place.sale-time-curr - buf_rvs-doc.fact-time)
          AND*/ ABS(buf_tt-place.sale-time - buf_rvs-doc.fact-time)
            < ABS(buf_tt-place.sale-time - buf_tt-place.sale-time-prev)
          THEN DO:
               assign
                  v-found = FALSE
               .
               FOR EACH buf_rvs-line-pump
                     WHERE   buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
                        and  buf_rvs-line-pump.obj-type = buf_rvs-doc.obj-type
                        and  buf_rvs-line-pump.obj-code = buf_rvs-doc.obj-code
                        and  buf_rvs-line-pump.pl-code  = buf_tt-place.pl-code
                        and  buf_rvs-line-pump.gds-code = buf_tt-place.gds-code
               :
                  IF v-found = FALSE THEN DO:
                     assign
                        v-found = TRUE
                        buf_tt-place.sale-qnty-prev = 0
                     .
                  END.
                  assign
                     buf_tt-place.sale-qnty-prev   = buf_tt-place.sale-qnty-prev + buf_rvs-line-pump.state-mh-cnt
                     buf_tt-place.sale-time-prev   = buf_rvs-doc.fact-time
                     v-delta-time = IF (buf_tt-place.sale-time - buf_tt-place.sale-time-prev) > v-delta-time THEN (buf_tt-place.sale-time - buf_tt-place.sale-time-prev) ELSE v-delta-time
                     v-start-time-prediction  = buf_tt-place.sale-time-prev
                  .
               END.
               IF v-found = TRUE THEN DO:
                     assign
                        buf_tt-place.sale-qnty-prev = buf_tt-place.sale-qnty-prev - buf_tt-place.sale-start-qnty-prev
                     .
               END.
          END.
      end.

   end.

   IF NOT v-found-control then do:
      message
         "В смене, заданной для прогноза, нет контрольных сверок"
         skip
      view-as alert-box information.
      return .
   end.
   IF v-delta-time > 1800 then do:
      message
         "В смене, заданной для прогноза, контрольная сверка"
         "отстоит по времени от точки начала прогноза более чем на 30 минут"
         skip
      view-as alert-box information.
   end.



   _buf_rvs-line-pump:
   for EACH buf_rvs-line-pump
      WHERE buf_rvs-line-pump.rvs-code = v-rvs-code
      NO-LOCK
      :

      find first buf_tt-place
           where buf_tt-place.gds-code = buf_rvs-line-pump.gds-code
             and buf_tt-place.pl-code  = buf_rvs-line-pump.pl-code
             no-error
             .

      IF NOT available buf_tt-place then do:
         next _buf_rvs-line-pump.
      end.

      assign
         buf_tt-place.sale-qnty-prev = buf_rvs-line-pump.state-mh-cnt
      .
   END. /* each buf_rvs-doc */

   /* находим сверку ближайшую ко времени окончания прогноза
      1 - конец смены
      2 - заданное время.
      */
   CASE rs-prediction :
   WHEN 1 THEN DO:
      find first buf_rvs-doc
         where buf_rvs-doc.obj-type = v-obj-type
         and buf_rvs-doc.obj-code   = v-obj-code
         and buf_rvs-doc.shift-date = v-shift-date-prediction
         and buf_rvs-doc.shift-num  = v-shift-num-prediction
         and buf_rvs-doc.status_    = {&fact}
         and buf_rvs-doc.rvs-type   = {&rvs-shift}
         no-lock
         .
         assign
            v-found-control-end = TRUE
         .
      FOR EACH   buf_tt-place
      :

         FOR each buf_rvs-line-pump
            WHERE buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
              and buf_rvs-line-pump.obj-type = buf_rvs-doc.obj-type
              and buf_rvs-line-pump.obj-code = buf_rvs-doc.obj-code
              and buf_rvs-line-pump.pl-code  = buf_tt-place.pl-code
              and buf_rvs-line-pump.gds-code = buf_tt-place.gds-code
            NO-LOCK
            :
            assign
               buf_tt-place.sale-end-qnty-prev = buf_tt-place.sale-end-qnty-prev + buf_rvs-line-pump.state-mh-cnt
            .
         END.
         assign
            buf_tt-place.sale-end-qnty-prev = buf_tt-place.sale-end-qnty-prev - buf_tt-place.sale-start-qnty-prev
         .

      END.
   END.
   OTHERWISE DO:
      FOR each buf_rvs-doc
         where buf_rvs-doc.obj-type   = v-obj-type
         and buf_rvs-doc.obj-code   = v-obj-code
         and buf_rvs-doc.shift-date = v-shift-date-prediction
         and buf_rvs-doc.shift-num  = v-shift-num-prediction
         and buf_rvs-doc.status_    = {&fact}
         and (buf_rvs-doc.rvs-type  = {&rvs-control}
               OR
               buf_rvs-doc.rvs-type   = {&rvs-shift})
         /*
         and buf_rvs-doc.rvs-type  = {&rvs-control}
         */
         no-lock
         :
         IF NOT v-found-control-end THEN DO:
            assign
               v-found-control-end = TRUE
            .
         END.

         FOR EACH  buf_tt-place
            :

            IF  ABS(v-end-time-prediction - buf_rvs-doc.fact-time)
               < ABS(v-end-time-prediction - buf_tt-place.sale-time-prev-end)
            THEN DO:
                  assign
                     v-found = FALSE
                  .
                  FOR EACH buf_rvs-line-pump
                        WHERE   buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
                           and  buf_rvs-line-pump.obj-type = buf_rvs-doc.obj-type
                           and  buf_rvs-line-pump.obj-code = buf_rvs-doc.obj-code
                           and  buf_rvs-line-pump.pl-code  = buf_tt-place.pl-code
                           and  buf_rvs-line-pump.gds-code = buf_tt-place.gds-code
                  :
                     IF v-found = FALSE THEN DO:
                        assign
                           v-found = TRUE
                           buf_tt-place.sale-end-qnty-prev = 0
                        .
                     END.
                     assign
                        buf_tt-place.sale-end-qnty-prev   = buf_tt-place.sale-end-qnty-prev + buf_rvs-line-pump.state-mh-cnt
                        buf_tt-place.sale-time-prev-end   = buf_rvs-doc.fact-time
                        v-delta-time-end = IF (buf_tt-place.sale-time - buf_tt-place.sale-time-prev-end) > v-delta-time THEN (buf_tt-place.sale-time - buf_tt-place.sale-time-prev-end) ELSE v-delta-time-end
                     .
                  END.
                  IF v-found = TRUE THEN DO:
                        assign
                           buf_tt-place.sale-end-qnty-prev = buf_tt-place.sale-end-qnty-prev - buf_tt-place.sale-start-qnty-prev
                        .
                  END.
            END.
         end.
      end.
   END.
   END CASE.

   IF NOT v-found-control-end then do:
      message
         "В смене, заданной для прогноза, нет контрольных сверок"
         skip
      view-as alert-box information.
      return .
   end.
   IF v-delta-time-end > 1800 then do:
      message
         "В смене, заданной для прогноза, контрольная сверка"
         "отстоит по времени от точки начала прогноза более чем на 30 минут"
         skip v-delta-time
      view-as alert-box information.
   end.

   define variable v-delta    as integer      no-undo.
   /* расчет прогноза */
   for each buf_tt-place
       no-lock
       break by buf_tt-place.gds-code
       :
     assign
        v-end-qnty-prev   = v-end-qnty-prev  + buf_tt-place.sale-end-qnty-prev
        v-sale-qnty-prev  = v-sale-qnty-prev   + buf_tt-place.sale-qnty-prev
        v-delta           = IF (v-delta > ABS((buf_tt-place.sale-time-prev - buf_tt-place.sale-time) / 60)) THEN v-delta ELSE ABS((buf_tt-place.sale-time-prev - buf_tt-place.sale-time) / 60)
        v-time            = IF (v-time > buf_tt-place.sale-time) THEN buf_tt-place.sale-time ELSE v-time
     .

     IF LAST-OF(buf_tt-place.gds-code) then do:
        find first buf_tt-gds-pred
             where buf_tt-gds-pred.gds-code = buf_tt-place.gds-code
             no-lock
             .

               IF v-sale-qnty-prev = 0 THEN message
                  SUBSTITUTE("Для топлива &1 невозможно рассчитать прогноз", buf_tt-gds-pred.gds-name)
                  skip
               view-as alert-box information.

               assign
                  buf_tt-gds-pred.prediction-qnty  = IF (rs-prediction = 1) THEN  v-end-qnty-prev                     * buf_tt-gds-pred.sale-qnty / v-sale-qnty-prev
                                                                            ELSE (v-end-qnty-prev - v-sale-qnty-prev) * buf_tt-gds-pred.sale-qnty / v-sale-qnty-prev
                  buf_tt-gds-pred.delta-time = v-delta
                  buf_tt-gds-pred.sale-time = v-time

                  v-sale-qnty-prev   = 0.0
                  v-end-qnty-prev    = 0.0
                  v-delta            = 0
                  v-time             = 999999
               .

     end. /* last-of */
   end. /* each buf_tt-place */
end.
END PROCEDURE. /* fill-prediction */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-sale Dialog-Frame
PROCEDURE fill-sale :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_rvs-doc     for ub.rvs-doc.
define buffer buf_rvs-line    for ub.rvs-line.
define buffer buf_rvs-line-pump    for ub.rvs-line-pump.
DEFINE BUFFER buf_place       FOR ub.place.
define buffer buf_goods       for ub.goods.
define buffer buf_tt-place    for tt-place.
define buffer buf_tt-gds-pred for tt-gds-pred.

define variable v-counter     as integer      no-undo.
define variable v-start-qnty  as decimal      no-undo.
define variable v-sale-qnty   as decimal      no-undo.
define variable v-curr-qnty   as decimal      no-undo.
define variable v-rvs-code    as character      no-undo.

do
on error undo, return error
:
   assign
      v-counter = 0
   .
   for each buf_tt-place
      no-lock
      break by buf_tt-place.gds-code
      :
      assign
         v-counter      = v-counter + 1
         v-start-qnty   = v-start-qnty  + buf_tt-place.curr-qnty
         v-sale-qnty    = v-sale-qnty   + buf_tt-place.sale-qnty-curr
         v-curr-qnty    = v-curr-qnty   + buf_tt-place.curr-qnty /* !!! free ? */
      .
      IF LAST-OF(buf_tt-place.gds-code) then do:
         create buf_tt-gds-pred.
         assign
            buf_tt-gds-pred.gds-code   = buf_tt-place.gds-code
            buf_tt-gds-pred.gds-name   = buf_tt-place.gds-name
            buf_tt-gds-pred.start-qnty = v-start-qnty
            buf_tt-gds-pred.sale-qnty  = v-sale-qnty
            buf_tt-gds-pred.curr-qnty  = v-curr-qnty
            buf_tt-gds-pred.count-pl   = v-counter
            v-start-qnty       = 0.0
            v-sale-qnty        = 0.0
            v-curr-qnty        = 0.0
            v-counter          = 0
         .
      end. /* last-of */
   end. /* each buf_tt-place */
end.
END PROCEDURE. /* fill-sale */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-date-shift Dialog-Frame
PROCEDURE find-date-shift :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-date as date no-undo .
define input parameter p-time as integer no-undo .
define output parameter p-shift-date as date no-undo .
define output parameter p-shift-num as integer no-undo .

define buffer buf_shift-obj      for ub.shift-obj.

define variable v-fact-order    as decimal      no-undo.


do
on error undo, return error
:
   run  day-begin-fact-order in this-procedure
        ( input p-date
        , output v-fact-order
        ) .
   for each  buf_shift-obj
      where buf_shift-obj.obj-type = p-obj-type
         and buf_shift-obj.obj-code =  p-obj-code
         and buf_shift-obj.fact-order >= v-fact-order
         and (buf_shift-obj.open-date < p-date
            or (buf_shift-obj.open-date = p-date
               and buf_shift-obj.open-time > p-time))
         and (buf_shift-obj.close-date > p-date
            or (buf_shift-obj.close-date = p-date
               and buf_shift-obj.close-time > p-time))
         and buf_shift-obj.status_ = {&sht-closed}
      no-lock
      :
      assign
         p-shift-date = buf_shift-obj.shift-date
         p-shift-num  = buf_shift-obj.shift-num
      .
      return .
   end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mandatory-24 Dialog-Frame
PROCEDURE mandatory-24 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT-OUTPUT PARAMETER p-time AS INTEGER NO-UNDO .
DO
ON error undo, RETURN:
   IF p-time > 23 THEN DO:
       ASSIGN
           p-time = 23
       .
       RETURN .
   END.
   IF p-time < 0 THEN DO:
       ASSIGN
           p-time = 0
       .
       RETURN .
   END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mandatory-60 Dialog-Frame
PROCEDURE mandatory-60 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT-OUTPUT PARAMETER p-time AS INTEGER NO-UNDO .
DO
ON error undo, RETURN:
   IF p-time > 59 THEN DO:
       ASSIGN
           p-time = 59
       .
       RETURN .
   END.
   IF p-time < 0 THEN DO:
       ASSIGN
           p-time = 0
       .
       RETURN .
   END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-shift Dialog-Frame
PROCEDURE select-shift :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-ok    as logical      no-undo.
define variable v-shift-list    as character    no-undo.
define buffer buf_rvs-doc     for ub.rvs-doc .

define buffer buf_shift-obj      for ub.shift-obj.

do
on error undo, return error
:
   _shift:
   do
   on error undo, retry
   :
      assign
         v-ok = false
      .
      run str/sht-all.w ( parparentproc
                        , v-obj-type
                        , v-obj-code
                        , "b-sel"
                        , "obj"
                        , v-obj-type
                        , v-obj-code
                        , ""
                        , input-output v-shift-list
                        ) no-error.
      IF error-status:error
      THEN do:
         message
            vss-workfile vss-revision vss-description skip
            "Ошибка при выборе смены"  skip
            error-status :get-message( 1 ) skip
            return-value skip
         view-as alert-box error .
         return no-apply.
      end.
      IF v-shift-list =  "":U
      THEN do:
         return no-apply.
      end.
      find first buf_shift-obj
         where recid (buf_shift-obj) = integer (entry(1,v-shift-list))
         no-lock
         .
      IF buf_shift-obj.status_ = {&sht-current}
      then do:
         message
            "Выбранная смена не закрыта" skip
            "Выбрать другую ?"
            view-as alert-box error
            buttons YES-NO
            update v-ok
            .
         IF v-ok then dO:
            undo _shift, retry _shift.
         end.
         else do:
            return no-apply.
         end.
      end.
   END.

   find first buf_rvs-doc
      where buf_rvs-doc.obj-type    = v-obj-type
         and buf_rvs-doc.obj-code   = v-obj-code
         and buf_rvs-doc.shift-date = buf_shift-obj.shift-date
         and buf_rvs-doc.shift-num  = buf_shift-obj.shift-num
         and buf_rvs-doc.status_    = {&fact}
         and buf_rvs-doc.rvs-type   = {&rvs-shift}
      no-lock
      no-error
      .

   Assign
      v-date-prediction       = buf_shift-obj.shift-date
      v-shift-date-prediction = buf_shift-obj.shift-date
      v-shift-num-prediction  = buf_shift-obj.shift-num
      v-end-time-prediction   = IF ( rs-prediction = 1 ) THEN buf_rvs-doc.fact-time ELSE v-end-time-prediction
      v-end-time-prediction-shift = buf_rvs-doc.fact-time
   .
   release buf_shift-obj.

end.
END PROCEDURE. /* select-shift */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-browser Dialog-Frame
PROCEDURE show-browser :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
WITH FRAME Dialog-Frame
:
  define buffer buf_tt-place     for tt-place.
  define buffer buf_tt-gds-pred     for tt-gds-pred.

  HIDE rect-1.
  HIDE rect-2.
  FOR EACH buf_tt-place :
      hide
         buf_tt-place.hnd
         buf_tt-place.hnd-top
         buf_tt-place.hnd-qnty
         buf_tt-place.hnd-max-qnty
         buf_tt-place.hnd-name
      .
  END.
  FOR EACH buf_tt-gds-pred :
      hide
         buf_tt-gds-pred.hnd
         buf_tt-gds-pred.hnd-name
         buf_tt-gds-pred.hnd-qnty
         buf_tt-gds-pred.hnd-sale-qnty
         buf_tt-gds-pred.hnd-pred-qnty
         buf_tt-gds-pred.hnd-total-qnty
         buf_tt-gds-pred.hnd-qnty-l
         buf_tt-gds-pred.hnd-sale-qnty-l
         buf_tt-gds-pred.hnd-pred-qnty-l
         buf_tt-gds-pred.hnd-total-qnty-l
      .
  END.
  DISPLAY
      BROWSE-3
      BROWSE-4
  .

end.
END PROCEDURE. /* show-browser */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-histogramm Dialog-Frame
PROCEDURE show-histogramm :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
WITH FRAME Dialog-Frame
:
  define buffer buf_tt-place     for tt-place.
  define buffer buf_tt-gds-pred     for tt-gds-pred.

  HIDE browse-3.
  HIDE browse-4.
  DISPLAY
      RECT-1
      RECT-2
      .
  FOR EACH buf_tt-place :
      Assign
            buf_tt-place.hnd-name      :HIDDEN = FALSE
            buf_tt-place.hnd-max-qnty  :HIDDEN = FALSE
            buf_tt-place.hnd-qnty      :HIDDEN = FALSE
            buf_tt-place.hnd-top       :HIDDEN = FALSE
            buf_tt-place.hnd           :HIDDEN = FALSE
      .
  END.
  FOR EACH buf_tt-gds-pred :
      assign
         buf_tt-gds-pred.hnd           :HIDDEN = FALSE
         buf_tt-gds-pred.hnd-name      :HIDDEN = FALSE
         buf_tt-gds-pred.hnd-qnty      :HIDDEN = FALSE
         buf_tt-gds-pred.hnd-sale-qnty :HIDDEN = FALSE
         buf_tt-gds-pred.hnd-pred-qnty :HIDDEN = FALSE
         buf_tt-gds-pred.hnd-total-qnty :HIDDEN = FALSE
         buf_tt-gds-pred.hnd-qnty-l      :HIDDEN = FALSE
         buf_tt-gds-pred.hnd-sale-qnty-l :HIDDEN = FALSE
         buf_tt-gds-pred.hnd-pred-qnty-l :HIDDEN = FALSE
         buf_tt-gds-pred.hnd-total-qnty-l :HIDDEN = FALSE
      .
  END.

end.
END PROCEDURE. /* show-histogramm */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME