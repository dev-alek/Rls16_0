&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER find_sum-grp-obj FOR ub.c-sum-grp-obj.
DEFINE BUFFER X_c-sum-grp-obj FOR ub.c-sum-grp-obj.
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

Список полной истории sum-grp-obj

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
/*контекст сессии*/
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo.
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo.
define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/

define input parameter p-mode  as char   no-undo .
/*может быть {&all} "one":U {&g___object} */
define input parameter p-obj-type like ub.sum-grp-obj.obj-type no-undo.
define input parameter p-obj-code like ub.sum-grp-obj.obj-code no-undo.
define input parameter p-grp-code like ub.sum-grp-obj.grp-code no-undo .

/*записи в выборке*/
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список полной истории sum-grp-obj":U.
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
{ ref/disgrpru.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
define variable filter-point as character no-undo init "csumgros" .
define variable filter-point0 as character no-undo init "csumgros" .
define variable filter-label as character no-undo init "История групп товаров на кассах объекта" .
define variable filter-labe0 as character no-undo init "История групп товаров на кассах объекта" .
define variable v-rid-list as character no-undo .
define variable sort-column-name as character no-undo .
define variable print-option as character no-undo.
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-find as logical no-undo.
define variable v-start-date-chr as character no-undo .
define variable v-end-date-chr as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .

/*вспомогат*/
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".

define buffer X_curr_sysconf for ub.sysconf.

{ ref/tmpchgs.i "NEW SHARED" " " "with-action" }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-changes

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-changes X_c-sum-grp-obj

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE br-sum-grp-obj                                */
&Scoped-define FIELDS-IN-QUERY-br-sum-grp-obj mark-string(recid(X_c-sum-grp-obj), v-rid-list) X_c-sum-grp-obj.grp-code get-subject(X_c-sum-grp-obj.subject) "Предмет изменений" X_c-sum-grp-obj.corr-date string(X_c-sum-grp-obj.corr-time, "HH:MM:SS":U) usrfulnf(X_c-sum-grp-obj.corr-user-name) get-action(X_c-sum-grp-obj.action) X_c-sum-grp-obj.corr-user-db-num X_c-sum-grp-obj.obj-type + string(X_c-sum-grp-obj.obj-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-sum-grp-obj X_c-sum-grp-obj.corr-date
&Scoped-define ENABLED-TABLES-IN-QUERY-br-sum-grp-obj X_c-sum-grp-obj
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-sum-grp-obj X_c-sum-grp-obj
&Scoped-define SELF-NAME br-sum-grp-obj
&Scoped-define QUERY-STRING-br-sum-grp-obj FOR EACH X_c-sum-grp-obj NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-sum-grp-obj OPEN QUERY {&SELF-NAME} FOR EACH X_c-sum-grp-obj NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-sum-grp-obj X_c-sum-grp-obj
&Scoped-define FIRST-TABLE-IN-QUERY-br-sum-grp-obj X_c-sum-grp-obj


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-print B-sch B-Help ~
B-lookup br-sum-grp-obj sch-corr-date sch-grp-code sch-corr-user-name ~
BR-changes mark-num
&Scoped-Define DISPLAYED-OBJECTS sch-corr-date sch-grp-code ~
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

DEFINE VARIABLE sch-grp-code AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     LABEL "код группы"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.

DEFINE QUERY br-sum-grp-obj FOR
      X_c-sum-grp-obj SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(40)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.25.

DEFINE BROWSE br-sum-grp-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-sum-grp-obj Dialog-Frame _FREEFORM
  QUERY br-sum-grp-obj NO-LOCK DISPLAY
      mark-string(recid(X_c-sum-grp-obj), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_c-sum-grp-obj.grp-code COLUMN-LABEL "Код группы" FORMAT "99":U
      get-subject(X_c-sum-grp-obj.subject) "Предмет изменений" FORMAT "X(15)"
      X_c-sum-grp-obj.corr-date FORMAT "99/99/9999":U
      string(X_c-sum-grp-obj.corr-time, "HH:MM:SS":U) COLUMN-LABEL "Время изм." FORMAT "X(8)":U
      usrfulnf(X_c-sum-grp-obj.corr-user-name) FORMAT "X(18)":U
      get-action(X_c-sum-grp-obj.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
      X_c-sum-grp-obj.corr-user-db-num FORMAT ">>>>9":U
      X_c-sum-grp-obj.obj-type + string(X_c-sum-grp-obj.obj-code) COLUMN-LABEL "Объект" FORMAT "X(8)":U
  ENABLE
      X_c-sum-grp-obj.corr-date
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 11.46.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     B-lookup AT ROW 1.04 COL 45
     br-sum-grp-obj AT ROW 2 COL 1
     sch-corr-date AT ROW 13.63 COL 85.75 COLON-ALIGNED
     sch-grp-code AT ROW 13.67 COL 56.13 COLON-ALIGNED
     sch-corr-user-name AT ROW 13.71 COL 22.5 COLON-ALIGNED
     BR-changes AT ROW 14.79 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 8.38 BY 1 AT ROW 13.63 COL 1.38
          FGCOLOR 4
     SPACE(89.48) SKIP(7.44)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Полная история группы товаров (на кассе)"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_sum-grp-obj B "?" NO-UNDO ub c-sum-grp-obj
      TABLE: X_c-sum-grp-obj B "?" ? ub c-sum-grp-obj
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
/* BROWSE-TAB br-sum-grp-obj B-lookup Dialog-Frame */
/* BROWSE-TAB BR-changes sch-corr-user-name Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-sum-grp-obj
/* Query rebuild information for BROWSE br-sum-grp-obj
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-sum-grp-obj NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-sum-grp-obj */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Полная история группы товаров (на кассе) */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Полная история группы товаров (на кассе) */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available X_c-sum-grp-obj then do:
    { gbl/markstrn.i X_c-sum-grp-obj v-rid-list }
    loc#log = br-sum-grp-obj:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-sum-grp-obj:select-next-row ().
        apply "VALUE-CHANGED" to br-sum-grp-obj in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-sum-grp-obj in frame {&frame-name}.
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
  if ( available X_c-sum-grp-obj ) then do:
    if ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_c-sum-grp-obj ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-sum-grp-obj
&Scoped-define SELF-NAME br-sum-grp-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-sum-grp-obj Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-sum-grp-obj IN FRAME Dialog-Frame
DO:
     run proc-br-sum-grp-obj in this-procedure no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-sum-grp-obj Dialog-Frame
ON RETURN OF br-sum-grp-obj IN FRAME Dialog-Frame
DO:
    run proc-br-sum-grp-obj in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-sum-grp-obj Dialog-Frame
ON VALUE-CHANGED OF br-sum-grp-obj IN FRAME Dialog-Frame
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


&Scoped-define SELF-NAME sch-grp-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-grp-code Dialog-Frame
ON CTRL-J OF sch-grp-code IN FRAME Dialog-Frame /* код группы */
DO:
  run proc-find-grp-code in this-procedure(yes, input frame {&frame-name} sch-grp-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-grp-code Dialog-Frame
ON RETURN OF sch-grp-code IN FRAME Dialog-Frame /* код группы */
DO:
  run proc-find-grp-code in this-procedure(no, input frame {&frame-name} sch-grp-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-changes
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-sum-grp-obj" }
{ gbl/brwrefre.i " v-doc-rec = recid(X_c-sum-grp-obj).  RUn OpenBR in this-procedure ( input yes, input no, input '':U).  REPOSITION br-sum-grp-obj to recid v-doc-rec No-ERROR. ~
              apply 'value-changed' to br-sum-grp-obj.      " }

{ gbl/setfltnm.i }
{ gbl/ed_date.i sch-corr-date}

{ gbl/srt-clmd.i
  &browse-name    = "br-sum-grp-obj"
  &frame-name     = "{&frame-name}"
  &table-name     = "X_c-sum-grp-obj"
  &sort-clmn_1    = "X_c-sum-grp-obj.grp-code"
  &sort-clmn_2    = "X_c-sum-grp-obj.corr-date"
  &sort-clmn_3    = "X_c-sum-grp-obj.corr-user-db-num"
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
  then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return.
 end.
 if p-mode = {&g___object}
 or p-mode = "subject":U
 then do:
  find first X_clients no-lock where
                X_clients.obj-type = p-obj-type
            and X_clients.obj-code = p-obj-code no-error.
    if not available X_clients then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-obj-type/p-obj-code"
        p-obj-type p-obj-code
        view-as alert-box ERROR.
        return.
    end.
   { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
 end.
 v-rid-list = p-rid-list.
  if v-rid-list <> "" then do:
      FIND FIRST find_sum-grp-obj No-LOCK where
                 recid(find_sum-grp-obj) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_sum-grp-obj then do:
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
  REPOSITION br-sum-grp-obj to recid integer(entry(1, v-rid-list)) No-ERROR.
  { gbl/mv-clmn.i
    &browse-name = "br-sum-grp-obj"
    &frame-name = "{&frame-name}"
    &ext-col = 8
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8'"
    &prev-order-column-condition_1 = " p-mode = {&all} "
    &prev-order-column_2 = "'1,2,3,4,5,6,7,8'"
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
  DISPLAY sch-corr-date sch-grp-code sch-corr-user-name mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-print B-sch B-Help B-lookup br-sum-grp-obj
         sch-corr-date sch-grp-code sch-corr-user-name BR-changes mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
assign
  br-sum-grp-obj:num-locked-columns in frame {&frame-name} = 1
  X_c-sum-grp-obj.corr-date:read-only in browse br-sum-grp-obj = yes
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
  sch-grp-code
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
  br-sum-grp-obj
  sch-corr-date
  sch-grp-code when p-mode = {&all}
  sch-corr-user-name
  BR-changes mark-num
  WITH FRAME {&frame-name} .
  VIEW FRAME {&frame-name} .
  hide b-lookup sch-corr-user-name
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
title0 = "История групп товаров на кассах объекта" + {&space-char}.
run waitfram-show in this-procedure ( input "Ждите...").

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


&scop flt-open-open-query OPEN QUERY br-sum-grp-obj FOR EACH X_c-sum-grp-obj

&scop flt-open-dyn_open-query FOR EACH X_c-sum-grp-obj

&scop flt-open-query-handle QUERY br-sum-grp-obj:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-sum-grp-obj

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_c-sum-grp-obj

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .
CASE p-mode :
  WHEN {&all}        THEN DO:
    assign
    filter-point = filter-point0 + p-mode
    filter-label = substitute("&1", filter-labe0)
    .
    { gbl/fltopend.i
        &where-cond = " TRUE "
        &use-ind    = "  "
        &by         = "  " }
  END.
  WHEN {&g___object} THEN DO:
    assign
    filter-point = filter-point0 + p-mode
    filter-label = substitute("&1 По объекту", filter-labe0)
    .
    if p-open-query then do:
      ASSIGN
      frame {&frame-name}:TITLE = title0 + substitute(" Объект: &1&2"
                                                        ,p-obj-type, p-obj-code).
    end.
    { gbl/fltopend.i
      &where-cond = " ~
                    X_c-sum-grp-obj.obj-type = p-obj-type and X_c-sum-grp-obj.obj-code = p-obj-code   ~
                    "
      &dyn_where-cond = " substitute('X_c-sum-grp-obj.obj-type = &1&2&1 and X_c-sum-grp-obj.obj-code = &3 ' ~
                          , ~{&double-quote~}, p-obj-type, p-obj-code) "

      &use-ind    = "  "
      &by         = "  " }
  END.
  WHEN "one":u THEN DO:
    assign
    filter-point = filter-point0 + p-mode
    filter-label = substitute("&1 Одна группы", filter-labe0)
    .
    if p-open-query then do:
      ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" Объект &1&2 Группа &3"
                                                              ,p-obj-type, p-obj-code ,p-grp-code  ).
    end.
    { gbl/fltopend.i
      &where-cond = " X_c-sum-grp-obj.obj-type = p-obj-type and X_c-sum-grp-obj.obj-code = p-obj-code AND X_c-sum-grp-obj.grp-code  = p-grp-code "
      &dyn_where-cond = " substitute('X_c-sum-grp-obj.obj-type = &1&2&1 and X_c-sum-grp-obj.obj-code = &3 AND X_c-sum-grp-obj.grp-code  = &4 ' ~
                            , ~{&double-quote~}, p-obj-type, p-obj-code,  p-grp-code)"
      &use-ind    = "  "
      &by         = "  " }

  END.
END CASE.

if not p-open-query  and v-doc-rec <> ? then
REPOSITION br-sum-grp-obj to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-sum-grp-obj:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-sum-grp-obj in frame {&frame-name}.
APPLY "ENTRY" TO br-sum-grp-obj.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable accum-count as integer.
define variable v-doc-rec as recid no-undo.
define variable v-prod as character no-undo .
define variable v-upd-time as character no-undo .
define variable v-obj as character no-undo .
define variable v-action-chr as character no-undo .
DEFINE VARIABLE v-for-user-name AS CHARACTER NO-UNDO.
DEFINE FRAME HistoryList
X_c-sum-grp-obj.grp-code COLUMn-LABEL "№ пистолета"
v-action-chr FORMAT "X(10)" COLUMN-LABEL "Действие"
X_c-sum-grp-obj.corr-date
v-upd-time COLUMN-LABEL "Время изм." FORMAT "X(8)"
v-for-user-name COLUMN-LABEL "Изменил" FORMAT "X(18)"
X_c-sum-grp-obj.corr-user-db-num
v-obj COLUMN-LABEL "Объект" FORMAT "X(8)"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 195).
date_string = cur-time-print() .
assign
v-doc-rec = recid( X_c-sum-grp-obj ).
DO WHILE available X_c-sum-grp-obj :
      GET prev br-sum-grp-obj.
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
Line format "X(180)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME HistoryList  .
run waitfram-show in this-procedure ("Ждите...").
  GET next br-sum-grp-obj.
    DO WHILE available X_c-sum-grp-obj :
      Display STREAM PrnLibStream
      X_c-sum-grp-obj.grp-code
      get-action(X_c-sum-grp-obj.action) @ v-action-chr
      X_c-sum-grp-obj.corr-date
      string(X_c-sum-grp-obj.corr-time, "HH:MM:SS":U) @ v-upd-time
      usrfulnf(X_c-sum-grp-obj.corr-user-name) @ v-for-user-name
      X_c-sum-grp-obj.corr-user-db-num
      X_c-sum-grp-obj.obj-type + string(X_c-sum-grp-obj.obj-code) @ v-obj
      with FRAME HistoryList .
  DOWN STREAM PrnLibStream 1 with FRAME HistoryList  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-sum-grp-obj.
END.
UNDERLINE  STREAM PrnLibStream
X_c-sum-grp-obj.grp-code
v-action-chr
X_c-sum-grp-obj.corr-date
v-upd-time
v-for-user-name
X_c-sum-grp-obj.corr-user-db-num
v-obj
with FRAME HistoryList .
DISPLAY STREAM PrnLibStream
"ИТОГО"  @ X_c-sum-grp-obj.grp-code
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
reposition br-sum-grp-obj to recid v-doc-rec no-error.
apply "entry" to br-sum-grp-obj in frame {&frame-name}.

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
  tbl = 'sum-grp-obj'
  join-tbl = 'X_c-sum-grp-obj'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('grp-code', 'Код группы', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время корр.', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('action', 'Действие', 'hist-action',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                    ,INPUT (filter-point + {&delim-par} + filter-label + {&delim-par} + 'yes':U)
                    ,INPUT tbl
                    ,INPUT join-tbl
                    ,INPUT fld
                    ,INPUT lab
                    ,INPUT spr
                    ,INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-sum-grp-obj Dialog-Frame
PROCEDURE proc-br-sum-grp-obj :
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
define input parameter p-next as logical no-undo.
define input parameter p-date like ub.fin-doc.doc-date no-undo.
define variable v-date-chr as character no-undo.
if p-date = ? then return .
display
0 @ sch-grp-code
"":U @ sch-corr-user-name
with frame {&frame-name}.
assign
v-date-chr = string(day(p-date)) + {&slash-char} +
                 string(month(p-date)) + {&slash-char} +
                 string(year(p-date)).

       run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input true  /* p-find-next  */
        ,input substitute("and X_c-sum-grp-obj.corr-date = &1 "
          , v-date-chr)
        ).
      apply "entry":u to sch-corr-date in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-grp-code Dialog-Frame
PROCEDURE proc-find-grp-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-grp-code like ub.sum-grp-obj.grp-code no-undo.
define variable v-grp-code as character no-undo.
assign
sch-corr-date = ?.
display
"":U @ sch-corr-user-name
sch-corr-date
with frame {&frame-name}.

assign
v-grp-code = string(p-grp-code).
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-sum-grp-obj.grp-code = &1 "
      , v-grp-code)
    ).
apply "entry":u to sch-grp-code in frame {&frame-name} .



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-user Dialog-Frame
PROCEDURE proc-find-user :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-user like ub.c-sum-grp-obj.corr-user-name no-undo.
assign
sch-corr-date = ?.
display
sch-corr-date
0 @ sch-grp-code
with frame {&frame-name}.
p-user = {&double-quote} + p-user + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-sum-grp-obj.corr-user-name = &1 "
      , p-user)
    ).
apply "entry":u to sch-corr-user-name in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame
PROCEDURE proc-view-changes :
define buffer buf_c-dis-grp-rule for ub.c-dis-grp-rule.
define variable v-description as character no-undo .
for each temp-changes:
    delete temp-changes.
END.
if not available X_c-sum-grp-obj then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
define variable v-label-param as character no-undo .
CASE X_c-sum-grp-obj.subject:
  when  {&table_sum-grp-obj} then do:
&scop fields-name-list "grp-code,grp-name,obj-code,obj-type"
    v-label-param =
      "grp-code" + {&delim-par} + "Код группы" + {&delim-par} + "" + {&delim-flf}
    + "grp-name" + {&delim-par} + "Наименование группы" + {&delim-par} + "" + {&delim-flf}
    + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
    + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + ""  .
    run proc-full-temp-changes in this-procedure (
                                                 input  (X_c-sum-grp-obj.action = integer({&hn-create}))
                                                ,input  (X_c-sum-grp-obj.action = integer({&hn-delete}))
                                                ,input  buffer X_c-sum-grp-obj:handle
                                                ,input  {&table_sum-grp-obj}
                                                ,input  {&fields-name-list}
                                                ,input  v-label-param).
  end.
  when {&table_dis-grp-rule} then do:
  &scop fields-name-list "rule-num,pos-type,templ-rl-root,discnt-role,obj-code,obj-type"
    find first buf_c-dis-grp-rule no-lock where
              buf_c-dis-grp-rule.classif-type = {&table_sum-grp-obj}
         and  buf_c-dis-grp-rule.node-code = X_c-sum-grp-obj.grp-code
         and  buf_c-dis-grp-rule.obj-type = X_c-sum-grp-obj.obj-type
         and  buf_c-dis-grp-rule.obj-code = X_c-sum-grp-obj.obj-code
        and  buf_c-dis-grp-rule.corr-user-db-num = X_c-sum-grp-obj.corr-user-db-num
        and  buf_c-dis-grp-rule.chip-num = X_c-sum-grp-obj.chip-num no-error.
   if not available buf_c-dis-grp-rule then do:
     message
     "Неверная ссылка на c-dis-grp-rule в таблице c-sum-grp-obj"
     view-as alert-box error.
   end.
    v-label-param =
      "rule-num" + {&delim-par} + "Номер правила скидки" + {&delim-par} + "" + {&delim-flf}
    + "pos-type" + {&delim-par} + "Место использ." + {&delim-par} + "" + {&delim-flf}
    + "templ-rl-root" + {&delim-par} + "Тип шаблона" + {&delim-par} + "disgrpru-get-disc-label"  + {&delim-flf}
    + "discnt-role" + {&delim-par} + "Тип скидки" + {&delim-par} + "disgrpru-get-disc-role-label"  + {&delim-flf}
    + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
    + "obj-code" + {&delim-par} + "Код" + {&delim-par} + ""
    .
    run proc-full-temp-changes in this-procedure (
                                                input  (X_c-sum-grp-obj.action = integer({&hn-create}))
                                                ,input  (X_c-sum-grp-obj.action = integer({&hn-delete}))
                                                ,input  buffer buf_c-dis-grp-rule:handle
                                                ,input  {&table_dis-grp-rule}
                                                ,input  {&fields-name-list}
                                                ,input  v-label-param).

  end.
END CASE.
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

&scop hn-sum-grp-obj-hist-code p-subject
  RETURN {&hn-sum-grp-obj-hist-name}.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME