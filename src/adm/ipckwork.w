&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_ext-file FOR ub.ext-file.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Работа с файлами, сохраненными в БД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/07/06
Author: Bakhtadze Natalya
Creation date: 08/07/06


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-all-or-upg  as integer no-undo .
/*0 все ext-file 1 только пакеты  обновлений*/
DEFINE INPUT PARAMETER p-db-num AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-from-db-num AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-file-name AS CHARACTER NO-UNDO.
/*имеет смысл только при p-all-or-upg = 1*/
DEFINE INPUT PARAMETER p-status_ AS CHARACTER NO-UNDO.
/*имеет смысл только при p-all-or-upg = 1*/
DEFINE INPUT-OUTPUT PARAMETER p-rid-list AS CHARACTER NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Работа с файлами, сохраненными в БД".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/mrk-strf.i }
{ gbl/flt-def.i }
{ gbl/fltfield.i }
{ gbl/getcntxt.i DEF }
{ nws/bintrnpr.i "NEW SHARED" }
{ gbl/fltopend.i defproc }

DEFINE VARIABLE add-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE del-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable sort-column-name as character no-undo .
define variable filter-point-name as character no-undo .
define variable filter-point as character no-undo init "ipckwork" .
define variable filter-point0 as character no-undo init "ipckwork" .

&SCOPED-DEFINE sort-clmn_3  X_ext-file.db-num
&scoped-define label-clmn_3 'Для БД'

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-ipck

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_ext-file

/* Definitions for BROWSE br-ipck                                       */
&Scoped-define FIELDS-IN-QUERY-br-ipck mark-string ( input recid(x_ext-file), input v-rid-list) X_ext-file.file-name {&sort-clmn_3} X_ext-file.STATUS_ X_ext-file.update-sys-date X_ext-file.update-sys-time X_ext-file.update-user-name X_ext-file.file-num X_ext-file.from-db-num X_ext-file.file-size X_ext-file.create-sys-time X_ext-file.create-sys-date
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-ipck X_ext-file.update-user-name
&Scoped-define ENABLED-TABLES-IN-QUERY-br-ipck X_ext-file
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-ipck X_ext-file
&Scoped-define SELF-NAME br-ipck
&Scoped-define QUERY-STRING-br-ipck FOR EACH X_ext-file NO-LOCK WHERE X_ext-file.file-num < 2147483647      INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-ipck OPEN QUERY {&SELF-NAME} FOR EACH X_ext-file NO-LOCK WHERE X_ext-file.file-num < 2147483647      INDEXED-REPOSITION .
&Scoped-define TABLES-IN-QUERY-br-ipck X_ext-file
&Scoped-define FIRST-TABLE-IN-QUERY-br-ipck X_ext-file


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-ipck}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark B-add B-del b-check b-params ~
b-install b-output-params b-save b-lkp b-sch B-Help br-ipck mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-add
       MENU-ITEM m_auto         LABEL "Отослать и зарегистрировать"
       MENU-ITEM m_manual       LABEL "Зарегистрировать".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-check
     LABEL "&Проверка"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-install
     LABEL "&Установить"
     SIZE 10 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Сохранить на диск".

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 4 BY 1.

DEFINE BUTTON b-output-params
     LABEL "&Рез.вып."
     SIZE 10 BY 1.

DEFINE BUTTON b-params
     LABEL "Пар-тры"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-save
     LABEL "&Сохр."
     SIZE 10 BY 1 TOOLTIP "Сохранить на диск".

DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 10.5 BY .67
     FGCOLOR 10  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-ipck FOR
      X_ext-file SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-ipck
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-ipck Dialog-Frame _FREEFORM
  QUERY br-ipck NO-LOCK DISPLAY
      mark-string ( input recid(x_ext-file), input v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
    WIDTH 2
X_ext-file.file-name COLUMN-LABEL "Файл манифеста" FORMAT "X(255)":U WIDTH 40
{&sort-clmn_3} column-label {&label-clmn_3} FORMAT "->>>>9":U
X_ext-file.STATUS_ FORMAT "X(12)":U
X_ext-file.update-sys-date COLUMN-LABEL "Дата устан.!/регистр." FORMAT "99/99/9999":U
X_ext-file.update-sys-time COLUMN-LABEL "Время устан.!/регистр." FORMAT "X(8)":U
X_ext-file.update-user-name COLUMN-LABEL "Установил!/Зарегистр." FORMAT "X(12)":U
X_ext-file.file-num COLUMN-LABEL "№ файла" FORMAT "->>>>>>>>9":U
X_ext-file.from-db-num COLUMN-LABEL "Из Бд" FORMAT ">>>>>>>>9":U
X_ext-file.file-size COLUMN-LABEL "Размер" FORMAT ">>>>>>>>9":U
X_ext-file.create-sys-time COLUMN-LABEL "Дата файла" FORMAT "X(5)":U
X_ext-file.create-sys-date COLUMN-LABEL "Время файла" FORMAT "99/99/9999":U
ENABLE
X_ext-file.update-user-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16
         TITLE "" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 17
     B-add AT ROW 1 COL 21
     B-del AT ROW 1 COL 31
     b-check AT ROW 1 COL 41
     b-params AT ROW 1 COL 41
     b-install AT ROW 1 COL 51
     b-output-params AT ROW 1 COL 51
     b-save AT ROW 1 COL 61
     b-lkp AT ROW 1 COL 71 WIDGET-ID 2
     b-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     br-ipck AT ROW 3 COL 1
     mark-num AT ROW 2 COL 2 NO-LABEL
     SPACE(86.74) SKIP(16.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Зарегистрированные пакеты обновлений"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_ext-file B "?" ? ub ext-file
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-ipck B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add:HANDLE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-ipck
/* Query rebuild information for BROWSE br-ipck
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_ext-file NO-LOCK WHERE X_ext-file.file-num < 2147483647
     INDEXED-REPOSITION .
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-ipck */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Зарегистрированные пакеты обновлений */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  if add-option = '':U then do:
    run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if add-option = '':U then return no-apply.
  run proc-b-add in this-procedure (input add-option) no-error.
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.
  APPLY "ENTRY" to br-ipck.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-check
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-check Dialog-Frame
ON CHOOSE OF b-check IN FRAME Dialog-Frame /* Проверка */
DO:
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE BUFFER buf_ext-file FOR ub.ext-file.
_ii:
DO ii = 1 TO NUM-ENTRIES(v-rid-list):
 FIND FIRST buf_Ext-file WHERE
           recid(buf_Ext-file) = INTEGER( ENTRY(ii, v-rid-list)) .
 IF LOOKUP( "ok", ENTRY(1, buf_ext-file.STATUS_, {&delim-par})) > 0 THEN DO:
     message
     substitute("Пакет обновлений &1 на БД &2 инсталлирован&3Отсылка запроса не производится"
                  ,buf_Ext-file.FILE-NAME
                  ,buf_Ext-file.db-num
                  ,{&NEW-LINE}
                   )
     view-as ALERT-BOX WARNING .
     NEXT _ii.
 END.
 IF abs(buf_ext-file.db-num) = v-cntxt-db-num
 AND v-cntxt-db-num = 0 THEN DO:
     run adm/ipck-chk.p ( INPUT parparentproc
                          ,INPUT THIS-PROCEDURE:HANDLE
                          ,INPUT parparentproc
                          ,INPUT (string(buf_ext-file.db-num)
                                    + {&delim-par} + string(buf_ext-file.from-db-num)
                                    + {&delim-par} + buf_ext-file.FILE-NAME
                                    + {&delim-par} + {&query})) no-error.
    if error-status:error then do:
      message
      error-status:get-message(1) skip
      return-value view-as alert-box error.
    end.
 END.
 ELSE DO:
     run nws/cr-route.p (
                       input {&send-cmd}
                      ,input ("command"
                              + {&delim-nws} + "run-file"
                              + {&delim-nws} + "ipck-chk.p"
                              + {&delim-nws} + (string(buf_ext-file.db-num)
                              + {&delim-par} +  string(buf_ext-file.from-db-num)
                              + {&delim-par} + buf_ext-file.FILE-NAME
                              + {&delim-par} + {&QUEry})  )

                      ,input ?
                      ,input string(abs(buf_ext-file.db-num))
                      ) no-error .
      if error-status:error then do:
        message
        substitute("Ошибка при отсылке запроса корректности зарегистрированного пакета&1&2"  +
                     "&3&3&4&2"
                     ,buf_Ext-file.FILE-NAME
                     , error-status:get-message(1)
                     , return-value )
        view-as alert-box error .
        NEXT _ii.
      end.
    END.
    DEFINE VARIABLE v-dop AS CHARACTER NO-UNDO.
    ASSIGN
    v-dop = entry(1, buf_Ext-file.STATUS_, {&delim-par})
    v-dop = REPLACE(v-dop, {&ready-ready}, "":U)
    v-dop = trim(v-dop, {&comma-char})
    v-dop = REPLACE(v-dop, {&comma-char} + {&comma-char}, {&comma-char})
    v-dop = v-dop + {&comma-char} + {&question-mark}
    v-dop = trim(v-dop, {&comma-char}).
    ENTRY(1, buf_Ext-file.STATUS_, {&delim-par}) = v-dop.
  END.
  br-ipck:REFRESH().

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  DEFINE VARIABLE del-option AS CHARACTER NO-UNDO.
  IF NOT AVAILABLE X_ext-file THEN RETURN NO-APPLY.
  IF LOOKUP({&auto}, X_ext-file.STATUS_) > 0 THEN do:
    del-option = {&auto}.
  END.
  ELSE do:
    del-option = {&manual}.
  END.

  run proc-b-del in this-procedure ( input del-option) no-error.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  APPLY "ENTRY" to br-ipck.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  IF NOT AVAILABLE X_ext-file THEN RETURN NO-APPLY.
  run proc-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
    define variable loc#log as logical no-undo .
    if available X_ext-file then do:
      { gbl/markstrn.i X_ext-file v-rid-list }
      loc#log = br-ipck:refresh() .

      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          loc#log = br-ipck:select-next-row ().
          apply "VALUE-CHANGED" to br-ipck in frame {&frame-name}.
      end.
      if num-entries( v-rid-list ) = 0
      then
          hide mark-num in frame {&frame-name}.
      else
          DISPLAY
           num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
    end.
    apply "entry" to br-ipck in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-output-params
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-output-params Dialog-Frame
ON CHOOSE OF b-output-params IN FRAME Dialog-Frame /* Рез.вып. */
DO:
  IF NOT AVAILABLE X_ext-file THEN RETURN NO-APPLY.
  if NOT (ENTRY(1, X_ext-file.STATUS_, {&delim-par})  = {&save-disk-and-run}
          OR entry(1, X_ext-file.STATUS_, {&delim-par})  = {&save-db-and-run}
          OR X_ext-file.file-type begins ({&table_cash-desk}  + {&delim-key})
          )
          THEN DO:
      MESSAGE
      substitute("Просмотр результатов выполнения доступен только для файлов, переданных в режиме &1 и &2"
                 , {&Save-db-and-run}
                 , {&save-disk-and-run})
      VIEW-AS ALERT-BOX.
      RETURN NO-APPLY.

  END.
  run nws/sndfnwp.w ( INPUT parparentproc
                  ,INPUT {&LOOKUP}
                  ,INPUT "output"
                  ,INPUT X_ext-file.db-num
                  ,INPUT X_ext-file.from-db-num
                  ,INPUT X_ext-file.file-num

                  ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-params
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-params Dialog-Frame
ON CHOOSE OF b-params IN FRAME Dialog-Frame /* Пар-тры */
DO:
  IF NOT AVAILABLE X_ext-file THEN RETURN NO-APPLY.
  IF not (entry(1, X_ext-file.STATUS_, {&delim-par}) = {&save-disk-and-run}
  or      entry(1, X_ext-file.STATUS_, {&delim-par}) <> {&save-db-and-run}
  or X_ext-file.file-type begins ({&table_cash-desk} + {&delim-key} ))
  THEN DO:
     MESSAGE
     substitute("Просмотр параметров доступен только для файлов, переданных в режиме &1 и &2"
                , {&Save-db-and-run}
                , {&save-disk-and-run})
     VIEW-AS ALERT-BOX.
     RETURN NO-APPLY.
  END.
  run nws/sndfnwp.w ( INPUT parparentproc
                  ,INPUT {&LOOKUP}
                  ,INPUT "input"
                  ,INPUT X_ext-file.db-num
                  ,INPUT X_ext-file.from-db-num
                  ,INPUT X_ext-file.file-num).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Сохр. */
DO:
  IF NOT AVAILABLE X_ext-file THEN RETURN NO-APPLY.
  run proc-save-disk IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-ipck
&Scoped-define SELF-NAME br-ipck
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-ipck Dialog-Frame
ON VALUE-CHANGED OF br-ipck IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE X_ext-file then do:
    DISABLE
    b-output-params
    b-params
    WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
    ENABLE
    b-output-params
    b-params
    WITH FRAME {&FRAME-NAME}.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_auto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_auto Dialog-Frame
ON CHOOSE OF MENU-ITEM m_auto /* Отослать и зарегистрировать */
DO:
  ASSIGN
  add-option = {&auto}.
  APPLY "CHOOSE" TO b-add in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_manual
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_manual Dialog-Frame
ON CHOOSE OF MENU-ITEM m_manual /* Зарегистрировать */
DO:
    ASSIGN
  add-option = {&manual}.
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
{ gbl/getcntxt.i GET }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-del }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/setfltnm.i }
{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &label-clmn_1  = "{&label-clmn_3}"
  &sort-clmn_1   = "{&sort-clmn_3}"
  &sort-clmn_2    = "X_ext-file.file-name"
  &sort-clmn_3    = "X_ext-file.file-num"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input no) ."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input no)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "no"
  &mv-brw-default = "no"
}

{ gbl/brwrepos.i
  &line-num=5
}


{ gbl/brwrefre.i " assign v-doc-rec = ?. if available X_ext-file then v-doc-rec = recid(X_ext-file). ~
             run OpenBr in this-procedure (input yes, input no, input no) no-error. reposition br-ipck to recid v-doc-rec no-error. ~
             APPLY 'Entry' TO br-ipck.  " }



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if p-all-or-upg = 1 then do:
     message
     "Функционал находится в разработке"
     view-as alert-box warning .
     return.
  end.
  ASSIGN
  v-rid-list = p-rid-list.
  CASE p-all-or-upg:
    when 0 then do:
      if p-file-name <> '':U
      or p-status_ <> '':U then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверно заданы параметры p-file-name и/или p-status_"
        view-as alert-box error .
        undo, return error .
      end.
    end.
    when 1 then do:
    end.
  END CASE.
  run Myenable in this-procedure .
  IF  v-rid-list = '':U THEN
  HIDE mark-num in frame {&frame-name} .
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
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark B-add B-del b-check b-params b-install b-output-params
         b-save b-lkp b-sch B-Help br-ipck mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
b-add:menu-mouse IN FRAME {&FRAME-NAME} = 1
X_ext-file.update-user-name:READ-ONLY IN BROWSE br-ipck = YES
X_ext-file.file-name:RESIZABLE IN BROWSE br-ipck = YES
.
CASE p-all-or-upg:
  WHEN 0 THEN DO: /*все файлы*/
    ASSIGN
    MENU-ITEM m_auto:LABEL IN menu menu-b-add = "Пересылка"
    MENU-ITEM m_manual:LABEL IN menu menu-b-add = "В текущую БД"
    .
    ENABLE
    b-quit
    b-mark
    b-add
    B-del
    b-sch
    B-Help
    b-save
    b-lkp
    br-ipck
    b-params
    b-output-params
    WITH FRAME {&frame-name} .
    HIDE
    b-check
    b-install
    IN FRAME {&FRAME-NAME}.
    ASSIGN
    X_ext-file.file-name:LABEL IN BROWSE br-ipck = "Файл"
    X_ext-file.FILE-NAME:resizable IN BROWSE br-ipck = YES
    X_ext-file.create-sys-time:LABEL IN BROWSE br-ipck = "Дата созд.файла"
    X_ext-file.create-sys-date:LABEL IN BROWSE br-ipck = "Время созд.файла"
    X_ext-file.update-sys-date:LABEL IN BROWSE br-ipck = "Дата устан.!/регистр"
    X_ext-file.update-sys-time:LABEL IN BROWSE br-ipck = "Время устан.!/регистр."
    X_ext-file.update-user-name:LABEL IN BROWSE br-ipck = "Польз"
    .
  END.
  WHEN 1 THEN DO: /*пакеты обновлений*/
    ENABLE
    b-quit
    b-mark
    B-add
    B-del
    b-check
    b-install
    b-sch
    B-Help
    br-ipck
    WITH FRAME {&frame-name} .
    HIDE
    b-save
    b-params
    b-output-params
    IN FRAME {&FRAME-NAME}.
  END.
END CASE.
VIEW FRAME {&frame-name} .

run OpenBr IN THIS-PROCEDURE ( input yes, input no, input no).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
DEFINE VARIABLE l-query-was-opened as logical no-undo .
define variable title00 as character no-undo.
define variable title01 as character no-undo.
assign
title00 = substitute("Файлы и ссылки на файлы, хранящиеся в БД &1", v-cntxt-db-num).
title01 = substitute("Зарегистрированные пакеты обновлений в БД &1", v-cntxt-db-num).
.
run waitfram-show in this-procedure ( INPUT "Ждите...").
DEFINE VARIABLE sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&scop flt-open-open-query OPEN QUERY br-ipck FOR EACH X_ext-file

&scop flt-open-dyn_open-query  FOR EACH X_ext-file

&scop flt-open-query-handle query br-ipck:handle

&scop flt-open-open-query-tail


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_ext-file

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_ext-file

&scop flt-open-waitfram true

define variable l-open-query as logical   no-undo .

CASE p-all-or-upg:
  when 0 then do: /*все файлы*/
    assign
    filter-point-name = "Работа с файлами, хранящимися в БД" .
    IF p-from-db-num = ?
    AND p-db-num = ? THEN DO:
      ASSIGN
      frame {&frame-name}:TITLE = SUBSTITUTE("&1", title00).

      { gbl/fltopend.i
      &where-cond = " X_ext-file.file-num < 2147483647 "
      &use-ind    = "  "
      &by         = "  " }
    END.
    IF p-db-num = ?
    AND p-from-db-num <> ? THEN DO:
      ASSIGN
      frame {&frame-name}:TITLE = SUBStITUTE("&1 из БД &2", title00, p-from-db-num).
      { gbl/fltopend.i
      &where-cond = " X_ext-file.from-db-num = p-from-db-num  ~
                      and X_ext-file.file-num < 2147483647 "
      &dyn_where-cond = " substitute('X_ext-file.from-db-num = &1  ~
                      and X_ext-file.file-num < 2147483647', p-from-db-num) "

      &use-ind    = "  "
      &by         = "  " }

   END.
   IF p-db-num <> ?
   AND p-from-db-num = ? THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = SUBStITUTE("&1 для БД &2", title00, p-db-num).
        { gbl/fltopend.i
        &where-cond = " X_ext-file.db-num = p-db-num  ~
                        and X_ext-file.file-num < 2147483647 "
        &dyn_where-cond = " substitute('X_ext-file.db-num = &1  ~
                        and X_ext-file.file-num < 2147483647', p-db-num )"

        &use-ind    = "  "
        &by         = "  " }

   END.
    IF p-db-num <> ?
    AND p-from-db-num <> ? THEN DO:
         ASSIGN
         frame {&frame-name}:TITLE = SUBStITUTE("&1 для БД &2 из БД &3", title00, p-db-num, p-from-db-num).
         { gbl/fltopend.i
         &where-cond = " X_ext-file.db-num = p-db-num and X_ext-file.from-db-num = p-from-db-num  ~
                         and X_ext-file.file-num < 2147483647 "
         &dyn_where-cond = " substitute('X_ext-file.db-num = &1 and X_ext-file.from-db-num = &2  ~
                         and X_ext-file.file-num < 2147483647', p-db-num, p-from-db-num ) "

         &use-ind    = "  "
         &by         = "  " }

    END.

 end. /*when 0*/
 when 1 then do: /*пакеты обновлений*/
   assign
   filter-point-name = "Работа с пакетами обновлений" .
   IF p-db-num = ?  THEN DO:
      IF p-FILE-NAME = '':U THEN DO:
          IF p-status_ = '':U THEN DO:
              ASSIGN
              frame {&frame-name}:TITLE = SUBSTITUTE("&1", title01).

            { gbl/fltopend.i
            &where-cond = " X_ext-file.file-num < 2147483647 ~
                            and X_ext-file.obj-type = '':U AND X_ext-file.obj-code = 0 ~
                            AND X_ext-file.FILE-TYPE = X_EXT-FILE.FILE-NAME "
            &use-ind    = "  "
            &by         = "  " }

          END.
          ELSE DO:
              ASSIGN
              frame {&frame-name}:TITLE = SUBStITUTE("&1 со статусом &2", title01, p-status_).

            { gbl/fltopend.i
            &where-cond = " X_ext-file.file-num < 2147483647 ~
                            and X_ext-file.obj-type = '':U AND X_ext-file.obj-code = 0 AND X_ext-file.FILE-TYPE = X_EXT-FILE.FILE-NAME ~
                            and X_ext-file.status_ = p-status_ "
            &where-cond = " substitute('X_ext-file.file-num < 2147483647 ~
                            and X_ext-file.obj-type = '':U AND X_ext-file.obj-code = 0 AND X_ext-file.FILE-TYPE = X_EXT-FILE.FILE-NAME ~
                            and X_ext-file.status_ = &1&2&1', ~{&double-quote~}, p-status_ ) "

            &use-ind    = "  "
            &by         = "  " }

          END.
      END.
      ELSE DO:
          ASSIGN
          frame {&frame-name}:TITLE = SUBStITUTE("&1, пакет &2", title01, p-file-name).

        { gbl/fltopend.i
        &where-cond = " X_ext-file.file-num < 2147483647 and X_ext-file.file-name = p-file-name "
        &dyn_where-cond = " substitute('X_ext-file.file-num < 2147483647 and X_ext-file.file-name = &1&2&1', ~{&double-quote~}, p-file-name )"
        &use-ind    = "  "
        &by         = "  " }

      END.
  END. /*if p-db-num = ?*/
  ELSE DO:
    IF p-file-name = '':U THEN DO:
      IF p-status_ = '':U THEN DO:
          ASSIGN
          frame {&frame-name}:TITLE = SUBStITUTE("&1 БД &2", title01, p-db-num).
          { gbl/fltopend.i
          &where-cond = " (X_ext-file.file-num < 2147483647  ~
                          and X_ext-file.obj-type = '':U AND X_ext-file.obj-code = 0 AND X_ext-file.FILE-TYPE = X_EXT-FILE.FILE-NAME ~
                          and X_ext-file.db-num = p-db-num) "
          &where-cond = " substitute('(X_ext-file.file-num < 2147483647  ~
                          and X_ext-file.obj-type = &2&2 AND X_ext-file.obj-code = 0 AND X_ext-file.FILE-TYPE = X_EXT-FILE.FILE-NAME ~
                          and X_ext-file.db-num = &1)',  p-db-num, ~{&double-quote~}) "


          &use-ind    = "  "
          &by         = "  " }

      END.
      ELSE DO:
          ASSIGN
          frame {&frame-name}:TITLE = SUBStITUTE("&1 БД &2 со статусом &3", title01, p-db-num, p-status_).
          { gbl/fltopend.i
          &where-cond = " (X_ext-file.file-num < 2147483647 ~
                          and X_ext-file.obj-type = '':U AND X_ext-file.obj-code = 0 AND X_ext-file.FILE-TYPE = X_EXT-FILE.FILE-NAME ~
                          and X_ext-file.db-num = p-db-num and X_ext-file.status_ = p-status_) "
          &dyn_where-cond = " substitute('(X_ext-file.file-num < 2147483647 ~
                          and X_ext-file.obj-type = &2&2 AND X_ext-file.obj-code = 0 AND X_ext-file.FILE-TYPE = X_EXT-FILE.FILE-NAME ~
                          and X_ext-file.db-num = &1 and X_ext-file.status_ = &2&3&2)', p-db-num , ~{&double-quote~}, p-status_) "

          &use-ind    = "  "
          &by         = "  " }

      END.
    END.
    ELSE DO:
        ASSIGN
        frame {&frame-name}:TITLE = SUBStITUTE("&1 БД &2 Пакет &3", title01, p-db-num, p-file-name).
        { gbl/fltopend.i
        &where-cond = " (X_ext-file.file-num < 2147483647 ~
                        and X_ext-file.obj-type = '':U AND X_ext-file.obj-code = 0 AND X_ext-file.FILE-TYPE = X_EXT-FILE.FILE-NAME ~
                        and X_ext-file.db-num = p-db-num and X_ext-file.file-name = p-file-name) "
        &dyn_where-cond = " substitute('(X_ext-file.file-num < 2147483647 ~
                        and X_ext-file.obj-type = &2&2 AND X_ext-file.obj-code = 0 AND X_ext-file.FILE-TYPE = X_EXT-FILE.FILE-NAME ~
                        and X_ext-file.db-num = &1 and X_ext-file.file-name = &2&3&2)', p-db-num,  ~{&double-quote~}, p-file-name) "

        &use-ind    = "  "
        &by         = "  " }

      END.
    END. /*not if p-db-num = ?*/
  end.
END CASE.


if not p-open-query then
REPOSITION br-ipck to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-ipck:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-ipck in frame {&frame-name}.
APPLY "ENTRY" TO br-ipck.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
DEFINE INPUT PARAMETER p-add-option AS CHARACTER NO-UNDO.
define variable v_manifest-file as character no-undo .
define variable ll_commit as logical no-undo .
define variable v-db-num as integer no-undo .
define variable v-rid as recid no-undo .
DEFINE buffer buf_db FOR ub.db.
CASE p-add-option:
  WHEN {&auto} THEN DO:
    IF p-all-or-upg = 0 THEN DO:
      run nws/sndfnws.w ( INPUT parparentproc
                     ,INPUT ""
                     ,input ?
                     ,input ?
                     ,input {&auto} ) no-error.
    END.
    IF p-all-or-upg = 1 THEN DO:
      run nws/sndfnws.w ( INPUT parparentproc
                     ,INPUT {&save-install}
                     ,input ?
                     ,input ?
                     ,input '':U ) no-error.
    END.
  END.
  WHEN {&manual} THEN DO:
    IF p-all-or-upg = 0 THEN DO:
      run nws/sndfnws.w ( INPUT parparentproc
                     ,INPUT {&save-this-db}
                     ,input v-cntxt-db-num
                     ,input v-cntxt-db-num
                     ,input '':U ) no-error.
    END.
    IF p-all-or-upg = 1 THEN DO:
      IF p-db-num = ?
      OR p-db-num < 0 THEN DO:
        IF v-cntxt-db-num = 0 THEN DO:
          run adm/dbs.w ( INPUT parparentproc
                  ,INPUT {&LOOKUP}
                  ,OUTPUT v-rid) NO-ERROR.
          IF ERROR-STATUS:ERROR THEN RETURN ERROR.
          FIND FIRST buf_db NO-LOCK WHERE
                  recid(buf_db) = v-rid .
        END.
        ELSE DO:
            FIND FIRST buf_db NO-LOCK WHERE
                    buf_db.db-num = v-cntxt-db-num.

        END.
      END.
      run nws/sndfnws.w ( INPUT parparentproc
                     ,INPUT {&save-install}
                     ,input buf_db.db-num
                     ,input v-cntxt-db-num
                     ,input {&manual} ) no-error.
    END.
   END.
END CASE.

run OpenBr in this-procedure ( input yes, input no, input no) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
DEFINE INPUT PARAMETER p-del-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE glog AS logical NO-UNDO.
define variable v-loc-rid-list as character no-undo .
define variable v-entry as character no-undo .
DEFINE BUFFER buf_exT-FILE FOR UB.EXT-FILE.
CASE p-all-or-upg :
  WHEN 0 THEN DO:
    if v-rid-list = '':U then do:
      MESSAGE
      "Вы действительно хотите удалить запись о выделенном файле?" skip
      "(с диска файла не удаляется)" skip
      VIEW-AS ALERT-BOX QUESTION buttons YES-NO UPDATE glog.
      IF NOT glog THEN RETURN.
      v-loc-rid-list = string(recid(X_ext-file)).
    end.
    else  do:
      MESSAGE
      "Вы действительно хотите удалить записи о выделенных файлах?" skip
      "(с диска файлы не удаляются)" skip
      VIEW-AS ALERT-BOX QUESTION buttons YES-NO UPDATE glog.
      IF NOT glog THEN RETURN.
      v-loc-rid-list = v-rid-list.
    end.
    DO ii = 1 TO NUM-ENTRIES(v-loc-rid-list):
      FIND FIRST BUF_EXT-FILE NO-LOCK WHERE
                RECID(BUF_eXT-FILE) = INTEGER( ENTRY(II, V-loc-RID-LIST)) NO-ERROR.
       IF AVAILABLE BUF_eXT-FILE  THEN DO:
          v-entry = string(recid(buf_ext-file)).
          run adm/extf-del.p ( BUFFER BUF_eXT-FILE
                             , input no /*tree*/
                             , INPUT buf_ext-file.status_) no-error .
          if error-status:error then do:
            message
            substitute("Ошибка при удалении файла БД&1&2№ файла &3&2&4&2&5&2&6"
                        , buf_ext-file.db-num
                        , {&new-line}
                        , buf_Ext-file.file-num
                        , buf_ext-file.file-name
                        , error-status:get-message(1)
                        , return-value )
            view-as alert-box error.
          end.
          else do:
            entry(lookup(v-entry, v-rid-list), v-rid-list) = ''.
            v-rid-list = replace(v-rid-list, {&comma-char} + {&comma-char}, {&comma-char}).
            v-rid-list = trim(v-rid-list, {&comma-char}).
            if num-entries( v-rid-list ) > 0 then do:
              DISPLAY
              num-entries( v-rid-list ) @ mark-num
              with frame {&frame-name}.
            end.
            else do:
              hide
              mark-num
              in frame {&frame-name} .
            end.
          end.
       END.
    END.
  END.
  WHEN 1 THEN DO:
   if v-rid-list = '':U then do:
      MESSAGE
      "Вы действительно хотите разрегистровать выделенный пакет/пакеты"
      VIEW-AS ALERT-BOX QUESTION buttons YES-NO UPDATE glog.
      IF NOT glog THEN RETURN.
      v-loc-rid-list = string(recid(X_ext-file)).
   end.
   else do:
      MESSAGE
      "Вы действительно хотите разрегистровать выделенный пакет/пакеты"
      VIEW-AS ALERT-BOX QUESTION buttons YES-NO UPDATE glog.
      IF NOT glog THEN RETURN.
      v-loc-rid-list = v-rid-list.
   end.
    DO ii = 1 TO NUM-ENTRIES(v-loc-rid-list):
      FIND FIRST BUF_EXT-FILE NO-LOCK WHERE
                RECID(BUF_eXT-FILE) = INTEGER( ENTRY(II, V-loc-RID-LIST)) NO-ERROR.
      IF AVAILABLE BUF_eXT-FILE  THEN DO:
        v-entry = string(recid(buf_ext-file)).
        run adm/extf-del.p ( BUFFER BUF_eXT-FILE
                           , input no /*no*/
                           , INPUT P-DEL-OPTION) no-error .
        if error-status:error then do:
           message
           substitute("Ошибка при удалении файла БД&1 (от БД &2)&3№ файла &4&3&5&3&6&3&7"
                       , buf_ext-file.db-num
                       , buf_ext-file.from-db-num
                       , {&new-line}
                       , buf_Ext-file.file-num
                       , buf_ext-file.file-name
                       , error-status:get-message(1)
                       , return-value )
           view-as alert-box error.
        end.
        else do:
          entry(lookup(v-entry, v-rid-list), v-rid-list) = ''.
          v-rid-list = replace(v-rid-list, {&comma-char} + {&comma-char}, {&comma-char}).
          v-rid-list = trim(v-rid-list, {&comma-char}).
          if num-entries( v-rid-list ) > 0 then do:
            DISPLAY
            num-entries( v-rid-list ) @ mark-num
            with frame {&frame-name}.
          end.
          else do:
            hide
            mark-num
            in frame {&frame-name} .
          end.
        end.
      END.
    END.
  END.
END CASE.

run OpenBr in this-procedure ( input yes, input no, input no) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
assign
  tbl = 'ext-file'
  join-tbl = 'X_ext-file'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('db-num', 'для БД', 'db',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('from-db-num', 'из БД', 'db',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('file-size', 'Размер', 'db',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('file-name', 'Файл манифеста', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('update-sys-date', 'Дата установки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                    , INPUT (filter-point + {&delim-par} +
                            filter-point-name)
                    , INPUT tbl
                    , INPUT join-tbl
                    , INPUT fld
                    , INPUT lab
                    , INPUT spr
                    , INPUT dim ).
  run OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-lkp Dialog-Frame
PROCEDURE proc-lkp :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-override AS INTEGER no-UNDO.
DEFINE VARIABLE v-printed AS logical no-UNDO.
DEFINE VARIABLE v-temp-file-name AS CHARACTER NO-UNDO.

/*сделаем временный файл*/
run gbl/_tmpfile.p (
       input  't':U
      ,input  "." + entry( num-entries(X_ext-file.file-name, "."), X_ext-file.FILE-NAME, ".")
      ,output v-temp-file-name
      ) .
run adm/extfsavd.p (
             INPUT X_ext-file.db-num
            ,INPUT X_ext-file.from-db-num
            ,INPUT X_ext-file.file-num
            ,INPUT v-temp-file-name
            ,INPUT-OUTPUT v-override) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
  MESSAGE
  SUBSTITUTE("Ошибка при сохранении файла &1 на диск во временный файл&2&3&2&4&2"
          , X_ext-file.FILE-NAME
          , {&NEW-LINE}
          ,error-status:get-message(1)
          , RETURN-VALUE)
  VIEW-AS ALERT-BOX ERROR.
  RETURN ERROR.
END.
os-command  value ('start /wait /b ' + v-temp-file-name).
/*run gbl/open_url.p ( input v-temp-file-name) no-error .*/
OS-DELETE VALUE(v-temp-file-name).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save-disk Dialog-Frame
PROCEDURE proc-save-disk :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-override AS INTEGER no-UNDO.
DEFINE VARIABLE v-dir-path AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dir-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-can-write AS logical NO-UNDO.
DEFINE VARIABLE v-num-files AS integer NO-UNDO.
DEFINE VARIABLE v-ok AS integer NO-UNDO.
DEFINE VARIABLE ii AS integer NO-UNDO.
DEFINE VARIABLE v-loc-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_Ext-file FOR ub.ext-file.
MESSAGE
"Вы действительно хотите сохранить на диск выбранный файл/файлы?"
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
IF NOT glog THEN RETURN.

 run gbl/dir-sel.p (
                  output v-dir-path
                , output v-dir-type
                , output v-can-write
                      )
.
if not v-can-write then do:
    message
    substitute("Вы не имеет прав на запись в выбранный каталог &1", v-dir-path)
    view-as alert-box error .
    return error.
end.
IF v-rid-list = '':U THEN DO:
  v-loc-rid-list = STRING(RECID(X_ext-file)).
END.
ELSE DO:
  v-loc-rid-list = v-rid-list.
END.
v-num-files = NUM-ENTRIES(v-loc-rid-list).
_ii:
DO ii = 1 TO v-NUM-files
on stop UNDO _ii, NEXT _ii:
  FIND FIRST buf_ext-file NO-LOCK WHERE
           recid(buf_Ext-file) = INTEGER(ENTRY(ii, v-loc-rid-list)) NO-ERROR.
  IF NOT AVAILABLE buf_ext-file THEN NEXT _ii.
  run adm/extfsavd.p (
                 INPUT buf_ext-file.db-num
                ,INPUT buf_ext-file.from-db-num
                ,INPUT buf_ext-file.file-num
                ,INPUT v-dir-path
                ,INPUT-OUTPUT v-override) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE
    SUBSTITUTE("Ошибка при сохранении файла &1 на диск&2&3&2&4&2"
              , buf_ext-file.FILE-NAME
              , {&NEW-LINE}
              ,error-status:get-message(1)
              , RETURN-VALUE)
    VIEW-AS ALERT-BOX ERROR.
    RETURN ERROR.
  END.
  ELSE DO:
      v-ok = v-ok + 1.
  END.
END.
IF v-ok <> v-NUM-files THEN DO:
   MESSAGE
   SUBSTITUTE("Выбрано файлов &1, удалось сохранить на диск &2"
              , v-num-files
              , v-ok)
   VIEW-AS ALERT-BOX.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME