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
DEFINE TEMP-TABLE tt-c-wth-line NO-UNDO LIKE ub.c-wth-line.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Добавление, изменение, просмотр истории строки документа МЦ (не инвентаризация)

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
       { str/ttpardt0.i }.
define input parameter par-mode as character no-undo .
define input parameter pardoc-rec as recid no-undo.
define input parameter par-current-w-p-code like ub.c-wth-line.w-p-code no-undo.
define input parameter par-out-w-p-code like ub.c-wth-line.out-code no-undo.
define input-output parameter parline-rec as recid no-undo.
define input parameter pardoc-type like ub.c-wth-doc.doc-type no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Добавление, изменение, просмотр истории строки документа МЦ (не инвентаризация)":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/showinf.i }
define variable vardoc-code like ub.c-wth-doc.doc-code no-undo.
define variable varchip-num like ub.c-wth-doc.chip-num no-undo.
define variable varcorr-user-db-num like ub.c-wth-doc.corr-user-db-num no-undo.
define variable lock-line as logical no-undo.
define variable locked-wth as logical no-undo .

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
&Scoped-Define ENABLED-FIELDS ub.wealth.wth-name tt-c-wth-line.wth-code ~
tt-c-wth-line.doc-sum tt-c-wth-line.fact-sum
&Scoped-define ENABLED-TABLES ub.wealth tt-c-wth-line
&Scoped-define FIRST-ENABLED-TABLE ub.wealth
&Scoped-define SECOND-ENABLED-TABLE tt-c-wth-line
&Scoped-Define ENABLED-OBJECTS b-quit B-dtl B-prev B-next B-Help T-dtl
&Scoped-Define DISPLAYED-FIELDS ub.wealth.wth-name tt-c-wth-line.wth-code ~
tt-c-wth-line.doc-sum tt-c-wth-line.sum-gds-rubl tt-c-wth-line.fact-sum ~
tt-c-wth-line.sum-gds-base
&Scoped-define DISPLAYED-TABLES ub.wealth tt-c-wth-line
&Scoped-define FIRST-DISPLAYED-TABLE ub.wealth
&Scoped-define SECOND-DISPLAYED-TABLE tt-c-wth-line
&Scoped-Define DISPLAYED-OBJECTS T-dtl

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-3 tt-c-wth-line.sum-gds-rubl tt-c-wth-line.sum-gds-base

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
     SIZE 10 BY 1
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
     B-dtl AT ROW 1 COL 11.5
     B-prev AT ROW 1 COL 37
     B-next AT ROW 1 COL 41
     B-Help AT ROW 1 COL 54.9
     T-dtl AT ROW 6.27 COL 1.5
     ub.wealth.wth-name AT ROW 2.77 COL 35 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 32 BY 1
          FGCOLOR 4
     tt-c-wth-line.wth-code AT ROW 3 COL 22.3 COLON-ALIGNED
          LABEL "Материальная ценность"
           VIEW-AS TEXT
          SIZE 12 BY .67
     tt-c-wth-line.doc-sum AT ROW 4.27 COL 22 COLON-ALIGNED
          LABEL "Кол-во движения"
           VIEW-AS TEXT
          SIZE 13.5 BY .67
          FGCOLOR 4
     tt-c-wth-line.sum-gds-rubl AT ROW 4.27 COL 68 COLON-ALIGNED WIDGET-ID 264
          LABEL "Сумма по тов. (abbr_rubl)" FORMAT "->,>>>,>>>,>>9.99"
           VIEW-AS TEXT
          SIZE 16 BY .67
          FGCOLOR 4
     tt-c-wth-line.fact-sum AT ROW 5.5 COL 22 COLON-ALIGNED
          LABEL "Количество факт"
           VIEW-AS TEXT
          SIZE 13.5 BY .67
          FGCOLOR 4
     tt-c-wth-line.sum-gds-base AT ROW 5.5 COL 68 COLON-ALIGNED WIDGET-ID 262
          LABEL "Сумма по тов. (баз.вал.)" FORMAT "->,>>>,>>>,>>9.99"
           VIEW-AS TEXT
          SIZE 14 BY .67
          FGCOLOR 4
     SPACE(8.74) SKIP(1.20)
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

/* SETTINGS FOR FILL-IN tt-c-wth-line.doc-sum IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-line.fact-sum IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-line.sum-gds-base IN FRAME Dialog-Frame
   NO-ENABLE 3 EXP-LABEL EXP-FORMAT                                     */
ASSIGN
       tt-c-wth-line.sum-gds-base:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-c-wth-line.sum-gds-rubl IN FRAME Dialog-Frame
   NO-ENABLE 3 EXP-LABEL EXP-FORMAT                                     */
ASSIGN
       tt-c-wth-line.sum-gds-rubl:HIDDEN IN FRAME Dialog-Frame           = TRUE.

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
     _Design-Parent    is DIALOG-BOX Dialog-Frame @ ( 1.27 , 71.5 )
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


&Scoped-define SELF-NAME B-dtl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-dtl Dialog-Frame
ON CHOOSE OF B-dtl IN FRAME Dialog-Frame /* Номиналы */
DO:
  assign
  tt-c-wth-line.doc-sum
  tt-c-wth-line.fact-sum
  tt-c-wth-line.wth-code
  .
  run str/wthcdtlc.w (
                  input parparentproc
                  ,INPUT par-mode
                  ,INPUT parline-rec
                  ,INPUT tt-c-wth-line.doc-code
                  ,INPUT tt-c-wth-line.wth-code
                  ,INPUT tt-c-wth-line.w-p-code
                  ,INPUT tt-c-wth-line.corr-user-db-num
                  ,INPUT tt-c-wth-line.chip-num
                  ,INPUT tt-c-wth-line.doc-sum
                  ,INPUT tt-c-wth-line.fact-sum
                  ,INPUT tt-c-wth-line.bef-sum
                  ,INPUT tt-c-wth-line.aft-sum
                  ,INPUT ub.c-wth-doc.doc-type
                  ,input-output table tt-par-dtl ).
  run control-dtl in this-procedure(output lock-line).
  run lock-proc in this-procedure(input lock-line).

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


&Scoped-define SELF-NAME tt-c-wth-line.wth-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-c-wth-line.wth-code Dialog-Frame
ON LEAVE OF tt-c-wth-line.wth-code IN FRAME Dialog-Frame /* Материальная ценность */
DO:
  FIND FIRST buf_wealth NO-LOCK WHERE
                   buf_wealth.wth-code = INPUT FRAME {&FRAME-NAME} tt-c-wth-line.wth-code NO-ERROR.
  IF AVAIL buf_wealth THEN DO:
    DISPLAY buf_wealth.wth-name @ ub.wealth.wth-name
    WITH FRAME {&FRAME-NAME}.
  END.

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
       AND  buf_c-wth-line.corr-user-db-num = varcorr-user-db-num
       AND  buf_c-wth-line.chip-num = varchip-num NO-LOCK INDEXED-REPOSITION.

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
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter lock-line as logical no-undo.
if not avail tt-c-wth-line then return error.
if can-find(first tt-par-dtl) then dO:

     find first tt-par-dtl No-LOCK  where
                tt-par-dtl.doc-sum > 0 No-ERROR .
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
par-mode = {&lookup}
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
    DISPLAY tt-c-wth-line.wth-code tt-c-wth-line.doc-sum
          tt-c-wth-line.sum-gds-rubl tt-c-wth-line.fact-sum
          tt-c-wth-line.sum-gds-base
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.wealth THEN
    DISPLAY ub.wealth.wth-name
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-dtl B-prev B-next B-Help T-dtl ub.wealth.wth-name
         tt-c-wth-line.wth-code tt-c-wth-line.doc-sum tt-c-wth-line.fact-sum
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
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER lock-line as logical no-undo.
  if lock-line then
  DISABLE
  tt-c-wth-line.wth-code
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
assign
tt-c-wth-line.sum-gds-rubl:label in frame {&frame-name} = "Сумма по тов. ({&abbr_rubl})".
IF AVAILABLE tt-c-wth-line THEN
    DISPLAY
    tt-c-wth-line.wth-code
    tt-c-wth-line.doc-sum
    tt-c-wth-line.fact-sum
  WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_wealth THEN DO:
    DISPLAY
    buf_wealth.wth-name @ ub.wealth.wth-name
    WITH FRAME Dialog-Frame.
    if buf_wealth.is-ser = 1 then do:
      view
      tt-c-wth-line.sum-gds-base
      tt-c-wth-line.sum-gds-rubl
      in frame Dialog-Frame.
      DISPLAY
      tt-c-wth-line.sum-gds-base
      tt-c-wth-line.sum-gds-rubl
      WITH FRAME Dialog-Frame.
    end.
  END.
  ELSE
  DISPLAY
  '':u @ WEALTH.WTH-NAME
  WITH FRAME Dialog-Frame.
CASE par-mode:
    when {&lookup}  THEN DO:
      IF ub.c-wth-doc.status_ <> {&wayb} THEN DO:
        DISPLAY
        tt-c-wth-line.fact-sum WITH FRAME {&FRAME-NAME}.
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
  run lock-proc in this-procedure(input lock-line).
  ENABLE
  b-help
  WITH FRAME {&FRAME-NAME}.
  FRAME {&FRAME-NAME}:TITLE =
      "Удаленный документ № " + c-wth-doc.doc-code + " (" + TRIM(
      ( IF c-wth-doc.doc-type = {&income}     THEN "ПРИХОД"         ELSE
      ( IF c-wth-doc.doc-type = {&expense}    THEN "РАСХОД"         ELSE
      ( IF c-wth-doc.doc-type = {&write-off}  THEN "СПИСАНИЕ"       ELSE
      ( IF c-wth-doc.doc-type = {&inventory}  THEN "ИНВЕНТАРИЗАЦИЯ" ELSE c-wth-doc.doc-type ) ) ) ) +
      STRING( c-wth-doc.inter_, "ВНУТ/":U ) + STRING( c-wth-doc.exter_, "ВНЕШ/":U ) ) + ")" +
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

define variable is-updated as logical no-undo.
define variable loc#log as logical no-undo.
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
