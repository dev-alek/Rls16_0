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
DEFINE BUFFER buf_wth-place FOR ub.wth-place.
DEFINE TEMP-TABLE tt-wth-line NO-UNDO LIKE ub.wth-line.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Добавление, изменение, просмотр строки документа МЦ (инвентаризация)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06


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
define variable vss-description AS CHAR NO-UNDO INIT "Добавление, изменение, просмотр строки документа МЦ (инвентаризация)":U.
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/showinf.i }
{ str/wth-lib.i }
{ gbl/cur-time.i }
define variable vardoc-code like ub.wth-doc.doc-code no-undo.
define variable lock-line as logical no-undo.
define variable locked-wth as logical no-undo .
define variable for-bef-sum like ub.wth-line.bef-sum no-undo .

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
&Scoped-define INTERNAL-TABLES ub.buf_wth-line

/* Definitions for QUERY QUERY-lines                                    */
&Scoped-define QUERY-STRING-QUERY-lines FOR EACH ub.buf_wth-line ~
      WHERE buf_wth-line.doc-code = vardoc-code NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-QUERY-lines OPEN QUERY QUERY-lines FOR EACH ub.buf_wth-line ~
      WHERE buf_wth-line.doc-code = vardoc-code NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-QUERY-lines ub.buf_wth-line
&Scoped-define FIRST-TABLE-IN-QUERY-QUERY-lines ub.buf_wth-line


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-wth-line.wth-code tt-wth-line.w-p-code ~
tt-wth-line.aft-sum ub.wealth.wth-name ub.wth-place.w-p-name ~
tt-wth-line.bef-sum tt-wth-line.fact-sum
&Scoped-define ENABLED-TABLES tt-wth-line ub.wealth ub.wth-place
&Scoped-define FIRST-ENABLED-TABLE tt-wth-line
&Scoped-define SECOND-ENABLED-TABLE ub.wealth
&Scoped-define THIRD-ENABLED-TABLE ub.wth-place
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-save B-prev B-next B-Help ~
B-wealth B-place T-dtl B-dtl
&Scoped-Define DISPLAYED-FIELDS tt-wth-line.wth-code tt-wth-line.w-p-code ~
tt-wth-line.aft-sum ub.wealth.wth-name ub.wth-place.w-p-name ~
tt-wth-line.bef-sum tt-wth-line.fact-sum
&Scoped-define DISPLAYED-TABLES tt-wth-line ub.wealth ub.wth-place
&Scoped-define FIRST-DISPLAYED-TABLE tt-wth-line
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

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-next
     LABEL "&>>"
     SIZE 4 BY 1.

DEFINE BUTTON B-place
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-prev
     LABEL "&<<"
     SIZE 4 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-save
     LABEL "&Создать"
     SIZE 10 BY 1.

DEFINE BUTTON B-wealth
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE VARIABLE T-dtl AS LOGICAL INITIAL no
     LABEL "Расшифровка суммы"
     VIEW-AS TOGGLE-BOX
     SIZE 21.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY QUERY-lines FOR
      ub.buf_wth-line SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-save AT ROW 1 COL 21
     B-prev AT ROW 1 COL 37
     B-next AT ROW 1 COL 41
     B-Help AT ROW 1 COL 89.75
     tt-wth-line.wth-code AT ROW 3 COL 23.8 COLON-ALIGNED
          LABEL "Материальная ценность"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     B-wealth AT ROW 3 COL 39.4
     tt-wth-line.w-p-code AT ROW 4.7 COL 23.8 COLON-ALIGNED
          LABEL "Код места"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     B-place AT ROW 4.77 COL 39.3
     tt-wth-line.aft-sum AT ROW 6.67 COL 56.4 COLON-ALIGNED
          LABEL "Сумма факт"
          VIEW-AS FILL-IN
          SIZE 17.5 BY 1
     T-dtl AT ROW 9.5 COL 5.5
     B-dtl AT ROW 9.53 COL 28.8
     ub.wealth.wth-name AT ROW 2.93 COL 56.4 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 24.5 BY 1
          FGCOLOR 4
     ub.wth-place.w-p-name AT ROW 4.57 COL 56.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 24.8 BY 1
          FGCOLOR 4
     tt-wth-line.bef-sum AT ROW 6.83 COL 23.5 COLON-ALIGNED
          LABEL "Сумма план"
           VIEW-AS TEXT
          SIZE 17.5 BY .67
     tt-wth-line.fact-sum AT ROW 8.2 COL 39.9 COLON-ALIGNED
          LABEL "Расхождение"
           VIEW-AS TEXT
          SIZE 17.5 BY .67
          FGCOLOR 4
     SPACE(33.34) SKIP(3.08)
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
      TABLE: buf_wth-place B "?" ? ub wth-place
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

/* SETTINGS FOR FILL-IN tt-wth-line.aft-sum IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-line.bef-sum IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-line.fact-sum IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-line.w-p-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
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
     _Design-Parent    is DIALOG-BOX Dialog-Frame @ ( 9.63 , 45.1 )
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


&Scoped-define SELF-NAME tt-wth-line.aft-sum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-line.aft-sum Dialog-Frame
ON LEAVE OF tt-wth-line.aft-sum IN FRAME Dialog-Frame /* Сумма факт */
DO:
  if ub.wth-doc.status_ = {&permitted}   then do:
  DISPLAY
        (input frame {&frame-name} tt-wth-line.aft-sum - tt-wth-line.bef-sum) @ tt-wth-line.fact-sum
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
  tt-wth-line.bef-sum
  tt-wth-line.AFT-sum
  tt-wth-line.fact-sum
  tt-wth-line.wth-code
  .
  run str/wth-dtlv.w (INPUT parparentproc,
                  INPUT par-mode,
                  INPUT parline-rec,
                  INPUT tt-wth-line.doc-code,
                  INPUT tt-wth-line.wth-code,
                  INPUT tt-wth-line.w-p-code,
                  INPUT ?,
                  INPUT tt-wth-line.fact-sum,
                  INPUT tt-wth-line.bef-sum,
                  INPUT tt-wth-line.aft-sum,
                  INPUT ub.wth-doc.doc-type,
                  input-output table tt-par-dtl ).
  run control-dtl in this-procedure(output lock-line).
  run lock-proc in this-procedure(input lock-line).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  run proc-save-line(no, input-output par-mode) No-ERROR.
  if error-status:error then return no-apply.
  APPLY "GO":U TO FRAME {&FRAME-NAME}.
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


&Scoped-define SELF-NAME B-place
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-place Dialog-Frame
ON CHOOSE OF B-place IN FRAME Dialog-Frame
DO:
  define variable v_rid-list as character no-undo.
  define variable v-ref-rec as recid no-undo .

  FIND FIRST buf_wth-place NO-LOCK WHERE
    buf_wth-place.host-code = ub.wth-doc.host-code AND
    buf_wth-place.obj-type = tt-wth-line.obj-type AND
    buf_wth-place.obj-code = tt-wth-line.obj-code AND
    buf_wth-place.w-p-code    = INPUT FRAME {&FRAME-NAME} tt-wth-line.w-p-code NO-ERROR.
  IF AVAIL buf_wth-place THEN DO:
    if ub.wth-doc.auto-fill and buf_wth-place.cash-desk = 0 then do:
      message
      "Для автоматического документа место хранения должно быть кассой"
      view-as alert-box error.
      return no-apply.
    end.
      ASSIGN
      v_rid-list = string(RECID( buf_wth-place ))
      .
  END.
    run ref/wthplref.w (
                    input parparentproc
                   ,INPUT "b-sel":U
                   ,INPUT wth-doc.host-code
                   ,INPUT tt-wth-line.obj-type
                   ,INPUT tt-wth-line.obj-code
                   ,input {&g___object}
                   ,input-OUTPUT v_rid-list ).

  IF v_rid-list <> ? AND v_rid-list <> "":U THEN DO:
    ASSIGN v-ref-rec = INT( v_rid-list ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND FIRST buf_wth-place NO-LOCK WHERE
                        RECID( buf_wth-place ) = v-ref-rec NO-ERROR.
    IF AVAIL buf_wth-place THEN DO:
      if ub.wth-doc.auto-fill and buf_wth-place.cash-desk = 0 then do:
        message
        "Для автоматического документа место хранения должно быть кассой"
        view-as alert-box error.
        return no-apply.
      end.
      ASSIGN
      tt-wth-line.w-p-code = buf_wth-place.w-p-code.
      DISPLAY
      tt-wth-line.w-p-code
      buf_wth-place.w-p-name @ ub.wth-place.w-p-name
      WITH FRAME {&FRAME-NAME}.
    END.
    ELSE DO:
      RETURN NO-APPLY.
    END.
  END.
  ELSE DO:
    RETURN NO-APPLY.
  END.
  run display-bef-sum in this-procedure no-error.

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


&Scoped-define SELF-NAME B-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-save Dialog-Frame
ON CHOOSE OF B-save IN FRAME Dialog-Frame /* Создать */
DO:
 define variable loc-mode as character no-undo.
 loc-mode = {&add-def}.
  run proc-save-line(no, input-output loc-mode) No-ERROR.
  if error-status:error then return no-apply.
   run fill-tables in this-procedure no-error.
  if error-status:error then return no-apply.
  run Myenable in this-procedure no-error.
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
  if v_rid-list = '':U then return no-apply.
  FIND FIRSt buf_wealth NO-LOCK WHERE
             RECID( buf_wealth ) = INT( ENTRY( NUM-ENTRIES( v_rid-list ), v_rid-list ) ) NO-ERROR.
  IF AVAIL buf_wealth THEN DO:
    DISPLAY
    buf_wealth.wth-code @ tt-wth-line.wth-code
    buf_wealth.wth-name @ ub.wealth.wth-name
    WITH FRAME {&FRAME-NAME}.
  END.
run display-bef-sum in this-procedure no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-line.w-p-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-line.w-p-code Dialog-Frame
ON LEAVE OF tt-wth-line.w-p-code IN FRAME Dialog-Frame /* Код места */
DO:
   FIND FIRST buf_wth-place NO-LOCK WHERE
    buf_wth-place.host-code = ub.wth-DOC.host-code AND
    buf_wth-place.obj-type = tt-wth-line.obj-type AND
    buf_wth-place.obj-code = tt-wth-line.obj-code AND
    buf_wth-place.w-p-code = INPUT FRAME {&FRAME-NAME} tt-wth-line.w-p-code    NO-ERROR.
  IF NOT AVAIL buf_wth-place THEN DO:
    IF tt-wth-line.w-p-code = INPUT FRAME {&FRAME-NAME} tt-wth-line.w-p-code THEN DO:
        RETURN.
    END.
    MESSAGE
      "Место хранения МЦ" INPUT FRAME {&FRAME-NAME} tt-wth-line.w-p-code
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


&Scoped-define SELF-NAME tt-wth-line.wth-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-line.wth-code Dialog-Frame
ON LEAVE OF tt-wth-line.wth-code IN FRAME Dialog-Frame /* Материальная ценность */
DO:
  FIND FIRST buf_wealth NO-LOCK WHERE
                   buf_wealth.wth-code = INPUT FRAME {&FRAME-NAME} tt-wth-line.wth-code NO-ERROR.
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
        find first tt-par-dtl No-LOCK  where
                   tt-par-dtl.sum-bef > 0 No-ERROR .
        t-dtl:screen-value in frame {&frame-name} = (if available tt-par-dtl then "yes" else "no").
   end.
   else do:
          find first ub.wth-dtl No-LOCK  where
                       ub.wth-dtl.doc-code = tt-wth-line.doc-code AND
                       ub.wth-dtl.wth-code = tt-wth-line.wth-code AND
                       ub.wth-dtl.w-p-code = tt-wth-line.w-p-code No-ERROR .
        t-dtl:screen-value in frame {&frame-name} = (if available wth-dtl then "yes" else "no").

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
                                 INPUT tt-wth-line.obj-type,
                                 INPUT tt-wth-line.obj-code,
                                 INPUT ( INPUT FRAME {&FRAME-NAME} tt-wth-line.w-p-code ),
                                 INPUT ( INPUT FRAME {&FRAME-NAME} tt-wth-line.wth-code ),
                                OUTPUT for-bef-sum
                              ).
  /*
  IF for-bef-sum > 0 THEN DO:*/
      DISPLAY
      foR-bef-sum @ tt-wth-line.bef-sum
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
  IF AVAILABLE tt-wth-line THEN
    DISPLAY tt-wth-line.wth-code tt-wth-line.w-p-code tt-wth-line.aft-sum
          tt-wth-line.bef-sum tt-wth-line.fact-sum
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.wealth THEN
    DISPLAY ub.wealth.wth-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.wth-place THEN
    DISPLAY ub.wth-place.w-p-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-save B-prev B-next B-Help tt-wth-line.wth-code
         B-wealth tt-wth-line.w-p-code B-place tt-wth-line.aft-sum T-dtl B-dtl
         ub.wealth.wth-name ub.wth-place.w-p-name tt-wth-line.bef-sum
         tt-wth-line.fact-sum
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

  if par-mode = {&add-def} then do:
    run cur-time in this-procedure(output v-today, output v-time).
    { trg/wth-licr.i tt-wth-line ub.wth-doc inv " " " " v-today }
  end.
  else do:
    create tt-wth-line.
    buffer-copy buf_wth-line to tt-wth-line.
    FIND FIRST buf_wealth No-LOCK WHERE
               buf_wealth.wth-code = tt-wth-line.wth-code No-error.
        FIND FIRST buf_wth-place No-LOCK WHERE
               buf_wth-place.w-p-code = tt-wth-line.w-p-code No-error.

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
  b-place
  tt-wth-line.w-p-code
  with frame {&frame-name}
  .
  ELSE
  ENABLE
  b-wealth when locked-wth = no
  tt-wth-line.wth-code when locked-wth = no
  b-place when locked-wth = no
  tt-wth-line.w-p-code when locked-wth = no
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
IF AVAILABLE tt-wth-line THEN
    DISPLAY
    tt-wth-line.wth-code
    tt-wth-line.BEF-sum
    tt-wth-line.AFT-sum
    tt-wth-line.fact-sum
    tt-wth-line.w-p-code
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
  tt-wth-line.AFT-sum
  tt-wth-line.fact-sum
  IN FRAME {&frame-name}.
CASE par-mode:
  when {&add-def} THEN DO:
    ENABLE
    tt-wth-line.wth-code
    TT-WTH-LINE.W-P-CODE
    B-Wealth
    B-PLACE
    B-save
    B-exit
    b-quit
    b-dtl
    WITH FRAME {&FRAME-NAME}.
    HIDE
    tt-wth-line.fact-sum IN FRAME {&FRAME-NAME}
    tt-wth-line.Aft-sum IN FRAME {&FRAME-NAME}
    B-Next IN FRAME {&FRAME-NAME}
    B-Prev IN FRAME {&FRAME-NAME}
    .
    locked-wth = no.
  END.
  when {&update}  THEN DO:
      IF ub.wth-doc.status_ = {&wayb} THEN DO:
        ENABLE
        B-save
        B-exit
        b-quit
        b-dtl
        WITH FRAME {&FRAME-NAME}.
        HIDE
        tt-wth-line.fact-sum IN FRAME {&FRAME-NAME}
        tt-wth-line.Aft-sum IN FRAME {&FRAME-NAME}
        B-Next        IN FRAME {&FRAME-NAME}
        B-Prev        IN FRAME {&FRAME-NAME}
        .
        locked-wth = yes.
      END.
    ELSE IF wth-doc.status_ = {&permitted} THEN DO:
        DISPLAY
        (tt-wth-line.aft-sum - tt-wth-line.bef-sum) @ tt-wth-line.fact-sum
        TT-WTH-LINE.AFT-SUM
        WITH FRAME {&FRAME-NAME}.
        ENABLE
        tt-wth-line.Aft-sum
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
      IF ub.wth-doc.status_ = {&wayb} THEN DO:
        HIDE
        tt-wth-line.fact-sum IN FRAME {&FRAME-NAME}
        tt-wth-line.Aft-sum IN FRAME {&FRAME-NAME}.
      end.
      else do:
        DISPLAY
        TT-WTH-LINE.AFT-SUM
        (tt-wth-line.aft-sum - tt-wth-line.bef-sum) @ tt-wth-line.fact-sum WITH FRAME {&FRAME-NAME}.
      END.
      ENABLE
      B-Next
      B-Prev
      b-quit
      b-dtl when avail wth-dtl
      WITH FRAME {&FRAME-NAME}.
      HIDE
      B-save IN FRAME {&FRAME-NAME}
      B-Wealth IN FRAME {&FRAME-NAME}
      B-PLACE IN FRAME {&FRAME-NAME}
      .
      locked-wth = yes.
    END.
  END CASE.
  run control-dtl in this-procedure (output lock-line).
  run lock-proc in this-procedure(input lock-line).
  ENABLE
  b-help
  WITH FRAME {&FRAME-NAME}.
  FRAME {&FRAME-NAME}:TITLE =
      "Документ № " + wth-doc.doc-code + " (" + TRIM(
      ( IF wth-doc.doc-type = {&income}     THEN "ПРИХОД"         ELSE
      ( IF wth-doc.doc-type = {&expense}    THEN "РАСХОД"         ELSE
      ( IF wth-doc.doc-type = {&write-off}  THEN "СПИСАНИЕ"       ELSE
      ( IF wth-doc.doc-type = {&inventory}  THEN "ИНВЕНТАРИЗАЦИЯ" ELSE wth-doc.doc-type ) ) ) ) +
      STRING( wth-doc.inter_, "ВНУТ/":U ) + STRING( wth-doc.exter_, "ВНЕШ/":U ) ) + ")" +
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
frame {&frame-name} tt-wth-line.w-p-code
frame {&frame-name} tt-wth-line.bef-sum
frame {&frame-name} tt-wth-line.aft-sum
frame {&frame-name} tt-wth-line.fact-sum
.
 run str/wth-lnv1.p (input-output parline-rec,
                input  loc-mode,
                vardoc-code,
                tt-wth-line.wth-code,
                tt-wth-line.w-p-code,
                tt-wth-line.bef-sum,
                tt-wth-line.aft-sum,
                input table tt-par-dtl,
                par-log
                ) no-error .


  IF ERROR-STATUS:ERROR THEN DO:
    if var-entry <> '':U then do:
      CASE var-entry:
        when "wth-code":U then do:
            APPLY "ENTRY":U TO tt-wth-line.wth-code IN FRAME {&FRAME-NAME}.
        end.
        when "w-p-code":U then do:
            APPLY "ENTRY":U TO tt-wth-line.w-p-code IN FRAME {&FRAME-NAME}.
        end.
        when "aft-sum":U then do:
            APPLY "ENTRY":U TO tt-wth-line.aft-sum IN FRAME {&FRAME-NAME}.
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
