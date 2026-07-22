&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_cd-trans FOR ub.cd-trans.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Фискальные счетчики

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/12/07
Author: Bakhtadze Natalya
Creation date: 06/12/07

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns  as CHARACTER   no-undo .
define input parameter p-list-mode  as CHARACTER   no-undo .
define input parameter p-trans-type  as INTEGER   no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input parameter p-start-date like ub.chk-doc.chk-date no-undo .
define input parameter p-end-date like ub.chk-doc.chk-date no-undo .
define input parameter p-charkey-one AS character no-undo .
define input parameter p-chk-id as character no-undo .
define output PARAMETER p-rid-list    as  CHARACTER no-undo . /* список recid'ов выбранных  */


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Фискальные счетчики".

define variable filter-label as character no-undo init "Фискальные счетчики" .
define variable filter-label0 as character no-undo init "Фискальные счетчики" .
define variable filter-point0 as character no-undo init "cf-cdtrs" .
define variable filter-point as character no-undo init "cf-cdtrs" .
define variable sort-column-name as character no-undo .
define variable print-type as character no-undo.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rep-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-cd-trans-recid as recid no-undo .
DEFINE VARIABLE v-trans-type-char AS CHARACTER NO-UNDO.
define variable v-charkey-one-label as character no-undo .
define variable lnk-option as character no-undo .
DEFINE BUFFER buf_obj FOR ub.clients.
DEFINE BUFFER buf_chk-doc FOR ub.chk-doc.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/waitfram.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/fltfield.i }
{ gbl/cur-time.i }
{ str/shftnmef.i chk-doc shift-name }
{ cmp/mrk-strf.i }
{ gbl/getcntxt.i def }
{ gbl/fltopend.i defproc }
{ gbl/paramls.i }

&scop discnt-target-code string(X_cd-trans.line-type)
&SCOPED-DEFINE label-time "Время"
&SCOPED-DEFINE label-trans-name "Тип!транзакции"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-trans

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_cd-trans

/* Definitions for BROWSE br-trans                                      */
&Scoped-define FIELDS-IN-QUERY-br-trans mark-string(recid(X_cd-trans), v-rid-list) X_cd-trans.chk-date string(X_cd-trans.chk-time, "HH:MM") X_cd-trans.doc-code X_cd-trans.obj-type X_cd-trans.obj-code X_cd-trans.pay-desk X_cd-trans.out-code get-trans-name(X_cd-trans.trans-type) X_cd-trans.charkey_one X_cd-trans.key#_one X_cd-trans.deckey_one
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-trans
&Scoped-define SELF-NAME br-trans
&Scoped-define QUERY-STRING-br-trans FOR EACH X_cd-trans       WHERE X_cd-trans.trans-type = p-trans-type NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-trans OPEN QUERY {&SELF-NAME} FOR EACH X_cd-trans       WHERE X_cd-trans.trans-type = p-trans-type NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-trans X_cd-trans
&Scoped-define FIRST-TABLE-IN-QUERY-br-trans X_cd-trans


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-chk-doc b-sch B-Help ~
br-trans mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-trans-name Dialog-Frame
FUNCTION get-trans-name RETURNS CHARACTER
  ( p-trans-type AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chk-doc
     LABEL "Чек"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "&Выбор"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U INITIAL "0"
      VIEW-AS TEXT
     SIZE 10 BY .67 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-trans FOR
      X_cd-trans SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-trans
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-trans Dialog-Frame _FREEFORM
  QUERY br-trans NO-LOCK DISPLAY
      mark-string(recid(X_cd-trans), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
X_cd-trans.chk-date COLUMN-LABEL "Дата" FORMAT "99/99/9999":U
string(X_cd-trans.chk-time, "HH:MM") COLUMN-LABEL {&label-time} FORMAT "X(5)"
X_cd-trans.doc-code COLUMN-LABEL "Номер чека" FORMAT "X(20)":U
X_cd-trans.obj-type COLUMN-LABEL "Тип!Объ" FORMAT "X(3)":U
X_cd-trans.obj-code COLUMN-LABEL "Код!обЪ" FORMAT ">>>>9":U
X_cd-trans.pay-desk COLUMN-LABEL "Касса" FORMAT ">>>9":U
X_cd-trans.out-code COLUMN-LABEL "Номер_РН" FORMAT "X(14)":U
get-trans-name(X_cd-trans.trans-type) COLUMN-LABEL {&label-trans-name} FORMAT "X(255)" WIDTH 40
X_cd-trans.charkey_one COLuMN-LABEL "" FORMAT "X(255)":U WIDTH 20
X_cd-trans.key#_one COLuMN-LABEL "" FORMAT "->>>>>>>>9":U
X_cd-trans.deckey_one COLuMN-LABEL "" FORMAT "->>>>>>>>9.99":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.8 BY 20 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 21 WIDGET-ID 52
     b-sel AT ROW 1 COL 24 WIDGET-ID 54
     b-chk-doc AT ROW 1 COL 41 WIDGET-ID 50
     b-sch AT ROW 1 COL 92 WIDGET-ID 60
     B-Help AT ROW 1 COL 95
     br-trans AT ROW 2 COL 1 WIDGET-ID 100
     mark-num AT ROW 1 COL 9 COLON-ALIGNED NO-LABEL WIDGET-ID 62
     SPACE(78.80) SKIP(21.60)
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
      TABLE: X_cd-trans B "?" ? ub cd-trans
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-trans B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-trans
/* Query rebuild information for BROWSE br-trans
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_cd-trans
      WHERE X_cd-trans.trans-type = p-trans-type NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "X_cd-trans.trans-type = p-trans-type"
     _Query            is NOT OPENED
*/  /* BROWSE br-trans */
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


&Scoped-define SELF-NAME b-chk-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chk-doc Dialog-Frame
ON CHOOSE OF b-chk-doc IN FRAME Dialog-Frame /* Чек */
DO:
define variable next-prev as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-chk-doc-rec as recid no-undo .
DEFINE BUFFER buf_chk-doc FOR ub.chk-doc.
assign
next-prev = '':U
v-cd-trans-recid = (if available X_cd-trans then recid(X_cd-trans) else ?)
.
DO WHILE next-prev = '':U:
    if NOT available X_cd-trans then do:
            message "Неправильно выбрана транзакция." view-as alert-box ERROR.
            return no-apply.
    end.
    IF X_cd-trans.chk-id = "" THEN DO:
      MESSAGE
      "Нет ссылки на чек для этой транзакции"
      VIEW-AS ALERT-BOX.
      undo, return no-apply.
    END.
    FIND FIRST buf_chk-doc NO-LOCK WHERE
               buf_chk-doc.chk-id = X_cd-trans.chk-id
           and buf_chk-doc.obj-type = X_cd-trans.obj-type
           and buf_chk-doc.obj-code = X_cd-trans.obj-code no-error .
    if not available buf_chk-doc then do:
      message
      substitute("Неверная ссылка на чек для этой транзакции&1id=&2"
                ,{&new-line}
                ,X_cd-trans.chk-id)
      view-as alert-box error .
      undo, return no-apply.
    end.
    v-chk-doc-rec = recid(buf_chk-doc).
    run str/superchk.w
                  (
                     input parparentproc
                    ,input {&lookup}
                    ,input buf_chk-doc.obj-type
                    ,input buf_chk-doc.obj-code
                    ,input-output v-chk-doc-rec
                    ,input this-procedure:handle
                    ,input-output next-prev
                                )
    .

END .
reposition br-trans to recid v-cd-trans-recid no-error.
apply "entry" to br-trans in frame {&frame-name}.
apply "value-changed" to br-trans in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable glog as logical no-undo .
  if available X_cd-trans then do:
    { gbl/markstrn.i X_cd-trans v-rid-list }
    glog = br-trans:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        glog = br-trans:select-next-row ().
        apply "VALUE-CHANGED" to br-trans in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        display
        num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-trans in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
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
    if ( available X_cd-trans ) AND ( v-rid-list = "" ) then
    v-rid-list = string( recid( X_cd-trans ) ) .



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-trans
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }


{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel  }

{ gbl/setfltnm.i }
{ gbl/brwrefre.i " v-rep-rec = ?. if available X_cd-trans then v-rep-rec = recid(X_cd-trans). RUn OpenBR in this-procedure ( input yes, input no, input '':U).  reposition br-trans to recid v-rep-rec no-error. " }

{ gbl/brwrepos.i
  &line-num=5
}


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }
  if lookup(p-list-mode, {&g___object} + {&comma-char} + "chk-id") = 0 THEN DO:
    message vss-workfile vss-revision vss-description skip
    "Неверный вызов - p-list-mode=" p-list-mode
    view-as alert-box ERROR.
    return.
  END.
  IF p-list-mode = {&g___object}
  OR p-list-mode = "chk-date":U THEN DO:
    FIND FIRST buf_obj No-LOCK WHERE
                buf_obj.obj-type = p-obj-type and
                buf_obj.obj-code = p-obj-code No-ERROR.
    if not avail buf_obj then do:
      message vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-obj-type и/или p-obj-code"
      p-obj-type p-obj-code
      view-as alert-box ERROR.
      return.
    end.
  end.
  IF p-list-mode = "chk-date":U then do:
      if p-start-date > p-end-date
      or p-start-date = ?
      or p-end-date = ?
      then do:
          message vss-workfile vss-revision vss-description skip
          "Неверное значение параметров p-start-date p-end-date" p-start-date p-end-date
          view-as alert-box ERROR.
          return.

    end.
  END.
  if this-procedure:instantiating-procedure:get-signature("cd-trans_cb")  <> "" then do:
    run cd-trans_cb in (this-procedure:INSTANTIATING-PROCEDURE) ( input ( buffer temp-param:handle)) no-error.
    if error-status:error then do:
       message
       substitute("Ошибка при инициализации параметров &1 в &2"
                  , this-procedure:file-name
                  , this-procedure:INSTANTIATING-PROCEDURE:file-name)
       view-as alert-box error .
       undo main-block, return error .
    end.
  end.
  RUN Myenable IN THIS-PROCEDURE.
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  /*
  { gbl/mv-clmn.i
    &browse-name = "br-trans"
    &frame-name = "{&frame-name}"
    &ext-col = 19
    &start-column = 7
    &prev-order-column_1 = "'1,2,3,19,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18'"
    &prev-order-column-condition_1 = " par-mode = ~{&TDEDT_inv~} "
    }
  */
  ASSIGN
  v-rid-list = p-rid-list.
  HIDE mark-num in frame {&frame-name} .
  if entry(1, v-rid-list) <> '':U then
  REPOSITION br-trans to recid integer(entry(1, v-rid-list)) No-ERROR.

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
  ENABLE b-quit b-mark b-sel b-chk-doc b-sch B-Help br-trans mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-h AS HANDLE NO-UNDO.
DEFINE VARIABLE v-chk-time-h AS HANDLE NO-UNDO.
DEFINE BUFFER buf_custom-labels FOR ub.custom-labels.
ASSIGN
v-h = br-trans:FIRST-COLUMN IN FRAME {&FRAME-NAME}
.
DO while valid-handle(v-h) :
 IF p-trans-type > 0  THEN DO:

    FIND FIRST buf_custom-labels NO-LOCK WHERE
            buf_custom-labels.CALL-TYPE = "cd-trans"
      AND buf_custom-labels.call-point = string(p-trans-type)
      AND buf_custom-labels.tbl-name = {&TABLE_cd-trans}
      AND buf_custom-labels.fld-name = v-h:NAME NO-ERROR.
    IF NOT AVAILABLE buf_custom-labels THEN DO:
       v-h:VISIBLE = NO.
    END.
    ELSE DO:
      ASSIGN
      v-h:visible = YES
      v-h:LABEL = buf_custom-labels.custom-label
      /*v-h:format = buf_custom-labels.custom-format*/
      v-h:width = max(buf_custom-labels.widget-width, length(buf_custom-labels.custom-label))
      v-h:RESIZABLE = (v-h:DATA-TYPE = {&abl-datatype-character})
      .
      if v-h:name = "charkey_one" then do:
        assign
        v-charkey-one-label = buf_custom-labels.custom-label
        .
      end.
      /*
      message
      v-h:LABEL
      v-h:format
      v-h:width
      view-as alert-box .
      */
    END.
  END.
  IF v-h:LABEL = {&label-time} THEN DO:
     v-chk-time-h = v-h.
  END.
  IF v-h:LABEL = {&label-trans-name} THEN DO:
     v-h:RESIZABLE = YES.
  END.
v-h = v-h:NEXT-COLUMN.
END.
CASE p-list-mode:
  WHEN {&g___Object} THEN DO:
      ASSIGN
      X_cd-trans.obj-type:VISIBLE IN BROWSE br-trans = NO
      X_cd-trans.obj-code:VISIBLE IN BROWSE br-trans = NO
      .
  END.
  WHEN "chk-id" THEN DO:
     ASSIGN
     X_cd-trans.chk-date:VISIBLE IN BROWSE br-trans = NO
     v-chk-time-h:VISIBLE = NO
     X_cd-trans.doc-code:VISIBLE IN BROWSE br-trans = NO
     X_cd-trans.obj-type:VISIBLE IN BROWSE br-trans = NO
     X_cd-trans.obj-code:VISIBLE IN BROWSE br-trans = NO
     X_cd-trans.pay-desk:VISIBLE IN BROWSE br-trans = NO
     X_cd-trans.out-code:VISIBLE IN BROWSE br-trans = NO
     .
  END.
END CASE.
DISPLAY
mark-num
WITH FRAME {&frame-name} .
ENABLE
b-quit
b-mark when lookup("b-sel", bttns) > 0
b-sel  when lookup("b-sel", bttns) > 0
b-chk-doc WHEN p-list-mode <> "chk-id"
b-sch
B-Help
br-trans
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
define variable sort-column-phrase as character no-undo .
DEFINE VARIABLE title0 AS CHARACTER NO-UNDO INIT "Список транзакций".

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

&scop flt-open-open-query OPEN QUERY br-trans FOR EACH X_cd-trans

&scop flt-open-dyn_open-query FOR EACH X_cd-trans

&scop flt-open-query-handle  QUERY br-trans:handle

&scop flt-open-open-query-tail


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_cd-trans

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_cd-trans

&Scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .
define variable v-tt-name as character no-undo .
if p-trans-type > 0 then
assign
v-tt-name = entry(lookup(string(p-trans-type), {&cdt-type-list})
                 , {&cdt-type-list-full})
.
  CASE p-list-mode :
    WHEN {&g___object} THEN DO:
      ASSIGN
      filter-point = filter-point0 + p-list-mode
      filter-label = SUBSTITUTE("&1 Один объект", filter-label0)
      .
      if p-open-query then do:
        frame {&frame-name}:TITLE = substitute("&1 Объект: &2&3 &4", title0 , p-obj-type , p-obj-code, v-tt-name).
      end.
      /*!!!!!!!!!!!!!!!!!!!!! формат даты при передаче в предикат должне совпадавть
      с формат представления текущей сессии а у нас это всегда dmy */

      { gbl/fltopend.i
        &where-cond = " ~
          X_cd-trans.obj-type  = p-obj-type  ~
          AND X_cd-trans.obj-code  = p-obj-code      ~
          AND X_cd-trans.trans-type  = p-trans-type     ~
                      "
        &dyn_where-cond = " substitute(' X_cd-trans.obj-type  = &1&2&1  ~
          AND X_cd-trans.obj-code  = &3      ~
          AND X_cd-trans.trans-type  = p-trans-type  ', ~{&double-quote~}, p-obj-type, p-obj-code) "

        &use-ind    = " USE-INDEX itype "
        &by         = "  " }

    END.
    WHEN "chk-id":U THEN DO:
      DEFINE VARIABLE v-chk-doc-code AS CHARACTER NO-UNDO.
      FIND FIRST buf_chk-doc NO-LOCK WHERE
            buf_chk-doc.chk-id = p-chk-id
        AND buf_chk-doc.obj-type = p-obj-type
        AND buf_chk-doc.obj-code = p-obj-code
        NO-ERROR.
      IF AVAILABLE buf_chk-doc THEN DO:
        v-chk-doc-code = buf_chk-doc.doc-code.
      END.

      ASSIGN
      filter-point = filter-point0 + p-list-mode
      filter-label = SUBSTITUTE("&1 Фискальные счетчики", filter-label0)
      .
      if p-open-query then do:
        IF v-chk-doc-code > '' THEN DO:
            FRAME {&frame-name}:TITLE = substitute((title0 + " Фискальные счетчики для чека &1 &2")
                                                        , v-chk-doc-code
                                                        , v-tt-name
                                                        )
                                                        .

        END.
        ELSE DO:
          FRAME {&frame-name}:TITLE = substitute((title0 + " Фискальные счетчики для чека с уник. ID &1 &2")
                                                      , p-chk-id
                                                      , v-tt-name
                                                      )
                                                      .
        END.
      end.
      { gbl/fltopend.i
        &where-cond = " ~
            X_cd-trans.obj-type  = p-obj-type  ~
            AND X_cd-trans.obj-code  = p-obj-code      ~
          AND X_cd-trans.chk-id  = p-chk-id    ~
                      "
        &dyn_where-cond = " substitute(' X_cd-trans.obj-type  = &1&2&1  ~
          AND X_cd-trans.obj-code  = &3      ~
          AND X_cd-trans.chk-id = &1&4&1', ~{&double-quote~},  p-obj-type, p-obj-code, p-chk-id) "

        &use-ind    = " USE-INDEX ichkid "
        &by         = " by X_cd-trans.trans-type " }
    end.

  END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-trans to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-trans:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-trans in frame {&frame-name}.
APPLY "ENTRY" TO br-trans.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
assign
  tbl = 'cd-trans'
  join-tbl = 'X_cd-trans'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .

run fltfield-add in this-procedure('doc-code', 'Номер в базе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-time', '', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-desk', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-id', 'ID чека', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('out-code', 'Номер продажи', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( input parparentproc
                   , INPUT filter-point
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-chk-doc Dialog-Frame
PROCEDURE reposition-chk-doc :
define input  parameter p-direction   as character no-undo .
define output parameter p-chk-doc-recid as recid no-undo .
DEFINE BUFFER buf_chk-doc FOR ub.chk-doc.
  /* перемещение на первую, последнюю, предыдущую, следующую */
  case p-direction :
    when "first":U
    then do:
      get first br-trans.
    end.
    when "last":U
    then do:
      get last br-trans.
    end.
    when "prev":U
    then do:
      get prev br-trans.
      if not available X_cd-trans then do:
        message
        "Это первая запись списка"
        view-as alert-box.
      end.
    end.
    when "next":U
    then do:
      get next br-trans.
      if not available X_cd-trans then do:
        message
        "Это последняя запись списка"
        view-as alert-box.
      end.
    end.
  end case . /* p-direction */
  FIND FIRST buf_chk-doc NO-LOCK WHERE
            buf_chk-doc.doc-code = X_cd-trans.doc-code no-error .
  assign
  p-chk-doc-recid = (if available buf_chk-doc
                     then recid(buf_chk-doc)
                     else ?)
  v-cd-trans-recid = RECID(X_cd-trans)
  .
  run reposition-query in this-procedure
    (input v-cd-trans-recid
    ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-query Dialog-Frame
PROCEDURE reposition-query :
define input parameter p-recid as recid no-undo .

  if p-recid <> ?
  then do:
    reposition br-trans to recid p-recid no-error.
  end.

  do with frame {&frame-name}:
    apply "entry":u to browse {&browse-name} .
    apply "VALUE-CHANGED":u to browse {&browse-name} .
  end. /* do with frame */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-trans-name Dialog-Frame
FUNCTION get-trans-name RETURNS CHARACTER
  ( p-trans-type AS INTEGER) :
DEFINE VARIABLE v-name AS CHARACTER NO-UNDO.
assign
v-name = entry(lookup(string(p-trans-type), {&cdt-type-list})
                 , {&cdt-type-list-full}) NO-ERROR
.
RETURN v-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
