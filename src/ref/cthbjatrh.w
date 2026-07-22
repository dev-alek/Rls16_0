&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER find_c-thbj-attr FOR c-thbj-attr.
DEFINE BUFFER X_c-thbj-attr FOR c-thbj-attr.
DEFINE BUFFER X_curr-sysconf FOR sysconf.
DEFINE BUFFER X_db FOR db.
DEFINE BUFFER X_sysconf FOR sysconf.
DEFINE BUFFER X_thbj-attr FOR thbj-attr.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список полной истории настроек объектов TH

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
/*define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.*/
/*define input parameter p-curr-obj-type like ub.clients.obj-type no-undo.  */
/*define input parameter p-curr-obj-code like ub.clients.obj-code no-undo.  */

define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/

define input parameter p-mode  as char   no-undo .
/*может быть {&all} "one":U "subject":U */
define input parameter p-obj-type like ub.c-thbj-attr.obj-type no-undo.
define input parameter p-obj-code like ub.c-thbj-attr.obj-code no-undo.
define input parameter p-upper-prop-code as character no-undo .
define input parameter p-prop-code as character no-undo .
define input parameter p-corr-user-db-num  like ub.c-thbj-attr.corr-user-db-num no-undo .
define input parameter p-corr-user-name  like ub.c-thbj-attr.corr-user-name no-undo .
define input parameter p-subject  as character no-undo .
/*стартуем с текущей БД обычно*/
/*define input parameter p-db-num  like ub.c-thbj-attr.corr-user-db-num no-undo .*/


/*записи в выборке*/
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список полной истории настроек объектов TH":U.
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
{ gbl/get-regf.i }
{ gbl/thbjattr.i }
define buffer X_cli-grp for ub.cli-grp.
define variable filter-point as character no-undo init "cthbjatr" .
define variable filter-point0 as character no-undo init "cthbjatr" .
define variable filter-label as character no-undo init "Список полной истории настроек объектов IBS TH" .
define variable filter-label0 as character no-undo init "Список полной истории настроек объектов IBS TH" .

define variable sort-column-name as character no-undo .
define variable print-option as character no-undo.
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-find as logical no-undo.
define variable v-param-name as character no-undo .
define variable v-start-date-chr as character no-undo .
define variable v-end-date-chr as character no-undo .
define variable v-subject-chr as character no-undo .
define variable v-rid-list as character no-undo .
define variable v-dop as character no-undo .
define variable v-section-name as character no-undo .

/*вспомогат*/
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".


define buffer X_curr_sysconf for ub.sysconf.
define buffer X_clients-sysconf for ub.clients.
define buffer X_clients-obj for ub.clients.

&scop label-1 "Назв. пар-ра"
&scop label-2 "Предмет изменений"

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
&Scoped-define INTERNAL-TABLES temp-changes X_c-thbj-attr

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes   
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE br-thbj-attr                                  */
&Scoped-define FIELDS-IN-QUERY-br-thbj-attr mark-string(recid(X_c-thbj-attr), v-rid-list) X_c-thbj-attr.corr-date string(X_c-thbj-attr.corr-time, "HH:MM:SS":U) usrfulnf(X_c-thbj-attr.corr-user-name) get-action(X_c-thbj-attr.action) X_c-thbj-attr.corr-user-db-num X_c-thbj-attr.is-news X_c-thbj-attr.obj-type + string(X_c-thbj-attr.obj-code) if v-find then get-param-name(X_c-thbj-attr.upper-prop-code, X_c-thbj-attr.prop-code, output v-dop) else "":U   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-thbj-attr X_c-thbj-attr.corr-date   
&Scoped-define ENABLED-TABLES-IN-QUERY-br-thbj-attr X_c-thbj-attr
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-thbj-attr X_c-thbj-attr
&Scoped-define SELF-NAME br-thbj-attr
&Scoped-define QUERY-STRING-br-thbj-attr FOR EACH X_c-thbj-attr NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-thbj-attr OPEN QUERY {&SELF-NAME} FOR EACH X_c-thbj-attr NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-thbj-attr X_c-thbj-attr
&Scoped-define FIRST-TABLE-IN-QUERY-br-thbj-attr X_c-thbj-attr


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel v-corr-user-db-num ~
b-lookup B-print B-sch B-Help br-thbj-attr sch-db-num sch-corr-date ~
sch-cli-code sch-corr-user-name BR-changes mark-num 
&Scoped-Define DISPLAYED-OBJECTS v-corr-user-db-num sch-db-num ~
sch-corr-date sch-cli-code sch-corr-user-name mark-num 

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-param-name Dialog-Frame 
FUNCTION get-param-name RETURNS CHARACTER
  (p-upper-prop-code as character, p-prop-code as character, output p-section-name as character )  FORWARD.

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

DEFINE BUTTON b-lookup 
     LABEL "Button 1" 
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

DEFINE VARIABLE sch-cli-code AS INTEGER FORMAT ">>>>>>9":U INITIAL 0 
     LABEL "коду" 
     VIEW-AS FILL-IN 
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

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

DEFINE QUERY br-thbj-attr FOR 
      X_c-thbj-attr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(40)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(255)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(255)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.25.

DEFINE BROWSE br-thbj-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-thbj-attr Dialog-Frame _FREEFORM
  QUERY br-thbj-attr NO-LOCK DISPLAY
      mark-string(recid(X_c-thbj-attr), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_c-thbj-attr.corr-date FORMAT "99/99/9999":U
      string(X_c-thbj-attr.corr-time, "HH:MM:SS":U) COLUMN-LABEL "Время изм." FORMAT "X(8)":U
      usrfulnf(X_c-thbj-attr.corr-user-name) FORMAT "X(18)":U
      get-action(X_c-thbj-attr.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
      X_c-thbj-attr.corr-user-db-num FORMAT ">>>>9":U
      X_c-thbj-attr.is-news FORMAT "+/":U
      X_c-thbj-attr.obj-type + string(X_c-thbj-attr.obj-code) COLUMN-LABEL "Объект" FORMAT "X(12)":U
      if v-find then get-param-name(X_c-thbj-attr.upper-prop-code, X_c-thbj-attr.prop-code, output v-dop) else "":U COLUMN-LABEL {&label-1} FORMAT "X(25)":U
  ENABLE
      X_c-thbj-attr.corr-date
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 11.46.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     v-corr-user-db-num AT ROW 1 COL 37 COLON-ALIGNED
     b-lookup AT ROW 1 COL 60 WIDGET-ID 2
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     br-thbj-attr AT ROW 2 COL 1
     sch-db-num AT ROW 13.63 COL 60.13 COLON-ALIGNED
     sch-corr-date AT ROW 13.63 COL 85.75 COLON-ALIGNED
     sch-cli-code AT ROW 13.67 COL 48.13 COLON-ALIGNED
     sch-corr-user-name AT ROW 13.71 COL 22.5 COLON-ALIGNED
     BR-changes AT ROW 14.79 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 8.38 BY 1 AT ROW 13.63 COL 1.38
          FGCOLOR 4 
     SPACE(89.48) SKIP(7.44)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "История по параметрам"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_c-thbj-attr B "?" NO-UNDO ub c-thbj-attr
      TABLE: X_c-thbj-attr B "?" ? ub c-thbj-attr
      TABLE: X_curr-sysconf B "?" ? ub sysconf
      TABLE: X_db B "?" ? ub db
      TABLE: X_sysconf B "?" ? ub sysconf
      TABLE: X_thbj-attr B "?" ? ub thbj-attr
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-thbj-attr B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes sch-corr-user-name Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       b-lookup:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN 
       br-thbj-attr:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-thbj-attr
/* Query rebuild information for BROWSE br-thbj-attr
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-thbj-attr NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-thbj-attr */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* История по параметрам */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История по параметрам */
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
  if available X_c-thbj-attr then do:
    { gbl/markstrn.i X_c-thbj-attr  v-rid-list }
    loc#log = br-thbj-attr:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-thbj-attr:select-next-row ().
        apply "VALUE-CHANGED" to br-thbj-attr in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-thbj-attr in frame {&frame-name}.
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
  if ( available X_c-thbj-attr ) then do:
    if ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_c-thbj-attr ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-thbj-attr
&Scoped-define SELF-NAME br-thbj-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-thbj-attr Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-thbj-attr IN FRAME Dialog-Frame
DO:
     run proc-br-thbj-attr in this-procedure no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-thbj-attr Dialog-Frame
ON RETURN OF br-thbj-attr IN FRAME Dialog-Frame
DO:
    run proc-br-thbj-attr in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-thbj-attr Dialog-Frame
ON VALUE-CHANGED OF br-thbj-attr IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-cli-code Dialog-Frame
ON CTRL-J OF sch-cli-code IN FRAME Dialog-Frame /* коду */
DO:
  run proc-find-obj-code in this-procedure(yes, input frame {&frame-name} sch-cli-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-cli-code Dialog-Frame
ON RETURN OF sch-cli-code IN FRAME Dialog-Frame /* коду */
DO:
  run proc-find-obj-code in this-procedure(no, input frame {&frame-name} sch-cli-code) no-error.
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
  RUn OpenBR in this-procedure ( input yes
                                ,input no
                                ,input '':U
                                ,input  v-corr-user-db-num).
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
{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-thbj-attr" }
{ gbl/brwrefre.i "v-doc-rec = recid(X_c-thbj-attr). run OpenBr in this-procedure ( input yes, input no, input no, input v-corr-user-db-num). reposition br-thbj-attr to recid v-doc-rec no-error. ~
              apply 'value-changed' to br-thbj-attr. " }

{ gbl/setfltnm.i }
{ gbl/ed_date.i sch-corr-date}

{ gbl/srt-clmd.i
  &browse-name    = "br-thbj-attr"
  &frame-name     = "{&frame-name}"
  &table-name     = "X_c-thbj-attr"
  &sort-clmn_1    = "X_c-thbj-attr.corr-date"
  &sort-clmn_2    = "X_c-thbj-attr.corr-user-db-num"
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
  and p-mode <> "one":U
 and p-mode <> "subject":U
 and p-mode <> "section":U
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
 if p-mode = "one":U then do:
  find first X_thbj-attr no-lock where
                X_thbj-attr.obj-type = p-obj-type
            AND X_thbj-attr.obj-code = p-obj-code
            and X_thbj-attr.upper-prop-code = p-upper-prop-code
            and X_thbj-attr.prop-code = p-prop-code
            no-error.
    if not available X_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-cli-type/p-cli-code/p-upper-prop-code/p-prop-code"
        p-obj-type p-obj-code p-upper-prop-code p-prop-code
        view-as alert-box ERROR.
        return.
    end.
  end.
 if p-mode = "section":U then do:
  find first X_thbj-attr no-lock where
                X_thbj-attr.obj-type = p-obj-type
            AND X_thbj-attr.obj-code = p-obj-code
            and X_thbj-attr.upper-prop-code = p-upper-prop-code
            no-error.
    if not available X_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-cli-type/p-cli-code/p-upper-prop-code"
        p-obj-type p-obj-code p-upper-prop-code
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

  if v-rid-list <> "" then do:
      FIND FIRST find_c-thbj-attr No-LOCK where
                 recid(find_c-thbj-attr) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_c-thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова v-rid-list" v-rid-list
        view-as alert-box error .
        return error.
      end.
      v-doc-rec = integer(entry(1, v-rid-list)).
    end.
  { gbl/curdbnum.i v-db-num }
  assign
  v-find = yes.
  if p-mode <> {&all} then do:
    assign
    v-param-name = get-param-name(p-upper-prop-code, p-prop-code, output v-section-name)
    .
  end.
  RUN MyEnable.
  RUn OpenBR in this-procedure ( input yes, input no, input '':U, input v-corr-user-db-num).
  HIDE mark-num in frame {&frame-name} .
  if v-rid-list <> "":U then
  REPOSITION br-thbj-attr to recid integer(entry(1, v-rid-list)) No-ERROR.
  { gbl/mv-clmn.i
    &browse-name = "br-thbj-attr"
    &frame-name = "{&frame-name}"
    &ext-col = 9
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9'"
    &prev-order-column-condition_1 = " p-mode = {&all} "
    &prev-order-column_2 = "'1,2,3,5,6,7,8,4,9'"
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
  DISPLAY v-corr-user-db-num sch-db-num sch-corr-date sch-cli-code 
          sch-corr-user-name mark-num 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel v-corr-user-db-num b-lookup B-print B-sch B-Help 
         br-thbj-attr sch-db-num sch-corr-date sch-cli-code sch-corr-user-name 
         BR-changes mark-num 
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
br-thbj-attr:num-locked-columns in frame {&frame-name} = 1
X_c-thbj-attr.corr-date:read-only in browse br-thbj-attr = yes
br-changes:title = "":U
v-corr-user-db-num = v-db-num
temp-changes.l_name:resizable in browse br-changes = true
temp-changes.v_old:resizable in browse br-changes = true
temp-changes.v_new:resizable in browse br-changes = true
temp-changes.l_name:width in browse br-changes = 30
temp-changes.v_old:width in browse br-changes = 40
temp-changes.v_new:width in browse br-changes = 40
v-h = br-thbj-attr:FIRST-COLUMN IN FRAME {&FRAME-NAME}
.
DO while valid-handle(v-h) :
  if v-h:LABEL = {&label-1}
  or v-h:label = {&label-2}
    then do:
    v-h:RESIZABLE = YES.
  end.
  v-h = v-h:next-column.
END.
DISPLAY
v-corr-user-db-num
sch-db-num
sch-corr-date
sch-cli-code
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
br-thbj-attr
sch-corr-date
sch-corr-user-name
sch-cli-code when p-mode = {&all}
sch-db-num when p-mode = {&all}
BR-changes mark-num
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
define input  parameter p-db-num like ub.c-thbj-attr.corr-user-db-num no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Список истории настроек объектов TH" + {&space-char}.
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


&scop flt-open-open-query OPEN QUERY br-thbj-attr FOR EACH X_c-thbj-attr

&scop flt-open-dyn_open-query  FOR EACH X_c-thbj-attr

&scop flt-open-query-handle query br-thbj-attr:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-thbj-attr

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_c-thbj-attr

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .
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
          &use-ind    = "  "
          &by         = "  " }
      END.
      WHEN "one":u THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1: Один параметр", filter-label0)
        .
        if p-open-query then do:
          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" Объект &1, параметр &2: &3"
                                                                  , get-objregion(p-obj-type, p-obj-code)
                                                                  , v-param-name ).
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-thbj-attr.obj-type  = p-obj-type AND  ~
          X_c-thbj-attr.obj-code  = p-obj-code AND  ~
          X_c-thbj-attr.upper-prop-code  = p-upper-prop-code AND  ~
          X_c-thbj-attr.prop-code  = p-prop-code  "
          &dyn_where-cond = " substitute(' X_c-thbj-attr.obj-type  = &1&2&1 AND  ~
          X_c-thbj-attr.obj-code  = &3 AND X_c-thbj-attr.upper-prop-code  = &1&4&1 AND ~
          X_c-thbj-attr.prop-code  = &1&5&1 ', ~{&double-quote~}, p-obj-type, p-obj-code, p-upper-prop-code, p-prop-code)  "
          &use-ind    = "  "
          &by         = "  " }
      END.
      WHEN "section":u THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1: Одна секция", filter-label0)
        .
        if p-open-query then do:
          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" Объект &1, секция &2: &3"
                                                                  , get-objregion(p-obj-type, p-obj-code)
                                                                  , v-section-name ).
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-thbj-attr.obj-type  = p-obj-type AND  ~
          X_c-thbj-attr.obj-code  = p-obj-code AND  ~
          X_c-thbj-attr.upper-prop-code  = p-upper-prop-code AND  ~
          X_c-thbj-attr.prop-code  > ''  "
          &dyn_where-cond = " substitute(' X_c-thbj-attr.obj-type  = &1&2&1 AND  ~
          X_c-thbj-attr.obj-code  = &3 AND X_c-thbj-attr.upper-prop-code  = &1&4&1 AND ~
          X_c-thbj-attr.prop-code  > &1&1 ', ~{&double-quote~}, p-obj-type, p-obj-code, p-upper-prop-code, p-prop-code)  "
          &use-ind    = "  "
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
          &use-ind    = "  "
          &by         = "  " }
      END.
      WHEN "one":u THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1: Один параметр", filter-label0)
        .
        if p-open-query then do:
          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" Объект &1, параметр &2, БД &3"
                                                      , get-objregion(p-obj-type, p-obj-code), v-param-name, p-db-num ).
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-thbj-attr.corr-user-db-num = p-db-num ANd  ~
          X_c-thbj-attr.obj-type  = p-obj-type AND  ~
          X_c-thbj-attr.obj-code  = p-obj-code AND  ~
          X_c-thbj-attr.upper-prop-code  = p-upper-prop-code AND  ~
          X_c-thbj-attr.prop-code  = p-prop-code  "
          &dyn_where-cond = " substitute(' X_c-thbj-attr.corr-user-db-num = &1 ANd  ~
          X_c-thbj-attr.obj-type  = &2&3&2 AND  X_c-thbj-attr.obj-code  = &4 AND ~
          X_c-thbj-attr.upper-prop-code  = &2&5&2 AND   X_c-thbj-attr.prop-code  = &2&6&2 ' ~
          , p-db-num, ~{&double-quote~}, p-obj-type, p-obj-code, p-upper-prop-code, p-prop-code)  "

          &use-ind    = "  "
          &by         = "  " }
      END.
      WHEN "section":u THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1: Одна секция", filter-label0)
        .
        if p-open-query then do:
          ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" Объект &1, секция &2, БД &3"
                                                      , get-objregion(p-obj-type, p-obj-code), v-section-name, p-db-num ).
        end.
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-thbj-attr.corr-user-db-num = p-db-num ANd  ~
          X_c-thbj-attr.obj-type  = p-obj-type AND  ~
          X_c-thbj-attr.obj-code  = p-obj-code AND  ~
          X_c-thbj-attr.upper-prop-code  = p-upper-prop-code AND  ~
          X_c-thbj-attr.prop-code  > '' "
          &dyn_where-cond = " substitute(' X_c-thbj-attr.corr-user-db-num = &1 ANd  ~
          X_c-thbj-attr.obj-type  = &2&3&2 AND  X_c-thbj-attr.obj-code  = &4 AND ~
          X_c-thbj-attr.upper-prop-code  = &2&5&2 AND   X_c-thbj-attr.prop-code  > &2&2 ' ~
          , p-db-num, ~{&double-quote~}, p-obj-type, p-obj-code, p-upper-prop-code, p-prop-code)  "

          &use-ind    = "  "
          &by         = "  " }
      END.

    END CASE.
  end.
END CASE.

if not p-open-query and v-doc-rec <> ? then
REPOSITION br-thbj-attr to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-thbj-attr:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .

APPLY "VALUE-CHANGED" TO br-thbj-attr in frame {&frame-name}.
APPLY "ENTRY" TO br-thbj-attr.


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
define variable v-dop as character no-undo .

DEFINE FRAME HistoryList
v-obj COLUMN-LABEL "Объект TH" FORMAT "X(12)"
v-action-chr FORMAT "X(10)" COLUMN-LABEL "Действие"
v-param-name COLUMN-LABEL "Назв. параметра" FORMAT "X(20)"
X_c-thbj-attr.is-news COLUMn-LABEL "СПН" FORMAT "+/ "
X_c-thbj-attr.corr-date
v-upd-time COLUMN-LABEL "Время изм." FORMAT "X(8)"
X_c-thbj-attr.corr-user-name
X_c-thbj-attr.corr-user-db-num
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 195).
date_string = cur-time-print() .
assign
v-doc-rec = recid( X_c-thbj-attr ).
DO WHILE available X_c-thbj-attr :
      GET prev br-thbj-attr.
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
  GET next br-thbj-attr.
    DO WHILE available X_c-thbj-attr :
      Display STREAM PrnLibStream
       X_c-thbj-attr.obj-type + string(X_c-thbj-attr.obj-code) @ v-obj
      get-action(X_c-thbj-attr.action) @ v-action-chr
      (if v-find then get-param-name(X_c-thbj-attr.upper-prop-code, X_c-thbj-attr.prop-code, output v-dop) else "":U )
      @ v-param-name
      X_c-thbj-attr.is-news
      X_c-thbj-attr.corr-date
      string(X_c-thbj-attr.corr-time, "HH:MM:SS":U) @ v-upd-time
      X_c-thbj-attr.corr-user-name
      X_c-thbj-attr.corr-user-db-num
      with FRAME HistoryList .
  DOWN STREAM PrnLibStream 1 with FRAME HistoryList  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-thbj-attr.
END.
UNDERLINE  STREAM PrnLibStream
v-obj
v-action-chr
v-param-name
X_c-thbj-attr.is-news
X_c-thbj-attr.corr-date
v-upd-time
X_c-thbj-attr.corr-user-name
X_c-thbj-attr.corr-user-db-num
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
reposition br-thbj-attr to recid v-doc-rec no-error.
apply "entry" to br-thbj-attr in frame {&frame-name}.

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
  tbl = 'c-thbj-attr'
  join-tbl = 'X_c-thbj-attr'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Контрагент', '',
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-thbj-attr Dialog-Frame 
PROCEDURE proc-br-thbj-attr :
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
0 @ sch-cli-code
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
        ,input substitute("and X_c-thbj-attr.corr-date = &1 "
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
define input parameter p-db-num like ub.c-thbj-attr.corr-user-db-num no-undo.
define variable v-db-num as character no-undo.
assign
sch-corr-date = ?
.
display
"":U @ sch-corr-user-name
0 @ sch-cli-code
sch-corr-date
with frame {&frame-name}.
assign
v-db-num = string(p-db-num).
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-thbj-attr.corr-user-db-num = &1 "
      , v-db-num)
    ,input v-corr-user-db-num
    ).
apply "entry":u to sch-db-num in frame {&frame-name} .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-obj-code Dialog-Frame 
PROCEDURE proc-find-obj-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-obj-code like ub.c-thbj-attr.obj-code no-undo.
define variable v-obj-code as character no-undo.
display
"":U @ sch-corr-user-name
with frame {&frame-name}.
display
"":U @ sch-corr-user-name
0 @ sch-db-num
sch-corr-date
with frame {&frame-name}.

assign
v-obj-code = string(p-obj-code).
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-thbj-attr.obj-code = &1 "
      , v-obj-code)
    ,input v-corr-user-db-num
    ).
apply "entry":u to sch-cli-code in frame {&frame-name} .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-user Dialog-Frame 
PROCEDURE proc-find-user :
define input parameter p-next as logical no-undo.
define input parameter p-user like ub.c-thbj-attr.corr-user-name no-undo.
assign
sch-corr-date = ?.
display
0 @ sch-db-num
sch-corr-date
0 @ sch-cli-code
with frame {&frame-name}.
p-user = {&double-quote} + p-user + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-thbj-attr.corr-user-name = &1 "
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
if not available X_c-thbj-attr then do:
  Open QUery br-changes for each temp-changes.
  return.
end.

run ref/cthbjatv.p (
                   input X_c-thbj-attr.obj-type
                  ,input X_c-thbj-attr.obj-code
                  ,input X_c-thbj-attr.upper-prop-code
                  ,input X_c-thbj-attr.prop-code
                  ,input X_c-thbj-attr.corr-user-db-num
                  ,input X_c-thbj-attr.chip-num
                  ,input ''
                  ,input X_c-thbj-attr.action
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-param-name Dialog-Frame 
FUNCTION get-param-name RETURNS CHARACTER
  (p-upper-prop-code as character, p-prop-code as character, output p-section-name as character ) :
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-tooltip-code as character no-undo .
run thbjattr_tooltip in this-procedure (
              input  p-upper-prop-code
            ,input  p-prop-code
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
p-section-name = v-tooltip.
if not error-status:error then return v-tooltip-code.

return substitute("&1:&2", p-upper-prop-code, p-prop-code).
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
&scop hn-thbj-attr-hist-code p-subject
define variable v-subject as character no-undo .
return v-subject.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

