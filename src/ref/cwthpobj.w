&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER find_c-wth-pobj FOR ub.c-wth-pobj.
DEFINE BUFFER X_c-wth-pobj FOR ub.c-wth-pobj.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_curr-sysconf FOR ub.sysconf.
DEFINE BUFFER X_sysconf FOR ub.sysconf.
DEFINE BUFFER X_wealth FOR ub.wealth.
DEFINE BUFFER X_wth-place FOR ub.wth-place.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории остатков МЦ на МХ

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
/*может быть {&all} "one":U {&g___object} place */
define input parameter p-obj-type like ub.c-wth-pobj.obj-type no-undo.
define input parameter p-obj-code like ub.c-wth-pobj.obj-code no-undo.
define input parameter p-w-p-code  like ub.c-wth-pobj.w-p-code no-undo .
define input parameter p-wth-code  like ub.c-wth-pobj.wth-code no-undo .



/*записи в выборке*/
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список истории остатков МЦ на МХ":U.
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
{ str/wth-lib.i  }
define variable filter-label as character no-undo init "История остатков МЦ на МХ" .
define variable filter-label0 as character no-undo init "История остатков МЦ на МХ" .
define variable filter-point0 as character no-undo init "cwthpobj" .
define variable filter-point as character no-undo init "cwthpobj" .
define variable sort-column-name as character no-undo .
define variable print-option as character no-undo.
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-find as logical no-undo.
define variable v-wth-name like ub.wealth.wth-name no-undo.
define variable v-w-p-name like ub.wth-place.w-p-name no-undo.
define variable v-start-date-chr as character no-undo .
define variable v-end-date-chr as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-rid-list as character no-undo .
/*вспомогат*/
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".

define buffer X_curr_sysconf for ub.sysconf.

{ ref/tmpchgs.i }

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
&Scoped-define INTERNAL-TABLES temp-changes X_c-wth-pobj

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE br-cwthobj                                    */
&Scoped-define FIELDS-IN-QUERY-br-cwthobj mark-string(recid(X_c-wth-pobj), v-rid-list) X_c-wth-pobj.wth-code X_c-wth-pobj.w-p-code X_c-wth-pobj.corr-date usrfulnf(X_c-wth-pobj.corr-user-name) string(X_c-wth-pobj.corr-time, "HH:MM:SS":U) X_c-wth-pobj.corr-user-db-num X_c-wth-pobj.source-ref get-action(X_c-wth-pobj.action-type) get-source-type(X_c-wth-pobj.source-type) if v-find and p-mode <> 'place' then get-wealth(X_c-wth-pobj.wth-code) else "":U if v-find then get-wp(X_c-wth-pobj.obj-type, X_c-wth-pobj.obj-code, X_c-wth-pobj.w-p-code) else "":U X_c-wth-pobj.obj-type + string(X_c-wth-pobj.obj-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-cwthobj X_c-wth-pobj.corr-date
&Scoped-define ENABLED-TABLES-IN-QUERY-br-cwthobj X_c-wth-pobj
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-cwthobj X_c-wth-pobj
&Scoped-define SELF-NAME br-cwthobj
&Scoped-define QUERY-STRING-br-cwthobj FOR EACH X_c-wth-pobj NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-cwthobj OPEN QUERY {&SELF-NAME} FOR EACH X_c-wth-pobj NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-cwthobj X_c-wth-pobj
&Scoped-define FIRST-TABLE-IN-QUERY-br-cwthobj X_c-wth-pobj


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-print B-sch B-Help ~
B-lookup br-cwthobj sch-corr-date sch-w-p-code sch-source-ref ~
sch-corr-user-name BR-changes mark-num
&Scoped-Define DISPLAYED-OBJECTS sch-corr-date sch-w-p-code sch-source-ref ~
sch-corr-user-name mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-action Dialog-Frame
FUNCTION get-action RETURNS CHARACTER
  ( p-action as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-source-type Dialog-Frame
FUNCTION get-source-type RETURNS CHARACTER
  ( p-source-type as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-wealth Dialog-Frame
FUNCTION get-wealth RETURNS CHARACTER
  ( p-wth-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-wp Dialog-Frame
FUNCTION get-wp RETURNS CHARACTER
  ( p-obj-type as character, p-obj-code as integer, p-w-p-code as integer )  FORWARD.

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
     LABEL "&Документ"
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
     LABEL "Дате изм."
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE sch-corr-user-name AS CHARACTER FORMAT "X(9)":U
     LABEL "пользователю"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-source-ref AS CHARACTER FORMAT "X(9)":U
     LABEL "док-ту"
     VIEW-AS FILL-IN
     SIZE 13 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-w-p-code AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     LABEL "коду МХ"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.

DEFINE QUERY br-cwthobj FOR
      X_c-wth-pobj SCROLLING.
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

DEFINE BROWSE br-cwthobj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-cwthobj Dialog-Frame _FREEFORM
  QUERY br-cwthobj NO-LOCK DISPLAY
      mark-string(recid(X_c-wth-pobj), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_c-wth-pobj.wth-code COLUMN-LABEL "Код МЦ" FORMAT ">>>>>>>>9":U
      X_c-wth-pobj.w-p-code COLUMN-LABEL "Код Мх МЦ" FORMAT ">>>>>>>>9":U
      X_c-wth-pobj.corr-date FORMAT "99/99/9999":U
      usrfulnf(X_c-wth-pobj.corr-user-name) FORMAT "X(18)":U
      string(X_c-wth-pobj.corr-time, "HH:MM:SS":U) COLUMN-LABEL "Время изм." FORMAT "X(8)":U
      X_c-wth-pobj.corr-user-db-num FORMAT ">>>>9":U
      X_c-wth-pobj.source-ref FORMAT "X(14)":U
      get-action(X_c-wth-pobj.action-type) COLUMN-LABEL "Действие" FORMAT "X(10)":U
      get-source-type(X_c-wth-pobj.source-type) COLUMN-LABEL "Источн.!измен."
      if v-find and p-mode <> 'place' then get-wealth(X_c-wth-pobj.wth-code) else "":U COLUMN-LABEL "Назв. МЦ" FORMAT "X(25)":U
      if v-find then get-wp(X_c-wth-pobj.obj-type, X_c-wth-pobj.obj-code, X_c-wth-pobj.w-p-code) else "":U COLUMN-LABEL "Назв. МХ" FORMAT "x(25)":U
      X_c-wth-pobj.obj-type + string(X_c-wth-pobj.obj-code) COLUMN-LABEL "Объект" FORMAT "X(8)":U
  ENABLE
      X_c-wth-pobj.corr-date
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
     br-cwthobj AT ROW 2 COL 1
     sch-corr-date AT ROW 13.63 COL 64.5 COLON-ALIGNED
     sch-w-p-code AT ROW 13.67 COL 45 COLON-ALIGNED
     sch-source-ref AT ROW 13.67 COL 84 COLON-ALIGNED
     sch-corr-user-name AT ROW 13.71 COL 22.5 COLON-ALIGNED
     BR-changes AT ROW 14.79 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 8.38 BY 1 AT ROW 13.63 COL 1.38
          FGCOLOR 4
     SPACE(89.48) SKIP(7.44)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История остатков МЦ на МХ"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_c-wth-pobj B "?" NO-UNDO ub c-wth-pobj
      TABLE: X_c-wth-pobj B "?" ? ub c-wth-pobj
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_curr-sysconf B "?" ? ub sysconf
      TABLE: X_sysconf B "?" ? ub sysconf
      TABLE: X_wealth B "?" ? ub wealth
      TABLE: X_wth-place B "?" ? ub wth-place
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-cwthobj B-lookup Dialog-Frame */
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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-cwthobj
/* Query rebuild information for BROWSE br-cwthobj
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-wth-pobj NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-cwthobj */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* История остатков МЦ на МХ */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История остатков МЦ на МХ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Документ */
DO:
define buffer buf_wth-doc for ub.wth-doc.
define buffer buf_C-wth-doc for ub.C-wth-doc.
if not available X_c-wth-pobj then return no-apply.
IF X_c-wth-pobj.source-type = {&table_wth-doc} then do:
  find first buf_wth-doc no-lock where
        buf_wth-doc.doc-code =  X_c-wth-pobj.source-ref no-error.
  if not available buf_wth-doc then do:
    for each buf_C-wth-doc no-lock where
          buf_c-wth-doc.doc-code =  X_c-wth-pobj.source-ref
      AND buf_c-wth-doc.is-del =  yes :
      run str/wthcdlkp.p (
                      input parparentproc
                     ,input recid(buf_C-wth-doc)
                     ) no-error .
      leave.
    end.
    if not available buf_c-wth-doc then do:
      message
      substitute("Не найден документ с № &1", X_c-wth-pobj.source-ref)
      view-as alert-box error .
      return no-apply.
    end.
  END.
  else do:
    run str/wthd-lkp.p (
                    input parparentproc
                  ,input recid(buf_wth-doc)) no-error .
  end.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available X_c-wth-pobj then do:
    { gbl/markstrn.i X_c-wth-pobj v-rid-list }
    loc#log = br-cwthobj:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-cwthobj:select-next-row ().
        apply "VALUE-CHANGED" to br-cwthobj in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-cwthobj in frame {&frame-name}.
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
  if ( available X_c-wth-pobj ) then do:
    if ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_c-wth-pobj ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-cwthobj
&Scoped-define SELF-NAME br-cwthobj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cwthobj Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-cwthobj IN FRAME Dialog-Frame
DO:
     run proc-br-cwthobj in this-procedure no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cwthobj Dialog-Frame
ON RETURN OF br-cwthobj IN FRAME Dialog-Frame
DO:
    run proc-br-cwthobj in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cwthobj Dialog-Frame
ON VALUE-CHANGED OF br-cwthobj IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-corr-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-corr-date Dialog-Frame
ON CTRL-J OF sch-corr-date IN FRAME Dialog-Frame /* Дате изм. */
DO:
   run proc-find-corr-date in this-procedure(yes, input frame {&frame-name} sch-corr-date) no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-corr-date Dialog-Frame
ON RETURN OF sch-corr-date IN FRAME Dialog-Frame /* Дате изм. */
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


&Scoped-define SELF-NAME sch-source-ref
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-source-ref Dialog-Frame
ON CTRL-J OF sch-source-ref IN FRAME Dialog-Frame /* док-ту */
DO:
  run proc-find-source-ref in this-procedure(yes, input frame {&frame-name} sch-source-ref) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-source-ref Dialog-Frame
ON RETURN OF sch-source-ref IN FRAME Dialog-Frame /* док-ту */
DO:
  run proc-find-source-ref in this-procedure(no, input frame {&frame-name} sch-source-ref) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-w-p-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-w-p-code Dialog-Frame
ON CTRL-J OF sch-w-p-code IN FRAME Dialog-Frame /* коду МХ */
DO:
  run proc-find-w-p-code in this-procedure(yes, input frame {&frame-name} sch-w-p-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-w-p-code Dialog-Frame
ON RETURN OF sch-w-p-code IN FRAME Dialog-Frame /* коду МХ */
DO:
  run proc-find-w-p-code in this-procedure(no, input frame {&frame-name} sch-w-p-code) no-error.
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

{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-cwthobj" }
{ gbl/brwrefre.i " v-doc-rec = recid(X_c-wth-pobj).  RUn OpenBR in this-procedure ( input yes, input no, input '':U).  REPOSITION br-cwthobj to recid v-doc-rec No-ERROR. ~
               apply 'value-changed' to br-cwthobj. " }

{ gbl/setfltnm.i }
{ gbl/ed_date.i sch-corr-date}

{ gbl/srt-clmd.i
  &browse-name    = "br-cwthobj"
  &frame-name     = "{&frame-name}"
  &table-name     = "X_c-wth-pobj"
  &sort-clmn_1    = "X_c-wth-pobj.wth-code"
  &sort-clmn_2    = "X_c-wth-pobj.corr-date"
  &sort-clmn_3    = "X_c-wth-pobj.corr-user-db-num"
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
 and p-mode <> 'place':U
  then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return.
 end.
 if p-mode = {&g___object}
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
 if p-mode = 'place'
 or p-mode = 'one' then do:
  find first X_wth-place no-lock where
             X_wth-place.obj-type = p-obj-type
         AND  X_wth-place.obj-code = p-obj-code
         AND  X_wth-place.w-p-code = p-w-p-code no-error.
    if not available X_wth-place then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-w-p-code" p-w-p-code
        view-as alert-box ERROR.
        return.
    end.

 end.
 if p-mode = "one":U
  then do:
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
  v-rid-list = p-rid-list.
  if v-rid-list <> "" then do:
      FIND FIRST find_c-wth-pobj No-LOCK where
                 recid(find_c-wth-pobj) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_c-wth-pobj then do:
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
    if p-mode = 'place' then do:
      assign
      v-w-p-name = get-wp(p-obj-type, p-obj-code, p-w-p-code)
      .
    end.
    else do:
      assign
      v-wth-name = get-wealth(p-wth-code)
      .
    end.
  end.
  RUN MyEnable in this-procedure .
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if v-rid-list <> "":U then
  REPOSITION br-cwthobj to recid integer(entry(1, v-rid-list)) No-ERROR.
  { gbl/mv-clmn.i
    &browse-name = "br-cwthobj"
    &frame-name = "{&frame-name}"
    &ext-col = 12
    &start-column = 1
    &prev-order-column_1 = "'12,1,2,3,4,5,6,7,8,9,10,11'"
    &prev-order-column-condition_1 = " p-mode = {&all} "
    &prev-order-column_2 = "'1,2,3,4,5,6,7,8,9,10,11,12'"
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE c-wth-lib_cur-stock-place Dialog-Frame
procedure c-wth-lib_cur-stock-place:
define parameter buffer bf_c-wth-pobj for ub.c-wth-pobj.
define output parameter parstock    like ub.c-wth-pobj.income-pl no-undo.
if available bf_c-wth-pobj then assign parstock = bf_c-wth-pobj.income-pl - bf_c-wth-pobj.incass-pl.
                         else assign parstock = 0.
end procedure.

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
  DISPLAY sch-corr-date sch-w-p-code sch-source-ref sch-corr-user-name mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-print B-sch B-Help B-lookup br-cwthobj
         sch-corr-date sch-w-p-code sch-source-ref sch-corr-user-name
         BR-changes mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
assign
  br-cwthobj:num-locked-columns in frame {&frame-name} = 1
  X_c-wth-pobj.corr-date:read-only in browse br-cwthobj = yes
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
  sch-w-p-code
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
  br-cwthobj
  sch-corr-date
  sch-w-p-code when p-mode = {&all}
  sch-corr-user-name
  sch-source-ref
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
title0 = "История остатков МЦ" + {&space-char}.
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


&scop flt-open-open-query OPEN QUERY br-cwthobj FOR EACH X_c-wth-pobj

&scop flt-open-dyn_open-query FOR EACH X_c-wth-pobj

&scop flt-open-query-handle  QUERY br-cwthobj:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-wth-pobj

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name  X_c-wth-pobj

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
  WHEN {&g___object} THEN DO:
    assign
    filter-point = filter-point0 + p-mode
    filter-label = substitute("&1 Один объект", filter-label0)
    .
    if p-open-query then do:
      ASSIGN
      frame {&frame-name}:TITLE = title0 + substitute(" Остатки МЦ по объекту: &1&2"
                                                        ,p-obj-type, p-obj-code)
      .
    end.
    { gbl/fltopend.i
      &where-cond = " ~
                    X_c-wth-pobj.obj-type = p-obj-type and X_c-wth-pobj.obj-code = p-obj-code   ~
                    "
      &dyn_where-cond = " substitute('X_c-wth-pobj.obj-type = &1&2&1 and X_c-wth-pobj.obj-code = &3', ~{&double-quote~}, p-obj-type, p-obj-code)"

      &use-ind    = " use-index ishow "
      &by         = "  " }
  END.
  WHEN "place":u THEN DO:
    assign
    filter-point = filter-point0 + p-mode
    filter-label = substitute("&1 Одно МХ", filter-label0)
    .
    if p-open-query then do:
      ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" Остатки МЦ на МХ &1: &2 Объект &3&4"
                                                              , p-w-p-code, v-w-p-name, p-obj-type, p-obj-code )
      .
    end.
    { gbl/fltopend.i
      &where-cond = " X_c-wth-pobj.obj-type = p-obj-type and X_c-wth-pobj.obj-code = p-obj-code ~
                      AND X_c-wth-pobj.w-p-code  = p-w-p-code "
      &dyn_where-cond = " substitute('X_c-wth-pobj.obj-type = &1&2&1 and X_c-wth-pobj.obj-code = &3 ~
                      AND X_c-wth-pobj.w-p-code  = &4 ', ~{&double-quote~}, p-obj-type, p-obj-code, p-w-p-code)"

      &use-ind    = "  "
      &by         = "  " }
  END.


  WHEN "one":u THEN DO:
    assign
    filter-point = filter-point0 + p-mode
    filter-label = substitute("&1 Одно МХ, одна МЦ", filter-label0)
    .
    if p-open-query then do:
      ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" Остатки МЦ с кодом &1 на МХ &2: &3 Объект &4&5"
                                                              ,p-wth-code, p-w-p-code, v-wth-name,p-obj-type, p-obj-code )
     .
    end.
    { gbl/fltopend.i
      &where-cond = " X_c-wth-pobj.obj-type = p-obj-type and X_c-wth-pobj.obj-code = p-obj-code ~
                      AND X_c-wth-pobj.wth-code  = p-wth-code AND X_c-wth-pobj.w-p-code  = p-w-p-code "
      &use-ind    = "  "
      &by         = "  " }
  END.
END CASE.

if not p-open-query  and v-doc-rec <> ? then
REPOSITION br-cwthobj to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-cwthobj:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.

run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-cwthobj in frame {&frame-name}.
APPLY "ENTRY" TO br-cwthobj.


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
define variable v-source-type as character no-undo .
DEFINE VARIABLE v-for-user-name AS CHARACTER NO-UNDO.
DEFINE FRAME HistoryList
X_c-wth-pobj.wth-code COLUMN-LABEL "Код МЦ"
X_c-wth-pobj.w-p-code COLUMN-LABEL "Код МХ МЦ"
v-action-chr FORMAT "X(10)" COLUMn-LABEL "Действие"
v-wth-name COLUMN-LABEL "Назв. МЦ" FORMAT "X(20)"
v-w-p-name COLUMN-LABEL "Назв. МХ МЦ" FORMAT "X(20)"
v-source-type COLUMn-LABEL "Источн.!измен"
X_c-wth-pobj.source-ref COLUMn-LABEL "№"
X_c-wth-pobj.corr-date
v-upd-time COLUMN-LABEL "Время изм." FORMAT "X(8)"
v-for-user-name COLUMN-LABEL "Изменил" FORMAT "X(18)"
X_c-wth-pobj.corr-user-db-num
v-obj COLUMN-LABEL "Объект" FORMAT "X(8)"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 195).
date_string = cur-time-print() .
assign
v-doc-rec = recid( X_c-wth-pobj ).
DO WHILE available X_c-wth-pobj :
      GET prev br-cwthobj.
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
  GET next br-cwthobj.
    DO WHILE available X_c-wth-pobj :
      Display STREAM PrnLibStream
      X_c-wth-pobj.wth-code
      X_c-wth-pobj.w-p-code
      get-action(X_c-wth-pobj.action-type) @ v-action-chr
      (if v-find and p-mode <> 'place':U then get-wealth(X_c-wth-pobj.wth-code) else "":U )
      @ v-wth-name
      (if v-find then get-wp(X_c-wth-pobj.obj-type, X_c-wth-pobj.obj-code, X_c-wth-pobj.w-p-code) else "":U )
      @ v-w-p-name
      get-source-type(X_c-wth-pobj.source-type) @ v-source-type
      X_c-wth-pobj.source-ref
      X_c-wth-pobj.corr-date
      string(X_c-wth-pobj.corr-time, "HH:MM:SS":U) @ v-upd-time
      usrfulnf(X_c-wth-pobj.corr-user-name) @ v-for-user-name
      X_c-wth-pobj.corr-user-db-num
      X_c-wth-pobj.obj-type + string(X_c-wth-pobj.obj-code) @ v-obj
      with FRAME HistoryList .
  DOWN STREAM PrnLibStream 1 with FRAME HistoryList  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-cwthobj.
END.
UNDERLINE  STREAM PrnLibStream
X_c-wth-pobj.wth-code
X_c-wth-pobj.w-p-code
v-action-chr
v-wth-name
v-w-p-name
v-source-type
X_c-wth-pobj.source-ref
X_c-wth-pobj.corr-date
v-upd-time
v-for-user-name
X_c-wth-pobj.corr-user-db-num
v-obj
with FRAME HistoryList .
DISPLAY STREAM PrnLibStream
"ИТОГО"  @ X_c-wth-pobj.wth-code
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
reposition br-cwthobj to recid v-doc-rec no-error.
apply "entry" to br-cwthobj in frame {&frame-name}.

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
  tbl = 'c-wth-pobj'
  join-tbl = 'X_c-wth-pobj'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('wth-code', 'Код МЦ', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('w-p-code', 'Код МХ МЦ', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время корр.', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('action-type', 'Действие', 'hist-action',
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-cwthobj Dialog-Frame
PROCEDURE proc-br-cwthobj :
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
0 @ sch-w-p-code
"":U @ sch-corr-user-name
'':U sch-source-ref
with frame {&frame-name}.
assign
v-date-chr = string(day(p-date)) + {&slash-char} +
                 string(month(p-date)) + {&slash-char} +
                 string(year(p-date)).

       run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input true  /* p-find-next  */
        ,input substitute("and X_c-wth-pobj.corr-date = &1 "
          , v-date-chr)
        ).
      apply "entry":u to sch-corr-date in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-source-ref Dialog-Frame
PROCEDURE proc-find-source-ref :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-user like ub.c-wth-obj.corr-user-name no-undo.
assign
sch-corr-date = ?
.
display
sch-corr-date
0 @ sch-w-p-code
'':U @ sch-corr-user-name
with frame {&frame-name}.
p-user = {&double-quote} + p-user + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-wth-obj.soruce-type = 'wth-doc' and X_c-wth-obj.source-ref = &1 "
      , p-user)
    ).
apply "entry":u to sch-source-ref in frame {&frame-name} .

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
define input parameter p-user like ub.c-wth-pobj.corr-user-name no-undo.
assign
sch-corr-date = ?.
display
sch-corr-date
0 @ sch-w-p-code
'':U sch-source-ref
with frame {&frame-name}.
p-user = {&double-quote} + p-user + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-wth-pobj.corr-user-name = &1 "
      , p-user)
    ).
apply "entry":u to sch-corr-user-name in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-w-p-code Dialog-Frame
PROCEDURE proc-find-w-p-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-w-p-code like ub.c-wth-pobj.w-p-code no-undo.
define variable v-w-p-code as character no-undo.
assign
sch-corr-date = ?.
display
"":U @ sch-corr-user-name
sch-corr-date
'':U sch-source-ref
with frame {&frame-name}.

assign
v-w-p-code = string(p-w-p-code).
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-wth-pobj.w-p-code = &1 "
      , v-w-p-code)
    ).
apply "entry":u to sch-w-p-code in frame {&frame-name} .



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame
PROCEDURE proc-view-changes :
for each temp-changes:
    delete temp-changes.
END.
if not available X_c-wth-pobj then do:
  Open QUery br-changes for each temp-changes.
  return.
end.

&scop fields-name-list "host-code,incass-pl,incass-bank-pl,incass-cassa-pl,incass-other-pl,income-pl,income-cassa-pl,income-other-pl,obj-code,obj-type,wth-code,w-p-code"
define variable v-label-param as character no-undo .

v-label-param =
  "host-code" + {&delim-par} + "Код фирмы" + {&delim-par} + "" + {&delim-flf}
 + "incass-pl" + {&delim-par} + "Инкассировано" + {&delim-par} + "" + {&delim-flf}
 + "incass-bank-pl" + {&delim-par} + "Инкассировано в банк" + {&delim-par} + "" + {&delim-flf}
 + "incass-cassa-pl" + {&delim-par} + "Возврат по кассе" + {&delim-par} + "" + {&delim-flf}
 + "incass-other-pl" + {&delim-par} + "Прочие инкассации" + {&delim-par} + "" + {&delim-flf}
 + "income-pl" + {&delim-par} + "Получено" + {&delim-par} + "" + {&delim-flf}
 + "income-cassa-pl" + {&delim-par} + "Выручка" + {&delim-par} + "" + {&delim-flf}
 + "income-other-pl" + {&delim-par} + "Прочие поступления" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип Объекта" + {&delim-par} + "" + {&delim-flf}
 + "wth-code" + {&delim-par} + "Код МЦ" + {&delim-par} + "" + {&delim-flf}
 + "w-p-code" + {&delim-par} + "Кoд МХ" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  buffer X_c-wth-pobj:handle
                                            ,input  {&table_wth-pobj}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).
/*добавим записи с остатками - их надо вычислить*/

define variable c-stock-1 as decimal no-undo.
define variable c-stock-2 as decimal no-undo.
define buffer buf_c-wth-pobj for ub.c-wth-pobj.

RUN c-wth-lib_cur-stock-place (
                             buffer X_c-wth-pobj
                            ,output c-stock-1) no-error.
find first buf_c-wth-pobj no-lock where
          buf_c-wth-pobj.obj-type =  X_c-wth-pobj.obj-type
      and buf_c-wth-pobj.obj-code =  X_c-wth-pobj.obj-code
      and buf_c-wth-pobj.w-p-code =  X_c-wth-pobj.w-p-code
      and buf_c-wth-pobj.wth-code =  X_c-wth-pobj.wth-code
      and buf_c-wth-pobj.corr-user-db-num =  X_c-wth-pobj.corr-user-db-num
      and buf_c-wth-pobj.chip-num > X_c-wth-pobj.chip-num no-error.
if available buf_c-wth-pobj then do:
  RUN c-wth-lib_cur-stock-place (
                              buffer buf_c-wth-pobj
                              ,output c-stock-2) no-error.

end.
else do:
  RUN wth-lib_cur-stock-place (
                              input X_c-wth-pobj.obj-type
                              ,input X_c-wth-pobj.obj-code
                              ,input X_c-wth-pobj.w-p-code
                              ,input X_c-wth-pobj.wth-code
                              ,output c-stock-2) no-error.
end.

create temp-changes.
assign
temp-changes.t_name = {&table_c-wth-pobj}
temp-changes.f_name = ""
temp-changes.l_name = "Остаток"
temp-changes.v_old  = string(c-stock-1)
temp-changes.v_new  = string(c-stock-2)
temp-changes.num_   = 0
.
release temp-changes.

Open QUery br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-action Dialog-Frame
FUNCTION get-action RETURNS CHARACTER
  ( p-action as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define variable dops as character no-undo.
CASE p-action:
   when {&c-wth-obj_close} then do:
      return "Закр.на факт".
   end.
   when {&c-wth-obj_delete} then do:
      return "Удаление".
   end.
END CASE.


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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-wealth Dialog-Frame
FUNCTION get-wealth RETURNS CHARACTER
  ( p-wth-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_wealth for ub.wealth.
find first buf_wealth no-lock where
     buf_wealth.wth-code = p-wth-code no-error.
if not available buf_wealth then do:
    return "!!! Неизвестная МЦ!!!".
end.

  RETURN buf_wealth.wth-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-wp Dialog-Frame
FUNCTION get-wp RETURNS CHARACTER
  ( p-obj-type as character, p-obj-code as integer, p-w-p-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_wth-place for ub.wth-place.
find first buf_wth-place no-lock where
     buf_wth-place.obj-type = p-obj-type
    AND buf_wth-place.obj-code = p-obj-code
   AND buf_wth-place.w-p-code = p-w-p-code no-error.
if not available buf_wth-place then do:
    return "!!! Неизвестное МХ!!!".
end.

  RETURN buf_wth-place.w-p-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME