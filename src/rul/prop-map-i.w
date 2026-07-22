&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-prop-map NO-UNDO LIKE ub.prop-map.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка prop-map


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
DEFINE INPUT PARAMETER p-dtm-code AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-node-code AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка prop-map".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }

DEFINE BUFFER locked_prop-map FOR dictdb.prop-map.
DEFINE BUFFER last_prop-map FOR dictdb.prop-map.
DEFINE BUFFER locked_prop-head FOR ub.prop-head.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-prop-map

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-prop-map.dtm-code ~
tt-prop-map.node-code tt-prop-map.upper-node-code ~
tt-prop-map.upper-node-name tt-prop-map.node-type ~
tt-prop-map.node-value-type tt-prop-map.is-collection tt-prop-map.is-term ~
tt-prop-map.node-name tt-prop-map.node-label ~
tt-prop-map.init-value-character tt-prop-map.init-value-date ~
tt-prop-map.node-format tt-prop-map.init-value-decimal ~
tt-prop-map.init-value-integer tt-prop-map.init-value-logical ~
tt-prop-map.node-description
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-prop-map.dtm-code ~
tt-prop-map.node-code tt-prop-map.upper-node-code tt-prop-map.node-type ~
tt-prop-map.node-value-type tt-prop-map.is-collection tt-prop-map.is-term ~
tt-prop-map.node-name tt-prop-map.node-label ~
tt-prop-map.init-value-character tt-prop-map.init-value-date ~
tt-prop-map.node-format tt-prop-map.init-value-decimal ~
tt-prop-map.init-value-integer tt-prop-map.init-value-logical ~
tt-prop-map.node-description
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-prop-map
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-prop-map
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-prop-map SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-prop-map SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-prop-map
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-prop-map


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-prop-map.dtm-code tt-prop-map.node-code ~
tt-prop-map.upper-node-code tt-prop-map.node-type ~
tt-prop-map.node-value-type tt-prop-map.is-collection tt-prop-map.is-term ~
tt-prop-map.node-name tt-prop-map.node-label ~
tt-prop-map.init-value-character tt-prop-map.init-value-date ~
tt-prop-map.node-format tt-prop-map.init-value-decimal ~
tt-prop-map.init-value-integer tt-prop-map.init-value-logical ~
tt-prop-map.node-description
&Scoped-define ENABLED-TABLES tt-prop-map
&Scoped-define FIRST-ENABLED-TABLE tt-prop-map
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help b-upper-code T-R T-W ~
T-C T-O cb-object-type
&Scoped-Define DISPLAYED-FIELDS tt-prop-map.dtm-code tt-prop-map.node-code ~
tt-prop-map.upper-node-code tt-prop-map.upper-node-name ~
tt-prop-map.node-type tt-prop-map.node-value-type tt-prop-map.is-collection ~
tt-prop-map.is-term tt-prop-map.node-name tt-prop-map.node-label ~
tt-prop-map.init-value-character tt-prop-map.init-value-date ~
tt-prop-map.node-format tt-prop-map.init-value-decimal ~
tt-prop-map.init-value-integer tt-prop-map.init-value-logical ~
tt-prop-map.node-description
&Scoped-define DISPLAYED-TABLES tt-prop-map
&Scoped-define FIRST-DISPLAYED-TABLE tt-prop-map
&Scoped-Define DISPLAYED-OBJECTS T-R T-W T-C T-O cb-object-type

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

DEFINE BUTTON b-upper-code
     LABEL "Btn 1"
     SIZE 3 BY 1.07.

DEFINE VARIABLE cb-object-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип Объект"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 23 BY 1 NO-UNDO.

DEFINE VARIABLE T-C AS LOGICAL INITIAL no
     LABEL "C"
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-O AS LOGICAL INITIAL no
     LABEL "O"
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-R AS LOGICAL INITIAL no
     LABEL "R"
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-W AS LOGICAL INITIAL no
     LABEL "W"
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-prop-map SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     tt-prop-map.dtm-code AT ROW 1 COL 34 COLON-ALIGNED WIDGET-ID 2
          LABEL "Код объекта"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          FGCOLOR 4
     tt-prop-map.node-code AT ROW 1 COL 69 COLON-ALIGNED WIDGET-ID 38
          LABEL "Код свойства (узла)"
          VIEW-AS FILL-IN
          SIZE 12 BY 1.07
          FGCOLOR 4
     B-Help AT ROW 1 COL 95
     tt-prop-map.upper-node-code AT ROW 2.07 COL 18.5 COLON-ALIGNED WIDGET-ID 46
          LABEL "Код узла-родителя"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     b-upper-code AT ROW 2.07 COL 31 WIDGET-ID 50
     tt-prop-map.upper-node-name AT ROW 2.07 COL 51.5 COLON-ALIGNED WIDGET-ID 48
          LABEL "Имя узла-родителя"
          VIEW-AS FILL-IN
          SIZE 45 BY 1
     T-R AT ROW 3.25 COL 72.5 WIDGET-ID 56
     T-W AT ROW 3.25 COL 78 WIDGET-ID 58
     T-C AT ROW 3.25 COL 85 WIDGET-ID 60
     T-O AT ROW 3.25 COL 91 WIDGET-ID 64
     tt-prop-map.node-type AT ROW 3.67 COL 9 COLON-ALIGNED WIDGET-ID 18
          LABEL "Тип узла" FORMAT "9"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Item 1",1
          DROP-DOWN-LIST
          SIZE 24.5 BY 1
     tt-prop-map.node-value-type AT ROW 3.67 COL 46 COLON-ALIGNED WIDGET-ID 20
          LABEL "Тип данных" FORMAT "X(20)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 23 BY 1
     tt-prop-map.is-collection AT ROW 5 COL 11 WIDGET-ID 54
          LABEL "Коллекция"
          VIEW-AS TOGGLE-BOX
          SIZE 24 BY 1
     cb-object-type AT ROW 5 COL 46 COLON-ALIGNED WIDGET-ID 42
     tt-prop-map.is-term AT ROW 5 COL 74.5 WIDGET-ID 62
          LABEL "Терминальный"
          VIEW-AS TOGGLE-BOX
          SIZE 16.5 BY 1.07
     tt-prop-map.node-name AT ROW 6.33 COL 15 COLON-ALIGNED WIDGET-ID 16
          LABEL "Имя свойства"
          VIEW-AS FILL-IN
          SIZE 76.5 BY 1
     tt-prop-map.node-label AT ROW 7.67 COL 15 COLON-ALIGNED WIDGET-ID 22
          LABEL "Лейбл" FORMAT "x(255)"
          VIEW-AS FILL-IN
          SIZE 76.5 BY 1
     tt-prop-map.init-value-character AT ROW 9 COL 15 COLON-ALIGNED WIDGET-ID 24
          LABEL "Нач.знач." FORMAT "X(255)"
          VIEW-AS FILL-IN
          SIZE 76.5 BY 1
     tt-prop-map.init-value-date AT ROW 10.33 COL 15 COLON-ALIGNED WIDGET-ID 26
          LABEL "Нач.знач."
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-prop-map.node-format AT ROW 10.57 COL 62.5 COLON-ALIGNED WIDGET-ID 52
          LABEL "Формат" FORMAT "X(22)"
          VIEW-AS FILL-IN
          SIZE 29 BY 1
     tt-prop-map.init-value-decimal AT ROW 11.67 COL 15 COLON-ALIGNED WIDGET-ID 28
          LABEL "Нач.знач." FORMAT "->,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 28.5 BY 1
     tt-prop-map.init-value-integer AT ROW 13 COL 15 COLON-ALIGNED WIDGET-ID 30
          LABEL "Нач.знач."
          VIEW-AS FILL-IN
          SIZE 28.5 BY 1
     tt-prop-map.init-value-logical AT ROW 14.33 COL 17 WIDGET-ID 34
          LABEL "Нач.знач."
          VIEW-AS TOGGLE-BOX
          SIZE 23.5 BY .8
     tt-prop-map.node-description AT ROW 16.2 COL 1 NO-LABEL WIDGET-ID 12
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 6.57
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     "Описание" VIEW-AS TEXT
          SIZE 14.5 BY .77 AT ROW 15.13 COL 1.5 WIDGET-ID 14
     SPACE(83.50) SKIP(7.34)
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
      TABLE: tt-prop-map T "?" NO-UNDO ub prop-map
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

/* SETTINGS FOR FILL-IN tt-prop-map.dtm-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-prop-map.init-value-character IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-prop-map.init-value-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-prop-map.init-value-decimal IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-prop-map.init-value-integer IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-prop-map.init-value-logical IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-prop-map.is-collection IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-prop-map.is-term IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-prop-map.node-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-prop-map.node-format IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-prop-map.node-label IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-prop-map.node-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX tt-prop-map.node-type IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR COMBO-BOX tt-prop-map.node-value-type IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-prop-map.upper-node-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-prop-map.upper-node-name IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-prop-map"
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


&Scoped-define SELF-NAME b-upper-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-upper-code Dialog-Frame
ON CHOOSE OF b-upper-code IN FRAME Dialog-Frame /* Btn 1 */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-map FOR ub.prop-map.
    run rul/prop-map-s.w (
                           input parparentproc
                          ,INPUT 'b-sel':U /* bttns */
                          ,INPUT "dtm-code" /* p-list-mode */
                          ,INPUT tt-prop-map.dtm-code
                          ,INPUT-OUTPUT v-rid-list) NO-ERROR.
IF ERROR-STATUS:ERROR
OR v-rid-list = '':U THEN RETURN NO-APPLY.
FIND FIRST buf_prop-map NO-LOCK WHERE
          recid(buf_prop-map) = INTEGER(v-rid-list).
ASSIGN
tt-prop-map.upper-node-code = buf_prop-map.node-code
tt-prop-map.upper-node-name = buf_prop-map.node-name
.
DISPLAY
tt-prop-map.upper-node-code
tt-prop-map.upper-node-name
WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-prop-map.dtm-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-prop-map.dtm-code Dialog-Frame
ON LEAVE OF tt-prop-map.dtm-code IN FRAME Dialog-Frame /* Код объекта */
DO:
  ASSIGN
  tt-prop-map.dtm-code.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-prop-map.node-value-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-prop-map.node-value-type Dialog-Frame
ON VALUE-CHANGED OF tt-prop-map.node-value-type IN FRAME Dialog-Frame /* Тип данных */
DO:
  ASSIGN
  tt-prop-map.node-value-type.
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
  IF p-dtm-code = 0 THEN DO:
    MESSAGE "Не задан ID термина в словаре"
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
  IF p-mode = {&add-def} THEN DO:
    /*заблокируем*/
    FIND FIRST locked_prop-head EXCLUSIVE-LOCK WHERE
            LOCKED_prop-head.dtm-code = p-dtm-code .
    CREATE tt-prop-map.
    FIND LAST LAST_prop-map NO-LOCK WHERE
            last_prop-map.dtm-code = p-dtm-code  NO-ERROR.
    ASSIGN
    tt-prop-map.node-code = (IF AVAILABLE LAST_prop-map
                                  THEN LAST_prop-map.node-code + 1
                                  ELSE 1)
    tt-prop-map.dtm-code = (if p-dtm-code > 0 then p-dtm-code else 0)
    .
  END.
  else do:
    IF p-mode = {&UPDATE} THEN DO:
        FIND FIRST locked_prop-head EXCLUSIVE-LOCK WHERE
                LOCKED_prop-head.dtm-code = p-dtm-code .
        FIND FIRST locked_prop-map EXCLUSIVE-LOCK WHERE
                LOCKED_prop-map.dtm-code = p-dtm-code
            AND LOCKED_prop-map.node-code = p-node-code.
    END.
    IF p-mode = {&LOOKUP} THEN DO:
        FIND FIRST locked_prop-head no-lock WHERE
                LOCKED_prop-head.dtm-code = p-dtm-code
            .
        FIND FIRST locked_prop-map no-LOCK WHERE
                LOCKED_prop-map.dtm-code = p-dtm-code
            AND LOCKED_prop-map.node-code = p-node-code.

    END.
    create tt-prop-map.
    buffer-copy locked_prop-map to tt-prop-map.
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
  DISPLAY T-R T-W T-C T-O cb-object-type
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-prop-map THEN
    DISPLAY tt-prop-map.dtm-code tt-prop-map.node-code tt-prop-map.upper-node-code
          tt-prop-map.upper-node-name tt-prop-map.node-type
          tt-prop-map.node-value-type tt-prop-map.is-collection
          tt-prop-map.is-term tt-prop-map.node-name tt-prop-map.node-label
          tt-prop-map.init-value-character tt-prop-map.init-value-date
          tt-prop-map.node-format tt-prop-map.init-value-decimal
          tt-prop-map.init-value-integer tt-prop-map.init-value-logical
          tt-prop-map.node-description
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit tt-prop-map.dtm-code tt-prop-map.node-code B-Help
         tt-prop-map.upper-node-code b-upper-code T-R T-W T-C T-O
         tt-prop-map.node-type tt-prop-map.node-value-type
         tt-prop-map.is-collection cb-object-type tt-prop-map.is-term
         tt-prop-map.node-name tt-prop-map.node-label
         tt-prop-map.init-value-character tt-prop-map.init-value-date
         tt-prop-map.node-format tt-prop-map.init-value-decimal
         tt-prop-map.init-value-integer tt-prop-map.init-value-logical
         tt-prop-map.node-description
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-item-pairs AS CHARACTER NO-UNDO.
DO v-ii = 1 TO NUM-ENTRIES({&xml-ntype-list}):
  ASSIGN
  v-item-pairs = v-item-pairs + {&comma-char} +
                 ENTRY(v-ii,{&xml-ntype-list-full}) + {&comma-char} + ENTRY(v-ii,{&xml-ntype-list}).
END.
v-item-pairs = TRIM(v-item-pairs, {&comma-char}).

ASSIGN
tt-prop-map.node-value-type:LIST-ITEMS IN FRAME {&FRAME-NAME} = {&ABL-simple-datatype-list}
tt-prop-map.node-type:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = v-item-pairs
cb-object-type:LIST-ITEMS IN FRAME {&FRAME-NAME} = ",r-b,dis-card"
.
assign
cb-object-type = (if num-entries(tt-prop-map.node-value-type) > 1
                  then entry(2, tt-prop-map.node-value-type)
                  else '':U)
tt-prop-map.node-value-type = entry(1, tt-prop-map.node-value-type)
t-r = (index(tt-prop-map.rw-option, "R") > 0)
t-W = (index(tt-prop-map.rw-option, "W") > 0)
t-C = (index(tt-prop-map.rw-option, "C") > 0)
t-O = (index(tt-prop-map.rw-option, "O") > 0)
.

IF AVAILABLE tt-prop-map THEN
DISPLAY
t-r
t-w
t-c
t-o
tt-prop-map.dtm-code
tt-prop-map.node-code
tt-prop-map.upper-node-code
tt-prop-map.upper-node-name
tt-prop-map.node-type
tt-prop-map.node-value-type
tt-prop-map.node-name
tt-prop-map.node-format
tt-prop-map.is-collection
tt-prop-map.node-label
tt-prop-map.is-term
tt-prop-map.init-value-character WHEN tt-prop-map.node-value-type = {&abl-datatype-character}
tt-prop-map.init-value-date WHEN tt-prop-map.node-value-type = {&abl-datatype-date}
tt-prop-map.init-value-decimal WHEN tt-prop-map.node-value-type = {&abl-datatype-decimal}
tt-prop-map.init-value-integer WHEN tt-prop-map.node-value-type = {&abl-datatype-integer}
tt-prop-map.init-value-logical WHEN tt-prop-map.node-value-type = {&abl-datatype-logical}
tt-prop-map.node-description
WITH FRAME {&frame-name} .
ENABLE
B-exit  when p-mode <> {&lookup}
b-quit
B-Help
tt-prop-map.dtm-code when (p-mode = {&add-def} and p-dtm-code = 0)
tt-prop-map.node-type when p-mode <> {&lookup}
tt-prop-map.node-value-type when p-mode <> {&lookup}
tt-prop-map.node-name       when p-mode <> {&lookup}
tt-prop-map.node-label when p-mode <> {&lookup}
tt-prop-map.node-format when p-mode <> {&lookup}
tt-prop-map.node-description when p-mode <> {&lookup}
tt-prop-map.is-term when p-mode <> {&lookup}
b-upper-code WHEN p-mode <> {&LOOKUP}
t-r WHEN p-mode <> {&LOOKUP}
t-w WHEN p-mode <> {&LOOKUP}
t-c WHEN p-mode <> {&LOOKUP}
t-o WHEN p-mode <> {&LOOKUP}
WITH FRAME {&frame-name} .

if p-mode = {&lookup} then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1.
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
IF p-mode = {&LOOKUP} THEN DO:
    RETURN.
END.
IF p-mode = {&update} THEN DO:
  v-rec = p-rec .
END.
ASSIGN
FRAME {&FRAME-NAME}
t-r
t-w
t-c
t-o
tt-prop-map.dtm-code
tt-prop-map.node-code
tt-prop-map.upper-node-code
tt-prop-map.upper-node-name
tt-prop-map.rw-option = (IF t-r THEN "R" ELSE "":U) +
                        (IF t-W THEN "W" ELSE "":U) +
                        (IF t-c THEN "C" ELSE "":U) +
                        (IF t-o THEN "O" ELSE "":U)
tt-prop-map.node-type
tt-prop-map.node-name
tt-prop-map.node-label
tt-prop-map.is-term
cb-object-type
tt-prop-map.node-value-type
tt-prop-map.node-value-type = tt-prop-map.node-value-type + {&comma-char} + cb-object-type
tt-prop-map.node-description
tt-prop-map.is-collection
tt-prop-map.node-format
tt-prop-map.init-value-character WHEN tt-prop-map.node-value-type = {&abl-datatype-character}
tt-prop-map.init-value-date WHEN tt-prop-map.node-value-type = {&abl-datatype-date}
tt-prop-map.init-value-decimal WHEN tt-prop-map.node-value-type = {&abl-datatype-decimal}
tt-prop-map.init-value-integer WHEN tt-prop-map.node-value-type = {&abl-datatype-integer}
tt-prop-map.init-value-logical WHEN tt-prop-map.node-value-type = {&abl-datatype-logical}
.
run rul/prop-map1.p ( INPUT p-mode
                ,INPUT NO /*p-silent*/
                ,INPUT-OUTPUT v-rec
                ,INPUT tt-prop-map.dtm-code
                ,INPUT tt-prop-map.node-code
                ,INPUT tt-prop-map.upper-node-code
                ,INPUT tt-prop-map.upper-node-name
                ,INPUT tt-prop-map.node-type
                ,INPUT tt-prop-map.is-collection
                ,INPUT tt-prop-map.rw-option
                ,INPUT tt-prop-map.node-name
                ,INPUT tt-prop-map.node-label
                ,INPUT tt-prop-map.node-value-type
                ,INPUT tt-prop-map.node-format
                ,INPUT tt-prop-map.node-description
                ,INPUT tt-prop-map.is-term
                ,INPUT tt-prop-map.init-value-character
                ,INPUT tt-prop-map.init-value-date
                ,INPUT tt-prop-map.init-value-decimal
                ,INPUT tt-prop-map.init-value-integer
                ,INPUT tt-prop-map.init-value-logical
               ) no-error.
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
tt-prop-map.init-value-character  IN FRAME {&FRAME-NAME}
tt-prop-map.init-value-date
tt-prop-map.init-value-decimal
tt-prop-map.init-value-integer
tt-prop-map.init-value-logical
.
DISABLE
tt-prop-map.init-value-character
tt-prop-map.init-value-date
tt-prop-map.init-value-decimal
tt-prop-map.init-value-integer
tt-prop-map.init-value-logical
with FRAME {&FRAME-NAME}.
CASE tt-prop-map.node-value-type:
  WHEN {&abl-datatype-character} THEN DO:
     DISPLAY
     tt-prop-map.init-value-character
     WITH FRAME {&FRAME-NAME}.
     ENABLE
     tt-prop-map.init-value-character WHEN p-mode <> {&LOOKUP}
     WITH FRAME {&FRAME-NAME}.
  END.
  WHEN {&abl-datatype-date} THEN DO:
     DISPLAY
     tt-prop-map.init-value-date
     WITH FRAME {&FRAME-NAME}.
     ENABLE
     tt-prop-map.init-value-date WHEN p-mode <> {&LOOKUP}
     WITH FRAME {&FRAME-NAME}.
  END.
  WHEN {&abl-datatype-decimal} THEN DO:
     DISPLAY
     tt-prop-map.init-value-decimal
     WITH FRAME {&FRAME-NAME}.
     ENABLE
     tt-prop-map.init-value-decimal WHEN p-mode <> {&LOOKUP}
     WITH FRAME {&FRAME-NAME}.
  END.
  WHEN {&abl-datatype-integer} THEN DO:
     DISPLAY
     tt-prop-map.init-value-integer
     WITH FRAME {&FRAME-NAME}.
     ENABLE
     tt-prop-map.init-value-integer WHEN p-mode <> {&LOOKUP}
     WITH FRAME {&FRAME-NAME}.
  END.
  WHEN {&abl-datatype-logical} THEN DO:
     DISPLAY
     tt-prop-map.init-value-logical
     WITH FRAME {&FRAME-NAME}.
     ENABLE
     tt-prop-map.init-value-logical WHEN p-mode <> {&LOOKUP}
     WITH FRAME {&FRAME-NAME}.
  END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE switch-main-widgets Dialog-Frame
PROCEDURE switch-main-widgets :
/*проверим что можно редактировать всякие важдые свойства*/
DEFINE INPUT parameter p-mode AS CHARACTER NO-UNDO.
define buffer buf_prop-script for ub.prop-script.
find first buf_prop-script NO-LOCK WHERE
            buf_prop-script.dtm-code = tt-prop-map.dtm-code  no-error.
IF AVAILABLE buf_prop-script THEN DO:


END.
IF (LOCKED_prop-head.storage-place = '':U
   OR LOCKED_prop-head.storage-place = {&question-mark}
    )
    AND
    (LOCKED_prop-head.storage-place-host = '':U
     OR
     LOCKED_prop-head.storage-place-host = {&question-mark})
AND
    (LOCKED_prop-head.storage-place-obj = '':U
     OR
     LOCKED_prop-head.storage-place-obj = {&question-mark})

    THEN DO:

END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
