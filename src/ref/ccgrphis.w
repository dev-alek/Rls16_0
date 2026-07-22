&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_cli FOR clients.
DEFINE BUFFER X_c-cli-grp FOR c-cli-grp.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник истории групп клиентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER bttns  as character  no-undo .
DEFINE INPUT PARAMETER p-mode as character no-undo.
/*{&all} или "cli-grp":U

*/
DEFINE INPUT PARAMETER p-node-code like ub.c-cli-grp.node-code no-undo.
define input parameter p-is-del    as logical no-undo .
DEFINE OUTPUT PARAMETER  p-rid-list    as  char no-undo . /* список recid'ов выбранных аписей */


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник истории групп клиентов" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ ref/grp-attr.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
define variable log-res as log no-undo.
define variable rr as recid no-undo.
define variable jj as integer no-undo .
define variable str as char no-undo.
define variable vartbl-name as char no-undo.
define variable varact      as char no-undo.
define variable filter-point0 as character no-undo init "cggrphist":U .
define variable filter-point as character no-undo init "cggrphist":U .
define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo .
define buffer X_cli-grp for ub.cli-grp.
{ ref/tmpchgs.i "NEW SHARED" }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-c-cli-grp

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-cli-grp temp-changes

/* Definitions for BROWSE BR-c-cli-grp                                  */
&Scoped-define FIELDS-IN-QUERY-BR-c-cli-grp mark-string( recid(X_c-cli-grp), v-rid-list ) get-subject(X_c-cli-grp.subject) X_c-cli-grp.corr-date usrfulnf(X_c-cli-grp.corr-user-name) X_c-cli-grp.corr-user-db-num string(X_c-cli-grp.corr-time, "HH:MM") get-action(X_c-cli-grp.action)   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-c-cli-grp   
&Scoped-define SELF-NAME BR-c-cli-grp
&Scoped-define QUERY-STRING-BR-c-cli-grp FOR EACH X_c-cli-grp NO-LOCK
&Scoped-define OPEN-QUERY-BR-c-cli-grp OPEN QUERY {&SELF-NAME} FOR EACH X_c-cli-grp NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-c-cli-grp X_c-cli-grp
&Scoped-define FIRST-TABLE-IN-QUERY-BR-c-cli-grp X_c-cli-grp


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
    ~{&OPEN-QUERY-BR-c-cli-grp}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-sch B-Help mark-num ~
BR-c-cli-grp BR-changes v-full-name-old v-full-name-new 
&Scoped-Define DISPLAYED-OBJECTS mark-num v-full-name-old v-full-name-new 

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

DEFINE VARIABLE v-full-name-new AS CHARACTER FORMAT "X(256)":U 
     LABEL "Стало" 
     VIEW-AS FILL-IN 
     SIZE 91 BY 1 NO-UNDO.

DEFINE VARIABLE v-full-name-old AS CHARACTER FORMAT "X(256)":U 
     LABEL "Было" 
     VIEW-AS FILL-IN 
     SIZE 91 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-c-cli-grp FOR 
      X_c-cli-grp SCROLLING.

DEFINE QUERY BR-changes FOR 
      temp-changes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-c-cli-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-c-cli-grp Dialog-Frame _FREEFORM
  QUERY BR-c-cli-grp DISPLAY
      mark-string( recid(X_c-cli-grp), v-rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
      get-subject(X_c-cli-grp.subject) column-label "Предмет изменений" format "X(20)"
      X_c-cli-grp.corr-date COLUMN-LABEL "Дата корр"
      usrfulnf(X_c-cli-grp.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)"
      X_c-cli-grp.corr-user-db-num COLUMN-LABEL "БД" WIDTH 3
      string(X_c-cli-grp.corr-time, "HH:MM") COLUMN-LABEL "Время!корр" FORMAT "X(5)":U
            WIDTH 6
      get-action(X_c-cli-grp.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
            WIDTH 12
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 11.25.

DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(40)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 5.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 14
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     mark-num AT ROW 1.92 COL 9 COLON-ALIGNED NO-LABEL
     BR-c-cli-grp AT ROW 3 COL 1
     BR-changes AT ROW 14.5 COL 1
     v-full-name-old AT ROW 20 COL 2
     v-full-name-new AT ROW 21 COL 1
     SPACE(0.24) SKIP(0.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Справочник истории групп клиентов"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_cli B "?" ? ub clients
      TABLE: X_c-cli-grp B "?" ? ub c-cli-grp
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-c-cli-grp mark-num Dialog-Frame */
/* BROWSE-TAB BR-changes BR-c-cli-grp Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       BR-c-cli-grp:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

/* SETTINGS FOR FILL-IN v-full-name-new IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN v-full-name-old IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-c-cli-grp
/* Query rebuild information for BROWSE BR-c-cli-grp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-cli-grp NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-c-cli-grp */
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
ON GO OF FRAME Dialog-Frame /* Справочник истории групп клиентов */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Справочник истории групп клиентов */
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
if not available X_c-cli-grp then return no-apply .
{ gbl/markstrn.i  X_c-cli-grp  v-rid-list }
 g#log = br-c-cli-grp :refresh( )  in frame {&frame-name}.
  if not can-do ("MOUSE-SELECT-DBLCLICK,Return", last-event:function) then do:
          g#log = br-c-cli-grp:select-next-row () in frame {&frame-name}.
          apply "value-changed" to br-c-cli-grp in frame {&frame-name}.
  end.
  if num-entries (v-rid-list) = 0 then
      hide mark-num in frame {&frame-name}.
  else
  disp num-entries (v-rid-list) @ mark-num
  with frame {&frame-name}.
  apply "entry" to br-c-cli-grp in frame {&frame-name}.
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
    if ( available X_c-cli-grp ) AND ( v-rid-list = "" ) then
        v-rid-list = string( recid( X_c-cli-grp ) ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-c-cli-grp
&Scoped-define SELF-NAME BR-c-cli-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-c-cli-grp Dialog-Frame
ON RETURN OF BR-c-cli-grp IN FRAME Dialog-Frame
DO:
      apply "DEFAULT-ACTION":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-c-cli-grp Dialog-Frame
ON VALUE-CHANGED OF BR-c-cli-grp IN FRAME Dialog-Frame
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
{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-c-cli-grp" }
{ gbl/brwrefre.i "v-doc-rec = recid(X_c-cli-grp). run openbr in this-procedure. reposition br-c-cli-grp to recid v-doc-rec no-error. " }
{ gbl/brwrepos.i
&line-num=5
}
{ gbl/setfltnm.i }

{ gbl/srt-clmd.i
  &browse-name    = "br-c-cli-grp"
  &frame-name     = "{&frame-name}"
  &table-name     = "X_c-cli-grp"
  &sort-clmn_1    = "X_c-cli-grp.corr-date"
  &sort-clmn_2    = "X_c-cli-grp.corr-user-db-num"
  &open-query     = "run OpenBr in this-procedure."
  &open-query-otherwise = "run OpenBr in this-procedure."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "no"
  &mv-brw-default = "no"
}


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   if LOOKUP(p-mode, ("cli-grp":U  + {&delim-par} +
                     {&all}),
                     {&delim-par}
                     ) > 0
   THEN DO:
     find first X_cli-grp no-lock where
                X_cli-grp.node-code = p-node-code
            no-error .
     if not available X_cli-grp
     and not p-is-del
     then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-node-code и/или p-is-del" p-node-code p-is-del
        view-as alert-box ERROR.
        return.
     end.
  END. /*ша дщллгз - все моды*/
  else do:
      message vss-workfile vss-revision vss-description skip
      "Неверный вызов - p-mode=" p-mode
      view-as alert-box ERROR.
      return.
  end.
  RUN MyEnable.
  HIDE mark-num in frame {&frame-name} .
  run OpenBR in this-procedure.
  run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  browse br-changes :handle
    ) .

  run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  v-full-name-old:handle
    ) .
  run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  v-full-name-new:handle
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
  DISPLAY mark-num v-full-name-old v-full-name-new 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-sch B-Help mark-num BR-c-cli-grp BR-changes 
         v-full-name-old v-full-name-new 
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
WITH FRAME {&FRAME-NAME}.
ENABLE
B-quit
B-mark when lookup('b-mark':U, bttns) >0
B-sel when lookup('b-sel':U, bttns) >0
B-sch
B-Help
BR-c-cli-grp
br-changes
mark-num
WITH FRAME {&FRAME-NAME}.
VIEW FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
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

&scop flt-open-open-query OPEN QUERY br-c-cli-grp FOR EACH X_c-cli-grp

&scop flt-open-dyn_open-query  FOR EACH X_c-cli-grp

&scop flt-open-query-handle query br-c-cli-grp:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-waitfram yes

CASE p-mode:
  when {&all} then do:
    ASSIGN frame {&frame-name}:TITLE = "Справочник истории групп клиентов"
    filter-point = filter-point0 + p-mode.
      { gbl/fltopend.i
        &where-cond = " TRUE "
        &use-ind = "  "
        &by = "  "
      }
  end.
  when "cli-grp":U then do:
    ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории групп клиентов: вн № группы &1",
                                                    p-node-code)
    filter-point = filter-point0 + p-mode.
      { gbl/fltopend.i
        &where-cond = " X_c-cli-grp.node-code = p-node-code "
        &dyn_where-cond = " substitute('X_c-cli-grp.node-code = &1', p-node-code) "
        &use-ind = "  "
        &by = "  "
      }
  end.
END CASE.
apply "entry" to br-c-cli-grp in frame {&frame-name}.
reposition br-c-cli-grp to row 1 no-error.
run waitfram-hide in this-procedure .
if avail X_c-cli-grp then
APPLY "VALUE-CHANGED":U to br-c-cli-grp.
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
tbl = 'c-cli-grp'
join-tbl = 'X_c-cli-grp'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('corr-date', 'Дата изменений', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время изменений', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', 'БД изменений', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('subject', 'Предмет изменений', 'cli-grp-hist-subject',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

DO on stop undo, leave:
    run gbl/filter.w ( input parparentproc
                      ,input filter-point + {&delim-par} + "Справочник истории групп клиентов"
                      ,input tbl
                      ,input join-tbl
                      ,input fld
                      ,input lab
                      ,input spr
                      ,input dim).
    RUN OpenBr in this-procedure.
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
if not available X_c-cli-grp then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
assign
v-full-name-old = "":U
v-full-name-new = "":U
.
run ref/ccgrhisv.p (
                   input X_c-cli-grp.node-code
                  ,input X_c-cli-grp.corr-user-db-num
                  ,input X_c-cli-grp.chip-num
                  ,input X_c-cli-grp.subject
                  ,input no /*p-silent*/
                  ,output v-description
                  ,OUTPUT v-full-name-old
                  ,OUTPUT v-full-name-new
               ) no-error .
Open QUery br-changes for each temp-changes.
assign
br-changes:title in frame {&frame-name} = v-description
.
if v-full-name-old <> "":U
or v-full-name-new <> "":U  then do:
  DISPLAY
  v-full-name-old
  v-full-name-new
  WITH FRAME {&FRAME-NAME}.
end.
else do:
  hide
  v-full-name-old
  v-full-name-new
  IN FRAME {&FRAME-NAME}.
end.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-subject Dialog-Frame 
FUNCTION get-subject RETURNS CHARACTER
  ( p-subject as character ) :
&scop hn-cli-grp-hist-code p-subject
  RETURN {&hn-cli-grp-hist-name}.   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

