&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-ruledict-param NO-UNDO LIKE ub.ruledict-param.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка ruledict-param


Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-update-proc-handle as handle no-undo .
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-entry-id AS INTEGER NO-UNDO.
define input parameter p-entry-type as character no-undo .
DEFINE INPUT PARAMETER p-language AS character NO-UNDO.
DEFINE INPUT PARAMETER p-param-num AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка ruledict-param".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }

DEFINE BUFFER locked_ruledict-param FOR dictdb.ruledict-param.
DEFINE BUFFER last_ruledict-param FOR dictdb.ruledict-param.
DEFINE BUFFER locked_ruledict FOR ub.ruledict.
define variable v-entry-type as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-ruledict-param

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-ruledict-param.entry-id ~
tt-ruledict-param.param-num tt-ruledict-param.language ~
tt-ruledict-param.param-mode tt-ruledict-param.param-data-type ~
tt-ruledict-param.param-name tt-ruledict-param.param-label ~
tt-ruledict-param.init-value-character tt-ruledict-param.init-value-date ~
tt-ruledict-param.init-value-decimal tt-ruledict-param.init-value-integer ~
tt-ruledict-param.init-value-logical tt-ruledict-param.documentation
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-ruledict-param.entry-id tt-ruledict-param.param-num ~
tt-ruledict-param.language tt-ruledict-param.param-mode ~
tt-ruledict-param.param-data-type tt-ruledict-param.param-name ~
tt-ruledict-param.param-label tt-ruledict-param.init-value-character ~
tt-ruledict-param.init-value-date tt-ruledict-param.init-value-decimal ~
tt-ruledict-param.init-value-integer tt-ruledict-param.init-value-logical ~
tt-ruledict-param.documentation
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-ruledict-param
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-ruledict-param
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-ruledict-param SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-ruledict-param SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-ruledict-param
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-ruledict-param


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-ruledict-param.entry-id ~
tt-ruledict-param.param-num tt-ruledict-param.language ~
tt-ruledict-param.param-mode tt-ruledict-param.param-data-type ~
tt-ruledict-param.param-name tt-ruledict-param.param-label ~
tt-ruledict-param.init-value-character tt-ruledict-param.init-value-date ~
tt-ruledict-param.init-value-decimal tt-ruledict-param.init-value-integer ~
tt-ruledict-param.init-value-logical tt-ruledict-param.documentation
&Scoped-define ENABLED-TABLES tt-ruledict-param
&Scoped-define FIRST-ENABLED-TABLE tt-ruledict-param
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-lkp B-Help rs-list ~
t-read-only t-hidden cb-object-type t-printable t-temp t-container
&Scoped-Define DISPLAYED-FIELDS tt-ruledict-param.entry-id ~
tt-ruledict-param.param-num tt-ruledict-param.language ~
tt-ruledict-param.param-mode tt-ruledict-param.param-data-type ~
tt-ruledict-param.param-name tt-ruledict-param.param-label ~
tt-ruledict-param.init-value-character tt-ruledict-param.init-value-date ~
tt-ruledict-param.init-value-decimal tt-ruledict-param.init-value-integer ~
tt-ruledict-param.init-value-logical tt-ruledict-param.documentation
&Scoped-define DISPLAYED-TABLES tt-ruledict-param
&Scoped-define FIRST-DISPLAYED-TABLE tt-ruledict-param
&Scoped-Define DISPLAYED-OBJECTS rs-list t-read-only t-hidden ~
cb-object-type t-printable t-temp t-container

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

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE cb-object-type AS CHARACTER
     LABEL "Тип Объект"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN
     SIZE 23 BY 1 NO-UNDO.

DEFINE VARIABLE rs-list AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "", "",
"LIST", "LIST",
"SORTED-LIST", "SORTED-LIST"
     SIZE 22.5 BY 1 NO-UNDO.

DEFINE VARIABLE t-container AS LOGICAL INITIAL no
     LABEL "CONTAINER"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 TOOLTIP "ХРАНИТСЯ В КОНТЕЙНЕРЕ ПРОЦЕССОВ" NO-UNDO.

DEFINE VARIABLE t-hidden AS LOGICAL INITIAL no
     LABEL "HIDDEN"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 TOOLTIP "Недоступен для задания и нигде не выводится" NO-UNDO.

DEFINE VARIABLE t-printable AS LOGICAL INITIAL no
     LABEL "PRINTABLE"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 TOOLTIP "Выводится при печати параметров в машине отчетов" NO-UNDO.

DEFINE VARIABLE t-read-only AS LOGICAL INITIAL no
     LABEL "READ-ONLY"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE t-temp AS LOGICAL INITIAL no
     LABEL "TEMP"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 TOOLTIP "Выводится при печати параметров в машине отчетов" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-ruledict-param SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     tt-ruledict-param.entry-id AT ROW 1 COL 32 COLON-ALIGNED WIDGET-ID 2
          LABEL "ID термина"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          FGCOLOR 4
     tt-ruledict-param.param-num AT ROW 1 COL 56 COLON-ALIGNED WIDGET-ID 38
          LABEL "№ параметра"
          VIEW-AS FILL-IN
          SIZE 12 BY 1.07
          FGCOLOR 4
     tt-ruledict-param.language AT ROW 1 COL 71 NO-LABEL WIDGET-ID 40
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "ABL", "ABL":U
          SIZE 8.5 BY 1
     b-lkp AT ROW 1 COL 80.5 WIDGET-ID 48
     B-Help AT ROW 1 COL 95
     rs-list AT ROW 2 COL 77 NO-LABEL WIDGET-ID 56
     tt-ruledict-param.param-mode AT ROW 2.87 COL 15 COLON-ALIGNED WIDGET-ID 18
          LABEL "Мода параметра" FORMAT "x(30)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 24.5 BY 1
     tt-ruledict-param.param-data-type AT ROW 2.87 COL 52 COLON-ALIGNED WIDGET-ID 20
          LABEL "Тип данных" FORMAT "X(20)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 23 BY 1
     t-read-only AT ROW 3 COL 80.5 WIDGET-ID 52
     t-hidden AT ROW 4 COL 80.5 WIDGET-ID 54
     cb-object-type AT ROW 4.2 COL 52 COLON-ALIGNED WIDGET-ID 42
     t-printable AT ROW 5 COL 80.5 WIDGET-ID 60
     tt-ruledict-param.param-name AT ROW 5.53 COL 15 COLON-ALIGNED WIDGET-ID 16
          LABEL "Имя параметра"
          VIEW-AS FILL-IN
          SIZE 60 BY 1
     t-temp AT ROW 6 COL 80.5 WIDGET-ID 62
     tt-ruledict-param.param-label AT ROW 6.87 COL 15 COLON-ALIGNED WIDGET-ID 22
          LABEL "Лейбл" FORMAT "x(255)"
          VIEW-AS FILL-IN
          SIZE 76.5 BY 1
     tt-ruledict-param.init-value-character AT ROW 8.2 COL 15 COLON-ALIGNED WIDGET-ID 24
          LABEL "Нач.знач." FORMAT "X(255)"
          VIEW-AS FILL-IN
          SIZE 76.5 BY 1
     tt-ruledict-param.init-value-date AT ROW 9.53 COL 15 COLON-ALIGNED WIDGET-ID 26
          LABEL "Нач.знач."
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     t-container AT ROW 9.53 COL 80.5 WIDGET-ID 64
     tt-ruledict-param.init-value-decimal AT ROW 10.87 COL 15 COLON-ALIGNED WIDGET-ID 28
          LABEL "Нач.знач."
          VIEW-AS FILL-IN
          SIZE 28.5 BY 1
     tt-ruledict-param.init-value-integer AT ROW 12.2 COL 15 COLON-ALIGNED WIDGET-ID 30
          LABEL "Нач.знач."
          VIEW-AS FILL-IN
          SIZE 28.5 BY 1
     tt-ruledict-param.init-value-logical AT ROW 13.53 COL 17 WIDGET-ID 34
          LABEL "Нач.знач."
          VIEW-AS TOGGLE-BOX
          SIZE 23.5 BY .8
     tt-ruledict-param.documentation AT ROW 15.13 COL 1 NO-LABEL WIDGET-ID 12
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 7.63
     "Описание" VIEW-AS TEXT
          SIZE 14.5 BY .77 AT ROW 14.07 COL 1.5 WIDGET-ID 14
     SPACE(83.50) SKIP(8.40)
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
      TABLE: tt-ruledict-param T "?" NO-UNDO ub ruledict-param
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

/* SETTINGS FOR FILL-IN tt-ruledict-param.entry-id IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-ruledict-param.init-value-character IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-ruledict-param.init-value-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-ruledict-param.init-value-decimal IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-ruledict-param.init-value-integer IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-ruledict-param.init-value-logical IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX tt-ruledict-param.param-data-type IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-ruledict-param.param-label IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR COMBO-BOX tt-ruledict-param.param-mode IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-ruledict-param.param-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-ruledict-param.param-num IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-ruledict-param"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
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


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
define variable v-longchar as longchar no-undo .
define variable v-ok as logical no-undo .
DEFINE BUFFER buf_clob-data FOR ub.clob-data.
DEFINE BUFFER buf_clob-bind FOR ub.clob-bind.
FOR first buf_clob-data NO-LOCK where
         buf_clob-data.db-num = 0
  AND buf_clob-data.file-name = tt-ruledict-param.init-value-character
 ,
FIRST  buf_clob-bind NO-LOCK where
   buf_clob-bind.resource-type = {&lob-res-gate}
AND buf_clob-bind.db-num = buf_clob-data.db-num
AND buf_clob-data.int64-id = buf_clob-bind.int64-id:
    LEAVE .
END.

v-longchar = buf_clob-data.cdata.
run gbl/d-longchar.w (
                       input ? /*r h-callback  */
                      ,input (
                                'title=':u + "XSD-схема" + '\':u
                              + 'Editor_row=2\':u
                              + 'Editor_col=1\':u
                              + 'Editor_width=96\':u
                              + 'Editor_height=15\':u
                              + 'readonly=yes\':u)
                      ,input-output v-longchar
                      ,output v-ok ) no-error .
assign
v-longchar = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-ruledict-param.param-data-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-ruledict-param.param-data-type Dialog-Frame
ON VALUE-CHANGED OF tt-ruledict-param.param-data-type IN FRAME Dialog-Frame /* Тип данных */
DO:
  ASSIGN
  tt-ruledict-param.param-data-type.
  RUN switch-data-type IN THIS-PROCEDURE .
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
if valid-handle(p-update-proc-handle) then do:
  run fill-ruledict-param in p-update-proc-handle ( input buffer tt-ruledict-param:handle
                                                   ,input p-mode
                                                   ) no-error.
  if error-status:error then do:
    MESSAGE
    substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    VIEW-AS ALERT-BOX ERROR.
    undo main-block, return error.
  end.
 v-entry-type = p-entry-type.
end.
else do:
  IF p-entry-id = 0 THEN DO:
    MESSAGE "Не задан ID термина в словаре"
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
end.
IF p-mode = {&add-def} THEN DO:
  /*заблокируем*/
  FIND FIRST locked_ruledict EXCLUSIVE-LOCK WHERE
          LOCKED_ruledict.entry-id = p-entry-id .
  CREATE tt-ruledict-param.
  FIND LAST LAST_ruledict-param NO-LOCK WHERE
          last_ruledict-param.entry-id = p-entry-id
      /*AND last_ruledict-param.language = p-language*/  NO-ERROR.
  ASSIGN
  tt-ruledict-param.param-num = (IF AVAILABLE LAST_ruledict-param
                                THEN LAST_ruledict-param.param-num + 1
                                ELSE 1)
  tt-ruledict-param.entry-id = p-entry-id
  .
END.
else do:
  IF p-mode = {&UPDATE} THEN DO:
      FIND FIRST locked_ruledict EXCLUSIVE-LOCK WHERE
              LOCKED_ruledict.entry-id = p-entry-id .
      FIND FIRST locked_ruledict-param EXCLUSIVE-LOCK WHERE
              LOCKED_ruledict-param.entry-id = p-entry-id
          AND LOCKED_ruledict-param.LANGUAGE = p-language
          AND LOCKED_ruledict-param.param-num = p-param-num.
  END.
  IF p-mode = {&LOOKUP} THEN DO:
      FIND FIRST locked_ruledict no-lock WHERE
              LOCKED_ruledict.entry-id = p-entry-id
          .
      FIND FIRST locked_ruledict-param no-LOCK WHERE
              LOCKED_ruledict-param.entry-id = p-entry-id
          AND LOCKED_ruledict-param.LANGUAGE = p-language
          AND LOCKED_ruledict-param.param-num = p-param-num.

  END.
end.
if not valid-handle(p-update-proc-handle) then do:
  create tt-ruledict-param.
  buffer-copy locked_ruledict-param to tt-ruledict-param.
  v-entry-type = locked_ruledict.entry-type.
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY rs-list t-read-only t-hidden cb-object-type t-printable t-temp
          t-container
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-ruledict-param THEN
    DISPLAY tt-ruledict-param.entry-id tt-ruledict-param.param-num
          tt-ruledict-param.language tt-ruledict-param.param-mode
          tt-ruledict-param.param-data-type tt-ruledict-param.param-name
          tt-ruledict-param.param-label tt-ruledict-param.init-value-character
          tt-ruledict-param.init-value-date tt-ruledict-param.init-value-decimal
          tt-ruledict-param.init-value-integer
          tt-ruledict-param.init-value-logical tt-ruledict-param.documentation
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit tt-ruledict-param.entry-id tt-ruledict-param.param-num
         tt-ruledict-param.language b-lkp B-Help rs-list
         tt-ruledict-param.param-mode tt-ruledict-param.param-data-type
         t-read-only t-hidden cb-object-type t-printable
         tt-ruledict-param.param-name t-temp tt-ruledict-param.param-label
         tt-ruledict-param.init-value-character
         tt-ruledict-param.init-value-date t-container
         tt-ruledict-param.init-value-decimal
         tt-ruledict-param.init-value-integer
         tt-ruledict-param.init-value-logical tt-ruledict-param.documentation
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
frame {&frame-name} :title = substitute("Параметр &1 термина &2 тип термина &3", tt-ruledict-param.param-num, locked_ruledict.script-al, locked_ruledict.entry-type)
tt-ruledict-param.param-data-type:LIST-ITEMS IN FRAME {&FRAME-NAME} = {&ABL-simple-datatype-list} + {&comma-char} + {&abl-datatype-longchar}
tt-ruledict-param.param-mode:LIST-ITEMS IN FRAME {&FRAME-NAME} = {&script-parmode-list}
cb-object-type:LIST-ITEMS IN FRAME {&FRAME-NAME} = {&comma-char} + {&r-b} +
                                                   {&comma-char} + {&period-type} +
                                                   {&comma-char} + {&output-type} +
                                                   {&comma-char} + {&table_dis-rule} +
                                                   {&comma-char} + {&table_prop-ref} +
                                                   {&comma-char} + {&table_clients} +
                                                   {&comma-char} + {&table_clients} + "_null" +
                                                   {&comma-char} + {&table_sysconf} +
                                                   {&comma-char} + {&table_cli-grp} +
                                                   {&comma-char} + {&table_shop} +
                                                   {&comma-char} + {&table_ext-system} +
                                                   {&comma-char} + {&calc-point-discnt-role-list} +
                                                   {&comma-char} + {&table_goods} + "_null" +
                                                   {&comma-char} + {&discnt-v-type-manual} +
                                                   {&comma-char} + {&table_cash-pay} + "_null" +
                                                   {&comma-char} + {&table_dis-card} + "_null" +
                                                   {&comma-char} + {&table_chk-doc} + "_wth-type_null" +
                                                   {&comma-char} + {&table_chk-doc} + "_wth-type" +
                                                   {&comma-char} + "xsd" +
                                                   {&comma-char} + "sub-type" +
                                                   {&comma-char} + "output-type" +
                                                   {&comma-char} + "dataset" +
                                                   {&comma-char} + "id"
cb-object-type = tt-ruledict-param.param-2-data-type
rs-list = (if lookup("LIST", tt-ruledict-param.param-3-data-type) > 0 then "LIST" else rs-list)
rs-list = (if lookup("SORTED-LIST", tt-ruledict-param.param-3-data-type) > 0 then "SORTED-LIST" else rs-list)
t-READ-ONLY = lookup("READ-ONLY", tt-ruledict-param.param-3-data-type) > 0
t-hidden = lookup("hidden", tt-ruledict-param.param-3-data-type) > 0
t-printable = lookup("printable", tt-ruledict-param.param-3-data-type) > 0
t-temp = lookup("temp", tt-ruledict-param.param-3-data-type) > 0
t-container = lookup("container", tt-ruledict-param.param-3-data-type) > 0
.

IF AVAILABLE tt-ruledict-param THEN
DISPLAY
tt-ruledict-param.entry-id
tt-ruledict-param.param-mode
tt-ruledict-param.param-data-type
tt-ruledict-param.LANGUAGE
tt-ruledict-param.param-num
tt-ruledict-param.param-name
tt-ruledict-param.param-label
tt-ruledict-param.init-value-character WHEN tt-ruledict-param.param-data-type = {&abl-datatype-character}
tt-ruledict-param.init-value-date WHEN tt-ruledict-param.param-data-type = {&abl-datatype-date}
tt-ruledict-param.init-value-decimal WHEN tt-ruledict-param.param-data-type = {&abl-datatype-decimal}
tt-ruledict-param.init-value-integer WHEN tt-ruledict-param.param-data-type = {&abl-datatype-integer}
tt-ruledict-param.init-value-logical WHEN tt-ruledict-param.param-data-type = {&abl-datatype-logical}
tt-ruledict-param.documentation
cb-object-type
rs-list
t-read-only
t-hidden
t-printable
t-temp
t-container
WITH FRAME {&frame-name} .
ENABLE
B-exit  when p-mode <> {&lookup}
b-quit
B-Help
tt-ruledict-param.param-mode when p-mode <> {&lookup}
tt-ruledict-param.param-data-type when p-mode <> {&lookup}
tt-ruledict-param.param-name       when p-mode <> {&lookup}
tt-ruledict-param.param-label when p-mode <> {&lookup}
tt-ruledict-param.documentation
cb-object-type when p-mode <> {&lookup}
rs-list when p-mode <> {&lookup}
t-read-only when p-mode <> {&lookup}
t-hidden when p-mode <> {&lookup}
t-printable when p-mode <> {&lookup}
t-temp when p-mode <> {&lookup}
t-container when p-mode <> {&lookup}
b-lkp WHEN p-mode = {&LOOKUP} AND tt-ruledict-param.param-2-data-type = "xsd"
WITH FRAME {&frame-name} .
IF NOT (v-entry-type = {&rdict-etype-prop-script}
        or
        v-entry-type = {&rdict-etype-rule}
        or
        v-entry-type = {&rdict-etype-rule-profile}
        )
        THEN DO:
 HIDE
 cb-object-type
 IN FRAME {&FRAME-NAME}.
END.
else do:

end.
if p-mode = {&lookup} then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  tt-ruledict-param.documentation :read-only in frame {&frame-name} = yes
  .
  hide b-exit in frame {&frame-name} .
end.

VIEW FRAME {&frame-name} .
RUN switch-data-type IN THIS-PROCEDURE .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS recID  NO-UNDO.
define variable v-param-3-data-type as character no-undo.
IF p-mode = {&LOOKUP} THEN DO:
    RETURN.
END.
ASSIGN
FRAME {&FRAME-NAME}
tt-ruledict-param.entry-id
tt-ruledict-param.LANGUAGE
tt-ruledict-param.param-mode
tt-ruledict-param.param-num
tt-ruledict-param.param-name
tt-ruledict-param.param-label
cb-object-type
rs-list
t-read-only
t-hidden
t-printable
t-temp
t-container
tt-ruledict-param.param-data-type
tt-ruledict-param.param-2-data-type = (if cb-object-type <> ? then cb-object-type else '')
v-param-3-data-type = (if rs-list = "" then "" else  rs-list)
v-param-3-data-type = v-param-3-data-type +
                      (if v-param-3-data-type = "" then "" else {&comma-char}) +
                      (if t-read-only then "READ-ONLY" else "")
v-param-3-data-type = v-param-3-data-type +
                      (if v-param-3-data-type = "" then "" else {&comma-char}) +
                      (if t-hidden then "HIDDEN" else "")
 v-param-3-data-type = v-param-3-data-type +
                          (if v-param-3-data-type = "" then "" else {&comma-char}) +
                          (if t-printable then "PRINTABLE" else "")
 v-param-3-data-type = v-param-3-data-type +
                          (if v-param-3-data-type = "" then "" else {&comma-char}) +
                          (if t-temp then "TEMP" else "")
v-param-3-data-type = v-param-3-data-type +
                          (if v-param-3-data-type = "" then "" else {&comma-char}) +
                          (if t-container then "CONTAINER" else "")
v-param-3-data-type = replace(v-param-3-data-type, {&comma-char} + {&comma-char}, {&comma-char})
v-param-3-data-type = trim(v-param-3-data-type, {&comma-char})
tt-ruledict-param.param-3-data-type = v-param-3-data-type
tt-ruledict-param.documentation
.
if tt-ruledict-param.init-value-character:visible in frame {&frame-name} then do:
  assign
  tt-ruledict-param.init-value-character
  tt-ruledict-param.init-value-date       = ?
  tt-ruledict-param.init-value-decimal    = 0.0
  tt-ruledict-param.init-value-integer    = 0
  tt-ruledict-param.init-value-logical    = no
  .
end.
if tt-ruledict-param.init-value-date:visible in frame {&frame-name} then do:
  assign
  tt-ruledict-param.init-value-character  = '':U
  tt-ruledict-param.init-value-date
  tt-ruledict-param.init-value-decimal    = 0.0
  tt-ruledict-param.init-value-integer    = 0
  tt-ruledict-param.init-value-logical    = no
  .
end.
if tt-ruledict-param.init-value-decimal:visible in frame {&frame-name} then do:
  assign
  tt-ruledict-param.init-value-character  = '':U
  tt-ruledict-param.init-value-date       = ?
  tt-ruledict-param.init-value-decimal
  tt-ruledict-param.init-value-integer    = 0
  tt-ruledict-param.init-value-logical    = no
  .
end.
if tt-ruledict-param.init-value-integer:visible in frame {&frame-name} then do:
  assign
  tt-ruledict-param.init-value-character  = '':U
  tt-ruledict-param.init-value-date       = ?
  tt-ruledict-param.init-value-decimal    = 0.0
  tt-ruledict-param.init-value-integer
  tt-ruledict-param.init-value-logical    = no
  .
end.
if tt-ruledict-param.init-value-logical:visible in frame {&frame-name} then do:
  assign
  tt-ruledict-param.init-value-character  = '':U
  tt-ruledict-param.init-value-date       = ?
  tt-ruledict-param.init-value-decimal    = 0.0
  tt-ruledict-param.init-value-integer    = 0
  tt-ruledict-param.init-value-logical
  .
end.
v-rec = p-rec.
if valid-handle(p-update-proc-handle) then do:
  run save-ruledict-param in p-update-proc-handle ( input buffer tt-ruledict-param:handle
                                                   ,input p-mode
                                                   ,output v-rec
                                                  ) no-error.
end.
else do:
  run rul/ruledict-param1.p ( INPUT p-mode
                  ,INPUT NO /*p-silent*/
                  ,INPUT-OUTPUT v-rec
                  ,INPUT tt-ruledict-param.entry-id
                  ,INPUT tt-ruledict-param.LANGUAGE
                  ,INPUT tt-ruledict-param.param-num
                  ,INPUT tt-ruledict-param.param-name
                  ,INPUT tt-ruledict-param.param-label
                  ,INPUT tt-ruledict-param.param-data-type
                  ,INPUT tt-ruledict-param.param-2-data-type
                  ,INPUT tt-ruledict-param.param-3-data-type
                  ,INPUT tt-ruledict-param.param-mode
                  ,INPUT tt-ruledict-param.documentation
                  ,INPUT tt-ruledict-param.init-value-character
                  ,INPUT tt-ruledict-param.init-value-date
                  ,INPUT tt-ruledict-param.init-value-decimal
                  ,INPUT tt-ruledict-param.init-value-integer
                  ,INPUT tt-ruledict-param.init-value-logical
                ) no-error.
end.
if error-status:error then do:
{ gbl/reterhnd.i error }
  undo, return error.
end.
p-rec = v-rec.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE switch-data-type Dialog-Frame
PROCEDURE switch-data-type :
HIDE
tt-ruledict-param.init-value-character  IN FRAME {&FRAME-NAME}
tt-ruledict-param.init-value-date
tt-ruledict-param.init-value-decimal
tt-ruledict-param.init-value-integer
tt-ruledict-param.init-value-logical
.
DISABLE
tt-ruledict-param.init-value-character
tt-ruledict-param.init-value-date
tt-ruledict-param.init-value-decimal
tt-ruledict-param.init-value-integer
tt-ruledict-param.init-value-logical
with FRAME {&FRAME-NAME}.
CASE tt-ruledict-param.param-data-type:
  WHEN {&abl-datatype-character}
  THEN DO:
     DISPLAY
     tt-ruledict-param.init-value-character
     WITH FRAME {&FRAME-NAME}.
     ENABLE
     tt-ruledict-param.init-value-character WHEN p-mode <> {&LOOKUP}
     WITH FRAME {&FRAME-NAME}.
  END.
  WHEN {&abl-datatype-longchar} then do:
     DISPLAY
     tt-ruledict-param.init-value-character
     WITH FRAME {&FRAME-NAME}.
     ENABLE
     tt-ruledict-param.init-value-character  WHEN p-mode <> {&LOOKUP}
     WITH FRAME {&FRAME-NAME}.
  end.
  WHEN {&abl-datatype-date} THEN DO:
     DISPLAY
     tt-ruledict-param.init-value-date
     WITH FRAME {&FRAME-NAME}.
     ENABLE
     tt-ruledict-param.init-value-date WHEN p-mode <> {&LOOKUP}
     WITH FRAME {&FRAME-NAME}.
  END.
  WHEN {&abl-datatype-decimal} THEN DO:
     DISPLAY
     tt-ruledict-param.init-value-decimal
     WITH FRAME {&FRAME-NAME}.
     ENABLE
     tt-ruledict-param.init-value-decimal WHEN p-mode <> {&LOOKUP}
     WITH FRAME {&FRAME-NAME}.
  END.
  WHEN {&abl-datatype-integer} THEN DO:
     DISPLAY
     tt-ruledict-param.init-value-integer
     WITH FRAME {&FRAME-NAME}.
     ENABLE
     tt-ruledict-param.init-value-integer WHEN p-mode <> {&LOOKUP}
     WITH FRAME {&FRAME-NAME}.
  END.
  WHEN {&abl-datatype-logical} THEN DO:
     DISPLAY
     tt-ruledict-param.init-value-logical
     WITH FRAME {&FRAME-NAME}.
     ENABLE
     tt-ruledict-param.init-value-logical WHEN p-mode <> {&LOOKUP}
     WITH FRAME {&FRAME-NAME}.
  END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME