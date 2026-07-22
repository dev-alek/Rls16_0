&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame



/* Temp-Table and Buffer definitions                                    */

&if defined (brwhistparam) eq 0
&then
&glob brwhistparam yes
&if defined ( objtt) ne 0
&then
define temp-table X_c-obj-hist like {&buf_obj-hist} {&addFields}.
DEFINE BUFFER find_c-obj-hist FOR X_c-obj-hist.
&else
DEFINE BUFFER X_c-obj-hist FOR {&buf_obj-hist}.
DEFINE BUFFER find_c-obj-hist FOR {&buf_obj-hist}.
&endif



DEFINE BUFFER X_curr-sysconf FOR sysconf.
DEFINE BUFFER X_db FOR db.
DEFINE BUFFER X_sysconf FOR sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список полной истории клиента

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/22/04
Author: Bakhtadze Natalya
Creation date: 01/22/04

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input     parameter parParentProc  as widget-handle no-undo.
/*контекст сессии*/
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo.
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo.
define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/
define input parameter p-mode  as char   no-undo .
define input parameter p-corr-user-db-num  like ub.c-cli-hist.corr-user-db-num no-undo .
define input parameter p-corr-user-name  like ub.c-cli-hist.corr-user-name no-undo .
define input parameter p-subject  like ub.c-cli-hist.subject no-undo .
/*стартуем с текущей БД обычно*/
define input parameter p-db-num  like ub.c-cli-hist.corr-user-db-num no-undo .
define input parameter p-chip-num  as int64 no-undo.

/*записи в выборке*/
define input-output param p-rid-list    as  char no-undo .
&endif
&if defined(Paramonly) eq 0
&then
/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список полной истории":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i noprocess}
{ gbl/fltfield.i }
{ gbl/prn-lib.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/color.i }
{ gbl/fltopend.i defproc }
/* define buffer X_cli-grp for ub.cli-grp. */
define variable filter-point as character no-undo init "cobjhist" .
define variable filter-point0 as character no-undo init "cobjhist" .
filter-point = program-name(1).
filter-point0 = filter-point.
define variable filter-label as character no-undo init "Список полной истории" .
define variable filter-label0 as character no-undo init "Список полной истории" .

define variable sort-column-name as character no-undo .
define variable print-option as character no-undo.
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-find as logical no-undo.
/*define variable v-cli-name like ub.clients.obj-name no-undo.*/
define variable v-start-date-chr as character no-undo .
define variable v-end-date-chr as character no-undo .
define variable v-subject-chr as character no-undo .
define variable v-rid-list as character no-undo .

/*вспомогат*/
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".
define variable v-show-reason as logical no-undo init ?.


define buffer X_curr_sysconf for ub.sysconf.
define buffer X_clients-sysconf for ub.clients.
define buffer X_clients-obj for ub.clients.
&scop label-user "Изменил"
&scop label-subject "Предмет изменения"

{ ref/tmpchgs.i " " "temp-changes" "with-action"}

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
&Scoped-define INTERNAL-TABLES temp-changes X_c-obj-hist

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes   
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE br-obj-hist                                   */
&Scoped-define FIELDS-IN-QUERY-br-obj-hist mark-string(recid(X_c-obj-hist), v-rid-list) X_c-obj-hist.corr-date string(X_c-obj-hist.corr-time, "HH:MM:SS":U) usrfulnf(X_c-obj-hist.corr-user-name) get-action(X_c-obj-hist.action) X_c-obj-hist.corr-user-db-num X_c-obj-hist.is-news get-source-type(X_c-obj-hist.source-type) X_c-obj-hist.source-ref   get-subject(X_c-obj-hist.subject)   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-obj-hist X_c-obj-hist.corr-date   
&Scoped-define ENABLED-TABLES-IN-QUERY-br-obj-hist X_c-obj-hist
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-obj-hist X_c-obj-hist
&Scoped-define SELF-NAME br-obj-hist
&Scoped-define QUERY-STRING-br-obj-hist FOR EACH X_c-obj-hist NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-obj-hist OPEN QUERY {&SELF-NAME} FOR EACH X_c-obj-hist NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-obj-hist X_c-obj-hist
&Scoped-define FIRST-TABLE-IN-QUERY-br-obj-hist X_c-obj-hist


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel v-corr-user-db-num ~
b-reason B-print B-sch B-Help br-obj-hist sch-db-num sch-corr-date ~
sch-obj-code sch-corr-user-name BR-changes mark-num b-nextlevel
&Scoped-Define DISPLAYED-OBJECTS v-corr-user-db-num sch-db-num ~
sch-corr-date sch-obj-code sch-corr-user-name mark-num 

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD local-open-br Dialog-Frame 
FUNCTION local-open-br RETURNS logical
  (  p-open-query     as logical    ,
  p-find-next       as logical    ,
  p-find-condition as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

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

DEFINE BUTTON b-reason 
     LABEL "&Причина" 
     SIZE 10 BY 1.

DEFINE BUTTON B-sch 
     LABEL "&Фильтр" 
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
     LABEL "Вы&бор" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-nextlevel 
     LABEL "Детали" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sch-obj-code AS CHARACTER FORMAT "X(50)":U 
     LABEL "коду" 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

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

DEFINE VARIABLE v-corr-user-db-num AS INTEGER FORMAT ">>>>9":U INITIAL 0 
     LABEL "по БД" 
     VIEW-AS FILL-IN 
     SIZE 6 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR 
      temp-changes SCROLLING.

DEFINE QUERY br-obj-hist FOR 
      X_c-obj-hist SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(200)" width 40
temp-changes.v_old COLUMn-LABEL "Было" format "X(255)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(255)"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.25.

DEFINE BROWSE br-obj-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-obj-hist Dialog-Frame _FREEFORM
  QUERY br-obj-hist NO-LOCK DISPLAY
      mark-string(recid(X_c-obj-hist), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      {&browse-fields}      
      X_c-obj-hist.corr-date FORMAT "99/99/9999":U COLUMN-LABEL "Дата изм."
      string(X_c-obj-hist.corr-time, "HH:MM:SS":U) COLUMN-LABEL "Время изм." FORMAT "X(8)":U
      usrfulnf(X_c-obj-hist.corr-user-name) COLUMn-LABEL {&label-user} FORMAT "X(255)":U width 18
      get-action(X_c-obj-hist.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
      X_c-obj-hist.corr-user-db-num FORMAT ">>>>9":U COLUMN-LABEL "Дб!созд."
      &if defined (objhead) ne 0 &then
      X_c-obj-hist.is-news FORMAT "+/":U COLUMN-LABEL "Прием.!нов."
      
      get-source-type(X_c-obj-hist.source-type) COLUMN-LABEL "Источн.!измен." WIDTH 7
      X_c-obj-hist.source-ref FORMAT "X(20)":U COLUMN-LABEL "Ссылка на!источник." WIDTH 9
       get-subject(X_c-obj-hist.subject) COLUMN-LABEL {&label-subject} FORMAT "X(35)":U WIDTH 15
      &endif
  ENABLE
      X_c-obj-hist.corr-date
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 11.46.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     v-corr-user-db-num AT ROW 1 COL 37 COLON-ALIGNED
     b-nextlevel AT ROW 1 COL 70
     b-reason AT ROW 1 COL 59
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     br-obj-hist AT ROW 2 COL 1
     sch-db-num AT ROW 13.63 COL 60.13 COLON-ALIGNED
     sch-corr-date AT ROW 13.63 COL 85.75 COLON-ALIGNED
     sch-obj-code AT ROW 13.67 COL 45.13 COLON-ALIGNED
     sch-corr-user-name AT ROW 13.71 COL 22.5 COLON-ALIGNED
     BR-changes AT ROW 14.79 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 8.38 BY 1 AT ROW 13.63 COL 1.38
          FGCOLOR 4 
     SPACE(89.48) SKIP(7.44)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE 
         &if defined (lable) ne 0 &then
         {&lable}
         &else
         "Полная история"
         &endif
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_c-obj-hist B "?" NO-UNDO ub {&buf_obj-hist}
      TABLE: X_c-obj-hist B "?" ? ub {&buf_obj-hist}
      TABLE: X_curr-sysconf B "?" ? ub sysconf
      TABLE: X_db B "?" ? ub db
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-obj-hist B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes sch-corr-user-name Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       br-obj-hist:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-obj-hist
/* Query rebuild information for BROWSE br-obj-hist
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-obj-hist NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-obj-hist */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Полная история по контрагенту */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Полная история по контрагенту */
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
  if available X_c-obj-hist then do:
    { gbl/markstrn.i X_c-obj-hist  v-rid-list }
    loc#log = br-obj-hist:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-obj-hist:select-next-row ().
        apply "VALUE-CHANGED" to br-obj-hist in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-obj-hist in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-nextlevel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-nextlavel Dialog-Frame
ON CHOOSE OF b-nextlevel IN FRAME Dialog-Frame /* * */
DO:
   define variable vRun as character no-undo.
   vRun = this-procedure:file-name.
   &if defined(proc_nextlevel) &then
   vRun = "{&proc_nextlevel}".    
   &endif
   
   run value(vRun)
      (
       &if defined(param_1) &then {&param_1}, &endif
       &if defined(param_2) &then {&param_2}, &endif
       &if defined(param_3) &then {&param_3}, &endif
       &if defined(param_4) &then {&param_4}, &endif
       &if defined(param_5) &then {&param_5}, &endif
       &if defined(param_6) &then {&param_6}, &endif
       &if defined(param_7) &then {&param_7}, &endif
       &if defined(param_8) &then {&param_8}, &endif
       &if defined(param_9) &then {&param_9}, &endif
       parParentProc,
      /*контекст сессии*/
       p-curr-host-code,
       p-curr-obj-type,
       p-curr-obj-code,
       bttns,
      /*кнопки для нажатия*/
       "one",
       p-corr-user-db-num,
       p-corr-user-name,
       p-subject,
      /*стартуем с текущей БД обычно*/
       p-db-num,
       X_c-obj-hist.chip-num ,
       input-output p-rid-list ).
   apply "entry" to br-obj-hist in frame {&frame-name}.
END.


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
  if ( available X_c-obj-hist ) then do:
    if ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_c-obj-hist ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-obj-hist
&Scoped-define SELF-NAME br-obj-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-obj-hist Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-obj-hist IN FRAME Dialog-Frame
DO:
     run proc-br-obj-hist in this-procedure no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-obj-hist Dialog-Frame
ON RETURN OF br-obj-hist IN FRAME Dialog-Frame
DO:
    run proc-br-obj-hist in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-obj-hist Dialog-Frame
ON VALUE-CHANGED OF br-obj-hist IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&if defined(VisibleKeyField) ne 0
&then
&Scoped-define SELF-NAME sch-obj-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-obj-code Dialog-Frame
ON ROW-DISPLAY OF BR-changes IN FRAME Dialog-Frame /* коду */
DO:
   if temp-changes.fNotChange
   then do:
      temp-changes.l_name:fGCOLOR in browse BR-changes = GRAY_COLOR.
      temp-changes.v_old:fGCOLOR in browse BR-changes  = GRAY_COLOR.
      temp-changes.v_new:fGCOLOR in browse BR-changes  = GRAY_COLOR.
   end.
   else do:
      temp-changes.l_name:fGCOLOR in browse BR-changes = BLACK_COLOR.
      temp-changes.v_old:fGCOLOR in browse BR-changes = BLACK_COLOR.
      temp-changes.v_new:fGCOLOR in browse BR-changes = BLACK_COLOR.
   end.
   
          
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&endif

&Scoped-define SELF-NAME sch-obj-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-obj-code Dialog-Frame
ON CTRL-J OF sch-obj-code IN FRAME Dialog-Frame /* коду */
DO:
  run proc-find-obj-code in this-procedure(yes, input frame {&frame-name} sch-obj-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-obj-code Dialog-Frame
ON RETURN OF sch-obj-code IN FRAME Dialog-Frame /* коду */
DO:
  run proc-find-obj-code in this-procedure(no, input frame {&frame-name} sch-obj-code) no-error.
  if error-status:error then return no-apply.
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
{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-obj-hist" }
{ gbl/brwrefre.i "v-doc-rec = recid(X_c-obj-hist). run OpenBr(yes, no, no, v-corr-user-db-num). reposition br-obj-hist to recid v-doc-rec no-error. ~
              apply 'value-changed' to br-obj-hist. " }

{ gbl/setfltnm.i }
{ gbl/ed_date.i sch-corr-date}

{ gbl/srt-clmd.i
  &browse-name    = "br-obj-hist"
  &frame-name     = "{&frame-name}"
  &table-name     = "X_c-obj-hist"
  &sort-clmn_1    = "X_c-obj-hist.corr-date"
  &sort-clmn_2    = "X_c-obj-hist.corr-user-db-num"
  &open-query     = "run OpenBr(yes, no, no, v-corr-user-db-num)."
  &open-query-otherwise = "run OpenBr(yes, no, no, v-corr-user-db-num)."
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
 and p-mode <> "subject":U
 and p-mode <> "parentbeg":U
 then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return.
 end.
/*
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
*/
 v-rid-list = p-rid-list.
 /*
 if p-mode = {&company} then do:
  find first X_clients-sysconf no-lock where
                X_clients-sysconf.obj-type = {&cmp}
            and X_clients-sysconf.obj-code = p-host-code no-error.
    if not available X_clients-sysconf then do:
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

 if p-mode = "one":U then do:
  find first X_clients no-lock where
                X_clients.obj-type = p-obj-type
            AND X_clients.obj-code = p-obj-code  no-error.
    if not available X_clients then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-cli-type p-cli-code" p-obj-type p-obj-code
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
*/
  if v-rid-list <> "" then do:
      FIND FIRST find_c-obj-hist No-LOCK where
                 recid(find_c-obj-hist) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_c-obj-hist then do:
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
    
  end.
  RUN MyEnable.
  RUn OpenBR(yes, no, '':U, v-corr-user-db-num).
  HIDE mark-num in frame {&frame-name} .
  if v-rid-list <> "":U then
  REPOSITION br-obj-hist to recid integer(entry(1, v-rid-list)) No-ERROR.
  &if defined (objhead) ne 0 &then
  { gbl/mv-clmn.i
    &browse-name = "br-obj-hist"
    &frame-name = "{&frame-name}"
    &ext-col = 10
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10'"
    &prev-order-column-condition_1 = " p-mode = {&all} "
    &prev-order-column_2 = "'1,2,3,5,6,7,8,9,4,10'"
    &prev-order-column-condition_2 = " p-mode <> {&all} "
    }
  &else
     { gbl/mv-clmn.i
    &browse-name = "br-obj-hist"
    &frame-name = "{&frame-name}"
    &ext-col = 6
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6'"
    &prev-order-column-condition_1 = " p-mode = {&all} "
    &prev-order-column_2 = "'1,2,3,5,6'"
    &prev-order-column-condition_2 = " p-mode <> {&all} "
    }
  
  &endif  
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
  DISPLAY v-corr-user-db-num sch-db-num sch-corr-date sch-obj-code 
          sch-corr-user-name mark-num 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel v-corr-user-db-num B-print B-sch 
         B-Help br-obj-hist sch-db-num sch-corr-date sch-obj-code 
         sch-corr-user-name BR-changes mark-num b-nextlevel
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
DEFINE VARIABLE v-h AS handle NO-UNDO.
assign
br-obj-hist:num-locked-columns in frame {&frame-name} = 1
X_c-obj-hist.corr-date:read-only in browse br-obj-hist = yes
br-changes:title = "":U
v-corr-user-db-num = v-db-num
temp-changes.l_name:resizable in browse br-changes = true
temp-changes.v_old:resizable in browse br-changes = true
temp-changes.v_new:resizable in browse br-changes = true
temp-changes.l_name:width in browse br-changes = 30
temp-changes.v_old:width in browse br-changes = 40
temp-changes.v_new:width in browse br-changes = 40
v-h = br-obj-hist:FIRST-COLUMN IN FRAME {&FRAME-NAME}
.
DO while valid-handle(v-h) :
  if v-h:LABEL = {&label-subject}
  or v-h:LABEL = {&label-user}
    then do:
    v-h:RESIZABLE = YES.
  end.
    v-h = v-h:NEXT-COLUMN.
  END.
DISPLAY
v-corr-user-db-num
sch-db-num
sch-corr-date
sch-obj-code
sch-corr-user-name
mark-num
WITH FRAME {&FRAME-NAME}.
ENABLE
v-corr-user-db-num
b-quit
B-mark when lookup("b-mark":U, bttns) > 0
b-sel when lookup("b-sel":U, bttns) > 0

B-sch
B-Print
B-Help
br-obj-hist
sch-corr-date
sch-corr-user-name
sch-obj-code when p-mode = {&all}
sch-db-num when p-mode = {&all}
BR-changes mark-num
b-nextlevel
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.

HIDE sch-corr-user-name IN FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define input  parameter p-db-num like {&buf_obj-hist}.corr-user-db-num no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Список полной истории контрагента" + {&space-char}.
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


&glob flt-open-open-query OPEN QUERY br-obj-hist FOR EACH X_c-obj-hist

&glob flt-open-dyn_open-query  FOR EACH X_c-obj-hist

&glob flt-open-query-handle query br-obj-hist:handle

&glob flt-open-open-query-tail

&glob flt-open-query-was-opened  l-query-was-opened

&glob flt-open-sort-column-phrase sort-column-phrase

&glob flt-open-call-point filter-point

&glob flt-open-set-filter-name set-filter-name

&glob flt-open-indexed-reposition indexed-reposition

&glob flt-open-query p-open-query

&glob flt-open-table-name X_c-obj-hist

&glob flt-open-search-option no-lock

&glob flt-open-find-next p-find-next

&glob flt-open-find-recid v-doc-rec

&glob flt-open-find-condition p-find-condition

&glob flt-open-find-buffer-name X_c-obj-hist

&glob flt-open-waitfram yes

define variable l-open-query as logical   no-undo .

/*run gbl/inidebug.p.*/
if p-mode = {&all} then
do:
      assign
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1", filter-label0)
      .
  { gbl/fltopend.i
       &where-cond = " TRUE "
       &by         = " BY X_c-obj-hist.corr-date DESC BY X_c-obj-hist.corr-time DESC {&by-sort} "
       &use-ind    = " BY X_c-obj-hist.corr-date DESC BY X_c-obj-hist.corr-time DESC {&by-sort} " 
  }
end.
else do:
  if not local-open-br( p-open-query      ,
                        p-find-next         ,
                       p-find-condition )
  then do:
      { gbl/fltopend.i
            &where-cond = " TRUE "
            
            &by         = "  " }
          
  end.
end.
/*
CASE p-db-num:
  when ? then do:
    CASE p-mode :
      WHEN {&all}        THEN DO:
      assign
      filter-point = filter-point0 + p-mode
      filter-label = filter-label0
      .
      { gbl/fltopend.i
          &where-cond = " TRUE "
          &use-ind    = " use-index idate "
          &by         = "  " }
      END.
      
     
      WHEN "subject":u THEN DO:
  &scop hn-cli-hist-code p-subject
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1: Предмет изменения", filter-label0)
        v-subject-chr = {&hn-cli-hist-name}
        .
        if p-open-query then do:
          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" Контрагент &1&2: &3, Предмет изменения &4",
                                                                p-obj-type, p-obj-code, v-cli-name, v-subject-chr ).
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-cli-hist.obj-type  = p-obj-type AND  ~
          X_c-cli-hist.obj-code  = p-obj-code AND  ~
          X_c-cli-hist.subject = p-subject ~
                        "
          &dyn_where-cond = " substitute(' X_c-cli-hist.obj-type  = &1&2&1 AND  ~
          X_c-cli-hist.obj-code  = &2 AND  ~
          X_c-cli-hist.subject = &1&4&1 ', ~{&double-quote~}, p-obj-type, p-obj-code, p-subject)   "
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
        filter-label = substitute("&1: Фирма", filter-label0)
        .
        if p-open-query then do:
          ASSIGN
          frame {&frame-name}:TITLE = title0 + substitute(" Контрагент &1&2: &3 Фирма: (&4) &5 БД: &6",
                                                            p-obj-type, p-obj-code, v-cli-name, p-host-code, X_clients-sysconf.obj-name, p-db-num).
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-cli-hist.corr-user-db-num = p-db-num ANd  ~
          X_c-cli-hist.obj-type  = p-obj-type  and  ~
            X_c-cli-hist.obj-code  = p-obj-code  and  ~
          (X_c-cli-hist.host-code  = p-host-code  or X_c-cli-hist.host-code = 0) ~
                        "
          &dyn_where-cond = " substitute(' X_c-cli-hist.corr-user-db-num = &1 ANd  ~
          X_c-cli-hist.obj-type  = &2&3&2  and  ~
            X_c-cli-hist.obj-code  = &4  and  ~
          (X_c-cli-hist.host-code  = &5  or X_c-cli-hist.host-code = 0)', p-db-num , ~{&double-quote~}, p-obj-type, p-obj-code, p-host-code)   "

          &use-ind    = " use-index ishow "
          &by         = "  " }
      END.
      WHEN "one":u THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1: Один клиент", filter-label0)
        .
        if p-open-query then do:
          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" Контрагент &1&2: &3 БД: &4",
                                                                p-obj-type, p-obj-code, v-cli-name, p-db-num ).
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-cli-hist.corr-user-db-num = p-db-num ANd  ~
          X_c-cli-hist.obj-type  = p-obj-type AND  ~
          X_c-cli-hist.obj-code  = p-obj-code   ~
                        "
          &dyn_where-cond = " substitute(' X_c-cli-hist.corr-user-db-num = &1 ANd  ~
          X_c-cli-hist.obj-type  = &2&3&2 AND  ~
          X_c-cli-hist.obj-code  = &4 ', p-db-num, ~{&double-quote~}, p-obj-type, p-obj-code)  "

          &use-ind    = " use-index ishow "
          &by         = "  " }
      END.
      WHEN "subject":u THEN DO:
  &scop hn-cli-hist-code p-subject
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1: Предмет изменений", filter-label0)
        v-subject-chr = {&hn-cli-hist-name}
        .
        if p-open-query then do:
          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" Контрагент &1&2: &3, Предмет изменения &4 БД: &5",
                                                                p-obj-type, p-obj-code, v-cli-name, v-subject-chr, p-db-num ).
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-cli-hist.corr-user-db-num = p-db-num  AND ~
          X_c-cli-hist.obj-type  = p-obj-type AND  ~
          X_c-cli-hist.obj-code  = p-obj-code AND  ~
          X_c-cli-hist.subject = p-subject ~
                        "
          &dyn_where-cond = " substitute('  X_c-cli-hist.corr-user-db-num = &1  AND ~
          X_c-cli-hist.obj-type  = &2&3&2 AND  ~
          X_c-cli-hist.obj-code  = &4 AND  ~
          X_c-cli-hist.subject = &2&5&2 ', p-db-num, ~{&double-quote~}, p-obj-type, p-obj-code, p-subject)  "

          &use-ind    = " use-index ishow "
          &by         = "  " }
      END.
    END CASE.
  end.
END CASE.
*/
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-obj-hist to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-obj-hist:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .

APPLY "VALUE-CHANGED" TO br-obj-hist in frame {&frame-name}.
APPLY "ENTRY" TO br-obj-hist.


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
define variable v-subject-chr as character no-undo .
define variable v-upd-time as character no-undo .
define variable v-obj as character no-undo .
define variable v-action-chr as character no-undo .
define variable v-source-type as character no-undo .

DEFINE FRAME HistoryList

v-action-chr FORMAT "X(10)" COLUMN-LABEL "Действие"
&if defined (objhead) ne 0 &then
v-subject-chr COLUMN-LABEL "Предмет изменений" FORMAT "X(20)"

X_c-obj-hist.is-news COLUMn-LABEL "СПН" FORMAT "+/ "
v-source-type COLUMn-LABEL "Источн.!измен"
X_c-obj-hist.source-ref COLUMn-LABEL "№"
&endif
X_c-obj-hist.corr-date
v-upd-time COLUMN-LABEL "Время изм." FORMAT "X(8)"
X_c-obj-hist.corr-user-name
X_c-obj-hist.corr-user-db-num

HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 195).
date_string = cur-time-print() .
assign
v-doc-rec = recid( X_c-obj-hist ).
DO WHILE available X_c-obj-hist :
      GET prev br-obj-hist.
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
  GET next br-obj-hist.
    DO WHILE available X_c-obj-hist :
      Display STREAM PrnLibStream
       get-action(X_c-obj-hist.action) @ v-action-chr
       &if defined (objhead) ne 0 &then
       get-subject(X_c-obj-hist.subject) @ v-subject-chr
      X_c-obj-hist.is-news
      get-source-type(X_c-obj-hist.source-type) @ v-source-type
      X_c-obj-hist.source-ref
      &endif
      X_c-obj-hist.corr-date
      string(X_c-obj-hist.corr-time, "HH:MM:SS":U) @ v-upd-time
      X_c-obj-hist.corr-user-name
      X_c-obj-hist.corr-user-db-num
      with FRAME HistoryList .
  DOWN STREAM PrnLibStream 1 with FRAME HistoryList  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-obj-hist.
END.
UNDERLINE  STREAM PrnLibStream

v-action-chr

v-subject-chr
&if defined (objhead) ne 0 &then
X_c-obj-hist.is-news
v-source-type
X_c-obj-hist.source-ref
&endif
X_c-obj-hist.corr-date
v-upd-time
X_c-obj-hist.corr-user-name
X_c-obj-hist.corr-user-db-num

with FRAME HistoryList .
DISPLAY STREAM PrnLibStream
"ИТОГО"  @ v-obj
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
reposition br-obj-hist to recid v-doc-rec no-error.
apply "entry" to br-obj-hist in frame {&frame-name}.

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
  tbl = "{&buf_obj-hist}"
  join-tbl = 'X_c-obj-hist'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .

run fltfield-add in this-procedure('corr-date', 'Дата корр.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время корр.', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', 'БД корр.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('action', 'Действие', 'hist-action',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
&if defined (objhead) ne 0 &then
run fltfield-add in this-procedure('subject', 'Предмет изменения', 'obj-hist-subject',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('source-type', 'Источник измен-я', 'hist-source-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('source-ref', 'Код источника измен-я', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

&endif




Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                   , INPUT filter-point + {&delim-par} + filter-label
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
0 @ sch-obj-code
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
        ,input substitute("and X_c-obj-hist.corr-date = &1 "
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
define input parameter p-db-num like {&buf_obj-hist}.corr-user-db-num no-undo.
define variable v-db-num as character no-undo.
assign
sch-corr-date = ?
.
display
"":U @ sch-corr-user-name
0 @ sch-obj-code
sch-corr-date
with frame {&frame-name}.
assign
v-db-num = string(p-db-num).
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-obj-hist.corr-user-db-num = &1 "
      , v-db-num)
    ,input v-corr-user-db-num
    ).
apply "entry":u to sch-db-num in frame {&frame-name} .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-user Dialog-Frame 
PROCEDURE proc-find-user :
define input parameter p-next as logical no-undo.
define input parameter p-user like {&buf_obj-hist}.corr-user-name no-undo.
assign
sch-corr-date = ?.
display
0 @ sch-db-num
sch-corr-date
0 @ sch-obj-code
with frame {&frame-name}.
p-user = {&double-quote} + p-user + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-obj-hist.corr-user-name = &1 "
      , p-user)
    ,input v-corr-user-db-num
    ).
apply "entry":u to sch-corr-user-name in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame 
PROCEDURE proc-view-changes :
define variable v-description as character no-undo .

for each temp-changes:
    delete temp-changes.
END.
if not available X_c-obj-hist then do:
  b-nextlevel:visible IN FRAME Dialog-Frame = no.
  Open QUery br-changes for each temp-changes.
  return.
end.

b-nextlevel:visible IN FRAME Dialog-Frame = &if defined (objhead) ne 0 &then X_c-obj-hist.subject eq "*" &ELSE no &ENDIF. 
/*
run ref/cclihisv.p (
                   input X_c-cli-hist.obj-type
                  ,input X_c-cli-hist.obj-code
                  ,input X_c-cli-hist.chip-num
                  ,input X_c-cli-hist.corr-user-db-num
                  ,input X_c-cli-hist.host-code
                  ,input X_c-cli-hist.subject
                  ,input X_c-cli-hist.action
                  ,input no /*p-silent*/
                  ,output v-description
               ) no-error . */
run local-view-cange in this-procedure (output v-description) .              
Open QUery br-changes for each temp-changes by temp-changes.fNotChange.
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
v-dop = {&hn-source-name}
no-error
.
RETURN v-dop.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&endif
