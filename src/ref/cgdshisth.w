&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER find_c-gds-hist FOR c-gds-hist.
DEFINE BUFFER X_c-gds-hist FOR c-gds-hist.
DEFINE BUFFER X_clients FOR clients.
DEFINE BUFFER X_curr-sysconf FOR sysconf.
DEFINE BUFFER X_db FOR db.
DEFINE BUFFER X_goods FOR goods.
DEFINE BUFFER X_sysconf FOR sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список полной истории товара

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

define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/

define input parameter p-mode  as char   no-undo .
/*может быть {&all} {&company} "one":U {&g___object} "subject":U */

define input parameter p-gds-code     like ub.c-gds-hist.gds-code no-undo .
define input parameter p-host-code like ub.c-gds-hist.host-code no-undo.
define input parameter p-obj-type like ub.c-gds-hist.obj-type no-undo.
define input parameter p-obj-code like ub.c-gds-hist.obj-code no-undo.
define input parameter p-corr-user-db-num  like ub.c-gds-hist.corr-user-db-num no-undo .
define input parameter p-corr-user-name  like ub.c-gds-hist.corr-user-name no-undo .
define input parameter p-subject  like ub.c-gds-hist.subject no-undo .
/*стартуем с текущей БД обычно*/

/*записи в выборке*/
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список полной истории товара":U.
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
{ gbl/usrfulnf.i }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }
define variable v-rid-list as character no-undo .
define variable filter-point as character no-undo init "cgdshist" .
define variable filter-point0 as character no-undo init "cgdshist" .
define variable filter-label0 as character no-undo init "Список полной истории товара" .
define variable filter-label as character no-undo init "Список полной истории товара" .
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

/*вспомогат*/
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".

define buffer X_curr_sysconf for ub.sysconf.
&SCOPED-DEFINE sort-clmn_2 usrfulnf(X_c-gds-hist.corr-user-name)
&SCOPED-DEFINE dyn_sort-clmn_2 substitute('dynamic-function(&1usrfulnf&1, X_c-gds-hist.corr-user-name)', ~{&double-quote~})
&scoped-define label-clmn_2 'Изменил'

&scop subject "Предмет изменений"

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
&Scoped-define INTERNAL-TABLES temp-changes X_c-gds-hist

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes   
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE BR-gds-hist                                   */
&Scoped-define FIELDS-IN-QUERY-BR-gds-hist mark-string(recid(X_c-gds-hist), v-rid-list) X_c-gds-hist.gds-code X_c-gds-hist.corr-date string(X_c-gds-hist.corr-time, "HH:MM:SS":U) {&sort-clmn_2} get-action(X_c-gds-hist.action) X_c-gds-hist.corr-user-db-num X_c-gds-hist.is-news get-source-type(X_c-gds-hist.source-type) X_c-gds-hist.source-ref if v-find then get-good(X_c-gds-hist.gds-code, output v-artic, output v-prod-type, output v-prod-code) else "":U v-artic v-prod-type + string(v-prod-code) get-subject(X_c-gds-hist.subject) X_c-gds-hist.host-code X_c-gds-hist.obj-type + string(X_c-gds-hist.obj-code)   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-gds-hist X_c-gds-hist.is-news   
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-gds-hist X_c-gds-hist
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-gds-hist X_c-gds-hist
&Scoped-define SELF-NAME BR-gds-hist
&Scoped-define QUERY-STRING-BR-gds-hist FOR EACH X_c-gds-hist NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-gds-hist OPEN QUERY {&SELF-NAME} FOR EACH X_c-gds-hist NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-gds-hist X_c-gds-hist
&Scoped-define FIRST-TABLE-IN-QUERY-BR-gds-hist X_c-gds-hist


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel v-corr-user-db-num ~
B-gds-obj B-print B-sch B-Help B-lookup BR-gds-hist sch-db-num ~
sch-corr-date sch-gds-code sch-corr-user-name BR-changes mark-num 
&Scoped-Define DISPLAYED-OBJECTS v-corr-user-db-num sch-db-num ~
sch-corr-date sch-gds-code sch-corr-user-name mark-num 

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
DEFINE BUTTON B-gds-obj 
     LABEL "&Остатки" 
     SIZE 10 BY 1.

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

DEFINE VARIABLE sch-db-num AS INTEGER FORMAT ">>>>>>9":U INITIAL 0 
     LABEL "БД" 
     VIEW-AS FILL-IN 
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-gds-code AS INTEGER FORMAT ">>>>>>9":U INITIAL 0 
     LABEL "коду товара" 
     VIEW-AS FILL-IN 
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE v-corr-user-db-num AS INTEGER FORMAT ">>>>9":U INITIAL 0 
     LABEL "по БД" 
     VIEW-AS FILL-IN 
     SIZE 5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR 
      temp-changes SCROLLING.

DEFINE QUERY BR-gds-hist FOR 
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
  X_c-gds-hist.corr-date FORMAT "99/99/9999":U
  string(X_c-gds-hist.corr-time, "HH:MM:SS":U) COLUMN-LABEL "Время изм." FORMAT "X(8)":U
  {&sort-clmn_2} column-label {&label-clmn_2} FORMAT "X(8)":U
  get-action(X_c-gds-hist.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
  X_c-gds-hist.corr-user-db-num FORMAT ">>>>9":U
  X_c-gds-hist.is-news FORMAT "+/":U
  get-source-type(X_c-gds-hist.source-type) COLUMN-LABEL "Источн.!измен."
  X_c-gds-hist.source-ref FORMAT "X(14)":U
  if v-find then get-good(X_c-gds-hist.gds-code, output v-artic, output v-prod-type, output v-prod-code) else "":U COLUMN-LABEL "Назв. товара" FORMAT "X(25)":U
  v-artic COLUMN-LABEL "Артикул" FORMAT "X(14)":U
  v-prod-type + string(v-prod-code) COLUMN-LABEL "Пр-ль" FORMAT "X(12)":U
  get-subject(X_c-gds-hist.subject) COLUMN-LABEL {&subject} FORMAT "X(55)":U width 15
  X_c-gds-hist.host-code COLUMN-LABEL "Фирма" FORMAT "999999999":U
  X_c-gds-hist.obj-type + string(X_c-gds-hist.obj-code) COLUMN-LABEL "Объект" FORMAT "X(8)":U
ENABLE
  X_c-gds-hist.is-news
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 11.46.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     v-corr-user-db-num AT ROW 1 COL 37 COLON-ALIGNED
     B-gds-obj AT ROW 1 COL 55
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     B-lookup AT ROW 1.04 COL 45
     BR-gds-hist AT ROW 2 COL 1
     sch-db-num AT ROW 13.63 COL 60.13 COLON-ALIGNED
     sch-corr-date AT ROW 13.63 COL 85.75 COLON-ALIGNED
     sch-gds-code AT ROW 13.67 COL 48.13 COLON-ALIGNED
     sch-corr-user-name AT ROW 13.71 COL 22.5 COLON-ALIGNED
     BR-changes AT ROW 14.79 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 8.38 BY 1 AT ROW 13.63 COL 1.38
          FGCOLOR 4 
     SPACE(89.48) SKIP(7.44)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Полная история по товару"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_c-gds-hist B "?" NO-UNDO ub c-gds-hist
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
/* BROWSE-TAB BR-changes sch-corr-user-name Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       BR-gds-hist:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

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
OPEN QUERY {&SELF-NAME} FOR EACH X_c-gds-hist NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-gds-hist */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Полная история по товару */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Полная история по товару */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Товар */
DO:
run str/showgds.p (input parparentproc
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


&Scoped-define SELF-NAME sch-gds-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-gds-code Dialog-Frame
ON CTRL-J OF sch-gds-code IN FRAME Dialog-Frame /* коду товара */
DO:
  run proc-find-gds-code in this-procedure(yes, input frame {&frame-name} sch-gds-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-gds-code Dialog-Frame
ON RETURN OF sch-gds-code IN FRAME Dialog-Frame /* коду товара */
DO:
  run proc-find-gds-code in this-procedure(no, input frame {&frame-name} sch-gds-code) no-error.
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
  RUn OpenBR(yes, no, '':U, v-corr-user-db-num).
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
{ gbl/brwrefre.i " v-doc-rec = recid(X_c-gds-hist).  Run OpenBR in this-procedure ( input yes, input no, input '':U, input v-corr-user-db-num).  REPOSITION br-gds-hist to recid v-doc-rec No-ERROR. ~
              apply 'value-changed' to br-gds-hist.  " }

{ gbl/setfltnm.i }
{ gbl/ed_date.i sch-corr-date}

{ gbl/srt-clmd.i
  &browse-name    = "br-gds-hist"
  &frame-name     = "{&frame-name}"
  &table-name     = "X_c-gds-hist"
  &sort-clmn_1    = "X_c-gds-hist.gds-code"
  &label-clmn_2  = "{&label-clmn_2}"
  &sort-clmn_2   = "{&sort-clmn_2}"
  &sort-clmn_3    = "X_c-gds-hist.corr-date"
  &sort-clmn_4    = "X_c-gds-hist.corr-user-db-num"
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
/*find first X_curr_sysconf no-lock where                              */
/*                X_curr_sysconf.host-code = p-curr-host-code no-error.*/
/*if not available X_curr_sysconf then do:                             */
/*  message                                                            */
/*  vss-workfile vss-revision vss-description skip                     */
/*  "Неверное значение параметра вызова p-curr-host-code"              */
/*  p-curr-host-code                                                   */
/*  view-as alert-box ERROR.                                           */
/*  return.                                                            */
/*end.                                                                 */
/* if p-mode = {&company} then do:                                     */
/*  find first X_clients no-lock where                                 */
/*                X_clients.obj-type = {&cmp}                          */
/*            and X_clients.obj-code = p-host-code no-error.           */
/*    if not available X_clients then do:                              */
/*        message                                                      */
/*        vss-workfile vss-revision vss-description skip               */
/*        "Неверное значение параметра вызова p-host-code"             */
/*        p-curr-host-code                                             */
/*        view-as alert-box ERROR.                                     */
/*        return.                                                      */
/*    end.                                                             */
/*    find first X_sysconf no-lock where                               */
/*                    X_sysconf.host-code = p-host-code no-error.      */
/*    if not available X_sysconf then do:                              */
/*      message                                                        */
/*      vss-workfile vss-revision vss-description skip                 */
/*      "Неверное значение параметра вызова p-host-code"               */
/*      p-host-code                                                    */
/*      view-as alert-box ERROR.                                       */
/*      return.                                                        */
/*    end.                                                             */
/*  end.                                                               */
/* if p-mode = {&g___object} then do:                                  */
/*  find first X_clients no-lock where                                 */
/*                X_clients.obj-type = p-obj-type                      */
/*            and X_clients.obj-code = p-obj-code no-error.            */
/*    if not available X_clients then do:                              */
/*        message                                                      */
/*        vss-workfile vss-revision vss-description skip               */
/*        "Неверное значение параметра вызова p-obj-type/p-obj-code"   */
/*        p-obj-type p-obj-code                                        */
/*        view-as alert-box ERROR.                                     */
/*        return.                                                      */
/*    end.                                                             */
/* end.                                                                */
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
    v-gds-name = get-good(p-gds-code, output v-artic, output v-prod-type, output v-prod-code)
    .
  end.
  RUN MyEnable.
  RUn OpenBR(yes, no, '':U, v-corr-user-db-num).
  HIDE mark-num in frame {&frame-name} .
  if v-rid-list <> "":U then
  REPOSITION br-gds-hist to recid integer(entry(1, v-rid-list)) No-ERROR.
  { gbl/mv-clmn.i
    &browse-name = "br-gds-hist"
    &frame-name = "{&frame-name}"
    &ext-col = 16
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16'"
    &prev-order-column-condition_1 = " p-mode = {&all} "
    &prev-order-column_2 = "'1,3,4,5,6,7,8,9,10,14,15,16,2,11,12,13'"
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
  DISPLAY v-corr-user-db-num sch-db-num sch-corr-date sch-gds-code 
          sch-corr-user-name mark-num 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel v-corr-user-db-num B-gds-obj B-print B-sch B-Help 
         B-lookup BR-gds-hist sch-db-num sch-corr-date sch-gds-code 
         sch-corr-user-name BR-changes mark-num 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
define variable v-h as handle no-undo .
assign
br-gds-hist:num-locked-columns in frame {&frame-name} = 1
X_c-gds-hist.is-news:read-only in browse br-gds-hist = yes
v-corr-user-db-num = v-db-num
br-changes:title = "":U
temp-changes.l_name:resizable in browse br-changes = true
temp-changes.v_old:resizable in browse br-changes = true
temp-changes.v_new:resizable in browse br-changes = true
temp-changes.l_name:width in browse br-changes = 30
temp-changes.v_old:width in browse br-changes = 40
temp-changes.v_new:width in browse br-changes = 40
v-h = br-gds-hist:FIRST-COLUMN IN FRAME {&FRAME-NAME}
.
DO while valid-handle(v-h) :
  if v-h:LABEL = {&subject} then do:
    v-h:RESIZABLE = YES.
    leave.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.


VIEW frame {&frame-name} .
DISPLAY
v-db-num @ v-corr-user-db-num
sch-db-num
sch-corr-date
sch-gds-code
sch-corr-user-name
mark-num
WITH FRAME {&FRAME-NAME}.
ENABLE
v-corr-user-db-num
b-quit
B-mark when lookup("b-mark":U, bttns) > 0
b-sel when lookup("b-sel":U, bttns) > 0
B-lookup
B-sch
B-gds-obj
B-Print
B-Help
BR-gds-hist
sch-corr-date
sch-gds-code when p-mode = {&all}
sch-db-num   when p-mode = {&all}
sch-corr-user-name
BR-changes mark-num
WITH FRAME {&FRAME-NAME}.
VIEW FRAME {&FRAME-NAME}.
HIDE sch-corr-user-name
IN FRAME {&FRAME-NAME}.
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

&scop flt-open-open-query OPEN QUERY br-gds-hist FOR EACH X_c-gds-hist

&scop flt-open-open-query-tail

&scop flt-open-dyn_open-query  FOR EACH X_c-gds-hist

&scop flt-open-query-handle query br-gds-hist:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-gds-hist

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_c-gds-hist

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .
CASE p-db-num :
  when ? then do:
    CASE p-mode :
      WHEN {&all}        THEN DO:
      assign
      filter-point = filter-point0 + p-mode
      filter-label = filter-label0
      .
      { gbl/fltopend.i
          &where-cond = " TRUE "
          &use-ind    = " use-index idate  "
          &by         = "  " }
      END.
      WHEN {&company} THEN DO:

        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Фирма", filter-label0)
        .
        if p-open-query then do:
          ASSIGN
          frame {&frame-name}:TITLE = title0 + substitute(" Товар с кодом &1: &2 &3 &4&5 Фирма: (&6) &7",
                                                            p-gds-code, v-gds-name, v-artic, v-prod-type, v-prod-code, p-host-code, X_clients.obj-name).
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-gds-hist.gds-code  = p-gds-code  and  (X_c-gds-hist.host-code  = p-host-code  or X_c-gds-hist.host-code = 0) ~
                        "
          &dyn_where-cond = " substitute(' X_c-gds-hist.gds-code  = &1  and  (X_c-gds-hist.host-code  = &2  or X_c-gds-hist.host-code = 0)' ~
                             ,p-gds-code  ~
                             ,p-host-code) "

          &use-ind    = " use-index idate  "
          &by         = "  " }
      END.
      WHEN {&g___object} THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Объект", filter-label0)
        .
        if p-open-query then do:
          ASSIGN
          frame {&frame-name}:TITLE = title0 + substitute(" Товар с кодом &1: &2 &3 &4&5 Объект: &6&7",
                                                            p-gds-code, v-gds-name, v-artic, v-prod-type, v-prod-code, p-obj-type, p-obj-code).
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-gds-hist.gds-code  = p-gds-code and ( X_c-gds-hist.host-code = 0 or (X_c-gds-hist.obj-type = p-obj-type and X_c-gds-hist.obj-code = p-obj-code))   ~
                        "
          &dyn_where-cond = " substitute(' X_c-gds-hist.gds-code  = &1 and ( X_c-gds-hist.host-code = 0 or (X_c-gds-hist.obj-type = &2&3&2 and X_c-gds-hist.obj-code = &4))'   ~
                         ,p-gds-code ~
                         ,~{&double-quote~} ~
                         ,p-obj-type ~
                         ,p-obj-code) "

          &use-ind    = " use-index idate "
          &by         = "  " }
      END.
      WHEN "one":u THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Один товар", filter-label0)
        .
        if p-open-query then do:
          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" Товар с кодом &1: &2 &3 &4&5",
                                                                                  p-gds-code, v-gds-name, v-artic, v-prod-type, v-prod-code ).
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-gds-hist.gds-code  = p-gds-code   ~
                        "
          &dyn_where-cond = " substitute(' X_c-gds-hist.gds-code  = &1', p-gds-code) "

          &use-ind    = " use-index idate "
          &by         = "  " }
      END.
      WHEN "subject":u THEN DO:
  &scop hn-gds-hist-code p-subject
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Предмет изменений", filter-label0)
        v-subject-chr = {&hn-gds-hist-name}
        .
        if p-open-query then do:
          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" Товар с кодом &1: &2 &3 &4&5, Предмет изменения &6",
                                                                                  p-gds-code, v-gds-name, v-artic, v-prod-type, v-prod-code, v-subject-chr ).
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-gds-hist.gds-code  = p-gds-code  and X_c-gds-hist.subject = p-subject ~
                        "
          &dyn_where-cond = " substitute(' X_c-gds-hist.gds-code  = &1  and X_c-gds-hist.subject = &2&3&2 ', p-gds-code, ~{&double-quote~}, p-subject) "
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
        filter-label = substitute("&1 Фирма", filter-label0)
        .
        if p-open-query then do:
          ASSIGN
          frame {&frame-name}:TITLE = title0 + substitute(" Товар с кодом &1: &2 &3 &4&5 Фирма: (&6) &7 БД: &8",
                                                            p-gds-code, v-gds-name, v-artic, v-prod-type, v-prod-code, p-host-code, X_clients.obj-name, p-db-num).
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-gds-hist.corr-user-db-num = p-db-num ANd X_c-gds-hist.gds-code  = p-gds-code  and  (X_c-gds-hist.host-code  = p-host-code  or X_c-gds-hist.host-code = 0) ~
                        "
          &dyn_where-cond = " substitute(' X_c-gds-hist.corr-user-db-num = &1 ANd X_c-gds-hist.gds-code  = &2  and  (X_c-gds-hist.host-code  = &3  or X_c-gds-hist.host-code = 0)' ~
                           ,p-db-num ~
                           ,p-gds-code  ~
                           ,p-host-code)  "

          &use-ind    = " use-index ishow "
          &by         = "  " }
      END.
      WHEN {&g___object} THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Объект", filter-label0)
        .
        if p-open-query then do:
          ASSIGN
          frame {&frame-name}:TITLE = title0 + substitute(" Товар с кодом &1: &2 &3 &4&5 Объект: &6&7 БД: &8",
                                                            p-gds-code, v-gds-name, v-artic, v-prod-type, v-prod-code, p-obj-type, p-obj-code, p-db-num).
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-gds-hist.corr-user-db-num = p-db-num ANd X_c-gds-hist.gds-code  = p-gds-code and ( X_c-gds-hist.host-code = 0 or (X_c-gds-hist.obj-type = p-obj-type and X_c-gds-hist.obj-code = p-obj-code))   ~
                        "
          &dyn_where-cond = " substitute(' X_c-gds-hist.corr-user-db-num = &1 ANd X_c-gds-hist.gds-code  = &2 and ( X_c-gds-hist.host-code = 0 or (X_c-gds-hist.obj-type = &3&4&3 and X_c-gds-hist.obj-code = &5)) '  ~
                         ,p-db-num ~
                         ,p-gds-code ~
                         ,~{&double-quote~} ~
                         ,p-obj-type ~
                         ,p-obj-code  )  "

          &use-ind    = " use-index ishow "
          &by         = "  " }
      END.
      WHEN "one":u THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Один товар", filter-label0)
        .
        if p-open-query then do:
          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" Товар с кодом &1: &2 &3 &4&5 БД: &6",
                                                                                  p-gds-code, v-gds-name, v-artic, v-prod-type, v-prod-code, p-db-num ).
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-gds-hist.corr-user-db-num = p-db-num ANd   X_c-gds-hist.gds-code  = p-gds-code   ~
                        "
          &dyn_where-cond = " substitute('  X_c-gds-hist.corr-user-db-num = &1 ANd   X_c-gds-hist.gds-code  = &2', p-db-num, p-gds-code ) "

          &use-ind    = " use-index ishow "
          &by         = "  " }
      END.
      WHEN "subject":u THEN DO:
  &scop hn-gds-hist-code p-subject
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Предмет изменений", filter-label0)
        v-subject-chr = {&hn-gds-hist-name}
        .
        if p-open-query then do:
          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" Товар с кодом &1: &2 &3 &4&5, Предмет изменения &6 БД: &7",
                                                                                  p-gds-code, v-gds-name, v-artic, v-prod-type, v-prod-code, v-subject-chr, p-db-num ).
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-gds-hist.corr-user-db-num = p-db-num ANd   X_c-gds-hist.gds-code  = p-gds-code  and X_c-gds-hist.subject = p-subject ~
                        "
          &dyn_where-cond = " substitute(' X_c-gds-hist.corr-user-db-num = &1 ANd   X_c-gds-hist.gds-code  =   and X_c-gds-hist.subject = &3&4&3' ~
                           ,p-db-num ~
                           ,p-gds-code ~
                           ,~{&double-quote~} ~
                           ,p-subject)   "

          &use-ind    = " use-index ishow "
          &by         = "  " }
      END.
    END CASE.
  end. /*otherwise <> ?*/
END CASE.

if not p-open-query  and v-doc-rec <> ? then
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
define variable v-source-type as character no-undo .

DEFINE FRAME HistoryList
X_c-gds-hist.gds-code
v-action-chr FORMAT "X(10)"
v-gds-name COLUMN-LABEL "Назв. товара" FORMAT "X(20)"
v-artic COLUMN-LABEL "Артикул" FORMAT "X(14)"
v-prod COLUMN-LABEL "Пр-ль" FORMAT "X(12)"
v-subject-chr COLUMN-LABEL "Предмет изменений" FORMAT "X(20)"
X_c-gds-hist.is-news COLUMn-LABEL "СПН" FORMAT "+/ "
v-source-type COLUMn-LABEL "Источн.!измен"
X_c-gds-hist.source-ref COLUMn-LABEL "№"
X_c-gds-hist.corr-date
v-upd-time COLUMN-LABEL "Время изм." FORMAT "X(8)"
X_c-gds-hist.corr-user-name
X_c-gds-hist.corr-user-db-num
X_c-gds-hist.host-code COLUMN-LABEL "Фирма"
v-obj COLUMN-LABEL "Объект" FORMAT "X(8)"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(192)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 192).
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
Line format "X(177)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME HistoryList  .
run waitfram-show in this-procedure ("Ждите...").
  GET next br-gds-hist.
    DO WHILE available X_c-gds-hist :
      Display STREAM PrnLibStream
      X_c-gds-hist.gds-code
      get-action(X_c-gds-hist.action) @ v-action-chr
      (if v-find then get-good(X_c-gds-hist.gds-code, output v-artic, output v-prod-type, output v-prod-code) else "":U )
      @ v-gds-name
      v-artic
      (v-prod-type + string(v-prod-code)) @ v-prod
      get-subject(X_c-gds-hist.subject) @ v-subject-chr
      X_c-gds-hist.is-news
      get-source-type(X_c-gds-hist.source-type) @ v-source-type
      X_c-gds-hist.source-ref
      X_c-gds-hist.corr-date
      string(X_c-gds-hist.corr-time, "HH:MM:SS":U) @ v-upd-time
      usrfulnf(X_c-gds-hist.corr-user-name)
      X_c-gds-hist.corr-user-db-num
      X_c-gds-hist.host-code
      X_c-gds-hist.obj-type + string(X_c-gds-hist.obj-code) @ v-obj
      with FRAME HistoryList .
  DOWN STREAM PrnLibStream 1 with FRAME HistoryList  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-gds-hist.
END.
UNDERLINE  STREAM PrnLibStream
X_c-gds-hist.gds-code
v-action-chr
v-gds-name
v-artic
v-prod
v-subject-chr
X_c-gds-hist.is-news
v-source-type
X_c-gds-hist.source-ref
X_c-gds-hist.corr-date
v-upd-time
X_c-gds-hist.corr-user-name
X_c-gds-hist.corr-user-db-num
X_c-gds-hist.host-code
v-obj
with FRAME HistoryList .
DISPLAY STREAM PrnLibStream
"ИТОГО"  @ X_c-gds-hist.gds-code
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
reposition br-gds-hist to recid v-doc-rec no-error.
apply "entry" to br-gds-hist in frame {&frame-name}.

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
  tbl = 'c-gds-hist'
  join-tbl = 'X_c-gds-hist'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('gds-code', 'Код товара', '',
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

run fltfield-add in this-procedure('b-code', 'Бар-код', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('b-str', 'ДопБК', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.



Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                    ,INPUT (filter-point + {&delim-par} +
                              filter-label0 + {&delim-par} +
                              string(yes))
                    ,INPUT tbl
                    ,INPUT join-tbl
                    ,INPUT fld
                    ,INPUT lab
                    ,INPUT spr
                    ,INPUT dim ).
  run OpenBr in this-procedure ( input yes, input no, input '':U, input v-corr-user-db-num).
END. /* Filter-Block */

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
0 @ sch-gds-code
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
        ,input substitute("and X_c-gds-hist.corr-date = &1 "
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
define input parameter p-db-num like ub.c-gds-hist.corr-user-db-num no-undo.
define variable v-db-num as character no-undo.
assign
sch-corr-date = ?
.
display
"":U @ sch-corr-user-name
0 @ sch-gds-code
sch-corr-date
with frame {&frame-name}.
assign
v-db-num = string(p-db-num).
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-gds-hist.corr-user-db-num = &1 "
      , v-db-num)
    ,input v-corr-user-db-num
    ).
apply "entry":u to sch-db-num in frame {&frame-name} .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-gds-code Dialog-Frame 
PROCEDURE proc-find-gds-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-gds-code like ub.c-gds-hist.gds-code no-undo.
define variable v-gds-code as character no-undo.
assign
sch-corr-date = ?.
display
"":U @ sch-corr-user-name
0 @ sch-db-num
sch-corr-date
with frame {&frame-name}.

assign
v-gds-code = string(p-gds-code).
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-gds-hist.gds-code = &1 "
      , v-gds-code)
    ,input v-corr-user-db-num
    ).
apply "entry":u to sch-gds-code in frame {&frame-name} .



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
define input parameter p-user like ub.c-gds-hist.corr-user-name no-undo.
assign
sch-corr-date = ?.
display
0 @ sch-db-num
sch-corr-date
0 @ sch-gds-code
with frame {&frame-name}.
p-user = {&double-quote} + p-user + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-gds-hist.corr-user-name = &1 "
      , p-user)
    ,input v-corr-user-db-num
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
define variable v-return as character no-undo .
assign
v-return =  {&hn-gds-hist-name} no-error.
if error-status:error then  do:
  message error-status:get-message(1) view-as alert-box .
  RETURN p-subject.
end.
else return v-return.
/* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

