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
DEFINE BUFFER X_deliv-type-cond-keep FOR ub.deliv-type-cond-keep.
DEFINE BUFFER X_delivery-type FOR ub.delivery-type.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список ВОЗМОЖНОСТЕЙ ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 22/03/04
Author: Bakhtadze Natalya
Creation date: 22/03/04

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
/*{&all} "delivery-type" "condition-keeping"*/
define input parameter p-deliv-type-code  LIKE ub.delivery-type.deliv-type-code   no-undo .
define input parameter p-cond-keep-code  LIKE ub.condition-keeping.cond-keep-code   no-undo .
define input-output parameter p-sts as integer no-undo .
define input-output PARAMETER p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список ВОЗМОЖНОСТЕЙ ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ":U.
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
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }
define variable v-rid-list as character no-undo .
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable filter-label as character no-undo init "Список ВОЗМОЖНОСТЕЙ ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ" .
define variable filter-label0 as character no-undo init "Список ВОЗМОЖНОСТЕЙ ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ" .
define variable filter-point as character no-undo init "dlvtcnds" .
define variable filter-point0 as character no-undo init "dlvtcnds" .



&SCOPED-DEFINE status-code STRING(X_deliv-type-cond-keep.sts)

define buffer pos_deliv-type-cond-keep for ub.deliv-type-cond-keep.

&scop cant-positioning   if error-status:error then do: ~
                          find first pos_deliv-type-cond-keep no-lock where ~
                                  recid(pos_deliv-type-cond-keep) = loc-doc-rec no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи ВОЗМОЖНОСТИ ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ" skip~
                            string(if avail pos_deliv-type-cond-keep ~
                                    then  substitute("Вн код типа доставки: &1 вн код услоий хранения: &2" ~
                                                    , pos_deliv-type-cond-keep.deliv-type-code ~
                                                    , pos_deliv-type-cond-keep.cond-keep-code) ~
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
&Scoped-define BROWSE-NAME br-delivtypecndk

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_deliv-type-cond-keep

/* Definitions for BROWSE br-delivtypecndk                              */
&Scoped-define FIELDS-IN-QUERY-br-delivtypecndk ~
mark-string(recid(X_deliv-type-cond-keep), v-rid-list) ~
X_deliv-type-cond-keep.deliv-type-code ~
get-type(X_deliv-type-cond-keep.deliv-type-code) ~
X_deliv-type-cond-keep.cond-keep-code ~
get-cond-keep(X_deliv-type-cond-keep.cond-keep-code) {&status-int-name} ~
X_deliv-type-cond-keep.des
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-delivtypecndk
&Scoped-define QUERY-STRING-br-delivtypecndk FOR EACH X_deliv-type-cond-keep NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-delivtypecndk OPEN QUERY br-delivtypecndk FOR EACH X_deliv-type-cond-keep NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-delivtypecndk X_deliv-type-cond-keep
&Scoped-define FIRST-TABLE-IN-QUERY-br-delivtypecndk X_deliv-type-cond-keep


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-delivtypecndk}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-add b-lkp B-chg B-del ~
B-print B-hist B-sch B-Help RS-sts br-delivtypecndk mark-num
&Scoped-Define DISPLAYED-OBJECTS RS-sts mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cond-keep Dialog-Frame
FUNCTION get-cond-keep RETURNS CHARACTER
  ( INPUT p-cond-keep-code AS INTEGER)  FORWARD.

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

DEFINE BUTTON B-sch
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
DEFINE QUERY br-delivtypecndk FOR
      X_deliv-type-cond-keep SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-delivtypecndk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-delivtypecndk Dialog-Frame _STRUCTURED
  QUERY br-delivtypecndk NO-LOCK DISPLAY
      mark-string(recid(X_deliv-type-cond-keep), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_deliv-type-cond-keep.deliv-type-code COLUMN-LABEL "Вн.код!типа!доставки" FORMAT ">>9":U
      get-type(X_deliv-type-cond-keep.deliv-type-code) COLUMN-LABEL "Тип доставки" FORMAT "X(25)":U
      X_deliv-type-cond-keep.cond-keep-code COLUMN-LABEL "Вн.код!условий!хранения" FORMAT ">>9":U
      get-cond-keep(X_deliv-type-cond-keep.cond-keep-code) COLUMN-LABEL "Условия хранения" FORMAT "X(25)":U
      {&status-int-name} COLUMN-LABEL "Статус"
      X_deliv-type-cond-keep.des FORMAT "X(100)":U
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
     B-print AT ROW 1 COL 86
     B-hist AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     RS-sts AT ROW 2.25 COL 3.5 NO-LABEL
     br-delivtypecndk AT ROW 3.5 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(78.62) SKIP(20.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Возможности доставки по условиям хранения"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_condition-keeping B "?" ? ub condition-keeping
      TABLE: X_curr_clients B "?" ? ub clients
      TABLE: X_deliv-type-cond-keep B "?" ? ub deliv-type-cond-keep
      TABLE: X_delivery-type B "?" ? ub delivery-type
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-delivtypecndk RS-sts Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-delivtypecndk
/* Query rebuild information for BROWSE br-delivtypecndk
     _TblList          = "X_deliv-type-cond-keep"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"mark-string(recid(X_deliv-type-cond-keep), v-rid-list)" "*" "X(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.X_deliv-type-cond-keep.deliv-type-code
"X_deliv-type-cond-keep.deliv-type-code" "Вн.код!типа!доставки" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > "_<CALC>"
"get-type(X_deliv-type-cond-keep.deliv-type-code)" "Тип доставки" "X(25)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > Temp-Tables.X_deliv-type-cond-keep.cond-keep-code
"X_deliv-type-cond-keep.cond-keep-code" "Вн.код!условий!хранения" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > "_<CALC>"
"get-cond-keep(X_deliv-type-cond-keep.cond-keep-code)" "Условия хранения" "X(25)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > "_<CALC>"
"{&status-int-name}" "Статус" ? ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > Temp-Tables.X_deliv-type-cond-keep.des
"X_deliv-type-cond-keep.des" ? "X(100)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-delivtypecndk */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Возможности доставки по условиям хранения */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Возможности доставки по условиям хранения */
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
run ref/dlvtcndi.w
              (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&add-def}
                ,input (if p-mode = "delivery-type" or p-mode = "one":U
                        then p-deliv-type-code
                        else 0) /*p-deliv-type-code*/
                ,input (if p-mode = "delivery-subj" or p-mode = "one":U
                        then p-cond-keep-code
                        else 0) /*p-cond-keep-code*/
                ,input-output loc-doc-rec
                            ) no-error
.
if loc-doc-rec <> ? then  do:
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  reposition br-delivtypecndk to recid loc-doc-rec no-error.
  {&cant-positioning}
end.
apply "entry" to br-delivtypecndk in frame {&frame-name}.
apply "value-changed" to br-delivtypecndk in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available X_deliv-type-cond-keep then return no-apply.
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
loc-doc-rec = recid(X_deliv-type-cond-keep).

run ref/dlvtcndi.w
              (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&update}
                ,input X_deliv-type-cond-keep.deliv-type-code
                ,input X_deliv-type-cond-keep.cond-keep-code
                ,input-output loc-doc-rec
                            ) no-error
.
if loc-doc-rec <> ? then do:
  RUn OpenBR in this-procedure ( input yes, input no, input no).
  reposition br-delivtypecndk to recid loc-doc-rec no-error.
  {&cant-positioning}
end.
apply "entry" to br-delivtypecndk in frame {&frame-name}.
apply "value-changed" to br-delivtypecndk in frame {&frame-name}.
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
  if NOT available X_deliv-type-cond-keep then return no-apply.
  loc-doc-rec = recid (X_deliv-type-cond-keep).
  .
  run ref/dlvctcns.w
                (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input "":U /*bttns*/
                ,input "one":U
                ,input X_deliv-type-cond-keep.deliv-type-code
                ,input X_deliv-type-cond-keep.cond-keep-code
                ,input-output v-rid-list
                              )
.
  reposition br-delivtypecndk to recid loc-doc-rec no-error.
  apply "entry" to br-delivtypecndk in frame {&frame-name}.
  apply "value-changed" to br-delivtypecndk in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available X_deliv-type-cond-keep then return no-apply.

assign
loc-doc-rec = recid(X_deliv-type-cond-keep).

run ref/dlvtcndi.w
              (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&lookup}
                ,input X_deliv-type-cond-keep.deliv-type-code
                ,input X_deliv-type-cond-keep.cond-keep-code
                ,input-output loc-doc-rec
                            )
.

apply "entry" to br-delivtypecndk in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available X_deliv-type-cond-keep then do:
    { gbl/markstrn.i X_deliv-type-cond-keep v-rid-list }
    loc#log = br-delivtypecndk:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-delivtypecndk:select-next-row ().
        apply "VALUE-CHANGED" to br-delivtypecndk in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-delivtypecndk in frame {&frame-name}.
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
  APPLY "ENTRY" to br-delivtypecndk.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
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
    if ( available X_deliv-type-cond-keep ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_deliv-type-cond-keep ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-delivtypecndk
&Scoped-define SELF-NAME br-delivtypecndk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-delivtypecndk Dialog-Frame
ON RETURN OF br-delivtypecndk IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-delivtypecndk IN FRAME Dialog-Frame
    DO:
    run proc-br-delivtypecndk no-error.
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
  RUN openbr IN THIS-PROCEDURE ( input YES, input NO, input '':U) NO-ERROR.
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
  &sort-clmn_1    = "X_deliv-type-cond-keep.deliv-type-code"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}


{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/setfltnm.i }

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
 if LOOKUP(p-mode, ({&all} + {&delim-par} + "delivery-type" + {&delim-par} + "condition-keeping") ,
                {&delim-par}) = 0
     then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return error .
 end.
 IF p-mode = "delivery-type" THEN DO:
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
IF p-mode = "condition-keeping" THEN DO:
     FIND FIRST X_condition-keeping NO-LOCK WHERE
                X_condition-keeping.cond-keep-code = p-cond-keep-code NO-ERROR.
    IF NOT AVAILABLE X_delivery-type THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-cond-keep-code"
        p-cond-keep-code
        view-as alert-box ERROR.
        return error .
   END.
 END.
 v-rid-list = p-rid-list.
 { gbl/curdbnum.i v-db-num }
  RUN MyEnable.
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if v-doc-rec <> ? then
  REPOSITION br-delivtypecndk to recid v-doc-rec No-ERROR.
    { gbl/mv-clmn.i
    &browse-name = "br-delivtypecndk"
    &frame-name = "{&frame-name}"
    &ext-col = 7
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7'"
    &prev-order-column-condition_1 = " p-mode = ~{&all~} "
    &prev-order-column_2 = "'1,4,5,6,7,2,3'"
    &prev-order-column-condition_2 = " p-mode = 'delivery-type' "
    &prev-order-column_3 = "'1,2,3,6,7,4,5'"
    &prev-order-column-condition_3 = " p-mode = 'condition-keeping' "
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
  ENABLE b-quit B-mark B-sel B-add b-lkp B-chg B-del B-print B-hist B-sch
         B-Help RS-sts br-delivtypecndk mark-num
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
b-sch
br-delivtypecndk
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
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Список возможностей доставки по условиям хранения" + {&space-char}.
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

&scop flt-open-open-query OPEN QUERY br-delivtypecndk FOR EACH X_deliv-type-cond-keep

&scop flt-open-dyn_open-query FOR EACH X_deliv-type-cond-keep

&scop flt-open-query-handle QUERY br-delivtypecndk:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_deliv-type-cond-keep

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_deliv-type-cond-keep

&scop flt-open-waitfram true

define variable l-open-query as logical   no-undo .

&SCOPED-DEFINE status-code STRING(p-sts)

  CASE p-mode :
    WHEN {&all}        THEN DO:
     assign
     filter-point = filter-point0 + p-mode
     filter-label = substitute("&1", filter-label0)
     .
     IF p-sts = ?  THEN DO:
        { gbl/fltopend.i
          &where-cond = " TRUE "
          &use-ind    = "  "
          &by         = "  " }
     END.
     ELSE DO:
      ASSIGN
      frame {&frame-name}:TITLE = title0 + {&space-char} + {&status-int-name}
      filter-label = substitute("&1 определенный статус", filter-label0)
      .
      { gbl/fltopend.i
        &where-cond = " X_deliv-type-cond-keep.sts = p-sts "
        &dyn_where-cond = " substitute('X_deliv-type-cond-keep.sts = &1', p-sts )"
        &use-ind    = "  "
        &by         = "  " }

     END.
    END.
    WHEN "delivery-type" THEN DO:
       filter-point = filter-point0 + p-mode.
       ASSIGN
       frame {&frame-name}:TITLE = title0 +
                                   substitute(" Тип доставки: &1"
                                   , X_delivery-type.deliv-type-name) +
                                   {&space-char} + (if p-sts = ? then "":U else  {&status-int-name})
       filter-label = substitute("&1 один тип доставки", filter-label0)
                                   .
      IF p-sts = ? THEN DO:
        { gbl/fltopend.i
        &where-cond = " ~
          X_deliv-type-cond-keep.deliv-type-code  = p-deliv-type-code    ~
                      "
        &dyn_where-cond = " substitute('X_deliv-type-cond-keep.deliv-type-code  = &1', p-deliv-type-code) "

        &use-ind    = "  "
        &by         = "  " }
      END.
      ELSE DO:
          { gbl/fltopend.i
          &where-cond = " ~
            X_deliv-type-cond-keep.deliv-type-code  = p-deliv-type-code    ~
          AND X_deliv-type-cond-keep.sts = p-sts "
          &dyn_where-cond = " substitute(' X_deliv-type-cond-keep.deliv-type-code  = &1    ~
          AND X_deliv-type-cond-keep.sts = &2 ', p-deliv-type-code, p-sts)"

          &use-ind    = "  "
          &by         = "  " }

      END.
    END.
  WHEN "condition-keeping" THEN DO:
     filter-point = filter-point0 + p-mode.
     ASSIGN
     frame {&frame-name}:TITLE = title0 +
                                 substitute(" Условия хранения: &1"
                                 , X_condition-keeping.cond-keep-name) +
                                 {&space-char} + (if p-sts = ? then "":U else  {&status-int-name})
     filter-label = substitute("&1 один тип условий хранения", filter-label0)
                                 .
    IF p-sts = ? THEN DO:
     { gbl/fltopend.i
      &where-cond = " ~
        X_deliv-type-cond-keep.cond-keep-code  = p-cond-keep-code    ~
                    "
      &dyn_where-cond = " substitute(' X_deliv-type-cond-keep.cond-keep-code  = &1', p-cond-keep-code )"

      &use-ind    = "  "
      &by         = "  " }
    END.
    ELSE DO:
        { gbl/fltopend.i
         &where-cond = " ~
           X_deliv-type-cond-keep.cond-keep-code  = p-cond-keep-code    ~
           AND X_deliv-type-cond-keep.sts = p-sts "
         &dyn_where-cond = " substitute(' X_deliv-type-cond-keep.cond-keep-code  = &1   ~
           AND X_deliv-type-cond-keep.sts = &2 ', p-cond-keep-code, p-sts )"

         &use-ind    = "  "
         &by         = "  " }

    END.
  END.
END CASE.
if not p-open-query then
REPOSITION br-delivtypecndk to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-delivtypecndk:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-delivtypecndk in frame {&frame-name}.
APPLY "ENTRY" TO br-delivtypecndk.
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
define variable v-sts like ub.deliv-type-cond-keep.sts no-undo .
DEFINE VARIABLE loc-doc-rec AS RECID NO-UNDO.
if not available X_deliv-type-cond-keep then return error.

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
  loc-doc-rec = RECID(X_deliv-type-cond-keep)
  .
  run ref/dlvtcnd2.p (
                  input recid(X_deliv-type-cond-keep)
                  ,input-output v-sts
                 ) no-error .
  if error-status:error then undo, return error.
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
  REPOSITION br-delivtypecndk to recid loc-doc-rec No-error.
  {&cant-positioning}
  if available X_deliv-type-cond-keep then do:
    loc#log = br-delivtypecndk:select-focused-row( ) IN FRAME {&FRAME-NAME}.
  end.
  apply "ENTRY" to br-delivtypecndk.
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
define variable v-deliv-type-name like ub.delivery-type.deliv-type-name no-undo .
define variable v-cond-keep-name like ub.condition-keeping.cond-keep-name no-undo .

DEFINE FRAME deliv-type-cond-keep-list
v-sts-chr FORMAT "X(8)" COLUMN-LABEL "Статус"
X_deliv-type-cond-keep.deliv-type-code COLUMN-LABEL "Вн.код!типа дост-ки"
v-deliv-type-name COLUmn-LABEL "Тип доставки" format "X(25)"
X_deliv-type-cond-keep.cond-keep-code COLUMN-LABEL "Вн.код!условий!хранения"
v-cond-keep-name COLUmn-LABEL "Условия хранения" format "X(25)"
X_deliv-type-cond-keep.des FORMAT "X(100)"
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

FORM with FRAME deliv-type-cond-keep-list  .
run waitfram-show in this-procedure ("Ждите...").
v-doc-rec = recid(X_deliv-type-cond-keep).
DO WHILE available X_deliv-type-cond-keep :
  GET prev br-delivtypecndk.
END.
GET next br-delivtypecndk.
DO WHILE available X_deliv-type-cond-keep :
  Display STREAM PrnLibStream
  {&status-int-name} @ v-sts-chr
  X_deliv-type-cond-keep.deliv-type-code
  get-type(X_deliv-type-cond-keep.deliv-type-code) @ v-deliv-type-name
  X_deliv-type-cond-keep.cond-keep-code
  get-cond-keep(X_deliv-type-cond-keep.cond-keep-code) @ v-cond-keep-name
  X_deliv-type-cond-keep.des
with FRAME deliv-type-cond-keep-list .
  DOWN STREAM PrnLibStream 1
  with FRAME deliv-type-cond-keep-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-delivtypecndk.
END.
UNDERLINE  STREAM PrnLibStream
v-sts-chr
X_deliv-type-cond-keep.deliv-type-code
v-deliv-type-name
X_deliv-type-cond-keep.cond-keep-code
v-cond-keep-name
X_deliv-type-cond-keep.des
with FRAME deliv-type-cond-keep-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ v-deliv-type-name
accum-count @ v-sts-chr
with frame deliv-type-cond-keep-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME deliv-type-cond-keep-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-delivtypecndk to recid v-doc-rec no-error.
APPLY "entry" to br-delivtypecndk.
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
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
  tbl = 'deliv-type-cond-keep'
  join-tbl = 'X_deliv-type-cond-keep'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('deliv-type-code', 'Код типа доставки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cond-keep-code', 'Код условий хранения', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('des', 'Описание', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sts', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-delivtypecndk Dialog-Frame
PROCEDURE proc-br-delivtypecndk :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ ref/brwsretr.i b-lkp }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cond-keep Dialog-Frame
FUNCTION get-cond-keep RETURNS CHARACTER
  ( INPUT p-cond-keep-code AS INTEGER) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
DEFINE BUFFER loc_condition-keeping FOR ub.condition-keeping.
FIND FIRST loc_condition-keeping NO-LOCK WHERE
          loc_condition-keeping.cond-keep-code = p-cond-keep-code NO-ERROR.
IF AVAILABLE loc_condition-keeping THEN RETURN loc_condition-keeping.cond-keep-name.
  RETURN "Неизв.условия хранения".   /* Function return value. */

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
