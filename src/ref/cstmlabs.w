&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-custom-labels NO-UNDO LIKE ub.custom-labels
       field default-field-size as decimal
       field field-vis as logical
       field field-size as decimal
       field field-num as integer
       field visible-field-num as integer.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выбор и конфигурирование настраиваемых полей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/01/07
Author: Bakhtadze Natalya
Creation date: 09/01/07

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-call-type as character no-undo .
DEFINE INPUT PARAMETER p-call-point AS character NO-UNDO.
DEFINE INPUT PARAMETER p-enable-size-change AS LOGICAL NO-UNDO.
DEFINE INPUT PARAMETER p-max-fields AS INTEGER NO-UNDO.
define output parameter p-ok as logical no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор и конфигурирование настраиваемых полей".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i DEF }
{ gbl/usr-flt.i DEF }
DEFINE VARIABLE v-all-ii AS INTEGER NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-custom-labels

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-custom-labels

/* Definitions for BROWSE BR-custom-labels                              */
&Scoped-define FIELDS-IN-QUERY-BR-custom-labels tt-custom-labels.custom-label tt-custom-labels.custom-tooltip tt-custom-labels.field-vis VIEW-AS TOGGLE-BOX tt-custom-labels.field-siz tt-custom-labels.visible-field-num tt-custom-labels.field-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-custom-labels tt-custom-labels.field-vis tt-custom-labels.field-siz
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-custom-labels tt-custom-labels
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-custom-labels tt-custom-labels
&Scoped-define SELF-NAME BR-custom-labels
&Scoped-define QUERY-STRING-BR-custom-labels FOR EACH tt-custom-labels BY tt-custom-labels.field-vis DESCENDING BY tt-custom-labels.visible-field-num BY tt-custom-labels.custom-label      INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-custom-labels OPEN QUERY {&SELF-NAME} FOR EACH tt-custom-labels BY tt-custom-labels.field-vis DESCENDING BY tt-custom-labels.visible-field-num BY tt-custom-labels.custom-label      INDEXED-REPOSITION .
&Scoped-define TABLES-IN-QUERY-BR-custom-labels tt-custom-labels
&Scoped-define FIRST-TABLE-IN-QUERY-BR-custom-labels tt-custom-labels


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-custom-labels}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help BR-custom-labels B-up ~
B-down B-vis B-no-vis

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-down
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Вниз"
     SIZE 3 BY 1 TOOLTIP "Переместить запись ниже"
     BGCOLOR 8 .

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-no-vis
     LABEL "Не вижу"
     SIZE 3 BY 1 TOOLTIP "Колонка не видна"
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-up
     IMAGE-UP FILE "btn-up-arrow":U
     IMAGE-DOWN FILE "btn-up-arrow":U
     IMAGE-INSENSITIVE FILE "btn-up-arrow":U
     LABEL "Вверх"
     SIZE 3 BY 1 TOOLTIP "Переместить запись выше"
     BGCOLOR 8 .

DEFINE BUTTON B-vis
     LABEL "Вижу"
     SIZE 3 BY 1 TOOLTIP "Колонка видна"
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-custom-labels FOR
      tt-custom-labels SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-custom-labels
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-custom-labels Dialog-Frame _FREEFORM
  QUERY BR-custom-labels NO-LOCK DISPLAY
      tt-custom-labels.custom-label COLUMN-LABEL "Лейбл" FORMAT "x(24)":U
tt-custom-labels.custom-tooltip COLUMN-LABEL "Подсказка" FORMAT "x(255)":U WIDTH 50
tt-custom-labels.field-vis COLUMN-LABEL "Вижу" VIEW-AS TOGGLE-BOX
tt-custom-labels.field-siz COLUMN-LABEL "Ширина" FORMAT ">>9.99":U
tt-custom-labels.visible-field-num COLUMN-LABEL "№№" FORMAT ">>9":U
tt-custom-labels.field-num COLUMN-LABEL "№№" FORMAT ">>9":U
ENABLE
tt-custom-labels.field-vis
tt-custom-labels.field-siz
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 95 BY 21.27 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     BR-custom-labels AT ROW 2 COL 1 WIDGET-ID 100
     B-up AT ROW 2.33 COL 96 WIDGET-ID 2
     B-down AT ROW 3.57 COL 96 WIDGET-ID 4
     B-vis AT ROW 4.83 COL 96 WIDGET-ID 6
     B-no-vis AT ROW 6.13 COL 96 WIDGET-ID 8
     SPACE(0.70) SKIP(16.14)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор и конфигурирование настраиваемых полей"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-custom-labels T "?" NO-UNDO ub custom-labels
      ADDITIONAL-FIELDS:
          field default-field-size as decimal
          field field-vis as logical
          field field-size as decimal
          field field-num as integer
          field visible-field-num as integer
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-custom-labels B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-no-vis:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-vis:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-custom-labels
/* Query rebuild information for BROWSE BR-custom-labels
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH tt-custom-labels
BY tt-custom-labels.field-vis DESCENDING
BY tt-custom-labels.visible-field-num
BY tt-custom-labels.custom-label
     INDEXED-REPOSITION .
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-custom-labels */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выбор и конфигурирование настраиваемых полей */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-down
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-down Dialog-Frame
ON CHOOSE OF B-down IN FRAME Dialog-Frame /* Вниз */
DO:
define buffer buf_next for tt-custom-labels  .
define variable old-number as integer   no-undo .
define variable new-number as integer   no-undo .
define variable v-recid as recid no-undo .
  if available tt-custom-labels then do:
  v-recid = recid (tt-custom-labels) .
  old-number = tt-custom-labels.visible-field-num .
  new-number = tt-custom-labels.visible-field-num + 1 .

  find first buf_next where buf_next.visible-field-num = new-number no-error .
    if available buf_next then do:
      buf_next.visible-field-num  = old-number .
      tt-custom-labels.visible-field-num = new-number .
      {&OPEN-QUERY-{&BROWSE-NAME}}
      reposition {&browse-name} to recid v-recid no-error.
    end.

  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  p-ok = yes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-no-vis
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-no-vis Dialog-Frame
ON CHOOSE OF B-no-vis IN FRAME Dialog-Frame /* Не вижу */
DO:
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  if available tt-custom-labels then do:
      tt-custom-labels.field-vis = false .
      glog =  {&BROWSE-NAME}:refresh() .
      glog = {&BROWSE-NAME}:select-next-row().

  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-up
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-up Dialog-Frame
ON CHOOSE OF B-up IN FRAME Dialog-Frame /* Вверх */
DO:
define buffer buf_prev for tt-custom-labels  .
define variable old-number as integer   no-undo .
define variable new-number as integer   no-undo .
define variable v-recid as recid no-undo .
  if available tt-custom-labels then do:
  v-recid = recid (tt-custom-labels) .
  old-number = tt-custom-labels.visible-field-num .
  new-number = tt-custom-labels.visible-field-num - 1 .

  find first buf_prev where buf_prev.visible-field-num = new-number no-error .
    if available buf_prev then do:
      buf_prev.visible-field-num  = old-number .
      tt-custom-labels.visible-field-num = new-number .
      {&OPEN-QUERY-{&BROWSE-NAME}}
      reposition {&browse-name} to recid v-recid no-error.
    end.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-vis
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-vis Dialog-Frame
ON CHOOSE OF B-vis IN FRAME Dialog-Frame /* Вижу */
DO:
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  if available tt-custom-labels then do:
      tt-custom-labels.field-vis = true  .
      glog =  {&BROWSE-NAME}:refresh().
      glog = {&BROWSE-NAME}:select-next-row().
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-custom-labels
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/brwrepos.i
&browse-name = "{&browse-name}"
&line-num=5
}

ON leave OF tt-custom-labels.field-vis IN BROWSE br-custom-labels
DO:
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE BUFFER buf_tt-custom-labels FOR tt-custom-labels.
  case LOGICAL(tt-custom-labels.field-vis:SCREEN-VALUE IN BROWSE br-custom-labels):
    WHEN YES THEN DO:
     IF tt-custom-labels.field-vis then return .
     IF v-all-ii + 1 > p-max-fields THEN DO:
        MESSAGE
        substitute("Max кол-во выбираемых полей = &1", p-max-fields)
        VIEW-AS ALERT-BOX ERROR.
        ASSIGN
        tt-custom-labels.field-vis = NO.
        DISPLAY
        tt-custom-labels.field-vis with BROWSE br-custom-labels.
        RETURN.
     END.
     v-all-ii = v-all-ii + 1.
     tt-custom-labels.field-vis = YES.
    END.
    WHEN NO THEN DO:
      IF tt-custom-labels.field-vis = no then return .
      v-all-ii = v-all-ii - 1.
      tt-custom-labels.field-vis = no.
    END.
  END CASE.
END.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/getcntxt.i get }
  RUN fill-tables IN THIS-PROCEDURE.
  RUN Myenable.
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
  ENABLE B-exit b-quit B-Help BR-custom-labels B-up B-down B-vis B-no-vis
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
define variable ii as integer   no-undo .
define variable v-size as character no-undo .
define variable v-num as character no-undo .

DEFINE BUFFER buf_custom-labels FOR ub.custom-labels.
DEFINE BUFFER buf_tt-custom-labels FOR tt-custom-labels.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
    for each buf_custom-labels no-lock where
        buf_custom-labels.language = "{&language}"
    and buf_custom-labels.call-type = p-call-type
    and buf_custom-labels.call-point = p-call-point
 by buf_custom-labels.custom-label
    :
  create buf_tt-custom-labels .
  BUFFER-COPY buf_custom-labels TO buf_tt-custom-labels.
  assign
  buf_tt-custom-labels.field-num  = ii + 1
  ii = ii + 1
  buf_tt-custom-labels.field-vis  = no
  buf_tt-custom-labels.default-field-size = buf_tt-custom-labels.widget-width
  buf_tt-custom-labels.field-size = buf_tt-custom-labels.default-field-size
  .
end.

run uf-get in this-procedure (
     input  p-call-point
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
    )  .
case p-call-point :
  when {&uf-gdsreffi} then do:
    if v-uf-List_ = "" or v-uf-List_ = ? then do:
      v-num  = {&gdsreffi-ord}.
      v-size = {&gdsreffi-siz}.
    end.
    else do:
      v-num   = entry(1, v-uf-List_, {&delim-par}) .
      v-size  = entry(2, v-uf-List_, {&delim-par}) .
    end.
  end.
  otherwise do:
    assign
    v-num   = entry(1, v-uf-List_, {&delim-par})
    v-size  = entry(2, v-uf-List_, {&delim-par})
    no-error
    .
    if v-size = '':U then do:
      assign
      v-size = fill({&question-mark}, num-entries(v-num)).
    end.
  end.
end case.
repeat ii = 1 to num-entries(v-num) :
  FIND FIRST buf_tt-custom-labels WHERE
            buf_tt-custom-labels.tbl-name = ENTRY(1, ENTRY(ii, v-num), ".":U)
        AND buf_tt-custom-labels.fld-name = ENTRY(2, ENTRY(ii, v-num), ".":U) no-error.
  IF AVAILABLE buf_tt-custom-labels THEN DO:
    ASSIGN
    buf_tt-custom-labels.visible-field-num = ii
    buf_tt-custom-labels.field-vis = YES
    buf_tt-custom-labels.field-size = (IF entry(ii, v-size) = {&question-mark}
                                      THEN buf_tt-custom-labels.field-size
                                      ELSE decimal(entry(ii, v-size)))
    v-all-ii = v-all-ii + 1
    .

  END.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
assign
tt-custom-labels.custom-tooltip:RESIZABLE IN BROWSE br-custom-labels = YES.
IF p-enable-size-change = NO THEN DO:
  ASSIGN
  tt-custom-labels.field-siz:REad-only IN BROWSE br-custom-labels = YES
  tt-custom-labels.field-siz:visible IN BROWSE br-custom-labels = NO
  .
END.
ENABLE
B-exit
b-quit
B-Help
BR-custom-labels
B-up
B-down
/*B-vis
B-no-vis
*/
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-num AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-wis AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_tt-custom-labels FOR tt-custom-labels.
FOR EACH buf_tt-custom-labels WHERE
        buf_tt-custom-labels.field-vis = YES
by buf_tt-custom-labels.visible-field-num
        :
   ASSIGN
   v-num  = v-num + (IF v-num = '':U
                     THEN '':U
                     ELSE {&comma-char}) + (buf_tt-custom-labels.tbl-name + "." + buf_tt-custom-labels.fld-name)
   v-wis = v-wis + (IF v-wis = '':U
                    THEN '':U
                    ELSE {&comma-char}) + STRING(buf_tt-custom-labels.field-size).
   v-ii = v-ii + 1.
  IF v-ii = p-max-fields THEN LEAVE.
END.
ASSIGN
v-uf-list_ = v-num + {&delim-par} + v-wis.
run uf-set in this-procedure(
    input  p-call-point
    ,input  v-cntxt-userid
    ,input v-uf-List_
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
)  no-error .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME