&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_curr_clients FOR ub.clients.
DEFINE BUFFER X_delivery-subject FOR ub.delivery-subject.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список СУБЪЕКТЫ ДОСТАВКИ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 17/03/04
Author: Bakhtadze Natalya
Creation date: 17/03/04

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
define input-output PARAMETER p-sts AS INTEGER NO-UNDO.
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список СУБЪЕКТЫ ДОСТАВКИ":U.
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
{ gbl/flt-def.i }
{ gbl/fltfield.i }
{ gbl/fltopend.i defproc }


define variable v-rid-list as character no-undo .
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable filter-point-name as character no-undo .
define variable filter-point as character no-undo init "dlvsubjs" .
define variable filter-point0 as character no-undo init "dlvsubjs" .


&SCOPED-DEFINE status-code STRING(X_delivery-subject.sts)

define buffer pos_delivery-subject for ub.delivery-subject.

&scop cant-positioning   if error-status:error then do: ~
                          find first pos_delivery-subject no-lock where ~
                                  recid(pos_delivery-subject) = loc-doc-rec no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи СУБЪЕКТА ДОСТАВКИ" skip~
                            string(if avail pos_delivery-subject ~
                                    then  substitute("Вн код субъекта доставки: &1" ~
                                                    , pos_delivery-subject.deliv-subj-code) ~
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
&Scoped-define BROWSE-NAME br-delivsubject

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_delivery-subject

/* Definitions for BROWSE br-delivsubject                               */
&Scoped-define FIELDS-IN-QUERY-br-delivsubject ~
mark-string(recid(X_delivery-subject), v-rid-list) ~
X_delivery-subject.deliv-subj-name {&status-int-name} ~
X_delivery-subject.deliv-subj-code X_delivery-subject.reg-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-delivsubject ~
X_delivery-subject.reg-code
&Scoped-define ENABLED-TABLES-IN-QUERY-br-delivsubject X_delivery-subject
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-delivsubject X_delivery-subject
&Scoped-define QUERY-STRING-br-delivsubject FOR EACH X_delivery-subject NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-delivsubject OPEN QUERY br-delivsubject FOR EACH X_delivery-subject NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-delivsubject X_delivery-subject
&Scoped-define FIRST-TABLE-IN-QUERY-br-delivsubject X_delivery-subject


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-delivsubject}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-add b-lkp B-chg B-del ~
B-delivtype b-sch B-print B-hist B-Help RS-sts br-delivsubject mark-num
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

DEFINE BUTTON B-delivtype
     LABEL "Тип&ы доставки"
     SIZE 15 BY 1.

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

DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

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
DEFINE QUERY br-delivsubject FOR
      X_delivery-subject SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-delivsubject
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-delivsubject Dialog-Frame _STRUCTURED
  QUERY br-delivsubject NO-LOCK DISPLAY
      mark-string(recid(X_delivery-subject), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_delivery-subject.deliv-subj-name FORMAT "X(50)":U
      {&status-int-name} COLUMN-LABEL "Статус"
      X_delivery-subject.deliv-subj-code FORMAT ">>9":U
      X_delivery-subject.reg-code COLUMN-LABEL "Регион" FORMAT "ZZ9":U
  ENABLE
      X_delivery-subject.reg-code
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     B-add AT ROW 1 COL 31
     b-lkp AT ROW 1 COL 41
     B-chg AT ROW 1 COL 51
     B-del AT ROW 1 COL 61
     B-delivtype AT ROW 1 COL 71
     b-sch AT ROW 1 COL 86.5 WIDGET-ID 2
     B-print AT ROW 1 COL 89
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     RS-sts AT ROW 2.5 COL 3.5 NO-LABEL
     br-delivsubject AT ROW 4 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(78.62) SKIP(20.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Субъекты доставки"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_curr_clients B "?" ? ub clients
      TABLE: X_delivery-subject B "?" ? ub delivery-subject
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-delivsubject RS-sts Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       X_delivery-subject.reg-code:COLUMN-READ-ONLY IN BROWSE br-delivsubject = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-delivsubject
/* Query rebuild information for BROWSE br-delivsubject
     _TblList          = "X_delivery-subject"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"mark-string(recid(X_delivery-subject), v-rid-list)" "*" "X(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   = Temp-Tables.X_delivery-subject.deliv-subj-name
     _FldNameList[3]   > "_<CALC>"
"{&status-int-name}" "Статус" ? ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   = Temp-Tables.X_delivery-subject.deliv-subj-code
     _FldNameList[5]   > Temp-Tables.X_delivery-subject.reg-code
"X_delivery-subject.reg-code" "Регион" ? "integer" ? ? ? ? ? ? yes ? no no ? yes no yes "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-delivsubject */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Субъекты доставки */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Субъекты доставки */
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
run ref/dlvsubji.w
              (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&add-def}
                ,input 0 /*p-deliv-subj-code*/
                ,input-output loc-doc-rec
                            ) no-error
.
if loc-doc-rec <> ? THEN DO:
  RUn OpenBR in this-procedure ( input yes, input no, input no).
  reposition br-delivsubject to recid loc-doc-rec no-error.
  {&cant-positioning}
END.

apply "entry" to br-delivsubject in frame {&frame-name}.
apply "value-changed" to br-delivsubject in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available X_delivery-subject then return no-apply.
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
loc-doc-rec = recid(X_delivery-subject).

run ref/dlvsubji.w
              (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&update}
                ,input X_delivery-subject.deliv-subj-code
                ,input-output loc-doc-rec
                            ) no-error
.
if loc-doc-rec <> ? then do:
  RUn OpenBR in this-procedure ( input yes, input no, input no).
  reposition br-delivsubject to recid loc-doc-rec no-error.
  {&cant-positioning}
end.
apply "entry" to br-delivsubject in frame {&frame-name}.
apply "value-changed" to br-delivsubject in frame {&frame-name}.
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


&Scoped-define SELF-NAME B-delivtype
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-delivtype Dialog-Frame
ON CHOOSE OF B-delivtype IN FRAME Dialog-Frame /* Типы доставки */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  define variable v-sts as integer no-undo init ?.
  IF NOT AVAILABLE X_delivery-subject THEN RETURN no-apply.
  run ref/dlvtysus.w (input parParentProc
              , p-curr-obj-type
              , p-curr-obj-code
              , (IF LOOKUP("b-add":U, bttns) > 0 THEN "b-add":U ELSE "":U)
              , "delivery-subject"
              , 0
              ,  X_delivery-subject.deliv-subj-code
              , input-output v-sts
              , input-output v-rid-list ) no-error .
  APPLY "ENTRY" TO Br-delivsubject.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
  define variable loc-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo.
  if NOT available X_delivery-subject then return no-apply.
  loc-doc-rec = recid (X_delivery-subject).
  .
  run ref/dlvcsubs.w
                (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input "":U /*bttns*/
                ,input "one":U
                ,input X_delivery-subject.deliv-subj-code
                ,input-output v-rid-list
                              )
.
  reposition br-delivsubject to recid loc-doc-rec no-error.
  apply "entry" to br-delivsubject in frame {&frame-name}.
  apply "value-changed" to br-delivsubject in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available X_delivery-subject then return no-apply.

assign
loc-doc-rec = recid(X_delivery-subject).

run ref/dlvsubji.w
              (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&lookup}
                ,input X_delivery-subject.deliv-subj-code
                ,input-output loc-doc-rec
                            )
.

apply "entry" to br-delivsubject in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available X_delivery-subject then do:
    { gbl/markstrn.i X_delivery-subject v-rid-list }
    loc#log = br-delivsubject:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-delivsubject:select-next-row ().
        apply "VALUE-CHANGED" to br-delivsubject in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-delivsubject in frame {&frame-name}.
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
  APPLY "ENTRY" to br-delivsubject.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  RUN proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_delivery-subject ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_delivery-subject ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-delivsubject
&Scoped-define SELF-NAME br-delivsubject
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-delivsubject Dialog-Frame
ON RETURN OF br-delivsubject IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-delivsubject IN FRAME Dialog-Frame
    DO:
    run proc-br-delivsubject no-error.
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
  RUN openbr IN THIS-PROCEDURE ( input yes, input no, input no) NO-ERROR .
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
{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_delivery-subject.deliv-subj-code"
  &sort-clmn_2    = "X_delivery-subject.deliv-subj-name"
  &sort-clmn_3    = "X_delivery-subject.reg-code"
  &open-query     = "run OpenBr ( input yes, input no, input no)."
  &open-query-otherwise = "run OpenBr ( input yes, input no, input no)."
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

{ gbl/setfltnm.i }


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
  RUn OpenBR in this-procedure ( input yes, input no, input no).
  HIDE mark-num in frame {&frame-name} .
  if v-doc-rec <> ? then
  REPOSITION br-delivsubject to recid v-doc-rec No-ERROR.
    { gbl/mv-clmn.i
    &browse-name = "br-delivsubject"
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
  ENABLE b-quit B-mark B-sel B-add b-lkp B-chg B-del B-delivtype b-sch B-print
         B-hist B-Help RS-sts br-delivsubject mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyENable Dialog-Frame
PROCEDURE MyENable :
ASSIGN
rs-sts:RADIO-BUTTONS IN FRAME {&FRAME-NAME}
                       = "Текущие&+" + {&comma-char} +  {&current-status-int} + {&comma-char} +
                       "Все&!" + {&comma-char} + {&all} + {&comma-char} +
                        "Удаленные&-" + {&comma-char} + {&deleted-status-int}
rs-sts = (IF p-sts = ? THEN {&all} ELSE string(p-sts))
X_delivery-subject.reg-code:read-only in browse br-delivsubject  = yes
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
b-sch
B-print
B-Help
B-hist
B-delivtype
br-delivsubject
mark-num
rs-sts
with FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

define variable title0 as character no-undo .
DEFINE VARIABLE l-query-was-opened as logical no-undo .
define variable title00 as character no-undo.
define variable title01 as character no-undo.
assign
title0 = "Список субъектов доставки"
title00 = "Список субъектов доставки"
.
run waitfram-show in this-procedure ( INPUT "Ждите...").
DEFINE VARIABLE sort-column-phrase as character no-undo .

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

&scop flt-open-query-handle query br-delivsubject:handle

&scop flt-open-open-query-tail


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_delivery-subject

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_delivery-subject

&scop flt-open-open-query OPEN QUERY br-delivsubject FOR  EACH  X_delivery-subject no-lock

&scop flt-open-dyn_open-query  FOR EACH X_delivery-subject

&scop flt-open-waitfram true

&scop flt-open-debug-file

define variable l-open-query as logical   no-undo .

/*все */
  IF p-sts = ? THEN DO:
      assign
      filter-point-name = title00 .
      frame {&frame-name}:TITLE = title0 +  {&space-char} + {&status-int-name}.

      ASSIGN
      frame {&frame-name}:TITLE = SUBSTITUTE("&1", title00).
      { gbl/fltopend.i
      &where-cond = " true "
      &use-ind    = "  "
      &by         = "  " }
  END.
  ELSE DO:
&SCOPED-DEFINE status-code STRING(p-sts)
    frame {&frame-name}:TITLE = title00 +  {&space-char} + {&status-int-name}.
    filter-point-name = title00 +  {&space-char} + {&status-int-name}.
    { gbl/fltopend.i
    &where-cond = " X_delivery-subject.sts = p-sts "
    &dyn_where-cond = " substitute('X_delivery-subject.sts = &1', p-sts) "
    &use-ind    = "  "
    &by         = "  " }
end.
if not p-open-query then
REPOSITION br-delivsubject to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-delivsubject:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-delivsubject in frame {&frame-name}.
APPLY "ENTRY" TO br-delivsubject.
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
define variable v-sts like ub.delivery-subject.sts no-undo .
DEFINE VARIABLE loc-doc-rec AS RECID NO-UNDO.
if not available X_delivery-subject then return error.

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
  loc-doc-rec = RECID(X_delivery-subject)
  .
  run ref/dlvsubj2.p (
                  input recid(X_delivery-subject)
                  ,input-output v-sts
                 ) no-error .
  if error-status:error then undo, return error.
  RUN OpenBr ( input yes, input no, input no).
  REPOSITION br-delivsubject to recid loc-doc-rec No-error.
  {&cant-positioning}
  if available X_delivery-subject then do:
    loc#log = br-delivsubject:select-focused-row( ) IN FRAME {&FRAME-NAME}.
  end.
  apply "ENTRY" to br-delivsubject.
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

DEFINE FRAME delivery-subject-list
X_delivery-subject.deliv-subj-name
v-sts-chr FORMAT "X(8)" COLUMN-LABEL "Статус"
X_delivery-subject.des FORMAT "X(100)"
/*X_delivery-subject.t-mode*/
/*X_delivery-subject.p-mode*/
X_delivery-subject.deliv-subj-code COLUMN-LABEL "Вн.код!группы"
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

FORM with FRAME delivery-subject-list  .
run waitfram-show in this-procedure ("Ждите...").
v-doc-rec = recid(X_delivery-subject).
DO WHILE available X_delivery-subject :
  GET prev br-delivsubject.
END.
GET next br-delivsubject.
DO WHILE available X_delivery-subject :
  Display STREAM PrnLibStream
   X_delivery-subject.deliv-subj-name
  {&status-int-name} @ v-sts-chr
  X_delivery-subject.des
  /*X_delivery-subject.t-mode*/
  /*X_delivery-subject.p-mode*/
  X_delivery-subject.deliv-subj-code
with FRAME delivery-subject-list .
  DOWN STREAM PrnLibStream 1
  with FRAME delivery-subject-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-delivsubject.
END.
UNDERLINE  STREAM PrnLibStream
X_delivery-subject.deliv-subj-name
v-sts-chr
X_delivery-subject.des
/*X_delivery-subject.t-mode*/
/*X_delivery-subject.p-mode*/
X_delivery-subject.deliv-subj-code
with FRAME delivery-subject-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_delivery-subject.deliv-subj-name
accum-count @ v-sts-chr
with frame delivery-subject-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME delivery-subject-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-delivsubject to recid v-doc-rec no-error.
APPLY "entry" to br-delivsubject.
run waitfram-hide in this-procedure .
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
  tbl = 'delivery-subject'
  join-tbl = 'X_delivery-subject'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('deliv-subj-code', 'Код субъекта доставки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('reg-code', 'Регион', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('deliv-subj-name', 'Название', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                    , INPUT (filter-point + {&delim-par} +
                            filter-point-name)
                    , INPUT tbl
                    , INPUT join-tbl
                    , INPUT fld
                    , INPUT lab
                    , INPUT spr
                    , INPUT dim ).
  run OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-delivsubject Dialog-Frame
PROCEDURE proc-br-delivsubject :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ ref/brwsretr.i b-lkp }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME