&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_db FOR ub.db.
DEFINE BUFFER X_ext-file FOR ub.ext-file.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Работа с файлами для IBM-XML, сохраненными в БД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/01/09
Author: Bakhtadze Natalya
Creation date: 07/01/09


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input-output parameter p-rid-list AS CHARACTER NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Работа с файлами для IBM-XML, сохраненными в БД".
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
{ gbl/usrfulnf.i }
{ gbl/key-rec.i }

DEFINE VARIABLE del-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable sort-column-name as character no-undo .
define variable filter-point-name as character no-undo .
define variable filter-point as character no-undo init "ipckxibm" .
define variable filter-point0 as character no-undo init "ipckxibm" .


DEFINE variable p-db-num AS INTEGER NO-UNDO.
DEFINE variable p-file-type AS character NO-UNDO.
define variable p-obj-type as character no-undo .
define variable p-obj-code as integer no-undo .
define variable p-pos-type as character no-undo .
define variable p-cash-num as integer no-undo .
DEFINE VARIABLE v-cd-db-num AS INTEGER NO-UNDO.
DEFINE VARIABLE v-cd-obj-code AS INTEGER NO-UNDO.
DEFINE VARIABLE v-cd-cash-num AS INTEGER NO-UNDO.
DEFINE VARIABLE v-ch-db AS WIDGET-HANDLE NO-UNDO.

&SCOPED-DEFINE sort-clmn_3  X_ext-file.db-num
&scoped-define label-clmn_3 'Для БД'
&SCOPED-DEFINE sort-clmn_2 usrfulnf(X_ext-file.update-user-name)
&SCOPED-DEFINE dyn_sort-clmn_2 substitute('dynamic-function(&1usrfulnf&1, X_ext-file.update-user-name)', ~{&double-quote~})
&scoped-define label-clmn_2 'Установил'
&scoped-define label-clmn_1 'БД'


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
&Scoped-define INTERNAL-TABLES X_db X_ext-file

/* Definitions for BROWSE br-ipck                                       */
&Scoped-define FIELDS-IN-QUERY-br-ipck mark-string ( input recid(x_ext-file), input v-rid-list) get-cd(X_ext-file.db-num, X_ext-file.from-db-num, X_ext-file.file-num) v-cd-obj-code v-cd-cash-num X_ext-file.file-name-exec X_ext-file.update-sys-date X_ext-file.update-sys-time {&sort-clmn_2} X_ext-file.file-num {&sort-clmn_3} X_ext-file.from-db-num X_ext-file.file-size X_ext-file.create-sys-time X_ext-file.create-sys-date
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-ipck X_ext-file.create-sys-time
&Scoped-define ENABLED-TABLES-IN-QUERY-br-ipck X_ext-file
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-ipck X_ext-file
&Scoped-define SELF-NAME br-ipck
&Scoped-define QUERY-STRING-br-ipck FOR EACH X_db no-lock, ~
       each X_ext-file NO-LOCK WHERE X_ext-file.file-num < 2147483647      INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-ipck OPEN QUERY {&SELF-NAME} FOR EACH X_db no-lock, ~
       each X_ext-file NO-LOCK WHERE X_ext-file.file-num < 2147483647      INDEXED-REPOSITION .
&Scoped-define TABLES-IN-QUERY-br-ipck X_db X_ext-file
&Scoped-define FIRST-TABLE-IN-QUERY-br-ipck X_db


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-ipck}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark B-add B-del b-params ~
b-output-params b-save b-lkp b-sch B-Help b-db rs-file-type br-ipck ~
mark-num
&Scoped-Define DISPLAYED-OBJECTS rs-file-type mark-num f-db-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cd Dialog-Frame
FUNCTION get-cd RETURNS INTEGER
  ( INPUT p-db-num AS integer
  , INPUT p-from-db-num AS integer
  , INPUT p-file-num AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-db
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "&БД"
     SIZE 4 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр".

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

DEFINE VARIABLE f-db-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "БД"
      VIEW-AS TEXT
     SIZE 6 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 10.5 BY .67
     FGCOLOR 10  NO-UNDO.

DEFINE VARIABLE rs-file-type AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "На кассу", "request",
"С кассы", "reply"
     SIZE 21 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-ipck FOR
      X_db, X_ext-file SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-ipck
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-ipck Dialog-Frame _FREEFORM
  QUERY br-ipck NO-LOCK DISPLAY
      mark-string ( input recid(x_ext-file), input v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
    WIDTH 2
get-cd(X_ext-file.db-num, X_ext-file.from-db-num, X_ext-file.file-num) COLUMN-LABEL {&label-clmn_1} FORMAT ">>>>9"
v-cd-obj-code COLUMN-LABEL "Маг" FORMAT ">>>>9"
v-cd-cash-num COLUMN-LABEL "Касса" FORMAT ">>>>9"
X_ext-file.file-name-exec COLUMN-LABEL "Файл манифеста" FORMAT "X(255)":U WIDTH 40
X_ext-file.update-sys-date COLUMN-LABEL "Дата устан." FORMAT "99/99/9999":U
X_ext-file.update-sys-time COLUMN-LABEL "Время устан." FORMAT "X(8)":U
{&sort-clmn_2} column-label {&label-clmn_2} FORMAT "X(12)":U
X_ext-file.file-num COLUMN-LABEL "№ файла" FORMAT "->>>>>>>>9":U
{&sort-clmn_3} column-label {&label-clmn_3} FORMAT "->>>>9":U
X_ext-file.from-db-num COLUMN-LABEL "Из Бд" FORMAT ">>>>>>>>9":U
X_ext-file.file-size COLUMN-LABEL "Размер" FORMAT ">>>>>>>>9":U
X_ext-file.create-sys-time COLUMN-LABEL "Дата файла" FORMAT "X(5)":U
X_ext-file.create-sys-date COLUMN-LABEL "Время файла" FORMAT "99/99/9999":U
ENABLE
X_ext-file.create-sys-time
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
     b-params AT ROW 1 COL 41
     b-output-params AT ROW 1 COL 51
     b-save AT ROW 1 COL 61
     b-lkp AT ROW 1 COL 71 WIDGET-ID 2
     b-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     b-db AT ROW 2 COL 25 WIDGET-ID 6
     rs-file-type AT ROW 2 COL 32 NO-LABEL WIDGET-ID 8
     br-ipck AT ROW 3 COL 1
     mark-num AT ROW 2 COL 2 NO-LABEL
     f-db-num AT ROW 2 COL 15 COLON-ALIGNED WIDGET-ID 4
     SPACE(76.24) SKIP(16.99)
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
      TABLE: X_db B "?" ? ub db
      TABLE: X_ext-file B "?" ? ub ext-file
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-ipck rs-file-type Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-db-num IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       f-db-num:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-ipck
/* Query rebuild information for BROWSE br-ipck
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_db no-lock, X_ext-file NO-LOCK WHERE X_ext-file.file-num < 2147483647
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
  run proc-b-add in this-procedure  no-error.
  if error-status:error then do:
    return no-apply.
  end.
  APPLY "ENTRY" to br-ipck.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-db Dialog-Frame
ON CHOOSE OF b-db IN FRAME Dialog-Frame /* БД */
DO:
 define variable ri as recid no-undo.
 define buffer buf_db for ub.db.
  run adm/dbs.w (
                input parparentproc
               ,input {&lookup}
               ,output ri) no-error.
  if ri <> ?
  then do:
    find buf_db where recid (buf_db) = ri .
    display
    buf_db.db-num @ f-db-num
    with frame {&frame-name}.
    p-db-num = buf_db.db-num.
  end.
  else do:
    p-db-num = ?.
    display
    ? @ f-db-num
    with frame {&frame-name}.
  end.
  RUN manage-rs-file-type IN THIS-PROCEDURE.
  run OpenBr IN THIS-PROCEDURE ( input yes, input no, input no).
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
    b-output-params when rs-file-type = "request"
    b-params
    WITH FRAME {&FRAME-NAME}.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-file-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-file-type Dialog-Frame
ON VALUE-CHANGED OF rs-file-type IN FRAME Dialog-Frame
DO:

  ASSIGN
  rs-file-type.
  RUN manage-rs-file-type IN THIS-PROCEDURE.

  run OpenBr IN THIS-PROCEDURE ( input yes, input no, input no).

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
  &sort-clmn_2    = "X_ext-file.file-name-exec"
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
  { gbl/getcntxt.i get }
  ASSIGN
  v-rid-list = p-rid-list.
  if v-cntxt-db-num = 0 then do:
    p-db-num = ?.
  end.
  else do:
    p-db-num = v-cntxt-db-num.
  end.
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
  DISPLAY rs-file-type mark-num f-db-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark B-add B-del b-params b-output-params b-save b-lkp b-sch
         B-Help b-db rs-file-type br-ipck mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE manage-rs-file-type Dialog-Frame
PROCEDURE manage-rs-file-type :
CASE rs-file-type:
    WHEN "request" THEN DO:
      p-file-type = {&TABLE_cash-desk} + {&delim-key}.
      assign
      b-params:label in frame {&frame-name} = "Лог"
      b-output-params:label = "Ответ"
      .
      assign
      v-ch-db:VISIBLE = NO
      v-cd-obj-code:VISIBLE IN BROWSE br-ipck = NO
      v-cd-cash-num:VISIBLE IN BROWSE br-ipck = NO
      .

      enable
      b-output-params
      b-add
      with frame {&frame-name} .
    END.
    WHEN "reply" THEN DO:
      assign
      v-ch-db:VISIBLE = YES
      v-cd-obj-code:VISIBLE IN BROWSE br-ipck = YES
      v-cd-cash-num:VISIBLE IN BROWSE br-ipck = YES
      .

      p-file-type = {&TABLE_cash-desk} + {&delim-key} + {&delim-key}.
      assign
      b-params:label = "Запрос"
      b-output-params:label = ""
      .
      disable
      b-output-params
      b-add
      with frame {&frame-name} .
      b-output-params:visible in frame {&frame-name} = no.
    END.
  END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-ch0 AS WIDGET-HANDLE NO-UNDO.


ASSIGN
v-ch0 = br-ipck:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
REPEAT WHILE valid-handle(v-ch0):
   IF v-ch0:LABEL = {&LABEL-clmn_1} THEN DO:
     v-ch-db = v-ch0.
     LEAVE.
   END.
   v-ch0 = v-ch0:NEXT-COLUMN.
END.

ASSIGN
X_ext-file.create-sys-time:READ-ONLY IN BROWSE br-ipck = YES
X_ext-file.file-name-exec:RESIZABLE IN BROWSE br-ipck = YES
.
f-db-num = p-db-num.
display
f-db-num
with frame {&frame-name} .
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
rs-file-type
b-db when v-cntxt-db-num = 0
WITH FRAME {&frame-name} .
ASSIGN
X_ext-file.file-name-exec:LABEL IN BROWSE br-ipck = "Файл"
X_ext-file.FILE-NAME-exec:resizable IN BROWSE br-ipck = YES
.
VIEW FRAME {&frame-name} .
APPLY "VALUE-CHANGED" TO rs-file-type IN FRAME {&FRAME-NAME}.
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
title00 = substitute("Файлы и ссылки на файлы для IBM-XML, принадлежащих БД &1", p-db-num).
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


&scop flt-open-query-handle query br-ipck:handle

&scop flt-open-open-query-tail


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_db

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_ext-file

&scop flt-open-waitfram true

&scop flt-open-debug-file kkk.txt

define variable l-open-query as logical   no-undo .

/*все файлы*/
  IF p-db-num = ? THEN DO:
      assign
     filter-point-name = substitute("Работа с файлами IBM-XML") .
&scop flt-open-open-query OPEN QUERY br-ipck FOR EACH X_db NO-LOCK, EACH  X_ext-file

&scop flt-open-dyn_open-query  FOR EACH X_db NO-LOCK, EACH X_ext-file

      ASSIGN
      frame {&frame-name}:TITLE = SUBSTITUTE("&1", title00).
      CASE p-file-type:
         WHEN {&TABLE_cash-desk} + {&delim-key} THEN DO:
         { gbl/fltopend.i
         &where-cond = " X_ext-file.file-num < 2147483647 and ~
           ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type = p-file-type) ~
             or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type = p-file-type)) "
         &dyn_where-cond = " substitute('X_ext-file.file-num < 2147483647 and ~
           ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type = &1&2&1) ~
            or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type = &1&2&1)) ~
               ',  ~{&double-quote~}, p-file-type) "

         &use-ind    = "  "
         &by         = "  " }

         END.
         OTHERWISE DO:
             { gbl/fltopend.i
       &where-cond = " X_ext-file.file-num < 2147483647 and ~
         ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type >  p-file-type)  ~
          or (X_db.db-num = 0 and X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type >  p-file-type))  "
         &dyn_where-cond = " substitute('X_ext-file.file-num < 2147483647 and ~
           ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type > &1&2&1) ~
           or (X_db.db-num = 0 and  X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and  X_ext-file.file-type > &1&2&1)) ~
           ',  ~{&double-quote~}, p-file-type) "
       &use-ind    = "  "
       &by         = "  " }

         END.
     END CASE.

  END.
  ELSE DO:
&scop flt-open-open-query OPEN QUERY br-ipck FOR EACH X_db NO-LOCK WHERE X_db.db-num = p-db-num, EACH  X_ext-file no-lock

&scop flt-open-dyn_open-query-string   substitute ( ' FOR EACH X_db NO-LOCK WHERE X_db.db-num = &1 , EACH X_ext-file no-lock ', p-db-num )


      assign
     filter-point-name = substitute("Работа с файлами IBM-XML БД &2", p-db-num) .
      ASSIGN
      frame {&frame-name}:TITLE = SUBSTITUTE("&1", title00).

      ASSIGN
 frame {&frame-name}:TITLE = SUBSTITUTE("&1", title00).
 CASE p-file-type:
    WHEN {&TABLE_cash-desk} + {&delim-key} THEN DO:
    { gbl/fltopend.i
    &where-cond = " X_ext-file.file-num < 2147483647 and ~
      ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type = p-file-type) ~
        or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type = p-file-type)) "
    &dyn_where-cond = " substitute('X_ext-file.file-num < 2147483647 and ~
      ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type = &1&2&1) ~
       or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type = &1&2&1)) ~
      ',  ~{&double-quote~}, p-file-type) "

    &use-ind    = "  "
    &by         = "  " }

    END.
    OTHERWISE DO:
        { gbl/fltopend.i
  &where-cond = " X_ext-file.file-num < 2147483647 and ~
    ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type >  p-file-type)  ~
     or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type >  p-file-type))  "
    &dyn_where-cond = " substitute('X_ext-file.file-num < 2147483647 and ~
      ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type > &1&2&1) ~
      or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and  X_ext-file.file-type > &1&2&1)) ~
      ',  ~{&double-quote~}, p-file-type) "
  &use-ind    = "  "
  &by         = "  " }

    END.
  END CASE.
END.
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
define variable v-recid as recid no-undo .
run utl/sendxprw.w ( input parparentproc) no-error.
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
                          , input no
                          , INPUT buf_ext-file.status_) no-error .
      if error-status:error then do:
        message
        substitute("Ошибка при удалении файла БД&1&2№ файла &3&2&4&2&5&2&6"
                    , buf_ext-file.db-num
                    , {&new-line}
                    , buf_Ext-file.file-num
                    , buf_ext-file.file-name-exec
                    , error-status:get-message(1)
                    , return-value )
        view-as alert-box error.
      end.
      else do:      
        if lookup(v-entry, v-rid-list) <> 0 then do:
          entry(lookup(v-entry, v-rid-list), v-rid-list) = ''.
          v-rid-list = replace(v-rid-list, {&comma-char} + {&comma-char}, {&comma-char}).
          v-rid-list = trim(v-rid-list, {&comma-char}).
        end.
      end.
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
    END.
END.
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
run fltfield-add in this-procedure('file-name-exec', 'Файл манифеста', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('update-sys-date', 'Дата установки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('update-user-name', 'Установил', 'usr',
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
      ,input  "." + entry( num-entries(X_ext-file.file-name-exec, "."), X_ext-file.FILE-NAME-exec, ".")
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
          , X_ext-file.FILE-NAME-exec
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
              , buf_ext-file.FILE-NAME-exec
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

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cd Dialog-Frame
FUNCTION get-cd RETURNS INTEGER
  ( INPUT p-db-num AS integer
  , INPUT p-from-db-num AS integer
  , INPUT p-file-num AS INTEGER ) :
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo.
DEFINE BUFFER buf_ext-file-par FOR ub.ext-file-par.
FIND FIRST buf_ext-file-par NO-LOCK WHERE
        buf_ext-file-par.db-num = p-db-num
    AND buf_ext-file-par.from-db-num = p-from-db-num
    AND buf_ext-file-par.file-num = p-file-num
    AND buf_ext-file-par.param-num = 1 NO-ERROR.
IF AVAILABLE buf_ext-file-par
AND buf_ext-file-par.param-type = {&datatype-uniq-key-rec} THEN DO:
    run gen-key-fv in this-procedure ( input buf_ext-file-par.param-name
                                      ,output v-field-list
                                      ,output v-value-list) .


    ASSIGN
    v-cd-db-num = INTEGER(entry(lookup("db-num", v-field-list, {&delim-key}), v-value-list, {&delim-key}))
    v-cd-obj-code = INTEGER(entry(lookup("obj-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}))
    v-cd-cash-num = INTEGER(entry(lookup("cash-num", v-field-list, {&delim-key}), v-value-list, {&delim-key}))
    .
    RETURN v-cd-db-num.
END.
ELSE DO:
    ASSIGN
    v-cd-db-num = ?
    v-cd-obj-code = 0
    v-cd-cash-num = 0
    .
   RETURN v-cd-db-num.   /* Function return value. */
END.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
