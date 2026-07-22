&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER for-c-cash-pay FOR c-cash-pay.
DEFINE BUFFER X_c-cash-pay FOR c-cash-pay.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник истории типов кассовых платежей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/16/06
Author: Bakhtadze Natalya
Creation date: 01/16/06

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER bttns  as character  no-undo .
DEFINE INPUT PARAMETER parref-mode as character no-undo.
/*{&all} или "one":U или "one-subject"*/
DEFINE OUTPUT PARAMETER  p-rid-list    as  char no-undo . /* список recid'ов выбранных аписей */
DEFINE INPUT PARAMETER p-cdpay-code like ub.c-cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER p-curr-code like ub.c-cash-pay.curr-code no-undo.
define input parameter p-subject   like ub.c-cash-pay.subject no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник истории типов кассовых платежей" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new}
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
define variable log-res as log no-undo.
define variable rr as recid no-undo.
define variable jj as integer no-undo .
define variable str as char no-undo.
define variable conf-par as char no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as char no-undo.
define variable vartbl-name as char no-undo.
define variable varact      as char no-undo.
DEFINE VARIABLE parstock like ub.wth-pobj.income-pl no-undo .
define variable filter-point0 as character no-undo init "ccashpay" .
define variable filter-point as character no-undo init "ccashpay" .
define variable filter-label0 as character no-undo init "Справочник_истории_кассовых_платежей" .
define variable filter-label  as character no-undo init "Справочник_истории_кассовых_платежей" .
define variable v-rid-list as character no-undo .
define variable sort-column-name as character no-undo .
define variable rep-rec as recid no-undo .
define buffer X_cash-pay for ub.cash-pay.
{ ref/tmpchgs.i "NEW SHARED" }

&SCOPED-DEFINE hn-cash-pay-hist-code X_c-cash-pay.subject

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-c-cash-pay

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-cash-pay temp-changes

/* Definitions for BROWSE BR-c-cash-pay                                 */
&Scoped-define FIELDS-IN-QUERY-BR-c-cash-pay mark-string( recid(X_c-cash-pay), v-rid-list ) {&hn-cash-pay-hist-name} get-action(X_c-cash-pay.action) X_c-cash-pay.corr-date usrfulnf(X_c-cash-pay.corr-user-name) string(X_c-cash-pay.corr-time, "HH:MM")   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-c-cash-pay   
&Scoped-define SELF-NAME BR-c-cash-pay
&Scoped-define QUERY-STRING-BR-c-cash-pay FOR EACH X_c-cash-pay NO-LOCK
&Scoped-define OPEN-QUERY-BR-c-cash-pay OPEN QUERY {&SELF-NAME} FOR EACH X_c-cash-pay NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-c-cash-pay X_c-cash-pay
&Scoped-define FIRST-TABLE-IN-QUERY-BR-c-cash-pay X_c-cash-pay


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
BR-c-cash-pay BR-changes 
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
DEFINE QUERY BR-c-cash-pay FOR X_c-cash-pay SCROLLING.


DEFINE QUERY BR-changes FOR 
      temp-changes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-c-cash-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-c-cash-pay Dialog-Frame _FREEFORM
  QUERY BR-c-cash-pay DISPLAY
      mark-string( recid(X_c-cash-pay), v-rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
      {&hn-cash-pay-hist-name} COLUMN-LABEL "Предмет изменений" FORMAT "X(12)":U
      get-action(X_c-cash-pay.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
      X_c-cash-pay.corr-date COLUMN-LABEL "Дата корр" FORMAT "99/99/9999":U
      usrfulnf(X_c-cash-pay.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
      string(X_c-cash-pay.corr-time, "HH:MM")
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
     mark-num AT ROW 1.92 COL 9 COLON-ALIGNED NO-LABEL
     BR-c-cash-pay AT ROW 3.42 COL 1
     BR-changes AT ROW 16.04 COL 1
     SPACE(0.24) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Справочник истории кассвых платежей"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: for-c-cash-pay B "?" ? ub c-cash-pay
      TABLE: X_c-cash-pay B "?" ? ub c-cash-pay
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-c-cash-pay mark-num Dialog-Frame */
/* BROWSE-TAB BR-changes BR-c-cash-pay Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       BR-c-cash-pay:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-c-cash-pay
/* Query rebuild information for BROWSE BR-c-cash-pay
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-cash-pay NO-LOCK.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE NEW SHARED QUERY BR-c-cash-pay FOR X_c-cash-pay SCROLLING.
     _END_FREEFORM_DEFINE
     _Query            is NOT OPENED
*/  /* BROWSE BR-c-cash-pay */
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
ON GO OF FRAME Dialog-Frame /* Справочник истории кассвых платежей */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Справочник истории кассвых платежей */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable glog as logical no-undo .
if not available X_c-cash-pay then return no-apply.
{ gbl/markstrn.i X_c-cash-pay v-rid-list }
 glog = br-c-cash-pay :refresh( )  in frame {&frame-name}.
  if not can-do ("MOUSE-SELECT-DBLCLICK,Return", last-event:function) then do:
          glog = br-c-cash-pay:select-next-row () in frame {&frame-name}.
          apply "value-changed" to br-c-cash-pay in frame {&frame-name}.
  end.
  if num-entries (v-rid-list) = 0 then
      hide mark-num in frame {&frame-name}.
  else
  disp num-entries (v-rid-list) @ mark-num
  with frame {&frame-name}.
  apply "entry" to br-c-cash-pay in frame {&frame-name}.
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
    if ( available X_c-cash-pay ) AND ( v-rid-list = "" ) then
        v-rid-list = string( recid( X_c-cash-pay ) ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-c-cash-pay
&Scoped-define SELF-NAME BR-c-cash-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-c-cash-pay Dialog-Frame
ON RETURN OF BR-c-cash-pay IN FRAME Dialog-Frame
DO:
      apply "DEFAULT-ACTION":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-c-cash-pay Dialog-Frame
ON VALUE-CHANGED OF BR-c-cash-pay IN FRAME Dialog-Frame
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
{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-c-cash-pay" }
{ gbl/brwrefre.i "rep-rec = recid(X_c-cash-pay). run openbr in this-procedure  ( input yes, input no, input '':U). reposition br-c-cash-pay to recid rep-rec no-error. ~
               APPLY 'ENTRY' to br-c-cash-pay. APPLY 'VALUE-CHANGED' to br-c-cash-pay. " }

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel  }
{ gbl/setfltnm.i }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  CASE parref-mode:
   WHEN {&all}        THEN DO:
   END.
   WHEN "one":U
   or
   when "one-subject":U
   THEN DO:
     find first X_cash-pay no-lock where
                X_cash-pay.cdpay-code = p-cdpay-code
           AND  X_cash-pay.curr-code = p-curr-code  no-error .
     if not available X_cash-pay then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров p-cdpay-code p-curr-code"
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
  RUN MyEnable in this-procedure .
  HIDE mark-num in frame {&frame-name} .
  run OpenBR in this-procedure  ( input yes, input no, input '':U).
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
  ENABLE b-quit B-mark b-sel B-sch B-Help mark-num BR-c-cash-pay BR-changes 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
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
WITH FRAME {&frame-name} .
ENABLE
B-quit
B-mark when lookup('b-mark':U, bttns) >0
B-sel when lookup('b-sel':U, bttns) >0
B-sch
B-Help
BR-c-cash-pay
br-changes
mark-num
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .


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

&scop flt-open-debug-file

&scop flt-open-open-query OPEN QUERY br-c-cash-pay FOR EACH X_c-cash-pay

&scop flt-open-dyn_open-query  FOR EACH X_c-cash-pay

&scop flt-open-query-handle query br-c-cash-pay:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-waitfram yes

CASE parref-mode:
    when {&all} then do:
        ASSIGN frame {&frame-name}:TITLE = "Справочник истории кассовых платежей"
        filter-point = filter-point0 + parref-mode
        filter-label = filter-label0
        .
          { gbl/fltopend.i
            &where-cond = " TRUE "
            &use-ind = "  "
            &by = "  "
          }
    end.
    when "one":U then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории кассовых платежей: код платежа &1 код валюты &2",
                                                       p-cdpay-code, p-curr-code)
        filter-point = filter-point0 + parref-mode
        filter-label = substitute("&1 - один тип платежа", filter-label0 )
        .
          { gbl/fltopend.i
            &where-cond = " X_c-cash-pay.curr-code = p-curr-code AND X_c-cash-pay.cdpay-code = p-cdpay-code "
            &dyn_where-cond = " substitute('X_c-cash-pay.curr-code = &1 AND X_c-cash-pay.cdpay-code = &2 ', p-curr-code, p-cdpay-code ) "
            &use-ind = "  "
            &by = "  "
          }
    end.
    when "one-subject":U then do:
&scop hn-cash-pay-hist-code p-subject
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории кассовых платежей: код платежа &1 код валюты &2; &3"
                                                       , p-cdpay-code
                                                       , p-curr-code
                                                       , {&hn-cash-pay-hist-name}
                                                       )
        filter-point = filter-point0 + parref-mode
        filter-label = substitute("&1 - один тип платежа", filter-label0 )
        .
          { gbl/fltopend.i
            &where-cond = " X_c-cash-pay.curr-code = p-curr-code AND X_c-cash-pay.cdpay-code = p-cdpay-code AND ~
                            X_c-cash-pay.subject = p-subject "
            &dyn_where-cond = " substitute('X_c-cash-pay.curr-code = &1 AND X_c-cash-pay.cdpay-code = &2 AND ~
                            X_c-cash-pay.subject = &3&4&3', p-curr-code, p-cdpay-code, ~{&double-quote~}, p-subject) "

            &use-ind = "  "
            &by = "  "
          }
    end.


END CASE.
apply "entry" to br-c-cash-pay in frame {&frame-name}.
if rep-rec <> ? then reposition br-c-cash-pay to recid rep-rec no-error.
if error-status:error then do:
  reposition br-c-cash-pay to row 1 no-error.
end.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-c-cash-pay:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
if avail X_c-cash-pay then
APPLY "VALUE-CHANGED":U to br-c-cash-pay.
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
tbl = 'c-cash-pay'
join-tbl = 'X_c-cash-pay'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('cdpay-code', 'Код платежат', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('curr-code', 'Код валюты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('attr-code', 'Атрибут', '',
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
                      ,input filter-point + {&delim-par} + filter-label
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
define variable v-description as character no-undo .
for each temp-changes:
    delete temp-changes.
END.
if not available X_c-cash-pay then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
run ref/ccshpayv.p (
                   input X_c-cash-pay.cdpay-code
                  ,input X_c-cash-pay.curr-code
                  ,input X_c-cash-pay.attr-code
                  ,input X_c-cash-pay.corr-user-db-num
                  ,input X_c-cash-pay.chip-num
                  ,input X_c-cash-pay.subject
                  ,input 0 /*X_c-cash-pay.action*/
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

