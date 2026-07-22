&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE find_c-layout NO-UNDO LIKE ub.c-layout.
DEFINE BUFFER X_c-layout FOR ub.c-layout.
DEFINE BUFFER X_layout FOR ub.layout.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории раскладок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/25/08
Author: Bakhtadze Natalya
Creation date: 10/25/08

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/
define input parameter p-mode  as char   no-undo .
define input parameter p-layout-id like ub.layout.layout-id no-undo .

/*типы документов в выборке*/
define input-output param p-rid-list    as  char no-undo . /* список recid'ов выбранных c-layout */

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список истории раскладок":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/flt-def.i }
{ gbl/fltfield.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ ref/tmpchgs.i }
{ gbl/waitfram.i }
{ gbl/cur-time.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
{ gbl/key-rec.i }
define variable filter-label as character no-undo init "Список истории раскладок" .
define variable filter-label0 as character no-undo init "Список истории раскладок" .
define variable filter-point as character no-undo init "clayouts" .
define variable filter-point0 as character no-undo init "clayouts" .

define variable sort-column-name as character no-undo .
define variable print-option as character no-undo.

define variable glog as logical no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo .

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
&Scoped-define INTERNAL-TABLES temp-changes X_c-layout

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE BR-docs                                       */
&Scoped-define FIELDS-IN-QUERY-BR-docs mark-string(RECID( X_c-layout), v-rid-list) X_c-layout.corr-date string(X_c-layout.corr-time, "HH:MM") X_c-layout.corr-user-db-num usrfulnf(X_c-layout.corr-user-name) get-action(X_c-layout.action) X_c-layout.layout-id
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-docs X_c-layout.layout-id
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-docs X_c-layout
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-docs X_c-layout
&Scoped-define SELF-NAME BR-docs
&Scoped-define QUERY-STRING-BR-docs FOR EACH X_c-layout NO-LOCK
&Scoped-define OPEN-QUERY-BR-docs OPEN QUERY {&SELF-NAME} FOR EACH X_c-layout NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-docs X_c-layout
&Scoped-define FIRST-TABLE-IN-QUERY-BR-docs X_c-layout


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-lkp B-sch B-Help ~
BR-docs BR-changes mark-num
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-is-default-name Dialog-Frame
FUNCTION get-is-default-name RETURNS CHARACTER
  ( p-is-default as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-is-mandatory-name Dialog-Frame
FUNCTION get-is-mandatory-name RETURNS CHARACTER
  ( p-is-mandatory as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-layout-type-name Dialog-Frame
FUNCTION get-layout-type-name RETURNS CHARACTER
  ( input p-layout-type as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-status-name Dialog-Frame
FUNCTION get-status-name RETURNS CHARACTER
  ( input p-sts as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

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
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.

DEFINE QUERY BR-docs FOR X_c-layout SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(255)" WIDTH 50
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8.5.

DEFINE BROWSE BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-docs Dialog-Frame _FREEFORM
  QUERY BR-docs DISPLAY
      mark-string(RECID( X_c-layout), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_c-layout.corr-date COLUMN-LABEL "Дата корр" FORMAT "99/99/9999":U
      string(X_c-layout.corr-time, "HH:MM")
      X_c-layout.corr-user-db-num FORMAT ">>>>9":U
      usrfulnf(X_c-layout.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
      get-action(X_c-layout.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
      X_c-layout.layout-id COLUMN-LABEL "ID" FORMAT "X(15)":U
  ENABLE
      X_c-layout.layout-id
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.03.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-lkp AT ROW 1 COL 41
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     BR-docs AT ROW 2.67 COL 1
     BR-changes AT ROW 12 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(78.50) SKIP(18.67)
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
      TABLE: find_c-layout T "?" NO-UNDO ub c-layout
      TABLE: X_c-layout B "?" ? ub c-layout
      TABLE: X_layout B "?" ? ub layout
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-docs B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes BR-docs Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-docs
/* Query rebuild information for BROWSE BR-docs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-layout NO-LOCK.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY BR-docs FOR X_c-layout SCROLLING.
     _END_FREEFORM_DEFINE
     _Query            is NOT OPENED
*/  /* BROWSE BR-docs */
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


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp Dialog-Frame
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  run proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  if available X_c-layout then do:
    { gbl/markstrn.i X_c-layout v-rid-list }
    glog = br-docs:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        glog = br-docs:select-next-row ().
        apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-docs in frame {&frame-name}.

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
  if ( available X_c-layout ) AND
  ( v-rid-list = ""
  or
  b-mark:sensitive = no
  ) then
    v-rid-list = string( recid( X_c-layout ) ) .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define BROWSE-NAME BR-docs
&Scoped-define SELF-NAME BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON DELETE-CHARACTER OF BR-docs IN FRAME Dialog-Frame
DO:
  if b-mark:sensitive in frame {&frame-name} then
  APPLY "CHOOSE" to b-mark.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON INSERT-MODE OF BR-docs IN FRAME Dialog-Frame
DO:
  if b-mark:sensitive in frame {&frame-name} then
  APPLY "CHOOSE" to b-mark.
    else do:
      if b-sel:sensitive in frame {&frame-name} then
      APPLY "CHOOSE" to b-sel.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON RETURN OF BR-docs IN FRAME Dialog-Frame
OR MOUSE-SELECT-DBLCLICK OF {&self-name} IN FRAME {&frame-name}
DO:
if b-sel:sensitive in frame {&frame-name} then dO:
    if b-mark:sensitive then do:
        apply "choose" to b-mark in frame {&frame-name}.
    end.
    else do:
        apply "choose" to b-sel in frame {&frame-name}.
    end.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON VALUE-CHANGED OF BR-docs IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure .

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
{ gbl/app_help.i &disable_diasize_init=true &browse-name="BR-docs" }

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel  }
{ gbl/setfltnm.i }

{ gbl/brwrefre.i "v-doc-rec = recid(X_c-layout). run OpenBr in this-procedure ( input yes, input no, input '':U). reposition br-docs to recid v-doc-rec no-error. v-doc-rec = ?. ~
              apply 'value-changed' to br-docs. " }

{ gbl/srt-clmd.i
&browse-name = "br-docs"
&frame-name  = {&frame-name}
&table-name = "X_c-layout"
&ext-col = 17
&start-column  = 7
&sort-column-name     = "sort-column-name"
&sort-clmn_2   = "X_c-layout.corr-date"
&sort-clmn_9   = "X_c-layout.layout-id"
&open-query = "run OpenBr  in this-procedure ( input yes, input no, input '')."
&open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '')."
&re-move-clmn = "no"
&mv-brw-default = "yes"
}
{ gbl/mv-clmn.i
  &browse-name = "br-docs"
  &frame-name = "{&frame-name}"
  &ext-col = 17
  &start-column = 7
}



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

{ gbl/getcntxt.i get }

if p-mode <> "one":U
and p-mode <> {&deletion}
and p-mode <> {&add-def}
then do:
  message vss-workfile vss-revision vss-description skip
  "Неверное значение параметра вызова p-mode" p-mode
  view-as alert-box ERROR.
  return.
end.
  if p-mode = "one":U then do:
    FIND FIRST X_layout No-LOCK where
                X_layout.layout-id = p-layout-id No-ERROR.
    if not avail X_layout then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-layout-id" p-layout-id
      view-as alert-box error .
      return error.
    end.
  end.
  v-rid-list = p-rid-list.
  if v-rid-list <> "" then do:
      FIND FIRST find_c-layout No-LOCK where
                 recid(find_c-layout) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_c-layout then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова v-rid-list" v-rid-list
        view-as alert-box error .
        return error.
      end.
      v-doc-rec = integer(entry(1, v-rid-list)).
  end.
  run MyEnable in this-procedure .
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  REPOSITION br-docs to row 1 No-ERROR.
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
  ENABLE b-quit B-mark b-sel B-lkp B-sch B-Help BR-docs BR-changes mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-line-changes-current Dialog-Frame
PROCEDURE get-line-changes-current :
define input parameter p-corr-user-db-num as integer   no-undo .
define input parameter p-chip-num like ub.c-layout.chip-num no-undo .

define variable v-chg-fields as character no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-field-name as character no-undo .
define variable v-field-label as character no-undo .
define variable v-field-function as character no-undo .
define variable v-real-field-name as character no-undo .
define variable v-field-list as character no-undo.
define variable v-value-list as character no-undo.
define variable v-mode-id as character no-undo.
define variable v-widget-id as character no-undo.
define variable fields-name-list as character no-undo .
define variable fields-label-list as character no-undo .
define variable fields-function-list as character no-undo .
define variable v-type as character no-undo .


define buffer buf_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_layout-attr for ub.layout-attr.
define buffer buf_c-layout-elem-rule for ub.c-layout-elem-rule.
define buffer buf_c-rule-call-param for ub.c-rule-call-param.
for each buf_c-layout-elem-rule no-lock where
         buf_c-layout-elem-rule.layout-id = p-layout-id
     AND buf_c-layout-elem-rule.corr-user-db-num = p-corr-user-db-num
     AND buf_c-layout-elem-rule.chip-num = p-chip-num:
  find first buf_layout-elem-rule  no-lock where
            buf_layout-elem-rule.layout-id = buf_c-layout-elem-rule.layout-id
        and buf_layout-elem-rule.mode-id = buf_c-layout-elem-rule.mode-id
        and buf_layout-elem-rule.widget-id = buf_c-layout-elem-rule.widget-id no-error.
&scop fields-name-list  "mode-id,widget-id,elem-label,elem-tooltip,image-id-down,image-id-insen,image-id-up,is-mandatory,rule_id,sts"

&scop fields-label-list "Режим,Элемент,Лейбл элемента,Тултип элемента,Изображение DOWN,Изображение INSEN,Изображение UP,Обяз,Функция,Статус"

&scop fields-function-list ",,,,,,,get-is-mandatory-name,,get-status-name"


  if available buf_layout-elem-rule then do:
    buffer-compare
    buf_layout-elem-rule to buf_c-layout-elem-rule
    case-sensitive
    save result in v-chg-fields.
  end.
  else do:
   v-chg-fields = {&fields-name-list}.
  end.

  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, {&fields-name-list}).
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, {&fields-label-list})
    v-field-function = entry(jj, {&fields-function-list})
    v-real-field-name = entry(1, v-field-name, ':')
    .
    create temp-changes.
    assign
    temp-changes.f_name = substitute("layout-elem-rule&1&2&1&3&4"
                                     ,{&delim-par}
                                     ,buf_c-layout-elem-rule.mode-id
                                     ,buf_c-layout-elem-rule.widget-id
                                     ,v-field-name)
    temp-changes.l_name = substitute("&4Элемент &1 в режиме &2: &3"
                                     ,buf_c-layout-elem-rule.widget-id
                                     ,buf_c-layout-elem-rule.mode-id
                                     ,v-field-label
                                     ,(if buf_c-layout-elem-rule.action = integer({&hn-create})
                                       then "+"
                                       else (if buf_c-layout-elem-rule.action = integer({&hn-delete})
                                             then "-"
                                             else {&tilda-char})
                                       )
                                      )
    temp-changes.v_old = string(buffer buf_c-layout-elem-rule:buffer-field(v-real-field-name):buffer-value)
    temp-changes.v_new = (if available buf_layout-elem-rule
                          then string(buffer buf_layout-elem-rule:buffer-field(v-real-field-name):buffer-value)
                          else '')
    .
    if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.
    if buf_c-layout-elem-rule.action = integer({&hn-create}) then do:
      assign
      temp-changes.v_old = ''
      .
    end.
    if buf_c-layout-elem-rule.action = integer({&hn-delete}) then do:
      assign
      temp-changes.v_new = ''
      .
    end.

  end.
end.
for each buf_c-rule-call-param no-lock where
          buf_c-rule-call-param.call_id begins ({&table_layout-elem-rule} + {&delim-key} + p-layout-id)
      AND buf_c-rule-call-param.corr-user-db-num = p-corr-user-db-num
     AND buf_c-rule-call-param.chip-num = p-chip-num :
  find first buf_rule-call-param no-lock where
            buf_rule-call-param.call_id = buf_c-rule-call-param.call_id
      and buf_rule-call-param.codex_id = buf_c-rule-call-param.codex_id
      and buf_rule-call-param.ruleset_id = buf_c-rule-call-param.ruleset_id
      and buf_rule-call-param.order_id = buf_c-rule-call-param.order_id
      and buf_rule-call-param.param-name = buf_c-rule-call-param.param-name
      and buf_rule-call-param.p-index = buf_c-rule-call-param.p-index no-error.

&scop fields-name-list "param-name,param-data-type,param-label,rule_id"

&scop fields-label-list "Имя параметра,Тип данных,Лейбл,№ правила"

&scop fields-function-list ",,,"

  assign
  fields-name-list  = {&fields-name-list}
  fields-label-list  = {&fields-label-list}
  fields-function-list  = {&fields-function-list}
  .
  if buf_c-rule-call-param.action = integer({&hn-create}) then do:
    assign
    v-type = (if available buf_rule-call-param
              then buf_rule-call-param.param-data-type
              else '').
  end.
  else do:
    assign
    v-type = buf_c-rule-call-param.param-data-type.
  end.
  if v-type = {&abl-datatype-character} then do:
    assign
    fields-name-list = fields-name-list + {&comma-char} + "param-value-character"
    fields-label-list = fields-label-list + {&comma-char} + "Знач.(строковое)"
    fields-function-list = fields-function-list + {&comma-char}
    .
  end.
  if v-type = {&abl-datatype-date} then do:
    assign
    fields-name-list = fields-name-list + {&comma-char} + "param-value-date"
    fields-label-list = fields-label-list + {&comma-char} + "Знач.(дата)"
    fields-function-list = fields-function-list + {&comma-char}
    .
  end.
  if v-type = {&abl-datatype-decimal} then do:
    assign
    fields-name-list = fields-name-list + {&comma-char} + "param-value-decimal"
    fields-label-list = fields-label-list + {&comma-char} + "Знач.(десятичн.)"
    fields-function-list = fields-function-list + {&comma-char}
    .
  end.
  if v-type = {&abl-datatype-integer} then do:
    assign
    fields-name-list = fields-name-list + {&comma-char} + "param-value-integer"
    fields-label-list = fields-label-list + {&comma-char} + "Знач.(целое)"
    fields-function-list = fields-function-list + {&comma-char}
    .
  end.
  if v-type = {&abl-datatype-logical} then do:
    assign
    fields-name-list = fields-name-list + {&comma-char} + "param-value-logical"
    fields-label-list = fields-label-list + {&comma-char} + "Знач.(логич.)"
    fields-function-list = fields-function-list + {&comma-char}
    .
  end.


  if available buf_rule-call-param then do:
    buffer-compare
    buf_rule-call-param
    to buf_c-rule-call-param
    case-sensitive
    save result in v-chg-fields.
  end.
  else do:
    v-chg-fields = {&fields-name-list}.
  end.

  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, fields-name-list).
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, fields-label-list)
    v-field-function = entry(jj, fields-function-list)
    v-real-field-name = entry(1, v-field-name, ':')
    .
    run gen-key-fv in this-procedure ( input buf_c-rule-call-param.call_id
                                       ,output v-field-list
                                       ,output v-value-list) no-error.
    assign
    v-widget-id =  entry(lookup("widget-id", v-field-list, {&delim-key}), v-value-list, {&delim-key})
    v-mode-id = entry(lookup("mode-id", v-field-list, {&delim-key}), v-value-list, {&delim-key})
    .

    create temp-changes.
    assign
    temp-changes.f_name = substitute("rule-call-param &1&2&1&3&1&4":U
                                     ,{&delim-par}
                                     ,buf_c-rule-call-param.call_id
                                     ,v-field-name
                                     ,buf_c-rule-call-param.param-name)
    temp-changes.l_name = substitute("&6Пар-р &1 функции &2 эл.&3 режим &4: &5"
                                      ,buf_c-rule-call-param.param-name
                                      ,(if buf_c-rule-call-param.rule_id > 0 then string(buf_c-rule-call-param.rule_id) else '')
                                      ,v-widget-id
                                      ,v-mode-id
                                      ,v-field-label
                                     ,(if buf_c-rule-call-param.action = integer({&hn-create})
                                       then "+"
                                       else (if buf_c-rule-call-param.action = integer({&hn-delete})
                                             then "-"
                                             else {&tilda-char})
                                       )
                                      )
    temp-changes.v_old = string(buffer buf_c-rule-call-param:buffer-field(v-real-field-name):buffer-value)
    temp-changes.v_new = (if available buf_rule-call-param
                         then string(buffer buf_rule-call-param:buffer-field(v-real-field-name):buffer-value)
                         else '')
    .
    if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.
    if buf_c-rule-call-param.action = integer({&hn-create}) then do:
      assign
      temp-changes.v_old = ''
      .
    end.
    if buf_c-rule-call-param.action = integer({&hn-delete}) then do:
      assign
      temp-changes.v_new = ''
      .
    end.
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-line-changes-hist Dialog-Frame
PROCEDURE get-line-changes-hist :
define input parameter p-layout-id like ub.c-layout.layout-id no-undo .
define input parameter p-corr-user-db-num as integer   no-undo .
define input parameter p-chip-num like ub.c-layout.chip-num no-undo.
define input parameter p-new-corr-user-db-num as integer   no-undo .
define input parameter p-new-chip-num like ub.c-layout.chip-num no-undo.

define variable v-chg-fields as character no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-field-name as character no-undo .
define variable v-field-label as character no-undo .
define variable v-field-function as character no-undo .
define variable v-real-field-name as character no-undo .
define variable v-field-list as character no-undo.
define variable v-value-list as character no-undo.
define variable v-mode-id as character no-undo.
define variable v-widget-id as character no-undo.
define variable fields-name-list as character no-undo .
define variable fields-label-list as character no-undo .
define variable fields-function-list as character no-undo .
define variable v-type as character no-undo .


define buffer new_c-layout-elem-rule for ub.c-layout-elem-rule.
define buffer new_c-rule-call-param for ub.c-rule-call-param.
define buffer buf_c-layout-elem-rule for ub.c-layout-elem-rule.
define buffer buf_c-rule-call-param for ub.c-rule-call-param.
for each  buf_c-layout-elem-rule no-lock where
         buf_c-layout-elem-rule.layout-id = p-layout-id
     AND buf_c-layout-elem-rule.corr-user-db-num = p-corr-user-db-num
     AND buf_c-layout-elem-rule.chip-num = p-chip-num
            :
  find first new_c-layout-elem-rule no-lock where
            new_c-layout-elem-rule.layout-id = p-layout-id
        AND new_c-layout-elem-rule.chip-num = p-new-chip-num
        AND new_c-layout-elem-rule.corr-user-db-num = p-new-corr-user-db-num
     AND new_c-layout-elem-rule.mode-id = buf_c-layout-elem-rule.mode-id
     AND new_c-layout-elem-rule.widget-id = buf_c-layout-elem-rule.widget-id no-error.

&scop fields-name-list  "mode-id,widget-id,elem-label,elem-tooltip,image-id-down,image-id-insen,image-id-up,is-mandatory,rule_id,sts"

&scop fields-label-list "Режим,Элемент,Лейбл элемента,Тултип элемента,Изображение DOWN,Изображение INSEN,Изображение UP,Обяз,Функция,Статус"

&scop fields-function-list ",,,,,,,get-is-mandatory-name,,get-status-name"


  if available new_c-layout-elem-rule then do:
    buffer-compare
    new_c-layout-elem-rule to buf_c-layout-elem-rule
    case-sensitive
    save result in v-chg-fields.
  end.
  else do:
     v-chg-fields = {&fields-name-list}.
  end.

  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, {&fields-name-list}).
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, {&fields-label-list})
    v-field-function = entry(jj, {&fields-function-list})
    v-real-field-name = entry(1, v-field-name, ":")
    .

    create temp-changes.
    assign
    temp-changes.f_name = substitute("layout-elem-rule&1&2&1&3&1&4"
                                      ,{&delim-par}
                                      ,buf_c-layout-elem-rule.mode-id
                                      ,buf_c-layout-elem-rule.widget-id
                                      ,v-field-name)
    temp-changes.l_name = substitute("&4Элемент &1 в режиме &2: &3"
                                      ,buf_c-layout-elem-rule.widget-id
                                      ,buf_c-layout-elem-rule.mode-id
                                      ,v-field-label
                                     ,(if buf_c-layout-elem-rule.action = integer({&hn-create})
                                       then "+"
                                       else (if buf_c-layout-elem-rule.action = integer({&hn-delete})
                                             then "-"
                                             else {&tilda-char})
                                       )
                                      )
    temp-changes.v_old = string(buffer buf_c-layout-elem-rule:buffer-field(v-real-field-name):buffer-value)
    temp-changes.v_new = (if available new_c-layout-elem-rule
                          then string(buffer new_c-layout-elem-rule:buffer-field(v-real-field-name):buffer-value)
                          else '')
    .
    if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.
    if buf_c-layout-elem-rule.action = integer({&hn-create}) then do:
      assign
      temp-changes.v_old = ''
      .
    end.
    if buf_c-layout-elem-rule.action = integer({&hn-delete}) then do:
      assign
      temp-changes.v_new = ''
      .
    end.

  end.
end.
for each  buf_c-rule-call-param no-lock where
          buf_c-rule-call-param.call_id begins ({&table_layout-elem-rule} + {&delim-key} + p-layout-id)
      AND buf_c-rule-call-param.chip-num = p-chip-num
      AND buf_c-rule-call-param.corr-user-db-num = p-corr-user-db-num
      :
  find first new_c-rule-call-param no-lock where
            new_c-rule-call-param.call_id = buf_c-rule-call-param.call_id
      and new_c-rule-call-param.codex_id = buf_c-rule-call-param.codex_id
      and new_c-rule-call-param.ruleset_id = buf_c-rule-call-param.ruleset_id
      and new_c-rule-call-param.order_id = buf_c-rule-call-param.order_id
      and new_c-rule-call-param.param-name = buf_c-rule-call-param.param-name
      and new_c-rule-call-param.p-index = buf_c-rule-call-param.p-index
        AND new_c-rule-call-param.chip-num = p-new-chip-num
        AND new_c-rule-call-param.corr-user-db-num = p-new-corr-user-db-num  no-error.
&scop fields-name-list "param-name,param-data-type,param-label,rule_id"

&scop fields-label-list "Имя параметра,Тип данных,Лейбл,№ правила"

&scop fields-function-list ",,,"

  assign
  fields-name-list  = {&fields-name-list}
  fields-label-list  = {&fields-label-list}
  fields-function-list  = {&fields-function-list}
  .
  if buf_c-rule-call-param.action = integer({&hn-create}) then do:
    assign
    v-type = (if available new_c-rule-call-param
              then new_c-rule-call-param.param-data-type
              else '').
  end.
  else do:
    assign
    v-type = buf_c-rule-call-param.param-data-type.
  end.
  if v-type = {&abl-datatype-character} then do:
    assign
    fields-name-list = fields-name-list + {&comma-char} + "param-value-character"
    fields-label-list = fields-label-list + {&comma-char} + "Знач.(строковое)"
    fields-function-list = fields-function-list + {&comma-char}
    .
  end.
  if v-type = {&abl-datatype-date} then do:
    assign
    fields-name-list = fields-name-list + {&comma-char} + "param-value-date"
    fields-label-list = fields-label-list + {&comma-char} + "Знач.(дата)"
    fields-function-list = fields-function-list + {&comma-char}
    .
  end.
  if v-type = {&abl-datatype-decimal} then do:
    assign
    fields-name-list = fields-name-list + {&comma-char} + "param-value-decimal"
    fields-label-list = fields-label-list + {&comma-char} + "Знач.(десятичн.)"
    fields-function-list = fields-function-list + {&comma-char}
    .
  end.
  if v-type = {&abl-datatype-integer} then do:
    assign
    fields-name-list = fields-name-list + {&comma-char} + "param-value-integer"
    fields-label-list = fields-label-list + {&comma-char} + "Знач.(целое)"
    fields-function-list = fields-function-list + {&comma-char}
    .
  end.
  if v-type = {&abl-datatype-logical} then do:
    assign
    fields-name-list = fields-name-list + {&comma-char} + "param-value-logical"
    fields-label-list = fields-label-list + {&comma-char} + "Знач.(логич.)"
    fields-function-list = fields-function-list + {&comma-char}
    .
  end.
  if available new_c-rule-call-param then do:
    buffer-compare
    new_c-rule-call-param to buf_c-rule-call-param
    case-sensitive
    save result in v-chg-fields.
  end.
  else do:
    v-chg-fields = fields-name-list.
  end.

  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, fields-name-list).
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, fields-label-list)
    v-field-function = entry(jj, fields-function-list)
    v-real-field-name = entry(1, v-field-name, ':')
    .
    run gen-key-fv in this-procedure ( input buf_c-rule-call-param.call_id
                                       ,output v-field-list
                                       ,output v-value-list) no-error.
    assign
    v-widget-id =  entry(lookup("widget-id", v-field-list, {&delim-key}), v-value-list, {&delim-key})
    v-mode-id = entry(lookup("mode-id", v-field-list, {&delim-key}), v-value-list, {&delim-key})
    .

    create temp-changes.
    assign
    temp-changes.f_name = substitute("rule-call-param &1&2&1&3&1&4":U
                                     ,{&delim-par}
                                     ,buf_c-rule-call-param.call_id
                                     ,v-field-name
                                     ,buf_c-rule-call-param.param-name)
    temp-changes.l_name = substitute("&6Пар-р &1 функции &2 эл.&3 режим &4: &5"
                                      ,buf_c-rule-call-param.param-name
                                      ,(if buf_c-rule-call-param.rule_id > 0 then string(buf_c-rule-call-param.rule_id) else '')
                                      ,v-widget-id
                                      ,v-mode-id
                                      ,v-field-label
                                     ,(if buf_c-rule-call-param.action = integer({&hn-create})
                                       then "+"
                                       else (if buf_c-rule-call-param.action = integer({&hn-delete})
                                             then "-"
                                             else {&tilda-char})
                                       )
                                      )
    temp-changes.v_old = string(buffer buf_c-rule-call-param:buffer-field(v-field-name):buffer-value)
    temp-changes.v_new = (if available new_c-rule-call-param
                          then string(buffer new_c-rule-call-param:buffer-field(v-field-name):buffer-value)
                          else '')
    .
    if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.
    if buf_c-rule-call-param.action = integer({&hn-create}) then do:
      assign
      temp-changes.v_old = ''
      .
    end.
    if buf_c-rule-call-param.action = integer({&hn-delete}) then do:
      assign
      temp-changes.v_new = ''
      .
    end.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
br-docs:NUM-LOCKED-COLUMNS IN FRAME {&frame-name} = 6
X_c-layout.layout-id:READ-ONLY IN BROWSE br-docs = YES
temp-changes.l_name:resizable in browse br-changes = true
temp-changes.v_old:resizable in browse br-changes = true
temp-changes.v_new:resizable in browse br-changes = true
temp-changes.l_name:width in browse br-changes = 50
temp-changes.v_old:width in browse br-changes = 25
temp-changes.v_new:width in browse br-changes = 25
.



DISPLAY
mark-num
WITH FRAME Dialog-Frame.
ENABLE
b-quit
b-help
br-docs
b-sel  when LOOKUP("b-sel":U, bttns) > 0
b-mark when LOOKUP("b-mark":U, bttns) > 0
b-sch
br-changes
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
hide
b-lkp
in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Список истории раскладок" + {&space-char}.
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

&scop flt-open-open-query OPEN QUERY br-docs FOR EACH X_c-layout

&scop flt-open-dyn_open-query FOR EACH X_c-layout

&scop flt-open-query-handle QUERY br-docs:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-layout

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_c-layout

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .


  CASE p-mode :
    WHEN "one":U        THEN DO:
     assign
     filter-point = filter-point0 + p-mode
     filter-label = substitute("&1", filter-label0)
     frame {&frame-name} :title = substitute("История изменения раскладки &1", p-layout-id)
     .

     { gbl/fltopend.i
        &where-cond = " X_c-layout.layout-id = p-layout-id "
        &dyn_where-cond = " substitute('X_c-layout.layout-id = &1&2&1', ~{&double-quote~}, p-layout-id ) "
        &use-ind    = "  "
        &by         = " by X_c-layout.corr-user-db-num  by X_c-layout.chip-num descending  " }
    END.
END CASE.

if not p-open-query then
REPOSITION br-docs to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-docs in frame {&frame-name}.
APPLY "ENTRY" TO br-docs.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lkp Dialog-Frame
PROCEDURE proc-b-lkp :
define variable next-prev as character no-undo .
define variable v-doc-rec as recid no-undo .
if not available X_c-layout then return.
v-doc-rec = recid(X_c-layout).
DO WHILE next-prev = '':U:
  if NOT available X_c-layout then do:
    message "Неправильно выбрана запись истории раскладки." view-as alert-box ERROR.
    return no-apply.
  end.
  v-doc-rec = recid (X_c-layout).
  /*
  run str/suprcchk.w (
                   input parparentproc
                  ,input {&lookup}
                  ,input X_c-layout.obj-type
                  ,input X_c-layout.obj-code
                  ,input-output v-doc-rec
                  ,input this-procedure:handle
                  ,input-output next-prev
                              ) no-error.*/
  END .

reposition br-docs to recid v-doc-rec no-error.
apply "entry" to br-docs in frame {&frame-name}.
apply "value-changed" to br-docs in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
assign
  tbl = 'c-layout'
  join-tbl = 'X_c-layout'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('corr-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время корр.', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('layout-id', 'Номер в базе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w (
                    input parparentproc
                  , INPUT (filter-point + {&delim-par} + filter-label)
                  , INPUT tbl
                  , INPUT join-tbl
                  , INPUT fld
                  , INPUT lab
                  , INPUT spr
                  , INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame
PROCEDURE proc-view-changes :
define buffer new_c-layout for ub.c-layout.
define buffer current_layout for ub.layout.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable jj as integer no-undo .
define variable v-field-name as character no-undo .
define variable v-field-label as character no-undo .
define variable v-field-function as character no-undo .
define variable v-real-field-name as character no-undo .


for each temp-changes:
    delete temp-changes.
END.
if not available X_c-layout then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
find first new_c-layout no-lock where
            new_c-layout.layout-id = X_c-layout.layout-id
              AND new_c-layout.chip-num > X_c-layout.chip-num no-error.
if not available new_c-layout then do:
    find first current_layout no-lock where
                current_layout.layout-id = X_c-layout.layout-id no-error.

    if not available current_layout then do:
        return error.
    end.
    buffer-compare current_layout to X_c-layout
    case-sensitive
    save result in v-chg-fields.
    run get-line-changes-current in this-procedure ( input X_c-layout.corr-user-db-num
                                                    ,input X_c-layout.chip-num).
end.
else do:
    buffer-compare new_c-layout except chip-num corr-date corr-user-name corr-user-db-num  to X_c-layout
    case-sensitive
    save result in v-chg-fields.
    run get-line-changes-hist in this-procedure (
                                                  input X_c-layout.layout-id
                                                , input X_c-layout.corr-user-db-num
                                                , input X_c-layout.chip-num
                                                , input new_c-layout.corr-user-db-num
                                                , input new_c-layout.chip-num

                                                ).
end.


&scop fields-name-list "layout-id,des,device-type,is-default,layout-name,layout-type,sts"


&scop fields-label-list  "ID,Описание,Устройство,Обяз/пользв/Шаблон,Название,Тип,Статус"


&scop fields-function-list ",,,get-is-default-name,,get-layout-type-name,get-status-name"


  _ii:
  do ii = 1 to num-entries(v-chg-fields):

    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, {&fields-name-list}).
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, {&fields-label-list})
    v-field-function = entry(jj, {&fields-function-list})
    v-real-field-name = entry(1, v-field-name, ':')
    .

    create temp-changes.
    assign
    temp-changes.f_name = substitute("layout&1&2"
                                     ,{&delim-par}
                                     ,v-field-name)
    temp-changes.l_name = substitute("Шапка раскладки &1"
                                     ,v-field-label)
    temp-changes.v_old =  string(buffer X_c-layout:buffer-field(v-field-name):buffer-value)
    temp-changes.v_new = (if available new_c-layout
                              then string(buffer new_c-layout:buffer-field(v-field-name):buffer-value)
                              else string(buffer current_layout:buffer-field(v-field-name):buffer-value)
                         )
    .
     if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.

end.

Open QUery br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-c-layout Dialog-Frame
PROCEDURE reposition-c-layout :
define input  parameter p-direction   as character no-undo .
define output parameter p-layout-recid as recid no-undo .

  /* перемещение на первую, последнюю, предыдущую, следующую */
  case p-direction :
    when "first":U
    then do:
      get first br-docs.
    end.
    when "last":U
    then do:
      get last br-docs.
    end.
    when "prev":U
    then do:
      get prev br-docs.
      if not available X_c-layout then do:
        message
        "Это первый чек списка"
        view-as alert-box.
      end.
    end.
    when "next":U
    then do:
      get next br-docs.
      if not available X_c-layout then do:
        message
        "Это последний чек списка"
        view-as alert-box.
      end.
    end.
  end case . /* p-direction */
  assign
  p-layout-recid = recid(X_c-layout)
  .
  run reposition-query in this-procedure
    (input p-layout-recid
    ).




END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-query Dialog-Frame
PROCEDURE reposition-query :
define input parameter p-recid as recid no-undo .

  if p-recid <> ?
  then do:
    reposition br-docs to recid p-recid no-error.
  end.

  do with frame {&frame-name}:
    apply "entry":u to browse {&browse-name} .
    apply "VALUE-CHANGED":u to browse {&browse-name} .
  end. /* do with frame */




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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-is-default-name Dialog-Frame
FUNCTION get-is-default-name RETURNS CHARACTER
  ( p-is-default as integer ) :
define variable v-layout-kind-name as character no-undo.
&scop layout-kind-code string(p-is-default)
assign
v-layout-kind-name = {&layout-kind-name} no-error.

RETURN v-layout-kind-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-is-mandatory-name Dialog-Frame
FUNCTION get-is-mandatory-name RETURNS CHARACTER
  ( p-is-mandatory as integer ) :
define variable v-layout-elem-kind-name as character no-undo.
&scop layout-elem-rule-kind-code string(p-is-mandatory)
assign
v-layout-elem-kind-name = {&layout-elem-rule-kind-name} no-error.

RETURN v-layout-elem-kind-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-layout-type-name Dialog-Frame
FUNCTION get-layout-type-name RETURNS CHARACTER
  ( input p-layout-type as character ) :
define variable v-layout-type-name as character no-undo.

&scop layout-type-code p-layout-type
assign
v-layout-type-name = {&layout-type-name} no-error.
RETURN v-layout-type-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-status-name Dialog-Frame
FUNCTION get-status-name RETURNS CHARACTER
  ( input p-sts as integer ) :
define variable v-status-name as character no-undo.

&scoped-define status-code string(p-sts)
assign
v-status-name = {&status-int-name} no-error.
return v-status-name.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
