&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED TEMP-TABLE tt-db NO-UNDO LIKE ub.db.
DEFINE NEW SHARED TEMP-TABLE tt-ext-file NO-UNDO LIKE ub.ext-file.
DEFINE NEW SHARED TEMP-TABLE tt-ext-file-par NO-UNDO LIKE ub.ext-file-par.
DEFINE BUFFER X_db FOR ub.db.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Опции пересылки файлов через систему СПН

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/04/06
Author: Bakhtadze Natalya
Creation date: 08/04/06

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
/*бывает save-db save-disk save-package*/
define input parameter p-db-num   as integer no-undo .
define input parameter p-from-db-num   as integer no-undo .
DEFINE INPUT PARAMETER p-status_ AS CHARACTER NO-UNDO.
/*действителен только для save-package  может быть auto или manual */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Опции пересылки файлов через систему СПН".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i DEF }
{ cmp/operlist.i }
{ gbl/fileslsh.i }
{ gbl/cur-time.i }
DEFINE VARIABLE v-file-num AS INTEGER NO-UNDO.
define variable glog as logical no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-db

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_db tt-db tt-ext-file

/* Definitions for BROWSE BR-db                                         */
&Scoped-define FIELDS-IN-QUERY-BR-db (if available tt-db then "*" else "":U) X_db.db-num X_db.db-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-db
&Scoped-define SELF-NAME BR-db
&Scoped-define OPEN-QUERY-BR-db IF p-db-num = ? THEN DO:   IF v-cntxt-db-num = 0 THEN DO:      OPEN QUERY {&SELF-NAME} FOR EACH X_db NO-LOCK WHERE X_db.db-num > 0, ~
                 EACH tt-db OF X_db OUTER-JOIN NO-LOCK .   END.   ELSE DO:     OPEN QUERY {&SELF-NAME} FOR EACH X_db NO-LOCK WHERE X_db.db-num = 0, ~
                 EACH tt-db OF X_db OUTER-JOIN NO-LOCK .    END. END. ELSE DO:     IF v-cntxt-db-num = 0 THEN DO:        OPEN QUERY {&SELF-NAME} FOR EACH X_db NO-LOCK WHERE X_db.db-num = p-db-num, ~
                   EACH tt-db OF X_db OUTER-JOIN NO-LOCK .     END. END.
&Scoped-define TABLES-IN-QUERY-BR-db X_db tt-db
&Scoped-define FIRST-TABLE-IN-QUERY-BR-db X_db
&Scoped-define SECOND-TABLE-IN-QUERY-BR-db tt-db


/* Definitions for BROWSE BR-files                                      */
&Scoped-define FIELDS-IN-QUERY-BR-files tt-ext-file.file-name ~
tt-ext-file.file-size tt-ext-file.update-sys-date ~
tt-ext-file.update-sys-time tt-ext-file.create-sys-date ~
tt-ext-file.create-sys-time
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-files
&Scoped-define QUERY-STRING-BR-files FOR EACH tt-ext-file NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-files OPEN QUERY BR-files FOR EACH tt-ext-file NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-files tt-ext-file
&Scoped-define FIRST-TABLE-IN-QUERY-BR-files tt-ext-file


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-db}~
    ~{&OPEN-QUERY-BR-files}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help b-mark B-all-select ~
B-all-deselect BR-db Rs-mode rs-path-type f-path b-add b-del B-params ~
BR-files
&Scoped-Define DISPLAYED-OBJECTS Rs-mode rs-path-type f-path

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-all-deselect
     LABEL "&-Все"
     SIZE 10 BY 1.

DEFINE BUTTON B-all-select
     LABEL "&+Все"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 4 BY 1.

DEFINE BUTTON B-params
     LABEL "&Пар-тры"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-path AS CHARACTER FORMAT "X(256)":U
     LABEL "Путь"
     VIEW-AS FILL-IN
     SIZE 55.5 BY 1 TOOLTIP "Абс. путь, относ. путь или настройка ini-файла (секция,параметр)" NO-UNDO.

DEFINE VARIABLE Rs-mode AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Сохранить в текущей БД", "save-this-db",
"Выложить на диск другой БД", "save-disk",
"Сохранить в другой БД", "save-db",
"Пакет обновления", "save-install",
"Выложить на диск другой БД и запустить", "save-disk-and-run",
"Сохранить в другой БД и запустить", "save-DB-and-run"
     SIZE 45 BY 4.27 NO-UNDO.

DEFINE VARIABLE rs-path-type AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Относительный", 0,
"Абсолютный", 1,
"Настройки из ini-файла IBS TH", 2
     SIZE 39.5 BY 2.7 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-db FOR
      X_db,
      tt-db SCROLLING.

DEFINE QUERY BR-files FOR
      tt-ext-file SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-db Dialog-Frame _FREEFORM
  QUERY BR-db NO-LOCK DISPLAY
      (if available tt-db then "*" else "":U) FORMAT "X(1)":U WIDTH 2
      X_db.db-num FORMAT ">>>>9":U WIDTH 6
      X_db.db-name FORMAT "X(40)":U WIDTH 22
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 33.3 BY 8.67
         TITLE "Список БД" ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.

DEFINE BROWSE BR-files
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-files Dialog-Frame _STRUCTURED
  QUERY BR-files NO-LOCK DISPLAY
      tt-ext-file.file-name COLUMN-LABEL "Имя и путь к файлу - на компьютере источнике" FORMAT "X(255)":U
            WIDTH 74
      tt-ext-file.file-size COLUMN-LABEL "Размер (б)" FORMAT ">>>>>>>>9":U
      tt-ext-file.update-sys-date COLUMN-LABEL "Дата изм." FORMAT "99/99/9999":U
            WIDTH 11
      tt-ext-file.update-sys-time COLUMN-LABEL "Время изм." FORMAT "X(8)":U
            WIDTH 9
      tt-ext-file.create-sys-date COLUMN-LABEL "Дата созд." FORMAT "99/99/9999":U
      tt-ext-file.create-sys-time COLUMN-LABEL "Время созд." FORMAT "X(8)":U
            WIDTH 9
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.07 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 88
     b-mark AT ROW 2 COL 66.5
     B-all-select AT ROW 2 COL 70.5
     B-all-deselect AT ROW 2 COL 80.5
     BR-db AT ROW 3 COL 66.5
     Rs-mode AT ROW 3.13 COL 2.5 NO-LABEL
     rs-path-type AT ROW 9 COL 2.5 NO-LABEL
     f-path AT ROW 11.8 COL 6.5 COLON-ALIGNED
     b-add AT ROW 12 COL 66.5
     b-del AT ROW 12 COL 76.5
     B-params AT ROW 12 COL 86.5
     BR-files AT ROW 13 COL 1
     "Тип пути к файлу - (на компьютере-приемнике)" VIEW-AS TEXT
          SIZE 44 BY .8 AT ROW 8 COL 2.5
          FGCOLOR 4
     "Режим передачи файла" VIEW-AS TEXT
          SIZE 44 BY .8 AT ROW 2 COL 2.5
          FGCOLOR 4
     SPACE(53.30) SKIP(17.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Опции пересылки файлов чере СПН и/или регистрации пакетов обновлений"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-db T "NEW SHARED" NO-UNDO ub db
      TABLE: tt-ext-file T "NEW SHARED" NO-UNDO ub ext-file
      TABLE: tt-ext-file-par T "NEW SHARED" NO-UNDO ub ext-file-par
      TABLE: X_db B "?" ? ub db
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BR-db B-all-deselect Dialog-Frame */
/* BROWSE-TAB BR-files B-params Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-db
/* Query rebuild information for BROWSE BR-db
     _START_FREEFORM
IF p-db-num = ? THEN DO:
  IF v-cntxt-db-num = 0 THEN DO:

    OPEN QUERY {&SELF-NAME} FOR EACH X_db NO-LOCK WHERE X_db.db-num > 0,
          EACH tt-db OF X_db OUTER-JOIN NO-LOCK .
  END.
  ELSE DO:
    OPEN QUERY {&SELF-NAME} FOR EACH X_db NO-LOCK WHERE X_db.db-num = 0,
          EACH tt-db OF X_db OUTER-JOIN NO-LOCK .

  END.
END.
ELSE DO:
    IF v-cntxt-db-num = 0 THEN DO:

      OPEN QUERY {&SELF-NAME} FOR EACH X_db NO-LOCK WHERE X_db.db-num = p-db-num,
            EACH tt-db OF X_db OUTER-JOIN NO-LOCK .
    END.
END.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _TblOptList       = ", OUTER"
     _Query            is OPENED
*/  /* BROWSE BR-db */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-files
/* Query rebuild information for BROWSE BR-files
     _TblList          = "Temp-Tables.tt-ext-file"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > Temp-Tables.tt-ext-file.file-name
"tt-ext-file.file-name" "Имя и путь к файлу - на компьютере источнике" ? "character" ? ? ? ? ? ? no ? no no "74" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > "_<CALC>"
"tt-ext-file.file-size" "Размер (б)" ">>>>>>>>9" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.tt-ext-file.update-sys-date
"tt-ext-file.update-sys-date" "Дата изм." ? "date" ? ? ? ? ? ? no ? no no "11" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > Temp-Tables.tt-ext-file.update-sys-time
"tt-ext-file.update-sys-time" "Время изм." "X(8)" "character" ? ? ? ? ? ? no ? no no "9" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > Temp-Tables.tt-ext-file.create-sys-date
"tt-ext-file.create-sys-date" "Дата созд." ? "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > Temp-Tables.tt-ext-file.create-sys-time
"tt-ext-file.create-sys-time" "Время созд." "X(8)" "character" ? ? ? ? ? ? no ? no no "9" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BR-files */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Опции пересылки файлов чере СПН и/или регистрации пакетов обновлений */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  run proc-add-file IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-all-deselect
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-all-deselect Dialog-Frame
ON CHOOSE OF B-all-deselect IN FRAME Dialog-Frame /* -Все */
DO:
  run proc-b-all-deselect IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-all-select
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-all-select Dialog-Frame
ON CHOOSE OF B-all-select IN FRAME Dialog-Frame /* +Все */
DO:
  run proc-b-all-select IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  DEFINE BUFFER buf_tt-ext-file FOR tt-ext-file.
  IF NOT AVAILABLE tt-ext-file THEN RETURN NO-APPLY.
  FIND FIRST buf_tt-ext-file WHERE
            recid(buf_tt-ext-file) = RECID(tt-ext-file).
  DELETE buf_tt-ext-file.
  {&OPEN-QUERY-br-files}
  find FIRST buf_tt-ext-file NO-LOCK NO-ERROR.
  IF NOT AVAILABLE buf_tt-ext-file
  and p-mode = {&save-install}
  THEN DO:
      rs-mode:ENABLE(radio-label({&save-install}, RS-mode:RADIO-BUTTONS IN FRAME {&FRAME-NAME})) IN FRAME {&FRAME-NAME}.
  END.
  IF NOT AVAILABLE buf_tt-ext-file
  and p-mode = {&save-this-db}
  THEN DO:
      rs-mode:ENABLE(radio-label({&save-this-db}, RS-mode:RADIO-BUTTONS IN FRAME {&FRAME-NAME})) IN FRAME {&FRAME-NAME}.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  define buffer buf_tt-ext-file for tt-ext-file.
  ASSIGN
  rs-mode
  rs-path-type
  f-path.
  find first buf_tt-ext-file no-lock no-error.
  if not available buf_tt-ext-file then do:
    message
    "Вы не выбрали ни одного файла для пересылки/сохранения"
    view-as alert-box error .
    return no-apply.
  end.
  IF rs-path-type > 0 /*не относительный*/
  AND f-path = '':U
  AND rs-mode <> {&save-db}    THEN DO:
     MESSAGE
     substitute("Для типа пути АБСОЛЮТНЫЙ или НАСТРОЙКИ ИЗ INI-ФАЙЛА IBS TH&1" +
                "необходимо указать ПУТЬ"
                , {&NEW-LINE}
                )
     VIEW-AS ALERT-BOX ERROR .
     RETURN NO-APPLY.
  END.
  IF rs-path-type = 0
   AND f-path = '':U
  AND not (rs-mode = {&save-db}
          or
          rs-mode = {&save-db-and-run}
          or
          rs-mode = {&save-this-db}
          or
          rs-mode = {&save-install})
  THEN DO:
      MESSAGE
      substitute("Файлы будут установлены в директорию R-кодов IBS TH&1" +
                 "Вы уверены в Вашем решении?"
                 , {&NEW-LINE}
                 )
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog .
      IF NOT glog  THEN RETURN NO-APPLY.

  END.
  run proc-run IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
  run proc-mark-db IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-params
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-params Dialog-Frame
ON CHOOSE OF B-params IN FRAME Dialog-Frame /* Пар-тры */
DO:
  IF rs-mode <> {&save-disk-and-run}
  AND rs-mode <> {&save-db-and-run} THEN DO:
    RETURN NO-APPLY.
  END.
  /*ЕЩЕ НЕ ЗНАЕМ ПАРАМЕТРЫ EXT-FILE*/
  run nws/sndfnwp.w (
                  input parparentproc
                 ,input {&update}
                 ,input "input"
                 ,input 0
                 ,input 0
                 ,input 0
                 ) NO-ERROR.

  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Rs-mode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Rs-mode Dialog-Frame
ON VALUE-CHANGED OF Rs-mode IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v_manifest-file AS CHARACTER NO-UNDO.
DEFINE VARIABLE ll_commit AS logical NO-UNDO.
DEFINE VARIABLE old-rs-mode AS CHARACTER NO-UNDO.
DEFINE VARIABLE glog AS logical NO-UNDO.
DEFINE BUFFER buf_tt-ext-file FOR tt-ext-file.
  ASSIGN
  old-rs-mode = rs-mode
  rs-mode
  .
  CASE rs-mode:
    WHEN {&SAVE-this-DB} THEN DO:
      ASSIGN
      f-path = '':U
      rs-path-type = 0.
      DISPLAY
      rs-path-type
      f-path
      WITH FRAME {&FRAME-NAME}.
      DISABLE
      rs-path-type
      f-path
      b-params
      WITH FRAME {&FRAME-NAME}.
    END.
    WHEN {&SAVE-DB} THEN DO:
      ASSIGN
      f-path = '':U
      rs-path-type = 0.
      DISPLAY
      rs-path-type
      f-path
      WITH FRAME {&FRAME-NAME}.
      DISABLE
      rs-path-type
      f-path
      b-params
      WITH FRAME {&FRAME-NAME}.
    END.
    WHEN {&save-install} THEN DO:
      FIND FIRST buf_tt-ext-file NO-LOCK  no-error.
      IF AVAILABLE buf_tt-ext-file THEN DO:
         MESSAGE
         "Уже есть выбранные файлы для пересылки" SKIP
         "Невозможно переключиться в режим пересылки ПАКЕТА ОБНОВЛЕНИЙ"
          VIEW-AS ALERT-BOX ERROR.
          UNDO, RETURN NO-APPLY.
      END.
      ASSIGN
      f-path = '':U
      rs-path-type = 0.
      DISPLAY
      rs-path-type
      f-path
      WITH FRAME {&FRAME-NAME}.
      DISABLE
      rs-path-type
      f-path
      b-params
      WITH FRAME {&FRAME-NAME}.
      /*надо выбрать файл манифеста*/
      SYSTEM-DIALOG GET-FILE v_manifest-file
      TITLE "Выберите файл манифеста данного пакета обновлений"
      FILTERS
        " Файлы манифеста пакета обновлений (*.mf) " "*.mf"
      INITIAL-FILTER 1
      DEFAULT-EXTENSION ".mf"
      USE-FILENAME
      MUST-EXIST
      UPDATE ll_commit
      .
      IF ll_commit <> YES THEN do:
         RETURN NO-APPLY.
      end.
      run nws/sndpckp.p ( INPUT v_manifest-file) NO-ERROR.
      IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
      DISPLAY
      entry(1, v_manifest-file, ".") @ f-path
      with frame {&frame-name}.
      {&OPEN-QUERY-br-files}
    END.
    WHEN {&SAVE-DISK} THEN DO:
      ENABLE
      rs-path-type
      f-path
      WITH FRAME {&FRAME-NAME}.
      DISABLE
      b-params
      WITH FRAME {&FRAME-NAME}.
    END.
    WHEN {&SAVE-DB-and-run} THEN DO:
      /*
      MESSAGE
      "Данный режим предназначен для сотрудников IBS" SKIP
      "Продолжить?"
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
      IF NOT glog THEN DO:
         ASSIGN
         rs-mode = old-rs-mode.
         DISPLAY
         rs-mode
         WITH FRAME {&FRAME-NAME}.
         RETURN NO-APPLY.
      END.
      */
      ASSIGN
      f-path = '':U
      rs-path-type = 0.
      DISPLAY
      rs-path-type
      f-path
      WITH FRAME {&FRAME-NAME}.
      DISABLE
      rs-path-type
      f-path
      WITH FRAME {&FRAME-NAME}.
      ENABLE
      b-params
      WITH FRAME {&FRAME-NAME}.
    END.
    WHEN {&SAVE-DISK-and-run} THEN DO:
        /*
      MESSAGE
      "Данный режим предназначен для сотрудников IBS" SKIP
      "Продолжить?"
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
      IF NOT glog THEN DO:
       ASSIGN
       rs-mode = old-rs-mode.
       DISPLAY
       rs-mode
       WITH FRAME {&FRAME-NAME}.
       RETURN NO-APPLY.
      END.
      */
      ENABLE
      rs-path-type
      f-path
      b-params
      WITH FRAME {&FRAME-NAME}.
    END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-db
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
  { gbl/getcntxt.i get }
  /*
  MESSAGE
  "Данный режим предназначен для сотрудников IBS" SKIP
  "Продолжить?"
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  IF NOT glog THEN DO:
    RETURN .
  END.
  */
  RUN Myenable IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE confirm-password Dialog-Frame
PROCEDURE confirm-password :
DEFINE INPUT PARAMETER p-file-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-today AS date NO-UNDO.
DEFINE OUTPUT PARAMETER p-ok AS LOGICAL no-undo.
DEFINE VARIABLE v-psw-buf AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-need-password AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-need-password-int AS INTEGER NO-UNDO.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
p-ok = YES.

/* Закоменнтили потому что не понятно зачем это закрывать на пароль
ASSIGN
p-file-name = LOWER(p-file-name).
DO v-ii = 1 TO LENGTH( p-file-NAME):
   ASSIGN
   v-need-password-int = v-need-password-int + ASC(SUBSTRING(p-file-name, v-ii, 1))
   .
END.
DO v-ii = 1 TO LENGTH(string(p-today, "99/99/9999")):
   ASSIGN
   v-need-password-int = v-need-password-int + ASC(SUBSTRING(string(p-today, "99/99/9999"), v-ii, 1))
   .
END.
ASSIGN
v-need-password = STRING(v-need-password-int).
/* message v-need-password view-as alert-box. */
run ref/per-pswd.w ( output v-psw-buf ) .
IF v-psw-buf =  v-need-password THEN p-ok = YES.
*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY Rs-mode rs-path-type f-path
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help b-mark B-all-select B-all-deselect BR-db Rs-mode
         rs-path-type f-path b-add b-del B-params BR-files
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
assign
rs-mode:radio-buttons in frame {&frame-name} =
"Сохранить в текущей БД" + {&comma-char} + {&save-this-db} + {&comma-char} +
"Выложить на диск другой БД" + {&comma-char} + {&save-disk} + {&comma-char} +
"Сохранить в другой БД" + {&comma-char} + {&save-db}  + {&comma-char} +
"Пакет обновления" + {&comma-char} + {&save-install} + {&comma-char} +
"Выложить на диск другой БД и запустить" + {&comma-char} + {&save-disk-and-run} + {&comma-char} +
"Сохранить в другой БД и запустить" + {&comma-char} + {&save-DB-and-run}.

IF p-mode <> "":U THEN DO:
  assign
  rs-mode = p-mode.
  .
END.
DISPLAY
Rs-mode
rs-path-type
f-path
WITH FRAME {&frame-name}.
ENABLE
B-exit
b-quit
B-Help
b-mark
B-all-select WHEN p-db-num = ?
B-all-deselect WHEN p-db-num = ?
BR-db
Rs-mode WHEN (p-mode = "":U)
rs-path-type
f-path
b-add
b-del
BR-files
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
if p-mode = {&save-install}
or p-mode = {&save-this-db}
then do:
  rs-mode:disable(radio-label({&save-db}, RS-mode:RADIO-BUTTONS IN FRAME {&FRAME-NAME})) IN FRAME {&FRAME-NAME}.
  rs-mode:disable(radio-label({&save-disk}, RS-mode:RADIO-BUTTONS IN FRAME {&FRAME-NAME})) IN FRAME {&FRAME-NAME}.
  rs-mode:disable(radio-label({&save-disk-and-run}, RS-mode:RADIO-BUTTONS IN FRAME {&FRAME-NAME})) IN FRAME {&FRAME-NAME}.
  rs-mode:disable(radio-label({&save-disk-and-run}, RS-mode:RADIO-BUTTONS IN FRAME {&FRAME-NAME})) IN FRAME {&FRAME-NAME}.
  if p-mode = {&save-install} then
  rs-mode:disable(radio-label({&save-this-db}, RS-mode:RADIO-BUTTONS IN FRAME {&FRAME-NAME})) IN FRAME {&FRAME-NAME}.
  if p-mode = {&save-this-db} then
  rs-mode:disable(radio-label({&save-install}, RS-mode:RADIO-BUTTONS IN FRAME {&FRAME-NAME})) IN FRAME {&FRAME-NAME}.
end.
else do:
   rs-mode:disable(radio-label({&save-install}, RS-mode:RADIO-BUTTONS IN FRAME {&FRAME-NAME})) IN FRAME {&FRAME-NAME}.
   rs-mode:disable(radio-label({&save-this-db}, RS-mode:RADIO-BUTTONS IN FRAME {&FRAME-NAME})) IN FRAME {&FRAME-NAME}.
end.

APPLY "value-changed" TO rs-mode IN FRAME {&FRAME-NAME}.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add-file Dialog-Frame
PROCEDURE proc-add-file :
define variable v_os-file   AS CHAR NO-UNDO INIT "".
define variable ll_commit AS LOG    NO-UNDO INIT NO.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
DEFINE VARIABLE v-md5-signature AS CHARACTER NO-undo.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
DEFINE BUFFER buf_tt-ext-file FOR tt-ext-file.

run gbl/dm-file.p ( INPUT (" Файлы Progress (*.i, *.r, *.p, *.w, *.d) " + "|" + "*.i;*.r;*.p;*.w;*.d"
                + "|" + " Текстовые файлы (*.txt) " + "|" + "*.txt"
                + "|" + " Все файлы (*.*) "  + "|" +  "*.*")
                ,INPUT "."
                ,INPUT "Выберите один или несколько файлов"
                ,input frame {&frame-name}:hwnd
                ,OUTPUT v_os-file
                ,OUTPUT ll_commit
                            ).

IF ll_commit <> YES THEN do:
   RETURN error.
end.
_ii:
DO ii = 1 TO NUM-ENTRIES (v_os-file, "|"):
    run gbl/filename.p (
                     input  entry(ii, v_os-file, '|')
                    ,output v-full-path
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .
    if error-status:error  = ? then do:
      message
      substitute("Ошибка при поиске файла файла &1&2" +
                 "возможно файл уже удален"
                 , v-full-path
                 , {&new-line})
     view-as alert-box error .
     next _ii.
    end.
    assign
    v-full-path = prepare-path(v-full-path).

    FIND FIRST buf_tt-ext-file NO-LOCK WHERE
              buf_tt-ext-file.FILE-NAME = v-full-path NO-ERROR.
    IF AVAILABLE buf_tt-ext-file THEN DO:
       MESSAGE
       substitute("В списке выбранных файлов уже есть файл &1&2&1" +
                  "Дата файла &3, время файла &4")
       VIEW-AS ALERT-BOX.
    END.
    file-info:FILE-NAME = v-full-path.
    run gbl/md5.p (
       input  v-full-path
      ,output v-md5-signature /* p-md5-signature */
      ) no-error.
    if error-status:error then do:
      message
      substitute("Ошибка при выполнении подсчета КС файла &1&2" +
                 "&3&2&4"
                 , v-full-path
                 , {&new-line}
                 , error-status:get-message(1)
                 , return-value )
     view-as alert-box error .
     next _ii.
    end.
    run cur-time in this-procedure ( output v-today, output v-time).
    CREATE buf_tt-ext-file.
    ASSIGN
    buf_tt-ext-file.FILE-NAME = v-full-path
    buf_tt-ext-file.file-num = v-file-num + 1
    v-file-num = v-file-num + 1
    buf_tt-ext-file.create-sys-date      = file-info:FILE-mod-DATE
    buf_tt-ext-file.create-sys-time      = STRING(file-info:FILE-mod-TIME, "HH:MM:SS")
    buf_tt-ext-file.create-sys-time-INT  = file-info:FILE-mod-TIME
    buf_tt-ext-file.update-sys-date      = v-today
    buf_tt-ext-file.update-sys-time      = STRING(v-time, "HH:MM:SS")
    buf_tt-ext-file.update-sys-time-INT  = file-info:FILE-MOD-TIME
    buf_tt-ext-file.file-size            = FILE-INFO:FILE-SIZE
    buf_tt-ext-file.crc-field            = v-md5-signature
    .
    rs-mode:DISABLE(radio-label({&save-install}, RS-mode:RADIO-BUTTONS IN FRAME {&FRAME-NAME})) IN FRAME {&FRAME-NAME}.
    /*найдем md5*/

    RELEASE buf_tt-ext-file.

    {&OPEN-QUERY-br-files}
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-all-deselect Dialog-Frame
PROCEDURE proc-b-all-deselect :
DEFINE BUFFER buf_tt-db FOR tt-db.
FOR EACH buf_tt-db:
   DELETE buf_tt-db.
END.
{&OPEN-QUERY-br-db}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-all-select Dialog-Frame
PROCEDURE proc-b-all-select :
DEFINE BUFFER buf_tt-db FOR tt-db.
GET first br-db no-lock.
DO WHILE available X_db :
    GET prev br-db no-lock.
END.
GET next br-db no-lock.
DO WHILE available X_db :
   FIND FIRST buf_tt-db NO-LOCK WHERE
             buf_tt-db.db-num = X_db.db-num NO-ERROR.
   IF NOT AVAILABLE buf_tt-db THEN DO:
       CREATE buf_tt-db.
       BUFFER-COPY X_db TO buf_tt-db.
       RELEASE buf_Tt-db.
   END.
   GET next br-db no-lock.
END.
GET first br-db no-lock.
{&OPEN-QUERY-br-db}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-mark-db Dialog-Frame
PROCEDURE proc-mark-db :
DEFINE VARIABLE v-deleted-db-num AS INTEGER NO-UNDO.
DEFINE VARIABLE v-new-db-num AS INTEGER NO-UNDO.
DEFINE BUFFER buf_tt-db FOR tt-db.
DEFINE BUFFER buf_db FOR ub.db.
IF NOT AVAILABLE X_db THEN RETURN.
IF AVAILABLE tt-db THEN DO:
  FIND FIRST buf_tt-db WHERE
         RECID(buf_tt-db) = RECID(tt-db).
  v-deleted-db-num = tt-db.db-num.
  DELETE buf_tt-db.
  {&OPEN-QUERY-br-db}
  FIND first buf_db NO-LOCK WHERE
            buf_db.db-num > v-deleted-db-num NO-ERROR.
  IF AVAILABLE buf_db THEN DO:
    REPOSITION br-db TO RECID RECID(buf_db).
  END.
  else do:
    FIND first buf_db NO-LOCK WHERE
              buf_db.db-num = v-deleted-db-num NO-ERROR.
    IF AVAILABLE buf_db THEN DO:
      REPOSITION br-db TO RECID RECID(buf_db).
    END.
    else do:
      FIND first buf_db NO-LOCK NO-ERROR.
      REPOSITION br-db TO RECID RECID(buf_db).
    end.
  end.
END.
ELSE DO:
    CREATE buf_tt-db.
    BUFFER-COPY X_db TO buf_tt-db.
    v-new-db-num = X_db.db-num.
    RELEASE buf_tt-db.
    {&OPEN-QUERY-br-db}
    FIND FIRST buf_db NO-LOCK WHERE
              buf_db.db-num > v-new-db-num NO-ERROR.
    IF AVAILABLE buf_db THEN DO:
      REPOSITION br-db TO RECID RECID(buf_db).
    END.
    else do:
      FIND first buf_db NO-LOCK WHERE
                buf_db.db-num = v-new-db-num NO-ERROR.
      IF AVAILABLE buf_db THEN DO:
        REPOSITION br-db TO RECID RECID(buf_db).
      END.
    end.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-run Dialog-Frame
PROCEDURE proc-run :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
define buffer buf_db for ub.db.
define buffer buf_tt-db for tt-db.
define buffer buf_tt-ext-file for tt-ext-file.
define buffer buf_tt-ext-file-par for tt-ext-file-par.
find first tt-db no-lock no-error.
if not available tt-db then do:
  if p-mode = {&save-this-db} then do:
    find first buf_db no-lock where buf_db.db-num = v-cntxt-db-num.
    create buf_tt-db.
    buffer-copy buf_db to buf_tt-db.
    release buf_tt-db.
  end.
  else do:
    if v-cntxt-db-num = 0 then do:
      message
      "Не выбрана ни одна БД для пересылки"
      view-as alert-box error .
      return error.
    end.
    else do:
      find first buf_db no-lock where buf_db.db-num = 0.
      create buf_tt-db.
      buffer-copy buf_db to buf_tt-db.
      release buf_tt-db.
    end.
  end.
end.
IF rs-mode = {&save-disk-and-run}
OR rs-mode = {&save-db-and-run} THEN DO:
  DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
  DEFINE VARIABLE v-file-name AS character NO-UNDO.
  v-ii = 0.
  FOR EACH buf_tt-ext-file NO-LOCK:
    v-ii = v-ii + 1.
    IF v-ii = 2 THEN DO:
      MESSAGE
      "В данном режиме для пересылки можно выбрать только ОДИН файл"
      VIEW-AS ALERT-BOX ERROR.
      RETURN error.
    END.
  END.
  FIND FIRST buf_tt-ext-file.
  ASSIGN
  v-file-name = prepare-path(buf_tt-ext-file.FILE-NAME)
  v-file-name = entry(num-entries(v-file-name, {&slash-char})
                           , v-file-name
                           , {&slash-char}
                          ).
  run cur-time in THIS-PROCEDURE ( output v-today, output v-time).
/*
  RUN confirm-password IN THIS-PROCEDURE (
                                          INPUT v-file-name
                                         ,INPUT v-today
                                         ,OUTPUT v-ok) NO-ERROR.

  IF NOT v-ok
  THEN DO:
     MESSAGE
     "Пароль неверный"
      VIEW-AS ALERT-BOX ERROR.
     UNDO, RETURN ERROR.
  END.
  
  */
  for each buf_tt-ext-file-par no-lock:
    if (buf_tt-ext-file-par.param-type = {&type-char}
       AND buf_tt-ext-file-par.param-name = '':U)
    or (buf_tt-ext-file-par.param-type= {&type-date}
       AND buf_tt-ext-file-par.param-date-name = '':U)
    or (buf_tt-ext-file-par.param-type = {&type-int}
       AND buf_tt-ext-file-par.param-int-name = '':U)
    or (buf_tt-ext-file-par.param-type = {&type-dec}
       AND buf_tt-ext-file-par.param-decimal-name = '':U)
    or (buf_tt-ext-file-par.param-type = {&type-log}
        AND buf_tt-ext-file-par.param-log-name = '':U) then do:
       message
       "Не всем входным параметрам присвоены имена"
       view-as alert-box error.
       undo, return error .
    end.
  end.
  message "ЕЩЕ РАЗ ПРОВЕРЬТЕ ВХОДНЫЕ ПАРАМЕТРЫ!!!!"
  view-as alert-box .
  run nws/sndfnwp.w (
                  input parparentproc
                 ,input {&update}
                 ,input "input"
                 ,input 0
                 ,input 0
                 ,input 0
                 ) NO-ERROR.
  MESSAGE
  substitute("ПРОДОЛЖИТЬ ВЫПОЛНЕНИЕ ОПЕРАЦИИ &1 над выбранным файлом с выбранными параметрами?"
             , rs-mode)
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  IF glog = NO THEN RETURN ERROR.
END.
else do:
  run cur-time in THIS-PROCEDURE ( output v-today, output v-time).

  RUN confirm-password IN THIS-PROCEDURE (
                                          INPUT '':U
                                          ,INPUT v-today
                                          ,OUTPUT v-ok) NO-ERROR.

  IF NOT v-ok
  THEN DO:
      MESSAGE
      "Пароль неверный"
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
end.

run str/diallog.w (
            INPUT parparentproc
          , INPUT this-procedure:HANDLE
          , INPUT 'nws/sndfnwr.p':U
          , INPUT (rs-mode + {&delim-par} +
                   string(rs-path-TYPE) + {&delim-par} +
                   f-path + {&delim-par} +
                   p-status_)
          , INPUT no /*p-auto-go*/
          , input 'Прервать'
          , INPUT (if p-mode = {&save-this-db} then 'Сохранение файлов в текущей БД' else 'Пересылка файлов через СПН')) no-error .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME