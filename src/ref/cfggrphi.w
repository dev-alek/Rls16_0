&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_cli FOR ub.clients.
DEFINE BUFFER for-c-fbr-gds-grp-hist FOR ub.c-fbr-gds-grp-hist.
DEFINE BUFFER X_cfgg-hist FOR ub.c-fbr-gds-grp-hist.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник истории групп блюд

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
/*{&all} или {&g___object} или "one":U или "fbr-gds-grp-attr" */
DEFINE INPUT PARAMETER p-obj-type  like ub.c-fbr-gds-grp-hist.obj-type  no-undo.
DEFINE INPUT PARAMETER p-obj-code  like ub.c-fbr-gds-grp-hist.obj-code  no-undo.
DEFINE INPUT PARAMETER p-node-code like ub.c-fbr-gds-grp-hist.node-code no-undo.
DEFINE INPUT PARAMETER p-attr-code like ub.c-fbr-gds-grp-hist.attr-code no-undo.
define input parameter p-is-del    as logical no-undo .
define input parameter p-subject   like ub.c-fbr-gds-grp-hist.subject no-undo .
DEFINE OUTPUT PARAMETER  p-rid-list    as  char no-undo . /* список recid'ов выбранных аписей */


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник истории групп блюд" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ ref/fgrpattr.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
define variable v-rid-list as character no-undo .
define variable log-res as log no-undo.
define variable rr as recid no-undo.
define variable jj as integer no-undo .
define variable str as char no-undo.
define variable vartbl-name as char no-undo.
define variable varact      as char no-undo.
define variable filter-point0 as character no-undo init "cfggrphi":U .
define variable filter-point as character no-undo init "cfggrphi":U .
define variable filter-label as character no-undo init "История групп блюд":U .
define variable filter-label0 as character no-undo init "История групп блюд":U .
define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
define NEW SHARED buffer c-fbr-gds-grp-hist for ub.c-fbr-gds-grp-hist .
define buffer X_fbr-gds-grp for ub.fbr-gds-grp.
define buffer X_fbr-gds-grp-attr for ub.fbr-gds-grp-attr.
define buffer x_clients-obj for ub.clients.
{ ref/tmpchgs.i "NEW SHARED" }

&SCOPED-DEFINE hn-fbr-gds-grp-hist-code X_cfgg-hist.subject

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-c-fgg-hist

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_cfgg-hist temp-changes

/* Definitions for BROWSE br-c-fgg-hist                                 */
&Scoped-define FIELDS-IN-QUERY-br-c-fgg-hist mark-string( recid(X_cfgg-hist), v-rid-list ) usrfulnf(X_cfgg-hist.corr-user-name) X_cfgg-hist.corr-date X_cfgg-hist.corr-user-db-num X_cfgg-hist.node-code {&hn-fbr-gds-grp-hist-name} get-action(X_cfgg-hist.action) string(X_cfgg-hist.corr-time, "HH:MM") if X_cfgg-hist.subject <> {&table_fbr-gds-grp} and X_cfgg-hist.obj-code > 0 then (X_cfgg-hist.obj-type + string(X_cfgg-hist.obj-code)) else '':U
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-c-fgg-hist
&Scoped-define SELF-NAME br-c-fgg-hist
&Scoped-define QUERY-STRING-br-c-fgg-hist FOR EACH X_cfgg-hist NO-LOCK
&Scoped-define OPEN-QUERY-br-c-fgg-hist OPEN QUERY {&SELF-NAME} FOR EACH X_cfgg-hist NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-c-fgg-hist X_cfgg-hist
&Scoped-define FIRST-TABLE-IN-QUERY-br-c-fgg-hist X_cfgg-hist


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
    ~{&OPEN-QUERY-br-c-fgg-hist}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-sch B-Help mark-num ~
br-c-fgg-hist BR-changes v-full-name-old v-full-name-new
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
DEFINE QUERY br-c-fgg-hist FOR
      X_cfgg-hist SCROLLING.

DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-c-fgg-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-c-fgg-hist Dialog-Frame _FREEFORM
  QUERY br-c-fgg-hist DISPLAY
      mark-string( recid(X_cfgg-hist), v-rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
      usrfulnf(X_cfgg-hist.corr-user-name) FORMAT "X(18)":U
      X_cfgg-hist.corr-date COLUMN-LABEL "Дата корр." FORMAT "99/99/9999":U
      X_cfgg-hist.corr-user-db-num FORMAT ">>>>9":U
      X_cfgg-hist.node-code FORMAT "->,>>>,>>9":U
      {&hn-fbr-gds-grp-hist-name} COLUMN-LABEL "Предмет изменений" FORMAT "X(32)":U
      get-action(X_cfgg-hist.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
      string(X_cfgg-hist.corr-time, "HH:MM") COLUMN-LABEL "Время!корр" FORMAT "X(5)":U
            WIDTH 6
      if X_cfgg-hist.subject <> {&table_fbr-gds-grp} and X_cfgg-hist.obj-code > 0 then
(X_cfgg-hist.obj-type + string(X_cfgg-hist.obj-code)) else '':U COLUMN-LABEL "Объект" FORMAT "X(9)":U
            WIDTH 10
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
     br-c-fgg-hist AT ROW 3 COL 1
     BR-changes AT ROW 14.5 COL 1
     v-full-name-old AT ROW 20 COL 2
     v-full-name-new AT ROW 21 COL 1
     SPACE(0.24) SKIP(0.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Справочник истории групп блюд"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_cli B "?" ? ub clients
      TABLE: for-c-fbr-gds-grp-hist B "?" ? ub c-fbr-gds-grp-hist
      TABLE: X_cfgg-hist B "?" ? ub c-fbr-gds-grp-hist
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-c-fgg-hist mark-num Dialog-Frame */
/* BROWSE-TAB BR-changes br-c-fgg-hist Dialog-Frame */
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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-c-fgg-hist
/* Query rebuild information for BROWSE br-c-fgg-hist
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_cfgg-hist NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-c-fgg-hist */
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
ON GO OF FRAME Dialog-Frame /* Справочник истории групп блюд */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Справочник истории групп блюд */
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
if not available X_cfgg-hist then return no-apply.
  { gbl/markstrn.i X_cfgg-hist v-rid-list }
  g#log = br-c-fgg-hist :refresh( )  in frame {&frame-name}.
  if not can-do ("MOUSE-SELECT-DBLCLICK,Return", last-event:function) then do:
          g#log = br-c-fgg-hist:select-next-row () in frame {&frame-name}.
          apply "value-changed" to br-c-fgg-hist in frame {&frame-name}.
  end.
  if num-entries (v-rid-list) = 0 then
      hide mark-num in frame {&frame-name}.
  else
  disp num-entries (v-rid-list) @ mark-num
  with frame {&frame-name}.
  apply "entry" to br-c-fgg-hist in frame {&frame-name}.

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
    if ( available X_cfgg-hist ) AND ( v-rid-list = "" ) then
        v-rid-list = string( recid( X_cfgg-hist ) ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-c-fgg-hist
&Scoped-define SELF-NAME br-c-fgg-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-c-fgg-hist Dialog-Frame
ON RETURN OF br-c-fgg-hist IN FRAME Dialog-Frame
DO:
      apply "DEFAULT-ACTION":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-c-fgg-hist Dialog-Frame
ON VALUE-CHANGED OF br-c-fgg-hist IN FRAME Dialog-Frame
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
{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-c-fgg-hist" }
{ gbl/brwrefre.i "v-doc-rec = recid(X_cfgg-hist). run openbr in this-procedure. reposition br-c-fgg-hist to recid v-doc-rec no-error. " }
{ gbl/brwrepos.i
&line-num=5
}
{ gbl/setfltnm.i }

{ gbl/srt-clmd.i
  &browse-name    = "br-c-fgg-hist"
  &frame-name     = "{&frame-name}"
  &table-name     = "X_cfgg-hist"
  &sort-clmn_1    = "X_cfgg-hist.corr-date"
  &sort-clmn_2    = "X_cfgg-hist.corr-user-db-num"
  &open-query     = "run OpenBr in this-procedure ."
  &open-query-otherwise = "run OpenBr in this-procedure ."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "no"
  &mv-brw-default = "no"
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   if LOOKUP(p-mode, (
                      {&all}  + {&delim-par} +
                      {&g___object}  + {&delim-par} +
                      "one":U  + {&delim-par} +
                     "fbr-gds-grp-attr":U),
                     {&delim-par}
                     ) > 0
   THEN DO:
     find first X_fbr-gds-grp no-lock where
                X_fbr-gds-grp.obj-type  = p-obj-type
            AND X_fbr-gds-grp.obj-code = p-obj-code
            AND X_fbr-gds-grp.node-code = p-node-code
            no-error .
     if not available X_fbr-gds-grp
     and not p-is-del
     then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-node-code и/или p-is-del" p-node-code p-is-del
        view-as alert-box ERROR.
        return.
     end.

   if LOOKUP(p-mode,
                     {&g___object} ) > 0
   THEN DO:
    find first X_clients-obj no-lock where
              X_clients-obj.obj-type = p-obj-type
          AND X_clients-obj.obj-code = p-obj-code no-error .
    if not available X_clients-obj then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров p-obj-type и/или p-obj-code" p-obj-type p-obj-code
        view-as alert-box ERROR.
        return.
    end.
   end.
   if lookup(p-mode, "fbr-gds-grp-attr") > 0 then do:
      if lookup(p-attr-code, {&fbr-gds-grp-attr-list}) = 0 then do:
          message
          vss-workfile vss-revision vss-description skip
          "Неверное значение параметра p-attr-code" p-attr-code
          view-as alert-box ERROR.
          return.
      end.
   end.
  END. /*ша дщллгз - все моды*/
  else do:
      message vss-workfile vss-revision vss-description skip
      "Неверный вызов - p-mode=" p-mode
      view-as alert-box ERROR.
      return.
  end.
  v-rid-list = p-rid-list.
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
  ENABLE b-quit B-mark b-sel B-sch B-Help mark-num br-c-fgg-hist BR-changes
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
br-c-fgg-hist
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

&scop flt-open-open-query OPEN QUERY br-c-fgg-hist FOR EACH X_cfgg-hist

&scop flt-open-dyn_open-query  FOR EACH X_cfgg-hist

&scop flt-open-query-handle query br-c-fgg-hist:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-waitfram yes

CASE p-mode:
    when {&all} then do:
        ASSIGN frame {&frame-name}:TITLE = "Справочник истории групп блюд"
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " TRUE "
            &use-ind = "  "
            &by = "  "
          }
    end.
    when {&g___object} then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории групп блюд: Объект &1&2",
                                                       p-obj-type, p-obj-code)
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1: Объект", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_cfgg-hist.obj-type = p-obj-type and X_cfgg-hist.obj-code  = p-obj-code "
            &dyn_where-cond = " substitute('X_cfgg-hist.obj-type = &1&2&1 and X_cfgg-hist.obj-code  = &3', ~{&double-quote~}, p-obj-type, p-obj-code)  "
            &use-ind = "  "
            &by = "  "
          }
    end.
    when "one":U then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории групп блюд: Объект &1&2 Вн. № группы &3",
                                                       p-obj-type, p-obj-code, p-node-code)

        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1: Одна группа", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_cfgg-hist.obj-type = p-obj-type and X_cfgg-hist.obj-code  = p-obj-code and  ~
                            X_cfgg-hist.node-code = p-node-code "
            &dyn_where-cond = " substitute('X_cfgg-hist.obj-type = &1&2&1 and X_cfgg-hist.obj-code  = &3 and ~
                               X_cfgg-hist.node-code = &4', ~{&double-quote~}, p-obj-type, p-obj-code, p-node-code)  "
            &use-ind = "  "
            &by = "  "
          }
    end.
    when "fbr-gds-grp-attr":U then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории групп блюд: Объект &1&2 Вн. № группы &3 атрибут &4",
                                                       p-obj-type, p-obj-code, p-node-code, p-attr-code)

        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1: Атрибут группы", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_cfgg-hist.obj-type = p-obj-type and X_cfgg-hist.obj-code  = p-obj-code and  ~
                            X_cfgg-hist.node-code = p-node-code and X_cfgg-hist.subject = ~{&table_fbr-gds-grp-attr~} "
            &dyn_where-cond = " substitute('X_cfgg-hist.obj-type = &1&2&1 and X_cfgg-hist.obj-code  = &3 and ~
                               X_cfgg-hist.node-code = &4 and X_cfgg-hist.subject = &1&5&1' ~
                               , ~{&double-quote~}, p-obj-type, p-obj-code, p-node-code, ~{&table_fbr-gds-grp-attr~})  "

            &use-ind = "  "
            &by = "  "
          }
    end.
END CASE.
apply "entry" to br-c-fgg-hist in frame {&frame-name}.
reposition br-c-fgg-hist to row 1 no-error.
run waitfram-hide in this-procedure .
if avail X_cfgg-hist then
APPLY "VALUE-CHANGED":U to br-c-fgg-hist.
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
tbl = 'c-fbr-gds-grp-hist'
join-tbl = 'X_cfgg-hist'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('subject', 'Предмет изменений', 'fbr-gds-grp-hist-subject',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('action', 'Действие', 'hist-action',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('attr-code', 'Код атрибута', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
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
                      ,input (filter-point + {&delim-par} + filter-label + {&delim-par} + 'yes')
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
if not available X_cfgg-hist then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
assign
v-full-name-old = "":U
v-full-name-new = "":U
.
run ref/cfggrhiv.p (
                   input X_cfgg-hist.obj-type
                  ,input X_cfgg-hist.obj-code
                  ,input X_cfgg-hist.node-code
                  ,input X_cfgg-hist.corr-user-db-num
                  ,input X_cfgg-hist.chip-num
                  ,input X_cfgg-hist.subject
                  ,input X_cfgg-hist.action
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