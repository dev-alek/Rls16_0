&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
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

Конфигурация раскладок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/26/08
Author: Bakhtadze Natalya
Creation date: 09/26/08

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Конфигурация раскладок".
{ cmp/vssrevis.i }
{ cmp/library.i  }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/tblfname.i }
{ gbl/cur-time.i }
define variable v-layout-tables as character no-undo.
define variable v-layout-table-names as character no-undo.
define variable v-sys-key as character no-undo .
define variable v-ibs as logical no-undo .
define variable glog as logical no-undo .
DEFINE BUFFER buf_file FOR dictdb._file.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-laytables

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_file

/* Definitions for BROWSE br-laytables                                  */
&Scoped-define FIELDS-IN-QUERY-br-laytables buf_file._file-name get-tbl-fname (buf_file._file-name)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-laytables
&Scoped-define SELF-NAME br-laytables
&Scoped-define QUERY-STRING-br-laytables FOR EACH buf_file NO-LOCK WHERE lookup(buf_file._file-name, ~
       v-layout-tables) > 0
&Scoped-define OPEN-QUERY-br-laytables OPEN QUERY {&SELF-NAME} FOR EACH buf_file NO-LOCK WHERE lookup(buf_file._file-name, ~
       v-layout-tables) > 0.
&Scoped-define TABLES-IN-QUERY-br-laytables buf_file
&Scoped-define FIRST-TABLE-IN-QUERY-br-laytables buf_file


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-laytables}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-sel b-export b-import B-Help ~
rs-language br-laytables
&Scoped-Define DISPLAYED-OBJECTS rs-language

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-tbl-fname Dialog-Frame
FUNCTION get-tbl-fname RETURNS CHARACTER ( INPUT p-tbl-name AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-export
     LABEL "&Экспорт"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-import
     LABEL "&Импорт"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel
     LABEL "В&ыбор"
     SIZE 10 BY 1.

DEFINE VARIABLE rs-language AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2"
     SIZE 21 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-laytables FOR
      buf_file SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-laytables
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-laytables Dialog-Frame _FREEFORM
  QUERY br-laytables DISPLAY
      buf_file._file-name FORMAT "X(32)" COLUMN-LABEL "Таблицы"
get-tbl-fname (buf_file._file-name) FORMAT "X(62)" COLUMN-LABEL "Описание"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 20.27 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-sel AT ROW 1 COL 21 WIDGET-ID 2
     b-export AT ROW 1 COL 48 WIDGET-ID 4
     b-import AT ROW 1 COL 58 WIDGET-ID 10
     B-Help AT ROW 1 COL 95
     rs-language AT ROW 2 COL 33.5 NO-LABEL WIDGET-ID 6
     br-laytables AT ROW 3 COL 1 WIDGET-ID 100
     SPACE(0.69) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Справочники конфигурации раскладок"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-laytables rs-language Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-laytables
/* Query rebuild information for BROWSE br-laytables
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_file NO-LOCK WHERE lookup(buf_file._file-name, v-layout-tables) > 0.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-laytables */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Справочники rule-машины */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-export Dialog-Frame
ON CHOOSE OF b-export IN FRAME Dialog-Frame /* Экспорт */
DO:
define variable v-file-name as character no-undo .
define variable v-old-file-name as character no-undo .
define variable v-dir-name as character no-undo .
define variable v-yesno as logical no-undo .
define variable v-mode-log as logical no-undo .
define variable v-mode as character no-undo .
message
"Хотите экспортировать уникальное имя каждой записи (uniq-key-rec)?"
view-as alert-box question buttons yes-no-cancel update v-mode-log.
if v-mode-log = ? then return no-apply.
if v-mode-log then do:
  v-mode = "full".
end.
message
"Хотите экспортировать ПОЛНУЮ конфигурацию раскладок" skip
"или только измененные записи?"
view-as alert-box question buttons yes-no-cancel update v-yesno.
if v-yesno = ? then return no-apply.
if v-yesno = no then do:
  run gbl/d-file.p (
        input-output v-old-file-name       /* p-file-id           */
      , input-output v-dir-name        /* p-file-directory    */
      , input  (" Все файлы txt (*.txt) ") /* p-filter-names      */
      , input  ("*.txt":U)                   /* p-filter-values     */
      , input  {&comma-char}                 /* p-filter-delimiter  */
      , input  (".txt":U)                    /* p-default-extension */
      , input  yes                            /* p-must-exist        */
      , input  no                           /* p-save-as           */
      , input  yes                           /* p-use-filename      */
      , input  "Введите имя старого файла (для сравнения)"           /* p-title             */
      , output v-yesno                       /* p-choose            */
  ) no-error.
  if error-status:error
  or v-yesno = no then return no-apply.
end.
v-yesno = no.
  run gbl/d-file.p (
        input-output v-file-name       /* p-file-id           */
      , input-output v-dir-name        /* p-file-directory    */
      , input  (" Все файлы txt (*.txt) ") /* p-filter-names      */
      , input  ("*.txt":U)                   /* p-filter-values     */
      , input  {&comma-char}                 /* p-filter-delimiter  */
      , input  (".txt":U)                    /* p-default-extension */
      , input  no                            /* p-must-exist        */
      , input  yes                           /* p-save-as           */
      , input  yes                           /* p-use-filename      */
      , input  "Введите имя файла для экспорта"           /* p-title             */
      , output v-yesno                       /* p-choose            */
  ) no-error.
  if error-status:error
  or v-yesno = no then return no-apply.

  run adm/exporlay.p (
                                 input v-file-name
                                ,input v-old-file-name
                                ,input v-mode
                               ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     MESSAGE
     ERROR-STATUS:GET-MESSAGE(1) SKIP
     RETURN-VALUE
     VIEW-AS ALERT-BOX.
     RETURN NO-APPLY.
  END.
  define variable v-md5-signature as character no-undo .
  define variable v-full-file-name          as character                no-undo .
  define variable v-path                    as character                no-undo .
  DEFINE VARIABLE v-full-path               as character                no-undo .
  DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
  DEFINE VARIABLE v-file-name-ext           as character                no-undo .

  run gbl/md5.p ( input v-file-name
                 ,output v-md5-signature ) .
  run gbl/filename.p (
                 input v-file-name
                ,output v-full-path
                ,output v-path
                ,output v-full-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
  if error-status:error then do:
    message
    return-value
    view-as alert-box ERROR.
    return.
  end.
  output to value(v-path + {&slash-char} + v-file-name-no-ext + ".md5").
  put unformatted v-md5-signature skip.
  output close.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-import
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-import Dialog-Frame
ON CHOOSE OF b-import IN FRAME Dialog-Frame /* Импорт */
DO:
define variable glog as logical no-undo.
message
"Хотите закачать новую конфигурацию?" skip
"ЕСЛИ НЕ УВЕРЕНЫ, ЧТО ЗНАЕТЕ ЗАЧЕМ ЭТО НАДО - НЕ ЗАКАЧИВАЙТЕ!!!!!"
view-as alert-box question buttons yes-no update glog.
if not glog then return no-apply.
run trg/fix-lay.p ( input yes
                   ,input no
                    ) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  run proc-b-sel IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-laytables
&Scoped-define SELF-NAME br-laytables
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-laytables Dialog-Frame
ON DEFAULT-ACTION OF br-laytables IN FRAME Dialog-Frame
DO:
  APPLY "CHOOSE" TO b-sel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-language
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-language Dialog-Frame
ON VALUE-CHANGED OF rs-language IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-language.
  CASE rs-language:
    WHEN "ABL" THEN DO:
      buf_file._file-name:VISIBLE IN BROWSE br-laytables = YES.
    END.
    WHEN "{&language}" THEN DO:
      buf_file._file-name:VISIBLE IN BROWSE br-laytables = NO.
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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/currsysk.i
    v-sys-key
    no-error
  }
  if error-status:error then return error.
  assign
  v-ibs = (v-sys-key = {&SuperSysKey}).
  if not v-ibs then do:
    message
    "Данная программа может вызываться только сотрудниками IBS" skip
    "Продолжать?" view-as alert-box question buttons yes-no update glog.
    if not glog then do:
      undo, return error .
    end.
    DEFINE VARIABLE v-value AS CHARACTER no-undo.
    DEFINE VARIABLE v-password AS CHARACTER no-undo.
    DEFINE VARIABLE v-today as date no-undo .
    DEFINE VARIABLE v-time as integer no-undo .
    run cur-time in this-procedure ( output v-today, output v-time).
    ASSIGN
    v-password = string((if weekday(v-today) = 1
                        then 7
                        else (weekday(v-today) - 1))
                        * 140).
        run gbl/d-prompt.w (
        'title=':u + "ВВЕДИТЕ ПАРОЛЬ" + '\':u
      + 'text1=' + substitute("Пароль") + '\':u
      + 'format=' + ">>>>>>>>9" + '\':u
      + 'type=' + {&type-int} + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=30\':u
      + 'fillin_height=1\':u
      + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
      + 'readonly=no\':u
      , input-output v-value
      ).
    if return-value = 'false':u
    then do:
      return no-apply.
    end.
    /*message v-password "v-password" skip v-value "v-value" view-as alert-box .*/
    IF v-value <> v-password THEN DO:
        MESSAGE
      "Неверный пароль!"
      VIEW-AS ALERT-BOX.
      RETURN error.
    END.
  end.
  assign
  v-layout-tables = v-layout-tables + {&comma-char} + {&table_layout} +
                                {&comma-char} + {&table_layout-elem} +
                                {&comma-char} + {&table_wi-mode} +
                                {&comma-char} + {&table_rule} +
                                {&comma-char} + {&table_ruleset}

                                .
  assign
  v-layout-table-names = v-layout-table-names + {&comma-char} + {&table_layout-full} +
                                {&comma-char} + {&table_layout-elem-full} +
                                {&comma-char} + {&table_wi-mode-full} +
                                {&comma-char} + "Правила (функции)" +
                                {&comma-char} + "Наборы правил (для органичения по режимам)"
                                .

  assign
  v-layout-tables = trim(v-layout-tables).
  v-layout-table-names = trim(v-layout-table-names).

  run Myenable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI.

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
  DISPLAY rs-language
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-sel b-export b-import B-Help rs-language br-laytables
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
rs-language:RADIO-BUTTONS IN FRAME {&FRAME-NAME} = "ABL" + {&comma-char} + "ABL" + {&comma-char} +
                                                 "{&language}" + {&comma-char} + "{&language}"
.
rs-language + "ABL".
ENABLE
b-quit
B-sel
B-Help
b-export
b-import
br-laytables
rs-language
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
run waitfram-show in this-procedure ( input "Ждите..." ).
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
run waitfram-hide in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sel Dialog-Frame
PROCEDURE proc-b-sel :
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
IF NOT AVAILABLE buf_file THEN DO:
   RETURN.
END.
CASE buf_file._file-name:
  WHEN {&TABLE_layout} THEN DO:
    run adm/layoutss.w ( INPUT parparentproc
                         ,INPUT (if v-ibs then
                                'b-add,admin':U
                                else '':U)
                                /*bttns*/
                         ,input {&all}
                         ,input "" /*p-layout-type*/
                         ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  END.
  WHEN {&TABLE_layout-elem} THEN DO:
    run adm/layoutes.w ( INPUT parparentproc
                         ,INPUT (if v-ibs then
                                'b-add,admin':U
                                else '':U)
                                /*bttns*/
                         ,input {&all}
                         ,input "" /*p-layout-type*/
                         ,input "" /*p-device-type*/
                         ,input "" /*p-mode-id*/
                         ,input ? /*p-elem-type*/
                         ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  END.
  WHEN {&TABLE_wi-mode} THEN DO:
    run adm/wi-modes.w ( INPUT parparentproc
                         ,INPUT (if v-ibs then
                                'b-add,admin':U
                                else '':U)
                                /*bttns*/
                         ,input {&all}
                         ,input "" /*p-mode-type*/
                         ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  end.
  WHEN {&TABLE_rule} THEN DO:
    run rul/rule-s.w ( INPUT parparentproc
                         ,INPUT (if v-ibs then
                                'b-add,admin':U
                                else '':U)
                                /*bttns*/
                         ,input "codex"
                         ,input 19
                         ,input -999999999
                         ,INPUT-OUTPUT v-rid-list) NO-ERROR.

  END.
  WHEN {&TABLE_ruleset} THEN DO:
    run rul/ruleset-s.w ( INPUT parparentproc
                         ,INPUT (if v-ibs then
                                'b-add,admin':U
                                else '':U)
                                /*bttns*/
                         ,input "codex"
                         ,input 19
                         ,INPUT-OUTPUT v-rid-list) NO-ERROR.

  END.


END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-tbl-fname Dialog-Frame
FUNCTION get-tbl-fname RETURNS CHARACTER ( INPUT p-tbl-name AS CHARACTER ) :
DEFINE VARIABLE v-tbl-fname AS CHARACTER NO-UNDO.

v-tbl-fname = ENTRY(LOOKUP(p-tbl-name, v-layout-tables), v-layout-table-names).
return v-tbl-fname.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME