&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_currency FOR currency.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ручной выбор цены в множественных прайс-листах при формировании документа

Автор: Чернова Светлана Александровна
Дата создания: 03/29/06
Author: Svetlana Chernova
Creation date: 03/29/06


*/

define input  parameter parparentproc as handle no-undo .
define input  parameter p-cli-type    as character no-undo .
define input  parameter p-cli-code    as integer   no-undo .
define input  parameter p-main-b-code as integer   no-undo .
define input  parameter p-b-code      as integer   no-undo .
define input  parameter p-obj-type    as character no-undo .
define input  parameter p-obj-code    as integer   no-undo .
define input  parameter p-qnty-doc    as decimal   no-undo .
define input  parameter p-sum-doc     as decimal   no-undo .
define input  parameter p-vid-pay     as character no-undo .
define input  parameter p-cash-type-pay as character no-undo.
define input  parameter p-fact-order  as decimal   no-undo .

define output parameter p-plt-id          as integer   no-undo .
define output parameter p-plt-db-num      as integer   no-undo .
define output parameter p-pdf-id          as integer   no-undo .
define output parameter p-pdf-db-num      as integer   no-undo .
define output parameter p-sale-price-base as decimal   no-undo .
define output parameter p-sale-price-rubl as decimal   no-undo .


define variable p-road-tax-base as decimal   no-undo .
define variable p-road-tax-rubl as decimal   no-undo .
define variable p-excise-base   as decimal   no-undo .
define variable p-excise-rubl   as decimal   no-undo .

/*
message
  'p-cli-type    '         p-cli-type         skip
  'p-cli-code    '         p-cli-code         skip
  'p-main-b-code '         p-main-b-code      skip
  'p-b-code      '         p-b-code           skip
  'p-obj-type    '         p-obj-type         skip
  'p-obj-code    '         p-obj-code         skip
  'p-qnty-doc    '         p-qnty-doc         skip
  'p-sum-doc     '         p-sum-doc          skip
  'p-fact-order  '         p-fact-order       skip
       .
  */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Ручной выбор цены в множественных прайс-листах при формировании документа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/color.i    }
{ cmp/showinf.i  }
{ gbl/usr-flt.i  }
{ str/mpl-auto.i }
/* ***************************  Definitions  ************************** */

/* Local Variable Definitions ---                                       */
define variable stime-1 as character no-undo .
define variable stime-2 as character no-undo .
define variable v-t-doc as decimal   no-undo . /* Оборот Покупателя */
define variable is-color as logical   no-undo .
define buffer buf_global-state       for ub.global-state  .
define buffer buf_price-doc-forming for ub.price-doc-forming  .

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
&Scoped-define INTERNAL-TABLES tt_price-all buf_currency

/* Definitions for BROWSE BROWSE-3                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-3 tt_price-all.plt-priority tt_price-all.b-code tt_price-all.unit-cli buf_currency.curr-abbr tt_price-all.plt-fix-cource-crc-doc tt_price-all.pdf-exch-rate tt_price-all.price-sale tt_price-all.plt-fix-cource-crc-base tt_price-all.pdf-base-rate tt_price-all.price-sale-base tt_price-all.price-sale-rubl tt_price-all.date-1 tt_price-all.shift-1 (if tt_price-all.time-1 = 0 then "" else string(tt_price-all.time-1,"hh:mm")) @ stime-1 tt_price-all.date-2 tt_price-all.shift-2 (if tt_price-all.time-2 = 0 then "" else string(tt_price-all.time-2,"hh:mm")) @ stime-2 tt_price-all.grp-name tt_price-all.interv-name tt_price-all.plt-id tt_price-all.pdf-id /* tt_price-all.fact-order tt_price-all.type-price tt_price-all.fact-order-sys-from tt_price-all.fact-order-sys-to p-fact-order */ tt_price-all.pay-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-3
&Scoped-define SELF-NAME BROWSE-3
&Scoped-define QUERY-STRING-BROWSE-3 FOR EACH tt_price-all NO-LOCK, ~
             EACH buf_currency OF tt_price-all  NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-3 OPEN QUERY {&SELF-NAME} FOR EACH tt_price-all NO-LOCK, ~
             EACH buf_currency OF tt_price-all  NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-3 tt_price-all buf_currency
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-3 tt_price-all
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-3 buf_currency


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-3}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-quit B-save B-pdf B-price-doc B-color ~
B-Help BROWSE-3 date-f time-f
&Scoped-Define DISPLAYED-OBJECTS date-f time-f

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-color
     IMAGE-UP FILE "cmp/color.bmp":U
     IMAGE-DOWN FILE "cmp/color.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/color.bmp":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Цветовое выделение на экране".

DEFINE BUTTON B-Help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-pdf
     LABEL "&ДНЦ"
     SIZE 11 BY 1.

DEFINE BUTTON B-price-doc
     LABEL "Пе&реоценка"
     SIZE 11 BY 1.

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-save AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE date-f AS DATE FORMAT "99/99/9999":U
     LABEL "Список цен на"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE time-f AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14.38 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-3 FOR
      tt_price-all,
      buf_currency SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-3 Dialog-Frame _FREEFORM
  QUERY BROWSE-3 NO-LOCK DISPLAY
      tt_price-all.plt-priority COLUMN-LABEL "Приор!итет" FORMAT ">>>>9":U
      tt_price-all.b-code FORMAT "999999999":U
      tt_price-all.unit-cli COLUMN-LABEL "Ед!изм" FORMAT "X(3)":U
      buf_currency.curr-abbr COLUMN-LABEL "Вал" FORMAT "X(3)":U
      tt_price-all.plt-fix-cource-crc-doc COLUMN-LABEL "Ф!к" FORMAT "+/-":U
      tt_price-all.pdf-exch-rate COLUMN-LABEL "Курс!док-та" FORMAT ">>>>9.9999":U
      tt_price-all.price-sale COLUMN-LABEL "Цена в вал!прайс-листа" FORMAT "->>,>>>,>>>,>>>,>>9.99":U
      tt_price-all.plt-fix-cource-crc-base COLUMN-LABEL "Ф!б" FORMAT "+/-":U
      tt_price-all.pdf-base-rate COLUMN-LABEL "Курс!баз.вал" FORMAT ">>>>9.9999":U
      tt_price-all.price-sale-base COLUMN-LABEL "Цена в !баз.вал" FORMAT "->>,>>>,>>>,>>>,>>9.99":U
      tt_price-all.price-sale-rubl COLUMN-LABEL "Цена в !{&abbr_rub_allshift}" FORMAT "->>,>>>,>>>,>>>,>>9.99":U
      tt_price-all.date-1 COLUMN-LABEL "Действие!с " FORMAT "99/99/9999":U
      tt_price-all.shift-1 COLUMN-LABEL "См!с" FORMAT ">9":U
      (if tt_price-all.time-1 = 0 then "" else string(tt_price-all.time-1,"hh:mm")) @ stime-1 COLUMN-LABEL "Время!c" FORMAT "x(5)":U
      tt_price-all.date-2 COLUMN-LABEL "Действие!по " FORMAT "99/99/9999":U
      tt_price-all.shift-2  COLUMN-LABEL "См!по" FORMAT ">9":U
      (if tt_price-all.time-2 = 0 then "" else string(tt_price-all.time-2,"hh:mm")) @ stime-2 COLUMN-LABEL "Время!по" FORMAT "x(5)":U
      tt_price-all.grp-name COLUMN-LABEL "Покупатели! " FORMAT "x(20)":U
      tt_price-all.interv-name COLUMN-LABEL "Интервал!группы" FORMAT "x(25)":U
      tt_price-all.plt-id COLUMN-LABEL "ТПЛ! "
      tt_price-all.pdf-id COLUMN-LABEL "ДНЦ! "
     /*
     tt_price-all.fact-order  FORMAT ">>>>>>>>>9.9999999999":U
      tt_price-all.type-price
      tt_price-all.fact-order-sys-from  FORMAT ">>>>>>>>>9.9999999999":U
      tt_price-all.fact-order-sys-to    FORMAT ">>>>>>>>>9.9999999999":U
      p-fact-order FORMAT ">>>>>>>>>9.9999999999":U
      */
      tt_price-all.pay-name COLUMN-LABEL "Тип платежа! " FORMAT "x(25)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 99 BY 10.75 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-quit AT ROW 1 COL 1
     B-save AT ROW 1 COL 11
     B-pdf AT ROW 1 COL 21 WIDGET-ID 2
     B-price-doc AT ROW 1 COL 32 WIDGET-ID 4
     B-color AT ROW 1 COL 86.88
     B-Help AT ROW 1 COL 90
     BROWSE-3 AT ROW 2.25 COL 1
     date-f AT ROW 1.21 COL 56.25 COLON-ALIGNED WIDGET-ID 6
     time-f AT ROW 1.21 COL 70.63 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     SPACE(13.23) SKIP(11.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ручной выбор цены"
         DEFAULT-BUTTON B-save CANCEL-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_currency B "?" ? ub currency
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-3 B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-3
/* Query rebuild information for BROWSE BROWSE-3
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt_price-all NO-LOCK,
      EACH buf_currency OF tt_price-all  NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-3 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Ручной выбор цены */
DO:
run uf-set in this-procedure(
    input  {&uf-color}
    ,input v-cntxt-userid
    ,input string(is-color)
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
) no-error    .

if available tt_price-all then do:
  assign
      p-plt-id             = tt_price-all.plt-id
      p-plt-db-num         = tt_price-all.plt-db-num
      p-pdf-id             = tt_price-all.pdf-id
      p-pdf-db-num         = tt_price-all.pdf-db
      p-sale-price-base    = tt_price-all.price-sale-base
      p-sale-price-rubl    = tt_price-all.price-sale-rubl
  .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Ручной выбор цены */
DO:
run uf-set in this-procedure(
    input  {&uf-color}
    ,input v-cntxt-userid
    ,input string(is-color)
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
) no-error    .

  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-color
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-color Dialog-Frame
ON CHOOSE OF B-color IN FRAME Dialog-Frame
DO:
  if B-color:IMAGE  = "cmp/nocol.bmp" then
  do:
    B-color:LOAD-IMAGE-UP("cmp/color.bmp") in frame {&frame-name}  . /* покрасим */
    is-color = true .
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  end.
  else do:
     B-color:LOAD-IMAGE-UP("cmp/nocol.bmp") in frame {&frame-name}  . /* снимим цвет */
     is-color = false  .
     {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Help Dialog-Frame
ON CHOOSE OF B-Help IN FRAME Dialog-Frame /* Помощь */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-pdf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-pdf Dialog-Frame
ON CHOOSE OF B-pdf IN FRAME Dialog-Frame /* ДНЦ */
DO:
/* Просмотр ДНЦ */
define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds  .
define variable v-rec-id as recid no-undo .
define variable v-recid as character no-undo .
define variable v-rec-list as character no-undo .
define variable br-handle      as handle no-undo.
define variable buffer-handle  as handle no-undo.
define variable next-prev      as logical no-undo .
define variable v-tt-recid as recid no-undo .


if not available tt_price-all then return .
find first buf_price-doc-forming no-lock where
           buf_price-doc-forming.plt-id =      tt_price-all.plt-id and
           buf_price-doc-forming.pdf-id =      tt_price-all.pdf-id and
           buf_price-doc-forming.plt-db-num =  tt_price-all.plt-db-num and
           buf_price-doc-forming.pdf-db     =  tt_price-all.pdf-db no-error .
if not available buf_price-doc-forming then return .

find first buf_price-doc-forming-gds where
      buf_price-doc-forming-gds.pdf-db     =  tt_price-all.pdf-db  and
      buf_price-doc-forming-gds.pdf-id     =  tt_price-all.pdf-id  and
      buf_price-doc-forming-gds.plt-db-num =  tt_price-all.plt-db-num and
      buf_price-doc-forming-gds.plt-id     =  tt_price-all.plt-id  and
      buf_price-doc-forming-gds.b-code     =  tt_price-all.b-code
      no-error .


if not available buf_price-doc-forming-gds then return .
v-rec-id = recid (buf_price-doc-forming) .

  assign
    v-rec-id      = recid (buf_price-doc-forming)
    next-prev     = no
    br-handle     = {&browse-name}:handle
    buffer-handle = buffer buf_price-doc-forming :handle .
    .
      run str/df-price.w
        ( input parparentproc,
          input {&lookup} ,
          input buf_price-doc-forming.plt-id ,
          input buf_price-doc-forming.plt-db-num ,
          input recid(buf_price-doc-forming-gds) ,
          output v-rec-list  ,
          input-output v-rec-id  ,
          input-output br-handle ,
          input-output buffer-handle ,
          input-output next-prev
          ) .
          v-tt-recid = recid(tt_price-all) .

  reposition {&browse-name} to recid v-tt-recid no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-price-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-price-doc Dialog-Frame
ON CHOOSE OF B-price-doc IN FRAME Dialog-Frame /* Переоценка */
DO:

/* Просмотр переоценки  */
if not available tt_price-all then return .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds  .

define variable v-rec-id as recid no-undo .
define variable v-recid as character no-undo .

if not available tt_price-all then return .
if tt_price-all.out-code = "" then return .

define variable doc-rec as recid no-undo .
define variable next-prev as logical   no-undo .
define buffer buf_price-doc for ub.price-doc  .
define buffer buf_price-list for ub.price-list  .
for each  buf_price-doc no-lock where
          buf_price-doc.doc-num     =  tt_price-all.out-code
           :
    find first buf_price-list no-lock where
              buf_price-list.doc-num = buf_price-doc.doc-num and
              buf_price-list.price-type = "" and
              buf_price-list.b-code  = tt_price-all.b-code no-error .
    if available buf_price-list then  do:
      doc-rec = recid(buf_price-doc).
    end.

  run str/pr-lkp.p
  ( input parParentProc   ,
    input doc-rec ) .
   return .
end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-quit Dialog-Frame
ON CHOOSE OF B-quit IN FRAME Dialog-Frame /* Отмена */
DO:
  assign
    p-plt-id             = ?
    p-plt-db-num         = ?
    p-pdf-id             = ?
    p-pdf-db-num         = ?
    p-sale-price-base    = ?
    p-sale-price-rubl    = ?
.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-3
&Scoped-define SELF-NAME BROWSE-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-3 Dialog-Frame
ON ROW-DISPLAY OF BROWSE-3 IN FRAME Dialog-Frame
DO:

if is-color = false then return .


define variable v-color  as integer   no-undo .
define variable v-color2 as integer   no-undo .

   case tt_price-all.type-price :
        when  integer({&mpl-type-main}) then do:
            v-color = ?.
        end.
        when  integer({&mpl-type-spec}) then do:
            v-color = dark_green_color.
        end.

        when  integer({&mpl-type-nomain}) then do:
            v-color = DARK_GREY_COLOR.
        end.
        when  integer({&mpl-type-specnomain}) then do:
            v-color =  blue_color .
        end.
   end case.

   case tt_price-all.main-indication :
        when  integer({&mpl-main}) then do:
            if tt_price-all.plt-priority = 0 then v-color2 = ?.
                                             else v-color2 = 8. /* серый */
        end.
        when  integer({&mpl-qnty}) then do:
            v-color2 = 11.
        end.
        when  integer({&mpl-sum}) then do:
            v-color2 = 10.
        end.
        when  integer({&mpl-tnv}) then do:
            v-color2 =  14 .
        end.
   end case.

    tt_price-all.plt-priority :fgcolor in browse {&BROWSE-name} = v-color.
    tt_price-all.b-code :fgcolor in browse {&BROWSE-name} = v-color.
    buf_currency.curr-abbr :fgcolor in browse {&BROWSE-name} = v-color.
    tt_price-all.price-sale:bgcolor in browse {&BROWSE-name} = v-color2.


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
  run init-proc in this-procedure .
  run enable_ui in this-procedure .
      tt_price-all.price-sale:RESIZABLE  in browse {&browse-name} = true .
      tt_price-all.price-sale-rubl:RESIZABLE  in browse {&browse-name} = true .
      tt_price-all.price-sale-base:RESIZABLE  in browse {&browse-name} = true .
  wait-for go of frame {&frame-name}.
end.
run disable_ui in this-procedure .

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
  DISPLAY date-f time-f
      WITH FRAME Dialog-Frame.
  ENABLE B-quit B-save B-pdf B-price-doc B-color B-Help BROWSE-3 date-f time-f
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer buf_goods              for ub.goods      .
define buffer buf_main-code          for ub.bar-code  .
define buffer buf_bar-code           for ub.bar-code  .

run uf-get in this-procedure(
     input  {&uf-color}
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
if v-uf-List_ = "yes"  then is-color = true .
if is-color = true then B-color:LOAD-IMAGE-UP("cmp/color.bmp") in frame {&frame-name}  .
if is-color = false then B-color:LOAD-IMAGE-UP("cmp/nocol.bmp") in frame {&frame-name}  .


find first buf_main-code no-lock where buf_main-code.b-code = p-main-b-code .
find first buf_goods no-lock where buf_goods.gds-code = buf_main-code.gds-code.

find first buf_global-state no-lock no-error .
if not available buf_global-state then do:
   message
     "Не заданы параметры ценообразования!"
     view-as alert-box error
   .
   return error return-value .
end.

define variable v-fact-num-fo as integer   no-undo .
define variable v-fact-date-fo as date     no-undo .
define variable v-shift-num-fo as integer   no-undo .

run  factord-to-date ( input p-fact-order , output v-fact-date-fo ).
run  factord-to-shift-num  ( input p-fact-order , output v-shift-num-fo  ).
run  factord-to-fact-num  ( input p-fact-order , output v-fact-num-fo  ).

date-f = v-fact-date-fo .
time-f = /* "Конец дня" */ "" .

if buf_global-state.pl-use-shift-date-num = false then do:
   tt_price-all.shift-1:visible in browse {&browse-name} = false .
   tt_price-all.shift-2:visible in browse {&browse-name} = false .
end.
else do:
   time-f = string( v-shift-num-fo ) .
   if v-fact-num-fo = 24 then time-f = /* "Посл.смена" */ "" .
end.

if buf_global-state.pl-use-sys-date-time  = false then do:
   stime-1 :visible in browse {&browse-name} = false .
   stime-2 :visible in browse {&browse-name} = false .
end.
else do:
   time-f = string(v-fact-num-fo , "hh:mm" ) .
end.

display date-f time-f  with frame {&frame-name} .

frame {&frame-name}:TITLE = SUBSTITUTE( "Цены товара : &1 &2 " , buf_goods.artic , buf_goods.gds-name) .
run mpl-autoprice in this-procedure
 ( input   true
  ,input   p-cli-type
  ,input   p-cli-code
  ,input   p-main-b-code
  ,input   p-b-code
  ,input   p-obj-type
  ,input   p-obj-code
  ,input   p-qnty-doc
  ,input   p-sum-doc
  ,input   p-vid-pay  /* вид оплаты */
  ,input   p-cash-type-pay  /* тип кассового платежа */
  ,input   p-fact-order
  ,output  p-plt-id
  ,output  p-plt-db-num
  ,output  p-pdf-id
  ,output  p-pdf-db-num
  ,output  p-sale-price-base
  ,output  p-sale-price-rubl
  ,output  p-road-tax-base
  ,output  p-road-tax-rubl
  ,output  p-excise-base
  ,output  p-excise-rubl
  ) no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "mpl-autoprice"
    view-as alert-box error
  .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME