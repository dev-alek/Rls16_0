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
DEFINE BUFFER X_delivery-type FOR ub.delivery-type.
DEFINE BUFFER X_delivery-type-subject FOR ub.delivery-type-subject.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список ТИПОВ ДОСТАВКИ ОТ СУБЪЕКТОВ

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
/*{&all} "delivery-type" "delivery-subject"*/
define input parameter p-deliv-type-code  LIKE ub.delivery-type.deliv-type-code   no-undo .
define input parameter p-deliv-subj-code  LIKE ub.delivery-subject.deliv-subj-code   no-undo .
define input-output parameter p-sts as integer no-undo .
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список ТИПОВ ДОСТАВКИ ОТ СУБЪЕКТОВ":U.
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
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
define variable filter-label as character no-undo init "dlvtysus" .
define variable filter-label0 as character no-undo init "dlvtysus" .
define variable filter-point as character no-undo init "Список типов доставки от субъектов" .
define variable filter-point0 as character no-undo init "Список типов доставки от субъектов" .



&SCOPED-DEFINE status-code STRING(X_delivery-type-subject.sts)

define buffer pos_delivery-type-subject for ub.delivery-type-subject.

&scop cant-positioning   if error-status:error then do: ~
                          find first pos_delivery-type-subject no-lock where ~
                                  recid(pos_delivery-type-subject) = loc-doc-rec no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи ТИПА ДОСТАВКИ ОТ СУБЪЕКТОВ" skip~
                            string(if avail pos_delivery-type-subject ~
                                    then  substitute("Вн код типа доставки: &1 вн код субъекта доставки: &2" ~
                                                    , pos_delivery-type-subject.deliv-type-code ~
                                                    , pos_delivery-type-subject.deliv-subj-code) ~
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
&Scoped-define BROWSE-NAME br-delivtypesubj

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_delivery-type-subject

/* Definitions for BROWSE br-delivtypesubj                              */
&Scoped-define FIELDS-IN-QUERY-br-delivtypesubj ~
mark-string(recid(X_delivery-type-subject), v-rid-list) ~
X_delivery-type-subject.deliv-type-code ~
get-type(X_delivery-type-subject.deliv-type-code) ~
X_delivery-type-subject.deliv-subj-code ~
get-subject(X_delivery-type-subject.deliv-subj-code) {&status-int-name} ~
X_delivery-type-subject.des
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-delivtypesubj
&Scoped-define QUERY-STRING-br-delivtypesubj FOR EACH X_delivery-type-subject NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-delivtypesubj OPEN QUERY br-delivtypesubj FOR EACH X_delivery-type-subject NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-delivtypesubj X_delivery-type-subject
&Scoped-define FIRST-TABLE-IN-QUERY-br-delivtypesubj X_delivery-type-subject


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-delivtypesubj}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-add b-lkp B-chg B-del ~
B-print B-hist B-sch B-Help B-obj RS-sts br-delivtypesubj mark-num
&Scoped-Define DISPLAYED-OBJECTS RS-sts mark-num

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

DEFINE BUTTON B-obj
     LABEL "&Объекты доставки"
     SIZE 20 BY 1.

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
DEFINE QUERY br-delivtypesubj FOR
      X_delivery-type-subject SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-delivtypesubj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-delivtypesubj Dialog-Frame _STRUCTURED
  QUERY br-delivtypesubj NO-LOCK DISPLAY
      mark-string(recid(X_delivery-type-subject), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_delivery-type-subject.deliv-type-code COLUMN-LABEL "Вн.код!типа!доставки" FORMAT ">>9":U
      get-type(X_delivery-type-subject.deliv-type-code) COLUMN-LABEL "Тип доставки" FORMAT "X(25)":U
      X_delivery-type-subject.deliv-subj-code COLUMN-LABEL "Вн.код!субъекта!доставки" FORMAT ">>9":U
      get-subject(X_delivery-type-subject.deliv-subj-code) COLUMN-LABEL "Субъект доставки" FORMAT "X(25)":U
      {&status-int-name} COLUMN-LABEL "Статус"
      X_delivery-type-subject.des FORMAT "X(100)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16.25.


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
     B-obj AT ROW 2 COL 51
     RS-sts AT ROW 3.5 COL 3.5 NO-LABEL
     br-delivtypesubj AT ROW 5 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(78.62) SKIP(20.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Типы доставки от субъекта"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_curr_clients B "?" ? ub clients
      TABLE: X_delivery-subject B "?" ? ub delivery-subject
      TABLE: X_delivery-type B "?" ? ub delivery-type
      TABLE: X_delivery-type-subject B "?" ? ub delivery-type-subject
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-delivtypesubj RS-sts Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-delivtypesubj
/* Query rebuild information for BROWSE br-delivtypesubj
     _TblList          = "X_delivery-type-subject"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"mark-string(recid(X_delivery-type-subject), v-rid-list)" "*" "X(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.X_delivery-type-subject.deliv-type-code
"X_delivery-type-subject.deliv-type-code" "Вн.код!типа!доставки" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > "_<CALC>"
"get-type(X_delivery-type-subject.deliv-type-code)" "Тип доставки" "X(25)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > Temp-Tables.X_delivery-type-subject.deliv-subj-code
"X_delivery-type-subject.deliv-subj-code" "Вн.код!субъекта!доставки" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > "_<CALC>"
"get-subject(X_delivery-type-subject.deliv-subj-code)" "Субъект доставки" "X(25)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > "_<CALC>"
"{&status-int-name}" "Статус" ? ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > Temp-Tables.X_delivery-type-subject.des
"X_delivery-type-subject.des" ? "X(100)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-delivtypesubj */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Типы доставки от субъекта */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Типы доставки от субъекта */
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
run ref/dlvtysui.w
              (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&add-def}
                ,input (if p-mode = "delivery-type"
                        then p-deliv-type-code
                        else 0) /*p-deliv-type-code*/
                ,input (if p-mode = "delivery-subject"
                        then p-deliv-subj-code
                        else 0) /*p-deliv-subj-code*/
                ,input-output loc-doc-rec
                            ) no-error
.
if loc-doc-rec <> ? then do:
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  reposition br-delivtypesubj to recid loc-doc-rec no-error.
  {&cant-positioning}
end.
apply "entry" to br-delivtypesubj in frame {&frame-name}.
apply "value-changed" to br-delivtypesubj in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available X_delivery-type-subject then return no-apply.
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
loc-doc-rec = recid(X_delivery-type-subject).

run ref/dlvtysui.w
              (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&update}
                ,input X_delivery-type-subject.deliv-type-code
                ,input X_delivery-type-subject.deliv-subj-code
                ,input-output loc-doc-rec
                            ) no-error
.
if loc-doc-rec <> ? then do:
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  reposition br-delivtypesubj to recid loc-doc-rec no-error.
  {&cant-positioning}
end.
apply "entry" to br-delivtypesubj in frame {&frame-name}.
apply "value-changed" to br-delivtypesubj in frame {&frame-name}.
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
  if NOT available X_delivery-type-subject then return no-apply.
  loc-doc-rec = recid (X_delivery-type-subject).
  .
  run ref/dlvctyss.w
                (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input "":U /*bttns*/
                ,input "one":U
                ,input X_delivery-type-subject.deliv-type-code
                ,input X_delivery-type-subject.deliv-subj-code
                ,input-output v-rid-list
                              )
.
  reposition br-delivtypesubj to recid loc-doc-rec no-error.
  apply "entry" to br-delivtypesubj in frame {&frame-name}.
  apply "value-changed" to br-delivtypesubj in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available X_delivery-type-subject then return no-apply.

assign
loc-doc-rec = recid(X_delivery-type-subject).

run ref/dlvtysui.w
              (
                 input parParentProc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&lookup}
                ,input X_delivery-type-subject.deliv-type-code
                ,input X_delivery-type-subject.deliv-subj-code
                ,input-output loc-doc-rec
                            )
.

apply "entry" to br-delivtypesubj in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available X_delivery-type-subject then do:
    { gbl/markstrn.i X_delivery-type-subject v-rid-list }
    loc#log = br-delivtypesubj:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-delivtypesubj:select-next-row ().
        apply "VALUE-CHANGED" to br-delivtypesubj in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-delivtypesubj in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-obj Dialog-Frame
ON CHOOSE OF B-obj IN FRAME Dialog-Frame /* Объекты доставки */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  define variable v-sts as integer no-undo init ? .
  IF NOT AVAILABLE X_delivery-type-subject  THEN DO:
      RETURN NO-APPLY.
  END.
  run ref/vardelvs.w (
                     INPUT parParentProc
                  ,  input p-curr-obj-type
                  ,  input p-curr-obj-code
                  ,  input (if lookup("b-add":U, bttns) > 0 then "b-add":U else "":U)
                  ,  INPUT "delivery-type-subject":U
                  ,  input X_delivery-type-subject.deliv-type-code
                  ,  input X_delivery-type-subject.deliv-subj-code
                  ,  input "":U /*p-deliv-obj-type   */
                  ,  input 0 /* p-deliv-obj-code   */
                  ,  input-output v-sts
                  ,  input-output v-rid-list    ) NO-ERROR.

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
  APPLY "ENTRY" to br-delivtypesubj.

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
    if ( available X_delivery-type-subject ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_delivery-type-subject ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-delivtypesubj
&Scoped-define SELF-NAME br-delivtypesubj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-delivtypesubj Dialog-Frame
ON RETURN OF br-delivtypesubj IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-delivtypesubj IN FRAME Dialog-Frame
    DO:
    run proc-br-delivtypesubj no-error.
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
  &sort-clmn_1    = "X_delivery-type-subject.deliv-type-code"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
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
 if LOOKUP(p-mode, ({&all} + {&delim-par} + "delivery-type" + {&delim-par} + "delivery-subject") ,
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
IF p-mode = "delivery-subject" THEN DO:
     FIND FIRST X_delivery-subject NO-LOCK WHERE
                X_delivery-subject.deliv-subj-code = p-deliv-subj-code NO-ERROR.
    IF NOT AVAILABLE X_delivery-subject THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-deliv-subj-code"
        p-DELIV-subj-CODE
        view-as alert-box ERROR.
        return error .
   END.
 END.
 { gbl/curdbnum.i v-db-num }
 v-rid-list = p-rid-list.
  RUN MyEnable.
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if v-doc-rec <> ? then
  REPOSITION br-delivtypesubj to recid v-doc-rec No-ERROR.
    { gbl/mv-clmn.i
    &browse-name = "br-delivtypesubj"
    &frame-name = "{&frame-name}"
    &ext-col = 7
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7'"
    &prev-order-column-condition_1 = " p-mode = ~{&all~} "
    &prev-order-column_2 = "'1,4,5,6,7,2,3'"
    &prev-order-column-condition_2 = " p-mode = 'delivery-type' "
    &prev-order-column_3 = "'1,2,3,6,7,4,5'"
    &prev-order-column-condition_3 = " p-mode = 'delivery-subject' "
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
         B-Help B-obj RS-sts br-delivtypesubj mark-num
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
b-obj
br-delivtypesubj
mark-num
RS-sts
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
title0 = "Список типов доставки до субъектов" + {&space-char}.
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

&scop flt-open-open-query OPEN QUERY br-delivtypesubj FOR EACH X_delivery-type-subject

&scop flt-open-dyn_open-query FOR EACH X_delivery-type-subject

&scop flt-open-query-handle  QUERY br-delivtypesubj:handle

&scop flt-open-open-query-tail


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_delivery-type-subject

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_delivery-type-subject

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
          frame {&frame-name}:TITLE = title0 + {&space-char} + {&status-int-name}.
          { gbl/fltopend.i
          &where-cond = " X_delivery-type-subject.sts = p-sts "
          &dyn_where-cond = " substitute('X_delivery-type-subject.sts = &1', p-sts) "
          &use-ind    = "  "
          &by         = "  " }
      END.

    END.
    WHEN "delivery-type" THEN DO:
      assign
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1 Один тип доставки", filter-label0)
      .
       ASSIGN
       frame {&frame-name}:TITLE = title0 +
                                   substitute(" Тип доставки: &1"
                                   , X_delivery-type.deliv-type-name) +
                                   {&space-char} + (if p-sts = ? then "":U else  {&status-int-name}).
      IF p-sts = ?  THEN DO:
          { gbl/fltopend.i
            &where-cond = " ~
              X_delivery-type-subject.deliv-type-code  = p-deliv-type-code    ~
                          "
            &dyn_where-cond = " substitute(' X_delivery-type-subject.deliv-type-code  = &1' , p-deliv-type-code ) "

            &use-ind    = "  "
            &by         = "  " }
      END.
      ELSE DO:
          { gbl/fltopend.i
            &where-cond = " ~
              X_delivery-type-subject.deliv-type-code  = p-deliv-type-code ~
          AND X_delivery-type-subject.sts  = p-sts "
            &dyn_where-cond = " substitute(' X_delivery-type-subject.deliv-type-code  = &1 ~
          AND X_delivery-type-subject.sts  = &2 ', p-deliv-type-code, p-sts)"

            &use-ind    = "  "
            &by         = "  " }

     END.
    END.
    WHEN "delivery-subject" THEN DO:
     assign
     filter-point = filter-point0 + p-mode
     filter-label = substitute("&1 Один субъект доставки", filter-label0)
     .
     ASSIGN
     frame {&frame-name}:TITLE = title0 +
                                 substitute(" Субъект доставки: &1"
                                 , X_delivery-subject.deliv-subj-name) +
                                 {&space-char} + (if p-sts = ? then "":U else  {&status-int-name}).
     IF p-sts = ?  THEN DO:
        { gbl/fltopend.i
          &where-cond = " ~
            X_delivery-type-subject.deliv-subj-code  = p-deliv-subj-code    ~
                        "
          &dyn_where-cond = " substitute('X_delivery-type-subject.deliv-subj-code  = &1', p-deliv-subj-code) "

          &use-ind    = "  "
          &by         = "  " }
     END.
     ELSE DO:
         { gbl/fltopend.i
           &where-cond = " ~
             X_delivery-type-subject.deliv-subj-code  = p-deliv-subj-code    ~
         AND X_delivery-type-subject.sts = p-sts "
           &dyn_where-cond = " substitute('X_delivery-type-subject.deliv-subj-code  = &1    ~
         AND X_delivery-type-subject.sts = &2 ', p-deliv-subj-code, p-sts) "
           &use-ind    = "  "
           &by         = "  " }

     END.
  END.
END CASE.
if not p-open-query then
REPOSITION br-delivtypesubj to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-delivtypesubj:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-delivtypesubj in frame {&frame-name}.
APPLY "ENTRY" TO br-delivtypesubj.
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
define variable v-sts like ub.delivery-type-subject.sts no-undo .
DEFINE VARIABLE loc-doc-rec AS RECID NO-UNDO.
if not available X_delivery-type-subject then return error.

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
  loc-doc-rec = RECID(X_delivery-type-subject)
  .
  run ref/dlvtysu2.p (
                  input recid(X_delivery-type-subject)
                  ,input-output v-sts
                 ) no-error .
  if error-status:error then undo, return error.
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
  REPOSITION br-delivtypesubj to recid loc-doc-rec No-error.
  {&cant-positioning}
  if available X_delivery-type-subject then do:
    loc#log = br-delivtypesubj:select-focused-row( ) IN FRAME {&FRAME-NAME}.
  end.
  apply "ENTRY" to br-delivtypesubj.
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
define variable v-deliv-subj-name like ub.delivery-subject.deliv-subj-name no-undo .

DEFINE FRAME delivery-type-subject-list
v-sts-chr FORMAT "X(8)" COLUMN-LABEL "Статус"
X_delivery-type-subject.des FORMAT "X(100)"
X_delivery-type-subject.deliv-type-code COLUMN-LABEL "Вн.код!типа!доставки"
v-deliv-type-name COLUmn-LABEL "Тип доставки" format "X(25)"
X_delivery-type-subject.deliv-subj-code COLUMN-LABEL "Вн.код!субъекта!доставки"
v-deliv-subj-name COLUmn-LABEL "Субъект доставки" format "X(25)"
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

FORM with FRAME delivery-type-subject-list  .
run waitfram-show in this-procedure ("Ждите...").
v-doc-rec = recid(X_delivery-type-subject).
DO WHILE available X_delivery-type-subject :
  GET prev br-delivtypesubj.
END.
GET next br-delivtypesubj.
DO WHILE available X_delivery-type-subject :
  Display STREAM PrnLibStream
  {&status-int-name} @ v-sts-chr
  X_delivery-type-subject.deliv-type-code
  get-type(X_delivery-type-subject.deliv-type-code) @ v-deliv-type-name
  X_delivery-type-subject.deliv-subj-code
  get-subject(X_delivery-type-subject.deliv-subj-code) @ v-deliv-subj-name
  X_delivery-type-subject.des
with FRAME delivery-type-subject-list .
  DOWN STREAM PrnLibStream 1
  with FRAME delivery-type-subject-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-delivtypesubj.
END.
UNDERLINE  STREAM PrnLibStream
v-sts-chr
X_delivery-type-subject.deliv-type-code
v-deliv-type-name
X_delivery-type-subject.deliv-subj-code
v-deliv-subj-name
X_delivery-type-subject.des
with FRAME delivery-type-subject-list .
DISPLAY STREAM PrnLibStream
/*"ИТОГО" @ X_delivery-type-subject.deliv-type-name*/
accum-count @ v-sts-chr
with frame delivery-type-subject-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME delivery-type-subject-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-delivtypesubj to recid v-doc-rec no-error.
APPLY "entry" to br-delivtypesubj.
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
  tbl = 'delivery-type-subject'
  join-tbl = 'X_delivery-type-subject'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('deliv-type-code', 'Код типа доставки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('deliv-subj-code', 'Код субъекта доставки', '',
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
                   , INPUT (filter-point + {&delim-par} + filter-label0)
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-delivtypesubj Dialog-Frame
PROCEDURE proc-br-delivtypesubj :
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
