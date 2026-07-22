&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER find_c-wth-hist FOR ub.c-wth-hist.
DEFINE BUFFER X_c-wth-hist FOR ub.c-wth-hist.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_curr-sysconf FOR ub.sysconf.
DEFINE BUFFER X_db FOR ub.db.
DEFINE BUFFER X_sysconf FOR ub.sysconf.
DEFINE BUFFER X_wealth FOR ub.wealth.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список полной истории МЦ

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
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo.
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo.
define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/
define input parameter p-mode  as char   no-undo .
/*может быть {&all} {&company} "one":U {&g___object} "subject":U */
define input parameter p-wth-code     like ub.c-wth-hist.wth-code no-undo .
define input parameter p-par-code     like ub.c-wth-hist.par-code no-undo .
define input parameter p-host-code like ub.c-wth-hist.host-code no-undo.
define input parameter p-obj-type like ub.c-wth-hist.obj-type no-undo.
define input parameter p-obj-code like ub.c-wth-hist.obj-code no-undo.
define input parameter p-corr-user-db-num  like ub.c-wth-hist.corr-user-db-num no-undo .
define input parameter p-corr-user-name  like ub.c-wth-hist.corr-user-name no-undo .
define input parameter p-subject  like ub.c-wth-hist.subject no-undo .
/*стартуем с текущей БД обычно*/
define input parameter p-db-num    like ub.c-wth-hist.corr-user-db-num no-undo .
define input parameter p-ser-code  like ub.c-wth-hist.ser-code no-undo .
define input parameter p-serdb-num like ub.c-wth-hist.db-num no-undo .
/*записи в выборке*/
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список полной истории МЦ":U.
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
{ gbl/getcntxt.i def }
define variable filter-label as character no-undo init "Список полной истории МЦ" .
define variable filter-label0 as character no-undo init "Список полной истории МЦ" .
define variable filter-point as character no-undo init "cwthhist" .
define variable filter-point0 as character no-undo init "cwthhist" .
define variable sort-column-name as character no-undo .
define variable print-option as character no-undo.
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-find as logical no-undo.
define variable v-wth-name like ub.wealth.wth-name no-undo.
define variable v-start-date-chr as character no-undo .
define variable v-end-date-chr as character no-undo .
define variable v-subject-chr as character no-undo .
define variable v-wth-par-name     as character no-undo .
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
&Scoped-define BROWSE-NAME BR-changes

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-changes X_c-wth-hist

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define OPEN-QUERY-BR-changes MESSAGE '9999' VIEW-AS ALERT-BOX. OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE br-wth-hist                                   */
&Scoped-define FIELDS-IN-QUERY-br-wth-hist mark-string(recid(X_c-wth-hist), v-rid-list) X_c-wth-hist.wth-code X_c-wth-hist.corr-date string(X_c-wth-hist.corr-time, "HH:MM:SS":U) usrfulnf(X_c-wth-hist.corr-user-name) get-action(X_c-wth-hist.action) X_c-wth-hist.corr-user-db-num X_c-wth-hist.is-news get-source-type(X_c-wth-hist.source-type) X_c-wth-hist.source-ref if v-find then get-wealth(X_c-wth-hist.wth-code, X_c-wth-hist.par-code, output v-wth-par-name) else "":U v-wth-par-name get-subject(X_c-wth-hist.subject) X_c-wth-hist.host-code X_c-wth-hist.obj-type + string(X_c-wth-hist.obj-code) /* substitute('&1-&2',X_c-wth-hist.ser-code,X_c-wth-hist.db-num) */
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-wth-hist X_c-wth-hist.corr-date
&Scoped-define ENABLED-TABLES-IN-QUERY-br-wth-hist X_c-wth-hist
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-wth-hist X_c-wth-hist
&Scoped-define SELF-NAME br-wth-hist
&Scoped-define QUERY-STRING-br-wth-hist FOR EACH X_c-wth-hist NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-wth-hist OPEN QUERY {&SELF-NAME} FOR EACH X_c-wth-hist NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-wth-hist X_c-wth-hist
&Scoped-define FIRST-TABLE-IN-QUERY-br-wth-hist X_c-wth-hist


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel v-corr-user-db-num ~
b-wth-obj B-print B-sch B-Help b-lkp br-wth-hist sch-db-num sch-corr-date ~
sch-wth-code sch-corr-user-name BR-changes mark-num
&Scoped-Define DISPLAYED-OBJECTS v-corr-user-db-num sch-db-num ~
sch-corr-date sch-wth-code sch-corr-user-name mark-num

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-source-type Dialog-Frame
FUNCTION get-source-type RETURNS CHARACTER
  ( p-source-type as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-subject Dialog-Frame
FUNCTION get-subject RETURNS CHARACTER
  ( p-subject as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-wealth Dialog-Frame
FUNCTION get-wealth RETURNS CHARACTER
  ( p-wth-code as integer, p-par-code as integer, output p-wth-par-name as character)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&МЦ"
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

DEFINE BUTTON b-wth-obj
     LABEL "&Остатки"
     SIZE 10 BY 1.

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

DEFINE VARIABLE sch-db-num AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     LABEL "БД"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-wth-code AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     LABEL "коду МЦ"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE v-corr-user-db-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "по БД"
     VIEW-AS FILL-IN
     SIZE 6.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.

DEFINE QUERY br-wth-hist FOR
      X_c-wth-hist SCROLLING.
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

DEFINE BROWSE br-wth-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-wth-hist Dialog-Frame _FREEFORM
  QUERY br-wth-hist NO-LOCK DISPLAY
      mark-string(recid(X_c-wth-hist), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_c-wth-hist.wth-code FORMAT "999999999":U
      X_c-wth-hist.corr-date FORMAT "99/99/9999":U
      string(X_c-wth-hist.corr-time, "HH:MM:SS":U) COLUMN-LABEL "Время изм." FORMAT "X(8)":U
      usrfulnf(X_c-wth-hist.corr-user-name) FORMAT "X(18)":U
      get-action(X_c-wth-hist.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
      X_c-wth-hist.corr-user-db-num FORMAT ">>>>9":U
      X_c-wth-hist.is-news FORMAT "+/":U
      get-source-type(X_c-wth-hist.source-type) COLUMN-LABEL "Источн.!измен."
      X_c-wth-hist.source-ref FORMAT "X(14)":U
      if v-find then get-wealth(X_c-wth-hist.wth-code, X_c-wth-hist.par-code, output v-wth-par-name) else "":U COLUMN-LABEL "Назв. МЦ" FORMAT "X(25)":U
      v-wth-par-name COLUMN-LABEL "Номинал" FORMAT "X(14)":U
      get-subject(X_c-wth-hist.subject) COLUMN-LABEL "Предмет изменений" FORMAT "X(15)":U
      X_c-wth-hist.host-code COLUMN-LABEL "Фирма" FORMAT "99999":U
      X_c-wth-hist.obj-type + string(X_c-wth-hist.obj-code) COLUMN-LABEL "Объект" FORMAT "X(8)":U
/*       substitute('&1-&2',X_c-wth-hist.ser-code,X_c-wth-hist.db-num) column-label 'Код маски' */
  ENABLE
      X_c-wth-hist.corr-date
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 11.46.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     v-corr-user-db-num AT ROW 1 COL 36 COLON-ALIGNED
     b-wth-obj AT ROW 1 COL 55
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     b-lkp AT ROW 1.04 COL 45
     br-wth-hist AT ROW 2 COL 1
     sch-db-num AT ROW 13.63 COL 60.13 COLON-ALIGNED
     sch-corr-date AT ROW 13.63 COL 85.75 COLON-ALIGNED
     sch-wth-code AT ROW 13.67 COL 48.13 COLON-ALIGNED
     sch-corr-user-name AT ROW 13.71 COL 22.5 COLON-ALIGNED
     BR-changes AT ROW 14.79 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 8.38 BY 1 AT ROW 13.63 COL 1.38
          FGCOLOR 4
     SPACE(89.48) SKIP(7.44)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Полная история по МЦ"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_c-wth-hist B "?" NO-UNDO ub c-wth-hist
      TABLE: X_c-wth-hist B "?" ? ub c-wth-hist
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_curr-sysconf B "?" ? ub sysconf
      TABLE: X_db B "?" ? ub db
      TABLE: X_sysconf B "?" ? ub sysconf
      TABLE: X_wealth B "?" ? ub wealth
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-wth-hist b-lkp Dialog-Frame */
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
MESSAGE '9999' VIEW-AS ALERT-BOX.
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-wth-hist
/* Query rebuild information for BROWSE br-wth-hist
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-wth-hist NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-wth-hist */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Полная история по МЦ */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Полная история по МЦ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* МЦ */
DO:
  define variable rep-rec as recid no-undo .
  DEFINE BUFFER buf_wealth FOR ub.wealth.
  IF NOT AVAILABLE X_c-wth-hist THEN RETURN NO-APPLY.
  FIND FIRST buf_wealth NO-LOCK WHERE
         buf_wealth.wth-code = X_c-wth-hist.wth-code NO-ERROR.
  if available buf_wealth then do:
    rep-rec = recid (buf_wealth).

    run ref/wth-form.w (
                     input parparentproc
                   , input buf_wealth.wth-code
                   , input {&lookup}
                   , output rep-rec) NO-ERROR.
     apply "entry" to br-wth-hist in frame {&frame-name}.
     return no-apply.
  END.
  ELSE DO:
     MESSAGE
     substitute("Неизвестная МЦ с кодом &1", X_c-wth-hist.wth-code)
     VIEW-AS ALERT-BOX.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available X_c-wth-hist then do:
    { gbl/markstrn.i X_c-wth-hist v-rid-list }
    loc#log = br-wth-hist:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-wth-hist:select-next-row ().
        apply "VALUE-CHANGED" to br-wth-hist in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-wth-hist in frame {&frame-name}.
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
  if ( available X_c-wth-hist ) then do:
    if ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_c-wth-hist ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-wth-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-wth-obj Dialog-Frame
ON CHOOSE OF b-wth-obj IN FRAME Dialog-Frame /* Остатки */
DO:
define variable v-rid-list as character no-undo .
  run ref/cwthobj.w (
     INPUT parparentproc
    ,INPUT p-obj-type
    ,INPUT p-obj-code
    ,input '':U /*bttns*/
    ,INPUT 'ONE':U
    ,input (if not available X_c-wth-hist
            or X_c-wth-hist.obj-type = ''
            then v-cntxt-obj-type
            else X_c-wth-hist.obj-type)
    ,input (if not available X_c-wth-hist
            or X_c-wth-hist.obj-code = 0
            then v-cntxt-obj-code
            else  X_c-wth-hist.obj-code)
    ,INPUT X_c-wth-hist.wth-code
    ,INPUT-OUTPUT v-rid-list
    ) no-error .
  if error-status :error
  then do:
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-wth-hist
&Scoped-define SELF-NAME br-wth-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-wth-hist Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-wth-hist IN FRAME Dialog-Frame
DO:
     run proc-br-wth-hist in this-procedure no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-wth-hist Dialog-Frame
ON RETURN OF br-wth-hist IN FRAME Dialog-Frame
DO:
    run proc-br-wth-hist in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-wth-hist Dialog-Frame
ON VALUE-CHANGED OF br-wth-hist IN FRAME Dialog-Frame
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


&Scoped-define SELF-NAME sch-db-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-db-num Dialog-Frame
ON CTRL-J OF sch-db-num IN FRAME Dialog-Frame /* БД */
DO:
  run proc-find-db-num in this-procedure(yes, input frame {&frame-name} sch-db-num) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-db-num Dialog-Frame
ON RETURN OF sch-db-num IN FRAME Dialog-Frame /* БД */
DO:
  run proc-find-db-num in this-procedure(no, input frame {&frame-name} sch-db-num) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-wth-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-wth-code Dialog-Frame
ON CTRL-J OF sch-wth-code IN FRAME Dialog-Frame /* коду МЦ */
DO:
  run proc-find-wth-code in this-procedure(yes, input frame {&frame-name} sch-wth-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-wth-code Dialog-Frame
ON RETURN OF sch-wth-code IN FRAME Dialog-Frame /* коду МЦ */
DO:
  run proc-find-wth-code in this-procedure(no, input frame {&frame-name} sch-wth-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-corr-user-db-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-corr-user-db-num Dialog-Frame
ON RETURN OF v-corr-user-db-num IN FRAME Dialog-Frame /* по БД */
DO:
  assign
  v-corr-user-db-num
  .
  RUn OpenBR in this-procedure ( input yes, input no, input '':U, input v-corr-user-db-num).
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

{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-wth-hist" }
{ gbl/brwrefre.i " v-doc-rec = recid(X_c-wth-hist).  RUn OpenBR in this-procedure ( input yes, input no, input '':U, input v-corr-user-db-num).  REPOSITION br-wth-hist to recid v-doc-rec No-ERROR. ~
              apply 'value-changed' to br-wth-hist.  " }

{ gbl/setfltnm.i }
{ gbl/ed_date.i sch-corr-date}

{ gbl/srt-clmd.i
  &browse-name    = "br-wth-hist"
  &frame-name     = "{&frame-name}"
  &table-name     = "X_c-wth-hist"
  &sort-clmn_1    = "X_c-wth-hist.wth-code"
  &sort-clmn_2    = "X_c-wth-hist.corr-date"
  &sort-clmn_3    = "X_c-wth-hist.corr-user-db-num"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input no, input v-corr-user-db-num)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input no, input v-corr-user-db-num)."
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
 { gbl/getcntxt.i get }
   if p-mode <> {&all}
 and p-mode <> {&company}
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
if p-curr-host-code <> ? then do:
  find first X_curr_sysconf no-lock where
                  X_curr_sysconf.host-code = p-curr-host-code no-error.
  if not available X_curr_sysconf then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-curr-host-code"
    p-curr-host-code
    view-as alert-box ERROR.
    return.
  end.
end.
 if p-mode = {&company} then do:
  find first X_clients no-lock where
                X_clients.obj-type = {&cmp}
            and X_clients.obj-code = p-host-code no-error.
    if not available X_clients then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-host-code"
        p-curr-host-code
        view-as alert-box ERROR.
        return.
    end.
    find first X_sysconf no-lock where
                    X_sysconf.host-code = p-host-code no-error.
    if not available X_sysconf then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-host-code"
      p-host-code
      view-as alert-box ERROR.
      return.
    end.
  end.
 if p-mode = {&g___object} then do:
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
 end.
 if p-mode = "one":U then do:
  find first X_wealth no-lock where
                X_wealth.wth-code = p-wth-code no-error.
    if not available X_wealth then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-wth-code" p-wth-code
        view-as alert-box ERROR.
        return.
    end.
  end.
 if p-mode = "db-num":U then do:
  find first X_db no-lock where
                X_db.db-num = p-corr-user-db-num no-error.
    if not available X_db then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-corr-user-db-num" p-corr-user-db-num
        view-as alert-box ERROR.
        return.
    end.
  end.
  v-rid-list = p-rid-list.
  if v-rid-list <> "" then do:
      FIND FIRST find_c-wth-hist No-LOCK where
                 recid(find_c-wth-hist) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_c-wth-hist then do:
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
    else do:
    assign
    v-wth-name = get-wealth(p-wth-code, p-par-code, output v-wth-par-name)
    .
  end.

  RUN MyEnable.

  RUn OpenBR in this-procedure ( input yes, input no, input '':U, input v-corr-user-db-num).

  HIDE mark-num in frame {&frame-name} .
  if v-rid-list <> "":U then
  REPOSITION br-wth-hist to recid integer(entry(1, v-rid-list)) No-ERROR.
  { gbl/mv-clmn.i
    &browse-name = "br-wth-hist"
    &frame-name = "{&frame-name}"
    &ext-col = 15
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11,12,13,14,15'"
    &prev-order-column-condition_1 = " p-mode = {&all} "
    &prev-order-column_2 = "'1,3,4,5,6,7,8,9,10,14,15,2,11,12,13'"
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
  DISPLAY v-corr-user-db-num sch-db-num sch-corr-date sch-wth-code
          sch-corr-user-name mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel v-corr-user-db-num b-wth-obj B-print B-sch B-Help
         b-lkp br-wth-hist sch-db-num sch-corr-date sch-wth-code
         sch-corr-user-name BR-changes mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
assign
  br-wth-hist:num-locked-columns in frame {&frame-name} = 1
  X_c-wth-hist.corr-date:read-only in browse br-wth-hist = yes
  v-corr-user-db-num = v-db-num
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
  v-db-num @ v-corr-user-db-num
  sch-db-num
  sch-corr-date
  sch-wth-code
  sch-corr-user-name
  mark-num
  WITH FRAME {&FRAME-NAME}.
  ENABLE
  v-corr-user-db-num
  b-quit
  B-mark when lookup("b-mark":U, bttns) > 0
  b-sel when lookup("b-sel":U, bttns) > 0
  b-lkp
  B-sch
  b-wth-obj
  B-Print
  B-Help
  br-wth-hist
  sch-corr-date
  sch-wth-code when p-mode = {&all}
  sch-db-num   when p-mode = {&all}
  sch-corr-user-name
  BR-changes mark-num
  WITH FRAME {&FRAME-NAME}.
  VIEW FRAME {&FRAME-NAME}.
  HIDE sch-corr-user-name IN FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define input  parameter p-db-num like ub.c-wth-hist.corr-user-db-num no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Список полной истории товара" + {&space-char}.
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

&scop flt-open-open-query OPEN QUERY br-wth-hist FOR EACH X_c-wth-hist

&scop flt-open-dyn_open-query FOR EACH X_c-wth-hist

&scop flt-open-query-handle query br-wth-hist:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-wth-hist

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_c-wth-hist

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .
CASE p-db-num :
  when ? then do:

    CASE p-mode :
      WHEN {&all}        THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1", filter-label0)
        .
        { gbl/fltopend.i
            &where-cond = " TRUE "
            &use-ind    = " use-index idate  "
            &by         = "  " }
      END.
      WHEN {&company} THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Одна МЦ, одна фирма", filter-label0)
        .
        if p-open-query then do:
          ASSIGN
          frame {&frame-name}:TITLE = title0 + substitute(" МЦ с кодом &1: &2 &3 &4&5 Фирма: (&6) &7",
                                                            p-wth-code, v-wth-name, v-wth-par-name, p-host-code, X_clients.obj-name).
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-wth-hist.wth-code  = p-wth-code  and  (X_c-wth-hist.host-code  = p-host-code  or X_c-wth-hist.host-code = 0) ~
                        "
          &dyn_where-cond = " substitute(' X_c-wth-hist.wth-code = &1  and  (X_c-wth-hist.host-code  = &2  or X_c-wth-hist.host-code = 0) ' ~
                             ,  p-wth-code, p-host-code) "

          &use-ind    = " use-index idate  "
          &by         = "  " }
      END.
      WHEN {&g___object} THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Одна МЦ, один объект", filter-label0)
        .
        if p-open-query then do:
          ASSIGN
          frame {&frame-name}:TITLE = title0 + substitute(" МЦ с кодом &1: &2 &3 &4&5 Объект: &6&7",
                                                            p-wth-code, v-wth-name, v-wth-par-name, p-obj-type, p-obj-code).
        end.

        { gbl/fltopend.i
          &where-cond = " ~
          X_c-wth-hist.wth-code  = p-wth-code and ( X_c-wth-hist.host-code = 0 or (X_c-wth-hist.obj-type = p-obj-type and X_c-wth-hist.obj-code = p-obj-code))   ~
                        "
          &dyn_where-cond = " substitute('X_c-wth-hist.wth-code  = &1 and ( X_c-wth-hist.host-code = 0 or (X_c-wth-hist.obj-type = &2&3&2 and X_c-wth-hist.obj-code = &4))'   ~
                            , p-wth-code  ~
                            , ~{&double-quote~} ~
                            , p-obj-type ~
                            ,p-obj-code) "

          &use-ind    = " use-index idate "
          &by         = "  " }
      END.
      WHEN "one":u THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Одна МЦ", filter-label0)
        .
        if p-open-query then do:
          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" МЦ с кодом &1: &2 &3 &4&5",
                                                                                  p-wth-code, v-wth-name, v-wth-par-name ).
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-wth-hist.wth-code  = p-wth-code   ~
                        "
          &dyn_where-cond = " substitute('X_c-wth-hist.wth-code  = &1', p-wth-code) "

          &use-ind    = " use-index idate "
          &by         = "  " }
      END.
      WHEN "subject":u THEN DO:
       &scop hn-wth-hist-code p-subject
        assign
        filter-point = filter-point0 + p-mode
        v-subject-chr = {&hn-wth-hist-name}
        filter-label = substitute("&1 Одна МЦ, предмет изменений", filter-label0)
        .
        if p-open-query then do:

          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" МЦ с кодом &1: &2 &3 &4&5, Предмет изменения &6",
                                                                                  p-wth-code, v-wth-name, v-wth-par-name, v-subject-chr )

                                                                                  .
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-wth-hist.wth-code  = p-wth-code  and X_c-wth-hist.subject = p-subject ~
                        "
          &dyn_where-cond = " substitute('X_c-wth-hist.wth-code  = &1  and X_c-wth-hist.subject = &2&3&2 ', p-wth-code, ~{&double-quote~}, p-subject)  "

          &use-ind    = " use-index idate "
          &by         = "  " }
      END.
    END CASE.


  end.
  otherwise do:
      CASE p-mode :
      WHEN {&all}        THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1", filter-label0)
        .
      { gbl/fltopend.i
          &where-cond = " TRUE "
          &use-ind    = "  use-index ishow "
          &by         = "  " }
      END.
      WHEN {&company} THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Одна МЦ, одна фирма", filter-label0)
        .
        if p-open-query then do:
          ASSIGN
          frame {&frame-name}:TITLE = title0 + substitute(" МЦ с кодом &1: &2 &3 &4&5 Фирма: (&6) &7 БД: &8",
                                                            p-wth-code, v-wth-name, v-wth-par-name, p-host-code, X_clients.obj-name, p-db-num)
          .
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-wth-hist.corr-user-db-num = p-db-num ANd X_c-wth-hist.wth-code  = p-wth-code  and  (X_c-wth-hist.host-code  = p-host-code  or X_c-wth-hist.host-code = 0) ~
                        "
          &where-cond = " substitute('X_c-wth-hist.corr-user-db-num = &1 ANd X_c-wth-hist.wth-code  = &2  and  (X_c-wth-hist.host-code  = &3  or X_c-wth-hist.host-code = 0) ~
                         , p-db-num ~
                         ,p-wth-code ~
                         ,p-host-code )"

          &use-ind    = " use-index ishow "
          &by         = "  " }
      END.
      WHEN {&g___object} THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Одна МЦ, один объект", filter-label0)
        .
        if p-open-query then do:
          ASSIGN
          frame {&frame-name}:TITLE = title0 + substitute(" МЦ с кодом &1: &2 &3 &4&5 Объект: &6&7 БД: &8",
                                                            p-wth-code, v-wth-name, v-wth-par-name, p-obj-type, p-obj-code, p-db-num)
          .
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-wth-hist.corr-user-db-num = p-db-num ANd X_c-wth-hist.wth-code  = p-wth-code and ( X_c-wth-hist.host-code = 0 or (X_c-wth-hist.obj-type = p-obj-type and X_c-wth-hist.obj-code = p-obj-code))   ~
                        "
          &dyn_where-cond = " substitute(' X_c-wth-hist.corr-user-db-num = &1 ANd X_c-wth-hist.wth-code  = &2 and ( X_c-wth-hist.host-code = 0 or (X_c-wth-hist.obj-type = &3&4&3 and X_c-wth-hist.obj-code = &5))'   ~
                           ,p-db-num ~
                           ,p-wth-code ~
                           , ~{&double-quote~} ~
                           ,p-obj-type ~
                           ,p-obj-code) "

          &use-ind    = " use-index ishow "
          &by         = "  " }
      END.
      WHEN "one":u THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Одна МЦ", filter-label0)
        .
        if p-open-query then do:

          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" МЦ с кодом &1: &2 &3 &4&5 БД: &6",
                                                                p-wth-code, v-wth-name, v-wth-par-name, p-db-num )
          .
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-wth-hist.corr-user-db-num = p-db-num ANd   X_c-wth-hist.wth-code  = p-wth-code   ~
                        "
          &dyn_where-cond = " substitute(' X_c-wth-hist.corr-user-db-num = &1 ANd   X_c-wth-hist.wth-code  = &2  ', p-db-num, p-wth-code ) "

          &use-ind    = " use-index ishow "
          &by         = "  " }

      END.
      WHEN "subject":u THEN DO:
      &scop hn-wth-hist-code p-subject
        assign
        filter-point = filter-point0 + p-mode
        v-subject-chr = {&hn-wth-hist-name}
        filter-label = substitute("&1 Одна МЦ, предмет изменений", filter-label0)
        .
        if p-open-query then do:
          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" МЦ с кодом &1: &2 &3 &4&5, Предмет изменения &6 БД: &7",
                                                                p-wth-code, v-wth-name, v-wth-par-name, v-subject-chr, p-db-num )
          .
        end.
        { gbl/fltopend.i
          &where-cond = " X_c-wth-hist.corr-user-db-num = p-db-num ANd   X_c-wth-hist.wth-code  = p-wth-code  and X_c-wth-hist.subject = p-subject ~
                          and (if p-subject = {&table_wth-ser} then ( X_c-wth-hist.ser-code = p-ser-code and X_c-wth-hist.db-num = p-serdb-num) else true) ~
                          and (p-subject <> {&table_wth-par} or  X_c-wth-hist.par-code = p-par-code ) ~
                        "
          &dyn_where-cond = " substitute('X_c-wth-hist.corr-user-db-num = &1 ANd   X_c-wth-hist.wth-code  = &2  and X_c-wth-hist.subject = &3&4&3 ~
                          and (if &3&4&3 = &3&5&3 then ( X_c-wth-hist.ser-code = &6 and X_c-wth-hist.db-num = &7) else true) ~
                          and (&3&4&3 <> &3&8&3 or  X_c-wth-hist.par-code = &9) '~
                          ,p-db-num ~
                          ,p-wth-code ~
                          , ~{&double-quote~} ~
                          , p-subject ~
                          , ~{&table_wth-ser~} ~
                          , p-ser-code      ~
                          , p-serdb-num     ~
                          ,~{&table_wth-par~} ~
                          , p-par-code ) "

          &use-ind    = " use-index ishow "
          &by         = "  " }
      END.
    END CASE.
  end. /*otherwise <> ?*/
END CASE.

if not p-open-query  and v-doc-rec <> ? then
REPOSITION br-wth-hist to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-wth-hist:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-wth-hist in frame {&frame-name}.
APPLY "ENTRY" TO br-wth-hist.


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
define variable v-subject-chr as character no-undo .
define variable v-upd-time as character no-undo .
define variable v-obj as character no-undo .
define variable v-action-chr as character no-undo .
define variable v-source-type as character no-undo .
DEFINE VARIABLE v-for-user-name AS CHARACTER NO-UNDO.
DEFINE FRAME HistoryList
X_c-wth-hist.wth-code
v-action-chr FORMAT "X(10)"
v-wth-name COLUMN-LABEL "Назв. товара" FORMAT "X(20)"
v-wth-par-name COLUMN-LABEL "Номинал" FORMAT "X(14)"
v-prod COLUMN-LABEL "Пр-ль" FORMAT "X(12)"
v-subject-chr COLUMN-LABEL "Предмет изменений" FORMAT "X(20)"
X_c-wth-hist.is-news COLUMn-LABEL "СПН" FORMAT "+/ "
v-source-type COLUMn-LABEL "Источн.!измен"
X_c-wth-hist.source-ref COLUMn-LABEL "№"
X_c-wth-hist.corr-date
v-upd-time COLUMN-LABEL "Время изм." FORMAT "X(8)"
v-for-user-name COLUMN-LABEL "Изменил" FORMAT "X(15)"
X_c-wth-hist.corr-user-db-num
X_c-wth-hist.host-code COLUMN-LABEL "Фирма"
v-obj COLUMN-LABEL "Объект" FORMAT "X(8)"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 195).
date_string = cur-time-print() .
assign
v-doc-rec = recid( X_c-wth-hist ).
DO WHILE available X_c-wth-hist :
      GET prev br-wth-hist.
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
  GET next br-wth-hist.
    DO WHILE available X_c-wth-hist :
      Display STREAM PrnLibStream
      X_c-wth-hist.wth-code
      get-action(X_c-wth-hist.action) @ v-action-chr
      (if v-find then get-wealth(X_c-wth-hist.wth-code, X_c-wth-hist.par-code, output v-wth-par-name) else "":U )
      @ v-wth-name
      v-wth-par-name
      get-subject(X_c-wth-hist.subject) @ v-subject-chr
      X_c-wth-hist.is-news
      get-source-type(X_c-wth-hist.source-type) @ v-source-type
      X_c-wth-hist.source-ref
      X_c-wth-hist.corr-date
      string(X_c-wth-hist.corr-time, "HH:MM:SS":U) @ v-upd-time
      usrfulnf(X_c-wth-hist.corr-user-name) @ v-for-user-name
      X_c-wth-hist.corr-user-db-num
      X_c-wth-hist.host-code
      X_c-wth-hist.obj-type + string(X_c-wth-hist.obj-code) @ v-obj
      with FRAME HistoryList .
  DOWN STREAM PrnLibStream 1 with FRAME HistoryList  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-wth-hist.
END.
UNDERLINE  STREAM PrnLibStream
X_c-wth-hist.wth-code
v-action-chr
v-wth-name
v-wth-par-name
v-subject-chr
X_c-wth-hist.is-news
v-source-type
X_c-wth-hist.source-ref
X_c-wth-hist.corr-date
v-upd-time
v-for-user-name
X_c-wth-hist.corr-user-db-num
X_c-wth-hist.host-code
v-obj
with FRAME HistoryList .
DISPLAY STREAM PrnLibStream
"ИТОГО"  @ X_c-wth-hist.wth-code
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
reposition br-wth-hist to recid v-doc-rec no-error.
apply "entry" to br-wth-hist in frame {&frame-name}.

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
  tbl = 'c-wth-hist'
  join-tbl = 'X_c-wth-hist'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('wth-code', 'Код товара', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время корр.', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('subject', 'Предмет изменения', 'gds-hist-subject',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('action', 'Действие', 'hist-action',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('source-type', 'Источник_измен-я', 'hist-source-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('source-ref', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                   , INPUT (filter-point + {&delim-par} + filter-label)
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U, input v-corr-user-db-num).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-wth-hist Dialog-Frame
PROCEDURE proc-br-wth-hist :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ ref/brwsretr.i b-lkp }
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
0 @ sch-wth-code
0 @ sch-db-num
"":U @ sch-corr-user-name
with frame {&frame-name}.
assign
v-date-chr = string(day(p-date)) + {&slash-char} +
                 string(month(p-date)) + {&slash-char} +
                 string(year(p-date)).

       run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input true  /* p-find-next  */
        ,input substitute("and X_c-wth-hist.corr-date = &1 "
          , v-date-chr)
        ,input v-corr-user-db-num
        ).
      apply "entry":u to sch-corr-date in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-db-num Dialog-Frame
PROCEDURE proc-find-db-num :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-db-num like ub.c-wth-hist.corr-user-db-num no-undo.
define variable v-db-num as character no-undo.
assign
sch-corr-date = ?
.
display
"":U @ sch-corr-user-name
0 @ sch-wth-code
sch-corr-date
with frame {&frame-name}.
assign
v-db-num = string(p-db-num).
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-wth-hist.corr-user-db-num = &1 "
      , v-db-num)
    ,input v-corr-user-db-num
    ).
apply "entry":u to sch-db-num in frame {&frame-name} .


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
define input parameter p-user like ub.c-wth-hist.corr-user-name no-undo.
assign
sch-corr-date = ?.
display
0 @ sch-db-num
sch-corr-date
0 @ sch-wth-code
with frame {&frame-name}.
p-user = {&double-quote} + p-user + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-wth-hist.corr-user-name = &1 "
      , p-user)
    ,input v-corr-user-db-num
    ).
apply "entry":u to sch-corr-user-name in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-wth-code Dialog-Frame
PROCEDURE proc-find-wth-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-wth-code like ub.c-wth-hist.wth-code no-undo.
define variable v-wth-code as character no-undo.
assign
sch-corr-date = ?.
display
"":U @ sch-corr-user-name
0 @ sch-db-num
sch-corr-date
with frame {&frame-name}.

assign
v-wth-code = string(p-wth-code).
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-wth-hist.wth-code = &1 "
      , v-wth-code)
    ,input v-corr-user-db-num
    ).
apply "entry":u to sch-wth-code in frame {&frame-name} .



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
FOR each temp-changes:
    delete temp-changes.
END.
if not available X_c-wth-hist then do:
  Open QUery br-changes for each temp-changes.
  return.
end.

run ref/cwthhisv.p (
                   input X_c-wth-hist.wth-code
                  ,input X_c-wth-hist.par-code
                  ,input X_c-wth-hist.chip-num
                  ,input X_c-wth-hist.corr-user-db-num
                  ,input X_c-wth-hist.host-code
                  ,input X_c-wth-hist.obj-type
                  ,input X_c-wth-hist.obj-code
                  ,input X_c-wth-hist.subject
                  ,input X_c-wth-hist.action
                  ,input no /*p-silent*/
                  ,input X_c-wth-hist.ser-code
                  ,input X_c-wth-hist.db-num
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-source-type Dialog-Frame
FUNCTION get-source-type RETURNS CHARACTER
  ( p-source-type as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
&scop hn-source-code p-source-type
define variable v-dop as character no-undo .
assign
v-dop =  {&hn-source-name} no-error
.
  RETURN v-dop .   /* Function return value. */



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
&scop hn-wth-hist-code p-subject
  RETURN {&hn-wth-hist-name}.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-wealth Dialog-Frame
FUNCTION get-wealth RETURNS CHARACTER
  ( p-wth-code as integer, p-par-code as integer, output p-wth-par-name as character) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_wealth for ub.wealth.
define buffer buf_wth-par for ub.wth-par.
find first buf_wealth no-lock where buf_wealth.wth-code = p-wth-code no-error.
if not available buf_wealth then do:
    return "!!! Неизвестная МЦ!!!".
end.
if p-par-code <> ?
and p-par-code <> 0 then do:
  find first buf_wth-par no-lock where
            buf_wth-par.wth-code = p-wth-code
      AND   buf_wth-par.par-code = p-par-code no-error .
  if available buf_wth-par then do:
    assign
    p-wth-par-name = substitute("&1 &2", buf_wth-par.par-unit, buf_wth-par.par-val)
    .

  end.
end.


  RETURN buf_wealth.wth-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME