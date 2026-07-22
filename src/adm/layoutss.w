&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_layout FOR ub.layout.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список раскладок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/26/08
Author: Bakhtadze Natalya
Creation date: 09/26/08

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns as character no-undo.
define input parameter p-list-mode as character no-undo .
/*{&all}  layout-type*/
define input parameter p-layout-type as character no-undo .
define input-output parameter p-rid-list as character no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список раскладок".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/mrk-strf.i }
{ gbl/getcntxt.i def }
{ gbl/key-rec.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/fltopend.i defproc }

DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable v-admin as logical no-undo .
DEFINE VARIABLE link-option AS CHARACTER NO-UNDO.
define variable v-rid-list as character no-undo .
DEFINE VARIABLE lkp-option AS CHARACTER NO-UNDO.
define variable sort-column-name as character no-undo .
define variable filter-point-label as character no-undo init "Список раскладок" .
define variable filter-point0 as character no-undo init "layoutss" .
define variable filter-point as character no-undo init "layoutss" .


&SCOPED-DEFINE layout-type-code X_layout.layout-type
&scop label-1 "Тип раскладки"
&scop label-2 "Статус"
&scoped-define status-code string(X_layout.sts)
&SCOPED-DEFINE layout-kind-code string(X_layout.is-default)

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-layout

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_layout

/* Definitions for BROWSE br-layout                                     */
&Scoped-define FIELDS-IN-QUERY-br-layout mark-string(recid(X_layout), v-rid-list) {&layout-type-name} X_layout.device-type {&layout-kind-name} {&status-int-name} X_layout.layout-name X_layout.layout-id
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-layout
&Scoped-define SELF-NAME br-layout
&Scoped-define QUERY-STRING-br-layout FOR EACH X_layout NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-layout OPEN QUERY {&SELF-NAME} FOR EACH X_layout NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-layout X_layout
&Scoped-define FIRST-TABLE-IN-QUERY-br-layout X_layout


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-copy b-chg b-del ~
b-lkp b-sch b-hist B-Help br-layout EDITOR-des mark-num
&Scoped-Define DISPLAYED-OBJECTS EDITOR-des mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
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

DEFINE BUTTON b-copy
     LABEL "&Копировать"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-hist
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 4 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1.

DEFINE VARIABLE EDITOR-des AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 97 BY 3 NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9 BY .67
     FGCOLOR 10  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-layout FOR
      X_layout SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-layout
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-layout Dialog-Frame _FREEFORM
  QUERY br-layout NO-LOCK DISPLAY
      mark-string(recid(X_layout), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
{&layout-type-name} COLUMN-LABEL {&label-1} FORMAT "X(255)" WIDTH 22
X_layout.device-type COLUMN-LABEL "Устройства" FORMAT "X(15)"
{&layout-kind-name} COLUMN-LABEL "Вид раскладки" FORMAT "X(13)"
{&status-int-name} COLUMn-label {&label-2} format "X(6)"
X_layout.layout-name COLUMN-LABEL "Название" FORMAT "X(255)" WIDTH 35
X_layout.layout-id COLUMN-LABEL "ID Раскладки" FORMAT "X(15)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 17.5 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 20 WIDGET-ID 12
     b-sel AT ROW 1 COL 24 WIDGET-ID 10
     b-add AT ROW 1 COL 34 WIDGET-ID 2
     b-copy AT ROW 1 COL 44 WIDGET-ID 18
     b-chg AT ROW 1 COL 54 WIDGET-ID 4
     b-del AT ROW 1 COL 64 WIDGET-ID 8
     b-lkp AT ROW 1 COL 74 WIDGET-ID 6
     b-sch AT ROW 1 COL 89 WIDGET-ID 16
     b-hist AT ROW 1 COL 92 WIDGET-ID 22
     B-Help AT ROW 1 COL 95
     br-layout AT ROW 2.33 COL 1.5 WIDGET-ID 100
     EDITOR-des AT ROW 19.88 COL 1.5 NO-LABEL WIDGET-ID 20
     mark-num AT ROW 1 COL 11 NO-LABEL WIDGET-ID 14
     SPACE(78.59) SKIP(21.21)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_layout B "?" ? ub layout
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-layout B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       EDITOR-des:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-layout
/* Query rebuild information for BROWSE br-layout
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_layout NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-layout */
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
 define variable v-rec as recid no-undo.
  run adm/layout-i.w ( input parparentproc
                       ,input {&add-def} + (if v-admin then ({&comma-char} + "admin") else '')
                       ,input '' /*p-layout-id*/
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
    RUN openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  define variable v-rec as recid no-undo.
  if not available X_layout then return no-apply.
  v-rec = recid(X_layout).
  if X_layout.is-default = integer({&layout-default})
  and not v-admin then do:
    &scop layout-kind-code    string(X_layout.is-default)
    message
    substitute("Нельзя редактировать &1", {&layout-kind-name})
    view-as alert-box error .
    undo, return no-apply .
  end.

  run adm/layout-i.w ( input parparentproc
                       ,input {&update} + (if v-admin then ( {&comma-char} + "admin") else '')
                       ,input X_layout.layout-id
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
     br-layout:refresh().
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-copy Dialog-Frame
ON CHOOSE OF b-copy IN FRAME Dialog-Frame /* Копировать */
DO:
    IF NOT AVAILABLE X_layout THEN DO:
     BELL.
     RETURN NO-APPLY.
    END.
    RUN proc-b-copy IN THIS-PROCEDURE NO-ERROR.
IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  define variable v-rec as recid no-undo.
  define variable glog as logical no-undo.
  if not available X_layout then return no-apply.
  v-rec = recid(X_layout).
  message
  "Вы уверены, что хотите удалить раскладку?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then return no-apply.
  run adm/layout30.p (
                       buffer X_layout
                          ) no-error.
 if error-status:error then return no-apply.
 run Openbr in this-procedure ( input yes, input no, input '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
ON CHOOSE OF b-hist IN FRAME Dialog-Frame /* Btn 1 */
DO:
define variable v-rid-list as character no-undo.
      run adm/clayouts.w (
                        input parparentproc
                       , "":U /*bttns*/
                       , "one":U
                       , X_layout.layout-id
                       , input-output v-rid-list
                    ) no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:

if not available X_layout then return no-apply.
run proc-b-lkp IN THIS-PROCEDURE ( INPUT {&table_layout}) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
    lkp-option = '':U.
    RETURN NO-APPLY.
END.
lkp-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable glog as logical no-undo .
  if available X_layout then do:
 { gbl/markstrn.i X_layout v-rid-list }
  glog = br-layout:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-layout:select-next-row ().
      apply "VALUE-CHANGED" to br-layout in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-layout in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  RUN proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available X_layout then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_layout ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-layout
&Scoped-define SELF-NAME br-layout
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-layout Dialog-Frame
ON VALUE-CHANGED OF br-layout IN FRAME Dialog-Frame
DO:
  if available X_layout then do:
    editor-des:screen-value = X_layout.des.
  end.
  else do:
      editor-des:screen-value = '' .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/brwrefre.i " v-doc-rec = recid(X_layout).  ~
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).  REPOSITION br-layout to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to br-layout. " }

{ gbl/app_help.i }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/setfltnm.i }


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  v-admin = lookup('admin', bttns) > 0.
  if p-list-mode = "layout-type"
  and lookup(p-layout-type, {&layout-type-list}) = 0 then do:
    message
    substitute("Неверное значение параметра p-layout-type = &1", p-layout-type)
    view-as alert-box error .
    undo main-block, return error .
  end.
  run Myenable in this-procedure .
  v-rid-list = p-rid-list.
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
  DISPLAY EDITOR-des mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel b-add b-copy b-chg b-del b-lkp b-sch b-hist B-Help
         br-layout EDITOR-des mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable v-h as handle no-undo .
define variable vh-layout-type-name as handle no-undo .
ASSIGN
v-h = br-layout:FIRST-COLUMN in frame {&frame-name}
.
DO while valid-handle(v-h) :
  if v-h:LABEL = {&label-1} then do:
    vh-layout-type-name = v-h.
    leave.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.

ASSIGN
X_layout.device-type:RESIZABLE IN BROWSE br-layout = YES
X_layout.layout-name:RESIZABLE IN BROWSE br-layout = YES
vh-layout-type-name:resizable = yes
.
ENABLE
b-quit
b-add when (lookup("b-add", bttns) > 0)
b-chg when (lookup("b-add", bttns) > 0)
b-del when (lookup("b-add", bttns) > 0)
b-copy when (lookup("b-add", bttns) > 0)
b-lkp
B-Help
b-mark when lookup("b-mark", bttns) > 0
b-sel when lookup("b-sel", bttns) > 0
b-sch
b-hist
br-layout
editor-des
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
if p-list-mode = "layout-type" then do:
  assign
  vh-layout-type-name:visible  = no.
end.
run Openbr in this-procedure ( input yes, input no, input '':U).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
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

&scop flt-open-open-query OPEN QUERY br-layout FOR EACH X_layout

&scop flt-open-dyn_open-query FOR EACH X_layout

&scop flt-open-query-handle QUERY br-layout:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_layout

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_layout

&scop flt-open-waitfram true

define variable l-open-query as logical   no-undo .

filter-point = filter-point0 + p-list-mode.
CASE p-list-mode :
  WHEN {&all}        THEN DO:
      assign
      filter-point-label = "Все раскладки"
      frame {&frame-name}:title = filter-point-label
      .
      if v-admin then do:
        OPEN QUERY br-layout
        FOR EACH X_layout NO-LOCK INDEXED-REPOSITION.
        { gbl/fltopend.i
            &where-cond = " true "
            &use-ind    = "  "
            &by         = "  " }

       end.
       else do:
        frame {&frame-name} :title = "Все раскладки".
        { gbl/fltopend.i
            &where-cond = " X_layout.layout-id < '_' "
            &dyn_where-cond = " substitute('X_layout.layout-id < &1_&1 and X_layout.is-default >= 0 ', ~{&double-quote~}) "
            &use-ind    = "  "
            &by         = "  " }

       end.
   END.
   when "layout-type" then do:
&scop layout-type-code p-layout-type
      ASSIGN
      filter-point-label = substitute("Раскладки типа: &1", {&layout-type-name}).
      frame {&frame-name}:title = filter-point-label
      .
        { gbl/fltopend.i
        &where-cond = " X_layout.layout-type = p-layout-type and X_layout.is-default >= 0 "
        &dyn_where-cond = " substitute('X_layout.layout-type = &1&2&1 and X_layout.is-default >= 0', ~{&double-quote~}, p-layout-type)"
        &use-ind    = " "
        &by         = " " }

  END.
END CASE.
if not p-open-query then
REPOSITION br-layout to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-layout:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "ENTRY" TO br-layout.
APPLY "VALUE-CHANGED" TO br-layout in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-copy Dialog-Frame
PROCEDURE proc-b-copy :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
 IF NOT v-admin
 AND X_layout.is-default = INTEGER({&layout-mandatory}) THEN DO:
    MESSAGE
    "Нельзя скопировать обязательную раскладку"
     VIEW-AS ALERT-BOX error.
    UNDO, RETURN ERROR.
 END.
 MESSAGE
 SUBSTITUTE("Вы действительно хотите скопировать новую раскладку с раскладки &1?", X_layout.layout-id)
 VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
 IF NOT glog THEN UNDO, RETURN ERROR.
 define variable v-rec as recid no-undo.
  run adm/layout-i.w ( input parparentproc
                       ,input {&add-copy} + (if v-admin then ({&comma-char} + "admin") else '')
                       ,input X_layout.layout-id /*p-layout-id*/
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
    RUN openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lkp Dialog-Frame
PROCEDURE proc-b-lkp :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
define variable v-rec as recid no-undo.
CASE p-option:
  WHEN {&TABLE_layout} THEN DO:
      run adm/layout-i.w ( input parparentproc
                           ,input {&lookup} +  (if v-admin then ({&comma-char} + "admin") else '')
                           ,input X_layout.layout-id
                           ,input-output v-rec) no-error.

  END.
END CASE.
IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
assign
  tbl = 'layout'
  join-tbl = 'X_layout'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('layout-id', 'ID раскладки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('layout-name', 'Название раскладки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('device-type', 'Для устройства', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cr-db-num', 'Создана в БД', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.




Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                   , INPUT filter-point + {&delim-par} + filter-point-label
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  RUN OpenBr IN THIS-PROCEDURE (INPUT yes
                               ,INPUT no
                               ,INPUT '':U).
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
