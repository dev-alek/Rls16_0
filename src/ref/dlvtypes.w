&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_curr_clients FOR ub.clients.
DEFINE BUFFER X_delivery-type FOR ub.delivery-type.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список ТИПОВ ДОСТАВКИ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 16/03/04
Author: Bakhtadze Natalya
Creation date: 16/03/04

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
/*{&all}*/
define input-output parameter p-sts like ub.delivery-type.sts no-undo .
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список ТИПОВ ДОСТАВКИ":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
define variable v-rid-list as character no-undo .
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.

&SCOPED-DEFINE status-code STRING(X_delivery-type.sts)
define buffer pos_delivery-type for ub.delivery-type.

&scop cant-positioning   if error-status:error then do: ~
                          find first pos_delivery-type no-lock where ~
                                  recid(pos_delivery-type) = loc-doc-rec no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи ТИПА ДОСТАВКИ" skip~
                            string(if avail pos_delivery-type ~
                                    then  substitute("Вн код типа доставки: &1" ~
                                                    , pos_delivery-type.deliv-type-code) ~
                                    else "":U) skip ~
                            "Запись была добавлена (или изменена или удалена) -" skip ~
                            "и теперь не попадает в текущую выборку" ~
                            view-as alert-box WARNING. ~
                          end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-delivtype

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_delivery-type

/* Definitions for BROWSE br-delivtype                                  */
&Scoped-define FIELDS-IN-QUERY-br-delivtype ~
mark-string(recid(X_delivery-type), v-rid-list) ~
X_delivery-type.deliv-type-name {&status-int-name} X_delivery-type.des ~
X_delivery-type.deliv-type-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-delivtype
&Scoped-define QUERY-STRING-br-delivtype FOR EACH X_delivery-type NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-delivtype OPEN QUERY br-delivtype FOR EACH X_delivery-type NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-delivtype X_delivery-type
&Scoped-define FIRST-TABLE-IN-QUERY-br-delivtype X_delivery-type


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-delivtype}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-add b-lkp B-chg B-del ~
B-print B-hist B-Help B-delivsubj B-condkeep RS-sts br-delivtype mark-num
&Scoped-Define DISPLAYED-OBJECTS RS-sts mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-condkeep
     LABEL "Условия &хранения"
     SIZE 20 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-delivsubj
     LABEL "&Субъекты"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
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

DEFINE VARIABLE RS-sts AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 33.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-delivtype FOR
      X_delivery-type SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-delivtype
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-delivtype Dialog-Frame _STRUCTURED
  QUERY br-delivtype NO-LOCK DISPLAY
      mark-string(recid(X_delivery-type), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_delivery-type.deliv-type-name FORMAT "X(50)":U
      {&status-int-name} COLUMN-LABEL "Статус"
      X_delivery-type.des FORMAT "X(255)":U
      X_delivery-type.deliv-type-code FORMAT ">>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16.27.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     B-add AT ROW 1 COL 31
     b-lkp AT ROW 1 COL 41
     B-chg AT ROW 1 COL 51
     B-del AT ROW 1 COL 61
     B-print AT ROW 1 COL 89
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     B-delivsubj AT ROW 2 COL 51
     B-condkeep AT ROW 2 COL 61
     RS-sts AT ROW 3.5 COL 3.5 NO-LABEL
     br-delivtype AT ROW 5 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(78.62) SKIP(20.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Типы доставки"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_curr_clients B "?" ? ub clients
      TABLE: X_delivery-type B "?" ? ub delivery-type
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-delivtype RS-sts Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-delivtype
/* Query rebuild information for BROWSE br-delivtype
     _TblList          = "X_delivery-type"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"mark-string(recid(X_delivery-type), v-rid-list)" "*" "X(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   = Temp-Tables.X_delivery-type.deliv-type-name
     _FldNameList[3]   > "_<CALC>"
"{&status-int-name}" "Статус" ? ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   = Temp-Tables.X_delivery-type.des
     _FldNameList[5]   = Temp-Tables.X_delivery-type.deliv-type-code
     _Query            is OPENED
*/  /* BROWSE br-delivtype */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Типы доставки */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Типы доставки */
OR ENDKEY OF FRAME Dialog-Frame DO:
  run gbl/markqwa.p (
                           input b-mark:sensitive
                          , input v-rid-list) no-error.
  if error-status:error then return no-apply.

  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .

{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_delivery-storage_work':U
{&cntxt-global}
0
'':U
0
0
0
0
true
loc#log
}

if not loc#log then return no-apply.
run ref/dlvtypei.w
              (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&add-def}
                ,input 0 /*p-deliv-type-code*/
                ,input-output loc-doc-rec
                            ) no-error
.
if loc-doc-rec <> ? then do:
  RUn OpenBR in this-procedure .
  reposition br-delivtype to recid loc-doc-rec no-error.
  {&cant-positioning}
end.
apply "entry" to br-delivtype in frame {&frame-name}.
apply "value-changed" to br-delivtype in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available X_delivery-type then return no-apply.
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_delivery-storage_work':U
{&cntxt-global}
0
'':U
0
0
0
0
true
loc#log
}

if not loc#log then return no-apply.
assign
loc-doc-rec = recid(X_delivery-type).

run ref/dlvtypei.w
              (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&update}
                ,input X_delivery-type.deliv-type-code
                ,input-output loc-doc-rec
                            ) no-error
.
if loc-doc-rec <> ? then do:
  RUn OpenBR in this-procedure .
  reposition br-delivtype to recid loc-doc-rec no-error.
  {&cant-positioning}
end.
apply "entry" to br-delivtype in frame {&frame-name}.
apply "value-changed" to br-delivtype in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-condkeep
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-condkeep Dialog-Frame
ON CHOOSE OF B-condkeep IN FRAME Dialog-Frame /* Условия хранения */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  define variable v-sts as integer no-undo init ?.
  IF NOT AVAILABLE X_delivery-type THEN RETURN no-apply.
  run ref/dlvtcnds.w (input parParentProc
              , input p-curr-obj-type
              , input p-curr-obj-code
              , input (IF LOOKUP("b-add":U, bttns) > 0 THEN "b-add":U ELSE "":U)
              , input "delivery-type":U
              , input  X_delivery-type.deliv-type-code
              , input 0
              , input-output v-sts
              , input-output v-rid-list ) no-error .
  APPLY "ENTRY" TO br-delivtype.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
    run proc-b-del in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-delivsubj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-delivsubj Dialog-Frame
ON CHOOSE OF B-delivsubj IN FRAME Dialog-Frame /* Субъекты */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  define variable v-sts as integer no-undo init ?.
  IF NOT AVAILABLE X_delivery-type THEN RETURN no-apply.
  run ref/dlvtysus.w (input parParentProc
              , input p-curr-obj-type
              , input p-curr-obj-code
              , input (IF LOOKUP("b-add":U, bttns) > 0 THEN "b-add":U ELSE "":U)
              , input "delivery-type":U
              , input X_delivery-type.deliv-type-code
              , input 0
              , input-output v-sts
              , input-output v-rid-list ) no-error .
  APPLY "ENTRY" TO br-delivtype.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
  define variable loc-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo.
  if NOT available X_delivery-type then return no-apply.
  loc-doc-rec = recid (X_delivery-type).
  .
  run ref/dlvctyps.w
                (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input "":U /*bttns*/
                ,input "one":U
                ,input X_delivery-type.deliv-type-code
                ,input-output v-rid-list
                              )
.
  reposition br-delivtype to recid loc-doc-rec no-error.
  apply "entry" to br-delivtype in frame {&frame-name}.
  apply "value-changed" to br-delivtype in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available X_delivery-type then return no-apply.

assign
loc-doc-rec = recid(X_delivery-type).

run ref/dlvtypei.w
              (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&lookup}
                ,input X_delivery-type.deliv-type-code
                ,input-output loc-doc-rec
                            )
.

apply "entry" to br-delivtype in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available X_delivery-type then do:
    { gbl/markstrn.i X_delivery-type v-rid-list }
    loc#log = br-delivtype:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-delivtype:select-next-row ().
        apply "VALUE-CHANGED" to br-delivtype in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-delivtype in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
  APPLY "ENTRY" to br-delivtype.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_delivery-type ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_delivery-type ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-delivtype
&Scoped-define SELF-NAME br-delivtype
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-delivtype Dialog-Frame
ON RETURN OF br-delivtype IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-delivtype IN FRAME Dialog-Frame
    DO:
    run proc-br-delivtype no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-sts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-sts Dialog-Frame
ON VALUE-CHANGED OF RS-sts IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-sts
  p-sts = (IF rs-sts = {&all} THEN ? ELSE INTEGER(rs-sts))
  .
  RUN openbr IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
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
{ gbl/srt-clmn.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_delivery-type.deliv-type-code"
  &open-query     = "run OpenBr."
  &open-query-otherwise = "run OpenBr."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}


{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  if v-cntxt-level = {&cntxt-object} then do:
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
  end.
  if LOOKUP(p-mode, {&all},
                {&delim-par}) = 0
     then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return error .
 end.
 v-rid-list = p-rid-list.
 { gbl/curdbnum.i v-db-num }
  RUN MyEnable.
  RUn OpenBR.
  HIDE mark-num in frame {&frame-name} .
  if v-doc-rec <> ? then
  REPOSITION br-delivtype to recid v-doc-rec No-ERROR.
    { gbl/mv-clmn.i
    &browse-name = "br-delivtype"
    &frame-name = "{&frame-name}"
    &ext-col = 5
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5'"
    &prev-order-column-condition_1 = " p-mode = ~{&all~} "
    }

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
  DISPLAY RS-sts mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-add b-lkp B-chg B-del B-print B-hist B-Help
         B-delivsubj B-condkeep RS-sts br-delivtype mark-num
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
ASSIGN
rs-sts:RADIO-BUTTONS IN FRAME {&FRAME-NAME}
                       = "Текущие&+" + {&comma-char} +  {&current-status-int} + {&comma-char} +
                       "Все&!" + {&comma-char} + {&all} + {&comma-char} +
                        "Удаленные&-" + {&comma-char} + {&deleted-status-int}
rs-sts = (IF p-sts = ? THEN {&all} ELSE string(p-sts))
.

DISPLAY mark-num
WITH FRAME Dialog-Frame.
ENABLE
b-quit
B-mark when LOOKUP("b-mark":U, bttns) > 0
B-sel when LOOKUP("b-sel":U, bttns) > 0
B-add when LOOKUP("b-add":U, bttns) > 0 and v-db-num = 0
b-lkp
B-chg when LOOKUP("b-add":U, bttns) > 0 and v-db-num = 0
B-del when LOOKUP("b-add":U, bttns) > 0 and v-db-num = 0
B-print
B-Help
B-hist
B-delivsubj
B-condkeep
br-delivtype
mark-num
rs-sts
with FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable title0 as character no-undo init "Список типов доставки".
IF p-sts = ? THEN DO:
    OPEN QUERY br-delivtype
    FOR EACH X_delivery-type NO-LOCK
    INDEXED-REPOSITION.
END.
ELSE DO:
&SCOPED-DEFINE status-code STRING(p-sts)
    frame {&frame-name}:TITLE = title0 +  {&space-char} + {&status-int-name}.
    OPEN QUERY br-delivtype
    FOR EACH X_delivery-type NO-LOCK where
    X_delivery-type.sts = p-sts
    INDEXED-REPOSITION.
END.
APPLY "VALUE-CHANGED" TO br-delivtype in frame {&frame-name}.
APPLY "ENTRY" TO br-delivtype.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable loc#log as logical no-undo.
define variable v-sts like ub.delivery-type.sts no-undo .
DEFINE VARIABLE loc-doc-rec AS RECID NO-UNDO.
if not available X_delivery-type then return error.

do
on error undo, return error
on stop undo, return error
:

{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_delivery-storage_work':U
{&cntxt-global}
0
'':U
0
0
0
0
true
loc#log
}

if not loc#log then return error.
  assign
  v-sts = ?
  loc-doc-rec = RECID(X_delivery-type)
  .
  run ref/dlvtype2.p (
                  input recid(X_delivery-type)
                  ,input-output v-sts
                 ) no-error .
  if error-status:error then undo, return error.
  RUN OpenBr.
  REPOSITION br-delivtype to recid loc-doc-rec No-error.
  {&cant-positioning}
  if available X_delivery-type then do:
    loc#log = br-delivtype:select-focused-row( ) IN FRAME {&FRAME-NAME}.
  end.
  apply "ENTRY" to br-delivtype.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      char    no-undo.
define variable Line            as      char    no-undo.
DEFINE VARIABLE v-sts-chr AS CHARACTER NO-UNDO.

DEFINE FRAME delivery-type-list
X_delivery-type.deliv-type-name
v-sts-chr FORMAT "X(8)" COLUMN-LABEL "Статус"
X_delivery-type.des FORMAT "X(100)"
/*X_delivery-type.t-mode*/
/*X_delivery-type.p-mode*/
X_delivery-type.deliv-type-code COLUMN-LABEL "Вн.код!группы"
HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 195).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(195)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME delivery-type-list  .
run waitfram-show in this-procedure ("Ждите...").
v-doc-rec = recid(X_delivery-type).
DO WHILE available X_delivery-type :
  GET prev br-delivtype.
END.
GET next br-delivtype.
DO WHILE available X_delivery-type :
  Display STREAM PrnLibStream
   X_delivery-type.deliv-type-name
  {&status-int-name} @ v-sts-chr
  X_delivery-type.des
  /*X_delivery-type.t-mode*/
  /*X_delivery-type.p-mode*/
  X_delivery-type.deliv-type-code
with FRAME delivery-type-list .
  DOWN STREAM PrnLibStream 1
  with FRAME delivery-type-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-delivtype.
END.
UNDERLINE  STREAM PrnLibStream
X_delivery-type.deliv-type-name
v-sts-chr
X_delivery-type.des
/*X_delivery-type.t-mode*/
/*X_delivery-type.p-mode*/
X_delivery-type.deliv-type-code
with FRAME delivery-type-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_delivery-type.deliv-type-name
accum-count @ v-sts-chr
with frame delivery-type-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME delivery-type-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-delivtype to recid v-doc-rec no-error.
APPLY "entry" to br-delivtype.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-delivtype Dialog-Frame
PROCEDURE proc-br-delivtype :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ ref/brwsretr.i b-lkp }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
