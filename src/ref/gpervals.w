&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_curr_clients FOR ub.clients.
DEFINE BUFFER X_group-period-validity FOR ub.group-period-validity.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список групп сроков годности

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/03/04
Author: Bakhtadze Natalya
Creation date: 10/03/04

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
define input-output parameter p-sts like ub.group-period-validity.sts no-undo .
define input-output parameter p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список групп сроков годности":U.
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

&SCOPED-DEFINE status-code STRING(X_group-period-validity.sts)

define buffer pos_group-period-validity for ub.group-period-validity.

&scop cant-positioning   if error-status:error then do: ~
                          find first pos_group-period-validity no-lock where ~
                                  recid(pos_group-period-validity) = loc-doc-rec no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи ГРУППЫ СРОКОВ ГОДНОСТИ" skip~
                            string(if avail pos_group-period-validity ~
                                    then  substitute("Вн код группы сроков годности: &1" ~
                                                    , pos_group-period-validity.gr-per-val-code) ~
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
&Scoped-define BROWSE-NAME BR-gperval

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_group-period-validity

/* Definitions for BROWSE BR-gperval                                    */
&Scoped-define FIELDS-IN-QUERY-BR-gperval ~
mark-string(recid(X_group-period-validity), v-rid-list) ~
X_group-period-validity.gr-per-val-name {&status-int-name} ~
X_group-period-validity.gr-per-from X_group-period-validity.gr-per-to ~
X_group-period-validity.des X_group-period-validity.gr-per-val-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-gperval
&Scoped-define QUERY-STRING-BR-gperval FOR EACH X_group-period-validity NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-gperval OPEN QUERY BR-gperval FOR EACH X_group-period-validity NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-gperval X_group-period-validity
&Scoped-define FIRST-TABLE-IN-QUERY-BR-gperval X_group-period-validity


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-gperval}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-add b-lkp B-chg B-del ~
B-print B-hist B-Help B-var-deliv-gr-per-val RS-sts BR-gperval mark-num
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

DEFINE BUTTON B-var-deliv-gr-per-val
     LABEL "Варианты доставки до объекта"
     SIZE 30 BY 1.

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
DEFINE QUERY BR-gperval FOR
      X_group-period-validity SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-gperval
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-gperval Dialog-Frame _STRUCTURED
  QUERY BR-gperval NO-LOCK DISPLAY
      mark-string(recid(X_group-period-validity), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_group-period-validity.gr-per-val-name FORMAT "X(50)":U
      {&status-int-name} COLUMN-LABEL "Статус"
      X_group-period-validity.gr-per-from FORMAT "999":U
      X_group-period-validity.gr-per-to FORMAT "999":U
      X_group-period-validity.des FORMAT "X(255)":U
      X_group-period-validity.gr-per-val-code FORMAT ">>9":U
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
     B-var-deliv-gr-per-val AT ROW 2 COL 51
     RS-sts AT ROW 3.5 COL 3.5 NO-LABEL
     BR-gperval AT ROW 5 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(78.62) SKIP(20.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Группы сроков годности"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_curr_clients B "?" ? ub clients
      TABLE: X_group-period-validity B "?" ? ub group-period-validity
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-gperval RS-sts Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-gperval
/* Query rebuild information for BROWSE BR-gperval
     _TblList          = "X_group-period-validity"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"mark-string(recid(X_group-period-validity), v-rid-list)" "*" "X(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   = Temp-Tables.X_group-period-validity.gr-per-val-name
     _FldNameList[3]   > "_<CALC>"
"{&status-int-name}" "Статус" ? ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   = Temp-Tables.X_group-period-validity.gr-per-from
     _FldNameList[5]   = Temp-Tables.X_group-period-validity.gr-per-to
     _FldNameList[6]   = Temp-Tables.X_group-period-validity.des
     _FldNameList[7]   = Temp-Tables.X_group-period-validity.gr-per-val-code
     _Query            is OPENED
*/  /* BROWSE BR-gperval */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Группы сроков годности */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Группы сроков годности */
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
run ref/gpervali.w
              (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&add-def}
                ,input 0 /*p-gr-per-val-code*/
                ,input-output loc-doc-rec
                            ) no-error
.
if loc-doc-rec <> ? THEN DO:
    RUn OpenBR in this-procedure .
    reposition br-gperval to recid loc-doc-rec no-error.
    {&cant-positioning}
END.
apply "entry" to br-gperval in frame {&frame-name}.
apply "value-changed" to br-gperval in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available X_group-period-validity then return no-apply.
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
loc-doc-rec = recid(X_group-period-validity).

run ref/gpervali.w
              (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&update}
                ,input X_group-period-validity.gr-per-val-code
                ,input-output loc-doc-rec
                            ) no-error
.
if loc-doc-rec <> ? then do:
  RUn OpenBR in this-procedure.
  reposition br-gperval to recid loc-doc-rec no-error.
  {&cant-positioning}
end.
apply "entry" to br-gperval in frame {&frame-name}.
apply "value-changed" to br-gperval in frame {&frame-name}.
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
  if NOT available X_group-period-validity then return no-apply.
  loc-doc-rec = recid (X_group-period-validity).
  .
  run ref/gcprvals.w
                (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input "":U /*bttns*/
                ,input "one":U
                ,input X_group-period-validity.gr-per-val-code
                ,input-output v-rid-list
                              )
.
  reposition br-gperval to recid loc-doc-rec no-error.
  apply "entry" to br-gperval in frame {&frame-name}.
  apply "value-changed" to br-gperval in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available X_group-period-validity then return no-apply.

assign
loc-doc-rec = recid(X_group-period-validity).

run ref/gpervali.w
              (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&lookup}
                ,input X_group-period-validity.gr-per-val-code
                ,input-output loc-doc-rec
                            )
.

apply "entry" to br-gperval in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available X_group-period-validity then do:
    { gbl/markstrn.i X_group-period-validity v-rid-list }
    loc#log = BR-gperval:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = BR-gperval:select-next-row ().
        apply "VALUE-CHANGED" to BR-gperval in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to BR-gperval in frame {&frame-name}.
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
  APPLY "ENTRY" to BR-gperval.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_group-period-validity ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_group-period-validity ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-var-deliv-gr-per-val
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-var-deliv-gr-per-val Dialog-Frame
ON CHOOSE OF B-var-deliv-gr-per-val IN FRAME Dialog-Frame /* Варианты доставки до объекта */
DO:
      DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  define variable v-sts as integer no-undo init ? .
  IF NOT AVAILABLE X_group-period-validity  THEN DO:
      RETURN NO-APPLY.
  END.
  run ref/vrdlgrps.w (
                     INPUT parParentProc
                  ,  input p-curr-obj-type
                  ,  input p-curr-obj-code
                  ,  input (if lookup("b-add":U, bttns) > 0 then "b-add":U else "":U) /*bttns*/
                  ,  INPUT "group-period-validity":U
                  ,  input 0 /*p-deliv-type-code*/
                  ,  input 0 /*p-deliv-subj-code*/
                  ,  input p-curr-obj-type
                  ,  input p-curr-obj-code
                  ,  INPUT X_group-period-validity.gr-per-val-code
                  ,  input-output v-sts
                  ,  input-output v-rid-list    ) NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-gperval
&Scoped-define SELF-NAME BR-gperval
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-gperval Dialog-Frame
ON RETURN OF BR-gperval IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-gperval IN FRAME Dialog-Frame
    DO:
    run proc-br-gperval no-error.
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
  p-sts = (IF rs-sts = {&all}  THEN ? ELSE INTEGER(rs-sts))
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
  &sort-clmn_1    = "X_group-period-validity.gr-per-val-code"
  &open-query     = "run OpenBr in this-procedure ."
  &open-query-otherwise = "run OpenBr in this-procedure ."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "no"
  &mv-brw-default = "no"
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
  RUN MyEnable in this-procedure .
  RUn OpenBR in this-procedure .
  HIDE mark-num in frame {&frame-name} .
  if v-doc-rec <> ? then
  REPOSITION br-gperval to recid v-doc-rec No-ERROR.
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
         B-var-deliv-gr-per-val RS-sts BR-gperval mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyENable Dialog-Frame
PROCEDURE MyENable :
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
rs-sts
BR-gperval mark-num
B-var-deliv-gr-per-val
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
define variable title0 as character no-undo init "Список групп сроков годности".
IF p-sts = ? THEN DO:
    OPEN QUERY BR-gperval
    FOR EACH X_group-period-validity NO-LOCK
    INDEXED-REPOSITION.
END.
ELSE DO:
&SCOPED-DEFINE status-code STRING(p-sts)
    frame {&frame-name}:TITLE = title0 + {&space-char} + {&status-int-name}.
    OPEN QUERY BR-gperval
    FOR EACH X_group-period-validity NO-LOCK where
    X_group-period-validity.sts = p-sts
    INDEXED-REPOSITION.
END.
APPLY "VALUE-CHANGED" TO br-gperval in frame {&frame-name}.
APPLY "ENTRY" TO br-gperval.
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
define variable v-sts like ub.group-period-validity.sts no-undo .
DEFINE VARIABLE loc-doc-rec AS RECID NO-UNDO.
if not available X_group-period-validity then return error.

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
  loc-doc-rec = recid(X_group-period-validity)
  .
  run ref/gperval2.p (
                  input recid(X_group-period-validity)
                  ,input-output v-sts
                 ) no-error .
  if error-status:error then undo, return error.
  RUN OpenBr in this-procedure .
  REPOSITION br-gperval to recid loc-doc-rec No-error.
  {&cant-positioning}
  if available X_group-period-validity then do:
    loc#log = br-gperval:select-focused-row( ) IN FRAME {&FRAME-NAME}.
  end.
  apply "ENTRY" to br-gperval.
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

DEFINE FRAME group-period-validity-list
X_group-period-validity.gr-per-val-name
v-sts-chr FORMAT "X(8)" COLUMN-LABEL "Статус"
X_group-period-validity.des FORMAT "X(100)"
X_group-period-validity.gr-per-from
X_group-period-validity.gr-per-to
X_group-period-validity.gr-per-val-code COLUMN-LABEL "Вн.код!группы"
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

FORM with FRAME group-period-validity-list  .
run waitfram-show in this-procedure ( input "Ждите...").
v-doc-rec = recid(X_group-period-validity).
DO WHILE available X_group-period-validity :
  GET prev br-gperval.
END.
GET next br-gperval.
DO WHILE available X_group-period-validity :
  Display STREAM PrnLibStream
   X_group-period-validity.gr-per-val-name
  {&status-int-name} @ v-sts-chr
  X_group-period-validity.des
  X_group-period-validity.gr-per-from
  X_group-period-validity.gr-per-to
  X_group-period-validity.gr-per-val-code
with FRAME group-period-validity-list .
  DOWN STREAM PrnLibStream 1
  with FRAME group-period-validity-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-gperval.
END.
UNDERLINE  STREAM PrnLibStream
X_group-period-validity.gr-per-val-name
v-sts-chr
X_group-period-validity.des
X_group-period-validity.gr-per-from
X_group-period-validity.gr-per-to
X_group-period-validity.gr-per-val-code
with FRAME group-period-validity-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_group-period-validity.gr-per-val-name
accum-count @ v-sts-chr
with frame group-period-validity-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME group-period-validity-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-gperval to recid v-doc-rec no-error.
APPLY "entry" to br-gperval.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-gperval Dialog-Frame
PROCEDURE proc-br-gperval :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ ref/brwsretr.i b-lkp }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
