&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_c-wth-line FOR ub.c-wth-line.
DEFINE BUFFER buf_wealth FOR ub.wealth.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Добавление, изменение, просмотр детализации истории строки документа МЦ (инвентаризация)

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
DEFINE TEMP-TABLE tt-par-dtl NO-UNDO LIKE ub.wth-par
       { str/ttpardt0.i inv }.

DEFINE INPUT PARAMETER par-mode as character no-undo .
define input parameter parline-rec as recid no-undo.
define input parameter pardoc-code like ub.c-wth-line.doc-code no-undo .
define input parameter parwth-code like ub.c-wth-line.wth-code no-undo .
define input parameter parw-p-code like ub.c-wth-line.w-p-code no-undo .
define input parameter parcorr-user-db-num like ub.c-wth-line.corr-user-db-num no-undo .
define input parameter parchip-num like ub.c-wth-line.chip-num no-undo .
define input parameter pardoc-sum like ub.c-wth-line.doc-sum no-undo .
define input parameter parfact-sum like ub.c-wth-line.fact-sum no-undo .
define input parameter parbef-sum like ub.c-wth-line.bef-sum no-undo .
define input parameter paraft-sum like ub.c-wth-line.aft-sum no-undo .
DEFINE INPUT PARAMETER pardoc-type like ub.c-wth-doc.doc-type no-undo .
define input-output parameter table for tt-par-dtl.
/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Добавление, изменение, просмотр детализации истории строки документа МЦ (инвентаризация)":U.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/getcntxt.i def }

DEFine VARiable d_bef-sum LIKE ub.c-wth-doc.doc-sum NO-UNDO.
DEFine VARiable d_aft-sum LIKE ub.c-wth-doc.doc-sum NO-UNDO.
DEFine VARiable d_fact-sum LIKE ub.c-wth-doc.doc-sum NO-UNDO.
define buffer buf_wth-par for ub.wth-par.
define buffer buf_c-wth-doc for ub.c-wth-doc.
DEFINE VARIABLE vardoc-status_ like ub.c-wth-doc.status_ no-undo .

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
&Scoped-define INTERNAL-TABLES tt-par-dtl buf_c-wth-line

/* Definitions for BROWSE BR-dtl                                        */
&Scoped-define FIELDS-IN-QUERY-BR-dtl tt-par-dtl.par-feat tt-par-dtl.par-val tt-par-dtl.par-unit tt-par-dtl.q-ty-bef tt-par-dtl.sum-bef tt-par-dtl.q-ty-aft tt-par-dtl.sum-aft (if vardoc-status_ = {&permitted} then tt-par-dtl.q-ty-bef - tt-par-dtl.q-ty-aft else 0) tt-par-dtl.sum-fact
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-dtl tt-par-dtl.q-ty-bef tt-par-dtl.q-ty-aft
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-dtl tt-par-dtl
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-dtl tt-par-dtl
&Scoped-define SELF-NAME BR-dtl
&Scoped-define QUERY-STRING-BR-dtl FOR EACH tt-par-dtl NO-LOCK
&Scoped-define OPEN-QUERY-BR-dtl OPEN QUERY {&SELF-NAME} FOR EACH tt-par-dtl NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-dtl tt-par-dtl
&Scoped-define FIRST-TABLE-IN-QUERY-BR-dtl tt-par-dtl


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH buf_c-wth-line SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH buf_c-wth-line SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame buf_c-wth-line
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame buf_c-wth-line


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.wealth.wth-name ub.c-wth-line.bef-sum ~
ub.c-wth-line.aft-sum ub.c-wth-line.fact-sum
&Scoped-define ENABLED-TABLES ub.wealth ub.c-wth-line
&Scoped-define FIRST-ENABLED-TABLE ub.wealth
&Scoped-define SECOND-ENABLED-TABLE ub.c-wth-line
&Scoped-Define ENABLED-OBJECTS b-quit B-par B-Help BR-dtl for-d_aft-sum ~
for-d_bef-sum for-d_fact-sum
&Scoped-Define DISPLAYED-FIELDS ub.wealth.wth-name ub.c-wth-line.bef-sum ~
ub.c-wth-line.aft-sum ub.c-wth-line.fact-sum
&Scoped-define DISPLAYED-TABLES ub.wealth ub.c-wth-line
&Scoped-define FIRST-DISPLAYED-TABLE ub.wealth
&Scoped-define SECOND-DISPLAYED-TABLE ub.c-wth-line
&Scoped-Define DISPLAYED-OBJECTS for-d_aft-sum for-d_bef-sum for-d_fact-sum

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-par
     LABEL "&Инфо"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE for-d_aft-sum AS CHARACTER FORMAT "X(15)":U
     LABEL "ИТОГО факт"
      VIEW-AS TEXT
     SIZE 19.9 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE for-d_bef-sum AS CHARACTER FORMAT "X(15)":U
     LABEL "ИТОГО план"
      VIEW-AS TEXT
     SIZE 19.9 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE for-d_fact-sum AS CHARACTER FORMAT "X(15)":U
     LABEL "ИТОГО расхождение"
      VIEW-AS TEXT
     SIZE 19.9 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-dtl FOR
      tt-par-dtl SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      buf_c-wth-line SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-dtl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-dtl Dialog-Frame _FREEFORM
  QUERY BR-dtl DISPLAY
      tt-par-dtl.par-feat
      tt-par-dtl.par-val
      tt-par-dtl.par-unit
      tt-par-dtl.q-ty-bef
      tt-par-dtl.sum-bef
      tt-par-dtl.q-ty-aft
      tt-par-dtl.sum-aft
      (if vardoc-status_ = {&permitted} then tt-par-dtl.q-ty-bef - tt-par-dtl.q-ty-aft else 0)
      tt-par-dtl.sum-fact
ENABLE
      tt-par-dtl.q-ty-bef
tt-par-dtl.q-ty-aft
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 101.4 BY 11.83.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 11.1
     B-par AT ROW 1 COL 21
     B-Help AT ROW 1 COL 95
     BR-dtl AT ROW 6.33 COL 1.4
     ub.wealth.wth-name AT ROW 3.27 COL 24.3 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 20.9 BY .67
          FGCOLOR 4
     ub.c-wth-line.bef-sum AT ROW 4.37 COL 24.1 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 21 BY .67
          FGCOLOR 4
     ub.c-wth-line.aft-sum AT ROW 4.47 COL 67.8 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 21 BY .67
          FGCOLOR 4
     ub.c-wth-line.fact-sum AT ROW 5.37 COL 36.8 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 21 BY .67
          FGCOLOR 4
     for-d_aft-sum AT ROW 18.57 COL 69.6 COLON-ALIGNED
     for-d_bef-sum AT ROW 18.63 COL 24.1 COLON-ALIGNED
     for-d_fact-sum AT ROW 19.7 COL 36.8 COLON-ALIGNED
     SPACE(44.17) SKIP(0.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_c-wth-line B "?" ? ub c-wth-line
      TABLE: buf_wealth B "?" ? ub wealth
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
     _TblList          = "Temp-Tables.buf_c-wth-line"
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


&Scoped-define SELF-NAME B-par
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-par Dialog-Frame
ON CHOOSE OF B-par IN FRAME Dialog-Frame /* Инфо */
DO:
 { gbl/stdbtn.i }
 define variable glog as logical no-undo .
 define variable v-rep-rec as recid no-undo .

  DEF BUFFER buf-par FOR ub.wth-par.

  if not avail tt-par-dtl then return no-apply.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_wealth_work':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    glog
  }
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
                     input parparentproc
                    ,input buf_c-wth-doc.host-code
                    ,input buf_c-wth-doc.obj-type
                    ,input buf_c-wth-doc.obj-code
                    ,INPUT buf_wth-par.wth-code
                    ,INPUT buf_wth-par.par-code
                    ,INPUT {&lookup}
                   ,OUTPUT v-rep-rec
                 ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-dtl
&Scoped-define SELF-NAME BR-dtl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-dtl Dialog-Frame
ON ROW-LEAVE OF BR-dtl IN FRAME Dialog-Frame
DO:
  CASE vardoc-status_:
    when {&wayb} then do:
      ASSIGN
      tt-par-dtl.q-ty-bef = INPUT BROWSE {&BROWSE-NAME} tt-par-dtl.q-ty-bef.
      ASSIGN
      d_bef-sum = d_bef-sum - tt-par-dtl.sum-bef.
      ASSIGN
      tt-par-dtl.sum-bef = tt-par-dtl.q-ty-bef * tt-par-dtl.par-val * tt-par-dtl.par-rate.
      ASSIGN
      d_bef-sum = d_bef-sum + tt-par-dtl.sum-bef.
      DISPLAY
      tt-par-dtl.q-ty-bef
      tt-par-dtl.sum-bef
      WITH BROWSE {&BROWSE-NAME}.
      DISPLAY
      d_bef-sum @ for-d_bef-sum
      WITH FRAME {&FRAME-NAME}.
    end.
    when {&permitted} then do:
      ASSIGN
      tt-par-dtl.q-ty-aft = INPUT BROWSE {&BROWSE-NAME} tt-par-dtl.q-ty-aft.
      ASSIGN
      d_aft-sum = d_aft-sum - tt-par-dtl.sum-aft.
      ASSIGN
      tt-par-dtl.sum-aft = tt-par-dtl.q-ty-aft * tt-par-dtl.par-val * tt-par-dtl.par-rate.
      ASSIGN
      d_aft-sum = d_aft-sum + tt-par-dtl.sum-aft.
      DISPLAY
      tt-par-dtl.q-ty-aft
      tt-par-dtl.sum-aft
      WITH BROWSE {&BROWSE-NAME}.
      DISPLAY
      d_aft-sum @ for-d_aft-sum
      WITH FRAME {&FRAME-NAME}.
    end.
  END CASE.
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

  if par-mode <> {&lookup} then do:
      message vss-workfile vss-revision vss-description skip
                  "Неверный параметр вызова par-mode"
      view-as alert-box ERROR.
      return error.
  end.
  if par-mode = {&lookup} then do:
        FIND FIRST buf_c-wth-line No-LOCK WHERE
                   recid(buf_c-wth-line) = parline-rec No-ERROR.
  end.
  FIND FIRST buf_c-wth-doc No-LOCK WHERE
             buf_c-wth-doc.doc-code = pardoc-code No-ERROR.
  IF NOT AVAIL buf_c-wth-doc THEN DO:
    MESSAGE  "Не найден документ движения МЦ"
    VIEW-AS ALERT-BOX ERROR.
    RETURN error.
  END.
  if buf_c-wth-doc.doc-type <> {&inventory} then do:
    MESSAGE
    vss-workfile vss-revision vss-description skip
    "Неверный вызов - документ МЦ имеет тип" buf_c-wth-doc.doc-type
    VIEW-AS ALERT-BOX ERROR.
    RETURN error.
  end.
  vardoc-status_ = buf_c-wth-doc.status_.
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
  DISPLAY for-d_aft-sum for-d_bef-sum for-d_fact-sum
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.c-wth-line THEN
    DISPLAY ub.c-wth-line.bef-sum ub.c-wth-line.aft-sum ub.c-wth-line.fact-sum
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.wealth THEN
    DISPLAY ub.wealth.wth-name
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-par B-Help BR-dtl ub.wealth.wth-name ub.c-wth-line.bef-sum
         ub.c-wth-line.aft-sum ub.c-wth-line.fact-sum for-d_aft-sum
         for-d_bef-sum for-d_fact-sum
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
          tt-par-dtl.par-code = ub.wth-par.par-code
          tt-par-dtl.par-val  = ub.wth-par.par-val
          tt-par-dtl.par-unit = ub.wth-par.par-unit
          tt-par-dtl.par-feat = ub.wth-par.par-feat
          tt-par-dtl.par-rate = ub.wth-par.par-rate / ub.wth-par.par-val
          tt-par-dtl.q-ty-bef     = 0
          tt-par-dtl.sum-bef  = 0
          tt-par-dtl.q-ty-aft     = 0
          tt-par-dtl.sum-aft  = 0
          tt-par-dtl.sum-fact  = 0
          .
      END.
    END.

    FOR EACH ub.c-wth-dtl NO-LOCK WHERE
            ub.c-wth-dtl.doc-code = pardoc-code
        AND ub.c-wth-dtl.wth-code = parwth-code
        AND ub.c-wth-dtl.w-p-code = parw-p-code
        AND ub.c-wth-dtl.corr-user-db-num = parcorr-user-db-num
        AND ub.c-wth-dtl.chip-num = parchip-num
    BY
    ub.c-wth-dtl.par-code :
      FIND FIRST tt-par-dtl WHERE
                 tt-par-dtl.par-code = ub.c-wth-dtl.par-code NO-ERROR.
      IF NOT AVAIL tt-par-dtl THEN DO:
        NEXT.
      END.

    ASSIGN
    tt-par-dtl.sum-bef = ub.c-wth-dtl.bef-sum
    tt-par-dtl.sum-aft = ub.c-wth-dtl.aft-sum
    tt-par-dtl.sum-fact = if (vardoc-status_ = {&permitted})
                                                    then (ub.c-wth-dtl.aft-sum - ub.c-wth-dtl.bef-sum)
                                                    else tt-par-dtl.sum-fact
    .
      ASSIGN
      tt-par-dtl.q-ty-bef = tt-par-dtl.sum-bef / (tt-par-dtl.par-val * tt-par-dtl.par-rate)
      tt-par-dtl.q-ty-aft = tt-par-dtl.sum-aft / (tt-par-dtl.par-val * tt-par-dtl.par-rate)
      d_bef-sum   = d_bef-sum      + tt-par-dtl.sum-bef
      d_aft-sum   = d_aft-sum      + tt-par-dtl.sum-aft
      d_fact-sum = d_aft-sum - d_bef-sum
      .
    END.
end.
else do:
 FOR EACH ub.c-wth-dtl NO-LOCK WHERE
            ub.c-wth-dtl.doc-code = pardoc-code
        AND ub.c-wth-dtl.wth-code = parwth-code
        AND ub.c-wth-dtl.w-p-code = parw-p-code
        AND ub.c-wth-dtl.corr-user-db-num = parcorr-user-db-num
        AND ub.c-wth-dtl.chip-num = parchip-num
    BY
    ub.c-wth-dtl.par-code :
      FIND FIRST tt-par-dtl WHERE
                 tt-par-dtl.par-code = ub.c-wth-dtl.par-code NO-ERROR.
      IF NOT AVAIL tt-par-dtl THEN DO:
        NEXT.
      END.

    ASSIGN
      d_bef-sum   = d_bef-sum      + tt-par-dtl.sum-bef
      d_aft-sum   = d_aft-sum      + tt-par-dtl.sum-aft
      d_fact-sum = d_aft-sum - d_bef-sum
      .
    end.
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

IF par-mode = {&lookup} THEN DO:
  ASSIGN
  tt-par-dtl.q-ty-bef:READ-ONLY IN BROWSE {&BROWSE-NAME} = YES
  tt-par-dtl.q-ty-aft:READ-ONLY IN BROWSE {&BROWSE-NAME} = YES
  .
END.
  ASSIGN FRAME {&FRAME-NAME}:TITLE = CAPS( buf_wealth.wth-name ) + " (номиналы)".
  DISPLAY
  buf_wealth.wth-name @ ub.wealth.wth-name
  d_bef-sum @ for-d_bef-sum
  d_aft-sum  @ for-d_aft-sum
  d_fact-sum @  for-d_fact-sum

  WITH FRAME {&FRAME-NAME}.
  DISPLAY
  parbef-sum @ ub.c-wth-line.bef-sum
  paraft-sum @ ub.c-wth-line.aft-sum
  string(paraft-sum - parbef-sum) @ ub.c-wth-line.fact-sum

  WITH FRAME {&FRAME-NAME}.



  ENABLE
  b-quit
  b-help
  B-Par
  {&BROWSE-NAME}
  WITH FRAME {&FRAME-NAME}.
  CASE  buf_c-wth-doc.status_:
    when {&wayb} then dO:
      tt-par-dtl.q-ty-aft:READ-ONLY IN BROWSE {&BROWSE-NAME} = YES.
      HIDE
      c-wth-line.aft-sum
      c-wth-line.fact-sum
      for-d_aft-sum
      for-d_fact-sum
      in frame {&frame-name} .
    end.
    when {&permitted} then do:
      tt-par-dtl.q-ty-bef:READ-ONLY IN BROWSE {&BROWSE-NAME} = YES.
    end.
  end CASE.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY {&BROWSE-NAME} FOR EACH tt-par-dtl USE-INDEX tt-i1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
