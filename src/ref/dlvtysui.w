&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_delivery-subject FOR ub.delivery-subject.
DEFINE BUFFER locked_delivery-type FOR ub.delivery-type.
DEFINE BUFFER locked_delivery-type-subject FOR ub.delivery-type-subject.
DEFINE TEMP-TABLE tt-delivery-subject NO-UNDO LIKE ub.delivery-subject.
DEFINE TEMP-TABLE tt-delivery-type NO-UNDO LIKE ub.delivery-type.
DEFINE TEMP-TABLE tt-delivery-type-subject NO-UNDO LIKE ub.delivery-type-subject.
DEFINE BUFFER X_curr_clients FOR ub.clients.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка редактирования ТИПА ДОСТАВКИ ОТ СУБЪЕКТА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/16/04
Author: Bakhtadze Natalya
Creation date: 03/16/04

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo.
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo.
define input parameter p-mode as character no-undo.
/*может быть {&add-def} {&update} {&lookup}*/
DEFINE INPUT PARAMETER p-deliv-type-code LIKE ub.delivery-type-subject.deliv-type-code NO-UNDO.
DEFINE INPUT PARAMETER p-deliv-subj-code LIKE ub.delivery-type-subject.deliv-subj-code NO-UNDO.
define input-output parameter p-doc-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования ТИПА ДОСТАВКИ ОТ СУБЪЕКТА".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }


define variable v-tab-order as character no-undo.
define variable v-db-num LIKE ub.db.db-num no-undo.
&scop tab-order   "B-exit,b-quit,b-hist,b-help,deliv-type-code,b-deliv-type,deliv-subj-code,b-deliv-subj,des"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-delivery-type-subject tt-delivery-subject

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame ~
tt-delivery-type-subject.deliv-type-code ~
tt-delivery-type-subject.deliv-subj-code tt-delivery-type-subject.des
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-delivery-type-subject.deliv-type-code ~
tt-delivery-type-subject.deliv-subj-code tt-delivery-type-subject.des
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame ~
tt-delivery-type-subject
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-delivery-type-subject
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-delivery-type-subject SHARE-LOCK, ~
      EACH tt-delivery-subject WHERE TRUE /* Join to tt-delivery-type-subject incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-delivery-type-subject SHARE-LOCK, ~
      EACH tt-delivery-subject WHERE TRUE /* Join to tt-delivery-type-subject incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-delivery-type-subject ~
tt-delivery-subject
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-delivery-type-subject
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame tt-delivery-subject


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-delivery-type-subject.deliv-type-code ~
tt-delivery-type-subject.deliv-subj-code tt-delivery-type-subject.des
&Scoped-define ENABLED-TABLES tt-delivery-type-subject
&Scoped-define FIRST-ENABLED-TABLE tt-delivery-type-subject
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Hist B-Help B-deliv-type ~
B-deliv-subj
&Scoped-Define DISPLAYED-FIELDS tt-delivery-type-subject.deliv-type-code ~
tt-delivery-type-subject.deliv-subj-code tt-delivery-type-subject.des
&Scoped-define DISPLAYED-TABLES tt-delivery-type-subject
&Scoped-define FIRST-DISPLAYED-TABLE tt-delivery-type-subject
&Scoped-Define DISPLAYED-OBJECTS F-deliv-type-name F-deliv-subj-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-deliv-subj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON B-deliv-type
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
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Hist
     LABEL "Ис&тория"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE F-deliv-subj-name AS CHARACTER FORMAT "X(50)"
     LABEL "Название субъекта доставки"
     VIEW-AS FILL-IN
     SIZE 63 BY 1 NO-UNDO.

DEFINE VARIABLE F-deliv-type-name AS CHARACTER FORMAT "X(50)"
     LABEL "Название типа доставки"
     VIEW-AS FILL-IN
     SIZE 63 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-delivery-type-subject,
      tt-delivery-subject SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Hist AT ROW 1 COL 51
     B-Help AT ROW 1 COL 61
     tt-delivery-type-subject.deliv-type-code AT ROW 3 COL 34 COLON-ALIGNED
          LABEL "Внутр.код типа доставки"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     B-deliv-type AT ROW 3 COL 47.5
     F-deliv-type-name AT ROW 4.25 COL 34 COLON-ALIGNED
     tt-delivery-type-subject.deliv-subj-code AT ROW 5.5 COL 34 COLON-ALIGNED
          LABEL "Вн.код субъекта доставки"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     B-deliv-subj AT ROW 5.5 COL 47.5
     F-deliv-subj-name AT ROW 6.75 COL 34 COLON-ALIGNED
     tt-delivery-type-subject.des AT ROW 10 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 3.75
     "Описание" VIEW-AS TEXT
          SIZE 16 BY 1 AT ROW 8.75 COL 1.5
     SPACE(81.74) SKIP(4.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Тип доставки от субъекта"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_delivery-subject B "?" ? ub delivery-subject
      TABLE: locked_delivery-type B "?" ? ub delivery-type
      TABLE: locked_delivery-type-subject B "?" ? ub delivery-type-subject
      TABLE: tt-delivery-subject T "?" NO-UNDO ub delivery-subject
      TABLE: tt-delivery-type T "?" NO-UNDO ub delivery-type
      TABLE: tt-delivery-type-subject T "?" NO-UNDO ub delivery-type-subject
      TABLE: X_curr_clients B "?" ? ub clients
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-delivery-type-subject.deliv-subj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-delivery-type-subject.deliv-type-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN F-deliv-subj-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       F-deliv-subj-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN F-deliv-type-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       F-deliv-type-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-delivery-type-subject,Temp-Tables.tt-delivery-subject WHERE Temp-Tables.tt-delivery-type-subject ..."
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Тип доставки от субъекта*/
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-deliv-subj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-deliv-subj Dialog-Frame
ON CHOOSE OF B-deliv-subj IN FRAME Dialog-Frame /* Btn 1 */
DO:
   define variable v-rid-list as character no-undo.
   define variable v-sts as integer no-undo .
{ gbl/stdbtn.i }
if available locked_delivery-subject then
assign
v-rid-list = string(recid(locked_delivery-subject))
v-sts = locked_delivery-subject.sts
.
run ref/dlvsubjs.w (input parParentProc
              , p-curr-obj-type
              , p-curr-obj-code
              , "b-sel":U
              , {&all}
              , input-output v-sts
              , input-output v-rid-list ) no-error .

if v-rid-list <> "":U then do:
    FIND FIRST locked_delivery-subject WHERE
        recid( locked_delivery-subject ) = integer(entry(1, v-rid-list)) NO-LOCK .
    assign
    tt-delivery-type-subject.deliv-subj-code = locked_delivery-subject.deliv-subj-code
    f-deliv-subj-name = locked_delivery-subject.deliv-subj-name
.
    display
    tt-delivery-type-subject.deliv-subj-code
    f-deliv-subj-name
    with frame {&frame-name} .
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-deliv-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-deliv-type Dialog-Frame
ON CHOOSE OF B-deliv-type IN FRAME Dialog-Frame /* Btn 1 */
DO:
  define variable v-rid-list as character no-undo.
  define variable v-sts as integer no-undo .
{ gbl/stdbtn.i }
if available locked_delivery-type then
assign
v-rid-list = string(recid(locked_delivery-type))
v-sts = locked_delivery-type.sts
.
run ref/dlvtypes.w (input parParentProc
              , p-curr-obj-type
              , p-curr-obj-code
              , "b-sel":U
              , {&all}
              , input-output v-sts
              , input-output v-rid-list ) no-error .

if v-rid-list <> "":U then do:
    FIND FIRST locked_delivery-type WHERE
        recid( locked_delivery-type ) = integer(entry(1, v-rid-list)) NO-LOCK .
    assign
    tt-delivery-type-subject.deliv-type-code = locked_delivery-type.deliv-type-code
    f-deliv-type-name = locked_delivery-type.deliv-type-name
.
    display
    tt-delivery-type-subject.deliv-type-code
    f-deliv-type-name
    with frame {&frame-name} .
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
    run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Hist Dialog-Frame
ON CHOOSE OF B-Hist IN FRAME Dialog-Frame /* История */
DO:
  define variable v-rid-list as character no-undo.
    run ref/dlvctyss.w
                (
                 input parParentProc
                ,INPUT p-curr-obj-type
                ,INPUT p-curr-obj-code
                ,input "":U /*bttns*/
                ,input "one":U
                ,input locked_delivery-type-subject.deliv-type-code
                ,input locked_delivery-type-subject.deliv-subj-code
                ,input-output v-rid-list
                              )

 .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-delivery-type-subject.deliv-subj-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-delivery-type-subject.deliv-subj-code Dialog-Frame
ON LEAVE OF tt-delivery-type-subject.deliv-subj-code IN FRAME Dialog-Frame /* Вн.код субъекта доставки */
DO:
 assign
tt-delivery-type-subject.deliv-subj-code.
FIND FIRST locked_delivery-subject WHERE
         locked_delivery-subject.deliv-subj-code  = tt-delivery-type-subject.deliv-subj-code
 NO-LOCK NO-error.

if not available locked_delivery-subject then do:
  assign
  tt-delivery-type-subject.deliv-subj-code = ?
  f-deliv-subj-name = "":U
  .
    display
    tt-delivery-type-subject.deliv-subj-code
    f-deliv-subj-name
    with frame {&frame-name}.
    .
end.
else do:
    assign
    f-deliv-subj-name = locked_delivery-subject.deliv-subj-name
    .
    display
    tt-delivery-type-subject.deliv-subj-code
    f-deliv-subj-name
    with frame {&frame-name}.
    .
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-delivery-type-subject.deliv-type-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-delivery-type-subject.deliv-type-code Dialog-Frame
ON LEAVE OF tt-delivery-type-subject.deliv-type-code IN FRAME Dialog-Frame /* Внутр.код типа доставки */
DO:
  assign
tt-delivery-type-subject.deliv-type-code.
FIND FIRST locked_delivery-type WHERE
         locked_delivery-type.deliv-type-code  = tt-delivery-type-subject.deliv-type-code
 NO-LOCK NO-error.

if not available locked_delivery-type then do:
  assign
  tt-delivery-type-subject.deliv-type-code = ?
  f-deliv-type-name = "":U
  .
    display
    tt-delivery-type-subject.deliv-type-code
    f-deliv-type-name
    with frame {&frame-name}.
    .
end.
else do:
    assign
    f-deliv-type-name = locked_delivery-type.deliv-type-name
    .
    display
    tt-delivery-type-subject.deliv-type-code
    f-deliv-type-name
    with frame {&frame-name}.
    .
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
{ ref/tabhndmv.i v-tab-order }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 if p-mode  <> {&add-def}
 and p-mode <> {&update}
 and p-mode <> {&lookup}
 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
 end.
   find first X_curr_clients no-lock where
            X_curr_clients.obj-type = p-curr-obj-type
       AND X_curr_clients.obj-code = p-curr-obj-code no-error.
  if not available X_curr_clients then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-curr-obj-type p-curr-obj-code"
    p-curr-obj-type p-curr-obj-code
    view-as alert-box ERROR.
    return error .
  end.

 { gbl/curdbnum.i v-db-num }
IF v-db-num <> 0
AND (p-mode = {&add-def}
     OR p-mode = {&UPDATE} ) THEN DO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-mode" p-mode skip
    "Нельзя редактировать запись ТИП ДОСТАВКИ ОТ СУБЪЕКТОВ в УБД"
    view-as alert-box ERROR.
    return error .
END.
  for each tt-delivery-type:
    delete tt-delivery-type.
  end.
  for each tt-delivery-subject:
    delete tt-delivery-subject.
  end.

  for each tt-delivery-type-subject:
    delete tt-delivery-type-subject.
  end.

IF p-deliv-type-code <> 0  OR p-mode <> {&add-def} THEN DO:
    IF p-mode = {&add-def} OR p-mode = {&UPDATE}  THEN DO:
      FIND FIRST LOCKED_delivery-type EXCLUSIVE-LOCK WHERE
                LOCKED_delivery-type.deliv-type-code = p-deliv-type-code NO-ERROR.
    END.
    IF p-mode = {&LOOKUP} THEN DO:
        FIND FIRST LOCKED_delivery-type no-lock WHERE
                        LOCKED_delivery-type.deliv-type-code = p-deliv-type-code NO-ERROR.
   END.
   IF (p-mode = {&add-def}
    OR p-mode = {&update} )
    AND NOT AVAILABLE LOCKED_delivery-type  THEN DO:
        IF LOCKED(LOCKED_delivery-type) THEN DO:
            message
            vss-workfile vss-revision vss-description skip
             "Запись ТИП ДОСТАВКИ занята"
            view-as alert-box error .
            undo, return error.
        END.
   END.
    ELSE DO:
      IF NOT AVAILABLE LOCKED_delivery-type THEN DO:
            message
                vss-workfile vss-revision vss-description skip
                "Неверное значение параметра вызова p-deliv-type-code" p-deliv-type-code skip
                view-as alert-box ERROR.
                return error .

        END.
    END.
    CREATE tt-delivery-type.
    BUFFER-COPY LOCKED_delivery-type TO tt-delivery-type.
END.
IF p-deliv-subj-code <> 0
OR p-mode <> {&add-def} THEN DO:
    IF p-mode = {&add-def} OR p-mode = {&UPDATE}  THEN DO:
       FIND FIRST LOCKED_delivery-subject EXCLUSIVE-LOCK WHERE
                LOCKED_delivery-subject.deliv-subj-code = p-deliv-subj-code NO-ERROR.
    END.
    IF p-mode = {&LOOKUP}  THEN DO:
        FIND FIRST LOCKED_delivery-subject NO-LOCK WHERE
                LOCKED_delivery-subject.deliv-subj-code = p-deliv-subj-code NO-ERROR.
    END.
    IF (p-mode = {&add-def}
    OR p-mode = {&update} )
    AND NOT AVAILABLE LOCKED_delivery-subject  THEN DO:
        IF LOCKED(LOCKED_delivery-subject) THEN DO:
            message
            vss-workfile vss-revision vss-description skip
             "Запись СУБЪЕКТ ДОСТАВКИ занята"
            view-as alert-box error .
            undo, return error.
        END.
    END.
    ELSE DO:
        IF NOT AVAILABLE LOCKED_delivery-subject  THEN DO:
            message
            vss-workfile vss-revision vss-description skip
            "Неверное значение параметра вызова p-deliv-subj-code" p-deliv-subj-code skip
            view-as alert-box ERROR.
            return error .

        END.
    END.
    CREATE tt-delivery-subject.
    BUFFER-COPY LOCKED_delivery-subject TO tt-delivery-subject.
END.
if p-mode = {&update}
  or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:
      find first locked_delivery-type-subject EXclusive-lock where
                   recid(locked_delivery-type-subject) = p-doc-rec no-wait no-error.
      if locked locked_delivery-type-subject then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ТИП ДОСТАВКИ ОТ СУБЪЕКТА занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_delivery-type-subject no-lock where
                       recid(locked_delivery-type-subject) = p-doc-rec no-error .
      if not avail locked_delivery-type-subject then do:
        find first locked_delivery-type-subject no-lock where
                   locked_delivery-type-subject.deliv-type-code = p-deliv-type-code no-error .
      end.
    end.
    if not available locked_delivery-type-subject then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ТИП ДОСТАВКИ ОТ СУБЪЕКТА"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-delivery-type-subject.
    buffer-copy locked_delivery-type-subject to tt-delivery-type-subject.
   end.
   else do:
     create tt-delivery-type-subject.
     assign
     tt-delivery-type-subject.deliv-type-code = (IF p-mode = {&add-def} AND p-deliv-type-code <> 0
                                                 THEN p-deliv-type-code
                                                 ELSE tt-delivery-type-subject.deliv-type-code)
     tt-delivery-type-subject.deliv-subj-code = (IF p-mode = {&add-def} AND p-deliv-subj-code <> 0
                                                 THEN p-deliv-subj-code
                                                 ELSE tt-delivery-type-subject.deliv-type-code)
         .
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY F-deliv-type-name F-deliv-subj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-delivery-type-subject THEN
    DISPLAY tt-delivery-type-subject.deliv-type-code
          tt-delivery-type-subject.deliv-subj-code tt-delivery-type-subject.des
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Hist B-Help tt-delivery-type-subject.deliv-type-code
         B-deliv-type tt-delivery-type-subject.deliv-subj-code B-deliv-subj
         tt-delivery-type-subject.des
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyENable Dialog-Frame
PROCEDURE MyENable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
case p-mode:
  when {&add-def} then do:
    display
    (IF tt-delivery-type-subject.deliv-type-code <> 0
     THEN tt-delivery-type-subject.deliv-type-code
     ELSE ?) @ tt-delivery-type-subject.deliv-type-code
    (IF tt-delivery-type-subject.deliv-subj-code <> 0
     THEN tt-delivery-type-subject.deliv-subj-code
     ELSE ?) @ tt-delivery-type-subject.deliv-subj-code
    (if available locked_delivery-type
    then  locked_delivery-type.deliv-type-name
    else "":U ) @ f-deliv-type-name
    (if available locked_delivery-subject
    then  locked_delivery-subject.deliv-subj-name
    else "":U ) @ f-deliv-subj-name
    WITH FRAME Dialog-Frame.
  end.
  otherwise do:
    IF AVAILABLE tt-delivery-type-subject THEN
    DISPLAY
    tt-delivery-type-subject.deliv-type-code
    tt-delivery-type-subject.deliv-subj-code
    locked_delivery-type.deliv-type-name @ f-deliv-type-name
    locked_delivery-subject.deliv-subj-name @ f-deliv-subj-name
    tt-delivery-type-subject.des
    WITH FRAME Dialog-Frame.
  end.
END CASE.
if p-mode = {&lookup} then do:
assign
b-quit:label = "&Выход"
.
hide
b-exit in frame {&frame-name}.
end.


ENABLE
B-exit when p-mode <> {&lookup}
b-quit
B-Hist when p-mode <> {&add-def}
B-Help
tt-delivery-type-subject.des when p-mode <> {&lookup}
tt-delivery-type-subject.deliv-type-code when (p-mode = {&add-def} and p-deliv-type-code = 0)
tt-delivery-type-subject.deliv-subj-code when (p-mode = {&add-def} and p-deliv-subj-code = 0)
b-deliv-type when (p-mode = {&add-def} and p-deliv-type-code = 0)
b-deliv-subj when (p-mode = {&add-def} and p-deliv-subj-code = 0)
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Proc-save Dialog-Frame
PROCEDURE Proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if p-mode = {&lookup} then do:
    return error.
end.

if not available tt-delivery-type-subject then do:
    create tt-delivery-type-subject.
end.

assign
frame {&frame-name}
tt-delivery-type-subject.deliv-type-code
tt-delivery-type-subject.deliv-subj-code
tt-delivery-type-subject.des = tt-delivery-type-subject.des:SCREEN-VALUE
.
 run ref/dlvtysu1.p (
input-output p-doc-rec
,input p-mode
,input tt-delivery-type-subject.deliv-type-code
,input tt-delivery-type-subject.deliv-subj-code
,input tt-delivery-type-subject.des

)
no-error.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME