&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_trn-doc FOR ub.trn-doc.
DEFINE NEW SHARED BUFFER X_bar-code FOR ub.bar-code.
DEFINE NEW SHARED BUFFER X_chk-doc FOR ub.chk-doc.
DEFINE NEW SHARED BUFFER X_chk-gds FOR ub.chk-gds.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE NEW SHARED BUFFER X_goods FOR ub.goods.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список строк инвентаризации, полученных с кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

ПРОГРАММИСТ!!! НЕ ЗАБУДЬ ИСПРАВИТЬ new shared query br-invline
   подставить new shared в DEFINE QUERY query-chk-doc !!!!!!!


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER bttns AS character NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS character NO-UNDO.
/*может быть "calc" "not-calc" ""*/
DEFINE INPUT PARAMETER p-doc-code AS character NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rid-list AS character NO-UNDO.
DEFINE SHARED BUFFER t-doc FOR ub.trn-doc.

/* Local Variable Definitions ---                                       */
DEFINE VARIABLE vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список строк инвентаризации, полученных с кассы".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i DEF }
{ gbl/flt-def.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/fltfield.i }
{ gbl/prn-lib.i }
{ cmp/mrk-strf.i }
{ cmp/operlist.i }
{ str/libbcrcn.i }
{ gbl/fltopend.i defproc }
define variable filter-label0 as character no-undo init "Список строк инвентаризации с кассы" .
define variable filter-point0 as character no-undo INIT "invcdlin":U .
define variable filter-label as character NO-UNDO .
define variable filter-point as character no-undo.

define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable gds-rec as recid no-undo .
DEFINE BUFFER FIND_chk-gds FOR ub.chk-gds.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-invline
&Scoped-define QUERY-NAME QUERY-chk-doc

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_chk-gds X_bar-code X_goods X_chk-doc

/* Definitions for BROWSE br-invline                                    */
&Scoped-define FIELDS-IN-QUERY-br-invline mark-string(recid(X_chk-gds), v-rid-list) not (X_chk-gds.is-error) X_chk-gds.b-code X_chk-gds.doc-qnty X_bar-code.unit-cli X_goods.gds-name X_bar-code.gds-code get-prt-name ( buffer X_bar-code, buffer X_goods) X_chk-gds.src-code X_chk-gds.src-qnty X_chk-gds.line-num X_chk-gds.doc-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-invline X_chk-gds.src-qnty
&Scoped-define ENABLED-TABLES-IN-QUERY-br-invline X_chk-gds
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-invline X_chk-gds
&Scoped-define SELF-NAME br-invline
&Scoped-define QUERY-STRING-br-invline FOR EACH X_chk-gds NO-LOCK, ~
             EACH X_bar-code OF X_chk-gds OUTER-JOIN NO-LOCK, ~
             EACH X_goods OF X_bar-code OUTER-JOIN NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-invline OPEN QUERY {&SELF-NAME} FOR EACH X_chk-gds NO-LOCK, ~
             EACH X_bar-code OF X_chk-gds OUTER-JOIN NO-LOCK, ~
             EACH X_goods OF X_bar-code OUTER-JOIN NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-invline X_chk-gds X_bar-code X_goods
&Scoped-define FIRST-TABLE-IN-QUERY-br-invline X_chk-gds
&Scoped-define SECOND-TABLE-IN-QUERY-br-invline X_bar-code
&Scoped-define THIRD-TABLE-IN-QUERY-br-invline X_goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-invline}

/* Definitions for QUERY QUERY-chk-doc                                  */
&Scoped-define QUERY-STRING-QUERY-chk-doc FOR EACH X_chk-doc ~
      WHERE X_chk-doc.obj-type = p-obj-type ~
 AND X_chk-doc.obj-code = p-obj-code ~
 AND X_chk-doc.out-code = ? NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-QUERY-chk-doc OPEN QUERY QUERY-chk-doc FOR EACH X_chk-doc ~
      WHERE X_chk-doc.obj-type = p-obj-type ~
 AND X_chk-doc.obj-code = p-obj-code ~
 AND X_chk-doc.out-code = ? NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-QUERY-chk-doc X_chk-doc
&Scoped-define FIRST-TABLE-IN-QUERY-QUERY-chk-doc X_chk-doc


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel b-calc B-sch B-print ~
B-Help rs-calc sch-code br-invline mark-num f-prod-name
&Scoped-Define DISPLAYED-OBJECTS rs-calc sch-code mark-num f-prod-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-prt-name Dialog-Frame
FUNCTION get-prt-name RETURNS CHARACTER (  BUFFER buf_bar-code FOR ub.bar-code, BUFFER buf_goods FOR ub.goods )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-calc
     LABEL "&Посчитать"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-prod-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Произв-ль"
      VIEW-AS TEXT
     SIZE 87.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(16)":U
     LABEL "Код"
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE rs-calc AS LOGICAL
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", ?,
"Посчитанные", yes,
"Непосчитанные", no
     SIZE 40 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE NEW SHARED QUERY br-invline FOR
      X_chk-gds,
      X_bar-code,
      X_goods SCROLLING.

DEFINE NEW SHARED QUERY QUERY-chk-doc FOR
      X_chk-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-invline
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-invline Dialog-Frame _FREEFORM
  QUERY br-invline NO-LOCK DISPLAY
      mark-string(recid(X_chk-gds), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
            WIDTH 2
      not (X_chk-gds.is-error) COLUMN-LABEL "Посчи!тан" FORMAT "+/":U
      X_chk-gds.b-code FORMAT "999999999":U
      X_chk-gds.doc-qnty FORMAT "->>,>>>,>>9.<<<":U
      X_bar-code.unit-cli COLUMN-LABEL "Ед.!изм." FORMAT "X(3)":U
      X_goods.gds-name FORMAT "X(48)":U
      X_bar-code.gds-code FORMAT "999999999":U
      get-prt-name ( buffer X_bar-code, buffer X_goods) COLUMN-LABEL "Шкала" FORMAT "X(20)":U
            WIDTH 21
      X_chk-gds.src-code COLUMN-LABEL "Бар-код в чеке" FORMAT "X(16)":U
      X_chk-gds.src-qnty FORMAT "->>,>>>,>>9.<<<":U
      X_chk-gds.line-num COLUMN-LABEL "Строка" FORMAT "99999":U
      X_chk-gds.doc-code COLUMN-LABEL "Номер чека" FORMAT "X(20)":U
  ENABLE
      X_chk-gds.src-qnty
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 19 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     b-calc AT ROW 1 COL 51
     B-sch AT ROW 1 COL 61
     B-print AT ROW 1 COL 71
     B-Help AT ROW 1 COL 81
     rs-calc AT ROW 2 COL 2 NO-LABEL
     sch-code AT ROW 2 COL 49 COLON-ALIGNED
     br-invline AT ROW 3 COL 1.5
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     f-prod-name AT ROW 22.25 COL 1
     SPACE(0.24) SKIP(0.15)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список строк инвентаризации по кассе"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_trn-doc B "?" ? ub trn-doc
      TABLE: X_bar-code B "NEW SHARED" ? ub bar-code
      TABLE: X_chk-doc B "NEW SHARED" ? ub chk-doc
      TABLE: X_chk-gds B "NEW SHARED" NO-UNDO ub chk-gds
      TABLE: X_clients B "?" NO-UNDO ub clients
      TABLE: X_goods B "NEW SHARED" NO-UNDO ub goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB br-invline sch-code Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-prod-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-invline
/* Query rebuild information for BROWSE br-invline
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_chk-gds NO-LOCK,
      EACH X_bar-code OF X_chk-gds OUTER-JOIN NO-LOCK,
      EACH X_goods OF X_bar-code OUTER-JOIN NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _TblOptList       = ", OUTER, OUTER"
     _Query            is OPENED
*/  /* BROWSE br-invline */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK QUERY QUERY-chk-doc
/* Query rebuild information for QUERY QUERY-chk-doc
     _TblList          = "X_chk-doc"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "X_chk-doc.obj-type = p-obj-type
 AND X_chk-doc.obj-code = p-obj-code
 AND X_chk-doc.out-code = ?"
     _Design-Parent    is DIALOG-BOX Dialog-Frame @ ( 1.25 , 45 )
*/  /* QUERY QUERY-chk-doc */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список строк инвентаризации по кассе */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-calc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-calc Dialog-Frame
ON CHOOSE OF b-calc IN FRAME Dialog-Frame /* Посчитать */
DO:
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-ii-ok AS INTEGER NO-UNDO.
DEFINE VARIABLE is-all AS logical NO-UNDO.
DEFINE VARIABLE v-num AS INTEGER NO-UNDO.
define variable jj as integer no-undo .
define variable v-rec as recid no-undo .
DEFINE BUFFER buf_chk-doc FOR ub.chk-doc.
IF NOT AVAILABLE X_chk-gds THEN RETURN NO-APPLY.
  run str/inc-invd.w (
                   input parparentproc
                  ,input {&update}
                  ,input '':U
                  ,input (if v-rid-list = '':u then string(recid(X_chk-gds)) else v-rid-list) /*список recid стрко чеков*/
                  ,input buf_trn-doc.obj-type
                  ,input buf_trn-doc.obj-code
                  ,buffer buf_trn-doc
                  ) NO-ERROR.

if error-status:error then do:
  message error-status:get-message(1) return-value view-as alert-box .
end.
run Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U) NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
 DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  if available X_chk-gds then do:
    { gbl/markstrn.i X_chk-gds v-rid-list }
    glog = br-invline:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-invline:select-next-row ().
      apply "VALUE-CHANGED" to br-invline in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-invline in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print IN THIS-PROCEDURE ( input rs-calc) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
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
  if ( available X_chk-gds )
  AND (( v-rid-list = "" )
       or b-mark:sensitive in frame {&frame-name} = no) then
    v-rid-list = string( recid( X_chk-gds ) ) .
  p-rid-list = v-rid-list.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-invline
&Scoped-define SELF-NAME br-invline
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-invline Dialog-Frame
ON VALUE-CHANGED OF br-invline IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE X_goods THEN DO:
     f-prod-name = '':U.
  END.
  ELSE DO:
    FIND FIRST X_clients NO-LOCK WHERE
            X_clients.obj-type = X_goods.prod-type
        AND X_clients.obj-code = X_goods.prod-code NO-ERROR.
    IF AVAILABLE X_clients THEN DO:
       f-prod-name = X_clients.obj-name.
    END.
    ELSE DO:
        f-prod-name = X_clients.obj-type + {&space-char} + string(X_clients.obj-code).
    END.
  END.
  DISPLAY
  f-prod-name WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-calc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-calc Dialog-Frame
ON VALUE-CHANGED OF rs-calc IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-calc.
  run Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U) NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* Код */
DO:
  run proc-find-code in this-procedure ( input yes, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame /* Код */
DO:
  run proc-find-code in this-procedure ( input no, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.
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
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }
{ gbl/brwrefre.i " v-doc-rec = recid(X_chk-gds). run OpenBR in this-procedure ( input yes, input no, input '':U).  reposition br-invline to recid v-doc-rec no-error. ~
               APPLY 'VALUE-CHANGED' to br-invline. " }

{ gbl/srt-clmd.i
  &browse-name    = "br-invline"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_chk-gds.src-code"
  &sort-clmn_2    = "X_chk-gds.src-qnty"
  &sort-clmn_3    = "X_chk-gds.doc-qnty"
  &sort-clmn_4    = "X_chk-gds.b-code"
  &sort-clmn_5    = "X_goods.gds-name"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/brwrepos.i
  &line-num=5
}


{ gbl/mv-clmn.i
  &browse-name = "br-invline"
  &frame-name = "{&frame-name}"
  &ext-col = 12
  &start-column = 4
  &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11,12'"
  &prev-order-column-condition_1 = " rs-calc = ? or rs-calc = yes "
  &prev-order-column_2 = "'1,2,9,10,3,4,5,6,7,11,12'"
  &prev-order-column-condition_1 = " rs-calc = no "

    }

{ gbl/f2.i br-invline goods-recid get-goods-recid parparentproc }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i GET }
  FIND FIRST buf_trn-doc NO-LOCK WHERE
            buf_trn-doc.doc-code = p-doc-code NO-ERROR.
  IF NOT AVAILABLE buf_trn-doc THEN DO:
    MESSAGE
    substitute("Не найден документ &1", p-doc-code)
    VIEW-AS ALERT-BOX.
    RETURN ERROR.
  END.
  if buf_trn-doc.ext-doc-type <> {&TDEDT_inv} THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      substitute("Неверное значение параметера p-doc-code &1&2" +
                 "Документ должен иметь расширенный тип &2"
                 , p-doc-code
                 , {&NEW-LINE}
                 , {&TDEDT_inv})
      VIEW-AS ALERT-BOX.
      RETURN ERROR.
  END.
 IF p-rid-list <> "":U THEN DO:
   v-rid-list = p-rid-list.
   ASSIGN
   v-doc-rec = INTEGER(ENTRY(1, v-rid-list))
   .
  END.
  run Myenable IN THIS-PROCEDURE.
  run OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if v-doc-rec <> ? then
  REPOSITION br-invline to recid v-doc-rec No-ERROR.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI.

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
  DISPLAY rs-calc sch-code mark-num f-prod-name
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel b-calc B-sch B-print B-Help rs-calc sch-code
         br-invline mark-num f-prod-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-goods-recid Dialog-Frame
PROCEDURE get-goods-recid :
IF AVAILABLE X_goods THEN DO:
    gds-rec = RECID(X_goods).
END.
ELSE DO:
   gds-rec = ?.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :

{ str/sclspref.i varscales-pref varpgscales-pref }

ASSIGN
X_chk-gds.src-qnty:READ-ONLY IN BROWSE br-invline = YES
X_goods.gds-name:resizable IN BROWSE br-invline = YES
X_goods.gds-name:width IN BROWSE br-invline = 25
.
IF p-mode = "":u  THEN rs-calc = ?.
IF p-mode = "calc":u  THEN rs-calc = YES.
IF p-mode = "not-calc":u  THEN rs-calc = no.
DISPLAY
rs-calc
sch-code
WITH FRAME {&frame-name}.
ENABLE
b-quit
B-mark WHEN LOOKUP("b-mark", bttns) > 0
b-sel  WHEN LOOKUP("b-sel", bttns) > 0
b-calc WHEN (buf_trn-doc.STATUS_ = {&permitted}
             AND
             LOOKUP("b-calc", bttns) > 0
             AND buf_trn-doc.obj-type = v-cntxt-obj-type
             AND buf_trn-doc.obj-code = v-cntxt-obj-code)
B-sch
B-print
B-Help
rs-calc
sch-code
br-invline
WITH FRAME {&frame-name}.
VIEW FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
DEFINE VARIABLE l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ( input "Ждите...").
DEFINE VARIABLE sort-column-phrase as character no-undo .
DEFINE VARIABLE title0 as character no-undo INIT "Список строк инвентаризации по кассе".

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

&scop flt-open-open-query OPEN QUERY br-invline FOR EACH X_chk-gds

&scop flt-open-dyn_open-query FOR EACH X_chk-gds

&scop flt-open-query-handle QUERY br-invline:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name ub.chk-gds

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_chk-gds

&scop flt-open-waitfram  yes

define variable l-open-query as logical   no-undo .
&scop flt-open-open-query-tail  , FIRST X_bar-code No-LOCK outer-join WHERE X_bar-code.b-code = X_chk-gds.b-code,  ~
FIRST X_goods NO-LOCK OUTER-JOIN WHERE X_goods.gds-code = X_bar-code.gds-code
    ASSIGN
    filter-point = filter-point0 + {&comma-char} + (if rs-calc = ? then {&question-mark} else string(rs-calc))
    filter-label = filter-label0 + {&space-char} + (if (radio-label(string(rs-calc), rs-calc:RADIO-BUTTONS IN FRAME {&FRAME-NAME})) = ?
                                                    then {&question-mark}
                                                    else radio-label(string(rs-calc), rs-calc:RADIO-BUTTONS IN FRAME {&FRAME-NAME})
                                                    )

    title0 = SUBSTITUTE ("&1 документ &2", title0 , p-doc-code)
    .
    if p-open-query then do:
     ASSIGN frame {&frame-name}:TITLE = substitute("&1 &2"
                                                  , title0
                                                  , (if rs-calc <> ?
                                                     then ("Посчитаны:" + {&space-char} + string(rs-calc, "+/"))
                                                     else '':U)
                                                   ).
    end.
CASE Rs-calc:
  when ? then do:
     { gbl/fltopend.i
        &where-cond = " X_chk-gds.out-code = p-doc-code "
        &dyn_where-cond = " substitute('X_chk-gds.out-code = &1&2&1', ~{&double-quote~}, p-doc-code )"
        &use-ind    = "  "
        &by =  " "
        }
  end.
  when YES then do:
     { gbl/fltopend.i
        &where-cond = " X_chk-gds.out-code = p-doc-code and X_chk-gds.is-error = no"
        &dyn_where-cond = " substitute('X_chk-gds.out-code = &1&2&1 and X_chk-gds.is-error = no', ~{&double-quote~}, p-doc-code)"
        &use-ind    = "  "
        &by =  " "
        }
  end.
  when no then do:
       { gbl/fltopend.i
          &where-cond = " X_chk-gds.out-code = p-doc-code and X_chk-gds.is-error = yes"
          &dyn_where-cond = " substitute('X_chk-gds.out-code = &1&2&1 and X_chk-gds.is-error = yes', ~{&double-quote~}, p-doc-code)"
          &use-ind    = "  "
          &by =  " "
          }
  end.
END CASE.

if not p-open-query and v-doc-rec <> ? then
REPOSITION br-invline to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-invline:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-invline in frame {&frame-name}.
APPLY "ENTRY" TO br-invline.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
DEFINE INPUT PARAMETER p-calc AS LOGICAL NO-UNDO.
DEFINE VARIABLE accum-count AS INTEGER NO-UNDO.
DEFINE variable ACCUM-SRC-QNTY AS DECIMAL NO-UNDO.
DEFINE variable ACCUM-DOC-QNTY AS DECIMAL NO-UNDO.
define variable date_string as character no-undo .
define variable line as character no-undo .

DEFINE BUFFER buf_chk-gds FOR ub.chk-gds.
DEFINE BUFFER buf_bar-code FOR ub.bar-code.
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE FRAME PrnFrame
buf_chk-gds.is-error COLUMN-LABEL "Посчи!тан" FORMAT "+/":U
buf_chk-gds.b-code FORMAT "999999999":U
buf_chk-gds.doc-qnty FORMAT "->>,>>>,>>9.<<<":U
buf_bar-code.unit-cli COLUMN-LABEL "Ед.!изм." FORMAT "X(3)":U
buf_goods.gds-name FORMAT "X(48)":U
buf_bar-code.gds-code FORMAT "999999999":U
buf_chk-gds.src-code COLUMN-LABEL "Бар-код в чеке" FORMAT "X(16)":U
buf_chk-gds.src-qnty FORMAT "->>,>>>,>>9.<<<":U
buf_chk-gds.line-num COLUMN-LABEL "Строка" FORMAT "99999":U
buf_chk-gds.doc-code COLUMN-LABEL "Номер чека" FORMAT "X(20)":U
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>>9" SKIP
Line format "X({&A4_LS})" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", {&A4_LS}).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

PUT  STREAM PrnLibStream
( frame {&frame-name}:title )
format "x({&A4_LS})" SKIP(1) .
FORM HEADER
Line format "X({&A4_LS})" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME prnFrame  .
run waitfram-show in this-procedure (  input "Ждите...").
FOR EACH buf_CHK-GDS NO-LOCK WHERE
        BUF_CHK-GDS.OUT-CODE = P-DOC-CODE:
  FIND FIRST BUF_BAR-CODE NO-LOCK WHERE BUF_BAR-CODE.B-CODE = BUF_CHK-GDS.B-CODE NO-ERROR.
  IF AVAILABLE BUF_BAR-CODE THEN DO:
     FIND FIRST BUF_GOODS NO-LOCK WHERE
                BUF_GOODS.GDS-CODE = BUF_BAR-CODE.GDS-CODE NO-ERROR.
  END.
  if p-calc = ? then do:
  end.
  else do:
    IF p-calc = YES AND buf_chk-gds.is-error THEN NEXT.
    IF p-calc = no AND NOT buf_chk-gds.is-error THEN NEXT.
  end.
  Display STREAM PrnLibStream
  NOT(buf_chk-gds.is-error) @ buf_chk-gds.is-error
  buf_chk-gds.b-code
  buf_chk-gds.doc-qnty
  buf_chk-gds.src-code
  buf_chk-gds.src-qnty
  buf_chk-gds.line-num
  buf_chk-gds.doc-code
  buf_bar-code.unit-cli when available buf_bar-code
  buf_bar-code.gds-code when available buf_bar-code
  BUF_GOODS.GDS-NAME when available buf_goods
  with FRAME prnFrame .
  assign
  accum-count = accum-count + 1
  ACCUM-SRC-QNTY = ACCUM-SRC-QNTY + BUF_CHK-GDS.SRC-QNTY
  ACCUM-DOC-QNTY = ACCUM-DOC-QNTY + BUF_CHK-GDS.DOC-QNTY
  .
END.
UNDERLINE  STREAM PrnLibStream
buf_chk-gds.b-code
buf_chk-gds.doc-qnty
buf_chk-gds.src-code
buf_chk-gds.src-qnty
buf_chk-gds.line-num
buf_chk-gds.doc-code
buf_bar-code.unit-cli
buf_bar-code.gds-code
BUF_GOODS.GDS-NAME
with FRAME prnFrame .
DISPLAY STREAM PrnLibStream
accum-count @ buf_chk-gds.b-code
ACCUM-SRC-QNTY @ BUF_CHK-GDS.SRC-QNTY
ACCUM-DOC-QNTY @ BUF_CHK-GDS.doc-QNTY
with frame prnFrame.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME PrnFrame.
output  STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure.

run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
assign
  tbl = 'chk-gds'
  join-tbl = 'X_chk-gds'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('doc-code', 'Номер чека в базе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('line-num', 'Номер строки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('src-code', 'Код в чеке', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-qnty', 'Кол-во в чеке', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('src-code', 'Код', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-qnty', 'Кол-во', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-error', 'Посчитан', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w (
                 INPUT parparentproc
               , INPUT (filter-point + {&delim-par} + filter-label)
               , INPUT tbl
               , INPUT join-tbl
               , INPUT fld
               , INPUT lab
               , INPUT spr
               , INPUT dim ).
  if return-value = {&flt-undo-value} then return error.
  run OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-code Dialog-Frame
PROCEDURE proc-find-code :
define input parameter par-next as logical no-undo.
define input parameter p-sch-code like ub.chk-gds.src-code no-undo.
DEFINE VARIABLE v-src-code AS CHARACTER NO-UNDO.
DEFINE VARIABLE varresult AS CHARACTER NO-UNDO.
DEFINE VARIABLE vartype-bc AS CHARACTER NO-UNDO.
define variable varweight   as decimal           no-undo.
define buffer buf_bar-code for ub.bar-code .
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_place for ub.place.

{ str/bc-rcnz.i
  parparentproc
  p-sch-code
  ?
  buf_trn-doc.obj-type
  buf_trn-doc.obj-code
  yes
  no
  varscales-pref
  varpgscales-pref
  varresult
  vartype-bc
  varweight
  buf_bar-code
  buf_prod-bc
  buf_place
  no-error
  }
IF AVAILABLE buf_bar-code THEN DO:
    run OpenBr in this-procedure (
     input false /* p-open-query */
    ,input par-next  /* p-find-next  */
    ,input substitute("and X_chk-gds.b-code = &1 "
      , buf_bar-code.b-code)
    ).
END.
ELSE DO:
   ASSIGN
   v-src-code = {&double-quote} + p-sch-code + {&double-quote}.

    run OpenBr in this-procedure (
     input false /* p-open-query */
    ,input par-next  /* p-find-next  */
    ,input substitute("and X_chk-gds.src-code = &1 "
      , v-src-code)
    ).
END.
apply "entry":u to sch-code in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-prt-name Dialog-Frame
FUNCTION get-prt-name RETURNS CHARACTER (BUFFER buf_bar-code FOR ub.bar-code, BUFFER buf_goods FOR ub.goods):
define variable var-artic like ub.goods.artic no-undo.
define variable  pargds-name as character no-undo.
define variable  parprt-name as character no-undo.
define buffer loc_gds-prt for ub.gds-prt.


IF  AVAILABLE buf_bar-code then do:
    FIND FIRST loc_gds-prt WHERE
                       loc_gds-prt.node-code = buf_bar-code.node-code NO-LOCK.
    assign
    parprt-name =
                    ( if loc_gds-prt.node-name = {&empty-scale} then "-"
                      else ( if loc_gds-prt.upper-code = buf_goods.prt-root
                                then "-------------------" else loc_gds-prt.f-name ) ) .

end.


  RETURN parprt-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME