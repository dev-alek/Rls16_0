&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE status-edi NO-UNDO LIKE ub.ord-blank
       field state as char
       field date-st as char
       field date-time as datetime
       field transport as character
       field err-code as integer
       field des-err as character
       field gds-code as integer
       field color_ as integer
       index pi gds-code date-st.
DEFINE BUFFER X_goods FOR ub.goods.
DEFINE BUFFER X_ord-line FOR ub.ord-line.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Информация о статусах EDI

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 07/26/05
*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Информация о статусах EDI".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ cus/str-edi.i  }
{ cus/ordlnatt.i }
{ cus/cr-edist.i }

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter  p-doc-code as character no-undo .

/* Local Variable Definitions ---                                       */

define buffer buf_ord-doc for ub.ord-doc.
define variable  f-rcv   as decimal   no-undo .
define variable  f-delta as decimal   no-undo .
define variable gds-rec as recid no-undo .
define variable list-mode as character no-undo .
DEFINE BUFFER buf_status-edi FOR status-edi.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-status-gds

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_status-edi status-edi X_ord-line X_goods

/* Definitions for BROWSE br-status-gds                                 */
&Scoped-define FIELDS-IN-QUERY-br-status-gds buf_status-edi.state buf_status-edi.date-st fill("!", buf_status-edi.err-code) get-pack-num(buf_status-edi.transport)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-status-gds
&Scoped-define SELF-NAME br-status-gds
&Scoped-define QUERY-STRING-br-status-gds FOR EACH buf_status-edi where     buf_status-edi.gds-code = X_goods.gds-code and (rs-goods = "all" OR buf_status-edi.date-st = status-edi.date-st)
&Scoped-define OPEN-QUERY-br-status-gds OPEN QUERY {&SELF-NAME} FOR EACH buf_status-edi where     buf_status-edi.gds-code = X_goods.gds-code and (rs-goods = "all" OR buf_status-edi.date-st = status-edi.date-st).
&Scoped-define TABLES-IN-QUERY-br-status-gds buf_status-edi
&Scoped-define FIRST-TABLE-IN-QUERY-br-status-gds buf_status-edi


/* Definitions for BROWSE BROWSE-edi                                    */
&Scoped-define FIELDS-IN-QUERY-BROWSE-edi status-edi.state status-edi.date-st fill("!", status-edi.err-code) get-pack-num(status-edi.transport)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-edi
&Scoped-define SELF-NAME BROWSE-edi
&Scoped-define QUERY-STRING-BROWSE-edi FOR EACH status-edi NO-LOCK where status-edi.gds-code <= 0
&Scoped-define OPEN-QUERY-BROWSE-edi OPEN QUERY {&SELF-NAME} FOR EACH status-edi NO-LOCK where status-edi.gds-code <= 0 by status-edi.date-time descending .
&Scoped-define TABLES-IN-QUERY-BROWSE-edi status-edi
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-edi status-edi


/* Definitions for BROWSE BROWSE-ord                                    */
&Scoped-define FIELDS-IN-QUERY-BROWSE-ord X_ord-line.line-num X_ord-line.artic X_ord-line.initial-cli-qnty X_ord-line.cli-qnty func-rcv ( buffer X_ord-line ) @ f-rcv (X_ord-line.cli-qnty - func-rcv ( buffer X_ord-line )) @ f-delta X_ord-line.unit-cli X_ord-line.cli-art X_goods.gds-name get-ean13(BUFFER X_ord-line)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-ord
&Scoped-define SELF-NAME BROWSE-ord
&Scoped-define QUERY-STRING-BROWSE-ord FOR EACH X_ord-line       WHERE X_ord-line.doc-code = p-doc-code NO-LOCK, ~
             EACH X_goods NO-LOCK WHERE X_goods.artic = X_ord-line.artic   AND X_goods.prod-type = X_ord-line.prod-type   AND X_goods.prod-code = X_ord-line.prod-code by X_ord-line.doc-code by X_ord-line.line-num
&Scoped-define OPEN-QUERY-BROWSE-ord OPEN QUERY {&SELF-NAME} FOR EACH X_ord-line       WHERE X_ord-line.doc-code = p-doc-code NO-LOCK, ~
             EACH X_goods NO-LOCK WHERE X_goods.artic = X_ord-line.artic   AND X_goods.prod-type = X_ord-line.prod-type   AND X_goods.prod-code = X_ord-line.prod-code by X_ord-line.doc-code by X_ord-line.line-num.
&Scoped-define TABLES-IN-QUERY-BROWSE-ord X_ord-line X_goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-ord X_ord-line
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-ord X_goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-status-gds}~
    ~{&OPEN-QUERY-BROWSE-edi}~
    ~{&OPEN-QUERY-BROWSE-ord}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Cancel rs-goods B-Help BROWSE-ord ~
BROWSE-edi br-status-gds EDITOR-2 EDITOR-1
&Scoped-Define DISPLAYED-OBJECTS rs-goods EDITOR-2 EDITOR-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-rcv Dialog-Frame
FUNCTION func-rcv RETURNS DECIMAL
  (  buffer loc_ord-line for ub.ord-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-ean13 Dialog-Frame
FUNCTION get-ean13 RETURNS CHARACTER
  ( BUFFER buf_ord-line FOR ub.ord-line  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-pack-num Dialog-Frame
FUNCTION get-pack-num RETURNS CHARACTER
  ( INPUT p-transport AS character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE EDITOR-1 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 42.5 BY 4.43 NO-UNDO.

DEFINE VARIABLE EDITOR-2 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 21 BY 7 NO-UNDO.

DEFINE VARIABLE rs-goods AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все сообщ. по товару", "all",
"Только по выбранному событию", "synchro"
     SIZE 64 BY 1.07 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-status-gds FOR
      buf_status-edi SCROLLING.

DEFINE QUERY BROWSE-edi FOR
      status-edi SCROLLING.

DEFINE QUERY BROWSE-ord FOR
      X_ord-line,
      X_goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-status-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-status-gds Dialog-Frame _FREEFORM
  QUERY br-status-gds DISPLAY
      buf_status-edi.state COLUMN-LABEL "Статус" FORMAT "X(23)"
buf_status-edi.date-st COLUMN-LABEL "Дата" FORMAT "X(18)"
fill("!", buf_status-edi.err-code) COLUMN-LABEL "Ош" FORMAT "X(3)"
get-pack-num(buf_status-edi.transport) COLUMN-LABEL "Пакет" FORMAT "X(11)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 38 BY 7
         FONT 4 FIT-LAST-COLUMN TOOLTIP "История по строке".

DEFINE BROWSE BROWSE-edi
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-edi Dialog-Frame _FREEFORM
  QUERY BROWSE-edi DISPLAY
      status-edi.state COLUMN-LABEL "Статус" FORMAT "X(24)"
status-edi.date-st COLUMN-LABEL "Дата\Время" FORMAT "X(21)"
fill("!", status-edi.err-code) COLUMN-LABEL "Ош" FORMAT "X(3)"
get-pack-num(status-edi.transport) COLUMN-LABEL "Пакет" FORMAT "X(11)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 42.5 BY 16
         FONT 4 TOOLTIP "История статусов".

DEFINE BROWSE BROWSE-ord
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-ord Dialog-Frame _FREEFORM
  QUERY BROWSE-ord NO-LOCK DISPLAY
      X_ord-line.line-num COLUMN-LABEL "N/N" FORMAT ">>>>9":U
      X_ord-line.artic FORMAT "X(16)":U
      X_ord-line.initial-cli-qnty COLUMN-LABEL "Первично!Заказано" FORMAT "->>>>>>>9.<<<":U
      X_ord-line.cli-qnty COLUMN-LABEL "Заказано" FORMAT "->>>>>>>9.<<<":U
      func-rcv ( buffer X_ord-line ) @ f-rcv COLUMN-LABEL "Поставлено" FORMAT "->>>>>>>9.<<<":U
      (X_ord-line.cli-qnty - func-rcv ( buffer X_ord-line )) @ f-delta COLUMN-LABEL "Ожидается" FORMAT "->>>>>>>9.<<<":U
      X_ord-line.unit-cli COLUMN-LABEL "Ед.!изм." FORMAT "X(3)":U
      X_ord-line.cli-art COLUMN-LABEL "Артикул!поставщика" FORMAT "X(14)":U
      X_goods.gds-name FORMAT "X(55)":U
      get-ean13(BUFFER X_ord-line) COLUMN-LABEL "EAN в заказе" FORMAT "X(13)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 59 BY 13.5
         FONT 4.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 1
     rs-goods AT ROW 1 COL 23 NO-LABEL WIDGET-ID 6
     B-Help AT ROW 1 COL 89.3
     BROWSE-ord AT ROW 2.27 COL 1
     BROWSE-edi AT ROW 2.27 COL 60
     br-status-gds AT ROW 15.77 COL 1 WIDGET-ID 100
     EDITOR-2 AT ROW 15.77 COL 39 NO-LABEL WIDGET-ID 4
     EDITOR-1 AT ROW 18.33 COL 60 NO-LABEL WIDGET-ID 2
     SPACE(0.29) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Информация EDI"
         CANCEL-BUTTON B-Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: status-edi T "?" NO-UNDO ub ord-blank
      ADDITIONAL-FIELDS:
          field state as char
          field date-st as char
          field transport as character
          field err-code as integer
          field des-err as character
          field gds-code as integer
          field color_ as integer
          index pi gds-code date-st
      END-FIELDS.
      TABLE: X_goods B "?" ? ub goods
      TABLE: X_ord-line B "?" ? ub ord-line
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-ord B-Help Dialog-Frame */
/* BROWSE-TAB BROWSE-edi BROWSE-ord Dialog-Frame */
/* BROWSE-TAB br-status-gds BROWSE-edi Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-status-gds
/* Query rebuild information for BROWSE br-status-gds
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_status-edi where
    buf_status-edi.gds-code = X_goods.gds-code
and (rs-goods = "all" OR buf_status-edi.date-st = status-edi.date-st).
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-status-gds */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-edi
/* Query rebuild information for BROWSE BROWSE-edi
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH status-edi NO-LOCK where status-edi.gds-code <= 0.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-edi */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-ord
/* Query rebuild information for BROWSE BROWSE-ord
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_ord-line
      WHERE X_ord-line.doc-code = p-doc-code NO-LOCK,
      EACH X_goods NO-LOCK WHERE X_goods.artic = X_ord-line.artic
  AND X_goods.prod-type = X_ord-line.prod-type
  AND X_goods.prod-code = X_ord-line.prod-code
by X_ord-line.doc-code
by X_ord-line.line-num.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ","
     _Where[1]         = "X_ord-line.doc-code = p-doc-code"
     _JoinCode[2]      = "ub.goods.artic = X_ord-line.artic
  AND ub.goods.prod-type = X_ord-line.prod-type
  AND ub.goods.prod-code = X_ord-line.prod-code"
     _Query            is OPENED
*/  /* BROWSE BROWSE-ord */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Информация EDI */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-status-gds
&Scoped-define SELF-NAME br-status-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-status-gds Dialog-Frame
ON VALUE-CHANGED OF br-status-gds IN FRAME Dialog-Frame
DO:
  IF AVAILABLE buf_status-edi THEN DO:
    editor-2:screen-value = cr-edist_get-mess-mean (buf_status-edi.des-err).
  END.
  ELSE DO:
     editor-2:screen-value = ''.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-edi
&Scoped-define SELF-NAME BROWSE-edi
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-edi Dialog-Frame
ON ROW-DISPLAY OF BROWSE-edi IN FRAME Dialog-Frame
DO:
  status-edi.state:bgcolor in browse BROWSE-EDI = status-edi.COLOR_.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-edi Dialog-Frame
ON VALUE-CHANGED OF BROWSE-edi IN FRAME Dialog-Frame
DO:
  IF AVAILABLE status-edi THEN DO:
    editor-1:screen-value = (IF status-edi.gds-code < 0
                             THEN  substitute("строка &1 ", status-edi.gds-code)
                             ELSE '') + cr-edist_get-mess-mean (status-edi.des-err).
  END.
  ELSE DO:
     editor-1:screen-value = ''.
  END.
  {&OPEN-QUERY-br-status-gds}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-ord
&Scoped-define SELF-NAME BROWSE-ord
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-ord Dialog-Frame
ON VALUE-CHANGED OF BROWSE-ord IN FRAME Dialog-Frame
DO:
  {&OPEN-QUERY-br-status-gds}
  APPLY "ENTRY" to br-status-gds.
  apply "value-changed" to br-status-gds.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-goods Dialog-Frame
ON VALUE-CHANGED OF rs-goods IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-goods.
  APPLY "VALUE-CHANGED" TO browse-edi.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-status-gds
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
  run MYenable in this-procedure .
  APPLY "VALUE-CHANGED" TO BROWSE-edi.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cr-status-edi Dialog-Frame
PROCEDURE cr-status-edi :
define input  parameter p-gds-code as integer no-undo .
define input  parameter p-state as character no-undo .
define input  parameter p-date as character no-undo .
define input  parameter p-date-time as datetime no-undo .
define input  parameter p-transport as character no-undo .
define input  parameter p-err as integer no-undo .
define input  parameter p-des-err as character no-undo .
define input  parameter p-state-int as integer no-undo .

do
on error undo, return error return-value
:
 &SCOPED-DEFINE order-stts-int1 string(p-state-int)
  create status-edi.
  assign
  status-edi.gds-code = p-gds-code
  status-edi.state   = p-state
  status-edi.date-st = p-date
  status-edi.date-time = p-date-time
  status-edi.transport = p-transport
  status-edi.err-code = p-err
  status-edi.des-err = p-des-err
  status-edi.COLOR_ = INTEGER({&edi-stts-color}) NO-ERROR
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
  DISPLAY rs-goods EDITOR-2 EDITOR-1
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel rs-goods B-Help BROWSE-ord BROWSE-edi br-status-gds EDITOR-2
         EDITOR-1
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

find first buf_ord-doc no-lock where buf_ord-doc.doc-code = p-doc-code no-error .
define variable v-state as character no-undo .
define variable v-date as character no-undo .
define variable v-date-time as datetime no-undo .

define buffer buf_EDI-status for ub.EDI-status  .
define buffer buf2_ord-doc-rcv for ub.ord-doc-rcv  .
define buffer buf_trn-doc for ub.trn-doc  .
define buffer buf_ord-chain for ub.ord-chain .

/* статусы по заказу */
for each buf_EDI-status no-lock where
        buf_EDI-status.tbl-name  = {&table_ord-doc}
    and buf_EDI-status.doc-code  = buf_ord-doc.doc-code :
    v-state = ''.
    &scop order-stts-int1   buf_EDI-status.state
    v-state = {&edi-stts-name} no-error .
    v-date  = string(buf_EDI-status.date-status , "99/99/9999" ) + " " + string( buf_EDI-status.time-status   , "hh:mm:ss" ) .
    v-date-time = datetime(buf_EDI-status.date-status, buf_EDI-status.time-status) .
    run cr-status-edi in this-procedure (  input 0
                                         , input v-state
                                         , input v-date
                                         , input v-date-time
                                         , input buf_edi-status.mess
                                         , INPUT buf_edi-status.err-code
                                         , INPUT buf_edi-status.des-err
                                         , INPUT buf_edi-status.state
                                         ).
end.
for each buf_EDI-status no-lock where
        buf_EDI-status.tbl-name  = {&table_ord-doc}
    and buf_EDI-status.doc-code  BEGINS (buf_ord-doc.doc-code + {&delim-par}):
    v-state = ''.
    &scop order-stts-int1   buf_EDI-status.state
    v-state = {&edi-stts-name} no-error .
    v-date  = string(buf_EDI-status.date-status , "99/99/9999" ) + " " + string( buf_EDI-status.time-status   , "hh:mm:ss" ) .
    v-date-time = datetime(buf_EDI-status.date-status, buf_EDI-status.time-status) .
    run cr-status-edi in this-procedure (  input INTEGER(ENTRY(2, buf_EDI-status.doc-code, {&delim-par}))
                                         , input v-state
                                         , input v-date
                                         , input v-date-time
                                         , input buf_edi-status.mess
                                         , INPUT buf_edi-status.err-code
                                         , INPUT buf_edi-status.des-err
                                         , INPUT buf_edi-status.state
                                         ).
end.

for each buf_EDI-status no-lock where
        buf_EDI-status.tbl-name  = {&table_ord-line}
    and buf_EDI-status.doc-code  BEGINS (buf_ord-doc.doc-code + {&delim-par}) :
    v-state = ''.
    &scop order-stts-int1   buf_EDI-status.state
    v-state = {&edi-stts-name} no-error .
    v-date  = string(buf_EDI-status.date-status , "99/99/9999" ) + " " + string( buf_EDI-status.time-status   , "hh:mm:ss" ) .
    v-date-time = datetime(buf_EDI-status.date-status, buf_EDI-status.time-status) .
    run cr-status-edi in this-procedure (  input integer(entry(2, buf_edi-status.doc-code, {&delim-par}))
                                         , input v-state
                                         , input v-date
                                         , input v-date-time
                                         , input buf_edi-status.mess
                                         , INPUT buf_edi-status.err-code
                                         , INPUT buf_edi-status.des-err
                                         , INPUT buf_edi-status.state
                                         ).
end.



for each buf2_ord-doc-rcv no-lock where
          buf2_ord-doc-rcv.doc-code = buf_ord-doc.doc-code
:
  for each buf_EDI-status no-lock where
          buf_EDI-status.tbl-name  = {&table_ord-doc-rcv}
      and buf_EDI-status.doc-code  = buf2_ord-doc-rcv.rcv-code
    :
    /* прием поставки от поставщика */
    v-state = ''.
    &scop order-stts-int1   buf_EDI-status.state
    v-state = substitute("&1 &2", buf2_ord-doc-rcv.rcv-code, {&edi-stts-name}) no-error .
    v-date  = string(buf_EDI-status.date-status , "99/99/9999" ) + " " + string( buf_EDI-status.time-status   , "hh:mm:ss" ) .
    v-date-time = datetime(buf_EDI-status.date-status, buf_EDI-status.time-status) .
    run cr-status-edi in this-procedure (
                                           input 0
                                         , input v-state
                                         , input v-date
                                         , input v-date-time
                                         , input buf_edi-status.mess
                                         , INPUT buf_edi-status.err-code
                                         , INPUT buf_edi-status.des-err
                                         , INPUT buf_edi-status.state
                                         ).

  end.
  for each buf_EDI-status no-lock where
          buf_EDI-status.tbl-name  = {&table_ord-line-rcv}
      and buf_EDI-status.doc-code  BEGINS (buf2_ord-doc-rcv.rcv-code + {&delim-par}):
      v-state = ''.
      &scop order-stts-int1   buf_EDI-status.state
      v-state = substitute("&1 &2", buf2_ord-doc-rcv.rcv-code, {&edi-stts-name}) no-error .
      v-date  = string(buf_EDI-status.date-status , "99/99/9999" ) + " " + string( buf_EDI-status.time-status   , "hh:mm:ss" ) .
      v-date-time = datetime(buf_EDI-status.date-status, buf_EDI-status.time-status) .
      run cr-status-edi in this-procedure (  input integer(entry(2, buf_edi-status.doc-code, {&delim-par}))
                                           , input v-state
                                           , input v-date
                                           , input v-date-time
                                           , input buf_edi-status.mess
                                           , INPUT buf_edi-status.err-code
                                           , INPUT buf_edi-status.des-err
                                           , INPUT buf_edi-status.state
                                           ).
  end.

  for each buf_ord-chain no-lock where
          buf_ord-chain.doc-code = buf2_ord-doc-rcv.rcv-code
      and buf_ord-chain.doc-type = 'rcv'
      and buf_ord-chain.rel-doc-type = 'trn'
      :

    for each  buf_trn-doc no-lock where
              buf_trn-doc.doc-code = buf_ord-chain.rel-doc-code
          :
      for each buf_EDI-status no-lock where
              buf_EDI-status.tbl-name  = {&table_trn-doc}
          and buf_EDI-status.doc-code  = buf_trn-doc.doc-code
          :
         v-state = ''.
        &scop order-stts-int1   buf_EDI-status.state
        /* Отправка накладной поставщику */    /* статусы накладной TODO*/
        v-state = substitute("&1 &2", buf_trn-doc.doc-code, {&edi-stts-name})  no-error .
        v-date  = string(buf_EDI-status.date-status , "99/99/9999" ) + " " + string( buf_EDI-status.time-status   , "hh:mm:ss" ) .
        v-date-time = datetime(buf_EDI-status.date-status, buf_EDI-status.time-status) .
        run cr-status-edi in this-procedure ( input 0
                                           ,  input v-state
                                            , input v-date
                                            , input v-date-time
                                            , input buf_edi-status.mess
                                            , INPUT buf_edi-status.err-code
                                            , INPUT buf_edi-status.des-err
                                            , INPUT buf_edi-status.state
                                            ).

      end. /*for each buf_EDI-status no-lock where*/
      for each buf_EDI-status no-lock where
          buf_EDI-status.tbl-name  = {&table_doc-line}
      and buf_EDI-status.doc-code  BEGINS (buf_trn-doc.doc-code + {&delim-par})
      :
        &scop order-stts-int1   buf_EDI-status.state
        v-state = ''.
        /* Отправка накладной поставщику */    /* статусы накладной TODO*/
        v-state = substitute("&1 &2 &3", buf_trn-doc.doc-code, {&edi-stts-name})  no-error .
        v-date  = string(buf_EDI-status.date-status , "99/99/9999" ) + " " + string( buf_EDI-status.time-status   , "hh:mm:ss" ) .
        v-date-time = datetime(buf_EDI-status.date-status, buf_EDI-status.time-status) .
        run cr-status-edi in this-procedure ( input integer(entry(2, buf_edi-status.doc-code, {&delim-par}))
                                            , input v-state
                                            , input v-date
                                            , input v-date-time
                                            , input buf_edi-status.mess
                                            , INPUT buf_edi-status.err-code
                                            , INPUT buf_edi-status.des-err
                                            , INPUT buf_edi-status.state
                                            ).



      end. /*for each buf_EDI-status no-lock where*/
    END. /*for each  buf_trn-doc no-lock where*/
  end. /*for each buf_ord-chain no-lock where*/
end.  /*for each buf2_ord-doc-rcv no-lock where*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
rs-goods = "all".
DISPLAY
EDITOR-2
EDITOR-1
WITH FRAME {&frame-name}.
ENABLE
rs-goods
B-Cancel
B-Help
BROWSE-ord
BROWSE-edi
br-status-gds
EDITOR-2
EDITOR-1
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
apply "value-changed" to browse-edi.
apply "value-changed" to browse-ord.
apply "value-changed" to br-status-gds.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-rcv Dialog-Frame
FUNCTION func-rcv RETURNS DECIMAL
  (  buffer loc_ord-line for ub.ord-line ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_ord-line-rcv for ub.ord-line-rcv  .
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
define variable v-cli-qnty as decimal   no-undo .
v-cli-qnty = 0 .
for each buf_ord-line-rcv no-lock where
         buf_ord-line-rcv.doc-code  = loc_ord-line.doc-code and
         buf_ord-line-rcv.artic     = loc_ord-line.artic    and
         buf_ord-line-rcv.prod-type = loc_ord-line.prod-type and
         buf_ord-line-rcv.prod-code = loc_ord-line.prod-code
         :
         find first buf_ord-doc-rcv no-lock where
                    buf_ord-doc-rcv.rcv-code = buf_ord-line-rcv.rcv-code and
                    buf_ord-doc-rcv.doc-code = buf_ord-line-rcv.doc-code    no-error .
         if available buf_ord-doc-rcv and
            ( buf_ord-doc-rcv.status_ = {&fact} or
              buf_ord-doc-rcv.status_ = {&ord-rcv} ) then do
              :
              v-cli-qnty = v-cli-qnty + buf_ord-line-rcv.cli-qnty.
         end.

end.

  RETURN v-cli-qnty.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-ean13 Dialog-Frame
FUNCTION get-ean13 RETURNS CHARACTER
  ( BUFFER buf_ord-line FOR ub.ord-line  ) :
DEFINE VARIABLE v-value AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-type AS CHARACTER NO-UNDO.
RUN ordlineattr-value  IN THIS-PROCEDURE (
                                             input  buf_ord-line.doc-code
                                            ,input  buf_ord-line.gds-code
                                            ,INPUT  {&attr-order-ean13}
                                            ,output v-value
                                            ,output v-type) NO-ERROR.



RETURN v-value.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-pack-num Dialog-Frame
FUNCTION get-pack-num RETURNS CHARACTER
  ( INPUT p-transport AS character ) :
DEFINE VARIABLE v-pack-num-chr AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-route-chr AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dump-ord-int64 AS int64 NO-UNDO.
DEFINE BUFFER buf_esys-route FOR ub.esys-route.
v-pack-num-chr = cr-edist_get-mess-key-value(p-transport, {&edist_pack-num}) NO-ERROR.
IF v-pack-num-chr  = '' THEN DO:
  v-route-chr = cr-edist_get-mess-key-value(p-transport, {&edist_route}) NO-ERROR.
  v-dump-ord-int64 = INT64(v-route-chr) NO-ERROR.
  IF NOT ERROR-STATUS:ERROR THEN DO:
     find first buf_esys-route no-lock where
            buf_esys-route.esr-dump-ord   = v-dump-ord-int64 NO-ERROR.
     IF AVAILABLE buf_esys-route THEN DO:
       ASSIGN
       v-pack-num-chr = (IF buf_esys-route.esr-last-pack = -1
                           THEN {&question-mark}
                            ELSE STRING(buf_esys-route.esr-last-pack)).
        v-pack-num-chr = v-pack-num-chr + "->".
     END.
  END.
END.
RETURN v-pack-num-chr .
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
