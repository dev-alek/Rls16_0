&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_c-sum-grp FOR ub.c-sum-grp.
DEFINE BUFFER X_curr_clients FOR ub.clients.
DEFINE BUFFER X_sum-grp FOR ub.sum-grp.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История групп товаров на кассах

Автор: Бахтадзе Наталья Викторовна
Дата создания: 15/03/04
Author: Bakhtadze Natalya
Creation date: 15/03/04

Список истории групп для суммовых чеков
*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/
define input parameter p-mode  as char   no-undo .
/*one subject*/
define input parameter p-grp-code like ub.sum-grp.grp-code no-undo .
define input parameter p-subject as character no-undo .
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "История групп товаров на кассах":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ ref/disgrpru.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
define variable v-rid-list as character no-undo .
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.

{ ref/tmpchgs.i " " " " "with-action" }

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
&Scoped-define INTERNAL-TABLES temp-changes X_c-sum-grp

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE br-csum-grp                                   */
&Scoped-define FIELDS-IN-QUERY-br-csum-grp mark-string(recid(X_c-sum-grp), v-rid-list) get-subject(X_c-sum-grp.subject) usrfulnf(X_c-sum-grp.corr-user-name) X_c-sum-grp.corr-date string(X_c-sum-grp.corr-time, "HH:MM") X_c-sum-grp.grp-name X_c-sum-grp.grp-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-csum-grp
&Scoped-define SELF-NAME br-csum-grp
&Scoped-define QUERY-STRING-br-csum-grp FOR EACH X_c-sum-grp NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-csum-grp OPEN QUERY {&SELF-NAME} FOR EACH X_c-sum-grp NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-csum-grp X_c-sum-grp
&Scoped-define FIRST-TABLE-IN-QUERY-br-csum-grp X_c-sum-grp


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-csum-grp}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-Help br-csum-grp ~
BR-changes mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

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

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.

DEFINE QUERY br-csum-grp FOR
      X_c-sum-grp SCROLLING.
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
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.04.

DEFINE BROWSE br-csum-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-csum-grp Dialog-Frame _FREEFORM
  QUERY br-csum-grp NO-LOCK DISPLAY
      mark-string(recid(X_c-sum-grp), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      get-subject(X_c-sum-grp.subject) COLUMN-LABEL "Предмет изменений" FORMAT "X(15)":U
      usrfulnf(X_c-sum-grp.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
      X_c-sum-grp.corr-date COLUMN-LABEL "Дата!измен" FORMAT "99/99/9999":U
      string(X_c-sum-grp.corr-time, "HH:MM") COLUMN-LABEL "Время!измен" FORMAT "X(5)":U
      X_c-sum-grp.grp-name FORMAT "X(255)":U COLUMN-LABEL "Название группы" WIDTH 35
      X_c-sum-grp.grp-code COLUMN-LABEL "Код!группы" FORMAT "999":U WIDTH 6
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.25 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     B-lookup AT ROW 1 COL 61
     B-Help AT ROW 1 COL 95
     br-csum-grp AT ROW 3 COL 1
     BR-changes AT ROW 13 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(78.62) SKIP(20.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История групп товаров на кассах"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_c-sum-grp B "?" ? ub c-sum-grp
      TABLE: X_curr_clients B "?" ? ub clients
      TABLE: X_sum-grp B "?" ? ub sum-grp
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-csum-grp B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes br-csum-grp Dialog-Frame */
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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-csum-grp
/* Query rebuild information for BROWSE br-csum-grp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-sum-grp NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-csum-grp */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* История групп товаров на кассах */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История групп товаров на кассах */
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
  if available X_c-sum-grp then do:
    { gbl/markstrn.i X_c-sum-grp v-rid-list }
    loc#log = br-csum-grp:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-csum-grp:select-next-row ().
        apply "VALUE-CHANGED" to br-csum-grp in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-csum-grp in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_c-sum-grp ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_c-sum-grp ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-csum-grp
&Scoped-define SELF-NAME br-csum-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-csum-grp Dialog-Frame
ON RETURN OF br-csum-grp IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-csum-grp IN FRAME Dialog-Frame
    DO:
    run proc-br-csum-grp no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-csum-grp Dialog-Frame
ON VALUE-CHANGED OF br-csum-grp IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure no-error.
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
{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-csum-grp" }
{ gbl/brwrefre.i "v-doc-rec = recid(X_sum-grp). run openbr in this-procedure. reposition br-csum-grp to recid v-doc-rec no-error. ~
              apply 'value-changed' to br-csum-grp.   " }

{ gbl/srt-clmn.i
  &browse-name    = "br-csum-grp"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_c-sum-grp.grp-name"
  &sort-clmn_2    = "X_c-sum-grp.corr-date"
  &open-query     = "run OpenBr."
  &open-query-otherwise = "run OpenBr."
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
 if LOOKUP(p-mode, 'one':U,
                {&delim-par}) = 0
     then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return error .
 end.
 if p-mode = "one":U then do:
  find first X_sum-grp no-lock where
                X_sum-grp.grp-code = p-grp-code no-error.
    if not available X_sum-grp then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-grp-code"
        p-grp-code
        view-as alert-box ERROR.
        return.
    end.
  end.
 v-rid-list = p-rid-list.
 { gbl/curdbnum.i v-db-num }
  RUN MyEnable.
  RUn OpenBR.
  HIDE mark-num in frame {&frame-name} .
  if v-doc-rec <> ? then
  REPOSITION br-csum-grp to recid v-doc-rec No-ERROR.
    { gbl/mv-clmn.i
    &browse-name = "br-csum-grp"
    &frame-name = "{&frame-name}"
    &ext-col = 6
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6'"
    &prev-order-column-condition_1 = " p-mode = ~'one' "
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
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-Help br-csum-grp BR-changes mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
X_c-sum-grp.grp-name:resizable in browse br-csum-grp = yes.
assign
temp-changes.l_name:resizable in browse br-changes = true
temp-changes.v_old:resizable in browse br-changes = true
temp-changes.v_new:resizable in browse br-changes = true
temp-changes.l_name:width in browse br-changes = 30
temp-changes.v_old:width in browse br-changes = 40
temp-changes.v_new:width in browse br-changes = 40
.
DISPLAY mark-num
WITH FRAME {&frame-name} .
ENABLE
b-quit
B-mark when LOOKUP("b-mark":U, bttns) > 0
B-sel when LOOKUP("b-sel":U, bttns) > 0
B-Help
br-csum-grp mark-num
br-changes
with FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
CASE p-mode:
  when "one":U then do:
    OPEN QUERY br-csum-grp FOR EACH X_c-sum-grp NO-LOCK where
                                  X_c-sum-grp.grp-code = p-grp-code
                              AND X_c-sum-grp.corr-user-db-num = 0
                                  INDEXED-REPOSITION.
  end.
  when "subject" then do:
    OPEN QUERY br-csum-grp FOR EACH X_c-sum-grp NO-LOCK where
                                  X_c-sum-grp.subject = p-subject
                              and X_c-sum-grp.grp-code = p-grp-code
                              AND X_c-sum-grp.corr-user-db-num = 0
                                  INDEXED-REPOSITION.

  end.
end case.
APPLY "VALUE-CHANGED" TO br-csum-grp in frame {&frame-name}.
APPLY "ENTRY" TO br-csum-grp.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-csum-grp Dialog-Frame
PROCEDURE proc-br-csum-grp :
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
define buffer buf_c-dis-grp-rule for ub.c-dis-grp-rule.
for each temp-changes:
    delete temp-changes.
END.
if not available X_c-sum-grp then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
&scop fields-name-list "grp-code,grp-name"
define variable v-label-param as character no-undo .
CASE X_c-sum-grp.subject:
  when {&table_sum-grp} then do:
    v-label-param =
      "grp-code" + {&delim-par} + "Код группы" + {&delim-par} + "" + {&delim-flf}
    + "grp-name" + {&delim-par} + "Наименование группы" + {&delim-par} + ""  .
    run proc-full-temp-changes in this-procedure (
                                                input  (X_c-sum-grp.action = integer({&hn-create}))
                                                ,input  (X_c-sum-grp.action = integer({&hn-delete}))
                                                ,input  buffer X_c-sum-grp:handle
                                                ,input  {&table_sum-grp}
                                                ,input  {&fields-name-list}
                                                ,input  v-label-param).
  end.
  when {&table_dis-grp-rule} then do:
    &scop fields-name-list "rule-num,pos-type,templ-rl-root,discnt-role"
    find first buf_c-dis-grp-rule no-lock where
              buf_c-dis-grp-rule.classif-type = {&table_sum-grp}
         and  buf_c-dis-grp-rule.node-code = X_c-sum-grp.grp-code
        and  buf_c-dis-grp-rule.corr-user-db-num = X_c-sum-grp.corr-user-db-num
        and  buf_c-dis-grp-rule.chip-num = X_c-sum-grp.chip-num no-error.
   if not available buf_c-dis-grp-rule then do:
     message
     "Неверная ссылка на c-dis-grp-rule в таблице c-sum-grp"
     view-as alert-box error.
   end.
v-label-param =
  "rule-num" + {&delim-par} + "Номер правила скидки" + {&delim-par} + "" + {&delim-flf}
 + "pos-type" + {&delim-par} + "Место использ." + {&delim-par} + "" + {&delim-flf}
 + "templ-rl-root" + {&delim-par} + "Тип шаблона" + {&delim-par} + "disgrpru-get-disc-label"  + {&delim-flf}
 + "discnt-role" + {&delim-par} + "Тип скидки" + {&delim-par} + "disgrpru-get-disc-role-label"
 .
    run proc-full-temp-changes in this-procedure (
                                                input  (X_c-sum-grp.action = integer({&hn-create}))
                                                ,input  (X_c-sum-grp.action = integer({&hn-delete}))
                                                ,input  buffer buf_c-dis-grp-rule:handle
                                                ,input  {&table_dis-grp-rule}
                                                ,input  {&fields-name-list}
                                                ,input  v-label-param).

  end.
END CASe.
Open QUery br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-subject Dialog-Frame
FUNCTION get-subject RETURNS CHARACTER
  ( p-subject as character ) :

  &scop hn-sum-grp-hist-code p-subject
  RETURN {&hn-sum-grp-hist-name}.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME