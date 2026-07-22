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



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Добавление, изменение, просмотр детализации строки документа МЦ (не инвентаризация)

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

DEFINE TEMP-TABLE tt-par-dtl NO-UNDO LIKE ub.wth-par
       { str/ttpardt0.i }.
DEFINE INPUT PARAMETER par-mode as character no-undo .
define input parameter parline-rec as recid no-undo.
define input parameter pardoc-code like ub.wth-line.doc-code no-undo .
define input parameter parwth-code like ub.wth-line.wth-code no-undo .
define input parameter parw-p-code like ub.wth-line.w-p-code no-undo .
define input parameter pardoc-sum like ub.wth-line.doc-sum no-undo .
define input parameter parfact-sum like ub.wth-line.fact-sum no-undo .
define input parameter parbef-sum like ub.wth-line.bef-sum no-undo .
define input parameter paraft-sum like ub.wth-line.aft-sum no-undo .
DEFINE INPUT PARAMETER pardoc-type like ub.wth-doc.doc-type no-undo .
define input parameter parext-type like ub.wth-doc.ext-doc-type no-undo.
define input-output parameter table for tt-par-dtl.
/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Добавление, изменение, просмотр детализации строки документа МЦ (не инвентаризация)":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }

DEFine VARiable d_doc-sum LIKE ub.wth-doc.doc-sum NO-UNDO.
DEFine VARiable d_fact-sum LIKE ub.wth-doc.doc-sum NO-UNDO.
DEFINE VARIABLE vardoc-status_ like ub.wth-doc.status_ no-undo .
define buffer buf_wth-par for ub.wth-par.
define buffer buf_wth-doc for ub.wth-doc.
define buffer buf_wth-parts for ub.wth-parts.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-dtl

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-par-dtl buf_wth-line

/* Definitions for BROWSE BR-dtl                                        */
&Scoped-define FIELDS-IN-QUERY-BR-dtl tt-par-dtl.par-feat tt-par-dtl.par-val tt-par-dtl.par-unit tt-par-dtl.q-ty-doc tt-par-dtl.doc-sum tt-par-dtl.q-ty-fact tt-par-dtl.fact-sum tt-par-dtl.sum-gds-rubl tt-par-dtl.sum-gds-base tt-par-dtl.price-rubl tt-par-dtl.price-base tt-par-dtl.gds-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-dtl tt-par-dtl.q-ty-doc ~
tt-par-dtl.q-ty-fact
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-dtl tt-par-dtl
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-dtl tt-par-dtl
&Scoped-define SELF-NAME BR-dtl
&Scoped-define QUERY-STRING-BR-dtl FOR EACH tt-par-dtl NO-LOCK
&Scoped-define OPEN-QUERY-BR-dtl OPEN QUERY {&SELF-NAME} FOR EACH tt-par-dtl NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-dtl tt-par-dtl
&Scoped-define FIRST-TABLE-IN-QUERY-BR-dtl tt-par-dtl


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH buf_wth-line SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH buf_wth-line SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame buf_wth-line
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame buf_wth-line


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS wth-line.doc-sum wth-line.fact-sum
&Scoped-define ENABLED-TABLES wth-line
&Scoped-define FIRST-ENABLED-TABLE wth-line
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-par B-Help BR-dtl ~
for-d_doc-sum for-d_fact-sum
&Scoped-Define DISPLAYED-FIELDS wth-line.doc-sum wth-line.fact-sum
&Scoped-define DISPLAYED-TABLES wth-line
&Scoped-define FIRST-DISPLAYED-TABLE wth-line
&Scoped-Define DISPLAYED-OBJECTS for-d_doc-sum for-d_fact-sum

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-par
     LABEL "&Инфо"
     SIZE 10 BY 1.

DEFINE BUTTON B-parts
     LABEL "&Партии"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "Отменить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE for-d_doc-sum AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "ИТОГО по документу"
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE for-d_fact-sum AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "ИТОГО факт"
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-dtl FOR
      tt-par-dtl SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      buf_wth-line SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-dtl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-dtl Dialog-Frame _FREEFORM
  QUERY BR-dtl DISPLAY
      tt-par-dtl.par-feat
      tt-par-dtl.par-val
      tt-par-dtl.par-unit
      tt-par-dtl.q-ty-doc
      tt-par-dtl.doc-sum
      tt-par-dtl.q-ty-fact
      tt-par-dtl.fact-sum
      tt-par-dtl.sum-gds-rubl
      tt-par-dtl.sum-gds-base
      tt-par-dtl.price-rubl
      tt-par-dtl.price-base
      tt-par-dtl.gds-code

ENABLE
      tt-par-dtl.q-ty-doc
      tt-par-dtl.q-ty-fact
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 101.75 BY 13.67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13
     b-quit AT ROW 1 COL 11.13
     B-par AT ROW 1 COL 21
     B-parts AT ROW 1 COL 31 WIDGET-ID 4
     B-Help AT ROW 1 COL 54.88
     BR-dtl AT ROW 4.5 COL 1.38
     ub.wth-line.doc-sum AT ROW 3.25 COL 24 COLON-ALIGNED
          LABEL "Кол-во по документу"
           VIEW-AS TEXT
          SIZE 21.5 BY .67
          FGCOLOR 4
     ub.wth-line.fact-sum AT ROW 3.25 COL 60 COLON-ALIGNED
          LABEL "Кол-во факт"
           VIEW-AS TEXT
          SIZE 21.5 BY .67
          FGCOLOR 4
     for-d_doc-sum AT ROW 18.63 COL 24.25 COLON-ALIGNED
     for-d_fact-sum AT ROW 18.67 COL 60.25 COLON-ALIGNED
     SPACE(19.49) SKIP(0.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_wealth B "?" ? ub wealth
      TABLE: buf_wth-line B "?" ? ub wth-line
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-dtl B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-parts IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN wth-line.doc-sum IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN wth-line.fact-sum IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-dtl
/* Query rebuild information for BROWSE BR-dtl
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-par-dtl NO-LOCK.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-dtl */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.buf_wth-line"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  define variable d_line-sum LIKE d_doc-sum NO-UNDO.

  IF par-mode = {&lookup} THEN DO:
    RETURN NO-APPLY.
  END.

  { gbl/stdbtn.i }

  DO TRANSACTION on error undo, return NO-apply
                                on stop undo, return no-apply:
  case vardoc-status_:
    when {&wayb} then do:
      FOR EACH tt-par-dtl:
        IF tt-par-dtl.doc-sum  = 0 AND tt-par-dtl.q-ty-doc  = 0 THEN DO:
          NEXT.
        END.
        IF tt-par-dtl.doc-sum  = 0 AND tt-par-dtl.q-ty-doc <> 0 OR
          tt-par-dtl.doc-sum <> 0 AND tt-par-dtl.q-ty-doc  = 0
        THEN DO:
          IF tt-par-dtl.doc-sum  = 0 AND tt-par-dtl.q-ty-doc <> 0 THEN DO:
            ASSIGN
            tt-par-dtl.doc-sum = tt-par-dtl.q-ty-doc * tt-par-dtl.par-rate.
          END.
          IF tt-par-dtl.doc-sum <> 0 AND tt-par-dtl.q-ty-doc  = 0 THEN DO:
            ASSIGN tt-par-dtl.q-ty-doc    = tt-par-dtl.doc-sum / tt-par-dtl.par-rate .
          END.
        END.
      END.
    end.
    when {&permitted} then do:
      FOR EACH tt-par-dtl:
        IF tt-par-dtl.fact-sum  = 0 AND tt-par-dtl.q-ty-fact  = 0 THEN DO:
          NEXT.
        END.
        IF tt-par-dtl.fact-sum  = 0 AND tt-par-dtl.q-ty-fact <> 0 OR
           tt-par-dtl.fact-sum <> 0 AND tt-par-dtl.q-ty-fact  = 0
        THEN DO:
          IF tt-par-dtl.fact-sum  = 0 AND tt-par-dtl.q-ty-fact <> 0 THEN DO:
            ASSIGN
            tt-par-dtl.fact-sum = tt-par-dtl.q-ty-fact * tt-par-dtl.par-rate.
          END.
          IF tt-par-dtl.fact-sum <> 0 AND tt-par-dtl.q-ty-fact  = 0 THEN DO:
            ASSIGN tt-par-dtl.q-ty-fact = tt-par-dtl.fact-sum / tt-par-dtl.par-rate .
          END.
        END.
      END.
    end.
    END CASE.
  END. /*transaction*/

  APPLY "GO":U TO FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-par
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-par Dialog-Frame
ON CHOOSE OF B-par IN FRAME Dialog-Frame /* Инфо */
DO:
 { gbl/stdbtn.i }
 define variable glog as logical no-undo .
 define variable v-rep-rec as recid no-undo .

  DEF BUFFER buf-par FOR ub.wth-par.
    if not avail tt-par-dtl then return no-apply.
  case par-mode :
    when {&add-def}  then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_wth-doc_add-def':U
        {&cntxt-object}
        buf_wth-doc.host-code
        buf_wth-doc.obj-type
        buf_wth-doc.obj-code
        0
        0
        0
        true
        glog
      }
    end.
    when {&update}  then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_wth-doc_update':U
        {&cntxt-object}
        buf_wth-doc.host-code
        buf_wth-doc.obj-type
        buf_wth-doc.obj-code
        0
        0
        0
        true
        glog
      }
    end.
    when {&lookup}  then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_wth-doc_lookup':U
        {&cntxt-object}
        buf_wth-doc.host-code
        buf_wth-doc.obj-type
        buf_wth-doc.obj-code
        0
        0
        0
        true
        glog
      }
    end.
  end case.
  IF NOT glog THEN DO:
    RETURN NO-APPLY.
  END.
  FIND FIRST buf_wth-par NO-LOCK WHERE
             buf_wth-par.wth-code = buf_wealth.wth-code  AND
             buf_wth-par.par-code = tt-par-dtl.par-code NO-ERROR.
  IF NOT AVAIL buf_wth-par THEN DO:
    MESSAGE "Номинал не найден! " VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.
  run ref/wthpform.w (
                    input Parparentproc
                    ,input buf_wth-doc.host-code
                    ,input buf_wth-doc.obj-type
                    ,input buf_wth-doc.obj-code
                    ,INPUT buf_wth-par.wth-code
                    ,INPUT buf_wth-par.par-code
                    ,INPUT {&lookup}
                   ,OUTPUT v-rep-rec
                 ).


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-parts Dialog-Frame
ON CHOOSE OF B-parts IN FRAME Dialog-Frame /* Партии */
DO:
if not available tt-par-dtl then return.
run str/wthparts.w (
                 input parparentproc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input 'document':U
                ,input (if par-mode = {&lookup} then {&lookup} else {&update})
                ,input parwth-code
                ,input tt-par-dtl.par-code
                ,INPUT 0
                ,input 0
                ,INPUT buf_wth-doc.doc-code
                ,INPUT parw-p-code
                ,INPUT buf_wth-doc.cli-type
                ,INPUT buf_wth-doc.cli-code
                ,INPUT buf_wth-doc.doc-type ) no-error.
if error-status:error then do:
  message return-value error-status:get-message(1) view-as alert-box error title 'Ошибка при запуске wthparts.w'.
  return no-apply.
end.
if par-mode <> {&lookup} then do:
{ str/dtlsum.i tt-par-dtl buf_wth-parts }
    DISPLAY
    tt-par-dtl.q-ty-doc
    tt-par-dtl.doc-sum
    tt-par-dtl.q-ty-fact
    tt-par-dtl.fact-sum
    tt-par-dtl.sum-gds-rubl
    tt-par-dtl.sum-gds-base
    tt-par-dtl.price-rubl
    tt-par-dtl.price-base
    WITH BROWSE {&BROWSE-NAME}.
 end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-dtl
&Scoped-define SELF-NAME BR-dtl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-dtl Dialog-Frame
ON DEFAULT-ACTION OF BR-dtl IN FRAME Dialog-Frame
DO:
  if b-parts:sensitive then
  apply 'choose':U to b-parts .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-dtl Dialog-Frame
ON ROW-LEAVE OF BR-dtl IN FRAME Dialog-Frame
DO:
if vardoc-status_ = {&wayb} then do:
  if tt-par-dtl.q-ty-doc:read-only  in BROWSE {&BROWSE-NAME} = no then do:
    ASSIGN
    tt-par-dtl.q-ty-doc = INPUT BROWSE {&BROWSE-NAME} tt-par-dtl.q-ty-doc
    tt-par-dtl.q-ty-fact = tt-par-dtl.q-ty-doc.
    ASSIGN
    d_doc-sum = d_doc-sum - tt-par-dtl.doc-sum.
    ASSIGN
    tt-par-dtl.doc-sum = tt-par-dtl.q-ty-doc  * tt-par-dtl.par-rate
    tt-par-dtl.fact-sum = tt-par-dtl.doc-sum.
    ASSIGN
    d_doc-sum = d_doc-sum + tt-par-dtl.doc-sum.
    DISPLAY
    tt-par-dtl.q-ty-doc
    tt-par-dtl.doc-sum
    tt-par-dtl.q-ty-fact
    tt-par-dtl.fact-sum
    WITH BROWSE {&BROWSE-NAME}.
    DISPLAY
    d_doc-sum @ for-d_doc-sum
    WITH FRAME {&FRAME-NAME}.
  end.
  if tt-par-dtl.q-ty-fact:read-only  in BROWSE {&BROWSE-NAME} = no then do:
    ASSIGN
    tt-par-dtl.q-ty-fact = INPUT BROWSE {&BROWSE-NAME} tt-par-dtl.q-ty-fact.
    ASSIGN
    d_fact-sum = d_fact-sum - tt-par-dtl.fact-sum.
    ASSIGN
    tt-par-dtl.fact-sum = tt-par-dtl.q-ty-fact  * tt-par-dtl.par-rate.
    ASSIGN
    d_fact-sum = d_fact-sum + tt-par-dtl.fact-sum.
    DISPLAY
    tt-par-dtl.q-ty-fact
    tt-par-dtl.fact-sum
    WITH BROWSE {&BROWSE-NAME}.
    DISPLAY
    d_fact-sum @ for-d_fact-sum
    WITH FRAME {&FRAME-NAME}.
  end.
end.
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
  { gbl/getcntxt.i get }
  if par-mode <> {&update} and par-mode <> {&add-def} and par-mode <> {&lookup} then do:
      message vss-workfile vss-revision vss-description skip
                  "Неверный параметр вызова par-mode"
      view-as alert-box ERROR.
      return error.
  end.
  if par-mode = {&lookup} then do:
        FIND FIRST buf_wth-line No-LOCK WHERE
                   recid(buf_wth-line) = parline-rec No-ERROR.
  end.
  if par-mode = {&update} then do:
        FIND FIRST buf_wth-line EXCLUSIVE-LOCK WHERE
                   recid(buf_wth-line) = parline-rec NO-WAIT No-ERROR.
      IF LOCKED buf_wth-line then do:
        message
        vss-workfile vss-revision vss-description skip
        "Занята запись строки документа движения МЦ"
        view-as alert-box.
        return error.
      end.
      IF NOT avail buf_wth-line then do:
        message
        vss-workfile vss-revision vss-description skip
        "Не найдена строка документа движения МЦ"
        view-as alert-box.
        return error.
      end.
  assign
  pardoc-code = buf_wth-line.doc-code
  parwth-code = buf_wth-line.wth-code
  parbef-sum = buf_wth-line.bef-sum
  paraft-sum = buf_wth-line.aft-sum
  pardoc-sum = buf_wth-line.doc-sum
  parfact-sum = buf_wth-line.fact-sum
  .


  end.
  FIND FIRST buf_wth-doc No-LOCK WHERE
             buf_wth-doc.doc-code = pardoc-code No-ERROR.
  IF NOT AVAIL buf_wth-doc THEN DO:
    MESSAGE  "Не найден документ движения МЦ"
    VIEW-AS ALERT-BOX ERROR.
    RETURN error.
  END.
  if par-mode = {&update} and buf_wth-doc.status_ = {&fact} then do:
       message "Документ движения МЦ с N" buf_wth-doc.doc-code  "имеет статус" buf_wth-doc.status_ SKIP
                      "Изменения не допускаются"
        view-as alert-box error.
        return error.
  end.
  if LOOKUP(buf_wth-doc.ext-doc-type, {&WDEDT_list}) = 0 then do:
    MESSAGE
    vss-workfile vss-revision vss-description skip
    "Неверный вызов - документ МЦ имеет тип" buf_wth-doc.doc-type
    VIEW-AS ALERT-BOX ERROR.
    RETURN error.
  end.
  vardoc-status_ = buf_wth-doc.status_.
  FIND FIRST buf_wealth No-LOCK WHERE
              buf_wealth.wth-code = parwth-code NO-ERROR.
  IF NOT AVAIL buf_wealth THEN DO:
      MESSAGE
        "Не найдена материальная ценность в справочнике!"
      VIEW-AS ALERT-BOX ERROR.
      RETURN error.
  END.
  run fill-tables in this-Procedure no-error.
  if error-status:error then return error.

  RUN Myenable.
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
  DISPLAY for-d_doc-sum for-d_fact-sum
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.wth-line THEN
    DISPLAY ub.wth-line.doc-sum ub.wth-line.fact-sum
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-par B-Help BR-dtl ub.wth-line.doc-sum ub.wth-line.fact-sum
         for-d_doc-sum for-d_fact-sum
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
/*две ветки*/
/* в форму вошли в первый раз для данной строки*/
if not can-find(first tt-par-dtl) then do:
    FOR EACH ub.wth-par NO-LOCK WHERE
             ub.wth-par.wth-code = buf_wealth.wth-code :
      FIND FIRST tt-par-dtl WHERE
                 tt-par-dtl.par-code = ub.wth-par.par-code NO-ERROR.
      IF NOT AVAIL tt-par-dtl THEN DO:
        CREATE tt-par-dtl.
        ASSIGN
          tt-par-dtl.wth-code = ub.wth-par.wth-code
          tt-par-dtl.w-p-code = parw-p-code
          tt-par-dtl.doc-code = pardoc-code
          tt-par-dtl.par-code = ub.wth-par.par-code
          tt-par-dtl.par-val  = ub.wth-par.par-val
          tt-par-dtl.par-unit = ub.wth-par.par-unit
          tt-par-dtl.par-feat = ub.wth-par.par-feat
          tt-par-dtl.par-rate = ub.wth-par.par-rate
          tt-par-dtl.q-ty-doc = 0
          tt-par-dtl.doc-sum  = 0
          tt-par-dtl.q-ty-fact = 0
          tt-par-dtl.fact-sum  = 0
       .
      END.
    END.

    FOR EACH ub.wth-dtl NO-LOCK WHERE
            ub.wth-dtl.doc-code = pardoc-code AND
            ub.wth-dtl.wth-code = parwth-code AND
            ub.wth-dtl.w-p-code = parw-p-code
    BY
    ub.wth-dtl.par-code :
      FIND FIRST tt-par-dtl WHERE
                 tt-par-dtl.par-code = ub.wth-dtl.par-code NO-ERROR.
      IF NOT AVAIL tt-par-dtl THEN DO:
        NEXT.
      END.

      IF buf_wth-doc.doc-type = {&inventory} THEN DO:
        ASSIGN
        tt-par-dtl.doc-sum = ub.wth-dtl.bef-sum
        tt-par-dtl.fact-sum = ub.wth-dtl.aft-sum
        .
      END.
      ELSE DO:

      buffer-copy ub.wth-dtl using doc-sum fact-sum sum-gds-rubl sum-gds-base price-rubl price-base gds-code to tt-par-dtl.
  /*      ASSIGN
        tt-par-dtl.doc-sum = ub.wth-dtl.doc-sum
        tt-par-dtl.fact-sum = ub.wth-dtl.fact-sum.  */
      END.
      ASSIGN
      tt-par-dtl.q-ty-doc = tt-par-dtl.doc-sum / tt-par-dtl.par-rate       /* / (tt-par-dtl.par-val */
      tt-par-dtl.q-ty-fact = tt-par-dtl.fact-sum / tt-par-dtl.par-rate     /*  / (tt-par-dtl.par-val   */
      d_doc-sum    = d_doc-sum   + tt-par-dtl.doc-sum
      d_fact-sum   = d_fact-sum   + tt-par-dtl.fact-sum
      .
    END.
end.
else do:        /*только рассчит. сумма по документу*/
  for each tt-par-dtl no-lock:
      ASSIGN
      d_doc-sum   = d_doc-sum      + tt-par-dtl.doc-sum
      d_fact-sum   = d_fact-sum      + tt-par-dtl.fact-sum
      .
  end.
/*    FOR EACH ub.wth-dtl NO-LOCK WHERE
              ub.wth-dtl.doc-code = pardoc-code AND
              ub.wth-dtl.wth-code = parwth-code AND
              ub.wth-dtl.w-p-code = parw-p-code
      BY
      ub.wth-dtl.par-code :
        FIND FIRST tt-par-dtl WHERE
                  tt-par-dtl.par-code = ub.wth-dtl.par-code NO-ERROR.
        IF NOT AVAIL tt-par-dtl THEN DO:
          NEXT.
        END.
        ASSIGN
        d_doc-sum   = d_doc-sum      + tt-par-dtl.doc-sum
        d_fact-sum   = d_fact-sum      + tt-par-dtl.fact-sum
        .

  END. */

end.
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
tt-par-dtl.q-ty-doc:label-BGCOLOR IN BROWSE {&BROWSE-NAME} = 15.
tt-par-dtl.q-ty-fact:label-BGCOLOR IN BROWSE {&BROWSE-NAME} = 15.

IF par-mode = {&lookup} THEN DO:
  ASSIGN
  tt-par-dtl.q-ty-doc:READ-ONLY IN BROWSE {&BROWSE-NAME} = YES
  tt-par-dtl.q-ty-fact:READ-ONLY IN BROWSE {&BROWSE-NAME} = YES
  tt-par-dtl.q-ty-doc:label-BGCOLOR IN BROWSE {&BROWSE-NAME} = ?
  tt-par-dtl.q-ty-fact:label-BGCOLOR IN BROWSE {&BROWSE-NAME} = ?
    .
  b-quit:label in frame {&FRAME-NAME}  = 'Выход'.
END.
  ASSIGN FRAME {&FRAME-NAME}:TITLE = 'Детализация по номиналам. МЦ ' + CAPS( buf_wealth.wth-name ).
  DISPLAY
  d_doc-sum @ for-d_doc-sum
  d_fact-sum @ for-d_fact-sum
  WITH FRAME {&FRAME-NAME}.
  DISPLAY
  pardoc-sum @ ub.wth-line.doc-sum
  parfact-sum @ ub.wth-line.fact-sum
  WITH FRAME {&FRAME-NAME}.
  ENABLE
  b-quit
  b-help
  B-Par
  {&BROWSE-NAME}
  WITH FRAME {&FRAME-NAME}.
  IF par-mode <> {&lookup} THEN DO:
    ENABLE
    b-exit
    WITH FRAME {&FRAME-NAME}.
  END.
/*  CASE  buf_wth-doc.status_:
        when {&wayb} then dO:
            tt-par-dtl.q-ty-fact:READ-ONLY IN BROWSE {&BROWSE-NAME} = YES.
            tt-par-dtl.q-ty-fact:label-BGCOLOR IN BROWSE {&BROWSE-NAME} = ?.
            HIDE
            wth-line.fact-sum
            for-d_fact-sum
            in frame {&frame-name} .
        end.
        when {&permitted} then do:
             tt-par-dtl.q-ty-doc:READ-ONLY IN BROWSE {&BROWSE-NAME} = YES.
             tt-par-dtl.q-ty-doc:label-BGCOLOR IN BROWSE {&BROWSE-NAME} = ?.
        end.
    end CASE.     */
 if buf_wth-doc.doc-type = {&declaration} then do:
    HIDE
    wth-line.fact-sum
    for-d_fact-sum
    in frame {&frame-name} .
    assign
    tt-par-dtl.q-ty-fact:visible in browse br-dtl = no
    tt-par-dtl.fact-sum:visible in browse br-dtl = no
    .
  end.
  if buf_wealth.is-ser = 1 then do:
      tt-par-dtl.q-ty-doc:READ-ONLY IN BROWSE {&BROWSE-NAME} = YES.
      tt-par-dtl.q-ty-fact:READ-ONLY IN BROWSE {&BROWSE-NAME} = YES.
      tt-par-dtl.q-ty-doc:label-BGCOLOR IN BROWSE {&BROWSE-NAME} = ?.
      tt-par-dtl.q-ty-fact:label-BGCOLOR IN BROWSE {&BROWSE-NAME} = ?.
      enable b-parts with frame {&frame-name}.
  end.
  else do:
      if buf_wth-doc.doc-type = {&income} and buf_wth-doc.exter_ = no and par-mode <> {&lookup} then do:
             tt-par-dtl.q-ty-doc:READ-ONLY IN BROWSE {&BROWSE-NAME} = YES.
             tt-par-dtl.q-ty-doc:label-BGCOLOR IN BROWSE {&BROWSE-NAME} = ?.
      end.
      else  if buf_wth-doc.status_ =  {&wayb} then dO:
            tt-par-dtl.q-ty-fact:READ-ONLY IN BROWSE {&BROWSE-NAME} = YES.
            tt-par-dtl.q-ty-fact:label-BGCOLOR IN BROWSE {&BROWSE-NAME} = ?.
            HIDE
            wth-line.fact-sum
            for-d_fact-sum
            in frame {&frame-name} .
        end.
  end.

  VIEW FRAME {&frame-name} .
  OPEN QUERY {&BROWSE-NAME} FOR EACH tt-par-dtl USE-INDEX tt-i1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME