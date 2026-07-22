&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_cli FOR ub.clients.
DEFINE BUFFER for-c-scales FOR ub.c-scales.
DEFINE BUFFER X_c-scales FOR ub.c-scales.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История весов

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
/*{&all} или "one":U или "one-subject"*/
DEFINE OUTPUT PARAMETER  p-rid-list    as  char no-undo . /* список recid'ов выбранных аписей */
DEFINE INPUT PARAMETER pardb-num like ub.sys-ctrl.db-num no-undo.
define input parameter parscales-num like ub.scales.scales-num no-undo .
define input parameter p-subject   like ub.c-scales.subject no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник истории весов" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new}
{ str/wth-lib.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }

define variable log-res as log no-undo.
define variable rr as recid no-undo.
define variable jj as integer no-undo .
define variable str as character no-undo.
define variable conf-par as character no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as character no-undo.
define variable vartbl-name as character no-undo.
define variable varact      as character no-undo.
define variable filter-point0 as character no-undo  init "cscales".
define variable filter-point as character no-undo  init "cscales".
define variable filter-label0 as character no-undo  init "Справочник истории весов".
define variable filter-label as character no-undo init "Справочник истории весов".
define variable v-rid-list as character no-undo .
define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
define NEW SHARED buffer c-scales for ub.c-scales .
define buffer X_scales for ub.scales.
{ ref/tmpchgs.i "NEW SHARED" }

&SCOPED-DEFINE hn-scl-hist-code X_c-scales.subject

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-c-scales

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-scales temp-changes

/* Definitions for BROWSE BR-c-scales                                   */
&Scoped-define FIELDS-IN-QUERY-BR-c-scales mark-string( recid(X_c-scales), v-rid-list ) {&hn-scl-hist-name} get-action(X_c-scales.action) X_c-scales.corr-date usrfulnf(X_c-scales.corr-user-name) string(X_c-scales.corr-time, "HH:MM")
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-c-scales
&Scoped-define SELF-NAME BR-c-scales
&Scoped-define QUERY-STRING-BR-c-scales FOR EACH X_c-scales NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-c-scales OPEN QUERY {&SELF-NAME} FOR EACH X_c-scales NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-c-scales X_c-scales
&Scoped-define FIRST-TABLE-IN-QUERY-BR-c-scales X_c-scales


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
BR-c-scales BR-changes
&Scoped-Define DISPLAYED-OBJECTS mark-num

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
DEFINE QUERY BR-c-scales FOR
      X_c-scales SCROLLING.

DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-c-scales
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-c-scales Dialog-Frame _FREEFORM
  QUERY BR-c-scales NO-LOCK DISPLAY
      mark-string( recid(X_c-scales), v-rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
      {&hn-scl-hist-name} COLUMN-LABEL "Предмет изменений" FORMAT "X(20)":U
      get-action(X_c-scales.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
      X_c-scales.corr-date COLUMN-LABEL "Дата корр" FORMAT "99/99/9999":U
      usrfulnf(X_c-scales.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
      string(X_c-scales.corr-time, "HH:MM")
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 12.33.

DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(255)" width 20
temp-changes.v_old COLUMn-LABEL "Было" format "X(40)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(40)"
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
     mark-num AT ROW 2.27 COL 9 COLON-ALIGNED NO-LABEL
     BR-c-scales AT ROW 3.43 COL 1
     BR-changes AT ROW 16.03 COL 1
     SPACE(0.24) SKIP(0.01)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Справочник истории весов"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_cli B "?" ? ub clients
      TABLE: for-c-scales B "?" ? ub c-scales
      TABLE: X_c-scales B "?" ? ub c-scales
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-c-scales mark-num Dialog-Frame */
/* BROWSE-TAB BR-changes BR-c-scales Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-c-scales
/* Query rebuild information for BROWSE BR-c-scales
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-scales NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-c-scales */
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
ON GO OF FRAME Dialog-Frame /* Справочник истории весов */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Справочник истории весов */
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
 if not available X_c-scales then return no-apply.
 { gbl/markstrn.i X_c-scales v-rid-list  }
 glog = br-c-scales :refresh( )  in frame {&frame-name}.
  if not can-do ("MOUSE-SELECT-DBLCLICK,Return", last-event:function) then do:
    glog = br-c-scales:select-next-row () in frame {&frame-name}.
    apply "value-changed" to br-c-scales in frame {&frame-name}.
  end.
  if num-entries (v-rid-list) = 0 then
      hide mark-num in frame {&frame-name}.
  else
  disp num-entries (v-rid-list) @ mark-num
  with frame {&frame-name}.
  apply "entry" to br-c-scales in frame {&frame-name}.

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
    if ( available X_c-scales ) AND ( v-rid-list = "" ) then
        v-rid-list = string( recid( X_c-scales ) ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-c-scales
&Scoped-define SELF-NAME BR-c-scales
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-c-scales Dialog-Frame
ON RETURN OF BR-c-scales IN FRAME Dialog-Frame
DO:
      apply "DEFAULT-ACTION":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-c-scales Dialog-Frame
ON VALUE-CHANGED OF BR-c-scales IN FRAME Dialog-Frame
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
{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-c-scales" }
{ gbl/brwrefre.i "v-doc-rec = recid(X_c-scales). run openbr in this-procedure ( INPUT yes, input no, input '':U). reposition br-c-scales to recid v-doc-rec no-error. " }
{ gbl/brwrepos.i
&line-num=5
}
{ gbl/setfltnm.i }
{ gbl/srt-clmd.i
  &browse-name    = "br-c-scales"
  &frame-name     = "{&frame-name}"
  &table-name     = "X_c-scales"
  &sort-clmn_1    = "X_c-scales.corr-date"
  &open-query     = "run OpenBr in this-procedure ( INPUT yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure ( INPUT yes, input no, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "no"
  &mv-brw-default = "no"
}


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  CASE parref-mode:
   WHEN {&all}        THEN DO:
   END.
   WHEN "one":U THEN DO:
     find first X_scales no-lock where
                X_scales.db-num = pardb-num
           AND  X_scales.scales-num = parscales-num no-error .
     if not available X_scales then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверный значение параметров pardb-num parscales-num"
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
  run OpenBR in this-procedure ( INPUT yes, input no, input '':U).
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
  ENABLE b-quit B-mark b-sel B-sch B-Help mark-num BR-c-scales BR-changes
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
BR-c-scales
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


&scop flt-open-open-query OPEN QUERY br-c-scales FOR EACH X_c-scales

&scop flt-open-dyn_open-query FOR EACH X_c-scales

&scop flt-open-query-handle query br-c-scales:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-waitfram yes

CASE parref-mode:
    when {&all} then do:
        ASSIGN frame {&frame-name}:TITLE = "Справочник истории весов"
        filter-point = filter-point0 + parref-mode
        filter-label = substitute("&1", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " TRUE "
            &use-ind = "  "
            &by = "  "
          }
    end.
    when "one":U then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории весов: БД &1 весы N&2"
                                                       ,pardb-num
                                                       ,parscales-num)
        filter-point = filter-point0 + parref-mode
        filter-label = substitute("&1 Одни весы", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_c-scales.db-num = pardb-num AND X_c-scales.scales-num = parscales-num"
            &dyn_where-cond = " substitute('X_c-scales.db-num = &1 AND X_c-scales.scales-num = &2', pardb-num, parscales-num)"
            &use-ind = "  "
            &by = "  "
          }
    end.
    when "one-subject":U then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории весов: БД &1 весы N&2 &3"
                                                       , pardb-num
                                                       , parscales-num
                                                       , p-subject
                                                       )
        filter-point = filter-point0 + parref-mode
        filter-label = substitute("&1 Одни весы, Предмет изменений", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_c-scales.db-num = pardb-num AND X_c-scales.scales-num = parscales-num ~
                         AND X_c-scales.subject = p-subject "
            &dyn_where-cond = " substitute('X_c-scales.db-num = &1 AND X_c-scales.scales-num = &2 ~
                         AND X_c-scales.subject = &3&4&3 ', pardb-num, parscales-num, ~{&double-quote~}, p-subject)"

            &use-ind = "  "
            &by = "  "
          }
    end.


END CASE.
apply "entry" to br-c-scales in frame {&frame-name}.
reposition br-c-scales to row 1 no-error.
APPLY "VALUE-CHANGED":U to br-c-scales.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
assign
tbl = 'c-scales'
join-tbl = 'X_c-scales'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('db-num', 'БД', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('scales-num', 'Номер', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('subject', 'Предмет изменений', 'scl-hist-subject',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('address', 'Адрес', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-date', 'Дата изменений', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время изменений', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', 'БД изменений', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-del', 'Удаленная запись', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
DO on stop undo, leave:
    run gbl/filter.w ( input parparentproc
                      ,input (filter-point + {&delim-par} + filter-label)
                      ,input tbl
                      ,input join-tbl
                      ,input fld
                      ,input lab
                      ,input spr
                      ,input dim).
   RUN OpenBr in this-procedure ( INPUT yes, input no, input '':U).
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
if not available X_c-scales then do:
  Open QUery br-changes for each temp-changes.
  return.
end.

run ref/cscalv.p (
                   input X_c-scales.db-num
                  ,input X_c-scales.scales-num
                  ,input X_c-scales.attr-code
                  ,input X_c-scales.corr-user-db-num
                  ,input X_c-scales.chip-num
                  ,input X_c-scales.subject
                  ,input 0 /*c-cli-hist.action*/
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