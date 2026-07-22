&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_c-dis-card-type FOR ub.c-dis-card-type.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
Справочник истории типов дисконтных карт

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/15/05
Author: Bakhtadze Natalya
Creation date: 12/15/05

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER BTTNS AS CHAR NO-UNDO.
DEFINE INPUT PARAMETER rid# As recid NO-UNDO. /* фиктивный параметр для вызовов процедур*/
DEFINE INPUT PARAMETER p-emitent-host-code like ub.sysconf.host-code no-undo.
DEFINE INPUT PARAMETER p-host-code like ub.sysconf.host-code no-undo.
DEFINE INPUT PARAMETER p-obj-type like ub.clients.obj-type no-undo.
DEFINE INPUT PARAMETER p-obj-code like ub.clients.obj-code no-undo.
define input parameter p-type like ub.c-dis-card-type.type no-undo .
define input parameter p-mode as character no-undo .
/*{&all} или "one":U или subject*/
define input parameter p-subject as character no-undo .
DEFINE OUTPUT PARAMETER p-rid-list As char NO-UNDO. /* фиктивный параметр для вызовов процедур*/

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник истории типов дисконтных карт " .
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/fltfield.i }
{ gbl/usrfulnf.i }
define variable ri as recid no-undo.
define variable v-doc-rec as recid no-undo.
&SCOP dc-d-pcnt-code string(X_c-dis-card-type.dflt-d-pcnt-method)
{ cmp/mrk-strf.i }
{ ref/tmpchgs.i "NEW SHARED" }
{ gbl/waitfram.i }
{ gbl/fltopend.i defproc }


{ gbl/getcntxt.i def }
&SCOPED-DEFINE hn-dc-type-hist-code X_c-dis-card-type.subject
define variable filter-point as character no-undo init "dcctypes" .
define variable filter-point0 as character no-undo init "dcctypes" .
define variable filter-label0 as character no-undo init "Список полной истории типа ДК" .
define variable filter-label as character no-undo init "Список полной истории типа ДК" .
define variable sort-column-name as character no-undo .
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-subject-chr as character no-undo .

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
&Scoped-define INTERNAL-TABLES temp-changes X_c-dis-card-type

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes   
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE BR-dctype                                     */
&Scoped-define FIELDS-IN-QUERY-BR-dctype mark-string(recid(X_c-dis-card-type), v-rid-list) X_c-dis-card-type.type X_c-dis-card-type.emitent-host-code X_c-dis-card-type.corr-user-db-num X_c-dis-card-type.corr-date get-emitent(X_c-dis-card-type.emitent-host-code) usrfulnf(X_c-dis-card-type.corr-user-name) get-action(X_c-dis-card-type.action) {&hn-dc-type-hist-name} string(if X_c-dis-card-type.host-code = 0 then "Глобально" else (if X_c-dis-card-type.obj-code = 0 then ("Фирма" + {&space-char} + string(X_c-dis-card-type.host-code)) else (X_c-dis-card-type.obj-type + string(X_c-dis-card-type.obj-code)) )) string(X_c-dis-card-type.corr-time, "HH:MM":U) X_c-dis-card-type.chip-num   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-dctype   
&Scoped-define SELF-NAME BR-dctype
&Scoped-define QUERY-STRING-BR-dctype FOR EACH X_c-dis-card-type NO-LOCK     BY X_c-dis-card-type.type
&Scoped-define OPEN-QUERY-BR-dctype OPEN QUERY {&SELF-NAME} FOR EACH X_c-dis-card-type NO-LOCK     BY X_c-dis-card-type.type.
&Scoped-define TABLES-IN-QUERY-BR-dctype X_c-dis-card-type
&Scoped-define FIRST-TABLE-IN-QUERY-BR-dctype X_c-dis-card-type


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-mark B-sel b-sch B-Help ~
v-corr-user-db-num BR-dctype BR-changes mark-num 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-emitent Dialog-Frame 
FUNCTION get-emitent RETURNS CHARACTER
  ( input par-emitent-host-code  as integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-mark Dialog-Frame 
FUNCTION get-mark RETURNS CHARACTER
  ( par-rid as recid, pardc-type-rid as character  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark 
     LABEL "*" 
     SIZE 3 BY 1.

DEFINE BUTTON b-sch 
     LABEL "&Фильтр" 
     SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO 
     LABEL "Вы&бор" 
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 9.88 BY 1 NO-UNDO.

DEFINE VARIABLE v-corr-user-db-num AS INTEGER FORMAT ">>>>9":U INITIAL 0 
     LABEL "По БД" 
     VIEW-AS FILL-IN 
     SIZE 6 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR 
      temp-changes SCROLLING.

DEFINE QUERY BR-dctype FOR
                X_c-dis-card-type SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(255)" WIDTH 45
temp-changes.v_old COLUMn-LABEL "Было" format "X(255)" WIDTH 20
temp-changes.v_new COLUMn-LABEL "Стало" format "X(255)" WIDTH 20
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.04.

DEFINE BROWSE BR-dctype
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-dctype Dialog-Frame _FREEFORM
  QUERY BR-dctype DISPLAY
      mark-string(recid(X_c-dis-card-type), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
X_c-dis-card-type.type COLUMN-LABEL "Тип" FORMAT "X(8)":U
X_c-dis-card-type.emitent-host-code COLUMN-LABEL "Код!эмитента" FORMAT ">>>>>99999":U
X_c-dis-card-type.corr-user-db-num COLUMN-LABEL "БД" FORMAT ">>>>9":U
X_c-dis-card-type.corr-date COLUMN-LABEL "Дата корр" FORMAT "99/99/9999":U
get-emitent(X_c-dis-card-type.emitent-host-code) COLUMN-LABEL "Эмитент" FORMAT "X(15)":U
usrfulnf(X_c-dis-card-type.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
get-action(X_c-dis-card-type.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
{&hn-dc-type-hist-name} COLUMN-LABEL "Предмет изменений" FORMAT "X(35)":U
string(if X_c-dis-card-type.host-code = 0
then "Глобально"
else (if X_c-dis-card-type.obj-code = 0
then ("Фирма" + {&space-char} +                          string(X_c-dis-card-type.host-code))
 else (X_c-dis-card-type.obj-type +                            string(X_c-dis-card-type.obj-code))
)) COLUMN-LABEL "Область!действия" FORMAT "X(15)":U
string(X_c-dis-card-type.corr-time, "HH:MM":U) COLUMN-LABEL "Время корр"
X_c-dis-card-type.chip-num
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8.79.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 14
     b-sch AT ROW 1 COL 92 WIDGET-ID 8
     B-Help AT ROW 1 COL 95
     v-corr-user-db-num AT ROW 2.33 COL 19 COLON-ALIGNED WIDGET-ID 6
     BR-dctype AT ROW 3.46 COL 1
     BR-changes AT ROW 13 COL 1
     mark-num AT ROW 2.17 COL 2.88 NO-LABEL
     SPACE(86.24) SKIP(18.89)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "История типов дисконтных карт"
         DEFAULT-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_c-dis-card-type B "?" ? ub c-dis-card-type
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-dctype v-corr-user-db-num Dialog-Frame */
/* BROWSE-TAB BR-changes BR-dctype Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       BR-dctype:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-dctype
/* Query rebuild information for BROWSE BR-dctype
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-dis-card-type NO-LOCK
    BY X_c-dis-card-type.type.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE  BR-dctype FOR
                X_c-dis-card-type SCROLLING.
     _END_FREEFORM_DEFINE
     _Query            is NOT OPENED
*/  /* BROWSE BR-dctype */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* История типов дисконтных карт */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История типов дисконтных карт */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
DEFINE VARIABLE loc#log as logical no-undo.
    if available X_c-dis-card-type then do:
      { gbl/markstrn.i X_c-dis-card-type v-rid-list }
      loc#log = br-dctype:refresh() .

      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          loc#log = br-dctype:select-next-row ().
          apply "iteration-changed" to br-dctype in frame {&frame-name}.
      end.
      if num-entries( v-rid-list ) = 0
      then
          hide mark-num in frame {&frame-name}.
      else
          disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
    end.
    apply "entry" to br-dctype in frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
      run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if available X_c-dis-card-type and  v-rid-list = "" then do:
       v-rid-list = string(recid( X_c-dis-card-type)).
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-dctype
&Scoped-define SELF-NAME BR-dctype
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-dctype Dialog-Frame
ON VALUE-CHANGED OF BR-dctype IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-corr-user-db-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-corr-user-db-num Dialog-Frame
ON RETURN OF v-corr-user-db-num IN FRAME Dialog-Frame /* По БД */
DO:
  assign
  v-corr-user-db-num
  .
  RUn OpenBR IN THIS-PROCEDURE ( INPUT yes, INPUT no, INPUT '':U, INPUT v-corr-user-db-num).

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
{ gbl/app_help.i &disable_diasize_init=true &browse-name="BR-dctype" }
{ gbl/brwrefre.i "v-doc-rec = recid(X_c-dis-card-type). run OpenBr in this-procedure  ( input yes, input no, input '':U, input v-corr-user-db-num). reposition br-dctype to recid v-doc-rec no-error. v-doc-rec = ?. ~
              apply 'value-changed' to br-dctype. " }
{ gbl/brwrepos.i
  &line-num=5
}
{ gbl/setfltnm.i }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  RUN Myenable in this-procedure .
  Run OpenBR in this-procedure  ( input yes, input no, input '':U, input v-corr-user-db-num).
  HIDE mark-num in frame {&frame-name} .
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
  ENABLE B-exit B-mark B-sel b-sch B-Help v-corr-user-db-num BR-dctype 
         BR-changes mark-num 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
define variable v-h as handle no-undo.
v-h = br-dctype:fIRST-COLUMN IN FRAME {&FRAME-NAME}
.
DO while valid-handle(v-h) :
  if v-h:LABEL = "Предмет изменений" then do:
    v-h:RESIZABLE = YES.
    leave.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.
v-corr-user-db-num = v-cntxt-db-num.
assign
br-changes:title in frame {&frame-name} = "":U
temp-changes.l_name:resizable in browse br-changes = true
temp-changes.v_old:resizable in browse br-changes = true
temp-changes.v_new:resizable in browse br-changes = true
temp-changes.l_name:width in browse br-changes = 30
temp-changes.v_old:width in browse br-changes = 40
temp-changes.v_new:width in browse br-changes = 40
.
display
v-cntxt-db-num @ v-corr-user-db-num
with frame {&frame-name} .
ENABLE
B-exit
b-sel when lookup("b-sel":U, bttns) > 0
b-mark when lookup("b-mark":U, bttns) > 0
B-Help
BR-dctype
BR-changes
b-sch
v-corr-user-db-num
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
define input  parameter p-db-num like ub.c-dis-card-type.corr-user-db-num no-undo .

define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Список полной типа ДК" + {&space-char}.
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

&scop flt-open-open-query OPEN QUERY br-dctype FOR EACH X_c-dis-card-type

&scop flt-open-dyn_open-query FOR EACH X_c-dis-card-type

&scop flt-open-query-handle  QUERY br-dctype:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-dis-card-type

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name  X_c-dis-card-type

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .
CASE p-db-num :
  when ? then do:
    CASE p-mode :
        WHEN {&all}        THEN DO:
        ASSIGN
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1", filter-label0)
        .
        { gbl/fltopend.i
            &where-cond = " TRUE "
            &use-ind    = "  "
            &by         = "  " }
        END.
        WHEN {&company} THEN DO:
          assign
          filter-point = filter-point0 + p-mode
          filter-label = substitute("&1 Фирма", filter-label0)
         frame {&frame-name} :title = SUBSTITUTE("&1 Эмитент &2 Тип &3 Фирма &4"
                                     ,title0
                                    , p-emitent-host-code
                                    , p-type
                                    , p-host-code)
         .
          { gbl/fltopend.i
            &where-cond = " X_c-dis-card-type.type  = p-type ~
                            and  (X_c-dis-card-type.host-code  = p-host-code  or X_c-dis-card-type.host-code = 0) ~
                          "
            &dyn_where-cond = " substitute('X_c-dis-card-type.type  = &1&2&1 ~
                            and  (X_c-dis-card-type.host-code  = &3  or X_c-dis-card-type.host-code = 0) ', ~{&double-quote~}, p-type, p-host-code)   "

            &use-ind    = "  "
            &by         = "  " }
        END.
        WHEN {&g___object} THEN DO:
          assign
          filter-point = filter-point0 + p-mode
          filter-label = substitute("&1 Один тип ДК, Один объект", filter-label0)
          frame {&frame-name} :title = SUBSTITUTE("&1 Эмитент Фирма &2 Тип &3 Объект &4&5"
                                 ,title0
                                , p-emitent-host-code
                                , p-type
                                , p-obj-type
                               , p-obj-code)
          .

          { gbl/fltopend.i
            &where-cond = " X_c-dis-card-type.type  = p-type ~
                           and X_c-dis-card-type.emitent-host-code  = p-emitent-host-code ~
                           and ( X_c-dis-card-type.host-code = 0 or (X_c-dis-card-type.obj-type = p-obj-type and X_c-dis-card-type.obj-code = p-obj-code))   ~
                          "
            &dyn_where-cond = " substitute('X_c-dis-card-type.type  = &1&2&1 ~
                           and X_c-dis-card-type.emitent-host-code  = &3 ~
                           and ( X_c-dis-card-type.host-code = 0 or (X_c-dis-card-type.obj-type = &1&4&1 and X_c-dis-card-type.obj-code = &5))'   ~
                           , ~{&double-quote~} ~
                           ,p-type ~
                           ,p-emitent-host-code ~
                           ,p-obj-type ~
                           ,p-obj-code) "

            &use-ind    = "  "
            &by         = "  " }
        END.

      WHEN "one":u THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Один тип ДК", filter-label0)
        frame {&frame-name} :title = substitute("&1 Эмитент Фирма &2 Тип &3"
                                   ,title0
                                  , p-emitent-host-code
                                  , p-type)
        .
        { gbl/fltopend.i
          &where-cond = " X_c-dis-card-type.type  = p-type   ~
                          and X_c-dis-card-type.emitent-host-code  = p-emitent-host-code  ~
                        "
          &dyn_where-cond = " substitute('X_c-dis-card-type.type  = &1&2&1   ~
                          and X_c-dis-card-type.emitent-host-code  = &3 ', ~{&double-quote~}, p-type, p-emitent-host-code )  "

          &use-ind    = "  "
          &by         = "  " }
      END.
      WHEN "subject":u THEN DO:
  &scop hn-dc-type-hist-code p-subject
        assign
        filter-point = filter-point0 + p-mode
        v-subject-chr = {&hn-dc-type-hist-name}
        filter-label = substitute("&1 Один тип ДК, Предмет изменений", filter-label0)
        frame {&frame-name} :title = substitute("&1 Эмитент Фирма &2 Тип &3 Предмет изменений &4"
                                  , title0
                                  , p-emitent-host-code
                                  , p-type
                                  , v-subject-chr)


        .
        { gbl/fltopend.i
          &where-cond = " X_c-dis-card-type.type  = p-type ~
                          ANd   X_c-dis-card-type.emitent-host-code  = p-emitent-host-code   ~
                          and X_c-dis-card-type.subject = p-subject ~
                        "
          &dyn_where-cond = " substitute('X_c-dis-card-type.type  = &1&2&1 ~
                          ANd   X_c-dis-card-type.emitent-host-code  = &3   ~
                          and X_c-dis-card-type.subject = &1&4&1 ', ~{&double-quote~}, p-type, p-emitent-host-code, p-subject)  "

          &use-ind    = "  "
          &by         = "  " }

      END.
    END CASE.
  end.
  otherwise do:
    CASE p-mode :
      WHEN {&all}        THEN DO:
      ASSIGN
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1", filter-label0)
      .
      { gbl/fltopend.i
          &where-cond = " TRUE "
          &use-ind    = "  "
          &by         = "  " }
      END.
      WHEN {&company} THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Фирма", filter-label0)
       frame {&frame-name} :title = SUBSTITUTE("&1 Эмитент &2 Тип &3 Фирма &4"
                                   ,title0
                                  , p-emitent-host-code
                                  , p-type
                                  , p-host-code)
        .

        { gbl/fltopend.i
          &where-cond = " X_c-dis-card-type.corr-user-db-num = p-db-num ~
                          ANd X_c-dis-card-type.type  = p-type ~
                          and  (X_c-dis-card-type.host-code  = p-host-code  or X_c-dis-card-type.host-code = 0) ~
                        "
          &dyn_where-cond = " substitute('X_c-dis-card-type.corr-user-db-num = &1 ~
                          ANd X_c-dis-card-type.type  = &2&3&2 ~
                          and  (X_c-dis-card-type.host-code  = &4  or X_c-dis-card-type.host-code = 0) ', p-db-num, ~{&double-quote~}, p-type, p-host-code)"

          &use-ind    = "  "
          &by         = "  " }
      END.
      WHEN {&g___object} THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Один тип ДК, Один объект", filter-label0)
        frame {&frame-name} :title = SUBSTITUTE("&1 Эмитент Фирма &2 Тип &3 Объект &4&5"
                               ,title0
                              , p-emitent-host-code
                              , p-type
                              , p-obj-type
                             , p-obj-code)
        .

        { gbl/fltopend.i
          &where-cond = "  X_c-dis-card-type.corr-user-db-num = p-db-num ~
                           ANd X_c-dis-card-type.type  = p-type ~
                           ANd X_c-dis-card-type.emitent-host-code  = p-emitent-host-code ~
                           and ( X_c-dis-card-type.host-code = 0 or (X_c-dis-card-type.obj-type = p-obj-type and X_c-dis-card-type.obj-code = p-obj-code))   ~
                        "
          &dyn_where-cond = "  substitute('X_c-dis-card-type.corr-user-db-num = &1 ~
                           ANd X_c-dis-card-type.type  = &2&3&2 ~
                           ANd X_c-dis-card-type.emitent-host-code  = &4 ~
                           and ( X_c-dis-card-type.host-code = 0 or (X_c-dis-card-type.obj-type = &2&5&2 and X_c-dis-card-type.obj-code = &6))'   ~
                           ,p-db-num , ~{&double-quote~}, p-type, p-emitent-host-code, p-obj-type, p-obj-code) "

          &use-ind    = "  "
          &by         = "  " }
      END.
      WHEN "one":u THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Один тип ДК", filter-label0)
        frame {&frame-name} :title = substitute("&1 Эмитент Фирма &2 Тип &3"
                              , title0
                              , p-emitent-host-code
                              , p-type)
        .

        { gbl/fltopend.i
          &where-cond = " ~
          X_c-dis-card-type.corr-user-db-num = p-db-num ~
            ANd   X_c-dis-card-type.type  = p-type   ~
            ANd   X_c-dis-card-type.emitent-host-code  = p-emitent-host-code   ~
                        "
          &dyn_where-cond = " substitute(' X_c-dis-card-type.corr-user-db-num = &1 ~
            ANd   X_c-dis-card-type.type  = &2&3&2   ~
            ANd   X_c-dis-card-type.emitent-host-code  = &4  ', p-db-num, ~{&double-quote~}, p-type, p-emitent-host-code ) "

          &use-ind    = "  "
          &by         = "  " }
      END.
      WHEN "subject":u THEN DO:
  &scop hn-dc-type-hist-code p-subject
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Один тип ДК, Предмет изменений", filter-label0)
        v-subject-chr = {&hn-dc-type-hist-name}
        frame {&frame-name} :title = substitute("&1 Эмитент Фирма &2 Тип &3 Предмет изменений &4"
                                  , title0
                                  , p-emitent-host-code
                                  , p-type
                                 , v-subject-chr)

        .

        { gbl/fltopend.i
          &where-cond = " ~
          X_c-dis-card-type.corr-user-db-num = p-db-num ~
            ANd   X_c-dis-card-type.type  = p-type ~
            ANd   X_c-dis-card-type.emitent-host-code  = p-emitent-host-code   ~
            and X_c-dis-card-type.subject = p-subject ~
                        "
          &dyn_where-cond = " substitute(' X_c-dis-card-type.corr-user-db-num = &1 ~
            ANd   X_c-dis-card-type.type  = &2&3&2 ~
            ANd   X_c-dis-card-type.emitent-host-code  = &4   ~
            and X_c-dis-card-type.subject = &2&5&2 ', p-db-num, ~{&double-quote~}, p-type, p-emitent-host-code, p-subject)  "

          &use-ind    = "  "
          &by         = "  " }
      END.
    END CASE.
  end. /*otherwise <> ?*/
END CASE.

if not p-open-query  and v-doc-rec <> ? then
REPOSITION br-dctype to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-dctype:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-dctype in frame {&frame-name}.
APPLY "ENTRY" TO br-dctype.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame 
PROCEDURE proc-b-sch :
assign
  tbl = 'c-dis-card-type'
  join-tbl = 'X_c-dis-card-type'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('type', 'Тип ДК', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('emitent-host-code', 'Эмитент', '',
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
run fltfield-add in this-procedure('subject', 'Предмет изменения', 'dc-type-hist-subject',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('action', 'Действие', 'hist-action',
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
if not available X_c-dis-card-type then do:
  Open QUery br-changes for each temp-changes.
  return.
end.

run ref/cdcthisv.p (
                   input X_c-dis-card-type.emitent-host-code
                  ,input X_c-dis-card-type.type
                  ,input X_c-dis-card-type.chip-num
                  ,input X_c-dis-card-type.corr-user-db-num
                  ,input X_c-dis-card-type.obj-type
                  ,input X_c-dis-card-type.obj-code
                  ,input X_c-dis-card-type.host-code
                  ,input X_c-dis-card-type.subject
                  ,input X_c-dis-card-type.action
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
  &scop hn-action-code trim(string(p-action))
define variable dops as character no-undo.
assign dops = {&hn-action-name} no-error.

RETURN dops.   /* Function return value. */


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-emitent Dialog-Frame 
FUNCTION get-emitent RETURNS CHARACTER
  ( input par-emitent-host-code  as integer) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
if par-emitent-host-code = 0 then return "Глобальная".

find first ub.clients no-lock where
            ub.clients.obj-type = {&cmp} and
            ub.clients.obj-code = par-emitent-host-code no-error.
if not avail ub.clients then return "?".
else return ub.clients.obj-name.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-mark Dialog-Frame 
FUNCTION get-mark RETURNS CHARACTER
  ( par-rid as recid, pardc-type-rid as character  ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
if lookup(string(par-rid), pardc-type-rid) > 0 then return "*":U.
  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

