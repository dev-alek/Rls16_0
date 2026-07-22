&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_c-variant-delivery FOR ub.c-variant-delivery.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_curr_clients FOR ub.clients.
DEFINE BUFFER X_delivery-subject FOR ub.delivery-subject.
DEFINE BUFFER X_delivery-type FOR ub.delivery-type.
DEFINE BUFFER X_variant-delivery FOR ub.variant-delivery.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список ИСТОРИИ ВАРИАНТОВ ДОСТАВКИ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 24/03/04
Author: Bakhtadze Natalya
Creation date: 24/03/04

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo.
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo.
define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/
define input parameter p-mode  as char   no-undo .
/*{&all} "delivery-type-subject" "one" {&g___object}*/
define input parameter p-deliv-type-code  LIKE ub.delivery-type.deliv-type-code   no-undo .
define input parameter p-deliv-subj-code  LIKE ub.delivery-subject.deliv-subj-code   no-undo .
define input parameter p-deliv-obj-type   LIKE ub.variant-delivery.obj-type   no-undo .
define input parameter p-deliv-obj-code   LIKE ub.variant-delivery.obj-code   no-undo .
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список ИСТОРИИ ВАРИАНТОВ ДОСТАВКИ":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ gbl/flt-def.i }
{ gbl/fltfield.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable filter-point as character no-undo init "Список истории вариантов доставки" .
define variable filter-point0 as character no-undo init "Список истории вариантов доставки" .


&SCOPED-DEFINE status-code STRING(X_c-variant-delivery.sts)

{ ref/tmpchgs.i }

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
&Scoped-define INTERNAL-TABLES temp-changes X_c-variant-delivery

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE br-vardeliv                                   */
&Scoped-define FIELDS-IN-QUERY-br-vardeliv mark-string(recid(X_c-variant-delivery), p-rid-list) usrfulnf(X_c-variant-delivery.corr-user-name) X_c-variant-delivery.corr-date string(X_c-variant-delivery.corr-time, "HH:MM") {&status-int-name} X_c-variant-delivery.deliv-type-code get-type(X_c-variant-delivery.deliv-type-code) X_c-variant-delivery.deliv-subj-code get-subject(X_c-variant-delivery.deliv-subj-code) X_c-variant-delivery.des
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-vardeliv
&Scoped-define SELF-NAME br-vardeliv
&Scoped-define QUERY-STRING-br-vardeliv FOR EACH X_c-variant-delivery NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-vardeliv OPEN QUERY {&SELF-NAME} FOR EACH X_c-variant-delivery NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-vardeliv X_c-variant-delivery
&Scoped-define FIRST-TABLE-IN-QUERY-br-vardeliv X_c-variant-delivery


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-vardeliv}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-Help br-vardeliv ~
BR-changes mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-subject Dialog-Frame
FUNCTION get-subject RETURNS CHARACTER
  ( INPUT p-deliv-subj-code AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-type Dialog-Frame
FUNCTION get-type RETURNS CHARACTER
( INPUT p-deliv-type-code AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.

DEFINE QUERY br-vardeliv FOR
      X_c-variant-delivery SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(40)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8.04.

DEFINE BROWSE br-vardeliv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-vardeliv Dialog-Frame _FREEFORM
  QUERY br-vardeliv NO-LOCK DISPLAY
      mark-string(recid(X_c-variant-delivery), p-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      usrfulnf(X_c-variant-delivery.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
      X_c-variant-delivery.corr-date COLUMN-LABEL "Дата!измен" FORMAT "99/99/9999":U
      string(X_c-variant-delivery.corr-time, "HH:MM") COLUMN-LABEL "Время!измен~"" FORMAT "X(5)":U
      {&status-int-name} COLUMN-LABEL "Статус"
      X_c-variant-delivery.deliv-type-code COLUMN-LABEL "Вн.код!типа!доставки" FORMAT ">>9":U
      get-type(X_c-variant-delivery.deliv-type-code) COLUMN-LABEL "Тип доставки" FORMAT "X(25)":U
      X_c-variant-delivery.deliv-subj-code COLUMN-LABEL "Вн.код!субъекта!доставки" FORMAT ">>9":U
      get-subject(X_c-variant-delivery.deliv-subj-code) COLUMN-LABEL "Субъект доставки" FORMAT "X(25)":U
      X_c-variant-delivery.des FORMAT "X(100)":U WIDTH 17.25
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 10.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     b-lkp AT ROW 1 COL 61
     B-Help AT ROW 1 COL 95
     br-vardeliv AT ROW 3 COL 1
     BR-changes AT ROW 14 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(78.62) SKIP(20.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История вариантов доставки"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_c-variant-delivery B "?" ? ub c-variant-delivery
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_curr_clients B "?" ? ub clients
      TABLE: X_delivery-subject B "?" ? ub delivery-subject
      TABLE: X_delivery-type B "?" ? ub delivery-type
      TABLE: X_variant-delivery B "?" ? ub variant-delivery
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-vardeliv B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes br-vardeliv Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-lkp IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       b-lkp:HIDDEN IN FRAME Dialog-Frame           = TRUE.

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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-vardeliv
/* Query rebuild information for BROWSE br-vardeliv
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-variant-delivery NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-vardeliv */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История вариантов доставки */
OR ENDKEY OF FRAME Dialog-Frame DO:
  run gbl/markqwa.p (
                           input b-mark:sensitive
                          , input p-rid-list) no-error.
  if error-status:error then return no-apply.

  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available X_c-variant-delivery then do:
    { gbl/markstrn.i X_c-variant-delivery p-rid-list }
    loc#log = br-vardeliv:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-vardeliv:select-next-row ().
        apply "VALUE-CHANGED" to br-vardeliv in frame {&frame-name}.
    end.
    if num-entries( p-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( p-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-vardeliv in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_c-variant-delivery ) then do:
    if  ( p-rid-list = "" ) or b-mark:sensitive = no
    then
    p-rid-list = string( recid( X_c-variant-delivery ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-vardeliv
&Scoped-define SELF-NAME br-vardeliv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-vardeliv Dialog-Frame
ON RETURN OF br-vardeliv IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-vardeliv IN FRAME Dialog-Frame
    DO:
    run proc-br-vardeliv no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-vardeliv Dialog-Frame
ON VALUE-CHANGED OF br-vardeliv IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure no-error.
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
{ gbl/app_help.i &disable_diasize_init=true &browse-name="BR-vardeliv" }
{ gbl/brwrefre.i "v-doc-rec = recid(X_c-variant-delivery). run OpenBr in this-procedure(yes, no, no). reposition br-vardeliv to recid v-doc-rec no-error. v-doc-rec = ?. ~
              apply 'value-changed' to br-vardeliv. " }

{ gbl/srt-clmd.i
  &browse-name    = "br-vardeliv"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_c-variant-delivery.deliv-type-code"
  &sort-clmn_2    = "X_c-variant-delivery.deliv-subj-code"
  &open-query     = "run OpenBr(yes, no, no)."
  &open-query-otherwise = "run OpenBr(yes, no, no)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}


{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  find first X_curr_clients no-lock where
            X_curr_clients.obj-type = p-curr-obj-type
       AND X_curr_clients.obj-code = p-curr-obj-code no-error.
  if not available X_curr_clients then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-curr-obj-type p-curr-obj-code"
    p-curr-obj-type p-curr-obj-code
    view-as alert-box ERROR.
    return error .
  end.
 if LOOKUP(p-mode, ({&all} + {&delim-par} + "delivery-type-subject" + {&delim-par} + "one" + {&delim-par} + {&g___object}) ,
                {&delim-par}) = 0
     then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return error .
 end.
 IF p-mode = "delivery-type-subject"
 or p-mode = "one":U
 THEN DO:
     FIND FIRST X_delivery-type NO-LOCK WHERE
                X_delivery-type.deliv-type-code = p-deliv-type-code NO-ERROR.
    IF NOT AVAILABLE X_delivery-type THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-deliv-type-code"
        p-DELIV-TYPE-CODE
        view-as alert-box ERROR.
        return error .
   END.
 END.
IF p-mode = "delivery-type-subject"
or p-mode = "one":U
THEN DO:
     FIND FIRST X_delivery-subject NO-LOCK WHERE
                X_delivery-subject.deliv-subj-code = p-deliv-subj-code NO-ERROR.
    IF NOT AVAILABLE X_delivery-type THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-deliv-subj-code"
        p-DELIV-subj-CODE
        view-as alert-box ERROR.
        return error .
   END.
 END.
 if p-mode = {&g___object}
 or p-mode = "one" then do:
    FIND FIRST X_clients no-lock where
              X_clients.obj-type = p-deliv-obj-type
         AND  X_clients.obj-code = p-deliv-obj-code no-error .
    if not available X_clients then do:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-deliv-obj-type и/или p-deliv-obj-code"
        p-DELIV-obj-type p-deliv-obj-CODE
        view-as alert-box ERROR.
        return error .
    end.
 end.

 { gbl/curdbnum.i v-db-num }
  RUN MyEnable.
  RUn OpenBR(yes, no, no).
  HIDE mark-num in frame {&frame-name} .
  if v-doc-rec <> ? then
  REPOSITION br-vardeliv to recid v-doc-rec No-ERROR.
    { gbl/mv-clmn.i
    &browse-name = "br-vardeliv"
    &frame-name = "{&frame-name}"
    &ext-col = 12
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11,12'"
    &prev-order-column-condition_1 = " p-mode = ~{&all~} "
    &prev-order-column_2 = "'1,2,3,4,5,10,11,12,6,7,8,9'"
    &prev-order-column-condition_2 = " p-mode = 'delivery-type-subject' "
    &prev-order-column_3 = "'1,2,3,4,5,6,7,8,9,11,12,10'"
    &prev-order-column-condition_3 = " p-mode = ~{&g___object~} "
    &prev-order-column_4 = "'1,2,3,4,5,11,12,6,7,8,9,10'"
    &prev-order-column-condition_4 = " p-mode = 'one' "
    }
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
  ENABLE b-quit B-mark B-sel B-Help br-vardeliv BR-changes mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
assign
temp-changes.l_name:resizable in browse br-changes = true
temp-changes.v_old:resizable in browse br-changes = true
temp-changes.v_new:resizable in browse br-changes = true
temp-changes.l_name:width in browse br-changes = 30
temp-changes.v_old:width in browse br-changes = 40
temp-changes.v_new:width in browse br-changes = 40
.
DISPLAY mark-num
WITH FRAME {&FRAME-NAME}.
ENABLE
b-quit
B-mark when LOOKUP("b-mark":U, bttns) > 0
B-sel when LOOKUP("b-sel":U, bttns) > 0
B-Help
br-vardeliv
mark-num
br-changes
with FRAME {&FRAME-NAME}.
VIEW FRAME {&FRAME-NAME}.
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
title0 = "Список истории вариантов доставки" + {&space-char}.
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

&scop flt-open-open-query OPEN QUERY br-vardeliv FOR EACH X_c-variant-delivery

&scop flt-open-dyn_open-query FOR EACH X_c-variant-delivery

&scop flt-open-query-handle QUERY br-vardeliv:handle

&scop flt-open-open-query-tail


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-variant-delivery

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_c-variant-delivery

&scop flt-open-waitfram true

define variable l-open-query as logical   no-undo .


  CASE p-mode :
    WHEN {&all}        THEN DO:
     filter-point = filter-point0 + p-mode.
     { gbl/fltopend.i
        &where-cond = " TRUE "
        &use-ind    = "  "
        &by         = "  " }
    END.
    WHEN "delivery-type-subject" THEN DO:
       filter-point = filter-point0 + p-mode.
       ASSIGN
       frame {&frame-name}:TITLE = title0 +
                                   substitute(" Тип доставки: &1 Субъект доставки: &2"
                                   , X_delivery-type.deliv-type-name
                                   , X_delivery-subject.deliv-subj-name
                                   ).
      { gbl/fltopend.i
        &where-cond = " ~
          X_c-variant-delivery.deliv-type-code  = p-deliv-type-code    ~
      AND X_c-variant-delivery.deliv-subj-code  = p-deliv-subj-code    ~
                      "
        &dyn_where-cond = " substitute(' X_c-variant-delivery.deliv-type-code  = &1    ~
      AND X_c-variant-delivery.deliv-subj-code  = &2', p-deliv-type-code, p-deliv-subj-code) "

        &use-ind    = "  "
        &by         = "  " }
    END.
  WHEN "one" THEN DO:
     filter-point = filter-point0 + p-mode.
     ASSIGN
     frame {&frame-name}:TITLE = title0 +
                                 substitute(" Тип доставки: &1 Субъект доставки: &2 Объект доставки &3&4"
                                 , X_delivery-type.deliv-type-name
                                 , X_delivery-subject.deliv-subj-name
                                  , X_clients.obj-type
                                  , X_clients.obj-code
                                 ).
    { gbl/fltopend.i
      &where-cond = " ~
        X_c-variant-delivery.deliv-subj-code  = p-deliv-subj-code    ~
        AND X_c-variant-delivery.deliv-type-code  = p-deliv-type-code    ~
        AND X_c-variant-delivery.obj-type         = p-deliv-obj-type    ~
        AND X_c-variant-delivery.obj-code         = p-deliv-obj-code    ~
                    "
      &dyn_where-cond = " substitute(' X_c-variant-delivery.deliv-subj-code  = &1    ~
        AND X_c-variant-delivery.deliv-type-code  = &2    ~
        AND X_c-variant-delivery.obj-type         = &3    ~
        AND X_c-variant-delivery.obj-code         = &4 ', p-deliv-subj-code, p-deliv-type-code, p-deliv-obj-type, p-deliv-obj-code) "

      &use-ind    = "  "
      &by         = "  " }
  END.
  WHEN {&g___object} THEN DO:
     filter-point = filter-point0 + p-mode.
     ASSIGN
     frame {&frame-name}:TITLE = title0 +
                                 substitute(" Объект доставки &3&4"
                                 , X_delivery-type.deliv-type-name
                                 , X_delivery-subject.deliv-subj-name
                                  , X_clients.obj-type
                                  , X_clients.obj-code
                                 ).
    { gbl/fltopend.i
      &where-cond = " ~
            X_c-variant-delivery.obj-type         = p-deliv-obj-type    ~
        AND X_c-variant-delivery.obj-code         = p-deliv-obj-code    ~
                    "
      &dyn_where-cond = " substitute(' X_c-variant-delivery.obj-type         = &1    ~
        AND X_c-variant-delivery.obj-code         = &2 ', p-deliv-obj-type, p-deliv-obj-code) "

      &use-ind    = "  "
      &by         = "  " }
  END.




END CASE.
if not p-open-query then
REPOSITION br-vardeliv to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-vardeliv:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-vardeliv in frame {&frame-name}.
APPLY "ENTRY" TO br-vardeliv.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-vardeliv Dialog-Frame
PROCEDURE proc-br-vardeliv :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ ref/brwsretr.i  b-lkp }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame
PROCEDURE proc-view-changes :
for each temp-changes:
    delete temp-changes.
END.
if not available X_c-variant-delivery then do:
  Open QUery br-changes for each temp-changes.
  return.
end.

 &scop fields-name-list "des,deliv-type-code,deliv-subj-code,obj-type,obj-code,term-delivery,sts"

define variable v-label-param as character no-undo .

v-label-param =
  "des" + {&delim-par} + "Описание" + {&delim-par} + "" + {&delim-flf}
 + "deliv-type-code" + {&delim-par} + "Внутр.код типа доставки" + {&delim-par} + "" + {&delim-flf}
 + "deliv-subj-code" + {&delim-par} + "Внутр.код субеъкта доставки" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта доставки" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта доставки" + {&delim-par} + "" + {&delim-flf}
 + "term-delivery" + {&delim-par} + "Срок доставки(дней)" + {&delim-par} + "" + {&delim-flf}
 + "sts" + {&delim-par} + "Статус" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  buffer X_c-variant-delivery:handle
                                            ,input  {&table_variant-delivery}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


Open QUery br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-subject Dialog-Frame
FUNCTION get-subject RETURNS CHARACTER
  ( INPUT p-deliv-subj-code AS INTEGER) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
DEFINE BUFFER loc_delivery-subject FOR ub.delivery-subject.
FIND FIRST loc_delivery-subject NO-LOCK WHERE
          loc_delivery-subject.deliv-subj-code = p-deliv-subj-code NO-ERROR.
IF AVAILABLE loc_delivery-subject THEN RETURN loc_delivery-subject.deliv-subj-name.
  RETURN "Неизв.субъект доставки".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-type Dialog-Frame
FUNCTION get-type RETURNS CHARACTER
( INPUT p-deliv-type-code AS INTEGER) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
DEFINE BUFFER loc_delivery-type FOR ub.delivery-type.
FIND FIRST loc_delivery-type NO-LOCK WHERE
          loc_delivery-type.deliv-type-code = p-deliv-type-code NO-ERROR.
IF AVAILABLE loc_delivery-type THEN RETURN loc_delivery-type.deliv-type-name.
  RETURN "Неизв.тип доставки".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
