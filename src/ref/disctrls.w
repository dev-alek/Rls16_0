&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_c-dis-time-rule FOR ub.c-dis-time-rule.
DEFINE BUFFER X_curr_clients FOR ub.clients.
DEFINE BUFFER X_upper-dis-time-rule FOR ub.dis-time-rule.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории РАСПИСАНИЙ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 16/03/04
Author: Bakhtadze Natalya
Creation date: 16/03/04

*/


/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/
define input parameter p-mode  as char   no-undo .
/*{&all}  "one"  "upper-rule-num" "rl-root"  */
define input parameter p-rule-num like ub.dis-time-rule.time-rule-num no-undo .
define input parameter p-upper-rule-num like ub.dis-time-rule.upper-time-rule-num no-undo .
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список истории РАСПИСАНИЙ":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ gbl/flt-def.i }
{ gbl/fltfield.i }
{ gbl/disrules.i work }
{ ref/gtregion.i }
{ ref/tmpchgs.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable filter-label as character no-undo init "История расписаний" .
define variable filter-label0 as character no-undo init "История расписаний" .
define variable filter-point0 as character no-undo init "disctrls" .
define variable filter-point as character no-undo init "disctrls" .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-rid-list as character no-undo .

&SCOPED-DEFINE used-status-code STRING(X_c-dis-time-rule.sts)
&SCOPED-DEFINE discnt-type-code string(X_c-dis-time-rule.discnt-type)
&SCOPED-DEFINE discnt-target-code STRING(X_c-dis-time-rule.subject-type)
&SCOPED-DEFINE discnt-v-code STRING(X_c-dis-time-rule.value-type)
define buffer pos_c-dis-time-rule for ub.c-dis-time-rule.
define buffer X_dis-time-rule for ub.dis-time-rule.

&scop cant-positioning   if error-status:error then do: ~
                          find first pos_dis-time-rule no-lock where ~
                                  recid(pos_dis-time-rule) = loc-doc-rec no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи РАСПИСАНИЯ" skip~
                            string(if avail pos_dis-time-rule ~
                                    then  substitute("номер расписания: &1" ~
                                                    , pos_dis-time-rule.time-rule-num) ~
                                    else "":U) skip ~
                            "Запись была добавлена (или изменена или удалена) -" skip ~
                            "и теперь не попадает в текущую выборку" ~
                            view-as alert-box WARNING. ~
                          end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-c-dis-time-rule

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-dis-time-rule temp-changes

/* Definitions for BROWSE br-c-dis-time-rule                            */
&Scoped-define FIELDS-IN-QUERY-br-c-dis-time-rule mark-string(recid(X_c-dis-time-rule), v-rid-list) X_c-dis-time-rule.des X_c-dis-time-rule.is-news get-action(X_c-dis-time-rule.action) X_c-dis-time-rule.corr-user-db-num usrfulnf(X_c-dis-time-rule.corr-user-name) X_c-dis-time-rule.corr-date string(X_c-dis-time-rule.corr-time, "HH:MM") X_c-dis-time-rule.time-rule-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-c-dis-time-rule
&Scoped-define SELF-NAME br-c-dis-time-rule
&Scoped-define QUERY-STRING-br-c-dis-time-rule FOR EACH X_c-dis-time-rule NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-c-dis-time-rule OPEN QUERY {&SELF-NAME} FOR EACH X_c-dis-time-rule NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-c-dis-time-rule X_c-dis-time-rule
&Scoped-define FIRST-TABLE-IN-QUERY-br-c-dis-time-rule X_c-dis-time-rule


/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-c-dis-time-rule}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH X_c-dis-time-rule SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH X_c-dis-time-rule SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame X_c-dis-time-rule
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame X_c-dis-time-rule


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-sch B-Help ~
br-c-dis-time-rule BR-changes mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-action Dialog-Frame
FUNCTION get-action RETURNS CHARACTER
  ( p-action as INTEGER )  FORWARD.

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
     LABEL "Button 1"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-c-dis-time-rule FOR
      X_c-dis-time-rule SCROLLING.

DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      X_c-dis-time-rule SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-c-dis-time-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-c-dis-time-rule Dialog-Frame _FREEFORM
  QUERY br-c-dis-time-rule NO-LOCK DISPLAY
      mark-string(recid(X_c-dis-time-rule), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_c-dis-time-rule.des FORMAT "X(50)":U
      X_c-dis-time-rule.is-news FORMAT "+/":U
      get-action(X_c-dis-time-rule.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
      X_c-dis-time-rule.corr-user-db-num COLUMN-LABEL "Номер!БД" FORMAT ">>>>9":U
      usrfulnf(X_c-dis-time-rule.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
      X_c-dis-time-rule.corr-date COLUMN-LABEL "Дата корр" FORMAT "99/99/9999":U
      string(X_c-dis-time-rule.corr-time, "HH:MM") COLUMN-LABEL "Время корр" FORMAT "X(10)":U
      X_c-dis-time-rule.time-rule-num FORMAT ">>>>>>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.25.

DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(40)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.04.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     B-lookup AT ROW 1 COL 41
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     br-c-dis-time-rule AT ROW 3 COL 1
     BR-changes AT ROW 13 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(78.62) SKIP(20.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История расписаний"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_c-dis-time-rule B "?" ? ub c-dis-time-rule
      TABLE: X_curr_clients B "?" ? ub clients
      TABLE: X_upper-dis-time-rule B "?" ? ub dis-time-rule
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-c-dis-time-rule B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes br-c-dis-time-rule Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-lookup IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-lookup:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-c-dis-time-rule
/* Query rebuild information for BROWSE br-c-dis-time-rule
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-dis-time-rule NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-c-dis-time-rule */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.X_c-dis-time-rule"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* История расписаний */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История расписаний */
OR ENDKEY OF FRAME Dialog-Frame DO:
  run gbl/markqwa.p (
                           input b-mark:sensitive
                          , input v-rid-list) no-error.
  if error-status:error then return no-apply.

  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available X_c-dis-time-rule then do:
    { gbl/markstrn.i X_c-dis-time-rule v-rid-list }
    loc#log = br-c-dis-time-rule:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-c-dis-time-rule:select-next-row ().
        apply "VALUE-CHANGED" to br-c-dis-time-rule in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-c-dis-time-rule in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  RUN proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_c-dis-time-rule ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_c-dis-time-rule ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-c-dis-time-rule
&Scoped-define SELF-NAME br-c-dis-time-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-c-dis-time-rule Dialog-Frame
ON RETURN OF br-c-dis-time-rule IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-c-dis-time-rule IN FRAME Dialog-Frame
    DO:
  run proc-br-c-dis-time-rule no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-c-dis-time-rule Dialog-Frame
ON VALUE-CHANGED OF br-c-dis-time-rule IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

function display-int-status returns character(input p-stts-char as character):
case p-stts-char :
  when {&current-status-int} then return {&current-status-int-full}.
  when {&deleted-status-int} then return {&deleted-status-int-full}.
  when {&non-root-status-int} then return {&non-root-status-int-full}.
  otherwise return {&question-mark}.
end case.
END FUNCTION.


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i &disable_diasize_init=true &browse-name="BR-c-dis-time-rule" }
{ gbl/brwrefre.i "v-doc-rec = recid(X_c-dis-time-rule). run OpenBr in this-procedure ( input yes, input no, input '':U). reposition br-c-dis-time-rule to recid v-doc-rec no-error. v-doc-rec = ?. ~
              APPLY 'VALUE-CHANGED' to br-c-dis-time-rule. " }
{ gbl/srt-clmd.i
  &browse-name    = "br-c-dis-time-rule"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-br-c-dis-time-rule}"
  &sort-clmn_1    = "X_c-dis-time-rule.time-rule-num"
  &open-query     = "run OpenBr in this-procedure ( input YES, input NO, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input YES, input NO, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}


{ gbl/brwrepos.i
  &line-num=5
}
{ gbl/setfltnm.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 if LOOKUP(p-mode, ({&all} + {&delim-par} +
                   "upper-rule-num":U + {&delim-par} +
                   "one":U + {&delim-par} +
                   {&g___object} + {&delim-par} +
                   "rl-root":U),
                {&delim-par}) = 0
     then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return error .
 end.
  if p-mode = "upper-rule-num" then do:
   find first X_upper-dis-time-rule no-lock where
          X_upper-dis-time-rule.time-rule-num = p-upper-rule-num no-error.
   if not available X_upper-dis-time-rule then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-upper-rule-num"
    p-upper-rule-num
    view-as alert-box ERROR.
    return error .
   end.
  end.
  if p-mode = "one" then do:
   find first X_dis-time-rule no-lock where
          X_dis-time-rule.time-rule-num = p-rule-num no-error.
   if not available X_dis-time-rule then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-rule-num"
    p-upper-rule-num
    view-as alert-box ERROR.
    return error .
   end.
  end.

 { gbl/curdbnum.i v-db-num }
  RUN MyEnable in this-procedure .
  RUn OpenBR IN THIS-PROCEDURE ( input YES, input NO, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if v-doc-rec <> ? then
  REPOSITION br-c-dis-time-rule to recid v-doc-rec No-ERROR.
    { gbl/mv-clmn.i
    &browse-name = "br-c-dis-time-rule"
    &frame-name = "{&frame-name}"
    &ext-col = 9
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9'"
    &prev-order-column-condition_1 = " p-mode = ~{&all~} "
    &prev-order-column_2 = "'1,2,3,4,5,6,7,8,9'"
    &prev-order-column-condition_2 = " p-mode = 'upper-rule-num':U or p-mode = 'one' "
    &prev-order-column_3 = "'1,2,3,4,5,6,7,8,9'"
    &prev-order-column-condition_3 = " p-mode = ~{&g___object~} "
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-sch B-Help br-c-dis-time-rule BR-changes
         mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
assign
br-changes:title in frame {&frame-name} = '':U
temp-changes.l_name:resizable in browse br-changes = true
temp-changes.v_old:resizable in browse br-changes = true
temp-changes.v_new:resizable in browse br-changes = true
temp-changes.l_name:width in browse br-changes = 30
temp-changes.v_old:width in browse br-changes = 40
temp-changes.v_new:width in browse br-changes = 40
.
DISPLAY mark-num
WITH FRAME {&frame-name}.
ENABLE
b-quit
B-mark when LOOKUP("b-mark":U, bttns) > 0
B-sel when LOOKUP("b-sel":U, bttns) > 0
B-Help
br-c-dis-time-rule
b-sch
mark-num
br-changes
with FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo init "Список истории расписаний".
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

&scop flt-open-open-query OPEN QUERY br-c-dis-time-rule FOR EACH X_c-dis-time-rule

&scop flt-open-dyn_open-query FOR EACH X_c-dis-time-rule

&scop flt-open-query-handle QUERY br-c-dis-time-rule:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-dis-time-rule

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_c-dis-time-rule

&scop flt-open-waitfram true

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
    WHEN "upper-rule-num":U THEN DO:
       assign
       filter-point = filter-point0 + p-mode
       filter-label = substitute("&1 один тип", filter-label0)
       .
       ASSIGN
       frame {&frame-name}:TITLE = title0 +
                                   substitute(" История для расписаний типа: &1"
                                   , X_upper-dis-time-rule.des)
                                   .

        { gbl/fltopend.i
        &where-cond = " ~
          X_c-dis-time-rule.upper-time-rule-num  = p-upper-rule-num    ~
                      "
        &dyn_where-cond = " substitute('X_c-dis-time-rule.upper-time-rule-num  = &1', p-upper-rule-num ) "

        &use-ind    = "  "
        &by         = "  " }
    END.
    WHEN "rl-root":U THEN DO:
       assign
       filter-point = filter-point0 + p-mode
       filter-label = substitute("&1 одно расписание", filter-label0)
       .
       ASSIGN
       frame {&frame-name}:TITLE = title0 +
                                   substitute(" История для расписания №&1"
                                   , p-rule-num)
                                   .

        { gbl/fltopend.i
        &where-cond = " ~
          X_c-dis-time-rule.time-rule-num  = p-rule-num  or  X_c-dis-time-rule.upper-time-rule-num = p-rule-num ~
                      "
        &dyn_where-cond = " substitute(' X_c-dis-time-rule.time-rule-num  = &1 or X_c-dis-time-rule.upper-time-rule-num = &1 ', p-rule-num) "

        &use-ind    = "  "
        &by         = "  " }
    END.
    WHEN "one":U THEN DO:
       assign
       filter-point = filter-point0 + p-mode
       filter-label = substitute("&1 один расписание", filter-label0)
       .
       ASSIGN
       frame {&frame-name}:TITLE =  substitute(" История для расписания с номером &1" , p-rule-num)
                                   .
        { gbl/fltopend.i
        &where-cond = " ~
          X_c-dis-time-rule.time-rule-num  = p-rule-num   ~
                      "
        &dyn_where-cond = " substitute(' X_c-dis-time-rule.time-rule-num  = &1', p-rule-num ) "

        &use-ind    = "  "
        &by         = "  " }
    END.
END CASE.
if not p-open-query then
REPOSITION br-c-dis-time-rule to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-c-dis-time-rule:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-c-dis-time-rule in frame {&frame-name}.
APPLY "ENTRY" TO br-c-dis-time-rule.
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
  tbl = 'c-dis-time-rule'
  join-tbl = 'X_c-dis-time-rule'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('des', 'Описание расписания', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('templ-rl-root', 'Номер типа(шаблона) расписания', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
if p-mode <> "one" then do:
  run fltfield-add in this-procedure('rule-num', 'Номер расписания', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
end.
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
run fltfield-add in this-procedure('is-news', 'СПН', '',
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
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-c-dis-time-rule Dialog-Frame
PROCEDURE proc-br-c-dis-time-rule :
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
define buffer new_c-dis-time-rule for ub.c-dis-time-rule.
define buffer current_dis-time-rule for ub.dis-time-rule.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-is-created as logical no-undo .
define variable v-is-deleted as logical no-undo .
define variable jj as integer no-undo .
define variable v-field-name as character no-undo .
define variable v-field-label as character no-undo .
define variable v-field-function as character no-undo .


for each temp-changes:
    delete temp-changes.
END.
if not available X_c-dis-time-rule then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
assign
v-is-created = X_c-dis-time-rule.action = integer({&hn-create})
v-is-deleted = X_c-dis-time-rule.action = integer({&hn-delete})
.

find first new_c-dis-time-rule no-lock where
            new_c-dis-time-rule.time-rule-num = X_c-dis-time-rule.time-rule-num
        AND new_c-dis-time-rule.corr-user-db-num = X_c-dis-time-rule.corr-user-db-num
        AND new_c-dis-time-rule.chip-num > X_c-dis-time-rule.chip-num
    no-error.

if not available new_c-dis-time-rule then do:
    find first current_dis-time-rule no-lock where
                 current_dis-time-rule.time-rule-num = X_c-dis-time-rule.time-rule-num no-error.
    if not available current_dis-time-rule then do:
         return error.
    end.
    buffer-compare current_dis-time-rule to X_c-dis-time-rule
    case-sensitive
    save result in v-chg-fields.
    if v-is-created then do:
      IF current_dis-time-rule.time-from = -1  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "time-from":U, "":U).
      END.
      IF current_dis-time-rule.time-to = -1  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "time-to":U, "":U).
      END.
      IF current_dis-time-rule.date-from = 12/31/1989  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "date-from":U, "":U).
      END.
      IF current_dis-time-rule.date-to = 12/31/1989 THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "date-to":U, "":U).
      END.
      IF current_dis-time-rule.month-day = -1  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "month-day":U, "":U).
      END.
      IF current_dis-time-rule.week-day-0 = ?  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "week-day-0":U, "":U).
      END.
      IF current_dis-time-rule.week-day-1 = ?  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "week-day-1":U, "":U).
      END.
      IF current_dis-time-rule.week-day-2 = ?  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "week-day-2":U, "":U).
      END.
      IF current_dis-time-rule.week-day-3 = ?  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "week-day-3":U, "":U).
      END.
      IF current_dis-time-rule.week-day-4 = ?  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "week-day-4":U, "":U).
      END.
      IF current_dis-time-rule.week-day-5 = ?  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "week-day-5":U, "":U).
      END.
      IF current_dis-time-rule.week-day-6 = ?  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "week-day-6":U, "":U).
      END.
      IF current_dis-time-rule.week-day-7 = ?  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "week-day-7":U, "":U).
      END.
    end.
end.
else do:
    buffer-compare new_c-dis-time-rule
    except chip-num corr-date corr-time corr-user-name corr-user-db-num to X_c-dis-time-rule
    case-sensitive
    save result in v-chg-fields.

    if v-is-created then do:
      IF new_c-dis-time-rule.time-from = -1  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "time-from":U, "":U).
      END.
      IF new_c-dis-time-rule.time-to = -1  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "time-to":U, "":U).
      END.
      IF new_c-dis-time-rule.date-from = 12/31/1989  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "date-from":U, "":U).
      END.
      IF new_c-dis-time-rule.date-to = 12/31/1989 THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "date-to":U, "":U).
      END.
      IF new_c-dis-time-rule.month-day = -1  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "month-day":U, "":U).
      END.
      IF new_c-dis-time-rule.week-day-0 = ?  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "week-day-0":U, "":U).
      END.
      IF new_c-dis-time-rule.week-day-1 = ?  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "week-day-1":U, "":U).
      END.
      IF new_c-dis-time-rule.week-day-2 = ?  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "week-day-2":U, "":U).
      END.
      IF new_c-dis-time-rule.week-day-3 = ?  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "week-day-3":U, "":U).
      END.
      IF new_c-dis-time-rule.week-day-4 = ?  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "week-day-4":U, "":U).
      END.
      IF new_c-dis-time-rule.week-day-5 = ?  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "week-day-5":U, "":U).
      END.
      IF new_c-dis-time-rule.week-day-6 = ?  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "week-day-6":U, "":U).
      END.
      IF new_c-dis-time-rule.week-day-7 = ?  THEN DO:
        ASSIGN
        v-chg-fields = REPLACE(v-chg-fields, "week-day-7":U, "":U).
      END.
    end.
end.

&scop fields-name-list "des,time-rule-num,sts"
&scop fields-label-list  "Описание,№ расписания,Статус"
&scop fields-function-list ",,display-int-status"

  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, {&fields-name-list}).
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, {&fields-label-list})
    v-field-function = entry(jj, {&fields-function-list})
    .

    create temp-changes.
    assign
    temp-changes.f_name = v-field-name
    temp-changes.l_name = v-field-label
    temp-changes.v_old =  (if v-is-created
                          then "":U
                          else string(buffer X_c-dis-time-rule:buffer-field(v-field-name):buffer-value))
    temp-changes.v_new = (if v-is-deleted
                          then "":U
                          else  (if available new_c-dis-time-rule
                                then string(buffer new_c-dis-time-rule:buffer-field(v-field-name):buffer-value)
                                else string(buffer current_dis-time-rule:buffer-field(v-field-name):buffer-value)
                                )
                         )
    .
    if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.

end.
assign
br-changes:title in frame {&frame-name} = (if X_c-dis-time-rule.time-rule-num  <= {&max-num-dr-template}
                                            then "Шаблон"
                                            else (if X_c-dis-time-rule.upper-time-rule-num <= {&max-num-dr-template}
                                                  then "Расписание"
                                                  else "Детализация"))

.


Open QUery br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-action Dialog-Frame
FUNCTION get-action RETURNS CHARACTER
  ( p-action as INTEGER ) :
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