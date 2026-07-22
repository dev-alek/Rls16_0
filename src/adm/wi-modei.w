&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_wi-mode FOR ub.wi-mode.
DEFINE TEMP-TABLE tt-wi-mode NO-UNDO LIKE ub.wi-mode.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма для ввода, просмотра и изменения режима работы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/03/08
Author: Bakhtadze Natalya
Creation date: 10/03/08

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-mode-type AS character NO-UNDO.
DEFINE INPUT PARAMETER p-mode-id AS character NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма для ввода, просмотра и изменения режима работы".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
define variable v-admin as logical no-undo .
DEFINE BUFFER buf_wi-mode FOR ub.wi-mode.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-wi-mode

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define SELF-NAME Dialog-Frame
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-wi-mode SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY {&SELF-NAME} FOR EACH tt-wi-mode SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-wi-mode
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-wi-mode


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-wi-mode.mode-id tt-wi-mode.mode-name ~
tt-wi-mode.prev-mode-id tt-wi-mode.des
&Scoped-define ENABLED-TABLES tt-wi-mode
&Scoped-define FIRST-ENABLED-TABLE tt-wi-mode
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help f-prev-mode-id-name ~
B-prev-mode-id B-codex
&Scoped-Define DISPLAYED-FIELDS tt-wi-mode.mode-type tt-wi-mode.mode-id ~
tt-wi-mode.mode-name tt-wi-mode.prev-mode-id tt-wi-mode.codex_id ~
tt-wi-mode.ruleset_id tt-wi-mode.des
&Scoped-define DISPLAYED-TABLES tt-wi-mode
&Scoped-define FIRST-DISPLAYED-TABLE tt-wi-mode
&Scoped-Define DISPLAYED-OBJECTS f-prev-mode-id-name f-ruleset-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-codex
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-prev-mode-id
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3.5 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-prev-mode-id-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 66 BY 1 NO-UNDO.

DEFINE VARIABLE f-ruleset-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 66 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-wi-mode SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     tt-wi-mode.mode-type AT ROW 2.5 COL 14 COLON-ALIGNED WIDGET-ID 22
          LABEL "Тип режима" FORMAT "x(255)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Item 1","Item 1"
          DROP-DOWN-LIST
          SIZE 60 BY 1
     tt-wi-mode.mode-id AT ROW 4.5 COL 14 COLON-ALIGNED WIDGET-ID 4
          LABEL "ID режима"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-wi-mode.mode-name AT ROW 6.87 COL 31 COLON-ALIGNED WIDGET-ID 20
          LABEL "Название" FORMAT "x(40)"
          VIEW-AS FILL-IN NATIVE
          SIZE 66 BY 1
     f-prev-mode-id-name AT ROW 8.47 COL 31 COLON-ALIGNED NO-LABEL WIDGET-ID 24
     tt-wi-mode.prev-mode-id AT ROW 8.5 COL 13 COLON-ALIGNED WIDGET-ID 18
          LABEL "Пред. режим" FORMAT "x(12)"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     B-prev-mode-id AT ROW 8.5 COL 29 WIDGET-ID 16
     tt-wi-mode.codex_id AT ROW 10.33 COL 13.5 COLON-ALIGNED WIDGET-ID 50
          LABEL "Кодекс" FORMAT ">,>>>,>>9"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     B-codex AT ROW 10.33 COL 25.5 WIDGET-ID 28
     f-ruleset-name AT ROW 10.33 COL 31 COLON-ALIGNED NO-LABEL WIDGET-ID 54
     tt-wi-mode.ruleset_id AT ROW 11.43 COL 13.5 COLON-ALIGNED WIDGET-ID 52
          LABEL "Набор правил" FORMAT ">>>,>>>,>>9"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     tt-wi-mode.des AT ROW 14 COL 1 NO-LABEL WIDGET-ID 8
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 4
     SPACE(0.49) SKIP(0.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_wi-mode B "?" ? ub wi-mode
      TABLE: tt-wi-mode T "?" NO-UNDO ub wi-mode
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

/* SETTINGS FOR FILL-IN tt-wi-mode.codex_id IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN f-ruleset-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-wi-mode.mode-id IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wi-mode.mode-name IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR COMBO-BOX tt-wi-mode.mode-type IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN tt-wi-mode.prev-mode-id IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-wi-mode.ruleset_id IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-wi-mode SHARE-LOCK.
     _END_FREEFORM
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-codex
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-codex Dialog-Frame
ON CHOOSE OF B-codex IN FRAME Dialog-Frame /* Btn 1 */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-codex-id AS INTEGER NO-UNDO.
DEFINE BUFFER buf_ruleset FOR ub.ruleset.
IF tt-wi-mode.mode-type = ""
OR tt-wi-mode.mode-type =? THEN DO:
   MESSAGE "Не выбран тип режима"
   VIEW-AS ALERT-BOX ERROR.
   UNDO, RETURN NO-APPLY.
END.

if tt-wi-mode.codex_id <> 0 then do:
  find first buf_ruleset no-lock where
          buf_ruleset.codex_id = tt-wi-mode.codex_id
      and buf_ruleset.ruleset_id = tt-wi-mode.ruleset_id .
  v-rid-list = string(recid(buf_ruleset)).
end.
CASE tt-wi-mode.mode-type:
    WHEN {&wi-mode-ibs-th-pos} THEN DO:
        ASSIGN
        v-codex-id = 19.
    END.
    OTHERWISE DO:
        MESSAGE
        substitute("Неивестен кодекс для режима работы с типом &1", tt-wi-mode.mode-type)
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN NO-APPLY.
    END.
END CASE.
run rul/ruleset-s.w ( INPUT parparentproc
                     ,INPUT 'b-sel':U /*bttns*/
                     ,input "codex"
                     ,input v-codex-id
                     ,INPUT-OUTPUT v-rid-list) NO-ERROR.
IF v-rid-list <> '':U THEN DO:
   FIND FIRST buf_ruleset NO-LOCK WHERE
            recid(buf_ruleset) = INTEGER(v-rid-list) NO-ERROR.
  IF NOT AVAILABLE buf_RULESET THEN RETURN NO-APPLY.
  ASSIGN
  tt-wi-mode.codex_id = buf_ruleset.codex_id
  tt-wi-mode.ruleset_id = buf_ruleset.ruleset_id
  f-ruleset-name = buf_ruleset.NAME
  .
  DISPLAY
  tt-wi-mode.CODEx_id
  tt-wi-mode.ruleset_id
  f-ruleset-name
  WITH FRAME {&FRAME-NAME}.
END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-prev-mode-id
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-prev-mode-id Dialog-Frame
ON CHOOSE OF B-prev-mode-id IN FRAME Dialog-Frame /* Btn 1 */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_wi-mode FOR ub.wi-mode.
  IF tt-wi-mode.prev-mode-id > '' THEN DO:
      FIND FIRST buf_wi-mode NO-LOCK WHERE
                buf_wi-mode.mode-type = tt-wi-mode.mode-type
          AND   buf_wi-mode.mode-id = tt-wi-mode.prev-mode-id NO-ERROR.
  END.
  run adm/wi-modes.w ( input parparentproc
                       ,INPUT "b-sel"
                       ,INPUT "mode-type"
                       ,INPUT tt-wi-mode.mode-type
                       ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  IF v-rid-list > '' THEN DO:
      FIND FIRST buf_wi-mode NO-LOCK WHERE
            RECID(buf_wi-mode) = INTEGER(v-rid-list) NO-ERROR.
      IF NOT AVAILABLE buf_wi-mode THEN DO:
         ASSIGN
         tt-wi-mode.prev-mode-id = ?
         f-prev-mode-id-name = ?
         .
      END.
      ELSE DO:
         ASSIGN
         tt-wi-mode.prev-mode-id = buf_wi-mode.mode-id
         f-prev-mode-id-name = buf_wi-mode.mode-name
         .

      END.
      DISPLAY
      tt-wi-mode.prev-mode-id
      f-prev-mode-id-name
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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if lookup('admin', p-mode) > 0 then do:
    v-admin = yes.
    p-mode = trim(replace(p-mode, 'admin', ''), {&comma-char}).
  end.
  IF p-mode = {&add-def} THEN DO:
    /*заблокируем*/
    CREATE tt-wi-mode.
    assign
    tt-wi-mode.mode-type = {&wi-mode-ibs-th-pos}.
  END.
  else do:
    IF p-mode = {&UPDATE} THEN DO:
      FIND FIRST LOCKED_wi-mode EXCLUSIVE-LOCK WHERE
                LOCKED_wi-mode.mode-id = p-mode-id
          AND LOCKED_wi-mode.mode-type = p-mode-type .
    END.
    IF p-mode = {&LOOKUP} THEN DO:
        FIND FIRST LOCKED_wi-mode no-LOCK WHERE
                  LOCKED_wi-mode.mode-id = p-mode-id
            AND LOCKED_wi-mode.mode-type = p-mode-type NO-ERROR.
    END.
    create tt-wi-mode.
    buffer-copy locked_wi-mode to tt-wi-mode.
  end.

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
  DISPLAY f-prev-mode-id-name f-ruleset-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-wi-mode THEN
    DISPLAY tt-wi-mode.mode-type tt-wi-mode.mode-id tt-wi-mode.mode-name
          tt-wi-mode.prev-mode-id tt-wi-mode.codex_id tt-wi-mode.ruleset_id
          tt-wi-mode.des
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help tt-wi-mode.mode-id tt-wi-mode.mode-name
         f-prev-mode-id-name tt-wi-mode.prev-mode-id B-prev-mode-id B-codex
         tt-wi-mode.des
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE BUFFER buf_wi-mode FOR ub.wi-mode.
DEFINE BUFFER buf_ruleset FOR ub.ruleset.
IF tt-wi-mode.prev-mode-id > '' THEN DO:
  FIND FIRST buf_wi-mode NO-LOCK WHERE
            buf_wi-mode.mode-type = tt-wi-mode.mode-type
      AND   buf_wi-mode.mode-id = tt-wi-mode.prev-mode-id NO-ERROR.
  IF AVAILABLE buf_wi-mode THEN DO:
     f-prev-mode-id-name = buf_wi-mode.mode-name.
  END.
END.

if tt-wi-mode.codex_id <> 0 then do:
  find first buf_ruleset no-lock where
          buf_ruleset.codex_id = tt-wi-mode.codex_id
      and buf_ruleset.ruleset_id = tt-wi-mode.ruleset_id .
  IF AVAILABLE buf_ruleset THEN DO:
      ASSIGN
      f-ruleset-name = buf_ruleset.NAME.
  END.
end.


tt-wi-mode.MODE-TYPE:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = {&wi-mode-ibs-th-pos-full} + {&comma-char} + {&wi-mode-ibs-th-pos}.
IF AVAILABLE tt-wi-mode THEN
DISPLAY
tt-wi-mode.mode-type
tt-wi-mode.mode-id
tt-wi-mode.mode-name
tt-wi-mode.prev-mode-id
f-prev-mode-id-name
f-ruleset-name
tt-wi-mode.des
WITH FRAME {&frame-name} .
ENABLE
B-exit  when p-mode <> {&lookup}
b-quit
B-Help
tt-wi-mode.mode-type  when p-mode = {&add-def} AND num-entries(tt-wi-mode.MODE-TYPE:list-item-pairs) > 2
tt-wi-mode.mode-id when p-mode = {&add-def}
tt-wi-mode.mode-name       when p-mode <> {&lookup}
/*tt-wi-mode.prev-mode-id when p-mode <> {&lookup}*/
b-prev-mode-id WHEN p-mode <> {&LOOKUP}
b-codex WHEN p-mode <> {&LOOKUP}
tt-wi-mode.des
WITH FRAME {&frame-name} .
if p-mode = {&lookup} then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  tt-wi-mode.des:READ-ONLY IN FRAME {&FRAME-NAME} = YES .
  hide b-exit in frame {&frame-name} .
end.
VIEW FRAME {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS recID  NO-UNDO.
IF p-mode = {&LOOKUP} THEN DO:
    RETURN.
END.
IF p-mode = {&update} THEN DO:
  v-rec = p-rec.
END.
ASSIGN
FRAME {&FRAME-NAME}
tt-wi-mode.mode-type
tt-wi-mode.mode-id
tt-wi-mode.mode-name
tt-wi-mode.prev-mode-id
tt-wi-mode.des.
run adm/wi-mode1.p ( INPUT p-mode
                ,INPUT NO /*p-silent*/
                ,INPUT-OUTPUT v-rec
                ,INPUT tt-wi-mode.mode-type
                ,INPUT tt-wi-mode.mode-id
                ,INPUT tt-wi-mode.prev-mode-id
                ,input tt-wi-mode.codex_id
                ,input tt-wi-mode.ruleset_id
                ,INPUT tt-wi-mode.mode-name
                ,INPUT tt-wi-mode.des
                ) no-error.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
p-rec = v-rec.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
