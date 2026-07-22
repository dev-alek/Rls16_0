&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_condition-keeping FOR ub.condition-keeping.
DEFINE BUFFER locked_delivery-type FOR ub.delivery-type.
DEFINE BUFFER locked_deliv-type-cond-keep FOR ub.deliv-type-cond-keep.
DEFINE TEMP-TABLE tt-condition-keeping NO-UNDO LIKE ub.condition-keeping.
DEFINE TEMP-TABLE tt-delivery-type NO-UNDO LIKE ub.delivery-type.
DEFINE TEMP-TABLE tt-deliv-type-cond-keep NO-UNDO LIKE ub.deliv-type-cond-keep.
DEFINE BUFFER X_curr_clients FOR ub.clients.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка редактирования ВОЗМОЖНОСТИ ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/22/04
Author: Bakhtadze Natalya
Creation date: 03/22/04

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
DEFINE INPUT PARAMETER p-deliv-type-code LIKE ub.deliv-type-cond-keep.deliv-type-code NO-UNDO.
DEFINE INPUT PARAMETER p-cond-keep-code LIKE ub.deliv-type-cond-keep.cond-keep-code NO-UNDO.
define input-output parameter p-doc-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования ВОЗМОЖНОСТИ ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }


define variable v-tab-order as character no-undo.
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-last-code like ub.deliv-type-cond-keep.deliv-type-code no-undo.
&scop tab-order   "B-exit,b-quit,b-hist,b-help,deliv-type-code,b-deliv-type,cond-keep-code,b-cond-keep,des"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-deliv-type-cond-keep tt-condition-keeping

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame ~
tt-deliv-type-cond-keep.deliv-type-code ~
tt-deliv-type-cond-keep.cond-keep-code tt-deliv-type-cond-keep.des
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-deliv-type-cond-keep.deliv-type-code ~
tt-deliv-type-cond-keep.cond-keep-code tt-deliv-type-cond-keep.des
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame ~
tt-deliv-type-cond-keep
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-deliv-type-cond-keep
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-deliv-type-cond-keep SHARE-LOCK, ~
      EACH tt-condition-keeping WHERE TRUE /* Join to tt-deliv-type-cond-keep incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-deliv-type-cond-keep SHARE-LOCK, ~
      EACH tt-condition-keeping WHERE TRUE /* Join to tt-deliv-type-cond-keep incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-deliv-type-cond-keep ~
tt-condition-keeping
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-deliv-type-cond-keep
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame tt-condition-keeping


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-deliv-type-cond-keep.deliv-type-code ~
tt-deliv-type-cond-keep.cond-keep-code tt-deliv-type-cond-keep.des
&Scoped-define ENABLED-TABLES tt-deliv-type-cond-keep
&Scoped-define FIRST-ENABLED-TABLE tt-deliv-type-cond-keep
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Hist B-Help B-deliv-type ~
b-cond-keep
&Scoped-Define DISPLAYED-FIELDS tt-deliv-type-cond-keep.deliv-type-code ~
tt-deliv-type-cond-keep.cond-keep-code tt-deliv-type-cond-keep.des
&Scoped-define DISPLAYED-TABLES tt-deliv-type-cond-keep
&Scoped-define FIRST-DISPLAYED-TABLE tt-deliv-type-cond-keep
&Scoped-Define DISPLAYED-OBJECTS F-deliv-type-name F-cond-keep-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cond-keep
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

DEFINE VARIABLE F-cond-keep-name AS CHARACTER FORMAT "X(50)"
     LABEL "Название условий хранения"
     VIEW-AS FILL-IN
     SIZE 63 BY 1 NO-UNDO.

DEFINE VARIABLE F-deliv-type-name AS CHARACTER FORMAT "X(50)"
     LABEL "Название типа доставки"
     VIEW-AS FILL-IN
     SIZE 63 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-deliv-type-cond-keep,
      tt-condition-keeping SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Hist AT ROW 1 COL 51
     B-Help AT ROW 1 COL 61
     tt-deliv-type-cond-keep.deliv-type-code AT ROW 3 COL 34 COLON-ALIGNED
          LABEL "Внутр.код типа доставки"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     B-deliv-type AT ROW 3 COL 47.5
     F-deliv-type-name AT ROW 4.25 COL 34 COLON-ALIGNED
     tt-deliv-type-cond-keep.cond-keep-code AT ROW 5.5 COL 34 COLON-ALIGNED
          LABEL "Вн.код условий хранения"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     b-cond-keep AT ROW 5.5 COL 47.5
     F-cond-keep-name AT ROW 6.75 COL 34 COLON-ALIGNED
     tt-deliv-type-cond-keep.des AT ROW 10 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 3.75
     "Описание" VIEW-AS TEXT
          SIZE 16 BY 1 AT ROW 8.75 COL 1.5
     SPACE(81.74) SKIP(4.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Возможности доставки по условиям хранения"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_condition-keeping B "?" ? ub condition-keeping
      TABLE: locked_delivery-type B "?" ? ub delivery-type
      TABLE: locked_deliv-type-cond-keep B "?" ? ub deliv-type-cond-keep
      TABLE: tt-condition-keeping T "?" NO-UNDO ub condition-keeping
      TABLE: tt-delivery-type T "?" NO-UNDO ub delivery-type
      TABLE: tt-deliv-type-cond-keep T "?" NO-UNDO ub deliv-type-cond-keep
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

/* SETTINGS FOR FILL-IN tt-deliv-type-cond-keep.cond-keep-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-deliv-type-cond-keep.deliv-type-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN F-cond-keep-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       F-cond-keep-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN F-deliv-type-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       F-deliv-type-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-deliv-type-cond-keep,Temp-Tables.tt-condition-keeping WHERE Temp-Tables.tt-deliv-type-cond-keep ..."
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Тип доставки */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cond-keep
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cond-keep Dialog-Frame
ON CHOOSE OF b-cond-keep IN FRAME Dialog-Frame /* Btn 1 */
DO:
   define variable v-rid-list as character no-undo.
   define variable v-sts as integer no-undo.
{ gbl/stdbtn.i }
if available locked_condition-keeping then
assign
v-rid-list = string(recid(locked_condition-keeping))
v-sts = locked_condition-keeping.sts
.
run ref/cndkeeps.w (input parParentProc
              , p-curr-obj-type
              , p-curr-obj-code
              , "b-sel":U
              , {&all}
              , input-output v-sts
              , input-output v-rid-list ) no-error .

if v-rid-list <> "":U then do:
    FIND FIRST locked_condition-keeping WHERE
        recid( locked_condition-keeping ) = integer(entry(1, v-rid-list)) NO-LOCK .
    assign
    tt-deliv-type-cond-keep.cond-keep-code = locked_condition-keeping.cond-keep-code
    f-cond-keep-name = locked_condition-keeping.cond-keep-name
.
    display
    tt-deliv-type-cond-keep.cond-keep-code
    f-cond-keep-name
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
v-sts   = locked_delivery-type.sts
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
    tt-deliv-type-cond-keep.deliv-type-code = locked_delivery-type.deliv-type-code
    f-deliv-type-name = locked_delivery-type.deliv-type-name
.
    display
    tt-deliv-type-cond-keep.deliv-type-code
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
    run ref/dlvctcns.w
                (
                 input parParentProc
                ,INPUT p-curr-obj-type
                ,INPUT p-curr-obj-code
                ,input "":U /*bttns*/
                ,input "one":U
                ,input locked_deliv-type-cond-keep.deliv-type-code
                ,input locked_deliv-type-cond-keep.cond-keep-code
                ,input-output v-rid-list
                              )

 .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-deliv-type-cond-keep.cond-keep-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-deliv-type-cond-keep.cond-keep-code Dialog-Frame
ON LEAVE OF tt-deliv-type-cond-keep.cond-keep-code IN FRAME Dialog-Frame /* Вн.код субъекта доставки */
DO:
 assign
tt-deliv-type-cond-keep.cond-keep-code.
FIND FIRST locked_condition-keeping WHERE
         locked_condition-keeping.cond-keep-code  = tt-deliv-type-cond-keep.cond-keep-code
 NO-LOCK NO-error.

if not available locked_condition-keeping then do:
  assign
  tt-deliv-type-cond-keep.cond-keep-code = ?
  f-cond-keep-name = "":U
  .
    display
    tt-deliv-type-cond-keep.cond-keep-code
    f-cond-keep-name
    with frame {&frame-name}.
    .
end.
else do:
    assign
    f-cond-keep-name = locked_condition-keeping.cond-keep-name
    .
    display
    tt-deliv-type-cond-keep.cond-keep-code
    f-cond-keep-name
    with frame {&frame-name}.
    .
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-deliv-type-cond-keep.deliv-type-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-deliv-type-cond-keep.deliv-type-code Dialog-Frame
ON LEAVE OF tt-deliv-type-cond-keep.deliv-type-code IN FRAME Dialog-Frame /* Внутр.код типа доставки */
DO:
  assign
tt-deliv-type-cond-keep.deliv-type-code.
FIND FIRST locked_delivery-type WHERE
         locked_delivery-type.deliv-type-code  = tt-deliv-type-cond-keep.deliv-type-code
 NO-LOCK NO-error.

if not available locked_delivery-type then do:
  assign
  tt-deliv-type-cond-keep.deliv-type-code = ?
  f-deliv-type-name = "":U
  .
    display
    tt-deliv-type-cond-keep.deliv-type-code
    f-deliv-type-name
    with frame {&frame-name}.
    .
end.
else do:
    assign
    f-deliv-type-name = locked_delivery-type.deliv-type-name
    .
    display
    tt-deliv-type-cond-keep.deliv-type-code
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
  for each tt-condition-keeping:
    delete tt-condition-keeping.
  end.

  for each tt-deliv-type-cond-keep:
    delete tt-deliv-type-cond-keep.
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
IF p-cond-keep-code <> 0
OR p-mode <> {&add-def} THEN DO:
    IF p-mode = {&add-def} OR p-mode = {&UPDATE}  THEN DO:
       FIND FIRST LOCKED_condition-keeping EXCLUSIVE-LOCK WHERE
                LOCKED_condition-keeping.cond-keep-code = p-cond-keep-code NO-ERROR.
    END.
    IF p-mode = {&LOOKUP}  THEN DO:
        FIND FIRST LOCKED_condition-keeping NO-LOCK WHERE
                LOCKED_condition-keeping.cond-keep-code = p-cond-keep-code NO-ERROR.
    END.
    IF (p-mode = {&add-def}
    OR p-mode = {&update} )
    AND NOT AVAILABLE LOCKED_condition-keeping  THEN DO:
        IF LOCKED(LOCKED_condition-keeping) THEN DO:
            message
            vss-workfile vss-revision vss-description skip
             "Запись УСЛОВИЯ ХРАНЕНИЯ занята"
            view-as alert-box error .
            undo, return error.
        END.
    END.
    ELSE DO:
        IF NOT AVAILABLE LOCKED_condition-keeping  THEN DO:
            message
            vss-workfile vss-revision vss-description skip
            "Неверное значение параметра вызова p-cond-keep-code" p-cond-keep-code skip
            view-as alert-box ERROR.
            return error .

        END.
    END.
    CREATE tt-condition-keeping.
    BUFFER-COPY LOCKED_condition-keeping TO tt-condition-keeping.
END.
if p-mode = {&update}
  or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:
      find first locked_deliv-type-cond-keep EXclusive-lock where
                   recid(locked_deliv-type-cond-keep) = p-doc-rec no-wait no-error.
      if locked locked_deliv-type-cond-keep then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ВОЗМОЖНОСТЬ ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_deliv-type-cond-keep no-lock where
                       recid(locked_deliv-type-cond-keep) = p-doc-rec no-error .
      if not avail locked_deliv-type-cond-keep then do:
        find first locked_deliv-type-cond-keep no-lock where
                   locked_deliv-type-cond-keep.deliv-type-code = p-deliv-type-code no-error .
      end.
    end.
    if not available locked_deliv-type-cond-keep then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ВОЗМОЖНОСТЬ ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-deliv-type-cond-keep.
    buffer-copy locked_deliv-type-cond-keep to tt-deliv-type-cond-keep.
   end.
   else do:
     create tt-deliv-type-cond-keep.
     assign
     tt-deliv-type-cond-keep.deliv-type-code = (IF p-mode = {&add-def} AND p-deliv-type-code <> 0
                                                 THEN p-deliv-type-code
                                                 ELSE tt-deliv-type-cond-keep.deliv-type-code)
     tt-deliv-type-cond-keep.cond-keep-code = (IF p-mode = {&add-def} AND p-cond-keep-code <> 0
                                                 THEN p-cond-keep-code
                                                 ELSE tt-deliv-type-cond-keep.deliv-type-code)
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
  DISPLAY F-deliv-type-name F-cond-keep-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-deliv-type-cond-keep THEN
    DISPLAY tt-deliv-type-cond-keep.deliv-type-code
          tt-deliv-type-cond-keep.cond-keep-code tt-deliv-type-cond-keep.des
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Hist B-Help tt-deliv-type-cond-keep.deliv-type-code
         B-deliv-type tt-deliv-type-cond-keep.cond-keep-code b-cond-keep
         tt-deliv-type-cond-keep.des
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
    (IF tt-deliv-type-cond-keep.deliv-type-code <> 0
     THEN tt-deliv-type-cond-keep.deliv-type-code
     ELSE ?) @ tt-deliv-type-cond-keep.deliv-type-code
    (IF tt-deliv-type-cond-keep.cond-keep-code <> 0
     THEN tt-deliv-type-cond-keep.cond-keep-code
     ELSE ?) @ tt-deliv-type-cond-keep.cond-keep-code
    (if available locked_delivery-type
    then  locked_delivery-type.deliv-type-name
    else "":U ) @ f-deliv-type-name
    (if available locked_condition-keeping
    then  locked_condition-keeping.cond-keep-name
    else "":U ) @ f-cond-keep-name
    WITH FRAME Dialog-Frame.
  end.
  otherwise do:
    IF AVAILABLE tt-deliv-type-cond-keep THEN
    DISPLAY
    tt-deliv-type-cond-keep.deliv-type-code
    tt-deliv-type-cond-keep.cond-keep-code
    locked_delivery-type.deliv-type-name @ f-deliv-type-name
    locked_condition-keeping.cond-keep-name @ f-cond-keep-name
    tt-deliv-type-cond-keep.des
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
tt-deliv-type-cond-keep.deliv-type-code when (p-mode = {&add-def} and p-deliv-type-code = 0)
tt-deliv-type-cond-keep.cond-keep-code when (p-mode = {&add-def} and p-cond-keep-code = 0)
tt-deliv-type-cond-keep.des when p-mode <> {&lookup}
b-deliv-type when (p-mode = {&add-def} and p-deliv-type-code = 0)
b-cond-keep when (p-mode = {&add-def} and p-cond-keep-code = 0)
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

if not available tt-deliv-type-cond-keep then do:
    create tt-deliv-type-cond-keep.
end.

assign
frame {&frame-name}
tt-deliv-type-cond-keep.deliv-type-code
tt-deliv-type-cond-keep.cond-keep-code
tt-deliv-type-cond-keep.des = tt-deliv-type-cond-keep.des:SCREEN-VALUE
.
 run ref/dlvtcnd1.p (
input-output p-doc-rec
,input p-mode
,input tt-deliv-type-cond-keep.deliv-type-code
,input tt-deliv-type-cond-keep.cond-keep-code
,input tt-deliv-type-cond-keep.des

)
no-error.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME