&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_cli FOR ub.clients.
DEFINE BUFFER for-c-gds-prt FOR ub.c-gds-prt.
DEFINE BUFFER X_c-gds-prt FOR ub.c-gds-prt.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник истории шкал

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
/*{&all} или "one":U или "prt-root" */
DEFINE INPUT PARAMETER p-node-code like ub.c-gds-prt.node-code no-undo.
define input parameter p-is-del    as logical no-undo .
DEFINE OUTPUT PARAMETER  p-rid-list    as  char no-undo . /* список recid'ов выбранных аписей */


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник истории шкал" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
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
define variable vartbl-name as char no-undo.
define variable varact      as char no-undo.
define variable filter-point0 as character no-undo init "cgdsprts":U .
define variable filter-point as character no-undo .
define variable filter-label0 as character no-undo init "История шкал":U .
define variable filter-label as character no-undo init "История шкал":U .
define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo .
define buffer X_gds-prt for ub.gds-prt.

{ ref/tmpchgs.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-c-gds-prt

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-gds-prt temp-changes

/* Definitions for BROWSE BR-c-gds-prt                                  */
&Scoped-define FIELDS-IN-QUERY-BR-c-gds-prt mark-string( recid(X_c-gds-prt), v-rid-list ) X_c-gds-prt.corr-date usrfulnf(X_c-gds-prt.corr-user-name) X_c-gds-prt.corr-user-db-num X_c-gds-prt.node-code get-action(X_c-gds-prt.action) string(X_c-gds-prt.corr-time, "HH:MM")
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-c-gds-prt
&Scoped-define SELF-NAME BR-c-gds-prt
&Scoped-define QUERY-STRING-BR-c-gds-prt FOR EACH X_c-gds-prt NO-LOCK
&Scoped-define OPEN-QUERY-BR-c-gds-prt OPEN QUERY {&SELF-NAME} FOR EACH X_c-gds-prt NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-c-gds-prt X_c-gds-prt
&Scoped-define FIRST-TABLE-IN-QUERY-BR-c-gds-prt X_c-gds-prt


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
    ~{&OPEN-QUERY-BR-c-gds-prt}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-sch B-Help mark-num ~
BR-c-gds-prt BR-changes v-full-name-old v-full-name-new
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
DEFINE QUERY BR-c-gds-prt FOR
      X_c-gds-prt SCROLLING.

DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-c-gds-prt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-c-gds-prt Dialog-Frame _FREEFORM
  QUERY BR-c-gds-prt DISPLAY
      mark-string( recid(X_c-gds-prt), v-rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
X_c-gds-prt.corr-date COLUMN-LABEL "Дата корр" FORMAT "99/99/9999":U
usrfulnf(X_c-gds-prt.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
X_c-gds-prt.corr-user-db-num COLUMN-LABEL "БД" FORMAT ">>>>9":U
    WIDTH 6
X_c-gds-prt.node-code COLUMN-LABEL "Вн.№ узла" FORMAT ">,>>>,>>9":U
get-action(X_c-gds-prt.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
string(X_c-gds-prt.corr-time, "HH:MM") COLUMN-LABEL "Время!корр" FORMAT "X(5)":U
    WIDTH 6
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
     BR-c-gds-prt AT ROW 3 COL 1
     BR-changes AT ROW 14.5 COL 1
     v-full-name-old AT ROW 20 COL 2
     v-full-name-new AT ROW 21 COL 1
     SPACE(0.24) SKIP(0.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Справочник истории шкал"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_cli B "?" ? ub clients
      TABLE: for-c-gds-prt B "?" ? ub c-gds-prt
      TABLE: X_c-gds-prt B "?" ? ub c-gds-prt
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-c-gds-prt mark-num Dialog-Frame */
/* BROWSE-TAB BR-changes BR-c-gds-prt Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN v-full-name-new IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN v-full-name-old IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-c-gds-prt
/* Query rebuild information for BROWSE BR-c-gds-prt
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-gds-prt NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-c-gds-prt */
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
ON GO OF FRAME Dialog-Frame /* Справочник истории шкал */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Справочник истории шкал */
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
if not available X_c-gds-prt then return no-apply.
  { gbl/markstrn.i X_c-gds-prt v-rid-list }
  g#log = br-c-gds-prt :refresh( )  in frame {&frame-name}.
  if not can-do ("MOUSE-SELECT-DBLCLICK,Return", last-event:function) then do:
          g#log = br-c-gds-prt:select-next-row () in frame {&frame-name}.
          apply "value-changed" to br-c-gds-prt in frame {&frame-name}.
  end.
  if num-entries (v-rid-list) = 0 then
      hide mark-num in frame {&frame-name}.
  else
  disp num-entries (v-rid-list) @ mark-num
  with frame {&frame-name}.
  apply "entry" to br-c-gds-prt in frame {&frame-name}.

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
    if ( available X_c-gds-prt ) AND ( v-rid-list = "" ) then
        v-rid-list = string( recid( X_c-gds-prt ) ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-c-gds-prt
&Scoped-define SELF-NAME BR-c-gds-prt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-c-gds-prt Dialog-Frame
ON RETURN OF BR-c-gds-prt IN FRAME Dialog-Frame
DO:
      apply "DEFAULT-ACTION":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-c-gds-prt Dialog-Frame
ON VALUE-CHANGED OF BR-c-gds-prt IN FRAME Dialog-Frame
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
{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-c-gds-prt" }
{ gbl/setfltnm.i }
{ gbl/brwrefre.i "v-doc-rec = recid(X_c-gds-prt). run openbr in this-procedure ( input yes, input no, input '':U). reposition br-c-gds-prt to recid v-doc-rec no-error.
              APPLY 'VALUE-CHANGED' to br-c-gds-prt. " }
{ gbl/brwrepos.i
&line-num=5
}
{ gbl/srt-clmd.i
  &browse-name    = "br-c-gds-prt"
  &frame-name     = "{&frame-name}"
  &table-name     = "X_c-gds-prt"
  &sort-clmn_1    = "X_c-gds-prt.corr-date"
  &sort-clmn_2    = "X_c-gds-prt.corr-user-db-num"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "no"
  &mv-brw-default = "no"
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   if LOOKUP(p-mode, ("one":U  + {&delim-par} +
                     "prt-root":U + {&delim-par} +
                     {&all} + {&delim-par}),
                     {&delim-par}
                     ) > 0
   THEN DO:
     if p-mode = "one":U
     then do:
      find first X_gds-prt no-lock where
                  X_gds-prt.node-code = p-node-code
              no-error .
      if not available X_gds-prt
      and not p-is-del
      then do:
          message
          vss-workfile vss-revision vss-description skip
          "Неверное значение параметра p-node-code и/или p-is-del" p-node-code p-is-del
          view-as alert-box ERROR.
          return.
      end.
     end.
     if p-mode = "prt-root":U then do:
      find first X_gds-prt no-lock where
                  X_gds-prt.prt-root = p-node-code
              no-error .
      if not available X_gds-prt
      and not p-is-del
      then do:
          message
          vss-workfile vss-revision vss-description skip
          "Неверное значение параметра p-node-code и/или p-is-del" p-node-code p-is-del
          view-as alert-box ERROR.
          return.
      end.
     end.
   end.
  else do:
      message vss-workfile vss-revision vss-description skip
      "Неверный вызов - p-mode=" p-mode
      view-as alert-box ERROR.
      return.
  end.
  v-rid-list = p-rid-list.
  RUN MyEnable.
  HIDE mark-num in frame {&frame-name} .
  run OpenBR in this-procedure ( input yes, input no, input '':U).
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
  ENABLE b-quit B-mark b-sel B-sch B-Help mark-num BR-c-gds-prt BR-changes
         v-full-name-old v-full-name-new
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
BR-c-gds-prt
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

&scop flt-open-open-query OPEN QUERY br-c-gds-prt FOR EACH X_c-gds-prt

&scop flt-open-dyn_open-query  FOR EACH X_c-gds-prt

&scop flt-open-open-query-tail

&scop flt-open-query-handle query br-c-gds-prt:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-waitfram yes

CASE p-mode:
    when "one":U then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории шкал товаров: вн № узла шкалы &1",
                                                       p-node-code)
        filter-point = filter-point0 + p-mode
        filter-label = filter-label0 + " Один узел шкалы"
        .
          { gbl/fltopend.i
            &where-cond = " X_c-gds-prt.node-code = p-node-code "
            &dyn_where-cond = " substitute('X_c-gds-prt.node-code = &1', p-node-code) "
            &use-ind = "  "
            &by = "  "
          }
    end.
    when "prt-root":U then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории шкал товаров: Шкала &1",
                                                       X_gds-prt.node-name)
        filter-point = filter-point0 + p-mode
        filter-label = filter-label0 + " Одна шкала"
        .
          { gbl/fltopend.i
            &where-cond = " X_c-gds-prt.prt-root = p-node-code "
            &dyn_where-cond = " substitute('X_c-gds-prt.prt-root = &1', p-node-code) "
            &use-ind = "  "
            &by = "  "
          }
    end.
END CASE.
apply "entry" to br-c-gds-prt in frame {&frame-name}.
reposition br-c-gds-prt to row 1 no-error.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED":U to br-c-gds-prt.
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
tbl = 'c-gds-prt'
join-tbl = 'X_c-gds-prt'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('action', 'Действие', 'hist-action',
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
                    , input (filter-point + {&delim-par} +
                             filter-label + {&delim-par} +
                      string(yes))
                    , input tbl
                    , input join-tbl
                    , input fld
                    , input lab
                    , input spr
                    , input dim).
    RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame
PROCEDURE proc-view-changes :
define variable v-description as character no-undo .
define variable v-is-created as logical no-undo .
define variable v-is-deleted as logical no-undo .
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-field-name as character no-undo .
define variable v-field-label as character no-undo .


define buffer current_gds-prt for ub.gds-prt  .
define buffer new_c-gds-prt for ub.c-gds-prt  .

for each temp-changes:
    delete temp-changes.
END.
if not available X_c-gds-prt then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
assign
v-full-name-old = "":U
v-full-name-new = "":U
.

if X_c-gds-prt.action = integer({&hn-create}) then do:
  assign
  v-is-created = yes
  v-chg-fields = get-all-fields ("gds-prt")
  .
end.
if X_c-gds-prt.action = integer({&hn-delete}) then do:
  assign
  v-is-deleted = yes
  v-chg-fields = get-all-fields ("gds-prt")
  .
end.


find first new_c-gds-prt no-lock where
            new_c-gds-prt.node-code = X_c-gds-prt.node-code
        AND new_c-gds-prt.chip-num > X_c-gds-prt.chip-num
        AND new_c-gds-prt.corr-user-db-num = X_c-gds-prt.corr-user-db-num
        no-error .
if not available new_c-gds-prt then do:
    find first current_gds-prt no-lock where
            current_gds-prt.node-code = X_c-gds-prt.node-code no-error .
    if not available current_gds-prt
    and not  v-is-deleted
    then do:
        return error.
    end.
    if available current_gds-prt then
    buffer-compare current_gds-prt to X_c-gds-prt
    case-sensitive
    save result in v-chg-fields.
end.
else do:
    buffer-compare new_c-gds-prt
    except chip-num corr-date corr-time corr-user-name corr-user-db-num
    to X_c-gds-prt
    case-sensitive
    save result in v-chg-fields.
end.


&scop fields-name-list "prt-num,prt-root,is-term,lvl-num,node-code,node-name,root,upper-code"
&scop fields-label-list "Порядковый № в группе признаков одного уровня,Вн № выш.узла корневого признака шкалы,~
Терминальная,Уровень,Вн №,Наименование,Корневой?,Вн № выш.узла"


if lookup("node-code", v-chg-fields ) > 0
or lookup("upper-code", v-chg-fields ) > 0 then do:
    if not v-is-created then do:
    assign
    v-full-name-old = X_c-gds-prt.f-name.
    end.
    if not v-is-deleted then do:
    assign
    v-full-name-old = if available current_gds-prt then current_gds-prt.f-name  else new_c-gds-prt.f-name.
    end.
end.


_ii:
do ii = 1 to num-entries(v-chg-fields):
  assign
  v-field-name = entry(ii, v-chg-fields)
  jj = lookup(v-field-name, {&fields-name-list}).
  if jj = 0 then next _ii.
  assign
  v-field-label = entry(jj, {&fields-label-list})
  .

  create temp-changes.
  assign
  temp-changes.f_name = v-field-name
  temp-changes.l_name = v-field-label
  temp-changes.v_old =  (if v-is-created
                          then "":U
                          else  string(buffer X_c-gds-prt:buffer-field(v-field-name):buffer-value))
  temp-changes.v_new = (if available new_c-gds-prt
                        then string(buffer new_c-gds-prt:buffer-field(v-field-name):buffer-value)
                        else (if v-is-deleted
                              then '':U
                              else string(buffer current_gds-prt:buffer-field(v-field-name):buffer-value))
                        )
  .
end.
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