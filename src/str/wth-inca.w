&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_wealth FOR ub.wealth.
DEFINE BUFFER buf_wth-line FOR ub.wth-line.
DEFINE TEMP-TABLE tt-wth-line NO-UNDO LIKE ub.wth-line.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Добавление, изменение, просмотр строки документа МЦ (не инвентаризация)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .

define input parameter par-mode as character no-undo .
define input parameter pardoc-rec as recid no-undo.
define input parameter par-current-w-p-code like ub.wth-line.w-p-code no-undo.
define input parameter par-out-w-p-code like ub.wth-line.out-code no-undo.
define input parameter parext-type like ub.wth-doc.ext-doc-type no-undo .
define input-output parameter parline-rec as recid no-undo.
DEFINE TEMP-TABLE tt-par-dtl NO-UNDO LIKE ub.wth-par

    { str/ttpardt0.i }.
DEFINE TEMP-TABLE tt-wth-parts NO-UNDO LIKE ub.wth-parts.
/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Добавление, изменение, просмотр строки документа МЦ (не инвентаризация)":U.
define variable parext-doc-name as character no-undo.
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
define variable vardoc-code like ub.wth-doc.doc-code no-undo.
define variable lock-line as logical no-undo.
define variable locked-wth as logical no-undo .
define variable base-code         as integer   no-undo .

define buffer buf_wth-parts   for ub.wth-parts.
define buffer buf_wth-dtl     for ub.wth-dtl.


DEF BUFFER b-wealth FOR ub.wealth.
DEF BUFFER b-goods FOR ub.goods.
DEF BUFFER buf_wth-gds FOR ub.wth-gds.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define QUERY-NAME QUERY-lines

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_wth-line

/* Definitions for QUERY QUERY-lines                                    */
&Scoped-define QUERY-STRING-QUERY-lines FOR EACH buf_wth-line ~
      WHERE buf_wth-line.doc-code = vardoc-code NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-QUERY-lines OPEN QUERY QUERY-lines FOR EACH buf_wth-line ~
      WHERE buf_wth-line.doc-code = vardoc-code NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-QUERY-lines buf_wth-line
&Scoped-define FIRST-TABLE-IN-QUERY-QUERY-lines buf_wth-line


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-wth-line.wth-code tt-wth-line.fact-sum ~
wealth.wth-name
&Scoped-define ENABLED-TABLES tt-wth-line wealth
&Scoped-define FIRST-ENABLED-TABLE tt-wth-line
&Scoped-define SECOND-ENABLED-TABLE wealth
&Scoped-Define ENABLED-OBJECTS B-exit RECT-1 RECT-2 b-quit B-prev B-next ~
B-Help B-wealth T-dtl
&Scoped-Define DISPLAYED-FIELDS tt-wth-line.wth-code tt-wth-line.doc-sum ~
tt-wth-line.fact-sum tt-wth-line.sum-gds-rubl tt-wth-line.sum-gds-base ~
wealth.wth-name
&Scoped-define DISPLAYED-TABLES tt-wth-line wealth
&Scoped-define FIRST-DISPLAYED-TABLE tt-wth-line
&Scoped-define SECOND-DISPLAYED-TABLE wealth
&Scoped-Define DISPLAYED-OBJECTS T-dtl FL-gds-code fl-ProdCode TEXT-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-gds,List-4,List-5,List-6                          */
&Scoped-define List-gds tt-wth-line.sum-gds-rubl tt-wth-line.sum-gds-base ~
fl-gds FL-gds-code fl-artic fl-prodType fl-ProdCode fl-prod-name TEXT-1 ~
fl-curr-abbr

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-dtl
     LABEL "&Номиналы"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-next
     LABEL "&>>"
     SIZE 4 BY 1.

DEFINE BUTTON B-prev
     LABEL "&<<"
     SIZE 4 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "Отменить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-wealth
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE VARIABLE fl-artic AS CHARACTER FORMAT "X(16)":U INITIAL "0"
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 11 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-curr-abbr LIKE ub.currency.curr-abbr
      VIEW-AS TEXT
     SIZE 4 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE fl-gds AS CHARACTER FORMAT "X(256)":U
     LABEL "Товар"
     VIEW-AS FILL-IN
     SIZE 16 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FL-gds-code AS INTEGER FORMAT "999999999" INITIAL 0
     LABEL "Код"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-prod-name AS CHARACTER FORMAT "X(40)"
     VIEW-AS FILL-IN
     SIZE 17.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-ProdCode AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fl-prodType AS CHARACTER FORMAT "X(256)":U
     LABEL "Производитель"
     VIEW-AS FILL-IN
     SIZE 4.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE TEXT-1 AS CHARACTER FORMAT "x(3)":U
      VIEW-AS TEXT
     SIZE 4 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 90 BY 3.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 90 BY 2.75.

DEFINE VARIABLE T-dtl AS LOGICAL INITIAL no
     LABEL "Расшифровка суммы"
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY QUERY-lines FOR
      buf_wth-line SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-dtl AT ROW 1 COL 21
     B-prev AT ROW 1 COL 58.5
     B-next AT ROW 1 COL 62.5
     B-Help AT ROW 1 COL 80
     tt-wth-line.wth-code AT ROW 3 COL 21.88 COLON-ALIGNED
          LABEL "Материальная ценность"
          VIEW-AS FILL-IN
          SIZE 15.13 BY 1
     B-wealth AT ROW 3 COL 39
     tt-wth-line.doc-sum AT ROW 4.5 COL 22 COLON-ALIGNED
          LABEL "Кол-во движения"
          VIEW-AS FILL-IN
          SIZE 15 BY 1
          FGCOLOR 4
     tt-wth-line.fact-sum AT ROW 4.5 COL 52.5 COLON-ALIGNED
          LABEL "Кол-во факт"
          VIEW-AS FILL-IN
          SIZE 14.5 BY 1
          FGCOLOR 4
     T-dtl AT ROW 4.5 COL 72.5
     tt-wth-line.sum-gds-rubl AT ROW 7.25 COL 19.5 COLON-ALIGNED WIDGET-ID 264
          LABEL "Сумма по связ." FORMAT "->,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
          FGCOLOR 4
     tt-wth-line.sum-gds-base AT ROW 7.25 COL 42 COLON-ALIGNED NO-LABEL WIDGET-ID 262 FORMAT "->,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 14 BY 1
          FGCOLOR 4
     fl-gds AT ROW 9 COL 19.5 COLON-ALIGNED WIDGET-ID 58
     FL-gds-code AT ROW 9 COL 42 COLON-ALIGNED WIDGET-ID 250
     fl-artic AT ROW 9 COL 66.5 COLON-ALIGNED WIDGET-ID 46
     fl-prodType AT ROW 10.25 COL 19.5 COLON-ALIGNED WIDGET-ID 54
     fl-ProdCode AT ROW 10.25 COL 29 COLON-ALIGNED NO-LABEL WIDGET-ID 56
     fl-prod-name AT ROW 10.25 COL 44 NO-LABEL WIDGET-ID 248
     ub.wealth.wth-name AT ROW 3 COL 42.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 28.5 BY 1
          FGCOLOR 4
     TEXT-1 AT ROW 6 COL 20 COLON-ALIGNED NO-LABEL WIDGET-ID 270
     fl-curr-abbr AT ROW 6 COL 42.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 256
          BGCOLOR 3 FGCOLOR 15
     RECT-1 AT ROW 8.5 COL 2 WIDGET-ID 266
     RECT-2 AT ROW 5.75 COL 2 WIDGET-ID 268
     SPACE(0.74) SKIP(3.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Строка документа движения МЦ"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_wealth B "?" ? ub wealth
      TABLE: buf_wth-line B "?" ? ub wth-line
      TABLE: tt-wth-line T "?" NO-UNDO ub wth-line
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-dtl IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-wth-line.doc-sum IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-wth-line.fact-sum IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN fl-artic IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE 3                                               */
ASSIGN
       fl-artic:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN fl-curr-abbr IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE 3 LIKE = ub.currency.curr-abbr EXP-SIZE         */
ASSIGN
       fl-curr-abbr:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN fl-gds IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE 3                                               */
ASSIGN
       fl-gds:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN FL-gds-code IN FRAME Dialog-Frame
   NO-ENABLE 3                                                          */
ASSIGN
       FL-gds-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN fl-prod-name IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE ALIGN-L 3                                       */
ASSIGN
       fl-prod-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN fl-ProdCode IN FRAME Dialog-Frame
   NO-ENABLE 3                                                          */
ASSIGN
       fl-ProdCode:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN fl-prodType IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE 3                                               */
ASSIGN
       fl-prodType:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-wth-line.sum-gds-base IN FRAME Dialog-Frame
   NO-ENABLE 3 EXP-LABEL EXP-FORMAT                                     */
ASSIGN
       tt-wth-line.sum-gds-base:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-wth-line.sum-gds-rubl IN FRAME Dialog-Frame
   NO-ENABLE 3 EXP-LABEL EXP-FORMAT                                     */
ASSIGN
       tt-wth-line.sum-gds-rubl:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN TEXT-1 IN FRAME Dialog-Frame
   NO-ENABLE 3                                                          */
ASSIGN
       TEXT-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-wth-line.wth-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "NO-LOCK INDEXED-REPOSITION KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK QUERY QUERY-lines
/* Query rebuild information for QUERY QUERY-lines
     _TblList          = "ub.buf_wth-line"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "buf_wth-line.doc-code = vardoc-code"
     _Design-Parent    is DIALOG-BOX Dialog-Frame @ ( 2.25 , 86 )
*/  /* QUERY QUERY-lines */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Строка документа движения МЦ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-dtl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-dtl Dialog-Frame
ON CHOOSE OF B-dtl IN FRAME Dialog-Frame /* Номиналы */
DO:

{ gbl/stdbtn.i }
  assign
  tt-wth-line.doc-sum
  tt-wth-line.fact-sum
  tt-wth-line.wth-code
  .
  if ub.wth-doc.ext-doc-type = {&WDEDT_exch} then do:
    run str/wth-dtle.w (
                   input parparentproc
                  ,INPUT p-curr-host-code
                  ,INPUT p-curr-obj-type
                  ,INPUT p-curr-obj-code
                  ,INPUT par-mode
                  ,INPUT parline-rec
                  ,INPUT tt-wth-line.doc-code
                  ,INPUT tt-wth-line.wth-code
                  ,INPUT tt-wth-line.w-p-code
                  ,INPUT tt-wth-line.doc-sum
                  ,INPUT tt-wth-line.fact-sum
                  ,INPUT tt-wth-line.bef-sum
                  ,INPUT tt-wth-line.aft-sum
                  ,INPUT ub.wth-doc.doc-type
                  ,INPUT ub.wth-doc.ext-doc-type
                  ,input-output table tt-par-dtl ) .

  end.
  else do:
  run str/wth-dtlc.w (
                   input parparentproc
                  ,INPUT p-curr-host-code
                  ,INPUT p-curr-obj-type
                  ,INPUT p-curr-obj-code
                  ,INPUT par-mode
                  ,INPUT parline-rec
                  ,INPUT tt-wth-line.doc-code
                  ,INPUT tt-wth-line.wth-code
                  ,INPUT tt-wth-line.w-p-code
                  ,INPUT tt-wth-line.doc-sum
                  ,INPUT tt-wth-line.fact-sum
                  ,INPUT tt-wth-line.bef-sum
                  ,INPUT tt-wth-line.aft-sum
                  ,INPUT ub.wth-doc.doc-type
                  ,INPUT ub.wth-doc.ext-doc-type
                  ,input-output table tt-par-dtl ) .
   end.

/* if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове str/wth-dtlc.w" skip
      error-status:get-message(1) skip
      return-value skip
      view-as alert-box error .
      return no-apply.
 end. */
 /* если мц серийная рассчитываем суммы автоматически */
 if buf_wealth.is-ser = 1 and par-mode <> {&lookup} then do:

  { str/wthlnsum.i tt-wth-line tt-par-dtl }
  display
   tt-wth-line.doc-sum
   tt-wth-line.fact-sum
   tt-wth-line.sum-gds-rubl
   tt-wth-line.sum-gds-base
  with frame Dialog-Frame.
 end.
  run control-dtl in this-procedure(output lock-line).
  run lock-proc in this-procedure(input lock-line).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
{ gbl/stdbtn.i }
  run proc-save-line in this-procedure ( input no, input-output par-mode) No-ERROR.
  if error-status:error then return no-apply.
  APPLY "GO":U TO FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-next Dialog-Frame
ON CHOOSE OF B-next IN FRAME Dialog-Frame /* >> */
DO:
  run proc-b-move in this-procedure ( input self:name) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-prev Dialog-Frame
ON CHOOSE OF B-prev IN FRAME Dialog-Frame /* << */
DO:
  run proc-b-move in this-procedure ( input self:name) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-wealth
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-wealth Dialog-Frame
ON CHOOSE OF B-wealth IN FRAME Dialog-Frame
DO:
  define variable v_rid-list AS CHAR NO-UNDO.
  run ref/wth-ref.w (
                 input parparentproc
                ,input "b-sel":U
                ,input ub.wth-doc.host-code
                ,input ub.wth-doc.obj-type
                ,input ub.wth-doc.obj-code
                ,input (if lookup(ub.wth-doc.ext-doc-type,{&WDEDT_List-Ser}) > 0 then "wth-ser":U  else if lookup(ub.wth-doc.ext-doc-type,{&WDEDT_List-UnSer}) > 0 then "wth-nser":U else {&all})
                ,input-OUTPUT v_rid-list ).
  if v_rid-list = "":u then return no-apply.
  FIND FIRSt buf_wealth NO-LOCK WHERE
             RECID( buf_wealth ) = INT( ENTRY( NUM-ENTRIES( v_rid-list ), v_rid-list ) ) NO-ERROR.
  IF AVAIL buf_wealth THEN DO:
    DISPLAY
    buf_wealth.wth-code @ tt-wth-line.wth-code
    buf_wealth.wth-name @ ub.wealth.wth-name
    WITH FRAME {&FRAME-NAME}.
    for each tt-par-dtl: /*Для случая, когда заходили в детализацию, а потом изменили МЦ*/
      delete tt-par-dtl.
    end.
  END.
RUN DISP-fl IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-line.doc-sum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-line.doc-sum Dialog-Frame
ON LEAVE OF tt-wth-line.doc-sum IN FRAME Dialog-Frame /* Кол-во движения */
DO:
  tt-wth-line.fact-sum:SCREEN-VALUE = SELF:SCREEN-VALUE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-line.wth-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-line.wth-code Dialog-Frame
ON LEAVE OF tt-wth-line.wth-code IN FRAME Dialog-Frame /* Материальная ценность */
DO:
  RUN disp-fl IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME wealth.wth-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wealth.wth-name Dialog-Frame
ON LEAVE OF wealth.wth-name IN FRAME Dialog-Frame /* Название */
DO:
  RUN disp-fl IN THIS-PROCEDURE.
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
  if par-mode <> {&update} and par-mode <> {&add-def} and par-mode <> {&lookup} then do:
      message vss-workfile vss-revision vss-description skip
                  "Неверный параметр вызова par-mode"
      view-as alert-box ERROR.
      return error.
  end.
  if par-mode = {&lookup} then do:
    FIND FIRST ub.wth-doc No-LOCK WHERE
               recid(ub.wth-doc) = pardoc-rec No-ERROR.
  end.
  else do:
    FIND FIRST ub.wth-doc EXCLUSIVE-LOCK WHERE
               recid(ub.wth-doc) = pardoc-rec No-ERROR.
  end.
  IF NOT avail ub.wth-doc then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найден документ движения МЦ"
    view-as alert-box.
    return error.
  end.
  vardoc-code = ub.wth-doc.doc-code.
  OPEN QUERY QUERY-lines
  FOR EACH buf_wth-line WHERE
           buf_wth-line.doc-code = vardoc-code NO-LOCK INDEXED-REPOSITION.
  if par-mode <> {&add-def} then do:
    if par-mode = {&lookup} then do:
      get first {&query-name}.
      repeat while parline-rec <> recid(buf_wth-line):
        get next {&query-name}.
      end.
    end.
    else do:
      get first {&query-name} exclusive-lock.
      repeat while parline-rec <> recid(buf_wth-line):
        get next {&query-name} exclusive-lock.
      end.
    end.
    IF error-status:error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена строка по документу движения МЦ"
      view-as alert-box.
      return error.
    end.
  end.
  run fill-tables in this-procedure.
  RUN Myenable in this-procedure.
  RUN disp-fl IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control-dtl Dialog-Frame
PROCEDURE control-dtl :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter lock-line as logical no-undo.
if not avail tt-wth-line then return error.
if par-mode = {&add-def} or can-find(first tt-par-dtl) then dO:
  if not available buf_wealth then  t-dtl:screen-value in frame {&frame-name} =  "no".
  else if buf_wealth.is-ser = 0 then do:   /* МЦ  не серйная */
    find first tt-par-dtl NO-LOCK  where tt-par-dtl.doc-sum > 0  No-ERROR .
    t-dtl:screen-value in frame {&frame-name} = (if available tt-par-dtl then "yes" else "no").
  end.
  else do:
    t-dtl:screen-value in frame {&frame-name} = if can-find(first buf_wth-parts
                                                            where buf_wth-parts.wth-code = tt-wth-line.wth-code and
                                                                  buf_wth-parts.w-p-code = tt-wth-line.w-p-code  and
                                                                  buf_wth-parts.out-code = tt-wth-line.doc-code
                                                             ) then   "yes" else "no".
  end.
end.
else do:
       find first ub.wth-dtl No-LOCK  where
                    ub.wth-dtl.doc-code = tt-wth-line.doc-code AND
                    ub.wth-dtl.wth-code = tt-wth-line.wth-code AND
                    ub.wth-dtl.w-p-code = tt-wth-line.w-p-code No-ERROR .
     t-dtl:screen-value in frame {&frame-name} = (if available wth-dtl then "yes" else "no").

end.
if t-dtl:screen-value in frame {&frame-name} = "yes" or par-mode = {&lookup}
then lock-line = yes.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-fl Dialog-Frame
PROCEDURE disp-fl :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEF VAR v-doc-host-code like ub.sysconf.host-code no-undo .
define buffer buf_currency for ub.currency  .
define buffer buf_clients for ub.clients .

ASSIGN FRAME   {&FRAME-NAME} tt-wth-line.wth-code.
IF NOT( AVAILABLE buf_wealth AND buf_wealth.wth-code =  tt-wth-line.wth-code)
THEN DO:
    FIND FIRST buf_wealth NO-LOCK WHERE
         buf_wealth.wth-code =  tt-wth-line.wth-code NO-ERROR.
END.

IF NOT AVAILABLE buf_wealth  OR (AVAILABLE buf_wealth AND buf_wealth.is-ser = 0) THEN DO:
    HIDE
        {&list-gds}
    IN FRAME {&FRAME-NAME}.
    enable tt-wth-line.doc-sum  when   AVAILABLE buf_wealth  and par-mode <> {&lookup}
    with frame {&FRAME-NAME}.
    if ub.wth-doc.doc-type = {&income} and ub.wth-doc.exter_ = no and par-mode <> {&lookup} and  AVAILABLE buf_wealth   then do:
      enable tt-wth-line.fact-sum
      with frame {&FRAME-NAME}.
      disable tt-wth-line.doc-sum
      with frame {&FRAME-NAME}.
    end.

    RETURN.   /*Если не серийная МЦ или такой нет гасим поля*/
END.
DO WITH FRAME  {&FRAME-NAME}:
/*Определение фирмы объекта и баз. вал.*/
FIND FIRST buf_clients NO-LOCK WHERE
    buf_clients.obj-type = tt-wth-line.obj-type AND
    buf_clients.obj-code = tt-wth-line.obj-code .
   v-doc-host-code =  buf_clients.host-code.
      { gbl/basecode.i
          v-doc-host-code
          base-code
      }
   find first Buf_currency where Buf_currency.curr-code = base-code no-lock no-error.
   if available Buf_currency then DO :
       fl-curr-abbr:SCREEN-VALUE = Buf_currency.curr-abbr .
   END.

/*       define variable g#ret-sup-pay as integer   no-undo .                                    */
/*       define buffer buf_sysconf for ub.sysconf.                                               */
/*                                                                                               */
/*       find first buf_sysconf no-lock where buf_sysconf.host-code = v-doc-host-code no-error . */
/*       g#ret-sup-pay = buf_sysconf.ret-sup-pay . */

view {&list-gds}.
disable tt-wth-line.doc-sum
    with frame {&FRAME-NAME}.


DISPLAY
    tt-wth-line.sum-gds-rubl
    tt-wth-line.sum-gds-base
.


      find first ub.wth-gds no-lock where
              ub.wth-gds.wth-code = tt-wth-line.wth-code no-error .
      if available ub.wth-gds  then DO :
          FIND FIRST b-goods WHERE b-goods.gds-code = ub.wth-gds.gds-code NO-LOCK NO-ERROR.
          IF AVAILABLE b-goods THEN DO WITH FRAME {&FRAME-NAME}:
                 fl-artic:SCREEN-VALUE = b-goods.artic.
                 fl-prodType:SCREEN-VALUE = string(b-goods.prod-type).
                 fl-prodCode:SCREEN-VALUE = string(b-goods.prod-code).
                 fl-gds:SCREEN-VALUE = b-goods.gds-name.
                 fl-gds-code:SCREEN-VALUE = string(b-goods.gds-code).
           END.

           ELSE DO:  ASSIGN fl-artic:SCREEN-VALUE = '?':U
                 fl-prodType:SCREEN-VALUE = '?':U
                 fl-prodCode:SCREEN-VALUE = '?':U
                 fl-gds:SCREEN-VALUE = '?':U
                 fl-gds-code:SCREEN-VALUE = '?':U
                 fl-prod-name:SCREEN-VALUE = '?':U.
           END.
          FIND FIRST ub.clients NO-LOCK WHERE ub.clients.obj-type = b-goods.prod-type and ub.clients.obj-code = b-goods.prod-code NO-ERROR.
          IF AVAILABLE ub.clients THEN DO WITH FRAME {&FRAME-NAME}:
              fl-prod-name:SCREEN-VALUE = ub.clients.obj-name.
          END.
          ELSE do:
             ASSIGN fl-prod-name:SCREEN-VALUE = '?':U.
          END.
      END.
      ELSE DO:  ASSIGN fl-artic:SCREEN-VALUE = '?':U
             fl-prodType:SCREEN-VALUE = '?':U
             fl-prodCode:SCREEN-VALUE = '?':U
             fl-gds:SCREEN-VALUE = '?':U
             fl-gds-code:SCREEN-VALUE = '?':U
             fl-prod-name:SCREEN-VALUE = '?':U.
      END.

 END.
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
  DISPLAY T-dtl FL-gds-code fl-ProdCode TEXT-1
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-wth-line THEN
    DISPLAY tt-wth-line.wth-code tt-wth-line.doc-sum tt-wth-line.fact-sum
          tt-wth-line.sum-gds-rubl tt-wth-line.sum-gds-base
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.wealth THEN
    DISPLAY ub.wealth.wth-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit RECT-1 RECT-2 b-quit B-prev B-next B-Help tt-wth-line.wth-code
         B-wealth tt-wth-line.fact-sum T-dtl ub.wealth.wth-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
for each tt-wth-line:
  delete tt-wth-line.
end.
for each tt-par-dtl:
    delete tt-par-dtl.
end.
release buf_wealth.
  if par-mode = {&add-def} then do:
    run cur-time in this-procedure ( output v-today, output v-time).
    { trg/wth-licr.i tt-wth-line ub.wth-doc doc par-current-w-p-code par-out-w-p-code v-today }
  end.
  else do:
    create tt-wth-line.
    buffer-copy buf_wth-line to tt-wth-line.
    FIND FIRST buf_wealth No-LOCK WHERE
               buf_wealth.wth-code = tt-wth-line.wth-code No-error.
    find first ub.wth-dtl No-LOCK WHERE
                  ub.wth-dtl.wth-code = tt-wth-line.wth-code AND
                  ub.wth-dtl.doc-code = tt-wth-line.doc-code AND
                  ub.wth-dtl.w-p-code = tt-wth-line.w-p-code  No-ERROR.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE lock-proc Dialog-Frame
PROCEDURE lock-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER lock-line as logical no-undo.
  if lock-line then
  DISABLE
  b-wealth
  tt-wth-line.wth-code
  with frame {&frame-name}
  .
  ELSE
  ENABLE
  b-wealth when locked-wth = no
  tt-wth-line.wth-code when locked-wth = no
  with frame {&frame-name}
  .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
   TEXT-1 = "{&abbr_rub_allshift}" .
   display TEXT-1 with frame {&frame-name} .
IF AVAILABLE tt-wth-line THEN
    DISPLAY
    tt-wth-line.wth-code
    tt-wth-line.doc-sum
    tt-wth-line.fact-sum
  WITH FRAME Dialog-Frame.
IF AVAILABLE buf_wealth THEN
    DISPLAY
    buf_wealth.wth-name @ ub.wealth.wth-name
   WITH FRAME Dialog-Frame.
  ELSE
  DISPLAY
  '':u @ WEALTH.WTH-NAME
  WITH FRAME Dialog-Frame.
CASE par-mode:
  when {&add-def} THEN DO:
    ENABLE
    tt-wth-line.wth-code
/*    tt-wth-line.doc-sum  */
    B-Wealth
    B-exit
    b-quit
    b-dtl
    WITH FRAME {&FRAME-NAME}.
    HIDE
    tt-wth-line.fact-sum
    IN FRAME {&FRAME-NAME}
    B-Next IN FRAME {&FRAME-NAME}
    B-Prev IN FRAME {&FRAME-NAME}
    .
    locked-wth = no.
  END.
  when {&update}  THEN DO:
      IF ub.wth-doc.status_ = {&wayb} THEN DO:
        ENABLE
        tt-wth-line.wth-code
       /* tt-wth-line.doc-sum  */
        B-Wealth
        B-exit
        b-quit
        b-dtl
        WITH FRAME {&FRAME-NAME}.
        HIDE
        tt-wth-line.fact-sum IN FRAME {&FRAME-NAME}
        B-Next        IN FRAME {&FRAME-NAME}
        B-Prev        IN FRAME {&FRAME-NAME}
        .
        locked-wth = no.
      END.
    ELSE IF wth-doc.status_ = {&permitted} THEN DO:
        DISPLAY
        tt-wth-line.fact-sum
        WITH FRAME {&FRAME-NAME}.
        ENABLE
        tt-wth-line.fact-sum
        B-exit
        b-quit
        b-dtl when avail ub.wth-dtl
        WITH FRAME {&FRAME-NAME}.
        HIDE
        B-Next IN FRAME {&FRAME-NAME}
        B-Prev IN FRAME {&FRAME-NAME}
        .
        locked-wth = yes.
      END.
    END.
    when {&lookup}  THEN DO:
      IF wth-doc.status_ <> {&wayb} THEN DO:
        DISPLAY
        tt-wth-line.fact-sum WITH FRAME {&FRAME-NAME}.
      END.
      ENABLE
      B-Next
      B-Prev
      b-quit
      b-dtl when avail ub.wth-dtl
      WITH FRAME {&FRAME-NAME}.
      HIDE
      B-Wealth IN FRAME {&FRAME-NAME}
      .
      locked-wth = yes.
      b-quit:label = 'Выход'.
    END.
  END CASE.
  if wth-doc.doc-type = {&declaration} then do:
    hide
    tt-wth-line.fact-sum
    in frame {&frame-name} .
  end.
  run control-dtl in this-procedure ( output lock-line).
  run lock-proc in this-procedure ( input lock-line).
  ENABLE
  b-help
  WITH FRAME {&FRAME-NAME}.
     parext-doc-name = ENTRY(LOOKUP(parext-type, {&WDEDT_List}), {&WDEDT_List-full}) no-error.
  FRAME {&FRAME-NAME}:TITLE =
      "Документ № " + wth-doc.doc-code + " " + CAPS(parext-doc-name) + "  - " + CAPS( par-mode ) + " матценности".
  VIEW FRAME {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-move Dialog-Frame
PROCEDURE proc-b-move :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER par-action as character No-UNDO.

define variable is-updated as logical no-undo.
define variable loc#log as logical no-undo.
define variable v-line-rec as recid no-undo .

  ASSIGN v-line-rec = RECID( buf_wth-line ).
  CASE par-action:
    when "b-next":U then do:
        GET NEXT {&query-name} NO-LOCK.
    end.
    when "b-prev":U then do:
        GET PREV {&query-name} NO-LOCK.
    end.
  END CASE.
  IF AVAIL buf_wth-line THEN DO:
    ASSIGN v-line-rec = RECID( buf_wth-line ).
    run fill-tables in this-procedure.
    run MyEnable in this-procedure.
    RUN disp-fl IN THIS-PROCEDURE.
  END.
  ELSE DO:
    CASE par-action:
        when "b-next":U then do:
            GET PREV {&query-name} NO-LOCK.
        end.
        when "b-prev":U then do:
            GET NEXT {&query-name} NO-LOCK.
        end.
    END CASE.
    FIND FIRST buf_wth-line NO-LOCK WHERE
                    RECID( buf_wth-line ) = v-line-rec NO-ERROR.
    MESSAGE
      "Это" ( IF par-action = "B-Next":U THEN "последняя" ELSE "первая" )
      "строка в документе!"
    VIEW-AS ALERT-BOX INFORMATION.
    RETURN NO-APPLY.
  END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save-line Dialog-Frame
PROCEDURE proc-save-line :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER par-log as logical no-undo .
define input-output parameter loc-mode as character no-undo.
DEFINE VARIABLE var-entry as character no-undo .
IF loc-mode = {&lookup} THEN DO:
   RETURN NO-APPLY.
END.
parline-rec = if loc-mode = {&add-def} then ? else parline-rec.
assign
frame {&frame-name} tt-wth-line.wth-code
frame {&frame-name} tt-wth-line.doc-sum
frame {&frame-name} tt-wth-line.fact-sum
.

 run str/wth-lnc1.p (
                      input-output parline-rec
                      ,input  loc-mode
                      ,input no
                      ,input vardoc-code
                      ,input tt-wth-line.wth-code
                      ,input tt-wth-line.w-p-code
                      ,input tt-wth-line.out-code
                      ,input tt-wth-line.doc-sum
                      ,input tt-wth-line.fact-sum
                      ,input table tt-par-dtl
                      ,input par-log
                      ,input parext-type
                      ,input tt-wth-line.sum-gds-rubl
                      ,input tt-wth-line.sum-gds-base
                      ) no-error.
  IF ERROR-STATUS:ERROR THEN DO:
    if var-entry <> '':U then do:
      CASE entry(1, var-entry, {&delim-par}):
        when "wth-code":U then do:
            APPLY "ENTRY":U TO tt-wth-line.wth-code IN FRAME {&FRAME-NAME}.
        end.
        when "doc-sum":U then do:
            APPLY "ENTRY":U TO tt-wth-line.doc-sum IN FRAME {&FRAME-NAME}.
        end.
        when "fact-sum":U then do:
            APPLY "ENTRY":U TO tt-wth-line.fact-sum IN FRAME {&FRAME-NAME}.
        end.
        when "wth-dtl":U then do:
            APPLY "ENTRY":U TO b-dtl IN FRAME {&FRAME-NAME}.
       end.
      END CASE.
     end.
    RETURN error.
  END.
  loc-mode = {&update}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME