&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_custom-labels FOR ub.custom-labels.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список настраиваемых полей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/07/07
Author: Bakhtadze Natalya
Creation date: 07/07/07

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER bttns AS character NO-UNDO.
DEFINE INPUT PARAMETER p-list-mode AS character NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rid-list AS character NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список настраиваемых полей".
{ cmp/vssrevis.i }
{ cmp/library.i  }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ gbl/cur-time.i }
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-sys-key as character no-undo .
define variable v-ibs as logical no-undo .
define variable glog as logical no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-custom-labels

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_custom-labels

/* Definitions for BROWSE br-custom-labels                              */
&Scoped-define FIELDS-IN-QUERY-br-custom-labels X_custom-labels.CALL-TYPE X_custom-labels.CALL-point X_custom-labels.tbl-name X_custom-labels.fld-name X_custom-labels.LANGUAGE
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-custom-labels
&Scoped-define SELF-NAME br-custom-labels
&Scoped-define QUERY-STRING-br-custom-labels FOR EACH X_custom-labels NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-custom-labels OPEN QUERY {&SELF-NAME} FOR EACH X_custom-labels NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-custom-labels X_custom-labels
&Scoped-define FIRST-TABLE-IN-QUERY-br-custom-labels X_custom-labels


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-custom-labels}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-copy b-chg b-lkp ~
b-del b-export B-Help br-custom-labels mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

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

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-copy
     LABEL "&Копировать"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-export
     LABEL "&Экспорт"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 4 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9 BY .67
     FGCOLOR 10  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-custom-labels FOR
      X_custom-labels SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-custom-labels
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-custom-labels Dialog-Frame _FREEFORM
  QUERY br-custom-labels NO-LOCK DISPLAY
      X_custom-labels.CALL-TYPE FORMAT "X(20)"
X_custom-labels.CALL-point FORMAT "X(20)"
X_custom-labels.tbl-name FORMAT "X(20)"
X_custom-labels.fld-name FORMAT "X(20)"
X_custom-labels.LANGUAGE FORMAT "X(3)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.3 BY 20.5 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 21 WIDGET-ID 12
     b-sel AT ROW 1 COL 25 WIDGET-ID 10
     b-add AT ROW 1 COL 35 WIDGET-ID 2
     b-copy AT ROW 1 COL 45 WIDGET-ID 18
     b-chg AT ROW 1 COL 55 WIDGET-ID 4
     b-lkp AT ROW 1 COL 65 WIDGET-ID 6
     b-del AT ROW 1 COL 75 WIDGET-ID 16
     b-export AT ROW 1 COL 85 WIDGET-ID 22
     B-Help AT ROW 1 COL 95
     br-custom-labels AT ROW 2.5 COL 1.5 WIDGET-ID 100
     mark-num AT ROW 1 COL 11 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     SPACE(77.75) SKIP(21.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_custom-labels B "?" ? ub custom-labels
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-custom-labels B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-custom-labels
/* Query rebuild information for BROWSE br-custom-labels
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_custom-labels NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-custom-labels */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame
DO:
  p-rid-list = v-rid-list.
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


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
DEFINE VARIABLE v-rec AS RECID no-unDO.
   run utl/cuslabli.w ( input parparentproc
                       ,input {&add-def}
                       ,input '':U /*p-tbl-name*/
                       ,input '':U /*p-fld-point*/
                       ,input '':U /*p-call-type*/
                       ,input '':U /*p-call-point*/
                       ,input '':U /*p-language*/
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
    {&OPEN-QUERY-{&BROWSE-NAME}}
    REPOSITION br-custom-labels TO RECID v-rec NO-ERROR.
    APPLY "value-changed" to br-custom-labels.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
 IF NOT AVAILABLE X_custom-labels THEN RETURN NO-APPLY.
  v-rec = recid(X_custom-labels).
  run utl/cuslabli.w ( input parparentproc
                       ,input {&UPDATE}
                       ,input X_custom-labels.tbl-name
                       ,input X_custom-labels.fld-name
                       ,input X_custom-labels.CALL-TYPE
                       ,input X_custom-labels.call-point
                       ,input X_custom-labels.LANGUAGE
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
    {&OPEN-QUERY-{&BROWSE-NAME}}
    REPOSITION br-custom-labels TO RECID v-rec NO-ERROR.
    APPLY "value-changed" to br-custom-labels.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-copy Dialog-Frame
ON CHOOSE OF b-copy IN FRAME Dialog-Frame /* Копировать */
DO:
DEFINE VARIABLE v-rec AS RECID no-unDO.
IF NOT available X_custom-labels THEN RETURN NO-APPLY.
   run utl/cuslabli.w ( input parparentproc
                       ,input {&add-copy}
                       ,input X_custom-labels.tbl-name /*p-tbl-name*/
                       ,input X_custom-labels.fld-name /*p-fld-point*/
                       ,input X_custom-labels.call-type /*p-call-type*/
                       ,input X_custom-labels.call-point /*p-call-point*/
                       ,input X_custom-labels.language /*p-language*/
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
    {&OPEN-QUERY-{&BROWSE-NAME}}
    REPOSITION br-custom-labels TO RECID v-rec NO-ERROR.
    APPLY "value-changed" to br-custom-labels.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  define variable v-rec as recid no-undo.
  define variable glog as logical no-undo.
  if not available X_custom-labels then return no-apply.
  v-rec = recid(X_custom-labels).
  message "Вы уверены, что хотите удалить поле?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then return no-apply.
 run utl/cuslabl3.p ( input no /*p-silent*/
                       ,input v-rec) no-error.
 if error-status:error then return no-apply.
 {&OPEN-QUERY-{&BROWSE-NAME}}
 REPOSITION br-custom-labels TO ROW 1 NO-ERROR.
 APPLY "value-changed" to br-custom-labels.

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
"Хотите экспортировать ПОЛНУЮ конфигурацию правил НАСТРАИВАЕМЫХ ПОЛЕЙк" skip
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
  run utl/excuslab.p (
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
    DEFINE VARIABLE v-rec AS RECID NO-UNDO.
   IF NOT AVAILABLE X_custom-labels THEN RETURN NO-APPLY.
    v-rec = recid(X_custom-labels).
    run utl/cuslabli.w ( input parparentproc
                         ,input {&LOOKUP}
                         ,input X_custom-labels.tbl-name
                         ,input X_custom-labels.fld-name
                         ,input X_custom-labels.CALL-TYPE
                         ,input X_custom-labels.call-point
                         ,input X_custom-labels.LANGUAGE
                         ,input-output v-rec) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable glog as logical no-undo .
  if available X_custom-labels then do:
 { gbl/markstrn.i X_custom-labels v-rid-list }
  glog = br-custom-labels:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-custom-labels:select-next-row ().
      apply "VALUE-CHANGED" to br-custom-labels in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-custom-labels in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available X_custom-labels then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_custom-labels ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-custom-labels
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

  v-rid-list = p-rid-list.
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
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel b-add b-copy b-chg b-lkp b-del b-export B-Help
         br-custom-labels mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ENABLE
b-quit
B-Help
br-custom-labels
b-add when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-chg when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-del when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-copy when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-lkp
B-Help
b-mark when lookup("b-mark", bttns) > 0
b-sel when lookup("b-sel", bttns) > 0
b-export when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME