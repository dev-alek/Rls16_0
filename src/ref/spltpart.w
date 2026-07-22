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

Разбиение партий

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

/* ***************************  Definitions  ************************** */
define input parameter parparentproc as widget-handle no-undo .
/* Parameters Definitions ---                                           */
define input-output parameter p-line-rec as recid no-undo .
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Разбиение партий" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }

DEFINE TEMP-TABLE qnty-table NO-UNDO
FIELD nn as integer
FIELD qnty like ub.parts.qnty FORMAT ">>,>>>,>>9.999"
INDEX PI IS UNIQUE PRIMARY nn
.
def buffer b-qnty-table for qnty-table.

{ trg/partsplt.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-qnty

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES qnty-table ub.goods

/* Definitions for BROWSE BR-qnty                                       */
&Scoped-define FIELDS-IN-QUERY-BR-qnty qnty-table.nn qnty-table.qnty
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-qnty qnty-table.qnty
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-qnty qnty-table
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-qnty qnty-table
&Scoped-define SELF-NAME BR-qnty
&Scoped-define QUERY-STRING-BR-qnty FOR EACH qnty-table SHARE-LOCK
&Scoped-define OPEN-QUERY-BR-qnty OPEN QUERY {&SELF-NAME} FOR EACH qnty-table SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-qnty qnty-table
&Scoped-define FIRST-TABLE-IN-QUERY-BR-qnty qnty-table


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-qnty}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH ub.goods SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.goods SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.goods
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.goods


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-good B-doc B-split B-Help RECT-4 ~
RECT-1 RECT-3 RECT-2 for-qnty BR-qnty for-goods for-in-code for-parts ~
for-min-rate for-max-rate part-qnty part-cli-qnty all-qnty all-qnty-cli ~
rest-qnty rest-qnty-cli
&Scoped-Define DISPLAYED-OBJECTS for-qnty for-goods for-in-code for-parts ~
for-min-rate for-max-rate part-qnty part-cli-qnty all-qnty all-qnty-cli ~
rest-qnty rest-qnty-cli

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-doc
     LABEL "П&Н"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-good
     LABEL "&Товар"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-part
     LABEL "&Партия"
     SIZE 10 BY 1.

DEFINE BUTTON B-split AUTO-GO
     LABEL "&Разбить"
     SIZE 10 BY 1.

DEFINE VARIABLE all-qnty AS DECIMAL FORMAT ">>,>>9.999":U INITIAL 0
     LABEL "Введено"
      VIEW-AS TEXT
     SIZE 18 BY 1 NO-UNDO.

DEFINE VARIABLE all-qnty-cli AS DECIMAL FORMAT ">>,>>9.999":U INITIAL 0
     LABEL "Введено"
      VIEW-AS TEXT
     SIZE 18 BY 1 NO-UNDO.

DEFINE VARIABLE for-goods AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 93.1 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE for-in-code AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 24.1 BY 1 NO-UNDO.

DEFINE VARIABLE for-max-rate AS DECIMAL FORMAT "->>,>>9.999" INITIAL 0
     LABEL "Макс. кол-во в штуке"
      VIEW-AS TEXT
     SIZE 17 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE for-min-rate AS DECIMAL FORMAT "->>,>>9.999" INITIAL 0
     LABEL "Мин. кол-во в штуке"
      VIEW-AS TEXT
     SIZE 17 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE for-parts AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 35.4 BY 1 NO-UNDO.

DEFINE VARIABLE for-qnty AS DECIMAL FORMAT ">>,>>9.999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 18.4 BY 1 NO-UNDO.

DEFINE VARIABLE part-cli-qnty AS DECIMAL FORMAT ">>,>>9.999":U INITIAL 0
     LABEL "Кол-во изделий"
      VIEW-AS TEXT
     SIZE 18 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE part-qnty AS DECIMAL FORMAT ">>,>>9.999":U INITIAL 0
     LABEL "Вес изделий"
      VIEW-AS TEXT
     SIZE 18 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rest-qnty AS DECIMAL FORMAT "->>,>>9.999":U INITIAL 0
     LABEL "Осталось"
      VIEW-AS TEXT
     SIZE 18 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rest-qnty-cli AS DECIMAL FORMAT "->>,>>9.999":U INITIAL 0
     LABEL "Осталось"
      VIEW-AS TEXT
     SIZE 18 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 43.1 BY 2.87.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35.5 BY 4.7.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32.4 BY 4.7.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97.4 BY 3.27.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-qnty FOR
      qnty-table SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      ub.goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-qnty Dialog-Frame _FREEFORM
  QUERY BR-qnty DISPLAY
      qnty-table.nn column-label "N"
      qnty-table.qnty column-label "Вес"
ENABLE qnty-table.qnty
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 28.5 BY 15.77.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.1
     B-good AT ROW 1 COL 11
     B-doc AT ROW 1 COL 21
     B-split AT ROW 1 COL 31
     B-part AT ROW 1 COL 41
     B-Help AT ROW 1 COL 95
     for-qnty AT ROW 5.83 COL 2.1 NO-LABEL
     BR-qnty AT ROW 7.03 COL 1.9
     for-goods AT ROW 2.5 COL 2.4 COLON-ALIGNED NO-LABEL
     for-in-code AT ROW 3.93 COL 6.3 COLON-ALIGNED NO-LABEL
     for-parts AT ROW 3.93 COL 54.3 COLON-ALIGNED NO-LABEL
     for-min-rate AT ROW 6.37 COL 78.3 COLON-ALIGNED
     for-max-rate AT ROW 7.57 COL 78.1 COLON-ALIGNED
     part-qnty AT ROW 9.5 COL 42.5 COLON-ALIGNED
     part-cli-qnty AT ROW 9.53 COL 78.1 COLON-ALIGNED
     all-qnty AT ROW 10.87 COL 42.5 COLON-ALIGNED
     all-qnty-cli AT ROW 10.97 COL 78.1 COLON-ALIGNED
     rest-qnty AT ROW 12.3 COL 42.5 COLON-ALIGNED
     rest-qnty-cli AT ROW 12.37 COL 78.1 COLON-ALIGNED
     "ПН:" VIEW-AS TEXT
          SIZE 4.3 BY 1 AT ROW 3.93 COL 3.3
     "Партия:" VIEW-AS TEXT
          SIZE 8.4 BY 1 AT ROW 3.93 COL 46.8
     RECT-4 AT ROW 2.2 COL 2.1
     RECT-1 AT ROW 6.07 COL 56.4
     RECT-3 AT ROW 9.27 COL 30.9
     RECT-2 AT ROW 9.27 COL 63.9
     SPACE(0.72) SKIP(9.10)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Разбиение партий"
         DEFAULT-BUTTON B-exit.


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
/* BROWSE-TAB BR-qnty for-qnty Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-part IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-part:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN for-qnty IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-qnty
/* Query rebuild information for BROWSE BR-qnty
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH qnty-table SHARE-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-qnty */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.goods"
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Разбиение партий */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-doc Dialog-Frame
ON CHOOSE OF B-doc IN FRAME Dialog-Frame /* ПН */
DO:
  run str/showdoc.p
    (input parparentproc   /* parparentproc */
    ,input for-in-code     /* p-doc-code    */
    ,input ub.goods.artic     /* p-artic       */
    ,input ub.goods.prod-type /* p-prod-type   */
    ,input ub.goods.prod-code /* p-prod-code   */
    ,input true            /* p-doc-type    */
    ) .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Выход */
DO:
    p-line-rec = ?.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-good
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-good Dialog-Frame
ON CHOOSE OF B-good IN FRAME Dialog-Frame /* Товар */
DO:
  define variable old-min-rate like ub.goods.min-rate no-undo.
  define variable old-max-rate like ub.goods.max-rate no-undo.
  define variable glog as logical no-undo .
  def buffer b1-qnty for qnty-table.
  assign
  old-min-rate = ub.goods.min-rate
  old-max-rate = ub.goods.max-rate
  .
  FIND FIRST ub.db WHERE ub.db.db-num = v-cntxt-db-num NO-LOCK .
  if not avail db then return no-apply.
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_reference_update':U
  {&cntxt-global}
  0
  '':U
  0
  0
  goods.grp-code
  0
  true
  glog
  }

  if glog AND NOT goods.stts <> 0 AND db.add-goods AND NOT transaction
  then do:
    run str/showgds.p ( input parparentproc
                       ,input ? /*p-call-handle*/
                       ,input goods.gds-code
                       ,input {&update}).
    FIND current goods No-LOCK No-ERROR.
    if old-min-rate <> goods.min-rate OR old-max-rate <> goods.max-rate then do:
        assign
        for-min-rate = goods.min-rate
        for-max-rate = goods.max-rate
        .
        display
        for-min-rate
        for-max-rate
        with frame {&frame-name}.
        FOR EACh b1-qnty:
            run check-qnty(b1-qnty.qnty, 0, recid(b1-qnty)) no-error.
            if error-status:error then do:
              REPOSITION br-qnty to recid recid(b1-qnty) NO-ERROR.
              glog = br-qnty:select-focused-ROW( ).
              APPLY "ENTRY" to br-qnty.
              return no-apply.
            end.
        end.
    end.
  end.
  else
  run str/showgds.p ( input parparentproc
                     ,input ? /*p-call-handle*/
                     ,input goods.gds-code
                     ,input {&lookup}) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-split
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-split Dialog-Frame
ON CHOOSE OF B-split IN FRAME Dialog-Frame /* Разбить */
DO:
define variable glog as logical no-undo .
  glog = no.
  if can-find(first qnty-table) then do:
    message "Вы уверены, что хотите разбить партию " for-parts
            "по ПН " for-in-code " на указанные здесь количества?" skip
            "Общее количество изделий по партии" part-cli-qnty
            "Общий вес изделий по партии" part-qnty SKIP
            "Введено количесто изделий" all-qnty-cli "Общим весом" all-qnty SKIP
            "Осталось" rest-qnty-cli "с весом " rest-qnty
    view-as alert-box QUESTION buttons YES-NO update glog.
    if NOT glog then return no-apply.
    FOR EACH temp-parts-qnty:
        delete temp-parts-qnty.
    END.
    FOR EACH qnty-table:
        create temp-parts-qnty.
        assign
        temp-parts-qnty.cli-qnty = 1
        temp-parts-qnty.qnty = qnty-table.qnty
        temp-parts-qnty.fact-qnty = qnty-table.qnty
        .

    END.
    run trg/partsplt.p (
                   input ub.parts.obj-type,
                   input ub.parts.obj-code,
                   input ub.parts.artic,
                   input ub.parts.prod-type,
                   input ub.parts.prod-code,
                   input ub.parts.in-code,
                   input ub.parts.out-code,
                   input ub.parts.part-code,
                   input table temp-parts-qnty) no-error.
    if error-status:error then do:
        message "Не удалось разбить партию!" skip
           error-status:get-message(1)
           view-as alert-box ERROR.
        return no-apply.
    end.
  end.
  else do:
    message "Вы не ввели количества на которые Вы хотите разбить партию"
    view-as alert-box.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-qnty
&Scoped-define SELF-NAME BR-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-qnty Dialog-Frame
ON DELETE-CHARACTER OF BR-qnty IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
  glog = yes.
  if avail qnty-table then do:
    message "Удалить изделие N " qnty-table.nn " с весом "
             qnty-table.qnty
    view-as alert-box question buttons OK-Cancel update glog.
    if glog <> true then return.
    run check-qnty(- qnty-table.qnty, - 1, ?) no-error.
    if error-status:error then return no-apply.
    _MAIN-d:
    DO on error undo _main-d, return no-apply:
        delete qnty-table.
        run update-br no-error.
      IF ERROR-STATUS:ERROR THEN UNDO _main-d, return no-apply.
    end.


  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-qnty Dialog-Frame
ON RETURN OF BR-qnty IN FRAME Dialog-Frame
DO:
  APPLY "ENTRY" to qnty-table.qnty in browse br-qnty.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-qnty Dialog-Frame
ON ROW-LEAVE OF BR-qnty IN FRAME Dialog-Frame
DO:
 define variable new-qnty as decimal no-undo.
   if avail qnty-table then do :
   new-qnty = decimal(qnty-table.qnty:screen-value in browse br-qnty).
   if new-qnty <> qnty-table.qnty then do:
      run check-qnty(new-qnty, 0, recid(qnty-table)) no-error.
      if error-status:error then do:
        display
        qnty-table.qnty
        with browse br-qnty.
        return no-apply.
      end.
      run update-br no-error.
    end.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME for-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL for-qnty Dialog-Frame
ON RETURN OF for-qnty IN FRAME Dialog-Frame
DO:
define variable max-nn as integer no-undo.
  assign
  for-qnty.
  if all-qnty-cli >= part-cli-qnty then do:
    message "Количество введенных изделий уже равно количеству изделий в партии"
    view-as alert-box.
    return no-apply.
  end.
    run check-qnty(for-qnty, 1, ?) no-error.
    if error-status:error then return no-apply.
    FIND LAST qnty-table No-LOCK NO-ERROR.
    IF avail qnty-table then
    max-nn = qnty-table.nn.
    _MAIN:
    DO on error undo _main, return no-apply:
      CREATE qnty-table.
      assign
      qnty-table.nn = max-nn + 1
      qnty-table.qnty = for-qnty.
      run update-br no-error.
      IF ERROR-STATUS:ERROR THEN UNDO _main, return no-apply.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

ON RETURN OF qnty-table.qnty IN BROWSE BR-qnty
DO:

  if avail qnty-table then do:
  run check-qnty(decimal(qnty-table.qnty:screen-value in browse br-qnty), 0, recid(qnty-table)) no-error.
  if error-status:error then return no-apply.
  _Main-l:
  DO ON ERROR UNDO _main-l, return no-apply:
  FIND FIRST b-qnty-table where
            recid(b-qnty-table) = recid(qnty-table) No-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO _main-l, return no-apply.
  assign
  b-qnty-table.qnty = decimal(qnty-table.qnty:screen-value in browse br-qnty).
  run update-br no-error.
  IF ERROR-STATUS:ERROR THEN UNDO _main-l, return no-apply.
  END.
  end.
  APPLY "ENTRY" to for-qnty in frame {&frame-name}.
  return NO-APPLY.

END.


ON END-ERROR, TAB OF qnty-table.qnty IN BROWSE BR-qnty
DO:
    DISPLAY  qnty-table.qnty with browse br-qnty.
    APPLY "ENTRY" to for-qnty in frame {&frame-name}.
    return NO-APPLY.
END.

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
  FIND FIRST parts No-LOCK WHERE recid(parts) = p-line-rec No-ERROR.

  if not avail parts then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена партия" skip
      view-as alert-box error .
    return "error".
  end.
  IF NOT parts.cli-qnty > 1 then do:
      message
      vss-workfile vss-revision vss-description skip
      "Партия состоит из одной единицы товара или уже разбита" skip
      view-as alert-box error .
    return "error".
  end.

  FIND FIRST goods No-LOCK WHERE
             goods.artic = parts.artic AND
             goods.prod-type = parts.prod-type AND
             goods.prod-code = parts.prod-code No-ERROR.
  IF NOT AVAIL goods then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найден товар " parts.artic parts.prod-type string(parts.prod-code) skip
      view-as alert-box error .
    return "error".
  END.
  assign
  for-parts = parts.part-code
  for-in-code = parts.in-code
  part-cli-qnty = parts.cli-qnty
  part-qnty = parts.fact-qnty
  for-min-rate = goods.min-rate
  for-max-rate = goods.max-rate
  for-goods = goods.artic + " " + goods.prod-type + string(goods.prod-code) + " " +
              goods.gds-name.
  RUN enable_UI.
  APPLY "ENTRY" to for-qnty.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-qnty Dialog-Frame
PROCEDURE check-qnty :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter loc-for-qnty as decimal no-undo.
  define input parameter loc-for-qnty-cli as decimal no-undo.
  define input parameter curr-recid as recid no-undo.
  define var loc-all-qnty as decimal no-undo.
  define var loc-all-qnty-cli as decimal no-undo.
  define var loc-rest-qnty as decimal no-undo.
  define var loc-rest-qnty-cli as decimal no-undo.

  if loc-for-qnty = ?
  or loc-for-qnty = 0
  then do:
    message
      "Неверно введен вес изделия" skip
      view-as alert-box error.
    return error.
  end.
  if loc-for-qnty-cli >= 0
  then do:
    if (loc-for-qnty < ub.goods.min-rate)
    then do:
      define variable v-ok as logical   no-undo .
      message
        substitute("Вес изделия &1 меньше, чем минимальный вес, заданный в карточке товара &2"
                  ,loc-for-qnty
                  ,goods.min-rate
                  ) skip
        "Продолжить?" skip
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok <> true
      then do:
        return error.
      end.
    end.
    if loc-for-qnty > goods.max-rate then do:
      message
        substitute("Вес изделия &1 больше, чем максимальный вес, заданный в карточке товара &2"
                  ,loc-for-qnty
                  ,goods.max-rate
                  ) skip
        "Продолжить?" skip
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok <> true
      then do:
        return error.
      end.
    end.
  end.
  assign
    loc-all-qnty = 0
    loc-all-qnty-cli = 0
  .
  for each b-qnty-table no-lock
  on error undo, return error return-value
  :
    if recid(b-qnty-table) <> curr-recid then do:
      assign
        loc-all-qnty = loc-all-qnty + b-qnty-table.qnty
        loc-all-qnty-cli = loc-all-qnty-cli + 1
      .
    end.
  end.
  assign
    loc-all-qnty = loc-all-qnty + loc-for-qnty
    loc-all-qnty-cli = loc-all-qnty-cli + (if loc-for-qnty-cli = 0 then 1 else loc-for-qnty-cli)
    loc-rest-qnty = part-qnty - loc-all-qnty
    loc-rest-qnty-cli = part-cli-qnty - loc-all-qnty-cli
  .
  if loc-all-qnty-cli > part-cli-qnty
  then do:
    message
      "Общее введенное количество изделий больше количества изделий в партии" skip
      view-as alert-box error.
    return error.
  end.
  if loc-all-qnty > part-qnty then do:
    message
      "Общий введенный вес больше веса в партии" skip
      view-as alert-box error.
    return error.
  end.

  if  loc-rest-qnty-cli = 1
  and (loc-rest-qnty < goods.min-rate
       or loc-rest-qnty > goods.max-rate
       )
  then do:
    if loc-rest-qnty > goods.max-rate
    then do:
      message
        substitute("Вес одного оставшегося изделия &1 больше, чем максимальный вес, заданный в карточке товара &2"
                  ,loc-rest-qnty
                  ,goods.max-rate
                  ) skip
        "Продолжить?" skip
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok <> true
      then do:
        return error.
      end.
    end.
    if loc-rest-qnty < goods.min-rate
    then do:
      message
        substitute("Вес одного оставшегося изделия &1 меньше, чем минимальный вес, заданный в карточке товара &2"
                  ,loc-rest-qnty
                  ,goods.min-rate
                  ) skip
        "Продолжить?" skip
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok <> true
      then do:
        return error.
      end.
    end.
  end.
  if  loc-rest-qnty-cli = 0
  and loc-rest-qnty <> 0
  then do:
    message
      "Общее введенное количество изделий равно количеству изделий в партии" skip
      "но общий введенный вес не равен общему весу изделий в партии" skip
      view-as alert-box ERROR.
    return error.
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
  DISPLAY for-qnty for-goods for-in-code for-parts for-min-rate for-max-rate
          part-qnty part-cli-qnty all-qnty all-qnty-cli rest-qnty rest-qnty-cli
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-good B-doc B-split B-Help RECT-4 RECT-1 RECT-3 RECT-2
         for-qnty BR-qnty for-goods for-in-code for-parts for-min-rate
         for-max-rate part-qnty part-cli-qnty all-qnty all-qnty-cli rest-qnty
         rest-qnty-cli
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-br Dialog-Frame
PROCEDURE update-br :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable ii as integer no-undo.
      assign
      ii = 1
      all-qnty = 0
      all-qnty-cli = 0
      .
      for each b-qnty-table use-index pi:
        ASSIGN
        all-qnty = all-qnty + b-qnty-table.qnty
        all-qnty-cli = all-qnty-cli + 1
        .
        if b-qnty-table.nn <> ii then
        assign
        b-qnty-table.nn = ii.
        ii = ii + 1.
      end.
      assign
      rest-qnty = part-qnty - all-qnty
      rest-qnty-cli = part-cli-qnty - all-qnty-cli
      .

      display
      all-qnty
      rest-qnty
      all-qnty-cli
      rest-qnty-cli
      with frame {&frame-name}.
        OPEN QUERY br-qnty FOR EACH qnty-table SHARE-LOCK.
        DISPLAY br-qnty
        with frame {&frame-name}.
        APPLY "ENTRY" to for-qnty.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
