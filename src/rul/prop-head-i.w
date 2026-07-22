&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_prop-head FOR ub.prop-head.
DEFINE TEMP-TABLE tt-prop-head NO-UNDO LIKE ub.prop-head.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка prop-head


Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/07
Author: Bakhtadze Natalya
Creation date: 02/11/07

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-dtm-code AS INTEGER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка prop-head".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
DEFINE BUFFER FIRST_prop-head FOR dictdb.prop-head.
DEFINE BUFFER buf_prop-head FOR dictdb.prop-head.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-prop-head

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-prop-head.dtm-code ~
tt-prop-head.prop-name tt-prop-head.prop-label tt-prop-head.prop-des ~
tt-prop-head.hist-from-prim tt-prop-head.storage-place ~
tt-prop-head.hist-to-nws tt-prop-head.storage-place-host ~
tt-prop-head.nws-to-hist tt-prop-head.storage-place-obj ~
tt-prop-head.smart-nws tt-prop-head.get-hist-from-nws ~
tt-prop-head.nws-to-cd tt-prop-head.ref-type
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-prop-head.dtm-code ~
tt-prop-head.prop-name tt-prop-head.prop-label tt-prop-head.prop-des ~
tt-prop-head.hist-from-prim tt-prop-head.storage-place ~
tt-prop-head.hist-to-nws tt-prop-head.storage-place-host ~
tt-prop-head.nws-to-hist tt-prop-head.storage-place-obj ~
tt-prop-head.smart-nws tt-prop-head.get-hist-from-nws ~
tt-prop-head.nws-to-cd tt-prop-head.ref-type
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-prop-head
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-prop-head
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-prop-head SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-prop-head SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-prop-head
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-prop-head


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-prop-head.dtm-code tt-prop-head.prop-name ~
tt-prop-head.prop-label tt-prop-head.prop-des tt-prop-head.hist-from-prim ~
tt-prop-head.storage-place tt-prop-head.hist-to-nws ~
tt-prop-head.storage-place-host tt-prop-head.nws-to-hist ~
tt-prop-head.storage-place-obj tt-prop-head.smart-nws ~
tt-prop-head.get-hist-from-nws tt-prop-head.nws-to-cd tt-prop-head.ref-type
&Scoped-define ENABLED-TABLES tt-prop-head
&Scoped-define FIRST-ENABLED-TABLE tt-prop-head
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help f-hist-from-prim ~
f-hist-to-nws f-nws-to-hist f-smart-nws f-get-hist-from-nws list-general ~
f-nws-to-cd cb-select-general b-general-add b-general-del list-general-view ~
cb-select-general-view b-general-view-add b-general-view-del
&Scoped-Define DISPLAYED-FIELDS tt-prop-head.dtm-code ~
tt-prop-head.prop-name tt-prop-head.prop-label tt-prop-head.prop-des ~
tt-prop-head.hist-from-prim tt-prop-head.storage-place ~
tt-prop-head.hist-to-nws tt-prop-head.storage-place-host ~
tt-prop-head.nws-to-hist tt-prop-head.storage-place-obj ~
tt-prop-head.smart-nws tt-prop-head.get-hist-from-nws ~
tt-prop-head.nws-to-cd tt-prop-head.ref-type
&Scoped-define DISPLAYED-TABLES tt-prop-head
&Scoped-define FIRST-DISPLAYED-TABLE tt-prop-head
&Scoped-Define DISPLAYED-OBJECTS f-hist-from-prim f-hist-to-nws ~
f-nws-to-hist f-smart-nws f-get-hist-from-nws list-general f-nws-to-cd ~
cb-select-general list-general-view cb-select-general-view

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

DEFINE BUTTON b-general-add
     LABEL "Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-general-del
     LABEL "Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-general-view-add
     LABEL "Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-general-view-del
     LABEL "Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE cb-select-general AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 24 BY 1 NO-UNDO.

DEFINE VARIABLE cb-select-general-view AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 24 BY 1 NO-UNDO.

DEFINE VARIABLE f-get-hist-from-nws AS CHARACTER FORMAT "X(256)":U INITIAL "Принимает историю из чужих БД"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE f-hist-from-prim AS CHARACTER FORMAT "X(256)":U INITIAL "Запись истории при изменении"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE f-hist-to-nws AS CHARACTER FORMAT "X(256)":U INITIAL "Передача истории в другие БД"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE f-nws-to-cd AS CHARACTER FORMAT "X(256)":U INITIAL "Активация пер-чи на кассу из СПН"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE f-nws-to-hist AS CHARACTER FORMAT "X(256)":U INITIAL "Создание истории при приходе СПН"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE f-smart-nws AS CHARACTER FORMAT "X(256)":U INITIAL "Смарт-передача через СПН"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE list-general AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     LIST-ITEM-PAIRS "1","1"
     SIZE 24 BY 8 NO-UNDO.

DEFINE VARIABLE list-general-view AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     LIST-ITEM-PAIRS "1","1"
     SIZE 24 BY 6.13 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-prop-head SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     tt-prop-head.dtm-code AT ROW 1 COL 34 COLON-ALIGNED WIDGET-ID 2
          LABEL "Код"
          VIEW-AS FILL-IN
          SIZE 14 BY 1
     B-Help AT ROW 1 COL 54.9
     tt-prop-head.prop-name AT ROW 2.33 COL 9 COLON-ALIGNED WIDGET-ID 4
          LABEL "Название" FORMAT "X(255)"
          VIEW-AS FILL-IN NATIVE
          SIZE 87 BY 1
     tt-prop-head.prop-label AT ROW 3.57 COL 9 COLON-ALIGNED WIDGET-ID 6
          LABEL "Лейбл" FORMAT "X(255)"
          VIEW-AS FILL-IN NATIVE
          SIZE 87 BY 1
     tt-prop-head.prop-des AT ROW 5.8 COL 1 NO-LABEL WIDGET-ID 8
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 4.77
     f-hist-from-prim AT ROW 10.87 COL 48.5 COLON-ALIGNED NO-LABEL WIDGET-ID 90
     tt-prop-head.hist-from-prim AT ROW 10.87 COL 76.5 NO-LABEL WIDGET-ID 52
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Всегда", 10,
"Да", 0,
"Нет", -1,
"Никогда", -10
          SIZE 23 BY 1.07
          FONT 4
     tt-prop-head.storage-place AT ROW 11.13 COL 16 COLON-ALIGNED WIDGET-ID 14
          LABEL "Хранение глоб" FORMAT "X(32)"
          VIEW-AS FILL-IN NATIVE
          SIZE 32 BY 1
     f-hist-to-nws AT ROW 11.87 COL 48.5 COLON-ALIGNED NO-LABEL WIDGET-ID 92
     tt-prop-head.hist-to-nws AT ROW 11.87 COL 76.5 NO-LABEL WIDGET-ID 58
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Всегда", 10,
"Да", 0,
"Нет", -1,
"Никогда", -10
          SIZE 23 BY 1.07
          FONT 4
     tt-prop-head.storage-place-host AT ROW 12.37 COL 16 COLON-ALIGNED WIDGET-ID 16
          LABEL "Хранение фирма" FORMAT "X(32)"
          VIEW-AS FILL-IN NATIVE
          SIZE 32 BY 1
     f-nws-to-hist AT ROW 12.87 COL 48.5 COLON-ALIGNED NO-LABEL WIDGET-ID 94
     tt-prop-head.nws-to-hist AT ROW 12.87 COL 76.5 NO-LABEL WIDGET-ID 64
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Всегда", 10,
"Да", 0,
"Нет", -1,
"Никогда", -10
          SIZE 23 BY 1.07
          FONT 4
     tt-prop-head.storage-place-obj AT ROW 13.63 COL 16 COLON-ALIGNED WIDGET-ID 18
          LABEL "Хранение объект" FORMAT "X(32)"
          VIEW-AS FILL-IN NATIVE
          SIZE 32 BY 1
     f-smart-nws AT ROW 13.87 COL 48.5 COLON-ALIGNED NO-LABEL WIDGET-ID 96
     tt-prop-head.smart-nws AT ROW 13.87 COL 76.5 NO-LABEL WIDGET-ID 70
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Всегда", 10,
"Да", 0,
"Нет", -1,
"Никогда", -10
          SIZE 23 BY 1.07
          FONT 4
     f-get-hist-from-nws AT ROW 14.87 COL 48.5 COLON-ALIGNED NO-LABEL WIDGET-ID 98
     tt-prop-head.get-hist-from-nws AT ROW 14.87 COL 76.5 NO-LABEL WIDGET-ID 76
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Всегда", 10,
"Да", 0,
"Нет", -1,
"Никогда", -10
          SIZE 23 BY 1.07
          FONT 4
     list-general AT ROW 15.13 COL 25.5 NO-LABEL WIDGET-ID 34
     f-nws-to-cd AT ROW 15.87 COL 48.5 COLON-ALIGNED NO-LABEL WIDGET-ID 100
     tt-prop-head.nws-to-cd AT ROW 15.87 COL 76.5 NO-LABEL WIDGET-ID 84
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Всегда", 10,
"Да", 0,
"Нет", -1,
"Никогда", -10
          SIZE 23 BY 1.07
          FONT 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     cb-select-general AT ROW 16 COL 1 NO-LABEL WIDGET-ID 32
     b-general-add AT ROW 17 COL 1 WIDGET-ID 44
     b-general-del AT ROW 17 COL 15.5 WIDGET-ID 48
     list-general-view AT ROW 17 COL 75.5 NO-LABEL WIDGET-ID 38
     tt-prop-head.ref-type AT ROW 18.87 COL 1.5 NO-LABEL WIDGET-ID 102
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "Item 1", "1":U,
"Item 2", "2":U
          SIZE 23.5 BY 4.4
     cb-select-general-view AT ROW 19 COL 51 NO-LABEL WIDGET-ID 36
     b-general-view-add AT ROW 19.93 COL 51 WIDGET-ID 46
     b-general-view-del AT ROW 19.93 COL 65.5 WIDGET-ID 50
     "Описание" VIEW-AS TEXT
          SIZE 17.5 BY 1 AT ROW 4.83 COL 2.5 WIDGET-ID 10
     "Предназначение" VIEW-AS TEXT
          SIZE 24 BY 1 AT ROW 15 COL 1 WIDGET-ID 40
          FGCOLOR 3
     "Представление" VIEW-AS TEXT
          SIZE 24 BY 1 AT ROW 18 COL 51 WIDGET-ID 42
          FGCOLOR 3
     "Тип итогов/срезов" VIEW-AS TEXT
          SIZE 24 BY 1 AT ROW 18.07 COL 1 WIDGET-ID 106
          FGCOLOR 3
     SPACE(74.69) SKIP(4.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Объект rule-машины"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_prop-head B "?" ? ub prop-head
      TABLE: tt-prop-head T "?" NO-UNDO ub prop-head
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

/* SETTINGS FOR COMBO-BOX cb-select-general IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR COMBO-BOX cb-select-general-view IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN tt-prop-head.dtm-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       f-get-hist-from-nws:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       f-hist-from-prim:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       f-hist-to-nws:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       f-nws-to-cd:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       f-nws-to-hist:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       f-smart-nws:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN tt-prop-head.prop-label IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-prop-head.prop-name IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-prop-head.storage-place IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-prop-head.storage-place-host IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-prop-head.storage-place-obj IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-prop-head"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Объект rule-машины */
DO:
    RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Объект rule-машины */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-general-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-general-add Dialog-Frame
ON CHOOSE OF b-general-add IN FRAME Dialog-Frame /* Добавить */
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  IF cb-select-general = '':U THEN DO:
    MESSAGE
    "Нечего добавлять"
    VIEW-AS ALERT-BOX ERROR.
    RETURN  NO-APPLY.
  END.
  IF LOOKUP(cb-select-general, list-general) > 0 THEN DO:
      MESSAGE
      "Объект уже имеет данное предназначение"
      VIEW-AS ALERT-BOX ERROR.
      RETURN  NO-APPLY.
  END.

  &SCOPED-DEFINE prop-head-general-code cb-select-general
  glog = list-general:ADD-LAST({&prop-head-general-name}, cb-select-general) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     RETURN NO-APPLY.
  END.
  DISPLAY
  list-general
  WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-general-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-general-del Dialog-Frame
ON CHOOSE OF b-general-del IN FRAME Dialog-Frame /* Удалить */
DO:
  IF list-general:SCREEN-VALUE  = '':U
  OR list-general:SCREEN-VALUE  = ?
  OR list-general:IS-SELECTED(INPUT FRAME {&FRAME-NAME} list-general) = NO
  THEN DO:
     MESSAGE
     "Нечего удалять"
     VIEW-AS ALERT-BOX .
     RETURN NO-APPLY.
  END.
  list-general:DELETE(INPUT FRAME {&FRAME-NAME} list-general).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-general-view-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-general-view-add Dialog-Frame
ON CHOOSE OF b-general-view-add IN FRAME Dialog-Frame /* Добавить */
DO:
    DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
    IF cb-select-general-view = '':U THEN DO:
      MESSAGE
      "Нечего добавлять"
      VIEW-AS ALERT-BOX ERROR.
      RETURN  NO-APPLY.
    END.
    IF LOOKUP(cb-select-general-view, list-general-view) > 0 THEN DO:
        MESSAGE
        "Объект уже имеет данное предназначение"
        VIEW-AS ALERT-BOX ERROR.
        RETURN  NO-APPLY.
    END.

    &SCOPED-DEFINE prop-head-general-code cb-select-general-view
    glog = list-general-view:ADD-LAST({&prop-head-general-view-name}, cb-select-general-view) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
    END.
    DISPLAY
    list-general-view
    WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-general-view-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-general-view-del Dialog-Frame
ON CHOOSE OF b-general-view-del IN FRAME Dialog-Frame /* Удалить */
DO:
  IF list-general-view:SCREEN-VALUE = '':U
  OR list-general-view:SCREEN-VALUE  = ?
  OR list-general-view:IS-SELECTED(INPUT FRAME {&FRAME-NAME} list-general-view) = NO
  THEN DO:
     MESSAGE
     "Нечего удалять"
     VIEW-AS ALERT-BOX .
     RETURN NO-APPLY.
  END.
  list-general-view:DELETE(INPUT FRAME {&FRAME-NAME} list-general-view).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-select-general
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-select-general Dialog-Frame
ON VALUE-CHANGED OF cb-select-general IN FRAME Dialog-Frame
DO:
  ASSIGN
  cb-select-general.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-select-general-view
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-select-general-view Dialog-Frame
ON VALUE-CHANGED OF cb-select-general-view IN FRAME Dialog-Frame
DO:
  ASSIGN
  cb-select-general-view.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-prop-head.ref-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-prop-head.ref-type Dialog-Frame
ON VALUE-CHANGED OF tt-prop-head.ref-type IN FRAME Dialog-Frame
DO:
  ASSIGN
  tt-prop-head.ref-type.

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
    FIND FIRST first_prop-head EXCLUSIVE-LOCK.
    CREATE tt-prop-head.
  END.
  else do:
    IF p-mode = {&UPDATE} THEN DO:
      FIND FIRST LOCKED_prop-head EXCLUSIVE-LOCK WHERE
                LOCKED_prop-head.dtm-code = p-dtm-code .
    END.
    IF p-mode = {&LOOKUP} THEN DO:
        FIND FIRST LOCKED_prop-head no-LOCK WHERE
                  LOCKED_prop-head.dtm-code = p-dtm-code NO-ERROR.
    END.
    create tt-prop-head.
    buffer-copy locked_prop-head to tt-prop-head.
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
  DISPLAY f-hist-from-prim f-hist-to-nws f-nws-to-hist f-smart-nws
          f-get-hist-from-nws list-general f-nws-to-cd cb-select-general
          list-general-view cb-select-general-view
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-prop-head THEN
    DISPLAY tt-prop-head.dtm-code tt-prop-head.prop-name tt-prop-head.prop-label
          tt-prop-head.prop-des tt-prop-head.hist-from-prim
          tt-prop-head.storage-place tt-prop-head.hist-to-nws
          tt-prop-head.storage-place-host tt-prop-head.nws-to-hist
          tt-prop-head.storage-place-obj tt-prop-head.smart-nws
          tt-prop-head.get-hist-from-nws tt-prop-head.nws-to-cd
          tt-prop-head.ref-type
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit tt-prop-head.dtm-code B-Help tt-prop-head.prop-name
         tt-prop-head.prop-label tt-prop-head.prop-des f-hist-from-prim
         tt-prop-head.hist-from-prim tt-prop-head.storage-place f-hist-to-nws
         tt-prop-head.hist-to-nws tt-prop-head.storage-place-host f-nws-to-hist
         tt-prop-head.nws-to-hist tt-prop-head.storage-place-obj f-smart-nws
         tt-prop-head.smart-nws f-get-hist-from-nws
         tt-prop-head.get-hist-from-nws list-general f-nws-to-cd
         tt-prop-head.nws-to-cd cb-select-general b-general-add b-general-del
         list-general-view tt-prop-head.ref-type cb-select-general-view
         b-general-view-add b-general-view-del
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-general AS character  NO-UNDO.
DEFINE VARIABLE v-general-view AS character  NO-UNDO.
DEFINE VARIABLE v-ii AS integer  NO-UNDO.
DEFINE VARIABLE v-dop AS CHARACTER.
v-dop = "Не предусмотрено,,".
DO v-ii = 1 TO NUM-ENTRIES({&sum-id-type-list}):
   ASSIGN
   v-dop = v-dop + ENTRY(v-ii, {&sum-id-type-list-full}) + {&comma-char} +
           ENTRY(v-ii, {&sum-id-type-list}) + {&comma-char}.
END.
ASSIGN
v-dop = TRIM(v-dop, {&comma-char}).
ASSIGN
tt-prop-head.ref-type:radio-buttons IN FRAME {&FRAME-NAME} = v-dop.

ASSIGN
tt-prop-head.get-hist-from-nws:RADIO-BUTTONS IN FRAME {&FRAME-NAME} = {&hn-option-radio-buttons}
tt-prop-head.hist-from-prim:RADIO-BUTTONS IN FRAME {&FRAME-NAME} = {&hn-option-radio-buttons}
tt-prop-head.hist-to-nws:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =  {&hn-option-radio-buttons}
tt-prop-head.nws-to-cd:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =  {&hn-option-radio-buttons}
tt-prop-head.nws-to-hist:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =  {&hn-option-radio-buttons}
tt-prop-head.smart-nws:RADIO-BUTTONS IN FRAME {&FRAME-NAME} = {&hn-option-radio-buttons}
.
&SCOPED-DEFINE prop-head-general-code ENTRY(v-ii, tt-prop-head.general)
DO v-ii = 1 TO NUM-ENTRIES(tt-prop-head.general):
  assign
  v-general = v-general + {&comma-char} +
              {&prop-head-general-name} + {&comma-char} +
               ENTRY(v-ii, tt-prop-head.general).
END.
v-general = LEFT-TRIM(v-general, {&comma-char}).
&SCOPED-DEFINE prop-head-general-code ENTRY(v-ii, tt-prop-head.general-view)
DO v-ii = 1 TO NUM-ENTRIES(tt-prop-head.general-view):
  assign
  v-general-view = v-general-view + {&comma-char} +
              {&prop-head-general-view-name} + {&comma-char} +
               ENTRY(v-ii, tt-prop-head.general-view).
END.
v-general-view = LEFT-TRIM(v-general-view, {&comma-char}).
IF v-general <> '':U THEN DO:
  ASSIGN
  list-general:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = v-general.

END.
ELSE DO:
  ASSIGN
  list-general:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = ",".
END.
IF v-general-view <> '':U THEN DO:
  ASSIGN
  list-general-view:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = v-general-view.
END.
ELSE DO:
  ASSIGN
  list-general-view:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = ",".
END.
ASSIGN
cb-select-general:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = {&prop-head-general-list-pairs}
cb-select-general-view:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = {&prop-head-general-view-list-pairs}
.
DISPLAY
f-get-hist-from-nws
f-hist-from-prim
f-hist-to-nws
f-nws-to-cd
f-nws-to-hist
f-smart-nws
WITH FRAME {&FRAME-NAME}.
IF AVAILABLE tt-prop-head THEN
DISPLAY
tt-prop-head.dtm-code
tt-prop-head.prop-name
tt-prop-head.prop-label
tt-prop-head.prop-des
tt-prop-head.storage-place
tt-prop-head.storage-place-host
tt-prop-head.storage-place-obj
tt-prop-head.hist-from-prim
tt-prop-head.hist-to-nws
tt-prop-head.nws-to-hist
tt-prop-head.nws-to-cd
tt-prop-head.smart-nws
tt-prop-head.get-hist-from-nws
tt-prop-head.ref-type
WITH FRAME {&frame-name}.
ENABLE
B-exit WHEN p-mode <> {&lookup}
b-quit
B-Help
tt-prop-head.dtm-code  WHEN p-mode = {&add-def}
tt-prop-head.prop-name  WHEN p-mode <> {&lookup}
tt-prop-head.prop-label  WHEN p-mode <> {&lookup}
tt-prop-head.prop-des    WHEN p-mode <> {&lookup}
tt-prop-head.storage-place WHEN p-mode = {&add-def}
tt-prop-head.storage-place-host WHEN p-mode = {&add-def}
tt-prop-head.storage-place-obj  WHEN p-mode = {&add-def}
tt-prop-head.hist-from-prim    WHEN (p-mode <> {&lookup} AND (
     tt-prop-head.hist-from-prim <> INTEGER({&hn-is-on-blocked})
 AND tt-prop-head.hist-from-prim <> INTEGER({&hn-is-off-blocked}) ))
tt-prop-head.hist-to-nws       WHEN (p-mode <> {&lookup} AND (
    tt-prop-head.hist-to-nws <> INTEGER({&hn-is-on-blocked})
 AND tt-prop-head.hist-to-nws <> INTEGER({&hn-is-off-blocked}) ))
tt-prop-head.nws-to-hist       WHEN (p-mode <> {&lookup} AND (
    tt-prop-head.nws-to-hist <> INTEGER({&hn-is-on-blocked})
 AND tt-prop-head.nws-to-hist <> INTEGER({&hn-is-off-blocked}) ))
tt-prop-head.nws-to-cd         WHEN (p-mode <> {&lookup} AND (
    tt-prop-head.nws-to-cd <> INTEGER({&hn-is-on-blocked})
 AND tt-prop-head.nws-to-cd <> INTEGER({&hn-is-off-blocked}) ))
tt-prop-head.smart-nws         WHEN (p-mode <> {&lookup} AND (
    tt-prop-head.smart-nws <> INTEGER({&hn-is-on-blocked})
 AND tt-prop-head.smart-nws <> INTEGER({&hn-is-off-blocked}) ))
tt-prop-head.get-hist-from-nws WHEN (p-mode <> {&lookup} AND (
    tt-prop-head.get-hist-from-nws <> INTEGER({&hn-is-on-blocked})
 AND tt-prop-head.get-hist-from-nws <> INTEGER({&hn-is-off-blocked}) ))
b-general-add WHEN p-mode <> {&lookup}
b-general-del WHEN p-mode <> {&lookup}
b-general-view-add WHEN p-mode <> {&lookup}
b-general-view-del WHEN p-mode <> {&lookup}
CB-select-general WHEN p-mode <> {&lookup}
CB-select-general-view WHEN p-mode <> {&lookup}
tt-prop-head.ref-type WHEN p-mode <> {&LOOKUP}
list-general
list-general-view
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
IF p-mode = {&LOOKUP} THEN DO:
  HIDE
  b-general-add
  b-general-view-add
  b-general-del
  b-general-view-del
  cb-select-general
  cb-select-general-view
  b-exit
  IN FRAME {&FRAME-NAME}.
  ASSIGN
  b-quit:LABEL = "&Отмена"
  b-quit:COLUMN = 1.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS recID  NO-UNDO.
DEFINE VARIABLE v-general AS character  NO-UNDO.
DEFINE VARIABLE v-general-view AS character  NO-UNDO.
DEFINE VARIABLE v-ii AS integer  NO-UNDO.
IF p-mode = {&LOOKUP} THEN DO:
    RETURN.
END.
IF p-mode = {&update} THEN DO:
  v-rec = p-rec.
END.
ASSIGN
FRAME {&FRAME-NAME}
tt-prop-head.dtm-code
tt-prop-head.prop-name
tt-prop-head.prop-label
tt-prop-head.prop-des
tt-prop-head.ref-type
tt-prop-head.storage-place
tt-prop-head.storage-place-host
tt-prop-head.storage-place-obj
.
IF  tt-prop-head.hist-from-prim <> INTEGER({&hn-is-on-blocked})
AND tt-prop-head.hist-from-prim <> INTEGER({&hn-is-off-blocked}) THEN DO:
 ASSIGN
 tt-prop-head.hist-from-prim .

END.
IF  tt-prop-head.hist-to-nws <> INTEGER({&hn-is-on-blocked})
AND tt-prop-head.hist-to-nws <> INTEGER({&hn-is-off-blocked}) THEN DO:
 ASSIGN
 tt-prop-head.hist-to-nws .

END.
IF  tt-prop-head.nws-to-cd <> INTEGER({&hn-is-on-blocked})
AND tt-prop-head.nws-to-cd <> INTEGER({&hn-is-off-blocked}) THEN DO:
 ASSIGN
 tt-prop-head.nws-to-cd .

END.
IF  tt-prop-head.nws-to-hist <> INTEGER({&hn-is-on-blocked})
AND tt-prop-head.nws-to-hist <> INTEGER({&hn-is-off-blocked}) THEN DO:
 ASSIGN
 tt-prop-head.nws-to-hist.
END.
IF  tt-prop-head.smart-nws <> INTEGER({&hn-is-on-blocked})
AND tt-prop-head.smart-nws <> INTEGER({&hn-is-off-blocked}) THEN DO:
 ASSIGN
 tt-prop-head.smart-nws .
END.
IF  tt-prop-head.get-hist-from-nws <> INTEGER({&hn-is-on-blocked})
AND tt-prop-head.get-hist-from-nws <> INTEGER({&hn-is-off-blocked}) THEN DO:
 ASSIGN
 tt-prop-head.get-hist-from-nws .

END.
DO v-ii = 1 TO NUM-ENTRIES(list-general:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME}) BY 2:
  v-general = v-general + {&comma-char} +  entry(v-ii + 1, list-general:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME}).
END.
v-general = TRIM(v-general, {&comma-char}).
tt-prop-head.general = v-general.
 .
DO v-ii = 1 TO NUM-ENTRIES(list-general-view:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME})  BY 2:
  v-general-view = v-general-view + {&comma-char} +  entry(v-ii + 1, list-general-view:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME}).
END.
v-general-view = TRIM(v-general-view, {&comma-char}).
tt-prop-head.general-view = v-general-view.
 .
run rul/prop-head1.p ( INPUT p-mode
                ,INPUT NO /*p-silent*/
                ,INPUT-OUTPUT v-rec
                ,INPUT tt-prop-head.dtm-code
                ,INPUT tt-prop-head.prop-name
                ,INPUT tt-prop-head.prop-label
                ,INPUT tt-prop-head.prop-des
                ,INPUT tt-prop-head.ref-type
                ,INPUT tt-prop-head.storage-place
                ,INPUT tt-prop-head.storage-place-host
                ,INPUT tt-prop-head.storage-place-obj
                ,INPUT tt-prop-head.hist-from-prim
                ,INPUT tt-prop-head.hist-to-nws
                ,INPUT tt-prop-head.get-hist-from-nws
                ,INPUT tt-prop-head.nws-to-hist
                ,INPUT tt-prop-head.smart-nws
                ,INPUT tt-prop-head.nws-to-cd
                ,INPUT tt-prop-head.general
                ,INPUT tt-prop-head.general-view
) no-error.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
p-rec = v-rec.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME