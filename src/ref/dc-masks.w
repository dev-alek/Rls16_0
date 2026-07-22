&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_clients_emitent FOR ub.clients.
DEFINE BUFFER X_clients_sysconf FOR ub.clients.
DEFINE BUFFER X_curr_clients FOR ub.clients.
DEFINE BUFFER X_dis-card-mask FOR ub.dis-card-mask.
DEFINE BUFFER X_dis-card-type FOR ub.dis-card-type.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список масок дисконтных карт

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/17/04
Author: Bakhtadze Natalya
Creation date: 05/17/04

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input parameter bttns            as character no-undo .
define input parameter p-ref-mode       as character no-undo .
/*{&all} "one":U {&g___object} {&company} */

define input parameter p-type           like ub.dis-card-mask.type no-undo .
define input parameter p-emitent-host-code like ub.dis-card-mask.emitent-host-code no-undo .
define input parameter p-stts              like ub.dis-card-mask.stts no-undo .
DEFINE input-output    PARAMETER p-rid-list As char NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Маски дисконтных карт":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ gbl/flt-def.i }
{ gbl/fltfield.i }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }

&SCOPED-DEFINE label-mask-only 'Маска'
&SCOPED-DEFINE label-use-on-cd 'Используется'
&SCOPED-DEFINE label-cli-mask-only 'Маска короткого!номера'
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable filter-label as character no-undo init "Маски дисконтных карт" .
define variable filter-label0 as character no-undo init "Маски дисконтных карт" .
define variable filter-point as character no-undo .
define variable filter-point0 as character no-undo init "dc-masks" .
define variable v-rid-list as character no-undo .
&SCOPED-DEFINE status-code STRING(X_dis-card-mask.stts)
define buffer pos_dis-card-mask for ub.dis-card-mask.

&scop cant-positioning   if error-status:error then do: ~
                          find first pos_dis-card-mask no-lock where ~
                                  recid(pos_dis-card-mask) = loc-doc-rec no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи МАСКА КАРТЫ" skip~
                            string(if avail pos_dis-card-mask ~
                                    then  substitute("Вн номер: &1 ", pos_dis-card-mask.mask-num ) ~
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
&Scoped-define BROWSE-NAME BR-masks

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_dis-card-mask

/* Definitions for BROWSE BR-masks                                      */
&Scoped-define FIELDS-IN-QUERY-BR-masks mark-string(recid(X_dis-card-mask), v-rid-list) X_dis-card-mask.type X_dis-card-mask.emitent-host-code get-emitent(X_dis-card-mask.emitent-host-code) X_dis-card-mask.mask get-use-on-cd(X_dis-card-mask.use-on) X_dis-card-mask.rank X_dis-card-mask.mask-num get-region(X_dis-card-mask.host-code, X_dis-card-mask.obj-type, X_dis-card-mask.obj-code) {&status-int-name} X_dis-card-mask.cli-mask X_dis-card-mask.cli-type + string(X_dis-card-mask.cli-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-masks
&Scoped-define SELF-NAME BR-masks
&Scoped-define QUERY-STRING-BR-masks FOR EACH X_dis-card-mask NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-masks OPEN QUERY {&SELF-NAME} FOR EACH X_dis-card-mask NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-masks X_dis-card-mask
&Scoped-define FIRST-TABLE-IN-QUERY-BR-masks X_dis-card-mask


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-masks}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-add B-lookup B-chg ~
B-del B-print B-hist B-sch B-Help BR-masks mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-emitent Dialog-Frame
FUNCTION get-emitent RETURNS CHARACTER
  ( input par-emitent-host-code  as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-region Dialog-Frame
FUNCTION get-region RETURNS CHARACTER
  ( input p-host-code as integer, input p-obj-type as character, input p-obj-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-use-on-cd Dialog-Frame
FUNCTION get-use-on-cd RETURNS CHARACTER
  ( INPUT p-mask-field AS INTEGER )  FORWARD.

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

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-masks FOR
      X_dis-card-mask SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-masks
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-masks Dialog-Frame _FREEFORM
  QUERY BR-masks NO-LOCK DISPLAY
      mark-string(recid(X_dis-card-mask), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
X_dis-card-mask.type COLUMN-LABEL "Тип карты" FORMAT "X(8)":U
X_dis-card-mask.emitent-host-code COLUMN-LABEL "Код!эмитента" FORMAT ">>>>>99999":U
get-emitent(X_dis-card-mask.emitent-host-code) COLUMN-LABEL "Эмитент" FORMAT "X(15)":U
X_dis-card-mask.mask COLUMN-LABEL {&label-mask-only} FORMAT "X(19)":U
get-use-on-cd(X_dis-card-mask.use-on) COLUMN-LABEL {&label-use-on-cd} FORMAT "X(20)":U
X_dis-card-mask.rank FORMAT ">>>9":U
X_dis-card-mask.mask-num COLUMN-LABEL "Номер!маски" FORMAT ">>>>>>>>9":U
get-region(X_dis-card-mask.host-code, X_dis-card-mask.obj-type, X_dis-card-mask.obj-code) COLUMN-LABEL "Область!действия" FORMAT "X(14)":U
{&status-int-name} COLUMN-LABEL "Статус" FORMAT "X(8)":U
X_dis-card-mask.cli-mask COLUMN-LABEL {&label-cli-mask-only} FORMAT "X(19)":U
WIDTH 21
X_dis-card-mask.cli-type + string(X_dis-card-mask.cli-code) COLUMN-LABEL "Контрагент" FORMAT "X(12)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 19.25 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     B-add AT ROW 1 COL 31
     B-lookup AT ROW 1 COL 41
     B-chg AT ROW 1 COL 51
     B-del AT ROW 1 COL 61
     B-print AT ROW 1 COL 86
     B-hist AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     BR-masks AT ROW 2.25 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(78.50) SKIP(20.02)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Маски дисконтных карт"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_clients_emitent B "?" ? ub clients
      TABLE: X_clients_sysconf B "?" ? ub clients
      TABLE: X_curr_clients B "?" ? ub clients
      TABLE: X_dis-card-mask B "?" ? ub dis-card-mask
      TABLE: X_dis-card-type B "?" ? ub dis-card-type
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-masks B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-masks
/* Query rebuild information for BROWSE BR-masks
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_dis-card-mask NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-masks */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Маски дисконтных карт */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Маски дисконтных карт */
DO:
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
  'actn_reference-dc-type_input-deletion-updating':U
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
run ref/dc-maski.w
              (
                 input parParentProc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&add-def}
                ,input (if p-ref-mode = "one":U then X_dis-card-type.emitent-host-code else ?)
                ,input (if p-ref-mode = "one":U then X_dis-card-type.type else "":U)
                ,input 0
                ,input-output loc-doc-rec
                            ) no-error
.
if loc-doc-rec <> ? then do:
  run openbr in this-procedure ( input yes, input no, input '':U).
  reposition br-masks to recid loc-doc-rec no-error.
  {&cant-positioning}
end.
apply "entry" to br-masks in frame {&frame-name}.
apply "value-changed" to br-masks in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available X_dis-card-mask then return no-apply.
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_reference-dc-type_input-deletion-updating':U
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
loc-doc-rec = recid(X_dis-card-mask).

run ref/dc-maski.w
              (
                 input parParentProc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&update}
                ,input X_dis-card-mask.emitent-host-code
                ,input X_dis-card-mask.type
                ,input X_dis-card-mask.mask-num
                ,input-output loc-doc-rec
                            ) no-error
.
if loc-doc-rec <> ? then do:
    run OpenBR in this-procedure ( input yes, input no, input no).
    reposition br-masks to recid loc-doc-rec no-error.
    {&cant-positioning}
 end.
apply "entry" to br-masks in frame {&frame-name}.
apply "value-changed" to br-masks in frame {&frame-name}.
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
  if NOT available X_dis-card-mask then return no-apply.
  loc-doc-rec = recid (X_dis-card-mask).
  .
  run ref/dccmasks.w
                (
                 input parParentProc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input "":U /*bttns*/
                ,input "one":U
                ,input X_dis-card-mask.type
                ,input X_dis-card-mask.emitent-host-code
                ,input X_dis-card-mask.mask-num
                ,input-output v-rid-list
                              )
.
  reposition br-masks to recid loc-doc-rec no-error.
  apply "entry" to br-masks in frame {&frame-name}.
  apply "value-changed" to br-masks in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
  DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available X_dis-card-mask then return no-apply.

assign
loc-doc-rec = recid(X_dis-card-mask).

run ref/dc-maski.w
              (
                 input parParentProc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input {&lookup}
                ,input X_dis-card-mask.emitent-host-code
                ,input X_dis-card-mask.type
                ,input X_dis-card-mask.mask-num
                ,input-output loc-doc-rec
                            )
.

apply "entry" to br-masks in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available X_dis-card-mask then do:
    { gbl/markstrn.i X_dis-card-mask v-rid-list }
    loc#log = br-masks:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-masks:select-next-row ().
        apply "VALUE-CHANGED" to br-masks in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-masks in frame {&frame-name}.
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
  APPLY "ENTRY" to br-masks.

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
    if ( available X_dis-card-mask ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_dis-card-mask ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-masks
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
  &sort-clmn_1    = "get-mask-only(X_dis-card-mask.mask)"
  &dyn_sort-clmn_1    = "  substitute('dynamic-function(&1get-mask-only&1, X_dis-card-mask.mask)', ~{&double-quote~})"
  &label-clmn_1  = "{&label-mask-only}"
  &sort-clmn_2    = "get-use-on-cd(X_dis-card-mask.mask)"
  &dyn_sort-clmn_2    = "  substitute('dynamic-function(&1get-use-on-cd&1, X_dis-card-mask.mask)', ~{&double-quote~})"
  &label-clmn_2  = "{&label-use-on-cd}"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input no)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input no)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}
{ gbl/mv-clmn.i
&browse-name = "br-masks"
&frame-name = "{&frame-name}"
&ext-col = 12
&start-column = 1
&prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11'"
&prev-order-column-condition_1 = " p-ref-mode = ~{&all~} "
&prev-order-column_2 = "'1,4,5,6,7,8,9,10,11,2,3'"
&prev-order-column-condition_2 = " p-ref-mode = 'one' "
&prev-order-column_3 = "'1,2,3,4,5,6,7,8,9,10,11'"
&prev-order-column-condition_3 = " p-ref-mode = ~{&g___object~} "
&prev-order-column_4 = "'1,2,3,4,5,6,7,8,9,10,11'"
&prev-order-column-condition_4 = " p-ref-mode = ~{&company~} "
}

{ gbl/brwrepos.i
  &line-num=5
}
{ gbl/hot-key.i b-mark }
&SCOPED-DEFINE b-lookup ~{&b-lkp~}
{ gbl/hot-key.i b-lookup }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }
{ gbl/setfltnm.i }

{ gbl/brwrefre.i "if available X_dis-card-mask then v-doc-rec = recid(X_dis-card-mask). Run openbr in this-procedure ( input yes, input no, input no). ~
              REPOSITION br-masks to recid v-doc-rec. " }
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
find first X_sysconf no-lock where
            X_sysconf.host-code = p-curr-host-code no-error.
  if not available X_sysconf OR X_sysconf.host-code <> X_curr_clients.host-code then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-curr-host-code"
    p-curr-host-code
    view-as alert-box ERROR.
    return error .
  end.
find first X_clients_sysconf no-lock where
            X_clients_sysconf.obj-type = {&cmp}
       AND X_clients_sysconf.obj-code = p-curr-host-code no-error.
  if not available X_clients_sysconf then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-curr-host-code - не найдена фирма"
    p-curr-host-code
    view-as alert-box ERROR.
    return error .
  end.
 if LOOKUP(p-ref-mode, ({&all} + {&delim-par} +
                    "one":U + {&delim-par} +
                    {&g___object} + {&delim-par} +
                    {&company} + {&delim-par}
                    ) ,
                {&delim-par}) = 0
     then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-ref-mode
    view-as alert-box ERROR.
    return error .
 end.
 IF p-ref-mode = "one"
 THEN DO:
     FIND FIRST X_dis-card-type NO-LOCK WHERE
                X_dis-card-type.TYPE = p-type
        AND X_dis-card-type.emitent-host-code = p-emitent-host-code NO-ERROR.
    IF NOT AVAILABLE X_dis-card-type THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-type и /или p-emitent-host-code"
        p-type p-emitent-host-code
        view-as alert-box ERROR.
        return error .
   END.
   IF p-emitent-host-code > 0 THEN DO:
    FIND FIRST X_clients_emitent NO-LOCK WHERE
                X_clients_emitent.obj-type = {&cmp}
        AND X_clients_emitent.obj-code = p-emitent-host-code NO-ERROR.
    IF NOT AVAILABLE X_clients_emitent THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-emitent-host-code - не найдена фирма-эмитент"
        p-emitent-host-code
        view-as alert-box ERROR.
        return error .
    END.
   END.
 END.

  v-rid-list = p-rid-list.
  { gbl/curdbnum.i v-db-num }
  RUN MyEnable in this-procedure .
  run OpenBR in this-procedure ( input yes, input no, input no).
  HIDE mark-num in frame {&frame-name} .
  if v-doc-rec <> ? then
  REPOSITION br-masks to recid v-doc-rec No-ERROR.
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
  ENABLE b-quit B-mark B-sel B-add B-lookup B-chg B-del B-print B-hist B-sch
         B-Help BR-masks mark-num
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
DISPLAY mark-num
WITH FRAME Dialog-Frame.
ENABLE
b-quit
B-mark when LOOKUP("b-mark":U, bttns) > 0
B-sel when LOOKUP("b-sel":U, bttns) > 0
B-add when LOOKUP("b-add":U, bttns) > 0 and v-db-num = 0
B-lookup
B-chg when (LOOKUP("b-add":U, bttns) > 0 or
            LOOKUP("b-chg":U, bttns) > 0 )
           and v-db-num = 0
B-del when LOOKUP("b-add":U, bttns) > 0 and v-db-num = 0
B-print
B-Help
B-hist
b-sch
br-masks
mark-num
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
title0 = "Маски дисконтных карт" + {&space-char}.
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

&scop flt-open-open-query OPEN QUERY br-masks FOR EACH X_dis-card-mask

&scop flt-open-dyn_open-query FOR EACH X_dis-card-mask

&scop flt-open-query-handle QUERY br-masks:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_dis-card-mask

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_dis-card-mask

&scop flt-open-waitfram true

define variable l-open-query as logical   no-undo .
&SCOPED-DEFINE status-code STRING(p-stts)

  CASE p-ref-mode :
    WHEN {&all}        THEN DO:
     assign
     frame {&frame-name}:title = title0
     filter-point = filter-point0 + p-ref-mode
     filter-label = substitute("&1", filter-label0)
     .
     IF p-stts = ?  THEN DO:
         { gbl/fltopend.i
            &where-cond = " TRUE "
            &use-ind    = "  "
            &by         = " by X_dis-card-mask.rank " }

     END.
     ELSE DO:
          ASSIGN
          frame {&frame-name}:TITLE = title0 + {&space-char} + {&status-int-name}.

         { gbl/fltopend.i
            &where-cond = " X_dis-card-mask.stts = p-stts "
            &dyn_where-cond = " substitute('X_dis-card-mask.stts = &1', p-stts )"
            &use-ind    = "  "
            &by         = "  " }

     END.
    END.
    WHEN "one" THEN DO:
       assign
       filter-point = filter-point0 + p-ref-mode
       filter-label = substitute("&1 Один тип карты", filter-label0)
       .
       ASSIGN
       frame {&frame-name}:TITLE = title0 +
                                   substitute(" Тип карты: &1 Эмитент: (&2) &3"
                                   , X_dis-card-type.type
                                   , X_dis-card-type.emitent-host-code
                                   , (IF X_dis-card-type.emitent-host-code = 0 THEN "Глобальная" ELSE X_clients_emitent.obj-name)
                                   ) +
                                   {&space-char} + (if p-stts = ? then "":U else  {&status-int-name}).
      IF p-stts = ? THEN DO:
          { gbl/fltopend.i
            &where-cond = " ~
              X_dis-card-mask.type  = p-type    ~
          AND X_dis-card-mask.emitent-host-code  = p-emitent-host-code    ~
                          "
            &dyn_where-cond = " substitute(' X_dis-card-mask.type  = &1&2&1    ~
          AND X_dis-card-mask.emitent-host-code  = &3 ', ~{&double-quote~}, p-type, p-emitent-host-code ) "

            &use-ind    = "  "
            &by         = "  " }

      END.
      ELSE DO:
          { gbl/fltopend.i
            &where-cond = " ~
              X_dis-card-mask.type  = p-type    ~
          AND X_dis-card-mask.emitent-host-code  = p-emitent-host-code    ~
          AND X_dis-card-mask.stts = p-stts "
            &dyn_where-cond = " substitute('  X_dis-card-mask.type  = &1&2&1  ~
          AND X_dis-card-mask.emitent-host-code  = &3    ~
          AND X_dis-card-mask.stts = &4 ', ~{&double-quote~}, p-type, p-emitent-host-code, p-stts) "
            &use-ind    = "  "
            &by         = "  " }

      END.
    END.
    WHEN {&g___object} THEN DO:
       assign
       filter-point = filter-point0 + p-ref-mode
       filter-label = substitute("&1 Один объект", filter-label0)
       .
       ASSIGN
       frame {&frame-name}:TITLE = title0 +
                                   substitute(" Область действия: объект (&1&2) &3"
                                   , p-curr-obj-type
                                   , p-curr-obj-code
                                   , X_curr_clients.obj-name
                                   ) +
                                   {&space-char} + (if p-stts = ? then "":U else  {&status-int-name}).
       IF p-stts = ? THEN DO:
           { gbl/fltopend.i
             &where-cond = " ~
               X_dis-card-mask.host-code = 0 OR ~
               (X_dis-card-mask.host-code = X_sysconf.host-code    ~
           AND X_dis-card-mask.obj-type = '':U and X_dis-card-mask.obj-code = 0) OR    ~
               (X_dis-card-mask.obj-type = p-curr-obj-type and X_dis-card-mask.obj-code = p-curr-obj-code) ~
                           "
             &dyn_where-cond = " substitute(' X_dis-card-mask.host-code = 0 OR ~
               (X_dis-card-mask.host-code = X_sysconf.host-code    ~
           AND X_dis-card-mask.obj-type = &1&1 and X_dis-card-mask.obj-code = 0) OR    ~
               (X_dis-card-mask.obj-type = &1&2&1 and X_dis-card-mask.obj-code = &3) ', ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code) "

             &use-ind    = "  "
             &by         = "  " }

       END.
       ELSE DO:
           { gbl/fltopend.i
             &where-cond = " ~
               X_dis-card-mask.host-code = 0 OR ~
               (X_dis-card-mask.host-code = X_sysconf.host-code    ~
           AND X_dis-card-mask.obj-type = '':U and X_dis-card-mask.obj-code = 0) OR    ~
               (X_dis-card-mask.obj-type = p-curr-obj-type and X_dis-card-mask.obj-code = p-curr-obj-code) ~
                AND X_dis-card-mask.stts = p-stts "
                           "
             &dyn_where-cond = " substitute('  X_dis-card-mask.host-code = 0 OR ~
               (X_dis-card-mask.host-code = X_sysconf.host-code    ~
           AND X_dis-card-mask.obj-type = &1&1 and X_dis-card-mask.obj-code = 0) OR    ~
               (X_dis-card-mask.obj-type = &1&2&1 and X_dis-card-mask.obj-code = &3) ~
                AND X_dis-card-mask.stts = &4 ', {&double-quote}, p-curr-obj-type, p-curr-obj-code, p-stts)  "

             &use-ind    = "  "
             &by         = "  " }

       END.
    END.
  WHEN {&company} THEN DO:
     assign
     filter-point = filter-point0 + p-ref-mode
     filter-label = substitute("&1 Одна фирма", filter-label0)
     .
       ASSIGN
       frame {&frame-name}:TITLE = title0 +
                                   substitute(" Область действия: фирма (&1) &2"
                                   , p-curr-host-code
                                   , X_clients_sysconf.obj-name
                                   ) +
                                   {&space-char} + (if p-stts = ? then "":U else  {&status-int-name}).
      IF p-stts = ?  THEN DO:
          { gbl/fltopend.i
            &where-cond = " ~
              (X_dis-card-mask.host-code = 0 OR ~
              X_dis-card-mask.host-code = X_sysconf.host-code)    ~
                          "
            &use-ind    = "  "
            &by         = "  " }

      END.
      ELSE DO:
          { gbl/fltopend.i
            &where-cond = " ~
              (X_dis-card-mask.host-code = 0 OR ~
              X_dis-card-mask.host-code = X_sysconf.host-code)    ~
          AND X_dis-card-mask.stts = p-stts "
            &dyn_where-cond = " substitute(' (X_dis-card-mask.host-code = 0 OR ~
              X_dis-card-mask.host-code = X_sysconf.host-code)    ~
          AND X_dis-card-mask.stts = &1 ', p-stts) "
            &use-ind    = "  "
            &by         = "  " }

      END.
  END.

END CASE.
if not p-open-query then
REPOSITION br-masks to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-masks:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-masks in frame {&frame-name}.
APPLY "ENTRY" TO br-masks.

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
define variable v-stts like ub.dis-card-mask.stts no-undo .
DEFINE VARIABLE loc-doc-rec AS RECID NO-UNDO.
if not available X_dis-card-mask then return error.

do
on error undo, return error
on stop undo, return error

:

{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_reference-dc-type_input-deletion-updating':U
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
  v-stts = ?
  loc-doc-rec = RECID(X_dis-card-mask)
  .
  run ref/dc-mask2.p (
                   input parparentproc
                  ,input recid(X_dis-card-mask)
                  ,input-output v-stts
                 ) no-error .
  if error-status:error then undo, return error.
  run OpenBr in this-procedure ( input yes, input no, input no).
  REPOSITION br-masks to recid loc-doc-rec No-error.
  {&cant-positioning}
  if available X_dis-card-mask then do:
    loc#log = br-masks:select-focused-row( ) IN FRAME {&FRAME-NAME}.
  end.
  apply "ENTRY" to br-masks.
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
DEFINE VARIABLE v-stts-chr AS CHARACTER NO-UNDO.
define variable v-cli AS CHARACTER no-undo.
define variable v-emitent-name like ub.clients.obj-name no-undo .
define variable v-region as character no-undo .
define variable v-mask-only as character no-undo .
define variable v-cli-mask-only as character no-undo .
define variable v-use-on-cd as character no-undo .


DEFINE FRAME dis-card-mask-f
X_dis-card-mask.type COLUMN-LABEL "Тип карты" FORMAT "X(8)":U
X_dis-card-mask.emitent-host-code COLUMN-LABEL "Код!эмитента" FORMAT "99999":U
v-emitent-name COLUMN-LABEL "Эмитент" FORMAT "X(15)":U
v-mask-only FORMAT "X(19)":U
v-use-on-cd FORMAT "X(20)":U
X_dis-card-mask.rank FORMAT ">>>9":U
X_dis-card-mask.mask-num COLUMN-LABEL "Номер!маски" FORMAT ">>>>>>>>9":U
v-region COLUMN-LABEL "Область!действия" FORMAT "X(14)":U
v-stts-chr COLUMN-LABEL "Статус" FORMAT "X(8)":U
X_dis-card-mask.cli-mask COLUMN-LABEL "Маска КОРОТКОГО!номера" FORMAT "X(10)":U
v-cli COLUMN-LABEL "Контрагент" FORMAT "X(12)":U
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

FORM with FRAME dis-card-mask-f  .
run waitfram-show in this-procedure ("Ждите...").
v-doc-rec = recid(X_dis-card-mask).
DO WHILE available X_dis-card-mask :
  GET prev br-masks.
END.
GET next br-masks.
DO WHILE available X_dis-card-mask :
  Display STREAM PrnLibStream
  X_dis-card-mask.type
  X_dis-card-mask.emitent-host-code
  get-emitent(X_dis-card-mask.emitent-host-code) @ v-emitent-name
  X_dis-card-mask.mask @ v-mask-only
  get-use-on-cd(X_dis-card-mask.use-on) @ v-use-on-cd
  X_dis-card-mask.rank
  X_dis-card-mask.mask-num
  get-region(X_dis-card-mask.host-code, X_dis-card-mask.obj-type, X_dis-card-mask.obj-code) @ v-region
  {&status-int-name} @ v-stts-chr
  X_dis-card-mask.cli-mask @ v-mask-only
  (X_dis-card-mask.cli-type + string(X_dis-card-mask.cli-code)) @ v-cli
  with FRAME dis-card-mask-f .
  DOWN STREAM PrnLibStream 1
  with FRAME dis-card-mask-f  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-masks.
END.
UNDERLINE  STREAM PrnLibStream
X_dis-card-mask.type
X_dis-card-mask.emitent-host-code
v-emitent-name
v-mask-only
v-use-on-cd
X_dis-card-mask.rank
X_dis-card-mask.mask-num
v-region
v-stts-chr
X_dis-card-mask.cli-mask
v-cli
with FRAME dis-card-mask-f .
DISPLAY STREAM PrnLibStream
accum-count @ v-stts-chr
with frame dis-card-mask-f.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME dis-card-mask-f.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-masks to recid v-doc-rec no-error.
APPLY "entry" to br-masks.
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
  tbl = 'dis-card-mask'
  join-tbl = 'X_dis-card-mask'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('mask', 'Маска карты', 'function_character',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('mask-num', 'Номер маски', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('emitent-host-code', 'Код фирмы-эмитента', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('type', 'Тип карты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('rank', 'Ранг', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


run fltfield-add in this-procedure('host-code', 'Фирма', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект действия', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('stts', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('cli-type{&delim-flt}cli-code', 'Контрагент', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-mask', 'Маска КОРОТКОГО номера', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.




Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                    ,INPUT (filter-point + {&delim-par} +
                        filter-label + {&delim-par} + string(yes))
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-masks Dialog-Frame
PROCEDURE proc-br-masks :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ ref/brwsretr.i }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-emitent Dialog-Frame
FUNCTION get-emitent RETURNS CHARACTER
  ( input par-emitent-host-code  as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

if par-emitent-host-code = 0 then return "Глобальная".

find first ub.clients no-lock where
            ub.clients.obj-type = {&cmp} and
            ub.clients.obj-code = par-emitent-host-code no-error.
if not avail ub.clients then return "?".
return ub.clients.obj-name.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-region Dialog-Frame
FUNCTION get-region RETURNS CHARACTER
  ( input p-host-code as integer, input p-obj-type as character, input p-obj-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define variable par-region as character no-undo.
  if p-host-code = 0 and
       p-obj-type = "":U and
       p-obj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if p-obj-type = "" and
       p-obj-code = 0 then do:
       par-region = fill({&space-char}, 2) + "Фирма" + {&space-char} + string(p-host-code).
       return par-region.
    end.
    par-region = fill({&space-char}, 4) + p-obj-type + {&space-char} + string(p-obj-code).
    return par-region.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-use-on-cd Dialog-Frame
FUNCTION get-use-on-cd RETURNS CHARACTER
  ( INPUT p-mask-field AS INTEGER ) :
&SCOPED-DEFINE use-on-cd-code string(p-mask-field)
 RETURN {&use-on-cd-name}.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME