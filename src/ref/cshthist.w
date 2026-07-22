&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER find_c-sht-hist FOR c-sht-hist.
DEFINE BUFFER X_c-sht-hist FOR c-sht-hist.
DEFINE BUFFER X_clients FOR clients.
DEFINE BUFFER X_curr-sysconf FOR sysconf.
DEFINE BUFFER X_shift-obj FOR shift-obj.
DEFINE BUFFER X_sysconf FOR sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список полной истории смены объекта

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
/*может быть {&all} "one":U {&g___object} "subject":U {&deletion}*/
define input parameter p-obj-type   like ub.c-sht-hist.obj-type no-undo.
define input parameter p-obj-code   like ub.c-sht-hist.obj-code no-undo.
define input parameter p-shift-date like ub.c-sht-hist.shift-date no-undo .
define input parameter p-shift-num  like ub.c-sht-hist.shift-num no-undo .
define input parameter p-subject    like ub.c-sht-hist.subject no-undo .


/*записи в выборке*/
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список полной истории смены объекта":U.
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
define variable filter-point as character no-undo init "cshthist" .
define variable filter-point0 as character no-undo init "cshthist" .
define variable filter-label as character no-undo init "История смен на объекте" .
define variable filter-label0 as character no-undo init "История смен на объекте" .
define variable v-rid-list as character no-undo .
define variable sort-column-name as character no-undo .
define variable print-option as character no-undo.
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-find as logical no-undo.
define variable v-start-date-chr as character no-undo .
define variable v-end-date-chr as character no-undo .
define variable v-subject-chr as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .

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
&Scoped-define INTERNAL-TABLES temp-changes X_c-sht-hist

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes   
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE br-sht-hist                                   */
&Scoped-define FIELDS-IN-QUERY-br-sht-hist mark-string(recid(X_c-sht-hist), v-rid-list) X_c-sht-hist.shift-date X_c-sht-hist.shift-name X_c-sht-hist.shift-num X_c-sht-hist.corr-date usrfulnf(X_c-sht-hist.corr-user-name) X_c-sht-hist.corr-user-db-num string(X_c-sht-hist.corr-time, "HH:MM:SS":U) get-action(X_c-sht-hist.action) get-subject(X_c-sht-hist.subject) X_c-sht-hist.obj-type + string(X_c-sht-hist.obj-code)   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-sht-hist X_c-sht-hist.corr-date   
&Scoped-define ENABLED-TABLES-IN-QUERY-br-sht-hist X_c-sht-hist
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-sht-hist X_c-sht-hist
&Scoped-define SELF-NAME br-sht-hist
&Scoped-define QUERY-STRING-br-sht-hist FOR EACH X_c-sht-hist NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-sht-hist OPEN QUERY {&SELF-NAME} FOR EACH X_c-sht-hist NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-sht-hist X_c-sht-hist
&Scoped-define FIRST-TABLE-IN-QUERY-br-sht-hist X_c-sht-hist


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-lookup B-print B-sch ~
B-Help br-sht-hist sch-corr-date sch-shift-date sch-corr-user-name ~
BR-changes mark-num 
&Scoped-Define DISPLAYED-OBJECTS sch-corr-date sch-shift-date ~
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

DEFINE VARIABLE sch-shift-date AS DATE FORMAT "99/99/9999":U 
     LABEL "Дате смены" 
     VIEW-AS FILL-IN 
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR 
      temp-changes SCROLLING.

DEFINE QUERY br-sht-hist FOR 
      X_c-sht-hist SCROLLING.
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

DEFINE BROWSE br-sht-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-sht-hist Dialog-Frame _FREEFORM
  QUERY br-sht-hist NO-LOCK DISPLAY
      mark-string(recid(X_c-sht-hist), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_c-sht-hist.shift-date FORMAT "99/99/9999":U
      X_c-sht-hist.shift-name COLUMN-LABEL "№!смены" FORMAT "X(2)":U
      X_c-sht-hist.shift-num COLUMN-LABEL "Пор!смены" FORMAT ">9":U
      X_c-sht-hist.corr-date FORMAT "99/99/9999":U
      usrfulnf(X_c-sht-hist.corr-user-name) FORMAT "X(18)":U
      X_c-sht-hist.corr-user-db-num FORMAT ">>>>9":U
      string(X_c-sht-hist.corr-time, "HH:MM:SS":U) COLUMN-LABEL "Время изм." FORMAT "X(8)":U
      get-action(X_c-sht-hist.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
      get-subject(X_c-sht-hist.subject) COLUMN-LABEL "Предмет изменений" FORMAT "X(15)":U
      X_c-sht-hist.obj-type + string(X_c-sht-hist.obj-code) COLUMN-LABEL "Объект" FORMAT "X(8)":U
  ENABLE
      X_c-sht-hist.corr-date
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 11.46.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-lookup AT ROW 1 COL 45
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     br-sht-hist AT ROW 2 COL 1
     sch-corr-date AT ROW 13.63 COL 85.75 COLON-ALIGNED
     sch-shift-date AT ROW 13.67 COL 56.13 COLON-ALIGNED
     sch-corr-user-name AT ROW 13.71 COL 22.5 COLON-ALIGNED
     BR-changes AT ROW 14.79 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 8.38 BY 1 AT ROW 13.63 COL 1.38
          FGCOLOR 4 
     SPACE(89.48) SKIP(7.44)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Полная история по смене на объекте"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_c-sht-hist B "?" NO-UNDO ub c-sht-hist
      TABLE: X_c-sht-hist B "?" ? ub c-sht-hist
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_curr-sysconf B "?" ? ub sysconf
      TABLE: X_shift-obj B "?" ? ub shift-obj
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-sht-hist B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes sch-corr-user-name Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       br-sht-hist:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-sht-hist
/* Query rebuild information for BROWSE br-sht-hist
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-sht-hist NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-sht-hist */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Полная история по смене на объекте */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Полная история по смене на объекте */
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
  if available X_c-sht-hist then do:
    { gbl/markstrn.i X_c-sht-hist v-rid-list }
    loc#log = br-sht-hist:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-sht-hist:select-next-row ().
        apply "VALUE-CHANGED" to br-sht-hist in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-sht-hist in frame {&frame-name}.
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
  if ( available X_c-sht-hist ) then do:
    if ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_c-sht-hist ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-sht-hist
&Scoped-define SELF-NAME br-sht-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-sht-hist Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-sht-hist IN FRAME Dialog-Frame
DO:
     run proc-br-sht-hist in this-procedure no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-sht-hist Dialog-Frame
ON RETURN OF br-sht-hist IN FRAME Dialog-Frame
DO:
    run proc-br-sht-hist in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-sht-hist Dialog-Frame
ON VALUE-CHANGED OF br-sht-hist IN FRAME Dialog-Frame
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


&Scoped-define SELF-NAME sch-shift-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-shift-date Dialog-Frame
ON CTRL-J OF sch-shift-date IN FRAME Dialog-Frame /* Дате смены */
DO:
  run proc-find-shift-date in this-procedure(yes, input frame {&frame-name} sch-shift-date) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-shift-date Dialog-Frame
ON RETURN OF sch-shift-date IN FRAME Dialog-Frame /* Дате смены */
DO:
  run proc-find-shift-date in this-procedure(no, input frame {&frame-name} sch-shift-date) no-error.
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

{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-sht-hist" }
{ gbl/brwrefre.i " v-doc-rec = recid(X_c-sht-hist).  RUn OpenBR in this-procedure ( input yes, input no, '':U).  REPOSITION br-sht-hist to recid v-doc-rec No-ERROR. ~
               apply 'value-changed' to br-sht-hist.     " }

{ gbl/setfltnm.i }
{ gbl/ed_date.i sch-corr-date}
{ gbl/ed_date.i sch-shift-date}

{ gbl/srt-clmd.i
  &browse-name    = "br-sht-hist"
  &frame-name     = "{&frame-name}"
  &table-name     = "X_c-sht-hist"
  &sort-clmn_1    = "X_c-sht-hist.shift-date"
  &sort-clmn_2    = "X_c-sht-hist.corr-date"
  &sort-clmn_3    = "X_c-sht-hist.corr-user-db-num"
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
 if p-mode = "one":U
 or p-mode = "subject":U
 then do:
  find first X_shift-obj no-lock where
             X_shift-obj.obj-type = p-obj-type
         AND  X_shift-obj.obj-code = p-obj-code
         AND  X_shift-obj.shift-date = p-shift-date
         AND  X_shift-obj.shift-num = p-shift-num   no-error.
    if not available X_shift-obj then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-shift-date/p-shift-num" p-shift-date p-shift-num
        view-as alert-box ERROR.
        return.
    end.
  end.
  v-rid-list = p-rid-list.
  if v-rid-list <> "" then do:
      FIND FIRST find_c-sht-hist No-LOCK where
                 recid(find_c-sht-hist) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_c-sht-hist then do:
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
  RUN MyEnable in this-procedure .
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if v-rid-list <> "":U then
  REPOSITION br-sht-hist to recid integer(entry(1, v-rid-list)) No-ERROR.
  { gbl/mv-clmn.i
    &browse-name = "br-sht-hist"
    &frame-name = "{&frame-name}"
    &ext-col = 11
    &start-column = 1
    &prev-order-column_1 = "'11,1,2,3,4,5,6,7,8,9,10'"
    &prev-order-column-condition_1 = " p-mode = {&all} "
    &prev-order-column_2 = "'1,2,3,4,5,6,7,8,9,10,11'"
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
  DISPLAY sch-corr-date sch-shift-date sch-corr-user-name mark-num 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-lookup B-print B-sch B-Help br-sht-hist 
         sch-corr-date sch-shift-date sch-corr-user-name BR-changes mark-num 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
assign
  br-sht-hist:num-locked-columns in frame {&frame-name} = 1
  X_c-sht-hist.corr-date:read-only in browse br-sht-hist = yes
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
  sch-shift-date
  sch-corr-user-name
  mark-num
  WITH FRAME {&frame-name} .
  ENABLE
  b-quit
  B-mark when lookup("b-mark":U, bttns) > 0
  b-sel when lookup("b-sel":U, bttns) > 0
  B-sch
  B-Print
  B-Help
  br-sht-hist
  sch-corr-date
  sch-shift-date when (p-mode = {&all} or p-mode = {&deletion})
  sch-corr-user-name
  BR-changes mark-num
  WITH FRAME {&frame-name} .
  VIEW FRAME {&frame-name} .
  hide b-lookup  sch-corr-user-name
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
title0 = "История смен на объекте" + {&space-char}.
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



&scop flt-open-open-query OPEN QUERY br-sht-hist FOR EACH X_c-sht-hist

&scop flt-open-dyn_open-query FOR EACH X_c-sht-hist

&scop flt-open-query-handle query br-sht-hist:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-sht-hist

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_c-sht-hist

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
  WHEN {&deletion} THEN DO:
    assign
    filter-point = filter-point0 + p-mode
    filter-label = substitute("&1 Удаленные смены", filter-label0)
    .
    if p-open-query then do:
      ASSIGN
      frame {&frame-name}:TITLE = title0 + substitute(" Удаленные смены на объекте &1&2"
                                                        ,p-obj-type, p-obj-code).
    end.
    { gbl/fltopend.i
      &where-cond = " ~
                    X_c-sht-hist.obj-type = p-obj-type and X_c-sht-hist.obj-code = p-obj-code and ~
                    X_c-sht-hist.is-del = yes  ~
                    "
      &dyn_where-cond = " substitute(' X_c-sht-hist.obj-type = &1&2&1 and X_c-sht-hist.obj-code = &3 and ~
                    X_c-sht-hist.is-del = yes ', ~{&double-quote~}, p-obj-type, p-obj-code ) "

      &use-ind    = "  "
      &by         = "  " }
  END.
  WHEN "one":u THEN DO:
    assign
    filter-point = filter-point0 + p-mode
    filter-label = substitute("&1 Одна смена", filter-label0)
    .
    if p-open-query then do:
      ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" Объект &1&2 Смена от &3 №&4"
                                                              ,p-obj-type, p-obj-code, string(p-shift-date, "99/99/9999"), p-shift-num ).
    end.
    { gbl/fltopend.i
      &where-cond = " X_c-sht-hist.obj-type = p-obj-type and X_c-sht-hist.obj-code = p-obj-code AND ~
                      X_c-sht-hist.shift-date  = p-shift-date and X_c-sht-hist.shift-num  = p-shift-num "
      &dyn_where-cond = " substitute('X_c-sht-hist.obj-type = &1&2&1 and X_c-sht-hist.obj-code = &3 AND ~
                      X_c-sht-hist.shift-date  = &4 and X_c-sht-hist.shift-num  = &5 ', ~{&double-quote~}, p-obj-type, p-obj-code, p-shift-date, p-shift-num) "

      &use-ind    = "  "
      &by         = "  " }
  END.
  WHEN "subject":u THEN DO:
&scop hn-sht-hist-code p-subject
    assign
    filter-point = filter-point0 + p-mode
    v-subject-chr = {&hn-sht-hist-name}
    filter-label = substitute("&1 Предмет изменения", filter-label0)
    .

    v-title = title0 + substitute(" Объект &1&2 Смена от &3 №&4"
                                                            ,p-obj-type, p-obj-code, string(p-shift-date, "99/99/9999"), p-shift-num ).
    if p-subject =  {&table_shift-staff} then do:
      if p-open-query then do:
        assign
        frame {&frame-name}:title = v-title + substitute(" Персонал").
      end.
    end.

  { gbl/fltopend.i
    &where-cond = " X_c-sht-hist.obj-type = p-obj-type and X_c-sht-hist.obj-code = p-obj-code  ~
                    And X_c-sht-hist.shift-date  = p-shift-date and X_c-sht-hist.shift-num  = p-shift-num  ~
                    and X_c-sht-hist.subject = p-subject ~
                  "
    &dyn_where-cond = " substitute('X_c-sht-hist.obj-type = &1&2&1 and X_c-sht-hist.obj-code = &3  ~
                    And X_c-sht-hist.shift-date  = &4 and X_c-sht-hist.shift-num  = &5  ~
                    and X_c-sht-hist.subject = &1&6&1', ~{&double-quote~}, p-obj-type, p-obj-code, p-shift-date, p-shift-num, p-subject ) "

    &use-ind    = "  "
    &by         = "  " }
  END.
END CASE.

if not p-open-query  and v-doc-rec <> ? then
REPOSITION br-sht-hist to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-sht-hist:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.

run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-sht-hist in frame {&frame-name}.
APPLY "ENTRY" TO br-sht-hist.


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
DEFINE VARIABLE v-for-user-name AS CHARACTER NO-UNDO.
DEFINE FRAME HistoryList
X_c-sht-hist.shift-date COLUMN-LABEL "Дата смены"
X_c-sht-hist.shift-num COLUMN-LABEL "№ смены"
v-action-chr FORMAT "X(10)"  COLUMN-LABEL "Действие"
v-subject-chr COLUMN-LABEL "Предмет изменений" FORMAT "X(20)"
X_c-sht-hist.corr-date
v-upd-time COLUMN-LABEL "Время изм." FORMAT "X(8)"
v-for-user-name COLUMN-LABEL "Изменил" FORMAT "X(18)"
X_c-sht-hist.corr-user-db-num
v-obj COLUMN-LABEL "Объект" FORMAT "X(8)"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 195).
date_string = cur-time-print() .
assign
v-doc-rec = recid( X_c-sht-hist ).
DO WHILE available X_c-sht-hist :
      GET prev br-sht-hist.
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
  GET next br-sht-hist.
    DO WHILE available X_c-sht-hist :
      Display STREAM PrnLibStream
      X_c-sht-hist.shift-date
      X_c-sht-hist.shift-num
      get-action(X_c-sht-hist.action) @ v-action-chr
      get-subject(X_c-sht-hist.subject) @ v-subject-chr
      X_c-sht-hist.corr-date
      string(X_c-sht-hist.corr-time, "HH:MM:SS":U) @ v-upd-time
      usrfulnf(X_c-sht-hist.corr-user-name) @ v-for-user-name
      X_c-sht-hist.corr-user-db-num
      X_c-sht-hist.obj-type + string(X_c-sht-hist.obj-code) @ v-obj
      with FRAME HistoryList .
  DOWN STREAM PrnLibStream 1 with FRAME HistoryList  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-sht-hist.
END.
UNDERLINE  STREAM PrnLibStream
X_c-sht-hist.shift-date
X_c-sht-hist.shift-num
v-action-chr
v-subject-chr
X_c-sht-hist.corr-date
v-upd-time
v-for-user-name
X_c-sht-hist.corr-user-db-num
v-obj
with FRAME HistoryList .
DISPLAY STREAM PrnLibStream
"ИТОГО"  @ X_c-sht-hist.shift-date
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
reposition br-sht-hist to recid v-doc-rec no-error.
apply "entry" to br-sht-hist in frame {&frame-name}.

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
  tbl = 'c-sht-hist'
  join-tbl = 'X_c-sht-hist'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-date', 'Дата смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', '№ смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время корр.', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('subject', 'Предмет изменения', 'sht-hist-subject',
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-sht-hist Dialog-Frame 
PROCEDURE proc-br-sht-hist :
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
assign
sch-shift-date = ?.
display
sch-shift-date
"":U @ sch-corr-user-name
with frame {&frame-name}.
assign
v-date-chr = string(day(p-date)) + {&slash-char} +
                 string(month(p-date)) + {&slash-char} +
                 string(year(p-date)).

       run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input true  /* p-find-next  */
        ,input substitute("and X_c-sht-hist.corr-date = &1 "
          , v-date-chr)
        ).
      apply "entry":u to sch-corr-date in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-shift-date Dialog-Frame 
PROCEDURE proc-find-shift-date :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-shift-date like ub.c-sht-hist.shift-date no-undo.
define variable v-shift-date as character no-undo.
if p-shift-date = ? then return.
assign
sch-corr-date = ?.
display
"":U @ sch-corr-user-name
sch-corr-date
with frame {&frame-name}.

assign
v-shift-date = string(day(p-shift-date)) + {&slash-char} +
                 string(month(p-shift-date)) + {&slash-char} +
                 string(year(p-shift-date)).

run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-sht-hist.shift-date = &1 "
      , v-shift-date)
    ).
apply "entry":u to sch-shift-date in frame {&frame-name} .



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
define input parameter p-user like ub.c-sht-hist.corr-user-name no-undo.
assign
sch-corr-date = ?
sch-shift-date = ?
.
display
sch-corr-date
sch-shift-date
with frame {&frame-name}.
p-user = {&double-quote} + p-user + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-sht-hist.corr-user-name = &1 "
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
if not available X_c-sht-hist then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
run ref/cshthisv.p (
                   input X_c-sht-hist.obj-type
                  ,input X_c-sht-hist.obj-code
                  ,input X_c-sht-hist.shift-date
                  ,input X_c-sht-hist.shift-num
                  ,input X_c-sht-hist.chip-num
                  ,input X_c-sht-hist.corr-user-db-num
                  ,input X_c-sht-hist.subject
                  ,input X_c-sht-hist.action
                  ,input no
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
&scop hn-sht-hist-code p-subject
  RETURN {&hn-sht-hist-name}.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

