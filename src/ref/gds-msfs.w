&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_ext-classif FOR ub.ext-classif.
DEFINE BUFFER X_goods FOR ub.goods.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Товары по классификатору мясных полубфарикатов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/03/09
Author: Bakhtadze Natalya
Creation date: 08/03/09


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER bttns AS character NO-UNDO.
DEFINE INPUT PARAMETER p-list-mode AS character NO-UNDO.
define input parameter p-node-code as integer no-undo .
define input parameter p-uniq-key-rec as character no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-rid-list AS character NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Товары по классификатору мясных полубфарикатов".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ gbl/key-rec.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ cmp/mrk-strf.i }
{ ref/extclass.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i }
{ gbl/prn-lib.i }
{ gbl/fltopend.i defproc }
{ ref/meatsemi.i meat-semi-finished ds }
{ ref/meatsemi.i dop-msf }
{ ref/meatsemi.i " " proc }
define variable sort-column-name as character no-undo.
define variable filter-point     as character NO-UNDO INIT "gds-msfs".
define variable filter-label     as character NO-UNDO INIT "Товары-мясные полуфабрикаты".
define variable filter-point0     as character NO-UNDO INIT "gds-msfs".
define variable filter-label0     as character NO-UNDO INIT "Товары-мясные полуфабрикаты".
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define buffer buf_clob-bind for ub.clob-bind.
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .

&scoped-define view-dop-msf ~
DISPLAY ~
dop-msf.node-code AT ROW 16 COL 5 COLON-ALIGN  ~
dop-msf.group-name AT ROW 16 COL 17 COLON-ALIGN ~
dop-msf.kind-name AT ROW 16 COL 54 COLON-ALIGN SKIP ~
dop-msf.subkind-name-1 AT ROW 17 COL 17 COLON-ALIGN ~
dop-msf.subkind-name-2 AT ROW 17 COL 54 COLON-ALIGN SKIP ~
dop-msf.subkind-name-3 AT ROW 18 COL 17 colon-align ~
dop-msf.subkind-name-4 AT ROW 18 COL 54 COLON-ALIGN SKIP ~
dop-msf.subkind-name-5 AT ROW 19 COL 17 colon-align ~
dop-msf.subkind-name-6 AT ROW 19 COL 54 COLON-ALIGN SKIP  ~
dop-msf.category-name AT ROW 20 COL 17 COLON-ALIGN ~
dop-msf.termic-condition-name AT ROW 20 COL 54 COLON-ALIGN ~
with FRAME ~{&FRAME-NAME~}



&SCOPED-DEFINE hide-dop-msf ~
disable ~
dop-msf.node-code ~
dop-msf.group-name ~
dop-msf.kind-name ~
dop-msf.subkind-name-1  ~
dop-msf.subkind-name-2  ~
dop-msf.subkind-name-3  ~
dop-msf.subkind-name-4  ~
dop-msf.subkind-name-5  ~
dop-msf.subkind-name-6  ~
dop-msf.category-name   ~
dop-msf.termic-condition-name ~
with FRAME {&FRAME-NAME}. ~
hide ~
dop-msf.node-code ~
in FRAME {&FRAME-NAME} ~
dop-msf.group-name ~
dop-msf.kind-name ~
dop-msf.subkind-name-1  ~
dop-msf.subkind-name-2  ~
dop-msf.subkind-name-3  ~
dop-msf.subkind-name-4  ~
dop-msf.subkind-name-5  ~
dop-msf.subkind-name-6  ~
dop-msf.category-name   ~
dop-msf.termic-condition-name ~
in FRAME {&FRAME-NAME}

define buffer buf_goods for ub.goods.
define buffer buf_msf for meat-semi-finished.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-msf-codes

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_ext-classif X_goods

/* Definitions for BROWSE br-msf-codes                                  */
&Scoped-define FIELDS-IN-QUERY-br-msf-codes mark-string(recid(X_ext-classif), v-rid-list) X_ext-classif.KEY#_one X_goods.gds-code X_goods.gds-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-msf-codes
&Scoped-define SELF-NAME br-msf-codes
&Scoped-define QUERY-STRING-br-msf-codes FOR EACH X_ext-classif NO-LOCK, ~
       FIRST X_goods NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-msf-codes OPEN QUERY {&SELF-NAME} FOR EACH X_ext-classif NO-LOCK, ~
       FIRST X_goods NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-msf-codes X_ext-classif X_goods
&Scoped-define FIRST-TABLE-IN-QUERY-br-msf-codes X_ext-classif
&Scoped-define SECOND-TABLE-IN-QUERY-br-msf-codes X_goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-msf-codes}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel b-add b-del b-gds b-sch ~
b-print B-Help br-msf-codes mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cli-type-code Dialog-Frame
FUNCTION get-cli-type-code RETURNS CHARACTER
  ( INPUT p-uniq-key-rec AS character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-gds-name Dialog-Frame
FUNCTION get-gds-name RETURNS CHARACTER
  ( INPUT p-uniq-key-rec AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-gds
     LABEL "Товар"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-print
     LABEL "&Печать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch
     LABEL "Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-msf-codes FOR X_ext-classif, X_goods SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-msf-codes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-msf-codes Dialog-Frame _FREEFORM
  QUERY br-msf-codes NO-LOCK DISPLAY
      mark-string(recid(X_ext-classif), v-rid-list) COLUMN-LABEL "" FORMAT "X(1)"
X_ext-classif.KEY#_one  COLUMN-LABEL "Код в!класс-ре" FORMAT ">>>>>>>>9"
X_goods.gds-code COLUMN-LABEL "Код!Товара" FORMAT ">>>>>>>>9"
X_goods.gds-name COLUMN-LABEL "Название товара" FORMAT "X(60)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.3 BY 12 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11 WIDGET-ID 4
     B-sel AT ROW 1 COL 21 WIDGET-ID 6
     b-add AT ROW 1 COL 31 WIDGET-ID 14
     b-del AT ROW 1 COL 41 WIDGET-ID 16
     b-gds AT ROW 1 COL 61 WIDGET-ID 2
     b-sch AT ROW 1 COL 86 WIDGET-ID 12
     b-print AT ROW 1 COL 89 WIDGET-ID 10
     B-Help AT ROW 1 COL 95
     br-msf-codes AT ROW 2.87 COL 1.5 WIDGET-ID 100
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     SPACE(79.30) SKIP(21.26)
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
      TABLE: X_ext-classif B "?" ? ub ext-classif
      TABLE: X_goods B "?" ? ub goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-msf-codes B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-msf-codes
/* Query rebuild information for BROWSE br-msf-codes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_ext-classif NO-LOCK, FIRST X_goods NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY br-msf-codes FOR X_ext-classif, X_goods SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-msf-codes */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
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
  RUN proc-b-add IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  IF NOT AVAILABLE X_ext-classif THEN RETURN NO-APPLY.
  RUN proc-b-del IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gds Dialog-Frame
ON CHOOSE OF b-gds IN FRAME Dialog-Frame /* Товар */
DO:
  IF NOT AVAILABLE X_goods THEN RETURN NO-APPLY.
  run str/showgds.p ( input parparentproc
                    ,input ? /*p-call-handle*/
                    ,input X_goods.gds-code
                    ,input {&lookup}) no-error.
  APPLY "entry" TO br-msf-codes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available X_ext-classif then do:
    { gbl/markstrn.i X_ext-classif v-rid-list }
    loc#log = br-msf-codes:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-msf-codes:select-next-row ().
        apply "VALUE-CHANGED" to br-msf-codes in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-msf-codes in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_ext-classif ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_ext-classif ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-msf-codes
&Scoped-define SELF-NAME br-msf-codes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-msf-codes Dialog-Frame
ON VALUE-CHANGED OF br-msf-codes IN FRAME Dialog-Frame
DO:
  IF AVAILABLE X_ext-classif THEN DO:
    FIND FIRST meat-semi-finished WHERE
               meat-semi-finished.node-code = X_ext-classif.key#_one NO-ERROR.
    IF AVAILABLE meat-semi-finished THEN DO:
      ASSIGN
      dop-msf.node-code =  meat-semi-finished.node-code
      dop-msf.group-name =  meat-semi-finished.group-name
      dop-msf.kind-name  =  meat-semi-finished.kind-name
      dop-msf.subkind-name-1 = meat-semi-finished.subkind-name-1
      dop-msf.subkind-name-2 = meat-semi-finished.subkind-name-2
      dop-msf.subkind-name-3 = meat-semi-finished.subkind-name-3
      dop-msf.subkind-name-4  = meat-semi-finished.subkind-name-4
      dop-msf.subkind-name-5 = meat-semi-finished.subkind-name-5
      dop-msf.subkind-name-6 = meat-semi-finished.subkind-name-6
      dop-msf.category-name = meat-semi-finished.category-name
      dop-msf.termic-condition-name = meat-semi-finished.termic-condition-name
      .
      {&view-dop-msf}.
    END.
    ELSE DO:
      {&hide-dop-msf}.
    END.
  END.
  ELSE DO:
    {&hide-dop-msf}.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/setfltnm.i }

{ gbl/hot-key.i b-print }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }
  if lookup(p-list-mode, ({&all} + {&comma-char} +
                    "node-code" + {&comma-char} +
                    "uniq-key-rec")) = 0 then do:
    message
    substitute("Неверное значение параметра p-list-mode = &1", p-list-mode)
    view-as alert-box error .
  end.
  run fill-tables in this-procedure .
  case p-list-mode:
    when "uniq-key-rec" then do:
      /*найдем товар*/
     run gen-row-keyr in this-procedure ( input p-uniq-key-rec
                                         ,input ? /*p-key-handle  буфер записи которую будем искать. если ищем по key-rec то ? */
                                         ,input "ub"
                                         ,input ? /*p-tt-handle буфер таблицы - если надо найти во временной таблице. если ищем в БД то ?*/
                                         ,input no-lock
                                         ,output v-tbl-row
                                         ,output v-tbl-name).
      find first buf_goods no-lock where
                rowid(buf_goods) = v-tbl-row.
    end.
    when "node-code" then do:
       /*надем msf*/
       find first buf_msf no-lock where
                buf_msf.node-code = p-node-code.
    end.
  end case.
  v-rid-list = p-rid-list.
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
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel b-add b-del b-gds b-sch b-print B-Help
         br-msf-codes mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
run meatsemi_fill-msf in this-procedure ( input {&lookup}
                                        , buffer buf_clob-bind).
CREATE dop-msf.
RELEASE dop-msf.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
FIND FIRST dop-msf.
ENABLE
b-quit
b-gds
b-print
b-add when (lookup("b-add", bttns) > 0 and not transaction)
b-del when (lookup("b-add", bttns) > 0 and not transaction)
b-sch
B-Help
br-msf-codes
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
RUN Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo .
define variable title1 as character no-undo .

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

&scop flt-open-open-query         OPEN QUERY br-msf-codes FOR EACH X_ext-classif

&scop flt-open-dyn_open-query     FOR EACH X_ext-classif

&scop flt-open-query-handle      QUERY br-msf-codes:handle

&scop flt-open-open-query-tail  , FIRST X_goods NO-LOCK WHERE ~
                                  X_goods.gds-code = integer(ENTRY(2, X_eXt-classif.uniq-key-rec, {&delim-key}))

&scop flt-open-dyn_open-query-tail  substitute(', FIRST X_goods NO-LOCK WHERE ~
                                  X_goods.gds-code = integer(ENTRY(2, X_eXt-classif.uniq-key-rec, {&delim-key}))')



&scop flt-open-query-was-opened   l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point         filter-point

&scop flt-open-set-filter-name    set-filter-name

&scop flt-open-indexed-reposition INDEXED-REPOSITION
filter-point = filter-point0 + p-list-mode .

title0 = "Мясные полуфабрикаты".

case p-list-mode:
  when {&all} then do:
    ASSIGN
    title1 = substitute("&1", title0)
    frame {&frame-name}:title = title1
    filter-label = title1
    .
    { gbl/fltopend.i
      &where-cond = " X_ext-classif.classif-subject = ~{&table_goods~} ~
                      and X_ext-classif.classif-name = ~{&extclass_goods_msf~} ~
                      AND X_ext-classif.db-num = - 1"
      &dyn_where-cond = " substitute('X_ext-classif.classif-subject = &1&2&1 ~
                      and X_ext-classif.classif-name = &1&3&1 ~
                      AND X_ext-classif.db-num = - 1', {&double-quote}, ~{&table_goods~}, ~{&extclass_goods_msf~})"

      &use-ind    = "  "
      &by         = "  " }
  end.
  when "node-code" then do:
    if available buf_msf then do:
      ASSIGN
      title1 = substitute("Код &1 - &2, &3, &4, &5, &6"
                         , p-node-code
                         , buf_msf.group-name
                         , buf_msf.kind-name
                         , buf_msf.subkind-name
                         , buf_msf.category-name
                         , buf_msf.termic-condition-name)
      frame {&frame-name}:title = title1
      filter-label = title1
      .
    end.
    else do:
      ASSIGN
      title1 = substitute("&1 Код &2"
                         , title0
                         , p-node-code)
      frame {&frame-name}:title = title1
      filter-label = title1
      .

    end.
    { gbl/fltopend.i
      &where-cond = " X_ext-classif.classif-subject = ~{&table_goods~} ~
                      and X_ext-classif.classif-name = ~{&extclass_goods_msf~} ~
                      AND X_ext-classif.db-num = - 1 ~
                      and X_ext-classif.key#_one = p-node-code "
      &dyn_where-cond = " substitute('X_ext-classif.classif-subject = &1&2&1 ~
                      and X_ext-classif.classif-name = &1&3&1 ~
                      AND X_ext-classif.db-num = - 1 ~
                      AND X_ext-classif.key#_one = &4 ', {&double-quote}, ~{&table_goods~}, ~{&extclass_goods_msf~}, p-node-code) "

      &use-ind    = "  "
      &by         = "  " }

  end.
  when "uniq-key-rec" then do:
    ASSIGN
    title1 = sUBSTITUTE("&1 - Товар с кодом &2 - &3"
                              , title0
                              , buf_goods.gds-code
                              , buf_goods.gds-name
                              )
    frame {&frame-name}:title = title1
    filter-label = title1
    .
    { gbl/fltopend.i
      &where-cond = " X_ext-classif.classif-subject = ~{&table_goods~} ~
                      and X_ext-classif.classif-name = ~{&extclass_goods_msf~} ~
                      AND X_ext-classif.db-num = - 1 ~
                      and X_ext-classif.uniq-key-rec = p-uniq-key-rec "
      &dyn_where-cond = " substitute('X_ext-classif.classif-subject = &1&2&1 ~
                      and X_ext-classif.classif-name = &1&3&1 ~
                      AND X_ext-classif.db-num = - 1 ~
                      AND X_ext-classif.uniq-key-rec = &1&4&1 ', {&double-quote}, ~{&table_goods~}, ~{&extclass_goods_msf~}, p-uniq-key-rec) "

      &use-ind    = "  "
      &by         = "  " }
  end.
end case.
APPLY "entry" TO br-msf-codes.
if available X_ext-classif then do:
    APPLY "VALUE-CHANGED":U to {&browse-name}.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-rid as recid no-undo .
DEFINE VARIABLE v-ok AS logical NO-UNDO.
DEFINE VARIABLE v-value-integer AS integer NO-UNDO.
define variable v-uniq-key-rec as character no-undo .
define variable v-ii as integer no-undo .
define buffer buf_ext-classif for ub.ext-classif.
if p-list-mode = "uniq-key-rec" then do:
  v-uniq-key-rec = p-uniq-key-rec.
  v-rid-list = string(recid(buf_goods)).
end.
else do:
  message
  "Выберите товар(-ы), для который Вы хотите классифицировать как мясной полуфабрикат"
  view-as alert-box .
  run ref/gds-ref.p ( input parparentproc
                    , input "b-sel,b-mark"
                    , input {&current}
                    , input {&all}
                    , input ?
                    , input ?
                    , input ?
                    , input ?
                    , input ?
                    , input ?
                    , input ?
                    , input ?
                    , output v-rid-list) no-error.
  if v-rid-list = '':U then return no-apply.
end.
if p-list-mode = "node-code" then do:
  v-value-integer = p-node-code.
end.
else do:
  run ref/meatsemi.w ( input parparentproc
                      ,input "b-sel"
                      ,input {&lookup}
                      ,input-output v-value-integer) no-error.
  if v-value-integer = 0  then return error.
end.

_v-ii:
do v-ii = 1 to num-entries(v-rid-list):
  if p-list-mode <> "uniq-key-rec" then do:
    find first buf_goods where recid (buf_goods) = integer (entry(v-ii, v-rid-list)) no-lock no-error.
    run gen-key-rec IN THIS-PROCEDURE ( input {&table_goods}
                                  ,input (buffer buf_goods:handle)
                                  ,output v-uniq-key-rec).
  end.
  find first buf_ext-classif no-lock where
            buf_ext-classif.classif-subject = {&table_goods}
        and buf_ext-classif.classif-name = {&extclass_goods_msf}
        AND buf_ext-classif.db-num = - 1
        and buf_ext-classif.uniq-key-rec = v-uniq-key-rec no-error.
  if available buf_ext-classif then do:
    message
    substitute("Товар с кодом &1 уже привязан к классификатору мясных полуфабрикатов", buf_goods.gds-code)
    view-as alert-box error .
    if num-entries(v-rid-list) = 1 then  undo, return error .
    else next _v-ii.
  end.
  v-rid = ?.
  run ref/extclas1.p ( INPUT {&add-def}
                      ,INPUT NO /*p-silent*/
                      ,INPUT-OUTPUT v-rid
                      ,INPUT {&table_goods} /*p-classif-subject*/
                      ,INPUT {&extclass_goods_msf} /*p-classif-name*/
                      ,input (-1) /*p-db-num*/
                      ,input v-value-integer /*p-key#_one*/
                      ,input 0 /*p-Key#_Two*/
                      ,input 0 /*p-key#_Three*/
                      ,input '':U /*p-CharKey_One */
                      ,input '':U /*p-CharKey_two */
                      ,input '':U /*p-CharKey_three */
                      ,input string(buf_goods.gds-code) /*p-nonunique */
                      ,input v-uniq-key-rec ) no-error.
  if error-status:error then do:
    message error-status:get-message(1) view-as alert-box .
    undo, return error .
  end.
end. /*do v-ii = 1 to num-entries(v-rid-list):*/
if v-rid <> ?
or num-entries(v-rid-list) > 1
then do:
  run openbr in this-procedure ( input yes, input no, input '':U).
  reposition br-msf-codes to recid v-rid no-error .
  apply "entry" to br-msf-codes in frame {&frame-name} .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEFINE VARIABLE glog AS logical NO-UNDO.
IF NOT AVAILABLE X_ext-classif THEN UNDO, RETURN ERROR.
v-rec = recid(X_ext-classif).
MESSAGE
"Вы действительно хотите удалить эту запись?"
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
IF NOT glog THEN RETURN ERROR.
run ref/extclas3.p ( INPUT NO /*p-silent*/
                    ,INPUT v-rec) NO-ERROR.
if not error-status:error then do:
  run openbr in this-procedure ( input yes, input no, input '':U).
  reposition br-msf-codes to row 1 no-error .
  apply "entry" to br-msf-codes in frame {&frame-name} .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
DEFINE VARIABLE date_string              as   character no-undo .
DEFINE VARIABLE Line                     as   character no-undo .
DEFINE VARIABLE for-time                 as   character no-undo .
DEFINE VARIABLE accum-count              as   integer   no-undo .
define variable v-rid                    as   recid no-undo .

DEFINE FRAME list1
X_ext-classif.KEY#_one  COLUMN-LABEL "Код в!класс-ре" FORMAT ">>>>>>>>9"
X_goods.gds-code COLUMN-LABEL "Код!товара" FORMAT ">>>>>>>>9"
X_goods.gds-name COLUMN-LABEL "Название товара" FORMAT "X(60)"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 75 PAGE-NUMBER(PrnLibStream) AT 85 FORMAT ">>9" SKIP
Line format "X(192)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 121).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input  {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(177)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
v-rid = recid(X_ext-classif).
FORM with FRAME List1.
run waitfram-show in this-procedure ( input "Ждите...").
DO WHILE available X_ext-classif :
   GET prev br-msf-codes.
END.
GET next br-msf-codes.
DO WHILE available X_ext-classif :
  Display STREAM PrnLibStream
  X_ext-classif.KEY#_one
  X_goods.gds-code
  X_goods.gds-name
  with FRAME List1.
  DOWN STREAM PrnLibStream
  1
  with FRAME List1.
  assign
  accum-count = accum-count + 1
  .
  GET next br-msf-codes.
END.
UNDERLINE  STREAM PrnLibStream
X_ext-classif.KEY#_one
X_goods.gds-code
X_goods.gds-name
with FRAME List1.
DISPLAY STREAM PrnLibStream
accum-count @ X_ext-classif.key#_one
with frame List1.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME List1.
output  STREAM PrnLibStream CLOSE.
reposition br-msf-codes to recid v-rid no-error .
apply "ENTRY" to br-msf-codes in frame {&frame-name} .
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
define variable v-ri as recid no-undo .
assign
v-ri = (if avail X_ext-classif then recid(X_ext-classif) else ?)
.
assign
tbl = {&table_ext-classif}
join-tbl = 'X_ext-classif'
fld = ""
lab = ""
spr = ""
dim = '0'
.

run fltfield-add in this-procedure('key#_one', 'Код клиента ПАРУС', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

DO on stop undo, leave:
    run gbl/filter.w ( INPUT parparentproc
                 ,INPUT filter-point + {&delim-par} + filter-label
                 ,INPUT tbl
                 ,INPUT join-tbl
                 ,INPUT fld
                 ,INput lab
                 ,INPUT spr
                 ,INPUT  dim).
    run OpenBr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
    if v-ri <> ? then do:
      reposition br-msf-codes to recid v-ri no-error.
    end.
    APPLY "ENTRY" to br-msf-codes in frame {&frame-name} .
    APPLY "VALUE-CHANGED" to br-msf-codes.
END .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cli-type-code Dialog-Frame
FUNCTION get-cli-type-code RETURNS CHARACTER
  ( INPUT p-uniq-key-rec AS character ) :
DEFINE VARIABLE v-rowid AS ROWID NO-UNDO.
DEFINE VARIABLE v-tbl-name AS character NO-UNDO.
DEFINE BUFFER buf_goods FOR ub.goods.
/*
    RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT p-uniq-key-rec
                                        ,INPUT ?
                                        ,INPUT "ub"
                                        ,INPUT ? /*p-bh-handle*/
                                        ,INPUT NO-LOCK
                                        ,OUTPUT v-rowid
                                        ,OUTPUT v-tbl-name) NO-ERROR.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1)
        error-status :get-message(2)
      view-as alert-box error.
      undo, return error.
    end.

    IF v-rowid = ? THEN RETURN ''.

    FIND FIRST buf_goods NO-LOCK WHERE ROWID(buf_goods) = v-rowid.
    RETURN substitute("&1&2"
                      ,buf_goods.obj-type
                      ,buf_goods.obj-code).   /* Function return value. */
  */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-gds-name Dialog-Frame
FUNCTION get-gds-name RETURNS CHARACTER
  ( INPUT p-uniq-key-rec AS CHARACTER ) :
DEFINE VARIABLE v-rowid AS ROWID NO-UNDO.
DEFINE VARIABLE v-tbl-name AS character NO-UNDO.
DEFINE BUFFER buf_goods FOR ub.goods.
RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT p-uniq-key-rec
                                    ,input ?
                                    ,INPUT "ub"
                                    ,INPUT ? /*p-bh-handle*/
                                    ,INPUT NO-LOCK
                                    ,OUTPUT v-rowid
                                    ,OUTPUT v-tbl-name) no-error.
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1)
    error-status :get-message(2)
  view-as alert-box error.
  undo, return error.
end.
IF v-rowid = ? THEN RETURN 'НЕИЗВЕСТНЫЙ ТОВАР'.

FIND FIRST buf_goods NO-LOCK WHERE ROWID(buf_goods) = v-rowid.
RETURN buf_goods.gds-name.   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME