&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_condition-keeping FOR ub.condition-keeping.
DEFINE BUFFER X_curr_clients FOR ub.clients.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список УСЛОВИЙ ХРАНЕНИЯ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 15/03/04
Author: Bakhtadze Natalya
Creation date: 15/03/04

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
define input-output parameter p-sts like ub.condition-keeping.sts no-undo .
/*{&all}*/
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список УСЛОВИЙ ХРАНЕНИЯ":U.
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-rid-list as character no-undo .
&SCOPED-DEFINE status-code STRING(X_condition-keeping.sts)

define buffer pos_condition-keeping for ub.condition-keeping.

&scop cant-positioning   if error-status:error then do: ~
                          find first pos_condition-keeping no-lock where ~
                                  recid(pos_condition-keeping) = loc-doc-rec no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи УСЛОВИЙ ХРАНЕНИЯ" skip~
                            string(if avail pos_condition-keeping ~
                                    then  substitute("Вн код условий хранения: &1" ~
                                                    , pos_condition-keeping.cond-keep-code) ~
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
&Scoped-define BROWSE-NAME br-condkeep

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_condition-keeping

/* Definitions for BROWSE br-condkeep                                   */
&Scoped-define FIELDS-IN-QUERY-br-condkeep ~
mark-string(recid(X_condition-keeping), v-rid-list) ~
X_condition-keeping.cond-keep-name X_condition-keeping.des ~
{&status-int-name} X_condition-keeping.t-mode-from ~
X_condition-keeping.t-mode-to X_condition-keeping.h-mode-from ~
X_condition-keeping.h-mode-to X_condition-keeping.cond-keep-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-condkeep
&Scoped-define QUERY-STRING-br-condkeep FOR EACH X_condition-keeping NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-condkeep OPEN QUERY br-condkeep FOR EACH X_condition-keeping NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-condkeep X_condition-keeping
&Scoped-define FIRST-TABLE-IN-QUERY-br-condkeep X_condition-keeping


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-condkeep}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-add B-lookup B-chg ~
B-del B-print B-hist B-Help RS-sts br-condkeep mark-num
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

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON B-lookup
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
DEFINE QUERY br-condkeep FOR
      X_condition-keeping SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-condkeep
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-condkeep Dialog-Frame _STRUCTURED
  QUERY br-condkeep NO-LOCK DISPLAY
      mark-string(recid(X_condition-keeping), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_condition-keeping.cond-keep-name FORMAT "X(50)":U
      X_condition-keeping.des FORMAT "X(255)":U
      {&status-int-name} COLUMN-LABEL "Статус"
      X_condition-keeping.t-mode-from FORMAT "->>9.99":U
      X_condition-keeping.t-mode-to FORMAT "->>9.99":U
      X_condition-keeping.h-mode-from FORMAT ">>9.99":U
      X_condition-keeping.h-mode-to FORMAT ">>9.99":U
      X_condition-keeping.cond-keep-code FORMAT ">>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     B-add AT ROW 1 COL 31
     B-lookup AT ROW 1 COL 41
     B-chg AT ROW 1 COL 51
     B-del AT ROW 1 COL 61
     B-print AT ROW 1 COL 89
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     RS-sts AT ROW 2.5 COL 3.5 NO-LABEL
     br-condkeep AT ROW 4 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(78.62) SKIP(20.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Условия хранения"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_condition-keeping B "?" ? ub condition-keeping
      TABLE: X_curr_clients B "?" ? ub clients
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-condkeep RS-sts Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-condkeep
/* Query rebuild information for BROWSE br-condkeep
     _TblList          = "X_condition-keeping"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"mark-string(recid(X_condition-keeping), v-rid-list)" "*" "X(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   = Temp-Tables.X_condition-keeping.cond-keep-name
     _FldNameList[3]   = Temp-Tables.X_condition-keeping.des
     _FldNameList[4]   > "_<CALC>"
"{&status-int-name}" "Статус" ? ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   = Temp-Tables.X_condition-keeping.t-mode-from
     _FldNameList[6]   = Temp-Tables.X_condition-keeping.t-mode-to
     _FldNameList[7]   = Temp-Tables.X_condition-keeping.h-mode-from
     _FldNameList[8]   = Temp-Tables.X_condition-keeping.h-mode-to
     _FldNameList[9]   = Temp-Tables.X_condition-keeping.cond-keep-code
     _Query            is OPENED
*/  /* BROWSE br-condkeep */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Условия хранения */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Условия хранения */
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
run ref/cndkeepi.w
              (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&add-def}
                ,input 0 /*p-cond-keep-code*/
                ,input-output loc-doc-rec
                            ) no-error
.
if loc-doc-rec <> ? THEN DO:
    RUn OpenBR in this-procedure .
    reposition br-condkeep to recid loc-doc-rec no-error.
    {&cant-positioning}
END.

apply "entry" to br-condkeep in frame {&frame-name}.
apply "value-changed" to br-condkeep in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available X_condition-keeping then return no-apply.
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
loc-doc-rec = recid(X_condition-keeping).

run ref/cndkeepi.w
              (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&update}
                ,input X_condition-keeping.cond-keep-code
                ,input-output loc-doc-rec
                            ) no-error
.
if loc-doc-rec <> ? then do:
  RUn OpenBR in this-procedure .
  reposition br-condkeep to recid loc-doc-rec no-error.
  {&cant-positioning}
end.
apply "entry" to br-condkeep in frame {&frame-name}.
apply "value-changed" to br-condkeep in frame {&frame-name}.
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


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
  define variable loc-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo.
  if NOT available X_condition-keeping then return no-apply.
  loc-doc-rec = recid (X_condition-keeping).
  .
  run ref/ccnkeeps.w
                (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input "":U /*bttns*/
                ,input "one":U
                ,input X_condition-keeping.cond-keep-code
                ,input-output v-rid-list
                              )
.
  reposition br-condkeep to recid loc-doc-rec no-error.
  apply "entry" to br-condkeep in frame {&frame-name}.
  apply "value-changed" to br-condkeep in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
  DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available X_condition-keeping then return no-apply.

assign
loc-doc-rec = recid(X_condition-keeping).

run ref/cndkeepi.w
              (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&lookup}
                ,input X_condition-keeping.cond-keep-code
                ,input-output loc-doc-rec
                            )
.

apply "entry" to br-condkeep in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available X_condition-keeping then do:
    { gbl/markstrn.i X_condition-keeping v-rid-list }
    loc#log = br-condkeep:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-condkeep:select-next-row ().
        apply "VALUE-CHANGED" to br-condkeep in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-condkeep in frame {&frame-name}.
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
  APPLY "ENTRY" to br-condkeep.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_condition-keeping ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_condition-keeping ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-condkeep
&Scoped-define SELF-NAME br-condkeep
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-condkeep Dialog-Frame
ON RETURN OF br-condkeep IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-condkeep IN FRAME Dialog-Frame
    DO:
    run proc-br-condkeep no-error.
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
  &sort-clmn_1    = "X_condition-keeping.cond-keep-code"
  &open-query     = "run OpenBr."
  &open-query-otherwise = "run OpenBr."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}


{ gbl/brwrepos.i
  &line-num=5
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }

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
  REPOSITION br-condkeep to recid v-doc-rec No-ERROR.
    { gbl/mv-clmn.i
    &browse-name = "br-condkeep"
    &frame-name = "{&frame-name}"
    &ext-col = 9
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9'"
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
  ENABLE b-quit B-mark B-sel B-add B-lookup B-chg B-del B-print B-hist B-Help 
         RS-sts br-condkeep mark-num 
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
B-lookup
B-chg when LOOKUP("b-add":U, bttns) > 0 and v-db-num = 0
B-del when LOOKUP("b-add":U, bttns) > 0 and v-db-num = 0
B-print
B-Help
B-hist
br-condkeep
/*b-delivtype*/
mark-num
RS-sts
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
define variable title0 as character no-undo init "Список условий хранения".
IF p-sts = ? THEN DO:
    frame {&frame-name}:TITLE = title0 + {&space-char} + "все".
    OPEN QUERY br-condkeep
    FOR EACH X_condition-keeping NO-LOCK
    INDEXED-REPOSITION.
END.
ELSE DO:
    &SCOPED-DEFINE status-code STRING(p-sts)
    frame {&frame-name}:TITLE = title0 + {&space-char} + {&status-int-name}.
    OPEN QUERY br-condkeep
    FOR EACH X_condition-keeping NO-LOCK where
    X_condition-keeping.sts = p-sts
    INDEXED-REPOSITION.
END.
APPLY "VALUE-CHANGED" TO br-condkeep in frame {&frame-name}.
APPLY "ENTRY" TO br-condkeep.
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
define variable v-sts like ub.condition-keeping.sts no-undo .
DEFINE VARIABLE loc-doc-rec AS RECID NO-UNDO.
if not available X_condition-keeping then return error.

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
  loc-doc-rec = RECID(X_condition-keeping)
  .
  run ref/cndkeep2.p (
                  input recid(X_condition-keeping)
                  ,input-output v-sts
                 ) no-error .
  if error-status:error then undo, return error.
  RUN OpenBr.
  REPOSITION br-condkeep to recid loc-doc-rec No-error.
  {&cant-positioning}
  if available X_condition-keeping then do:
    loc#log = br-condkeep:select-focused-row( ) IN FRAME {&FRAME-NAME}.
  end.
  apply "ENTRY" to br-condkeep.
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
&SCOPED-DEFINE status-code STRING(X_condition-keeping.sts)
DEFINE FRAME condition-keeping-list
X_condition-keeping.cond-keep-name
v-sts-chr FORMAT "X(8)" COLUMN-LABEL "Статус"
X_condition-keeping.t-mode-from column-label "Темп-ра!от(град C)"
X_condition-keeping.t-mode-to   column-label "Темп-ра!до(град C)"
X_condition-keeping.h-mode-from column-label "Влажность!от (%)"
X_condition-keeping.h-mode-to   column-label "Влажность!до (%)"
X_condition-keeping.des FORMAT "X(100)"
X_condition-keeping.cond-keep-code COLUMN-LABEL "Вн.код!группы"
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

FORM with FRAME condition-keeping-list  .
run waitfram-show in this-procedure ("Ждите...").
v-doc-rec = recid(X_condition-keeping).
DO WHILE available X_condition-keeping :
  GET prev br-condkeep.
END.
GET next br-condkeep.
DO WHILE available X_condition-keeping :
  Display STREAM PrnLibStream
   X_condition-keeping.cond-keep-name
  {&status-int-name} @ v-sts-chr
  X_condition-keeping.des
  X_condition-keeping.t-mode-from
  X_condition-keeping.t-mode-to
  X_condition-keeping.h-mode-from
  X_condition-keeping.h-mode-to
  X_condition-keeping.cond-keep-code
with FRAME condition-keeping-list .
  DOWN STREAM PrnLibStream 1
  with FRAME condition-keeping-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-condkeep.
END.
UNDERLINE  STREAM PrnLibStream
X_condition-keeping.cond-keep-name
v-sts-chr
X_condition-keeping.des
X_condition-keeping.t-mode-from
X_condition-keeping.t-mode-to
X_condition-keeping.h-mode-from
X_condition-keeping.h-mode-to
X_condition-keeping.cond-keep-code
with FRAME condition-keeping-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_condition-keeping.cond-keep-name
accum-count @ v-sts-chr
with frame condition-keeping-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME condition-keeping-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-condkeep to recid v-doc-rec no-error.
APPLY "entry" to br-condkeep.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-condkeep Dialog-Frame 
PROCEDURE proc-br-condkeep :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ ref/brwsretr.i }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

