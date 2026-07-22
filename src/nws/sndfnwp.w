&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Окно ввода параметров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo .
/*{&update} {&lookup}*/
define input parameter p-list-mode as character no-undo .
/*"input" "output"*/
define input parameter p-db-num as integer no-undo .
define input parameter p-from-db-num as integer no-undo .
define input parameter p-file-num as integer no-undo .


/* Local Variable Definitions ---                                       */
DEFINE variable vss-revision    as character no-undo init "$Revision$":U .
DEFINE variable vss-author      as character no-undo init "$Author$":U .
DEFINE variable vss-date        as character no-undo init "$Date$":U .
DEFINE variable vss-workfile    as character no-undo init "$Workfile$":U .
DEFINE variable vss-archive     as character no-undo init "$Archive$":U .
DEFINE variable vss-description as character no-undo init "Окно ввода параметров".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ nws/bintrnpr.i " shared" }
{ gbl/color.i }
{ gbl/cur-time.i }
{ gbl/fileslsh.i }
{ gbl/key-rec.i }
{ rul/calldscr.i }
DEFINE VARIABLE add-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-num-params AS INTEGER NO-UNDO.
DEFINE VARIABLE v-run-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ibm-xml-mode AS logical NO-UNDO.

DEFINE BUFFER buf_Ext-file FOR ub.ext-file.

&SCOPED-DEFINE LABEL_cd "Касса"
&SCOPED-DEFINE LABEL_file "Файл"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME Br-params

/* External Tables                                                      */
&Scoped-define EXTERNAL-TABLES ub.ext-file-par
&Scoped-define FIRST-EXTERNAL-TABLE ub.ext-file-par


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR ub.ext-file-par.
/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-ext-file-par

/* Definitions for BROWSE Br-params                                     */
&Scoped-define FIELDS-IN-QUERY-Br-params tt-ext-file-par.param-name calldscr(tt-ext-file-par.param-name) tt-ext-file-par.param-value calldscr(tt-ext-file-par.param-value) tt-ext-file-par.param-date-name tt-ext-file-par.param-date-value tt-ext-file-par.param-int-name tt-ext-file-par.param-int-value tt-ext-file-par.param-log-name tt-ext-file-par.param-log-value
&Scoped-define ENABLED-FIELDS-IN-QUERY-Br-params tt-ext-file-par.param-value tt-ext-file-par.param-date-value tt-ext-file-par.param-int-value tt-ext-file-par.param-log-value
&Scoped-define ENABLED-TABLES-IN-QUERY-Br-params tt-ext-file-par
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Br-params tt-ext-file-par
&Scoped-define SELF-NAME Br-params
&Scoped-define QUERY-STRING-Br-params FOR EACH tt-ext-file-par  INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-Br-params OPEN QUERY {&SELF-NAME} FOR EACH tt-ext-file-par  INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-Br-params tt-ext-file-par
&Scoped-define FIRST-TABLE-IN-QUERY-Br-params tt-ext-file-par


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-Br-params}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-add B-del b-lkp B-Help Br-params

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-add
       MENU-ITEM m_character    LABEL "Символьный"
       MENU-ITEM m_date         LABEL "Дата"
       MENU-ITEM m_integer      LABEL "Целый"
       MENU-ITEM m_logical      LABEL "Логический"    .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Br-params FOR
      tt-ext-file-par SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE Br-params
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS Br-params Dialog-Frame _FREEFORM
  QUERY Br-params NO-LOCK DISPLAY
      tt-ext-file-par.param-name COLUMN-LABEL "Имя симв.!пар-ра" FORMAT "X(40)":U
    WIDTH 10
calldscr(tt-ext-file-par.param-name) COLUMN-LABEL {&LABEL_cd} FORMAT "X(255)":U
    WIDTH 40
tt-ext-file-par.param-value COLUMN-LABEL "Значение!симв. пар-ра" FORMAT "X(255)":U
    WIDTH 20
calldscr(tt-ext-file-par.param-value) COLUMN-LABEL {&LABEL_file} FORMAT "X(255)":U
    WIDTH 40
tt-ext-file-par.param-date-name COLUMN-LABEL "Имя пар-ра!типа ДАТА" FORMAT "X(40)":U
    WIDTH 10
tt-ext-file-par.param-date-value COLUMN-LABEL "Знач.пар-ра!типа ДАТА" FORMAT "99/99/9999":U
    WIDTH 10
tt-ext-file-par.param-int-name COLUMN-LABEL "Имя целого!пар-ра" FORMAT "X(40)":U
    WIDTH 10
tt-ext-file-par.param-int-value COLUMN-LABEL "Знач.целого!пар-ра" FORMAT "->,>>>,>>>,>>9":U
    WIDTH 15
tt-ext-file-par.param-log-name COLUMN-LABEL "Имя лог.!пар-ра" FORMAT "X(40)":U
    WIDTH 8
tt-ext-file-par.param-log-value COLUMN-LABEL "Знач.лог.!пар-ра" FORMAT "yes/no":U
    WIDTH 9
ENABLE
tt-ext-file-par.param-value
tt-ext-file-par.param-date-value
tt-ext-file-par.param-int-value
tt-ext-file-par.param-log-value
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.47 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-add AT ROW 1 COL 41
     B-del AT ROW 1 COL 51
     b-lkp AT ROW 1 COL 61 WIDGET-ID 2
     B-Help AT ROW 1 COL 88
     Br-params AT ROW 3 COL 1
     SPACE(0.59) SKIP(0.09)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   External Tables: ub.ext-file-par
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB Br-params B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE Br-params
/* Query rebuild information for BROWSE Br-params
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-ext-file-par  INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE Br-params */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  { gbl/stdbtn.i }
  IF add-option = '':U THEN DO:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  END.
  run proc-b-add IN THIS-PROCEDURE ( INPUT add-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
    add-option = ''.
    RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
    { gbl/stdbtn.i }
  DEFINE BUFFER buf_tt-ext-file-par FOR tt-ext-file-par.
  IF NOT AVAILABLE tt-ext-file-par THEN RETURN NO-APPLY.
  FIND FIRST buf_tt-ext-file-par WHERE
            recid(buf_tt-ext-file-par) = RECID(tt-ext-file-par).
  DELETE buf_tt-ext-file-par.
  run OpenBr in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  IF NOT AVAILABLE tt-ext-file-par THEN RETURN NO-APPLY.
  run proc-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
  { gbl/stdbtn.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME Br-params
&Scoped-define SELF-NAME Br-params
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Br-params Dialog-Frame
ON ROW-DISPLAY OF Br-params IN FRAME Dialog-Frame
DO:
  CASE tt-ext-file-par.param-type:
    WHEN {&type-char} THEN DO:
      ASSIGN
      tt-ext-file-par.param-name :bgcolor in browse {&browse-name} = white_COLOR
      tt-ext-file-par.param-value :bgcolor in browse {&browse-name} = white_COLOR
      tt-ext-file-par.param-date-name :bgcolor in browse {&browse-name} = GREY_COLOR
      tt-ext-file-par.param-date-value :bgcolor in browse {&browse-name} = GREY_COLOR
      tt-ext-file-par.param-int-name :bgcolor in browse {&browse-name} = GREY_COLOR
      tt-ext-file-par.param-int-value :bgcolor in browse {&browse-name} = GREY_COLOR
      tt-ext-file-par.param-log-name :bgcolor in browse {&browse-name} = GREY_COLOR
      tt-ext-file-par.param-log-value:bgcolor in browse {&browse-name} = GREY_COLOR
      tt-ext-file-par.param-date-name :fgcolor in browse {&browse-name} = GREY_COLOR
      tt-ext-file-par.param-date-value :fgcolor in browse {&browse-name} = GREY_COLOR
      tt-ext-file-par.param-int-name :fgcolor in browse {&browse-name} = GREY_COLOR
      tt-ext-file-par.param-int-value :fgcolor in browse {&browse-name} = GREY_COLOR
      tt-ext-file-par.param-log-name :fgcolor in browse {&browse-name} = GREY_COLOR
      tt-ext-file-par.param-log-value:fgcolor in browse {&browse-name} = GREY_COLOR

      .
    END.
    WHEN {&type-date} THEN DO:
        ASSIGN
        tt-ext-file-par.param-name :bgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-value :bgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-date-name :bgcolor in browse {&browse-name} = white_COLOR
        tt-ext-file-par.param-date-value :bgcolor in browse {&browse-name} = white_COLOR
        tt-ext-file-par.param-int-name :bgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-int-value :bgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-log-name :bgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-log-value:bgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-name :fgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-value :fgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-int-name :fgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-int-value :fgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-log-name :fgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-log-value:fgcolor in browse {&browse-name} = GREY_COLOR
        .
      END.
      WHEN {&type-int} THEN DO:
        ASSIGN
        tt-ext-file-par.param-name :bgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-value :bgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-date-name :bgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-date-value :bgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-int-name :bgcolor in browse {&browse-name} = white_COLOR
        tt-ext-file-par.param-int-value :bgcolor in browse {&browse-name} = white_COLOR
        tt-ext-file-par.param-log-name :bgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-log-value:bgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-name :fgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-value :fgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-date-name :fgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-date-value :fgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-log-name :fgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-log-value:fgcolor in browse {&browse-name} = GREY_COLOR
        .
      END.
      WHEN {&type-log} THEN DO:
        ASSIGN
        tt-ext-file-par.param-name :bgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-value :bgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-date-name :bgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-date-value :bgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-int-name :bgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-int-value :bgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-log-name :bgcolor in browse {&browse-name} = white_COLOR
        tt-ext-file-par.param-log-value:bgcolor in browse {&browse-name} = white_COLOR
        tt-ext-file-par.param-name :fgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-value :fgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-date-name :fgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-date-value :fgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-int-name :fgcolor in browse {&browse-name} = GREY_COLOR
        tt-ext-file-par.param-int-value :fgcolor in browse {&browse-name} = GREY_COLOR
        .
      END.
  END CASE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Br-params Dialog-Frame
ON ROW-ENTRY OF Br-params IN FRAME Dialog-Frame
OR VALUE-CHANGED OF br-params DO:
  IF p-mode = {&UPDATE} THEN DO:
   CASE tt-ext-file-par.param-type:
    WHEN {&type-char} THEN DO:
      assign
      tt-ext-file-par.param-value :read-only in browse {&browse-name} = no
      tt-ext-file-par.param-date-value :read-only  in browse {&browse-name} = yes
      tt-ext-file-par.param-int-value :read-only  in browse {&browse-name} = yes
      tt-ext-file-par.param-log-value:read-only  in browse {&browse-name} = yes
      .
    END.
    WHEN {&type-date} THEN DO:
      assign
      tt-ext-file-par.param-value :read-only in browse {&browse-name} = yes
      tt-ext-file-par.param-date-value :read-only  in browse {&browse-name} = no
      tt-ext-file-par.param-int-value :read-only  in browse {&browse-name} = yes
      tt-ext-file-par.param-log-value:read-only  in browse {&browse-name} = yes
      .
    END.
    WHEN {&type-int} THEN DO:
      assign
      tt-ext-file-par.param-value :read-only in browse {&browse-name} = yes
      tt-ext-file-par.param-date-value :read-only  in browse {&browse-name} = yes
      tt-ext-file-par.param-int-value :read-only  in browse {&browse-name} = no
      tt-ext-file-par.param-log-value:read-only  in browse {&browse-name} = yes
      .
    end.
    WHEN {&type-log} THEN DO:
      assign
      tt-ext-file-par.param-value :read-only in browse {&browse-name} = yes
      tt-ext-file-par.param-date-value :read-only  in browse {&browse-name} = yes
      tt-ext-file-par.param-int-value :read-only  in browse {&browse-name} = yes
      tt-ext-file-par.param-log-value:read-only  in browse {&browse-name} = no
      .
    END.
  END CASE.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Br-params Dialog-Frame
ON ROW-LEAVE OF Br-params IN FRAME Dialog-Frame
DO:
 IF p-mode = {&UPDATE} THEN DO:
 CASE tt-ext-file-par.param-type:
    WHEN {&type-char} then do:
       ASSIGN
       tt-ext-file-par.param-value = INPUT BROWSE br-params  tt-ext-file-par.param-value
       .
    END.
    WHEN {&type-date} then do:
       ASSIGN
       tt-ext-file-par.param-date-value = INPUT BROWSE br-params tt-ext-file-par.param-date-value
       .
    END.
    WHEN {&type-int} then do:
       ASSIGN
       tt-ext-file-par.param-int-value = INPUT BROWSE br-params tt-ext-file-par.param-int-value
       .
    END.
    WHEN {&type-log} then do:
       ASSIGN
       tt-ext-file-par.param-log-value = INPUT BROWSE br-params tt-ext-file-par.param-log-value
       .
    END.
  END CASE.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_character
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_character Dialog-Frame
ON CHOOSE OF MENU-ITEM m_character /* Символьный */
DO:
  { gbl/stdbtn.i b-add }
  ASSIGN
  add-option = {&type-char}.
  APPLY "CHOOSE" TO b-add in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_date Dialog-Frame
ON CHOOSE OF MENU-ITEM m_date /* Дата */
DO:
  { gbl/stdbtn.i b-add }
  ASSIGN
  add-option = {&type-date}.
  APPLY "CHOOSE" TO b-add in frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_integer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_integer Dialog-Frame
ON CHOOSE OF MENU-ITEM m_integer /* Целый */
DO:
  { gbl/stdbtn.i b-add }
  ASSIGN
  add-option = {&type-int}.
  APPLY "CHOOSE" TO b-add in frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_logical
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_logical Dialog-Frame
ON CHOOSE OF MENU-ITEM m_logical /* Логический */
DO:
  { gbl/stdbtn.i b-add }
  ASSIGN
  add-option = {&type-log}.
  APPLY "CHOOSE" TO b-add in frame {&frame-name} .

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
  if p-mode = {&lookup} then do:
    FIND FIRST buf_ext-file no-lock WHERE
             buf_Ext-file.db-num = p-db-num
         AND buf_Ext-file.file-num = p-file-num NO-ERROR.
    IF NOT AVAILABLE buf_Ext-file THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверно заданы входные параметры p-db-num, p-file-num" SKIP
        "В БД не хранится такой файл"
         VIEW-AS ALERT-BOX ERROR.
         RETURN .
    END.
    ASSIGN
    v-run-name = prepare-path(ENTRY(1, buf_ext-file.FILE-NAME, ">"))
    v-run-name = ENTRY(NUM-ENTRIES(v-run-name, {&slash-char}) ,v-run-name, {&slash-char}).
    run fill-table in this-procedure .
  end.
  run Myenable in this-procedure .
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
  ENABLE b-quit B-add B-del b-lkp B-Help Br-params
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-table Dialog-Frame
PROCEDURE fill-table :
DEFINE buffer buf_ext-file-par FOR ub.ext-file-par.
DEFINE buffer buf_tt-ext-file-par FOR tt-ext-file-par.
run ext-file-par-clear-temp IN THIS-PROCEDURE.
CASE p-list-mode:
  WHEN "input" THEN DO:
    FOR EACH buf_ext-file-par NO-LOCK WHERE
            buf_ext-file-par.db-num = p-db-num
        and buf_ext-file-par.from-db-num = p-from-db-num
       AND buf_ext-file-par.file-num = p-file-num
       and buf_ext-file-par.param-num > 0
       :
      CREATE buf_tt-ext-file-par.
      BUFFER-COPY buf_ext-file-par TO buf_tt-ext-file-par.
    END.
  END.
  WHEN "output" THEN DO:
    FOR EACH buf_ext-file-par NO-LOCK WHERE
            buf_ext-file-par.db-num = p-db-num
        and buf_ext-file-par.from-db-num = p-from-db-num
       AND buf_ext-file-par.file-num = p-file-num
       and buf_ext-file-par.param-num <= 0
       :
      CREATE buf_tt-ext-file-par.
      BUFFER-COPY buf_ext-file-par TO buf_tt-ext-file-par.
    END.
  END.
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-ch0 AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE v-ch-cd AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE v-ch-file AS WIDGET-HANDLE NO-UNDO.
IF available buf_ext-file
and buf_ext-file.FILE-TYPE BEGINS ({&table_cash-desk} + {&delim-key} )
AND p-mode = {&LOOKUP}    THEN DO:
  v-ibm-xml-mode = YES.
END.
ASSIGN
v-ch0 = br-params:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
REPEAT WHILE valid-handle(v-ch0):
   IF v-ch0:LABEL = {&LABEL_cd} THEN DO:
     v-ch-cd = v-ch0.
     v-ch-cd:resizable = yes.
   END.
   IF v-ch0:LABEL = {&LABEL_file} THEN DO:
      v-ch-file = v-ch0.
     v-ch-file:resizable = yes.
   END.
  v-ch0 = v-ch0:NEXT-COLUMN.
END.
assign
b-add:menu-mouse in frame {&frame-name} = 1
tt-ext-file-par.param-name:resizable in browse br-params = yes
tt-ext-file-par.param-value:resizable in browse br-params = yes
tt-ext-file-par.param-date-name:resizable in browse br-params = yes
tt-ext-file-par.param-int-name:resizable in browse br-params = yes
tt-ext-file-par.param-log-name:resizable in browse br-params = yes
.
IF v-ibm-xml-mode THEN DO:
  ASSIGN
  tt-ext-file-par.param-name:visible  IN BROWSE br-params = no
  tt-ext-file-par.param-value:visible  IN BROWSE br-params = no
  tt-ext-file-par.param-date-name:visible  IN BROWSE br-params = no
  tt-ext-file-par.param-date-value:visible  IN BROWSE br-params = no
  tt-ext-file-par.param-int-name:visible  IN BROWSE br-params = no
  tt-ext-file-par.param-int-value:visible  IN BROWSE br-params = no
  tt-ext-file-par.param-log-name:visible  IN BROWSE br-params = no
  tt-ext-file-par.param-log-value:visible  IN BROWSE br-params = no
  .
END.
ELSE DO:
  v-ch-cd:VISIBLE = NO.
  v-ch-file:VISIBLE = NO.
END.
ENABLE
b-quit
B-add  WHEN p-mode = {&UPDATE}
B-del WHEN p-mode = {&UPDATE}
B-Help
Br-params
b-lkp WHEN v-ibm-xml-mode
WITH FRAME {&frame-name} .
CASE p-mode:
  WHEN {&LOOKUP} THEN DO:
    IF p-list-mode = "Input" THEN DO:
      FRAME {&FRAME-NAME}:TITLE = substitute("Входные параметры для файла &1 (БД &2, № файла &3): ПРОСМОТР"
                                            , v-run-name
                                            , p-db-num
                                            , p-file-num).
    END.
    IF p-list-mode = "output" THEN DO:
      FRAME {&FRAME-NAME}:TITLE = substitute("Результаты работы файла &1 (№ &2) на БД &3: ПРОСМОТР"
                                            , v-run-name
                                            , p-file-num
                                            , p-db-num).
    END.
  END.
  WHEN {&update} THEN DO:
      FRAME {&FRAME-NAME}:TITLE = substitute("Входные параметры для запуска файла: РЕДАКТИРОВАНИЕ").

  END.
END CASE.
VIEW FRAME {&frame-name} .
run OpenBr IN THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
CASE p-mode:
  WHEN {&UPDATE} THEN DO:
    OPEN QUERY Br-params
        FOR EACH tt-ext-file-par .

  END.
  WHEN {&LOOKUP} THEN DO:
     OPEN QUERY Br-params
          FOR EACH tt-ext-file-par NO-LOCK  .
  END.
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
define variable v-value-name as character no-undo .
define variable v-value as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
DEFINE BUFFER buf_tt-ext-file-par FOR tt-ext-file-par.
FIND LAST buf_tt-ext-file-par WHERE
       buf_tt-ext-file-par.db-num = - 1
   and buf_tt-ext-file-par.from-db-num = - 1
   and buf_tt-ext-file-par.file-num = - 1  NO-ERROR.
IF NOT AVAILABLE buf_tt-ext-file-par THEN DO:
    v-num-params = 1.
END.
ELSE DO:
    v-num-params = buf_tt-ext-file-par.param-num + 1.
END.

    run gbl/d-prompt.w (
      'title=':u + "Введите Название параметра" + '\':u
    + 'text1=':u + "(реком. исп. короткие слова на латин. раскладке)" + '\':u
    + 'format=' + "X(40)" + '\':u
    + 'type=' + {&type-char} + '\':u
    + 'fillin_row=3\':u
    + 'fillin_col=4\':u
    + 'fillin_width=42\':u
    + 'fillin_height=1\':u
    + 'max-chars=10\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=no\':u
    , input-output v-value
    ).

run cur-time in this-procedure(output v-today, output v-time).
run ext-file-par-write-temp in this-procedure (
                                        input - 1
                                      , input - 1
                                      , input - 1
                                      , input  string(v-num-params)
                                      , input  p-option
                                      , input  v-value
                                      , input  '':U
                                      , input  v-today
                                      , input  0
                                      , input  0.0
                                      , input  no).
run OpenBr in this-procedure.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lkp Dialog-Frame
PROCEDURE proc-b-lkp :
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-lkp Dialog-Frame
PROCEDURE proc-lkp :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-override AS INTEGER no-UNDO.
DEFINE VARIABLE v-temp-file-name AS CHARACTER NO-UNDO.
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define buffer par_ext-file for ub.ext-file.
run gen-row-keyr in this-procedure (
   input  tt-ext-file-par.param-value /*ext-file-uniq-key-rec*/
  ,input  ? /*p-key-handle буфер записи которую будем искать. если ищем по key-rec то ? */
  ,input  "ub"
  ,input  ? /*p-tt-handle  буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
  ,input  no-lock
  ,output v-tbl-row
  ,output v-tbl-name  ) no-error.
if not error-status:error then do:
  find first par_ext-file no-lock where
            rowid(par_ext-file) = v-tbl-row.
end.
else do:
  message
  "Не найден в хранилище БД файл." skip
  "Возможно он уже удален или не существовал"
  view-as alert-box error.
  undo, return error .
end.
/*сделаем временный файл*/
run gbl/_tmpfile.p (
       input  't':U
      ,input  "." + entry( num-entries(par_ext-file.file-name, "."), par_ext-file.FILE-NAME, ".")
      ,output v-temp-file-name
      ) .
run adm/extfsavd.p (
             INPUT par_ext-file.db-num
            ,INPUT par_ext-file.from-db-num
            ,INPUT par_ext-file.file-num
            ,INPUT v-temp-file-name
            ,INPUT-OUTPUT v-override) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
  MESSAGE
  SUBSTITUTE("Ошибка при сохранении файла &1 на диск во временный файл&2&3&2&4&2"
          , par_ext-file.FILE-NAME
          , {&NEW-LINE}
          ,error-status:get-message(1)
          , RETURN-VALUE)
  VIEW-AS ALERT-BOX ERROR.
  RETURN ERROR.
END.
os-command  value ('start /wait /b ' + v-temp-file-name).
OS-DELETE VALUE(v-temp-file-name).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
