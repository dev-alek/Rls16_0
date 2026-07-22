&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_cli FOR ub.clients.
DEFINE BUFFER for-c-scales-gds FOR ub.c-scales-gds.
DEFINE BUFFER X_c-scales FOR ub.c-scales.
DEFINE BUFFER X_c-scales-gds FOR ub.c-scales-gds.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История товара на весах

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
DEFINE INPUT PARAMETER parref-mode as character no-undo.
/*{&all} или "one":U */
DEFINE OUTPUT PARAMETER  p-rid-list    as  char no-undo . /* список recid'ов выбранных аписей */
DEFINE INPUT PARAMETER pardb-num     like ub.sys-ctrl.db-num no-undo.
define input parameter parscales-num like ub.scales-gds.scales-num no-undo .
define input parameter parplu-code   like ub.scales-gds.plu-code no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник истории товара на весах" .
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
&Glob hn-scales-hist-name entry (lookup (~{&hn-scales-hist-code}, ~{&table_scales~} + ~{&comma-char~} +  ~
                                          ~{&table_scales-attr~} + ~{&comma-char~} + ~{&table_scales-grp~}), 'Весы,Аттр.весов,Группа товаров на весах':U)

define variable log-res as log no-undo.
define variable rr as recid no-undo.
define variable jj as integer no-undo .
define variable str as character no-undo.
define variable conf-par as character no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as character no-undo.
define variable vartbl-name as character no-undo.
define variable varact      as character no-undo.
define variable filter-point0 as character no-undo  init "cscalgds".
define variable filter-point as character no-undo init "cscalgds".
define variable filter-label0 as character no-undo  init "Справочник_истории_товара_на_весах".
define variable filter-label as character no-undo init "Справочник_истории_товара_на_весах".
define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo .
define buffer X_scales-gds for ub.scales-gds.
{ ref/tmpchgs.i "NEW SHARED" " " "with-action" }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-c-scales-gds

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-scales-gds X_c-scales temp-changes

/* Definitions for BROWSE BR-c-scales-gds                               */
&Scoped-define FIELDS-IN-QUERY-BR-c-scales-gds mark-string( recid(X_c-scales-gds), v-rid-list ) X_c-scales-gds.corr-user-db-num X_c-scales-gds.scales-num X_c-scales-gds.PLU-CODE get-action(X_c-scales.action) X_c-scales-gds.corr-date usrfulnf(X_c-scales-gds.corr-user-name) string(X_c-scales-gds.corr-time, "HH:MM")
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-c-scales-gds
&Scoped-define SELF-NAME BR-c-scales-gds
&Scoped-define QUERY-STRING-BR-c-scales-gds FOR EACH X_c-scales-gds NO-LOCK, ~
            FIRST X_c-scales NO-LOCK WHERE           X_c-scales.db-num = X_scales-gds.db-num       AND X_c-scales.scales-num = X_scales-gds.scales-num       AND X_c-scales.corr-user-db-num = X_scales-gds.corr-user-db-num       AND X_c-scales.chip-num = X_scales-gds.chip-num INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-c-scales-gds OPEN QUERY {&SELF-NAME} FOR EACH X_c-scales-gds NO-LOCK, ~
            FIRST X_c-scales NO-LOCK WHERE           X_c-scales.db-num = X_scales-gds.db-num       AND X_c-scales.scales-num = X_scales-gds.scales-num       AND X_c-scales.corr-user-db-num = X_scales-gds.corr-user-db-num       AND X_c-scales.chip-num = X_scales-gds.chip-num INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-c-scales-gds X_c-scales-gds X_c-scales
&Scoped-define FIRST-TABLE-IN-QUERY-BR-c-scales-gds X_c-scales-gds
&Scoped-define SECOND-TABLE-IN-QUERY-BR-c-scales-gds X_c-scales


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
BR-c-scales-gds BR-changes
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-action Dialog-Frame
FUNCTION get-action RETURNS CHARACTER
  ( INPUT p-action AS INTEGER )  FORWARD.

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
DEFINE QUERY BR-c-scales-gds FOR
      X_c-scales-gds,
      X_c-scales SCROLLING.

DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-c-scales-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-c-scales-gds Dialog-Frame _FREEFORM
  QUERY BR-c-scales-gds NO-LOCK DISPLAY
      mark-string( recid(X_c-scales-gds), v-rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
X_c-scales-gds.corr-user-db-num COLUMN-LABEL "БД" FORMAT ">>>>9":U
X_c-scales-gds.scales-num COLUMN-LABEL "Весы" FORMAT ">>>>9":U
X_c-scales-gds.PLU-code COLUMN-LABEL "PLU" FORMAT ">>>>9":U
get-action(X_c-scales.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
X_c-scales-gds.corr-date COLUMN-LABEL "Дата корр" FORMAT "99/99/9999":U
usrfulnf(X_c-scales-gds.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
string(X_c-scales-gds.corr-time, "HH:MM")
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 12.33.

DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(30)"
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
     mark-num AT ROW 2.25 COL 9 COLON-ALIGNED NO-LABEL
     BR-c-scales-gds AT ROW 3.42 COL 1
     BR-changes AT ROW 16.04 COL 1
     SPACE(0.24) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Справочник истории товара на весах"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_cli B "?" ? ub clients
      TABLE: for-c-scales-gds B "?" ? ub c-scales-gds
      TABLE: X_c-scales B "?" ? ub c-scales
      TABLE: X_c-scales-gds B "?" ? ub c-scales-gds
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-c-scales-gds mark-num Dialog-Frame */
/* BROWSE-TAB BR-changes BR-c-scales-gds Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-c-scales-gds
/* Query rebuild information for BROWSE BR-c-scales-gds
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH X_c-scales-gds NO-LOCK,
     FIRST X_c-scales NO-LOCK WHERE
          X_c-scales.db-num = X_scales-gds.db-num
      AND X_c-scales.scales-num = X_scales-gds.scales-num
      AND X_c-scales.corr-user-db-num = X_scales-gds.corr-user-db-num
      AND X_c-scales.chip-num = X_scales-gds.chip-num INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-c-scales-gds */
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
ON GO OF FRAME Dialog-Frame /* Справочник истории товара на весах */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Справочник истории товара на весах */
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
 if not available X_c-scales-gds then return no-apply.
 { gbl/markstrn.i X_c-scales-gds v-rid-list  }
 glog = br-c-scales-gds :refresh( )  in frame {&frame-name}.
  if not can-do ("MOUSE-SELECT-DBLCLICK,Return", last-event:function) then do:
    glog = br-c-scales-gds:select-next-row () in frame {&frame-name}.
    apply "value-changed" to br-c-scales-gds in frame {&frame-name}.
  end.
  if num-entries (v-rid-list) = 0 then
      hide mark-num in frame {&frame-name}.
  else
  disp num-entries (v-rid-list) @ mark-num
  with frame {&frame-name}.
  apply "entry" to br-c-scales-gds in frame {&frame-name}.

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
    if ( available X_c-scales-gds ) AND ( v-rid-list = "" ) then
        v-rid-list = string( recid( X_c-scales-gds ) ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-c-scales-gds
&Scoped-define SELF-NAME BR-c-scales-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-c-scales-gds Dialog-Frame
ON RETURN OF BR-c-scales-gds IN FRAME Dialog-Frame
DO:
      apply "DEFAULT-ACTION":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-c-scales-gds Dialog-Frame
ON VALUE-CHANGED OF BR-c-scales-gds IN FRAME Dialog-Frame
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
{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-c-scales-gds" }
{ gbl/brwrefre.i "v-doc-rec = recid(X_c-scales-gds). run openbr in this-procedure  ( INPUT yes, input no, input '':U). reposition br-c-scales-gds to recid v-doc-rec no-error. " }
{ gbl/brwrepos.i
&line-num=5
}
{ gbl/setfltnm.i }
{ gbl/srt-clmd.i
  &browse-name    = "br-c-scales-gds"
  &frame-name     = "{&frame-name}"
  &table-name     = "X_c-scales-gds"
  &sort-clmn_1    = "X_c-scales-gds.corr-date"
  &open-query     = "run OpenBr in this-procedure ( INPUT yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure  ( INPUT yes, input no, input '':U)."
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
     find first X_scales-gds no-lock where
                X_scales-gds.db-num = pardb-num
           AND  X_scales-gds.scales-num = parscales-num no-error .
     if not available X_scales-gds then do:
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
  run OpenBR in this-procedure  ( INPUT yes, input no, input '':U).
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
  ENABLE b-quit B-mark b-sel B-sch B-Help mark-num BR-c-scales-gds BR-changes
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
BR-c-scales-gds
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

&scop flt-open-open-query OPEN QUERY br-c-scales-gds FOR EACH X_c-scales-gds NO-LOCK

&scop flt-open-dyn_open-query  FOR EACH X_c-scales-gds NO-LOCK

&scop flt-open-query-handle query br-c-scales-gds:handle

&scop flt-open-open-query-tail   ~
          , FIRST X_c-scales NO-LOCK WHERE   X_c-scales.db-num = X_c-scales-gds.db-num ~
      AND X_c-scales.scales-num = X_c-scales-gds.scales-num ~
      AND X_c-scales.chip-num = X_c-scales-gds.chip-num ~
      AND X_c-scales.corr-user-db-num = X_c-scales-gds.corr-user-db-num

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-waitfram yes

CASE parref-mode:
    when {&all} then do:
        ASSIGN frame {&frame-name}:TITLE = "Справочник истории товара на весах"
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
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории товара на весах: БД &1 весы &2 PLU &3"
                                                       ,pardb-num
                                                       ,parscales-num)
        filter-point = filter-point0 + parref-mode
        filter-label = substitute("&1 Один весы один товар", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_c-scales-gds.db-num = pardb-num AND X_c-scales-gds.scales-num = parscales-num ~
                            and X_c-scales-gds.PLU-code = parplu-code"
            &dyn_where-cond = " substitute('X_c-scales-gds.db-num = &1 AND X_c-scales-gds.scales-num = &2 ~
                            and X_c-scales-gds.PLU-code = &3', pardb-num, parscales-num, parplu-code)"

            &use-ind = "  "
            &by = "  "
          }
    end.
END CASE.
apply "entry" to br-c-scales-gds in frame {&frame-name}.
reposition br-c-scales-gds to row 1 no-error.
APPLY "VALUE-CHANGED":U to br-c-scales-gds.
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
tbl = 'c-scales-gds'
join-tbl = 'X_c-scales-gds'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('db-num', 'БД', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('scales-num', 'Номер', '',
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
                     , input (filter-point + {&delim-par} + filter-label)
                     , input tbl
                     , input join-tbl
                     , input fld
                     , input lab
                     , input spr
                     , input dim).
    RUN OpenBr in this-procedure ( INPUT yes, input no, input '':U).
END .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame
PROCEDURE proc-view-changes :
define buffer buf_c-scales for ub.c-scales.
for each temp-changes:
  delete temp-changes.
END.
if not available X_c-scales-gds then do:
  Open QUery br-changes for each temp-changes.
  return.
end.

if not available X_c-scales then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
&scop fields-name-list "b-code,deadline,obj-code,to-send,to-del,wt-cart"
define variable v-label-param as character no-undo .

v-label-param =
  "b-code" + {&delim-par} + "Бар-код" + {&delim-par} + "" + {&delim-flf}
 + "deadline" + {&delim-par} + "Срок хранения" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Магазин" + {&delim-par} + "" + {&delim-flf}
 + "to-send" + {&delim-par} + "Требует обновления" + {&delim-par} + "" + {&delim-flf}
 + "to-del" + {&delim-par} + "Удаляется" + {&delim-par} + "" + {&delim-flf}
 + "wt-cart" + {&delim-par} + "Вес упаковки" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  X_c-scales.action = integer({&hn-create})
                                            ,input  X_c-scales.action = integer({&hn-delete})
                                            ,input  buffer X_c-scales-gds:handle
                                            ,input  {&table_scales-gds}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


Open QUery br-changes for each temp-changes.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-action Dialog-Frame
FUNCTION get-action RETURNS CHARACTER
  ( INPUT p-action AS INTEGER ) :

    &scop hn-action-code trim(string(p-action))
define variable dops as character no-undo.
assign dops = {&hn-action-name} no-error.
RETURN dops.   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME