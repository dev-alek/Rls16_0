&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER find_c-sert FOR ub.c-sert.
DEFINE BUFFER X_c-sert FOR ub.c-sert.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_curr-sysconf FOR ub.sysconf.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список полной истории сертификатов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/22/04
Author: Bakhtadze Natalya
Creation date: 01/22/04

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/

define input parameter p-mode  as char   no-undo .
/*может быть {&all} "one":U "subject":U 'cli' */
define input parameter p-cli-type like ub.c-sert.cli-type no-undo.
define input parameter p-cli-code like ub.c-sert.cli-code no-undo.
define input parameter p-sert-code like ub.c-sert.sert-code no-undo .
define input parameter p-b-code  like ub.c-sert.b-code no-undo .
define input parameter p-subject  like ub.c-sert.subject no-undo .


/*записи в выборке*/
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список полной истории сертификатов":U.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/fltfield.i }
{ gbl/prn-lib.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
define variable filter-label0 as character no-undo init "История сертификатов" .
define variable filter-label as character no-undo init "История сертификатов" .
define variable filter-point0 as character no-undo init "c-serts" .
define variable filter-point as character no-undo init "c-serts" .
define variable sort-column-name as character no-undo .
define variable print-option as character no-undo.
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-find as logical no-undo.
define variable v-start-date-chr as character no-undo .
define variable v-end-date-chr as character no-undo .
define variable v-subject-chr as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-rid-list as character no-undo .
/*вспомогат*/
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".

define buffer X_curr_sysconf for ub.sysconf.

{ ref/tmpchgs.i "NEW SHARED"}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-c-sert

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-sert temp-changes

/* Definitions for BROWSE br-c-sert                                     */
&Scoped-define FIELDS-IN-QUERY-br-c-sert mark-string(recid(X_c-sert), v-rid-list) X_c-sert.sert-code X_c-sert.corr-date string(X_c-sert.corr-time, "HH:MM:SS":U) usrfulnf(X_c-sert.corr-user-name) get-action(X_c-sert.action) X_c-sert.corr-user-db-num get-subject(X_c-sert.subject) X_c-sert.cli-type + string(X_c-sert.cli-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-c-sert X_c-sert.corr-date
&Scoped-define ENABLED-TABLES-IN-QUERY-br-c-sert X_c-sert
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-c-sert X_c-sert
&Scoped-define SELF-NAME br-c-sert
&Scoped-define QUERY-STRING-br-c-sert FOR EACH X_c-sert NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-c-sert OPEN QUERY {&SELF-NAME} FOR EACH X_c-sert NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-c-sert X_c-sert
&Scoped-define FIRST-TABLE-IN-QUERY-br-c-sert X_c-sert


/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-print B-sch B-Help ~
B-lookup br-c-sert sch-corr-date sch-sert-code sch-corr-user-name ~
BR-changes mark-num
&Scoped-Define DISPLAYED-OBJECTS sch-corr-date sch-sert-code ~
sch-corr-user-name mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-action Dialog-Frame
FUNCTION get-action RETURNS CHARACTER
  ( p-action as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-subject Dialog-Frame
FUNCTION get-subject RETURNS CHARACTER
  ( p-subject as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sch-corr-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дате изменения"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE sch-corr-user-name AS CHARACTER FORMAT "X(9)":U
     LABEL "пользователю"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-sert-code AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     LABEL "№ сертификата"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-c-sert FOR
      X_c-sert SCROLLING.

DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-c-sert
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-c-sert Dialog-Frame _FREEFORM
  QUERY br-c-sert NO-LOCK DISPLAY
      mark-string(recid(X_c-sert), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_c-sert.sert-code COLUMN-LABEL "№ сертиф." FORMAT "X(8)":U
      X_c-sert.corr-date FORMAT "99/99/9999":U
      string(X_c-sert.corr-time, "HH:MM:SS":U) COLUMN-LABEL "Время изм." FORMAT "X(8)":U
      usrfulnf(X_c-sert.corr-user-name) FORMAT "X(18)":U
      get-action(X_c-sert.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
      X_c-sert.corr-user-db-num FORMAT ">>>>9":U
      get-subject(X_c-sert.subject) COLUMN-LABEL "Предмет изменений" FORMAT "X(15)":U
      X_c-sert.cli-type + string(X_c-sert.cli-code) COLUMN-LABEL "Контрагент" FORMAT "X(8)":U
  ENABLE
      X_c-sert.corr-date
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 11.46.

DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(40)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     B-lookup AT ROW 1.04 COL 45
     br-c-sert AT ROW 2 COL 1
     sch-corr-date AT ROW 13.63 COL 85.75 COLON-ALIGNED
     sch-sert-code AT ROW 13.67 COL 56.13 COLON-ALIGNED
     sch-corr-user-name AT ROW 13.71 COL 22.5 COLON-ALIGNED
     BR-changes AT ROW 14.79 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 8.38 BY 1 AT ROW 13.63 COL 1.38
          FGCOLOR 4
     SPACE(89.48) SKIP(7.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Полная история по сертификатам"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_c-sert B "?" NO-UNDO ub c-sert
      TABLE: X_c-sert B "?" ? ub c-sert
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_curr-sysconf B "?" ? ub sysconf
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-c-sert B-lookup Dialog-Frame */
/* BROWSE-TAB BR-changes sch-corr-user-name Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-c-sert
/* Query rebuild information for BROWSE br-c-sert
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-sert NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-c-sert */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Полная история по сертификатам */
DO:
  ASSIGN
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Полная история по сертификатам */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
  DEFINE VARIABLE v-rec AS RECID NO-UNDO.
  DEFINE BUFFER buf_c-pump FOR ub.c-pump.
  DEFINE BUFFER buf_c-pl-gds-pump FOR ub.c-pl-gds-pump.
  DEFINE BUFFER buf_c-pl-pump FOR ub.c-pl-pump.
  DEFINE BUFFER buf_c-pl-pump-nozzle FOR ub.c-pl-pump-nozzle.
  DEFINE BUFFER buf_c-pump-nozzle FOR ub.c-pl-pump-nozzle.
    IF AVAILABLE X_c-sert THEN DO:

    CASE X_c-sert.subject:
    END CASE.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available X_c-sert then do:
    { gbl/markstrn.i X_c-sert v-rid-list }
    loc#log = br-c-sert:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-c-sert:select-next-row ().
        apply "VALUE-CHANGED" to br-c-sert in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-c-sert in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
    run proc-b-print in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
    run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available X_c-sert ) then do:
    if ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_c-sert ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-c-sert
&Scoped-define SELF-NAME br-c-sert
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-c-sert Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-c-sert IN FRAME Dialog-Frame
DO:
     run proc-br-c-sert in this-procedure no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-c-sert Dialog-Frame
ON RETURN OF br-c-sert IN FRAME Dialog-Frame
DO:
    run proc-br-c-sert in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-c-sert Dialog-Frame
ON VALUE-CHANGED OF br-c-sert IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-corr-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-corr-date Dialog-Frame
ON CTRL-J OF sch-corr-date IN FRAME Dialog-Frame /* Дате изменения */
DO:
   run proc-find-corr-date in this-procedure(yes, input frame {&frame-name} sch-corr-date) no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-corr-date Dialog-Frame
ON RETURN OF sch-corr-date IN FRAME Dialog-Frame /* Дате изменения */
DO:
  run proc-find-corr-date in this-procedure(no, input frame {&frame-name} sch-corr-date) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-corr-user-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-corr-user-name Dialog-Frame
ON CTRL-J OF sch-corr-user-name IN FRAME Dialog-Frame /* пользователю */
DO:
  run proc-find-user in this-procedure(yes, input frame {&frame-name} sch-corr-user-name) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-corr-user-name Dialog-Frame
ON RETURN OF sch-corr-user-name IN FRAME Dialog-Frame /* пользователю */
DO:
  run proc-find-user in this-procedure(no, input frame {&frame-name} sch-corr-user-name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-sert-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-sert-code Dialog-Frame
ON CTRL-J OF sch-sert-code IN FRAME Dialog-Frame /* № сертификата */
DO:
  run proc-find-sert-code in this-procedure(yes, input frame {&frame-name} sch-sert-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-sert-code Dialog-Frame
ON RETURN OF sch-sert-code IN FRAME Dialog-Frame /* № сертификата */
DO:
  run proc-find-sert-code in this-procedure(no, input frame {&frame-name} sch-sert-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-c-sert" }
{ gbl/brwrefre.i " v-doc-rec = recid(X_c-sert).  RUn OpenBR in this-procedure ( input yes, input no, input '':U).  REPOSITION br-c-sert to recid v-doc-rec No-ERROR. ~
               apply 'value-changed' to br-c-sert. " }

{ gbl/setfltnm.i }
{ gbl/ed_date.i sch-corr-date}

{ gbl/srt-clmd.i
  &browse-name    = "br-c-sert"
  &frame-name     = "{&frame-name}"
  &table-name     = "X_c-sert"
  &sort-clmn_1    = "X_c-sert.sert-code"
  &sort-clmn_2    = "X_c-sert.corr-date"
  &sort-clmn_3    = "X_c-sert.corr-user-db-num"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/brwrepos.i
  &line-num=5
}


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   if p-mode <> {&all}
 and p-mode <> "one":U
 and p-mode <> {&g___object}
 and p-mode <> "subject":U
 then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return.
 end.
 v-rid-list = p-rid-list.
  if v-rid-list <> "" then do:
      FIND FIRST find_c-sert No-LOCK where
                 recid(find_c-sert) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_c-sert then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова v-rid-list" v-rid-list
        view-as alert-box error .
        return error.
      end.
      v-doc-rec = integer(entry(1, v-rid-list)).
    end.
  { gbl/curdbnum.i v-db-num }
  if p-mode <> {&all} then do:
    assign
    v-find = yes.
  end.
  RUN MyEnable.
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if v-rid-list <> "":U then
  REPOSITION br-c-sert to recid integer(entry(1, v-rid-list)) No-ERROR.
  { gbl/mv-clmn.i
    &browse-name = "br-c-sert"
    &frame-name = "{&frame-name}"
    &ext-col = 9
    &start-column = 1
    &prev-order-column_1 = "'9,1,2,3,4,5,6,7,8'"
    &prev-order-column-condition_1 = " p-mode = {&all} "
    &prev-order-column_2 = "'1,2,3,4,5,6,7,8,9'"
    &prev-order-column-condition_2 = " p-mode <> {&all} "
    }

  run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  browse br-changes :handle
    ) .
  run diasize_init in this-procedure .

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
  DISPLAY sch-corr-date sch-sert-code sch-corr-user-name mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-print B-sch B-Help B-lookup br-c-sert
         sch-corr-date sch-sert-code sch-corr-user-name BR-changes mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
assign
br-c-sert:num-locked-columns in frame {&frame-name} = 1
X_c-sert.corr-date:read-only in browse br-c-sert = yes
br-changes:title = "":U
temp-changes.l_name:resizable in browse br-changes = true
temp-changes.v_old:resizable in browse br-changes = true
temp-changes.v_new:resizable in browse br-changes = true
temp-changes.l_name:width in browse br-changes = 30
temp-changes.v_old:width in browse br-changes = 40
temp-changes.v_new:width in browse br-changes = 40
.
VIEW frame {&frame-name} .
DISPLAY
sch-corr-date
sch-sert-code
sch-corr-user-name
mark-num
WITH FRAME {&frame-name} .
ENABLE
b-quit
B-mark when lookup("b-mark":U, bttns) > 0
b-sel when lookup("b-sel":U, bttns) > 0
B-lookup
B-sch
B-Print
B-Help
br-c-sert
sch-corr-date
sch-sert-code when p-mode = {&all}
sch-corr-user-name
BR-changes mark-num
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
hide b-lookup
sch-corr-user-name
in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable v-title as character no-undo .
define variable title0 as character no-undo.
title0 = "История сертификатов" + {&space-char}.
run waitfram-show in this-procedure ("Ждите...").

define variable sort-column-phrase as character no-undo .

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


&scop flt-open-open-query OPEN QUERY br-c-sert FOR EACH X_c-sert

&scop flt-open-dyn_open-query  FOR EACH X_c-sert

&scop flt-open-query-handle query br-c-sert:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-sert

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_c-sert

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .
CASE p-mode :
  WHEN {&all}        THEN DO:
   assign
    filter-point = filter-point0 + p-mode
    filter-label = substitute("&1", filter-label0)
    .
  { gbl/fltopend.i
      &where-cond = " TRUE "
      &use-ind    = "  "
      &by         = "  " }
  END.
  when 'cli' then do:
    assign
    filter-point = filter-point0 + p-mode
    filter-label = substitute("&1 Один контрагент", filter-label0)
    .
    if p-open-query then do:
      assign
      frame {&frame-name}:TITLE = title0 + substitute(" Контрагент &1&2"
                                                            ,p-cli-type, p-cli-code ).

    end.
    { gbl/fltopend.i
      &where-cond = " X_c-sert.cli-type = p-cli-type and X_c-sert.cli-code = p-cli-code "
      &dyn_where-cond = " substitute(' X_c-sert.cli-type = &1&2&1 and X_c-sert.cli-code = &3 ', ~{&double-quote~}, p-cli-type, p-cli-code)"
      &use-ind    = "  "
      &by         = "  " }

  end.

  WHEN "one":u THEN DO:
    assign
    filter-point = filter-point0 + p-mode
    filter-label = substitute("&1 Один контрагент, один сертификат", filter-label0)
    .
    if p-open-query then do:
      assign
      frame {&frame-name}:TITLE = title0 + substitute(" Контрагент &1&2 Сертификат &3"
                                                            ,p-cli-type, p-cli-code, p-sert-code )
     .
   end.
     { gbl/fltopend.i
      &where-cond = " X_c-sert.cli-type = p-cli-type and X_c-sert.cli-code = p-cli-code AND X_c-sert.sert-code  = p-sert-code "
      &dyn_where-cond = " substitute(' X_c-sert.cli-type = &1&2&1 and X_c-sert.cli-code = &3 AND X_c-sert.sert-code = &1&4&1' ~
                                   ,~{&double-quote~}, p-cli-type, p-cli-code, p-sert-code)"
      &use-ind    = "  "
      &by         = "  " }

  END.
  WHEN "subject":u THEN DO:
&scop hn-sert-hist-code p-subject
    assign
    filter-point = filter-point0 + p-mode
    filter-label = substitute("&1 Один контррагент, один сертификат, предмет изменения", filter-label0)
    v-subject-chr = {&hn-sert-hist-name}
    .
    v-title =  title0 + substitute(" Контрагент &1&2 Сертификат № &3"
                                    , p-cli-type, p-cli-code, p-sert-code, v-subject-chr ).

    CASE p-subject:
      when {&table_sert} then do:
        if p-open-query then do:
          assign
          frame {&frame-name}:title = v-title
          .
        end.
      { gbl/fltopend.i
        &where-cond = " X_c-sert.cli-type = p-cli-type and X_c-sert.cli-code = p-cli-code  ~
                        And X_c-sert.sert-code  = p-sert-code  and X_c-sert.subject = p-subject "
        &dyn_where-cond = " substitute('X_c-sert.cli-type = &1&2&1 and X_c-sert.cli-code = &3  ~
                        And X_c-sert.sert-code  = &1&4&1  and X_c-sert.subject = &1&5&1' ~
                        ,p-cli-type ~
                        ,p-cli-code ~
                        ,p-sert-code ~
                        ,p-subject)  "

        &use-ind    = "  "
        &by         = "  " }
      end.
      when {&table_sert-join} then do:
        if p-cli-type = '':U
        or p-cli-code = 0
        or p-sert-code = '':U then do:
          if p-open-query then do:
            assign
            frame {&frame-name}:title = title0 + substitute(" Все сертификаты к товару с кодом &1", p-b-code).
         end.
        { gbl/fltopend.i
          &where-cond = " X_c-sert.b-code = p-b-code and X_c-sert.subject = p-subject  "
          &dyn_where-cond = " substitute('X_c-sert.b-code = &1 and X_c-sert.subject = &2&3&2 ', p-b-code, ~{&double-quote~}, p-subject) "
          &use-ind    = "  "
          &by         = "  " }

        end.
        else do:
        end.
          if p-open-query then do:
            assign
            frame {&frame-name}:title = v-title + substitute(" к товару с кодом &1", p-b-code).
          end.
        { gbl/fltopend.i
          &where-cond = " X_c-sert.cli-type = p-cli-type and X_c-sert.cli-code = p-cli-code  ~
                          and X_c-sert.subject = p-subject ~
                          And X_c-sert.sert-code  = p-sert-code  and X_c-sert.b-code = p-b-code "
          &dyn_where-cond = " substitute('X_c-sert.cli-type = &1&2&1 and X_c-sert.cli-code = &3 ~
                          and X_c-sert.subject = &1&4&1 ~
                          And X_c-sert.sert-code  = &1&5&1  and X_c-sert.b-code = &6' ~
                           ,p-cli-type ~
                           ,p-cli-code ~
                           ,p-subject ~
                           ,p-sert-code ~
                           ,p-b-code )  "

          &use-ind    = "  "
          &by         = "  " }

      end.
    END CASE.
  END.
END CASE.

if not p-open-query  and v-doc-rec <> ? then
REPOSITION br-c-sert to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-c-sert:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-c-sert in frame {&frame-name}.
APPLY "ENTRY" TO br-c-sert.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable accum-count as integer.
define variable v-doc-rec as recid no-undo.
define variable v-prod as character no-undo .
define variable v-subject-chr as character no-undo .
define variable v-upd-time as character no-undo .
define variable v-obj as character no-undo .
define variable v-action-chr as character no-undo .
define variable v-for-usr-name as character no-undo .

DEFINE FRAME HistoryList
X_c-sert.sert-code COLUMn-LABEL "№ сертификата"
v-action-chr FORMAT "X(10)" COLUMN-LABEL "Действие"
v-subject-chr COLUMN-LABEL "Предмет изменений" FORMAT "X(20)"
X_c-sert.corr-date
v-upd-time COLUMN-LABEL "Время изм." FORMAT "X(8)"
v-for-usr-name column-label "Изменил" format "(18)"
X_c-sert.corr-user-db-num
v-obj COLUMN-LABEL "Контрагент" FORMAT "X(8)"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(192)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 192).
date_string = cur-time-print() .
assign
v-doc-rec = recid( X_c-sert ).
DO WHILE available X_c-sert :
      GET prev br-c-sert.
END.
run prn-lib-open-stream  in this-procedure (
                                             input parparentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).
PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(177)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME HistoryList  .
run waitfram-show in this-procedure ("Ждите...").
  GET next br-c-sert.
    DO WHILE available X_c-sert :
      Display STREAM PrnLibStream
      X_c-sert.sert-code
      get-action(X_c-sert.action) @ v-action-chr
      get-subject(X_c-sert.subject) @ v-subject-chr
      X_c-sert.corr-date
      string(X_c-sert.corr-time, "HH:MM:SS":U) @ v-upd-time
      usrfulnf(X_c-sert.corr-user-name) @ v-for-usr-name
      X_c-sert.corr-user-db-num
      X_c-sert.cli-type + string(X_c-sert.cli-code) @ v-obj
      with FRAME HistoryList .
  DOWN STREAM PrnLibStream 1 with FRAME HistoryList  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-c-sert.
END.
UNDERLINE  STREAM PrnLibStream
X_c-sert.sert-code
v-action-chr
v-subject-chr
X_c-sert.corr-date
v-upd-time
v-for-usr-name
X_c-sert.corr-user-db-num
v-obj
with FRAME HistoryList .
DISPLAY STREAM PrnLibStream
"ИТОГО"  @ X_c-sert.sert-code
string(accum-count)  @ v-action-chr
with frame HistoryList.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME CheckList.
output  STREAM PrnLibStream CLOSE.

run waitfram-hide in this-procedure.
run prn-lib-prn-file in this-procedure (
                                          input parparentproc
                                          ,input 8
                                          ).
reposition br-c-sert to recid v-doc-rec no-error.
apply "entry" to br-c-sert in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
  tbl = 'c-sert'
  join-tbl = 'X_c-sert'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('cli-type{&delim-flt}cli-code', 'Контрагент', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sert-code', '№ сертификата', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время корр.', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', '', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('subject', 'Предмет изменения', 'sert-hist-subject',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('action', 'Действие', 'hist-action',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                    ,INPUT (filter-point + {&delim-par} + filter-label + {&delim-par} + 'yes':U)
                    , INPUT tbl
                    , INPUT join-tbl
                    , INPUT fld
                    , INPUT lab
                    , INPUT spr
                    , INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-c-sert Dialog-Frame
PROCEDURE proc-br-c-sert :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ ref/brwsretr.i }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-corr-date Dialog-Frame
PROCEDURE proc-find-corr-date :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-date like ub.fin-doc.doc-date no-undo.
define variable v-date-chr as character no-undo.
if p-date = ? then return .
display
0 @ sch-sert-code
"":U @ sch-corr-user-name
with frame {&frame-name}.
assign
v-date-chr = string(day(p-date)) + {&slash-char} +
                 string(month(p-date)) + {&slash-char} +
                 string(year(p-date)).

       run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input true  /* p-find-next  */
        ,input substitute("and X_c-sert.corr-date = &1 "
          , v-date-chr)
        ).
      apply "entry":u to sch-corr-date in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-sert-code Dialog-Frame
PROCEDURE proc-find-sert-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-sert-code like ub.c-sert.sert-code no-undo.
define variable v-sert-code as character no-undo.
assign
sch-corr-date = ?.
display
"":U @ sch-corr-user-name
sch-corr-date
with frame {&frame-name}.

assign
v-sert-code = string(p-sert-code).
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-sert.sert-code = &1 "
      , v-sert-code)
    ).
apply "entry":u to sch-sert-code in frame {&frame-name} .



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-user Dialog-Frame
PROCEDURE proc-find-user :
define input parameter p-next as logical no-undo.
define input parameter p-user like ub.c-sert.corr-user-name no-undo.
assign
sch-corr-date = ?.
display
sch-corr-date
0 @ sch-sert-code
with frame {&frame-name}.
p-user = {&double-quote} + p-user + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-sert.corr-user-name = &1 "
      , p-user)
    ).
apply "entry":u to sch-corr-user-name in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame
PROCEDURE proc-view-changes :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-description as character no-undo .
for each temp-changes:
    delete temp-changes.
END.
if not available X_c-sert then do:
  Open QUery br-changes for each temp-changes.
  return.
end.

run ref/c-sertv.p (
                   input X_c-sert.cli-type
                  ,input X_c-sert.cli-code
                  ,input X_c-sert.sert-code
                  ,input X_c-sert.b-code
                  ,input X_c-sert.chip-num
                  ,input X_c-sert.corr-user-db-num
                  ,input X_c-sert.subject
                  ,input X_c-sert.action
                  ,input no /*p-silent*/
                  ,output v-description
               ) no-error .
Open QUery br-changes for each temp-changes.
assign
br-changes:title in frame {&frame-name} = v-description
.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-action Dialog-Frame
FUNCTION get-action RETURNS CHARACTER
  ( p-action as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  &scop hn-action-code trim(string(p-action))
define variable dops as character no-undo.
assign dops = {&hn-action-name} no-error.

RETURN dops.   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-subject Dialog-Frame
FUNCTION get-subject RETURNS CHARACTER
  ( p-subject as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
&scop hn-sert-hist-code p-subject
  RETURN {&hn-sert-hist-name}.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME