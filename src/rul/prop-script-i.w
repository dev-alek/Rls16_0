&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_prop-script FOR ub.prop-script.
DEFINE TEMP-TABLE tt-prop-script NO-UNDO LIKE ub.prop-script.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка prop-script


Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/12/07
Author: Bakhtadze Natalya
Creation date: 02/12/07

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-dtm-code AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-language AS character NO-UNDO.
DEFINE INPUT PARAMETER p-script-name AS character NO-UNDO.
DEFINE INPUT PARAMETER p-revis-id AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка prop-script".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
define variable v-is-copy as logical no-undo .
DEFINE BUFFER first_prop-script FOR ub.prop-script.
DEFINE BUFFER buf_ruledict FOR ub.ruledict.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-prop-script

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-prop-script.dtm-code ~
tt-prop-script.class-dtm-code tt-prop-script.language ~
tt-prop-script.revis_id tt-prop-script.script-name tt-prop-script.hidden_ ~
tt-prop-script.documentation tt-prop-script.proc-type ~
tt-prop-script.script-type tt-prop-script.script-value-type ~
tt-prop-script.signature tt-prop-script.script-head ~
tt-prop-script.script-body tt-prop-script.script-foot
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-prop-script.dtm-code ~
tt-prop-script.class-dtm-code tt-prop-script.language ~
tt-prop-script.revis_id tt-prop-script.script-name tt-prop-script.hidden_ ~
tt-prop-script.documentation tt-prop-script.proc-type ~
tt-prop-script.script-type tt-prop-script.script-value-type ~
tt-prop-script.signature tt-prop-script.script-head ~
tt-prop-script.script-body tt-prop-script.script-foot
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-prop-script
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-prop-script
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-prop-script SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-prop-script SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-prop-script
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-prop-script


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-prop-script.dtm-code ~
tt-prop-script.class-dtm-code tt-prop-script.language ~
tt-prop-script.revis_id tt-prop-script.script-name tt-prop-script.hidden_ ~
tt-prop-script.documentation tt-prop-script.proc-type ~
tt-prop-script.script-type tt-prop-script.script-value-type ~
tt-prop-script.signature tt-prop-script.script-head ~
tt-prop-script.script-body tt-prop-script.script-foot
&Scoped-define ENABLED-TABLES tt-prop-script
&Scoped-define FIRST-ENABLED-TABLE tt-prop-script
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-params B-Help b-copy f-label ~
b-prop-map b-prop-map-2 cb-object-type
&Scoped-Define DISPLAYED-FIELDS tt-prop-script.dtm-code ~
tt-prop-script.class-dtm-code tt-prop-script.language ~
tt-prop-script.revis_id tt-prop-script.script-name tt-prop-script.hidden_ ~
tt-prop-script.documentation tt-prop-script.proc-type ~
tt-prop-script.script-type tt-prop-script.script-value-type ~
tt-prop-script.signature tt-prop-script.script-head ~
tt-prop-script.script-body tt-prop-script.script-foot
&Scoped-define DISPLAYED-TABLES tt-prop-script
&Scoped-define FIRST-DISPLAYED-TABLE tt-prop-script
&Scoped-Define DISPLAYED-OBJECTS f-label cb-object-type

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-copy
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-params
     LABEL "Пар-ры"
     SIZE 10 BY 1.

DEFINE BUTTON b-prop-map
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON b-prop-map-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE cb-object-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип Объект"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 35 BY 1 NO-UNDO.

DEFINE VARIABLE f-label AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 95 BY 1.58 TOOLTIP "Лейбл" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-prop-script SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     tt-prop-script.dtm-code AT ROW 1 COL 22 WIDGET-ID 2
          LABEL "Код объ."
          VIEW-AS FILL-IN NATIVE
          SIZE 7.5 BY 1
     tt-prop-script.class-dtm-code AT ROW 1 COL 48.5 COLON-ALIGNED WIDGET-ID 58
          LABEL "Код кл."
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     tt-prop-script.language AT ROW 1 COL 58 NO-LABEL WIDGET-ID 10
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "ABL", "ABL":U
          SIZE 5.5 BY 1.08
     tt-prop-script.revis_id AT ROW 1 COL 69.5 COLON-ALIGNED WIDGET-ID 44
          LABEL "Верс."
          VIEW-AS FILL-IN NATIVE
          SIZE 5.5 BY 1
     b-params AT ROW 1 COL 78 WIDGET-ID 36
     B-Help AT ROW 1 COL 88
     tt-prop-script.script-name AT ROW 2.08 COL 1 NO-LABEL WIDGET-ID 54
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 95 BY 1.88 TOOLTIP "Название"
     b-copy AT ROW 2.33 COL 96.5 WIDGET-ID 50
     f-label AT ROW 3.92 COL 1 NO-LABEL WIDGET-ID 52
     b-prop-map AT ROW 4.21 COL 96.5 WIDGET-ID 46
     b-prop-map-2 AT ROW 5.54 COL 18.5 WIDGET-ID 48
     tt-prop-script.hidden_ AT ROW 5.54 COL 41 WIDGET-ID 56
          LABEL "Скрытый"
          VIEW-AS TOGGLE-BOX
          SIZE 18.5 BY 1
     tt-prop-script.documentation AT ROW 6.58 COL 1 NO-LABEL WIDGET-ID 6
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 1.88
     tt-prop-script.proc-type AT ROW 8.46 COL 12 COLON-ALIGNED WIDGET-ID 12
          LABEL "Тип проц-ры" FORMAT "x(20)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 30.5 BY 1
     tt-prop-script.script-type AT ROW 8.46 COL 59.5 COLON-ALIGNED WIDGET-ID 16
          LABEL "Тип скрипта" FORMAT "X(20)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 35 BY 1
     cb-object-type AT ROW 9.46 COL 59.5 COLON-ALIGNED WIDGET-ID 42
     tt-prop-script.script-value-type AT ROW 9.54 COL 12 COLON-ALIGNED WIDGET-ID 18
          LABEL "Знач-е" FORMAT "X(20)"
          VIEW-AS COMBO-BOX INNER-LINES 7
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 30.5 BY 1
     tt-prop-script.signature AT ROW 10.58 COL 2 WIDGET-ID 22
          LABEL "Сигн-ра"
          VIEW-AS FILL-IN NATIVE
          SIZE 88 BY 1 TOOLTIP "Чтобы заблок авто формирование напиши сигнатуру с @ впереди"
     tt-prop-script.script-head AT ROW 12.21 COL 1 NO-LABEL WIDGET-ID 20
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 2.92
     tt-prop-script.script-body AT ROW 15.92 COL 1 NO-LABEL WIDGET-ID 26
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 3.42
     tt-prop-script.script-foot AT ROW 20.21 COL 1 NO-LABEL WIDGET-ID 30
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98.5 BY 2.92
     "Подвал" VIEW-AS TEXT
          SIZE 7.5 BY .79 AT ROW 19.42 COL 1 WIDGET-ID 32
     "Тело" VIEW-AS TEXT
          SIZE 7.5 BY .79 AT ROW 15.13 COL 1 WIDGET-ID 28
     "Голова" VIEW-AS TEXT
          SIZE 7.5 BY .79 AT ROW 11.42 COL 1 WIDGET-ID 24
     "Описание" VIEW-AS TEXT
          SIZE 17 BY 1 AT ROW 5.54 COL 1.5 WIDGET-ID 8
     SPACE(81.20) SKIP(16.68)
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
      TABLE: locked_prop-script B "?" ? ub prop-script
      TABLE: tt-prop-script T "?" NO-UNDO ub prop-script
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

/* SETTINGS FOR FILL-IN tt-prop-script.class-dtm-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-prop-script.dtm-code IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR TOGGLE-BOX tt-prop-script.hidden_ IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX tt-prop-script.proc-type IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-prop-script.revis_id IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-prop-script.script-foot:RETURN-INSERTED IN FRAME Dialog-Frame  = TRUE.

ASSIGN
       tt-prop-script.script-name:RETURN-INSERTED IN FRAME Dialog-Frame  = TRUE.

/* SETTINGS FOR COMBO-BOX tt-prop-script.script-type IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR COMBO-BOX tt-prop-script.script-value-type IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-prop-script.signature IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-prop-script"
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
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
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


&Scoped-define SELF-NAME b-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-copy Dialog-Frame
ON CHOOSE OF b-copy IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  DEFINE BUFFER buf_prop-script FOR ub.prop-script.
  run rul/prop-script-s.w (
                           input parparentproc
                          ,INPUT 'b-sel':U /* bttns */
                          ,INPUT "dtm-code" /* p-list-mode */
                          ,INPUT '':U /*p-language*/
                          ,INPUT tt-prop-script.dtm-code
                          ,INPUT "":U /* p-proc-type */
                          ,INPUT "":U /* p-script-type */
                          ,INPUT-OUTPUT v-rid-list) NO-ERROR.
 IF ERROR-STATUS:ERROR OR v-rid-list = '':U THEN RETURN NO-APPLY.
 FIND FIRST buf_prop-script NO-LOCK WHERE
           recid(buf_prop-script) = INTEGER(v-rid-list).
 BUFFER-COPY buf_prop-script TO tt-prop-script.
 RUN MyEnable IN THIS-PROCEDURE ( input {&add-copy}) NO-ERROR .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-params
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-params Dialog-Frame
ON CHOOSE OF b-params IN FRAME Dialog-Frame /* Пар-ры */
DO:
 DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  DEFINE BUFFER buf_ruledict-param FOR ub.ruledict-param.
  IF NOT AVAILABLE buf_ruledict  THEN DO:
    MESSAGE
    "Еще отсутствует в словаре"
    VIEW-AS ALERT-BOX.
    RETURN NO-APPLY.
  END.
  find first buf_ruledict-param no-lock where
            buf_ruledict-param.entry-id = buf_ruledict.entry-id no-error.
  if not available buf_ruledict-param then do:
    message
    "Нет параметров!"
    view-as alert-box error .
    undo, return no-apply .
  end.
  run rul/ruledict-param-s.w ( INPUT parparentproc
                            ,input ? /*p-update-proc-handle*/
                            ,INPUT '':U /*bttns*/
                            ,INPUT "entry-id"
                            ,INPUT buf_ruledict.entry-id
                            ,input {&rdict-etype-prop-script} /*p-entry-type*/
                            ,INPUT-OUTPUT v-rid-list) NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prop-map
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prop-map Dialog-Frame
ON CHOOSE OF b-prop-map IN FRAME Dialog-Frame
DO:
   DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-map FOR ub.prop-map.
    run rul/prop-map-s.w (
                           input parparentproc
                          ,INPUT 'b-sel':U /* bttns */
                          ,INPUT "dtm-code" /* p-list-mode */
                          ,INPUT tt-prop-script.dtm-code
                          ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  IF v-rid-list = '':U THEN DO:
     RETURN NO-APPLY.
  END.
  FIND FIRST buf_prop-map NO-LOCK WHERE
            RECID(buf_prop-map) = INTEGER(v-rid-list) NO-ERROR.
  IF NOT AVAILABLE buf_prop-map THEN RETURN NO-APPLY.
  ASSIGN
  f-label = buf_prop-map.node-label.
  DISPLAY
  f-label
  WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prop-map-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prop-map-2 Dialog-Frame
ON CHOOSE OF b-prop-map-2 IN FRAME Dialog-Frame
DO:
    DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
 DEFINE BUFFER buf_prop-map FOR ub.prop-map.
     run rul/prop-map-s.w (
                            input parparentproc
                           ,INPUT 'b-sel':U /* bttns */
                           ,INPUT "dtm-code" /* p-list-mode */
                           ,INPUT tt-prop-script.dtm-code
                           ,INPUT-OUTPUT v-rid-list) NO-ERROR.
   IF v-rid-list = '':U THEN DO:
      RETURN NO-APPLY.
   END.
   FIND FIRST buf_prop-map NO-LOCK WHERE
             RECID(buf_prop-map) = INTEGER(v-rid-list) NO-ERROR.
   IF NOT AVAILABLE buf_prop-map THEN RETURN NO-APPLY.
   ASSIGN
   tt-prop-script.documentation = buf_prop-map.node-description.
   DISPLAY
   f-label
   WITH FRAME {&FRAME-NAME}.

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
    FIND FIRST first_prop-script EXCLUSIVE-LOCK.
    CREATE tt-prop-script.
    ASSIGN
    tt-prop-script.LANGUAGE = "ABL"
    tt-prop-script.dtm-code = p-dtm-code.
  END.
  else do:
    IF p-mode = {&add-copy} THEN DO:
      v-is-copy = yes.
      p-mode = {&add-def}.
      FIND FIRST first_prop-script EXCLUSIVE-LOCK.
      FIND FIRST first_prop-script EXCLUSIVE-LOCK.
      FIND FIRST LOCKED_prop-script no-lock WHERE
                LOCKED_prop-script.script-name = p-script-name
          AND LOCKED_prop-script.LANGUAGE = p-language
          AND LOCKED_prop-script.dtm-code = p-dtm-code
          AND LOCKED_prop-script.revis_id = p-revis-id
          .
      create tt-prop-script.
      buffer-copy locked_prop-script
      to tt-prop-script.
      release locked_prop-script.
    END.
    IF p-mode = {&UPDATE} THEN DO:
      FIND FIRST LOCKED_prop-script EXCLUSIVE-LOCK WHERE
                LOCKED_prop-script.script-name = p-script-name
          AND LOCKED_prop-script.LANGUAGE = p-language
          AND LOCKED_prop-script.dtm-code = p-dtm-code
          AND LOCKED_prop-script.revis_id = p-revis-id
          .
      create tt-prop-script.
      buffer-copy locked_prop-script to tt-prop-script.
    END.
    IF p-mode = {&LOOKUP} THEN DO:
        FIND FIRST LOCKED_prop-script no-lock WHERE
                  LOCKED_prop-script.script-name = p-script-name
            AND LOCKED_prop-script.LANGUAGE = p-language
            AND LOCKED_prop-script.dtm-code = p-dtm-code
            AND LOCKED_prop-script.revis_id = p-revis-id.
      create tt-prop-script.
      buffer-copy locked_prop-script to tt-prop-script.
    END.
  end.

  RUN Myenable in THIS-PROCEDURE ( input p-mode).
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
  DISPLAY f-label cb-object-type 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-prop-script THEN 
    DISPLAY tt-prop-script.dtm-code tt-prop-script.class-dtm-code 
          tt-prop-script.language tt-prop-script.revis_id 
          tt-prop-script.script-name tt-prop-script.hidden_ 
          tt-prop-script.documentation tt-prop-script.proc-type 
          tt-prop-script.script-type tt-prop-script.script-value-type 
          tt-prop-script.signature tt-prop-script.script-head 
          tt-prop-script.script-body tt-prop-script.script-foot 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit tt-prop-script.dtm-code tt-prop-script.class-dtm-code 
         tt-prop-script.language tt-prop-script.revis_id b-params B-Help 
         tt-prop-script.script-name b-copy f-label b-prop-map b-prop-map-2 
         tt-prop-script.hidden_ tt-prop-script.documentation 
         tt-prop-script.proc-type tt-prop-script.script-type cb-object-type 
         tt-prop-script.script-value-type tt-prop-script.signature 
         tt-prop-script.script-head tt-prop-script.script-body 
         tt-prop-script.script-foot 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
define input parameter p-mode as character no-undo .
define buffer bufcL_prop-script for ub.prop-script.
IF p-mode = {&UPDATE}
OR p-mode = {&lookup}
OR (p-mode = {&add-def} and v-is-copy = yes)
THEN DO:
  FIND FIRST buf_Ruledict NO-LOCK WHERE
            buf_ruledict.entry-type  = {&rdict-etype-prop-script}
          and buf_ruledict.uniq-key-rec  = tt-prop-script.uniq-key-rec no-error.
  if available buf_ruledict then do:
    f-label = buf_ruledict.script-nl.
  end.
END.
if not available buf_ruledict
and (p-mode = {&update} or (p-mode = {&add-def} and v-is-copy = yes))
and lookup(tt-prop-script.proc-type,
          (
          {&script-ptype-DATA-MEMBER} + {&comma-char} +
          {&script-ptype-PROPERTY} + {&comma-char} +
          {&script-ptype-METHOD} + {&comma-char} +
          {&script-ptype-CONSTRUCTOR} + {&comma-char} +
          {&script-ptype-DESTRUCTOR})) > 0 then do:
  find first bufcl_prop-script no-lock where
            bufcl_prop-script.dtm-code = tt-prop-script.dtm-code
       and  bufcl_prop-script.language = tt-prop-script.language
       and  bufcl_prop-script.script-name  = entry(1, tt-prop-script.script-name, ":") no-error.
  if available bufcl_prop-script then do:
    FIND FIRST buf_Ruledict NO-LOCK WHERE
              buf_ruledict.entry-type  = {&rdict-etype-prop-script}
            and buf_ruledict.uniq-key-rec  = bufcl_prop-script.uniq-key-rec no-error.
    if available buf_ruledict then do:
      f-label = buf_ruledict.script-nl.
    end.
  end.
end.
ASSIGN
tt-prop-script.proc-type:LIST-ITEMS IN FRAME {&FRAME-NAME} = {&script-ptype-list}
tt-prop-script.script-type:LIST-ITEMS IN FRAME {&FRAME-NAME} = {&prop-script-type-list}
tt-prop-script.script-value-type:LIST-ITEMS IN FRAME {&FRAME-NAME} = {&ABL-simple-datatype-list} + {&comma-char} +
                                                                      {&abl-datatype-handle} + {&comma-char} +
                                                                      {&abl-datatype-void}
cb-object-type:LIST-ITEMS IN FRAME {&FRAME-NAME} = ",r-b,dis-card"
.
ASSIGN
cb-object-type = (if num-entries(tt-prop-script.script-value-type) > 1
                  then ENTRY(2, tt-prop-script.script-value-type)
                  else '':U)
tt-prop-script.script-value-type =ENTRY(1, tt-prop-script.script-value-type)
.

DISPLAY
f-label
WITH FRAME {&frame-name}.
IF AVAILABLE tt-prop-script THEN
DISPLAY
tt-prop-script.dtm-code
tt-prop-script.class-dtm-code
tt-prop-script.language
tt-prop-script.script-name
tt-prop-script.revis_id
tt-prop-script.documentation
tt-prop-script.proc-type
tt-prop-script.script-type
tt-prop-script.script-value-type
tt-prop-script.signature
tt-prop-script.script-head
tt-prop-script.script-body
tt-prop-script.script-foot
cb-object-type
tt-prop-script.hidden_
WITH FRAME {&frame-name}.
assign
tt-prop-script.script-head:read-only in frame {&frame-name} = (p-mode = {&lookup})
tt-prop-script.script-body:read-only in frame {&frame-name} = (p-mode = {&lookup})
tt-prop-script.script-foot:read-only in frame {&frame-name} = (p-mode = {&lookup})
tt-prop-script.documentation:read-only in frame {&frame-name} = (p-mode = {&lookup})
.
ENABLE
B-exit WHEN p-mode <> {&lookup}
b-quit
b-params WHEN p-mode <> {&add-def}
B-Help
b-copy WHEN p-mode = {&add-def}
tt-prop-script.dtm-code WHEN (p-mode = {&add-def} AND p-dtm-code = ?)
tt-prop-script.class-dtm-code WHEN (p-mode <> {&lookup})
tt-prop-script.language WHEN p-mode = {&add-def}
tt-prop-script.script-name
f-label
b-prop-map WHEN (p-mode <> {&lookup} AND tt-prop-script.dtm-code > 0)
b-prop-map-2 WHEN (p-mode <> {&lookup} AND tt-prop-script.dtm-code > 0)
tt-prop-script.documentation
tt-prop-script.proc-type   WHEN p-mode <> {&lookup}
tt-prop-script.script-type  WHEN p-mode <> {&lookup}
tt-prop-script.script-value-type WHEN p-mode <> {&lookup}
tt-prop-script.signature   WHEN p-mode <> {&lookup}
tt-prop-script.hidden   WHEN p-mode <> {&lookup}
tt-prop-script.script-head
tt-prop-script.script-body
tt-prop-script.script-foot
cb-object-type WHEN (p-mode = {&add-def}
                     OR (p-mode = {&UPDATE}
                         AND
                         cb-object-type <> '':U))
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
if p-mode = {&lookup} then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  f-label:READ-ONLY IN FRAME {&FRAME-NAME} = YES
  tt-prop-script.script-name:READ-ONLY IN FRAME {&FRAME-NAME} = YES.
  hide b-exit in frame {&frame-name} .
end.
if p-mode <> {&add-def} then do:
  tt-prop-script.script-name:READ-ONLY IN FRAME {&FRAME-NAME} = YES.
  hide b-copy in frame {&frame-name} .
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
if p-mode = {&update} then do:
  v-rec = p-rec.
end.
ASSIGN
FRAME {&FRAME-NAME}
f-label
tt-prop-script.dtm-code
tt-prop-script.class-dtm-code
tt-prop-script.language
tt-prop-script.script-name
tt-prop-script.documentation
tt-prop-script.documentation
cb-object-type
tt-prop-script.proc-type
tt-prop-script.script-type
tt-prop-script.script-value-type
tt-prop-script.script-value-type = tt-prop-script.script-value-type + {&comma-char} + cb-object-type
tt-prop-script.script-head
tt-prop-script.script-body
tt-prop-script.script-foot
tt-prop-script.signature
tt-prop-script.HIDDEN_
.
run rul/prop-script1.p ( INPUT p-mode
                ,INPUT NO /*p-silent*/
                ,INPUT-OUTPUT v-rec
                ,INPUT tt-prop-script.dtm-code
                ,INPUT tt-prop-script.language
                ,INPUT tt-prop-script.script-name
                ,input tt-prop-script.revis_id
                ,input f-label
                ,input tt-prop-script.class-dtm-code
                ,INPUT tt-prop-script.documentation
                ,INPUT tt-prop-script.proc-type
                ,INPUT tt-prop-script.script-type
                ,INPUT tt-prop-script.script-value-type
                ,INPUT tt-prop-script.script-head
                ,INPUT tt-prop-script.script-body
                ,INPUT tt-prop-script.script-foot
                ,INPUT tt-prop-script.signature
                ,INPUT tt-prop-script.HIDDEN_
                ) no-error.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
p-rec = v-rec.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

