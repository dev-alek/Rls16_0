&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_clob-bind FOR ub.clob-bind.
DEFINE BUFFER X_clob-data FOR ub.clob-data.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список гейтов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/02/08
Author: Bakhtadze Natalya
Creation date: 02/02/08

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
define variable vss-description as character no-undo init "Список гейтов".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ cmp/tblfname.i }
{ gbl/cur-time.i }
{ nws/db-rec.i   }
{ trg/clbdattd.i }
{ gbl/key-rec.i }
define variable v-gate-tables as character no-undo.
define variable v-gate-table-names as character no-undo.
define variable v-sys-key as character no-undo .
define variable v-ibs as logical no-undo .
define variable glog as logical no-undo .
define variable del-option as character no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-gates

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_clob-bind X_clob-data

/* Definitions for BROWSE br-gates                                      */
&Scoped-define FIELDS-IN-QUERY-br-gates X_clob-bind.uniq-key-rec (X_clob-bind.int64-id = X_clob-data.int64-id) X_clob-data.int64-id (if (X_clob-bind.int64-id = X_clob-data.int64-id) then X_clob-bind.sys-date else ?) (if (X_clob-bind.int64-id = X_clob-data.int64-id) then X_clob-bind.sys-time else '') (if (X_clob-bind.int64-id = X_clob-data.int64-id) then X_clob-bind.user-name else '') X_clob-data.int64-id X_clob-data.crc-field X_clob-data.file-size X_clob-data.sys-date X_clob-data.sys-time X_clob-data.user-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-gates
&Scoped-define SELF-NAME br-gates
&Scoped-define QUERY-STRING-br-gates FOR EACH X_clob-bind NO-LOCK where       X_clob-bind.resource-type = {&lob-res-gate} and       X_clob-bind.db-num = 0 and       X_clob-bind.int64-id > 0       , ~
             EACH X_clob-data outer-join NO-LOCK where       (X_clob-data.db-num = X_clob-bind.db-num   and X_clob-data.int64-id = X_clob-bind.int64-id )   or (X_clob-data.file-name = X_clob-bind.uniq-key-rec       and       X_clob-data.resource-type = {&lob-res-gate})        INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-gates OPEN QUERY {&SELF-NAME} FOR EACH X_clob-bind NO-LOCK where       X_clob-bind.resource-type = {&lob-res-gate} and       X_clob-bind.db-num = 0 and       X_clob-bind.int64-id > 0       , ~
             EACH X_clob-data outer-join NO-LOCK where       (X_clob-data.db-num = X_clob-bind.db-num   and X_clob-data.int64-id = X_clob-bind.int64-id )   or (X_clob-data.file-name = X_clob-bind.uniq-key-rec       and       X_clob-data.resource-type = {&lob-res-gate})        INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-gates X_clob-bind X_clob-data
&Scoped-define FIRST-TABLE-IN-QUERY-br-gates X_clob-bind
&Scoped-define SECOND-TABLE-IN-QUERY-br-gates X_clob-data


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-gates}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-add b-chg b-lkp b-del b-version ~
b-export B-Help br-gates E-descr
&Scoped-Define DISPLAYED-OBJECTS E-descr

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-del
       MENU-ITEM m_clob-data    LABEL "CLOB-DATA"
       MENU-ITEM m_clob-bind    LABEL "clob-bind"
       MENU-ITEM m_both         LABEL "Обоих"         .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-export
     LABEL "Экспорт"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-version
     LABEL "Уст.верc."
     SIZE 10 BY 1.

DEFINE VARIABLE E-descr AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-gates FOR
      X_clob-bind,
      X_clob-data SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-gates
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-gates Dialog-Frame _FREEFORM
  QUERY br-gates NO-LOCK DISPLAY
      X_clob-bind.uniq-key-rec column-label "Файл" format "X(40)"
(X_clob-bind.int64-id = X_clob-data.int64-id) column-label "Тек" format "+/"
X_clob-data.int64-id column-label "id связки"
(if (X_clob-bind.int64-id = X_clob-data.int64-id)
then X_clob-bind.sys-date
else ?) column-label "Дата!связки" format "99/99/9999"
(if (X_clob-bind.int64-id = X_clob-data.int64-id)
then X_clob-bind.sys-time
else '') column-label "Время!связки" format "X(8)"
(if (X_clob-bind.int64-id = X_clob-data.int64-id)
then X_clob-bind.user-name
else '') column-label "Изменил!связку" format "X(8)"
X_clob-data.int64-id column-label "id cdata"
X_clob-data.crc-field column-label "MD5"
X_clob-data.file-size column-label "Длина файла"
X_clob-data.sys-date column-label "Дата!cdata" format "99/99/9999"
X_clob-data.sys-time column-label "Время!cdata" format "X(8)"
X_clob-data.user-name column-label "Изменил!cdata" format "X(8)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.27 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-add AT ROW 1 COL 31 WIDGET-ID 2
     b-chg AT ROW 1 COL 41 WIDGET-ID 4
     b-lkp AT ROW 1 COL 51 WIDGET-ID 12
     b-del AT ROW 1 COL 61 WIDGET-ID 6
     b-version AT ROW 1 COL 71 WIDGET-ID 14
     b-export AT ROW 1 COL 81 WIDGET-ID 8
     B-Help AT ROW 1 COL 95
     br-gates AT ROW 3 COL 1 WIDGET-ID 100
     E-descr AT ROW 21.27 COL 1 NO-LABEL WIDGET-ID 10
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список гейтов, имеющихся в системе"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_clob-bind B "?" ? ub clob-bind
      TABLE: X_clob-data B "?" ? ub clob-data
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-gates B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-del:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-del:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-gates
/* Query rebuild information for BROWSE br-gates
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_clob-bind NO-LOCK where
      X_clob-bind.resource-type = {&lob-res-gate} and
      X_clob-bind.db-num = 0 and
      X_clob-bind.int64-id > 0
      ,
      EACH X_clob-data outer-join NO-LOCK where
      (X_clob-data.db-num = X_clob-bind.db-num
  and X_clob-data.int64-id = X_clob-bind.int64-id )
  or (X_clob-data.file-name = X_clob-bind.uniq-key-rec
      and
      X_clob-data.resource-type = {&lob-res-gate})

      INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-gates */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список гейтов, имеющихся в системе */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  run proc-b-add in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  if not available X_clob-bind then undo, return no-apply.
  run proc-b-chg in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  define variable v-rec as recid no-undo.
  if not available X_clob-bind
  and not available X_clob-data
  then undo, return no-apply.
  IF del-option = '':U THEN DO:
    run gbl/pop-up.p ( INPUT SELF :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if del-option = "":U then do:
      return no-apply.
  end.
  run proc-b-del in this-procedure ( input del-option) no-error.
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
"??Хотите экспортировать уникальное имя каждой записи (uniq-key-rec)?"
view-as alert-box question buttons yes-no-cancel update v-mode-log.
if v-mode-log = ? then return no-apply.
if v-mode-log then do:
  v-mode = "full".
end.
message
"Хотите экспортировать ПОЛНУЮ конфигурацию GATE" skip
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
      , input  (" Все файлы? txt (*.txt) ") /* p-filter-names      */
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

  run utl/export-current-gate.p (
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


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
    define variable v-longchar as longchar no-undo .
    define variable v-ok as logical no-undo .
    if not available X_clob-data then return no-apply.
    v-longchar = X_clob-data.cdata.
    run gbl/d-longchar.w (
                           input ? /*r h-callback  */
                          ,input (
                                    'title=':u + X_clob-data.file-name_ + '\':u
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


&Scoped-define SELF-NAME b-version
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-version Dialog-Frame
ON CHOOSE OF b-version IN FRAME Dialog-Frame /* Уст.верc. */
DO:
  run proc-b-vers in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-gates
&Scoped-define SELF-NAME br-gates
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-gates Dialog-Frame
ON VALUE-CHANGED OF br-gates IN FRAME Dialog-Frame
DO:
  if available X_clob-bind then do:
    e-descr:screen-value = X_clob-bind.descr.
  end.
  else do:
    e-descr:screen-value = "".
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_both
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_both Dialog-Frame
ON CHOOSE OF MENU-ITEM m_both /* Обоих */
DO:
    ASSIGN
  del-option = "both".
  run proc-b-del IN THIS-PROCEDURE ( INPUT del-option) NO-ERROR.
  ASSIGN
  del-option = '':U.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_clob-bind
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_clob-bind Dialog-Frame
ON CHOOSE OF MENU-ITEM m_clob-bind /* clob-bind */
DO:
     ASSIGN
  del-option = {&table_clob-bind}.
  run proc-b-del IN THIS-PROCEDURE ( INPUT del-option) NO-ERROR.
  ASSIGN
  del-option = '':U.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_clob-data
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_clob-data Dialog-Frame
ON CHOOSE OF MENU-ITEM m_clob-data /* CLOB-DATA */
DO:
       ASSIGN
  del-option = {&table_clob-data}.
  run proc-b-del IN THIS-PROCEDURE ( INPUT del-option) NO-ERROR.
  ASSIGN
  del-option = '':U.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.


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
  { gbl/getcntxt.i get }
  { gbl/currsysk.i
    v-sys-key
    no-error
  }
  if error-status:error then return error.
  assign
  v-ibs = (v-sys-key = {&SuperSysKey}).
  /*if not v-ibs then do:
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
  end.              */
  assign
  v-gate-tables = v-gate-tables + {&comma-char} + {&table_clob-bind} +
                                {&comma-char} + {&table_clob-data}
                                .
  assign
  v-gate-table-names = v-gate-table-names + {&comma-char} + {&table_clob-bind-full} +
                                {&comma-char} + {&table_clob-data-full}
                                .

  assign
  v-gate-tables = trim(v-gate-tables).


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
  DISPLAY E-descr
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-add b-chg b-lkp b-del b-version b-export B-Help br-gates
         E-descr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
assign
b-del:menu-mouse in frame {&frame-name}  = 1
e-descr:read-only in frame {&frame-name} = yes
.
ENABLE
b-quit
b-add when v-cntxt-db-num = 0
b-chg when v-cntxt-db-num = 0
b-del when v-cntxt-db-num = 0
b-lkp
B-Help
b-version when v-cntxt-db-num = 0
b-export
br-gates
E-descr
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
apply "value-changed" to br-gates.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
define variable v-part-num as integer   no-undo .
define variable v-clob-db-num as integer   no-undo .
define variable v-int64-id as int64 no-undo .
define variable v-descr as character no-undo .
define variable v-file-name0 as character no-undo .
define variable v-ok as logical   no-undo .
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .

/*выберем файл*/
system-dialog get-file v-file-name0
filters "Гейты *.xsd" "*.xsd"
use-filename
initial-dir "exe"
must-exist
update glog
default-extension "xsd".
if v-file-name0 = ""
or v-file-name0 = ? then do:
  undo, return error.
end.
run gbl/filename.p (
                input v-file-name0
              ,output v-full-path
              ,output v-path
              ,output v-file-name
              ,output v-file-name-no-ext
              ,output v-file-name-ext
              ) no-error .
if error-status:error then do:
  undo, return error .
end.
v-file-name0 = entry(num-entries(v-path, {&back-slash-char}), v-path, {&back-slash-char}) + {&slash-char} + v-file-name.
run gbl/d-character.w (
      input ?
      ,input (
      'title=':u + substitute("Описание применения гейта &1", v-file-name0) + '\':u
    + 'format=' + "X(75)" + '\':u
    + 'fillin_row=4\':u
    + 'fillin_col=4\':u
    + 'fillin_width=75\':u
    + 'fillin_height=1\':u
    + 'max-chars=75\':u
    + 'readonly=' + 'no':u + '\':u)
    , input-output v-descr
    , output v-ok
        ).
if not v-ok then return error.
assign
v-clob-db-num = ?
v-int64-id = 0
.
run gbl/file2clb.p ( input {&add-def}
                    ,input "" /*p-clob-mode*/
                    ,input ? /*p-bh*/
                    ,input v-file-name0
                    ,input '':U /*p-field-*/
                    ,input v-descr
                    ,input-output v-part-num
                    ,input {&lob-res-gate} /*p-resource-type*/
                    ,input-output v-clob-db-num
                    ,input-output v-int64-id
                    ,input v-file-name0
                    ,input ? /*p-src-encoding*/
                    ) no-error .
if error-status:error then do:
  message error-status :error  skip
  return-value
  view-as alert-box error .
  undo, return error  .
end.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
apply "value-changed" to br-gates in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg :
define variable v-part-num as integer   no-undo .
define variable v-clob-db-num as integer   no-undo .
define variable v-int64-id as int64 no-undo .
define variable v-old-clob-db-num as integer   no-undo .
define variable v-old-int64-id as int64 no-undo .

define variable v-descr as character no-undo .
define variable v-file-name0 as character no-undo .
define variable v-ok as logical   no-undo .
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define buffer buf_clob-data for ub.clob-data.

/*выберем файл*/
system-dialog get-file v-file-name0
filters "Гейты *.xsd" "*.xsd"
use-filename
initial-dir "exe"
must-exist
update glog
default-extension "xsd".
if v-file-name0 = ""
or v-file-name0 = ? then do:
  undo, return error.
end.
run gbl/filename.p (
                input v-file-name0
              ,output v-full-path
              ,output v-path
              ,output v-file-name
              ,output v-file-name-no-ext
              ,output v-file-name-ext
              ) no-error .
if error-status:error then do:
  undo, return error .
end.
v-file-name0 = entry(num-entries(v-path, {&back-slash-char}), v-path, {&back-slash-char}) + {&slash-char} + v-file-name.
v-descr = X_clob-bind.descr.
run gbl/d-character.w (
      input ?
      ,input (
      'title=':u + substitute("Описание применения гейта &1", v-file-name0) + '\':u
    + 'format=' + "X(75)" + '\':u
    + 'fillin_row=4\':u
    + 'fillin_col=4\':u
    + 'fillin_width=75\':u
    + 'fillin_height=1\':u
    + 'max-chars=75\':u
    + 'readonly=' + 'no':u + '\':u)
    , input-output v-descr
    , output v-ok
        ).
if not v-ok then return error.
assign
v-old-clob-db-num = X_clob-bind.db-num
v-old-int64-id = X_clob-bind.int64-id
v-clob-db-num = X_clob-bind.db-num
v-int64-id = X_clob-bind.int64-id
v-part-num = X_clob-bind.part-num
.
run gbl/file2clb.p ( input {&update}
                    ,input "add-new" /*p-clob-mode*/
                    ,input ? /*p-bh*/
                    ,input v-file-name0
                    ,input '':U /*p-field-*/
                    ,input v-descr
                    ,input-output v-part-num
                    ,input {&lob-res-gate} /*p-resource-type*/
                    ,input-output v-clob-db-num
                    ,input-output v-int64-id
                    ,input v-file-name0
                    ,input ? /*p-src-encoding*/
                    ) no-error .
if error-status:error then do:
  message error-status :error  skip
  return-value
  view-as alert-box error .
  undo, return error  .
end.
find first buf_clob-data no-lock where
          buf_clob-data.db-num = v-old-clob-db-num
      and buf_clob-data.int64-id = v-old-int64-id no-error.
if available buf_clob-data then do:
  run clbdattd_two-commit-del in this-procedure ( buffer buf_clob-data, input 1) no-error.
  if error-status :error then do:
    undo , return error substitute("Ошибка при попытке запустить удаление неиспользуемых clob-data &1 (&2&3)(2)&4&5&4&6"
                                              ,buf_clob-data.file-name_
                                              ,buf_clob-data.db-num
                                              ,buf_clob-data.int64-id
                                              ,{&new-line}
                                              , error-status:get-message(1)
                                              , return-value ).
  end.
end.

{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
apply "value-changed" to br-gates in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
define input parameter p-option as character no-undo.
define variable v-clob-db-num as integer   no-undo .
define variable v-int64-id as int64 no-undo .
define variable v-part-num as integer   no-undo .
define buffer buf_clob-data for ub.clob-data.
case p-option:
  when "both" then do:
     find first buf_clob-data no-lock where
              buf_clob-data.db-num = X_clob-bind.db-num
          and buf_clob-data.int64-id = X_clob-bind.int64-id no-error.

      assign
      v-clob-db-num = X_clob-bind.db-num
      v-int64-id = X_clob-bind.int64-id
      v-part-num = X_clob-bind.part-num
      .
      run gbl/file2clb.p ( input {&deletion}
                          ,input "leave" /*p-clob-mode*/
                          ,input ? /*p-bh*/
                          ,input X_clob-bind.uniq-key-rec
                          ,input X_clob-bind.field-name
                          ,input '':U
                          ,input-output v-part-num
                          ,input {&lob-res-gate} /*p-resource-type*/
                          ,input-output v-clob-db-num
                          ,input-output v-int64-id
                          ,input X_clob-bind.uniq-key-rec
                          ,input ? /*p-src-encoding*/
                          ) no-error .
     if error-status :error then do:
       message
       error-status:get-message(1) skip
       return-value
       view-as alert-box error .
       undo , return error return-value .
     end.
  end.
  when {&table_clob-bind} then do:
      assign
      v-clob-db-num = X_clob-bind.db-num
      v-int64-id = X_clob-bind.int64-id
      v-part-num = X_clob-bind.part-num
      .
      run gbl/file2clb.p ( input {&deletion}
                          ,input "leave" /*p-clob-mode*/
                          ,input ? /*p-bh*/
                          ,input X_clob-bind.uniq-key-rec
                          ,input X_clob-bind.field-name
                          ,input '':U
                          ,input-output v-part-num
                          ,input {&lob-res-gate} /*p-resource-type*/
                          ,input-output v-clob-db-num
                          ,input-output v-int64-id
                          ,input X_clob-bind.uniq-key-rec
                          ,input ? /*p-src-encoding*/
                          ) no-error .
     if error-status :error then do:
       message
       error-status:get-message(1) skip
       return-value
       view-as alert-box error .
       undo , return error return-value .
     end.
  end.
  when {&table_clob-data} then do:
     find first buf_clob-data no-lock where
              buf_clob-data.db-num = X_clob-data.db-num
          and buf_clob-data.int64-id = X_clob-data.int64-id no-error.

  end.
end case.
if available buf_clob-data then do:
  run clbdattd_two-commit-del in this-procedure ( buffer buf_clob-data, input 1) no-error.
  if error-status :error then do:
    undo , return error substitute("Ошибка при попытке запустить удаление неиспользуемых clob-data &1 (&2&3)(2)&4&5&4&6"
                                              ,buf_clob-data.file-name_
                                              ,buf_clob-data.db-num
                                              ,buf_clob-data.int64-id
                                              ,{&new-line}
                                              , error-status:get-message(1)
                                              , return-value ).
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-vers Dialog-Frame
PROCEDURE proc-b-vers :
define variable v-descr as character no-undo.
define variable v-ok as logical no-undo.

define buffer buf_clob-bind for ub.clob-bind.
find first buf_clob-bind share-lock where
           buf_clob-bind.db-num = 0
       and buf_clob-bind.int64-id = 0 no-error.
if not available buf_clob-bind then do:
    v-descr = "v15_0.0".
    create buf_clob-bind.
    assign
    buf_clob-bind.db-num = 0
    buf_clob-bind.int64-id = 0
    buf_clob-bind.resource-type = {&lob-res-gate}
    .
end.
else do:
    v-descr = buf_clob-bind.descr.
end.

run gbl/d-character.w (
    input ? /*callback*/
      ,input (
      'title=':u + "Изменение версии кофигурации гейтов" + '\':u
    + 'text1=':u + "версия" + '\':u
    + 'format=' + "X(8)" + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=8\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u
    + 'readonly=no\')
    , input-output v-descr
    , output v-ok
        ).
    if not v-ok then return NO-apply.
buf_clob-bind.descr = v-descr.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME