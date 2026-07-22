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
DEFINE BUFFER buf_wth-place FOR ub.wth-place.
DEFINE TEMP-TABLE tt-c-wth-line NO-UNDO LIKE ub.c-wth-line.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Добавление, изменение, просмотр истории строки документа МЦ (инвентаризация)

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
define input parameter par-mode as character no-undo .
define input parameter pardoc-rec as recid no-undo.
define input-output parameter parline-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Добавление, изменение, просмотр истории строки документа МЦ (инвентаризация)":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ str/wth-lib.i }
define variable vardoc-code like ub.c-wth-doc.doc-code no-undo.
define variable varchip-num like ub.c-wth-doc.chip-num no-undo.
define variable varcorr-user-db-num like ub.c-wth-doc.corr-user-db-num no-undo.
define variable lock-line as logical no-undo.
define variable locked-wth as logical no-undo .
define variable for-bef-sum like ub.c-wth-line.bef-sum no-undo .

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
&Scoped-define INTERNAL-TABLES buf_c-wth-line

/* Definitions for QUERY QUERY-lines                                    */
&Scoped-define QUERY-STRING-QUERY-lines FOR EACH buf_c-wth-line ~
      WHERE buf_c-wth-line.doc-code = vardoc-code ~
AND buf_c-wth-line.corr-user-db-num = varcorr-user-db-num ~
 AND buf_c-wth-line.chip-num = varchip-num NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-QUERY-lines OPEN QUERY QUERY-lines FOR EACH buf_c-wth-line ~
      WHERE buf_c-wth-line.doc-code = vardoc-code ~
AND buf_c-wth-line.corr-user-db-num = varcorr-user-db-num ~
 AND buf_c-wth-line.chip-num = varchip-num NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-QUERY-lines buf_c-wth-line
&Scoped-define FIRST-TABLE-IN-QUERY-QUERY-lines buf_c-wth-line


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-c-wth-line.aft-sum ub.wealth.wth-name ~
tt-c-wth-line.wth-code ub.wth-place.w-p-name tt-c-wth-line.w-p-code ~
tt-c-wth-line.bef-sum tt-c-wth-line.fact-sum
&Scoped-define ENABLED-TABLES tt-c-wth-line ub.wealth ub.wth-place
&Scoped-define FIRST-ENABLED-TABLE tt-c-wth-line
&Scoped-define SECOND-ENABLED-TABLE ub.wealth
&Scoped-define THIRD-ENABLED-TABLE ub.wth-place
&Scoped-Define ENABLED-OBJECTS b-quit B-prev B-next B-Help T-dtl B-dtl
&Scoped-Define DISPLAYED-FIELDS tt-c-wth-line.aft-sum ub.wealth.wth-name ~
tt-c-wth-line.wth-code ub.wth-place.w-p-name tt-c-wth-line.w-p-code ~
tt-c-wth-line.bef-sum tt-c-wth-line.fact-sum
&Scoped-define DISPLAYED-TABLES tt-c-wth-line ub.wealth ub.wth-place
&Scoped-define FIRST-DISPLAYED-TABLE tt-c-wth-line
&Scoped-define SECOND-DISPLAYED-TABLE ub.wealth
&Scoped-define THIRD-DISPLAYED-TABLE ub.wth-place
&Scoped-Define DISPLAYED-OBJECTS T-dtl

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-dtl
     LABEL "&Номиналы"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-next
     LABEL "&>>"
     SIZE 4 BY 1.

DEFINE BUTTON B-prev
     LABEL "&<<"
     SIZE 4 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE T-dtl AS LOGICAL INITIAL no
     LABEL "Расшифровка суммы"
     VIEW-AS TOGGLE-BOX
     SIZE 21.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY QUERY-lines FOR
      buf_c-wth-line SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-prev AT ROW 1 COL 37
     B-next AT ROW 1 COL 41
     B-Help AT ROW 1 COL 89.75
     tt-c-wth-line.aft-sum AT ROW 6.67 COL 56.4 COLON-ALIGNED
          LABEL "Сумма факт"
          VIEW-AS FILL-IN
          SIZE 17.5 BY 1
     T-dtl AT ROW 9.5 COL 5.5
     B-dtl AT ROW 9.53 COL 28.8
     ub.wealth.wth-name AT ROW 2.93 COL 56.4 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 24.5 BY 1
          FGCOLOR 4
     tt-c-wth-line.wth-code AT ROW 3 COL 23.8 COLON-ALIGNED
          LABEL "Материальная ценность"
           VIEW-AS TEXT
          SIZE 12 BY .67
     ub.wth-place.w-p-name AT ROW 4.57 COL 56.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 24.8 BY 1
          FGCOLOR 4
     tt-c-wth-line.w-p-code AT ROW 4.7 COL 23.8 COLON-ALIGNED
          LABEL "Код места"
           VIEW-AS TEXT
          SIZE 12 BY .67
     tt-c-wth-line.bef-sum AT ROW 6.83 COL 23.5 COLON-ALIGNED
          LABEL "Сумма план"
           VIEW-AS TEXT
          SIZE 17.5 BY .67
     tt-c-wth-line.fact-sum AT ROW 8.2 COL 39.9 COLON-ALIGNED
          LABEL "Расхождение"
           VIEW-AS TEXT
          SIZE 17.5 BY .67
          FGCOLOR 4
     SPACE(33.34) SKIP(3.08)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Строка удаленного документа движения МЦ"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_c-wth-line B "?" ? ub c-wth-line
      TABLE: buf_wealth B "?" ? ub wealth
      TABLE: buf_wth-place B "?" ? ub wth-place
      TABLE: tt-c-wth-line T "?" NO-UNDO ub c-wth-line
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

/* SETTINGS FOR FILL-IN tt-c-wth-line.aft-sum IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-line.bef-sum IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-line.fact-sum IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-line.w-p-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-line.wth-code IN FRAME Dialog-Frame
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
     _TblList          = "buf_c-wth-line"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "buf_c-wth-line.doc-code = vardoc-code
AND buf_c-wth-line.corr-user-db-num = varcorr-user-db-num
 AND buf_c-wth-line.chip-num = varchip-num"
     _Design-Parent    is DIALOG-BOX Dialog-Frame @ ( 9.63 , 45.1 )
*/  /* QUERY QUERY-lines */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Строка удаленного документа движения МЦ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-c-wth-line.aft-sum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-c-wth-line.aft-sum Dialog-Frame
ON LEAVE OF tt-c-wth-line.aft-sum IN FRAME Dialog-Frame /* Сумма факт */
DO:
  if ub.c-wth-doc.status_ = {&permitted}   then do:
  DISPLAY
        (input frame {&frame-name} tt-c-wth-line.aft-sum - tt-c-wth-line.bef-sum) @ tt-c-wth-line.fact-sum
        WITH FRAME {&FRAME-NAME}.

  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-dtl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-dtl Dialog-Frame
ON CHOOSE OF B-dtl IN FRAME Dialog-Frame /* Номиналы */
DO:
  assign
  tt-c-wth-line.bef-sum
  tt-c-wth-line.AFT-sum
  tt-c-wth-line.fact-sum
  tt-c-wth-line.wth-code
  .
  run str/wthcdtlv.w (
                   input parparentproc
                  ,INPUT par-mode
                  ,INPUT parline-rec
                  ,INPUT tt-c-wth-line.doc-code
                  ,INPUT tt-c-wth-line.wth-code
                  ,INPUT tt-c-wth-line.w-p-code
                  ,INPUT tt-c-wth-line.corr-user-db-num
                  ,INPUT tt-c-wth-line.chip-num
                  ,INPUT ?
                  ,INPUT tt-c-wth-line.fact-sum
                  ,INPUT tt-c-wth-line.bef-sum
                  ,INPUT tt-c-wth-line.aft-sum
                  ,INPUT ub.c-wth-doc.doc-type
                  ,input-output table tt-par-dtl ).
  run control-dtl in this-procedure(output lock-line).
  run lock-proc in this-procedure.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-next Dialog-Frame
ON CHOOSE OF B-next IN FRAME Dialog-Frame /* >> */
DO:
      run proc-b-move(input self:name) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-prev Dialog-Frame
ON CHOOSE OF B-prev IN FRAME Dialog-Frame /* << */
DO:
      run proc-b-move(input self:name) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-c-wth-line.w-p-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-c-wth-line.w-p-code Dialog-Frame
ON LEAVE OF tt-c-wth-line.w-p-code IN FRAME Dialog-Frame /* Код места */
DO:
   FIND FIRST buf_wth-place NO-LOCK WHERE
    buf_wth-place.host-code = ub.c-wth-doc.host-code AND
    buf_wth-place.obj-type = tt-c-wth-line.obj-type AND
    buf_wth-place.obj-code = tt-c-wth-line.obj-code AND
    buf_wth-place.w-p-code = INPUT FRAME {&FRAME-NAME} tt-c-wth-line.w-p-code    NO-ERROR.
  IF NOT AVAIL buf_wth-place THEN DO:
    IF tt-c-wth-line.w-p-code = INPUT FRAME {&FRAME-NAME} tt-c-wth-line.w-p-code THEN DO:
        RETURN.
    END.
    MESSAGE
      "Место хранения МЦ" INPUT FRAME {&FRAME-NAME} tt-c-wth-line.w-p-code
      "отсутствует в справочнике или принадлежит другому объекту!"
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.
  DISPLAY
  buf_wth-place.w-p-name @ ub.wth-place.w-p-name
  WITH FRAME {&FRAME-NAME}.
  run display-bef-sum in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-c-wth-line.wth-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-c-wth-line.wth-code Dialog-Frame
ON LEAVE OF tt-c-wth-line.wth-code IN FRAME Dialog-Frame /* Материальная ценность */
DO:
  FIND FIRST buf_wealth NO-LOCK WHERE
                   buf_wealth.wth-code = INPUT FRAME {&FRAME-NAME} tt-c-wth-line.wth-code NO-ERROR.
  IF AVAIL buf_wealth THEN DO:
    DISPLAY
    buf_wealth.wth-name @ ub.wealth.wth-name
    WITH FRAME {&FRAME-NAME}.
  END.
    run display-bef-sum in this-procedure no-error.
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
  if par-mode <> {&lookup} then do:
      message vss-workfile vss-revision vss-description skip
                  "Неверный параметр вызова par-mode"
      view-as alert-box ERROR.
      return error.
  end.
  if par-mode = {&lookup} then do:
    FIND FIRST ub.c-wth-doc No-LOCK WHERE
               recid(ub.c-wth-doc) = pardoc-rec No-ERROR.
  end.
  IF NOT avail ub.c-wth-doc then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найден документ движения МЦ"
    view-as alert-box.
    return error.
  end.
  assign
  vardoc-code = ub.c-wth-doc.doc-code
  varcorr-user-db-num = ub.c-wth-doc.corr-user-db-num
  varchip-num = ub.c-wth-doc.chip-num
  .
  OPEN QUERY QUERY-lines
  FOR EACH buf_c-wth-line WHERE
            buf_c-wth-line.doc-code = vardoc-code
        and buf_c-wth-line.corr-user-db-num = varcorr-user-db-num
        and buf_c-wth-line.chip-num = varchip-num
            NO-LOCK INDEXED-REPOSITION.

    if par-mode = {&lookup} then do:
      get first {&query-name}.
      repeat while parline-rec <> recid(buf_c-wth-line):
        get next {&query-name}.
      end.
    end.
    IF error-status:error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена строка по документу движения МЦ"
      view-as alert-box.
      return error.
    end.

  run fill-tables in this-procedure.
  RUN Myenable in this-procedure.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control-dtl Dialog-Frame
PROCEDURE control-dtl :
define output parameter lock-line as logical no-undo.
   if not avail tt-c-wth-line then return error.
   if par-mode = {&add-def} or can-find(first tt-par-dtl) then dO:
        find first tt-par-dtl No-LOCK  where
                   tt-par-dtl.sum-bef > 0 No-ERROR .
        t-dtl:screen-value in frame {&frame-name} = (if available tt-par-dtl then "yes" else "no").
   end.
   else do:
          find first ub.c-wth-dtl No-LOCK  where
                       ub.c-wth-dtl.doc-code = tt-c-wth-line.doc-code AND
                       ub.c-wth-dtl.wth-code = tt-c-wth-line.wth-code AND
                       ub.c-wth-dtl.w-p-code = tt-c-wth-line.w-p-code No-ERROR .
        t-dtl:screen-value in frame {&frame-name} = (if available ub.c-wth-dtl then "yes" else "no").

   end.
   if t-dtl:screen-value in frame {&frame-name} = "yes" or
         par-mode = {&lookup} then lock-line = yes.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-bef-sum Dialog-Frame
PROCEDURE display-bef-sum :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if available buf_wealth and
   available buf_wth-place then do:
end.

IF AVAIL buf_wealth THEN DO:
  RUN wth-lib_cur-stock-place (
                                 INPUT tt-c-wth-line.obj-type,
                                 INPUT tt-c-wth-line.obj-code,
                                 INPUT ( INPUT FRAME {&FRAME-NAME} tt-c-wth-line.w-p-code ),
                                 INPUT ( INPUT FRAME {&FRAME-NAME} tt-c-wth-line.wth-code ),
                                OUTPUT for-bef-sum
                              ).
  /*
  IF for-bef-sum > 0 THEN DO:*/
      DISPLAY
      foR-bef-sum @ tt-c-wth-line.bef-sum
      WITH FRAME {&FRAME-NAME}.
  /*END.*/
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
  DISPLAY T-dtl
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-c-wth-line THEN
    DISPLAY tt-c-wth-line.aft-sum tt-c-wth-line.wth-code tt-c-wth-line.w-p-code
          tt-c-wth-line.bef-sum tt-c-wth-line.fact-sum
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.wealth THEN
    DISPLAY ub.wealth.wth-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.wth-place THEN
    DISPLAY ub.wth-place.w-p-name
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-prev B-next B-Help tt-c-wth-line.aft-sum T-dtl B-dtl
         ub.wealth.wth-name tt-c-wth-line.wth-code ub.wth-place.w-p-name
         tt-c-wth-line.w-p-code tt-c-wth-line.bef-sum tt-c-wth-line.fact-sum
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
  for each tt-c-wth-line:
    delete tt-c-wth-line.
  end.
for each tt-par-dtl:
    delete tt-par-dtl.
end.

    create tt-c-wth-line.
    buffer-copy buf_c-wth-line to tt-c-wth-line.
    FIND FIRST buf_wealth No-LOCK WHERE
               buf_wealth.wth-code = tt-c-wth-line.wth-code No-error.
        FIND FIRST buf_wth-place No-LOCK WHERE
               buf_wth-place.w-p-code = tt-c-wth-line.w-p-code No-error.

    find first ub.c-wth-dtl No-LOCK WHERE
                  ub.c-wth-dtl.wth-code = tt-c-wth-line.wth-code
              AND ub.c-wth-dtl.doc-code = tt-c-wth-line.doc-code
              AND ub.c-wth-dtl.w-p-code = tt-c-wth-line.w-p-code
              AND ub.c-wth-dtl.corr-user-db-num = tt-c-wth-line.corr-user-db-num
              AND ub.c-wth-dtl.chip-num = tt-c-wth-line.chip-num No-ERROR.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE lock-proc Dialog-Frame
PROCEDURE lock-proc :
DISABLE
  tt-c-wth-line.wth-code
  tt-c-wth-line.w-p-code
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
IF AVAILABLE tt-c-wth-line THEN
    DISPLAY
    tt-c-wth-line.wth-code
    tt-c-wth-line.BEF-sum
    tt-c-wth-line.AFT-sum
    tt-c-wth-line.fact-sum
    tt-c-wth-line.w-p-code
  WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_wealth THEN
    DISPLAY
    buf_wealth.wth-name @ ub.wealth.wth-name
    WITH FRAME Dialog-Frame.
  ELSE
  DISPLAY
  '':u @ WEALTH.WTH-NAME
  WITH FRAME Dialog-Frame.
  IF AVAILABLE BUF_WTH-PLACE THEN
    DISPLAY
    BUF_WTH-PLACE.w-P-name @ ub.wth-place.w-p-name
   WITH FRAME Dialog-Frame.
  ELSE
  DISPLAY
  '':u @ WTH-PLACE.W-P-NAME
  WITH FRAME Dialog-Frame.
  HIDE
  tt-c-wth-line.AFT-sum
  tt-c-wth-line.fact-sum
  IN FRAME {&frame-name}.
CASE par-mode:
    when {&lookup}  THEN DO:
      IF ub.c-wth-doc.status_ = {&wayb} THEN DO:
        HIDE
        tt-c-wth-line.fact-sum IN FRAME {&FRAME-NAME}
        tt-c-wth-line.Aft-sum IN FRAME {&FRAME-NAME}.
      end.
      else do:
        DISPLAY
        TT-c-wth-line.AFT-SUM
        (tt-c-wth-line.aft-sum - tt-c-wth-line.bef-sum) @ tt-c-wth-line.fact-sum WITH FRAME {&FRAME-NAME}.
      END.
      ENABLE
      B-Next
      B-Prev
      b-quit
      b-dtl when avail ub.c-wth-dtl
      WITH FRAME {&FRAME-NAME}.
      locked-wth = yes.
    END.
  END CASE.
  run control-dtl in this-procedure (output lock-line).
  run lock-proc in this-procedure.
  ENABLE
  b-help
  WITH FRAME {&FRAME-NAME}.
  FRAME {&FRAME-NAME}:TITLE =
      "Удаленный документ № " + ub.c-wth-doc.doc-code + " (" + TRIM(
      ( IF ub.c-wth-doc.doc-type = {&income}     THEN "ПРИХОД"         ELSE
      ( IF ub.c-wth-doc.doc-type = {&expense}    THEN "РАСХОД"         ELSE
      ( IF ub.c-wth-doc.doc-type = {&write-off}  THEN "СПИСАНИЕ"       ELSE
      ( IF ub.c-wth-doc.doc-type = {&inventory}  THEN "ИНВЕНТАРИЗАЦИЯ" ELSE ub.c-wth-doc.doc-type ) ) ) ) +
      STRING( ub.c-wth-doc.inter_, "ВНУТ/":U ) + STRING( ub.c-wth-doc.exter_, "ВНЕШ/":U ) ) + ")" +
      "  - " + CAPS( par-mode ) + " матценности".
  VIEW FRAME Dialog-Frame.

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
define variable v-line-rec as recid no-undo .
  ASSIGN v-line-rec = RECID( buf_c-wth-line ).
  CASE par-action:
    when "b-next":U then do:
        GET NEXT {&query-name} NO-LOCK.
    end.
    when "b-prev":U then do:
        GET PREV {&query-name} NO-LOCK.
    end.
  END CASE.
  IF AVAIL buf_c-wth-line THEN DO:
    ASSIGN v-line-rec = RECID( buf_c-wth-line ).
    run fill-tables in this-procedure.
    run MyEnable in this-procedure.
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
    FIND FIRST buf_c-wth-line NO-LOCK WHERE
                    RECID( buf_c-wth-line ) = v-line-rec NO-ERROR.
    MESSAGE
      "Это" ( IF par-action = "B-Next":U THEN "последняя" ELSE "первая" )
      "строка в документе!"
    VIEW-AS ALERT-BOX INFORMATION.
    RETURN NO-APPLY.
  END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
