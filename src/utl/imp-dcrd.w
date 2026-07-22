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
DEFINE BUFFER X_dis-card-type FOR ub.dis-card-type.
DEFINE BUFFER X_rp-by-call FOR ub.rp-by-call.
DEFINE BUFFER X_rule FOR ub.rule.
DEFINE BUFFER X_rule-by-call FOR ub.rule-by-call.
DEFINE BUFFER X_rule-by-profile FOR ub.rule-by-profile.
DEFINE BUFFER X_rule-profile FOR ub.rule-profile.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Утилиты закачки дисконтных карт и клиентов - интерфейсная часть

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/21/05
Author: Bakhtadze Natalya
Creation date: 11/21/05


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
define variable vss-description as character no-undo init "Утилиты закачки дисконтных карт и клиентов-интерфейс".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ str/defc-cli.i "NEW SHARED"}
{ cmp/dc-list.i dc-list def "new shared" }
{ cmp/dcp-list.i dcp-list def "new shared" }
{ gbl/cur-time.i }
{ gbl/key-rec.i }
{ rul/calldscr.i }
define variable dops0 as character no-undo format "X(8)".
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".
define variable dopsp as character no-undo format "X(10)".
define variable v-is-dc as character no-undo .
define variable v-conf-type as character no-undo .
define variable v-run as logical no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_rule-profile X_dis-card-type

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame X_rule-profile.name ~
X_dis-card-type.type X_dis-card-type.emitent-host-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame X_rule-profile.name ~
X_dis-card-type.type X_dis-card-type.emitent-host-code
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame X_rule-profile ~
X_dis-card-type
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame X_rule-profile
&Scoped-define SECOND-ENABLED-TABLE-IN-QUERY-Dialog-Frame X_dis-card-type
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH X_rule-profile SHARE-LOCK, ~
      EACH X_dis-card-type WHERE TRUE /* Join to X_rule-profile incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH X_rule-profile SHARE-LOCK, ~
      EACH X_dis-card-type WHERE TRUE /* Join to X_rule-profile incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame X_rule-profile X_dis-card-type
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame X_rule-profile
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame X_dis-card-type


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS X_rule-profile.name X_rule.name ~
X_dis-card-type.type X_dis-card-type.emitent-host-code
&Scoped-define ENABLED-TABLES X_rule-profile X_rule X_dis-card-type
&Scoped-define FIRST-ENABLED-TABLE X_rule-profile
&Scoped-define SECOND-ENABLED-TABLE X_rule
&Scoped-define THIRD-ENABLED-TABLE X_dis-card-type
&Scoped-Define ENABLED-OBJECTS b-exit B-quit B-help B-profile B-type ~
b-param file-name B-file T-tocd emitent-name
&Scoped-Define DISPLAYED-FIELDS X_rule-profile.name X_rule.name ~
X_dis-card-type.type X_dis-card-type.emitent-host-code
&Scoped-define DISPLAYED-TABLES X_rule-profile X_rule X_dis-card-type
&Scoped-define FIRST-DISPLAYED-TABLE X_rule-profile
&Scoped-define SECOND-DISPLAYED-TABLE X_rule
&Scoped-define THIRD-DISPLAYED-TABLE X_dis-card-type
&Scoped-Define DISPLAYED-OBJECTS file-name T-tocd emitent-name

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

DEFINE BUTTON B-type
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE VARIABLE emitent-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 42 BY .67 NO-UNDO.

DEFINE VARIABLE file-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл импорта"
     VIEW-AS FILL-IN
     SIZE 78.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-tocd AS LOGICAL INITIAL no
     LABEL "Отправить на кассу по окончании импорта"
     VIEW-AS TOGGLE-BOX
     SIZE 46.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      X_rule-profile,
      X_dis-card-type SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-help AT ROW 1 COL 95
     X_rule-profile.name AT ROW 2 COL 14 COLON-ALIGNED WIDGET-ID 10
          LABEL "Профайл"
          VIEW-AS FILL-IN
          SIZE 79 BY 1
     B-profile AT ROW 2 COL 95 WIDGET-ID 12
     X_rule.name AT ROW 3 COL 16 NO-LABEL WIDGET-ID 18
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 79.5 BY 2
     B-type AT ROW 5 COL 24
     b-param AT ROW 5 COL 88 WIDGET-ID 14
     file-name AT ROW 6 COL 2
     B-file AT ROW 6 COL 95
     T-tocd AT ROW 7 COL 5
     X_dis-card-type.type AT ROW 5 COL 7 COLON-ALIGNED
          LABEL "Тип ДК"
           VIEW-AS TEXT
          SIZE 14.8 BY .67
     X_dis-card-type.emitent-host-code AT ROW 5 COL 34 COLON-ALIGNED
          LABEL "Эмитент"
           VIEW-AS TEXT
          SIZE 6 BY .67
     emitent-name AT ROW 5 COL 41 COLON-ALIGNED NO-LABEL
     "Правило:" VIEW-AS TEXT
          SIZE 8.5 BY 1 AT ROW 3 COL 7 WIDGET-ID 20
     SPACE(84.29) SKIP(19.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Импорт данных по ДК"
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
      TABLE: X_dis-card-type B "?" ? ub dis-card-type
      TABLE: X_rp-by-call B "?" ? ub rp-by-call
      TABLE: X_rule B "?" ? ub rule
      TABLE: X_rule-by-call B "?" ? ub rule-by-call
      TABLE: X_rule-by-profile B "?" ? ub rule-by-profile
      TABLE: X_rule-profile B "?" ? ub rule-profile
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

/* SETTINGS FOR FILL-IN X_dis-card-type.emitent-host-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN file-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       X_rule.name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN X_rule-profile.name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN X_dis-card-type.type IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.X_rule-profile,Temp-Tables.X_dis-card-type WHERE Temp-Tables.X_rule-profile ..."
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Импорт данных по ДК */
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

    SYSTEM-DIALOG GET-FILE v_os-file
        TITLE "Выберите файл для импорта"
        FILTERS
          " Все текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
        INITIAL-FILTER 1
        DEFAULT-EXTENSION ".txt"
        USE-FILENAME
        MUST-EXIST
        UPDATE ll_commit
        .

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
    DISP file-name WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-param
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-param Dialog-Frame
ON CHOOSE OF b-param IN FRAME Dialog-Frame /* Параметры */
DO:

    RUN proc-b-param IN THIS-PROCEDURE NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-profile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-profile Dialog-Frame
ON CHOOSE OF B-profile IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
IF AVAILABLE X_rule-by-profile THEN DO:
   ASSIGN
   v-rid-list = STRING(RECID(X_rule-by-profile)).
END.
/*выберем правила импорта, привязанные к профайлу*/
 run rul/rule-by-profile-s.w ( INPUT parparentproc
                              ,INPUT "b-sel":u /*bttns*/
                              ,INPUT "ruleset"
                              ,INPUT 0 /*p-profile-id*/
                              ,INPUT 4 /*codex_id*/
                              ,INPUT 1 /*ruleset_id*/
                              ,INPUT 0 /*rule_id*/
                              ,INPUT-OUTPUT v-rid-list) NO-ERROR.
if v-rid-list = '':U then RETURN NO-APPLY.
find first X_rule-by-profile no-lock where
          recid(X_rule-by-profile) = integer(v-rid-list).
FIND FIRST X_rule-profile NO-LOCK WHERE
        X_rule-profile.profile_id = X_rule-by-profile.profile_id.
FIND FIRST X_rule NO-LOCK WHERE
        X_rule.rule_id = X_rule-by-profile.rule_id.

DISPLAY
X_rule-profile.NAME
X_rule.NAME
WITH FRAME {&FRAME-NAME}.
ENABLE
b-type
b-param
WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-type Dialog-Frame
ON CHOOSE OF B-type IN FRAME Dialog-Frame
DO:
 run proc-b-type in this-procedure no-error.
 if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME file-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL file-name Dialog-Frame
ON LEAVE OF file-name IN FRAME Dialog-Frame /* Файл импорта */
DO:
    ASSIGN file-name.
    IF SEARCH( file-name ) <> ? AND SEARCH( file-name ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = file-name.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN file-name = FILE-INFO:FULL-PATHNAME.
        DISP file-name WITH FRAME {&FRAME-NAME}.
    END.
    APPLY "TAB":U TO file-name IN FRAME {&FRAME-NAME}.
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
  if NOT v-cntxt-db-num = 0 then do:
      message "Импорт клиентов и их дисконтных карт возможен только в ГБД"
      view-as alert-box ERROR.
    undo main-block, return error .
  end.
  { gbl/conf-rd.i
  "'is-dc'"
  0
  "''":U
  0
  "''":U
  "''":U
  "''":U
  NO
  v-is-dc
  v-conf-type
  NO-ERROR
  }
  IF ERROR-STATUS:ERROR OR
    v-conf-type <> {&type-log} THEN
    v-is-dc = "no".
  if logical(v-is-dc) = no then do:
    message
    "В Вашей системе недоступна функциональность работы с дисконтными картами"
    view-as alert-box WARNING.
    undo main-block, return error .
  end.
  run Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .
if v-run then do:
  run str/saledc.p
    (
      input parparentproc
    ,input this-procedure :handle
    ,input p-log-handle
    ,input {&dct-proc_text-import}
    ,input X_dis-card-type.emitent-host-code
    ,input X_dis-card-type.type
    ,input X_rule-by-profile.profile_id
    ,input 0 /*p-codex-id*/
    ,input 0 /*p-ruleset-id*/
    ,input v-cntxt-db-num
    ,input ( string(next-value(s-v-doc, {&db-name_schema})) + {&delim-par} +
                  file-name
            )
    ,input ? /*doc-date - выставим внутри*/
    ,input ? /*fact-date - выставим внутри*/
    ,input ? /*cre-pay*/
    ,input 1 /*p-sign*/
    ,input 1 /* p-direction */
    ,input yes /*p-save*/
    ) no-error .
  if error-status:error then do:
    undo, return error return-value .
  end.
  if can-find(first dc-list NO-LOCK)
  and t-tocd /*это важно */
  then do:
    run str/diallog.w (
                        input parparentproc
                        ,input this-procedure
                        ,input 'sendclia.p':U
                        ,input (string(v-cntxt-db-num) + {&delim-par} +  {&delim-par} + "no":U + {&delim-par} + "O":U)
                        ,input yes /*p-auto-go*/
                        ,input '':U
                        ,input 'Отправка информации по клиентским картам на кассу') no-error .
  end.
end.

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
  DISPLAY file-name T-tocd emitent-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_dis-card-type THEN
    DISPLAY X_dis-card-type.type X_dis-card-type.emitent-host-code
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_rule THEN
    DISPLAY X_rule.name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_rule-profile THEN
    DISPLAY X_rule-profile.name
      WITH FRAME Dialog-Frame.
  ENABLE b-exit B-quit B-help X_rule-profile.name B-profile X_rule.name B-type
         b-param file-name B-file T-tocd X_dis-card-type.type
         X_dis-card-type.emitent-host-code emitent-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DISPLAY
file-name
T-tocd
emitent-name
WITH FRAME {&frame-name} .
ENABLE
b-exit
B-quit
B-help
file-name
B-file
T-tocd
b-profile
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-param Dialog-Frame
PROCEDURE proc-b-param :
/*вызываем интерфейс */
if not available X_rule-by-profile then do:
  message
  "Сначала необходимо определить тип ДК, для которой вызывается импорт"
  view-as alert-box error .
  return error.
end.
define variable v-param-form as character no-undo .
define variable v-list-mode as character no-undo .
define buffer buf_rule-profile for ub.rule-profile.
find first buf_rule-profile no-lock where
          buf_rule-profile.profile_id = X_rule-by-profile.profile_id.

assign
v-param-form = (if buf_rule-profile.custom-param-form > 0
                then  substitute("rul/rcps-&1.w", buf_rule-profile.profile_id)
                else "ref/rulercps.w")
v-list-mode = (if buf_rule-profile.custom-param-form > 0
               then {&table_rp-rule-param}
               else {&table_rule-call-param})
.
run value(v-param-form) (
                     input parparentproc
                    ,input this-procedure:handle
                    ,input "b-chg":U
                    ,input {&update} /*p-mode*/
                    ,input v-list-mode
                    ,input buf_rule-profile.profile_id /*profile-id*/
                    ,input X_rp-by-call.once-more /*once-more*/
                    ,input X_rp-by-call.call_id /*p-call-id*/
                    ,input X_rule-by-profile.codex_id /*p-codex-id*/
                    ,input X_rule-by-profile.ruleset_id /*p-codex-id*/
                    ,input ? /*p-order-id*/
                    ,input X_rule-by-profile.RULE_id /*p-rule-id*/
                    ,INput substitute("Правило &1 &2"
                                      , X_rule-by-profile.RULE_id, calldscr(X_rp-by-call.call_id))  /**/
                    ,input-output table tt0-rule-call-param  ) no-error.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-type Dialog-Frame
PROCEDURE proc-b-type :
define variable v-rid-list as character no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

define buffer buf_clients for ub.clients.
DEFINE BUFFER buf_rp-by-call FOR ub.rp-by-call.
DEFINE BUFFER buf_dis-card-type FOR ub.dis-card-type.
define buffer buf_rule for ub.rule.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_tt0-rule-call-param for tt0-rule-call-param.

IF NOT AVAILABLE X_rule-by-profile THEN DO:
  MESSAGE
  "Сначала необходимо определить правило импорта"
  VIEW-AS ALERT-BOX.
  disable b-param
  with frame {&frame-name} .
  RETURN ERROR.
END.
IF AVAILABLE X_rp-by-call THEN DO:
   ASSIGN
   v-rid-list = STRING(RECID(X_rp-by-call)).
END.
/*выводим список привязок к данному профайлу*/
run rul/rp-by-call-s.w ( INPUT parparentproc
                        ,INPUT "b-sel":U
                        ,INPUT "profile-id"
                        ,INPUT X_rule-by-profile.profile_id
                        ,INPUT '':U /*p-profile-type*/
                        ,input '' /*p-call-id*/
                        ,input 0 /*codex*/
                        ,input 0  /*ruelset*/
                        ,INPUT-OUTPUT v-rid-list
                        ) NO-ERROR.

if v-rid-list = "" then return error.
find first buf_rp-by-call no-lock where
          recid(buf_rp-by-call) = integer(v-rid-list) no-error.
if not available buf_rp-by-call then do:
  message
  substitute("Не найдена привязка правила rp-by-call с recid &1" , v-rid-list)
  view-as alert-box error .
  return.
end.
FIND FIRST X_rp-by-call WHERE RECID(X_rp-by-call) = RECID(buf_rp-by-call).
/*надо найти все rule-call-param для данного типа ДК и показать в БРОУЗЕ  с возможностью изменения*/
FIND FIRST X_dis-card-type WHERE
        X_dis-card-type.uniq-key-rec = buf_rp-by-call.call_id.
display
X_dis-card-type.type
X_dis-card-type.emitent-host-code
with frame {&frame-name}.
FOR EACH buf_tt0-rule-call-param:
   DELETE buf_tt0-rule-call-param.
END.
if X_rule-by-profile.profile_id = 1
and not can-find(first buf_Rule-call-param no-lock where
          buf_rule-call-param.call#_id = X_rp-by-call.call#_id
     and  buf_rule-call-param.codex_id = X_rule-by-profile.codex_id
     and  buf_rule-call-param.ruleset_id = X_rule-by-profile.ruleset_id
     and  buf_rule-call-param.rule_id = X_rule-by-profile.rule_id)
then do:
  find first buf_rule no-lock where
            buf_rule.rule_id = X_rule-by-profile.rule_id.
  find first buf_ruledict where
            buf_ruledict.entry-type = {&rdict-etype-rule}
        and buf_ruledict.uniq-key-rec = buf_rule.uniq-key-rec.
  for each buf_ruledict-param no-lock where
        buf_ruledict-param.entry-id = buf_ruledict.entry-id:
    create buf_tt0-rule-call-param.
    assign
    buf_tt0-rule-call-param.codex_id              = X_rule-by-profile.codex_id
    buf_tt0-rule-call-param.ruleset_id            = X_rule-by-profile.ruleset_id
    buf_tt0-rule-call-param.call_id               = X_rp-by-call.call_id
    buf_tt0-rule-call-param.call#_id              = X_rp-by-call.call#_id
    buf_tt0-rule-call-param.order_id              = 0 /*у нас самый первый*/
    buf_tt0-rule-call-param.rule_id               = buf_rule.rule_id
    buf_tt0-rule-call-param.param-name            = buf_ruledict-param.param-name
    buf_tt0-rule-call-param.p-index               = 0
    buf_tt0-rule-call-param.param-des             = buf_ruledict-param.documentation
    buf_tt0-rule-call-param.param-num             = buf_ruledict-param.param-num
    buf_tt0-rule-call-param.param-label           = buf_ruledict-param.param-label
    buf_tt0-rule-call-param.param-mode            = buf_ruledict-param.param-mode
    buf_tt0-rule-call-param.param-data-type       = buf_ruledict-param.param-data-type
    buf_tt0-rule-call-param.param-2-data-type       = buf_ruledict-param.param-2-data-type
    buf_tt0-rule-call-param.param-3-data-type       = buf_ruledict-param.param-3-data-type
    buf_tt0-rule-call-param.param-value-character = buf_ruledict-param.init-value-character
    buf_tt0-rule-call-param.param-value-date      = buf_ruledict-param.init-value-date
    buf_tt0-rule-call-param.param-value-decimal   = buf_ruledict-param.init-value-decimal
    buf_tt0-rule-call-param.param-value-integer   = buf_ruledict-param.init-value-integer
    buf_tt0-rule-call-param.param-value-logical   = buf_ruledict-param.init-value-logical
    buf_tt0-rule-call-param.once-more             = 1
    buf_tt0-rule-call-param.profile_id   = 1
    .
    if buf_ruledict-param.param-name = "p-dis-tot-obj-code" then do:
      assign
      buf_tt0-rule-call-param.param-value-integer = 0.
    end.
    if buf_ruledict-param.param-name = "p-issue-code" then do:
      assign
      buf_tt0-rule-call-param.param-value-integer = 0.
    end.
    if buf_ruledict-param.param-name = "p-issue-date" then do:
      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      buf_tt0-rule-call-param.param-value-date = v-today.
    end.
    if buf_ruledict-param.param-name = "p-valid-date" then do:
      assign
      buf_tt0-rule-call-param.param-value-date = ?.
    end.
    if buf_ruledict-param.param-name = "p-cli-grp-code" then do:
      assign
      buf_tt0-rule-call-param.param-value-integer = 0.
    end.
    if buf_ruledict-param.param-name = "p-lim-cr" then do:
      assign
      buf_tt0-rule-call-param.param-value-decimal = 0.0.
    end.
    if buf_ruledict-param.param-name = "p-category" then do:
      assign
      buf_tt0-rule-call-param.param-value-integer = 0.
    end.
  end. /*        for each buf_ruledict-param no-lock where*/
end. /*if buf_rule-by-profile.profile_id = 1  then do:*/
else do:
  find X_rule-by-call where
      X_rule-by-call.call#_id = X_rp-by-call.call#_id
    and X_rule-by-call.rule_id = X_rule-by-profile.rule_id
    and X_rule-by-call.profile_id = X_rule-by-profile.profile_id no-error .
  if ambiguous X_rule-by-call then do:
    /*надо выбрать какой*/
    message
    "Выберите какой вызов правила Вас необходим"
    view-as alert-box .
    run rul/rule-by-call-s.w ( input parparentproc
                              ,input "b-sel"
                              ,input "call_id"
                              ,input X_rp-by-call.call_id
                              ,input X_rule-by-profile.codex_id
                              ,input X_rule-by-profile.ruleset_id
                              ,input X_rule-by-profile.rule_id
                              ,input-output v-rid-list) no-error .
    if v-rid-list = '':u then do:
      UNDO, RETURN ERROR.
    end.
    find first X_rule-by-call no-lock where
              recid(X_rule-by-call) = integer(v-rid-list) no-error .
    if not available X_rule-by-call then do:
      UNDO, RETURN ERROR.
    end.
  end.
  for each buf_Rule-call-param no-lock where
          buf_rule-call-param.call#_id = X_rp-by-call.call#_id
     and  buf_rule-call-param.codex_id = X_rule-by-profile.codex_id
     and  buf_rule-call-param.ruleset_id = X_rule-by-profile.ruleset_id
     and  buf_rule-call-param.rule_id = X_rule-by-profile.rule_id
     and  buf_rule-call-param.profile_id = X_rule-by-profile.profile_id
     and  buf_rule-call-param.once-more = X_rp-by-call.once-more
     :
    create buf_tt0-rule-call-param.
    buffer-copy buf_rule-call-param to buf_tt0-rule-call-param.
  end.
end.

RUN proc-b-param IN THIS-PROCEDURE NO-ERROR.

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
if not available X_dis-card-type then do:
  message
  "Вы не выбрали тип ДК"
  view-as alert-box error .
  undo, return error .
end.
ASSIGN FRAME {&FRAME-NAME}
file-name
t-tocd
.
if file-name = '':u
or file-name = ?
then do:
  message
  "Не выбран файл для импорта"
  view-as alert-box error .
  undo, return error .
end.

run gbl/filename.p (
                 input  file-name
                ,output v-full-path
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
if error-status:error then do:
  message
  "Не найден файл, выбранный в качестве файла для импорта"
  view-as alert-box error .
  undo, return error .
end.
FOR EACH dc-list:
  DELETE dc-list.
END.
run rul/ruprcall.p ( input {&table_dis-card-type}
                    ,input X_dis-card-type.uniq-key-rec
                    ,input {&table_rule-call-param} /*p-data-completeness*/
                    ,input ? /*p-cmd-proc-handle*/  /*cmd-bush вызоывем внутри*/
                    ,input 0
                    ,INPUT TABLE tt0-rp-by-call
                    ,INPUT TABLE tt0-rule-by-call
                    ,INPUT TABLE tt0-rule-call-param) no-error .

if error-status:error then do:
  message
  "Ошибка при сохранении параметров правила импорта" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo, return error .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME