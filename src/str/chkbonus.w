&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_chk-bonus FOR ub.chk-discnt.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список бонусов, начисленных на кассе

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
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input parameter p-start-date like ub.chk-doc.chk-date no-undo .
define input parameter p-end-date like ub.chk-doc.chk-date no-undo .
define output PARAMETER p-rid-list    as  CHARACTER no-undo . /* список recid'ов выбранных  */


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список бонусов, начисленных на кассе".

define variable filter-label as character no-undo init "Список бонусов, начисленных на кассе" .
define variable filter-label0 as character no-undo init "Список бонусов, начисленных на кассе" .
define variable filter-point0 as character no-undo init "chkbonus" .
define variable filter-point as character no-undo init "chkbonus" .
define variable sort-column-name as character no-undo .
define variable print-type as character no-undo.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rep-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-chk-bonus-recid as recid no-undo .
DEFINE BUFFER buf_obj FOR ub.clients.

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

&scop discnt-target-code string(X_chk-bonus.line-type)

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-bonus

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_chk-bonus

/* Definitions for BROWSE br-bonus                                      */
&Scoped-define FIELDS-IN-QUERY-br-bonus mark-string(recid(X_chk-bonus), v-rid-list) X_chk-bonus.chk-date string(X_chk-bonus.chk-time, "HH:MM") X_chk-bonus.discnt-value-abs {&discnt-target-name} X_chk-bonus.doc-code X_chk-bonus.obj-type X_chk-bonus.obj-code X_chk-bonus.object-line-num X_chk-bonus.out-code X_chk-bonus.src-d-card X_chk-bonus.discnt-type X_chk-bonus.kateg X_chk-bonus.discnt-id
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-bonus
&Scoped-define SELF-NAME br-bonus
&Scoped-define QUERY-STRING-br-bonus FOR EACH X_chk-bonus       WHERE X_chk-bonus.record-type = 4 NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-bonus OPEN QUERY {&SELF-NAME} FOR EACH X_chk-bonus       WHERE X_chk-bonus.record-type = 4 NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-bonus X_chk-bonus
&Scoped-define FIRST-TABLE-IN-QUERY-br-bonus X_chk-bonus


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-chk-doc b-sch B-Help ~
br-bonus sch-code sch-date sch-sum mark-num
&Scoped-Define DISPLAYED-OBJECTS sch-code sch-date sch-sum mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
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

DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(20)":U
     LABEL "№ чека"
     VIEW-AS FILL-IN
     SIZE 21 BY 1 NO-UNDO.

DEFINE VARIABLE sch-date AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE sch-sum AS CHARACTER FORMAT "X(256)":U
     LABEL "Кол-во бонусов"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-bonus FOR
      X_chk-bonus SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-bonus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-bonus Dialog-Frame _FREEFORM
  QUERY br-bonus NO-LOCK DISPLAY
      mark-string(recid(X_chk-bonus), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
X_chk-bonus.chk-date COLUMN-LABEL "Дата" FORMAT "99/99/9999":U
string(X_chk-bonus.chk-time, "HH:MM") COLUMN-LABEL "Время" FORMAT "X(5)"
X_chk-bonus.discnt-value-abs COLUMN-LABEL "Кол-во бонусов" FORMAT "->>>,>>>,>>9.99":U
{&discnt-target-name} COLUMN-LABEL "Объект бонуса" FORMAT "X(20)"
X_chk-bonus.doc-code COLUMN-LABEL "Номер чека" FORMAT "X(20)":U
X_chk-bonus.obj-type COLUMN-LABEL "Тип!Объ" FORMAT "X(3)":U
X_chk-bonus.obj-code COLUMN-LABEL "Код!обЪ" FORMAT ">>>>9":U
X_chk-bonus.object-line-num COLUMN-LABEL "N строки товара!-объекта" FORMAT "999":U
X_chk-bonus.out-code COLUMN-LABEL "Номер_РН" FORMAT "X(14)":U
X_chk-bonus.src-d-card COLUMN-LABEL "№ Карты!для начисления" FORMAT "X(19)":U
X_chk-bonus.discnt-type COLUMN-LABEL "№ схемы!начисления"
X_chk-bonus.kateg COLUMN-LABEL "Код !валюты" FORMAT "->>>9"
X_chk-bonus.discnt-id COLUMN-LABEL "ID транзакц" FORMAT ">>>>>>>>9"
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
     br-bonus AT ROW 2 COL 1 WIDGET-ID 100
     sch-code AT ROW 22.27 COL 17 COLON-ALIGNED WIDGET-ID 64
     sch-date AT ROW 22.27 COL 44.5 COLON-ALIGNED WIDGET-ID 56
     sch-sum AT ROW 22.27 COL 76 COLON-ALIGNED WIDGET-ID 66
     mark-num AT ROW 1 COL 9 COLON-ALIGNED NO-LABEL WIDGET-ID 62
     "Поиск по:" VIEW-AS TEXT
          SIZE 11 BY 1.27 AT ROW 22 COL 1 WIDGET-ID 58
          FGCOLOR 4
     SPACE(87.75) SKIP(0.00)
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
      TABLE: X_chk-bonus B "?" ? ub chk-discnt
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-bonus B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-bonus
/* Query rebuild information for BROWSE br-bonus
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_chk-bonus
      WHERE X_chk-bonus.record-type = 4 NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "X_chk-bonus.record-type = 4"
     _Query            is NOT OPENED
*/  /* BROWSE br-bonus */
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
v-chk-bonus-recid = (if available X_chk-bonus then recid(X_chk-bonus) else ?)
.
DO WHILE next-prev = '':U:
    if NOT available X_chk-bonus then do:
            message "Неправильно выбрана строка бонусов." view-as alert-box ERROR.
            return no-apply.
    end.
    FIND FIRST buf_chk-doc NO-LOCK WHERE
               buf_chk-doc.doc-code = X_chk-bonus.doc-code.
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
reposition br-bonus to recid v-chk-bonus-recid no-error.
apply "entry" to br-bonus in frame {&frame-name}.
apply "value-changed" to br-bonus in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable glog as logical no-undo .
  if available X_chk-bonus then do:
    { gbl/markstrn.i X_chk-bonus v-rid-list }
    glog = br-bonus:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        glog = br-bonus:select-next-row ().
        apply "VALUE-CHANGED" to br-bonus in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        display
        num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-bonus in frame {&frame-name}.

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
    if ( available X_chk-bonus ) AND ( v-rid-list = "" ) then
    v-rid-list = string( recid( X_chk-bonus ) ) .



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* № чека */
DO:
    run proc-find-code in this-procedure ( input yes, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame /* № чека */
DO:
    run proc-find-code in this-procedure ( input NO, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON CTRL-J OF sch-date IN FRAME Dialog-Frame /* Дата */
DO:
    run proc-find-date in this-procedure ( input YES, input frame {&frame-name} sch-date) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON RETURN OF sch-date IN FRAME Dialog-Frame /* Дата */
DO:
  run proc-find-date in this-procedure ( input no, input frame {&frame-name} sch-date) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-sum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-sum Dialog-Frame
ON CTRL-J OF sch-sum IN FRAME Dialog-Frame /* Кол-во бонусов */
DO:
    run proc-find-sum in this-procedure ( input NO, input frame {&frame-name} sch-sum) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-sum Dialog-Frame
ON RETURN OF sch-sum IN FRAME Dialog-Frame /* Кол-во бонусов */
DO:
  run proc-find-sum in this-procedure ( input NO, input frame {&frame-name} sch-sum) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-bonus
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
{ gbl/ed_date.i sch-date }
{ gbl/brwrefre.i " v-rep-rec = ?. if available X_chk-bonus then v-rep-rec = recid(X_chk-bonus). RUn OpenBR in this-procedure ( input yes, input no, input '':U).  reposition br-bonus to recid v-rep-rec no-error. " }

{ gbl/brwrepos.i
  &line-num=5
}


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }
  if lookup(p-list-mode, {&g___object} + {&comma-char} + "chk-date") = 0 THEN DO:
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
  RUN Myenable IN THIS-PROCEDURE.
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  /*
  { gbl/mv-clmn.i
    &browse-name = "br-bonus"
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
  REPOSITION br-bonus to recid integer(entry(1, v-rid-list)) No-ERROR.

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
  DISPLAY sch-code sch-date sch-sum mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel b-chk-doc b-sch B-Help br-bonus sch-code sch-date
         sch-sum mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DISPLAY
sch-code
sch-date
sch-sum
mark-num
WITH FRAME {&frame-name} .
ENABLE
b-quit
b-mark when lookup("b-sel", bttns) > 0
b-sel  when lookup("b-sel", bttns) > 0
b-chk-doc
b-sch
B-Help
br-bonus
sch-code
sch-date
sch-sum
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
DEFINE VARIABLE title0 AS CHARACTER NO-UNDO INIT "Список бонусов, начисленных на кассе".

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

&scop flt-open-open-query OPEN QUERY br-bonus FOR EACH X_chk-bonus

&scop flt-open-dyn_open-query FOR EACH X_chk-bonus

&scop flt-open-query-handle  QUERY br-bonus:handle

&scop flt-open-open-query-tail


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_chk-bonus

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_chk-bonus

&Scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .

  CASE p-list-mode :
    WHEN {&g___object} THEN DO:
      ASSIGN
      filter-point = filter-point0 + p-list-mode
      filter-label = SUBSTITUTE("&1 Один объект", filter-label0)
      .
      if p-open-query then do:
        frame {&frame-name}:TITLE = substitute("&1 Объект: &2&3", title0 , p-obj-type , p-obj-code).
      end.
      /*!!!!!!!!!!!!!!!!!!!!! формат даты при передаче в предикат должне совпадавть
      с формат представления текущей сессии а у нас это всегда dmy */

      { gbl/fltopend.i
        &where-cond = " ~
          X_chk-bonus.obj-type  = p-obj-type  ~
          AND X_chk-bonus.obj-code  = p-obj-code      ~
          AND X_chk-bonus.chk-date  >= 01/01/1990      ~
          AND X_chk-bonus.chk-date  <= 12/31/9999      ~
          AND X_chk-bonus.record-type  = 4     ~
                      "
        &dyn_where-cond = " substitute(' X_chk-bonus.obj-type  = &1&2&1  ~
          AND X_chk-bonus.obj-code  = &3      ~
          AND X_chk-bonus.chk-date  >= 01/01/1990 ~
          AND X_chk-bonus.chk-date  <= 31/12/9999      ~
          AND X_chk-bonus.record-type  = 4  ', ~{&double-quote~}, p-obj-type, p-obj-code) "

        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " }

    END.
    WHEN "chk-date":U THEN DO:
      ASSIGN
      filter-point = filter-point0 + p-list-mode
      filter-label = SUBSTITUTE("&1 Один объект, период времени", filter-label0)
      .
      if p-open-query then do:
        FRAME {&frame-name}:TITLE = substitute((title0 + " Объект: &1&2 c &3 по &4")
                                                      , p-obj-type
                                                      , p-obj-code
                                                      , string(p-start-date)
                                                      , string(p-end-date))
                                                      .
      end.
      { gbl/fltopend.i
        &where-cond = " ~
          X_chk-bonus.obj-type  = p-obj-type  ~
          AND X_chk-bonus.obj-code  = p-obj-code      ~
          AND X_chk-bonus.chk-date  >= p-start-date      ~
          AND X_chk-bonus.chk-date  <= p-end-date      ~
          AND X_chk-bonus.record-type  = 4     ~
                      "
        &dyn_where-cond = " substitute(' X_chk-bonus.obj-type  = &1&2&1  ~
          AND X_chk-bonus.obj-code  = &3      ~
          AND X_chk-bonus.chk-date  >= &4      ~
          AND X_chk-bonus.chk-date  <= &5      ~
          AND X_chk-bonus.record-type  = 4 ', ~{&double-quote~}, p-obj-type, p-obj-code, p-start-date, p-end-date) "

        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " }
    end.
  END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-bonus to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-bonus:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-bonus in frame {&frame-name}.
APPLY "ENTRY" TO br-bonus.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
assign
  tbl = 'chk-discnt'
  join-tbl = 'X_chk-bonus'
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
run fltfield-add in this-procedure('discnt-value-abs', 'Кол-во бонусов', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('out-code', 'Номер продажи', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('d-card', 'N дис.карты', '',
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-code Dialog-Frame
PROCEDURE proc-find-code :
define input parameter par-next as logical no-undo.
define input parameter p-doc-code like ub.chk-doc.doc-code no-undo.
assign
sch-date = ?
.
display
sch-date
0 @ sch-sum
with frame {&frame-name}.
assign
p-doc-code = {&double-quote} + p-doc-code + {&double-quote}.
run OpenBr in this-procedure (
     input false /* p-open-query */
    ,input par-next  /* p-find-next  */
    ,input substitute("and X_chk-bonus.doc-code   begins &1 "
      , p-doc-code)
    ).
apply "entry":u to sch-code in frame {&frame-name} .



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-date Dialog-Frame
PROCEDURE proc-find-date :
define input parameter par-next as logical no-undo.
define input parameter parchk-date like ub.chk-doc.chk-date no-undo.
define variable varchk-datechr as character no-undo.
display
'':U @ sch-code
0 @ sch-sum
with frame {&frame-name}.

assign
varchk-datechr = string(day(parchk-date)) + {&slash-char} +
                 string(month(parchk-date)) + {&slash-char} +
                 string(year(parchk-date)).


run OpenBr in this-procedure (
   input false /* p-open-query */
  ,input true  /* p-find-next  */
  ,input substitute("and X_chk-bonus.chk-date = &1 "
    , varchk-datechr)
  ).
apply "entry":u to sch-date in frame {&frame-name}.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-sum Dialog-Frame
PROCEDURE proc-find-sum :
define input parameter par-next as logical no-undo.
define input parameter p-value-abs like ub.chk-discnt.discnt-value-abs no-undo.
assign
sch-date = ?
.

display
sch-date
"":U @ sch-code
with frame {&frame-name}.
/*assign
par-netto = {&double-quote} + pardoc-code + {&double-quote}.*/
run OpenBr in this-procedure (
     input false /* p-open-query */
    ,input par-next  /* p-find-next  */
    ,input substitute("and X_chk-bonus.discnt-value-abs = &1 "
      , p-value-abs)
    ).
apply "entry":u to sch-sum in frame {&frame-name} .


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
      get first br-bonus.
    end.
    when "last":U
    then do:
      get last br-bonus.
    end.
    when "prev":U
    then do:
      get prev br-bonus.
      if not available X_chk-bonus then do:
        message
        "Это первая запись списка"
        view-as alert-box.
      end.
    end.
    when "next":U
    then do:
      get next br-bonus.
      if not available X_chk-bonus then do:
        message
        "Это последняя запись списка"
        view-as alert-box.
      end.
    end.
  end case . /* p-direction */
  FIND FIRST buf_chk-doc NO-LOCK WHERE
            buf_chk-doc.doc-code = X_chk-bonus.doc-code no-error .
  assign
  p-chk-doc-recid = (if available buf_chk-doc
                     then recid(buf_chk-doc)
                     else ?)
  v-chk-bonus-recid = RECID(X_chk-bonus)
  .
  run reposition-query in this-procedure
    (input v-chk-bonus-recid
    ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-query Dialog-Frame
PROCEDURE reposition-query :
define input parameter p-recid as recid no-undo .

  if p-recid <> ?
  then do:
    reposition br-bonus to recid p-recid no-error.
  end.

  do with frame {&frame-name}:
    apply "entry":u to browse {&browse-name} .
    apply "VALUE-CHANGED":u to browse {&browse-name} .
  end. /* do with frame */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
