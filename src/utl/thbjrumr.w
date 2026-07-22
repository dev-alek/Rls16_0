&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt0-rp-by-call NO-UNDO LIKE ub.rp-by-call.
DEFINE TEMP-TABLE tt0-rule-by-call NO-UNDO LIKE ub.rule-by-call.
DEFINE NEW SHARED TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE BUFFER X_rp-by-call FOR ub.rp-by-call.
DEFINE BUFFER X_rule FOR ub.rule.
DEFINE BUFFER X_rule-by-call FOR ub.rule-by-call.
DEFINE BUFFER X_rule-profile FOR ub.rule-profile.
DEFINE BUFFER X_ruleset FOR ub.ruleset.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запуск RUM

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/21/08
Author: Bakhtadze Natalya
Creation date: 05/21/08

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запуск RUM".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ gbl/cur-time.i }
{ rul/calldscr.i }
{ gbl/key-rec.i }
{ rul/rum-fn.i }
{ rul/tempstrn.i }
{ rul/disprclp.i temp }
{ rul/ruleset_.i }

define variable dops0 as character no-undo format "X(8)".
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".
define variable dopsp as character no-undo format "X(10)".
define variable v-conf-type as character no-undo .
define variable v-run as logical no-undo .
define variable v-profile-type as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-prop-code as character no-undo .
define variable v-codex-id as integer no-undo .
define variable v-ruleset-id as integer no-undo .
define variable v-ruleproc as character no-undo .
define variable v-current-file-name as character no-undo .
define variable v-current-file-index as integer no-undo .
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-rp-by-call-uniq-key-rec as character no-undo .
define variable v-needs-ifile as logical no-undo .
define variable v-dop as character no-undo .

define buffer buf_thbj-attr for ub.thbj-attr.
DEFINE BUFFER buf_ruleset FOR ub.ruleset.
define buffer buf_rule-process for ub.rule-process.
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
{ rul/rcps-run.i cb_ }


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_rule-profile X_ruleset X_rule-by-call ~
X_rp-by-call

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame X_rule-profile.name ~
X_rp-by-call.once-more
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame X_rule-profile.name ~
X_rp-by-call.once-more
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame X_rule-profile ~
X_rp-by-call
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame X_rule-profile
&Scoped-define SECOND-ENABLED-TABLE-IN-QUERY-Dialog-Frame X_rp-by-call
&Scoped-define BUFFER-FIELDS-IN-QUERY-Dialog-Frame X_ruleset.name
&Scoped-define ENABLED-BUFFER-FIELDS-IN-QUERY-Dialog-Frame X_ruleset.name ~

&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH X_rule-profile SHARE-LOCK, ~
      EACH X_ruleset WHERE TRUE /* Join to X_rule-profile incomplete */ SHARE-LOCK, ~
      EACH X_rule-by-call WHERE TRUE /* Join to X_rule-profile incomplete */ SHARE-LOCK, ~
      EACH X_rp-by-call WHERE TRUE /* Join to X_rule-profile incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH X_rule-profile SHARE-LOCK, ~
      EACH X_ruleset WHERE TRUE /* Join to X_rule-profile incomplete */ SHARE-LOCK, ~
      EACH X_rule-by-call WHERE TRUE /* Join to X_rule-profile incomplete */ SHARE-LOCK, ~
      EACH X_rp-by-call WHERE TRUE /* Join to X_rule-profile incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame X_rule-profile X_ruleset ~
X_rule-by-call X_rp-by-call
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame X_rule-profile
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame X_ruleset
&Scoped-define THIRD-TABLE-IN-QUERY-Dialog-Frame X_rule-by-call
&Scoped-define FOURTH-TABLE-IN-QUERY-Dialog-Frame X_rp-by-call


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.X_ruleset.name X_rule-profile.name ~
X_rp-by-call.once-more
&Scoped-define ENABLED-TABLES ub.X_ruleset X_rule-profile X_rp-by-call
&Scoped-define FIRST-ENABLED-TABLE ub.X_ruleset
&Scoped-define SECOND-ENABLED-TABLE X_rule-profile
&Scoped-define THIRD-ENABLED-TABLE X_rp-by-call
&Scoped-Define ENABLED-OBJECTS b-exit B-quit rs-rule-process B-help b-rule ~
b-param B-profile file-name B-file Ed-notes
&Scoped-Define DISPLAYED-FIELDS ub.X_ruleset.name X_rule-profile.name ~
X_rp-by-call.once-more
&Scoped-define DISPLAYED-TABLES ub.X_ruleset X_rule-profile X_rp-by-call
&Scoped-define FIRST-DISPLAYED-TABLE ub.X_ruleset
&Scoped-define SECOND-DISPLAYED-TABLE X_rule-profile
&Scoped-define THIRD-DISPLAYED-TABLE X_rp-by-call
&Scoped-Define DISPLAYED-OBJECTS rs-rule-process file-name Ed-notes

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-file
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-param
     LABEL "&Параметры"
     SIZE 10 BY 1.

DEFINE BUTTON B-profile
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-rule
     LABEL "Правила"
     SIZE 10 BY 1.

DEFINE VARIABLE Ed-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 9.21
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE file-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл"
     VIEW-AS FILL-IN
     SIZE 78.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-rule-process AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Экспорт", "1"
     SIZE 71.5 BY 5 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      X_rule-profile,
      X_ruleset,
      X_rule-by-call,
      X_rp-by-call SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     rs-rule-process AT ROW 1 COL 22 NO-LABEL WIDGET-ID 22
     B-help AT ROW 1 COL 95
     ub.X_ruleset.name AT ROW 6 COL 1.5 NO-LABEL WIDGET-ID 28
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 97 BY 2.5
     b-rule AT ROW 9 COL 77 WIDGET-ID 24
     b-param AT ROW 9 COL 87 WIDGET-ID 14
     X_rule-profile.name AT ROW 10 COL 14 COLON-ALIGNED WIDGET-ID 10
          LABEL "Профайл"
          VIEW-AS FILL-IN NATIVE
          SIZE 79 BY 1
          FGCOLOR 0
     B-profile AT ROW 10 COL 95 WIDGET-ID 12
     X_rp-by-call.once-more AT ROW 11 COL 14 COLON-ALIGNED WIDGET-ID 32
          LABEL "№ привязки" FORMAT ">>9"
          VIEW-AS FILL-IN NATIVE
          SIZE 4 BY 1
          FGCOLOR 0
     file-name AT ROW 12.25 COL 10
     B-file AT ROW 12.25 COL 95
     Ed-notes AT ROW 13.25 COL 1.5 NO-LABEL WIDGET-ID 30
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON b-exit CANCEL-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt0-rp-by-call T "?" NO-UNDO ub rp-by-call
      TABLE: tt0-rule-by-call T "?" NO-UNDO ub rule-by-call
      TABLE: tt0-rule-call-param T "NEW SHARED" NO-UNDO ub rule-call-param
      TABLE: X_rp-by-call B "?" ? ub rp-by-call
      TABLE: X_rule B "?" ? ub rule
      TABLE: X_rule-by-call B "?" ? ub rule-by-call
      TABLE: X_rule-profile B "?" ? ub rule-profile
      TABLE: X_ruleset B "?" ? ub ruleset
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

ASSIGN
       B-file:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       Ed-notes:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN file-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       file-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN X_rule-profile.name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN X_rp-by-call.once-more IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.X_rule-profile,Temp-Tables.X_ruleset WHERE Temp-Tables.X_rule-profile ...,Temp-Tables.X_rule-by-call WHERE Temp-Tables.X_rule-profile ...,Temp-Tables.X_rp-by-call WHERE Temp-Tables.X_rule-profile ..."
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  v-run = yes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-file Dialog-Frame
ON CHOOSE OF B-file IN FRAME Dialog-Frame
DO:

define variable v_os-file   AS CHAR NO-UNDO INIT "".
define variable ll_commit AS LOG    NO-UNDO INIT NO.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-txt-name as character no-undo .
define variable v-flt-name as character no-undo .
define variable glog as logical no-undo .
define variable v-needs-ifile as logical no-undo .
define variable v-needs-efile as logical no-undo .
define variable v-xml-file as logical no-undo .
define variable v-excel-file as logical no-undo .
define variable v-text-file as logical no-undo .
define variable v-dflt-extension as character no-undo .
define buffer buf_rule-process for ub.rule-process.
for each buf_rule-process no-lock where
          buf_rule-process.pchain-type = v-profile-type
      and buf_rule-process.pchain-id = rs-rule-process
      and buf_rule-process.start-from = (if v-cntxt-db-num = 0 then 0 else 1):
if buf_rule-process.needs-ifile = 1 then do:
    v-needs-ifile = yes.
  end.
  if buf_rule-process.needs-efile = 1 then do:
    v-needs-efile = yes.
  end.
end.
if v-needs-ifile then do:
  if lookup( "xml", rs-rule-process, '-') > 0  then do:
    v-xml-file = yes.
  end.
  if lookup("excel", rs-rule-process, '-' ) > 0 then do:
    v-excel-file = yes.
  end.
  if lookup("text", rs-rule-process, '-') > 0 then do:
    v-text-file = yes.
  end.
  if rs-rule-process = "batchwork-import" then do:
    v-xml-file = yes.
  end.
  if v-xml-file then do:
  SYSTEM-DIALOG GET-FILE v_os-file
  TITLE "Задайте файл для импорта"
  FILTERS
    " Все XML файлы (*.xml) " "*.xml",
    " Все файлы (*.*) "                      "*.*"
  INITIAL-FILTER 1
  DEFAULT-EXTENSION ".xml"
  USE-FILENAME
  MUST-EXIST
  UPDATE ll_commit
  .
  end.
  if v-excel-file then do:
    SYSTEM-DIALOG GET-FILE v_os-file
    TITLE "Задайте файл для импорта"
    FILTERS
      " Все EXCEL файлы (*.xls,*.xlsx) " "*.xls,*.xlsx",
      " Все файлы (*.*) "                      "*.*"
    INITIAL-FILTER 1
    DEFAULT-EXTENSION ".xml"
    USE-FILENAME
    MUST-EXIST
    UPDATE ll_commit
    .
  end.
  if v-text-file then do:
    case rs-rule-process:
      when {&edoc-proc_text-export_specif} then do:
        assign
        v-txt-name = " Все TEXT файлы (*.txt), Все SPC файлы (*.spc) "
        v-flt-name = "*.txt, *.spc"
        .
      end.
      otherwise do:
        assign
        v-txt-name = " Все TEXT файлы (*.txt) "
        v-flt-name = "*.txt"
        .
      end.
    end case.
    SYSTEM-DIALOG GET-FILE v_os-file
    TITLE "Задайте файл для импорта"
    FILTERS
      v-txt-name  v-flt-name
      ," Все файлы (*.*) "                      "*.*"
    INITIAL-FILTER 1
    DEFAULT-EXTENSION ".xml"
    USE-FILENAME
    MUST-EXIST
    UPDATE ll_commit
    .
  end.
  IF ll_commit <> YES THEN do:
      RETURN NO-APPLY.
  end.
  IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
      BELL.
      MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
  END.
  ASSIGN file-name = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) ).
  run gbl/filename.p (
                  input  v_os-file
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
  if error-status:error  = ? then do:
    return no-apply.
  end.
  assign
  file-name = v-full-path.
  DISPlay
  file-name WITH FRAME {&FRAME-NAME}.
END.
if v-needs-efile then do:
  if lookup( "xml", rs-rule-process, '-') > 0 then do:
    v-xml-file = yes.
  end.
  if lookup("excel", rs-rule-process, '-' ) > 0 then do:
    v-excel-file = yes.
  end.
  if lookup("text", rs-rule-process, '-') > 0 then do:
    v-text-file = yes.
  end.
  if rs-rule-process = "batchwork-export" then do:
    v-xml-file = yes.
  end.
  if v-xml-file then do:
  assign
  v_os-file = "default.xml"
  glog = yes
  .
  system-dialog get-file v_os-file
  filters "Файл экспорта *.xml" "*.xml"
  ask-overwrite
  save-as
  use-filename
  update glog
  default-extension "xml".
  end.
  if v-excel-file then do:
    assign
    v_os-file = "default.xls"
    glog = yes
    .
    system-dialog get-file v_os-file
    filters "Файл экспорта *.xls" "*.xls"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "xml".
  end.
  if v-text-file then do:
    case rs-rule-process:
      when {&edoc-proc_text-export_specif} then do:
        assign
        v-txt-name = " Все TEXT файлы (*.txt), Все SPC файлы (*.spc) "
        v-flt-name = "*.txt, *.spc"
        v_os-file = "default.spc"
        v-dflt-extension = "spc"
        .
      end.
      otherwise do:
        assign
        v-txt-name = " Все TEXT файлы (*.txt) "
        v-flt-name = "*.txt"
        v_os-file = "default.txt"
        v-dflt-extension = "txt"
        .
      end.
    end case.
    assign
    glog = yes
    .
    system-dialog get-file v_os-file
    filters v-txt-name v-flt-name
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension v-dflt-extension.
  end.
  if not glog then do:
    return no-apply.
  end.
  file-name = v_os-file.
  DISPlay
  file-name WITH FRAME {&FRAME-NAME}.
  /*проверпим на запись директорию*/
    run gbl/filename.p (
                     input  file-name
                    ,output v-full-path
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .
    if not (error-status:error
    or v-full-path = ?
    or v-full-path = '':U) then do:
      message
      "Такой файл существует!" skip
      "перезаписывать?"
      view-as alert-box question buttons yes-no update glog.
      if not glog then return no-apply.
    end.
END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-param
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-param Dialog-Frame
ON CHOOSE OF b-param IN FRAME Dialog-Frame /* Параметры */
DO:

  RUN proc-b-param IN THIS-PROCEDURE ( input yes) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-profile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-profile Dialog-Frame
ON CHOOSE OF B-profile IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable glog as logical no-undo .
define buffer buf_rule-by-profile for ub.rule-by-profile.
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_rule-profile for ub.rule-profile.
IF AVAILABLE X_rp-by-call THEN DO:
   ASSIGN
   v-rid-list = STRING(RECID(X_rp-by-call)).
END.
/*выводим список привязок */
run rul/rp-by-call-s.w ( INPUT parparentproc
                        ,INPUT "b-sel,instant":U
                        ,INPUT "call-id,ruleset-id"
                        ,INPUT 0
                        ,INPUT '':U /*p-profile-type*/
                        ,input v-uniq-key-rec
                        ,input v-codex-id
                        ,input v-ruleset-id
                        ,INPUT-OUTPUT v-rid-list
                        ) NO-ERROR.
if v-rid-list = '':U then RETURN NO-APPLY.
FIND FIRST buf_rp-by-call NO-LOCK WHERE
        recid(buf_rp-by-call) = integer(v-rid-list).
find first buf_rule-by-profile no-lock where
          buf_rule-by-profile.profile_id = buf_rp-by-call.profile_id
      and buf_rule-by-profile.codex_id = v-codeX-id
      and buf_rule-by-profile.ruleset_id = v-ruleset-id no-error.
if not available buf_rule-by-profile then do:
   message
   substitute("Для данного профайла не определено никаких правил")
   view-as alert-box error .
   return no-apply.
end.
find first buf_rule-profile no-lock where
          buf_rule-profile.profile_id = buf_rule-by-profile.profile_id.
if buf_rule-profile.action-item-id > '' then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    buf_rule-profile.action-head-code
    buf_rule-profile.action-item-id
    buf_rule-profile.action-item-context
    "(if buf_rule-profile.action-item-context = {&cntxt-global} then 0 else v-cntxt-host-code-obj)"
    "(if buf_rule-profile.action-item-context = {&cntxt-object} then v-cntxt-obj-type else '')"
    "(if buf_rule-profile.action-item-context = {&cntxt-object} then v-cntxt-obj-code else 0)"
    0
    0
    0
    true
    glog
  }
  if not glog then do:
   return no-apply.
  end.
end.
find first X_rp-by-call no-lock where
          recid(X_rp-by-call) = recid(buf_rp-by-call).
FIND FIRST X_rule-profile NO-LOCK WHERE
        X_rule-profile.profile_id = X_rp-by-call.profile_id.
DISPLAY
X_rule-profile.NAME
X_rp-by-call.once-more
WITH FRAME {&FRAME-NAME}.
RUN  refill-rp-by-call IN THIS-PROCEDURE NO-ERROR.
ENABLE
b-param
b-rule
WITH FRAME {&FRAME-NAME}.
run proc-b-type in this-procedure no-error.
if error-status:error then do:
  undo, return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rule Dialog-Frame
ON CHOOSE OF b-rule IN FRAME Dialog-Frame /* Правила */
DO:
   RUN proc-b-rule IN THIS-PROCEDURE NO-ERROR.
   IF ERROR-STATUS:error THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME file-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL file-name Dialog-Frame
ON LEAVE OF file-name IN FRAME Dialog-Frame /* Файл */
DO:

  CASE v-ruleproc:
    WHEN {&cli-grp-proc_xml-file-import}
    or
    WHEN {&clients-proc_xml-file-import}
    or
    WHEN {&gds-grp-proc_xml-file-import}
    or
    WHEN {&edoc-proc_xml-file-import_order}
    or
    WHEN {&edoc-proc_text-import_specif}
    or
    WHEN {&edoc-proc_excel-import_specif}
    or
    when {&thref-proc_xml-file-import}
        or
    when "recipe-xml-file-import":U
    THEN DO:
        ASSIGN file-name.
        IF SEARCH( file-name ) <> ? AND SEARCH( file-name ) <> "":U THEN DO:
            ASSIGN FILE-INFO:FILE-NAME = file-name.
            IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN file-name = FILE-INFO:FULL-PATHNAME.
            DISP file-name WITH FRAME {&FRAME-NAME}.
        END.
        APPLY "TAB":U TO file-name IN FRAME {&FRAME-NAME}.
    END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-rule-process
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-rule-process Dialog-Frame
ON VALUE-CHANGED OF rs-rule-process IN FRAME Dialog-Frame
DO:
  define variable v-needs-ifile as logical no-undo .
  define variable v-needs-efile as logical no-undo .
  define buffer buf_rule-process for ub.rule-process.
  ASSIGN
  rs-rule-process.
  FILE-NAME = ''.
  IF AVAILABLE X_rp-by-call THEN RELEASE X_rp-by-call.
  IF AVAILABLE X_rule-profile THEN RELEASE X_rule-profile.
  X_rule-profile.NAME :SCREEN-VALUE = ''.
  disABLE
  FILE-NAME
  b-file
  WITH FRAME {&FRAME-NAME}.
  hide
  FILE-NAME
  b-file
  IN FRAME {&FRAME-NAME}.
  for each buf_rule-process no-lock where
            buf_rule-process.pchain-type = v-profile-type
        and buf_rule-process.pchain-id = rs-rule-process
        and buf_rule-process.start-from = (if v-cntxt-db-num = 0 then 0 else 1):
    if buf_rule-process.needs-efile = 1 then do:
      v-needs-efile = yes.
    end.
    if buf_rule-process.needs-ifile = 1 then do:
      v-needs-ifile = yes.
    end.
  end.
  find first buf_rule-process no-lock where
            buf_rule-process.pchain-type = v-profile-type
        and buf_rule-process.pchain-id = rs-rule-process
      and buf_rule-process.start-from = (if v-cntxt-db-num = 0 then 0 else 1)
      and buf_rule-process.main-link = 1.
  ASSIGN
  v-ruleset-id = integer(buf_rule-process.ruleset_id)
  v-ruleproc = rs-rule-process
  .
  if v-needs-efile = yes then do:
    ENABLE
    FILE-NAME
    b-file
    WITH FRAME {&FRAME-NAME}.
    DISPLAY
    FILE-NAME
    b-file
    WITH FRAME {&FRAME-NAME}.
  end.
  if v-needs-ifile = yes then do:
    ENABLE
    FILE-NAME
    b-file
    WITH FRAME {&FRAME-NAME}.
    DISPLAY
    FILE-NAME
    b-file
    WITH FRAME {&FRAME-NAME}.
  end.
  FIND first X_ruleset no-lock where
        X_ruleset.codex_id = v-codex-id
    and X_ruleset.ruleset_id = v-ruleset-id.
  DISPLAY
  X_ruleset.NAME
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
{ rul/rcpscont.i ub.rule-by-call }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  v-profile-type = entry(1, p-parameter, {&delim-par}).
  v-dop = (if num-entries(p-parameter, {&delim-par}) > 2
           then entry(3, p-parameter, {&delim-par})
           else '').
  find first buf_rule-process no-error.
  if not available buf_rule-process
  then do:
    message
      "Нарушение целосности машины правил: нет записей в таблице rule-process. Обратитесь к администратору системы"
      view-as alert-box error.
    undo, return error.
  end.
  case v-profile-type:
    when {&table_goods} then do:
      v-prop-code = {&attr-rum_goods}.
      v-codex-id = {&goods-proc_11}.
      FIND FIRST buf_ruleset NO-LOCK WHERE
          buf_ruleset.codex_id = v-codex-id
          AND buf_ruleset.ruleset_id = 0.
      ASSIGN
      frame {&frame-name}:title = buf_ruleset.name.
    end.
    when {&table_clients} then do:
      v-prop-code = {&attr-rum_clients}.
      v-codex-id = {&clients-proc_12}.
      FIND FIRST buf_ruleset NO-LOCK WHERE
          buf_ruleset.codex_id = v-codex-id
          AND buf_ruleset.ruleset_id = 0.
      ASSIGN
      frame {&frame-name}:title = buf_ruleset.name.
    end.
    when {&table_gds-grp} then do:
      v-prop-code = {&attr-rum_gds-grp}.
      v-codex-id = {&gds-grp-proc_13}.
      FIND FIRST buf_ruleset NO-LOCK WHERE
          buf_ruleset.codex_id = v-codex-id
          AND buf_ruleset.ruleset_id = 0.
      ASSIGN
      frame {&frame-name}:title = buf_ruleset.name.
    end.
    when {&table_cli-grp} then do:
      v-prop-code = {&attr-rum_cli-grp}.
      v-codex-id = {&cli-grp-proc_14}.
      FIND FIRST buf_ruleset NO-LOCK WHERE
          buf_ruleset.codex_id = v-codex-id
          AND buf_ruleset.ruleset_id = 0.
      ASSIGN
      frame {&frame-name}:title = buf_ruleset.name.
    end.
    when {&edoc} then do:
      v-prop-code = {&attr-rum_edoc}.
      v-codex-id = {&edoc-proc_18}.
      FIND FIRST buf_ruleset NO-LOCK WHERE
          buf_ruleset.codex_id = v-codex-id
          AND buf_ruleset.ruleset_id = 0.
      ASSIGN
      frame {&frame-name}:title = buf_ruleset.name.
    end.
    when {&thref} then do:
      v-prop-code = {&attr-rum_thref}.
      v-codex-id = {&thref-proc_20}.
      FIND FIRST buf_ruleset NO-LOCK WHERE
          buf_ruleset.codex_id = v-codex-id
          AND buf_ruleset.ruleset_id = 0.
      ASSIGN
      frame {&frame-name}:title = buf_ruleset.name.
    end.
    when {&rep} then do:
      v-prop-code = {&attr-rum_rep}.
      v-codex-id = {&rep-proc_22}.
      FIND FIRST buf_ruleset NO-LOCK WHERE
          buf_ruleset.codex_id = v-codex-id
          AND buf_ruleset.ruleset_id = 0.
      ASSIGN
      frame {&frame-name}:title = buf_ruleset.name.
    end.
    when {&ord} then do:
      v-prop-code = {&attr-rum_ord}.
      v-codex-id = {&ord-proc_23}.
      FIND FIRST buf_ruleset NO-LOCK WHERE
          buf_ruleset.codex_id = v-codex-id
          AND buf_ruleset.ruleset_id = 0.
      ASSIGN
      frame {&frame-name}:title = buf_ruleset.name.
    end.
  end case.
  /*проверим параметры для rs-rule-process*/
  DO v-ii = 1 TO NUM-ENTRIES(ENTRY(2, p-parameter, {&delim-par})) by 2:
      FIND FIRST buf_rule-process NO-LOCK WHERE
                buf_rule-process.pchain-type = entry(1, p-parameter, {&delim-par})
           AND buf_rule-process.pchain-id = entry(v-ii, ENTRY(2, p-parameter, {&delim-par})) NO-ERROR.
      IF NOT AVAILABLE buf_rule-process THEN DO:
          MESSAGE
          "Неверное значение параметра p-parameter" SKIP
          substitute("Не удается найти процесс &1 для типа процесса &2"
                     , entry(v-ii , ENTRY(2, p-parameter, {&delim-par}))
                     , entry(1, p-parameter, {&delim-par}))
         VIEW-AS ALERT-BOX ERROR.
          UNDO, RETURN ERROR.
      END.
  END.
  find first buf_thbj-attr no-lock where
            buf_thbj-attr.upper-prop-code = {&attr-rum}
        and buf_thbj-attr.prop-code = v-prop-code
        and buf_thbj-attr.obj-type = ''
        and buf_thbj-attr.obj-code = 0
        and buf_thbj-attr.property-value-logical = yes
        no-error.
  if not available buf_thbj-attr then do:
    find first buf_ruleset no-lock where
              buf_ruleset.codex_id = v-codex-id
          and buf_ruleset.ruleset_id = 0.
    message
    substitute("В Вашей системе нет настроек &1", buf_ruleset.name)
    view-as alert-box error .
    undo, return ''.
  end.
  run gen-key-rec in this-procedure (
                                    input  {&table_thbj-attr}
                                   ,input (buffer buf_thbj-attr:handle)
                                   ,output v-uniq-key-rec).
  run Myenable in this-procedure .
  if rs-rule-process:num-buttons = 1 then do:
    apply "CHOOSE" to b-profile.
  end.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .
for each buf_rule-process no-lock where
          buf_rule-process.pchain-type = v-profile-type
      and buf_rule-process.pchain-id = rs-rule-process
      and buf_rule-process.start-from = (if v-cntxt-db-num = 0 then 0 else 1) :
  if buf_rule-process.needs-ifile = 1 /*импорт*/ then do:
    v-needs-ifile = yes.
  end.
end.
assign
v-current-file-name = file-name.

if v-run then do:
  _do:
  do while v-current-file-index >= 0 :
    case v-prop-code:
      when {&attr-rum_goods} then do:
        if not available X_rp-by-call then do:
          message
          "Не выбрана привязка к алгоритму"
          view-as alert-box error .
        end.
        if v-ruleproc = {&goods-proc_goods-batchwork}
        then do:
          /*внутри происходит поиск rp-by-call по его call_id копируем все на call_id, соответствующий schedule*/
          run cb_set-rp-by-call in p-parent-handle (
                                                      input X_rp-by-call.call_id
                                                    ,input X_rp-by-call.profile_id
                                                    ,input X_rp-by-call.once-more
                                                    ,input table tt0-rule-call-param
                                                    ).
        end.
        else do:
        run str/goodsrum.p
          (
          input parparentproc
          ,input p-parent-handle
          ,input p-log-handle
          ,input v-ruleproc
          ,input X_rule-profile.profile_id /*p-profile-id*/
          ,input v-codex-id /*p-codex-id*/
          ,input v-ruleset-id /*p-ruleset-id*/
          ,input v-cntxt-db-num
          ,input v-uniq-key-rec
          ,input ( string(next-value(s-v-doc, {&db-name_schema})) + {&delim-par} +
                        v-current-file-name
                  )
          ,input yes /*p-save*/
          ) no-error .
      end.
      end.
      when {&attr-rum_clients} then do:
        run str/clisrum.p
          (
          input parparentproc
          ,input p-parent-handle
          ,input p-log-handle
          ,input v-ruleproc
          ,input X_rule-profile.profile_id /*p-profile-id*/
          ,input v-codex-id /*p-codex-id*/
          ,input v-ruleset-id /*p-ruleset-id*/
          ,input v-cntxt-db-num
          ,input v-uniq-key-rec
          ,input ( string(next-value(s-v-doc, {&db-name_schema})) + {&delim-par} +
                        v-current-file-name
                  )
          ,input yes /*p-save*/
          ) no-error .
      end.
      when {&attr-rum_gds-grp} then do:
        run str/ggrprum.p
          (
          input parparentproc
          ,input p-parent-handle
          ,input p-log-handle
          ,input v-ruleproc
          ,input X_rule-profile.profile_id /*p-profile-id*/
          ,input v-codex-id /*p-codex-id*/
          ,input v-ruleset-id /*p-ruleset-id*/
          ,input v-cntxt-db-num
          ,input v-uniq-key-rec
          ,input ( string(next-value(s-v-doc, {&db-name_schema})) + {&delim-par} +
                        v-current-file-name
                  )
          ,input yes /*p-save*/
          ) no-error .
      end.
      when {&attr-rum_cli-grp} then do:
        run str/cgrprum.p
          (
          input parparentproc
          ,input p-parent-handle
          ,input p-log-handle
          ,input v-ruleproc
          ,input X_rule-profile.profile_id /*p-profile-id*/
          ,input v-codex-id /*p-codex-id*/
          ,input v-ruleset-id /*p-ruleset-id*/
          ,input v-cntxt-db-num
          ,input v-uniq-key-rec
          ,input ( string(next-value(s-v-doc, {&db-name_schema})) + {&delim-par} +
                        v-current-file-name
                  )
          ,input yes /*p-save*/
          ) no-error .
      end.
      when {&attr-rum_edoc} then do:
        run str/edocrum.p
          (
          input parparentproc
          ,input p-parent-handle
          ,input p-log-handle
          ,input v-ruleproc
          ,input X_rule-profile.profile_id /*p-profile-id*/
          ,input v-codex-id /*p-codex-id*/
          ,input v-ruleset-id /*p-ruleset-id*/
          ,input v-cntxt-db-num
          ,input v-uniq-key-rec
          ,input ( v-dop + {&delim-par} +
                        v-current-file-name
                  )
          ,input yes /*p-save*/
          ) no-error .
      end.
      when {&attr-rum_thref} then do:
        run ref/threfrum.p
          (
          input parparentproc
          ,input p-parent-handle
          ,input p-log-handle
          ,input v-ruleproc
          ,input X_rule-profile.profile_id /*p-profile-id*/
          ,input v-codex-id /*p-codex-id*/
          ,input v-ruleset-id /*p-ruleset-id*/
          ,input v-cntxt-db-num
          ,input v-uniq-key-rec
          ,input ( string(next-value(s-v-doc, {&db-name_schema})) + {&delim-par} +
                        v-current-file-name
                  )
          ,input yes /*p-save*/
          ) no-error .
      end.
      when {&attr-rum_rep}
      or
      when {&attr-rum_ord}
      then do:
        if not available X_rp-by-call then do:
          message
          "Не выбрана привязка к алгоритму"
          view-as alert-box error .
        end.
        else do:
          if v-ruleproc = {&rep-proc_rep-batchwork}
          or v-ruleproc = {&ord-proc_ord-batchwork}
          then do:
            /*внутри происходит поиск rp-by-call по его call_id копируем все на call_id, соответствующий schedule*/
            run cb_set-rp-by-call in p-parent-handle (
                                                       input X_rp-by-call.call_id
                                                      ,input X_rp-by-call.profile_id
                                                      ,input X_rp-by-call.once-more
                                                      ,input table tt0-rule-call-param
                                                      ).
          end.
          else do:
            /*
            run rep/reprum.p
              (
              input parparentproc
              ,input p-parent-handle
              ,input p-log-handle
              ,input v-ruleproc
              ,input X_rule-profile.profile_id /*p-profile-id*/
              ,input v-codex-id /*p-codex-id*/
              ,input v-ruleset-id /*p-ruleset-id*/
              ,input -1
              ,input v-cntxt-db-num
              ,input v-uniq-key-rec
              ,input ( string(next-value(s-v-doc, {&db-name_schema})) + {&delim-par} +
                            v-current-file-name
                      )
              ,input yes /*p-save*/
              ) no-error .
              */
              message "Не обработано!"
              view-as alert-box .
          end.
        end.
      end.
    end case.
    if v-needs-ifile then do:
      /*найдем следующий файл*/
      v-current-file-index = v-current-file-index  + 1.
      assign
      v-current-file-name = rum-fn_get-next-file-name ( file-name, v-current-file-index)
      no-error.
      if error-status:error then do:
        if v-current-file-index = 1 then do:
          v-current-file-index = -2.
        end.
        else do:
          v-current-file-index = -1.
        end.
        leave _do.
      end.
      assign
      file-info:file-name = v-current-file-name
      .
      run gbl/filename.p (
                     input  v-current-file-name
                    ,output v-full-path
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .
      if error-status:error then do:
        if v-current-file-index = 0 then do:
          v-current-file-index = -2.
        end.
        else do:
          v-current-file-index = -1.
        end.
        leave _do.
      end.
    end.
    else do:
      leave _do.
    end.
  end.
  if error-status:error
  and v-current-file-index = -2
  then do:
    message
    error-status:get-message(1) view-as alert-box .
    undo, return error return-value .
  end.
end.
else do:
  return "return".
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-lines Dialog-Frame
PROCEDURE add-lines :
DEFINE BUFFER buf_temp-string FOR temp-string.
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
for each buf_temp-string:
  glog = ed-notes:INSERT-STRING ( buf_temp-string.v-string ) in frame {&frame-name} .
  glog = ed-notes:INSERT-STRING ( {&new-line} ) in frame {&frame-name} .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb_thbjrumr_is-running Dialog-Frame
PROCEDURE cb_thbjrumr_is-running :
DEFINE OUTPUT PARAMETER p-is-running AS LOGICAL NO-UNDO.
p-is-running = YES.

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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY rs-rule-process file-name Ed-notes
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_rp-by-call THEN
    DISPLAY X_rp-by-call.once-more
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_rule-profile THEN
    DISPLAY X_rule-profile.name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_ruleset THEN
    DISPLAY X_ruleset.name
      WITH FRAME Dialog-Frame.
  ENABLE b-exit B-quit rs-rule-process B-help X_ruleset.name b-rule b-param
         X_rule-profile.name B-profile X_rp-by-call.once-more file-name B-file
         Ed-notes
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable v-ii as integer no-undo .
define variable v-name as character no-undo .
define buffer buf_rule-process for ub.rule-process.
do v-ii = 1 to num-entries(ENTRY(2, p-parameter, {&delim-par})):
  find first buf_rule-process no-lock where
            buf_rule-process.pchain-type = ENTRY(1, p-parameter, {&delim-par})
        and buf_rule-process.pchain-id = entry(v-ii, ENTRY(2, p-parameter, {&delim-par}))
        and buf_rule-process.start-from = (if v-cntxt-db-num = 0 then 0 else 1) no-error .
if not available buf_rule-process then do:
  message
  substitute("Не найден процесс &1 типа &2 для &3"
             ,entry(v-ii, ENTRY(2, p-parameter, {&delim-par}))
             ,ENTRY(1, p-parameter, {&delim-par})
             ,(if v-cntxt-db-num = 0 then "ГБД" else "УБД")
             )
  view-as alert-box error .
  return error.
end.
case entry(1, p-parameter, {&delim-par}):
  when {&table_clients} then do:
&scop clients-proc-code buf_rule-process.pchain-id
    v-name = {&clients-proc-name}.
  end.
  when {&table_goods} then do:
&scop goods-proc-code buf_rule-process.pchain-id
    v-name = {&goods-proc-name}.
  end.
  when {&table_gds-grp} then do:
&scop gds-grp-proc-code buf_rule-process.pchain-id
    v-name = {&gds-grp-proc-name}.
  end.
  when {&table_cli-grp} then do:
&scop cli-grp-proc-code buf_rule-process.pchain-id
    v-name = {&cli-grp-proc-name}.
  end.
  when {&edoc} then do:
&scop edoc-proc-code buf_rule-process.pchain-id
    v-name = {&edoc-proc-name}.
  end.
  when {&thref} then do:
&scop thref-proc-code buf_rule-process.pchain-id
    v-name = {&thref-proc-name}.
  end.
  when {&rep} then do:
&scop rep-proc-code buf_rule-process.pchain-id
    v-name = {&rep-proc-name}.
  end.
  when {&ord} then do:
&scop ord-proc-code buf_rule-process.pchain-id
    v-name = {&ord-proc-name}.
  end.
end case.
  assign
  rs-rule-process:RADIO-BUTTONS IN FRAME {&FRAME-NAME} = (if v-ii = 1 then '' else ((rs-rule-process:RADIO-BUTTONS IN FRAME {&FRAME-NAME}) + {&comma-char})) +
                                                    v-name + {&comma-char} + buf_rule-process.pchain-id
  .
end.
ASSIGN
rs-rule-process = ENTRY(1, ENTRY(2, p-parameter, {&delim-par}))
.
assign
X_rule-profile.name:read-only in frame {&frame-name} = yes
X_rp-by-call.once-more:read-only in frame {&frame-name} = yes
.

DISPLAY
rs-rule-process
file-name
WITH FRAME {&frame-name} .
ENABLE
rs-rule-process
b-exit
B-quit
B-help
file-name
B-file
b-profile
ed-notes
X_ruleset.NAME
X_rule-profile.name
X_rp-by-call.once-more
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
APPLY "VALUE-CHANGED" TO rs-rule-process.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-param Dialog-Frame
PROCEDURE proc-b-param :
/*вызываем интерфейс */
define input parameter p-from-button as logical no-undo .
if not available X_rule-profile then do:
  message
  "Сначала необходимо выбрать профайл"
  view-as alert-box error .
  return error.
end.
define variable v-list-mode as character no-undo .
define variable v-param-form as character no-undo .
define variable v-is-esys-import as logical no-undo .
define variable v-is-routing as logical no-undo .
define buffer buf_rule-process for ub.rule-process.
for each buf_rule-process no-lock where
          buf_rule-process.pchain-type = v-profile-type
      and buf_rule-process.pchain-id = rs-rule-process
      and buf_rule-process.start-from = (if v-cntxt-db-num = 0 then 0 else 1):
  if buf_rule-process.is-esys-import = 1  then v-is-esys-import = yes.
  if buf_rule-process.is-routing = 1 then v-is-routing = yes.
end.

assign
v-param-form = (if X_rule-profile.custom-param-form > 0
                then  substitute("rul/rcps-&1.w", X_rule-profile.profile_id)
                else "ref/rulercps.w")
v-list-mode = (if X_rule-profile.custom-param-form > 0
               then {&table_rp-rule-param}
               else {&table_rule-call-param})
.
run value(v-param-form) (
                     input parparentproc
                    ,input this-procedure:handle
                    ,input (if not (v-is-esys-import or  v-is-routing )
                            and v-ruleproc <> {&rep-proc_rep-batchwork}
                           and v-ruleproc <> {&ord-proc_ord-batchwork}
                           and v-ruleproc <> {&goods-proc_goods-batchwork}
                           then "b-chg,running":U
                           else 'running')
                    ,input (if not (v-is-esys-import or v-is-routing )
                           then {&update}
                           else {&lookup})
                    ,input v-list-mode
                    ,input X_rule-profile.profile_id /*profile-id*/
                    ,input X_rp-by-call.once-more /*once-more*/
                    ,input X_rp-by-call.call_id /*p-call-id*/
                    ,input 0 /*v-codex-id*/ /*p-codex-id*/
                    ,input 0 /*v-ruleset-id*/ /*p-ruleset-id*/
                    ,input ? /*p-order-id*/
                    ,input 0 /*p-rule-id*/
                    ,INput substitute("Профайл &1 &2"
                                      , X_rule-profile.profile_id, calldscr(X_rp-by-call.call_id))  /**/
                    ,input-output table tt0-rule-call-param  ) no-error.
RUN  refill-rp-by-call IN THIS-PROCEDURE NO-ERROR.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-rule Dialog-Frame
PROCEDURE proc-b-rule :
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
/*вызываем интерфейс */
if not available X_rule-profile then do:
  message
  "Сначала необходимо определить профайл"
  view-as alert-box error .
  return error.
end.
run rul/rule-by-profile-s.w ( INPUT parparentproc
                             ,INPUT '' /* bttns */
                             ,INPUT "profile"
                             ,INPUT X_rule-profile.profile_id
                             ,INPUT v-codex-id
                             ,INPUT v-ruleset-id
                             ,INPUT 0 /*rule-id*/
                             ,INPUT-OUTPUT v-rid-list) NO-ERROR.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-type Dialog-Frame
PROCEDURE proc-b-type :
define variable v-found as logical no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_tt0-rule-call-param for tt0-rule-call-param.
IF NOT AVAILABLE X_rp-by-call THEN DO:
  MESSAGE
  "Сначала необходимо определить профайл"
  VIEW-AS ALERT-BOX.
  disable b-param
  with frame {&frame-name} .
  RETURN ERROR.
END.
/*надо найти все rule-call-param для данного вызова и показать в БРОУЗЕ  с возможностью изменения*/
FOR EACH buf_tt0-rule-call-param:
   DELETE buf_tt0-rule-call-param.
END.
for each buf_Rule-call-param no-lock where
        buf_rule-call-param.call#_id = X_rp-by-call.call#_id
    /*and  buf_rule-call-param.codex_id = v-codex-id
    and  buf_rule-call-param.ruleset_id = v-ruleset-id*/
    and  buf_rule-call-param.profile_id = X_rp-by-call.profile_id
    AND buf_rule-call-param.once-more = X_rp-by-call.once-more:
  create buf_tt0-rule-call-param.
  buffer-copy buf_rule-call-param to buf_tt0-rule-call-param.
  v-found = yes.
end.
if v-found
and v-ruleproc <> {&rep-proc_rep-batchwork}
and v-ruleproc <> {&ord-proc_ord-batchwork}
and v-ruleproc <> {&goods-proc_goods-batchwork}
then do:
  RUN proc-b-param IN THIS-PROCEDURE ( input no) NO-ERROR.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable glog as logical no-undo .
if file-name:visible in frame {&frame-name} then do:
  ASSIGN FRAME {&FRAME-NAME}
  file-name
  .
  if file-name = '':u
  or file-name = ?
  then do:
    message
    "Не задан файл"
    view-as alert-box error .
    undo, return error .
  end.
end.
if not available X_rule-profile then do:
  message
  "Не выбран профайл!"
  view-as alert-box error .
  undo, return error .
end.
if v-cntxt-db-num = 0 then do:
  if (v-profile-type = {&rep}
  and v-ruleproc = {&rep-proc_rep-batchwork})
  or (v-profile-type = {&ord}
  and v-ruleproc = {&ord-proc_ord-batchwork})
  or (v-profile-type = {&table_goods}
  and v-ruleproc = {&goods-proc_goods-batchwork})
  or (v-profile-type = {&edoc}
  and v-ruleproc = {&edoc-proc_batchwork-routing_order})
  or (v-profile-type = {&edoc}
  and v-ruleproc = {&edoc-proc_batchwork-routing_price-doc})
  or (v-profile-type = {&edoc}
  and v-ruleproc = {&edoc-proc_batchwork-routing_trn-doc})
  or (v-profile-type = {&edoc}
  and v-ruleproc = {&edoc-proc_batchwork-routing_inkas})
  or (v-profile-type = {&edoc}
  and v-ruleproc = {&edoc-proc_text-import_specif})
  or (v-profile-type = {&edoc}
  and v-ruleproc = {&edoc-proc_excel-import_specif})
  or (v-profile-type = {&edoc}
  and v-ruleproc = {&edoc-proc_text-export_specif})
  or (v-profile-type = {&edoc}
  and v-ruleproc = {&edoc-proc_excel-export_specif})
  or X_rule-profile.short-name begins "_"
  or v-ruleproc = 'recipe-xml-file-import':U
  then do:
    glog = no.
  end.
  else do:
  message
  "Сохранить изменения значений параметров (если они были) в БД?"
  view-as alert-box question buttons yes-no update glog.
  end.
  if glog then do:
    run rul/ruprcall.p ( input v-profile-type
                        ,input v-uniq-key-rec
                        ,input {&table_rule-call-param} /*p-data-completeness*/
                        ,input ? /*p-cmd-proc-handle*/  /*cmd-bush вызоывем внутри*/
                        ,input 0
                        ,INPUT TABLE tt0-rp-by-call
                        ,INPUT TABLE tt0-rule-by-call
                        ,INPUT TABLE tt0-rule-call-param) no-error .
  if error-status:error then do:
    message
    "Ошибка при сохранении параметров правил" skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box error .
    undo, return error .
  end.
end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refill-rp-by-call Dialog-Frame
PROCEDURE refill-rp-by-call :
RUN temp-string_clear IN THIS-PROCEDURE.
IF AVAILABLE X_rp-by-call  THEN DO:

    run rul/rule-proc-view.p ( input v-profile-type
                              ,input v-ruleproc
                              ,input (IF v-cntxt-db-num = 0 THEN 0 ELSE 1 )
                              ,input X_rp-by-call.CALL_id
                              ,input X_rp-by-call.profile_id /*p-profile-id*/
                              ,input X_rp-by-call.once-more
                              ,input "text-temp" /*mode*/
                              ,input this-procedure:HANDLE /*где добавлять строки - handle*/
                              ) no-error.
    ed-notes:SCREEN-VALUE  IN FRAME {&FRAME-NAME} = '' .
    run add-lines in THIS-PROCEDURE  .
END.
ELSE DO:
  ed-notes:SCREEN-VALUE  IN FRAME {&FRAME-NAME} = '' .
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME