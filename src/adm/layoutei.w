&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_layout-elem FOR ub.layout-elem.
DEFINE TEMP-TABLE tt-layout-elem NO-UNDO LIKE ub.layout-elem.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма Редактирования элемента Раскладки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/26/08
Author: Bakhtadze Natalya
Creation date: 09/26/08

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT  PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT  PARAMETER p-mode AS CHARACTER NO-UNDO.
define input  parameter p-layout-type as character no-undo .
define input  parameter p-device-type as character no-undo .
define input  parameter p-mode-id as character no-undo .
define input  parameter p-widget-id as character no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма Редактирования элемента Раскладки".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/key-rec.i }
{ adm/cd-mode2.i def }

DEFINE VARIABLE v-param-num-list AS CHARACTER NO-UNDO.
define variable v-admin as logical no-undo .
DEFINE BUFFER buf_layout FOR ub.layout.
DEFINE BUFFER FIRST_layout FOR ub.layout.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-layout-elem

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define SELF-NAME Dialog-Frame
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-layout-elem WHERE TRUE SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY {&SELF-NAME} FOR EACH tt-layout-elem WHERE TRUE SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-layout-elem
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-layout-elem


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-layout-elem.layout-type ~
tt-layout-elem.elem-type tt-layout-elem.widget-type ~
tt-layout-elem.device-type tt-layout-elem.mode-id tt-layout-elem.widget-id ~
tt-layout-elem.des
&Scoped-define ENABLED-TABLES tt-layout-elem
&Scoped-define FIRST-ENABLED-TABLE tt-layout-elem
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help
&Scoped-Define DISPLAYED-FIELDS tt-layout-elem.layout-type ~
tt-layout-elem.elem-type tt-layout-elem.widget-type ~
tt-layout-elem.device-type tt-layout-elem.mode-id tt-layout-elem.widget-id ~
tt-layout-elem.des
&Scoped-define DISPLAYED-TABLES tt-layout-elem
&Scoped-define FIRST-DISPLAYED-TABLE tt-layout-elem


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
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-layout-elem SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     tt-layout-elem.layout-type AT ROW 2.07 COL 15 COLON-ALIGNED WIDGET-ID 14
          LABEL "Тип раскладки" FORMAT "x(255)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Item 1","Item 1"
          DROP-DOWN-LIST
          SIZE 35 BY 1
     tt-layout-elem.elem-type AT ROW 2.07 COL 54 NO-LABEL WIDGET-ID 74
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Item 1", 1,
"Item 2", 2
          SIZE 39.5 BY 1.07
     tt-layout-elem.widget-type AT ROW 3 COL 66 NO-LABEL WIDGET-ID 72
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Кнопка", "BUTTON":U
          SIZE 20.5 BY 1
     tt-layout-elem.device-type AT ROW 3.13 COL 15 COLON-ALIGNED WIDGET-ID 62
          LABEL "Тип устройства" FORMAT "x(16)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 35 BY 1
     tt-layout-elem.mode-id AT ROW 4 COL 15 COLON-ALIGNED WIDGET-ID 66
          LABEL "Режим" FORMAT "x(8)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Item 1","Item 1"
          DROP-DOWN-LIST
          SIZE 47.5 BY 1
     tt-layout-elem.widget-id AT ROW 5 COL 15 COLON-ALIGNED WIDGET-ID 68
          LABEL "ID элемента" FORMAT "x(12)"
          VIEW-AS FILL-IN
          SIZE 12.5 BY 1
     tt-layout-elem.des AT ROW 6 COL 15 COLON-ALIGNED WIDGET-ID 70
          LABEL "Описание" FORMAT "x(255)"
          VIEW-AS FILL-IN
          SIZE 81 BY 1
     SPACE(1.49) SKIP(0.82)
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
      TABLE: locked_layout-elem B "?" ? ub layout-elem
      TABLE: tt-layout-elem T "?" NO-UNDO ub layout-elem
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

/* SETTINGS FOR FILL-IN tt-layout-elem.des IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR COMBO-BOX tt-layout-elem.device-type IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR COMBO-BOX tt-layout-elem.layout-type IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR COMBO-BOX tt-layout-elem.mode-id IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-layout-elem.widget-id IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-layout-elem WHERE TRUE SHARE-LOCK.
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


&Scoped-define SELF-NAME tt-layout-elem.layout-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-layout-elem.layout-type Dialog-Frame
ON VALUE-CHANGED OF tt-layout-elem.layout-type IN FRAME Dialog-Frame /* Тип раскладки */
DO:
  assign
  tt-layout-elem.layout-type.
  CASE tt-layout-elem.layout-type:
    WHEN {&th-pos-keyboard}  THEN DO:
        ASSIGN
        tt-layout-elem.device-type:LIST-ITEMS = {&th-pos-device-keyboard-list}.
    END.
    WHEN {&th-pos-screen}  THEN DO:
        ASSIGN
        tt-layout-elem.device-type:LIST-ITEMS = {&th-pos-device-screen-list}.

    END.
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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if lookup('admin', p-mode) > 0 then do:
    v-admin = yes.
    p-mode = trim(replace(p-mode, 'admin', ''), {&comma-char}).
  end.
  IF p-mode = {&add-def} THEN DO:
    CREATE tt-layout-elem.
    if p-layout-type <> '' then do:
       assign
       tt-layout-elem.layout-type = p-layout-type
       .
    end.
    if p-device-type <> '' then do:
       assign
       tt-layout-elem.device-type = p-device-type
       .

    end.
    if p-mode-id <> '' then do:
       assign
       tt-layout-elem.mode-id = p-mode-id
       .

    end.
    assign
    tt-layout-elem.widget-type = "BUTTON".
  END.
  else do:

    IF p-mode = {&UPDATE} THEN DO:
      FIND FIRST LOCKED_layout-elem EXCLUSIVE-LOCK WHERE
                LOCKED_layout-elem.layout-type = p-layout-type
            and LOCKED_layout-elem.device-type = p-device-type
            and LOCKED_layout-elem.mode-id = p-mode-id
            and LOCKED_layout-elem.widget-id = p-widget-id

                .
    END.
    IF p-mode = {&LOOKUP} THEN DO:
      FIND FIRST LOCKED_layout-elem no-lock WHERE
                LOCKED_layout-elem.layout-type = p-layout-type
            and LOCKED_layout-elem.device-type = p-device-type
            and LOCKED_layout-elem.mode-id = p-mode-id
            and LOCKED_layout-elem.widget-id = p-widget-id.

    END.
    create tt-layout-elem.
    buffer-copy locked_layout-elem to tt-layout-elem.
  end.
  RUN Myenable in this-procedure .
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
  IF AVAILABLE tt-layout-elem THEN
    DISPLAY tt-layout-elem.layout-type tt-layout-elem.elem-type
          tt-layout-elem.widget-type tt-layout-elem.device-type
          tt-layout-elem.mode-id tt-layout-elem.widget-id tt-layout-elem.des
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help tt-layout-elem.layout-type
         tt-layout-elem.elem-type tt-layout-elem.widget-type
         tt-layout-elem.device-type tt-layout-elem.mode-id
         tt-layout-elem.widget-id tt-layout-elem.des
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
define buffer buf_wi-mode for ub.wi-mode.

DO v-ii = 1 TO NUM-ENTRIES({&lelem-type-codes}):
   v-list-items = v-list-items  + (IF v-ii = 1 THEN '' ELSE {&comma-char}) +
                  ENTRY(v-ii, {&lelem-type-codes-full}) + {&comma-char} +
                  ENTRY(v-ii, {&lelem-type-codes}).
END.
tt-layout-elem.elem-type:RADIO-BUTTONS IN FRAME {&FRAME-NAME} = V-LIST-ITEMS.
v-list-items = ''.
DO v-ii = 1 TO NUM-ENTRIES({&layout-type-list}):
   v-list-items = v-list-items  + (IF v-ii = 1 THEN '' ELSE {&comma-char}) +
                  ENTRY(v-ii, {&layout-type-list-full}) + {&comma-char} +
                  ENTRY(v-ii, {&layout-type-list}).
END.
ASSIGN
tt-layout-elem.layout-type:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = v-list-items .
v-list-items = {&comma-char}.
assign
tt-layout-elem.mode-id:list-item-pairs in frame {&frame-name} = v-list-items.
for each buf_wi-mode NO-LOCK WHERE buf_wi-mode.mode-type = {&wi-mode-ibs-th-pos}
:
  tt-layout-elem.mode-id:add-last ( substitute("&1 (&2)", string(buf_wi-mode.mode-name, "X(35)"), buf_wi-mode.mode-id), buf_wi-mode.mode-id).
end.
tt-layout-elem.mode-id:delete(1).
if available tt-layout-elem
and tt-layout-elem.layout-type <> ''
then do:
  APPLY "VALUE-CHANGED" TO tt-layout-elem.layout-type.
end.

IF AVAILABLE tt-layout-elem THEN
DISPLAY
tt-layout-elem.layout-type
tt-layout-elem.device-type
tt-layout-elem.mode-id
tt-layout-elem.widget-id
tt-layout-elem.des
tt-layout-elem.widget-type
tt-layout-elem.elem-type
wITH FRAME {&frame-name} .
ENABLE
B-exit  when p-mode <> {&lookup}
b-quit
B-Help
tt-layout-elem.layout-type WHEN p-mode = {&add-def}
tt-layout-elem.device-type WHEN p-mode = {&add-def}
tt-layout-elem.mode-id WHEN p-mode = {&add-def}
tt-layout-elem.widget-id WHEN p-mode = {&add-def}
tt-layout-elem.elem-type WHEN p-mode <> {&lookup}
tt-layout-elem.des
WITH FRAME {&frame-name} .
if p-mode = {&lookup} then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
  hide b-exit in frame {&frame-name} .
end.
VIEW FRAME {&frame-name} .
if tt-layout-elem.device-type = '' then do:
  APPLY "VALUE-CHANGED" TO tt-layout-elem.layout-type.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS recID  NO-UNDO.
IF p-mode = {&LOOKUP} THEN DO:
    RETURN.
END.
v-rec = recid(locked_layout-elem).
ASSIGN
FRAME {&FRAME-NAME}
tt-layout-elem.layout-type
tt-layout-elem.device-type
tt-layout-elem.mode-id
tt-layout-elem.widget-id
tt-layout-elem.des
tt-layout-elem.widget-type
tt-layout-elem.elem-type

.
run adm/layoute1.p ( INPUT p-mode
                ,INPUT NO /*p-silent*/
                ,INPUT-OUTPUT v-rec
                ,INPUT tt-layout-elem.layout-type
                ,INPUT tt-layout-elem.device-type
                ,INPUT tt-layout-elem.mode-id
                ,INPUT tt-layout-elem.widget-id
                ,INPUT tt-layout-elem.widget-type
                ,INPUT tt-layout-elem.elem-type
                ,INPUT tt-layout-elem.des
                ) no-error.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
p-rec = v-rec.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
