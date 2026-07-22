&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_rule-profile FOR ub.rule-profile.
DEFINE BUFFER locked_ruledict FOR ub.ruledict.
DEFINE TEMP-TABLE tt-rule-profile NO-UNDO LIKE ub.rule-profile.
DEFINE NEW SHARED TEMP-TABLE tt-ruledict-param NO-UNDO LIKE ub.ruledict-param.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка rule-profile


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
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-profile-id AS INTEGER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка rule-profile".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/key-rec.i }
DEFINE VARIABLE v-param-num-list AS CHARACTER NO-UNDO.
DEFINE BUFFER FIRST_rule-profile FOR ub.rule-profile.
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-rule-profile

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-rule-profile.profile_id ~
tt-rule-profile.short-name tt-rule-profile.profile-type ~
tt-rule-profile.is_dynamic tt-rule-profile.param-code ~
tt-rule-profile.param-value tt-rule-profile.action-item-id ~
tt-rule-profile.action-item-context tt-rule-profile.custom-param-form ~
tt-rule-profile.reusable-params tt-rule-profile.name ~
tt-rule-profile.documentation
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-rule-profile.profile_id tt-rule-profile.short-name ~
tt-rule-profile.profile-type tt-rule-profile.is_dynamic ~
tt-rule-profile.param-code tt-rule-profile.action-item-id ~
tt-rule-profile.action-item-context tt-rule-profile.custom-param-form ~
tt-rule-profile.reusable-params tt-rule-profile.name ~
tt-rule-profile.documentation
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-rule-profile
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-rule-profile
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-rule-profile SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-rule-profile SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-rule-profile
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-rule-profile


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-rule-profile.profile_id ~
tt-rule-profile.short-name tt-rule-profile.profile-type ~
tt-rule-profile.is_dynamic tt-rule-profile.param-code ~
tt-rule-profile.action-item-id tt-rule-profile.action-item-context ~
tt-rule-profile.custom-param-form tt-rule-profile.reusable-params ~
tt-rule-profile.name tt-rule-profile.documentation
&Scoped-define ENABLED-TABLES tt-rule-profile
&Scoped-define FIRST-ENABLED-TABLE tt-rule-profile
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-params B-Help ~
T-parent-feature e-param-value b-action-item-id f-action-item-name
&Scoped-Define DISPLAYED-FIELDS tt-rule-profile.profile_id ~
tt-rule-profile.short-name tt-rule-profile.profile-type ~
tt-rule-profile.is_dynamic tt-rule-profile.param-code ~
tt-rule-profile.param-value tt-rule-profile.action-item-id ~
tt-rule-profile.action-item-context tt-rule-profile.custom-param-form ~
tt-rule-profile.reusable-params tt-rule-profile.name ~
tt-rule-profile.documentation
&Scoped-define DISPLAYED-TABLES tt-rule-profile
&Scoped-define FIRST-DISPLAYED-TABLE tt-rule-profile
&Scoped-Define DISPLAYED-OBJECTS T-parent-feature e-param-value ~
f-action-item-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-action-item-id
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3.5 BY 1.33.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-params
     LABEL "Параметры"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE e-param-value AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 46.5 BY 2.13 NO-UNDO.

DEFINE VARIABLE f-action-item-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 81 BY .67 NO-UNDO.

DEFINE VARIABLE T-parent-feature AS LOGICAL INITIAL no
     LABEL "Только в составе комб.профайла"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY 1.33 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-rule-profile SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-params AT ROW 1 COL 41 WIDGET-ID 30
     B-Help AT ROW 1 COL 95
     T-parent-feature AT ROW 2.33 COL 66 WIDGET-ID 64
     tt-rule-profile.profile_id AT ROW 2.57 COL 14 COLON-ALIGNED WIDGET-ID 4
          LABEL "Профайл"
          VIEW-AS FILL-IN NATIVE
          SIZE 10 BY 1
     tt-rule-profile.short-name AT ROW 2.57 COL 48.5 COLON-ALIGNED WIDGET-ID 36
          LABEL "Псевдоним"
          VIEW-AS FILL-IN NATIVE
          SIZE 11 BY 1
     tt-rule-profile.profile-type AT ROW 4.2 COL 14 COLON-ALIGNED WIDGET-ID 14
          LABEL "Тип" FORMAT "x(32)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 34 BY 1
     tt-rule-profile.is_dynamic AT ROW 4.2 COL 50.5 HELP
          "" NO-LABEL WIDGET-ID 60
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Редактир", yes,
"Нередактир", no,
"Условно", ?
          SIZE 48.5 BY 1
     tt-rule-profile.param-code AT ROW 5.27 COL 48.5 COLON-ALIGNED WIDGET-ID 32
          LABEL "Конф.параметр, необходимый для включения"
          VIEW-AS FILL-IN NATIVE
          SIZE 9 BY 1
     tt-rule-profile.param-value AT ROW 6.33 COL 48.5 COLON-ALIGNED WIDGET-ID 34
          LABEL "Значение параметра"
          VIEW-AS FILL-IN NATIVE
          SIZE 46.5 BY 1
     e-param-value AT ROW 7.4 COL 50.5 NO-LABEL WIDGET-ID 66
     tt-rule-profile.action-item-id AT ROW 9.53 COL 48.5 COLON-ALIGNED WIDGET-ID 38
          LABEL "Идентификатор права" FORMAT "X(55)"
          VIEW-AS FILL-IN NATIVE
          SIZE 35.5 BY 1
     b-action-item-id AT ROW 9.53 COL 87 WIDGET-ID 50
     tt-rule-profile.action-item-context AT ROW 11.67 COL 50.5 NO-LABEL WIDGET-ID 42
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Item 1", "1":U,
"Item 2", "2":U,
"Item 3", "3":U
          SIZE 34.5 BY 1.07
     tt-rule-profile.custom-param-form AT ROW 12.73 COL 2.5 NO-LABEL WIDGET-ID 54
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Item 1", 1,
"Item 2", 2
          SIZE 68 BY 1
     tt-rule-profile.reusable-params AT ROW 13.8 COL 49 COLON-ALIGNED WIDGET-ID 58
          LABEL "Повторно используемо" FORMAT "x(20)"
          VIEW-AS FILL-IN
          SIZE 20 BY 1
     tt-rule-profile.name AT ROW 15.13 COL 1 NO-LABEL WIDGET-ID 8
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 1.7
     tt-rule-profile.documentation AT ROW 17 COL 1 NO-LABEL WIDGET-ID 16
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 3.27
     f-action-item-name AT ROW 10.87 COL 15 COLON-ALIGNED NO-LABEL WIDGET-ID 52
     "Название" VIEW-AS TEXT
          SIZE 14.5 BY .77 AT ROW 10.87 COL 1 WIDGET-ID 10
     SPACE(83.99) SKIP(8.95)
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
      TABLE: locked_rule-profile B "?" ? ub rule-profile
      TABLE: locked_ruledict B "?" ? ub ruledict
      TABLE: tt-rule-profile T "?" NO-UNDO ub rule-profile
      TABLE: tt-ruledict-param T "NEW SHARED" NO-UNDO ub ruledict-param
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

/* SETTINGS FOR FILL-IN tt-rule-profile.action-item-id IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
ASSIGN
       e-param-value:RETURN-INSERTED IN FRAME Dialog-Frame  = TRUE.

/* SETTINGS FOR RADIO-SET tt-rule-profile.is_dynamic IN FRAME Dialog-Frame
   EXP-HELP                                                             */
/* SETTINGS FOR FILL-IN tt-rule-profile.param-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-rule-profile.param-value IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR COMBO-BOX tt-rule-profile.profile-type IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-rule-profile.profile_id IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-rule-profile.reusable-params IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-rule-profile.short-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-rule-profile"
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


&Scoped-define SELF-NAME b-action-item-id
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-action-item-id Dialog-Frame
ON CHOOSE OF b-action-item-id IN FRAME Dialog-Frame /* Btn 1 */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_action-item FOR ub.action-item.
FIND FIRST buf_action-item NO-LOCK WHERE
         buf_action-item.action-head-code = tt-rule-profile.action-head-code
     AND buf_action-item.action-item-id = tt-rule-profile.action-item-id
    AND buf_action-item.action-item-context = tt-rule-profile.action-item-context NO-ERROR.
  IF AVAILABLE buf_action-item  THEN DO:
      v-rid-list = STRING(RECID(buf_action-item)).
  END.
  run adm/actnitem.w ( INPUT parparentproc
                      ,INPUT "b-sel"
                      ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  IF v-rid-list <> '' THEN DO:
    FIND FIRST buf_action-item NO-LOCK WHERE
              recid(buf_action-item) = integer(v-rid-list) NO-ERROR.
    IF AVAILABLE buf_action-item THEN DO:
        ASSIGN
        tt-rule-profile.action-head-code = buf_action-item.action-head-code
        tt-rule-profile.action-item-id = buf_action-item.action-item-id
        tt-rule-profile.action-item-context = buf_action-item.action-item-context
        .
        DISPLAY
        tt-rule-profile.action-item-id
        tt-rule-profile.action-item-context
        buf_action-item.action-item-name @ f-action-item-name
        WITH FRAME {&FRAME-NAME}.
    END.
  END.
  ELSE DO:
    BELL.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-params
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-params Dialog-Frame
ON CHOOSE OF b-params IN FRAME Dialog-Frame /* Параметры */
DO:
  RUN proc-b-params IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      UNDO, RETURN NO-APPLY.
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
  IF p-mode = {&add-def} THEN DO:
    /*заблокируем*/
    FIND FIRST first_rule-profile EXCLUSIVE-LOCK.
    CREATE tt-rule-profile.
    ASSIGN
    tt-rule-profile.action-head-code = 0
    .
  END.
  else do:

    IF p-mode = {&UPDATE} THEN DO:
      FIND FIRST LOCKED_rule-profile EXCLUSIVE-LOCK WHERE
                LOCKED_rule-profile.profile_id = p-profile-id .
    END.
    IF p-mode = {&LOOKUP} THEN DO:
        FIND FIRST LOCKED_rule-profile no-LOCK WHERE
                  LOCKED_rule-profile.profile_id = p-profile-id  NO-ERROR.

    END.
    create tt-rule-profile.
    buffer-copy locked_rule-profile to tt-rule-profile.
  end.
  RUN fill-table  IN THIS-PROCEDURE.
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
  DISPLAY T-parent-feature e-param-value f-action-item-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-rule-profile THEN
    DISPLAY tt-rule-profile.profile_id tt-rule-profile.short-name
          tt-rule-profile.profile-type tt-rule-profile.is_dynamic
          tt-rule-profile.param-code tt-rule-profile.param-value
          tt-rule-profile.action-item-id tt-rule-profile.action-item-context
          tt-rule-profile.custom-param-form tt-rule-profile.reusable-params
          tt-rule-profile.name tt-rule-profile.documentation
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-params B-Help T-parent-feature
         tt-rule-profile.profile_id tt-rule-profile.short-name
         tt-rule-profile.profile-type tt-rule-profile.is_dynamic
         tt-rule-profile.param-code e-param-value
         tt-rule-profile.action-item-id b-action-item-id
         tt-rule-profile.action-item-context tt-rule-profile.custom-param-form
         tt-rule-profile.reusable-params tt-rule-profile.name
         tt-rule-profile.documentation f-action-item-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-table Dialog-Frame
PROCEDURE fill-table :
DEFINE BUFFER buf_tt-ruledict-param FOR tt-ruledict-param.
DEFINE BUFFER buf_ruledict-param FOR ub.ruledict-param.
DEFINE BUFFER buf_ruledict FOR ub.ruledict.
DEFINE VARIABLE v-uniq-key-rec AS CHARACTER NO-UNDO.
FOR EACH tt-ruledict-param:
  DELETE tt-ruledict-param.
END.
CASE p-mode:
  WHEN {&add-def} THEN DO:
  END.
  WHEN {&UPDATE} THEN DO:
    run gen-key-rec in this-procedure (
                                        input {&table_rule-profile}
                                        ,input  buffer locked_rule-profile:handle
                                        ,output v-uniq-key-rec
                                        ).
    FIND FIRST locked_ruledict EXCLUSIVE-LOCK WHERE
              locked_ruledict.ENTRY-type = {&rdict-etype-rule-profile}
        AND locked_ruledict.uniq-key-rec = v-uniq-key-rec NO-ERROR.
    FOR EACH buf_ruledict-param NO-LOCK WHERE
          buf_ruledict-param.entry-id = locked_ruledict.ENTRY-id:
      CREATE buf_tt-ruledict-param.
      BUFFER-COPY buf_ruledict-param TO buf_tt-ruledict-param.
    END.
  END.
  WHEN {&LOOKUP} THEN DO:
      run gen-key-rec in this-procedure (
                                          input {&table_rule-profile}
                                          ,input  buffer locked_rule-profile:handle
                                          ,output v-uniq-key-rec
                                          ).

      FIND FIRST locked_ruledict no-LOCK WHERE
                locked_ruledict.ENTRY-type = {&rdict-etype-rule-profile}
          AND locked_ruledict.uniq-key-rec = v-uniq-key-rec NO-ERROR.

      FOR EACH buf_ruledict-param NO-LOCK WHERE
            buf_ruledict-param.entry-id = locked_ruledict.ENTRY-id:
        CREATE buf_tt-ruledict-param.
        BUFFER-COPY buf_ruledict-param TO buf_tt-ruledict-param.
      END.

  END.
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tt-ruledict-param Dialog-Frame
PROCEDURE fill-tt-ruledict-param :
DEFINE INPUT PARAMETER p-bh AS HANDLE NO-UNDO.
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
FOR EACH tt-ruledict-param
ON error  UNDO, RETURN ERROR
ON stop  UNDO, RETURN ERROR:
  ASSIGN
  glog = p-bh:BUFFER-CREATE() NO-ERROR.
  IF NOT glog THEN DO:
     UNDO, RETURN ERROR substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  END.
  ASSIGN
  glog = p-bh:BUFFER-Copy( BUFFER tt-ruledict-param:HANDLE) NO-ERROR.
  IF NOT glog THEN DO:
     UNDO, RETURN ERROR substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  END.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE BUFFER buf_action-item FOR ub.action-item.
IF tt-rule-profile.action-item-id <> '' THEN DO:
  FIND FIRST buf_action-item NO-LOCK WHERE
             buf_action-item.action-head-code = tt-rule-profile.action-head-code
         AND buf_action-item.action-item-id = tt-rule-profile.action-item-id
        AND buf_action-item.action-item-context = tt-rule-profile.action-item-context NO-ERROR.
END.
ASSIGN
tt-rule-profile.profile-type:LIST-ITEMS IN FRAME {&FRAME-NAME} = {&profile-type-list}
e-param-value:SCREEN-VALUE = replace(tt-rule-profile.param-value, {&delim-par}, {&NEW-LINE})
tt-rule-profile.action-item-context:RADIO-BUTTONS in FRAME {&FRAME-NAME} =
{&cntxt-global} + {&comma-char} + {&cntxt-global} + {&comma-char} +
{&cntxt-firm} + {&comma-char} + {&cntxt-firm} +  {&comma-char} +
{&cntxt-object} + {&comma-char} + {&cntxt-object}
tt-rule-profile.custom-param-form:RADIO-BUTTONS in FRAME {&FRAME-NAME} =
"Станд. форма для ввода параметров" + {&comma-char} + "0" + {&comma-char} +
"Спец. форма для ввода параметров" + {&comma-char} + "1"
.
t-parent-feature = (if tt-rule-profile.parent-feature = integer({&rp-parentf-only-in-combo})
                    then  yes
                    else no ).

IF AVAILABLE tt-rule-profile THEN
DISPLAY
t-parent-feature
tt-rule-profile.profile-type
tt-rule-profile.profile_id
tt-rule-profile.name
tt-rule-profile.is_dynamic
tt-rule-profile.param-code
tt-rule-profile.param-value
tt-rule-profile.short-name
tt-rule-profile.documentation
tt-rule-profile.action-item-context
tt-rule-profile.action-item-id
tt-rule-profile.custom-param-form
tt-rule-profile.reusable-param
WITH FRAME {&frame-name} .
IF available buf_action-item THEN DO:
  DISPLAY
  buf_action-item.action-item-name @ f-action-item-name
  WITH FRAME {&frame-name} .
END.
ELSE DO:
  IF p-mode = {&LOOKUP} THEN
  HIDE
  tt-rule-profile.action-item-context
  tt-rule-profile.action-item-id
  f-action-item-name
  b-action-item-id
  IN FRAME {&FRAME-NAME}.

END.
ENABLE
B-exit  when p-mode <> {&lookup}
b-quit
B-Help
b-params WHEN p-mode <> {&add-def}
t-parent-feature when p-mode <> {&lookup}
tt-rule-profile.profile-type  when p-mode <> {&lookup}
tt-rule-profile.profile_id when p-mode = {&add-def}
tt-rule-profile.name      when p-mode <> {&lookup}
tt-rule-profile.short-name when p-mode <> {&lookup}
tt-rule-profile.is_dynamic when p-mode <> {&lookup}
tt-rule-profile.documentation
tt-rule-profile.param-code when p-mode <> {&lookup}
tt-rule-profile.action-item-context when p-mode <> {&lookup}
tt-rule-profile.action-item-id when p-mode <> {&lookup}
b-action-item-id when p-mode <> {&lookup}
tt-rule-profile.custom-param-form when p-mode <> {&lookup}
tt-rule-profile.reusable-param when p-mode <> {&lookup}
e-param-value
WITH FRAME {&frame-name} .
if p-mode = {&lookup} then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  tt-rule-profile.NAME:READ-ONLY = YES
  tt-rule-profile.documentation:READ-ONLY = YES
  e-param-value:READ-ONLY = YES
  .
  hide
  b-exit
  tt-rule-profile.reusable-param
  in frame {&frame-name} .
end.
VIEW FRAME {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-params Dialog-Frame
PROCEDURE proc-b-params :
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-return-value as character no-undo .
DEFINE BUFFER buf_tt-ruledict-param FOR tt-ruledict-param.
IF p-mode = {&LOOKUP} THEN DO:
  FIND FIRST buf_tt-ruledict-param NO-ERROR.
  IF NOT AVAILABLE buf_tt-ruledict-param THEN DO:
    MESSAGE
    "У этого профайла нет параметров"
    VIEW-AS ALERT-BOX.
    RETURN.
  END.
END.
ELSE DO:
  v-param-num-list = '':U.
END.

run rul/ruledict-param-s.w ( INPUT parparentproc
                            ,input this-procedure:handle /*p-update-proc-handle*/
                            ,INPUT (IF p-mode = {&UPDATE}
                                    OR p-mode = {&add-def}
                                    THEN "b-add"
                                    ELSE "":U)
                            ,INPUT (if p-mode = {&lookup}
                                    then "entry-id"
                                    else {&UPDATE})  /*p-list-mode*/
                            ,INPUT (if p-mode = {&update}
                                    or p-mode = {&lookup}
                                    then locked_ruledict.entry-id
                                    else 0)
                            ,input {&rdict-etype-rule-profile}
                            ,INPUT-OUTPUT v-rid-list) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
   message error-status:get-message(1) view-as alert-box .
   UNDO, RETURN ERROR.
END.
v-return-value = return-value .
if (p-mode = {&update}
or p-mode = {&add-def})
and v-return-value <> "quit" then do:
  FOR EACH tt-ruledict-param:
    IF LOOKUP(string(tt-ruledict-param.param-num), v-param-num-list) = 0 THEN DO:
        DELETE tt-ruledict-param.
    END.
  END.
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
v-rec = p-rec.
ASSIGN
FRAME {&FRAME-NAME}
t-parent-feature
tt-rule-profile.profile-type
tt-rule-profile.profile_id
tt-rule-profile.NAME
tt-rule-profile.is_dynamic
tt-rule-profile.param-code
tt-rule-profile.param-value = replace(e-param-value:SCREEN-VALUE, {&NEW-LINE}, {&delim-par})
tt-rule-profile.short-name
tt-rule-profile.action-item-context
tt-rule-profile.action-item-id
tt-rule-profile.custom-param-form
tt-rule-profile.reusable-params
tt-rule-profile.parent-feature = (if t-parent-feature
                                  then integer({&rp-parentf-only-in-combo})
                                  else integer({&rp-parentf-ordinal}))
.
run rul/rule-profile1.p ( INPUT p-mode
                ,INPUT NO /*p-silent*/
                ,INPUT-OUTPUT v-rec
                ,INPUT tt-rule-profile.profile_id
                ,INPUT tt-rule-profile.profile-type
                ,INPUT tt-rule-profile.name
                ,INPUT tt-rule-profile.is_dynamic
                ,INPUT tt-rule-profile.documentation:screen-value
                ,INPUT tt-rule-profile.param-code
                ,INPUT tt-rule-profile.param-value
                ,INPUT tt-rule-profile.short-name
                ,INPUT tt-rule-profile.action-head-code
                ,INPUT tt-rule-profile.action-item-id
                ,INPUT tt-rule-profile.action-item-context
                ,INPUT tt-rule-profile.custom-param-form
                ,input tt-rule-profile.reusable-params
                ,input tt-rule-profile.parent-feature
                ,input table tt-ruledict-param
                ) no-error.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
p-rec = v-rec.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-tt-ruledict-param Dialog-Frame 
PROCEDURE save-tt-ruledict-param :
DEFINE INPUT PARAMETER p-bh AS HANDLE NO-UNDO.
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
FIND FIRST tt-ruledict-param WHERE
           tt-ruledict-param.param-num = p-bh::param-num NO-ERROR.
IF NOT AVAILABLE tt-ruledict-param THEN DO:
   CREATE tt-ruledict-param.
END.
ASSIGN
glog = BUFFER tt-ruledict-param:handle:BUFFER-Copy( p-bh) NO-ERROR.
IF NOT glog THEN DO:
  UNDO, RETURN ERROR substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
END.
v-param-num-list = v-param-num-list + {&comma-char} + STRING( tt-ruledict-param.param-num).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

