&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-prop-ref NO-UNDO LIKE ub.prop-ref.
DEFINE BUFFER X_prop-head FOR ub.prop-head.
DEFINE BUFFER X_prop-ref FOR ub.prop-ref.
DEFINE BUFFER X_prop-ref-call FOR ub.prop-ref-call.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Срезы данных для объектов системы лояльности

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/05/06
Author: Bakhtadze Natalya
Creation date: 03/05/06

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-bttns as character no-undo .
define input parameter p-list-mode as character no-undo .
/*dis-tot dis-card-property {&all} call_id sum-id {&table_prop-ref-call}*/
define input parameter p-dtm-code as integer no-undo .
define input parameter p-sum-id as character no-undo .
define input parameter p-call-id as character no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-rid-list AS CHARACTER NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Срезы данных для объектов системы лояльности".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i DEF }
{ cmp/mrk-strf.i }
{ gbl/key-rec.i }
{ rul/calldscr.i }
{ gbl/flt-def.i  }
{ gbl/fltopend.i defproc }
{ ref/proprefd.i }

DEFINE VARIABLE ri AS RECID NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable sort-column-name as character no-undo .
DEFINE VARIABLE template-recid AS RECID NO-UNDO.
define variable v-doc-rec as recid no-undo .
define variable filter-point as character no-undo .

&SCOPED-DEFINE sort-clmn_1 mark-string(recid(X_prop-ref), v-rid-list)
&SCOPED-DEFINE dyn_sort-clmn_1  substitute('dynamic-function(&1mark-string&1, recid(X_prop-ref), &1&2&1)', ~{&double-quote~}, v-rid-list)
&scoped-define label-clmn_1 '*'
&SCOPED-DEFINE sort-clmn_2 X_prop-ref.sum-id
&scoped-define label-clmn_2 'Идентификатор!итога'
&SCOPED-DEFINE sort-clmn_3 X_prop-ref.dt-code
&scoped-define label-clmn_3 'Код!итога'
&SCOPED-DEFINE sort-clmn_4 X_prop-ref.dtm-code
&scoped-define label-clmn_4 'Код!объекта!операнда'
&SCOPED-DEFINE sort-clmn_5 X_prop-ref.caller_id
&scoped-define label-clmn_5 'Доп!идентификатор'
&SCOPED-DEFINE sort-clmn_6 calldscr(X_prop-ref-call.CALL_id)
&SCOPED-DEFINE dyn_sort-clmn_6 substitute('dynamic-function(&1calldscr&1, X_prop-ref.call_id)', ~{&double-quote~})
&scoped-define label-clmn_6 'Задействован'
&SCOPED-DEFINE sort-clmn_7 proprefd_sum-id-des(X_prop-ref.sum-id, X_prop-ref.ref-type)
&SCOPED-DEFINE dyn_sort-clmn_6 substitute('dynamic-function(&1calldscr&1, X_prop-ref.call_id)', ~{&double-quote~})
&scoped-define label-clmn_7 'Описание'
&SCOPED-DEFINE sort-clmn_8 get-dtm-name( INPUT X_prop-ref.dtm-code)
&SCOPED-DEFINE dyn_sort-clmn_8  substitute('dynamic-function(&1get-dtm-name&1, X_prop-ref.dtm-code)', ~{&double-quote~})
&scoped-define label-clmn_8 'Код-операнд'

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-prop-ref

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_prop-ref X_prop-head X_prop-ref-call

/* Definitions for BROWSE br-prop-ref                                   */
&Scoped-define FIELDS-IN-QUERY-br-prop-ref {&sort-clmn_1} {&sort-clmn_2} {&sort-clmn_3} {&sort-clmn_4} {&sort-clmn_8} {&sort-clmn_7} {&sort-clmn_5} {&sort-clmn_6}
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-prop-ref {&sort-clmn_2}
&Scoped-define SELF-NAME br-prop-ref
&Scoped-define QUERY-STRING-br-prop-ref FOR EACH X_prop-ref NO-LOCK, ~
       FIRST X_prop-head, ~
       FIRST X_prop-ref-call INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-prop-ref OPEN QUERY {&SELF-NAME} FOR EACH X_prop-ref NO-LOCK, ~
       FIRST X_prop-head, ~
       FIRST X_prop-ref-call INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-prop-ref X_prop-ref X_prop-head ~
X_prop-ref-call
&Scoped-define FIRST-TABLE-IN-QUERY-br-prop-ref X_prop-ref
&Scoped-define SECOND-TABLE-IN-QUERY-br-prop-ref X_prop-head
&Scoped-define THIRD-TABLE-IN-QUERY-br-prop-ref X_prop-ref-call


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-prop-ref}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-quit B-mark B-sel b-add b-chg b-del b-use ~
B-Help br-prop-ref mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-dtm-name Dialog-Frame
FUNCTION get-dtm-name RETURNS CHARACTER
  ( INPUT p-dtm-code AS integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "*"
     SIZE 3 BY 1.

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE BUTTON b-use
     LABEL "Используют"
     SIZE 15 BY 1.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9.88 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-prop-ref FOR
      X_prop-ref,
      X_prop-head,
      X_prop-ref-call SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-prop-ref
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-prop-ref Dialog-Frame _FREEFORM
  QUERY br-prop-ref NO-LOCK DISPLAY
      {&sort-clmn_1} COLUMN-LABEL {&label-clmn_1} FORMAT "X(1)":U
{&sort-clmn_2} COLUMN-LABEL {&label-clmn_2} FORMAT "X(21)":U WIDTH 22
{&sort-clmn_3} COLUMN-LABEL {&label-clmn_3} FORMAT ">>>>>>>>9":U WIDTH 9
{&sort-clmn_4} COLUMN-LABEL {&label-clmn_4} FORMAT ">>9" WIDTH 9
{&sort-clmn_8} COLUMN-LABEL {&label-clmn_8} FORMAT "X(255)" WIDTH 35
{&sort-clmn_7} COLUMN-LABEL {&label-clmn_7} FORMAT "X(255)" WIDTH 30
{&sort-clmn_5} COLUMN-LABEL {&label-clmn_5} FORMAT "X(20)":U
{&sort-clmn_6} COLUMN-LABEL {&label-clmn_6} FORMAT "X(50)":U
ENABLE
{&sort-clmn_2}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 14
     b-add AT ROW 1 COL 31 WIDGET-ID 2
     b-chg AT ROW 1 COL 41 WIDGET-ID 4
     b-del AT ROW 1 COL 51 WIDGET-ID 6
     b-use AT ROW 1 COL 61 WIDGET-ID 8
     B-Help AT ROW 1 COL 95
     br-prop-ref AT ROW 3 COL 1
     mark-num AT ROW 2 COL 2.88 NO-LABEL
     SPACE(86.24) SKIP(16.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-prop-ref T "?" NO-UNDO ub prop-ref
      TABLE: X_prop-head B "?" ? ub prop-head
      TABLE: X_prop-ref B "?" ? ub prop-ref
      TABLE: X_prop-ref-call B "?" ? ub prop-ref-call
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-prop-ref B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-chg:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-prop-ref
/* Query rebuild information for BROWSE br-prop-ref
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_prop-ref NO-LOCK, FIRST X_prop-head, FIRST X_prop-ref-call INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-prop-ref */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  DEFINE VARIABLE v-rec AS RECID NO-UNDO.
  define variable glog as logical no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_prop-ref_work':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    glog
  }
  if not glog then return no-apply.
  run rul/prop-ref-i.w ( INPUT parparentproc
                         ,INPUT {&add-def}
                         ,INPUT (if p-list-mode = "dtm-code"
                                 then p-dtm-code
                                 else 0) /*p-dtm-code*/
                         ,input 0
                         ,INPUT p-call-id
                         ,INPUT-OUTPUT v-rec) NO-ERROR.
  IF v-rec <> ? THEN DO:
      RUN openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
      REPOSITION br-prop-ref TO RECID v-rec NO-ERROR.
      APPLY "entry" TO br-prop-ref.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  IF NOT AVAILABLE X_prop-ref THEN RETURN NO-APPLY.
  DEFINE variable glog as logical no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_prop-ref_work':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    glog
  }
  if not glog then return no-apply.
  run rul/prop-ref3.p ( INPUT NO /*p-silent */
                       ,INPUT recid(X_prop-ref)) NO-ERROR.
  IF error-status:error THEN RETURN NO-APPLY.
  RUN openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
  APPLY "entry" TO br-prop-ref.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
DEFINE VARIABLE loc#log as logical no-undo.
    if available X_prop-ref then do:
      { gbl/markstrn.i X_prop-ref v-rid-list }
      loc#log = br-prop-ref:refresh() .

      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          loc#log = br-prop-ref:select-next-row ().
          apply "iteration-changed" to br-prop-ref in frame {&frame-name}.
      end.
      if num-entries( v-rid-list ) = 0
      then
          hide mark-num in frame {&frame-name}.
      else
          disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
    end.
    apply "entry" to br-prop-ref in frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available X_prop-ref then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_prop-ref ) ) .
  end.
  else do:
    bell.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-use
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-use Dialog-Frame
ON CHOOSE OF b-use IN FRAME Dialog-Frame /* Используют */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  IF NOT AVAILABLE X_prop-ref THEN RETURN NO-APPLY.
run ref/proprefs.w ( INPUT parparentproc
                  ,INPUT "" /*bttns*/
                  ,INPUT {&table_prop-ref-call} /*p-list-mode*/
                  ,INPUT X_prop-ref.dtm-code /*p-dtm-code*/
                  ,input X_prop-ref.sum-id
                  ,INPUT X_prop-ref.caller_id /*p-call-id*/
                  ,INPUT-OUTPUT v-rid-list) NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-prop-ref
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }

{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/brwrefre.i

  " if available X_prop-ref then ri = recid(X_prop-ref). ~
    RUn OpenBr in this-procedure ( input yes, input no, input '':U) . ~
    reposition br-prop-ref to recid ri no-error. "
}

{ gbl/setfltnm.i no-button }

{ gbl/srt-clmd.i
&browse-name = {&browse-name}
&frame-name  = {&frame-name}
&table-name = "X_prop-ref"
&ext-col = 4
&start-column  = 1
&sort-clmn_1   = "{&sort-clmn_1}"
&label-clmn_1  = "{&label-clmn_1}"
&sort-clmn_2   = "{&sort-clmn_2}"
&label-clmn_2  = "{&label-clmn_2}"
&sort-clmn_3   = "{&sort-clmn_3}"
&label-clmn_3  = "{&label-clmn_3}"
&sort-clmn_4   = "{&sort-clmn_4}"
&label-clmn_4  = "{&label-clmn_4}"
&open-query = "run OpenBr in this-procedure ( input yes, input no, input '':U) ."
&open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
&re-move-clmn = "no"
&mv-brw-default = "no"
&sort-column-name     = "sort-column-name"
}



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/getcntxt.i get }
 IF LOOKUP(p-list-mode, {&all} + {&comma-char} + "dis-tot" + {&comma-char} + "sum-id" + {&comma-char} +
           {&table_dis-card-property} + {&comma-char} + "call_id" + {&comma-char} +
           ({&table_dis-card-property} + {&delim-par} + 'call_id':U + {&comma-char} + "dtm-code" + {&comma-char} +
            {&TABLE_prop-ref-call})
           ) = 0 THEN DO:
   message
   vss-workfile vss-revision vss-description skip
   "Неверный параметр вызова p-list-mode" p-list-mode
    view-as alert-box ERROR.
    return error.
  END.
  run gbl/dftempl.p ( input {&table_prop-ref-call}, output template-recid) no-error.
  v-rid-list = p-rid-list.
  run Myenable IN THIS-PROCEDURE .
  run openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
    if num-entries (v-rid-list) = 0 then
        hide mark-num in frame {&frame-name}.
    else
        disp
        num-entries (v-rid-list) @ mark-num
        with frame {&frame-name}.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure.

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
  ENABLE B-quit B-mark B-sel b-add b-chg b-del b-use B-Help br-prop-ref
         mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE ch AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE v-h AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE ii AS integer NO-UNDO.
FRAME {&FRAME-NAME}:TITLE = "Список поддерживаемых срезов(итогов)".
ASSIGN
{&sort-clmn_2}:READ-ONLY IN BROWSE br-prop-ref = YES.

ASSIGN
v-h = br-prop-ref:FIRST-COLUMN IN FRAME {&FRAME-NAME}
.
DO while valid-handle(v-h) :
  if v-h:LABEL = {&label-clmn_6} then do:
    v-h:visible = (p-list-mode = {&TABLE_prop-ref-call}).
  end.
  ELSE DO:
    v-h:visible = (p-list-mode <> {&TABLE_prop-ref-call}).
  END.
  if v-h:LABEL = {&label-clmn_4}
  OR v-h:LABEL = {&label-clmn_8}
    then do:
    v-h:visible = (p-list-mode <> "dtm-code").

  end.
  if v-h:LABEL = {&label-clmn_7}
   OR
  v-h:LABEL = {&label-clmn_8}
      then do:
    v-h:RESIZAble = YES.
  END.
  v-h = v-h:NEXT-COLUMN.
END.
DISPLAY mark-num
WITH FRAME {&frame-name}.
ENABLE
B-quit
B-mark WHEN lookup('b-mark', p-bttns) > 0
B-sel WHEN lookup('b-sel', p-bttns) > 0
b-del WHEN lookup('b-add', p-bttns) > 0 AND v-cntxt-db-num = 0 and not transaction and p-list-mode <> "call_id"
b-add WHEN lookup('b-add', p-bttns) > 0 AND v-cntxt-db-num = 0 and not transaction and p-list-mode <> "call_id"
/*b-chg WHEN lookup('b-add', p-bttns) > 0 and not transaction */
B-Help
b-use WHEN p-list-mode <> {&TABLE_prop-ref-call}
br-prop-ref
WITH FRAME {&frame-name}.
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
run waitfram-show in this-procedure ("Ждите...").
define variable sort-column-phrase as character no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-ref for ub.prop-ref.


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

&scop flt-open-open-query OPEN QUERY br-prop-ref FOR EACH X_prop-ref

&scop flt-open-dyn_open-query FOR EACH X_prop-ref

&scop flt-open-query-handle QUERY br-prop-ref:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_prop-ref

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_prop-ref

&scop flt-open-waitfram true

define variable l-open-query as logical   no-undo .

CASE p-list-mode :
  WHEN {&all}        THEN DO:
    { gbl/fltopend.i
      &where-cond = " true "
      &use-ind    = "  "
      &by         = "  "
      &flt-open-open-query-tail = ", FIRST X_prop-head WHERE ~
            X_prop-head.dtm-code = X_prop-ref.dtm-code ~
        ,FIRST X_prop-ref-call NO-LOCK WHERE RECID(X_prop-ref-call) = template-recid "
      &flt-open-dyn_open-query-tail = " substitute(', FIRST X_prop-head WHERE ~
            X_prop-head.dtm-code = X_prop-ref.dtm-code ~
        ,FIRST X_prop-ref-call NO-LOCK WHERE RECID(X_prop-ref-call) = &1', template-recid )"
     }
  END.
  WHEN "call_id" THEN DO:
    assign
    frame {&frame-name}:title = substitute("&1 &2", frame {&frame-name}:title,  calldscr ( input p-call-id)).
    { gbl/fltopend.i
        &where-cond = " true "
        &use-ind    = "  "
        &by         = "  "
        &flt-open-open-query-tail = ", FIRST X_prop-head WHERE ~
             (X_prop-head.dtm-code = X_prop-ref.dtm-code or X_prop-ref.dt-code = 0) ~
         ,FIRST X_prop-ref-call no-lock where ~
              (X_prop-ref-call.dt-code = X_prop-ref.dt-code ~
          AND X_prop-ref-call.CALL_id = p-call-id) or X_prop-ref.dt-code = 0 "
        &flt-open-dyn_open-query-tail = " substitute(', FIRST X_prop-head WHERE ~
             (X_prop-head.dtm-code = X_prop-ref.dtm-code or X_prop-ref.dt-code = 0) ~
         ,FIRST X_prop-ref-call no-lock where ~
              (X_prop-ref-call.dt-code = X_prop-ref.dt-code ~
          AND X_prop-ref-call.CALL_id = &1&2&1) or X_prop-ref.dt-code = 0 ', ~{&double-quote~}, p-call-id) "
     }

  end.
  when "sum-id" then do:
    assign
    frame {&frame-name}:title = substitute("&1 Идентификатор &2", frame {&frame-name}:title,  p-sum-id).
    { gbl/fltopend.i
      &where-cond = " X_prop-ref.dtm-code = p-dtm-code ~
                      and X_prop-ref.sum-id = p-sum-id "
      &dyn_where-cond = " substitute('X_prop-ref.dtm-code = p-dtm-code ~
                      and X_prop-ref.sum-id = &1&2&1', ~{&double-quote~}, p-sum-id )"
      &use-ind    = "  "
      &by         = "  "
      &flt-open-open-query-tail = ",  FIRST X_prop-head WHERE ~
            X_prop-head.dtm-code = X_prop-ref.dtm-code ~
            ,FIRST X_prop-ref-call NO-LOCK WHERE RECID(X_prop-ref-call) = template-recid "
      &flt-open-dyn_open-query-tail = " substitute(',  FIRST X_prop-head WHERE ~
            X_prop-head.dtm-code = X_prop-ref.dtm-code ~
            ,FIRST X_prop-ref-call NO-LOCK WHERE RECID(X_prop-ref-call) = &1', template-recid )"
     }
  end.
  WHEN "dis-tot" THEN DO:
    assign
    frame {&frame-name}:title = substitute("&1 Общие и частные Итоги", frame {&frame-name}:title).
    { gbl/fltopend.i
    &where-cond = " true  "
    &use-ind    = "  "
    &by         = "  "
    &flt-open-open-query-tail = " ,FIRST X_prop-head WHERE ~
              X_prop-head.dtm-code = X_prop-ref.dtm-code ~
           AND (X_prop-head.storage-place = ~{&TABLE_dis-host~} ~
            OR X_prop-head.storage-place-host = ~{&TABLE_dis-host~} ~
            OR X_prop-head.storage-place-obj = ~{&TABLE_dis-obj~}) ~
      ,FIRST X_prop-ref-call NO-LOCK WHERE RECID(X_prop-ref-call) = template-recid "
        &flt-open-dyn_open-query-tail = " substitute(',FIRST X_prop-head WHERE ~
              X_prop-head.dtm-code = X_prop-ref.dtm-code ~
           AND (X_prop-head.storage-place = &1&2&1 ~
            OR X_prop-head.storage-place-host = &1&3&1 ~
            OR X_prop-head.storage-place-obj = &1&4&1) ~
      ,FIRST X_prop-ref-call NO-LOCK WHERE RECID(X_prop-ref-call) = &5 ' ~
      , {&double-quote}, ~{&TABLE_dis-host~}, ~{&TABLE_dis-host~}, ~{&TABLE_dis-obj~}, template-recid) "
     }
  end.
  WHEN {&table_dis-card-property} THEN DO:
    assign
    frame {&frame-name}:title = substitute("&1 Свойства ДК", frame {&frame-name}:title).
        { gbl/fltopend.i
        &where-cond = " true  "
        &use-ind    = "  "
        &by         = "  "
        &flt-open-open-query-tail = " ,FIRST X_prop-head WHERE ~
                          X_prop-head.dtm-code = X_prop-ref.dtm-code ~
               AND (X_prop-head.storage-place = ~{&table_dis-card-property~} ~
                OR X_prop-head.storage-place-host = ~{&table_dis-card-property~}  ~
                OR X_prop-head.storage-place-obj = ~{&table_dis-card-property~}) ~
        ,FIRST X_prop-ref-call NO-LOCK WHERE RECID(X_prop-ref-call) = template-recid "
        &flt-open-dyn_open-query-tail = " substitute(' ,FIRST X_prop-head WHERE ~
                          X_prop-head.dtm-code = X_prop-ref.dtm-code ~
               AND (X_prop-head.storage-place = &1&2&1 ~
                OR X_prop-head.storage-place-host = &1&3&1  ~
                OR X_prop-head.storage-place-obj = &1&4&1) ~
        ,FIRST X_prop-ref-call NO-LOCK WHERE RECID(X_prop-ref-call) = &5 ', ~
        {&double-quote}, ~{&table_dis-card-property~}, ~{&table_dis-card-property~}, ~{&table_dis-card-property~}, template-recid) "
      }
  end.
  when ({&table_dis-card-property} + {&delim-par} + 'call_id':U) then do:
    assign
    frame {&frame-name}:title = substitute("&1 Свойства ДК &2", frame {&frame-name}:title, calldscr(p-call-id)).
    { gbl/fltopend.i
    &where-cond = " true  "
    &use-ind    = "  "
    &by         = "  "
    &flt-open-open-query-tail = " ,FIRST X_prop-head WHERE ~
            X_prop-head.dtm-code = X_prop-ref.dtm-code ~
          AND (X_prop-head.storage-place = ~{&table_dis-card-property~} ~
          OR X_prop-head.storage-place-host = ~{&table_dis-card-property~} ~
          OR X_prop-head.storage-place-obj = ~{&table_dis-card-property~}) ~
        ,FIRST X_prop-ref-call NO-LOCK WHERE ~
              X_prop-ref-call.dt-code = X_prop-ref.dt-code ~
          AND X_prop-ref-call.CALL_id = p-call-id "
    &flt-open-dyn_open-query-tail = " substitute(' ,FIRST X_prop-head WHERE ~
            X_prop-head.dtm-code = X_prop-ref.dtm-code ~
          AND (X_prop-head.storage-place = &1&2&1 ~
          OR X_prop-head.storage-place-host = &1&3&1 ~
          OR X_prop-head.storage-place-obj = &1&4&1) ~
        ,FIRST X_prop-ref-call NO-LOCK WHERE ~
              X_prop-ref-call.dt-code = X_prop-ref.dt-code ~
          AND X_prop-ref-call.CALL_id = &1&5&1 ' ~
         ,  ~{&double-quote~}, ~{&table_dis-card-property~}, ~{&table_dis-card-property~}, ~{&table_dis-card-property~}, p-call-id) "
     }
  end.
  when "dtm-code" then do:
    find first buf_prop-head where buf_prop-head.dtm-code = p-dtm-code.
    assign
    frame {&frame-name}:title = substitute("&1 Объект-операнд &2", frame {&frame-name}:title, buf_prop-head.prop-label).
    { gbl/fltopend.i
    &where-cond = " X_prop-ref.dtm-code = p-dtm-code  "
    &dyn_where-cond = " substitute('X_prop-ref.dtm-code = &1', p-dtm-code ) "
    &use-ind    = "  "
    &by         = "  "
    &flt-open-open-query-tail = " ,FIRST X_prop-head WHERE ~
            X_prop-head.dtm-code = X_prop-ref.dtm-code ~
        ,FIRST X_prop-ref-call NO-LOCK WHERE RECID(X_prop-ref-call) = template-recid "
    &flt-open-dyn_open-query-tail = " substitute( ' ,FIRST X_prop-head WHERE ~
            X_prop-head.dtm-code = X_prop-ref.dtm-code ~
        ,FIRST X_prop-ref-call NO-LOCK WHERE RECID(X_prop-ref-call) = &1', template-recid )"
    }
  end.
  WHEN {&TABLE_prop-ref-call} THEN DO:
      find first buf_prop-ref where
                buf_prop-ref.dtm-code = p-dtm-code
            AND buf_prop-ref.SUM-id = p-sum-id
            AND buf_prop-ref.caller_id = p-call-id.
      assign
      frame {&frame-name}:title = substitute("Использование итога(среза) &1", frame {&frame-name}:title, buf_prop-ref.dt-code).
    { gbl/fltopend.i
    &where-cond = " X_prop-ref.dtm-code = p-dtm-code ~
          AND X_prop-ref.sum-id = p-sum-id   ~
          AND X_prop-ref.caller_id = p-call-id "
    &dyn_where-cond = " substitute(' X_prop-ref.dtm-code = &1 ~
          AND X_prop-ref.sum-id = &2&3&2   ~
          AND X_prop-ref.caller_id = &2&4&2 ', p-dtm-code, ~{&double-quote~}, p-sum-id, p-call-id)"
    &use-ind    = "  "
    &by         = "  "
    &flt-open-open-query-tail = " ,FIRST X_prop-head WHERE ~
              X_prop-head.dtm-code = X_prop-ref.dtm-code, ~
          each X_prop-ref-call NO-LOCK WHERE X_prop-ref-call.dt-code = X_prop-ref.dt-code "
    }
  end.
END CASE.
if not p-open-query then
REPOSITION br-prop-ref to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-prop-ref:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "ENTRY" TO br-prop-ref.
APPLY "VALUE-CHANGED" TO br-prop-ref in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-dtm-name Dialog-Frame
FUNCTION get-dtm-name RETURNS CHARACTER
  ( INPUT p-dtm-code AS integer ) :
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
FIND first buf_prop-head NO-LOCK WHERE
            buf_prop-head.dtm-code = p-dtm-code NO-ERROR.
IF NOT AVAILABLE buf_prop-head  THEN  RETURN "!!!Неизвестный объект".   /* Function return value. */
RETURN buf_prop-head.prop-label.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
