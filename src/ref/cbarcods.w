&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER find_c-gds-hist FOR ub.c-gds-hist.
DEFINE BUFFER X_c-bar-code FOR ub.c-bar-code.
DEFINE BUFFER X_c-gds-hist FOR ub.c-gds-hist.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_curr-sysconf FOR ub.sysconf.
DEFINE BUFFER X_db FOR ub.db.
DEFINE BUFFER X_goods FOR ub.goods.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории бар-кода

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
/*может быть "one":U */
define input parameter p-gds-code     like ub.c-gds-hist.gds-code no-undo .
define input parameter p-b-code     like ub.c-gds-hist.b-code   no-undo .
define input parameter p-corr-user-db-num  like ub.c-gds-hist.corr-user-db-num no-undo .
define input parameter p-corr-user-name  like ub.c-gds-hist.corr-user-name no-undo .
/*стартуем с текущей БД обычно*/
define input parameter p-db-num  like ub.c-gds-hist.corr-user-db-num no-undo .


/*записи в выборке*/
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список истории бар-кода":U.
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
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
define variable filter-label as character no-undo init "Список истории бар-кода" .
define variable filter-label0 as character no-undo init "Список истории бар-кода" .
define variable filter-point as character no-undo init "cbarcods" .
define variable filter-point0 as character no-undo init "cbarcods" .

define variable sort-column-name as character no-undo .
define variable print-option as character no-undo.
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-find as logical no-undo.
define variable v-gds-name like ub.goods.gds-name no-undo.
define variable v-artic like ub.goods.artic no-undo.
define variable v-prod-type like ub.goods.prod-type no-undo.
define variable v-prod-code like ub.goods.prod-code no-undo.
define variable v-start-date-chr as character no-undo .
define variable v-end-date-chr as character no-undo .
define variable v-subject-chr as character no-undo .
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.

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
&Scoped-define INTERNAL-TABLES temp-changes X_c-bar-code X_c-gds-hist

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE BR-gds-hist                                   */
&Scoped-define FIELDS-IN-QUERY-BR-gds-hist mark-string(recid(X_c-gds-hist), v-rid-list) X_c-gds-hist.gds-code get-subject(X_c-gds-hist.subject) X_c-gds-hist.corr-date usrfulnf(X_c-gds-hist.corr-user-name) string(X_c-gds-hist.corr-time, "HH:MM:SS":U) X_c-gds-hist.corr-user-db-num X_c-gds-hist.is-news get-action(X_c-gds-hist.action) X_c-gds-hist.source-ref get-source-type(X_c-gds-hist.source-type)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-gds-hist X_c-gds-hist.corr-date
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-gds-hist X_c-gds-hist
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-gds-hist X_c-gds-hist
&Scoped-define SELF-NAME BR-gds-hist
&Scoped-define QUERY-STRING-BR-gds-hist FOR EACH X_c-bar-code NO-LOCK, ~
             EACH X_c-gds-hist OF X_c-bar-code NO-LOCK
&Scoped-define OPEN-QUERY-BR-gds-hist OPEN QUERY {&SELF-NAME} FOR EACH X_c-bar-code NO-LOCK, ~
             EACH X_c-gds-hist OF X_c-bar-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-gds-hist X_c-bar-code X_c-gds-hist
&Scoped-define FIRST-TABLE-IN-QUERY-BR-gds-hist X_c-bar-code
&Scoped-define SECOND-TABLE-IN-QUERY-BR-gds-hist X_c-gds-hist


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel v-corr-user-db-num ~
B-print B-Help B-lookup BR-gds-hist BR-changes mark-num
&Scoped-Define DISPLAYED-OBJECTS v-corr-user-db-num mark-num

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-good Dialog-Frame
FUNCTION get-good RETURNS CHARACTER
  ( p-gds-code as integer, output p-artic as character, output p-prod-type as character, output p-prod-code as integer )  FORWARD.

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


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lookup
     LABEL "&Товар"
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

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-corr-user-db-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "по БД"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.

DEFINE QUERY BR-gds-hist FOR
      X_c-bar-code,
      X_c-gds-hist SCROLLING.
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

DEFINE BROWSE BR-gds-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-gds-hist Dialog-Frame _FREEFORM
  QUERY BR-gds-hist NO-LOCK DISPLAY
      mark-string(recid(X_c-gds-hist), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_c-gds-hist.gds-code FORMAT "999999999":U
      get-subject(X_c-gds-hist.subject) COLUMN-LABEL "Предмет изменений" FORMAT "X(15)":U
      X_c-gds-hist.corr-date FORMAT "99/99/9999":U
      usrfulnf(X_c-gds-hist.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
      string(X_c-gds-hist.corr-time, "HH:MM:SS":U) COLUMN-LABEL "Время изм." FORMAT "X(8)":U
      X_c-gds-hist.corr-user-db-num FORMAT ">>>>9":U
      X_c-gds-hist.is-news FORMAT "+/":U
      get-action(X_c-gds-hist.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
      X_c-gds-hist.source-ref FORMAT "X(14)":U
      get-source-type(X_c-gds-hist.source-type) COLUMN-LABEL "Источн.!измен."
  ENABLE
      X_c-gds-hist.corr-date
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 11.46.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     v-corr-user-db-num AT ROW 1 COL 37 COLON-ALIGNED
     B-print AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     B-lookup AT ROW 1.04 COL 51
     BR-gds-hist AT ROW 2 COL 1
     BR-changes AT ROW 14.79 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(78.99) SKIP(20.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Полная истоия по товару"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_c-gds-hist B "?" NO-UNDO ub c-gds-hist
      TABLE: X_c-bar-code B "?" ? ub c-bar-code
      TABLE: X_c-gds-hist B "?" ? ub c-gds-hist
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_curr-sysconf B "?" ? ub sysconf
      TABLE: X_db B "?" ? ub db
      TABLE: X_goods B "?" ? ub goods
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-gds-hist B-lookup Dialog-Frame */
/* BROWSE-TAB BR-changes BR-gds-hist Dialog-Frame */
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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-gds-hist
/* Query rebuild information for BROWSE BR-gds-hist
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-bar-code NO-LOCK,
      EACH X_c-gds-hist OF X_c-bar-code NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* BROWSE BR-gds-hist */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Полная истоия по товару */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Полная истоия по товару */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Товар */
DO:
run str/showgds.p ( input parparentproc
              ,input ? /*p-call-handle*/
              ,input X_c-gds-hist.gds-code
              ,input {&lookup}) no-error.
if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available X_c-gds-hist then do:
    { gbl/markstrn.i X_c-gds-hist v-rid-list }
    loc#log = br-gds-hist:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-gds-hist:select-next-row ().
        apply "VALUE-CHANGED" to br-gds-hist in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-gds-hist in frame {&frame-name}.
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


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available X_c-gds-hist ) then do:
    if ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_c-gds-hist ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-gds-hist
&Scoped-define SELF-NAME BR-gds-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-gds-hist Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BR-gds-hist IN FRAME Dialog-Frame
DO:
   run proc-br-gds-hist in this-procedure no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-gds-hist Dialog-Frame
ON RETURN OF BR-gds-hist IN FRAME Dialog-Frame
DO:
  run proc-br-gds-hist in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-gds-hist Dialog-Frame
ON VALUE-CHANGED OF BR-gds-hist IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure no-error.
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
{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-gds-hist" }
{ gbl/brwrefre.i  " v-doc-rec = recid(X_c-bar-code). RUn OpenBR in this-procedure ( input yes, input no, input '':U, input v-corr-user-db-num). REPOSITION br-gds-hist to recid v-doc-rec No-ERROR. ~
                apply 'value-changed' to br-gds-hist. " }

{ gbl/srt-clmd.i
  &browse-name    = "br-gds-hist"
  &frame-name     = "{&frame-name}"
  &table-name     = "X_c-gds-hist"
  &sort-clmn_1    = "X_c-gds-hist.corr-date"
  &sort-clmn_2    = "X_c-gds-hist.corr-user-db-num"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input '':U, input v-corr-user-db-num)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U, input v-corr-user-db-num)."
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
   if p-mode <> "one":U
  then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return.
 end.
 if p-mode = "one":U then do:
  find first X_goods no-lock where
                X_goods.gds-code = p-gds-code no-error.
    if not available X_goods then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-gds-code" p-gds-code
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
      FIND FIRST find_c-gds-hist No-LOCK where
                 recid(find_c-gds-hist) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_c-gds-hist then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова v-rid-list" p-rid-list
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
    v-gds-name = get-good(p-gds-code, output v-artic, output v-prod-type, output v-prod-code)
    .
  end.
  RUN MyEnable in this-procedure .
  RUn OpenBR in this-procedure ( input yes, input no, input '':U, input v-corr-user-db-num).
  HIDE mark-num in frame {&frame-name} .
  if v-rid-list <> "":U then
  REPOSITION br-gds-hist to recid integer(entry(1, v-rid-list)) No-ERROR.
  { gbl/mv-clmn.i
    &browse-name = "br-gds-hist"
    &frame-name = "{&frame-name}"
    &ext-col = 10
    &start-column = 1
    &prev-order-column_2 = "'1,2,3,4,5,6,7,8,9,10'"
    &prev-order-column-condition_2 = " p-mode = 'one':U "
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
  DISPLAY v-corr-user-db-num mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel v-corr-user-db-num B-print B-Help B-lookup
         BR-gds-hist BR-changes mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  assign
  br-gds-hist:num-locked-columns in frame {&frame-name} = 1
  X_c-gds-hist.corr-date:read-only in browse br-gds-hist = yes
  br-changes:title = "":U
  v-corr-user-db-num = v-db-num
  temp-changes.l_name:resizable in browse br-changes = true
  temp-changes.v_old:resizable in browse br-changes = true
  temp-changes.v_new:resizable in browse br-changes = true
  temp-changes.l_name:width in browse br-changes = 30
  temp-changes.v_old:width in browse br-changes = 40
  temp-changes.v_new:width in browse br-changes = 40
  .

  VIEW frame {&frame-name} .
  DISPLAY
  v-corr-user-db-num
  mark-num
  WITH FRAME Dialog-Frame.
  ENABLE
  v-corr-user-db-num
  b-quit
  B-mark when lookup("b-mark":U, bttns) > 0
  b-sel when lookup("b-sel":U, bttns) > 0
  B-lookup
  B-Print
  B-Help
  BR-gds-hist
  BR-changes mark-num
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define input  parameter p-db-num like ub.c-gds-hist.corr-user-db-num no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Список полной истории товара" + {&space-char}.
define variable sort-column-phrase as character no-undo .
run waitfram-show in this-procedure ( input "Ждите" ).
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

&scop flt-open-open-query OPEN QUERY br-gds-hist FOR EACH X_c-bar-code

&scop flt-open-open-query-tail , first X_c-gds-hist no-lock WHERE X_c-gds-hist.gds-code = X_c-bar-code.gds-code ~
  AND X_c-gds-hist.chip-num = X_c-bar-code.chip-num ~
  AND X_c-gds-hist.corr-user-db-num = X_c-bar-code.corr-user-db-num

&scop flt-open-dyn_open-query  FOR EACH X_c-bar-code

&scop flt-open-query-handle query br-gds-hist:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-bar-code

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_c-bar-code

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .

CASE p-db-num:
  when ? then do:
    CASE p-mode :
      WHEN "one":u THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        frame {&frame-name}:TITLE = title0 + substitute(" Бар-код &1 Товар с кодом &2: &3 &4 &5&6",
                                                                          p-b-code, p-gds-code, v-gds-name, v-artic, v-prod-type, v-prod-code )
        filter-label = substitute("&1 Один бар-код", filter-label0)
                                                                          .
        { gbl/fltopend.i
          &where-cond = "  X_c-bar-code.b-code = p-b-code  "
          &dyn_where-cond = "  substitute('X_c-bar-code.b-code = &1', p-b-code ) "
          &use-ind    = "  "
          &by         = "  " }
      END.
    END CASE.
  end.
  otherwise do:
    CASE p-mode :
      WHEN "one":u THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        frame {&frame-name}:TITLE = title0 + substitute(" Бар-код &1 Товар с кодом &2: &3 &4 &5&6 БД: &7",
                                                                          p-b-code, p-gds-code, v-gds-name, v-artic, v-prod-type, v-prod-code, p-db-num )
        filter-label = substitute("&1 Один бар-код", filter-label0)
                                                                          .
        { gbl/fltopend.i
          &where-cond = " X_c-bar-code.b-code = p-b-code ANd   X_c-bar-code.corr-user-db-num  = p-db-num  "
          &dyn_where-cond = " substitute('X_c-bar-code.b-code = &1 ANd   X_c-bar-code.corr-user-db-num  = &2 ' , p-b-code, p-db-num) "
          &use-ind    = " use-index ishow  "
          &by         = "  " }
      END.
    END CASE.
  end.
END CASE.

if not p-open-query then
REPOSITION br-gds-hist to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-gds-hist:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-gds-hist in frame {&frame-name}.
APPLY "ENTRY" TO br-gds-hist.


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
v-action-chr FORMAT "X(10)" COLUMN-LABEL "Действие"
v-subject-chr COLUMN-LABEL "Предмет изменений" FORMAT "X(20)"
X_c-gds-hist.is-news COLUMn-LABEL "СПН" FORMAT "+/ "
v-source-type COLUMn-LABEL "Источн.!измен"
X_c-gds-hist.source-ref COLUMn-LABEL "№"
X_c-gds-hist.corr-date
v-upd-time COLUMN-LABEL "Время изм." FORMAT "X(8)"
v-for-user-name COLUMN-LABEL "Изменил" FORMAT "X(18)"
X_c-gds-hist.corr-user-db-num
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 195).
date_string = cur-time-print() .
assign
v-doc-rec = recid( X_c-gds-hist ).
DO WHILE available X_c-gds-hist :
      GET prev br-gds-hist.
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
run waitfram-show in this-procedure ( input "Ждите...").
  GET next br-gds-hist.
    DO WHILE available X_c-gds-hist :
      Display STREAM PrnLibStream
      get-action(X_c-gds-hist.action) @ v-action-chr
      get-subject(X_c-gds-hist.subject) @ v-subject-chr
      X_c-gds-hist.is-news
      get-source-type(X_c-gds-hist.source-type) @ v-source-type
      X_c-gds-hist.source-ref
      X_c-gds-hist.corr-date
      string(X_c-gds-hist.corr-time, "HH:MM:SS":U) @ v-upd-time
      usrfulnf(X_c-gds-hist.corr-user-name) @ v-for-user-name
      X_c-gds-hist.corr-user-db-num
      with FRAME HistoryList .
  DOWN STREAM PrnLibStream 1 with FRAME HistoryList  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-gds-hist.
END.
UNDERLINE  STREAM PrnLibStream
v-action-chr
v-subject-chr
X_c-gds-hist.is-news
v-source-type
X_c-gds-hist.source-ref
X_c-gds-hist.corr-date
v-upd-time
v-for-user-name
X_c-gds-hist.corr-user-db-num
with FRAME HistoryList .
DISPLAY STREAM PrnLibStream
("ИТОГО" + {&space-char} + string(accum-count))   @ v-action-chr
 with frame HistoryList.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME CheckList.
output  STREAM PrnLibStream CLOSE.

run waitfram-hide in this-procedure.
run prn-lib-prn-file in this-procedure (
                                          input parparentproc
                                          ,input 8
                                          ).
reposition br-gds-hist to recid v-doc-rec no-error.
apply "entry" to br-gds-hist in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-gds-hist Dialog-Frame
PROCEDURE proc-br-gds-hist :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ ref/brwsretr.i }
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
if not available X_c-gds-hist then do:
  Open QUery br-changes for each temp-changes.
  return.
end.

run ref/cgdshisv.p (
                   input X_c-gds-hist.gds-code
                  ,input X_c-gds-hist.chip-num
                  ,input X_c-gds-hist.corr-user-db-num
                  ,input X_c-gds-hist.host-code
                  ,input X_c-gds-hist.obj-type
                  ,input X_c-gds-hist.obj-code
                  ,input X_c-gds-hist.subject
                  ,input X_c-gds-hist.action
                  ,input no /*p-silent*/
                  ,input "":U /*p-log-file*/
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-good Dialog-Frame
FUNCTION get-good RETURNS CHARACTER
  ( p-gds-code as integer, output p-artic as character, output p-prod-type as character, output p-prod-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_goods for ub.goods.
find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error.
if not available buf_goods then do:
    return "!!! Неизвестный товар!!!".

end.
assign
p-artic =  buf_goods.artic
p-prod-type =  buf_goods.prod-type
p-prod-code =  buf_goods.prod-code
.

  RETURN buf_goods.gds-name.   /* Function return value. */

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
&scop hn-gds-hist-code p-subject
  RETURN {&hn-gds-hist-name}.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME