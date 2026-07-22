&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt0-template_dis-time-rule NO-UNDO LIKE ub.dis-time-rule.
DEFINE BUFFER X_curr_clients FOR ub.clients.
DEFINE BUFFER X_dis-rule FOR ub.dis-rule.
DEFINE BUFFER X_dis-time-rule FOR ub.dis-time-rule.
DEFINE BUFFER X_upper-dis-time-rule FOR ub.dis-time-rule.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список РАСПИСАНИЙ СКИДОК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 15/09/04
Author: Bakhtadze Natalya
Creation date: 15/09/04

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/
define input parameter p-mode  as char   no-undo .
/*{&all}  "upper-time-rule-num"  "template" {&table_dis-rule} "rule-num" ("rule-num" + {&comma-char} + {&update}) */
define input parameter p-rule-num like ub.dis-rule.rule-num no-undo .
define input parameter p-upper-time-rule-num like ub.dis-time-rule.upper-time-rule-num no-undo .
define input parameter p-pos-type as character no-undo .
define input-output parameter p-sts like ub.dis-time-rule.sts no-undo .
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список РАСПИСАНИЙ СКИДОК":U.
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
{ gbl/disrules.i "work" }
{ gbl/distruls.i "work" }
{ ref/gtregion.i }
{ gbl/getcntxt.i def }
{ gbl/fltopend.i defproc }
define variable v-rid-list as character no-undo .
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable filter-point as character no-undo init "dist-rls" .
define variable filter-point0 as character no-undo init "dist-rls" .
define variable filter-label as character no-undo init "Список расписаний" .
define variable filter-label0 as character no-undo init "Список расписаний" .

DEFINE variable v-display-time-from AS CHARACTER NO-UNDO.
DEFINE variable v-display-time-to AS CHARACTER NO-UNDO.
DEFINE variable v-display-date-from AS CHARACTER NO-UNDO.
DEFINE variable v-display-date-to AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-0 AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-1 AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-2 AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-3 AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-4 AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-5 AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-6 AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-7 AS CHARACTER NO-UNDO.
DEFINE variable v-display-month-day AS CHARACTER NO-UNDO.
define variable v-using-fields as character no-undo .
&SCOPED-DEFINE used-status-code STRING(X_dis-time-rule.sts)
define buffer pos_dis-time-rule for ub.dis-time-rule.
DEFINE BUFFER tt-template_dis-time-rule FOR tt0-template_dis-time-rule.


&scop cant-positioning   if error-status:error then do: ~
                          find first pos_dis-time-rule no-lock where ~
                                  recid(pos_dis-time-rule) = loc-doc-rec no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи РАСПИСАНИЕ" skip~
                            string(if avail pos_dis-time-rule ~
                                    then  substitute("номер расписания: &1" ~
                                                    , pos_dis-time-rule.time-rule-num) ~
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
&Scoped-define BROWSE-NAME br-dis-time-rule

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_dis-time-rule tt-template_dis-time-rule

/* Definitions for BROWSE br-dis-time-rule                              */
&Scoped-define FIELDS-IN-QUERY-br-dis-time-rule mark-string(buffer X_dis-time-rule, v-rid-list) X_dis-time-rule.des {&used-status-int-name} v-display-time-from v-display-time-to v-display-date-from v-display-date-to v-display-week-day-0 v-display-week-day-1 v-display-week-day-2 v-display-week-day-3 v-display-week-day-4 v-display-week-day-5 v-display-week-day-6 v-display-week-day-7 v-display-month-day time-v-name(buffer X_dis-time-rule) X_dis-time-rule.time-rule-num   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-dis-time-rule   
&Scoped-define SELF-NAME br-dis-time-rule
&Scoped-define QUERY-STRING-br-dis-time-rule FOR EACH X_dis-time-rule NO-LOCK, ~
             EACH tt-template_dis-time-rule OF ub.X_dis-time-rule  NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-dis-time-rule OPEN QUERY {&SELF-NAME} FOR EACH X_dis-time-rule NO-LOCK, ~
             EACH tt-template_dis-time-rule OF ub.X_dis-time-rule  NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-dis-time-rule X_dis-time-rule ~
tt-template_dis-time-rule
&Scoped-define FIRST-TABLE-IN-QUERY-br-dis-time-rule X_dis-time-rule
&Scoped-define SECOND-TABLE-IN-QUERY-br-dis-time-rule tt-template_dis-time-rule


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-dis-time-rule}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH X_dis-time-rule SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH X_dis-time-rule SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame X_dis-time-rule
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame X_dis-time-rule


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-add B-lookup B-chg ~
B-del B-stat B-print b-history B-sch B-Help B-dis-time-rules B-dis-rule ~
RS-sts br-dis-time-rule mark-num v-des 
&Scoped-Define DISPLAYED-OBJECTS RS-sts mark-num v-des 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame 
FUNCTION mark-string RETURNS CHARACTER
  ( BUFFER loc-dis-time-rule FOR ub.dis-time-rule, input mark-list as CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD time-v-name Dialog-Frame 
FUNCTION time-v-name RETURNS CHARACTER
  ( BUFFER loc_dis-time-rule FOR ub.dis-time-rule )  FORWARD.

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

DEFINE BUTTON B-dis-rule 
     LABEL "Пр&авила" 
     SIZE 10 BY 1.

DEFINE BUTTON B-dis-time-rules 
     LABEL "&Расп-ния" 
     SIZE 10 BY 1.

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-history 
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

DEFINE BUTTON b-quit AUTO-GO 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch 
     LABEL "&Фильтр" 
     SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO 
     LABEL "Вы&бор" 
     SIZE 10 BY 1.

DEFINE BUTTON B-stat 
     LABEL "&Статус" 
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-des AS CHARACTER FORMAT "X(255)" 
      VIEW-AS TEXT 
     SIZE 98 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE RS-sts AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 40 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-dis-time-rule FOR
                X_dis-time-rule,
                tt-template_dis-time-rule SCROLLING.


DEFINE QUERY Dialog-Frame FOR 
      X_dis-time-rule SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-dis-time-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-dis-time-rule Dialog-Frame _FREEFORM
  QUERY br-dis-time-rule NO-LOCK DISPLAY
      mark-string(buffer X_dis-time-rule, v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_dis-time-rule.des FORMAT "X(50)":U
      {&used-status-int-name} COLUMN-LABEL "Статус"
      v-display-time-from COLUMN-LABEL "Время!нач." FORMAT "X(5)":U
            WIDTH 6
      v-display-time-to COLUMN-LABEL "Время!конца" FORMAT "X(5)":U
            WIDTH 6
      v-display-date-from COLUMN-LABEL "Дата нач." FORMAT "X(10)":U
      v-display-date-to COLUMN-LABEL "Дата!конца" FORMAT "X(10)":U
            WIDTH 11
      v-display-week-day-0 COLUMN-LABEL "ДН" FORMAT "X(1)":U
      v-display-week-day-1 COLUMN-LABEL "Пн" FORMAT "X(3)":U
      v-display-week-day-2 COLUMN-LABEL "Вт" FORMAT "X(3)":U
      v-display-week-day-3 COLUMN-LABEL "Ср" FORMAT "X(3)":U
      v-display-week-day-4 COLUMN-LABEL "Чт" FORMAT "X(3)":U
      v-display-week-day-5 COLUMN-LABEL "Птн" FORMAT "X(3)":U
      v-display-week-day-6 COLUMN-LABEL "Сб" FORMAT "X(3)":U
      v-display-week-day-7 COLUMN-LABEL "Вс" FORMAT "X(3)":U
      v-display-month-day COLUMN-LABEL "ДМ" FORMAT "X(2)":U
      time-v-name(buffer X_dis-time-rule) COLUMN-LABEL "Тип расп-ния" FORMAT "X(16)":U
      X_dis-time-rule.time-rule-num COLUMN-LABEL "№ расп-ния" FORMAT ">>>>>>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     B-add AT ROW 1 COL 31
     B-lookup AT ROW 1 COL 41
     B-chg AT ROW 1 COL 51
     B-del AT ROW 1 COL 61
     B-stat AT ROW 1 COL 71
     B-print AT ROW 1 COL 86
     b-history AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     B-dis-time-rules AT ROW 2 COL 51
     B-dis-rule AT ROW 2 COL 61
     RS-sts AT ROW 3.5 COL 3.5 NO-LABEL
     br-dis-time-rule AT ROW 5 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     v-des AT ROW 21.38 COL 1 NO-LABEL
     SPACE(0.12) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Расписания скидок".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt0-template_dis-time-rule T "?" NO-UNDO ub dis-time-rule
      TABLE: X_curr_clients B "?" ? ub clients
      TABLE: X_dis-rule B "?" ? ub dis-rule
      TABLE: X_dis-time-rule B "?" ? ub dis-time-rule
      TABLE: X_upper-dis-time-rule B "?" ? ub dis-time-rule
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-dis-time-rule RS-sts Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       B-add:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN 
       B-chg:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN 
       B-del:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN 
       B-dis-time-rules:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN v-des IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-dis-time-rule
/* Query rebuild information for BROWSE br-dis-time-rule
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_dis-time-rule NO-LOCK,
      EACH tt-template_dis-time-rule OF ub.X_dis-time-rule  NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY br-dis-time-rule FOR
                X_dis-time-rule,
                tt-template_dis-time-rule SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-dis-time-rule */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.X_dis-time-rule"
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Расписания скидок */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Расписания скидок */
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
define variable  v-templ-rl-root     like ub.dis-time-rule.templ-rl-root     no-undo .
define variable v-attr-codes as character no-undo .
define variable v-attr-labels as character no-undo .
define variable v-presel-codes as character no-undo .
define variable v-sel-codes as character no-undo .

define buffer root_dis-time-rule for ub.dis-time-rule.
define buffer buf_tt-template_dis-time-rule for tt0-template_dis-time-rule.
define buffer template_dis-time-rule for ub.dis-time-rule.
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_discount_work':U
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

if p-mode <> "upper-time-rule-num":U
or not avail X_upper-dis-time-rule
or X_upper-dis-time-rule.upper-time-rule-num  = 0
or p-upper-time-rule-num <> 0 then do:
  /*выберите тип расписания*/
  if p-mode = {&table_dis-rule}
  or p-mode = "rule-num":U
  then do:
    for each buf_tt-template_dis-time-rule no-lock where
            buf_tt-template_dis-time-rule.sts = integer({&used-status-int}):
       assign
       v-attr-codes   =  v-attr-codes +  {&delim-par} + string(buf_tt-template_dis-time-rule.time-rule-num)
       v-attr-labels  =  v-attr-labels +  {&delim-par} + substitute("&1 (тип &2)"
                                                                    ,buf_tt-template_dis-time-rule.des
                                                                    ,buf_tt-template_dis-time-rule.time-rule-num)
       .
    end.
    assign
    v-attr-codes = trim (v-attr-codes, {&delim-par})
    v-attr-labels = trim (v-attr-labels, {&delim-par})
    .

  end.
  else do:
    for each template_dis-time-rule no-lock where
            template_dis-time-rule.sts = integer({&used-status-int}):
       assign
       v-attr-codes   =  v-attr-codes +  {&delim-par} + string(template_dis-time-rule.time-rule-num)
       v-attr-labels  =  v-attr-labels +  {&delim-par} + substitute("&1 (тип &2)"
                                                                    ,template_dis-time-rule.des
                                                                    ,template_dis-time-rule.time-rule-num)
       .
    end.
    assign
    v-attr-codes = trim (v-attr-codes, {&delim-par})
    v-attr-labels = trim (v-attr-labels, {&delim-par})
    .
  end.
  run gbl/d-list.w (
               input "b-sel":U
              ,input "Выберите тип расписания"
              ,input v-attr-codes
              ,input v-attr-labels
              ,input {&delim-par}
              ,input v-presel-codes
              ,output v-sel-codes).
   if v-sel-codes = "":U then return no-apply.

   assign
   v-templ-rl-root = integer(v-sel-codes)
   .
end.
else do:
  assign
  v-templ-rl-root = X_upper-dis-time-rule.templ-rl-root
  .
end.
run ref/dis-timi.w
              (
                 input parParentProc
                ,input {&add-def}
                ,input v-templ-rl-root
                ,input 0 /*p-rule-num*/
                ,input p-upper-time-rule-num
                ,input-output loc-doc-rec
                            ) no-error
.
if loc-doc-rec <> ? then do:
  RUn OpenBR in this-procedure ( input YES, input NO, input '':U).
  reposition br-dis-time-rule to recid loc-doc-rec no-error.
  {&cant-positioning}
end.
apply "entry" to br-dis-time-rule in frame {&frame-name}.
apply "value-changed" to br-dis-time-rule in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available X_dis-time-rule then return no-apply.
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_discount_work':U
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
loc-doc-rec = recid(X_dis-time-rule)
.
run ref/dis-timi.w
              (
                 input parParentProc
                ,input {&update}
                ,input X_dis-time-rule.templ-rl-root
                ,input X_dis-time-rule.time-rule-num /*p-rule-num*/
                ,input X_dis-time-rule.upper-time-rule-num
                ,input-output loc-doc-rec
                            ) no-error
.

if loc-doc-rec <> ? then do:
  RUn OpenBR in this-procedure ( input YES, input NO, input NO).
  reposition br-dis-time-rule to recid loc-doc-rec no-error.
  {&cant-positioning}
end.
apply "entry" to br-dis-time-rule in frame {&frame-name}.
apply "value-changed" to br-dis-time-rule in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
if not available X_dis-time-rule then return no-apply.
  run proc-b-del in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-dis-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-dis-rule Dialog-Frame
ON CHOOSE OF B-dis-rule IN FRAME Dialog-Frame /* Правила */
DO:
   DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  define variable v-sts as integer no-undo init ?.

    IF NOT AVAILABLE X_dis-time-rule THEN RETURN no-apply.
    IF X_dis-time-rule.sts = INTEGER({&non-used-status-int}) THEN RETURN NO-APPLY.
    IF X_dis-time-rule.sts = INTEGER({&non-root-status-int}) THEN RETURN NO-APPLY.
    run ref/dis-ruls.w (
                 input parParentProc
                ,input 0 /*p-host-code*/
                ,input "":U /*p-curr-obj-type*/
                ,input 0    /*p-curr-obj-code*/
                ,input "":U /*bttns*/
                ,input "time-rule-num":U
                ,input 0
                ,input X_dis-time-rule.time-rule-num
                ,input 0 /*p-b-code*/
                ,input-output v-sts
                ,input-output v-rid-list ) no-error .
    APPLY "ENTRY" TO br-dis-time-rule.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-dis-time-rules
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-dis-time-rules Dialog-Frame
ON CHOOSE OF B-dis-time-rules IN FRAME Dialog-Frame /* Расп-ния */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-sts as integer no-undo init ?.
 IF NOT AVAILABLE X_dis-time-rule THEN RETURN no-apply.
  IF X_dis-time-rule.sts = INTEGER({&non-used-status-int}) THEN RETURN NO-APPLY.
  if X_dis-time-rule.uniq-field <> "":U
  and X_dis-time-rule.time-rule-num > {&max-num-dr-template}
  then do:
    v-sts = integer({&non-root-status-int}).
  end.
  run ref/dist-rls.w (
               input parParentProc
              ,input "b-add":U
              ,input "upper-time-rule-num":U
              ,input 0 /*p-rule-num*/
              ,input X_dis-time-rule.time-rule-num
              ,input p-pos-type
              ,input-output v-sts
              ,input-output v-rid-list ) no-error .
  APPLY "ENTRY" TO br-dis-time-rule.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-history Dialog-Frame
ON CHOOSE OF b-history IN FRAME Dialog-Frame /* История */
DO:
  define variable loc-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo.
  if NOT available X_dis-time-rule then return no-apply.
  loc-doc-rec = recid (X_dis-time-rule).
  run ref/disctrls.w (
                   INPUT parParentProc
                  ,input "":U /*bttns*/
                  ,input (if X_dis-time-rule.uniq-field = "":U then "one":U else "rl-root":U) /*p-mode*/
                  ,input X_dis-time-rule.time-rule-num
                  ,input X_dis-time-rule.upper-time-rule-num
                  ,input-output v-rid-list ).

  apply "entry" to br-dis-time-rule in frame {&frame-name}.
  apply "value-changed" to br-dis-time-rule in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available X_dis-time-rule then return no-apply.
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_discount_work':U
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
ASSIGN
loc-doc-rec = recid(X_dis-time-rule)
.
run ref/dis-timi.w
              (
                 input parParentProc
                ,input {&lookup}
                ,input X_dis-time-rule.templ-rl-root
                ,input X_dis-time-rule.time-rule-num /*p-rule-num*/
                ,input X_dis-time-rule.upper-time-rule-num
                ,input-output loc-doc-rec
                            ) no-error
.
apply "entry" to br-dis-time-rule in frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available X_dis-time-rule then do:
    { gbl/markstrn.i X_dis-time-rule v-rid-list }
    loc#log = br-dis-time-rule:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-dis-time-rule:select-next-row ().
        apply "VALUE-CHANGED" to br-dis-time-rule in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-dis-time-rule in frame {&frame-name}.
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
  APPLY "ENTRY" to br-dis-time-rule.

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
    if ( available X_dis-time-rule ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_dis-time-rule ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-stat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-stat Dialog-Frame
ON CHOOSE OF B-stat IN FRAME Dialog-Frame /* Статус */
DO:
define variable loc#log as logical no-undo .
  IF NOT AVAILABLE X_dis-time-rule THEN RETURN NO-APPLY.
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_discount_work':U
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
v-doc-rec = recid(X_dis-time-rule).
 RUN proc-b-stat IN THIS-PROCEDURE ( input recid(X_dis-time-rule)) NO-ERROR.
 IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
 RUN openbr IN THIS-PROCEDURE ( input YES, input NO, input '':U) NO-ERROR.
 REPOSITION br-dis-time-rule to recid v-doc-rec No-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-dis-time-rule
&Scoped-define SELF-NAME br-dis-time-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dis-time-rule Dialog-Frame
ON RETURN OF br-dis-time-rule IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-dis-time-rule IN FRAME Dialog-Frame
    DO:
    run proc-br-dis-time-rule no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dis-time-rule Dialog-Frame
ON VALUE-CHANGED OF br-dis-time-rule IN FRAME Dialog-Frame
DO:

  IF AVAILABLE X_dis-time-rule  THEN DO:
    ASSIGN
    v-des = X_dis-time-rule.des
    .
  END.
  ELSE DO:
    ASSIGN
    v-des = "":U.
  END.
  DISPLAY
  v-des
  WITH FRAME {&FRAME-NAME}.

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
{ gbl/setfltnm.i }
{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&second-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_dis-time-rule.time-rule-num"
  &open-query     = "run OpenBr in this-procedure ( input YES, input NO, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input YES, input NO, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/brwrefre.i " v-doc-rec = recid(X_dis-time-rule). run OpenBr in this-procedure ( input yes, input no, input '':U). reposition br-dis-time-rule to recid v-doc-rec no-error. v-doc-rec = ?. ~
  apply 'entry' to br-dis-time-rule in frame ~{&frame-name~}.  ~
  apply 'value-changed' to br-dis-time-rule in frame ~{&frame-name~}.  ~
" }

{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel  }
&scop b-lookup ~{&b-lkp~}
{ gbl/hot-key.i b-lookup }
{ gbl/hot-key.i b-add  }
{ gbl/hot-key.i b-chg  }
{ gbl/hot-key.i b-del  }
{ gbl/hot-key.i b-print  }
{ gbl/hot-key.i b-history }


on f6 anywhere do:
define buffer buf0_dis-time-rule for ub.dis-time-rule.
find first buf0_dis-time-rule no-lock where
        buf0_dis-time-rule.time-rule-num = 0 + {&dtr-templates-shift} no-error .
if available buf0_dis-time-rule then do:
  message
  "Версия структуры расписаний" buf0_dis-time-rule.des
  view-as alert-box .
end.
else do:
  message
  "Не найдена головная запись структуры расписаний!"
  view-as alert-box error .
end.

end.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }
 if LOOKUP(p-mode, ({&all} + {&delim-par} +
                    "upper-time-rule-num":U + {&delim-par} +
                    "template":U + {&delim-par} +
                    "rule-num" + {&delim-par} +
                    {&table_dis-rule} +  {&delim-par} +
                    ("rule-num" + {&comma-char} + {&update})
                    ),
                {&delim-par}) = 0
     then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return error .
 end.
 if p-mode = "upper-time-rule-num" then do:
   find first X_upper-dis-time-rule no-lock where
          X_upper-dis-time-rule.time-rule-num = p-upper-time-rule-num no-error.
   if not available X_upper-dis-time-rule then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-upper-time-rule-num"
    p-upper-time-rule-num
    view-as alert-box ERROR.
    return error .
   end.
   if X_upper-dis-time-rule.time-rule-num > {&max-num-dr-template}
   and (lookup(bttns, "b-sel") > 0 or lookup(bttns, "b-mark") > 0) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова bttn или p-upper-time-rule-num"
    bttns p-upper-time-rule-num
    view-as alert-box ERROR.
    return error .

   end.

  end.
  IF p-mode = {&table_dis-rule}
  or p-mode = "rule-num" + {&comma-char} + {&update}
  OR p-mode = "rule-num":U
  THEN do:
    FIND FIRST X_dis-rule NO-LOCK WHERE
              X_dis-rule.rule-num = p-rule-num NO-ERROR.
    IF NOT AVAILABLE X_dis-rule THEN DO:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-rule-num"
        p-rule-num
        view-as alert-box ERROR.
        return error .
    END.
  END.

  v-rid-list = p-rid-list.
 { gbl/curdbnum.i v-db-num }
  RUN fill-tables IN THIS-PROCEDURE ( IF AVAILABLE X_dis-rule THEN X_dis-rule.templ-rl-root else 0) NO-ERROR.
 IF ERROR-STATUS:ERROR THEN UNDO main-block, RETURN ERROR.
  RUN MyEnable in this-procedure .
  assign
  v-doc-rec = integer(entry(1, v-rid-list))
  .
  RUn OpenBR IN THIS-PROCEDURE ( input YES, input NO, input '':U).
  REPOSITION br-dis-time-rule to recid v-doc-rec No-ERROR.
  HIDE mark-num in frame {&frame-name} .
    { gbl/mv-clmn.i
    &browse-name = "br-dis-time-rule"
    &frame-name = "{&frame-name}"
    &ext-col = 12
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11,12'"
    &prev-order-column-condition_1 = " p-mode = ~{&all~} or p-mode = 'template':U "
    &prev-order-column_2 = "'1,2,3,4,8,9,10,11,5,6,7,12'"
    &prev-order-column-condition_2 = " p-mode = 'upper-time-rule-num':U "
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
  DISPLAY RS-sts mark-num v-des 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-add B-lookup B-chg B-del B-stat B-print 
         b-history B-sch B-Help B-dis-time-rules B-dis-rule RS-sts 
         br-dis-time-rule mark-num v-des 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame 
PROCEDURE fill-tables :
define input parameter p-templ-rl-root as integer no-undo .

DEFINE BUFFER buf_dis-time-rule FOR ub.dis-time-rule.
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-time-template-list AS character NO-UNDO.
DEFINE VARIABLE v-entry AS character NO-UNDO.
define variable v-pos-type as character no-undo .

FOR EACH tt-template_dis-time-rule:
    DELETE tt-template_dis-time-rule.
END.
CASE p-mode:
    WHEN {&ALL} THEN DO:
      FOR EACH buf_dis-time-rule NO-LOCK WHERE
                buf_dis-time-rule.time-rule-num < {&max-num-dr-template}:
         CREATE tt-template_dis-time-rule.
         BUFFER-COPY buf_dis-time-rule to tt-template_dis-time-rule.
      END.
    END.
    WHEN "template" THEN DO:
        FOR EACH buf_dis-time-rule NO-LOCK WHERE
                        buf_dis-time-rule.time-rule-num < {&max-num-dr-template}:
                 CREATE tt-template_dis-time-rule.
                 BUFFER-COPY buf_dis-time-rule to tt-template_dis-time-rule.
              END.

    END.
    WHEN "upper-time-rule-num" THEN DO:

        FOR EACH buf_dis-time-rule NO-LOCK WHERE
                        buf_dis-time-rule.templ-rl-root = X_upper-dis-time-rule.templ-rl-root:
                 CREATE tt-template_dis-time-rule.
                 BUFFER-COPY buf_dis-time-rule to tt-template_dis-time-rule.
              END.

    END.
    WHEN {&table_dis-rule} then do:
      for each buf_dis-cfg-rule no-lock where
              buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root:
        if buf_dis-cfg-rule.time-templ-rl-root <= 0 then next.
        if p-pos-type <> ''
        and buf_dis-cfg-rule.pos-type <> p-pos-type then next.
        FIND FIRST buf_dis-time-rule NO-LOCK WHERE
                buf_dis-time-rule.time-rule-num = buf_dis-cfg-rule.time-templ-rl-root  NO-ERROR.
        IF NOT AVAILABLE buf_dis-time-rule THEN DO:
          message
          vss-workfile vss-revision vss-description skip
          "Неверное значение параметра вызова p-rule-num" p-rule-num skip
          "Ссылка на расписание c time-rule-num " buf_dis-cfg-rule.time-templ-rl-root
          view-as alert-box ERROR.
          return error .
        END.
        find first tt-template_dis-time-rule no-lock where
                  tt-template_dis-time-rule.templ-rl-root = buf_dis-time-rule.templ-rl-root no-error.
        if not available tt-template_dis-time-rule then do:
          CREATE tt-template_dis-time-rule.
          BUFFER-COPY buf_dis-time-rule to tt-template_dis-time-rule.
        end.
      end.
    END.
    WHEN ("rule-num" + {&comma-char} + {&update}) THEN DO:
      FOR EACH buf_dis-rule NO-LOCK WHERE
        buf_dis-rule.rule-num = p-rule-num,
        FIRST buf_dis-time-rule no-lock WHERE
            buf_dis-time-rule.time-rule-num = buf_dis-rule.time-templ-rl-root:
        find first tt-template_dis-time-rule no-lock where
                  tt-template_dis-time-rule.templ-rl-root = buf_dis-time-rule.templ-rl-root no-error.
        if not available tt-template_dis-time-rule then do:
          CREATE tt-template_dis-time-rule.
          BUFFER-COPY buf_dis-time-rule to tt-template_dis-time-rule.
        end.
      END.
      find first buf_dis-rule NO-LOCK WHERE
        buf_dis-rule.rule-num = p-rule-num no-error.
      if buf_dis-rule.time-templ-rl-root = 0 then do:
        for each buf_dis-cfg-rule no-lock where
                buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
            and buf_dis-cfg-rule.time-templ-rl-root > 0
                :
          if v-pos-type <> ''
          and v-pos-type <> buf_dis-cfg-rule.pos-type then do:
            run ref/dcr-pos.p (
                              input p-mode
                              ,input no /*p-silent*/
                              ,input p-templ-rl-root
                              ,input buf_dis-rule.host-code
                              ,input buf_dis-rule.obj-type
                              ,input buf_dis-rule.obj-code
                              ,input buf_dis-rule.sts
                              ,input buf_dis-rule.rule-num
                              ,output v-pos-type) no-error.
            leave.
          end.
          v-pos-type = buf_dis-cfg-rule.pos-type.
        end.
        for each buf_dis-cfg-rule no-lock where
                buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
           and  buf_dis-cfg-rule.pos-type = v-pos-type,
          FIRST buf_dis-time-rule no-lock WHERE
              buf_dis-time-rule.time-rule-num = buf_dis-cfg-rule.time-templ-rl-root:
          find first tt-template_dis-time-rule no-lock where
                    tt-template_dis-time-rule.templ-rl-root = buf_dis-time-rule.templ-rl-root no-error.
          if not available tt-template_dis-time-rule then do:
            CREATE tt-template_dis-time-rule.
            BUFFER-COPY buf_dis-time-rule to tt-template_dis-time-rule.
          end.
        END.
      end.
    END.

    WHEN "rule-num" THEN DO:
      FOR EACH buf_dis-rule NO-LOCK WHERE
        buf_dis-rule.upper-rule-num = p-rule-num,
        FIRST buf_dis-time-rule no-lock WHERE
            buf_dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num:
        find first tt-template_dis-time-rule no-lock where
                  tt-template_dis-time-rule.templ-rl-root = buf_dis-time-rule.templ-rl-root no-error.
        if not available tt-template_dis-time-rule then do:
          CREATE tt-template_dis-time-rule.
          BUFFER-COPY buf_dis-time-rule to tt-template_dis-time-rule.
        end.
      END.
    END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-tree Dialog-Frame 
PROCEDURE get-tree :
DEFINE PARAMETER BUFFER loc_dis-time-rule for ub.dis-time-rule.
define output parameter p-display-time-from as character no-undo .
define output parameter p-display-time-to as character no-undo .
define output parameter p-display-date-from as character no-undo .
define output parameter p-display-date-to as character no-undo .
define output parameter p-display-week-day-0 as character no-undo .
define output parameter p-display-week-day-1 as character no-undo .
define output parameter p-display-week-day-2 as character no-undo .
define output parameter p-display-week-day-3 as character no-undo .
define output parameter p-display-week-day-4 as character no-undo .
define output parameter p-display-week-day-5 as character no-undo .
define output parameter p-display-week-day-6 as character no-undo .
define output parameter p-display-week-day-7 as character no-undo .
define output parameter p-display-month-day as character no-undo .
define output parameter p-using-fields as character no-undo .
DEFINE VARIABLE v-entry AS CHARACTER NO-UNDO INIT ?.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
define variable v-level-1 as character no-undo .
define variable v-level-2 as character no-undo .
define variable v-curr-level as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.

&SCOPED-DEFINE etc "...    "

IF loc_dis-time-rule.uniq-field <> "":U
  AND loc_dis-time-rule.upper-time-rule-num <= {&max-num-dr-template} THEN DO:
  DO ii = 1 TO NUM-ENTRIES(loc_dis-time-rule.uniq-field):
    v-entry = ENTRY(ii, loc_dis-time-rule.uniq-field).
    CASE v-entry:
        WHEN "time-from" THEN DO:
            ASSIGN
            p-display-time-from = {&etc}.
        END.
        WHEN "time-to" THEN DO:
            ASSIGN
            p-display-time-to = {&etc}.
        END.
        WHEN "time-period" THEN DO:
            ASSIGN
            p-display-time-from = {&etc}
            p-display-time-to = {&etc}.
        END.
        WHEN "date-from" THEN DO:
            ASSIGN
            p-display-date-from = {&etc}.
        END.
        WHEN "date-to" THEN DO:
            ASSIGN
            p-display-date-to = {&etc}.
        END.
        WHEN "date-period" THEN DO:
            ASSIGN
            p-display-date-from = {&etc}
            p-display-date-to = {&etc}.
        END.
        WHEN "week-day-0" THEN DO:
            ASSIGN
            p-display-week-day-0 = {&etc}.
        END.
        WHEN "week-day-1" THEN DO:
            ASSIGN
            p-display-week-day-1 = {&etc}.
        END.
        WHEN "week-day-2" THEN DO:
            ASSIGN
            p-display-week-day-2 = {&etc}.
        END.
        WHEN "week-day-3" THEN DO:
            ASSIGN
            p-display-week-day-3 = {&etc}.
        END.
        WHEN "week-day-4" THEN DO:
            ASSIGN
            p-display-week-day-4 = {&etc}.
        END.
        WHEN "week-day-5" THEN DO:
            ASSIGN
            p-display-week-day-5 = {&etc}.
        END.
        WHEN "week-day-6" THEN DO:
            ASSIGN
            p-display-week-day-6 = {&etc}.
        END.
        WHEN "week-day-7" THEN DO:
            ASSIGN
            p-display-week-day-7 = {&etc}.
        END.
        WHEN "month-day" THEN DO:
            ASSIGN
            p-display-month-day = {&etc}.
        END.
        when "week-day-a" then do:
            ASSIGN
            p-display-week-day-0 = {&etc}
            p-display-week-day-1 = {&etc}
            p-display-week-day-2 = {&etc}
            p-display-week-day-3 = {&etc}
            p-display-week-day-4 = {&etc}
            p-display-week-day-5 = {&etc}
            p-display-week-day-6 = {&etc}
            p-display-week-day-7 = {&etc}.
        end.
        when "week-day-b" then do:
            ASSIGN
            p-display-week-day-1 = {&etc}
            p-display-week-day-2 = {&etc}
            p-display-week-day-3 = {&etc}
            p-display-week-day-4 = {&etc}
            p-display-week-day-5 = {&etc}
            p-display-week-day-6 = {&etc}
            p-display-week-day-7 = {&etc}.
        end.
        when "week-day-c" then do:
            if lookup("week-day-1", loc_dis-time-rule.uniq-field) > 0 then
            ASSIGN
            p-display-week-day-1 = {&etc}.
            if lookup("week-day-2", loc_dis-time-rule.uniq-field) > 0 then
            p-display-week-day-2 = {&etc}.
            if lookup("week-day-3", loc_dis-time-rule.uniq-field) > 0 then
            p-display-week-day-3 = {&etc}.
            if lookup("week-day-4", loc_dis-time-rule.uniq-field) > 0 then
            p-display-week-day-4 = {&etc}.
            if lookup("week-day-5", loc_dis-time-rule.uniq-field) > 0 then
            p-display-week-day-5 = {&etc}.
            if lookup("week-day-6", loc_dis-time-rule.uniq-field) > 0 then
            p-display-week-day-6 = {&etc}.
            if lookup("week-day-7", loc_dis-time-rule.uniq-field) > 0 then
            p-display-week-day-7 = {&etc}.
        end.
    END CASE.
  END.
END.
else do:
find first buf_Dis-cfg-rule no-lock where
          buf_Dis-cfg-rule.time-templ-rl-root = loc_dis-time-rule.templ-rl-root
     and  buf_Dis-cfg-rule.table-name = '':U
     and  buf_Dis-cfg-rule.pos-type = '':U
     and  buf_Dis-cfg-rule.discnt-role = '':U
     and  buf_Dis-cfg-rule.self-nonunique = '':U
     and buf_Dis-cfg-rule.templ-rl-root = 0 no-error .
if error-status:error then do:
end.
  assign
  v-level-1 = entry(1, buf_dis-cfg-rule.other-inf, ";":U)
  v-level-2 = (if num-entries(buf_dis-cfg-rule.other-inf, ";":U) > 1
                then entry(2, buf_dis-cfg-rule.other-inf, ";":U)
                else '')
  p-using-fields = (if loc_dis-time-rule.upper-time-rule-num <= {&max-num-dr-template}
                  then v-level-1
                  else v-level-2).

  ASSIGN
  p-display-time-from = (if lookup("time-from", p-using-fields) = 0
                         then "":U else string(loc_dis-time-rule.time-from, "HH:MM"))
  p-display-time-to = (if lookup("time-to", p-using-fields) = 0
                       then "":U else string(loc_dis-time-rule.time-to, "HH:MM"))
  p-display-date-from = (if lookup("date-from", p-using-fields) = 0
                         then "":U else string(loc_dis-time-rule.date-from, "99/99/9999"))
  p-display-date-to = (if lookup("date-to", p-using-fields) = 0
                       then "":U else string(loc_dis-time-rule.date-to, "99/99/9999"))
  p-display-week-day-0 = (if lookup("week-day-0", p-using-fields) = 0
                          then "":U else string(loc_dis-time-rule.week-day-0, "*/":U))
  p-display-week-day-1 = (if lookup("week-day-1", p-using-fields) = 0
                          then "":U else string(loc_dis-time-rule.week-day-1, "Пн/":U))
  p-display-week-day-2 = (if lookup("week-day-2", p-using-fields) = 0
                          then "":U else string(loc_dis-time-rule.week-day-2, "Вт/":U))
  p-display-week-day-3 = (if lookup("week-day-3", p-using-fields) = 0
                          then "":U else string(loc_dis-time-rule.week-day-3, "Ср/":U))
  p-display-week-day-4 = (if lookup("week-day-4", p-using-fields) = 0
                          then "":U else string(loc_dis-time-rule.week-day-4, "Чт/":U))
  p-display-week-day-5 = (if lookup("week-day-5", p-using-fields) = 0
                          then "":U else string(loc_dis-time-rule.week-day-5, "Птн/":U))
  p-display-week-day-6 = (if lookup("week-day-6", p-using-fields) = 0
                          then "":U else string(loc_dis-time-rule.week-day-6, "Сб/":U))
  p-display-week-day-7 = (if lookup("week-day-7", p-using-fields) = 0
                          then "":U else string(loc_dis-time-rule.week-day-7, "Вс/":U))
  p-display-month-day = (if lookup("month-day", p-using-fields) = 0
                         then "":U else string(loc_dis-time-rule.month-day, "99"))
  .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
DEFINE VARIABLE v-rule-num LIKE ub.dis-time-rule.time-rule-num NO-UNDO.
define variable  v-des               like ub.dis-time-rule.des               no-undo .
define variable v-upper-time-rule-num    like ub.dis-time-rule.upper-time-rule-num    no-undo .
define variable v-value-type        like ub.dis-time-rule.value-type        no-undo .
define variable vt-level-1 as character no-undo .
define variable vt-level-2 as character no-undo .
define variable v-output-display as logical   no-undo . /* виден в броусе */
define variable v-tree              as character no-undo .
define variable v-other          as character no-undo . /* еще чего - нибудь */

ASSIGN
rs-sts:RADIO-BUTTONS IN FRAME {&FRAME-NAME}
                       = "Используемые&+" + {&comma-char} +  {&used-status-int} + {&comma-char} +
                       "Все&!" + {&comma-char} + {&all} + {&comma-char} +
                        "Неиспользуемые&-" + {&comma-char} + {&non-used-status-int}
rs-sts = (IF p-sts = ? THEN {&all} ELSE string(p-sts))

.


    run dtr-code  in this-procedure (
     input  p-upper-time-rule-num
    ,output v-des
    ,output v-upper-time-rule-num
    ,output v-value-type
    ,output vt-level-1
    ,output vt-level-2
    ,output v-output-display
    ,output v-tree
    ,output v-other
                               )  NO-ERROR.


DISPLAY mark-num
WITH FRAME {&frame-name}.
ENABLE
b-quit
B-mark when LOOKUP("b-mark":U, bttns) > 0
B-sel when LOOKUP("b-sel":U, bttns) > 0
B-add when (LOOKUP("b-add":U, bttns) > 0
            and not transaction)
B-lookup
B-chg when (LOOKUP("b-add":U, bttns) > 0
           and not transaction)
B-del when (LOOKUP("b-add":U, bttns) > 0
            and p-mode = "upper-time-rule-num":U
            AND X_upper-dis-time-rule.upper-time-rule-num  = 0
            AND p-upper-time-rule-num <> 0
            and not transaction)
B-print
B-Help
b-history
B-dis-time-rules WHEN p-mode = "template":U OR p-upper-time-rule-num = 0 or v-tree <> "":U
br-dis-time-rule
b-dis-rule WHEN p-mode <> "template":U and p-upper-time-rule-num <> 0
b-sch
mark-num
rs-sts when not (p-mode = "template":U or p-upper-time-rule-num = {&dtr-templates-shift})
b-stat when LOOKUP("b-add", bttns) > 0
with FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF (p-mode <> "template":U and p-mode <> {&all}) or p-upper-time-rule-num <> 0 THEN DO:
  assign
  b-dis-time-rules:label in frame {&frame-name} = "Детально"
  .
END.
if p-mode = "template"
or p-upper-time-rule-num = 0 then do:
  DISABLE
  rs-sts
  b-stat
  with FRAME {&frame-name}.
end.
if p-mode = "upper-time-rule-num" and X_upper-dis-time-rule.time-rule-num > {&max-num-dr-template} then do:
  HIDE
  b-add
  b-chg
  b-del
  b-stat
  IN FRAME {&frame-name}.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo init "Список расписаний".
define variable p-host-code like ub.sysconf.host-code no-undo .
run waitfram-show in this-procedure (  input "Ждите...").
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

&scop flt-open-open-query OPEN QUERY br-dis-time-rule FOR EACH X_dis-time-rule no-lock

&scop flt-open-dyn_open-query FOR EACH X_dis-time-rule no-lock

&scop flt-open-query-handle QUERY br-dis-time-rule:handle


&scop flt-open-open-query-tail     , first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_dis-time-rule

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_dis-time-rule

&scop flt-open-waitfram true

define variable l-open-query as logical   no-undo .

&SCOPED-DEFINE used-status-code STRING(p-sts)


  CASE p-mode :
    WHEN {&all}        THEN DO:
     assign
     filter-point = filter-point0 + p-mode
     filter-label = substitute("&1", filter-label0)
     .
     IF p-sts = -1  THEN DO:
        { gbl/fltopend.i
            &where-cond = " TRUE "
            &use-ind    = "  "
            &by         = "  " }
     END.
     ELSE DO:
&SCOPED-DEFINE used-status-code STRING(p-sts)
          ASSIGN
          frame {&frame-name}:TITLE = title0 + {&space-char} + {&used-status-int-name}
          filter-label = substitute("&1  с определенным статусом", filter-label0, {&used-status-int-name})
          .
         { gbl/fltopend.i
            &where-cond = " X_dis-time-rule.sts = p-sts "
            &dyn_where-cond = " substitute('X_dis-time-rule.sts = &1', p-sts )"
            &use-ind    = "  "
            &by         = "  " }

     END.
    END.
    WHEN "upper-time-rule-num":U THEN DO:
       assign
       filter-point = filter-point0 + p-mode
       .
       if X_upper-dis-time-rule.time-rule-num > {&max-num-dr-template}
       then
       ASSIGN
       frame {&frame-name}:TITLE = title0 +
                                   substitute(" Расписание №&1: &2: Детализация"
                                   , X_upper-dis-time-rule.time-rule-num
                                   , X_upper-dis-time-rule.des
                                   )
       filter-label = substitute("&1 Детализация", filter-label0)
                                   .
      else
       ASSIGN
       frame {&frame-name}:TITLE = title0 +
                                   substitute(" Расписания типа: &1 &2"
                                   , X_upper-dis-time-rule.des
                                   , (if p-sts = -1 then "":U else  {&used-status-int-name})
                                   )
       filter-label = substitute("&1 Расписания одного типа", filter-label0)
                                   .


      IF p-sts = -1 THEN DO:
        { gbl/fltopend.i
        &where-cond = " X_dis-time-rule.upper-time-rule-num  = p-upper-time-rule-num   ~
                      "
        &dyn_where-cond = " substitute('X_dis-time-rule.upper-time-rule-num  = &1', p-upper-time-rule-num )  "

        &use-ind    = "  "
        &by         = "  " }
      END.
      ELSE DO:
          { gbl/fltopend.i
          &where-cond = " X_dis-time-rule.upper-time-rule-num  = p-upper-time-rule-num    ~
             AND X_dis-time-rule.sts = p-sts "
          &dyn_where-cond = " substitute('X_dis-time-rule.upper-time-rule-num  = &1    ~
             AND X_dis-time-rule.sts = &2 ', p-upper-time-rule-num, p-sts) "

          &use-ind    = "  "
          &by         = "  " }

      END.
    END.
    WHEN "template":U THEN DO:
       filter-point = filter-point0 + p-mode.
       ASSIGN
       frame {&frame-name}:TITLE =  substitute(" Типы расписаний (Шаблоны) &1"
                                               ,(if p-sts = -1 then "":U else  {&used-status-int-name})
                                               )
       filter-label = substitute("&1 Шаблоны расписаний", filter-label0)
                                               .
      IF p-sts = -1 THEN DO:
        { gbl/fltopend.i
        &where-cond = "  X_dis-time-rule.time-rule-num  <= ~{&max-num-dr-template~}    ~
                      "
        &dyn_where-cond = "  substitute('X_dis-time-rule.time-rule-num  <= &1', ~{&max-num-dr-template~})  "

        &use-ind    = "  "
        &by         = "  " }
      END.
      ELSE DO:
          { gbl/fltopend.i
          &where-cond = " X_dis-time-rule.time-rule-num  <= ~{&max-num-dr-template~}    ~
             AND X_dis-time-rule.sts = p-sts "
          &dyn_where-cond = " substitute('X_dis-time-rule.time-rule-num  <= &1    ~
             AND X_dis-time-rule.sts = &2 ', ~{&max-num-dr-template~}, p-sts)"

          &use-ind    = "  "
          &by         = "  " }

      END.
    END.
    when {&table_dis-rule} then do:
     filter-point = filter-point0 + p-mode.

      ASSIGN
      frame {&frame-name}:TITLE =  substitute(" Расписания доступные для правил скидок с типом &1: &2"
                                              , X_dis-rule.des
                                              ,(if p-sts = -1 then "":U else  {&used-status-int-name})
                                              )
      filter-label = substitute("&1 доступные для правил скидок определенного типа", filter-label0)
                                              .

     IF p-sts = -1  THEN DO:
        { gbl/fltopend.i
            &where-cond = " X_dis-time-rule.lvl-num = 1"
            &use-ind    = "  "
            &by         = "  " }
     END.
     ELSE DO:
&SCOPED-DEFINE used-status-code STRING(p-sts)
          ASSIGN
          frame {&frame-name}:TITLE = title0 + {&space-char} + {&used-status-int-name}.
         { gbl/fltopend.i
          &where-cond = " X_dis-time-rule.sts = p-sts "
          &dyn_where-cond = " substitute('X_dis-time-rule.sts = &1', p-sts) "
          &use-ind    = "  "
          &by         = "  " }

     END.

    end.
    when ("rule-num":U + {&comma-char} + {&update}) then do:
       filter-point = filter-point0 + p-mode.
        ASSIGN
        frame {&frame-name}:TITLE =  substitute(" Расписания для правила скидки №&1 &2"
                                                , X_dis-rule.rule-num
                                                , X_dis-rule.des
                                                )
       filter-label = substitute("&1 в правиле скидки", filter-label0)
                                                .

     IF p-sts = -1  THEN DO:
        { gbl/fltopend.i
            &where-cond = " X_dis-time-rule.lvl-num = 1"
            &use-ind    = "  "
            &by         = "  " }
     END.
     ELSE DO:
&SCOPED-DEFINE used-status-code STRING(p-sts)
          ASSIGN
          frame {&frame-name}:TITLE = title0 + {&space-char} + {&used-status-int-name}.
         { gbl/fltopend.i
          &where-cond = " X_dis-time-rule.sts = p-sts "
          &dyn_where-cond = " substitute('X_dis-time-rule.sts = &1', p-sts) "
          &use-ind    = "  "
          &by         = "  " }

     END.
   end.
    when "rule-num":U then do:
       filter-point = filter-point0 + p-mode.
        ASSIGN
        frame {&frame-name}:TITLE =  substitute(" Расписания в детализации правил скидки №&1 &2"
                                                , X_dis-rule.rule-num
                                                , X_dis-rule.des
                                                )
       filter-label = substitute("&1 в детализации правила скидки", filter-label0)
                                                .
&scop flt-open-open-query-tail     , first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.templ-rl-root = X_dis-time-rule.templ-rl-root  ~
AND X_dis-time-rule.time-rule-num = tt-template_dis-time-rule.time-rule-num
       IF p-sts = -1  THEN DO:
          { gbl/fltopend.i
              &where-cond = " TRUE "
              &use-ind    = "  "
              &by         = "  " }
       END.
   end.
END CASE.
if not p-open-query then
REPOSITION br-dis-time-rule to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-dis-time-rule:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
if error-status:error then do:
  REPOSITION br-dis-time-rule to row 1 No-ERROR.
end.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-dis-time-rule in frame {&frame-name}.
APPLY "ENTRY" TO br-dis-time-rule.
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
define variable v-sts like ub.dis-time-rule.sts no-undo .
DEFINE VARIABLE loc-doc-rec AS RECID NO-UNDO.
define buffer loc_dis-time-rule for ub.dis-time-rule.
if not available X_dis-time-rule then return error.
do
on error undo, return error
on stop undo, return error
:
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_discount_work':U
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
loc#log = no.
message
"Вы действительно хотите удалить данное РАСПИСАНИЕ?"
view-as alert-box QUESTION buttons YEs-NO update loc#log.
if not loc#log then undo, return error .
    find first loc_dis-time-rule exclusive-lock where
              recid(loc_dis-time-rule) = loc-doc-rec .
    run ref/dis-tim3.p (
                      buffer loc_dis-time-rule
                    , input no /*p-sts-mode*/
                    , input no /*p-silent*/
                    ) no-error.
    if error-status:error then do:
      message
      "Ошибка при удалении РАСПИСАНИЯ" skip
      error-status:get-message(1) skip
      return-value
      view-as alert-box error .
      undo, return error .
    end.
  RUN OpenBr in this-procedure ( input YES, input NO, input NO).
  REPOSITION br-dis-time-rule to recid loc-doc-rec No-error.
  {&cant-positioning}
  if available X_dis-time-rule then do:
    loc#log = br-dis-time-rule:select-focused-row( ) IN FRAME {&FRAME-NAME}.
  end.
  apply "ENTRY" to br-dis-time-rule.
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
define variable v-value-type as character no-undo .
/*
DEFINE variable v-display-time-from AS CHARACTER NO-UNDO.
DEFINE variable v-display-time-to AS CHARACTER NO-UNDO.
DEFINE variable v-display-date-from AS CHARACTER NO-UNDO.
DEFINE variable v-display-date-to AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-0 AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-1 AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-2 AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-3 AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-4 AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-5 AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-6 AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-7 AS CHARACTER NO-UNDO.
DEFINE variable v-display-month-day AS CHARACTER NO-UNDO.
*/
define variable v-mark as character no-undo .


DEFINE FRAME dis-time-rule-list
X_dis-time-rule.des FORMAT "X(65)"
v-sts-chr FORMAT "X(8)" COLUMN-LABEL "Статус"
v-display-time-from COLUMN-LABEL "Время!нач." FORMAT "X(5)":U
v-display-time-to COLUMN-LABEL "Время!конца" FORMAT "X(5)":U
v-display-date-from COLUMN-LABEL "Дата нач." FORMAT "X(10)":U
v-display-date-to COLUMN-LABEL "Дата!конца" FORMAT "X(10)":U
v-display-week-day-0 COLUMN-LABEL "ДН" FORMAT "X(1)":U
v-display-week-day-1 COLUMN-LABEL "Пн" FORMAT "X(3)":U
v-display-week-day-2 COLUMN-LABEL "Вт" FORMAT "X(3)":U
v-display-week-day-3 COLUMN-LABEL "Ср" FORMAT "X(3)":U
v-display-week-day-4 COLUMN-LABEL "Чт" FORMAT "X(3)":U
v-display-week-day-5 COLUMN-LABEL "Птн" FORMAT "X(3)":U
v-display-week-day-6 COLUMN-LABEL "Сб" FORMAT "X(3)":U
v-display-week-day-7 COLUMN-LABEL "Вс" FORMAT "X(3)":U
v-display-month-day COLUMN-LABEL "ДМ" FORMAT "X(2)":U
v-value-type        COLUMN-LABEL "Тип расп-ния" FORMAT "X(20)":U
/*time-v-name(buffer X_dis-time-rule) */
X_dis-time-rule.time-rule-num COLUMN-LABEL "Номер!расп-ния"
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

FORM with FRAME dis-time-rule-list  .
run waitfram-show in this-procedure (  input "Ждите...").
v-doc-rec = recid(X_dis-time-rule).
DO WHILE available X_dis-time-rule :
  GET prev br-dis-time-rule.
END.
GET next br-dis-time-rule.
&scop used-status-code string(X_dis-time-rule.sts)
DO WHILE available X_dis-time-rule :
  assign
  v-sts-chr = {&used-status-int-name}
  v-value-type = time-v-name(buffer X_dis-time-rule)
  v-mark = mark-string(buffer X_dis-time-rule, v-rid-list)
  .
  Display STREAM PrnLibStream
  X_dis-time-rule.des
  {&used-status-int-name} @ v-sts-chr
  v-display-time-from
  v-display-time-to
  v-display-date-from
  v-display-date-to
  v-display-week-day-0
  v-display-week-day-1
  v-display-week-day-2
  v-display-week-day-3
  v-display-week-day-4
  v-display-week-day-5
  v-display-week-day-6
  v-display-week-day-7
  v-display-month-day
  v-value-type
  X_dis-time-rule.time-rule-num
  with FRAME dis-time-rule-list .
  DOWN STREAM PrnLibStream 1
  with FRAME dis-time-rule-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-dis-time-rule.
END.
UNDERLINE  STREAM PrnLibStream
X_dis-time-rule.des
v-sts-chr
v-display-time-from
v-display-time-to
v-display-date-from
v-display-date-to
v-display-week-day-0
v-display-week-day-1
v-display-week-day-2
v-display-week-day-3
v-display-week-day-4
v-display-week-day-5
v-display-week-day-6
v-display-week-day-7
v-display-month-day
v-value-type
X_dis-time-rule.time-rule-num
with FRAME dis-time-rule-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_dis-time-rule.des
accum-count @ v-sts-chr
with frame dis-time-rule-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME dis-time-rule-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-dis-time-rule to recid v-doc-rec no-error.
APPLY "entry" to br-dis-time-rule.
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
  tbl = 'dis-time-rule'
  join-tbl = 'X_dis-time-rule'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('des', 'Описание расписания', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
if p-mode <> "template" and p-upper-time-rule-num <> 0 and p-mode <> "upper-time-rule-num" then do:
  run fltfield-add in this-procedure('templ-rl-root', 'Номер типа(шаблона) расписания', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
end.

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                    ,INPUT (filter-point + {&delim-par} + filter-label)
                    ,INPUT tbl
                    ,INPUT join-tbl
                    ,INPUT fld
                    ,INPUT lab
                    ,INPUT spr
                    ,INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-stat Dialog-Frame 
PROCEDURE proc-b-stat :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-doc-rec as recid no-undo .
define variable v-sts like ub.dis-time-rule.sts no-undo .
define buffer loc_dis-time-rule for ub.dis-rule.
do
on error undo, return error
:

  find first loc_dis-time-rule exclusive-lock where
            recid(loc_Dis-time-rule) = p-doc-rec .
  v-sts = ?.
  run ref/dis-tim2.p (
                    buffer loc_dis-time-rule
                  , input no /*p-silent*/
                  , input-output v-sts
                  ) no-error.

end. /*doe*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-dis-time-rule Dialog-Frame 
PROCEDURE proc-br-dis-time-rule :
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame 
FUNCTION mark-string RETURNS CHARACTER
  ( BUFFER loc-dis-time-rule FOR ub.dis-time-rule, input mark-list as CHARACTER ) :
  RUN get-tree IN THIS-PROCEDURE(
         BUFFER loc-dis-time-rule
        ,output v-display-time-from
        ,OUTPUT v-display-time-to
        ,output v-display-date-from
        ,OUTPUT v-display-date-to
        ,OUTPUT v-display-week-day-0
        ,OUTPUT v-display-week-day-1
        ,OUTPUT v-display-week-day-2
        ,OUTPUT v-display-week-day-3
        ,OUTPUT v-display-week-day-4
        ,OUTPUT v-display-week-day-5
        ,OUTPUT v-display-week-day-6
        ,OUTPUT v-display-week-day-7
        ,OUTPUT v-display-month-day
        ,output v-using-fields
    ).
RETURN ( IF LOOKUP( STRING( RECID( loc-dis-time-rule ) ), mark-list ) > 0 THEN "*" ELSE "":U ).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION time-v-name Dialog-Frame 
FUNCTION time-v-name RETURNS CHARACTER
  ( BUFFER loc_dis-time-rule FOR ub.dis-time-rule ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-str AS CHARACTER NO-UNDO.
&SCOPED-DEFINE dtr-t-code ENTRY(ii, loc_dis-time-rule.value-type)
DO ii = 1 TO NUM-ENTRIES(loc_dis-time-rule.value-type):
   ASSIGN
   v-str = v-str + (IF v-str = "":U THEN "":U ELSE {&comma-char}) +
                   {&dtr-t-name} NO-ERROR.
END.

RETURN v-str.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

