&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_c-dis-rule FOR ub.c-dis-rule.
DEFINE BUFFER X_curr_clients FOR ub.clients.
DEFINE BUFFER X_upper-dis-rule FOR ub.dis-rule.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории ПРАВИЛ СКИДОК

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
/*{&all}  "one"  {&g___object} "upper-rule-num" "rl-root"  */
define input parameter p-rule-num like ub.dis-rule.rule-num no-undo .
define input parameter p-upper-rule-num like ub.dis-rule.upper-rule-num no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список истории ПРАВИЛ СКИДОК":U.
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ gbl/flt-def.i }
{ gbl/fltfield.i }
{ gbl/disrules.i work }
{ gbl/disrules.i }
{ ref/gtregion.i }
{ ref/tmpchgs.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
define variable v-rid-list as character no-undo .
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable filter-label0 as character no-undo init "История правил скидки" .
define variable filter-label as character no-undo init "История правил скидки" .
define variable filter-point as character no-undo init "discruls" .
define variable filter-point0 as character no-undo init "discruls" .
define variable v-host-code like ub.sysconf.host-code no-undo .


&SCOPED-DEFINE used-status-code STRING(X_c-dis-rule.sts)
&SCOPED-DEFINE discnt-type-code string(X_c-dis-rule.discnt-type)
&SCOPED-DEFINE discnt-target-code STRING(X_c-dis-rule.subject-type)
&SCOPED-DEFINE discnt-v-code STRING(X_c-dis-rule.value-type)
define buffer pos_c-dis-rule for ub.c-dis-rule.
define buffer X_dis-rule for ub.dis-rule.

&scop cant-positioning   if error-status:error then do: ~
                          find first pos_dis-rule no-lock where ~
                                  recid(pos_dis-rule) = loc-doc-rec no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи ПРАВИЛО СКИДКИ" skip~
                            string(if avail pos_dis-rule ~
                                    then  substitute("номер правила скидки: &1" ~
                                                    , pos_dis-rule.rule-num) ~
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
&Scoped-define BROWSE-NAME br-c-dis-rule

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-dis-rule temp-changes

/* Definitions for BROWSE br-c-dis-rule                                 */
&Scoped-define FIELDS-IN-QUERY-br-c-dis-rule mark-string(recid(X_c-dis-rule), v-rid-list) X_c-dis-rule.des X_c-dis-rule.is-news get-action(X_c-dis-rule.action) X_c-dis-rule.corr-user-db-num usrfulnf(X_c-dis-rule.corr-user-name) X_c-dis-rule.corr-date string(X_c-dis-rule.corr-time, "HH:MM") X_c-dis-rule.rule-num gtregion(X_c-dis-rule.host-code, X_c-dis-rule.obj-type, X_c-dis-rule.obj-code, no) {&discnt-type-name} {&discnt-target-name} {&discnt-v-name}
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-c-dis-rule
&Scoped-define SELF-NAME br-c-dis-rule
&Scoped-define QUERY-STRING-br-c-dis-rule FOR EACH X_c-dis-rule NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-c-dis-rule OPEN QUERY {&SELF-NAME} FOR EACH X_c-dis-rule NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-c-dis-rule X_c-dis-rule
&Scoped-define FIRST-TABLE-IN-QUERY-br-c-dis-rule X_c-dis-rule


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
    ~{&OPEN-QUERY-br-c-dis-rule}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH X_c-dis-rule SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH X_c-dis-rule SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame X_c-dis-rule
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame X_c-dis-rule


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-sch B-Help ~
br-c-dis-rule BR-changes mark-num
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
DEFINE QUERY br-c-dis-rule FOR
      X_c-dis-rule SCROLLING.

DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      X_c-dis-rule SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-c-dis-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-c-dis-rule Dialog-Frame _FREEFORM
  QUERY br-c-dis-rule NO-LOCK DISPLAY
      mark-string(recid(X_c-dis-rule), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_c-dis-rule.des FORMAT "X(50)":U
      X_c-dis-rule.is-news FORMAT "+/":U
      get-action(X_c-dis-rule.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
      X_c-dis-rule.corr-user-db-num COLUMN-LABEL "Номер!БД" FORMAT ">>>>9":U
      usrfulnf(X_c-dis-rule.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
      X_c-dis-rule.corr-date COLUMN-LABEL "Дата корр" FORMAT "99/99/9999":U
      string(X_c-dis-rule.corr-time, "HH:MM") COLUMN-LABEL "Время корр" FORMAT "X(10)":U
      X_c-dis-rule.rule-num COLUMN-LABEL "№ правила" FORMAT ">>>>>>>>9":U
      gtregion(X_c-dis-rule.host-code, X_c-dis-rule.obj-type, X_c-dis-rule.obj-code, no) COLUMN-LABEL "Область действия" FORMAT "X(12)":U
      {&discnt-type-name} COLUMN-LABEL "Тип скидки" FORMAT "X(20)":U
            WIDTH 22
      {&discnt-target-name} COLUMN-LABEL "Объект воздействия!скидки" FORMAT "X(20)":U
            WIDTH 22
      {&discnt-v-name} COLUMN-LABEL "Тип!знач." FORMAT "X(3)":U
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
     br-c-dis-rule AT ROW 3 COL 1
     BR-changes AT ROW 13 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(78.62) SKIP(20.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История правил скидок"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_c-dis-rule B "?" ? ub c-dis-rule
      TABLE: X_curr_clients B "?" ? ub clients
      TABLE: X_upper-dis-rule B "?" ? ub dis-rule
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-c-dis-rule B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes br-c-dis-rule Dialog-Frame */
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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-c-dis-rule
/* Query rebuild information for BROWSE br-c-dis-rule
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-dis-rule NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-c-dis-rule */
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
     _TblList          = "Temp-Tables.X_c-dis-rule"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* История правил скидок */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История правил скидок */
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
  if available X_c-dis-rule then do:
    { gbl/markstrn.i X_c-dis-rule v-rid-list }
    loc#log = br-c-dis-rule:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-c-dis-rule:select-next-row ().
        apply "VALUE-CHANGED" to br-c-dis-rule in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-c-dis-rule in frame {&frame-name}.
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
    if ( available X_c-dis-rule ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_c-dis-rule ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-c-dis-rule
&Scoped-define SELF-NAME br-c-dis-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-c-dis-rule Dialog-Frame
ON RETURN OF br-c-dis-rule IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-c-dis-rule IN FRAME Dialog-Frame
    DO:
  run proc-br-c-dis-rule in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-c-dis-rule Dialog-Frame
ON VALUE-CHANGED OF br-c-dis-rule IN FRAME Dialog-Frame
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
{ gbl/app_help.i &disable_diasize_init=true &browse-name="BR-c-dis-rule" }
{ gbl/brwrefre.i "v-doc-rec = ?. if available X_c-dis-rule then v-doc-rec = recid(X_c-dis-rule). run OpenBr in this-procedure ( input yes, input no, input no). reposition br-c-dis-rule to recid v-doc-rec no-error. v-doc-rec = ?. ~
              APPLY 'value-changed' to br-c-dis-rule. " }
{ gbl/srt-clmd.i
  &browse-name    = "br-c-dis-rule"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-br-c-dis-rule}"
  &sort-clmn_1    = "X_c-dis-rule.rule-num"
  &open-query     = "run OpenBr in this-procedure ( input YES, input NO, input NO)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input YES, input NO, input NO)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}
{ gbl/setfltnm.i  }

{ gbl/brwrepos.i
  &line-num=5
}

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
   find first X_upper-dis-rule no-lock where
          X_upper-dis-rule.rule-num = p-upper-rule-num no-error.
   if not available X_upper-dis-rule then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-upper-rule-num"
    p-upper-rule-num
    view-as alert-box ERROR.
    return error .
   end.
  end.
  if p-mode = "one" then do:
   find first X_dis-rule no-lock where
          X_dis-rule.rule-num = p-rule-num no-error.
   if not available X_dis-rule then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-rule-num"
    p-upper-rule-num
    view-as alert-box ERROR.
    return error .
   end.
  end.
 if p-mode = {&g___object} then do:
  find first X_curr_clients no-lock where
            X_curr_clients.obj-type = p-obj-type
       AND X_curr_clients.obj-code = p-obj-code no-error.
  if not available X_curr_clients then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-obj-type p-obj-code"
    p-obj-type p-obj-code
    view-as alert-box ERROR.
    return error .
  end.
  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
end.


 { gbl/curdbnum.i v-db-num }
 v-rid-list = p-rid-list.
  RUN MyEnable in this-procedure .
  RUn OpenBR IN THIS-PROCEDURE ( input YES, input NO, input NO).
  HIDE mark-num in frame {&frame-name} .
  if v-doc-rec <> ? then
  REPOSITION br-c-dis-rule to recid v-doc-rec No-ERROR.
    { gbl/mv-clmn.i
    &browse-name = "br-c-dis-rule"
    &frame-name = "{&frame-name}"
    &ext-col = 13
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11,12,13'"
    &prev-order-column-condition_1 = " p-mode = ~{&all~} "
    &prev-order-column_2 = "'1,2,3,4,5,6,7,8,9,10,11,12,13'"
    &prev-order-column-condition_2 = " p-mode = 'upper-rule-num':U or p-mode = 'one' "
    &prev-order-column_3 = "'1,2,3,4,5,6,8,9,10,11,12,13,9'"
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
  ENABLE b-quit B-mark B-sel B-sch B-Help br-c-dis-rule BR-changes mark-num
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
br-c-dis-rule
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
define variable title0 as character no-undo init "Список истории правил скидок".
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

&scop flt-open-open-query OPEN QUERY br-c-dis-rule FOR EACH X_c-dis-rule

&scop flt-open-dyn_open-query FOR EACH X_c-dis-rule

&scop flt-open-query-handle QUERY br-c-dis-rule:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-dis-rule

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_c-dis-rule

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
       filter-label = substitute("&1 для правил одного шаблона", filter-label0)
       .
       ASSIGN
       frame {&frame-name}:TITLE = title0 +
                                   substitute(" История для правил скидок типа: &1"
                                   , X_upper-dis-rule.des)
                                   .

        { gbl/fltopend.i
        &where-cond = " ~
          X_c-dis-rule.upper-rule-num  = p-upper-rule-num    ~
                      "
        &dyn_where-cond = " substitute('X_c-dis-rule.upper-rule-num  = &1', p-upper-rule-num )  "

        &use-ind    = "  "
        &by         = "  " }
    END.
    WHEN "rl-root":U THEN DO:
       assign
       filter-point = filter-point0 + p-mode
       filter-label = substitute("&1 для одного правила", filter-label0)
       .
       ASSIGN
       frame {&frame-name}:TITLE = title0 +
                                   substitute(" История для правила скидки №&1"
                                   , p-rule-num)
                                   .

        { gbl/fltopend.i
        &where-cond = " ~
          X_c-dis-rule.rule-num  = p-rule-num  or  X_c-dis-rule.upper-rule-num = p-rule-num ~
                      "
        &dyn_where-cond = " substitute('  X_c-dis-rule.rule-num  = &1  or  X_c-dis-rule.upper-rule-num = &1 ', p-rule-num) "

        &use-ind    = "  "
        &by         = "  " }
    END.
    WHEN "one":U THEN DO:
       assign
       filter-point = filter-point0 + p-mode
       filter-label = substitute("&1 одного правила", filter-label0)
       .
       ASSIGN
       frame {&frame-name}:TITLE =  substitute(" История для правила скидок с номером &1" , p-rule-num)
                                   .
        { gbl/fltopend.i
        &where-cond = " ~
          X_c-dis-rule.rule-num  = p-rule-num   ~
                      "
        &dyn_where-cond = " substitute(' X_c-dis-rule.rule-num  = &1', p-rule-num  ) "

        &use-ind    = "  "
        &by         = "  " }
    END.
    WHEN {&g___object} THEN DO:
       assign
       filter-point = filter-point0 + p-mode
       filter-label = substitute("&1 один объект", filter-label0)
       .
       ASSIGN
       frame {&frame-name}:TITLE =  substitute(" История для правил скидок, действующих на объекте &1&2" , p-obj-type, p-obj-code)
                                   .
        { gbl/fltopend.i
        &where-cond = " ~
          X_c-dis-rule.rule-num  = p-rule-num  ~
      AND X_c-dis-rule.host-code = 0 ~
      OR  (X_c-dis-rule.host-code = v-host-code ~
      and X_c-dis-rule.obj-type = '':U ~
      and X_c-dis-rule.obj-code = 0)  ~
      OR  (X_c-dis-rule.host-code = v-host-code ~
      and X_c-dis-rule.obj-type = p-obj-type ~
      and X_c-dis-rule.obj-code = p-obj-code)  ~
                      "
        &dyn_where-cond = " substitute(' X_c-dis-rule.rule-num  = &1  ~
      AND X_c-dis-rule.host-code = 0 ~
      OR  (X_c-dis-rule.host-code = &2 ~
      and X_c-dis-rule.obj-type = &3&3 ~
      and X_c-dis-rule.obj-code = 0)  ~
      OR  (X_c-dis-rule.host-code = &2 ~
      and X_c-dis-rule.obj-type = &3&4&3 ~
      and X_c-dis-rule.obj-code = &5) ', p-rule-num, v-host-code, ~{&double-quote~}, p-obj-type, p-obj-code)  "

        &use-ind    = "  "
        &by         = "  " }
    END.

END CASE.
if not p-open-query then
REPOSITION br-c-dis-rule to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-c-dis-rule:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-c-dis-rule in frame {&frame-name}.
APPLY "ENTRY" TO br-c-dis-rule.
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
  tbl = 'c-dis-rule'
  join-tbl = 'X_c-dis-rule'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('des', 'Описание правила скидок', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('templ-rl-root', 'Номер типа(шаблона) правила', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
if p-mode <> "one" then do:
  run fltfield-add in this-procedure('rule-num', 'Номер правила', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
end.
run fltfield-add in this-procedure('host-code', 'Фирма', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt-value', 'Значение скидки', '',
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-c-dis-rule Dialog-Frame
PROCEDURE proc-br-c-dis-rule :
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
define buffer new_c-dis-rule for ub.c-dis-rule.
define buffer current_dis-rule for ub.dis-rule.
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
define variable  v-des               like ub.dis-rule.des               no-undo .
define variable  v-level-1           as character no-undo .
define variable  v-level-2           as character no-undo .
define variable  v-discnt-type       like ub.dis-rule.discnt-type       no-undo .
define variable  v-subject-type      like ub.dis-rule.subject-type      no-undo .
define variable  v-value-type        like ub.dis-rule.value-type        no-undo .
define variable  v-global            as integer no-undo .
define variable  v-host              as integer no-undo .
define variable  v-object            as integer no-undo .
define variable  v-output-display    as logical   no-undo . /* виден в броусе */
define variable  v-tree              as character no-undo .
define variable  v-other             as character no-undo . /* еще чего - нибудь */
define variable v-using-fields as character no-undo .
define variable v-fields-name-list as character no-undo .
define variable v-fields-label-list as character no-undo .
define variable v-fields-function-list as character no-undo .
define buffer buf_temp-drt-prop for temp-drt-prop.

for each temp-changes:
    delete temp-changes.
END.
if not available X_c-dis-rule then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
assign
v-is-created = X_c-dis-rule.action = integer({&hn-create})
v-is-deleted = X_c-dis-rule.action = integer({&hn-delete})
.
run dr-code in this-procedure ( input X_c-dis-rule.templ-rl-root
                              ,output v-des
                              ,output v-discnt-type
                              ,output v-subject-type
                              ,output v-value-type
                              ,output v-level-1
                              ,output v-level-2
                              ,output v-global
                              ,output v-host
                              ,output v-object
                              ,output v-output-display
                              ,output v-tree
                              ,output v-other
                                                        ) no-error .

find first new_c-dis-rule no-lock where
            new_c-dis-rule.rule-num = X_c-dis-rule.rule-num
        AND new_c-dis-rule.chip-num > X_c-dis-rule.chip-num
        AND new_c-dis-rule.corr-user-db-num = X_c-dis-rule.corr-user-db-num
    no-error.

if not available new_c-dis-rule then do:
    find first current_dis-rule no-lock where
                 current_dis-rule.rule-num = X_c-dis-rule.rule-num no-error.
    if not available current_dis-rule then do:
         return error.
    end.
    buffer-compare current_dis-rule to X_c-dis-rule
    case-sensitive
    save result in v-chg-fields.
end.
else do:
    buffer-compare new_c-dis-rule
    except chip-num corr-date corr-time corr-user-name corr-user-db-num
    to X_c-dis-rule
    case-sensitive
    save result in v-chg-fields.
end.

&scop fields-name-list "other-inf,uniq-field,time-templ-rl-root,des,rule-num,dis-kat,discnt-value,doc-qnty,time-rule-num,tot-sum,charkey_one,charkey_two,charkey_three,key#_one,key#_two,key#_three,sts"
&scop fields-label-list "Св-ва,Дерево,Шаблон расписания,Описание,№ правила,Категория скидки,Значение скидки,Количество,Номер расписания,Сумма в ценах продажи, , , , , , ,Статус"
&scop fields-function-list " , , , , , , , , , , , , , , , ,display-int-status"

run disrules-fill-properties in this-procedure ( input X_c-dis-rule.templ-rl-root).
if X_c-dis-rule.lvl-num < 2
then do:
  v-using-fields = v-level-1.
end.
else do:
  v-using-fields = v-level-2.
end.
define variable ll as integer no-undo .
do ii = 1 to num-entries({&fields-name-list}):
  if lookup(entry(ii, {&fields-name-list}), v-using-fields) > 0 then do:
    assign
    ll = ll + 1
    v-fields-name-list = v-fields-name-list + (if ll  = 1 then '' else {&comma-char}) + entry(ii, {&fields-name-list})
    v-fields-label-list = v-fields-label-list + (if ll = 1 then '' else {&comma-char}) + entry(ii, {&fields-label-list})
    v-fields-function-list = v-fields-function-list + (if ll = 1 then '' else {&comma-char}) + entry(ii, {&fields-function-list})
    .
  end.
end.
do ii = 1 to num-entries(v-fields-name-list):
  if X_c-dis-rule.lvl-num < 2
  then do:
    v-using-fields = v-level-1.
  end.
  else do:
    v-using-fields = v-level-2.
  end.
  if lookup(entry(ii, v-fields-name-list), v-using-fields) > 0 then do:
    find first buf_temp-drt-prop no-lock where
              buf_temp-drt-prop.upper-prop-code = entry(ii, v-fields-name-list)
          and buf_temp-drt-prop.prop-code = "label" no-error.
    if available buf_temp-drt-prop then do:
      entry(ii, v-fields-label-list) = buf_temp-drt-prop.property-value.
    end.
    else do:
      /*
      entry(ii, v-fields-label-list) = {&space-char} .*/
    end.
  end.
  else do:
    /*
    if lookup(entry(ii, v-fields-name-list), "discnt-value,des,dis-kat,tot-sum.doc-qnty," +
                                                "charkey_one,charkey_two,charkey_three," +
                                                "deckey_one,deckey_two,deckey_three," +
                                                "key#_one,key#_two,key#_three") > 0 then do:
      assign
      entry(ii, v-fields-label-list) = '':U
      entry(ii, v-fields-name-list) = '':U
      entry(ii, v-fields-function-list) = '':U
      v-fields-label-list = replace(v-fields-label-list, {&comma-char} + {&comma-char}, {&comma-char})
      v-fields-name-list = replace(v-fields-name-list, {&comma-char} + {&comma-char}, {&comma-char})
      v-fields-function-list = replace(v-fields-function-list, {&comma-char} + {&comma-char}, {&comma-char})
      .
    end.
    */
  end.
end.

_ii:
do ii = 1 to num-entries(v-chg-fields):
  assign
  v-field-name = entry(ii, v-chg-fields)
  jj = lookup(v-field-name, v-fields-name-list).
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, v-fields-label-list)
    v-field-function = entry(jj, v-fields-function-list)
    .

    create temp-changes.
    assign
    temp-changes.f_name = v-field-name
    temp-changes.l_name = v-field-label
    temp-changes.v_old =  (if v-is-created
                           then "":U
                           else string(buffer X_c-dis-rule:buffer-field(v-field-name):buffer-value))
    temp-changes.v_new = (if v-is-deleted
                          then "":U else (if available new_c-dis-rule
                                            then string(buffer new_c-dis-rule:buffer-field(v-field-name):buffer-value)
                                            else string(buffer current_dis-rule:buffer-field(v-field-name):buffer-value)
                                            )
                         )
    .
    if v-field-function <> {&space-char} then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.
  end.

assign
br-changes:title in frame {&frame-name} = (if X_c-dis-rule.rule-num  <= {&max-num-dr-template}
                                            then "Шаблон"
                                            else (if X_c-dis-rule.upper-rule-num <= {&max-num-dr-template}
                                                  then "Правило скидки"
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