&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_curr-shop FOR ub.curr-shop.
DEFINE BUFFER X_currency FOR ub.currency.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Курсы валют в магазине

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/09/05
Author: Bakhtadze Natalya
Creation date: 08/09/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code LIKE ub.clients.obj-code NO-UNDO.
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Курсы валют в магазине".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/usrfulnf.i }
DEFINE VARIABLE log-res AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-created AS LOGICAL NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-curr-shop

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_curr-shop X_currency

/* Definitions for BROWSE BR-curr-shop                                  */
&Scoped-define FIELDS-IN-QUERY-BR-curr-shop X_curr-shop.exch-rate X_curr-shop.exch-scale X_curr-shop.exch-date string(X_curr-shop.exch-time, "hh:mm:ss") usrfulnf(X_curr-shop.corr-user-name) X_curr-shop.cre-date string(X_curr-shop.cre-time, "hh:mm:ss")
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-curr-shop
&Scoped-define SELF-NAME BR-curr-shop
&Scoped-define QUERY-STRING-BR-curr-shop FOR EACH X_curr-shop       WHERE X_curr-shop.obj-type = p-obj-type  AND X_curr-shop.obj-code = p-obj-code  AND X_curr-shop.curr-code = X_currency.curr-code NO-LOCK     BY X_curr-shop.exch-date DESCENDING      BY X_curr-shop.exch-time DESCENDING INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-curr-shop OPEN QUERY {&SELF-NAME} FOR EACH X_curr-shop       WHERE X_curr-shop.obj-type = p-obj-type  AND X_curr-shop.obj-code = p-obj-code  AND X_curr-shop.curr-code = X_currency.curr-code NO-LOCK     BY X_curr-shop.exch-date DESCENDING      BY X_curr-shop.exch-time DESCENDING INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-curr-shop X_curr-shop
&Scoped-define FIRST-TABLE-IN-QUERY-BR-curr-shop X_curr-shop


/* Definitions for BROWSE br-currency                                   */
&Scoped-define FIELDS-IN-QUERY-br-currency X_currency.curr-code ~
X_currency.curr-abbr
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-currency
&Scoped-define QUERY-STRING-br-currency FOR EACH X_currency ~
      WHERE X_currency.curr-code > 0 NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-currency OPEN QUERY br-currency FOR EACH X_currency ~
      WHERE X_currency.curr-code > 0 NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-currency X_currency
&Scoped-define FIRST-TABLE-IN-QUERY-br-currency X_currency


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-curr-shop}~
    ~{&OPEN-QUERY-br-currency}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-repeat B-add B-Help br-currency ~
BR-curr-shop f-curr-bank-title f-curr-bank-rate f-curr-bank-scale-title ~
f-curr-bank-scale
&Scoped-Define DISPLAYED-OBJECTS f-curr-bank-title f-curr-bank-rate ~
f-curr-bank-scale-title f-curr-bank-scale

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "Новый курс"
     SIZE 20 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-repeat
     LABEL "Отослать повторно"
     SIZE 20 BY 1.

DEFINE VARIABLE f-curr-bank-rate LIKE ub.curr-bank.exch-rate
      VIEW-AS TEXT
     SIZE 14.5 BY .67 NO-UNDO.

DEFINE VARIABLE f-curr-bank-scale LIKE ub.curr-bank.exch-scale
      VIEW-AS TEXT
     SIZE 9 BY .67 NO-UNDO.

DEFINE VARIABLE f-curr-bank-scale-title AS CHARACTER FORMAT "X(256)":U INITIAL "Масштаб"
      VIEW-AS TEXT
     SIZE 9.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-curr-bank-title AS CHARACTER FORMAT "X(256)":U INITIAL "Текущий курс ЦБ РФ"
      VIEW-AS TEXT
     SIZE 19 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-curr-shop FOR
      X_curr-shop SCROLLING.

DEFINE QUERY br-currency FOR
      X_currency SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-curr-shop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-curr-shop Dialog-Frame _FREEFORM
  QUERY BR-curr-shop NO-LOCK DISPLAY
      X_curr-shop.exch-rate FORMAT ">>,>>9.9999":U
      X_curr-shop.exch-scale FORMAT ">>>9":U
      X_curr-shop.exch-date FORMAT "99/99/9999":U
      string(X_curr-shop.exch-time, "hh:mm:ss") COLUMN-LABEL "Время" FORMAT "X(8)":U
            WIDTH 9
      usrfulnf(X_curr-shop.corr-user-name) COLUMN-LABEL "Оператор" FORMAT "X(18)":U
      X_curr-shop.cre-date FORMAT "99/99/9999":U
      string(X_curr-shop.cre-time, "hh:mm:ss") COLUMN-LABEL "Время!ввода" FORMAT "X(8)":U
            WIDTH 5.25
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 83 BY 13 FIT-LAST-COLUMN.

DEFINE BROWSE br-currency
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-currency Dialog-Frame _STRUCTURED
  QUERY br-currency NO-LOCK DISPLAY
      X_currency.curr-code COLUMN-LABEL "Код!вал" FORMAT ">>9":U
            WIDTH 4
      X_currency.curr-abbr FORMAT "X(3)":U WIDTH 5.8
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 13 BY 13 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-repeat AT ROW 1 COL 21
     B-add AT ROW 1 COL 51
     B-Help AT ROW 1 COL 95
     br-currency AT ROW 2 COL 1
     BR-curr-shop AT ROW 2 COL 15
     f-curr-bank-title AT ROW 16 COL 2 NO-LABEL
     f-curr-bank-rate AT ROW 16 COL 21 COLON-ALIGNED HELP
          "" NO-LABEL FORMAT ">>,>>9.99"
     f-curr-bank-scale-title AT ROW 16 COL 39 NO-LABEL
     f-curr-bank-scale AT ROW 16 COL 49 COLON-ALIGNED HELP
          "" NO-LABEL FORMAT ">,>>>,>>9"
     SPACE(38.62) SKIP(1.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Курсы валют в магазине"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_curr-shop B "?" ? ub curr-shop
      TABLE: X_currency B "?" ? ub currency
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-currency B-Help Dialog-Frame */
/* BROWSE-TAB BR-curr-shop br-currency Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-curr-bank-rate IN FRAME Dialog-Frame
   LIKE = ub.curr-bank.exch-rate EXP-LABEL EXP-FORMAT EXP-SIZE          */
/* SETTINGS FOR FILL-IN f-curr-bank-scale IN FRAME Dialog-Frame
   LIKE = ub.curr-bank.exch-scale EXP-LABEL EXP-FORMAT EXP-SIZE         */
/* SETTINGS FOR FILL-IN f-curr-bank-scale-title IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-curr-bank-title IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-curr-shop
/* Query rebuild information for BROWSE BR-curr-shop
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_curr-shop
      WHERE X_curr-shop.obj-type = p-obj-type
 AND X_curr-shop.obj-code = p-obj-code
 AND X_curr-shop.curr-code = X_currency.curr-code NO-LOCK
    BY X_curr-shop.exch-date DESCENDING
     BY X_curr-shop.exch-time DESCENDING INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _OrdList          = "X_curr-shop.exch-date|no,X_curr-shop.exch-time|no"
     _Where[1]         = "X_curr-shop.obj-type = p-obj-type
 AND X_curr-shop.obj-code = p-obj-code
 AND X_curr-shop.curr-code = X_currency.curr-code"
     _Query            is OPENED
*/  /* BROWSE BR-curr-shop */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-currency
/* Query rebuild information for BROWSE br-currency
     _TblList          = "X_currency"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "X_currency.curr-code > 0"
     _FldNameList[1]   > Temp-Tables.X_currency.curr-code
"X_currency.curr-code" "Код!вал" ? "integer" ? ? ? ? ? ? no ? no no "4" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.X_currency.curr-abbr
"X_currency.curr-abbr" ? ? "character" ? ? ? ? ? ? no ? no no "5.8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-currency */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Курсы валют в магазине */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Новый курс */
DO:
   define variable ri as recid no-undo.
  define variable glog as logical no-undo .
  if not available X_currency THEN  return no-apply.
  define variable v-obj-host-code as integer no-undo .
  { gbl/hostcode.i p-obj-type p-obj-code v-obj-host-code }
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_shop-rate_update':U
  {&cntxt-object}
  v-obj-host-code
  p-obj-type
  p-obj-code
  0
  0
  0
  true
  glog
  }
  if NOT glog then
  return no-apply.
  RUN add-rate in this-procedure ( buffer X_currency, output ri ).
  if ri <> ? then  do:
    apply "value-changed":U to br-currency.
    apply "entry":U to br-currency.
 end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
DEFINE VARIABLE glog as LOGICAL NO-UNDO.
iF v-created THEN DO:

message
"Вы хотите переслать курсы на кассу ПРЯМО СЕЙЧАС?"
view-as alert-box
question buttons YES-NO update glog.
if glog then do:
  run str/diallog.w (
          input parparentproc
        , input this-procedure
        , input "str/send-cur.p":U
        , input (p-obj-type + {&delim-par} + string(p-obj-code) + {&delim-par} + "U":U)
        , input no /*p-auto-go*/
        , input "":U
        , input substitute("Отсылка данных по курсам валют на кассы")
    ) no-error.
end.
END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-repeat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-repeat Dialog-Frame
ON CHOOSE OF B-repeat IN FRAME Dialog-Frame /* Отослать повторно */
DO:
  define variable glog as logical no-undo .
  assign
  glog = no.
  message
  "Вы хотите ПОВТОРНО переслать курсы на кассу?"
  view-as alert-box
  question buttons YES-NO update glog.
  if glog then do:
    run str/diallog.w (
            input parparentproc
          , input this-procedure
          , input "str/send-cur.p":U
          , input (p-obj-type + {&delim-par} + string(p-obj-code) + {&delim-par} + "U":U)
          , input no /*p-auto-go*/
          , input "":U
          , input substitute("Отсылка данных по курсам валют на кассы")
      ) no-error.
  end.
 {&OPEN-QUERY-br-currency}
 {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
apply "value-changed":U to br-currency IN FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-currency
&Scoped-define SELF-NAME br-currency
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-currency Dialog-Frame
ON VALUE-CHANGED OF br-currency IN FRAME Dialog-Frame
DO:
  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.
  define buffer buf_curr-bank for ub.curr-bank.

  {&OPEN-QUERY-br-curr-shop}
  if not avail X_curr-shop then do:

  END.
  if available X_curr-shop then do:
    assign
   log-res = br-curr-shop:select-row( 1 )
    .
  end.
  { gbl/curobjdt.i p-obj-type p-obj-code v-today }
  FIND LAST buf_curr-bank WHERE
           buf_curr-bank.curr-code = X_curr-shop.curr-code
       AND buf_curr-bank.exch-date <= v-today No-LOCK NO-ERROR.
  IF avail buf_curr-bank then do:
    assign
    f-curr-bank-rate = buf_curr-bank.exch-rate
    f-curr-bank-scale = buf_curr-bank.exch-scale
    .
    DISPLAY
    f-curr-bank-rate
    f-curr-bank-scale
    with frame {&frame-name}.
  end.
  else do:
    assign
    f-curr-bank-rate = 0
    f-curr-bank-scale = 0
    .
    HIDE
    f-curr-bank-rate f-curr-bank-scale
    in frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-curr-shop
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
  { gbl/getcntxt.i get }
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-rate Dialog-Frame
PROCEDURE add-rate :
define parameter buffer buf_currency for ub.currency.
define output param rid as recid no-undo init ?.


define variable found as logical init no.
define variable last-rate  like ub.curr-shop.exch-rate.
define variable last-scale like ub.curr-shop.exch-scale.
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.

define buffer b-curr-shop   for ub.curr-shop.
define buffer buf_curr-shop for ub.curr-shop.

define button b-OK        label "&Ввод "   size 10 by 1  auto-go.
define button b-cancel  label "&Отмена"  size 10 by 1  auto-endkey.

      /* фрейм для ввода/изменения курса валюты */
define frame d-rate
b-OK
b-cancel
ub.curr-shop.exch-date    at row 2 col 16     colon-aligned  label "&Дата курса" format "99/99/9999"
ub.curr-shop.exch-rate     at row 3 col 16     colon-aligned  label "&Курс валюты"
ub.curr-shop.exch-scale   at row 4 col 16     colon-aligned  label "&Масштаб"
space( 1 )
with view-as dialog-box side-labels three-d
default-button b-OK title "Курс валюты: ВВОД".


find LAST b-curr-shop where
         b-curr-shop.curr-code = buf_currency.curr-code
     AND b-curr-shop.obj-type   = p-obj-type
     AND b-curr-shop.obj-code  = p-obj-code no-error.
  if  available b-curr-shop
  then
  assign
  last-rate = b-curr-shop.exch-rate
  last-scale = b-curr-shop.exch-scale
  .
  on go of frame d-rate do:

    define buffer b-currency for ub.currency.
    define variable rr as recid no-undo.

    do on error undo, return on stop undo, return:   /* для многопользов. работы */
        rr = recid( buf_currency ).
        find b-currency where recid( b-currency ) = rr exclusive-lock.
    end.

   find LAST b-curr-shop where
            b-curr-shop.curr-code = buf_currency.curr-code
        AND b-curr-shop.obj-type   = p-obj-type
        AND b-curr-shop.obj-code  = p-obj-code no-error.

   run cur-time in this-procedure ( output v-today
                                  , output v-time
                                  ).
   if  available b-curr-shop
   AND (( b-curr-shop.exch-date > input ub.curr-shop.exch-date )
         OR (( b-curr-shop.exch-date = input ub.curr-shop.exch-date )
         AND ( b-curr-shop.exch-time > v-time )))     then do:
      message
      "Дата и время вводимого курса не могут быть" skip
      "раньше чем у последнего введенного курса"
      view-as alert-box error.
      apply "entry":U to ub.curr-shop.exch-date.
      return no-apply.
   end.
    find first buf_curr-shop where
            buf_curr-shop.obj-type = p-obj-type
        AND  buf_curr-shop.obj-code = p-obj-code
        AND  buf_curr-shop.curr-code = buf_currency.curr-code
        AND  buf_curr-shop.exch-date = 01/01/9999 no-error.
    if NOT AVAIL buf_curr-shop then do:
      create buf_curr-shop.
      assign
      buf_curr-shop.curr-code = buf_currency.curr-code
      buf_curr-shop.obj-type   = p-obj-type
      buf_curr-shop.obj-code  = p-obj-code
      buf_curr-shop.exch-date = input curr-shop.exch-date
      buf_curr-shop.exch-time = 0
      buf_curr-shop.exch-rate = input curr-shop.exch-rate
      buf_curr-shop.exch-scale = input curr-shop.exch-scale
      rid = recid( buf_curr-shop )
      v-created = YES
      .
    end.
    else do:
      assign
      found = yes
      buf_curr-shop.exch-rate = input curr-shop.exch-rate
      buf_curr-shop.exch-scale =  input curr-shop.exch-scale
      rid = recid( buf_curr-shop )
      .

    end.
  end.
  on window-close of frame d-rate apply "end-error":U to self.

  frame d-rate:title = "Курс валюты: ВВОД".
  enable all except curr-shop.exch-date with frame d-rate.
  if avail buf_curr-shop then do:
    display
    1/1/9999 @ curr-shop.exch-date
    last-rate @ curr-shop.exch-rate
    last-scale @ curr-shop.exch-scale
    with frame d-rate.
  end.
  else do:
     display
      1/1/9999 @ curr-shop.exch-date
      1 @ curr-shop.exch-rate
      1 @ curr-shop.exch-scale
      with frame d-rate.
  end.
  do on endkey undo, leave on error undo, leave:
      wait-for go of frame d-rate  focus curr-shop.exch-rate.
  end.
  disable all with frame d-rate.
  hide frame d-rate.
{&OPEN-QUERY-br-currency}
 {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
apply "value-changed":U to br-currency IN FRAME {&FRAME-NAME}.
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
  DISPLAY f-curr-bank-title f-curr-bank-rate f-curr-bank-scale-title
          f-curr-bank-scale
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-repeat B-add B-Help br-currency BR-curr-shop
         f-curr-bank-title f-curr-bank-rate f-curr-bank-scale-title
         f-curr-bank-scale
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DISPLAY
 f-curr-bank-title
 f-curr-bank-scale-title
 f-curr-bank-rate
 f-curr-bank-scale
 WITH FRAME {&frame-name}.
 ENABLE
 b-quit
 B-repeat
 B-add
 B-Help
 br-currency
 BR-curr-shop
 f-curr-bank-title
 f-curr-bank-scale-title
 f-curr-bank-rate
 f-curr-bank-scale
 WITH FRAME {&frame-name}.
 VIEW FRAME {&frame-name}.
 {&OPEN-QUERY-br-currency}
 {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
apply "value-changed":U to br-currency.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME