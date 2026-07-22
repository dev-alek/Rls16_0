&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_cli FOR ub.clients.
DEFINE BUFFER for-c-tax-hist FOR ub.c-tax-hist.
DEFINE BUFFER X_c-tax-hist FOR ub.c-tax-hist.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник истории налогов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER bttns  as character  no-undo .
DEFINE INPUT PARAMETER parref-mode as character no-undo.
/*{&all} или "tax":U или "tax-rate" или "tax-rate-value"*/
DEFINE OUTPUT PARAMETER  p-rid-list    as  char no-undo . /* список recid'ов выбранных аписей */
DEFINE INPUT PARAMETER p-tax-code like ub.c-tax-hist.tax-code no-undo.
DEFINE INPUT PARAMETER p-rate-code like ub.c-tax-hist.rate-code no-undo.
define input parameter p-subject   like ub.c-tax-hist.subject no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник истории налогов" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ trg/factord.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
define variable v-rid-list as character no-undo .
define variable log-res as log no-undo.
define variable rr as recid no-undo.
define variable jj as integer no-undo .
define variable str as char no-undo.
define variable conf-par as char no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as char no-undo.
define variable vartbl-name as char no-undo.
define variable varact      as char no-undo.
define variable filter-point0 as character no-undo init "ctaxhist":U .
define variable filter-point as character no-undo init "ctaxhist":U .
define variable filter-label0 as character no-undo init "Справочник истории налогов и ставок":U .
define variable filter-label as character no-undo init "Справочник истории налогов и ставок":U .

define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
define buffer X_tax for ub.tax.
define buffer X_tax-rate for ub.tax-rate.
define buffer X_tax-rate-value for ub.tax-rate-value.
{ ref/tmpchgs.i "NEW SHARED" }

&SCOPED-DEFINE hn-tax-hist-code X_c-tax-hist.subject

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-c-tax-hist

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-tax-hist temp-changes

/* Definitions for BROWSE BR-c-tax-hist                                 */
&Scoped-define FIELDS-IN-QUERY-BR-c-tax-hist mark-string( recid(X_c-tax-hist), v-rid-list ) X_c-tax-hist.corr-date usrfulnf(X_c-tax-hist.corr-user-name) X_c-tax-hist.corr-user-db-num {&hn-tax-hist-name} X_c-tax-hist.tax-code get-action(X_c-tax-hist.action) string(X_c-tax-hist.corr-time, "HH:MM") if X_c-tax-hist.subject = {&table_tax-rate} or X_c-tax-hist.subject = {&table_tax-rate-value} then string(X_c-tax-hist.rate-code) else '':U if X_c-tax-hist.subject = {&table_tax-rate-value} and X_c-tax-hist.host-code > 0 then string(X_c-tax-hist.host-code) else '':U if X_c-tax-hist.subject = {&table_tax-rate-value} and X_c-tax-hist.obj-code > 0 then (X_c-tax-hist.obj-type + string(X_c-tax-hist.obj-code)) else '':U if X_c-tax-hist.subject = {&table_tax-rate-value} then get-fact-date-str(X_c-tax-hist.fact-order) else '':U if X_c-tax-hist.subject = {&table_tax-rate-value} then string(X_c-tax-hist.status_) else '':U   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-c-tax-hist   
&Scoped-define SELF-NAME BR-c-tax-hist
&Scoped-define QUERY-STRING-BR-c-tax-hist FOR EACH X_c-tax-hist NO-LOCK
&Scoped-define OPEN-QUERY-BR-c-tax-hist OPEN QUERY {&SELF-NAME} FOR EACH X_c-tax-hist NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-c-tax-hist X_c-tax-hist
&Scoped-define FIRST-TABLE-IN-QUERY-BR-c-tax-hist X_c-tax-hist


/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes   
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-sch B-Help mark-num ~
BR-c-tax-hist BR-changes 
&Scoped-Define DISPLAYED-OBJECTS mark-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-action Dialog-Frame 
FUNCTION get-action RETURNS CHARACTER
  (  p-action as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-fact-date-str Dialog-Frame 
FUNCTION get-fact-date-str RETURNS CHARACTER
  ( INPUT p-fact-order AS DECIMAL )  FORWARD.

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

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch 
     LABEL "&Фильтр" 
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
     LABEL "Вы&бор" 
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-c-tax-hist FOR 
      X_c-tax-hist SCROLLING.

DEFINE QUERY BR-changes FOR 
      temp-changes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-c-tax-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-c-tax-hist Dialog-Frame _FREEFORM
  QUERY BR-c-tax-hist DISPLAY
      mark-string( recid(X_c-tax-hist), v-rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_c-tax-hist.corr-date COLUMN-LABEL "Дата корр" FORMAT "99/99/9999":U
      usrfulnf(X_c-tax-hist.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
      X_c-tax-hist.corr-user-db-num COLUMN-LABEL "БД" FORMAT ">>>>9":U
            WIDTH 6
      {&hn-tax-hist-name} COLUMN-LABEL "Предмет изменений" FORMAT "X(12)":U
      X_c-tax-hist.tax-code COLUMN-LABEL "Код!налога" FORMAT "9":U
            WIDTH 7
      get-action(X_c-tax-hist.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
      string(X_c-tax-hist.corr-time, "HH:MM") COLUMN-LABEL "Время!корр" FORMAT "X(5)":U
            WIDTH 6
      if X_c-tax-hist.subject = {&table_tax-rate} or X_c-tax-hist.subject = {&table_tax-rate-value} then string(X_c-tax-hist.rate-code) else '':U COLUMN-LABEL "Код!ставки" FORMAT "X(3)":U
            WIDTH 7
      if X_c-tax-hist.subject = {&table_tax-rate-value} and X_c-tax-hist.host-code > 0 then string(X_c-tax-hist.host-code) else '':U COLUMN-LABEL "Фирма" FORMAT "X(5)":U
            WIDTH 6
      if X_c-tax-hist.subject = {&table_tax-rate-value} and X_c-tax-hist.obj-code > 0 then
(X_c-tax-hist.obj-type + string(X_c-tax-hist.obj-code)) else '':U COLUMN-LABEL "Объект" FORMAT "X(9)":U
            WIDTH 10
      if X_c-tax-hist.subject = {&table_tax-rate-value} then
get-fact-date-str(X_c-tax-hist.fact-order) else '':U COLUMN-LABEL "Дата факт" FORMAT "X(10)":U
            WIDTH 11
      if X_c-tax-hist.subject = {&table_tax-rate-value} then string(X_c-tax-hist.status_) else '':U COLUMN-LABEL "Статус" FORMAT "X(10)":U
            WIDTH 11
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 12.33.

DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(40)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 14
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     mark-num AT ROW 1.93 COL 9 COLON-ALIGNED NO-LABEL
     BR-c-tax-hist AT ROW 3.43 COL 1
     BR-changes AT ROW 16.03 COL 1
     SPACE(0.24) SKIP(0.01)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Справочник истории налогов и ставок"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_cli B "?" ? ub clients
      TABLE: for-c-tax-hist B "?" ? ub c-tax-hist
      TABLE: X_c-tax-hist B "?" ? ub c-tax-hist
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-c-tax-hist mark-num Dialog-Frame */
/* BROWSE-TAB BR-changes BR-c-tax-hist Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-c-tax-hist
/* Query rebuild information for BROWSE BR-c-tax-hist
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-tax-hist NO-LOCK.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-c-tax-hist */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Справочник истории налогов и ставок */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Справочник истории налогов и ставок */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable g#log as logical no-undo .
 if not available X_c-tax-hist then return no-apply.
 { gbl/markstrn.i X_c-tax-hist v-rid-list }
 g#log = br-c-tax-hist :refresh( )  in frame {&frame-name}.
  if not can-do ("MOUSE-SELECT-DBLCLICK,Return", last-event:function) then do:
          g#log = br-c-tax-hist:select-next-row () in frame {&frame-name}.
          apply "value-changed" to br-c-tax-hist in frame {&frame-name}.
  end.
  if num-entries (v-rid-list) = 0 then
      hide mark-num in frame {&frame-name}.
  else
  disp num-entries (v-rid-list) @ mark-num
  with frame {&frame-name}.
  apply "entry" to br-c-tax-hist in frame {&frame-name}.

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
    if ( available X_c-tax-hist ) AND ( v-rid-list = "" ) then
        v-rid-list = string( recid( X_c-tax-hist ) ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-c-tax-hist
&Scoped-define SELF-NAME BR-c-tax-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-c-tax-hist Dialog-Frame
ON RETURN OF BR-c-tax-hist IN FRAME Dialog-Frame
DO:
      apply "DEFAULT-ACTION":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-c-tax-hist Dialog-Frame
ON VALUE-CHANGED OF BR-c-tax-hist IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i &disable_diasize_init=true &browse-name="BR-c-tax-hist" }
{ gbl/brwrefre.i "v-doc-rec = recid(X_c-tax-hist). run OpenBr in this-procedure ( input yes, input no, input '':U). reposition br-c-tax-hist to recid v-doc-rec no-error. " }
{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/setfltnm.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  CASE parref-mode:
   WHEN {&all}        THEN DO:
   END.
   WHEN "tax":U THEN DO:
     find first X_tax no-lock where
                X_tax.tax-code = p-tax-code
            no-error .
     if not available X_tax then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-tax-code" p-tax-code
        view-as alert-box ERROR.
        return.
     end.
   END.
   WHEN "tax-rate":U
   or when "tax-rate-value"
   THEN DO:
     find first X_tax-rate no-lock where
                X_tax-rate.tax-code = p-tax-code
             AND X_tax-rate.rate-code = p-rate-code
            no-error .
     if not available X_tax-rate then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров p-tax-code и/или p-rate-code" p-tax-code p-rate-code
        view-as alert-box ERROR.
        return.
     end.
   END.
   otherwise do:
      message vss-workfile vss-revision vss-description skip
      "Неверный вызов - parref-mode=" parref-mode
      view-as alert-box ERROR.
      return.
    end.
  end case.
  v-rid-list = p-rid-list.
  RUN MyEnable.
  HIDE mark-num in frame {&frame-name} .
  run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  browse br-changes :handle
    ) .
  run diasize_init in this-procedure .
  run OpenBR in this-procedure ( input yes, input no, input '':U).
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
  ENABLE b-quit B-mark b-sel B-sch B-Help mark-num BR-c-tax-hist BR-changes 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
br-changes:title in frame {&frame-name}  = "":U.
assign
temp-changes.l_name:resizable in browse br-changes = true
temp-changes.v_old:resizable in browse br-changes = true
temp-changes.v_new:resizable in browse br-changes = true
temp-changes.l_name:width in browse br-changes = 30
temp-changes.v_old:width in browse br-changes = 40
temp-changes.v_new:width in browse br-changes = 40
.
DISPLAY
mark-num
br-changes
WITH FRAME {&frame-name}.
ENABLE
B-quit
B-mark when lookup('b-mark':U, bttns) >0
B-sel when lookup('b-sel':U, bttns) >0
B-sch
B-Help
BR-c-tax-hist
br-changes
mark-num
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

&scop flt-open-debug-file

&scop flt-open-open-query OPEN QUERY br-c-tax-hist FOR EACH X_c-tax-hist

&scop flt-open-dyn_open-query FOR EACH X_c-tax-hist

&scop flt-open-query-handle query br-c-tax-hist:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-waitfram yes

CASE parref-mode:
    when {&all} then do:
        ASSIGN frame {&frame-name}:TITLE = "Справочник истории категорий и ставок налогов"
        filter-point = filter-point0 + parref-mode
        filter-label = substitute("&1", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " TRUE "
            &use-ind = "  "
            &by = "  "
          }
    end.
    when "tax":U then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории категорий и ставок налогов: код налога &1",
                                                       p-tax-code)
        filter-point = filter-point0 + parref-mode
        filter-label = substitute("&1 Один налог", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_c-tax-hist.tax-code = p-tax-code "
            &dyn_where-cond = " substitute('X_c-tax-hist.tax-code = &1', p-tax-code )"
            &use-ind = "  "
            &by = "  "
          }
    end.
    when "tax-rate":U then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории категорий и ставок налогов: код налога &1 код ставки &2"
                                                       , p-tax-code
                                                       , p-rate-code
                                                       )
        filter-point = filter-point0 + parref-mode
        filter-label = substitute("&1 Одна ставка", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_c-tax-hist.tax-code = p-tax-code AND ~
                            X_c-tax-hist.rate-code = p-rate-code AND ~
                            X_c-tax-hist.subject = ~{&table_tax-rate~} "
            &dyn_where-cond = " substitute('X_c-tax-hist.tax-code = &1 AND ~
                            X_c-tax-hist.rate-code = &2 AND ~
                            X_c-tax-hist.subject = &3&4&3', p-tax-code, p-rate-code, {&double-quote}, ~{&table_tax-rate~}) "

            &use-ind = "  "
            &by = "  "
          }
    end.
    when "tax-rate-value":U then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории категорий и ставок налогов: код налога &1 код ставки &2: значения ставок"
                                                       , p-tax-code
                                                       , p-rate-code
                                                       )
        filter-point = filter-point0 + parref-mode
        filter-label = substitute("&1 Одно значение ставки", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_c-tax-hist.tax-code = p-tax-code AND ~
                            X_c-tax-hist.rate-code = p-rate-code AND ~
                            X_c-tax-hist.subject = ~{&table_tax-rate-value~} "
            &dyn_where-cond = " substitute('X_c-tax-hist.tax-code = &1 AND ~
                            X_c-tax-hist.rate-code = &2 AND ~
                            X_c-tax-hist.subject = &3&4&3', p-tax-code, p-rate-code , ~{&double-quote~}, ~{&table_tax-rate-value~})"

            &use-ind = "  "
            &by = "  "
          }
    end.
    when "subject":U then do:
&scop hn-tax-hist-code p-subject
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории категорий и ставок налогов: код налога &1 код ставки &2 предмет изменений &3"
                                                       , p-tax-code
                                                       , p-rate-code
                                                       , {&hn-tax-hist-name}
                                                       )
        filter-point = filter-point0 + parref-mode
        filter-label = substitute("&1 Один налог Предмет изменений", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_c-tax-hist.tax-code = p-tax-code AND ~
                            X_c-tax-hist.rate-code = p-rate-code AND ~
                            X_c-tax-hist.subject = p-subject "
            &dyn_where-cond = " substitute('X_c-tax-hist.tax-code = &1 AND ~
                            X_c-tax-hist.rate-code = &2 AND ~
                            X_c-tax-hist.subject = &3&4&3 ', p-tax-code, p-rate-code, p-subject)"

            &use-ind = "  "
            &by = "  "
          }
    end.




END CASE.
apply "entry" to br-c-tax-hist in frame {&frame-name}.
reposition br-c-tax-hist to row 1 no-error.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED":U to br-c-tax-hist.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame 
PROCEDURE proc-b-sch :
assign
tbl = 'c-tax-hist'
join-tbl = 'X_c-tax-hist'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('subject', 'Предмет изменений', 'tax-hist-subject',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('action', 'Действие', 'hist-action',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tax-code', 'Код налога', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('rate-code', 'Код ставки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-date', 'Дата изменений', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время изменений', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', 'БД изменений', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
DO on stop undo, leave:
    run gbl/filter.w ( input parparentproc
                      ,input (filter-point + {&delim-par} + filter-label0)
                      ,input tbl
                      ,input join-tbl
                      ,input fld
                      ,input lab
                      ,input spr
                      ,input dim).
    RUN OpenBr in this-procedure  ( input yes, input no, input '':U).
END .

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
if not available X_c-tax-hist then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
run ref/ctaxhisv.p (
                   input X_c-tax-hist.tax-code
                  ,input X_c-tax-hist.rate-code
                  ,input X_c-tax-hist.corr-user-db-num
                  ,input X_c-tax-hist.chip-num
                  ,input X_c-tax-hist.host-code
                  ,input X_c-tax-hist.obj-type
                  ,input X_c-tax-hist.obj-code
                  ,input X_c-tax-hist.subject
                  ,input X_c-tax-hist.action
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
  (  p-action as integer ) :
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-fact-date-str Dialog-Frame 
FUNCTION get-fact-date-str RETURNS CHARACTER
  ( INPUT p-fact-order AS DECIMAL ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-fact-date AS DATE NO-UNDO.
DEFINE VARIABLE v-fact-date-str AS character NO-UNDO.
RUN factord-to-date  IN THIS-PROCEDURE(p-fact-order, OUTPUT v-fact-date) NO-ERROR.
IF NOT ERROR-STATUS:ERROR  THEN DO:
   ASSIGN
   v-fact-date-str = STRING(v-fact-date, "99/99/9999":U)
   .
   RETURN v-fact-date-str.
END.
RETURN {&question-mark}.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

