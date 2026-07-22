&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_cli-grp FOR ub.cli-grp.
DEFINE BUFFER X_clients-obj FOR ub.clients.
DEFINE BUFFER X_dis-cfg-rule FOR ub.dis-cfg-rule.
DEFINE BUFFER X_dis-grp-rule FOR ub.dis-grp-rule.
DEFINE BUFFER X_sum-grp FOR ub.sum-grp.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список скидок на группы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/26/07
Author: Bakhtadze Natalya
Creation date: 01/26/07

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define INPUT PARAMETER bttn AS CHARACTER NO-UNDO.
define INPUT PARAMETER p-list-mode AS CHARACTER NO-UNDO.
/*список возможных list-mode
({&all}
"pos"
"templ-rl-root"
"discnt-role"
{&g___object}
({&g___Object} + {&comma-char} + "pos-type":U)
({&g___Object} + {&comma-char} + "templ-rl-root":U)
({&g___Object} + {&comma-char} + "discnt-role":U)
"rule-num":U
"rl-root":U
) , {&delim-par})
*/
DEFINE INPUT PARAMETER p-classif-type AS CHARACTER NO-UNDO.
define input parameter p-curr-host-code as integer no-undo .
define INPUT PARAMETER p-curr-obj-type AS CHARACTER NO-UNDO.
define INPUT PARAMETER p-curr-obj-code AS integer NO-UNDO.
define INPUT PARAMETER p-templ-rl-root AS integer NO-UNDO.
define INPUT PARAMETER p-pos-type AS character NO-UNDO.
define INPUT PARAMETER p-discnt-role AS character NO-UNDO.
define input parameter p-rule-num as integer no-undo .
define INPUT-OUTPUT PARAMETER p-rid-list AS CHARACTER NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список скидок на группы".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i DEF }
{ cmp/r-pril.i new }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/prn-lib.i }
{ cmp/mrk-strf.i }
{ gbl/cur-time.i }
{ ref/cgrplbfn.i }
{ gbl/fltopend.i defproc }
&SCOPED-DEFINE dis-ggr-rule-code X_dis-grp-rule.discnt-role

DEFINE VARIABLE gds-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable filter-point as character no-undo init "dis-gprs" .
define variable filter-point0 as character no-undo init "dis-grps" .
define variable filter-label as character no-undo init "Скидки на группы" .
define variable filter-label0 as character no-undo init "Скидки на группы" .
&scop dis-grp-classif-code X_dis-grp-rule.classif-type


define variable sort-column-name as character no-undo .
define variable v-rid-list as character no-undo .
DEFINE BUFFER par_dis-rule FOR ub.dis-rule.
DEFINE BUFFER par_dis-cfg-rule FOR ub.dis-cfg-rule.

&SCOPED-DEFINE cd-type-code X_dis-grp-rule.pos-type
&scop dis-clgr-rule-code X_dis-grp-rule.discnt-role
&scop dis-ggr-rule-code X_dis-grp-rule.discnt-role

&SCOPED-DEFINE sort-clmn_1 mark-string(recid(X_dis-grp-rule), v-rid-list)
&scoped-define label-clmn_1 '*'
&SCOPED-DEFINE sort-clmn_2 ~{&dis-grp-classif-name~}
&scoped-define label-clmn_2 'Тип классификатора'
&SCOPED-DEFINE sort-clmn_3 X_dis-grp-rule.node-code
&scoped-define label-clmn_3 'Код группы'
&SCOPED-DEFINE sort-clmn_4 X_dis-grp-rule.templ-rl-root
&scoped-define label-clmn_4 'Тип правила'
&SCOPED-DEFINE sort-clmn_5 {&cd-type-name}
&scoped-define label-clmn_5 'Место использ.'
&SCOPED-DEFINE sort-clmn_6 X_dis-grp-rule.obj-type
&scoped-define label-clmn_6 'Тип объ'
&SCOPED-DEFINE sort-clmn_7 X_dis-grp-rule.obj-code
&scoped-define label-clmn_7 'Код объ'
&SCOPED-DEFINE sort-clmn_8 (if p-classif-type = ~{&table_sum-grp} then ~{&dis-ggr-rule-name~} else ~{&dis-clgr-rule-name~})
&scoped-define label-clmn_8 'Тип скидки'
&SCOPED-DEFINE sort-clmn_9 X_dis-grp-rule.rule-num
&scoped-define label-clmn_9 '№ правила'
&SCOPED-DEFINE sort-clmn_10 full-grp-name(X_dis-grp-rule.classif-type, X_dis-grp-rule.node-code, X_dis-grp-rule.host-code, X_dis-grp-rule.obj-type, X_dis-grp-rule.obj-code)
&scoped-define label-clmn_10 'Название группы'
&SCOPED-DEFINE sort-clmn_11 X_dis-grp-rule.rl-root
&scoped-define label-clmn_11 '№ корн.правила'

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-dis-grp-rule

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_dis-grp-rule

/* Definitions for BROWSE BR-dis-grp-rule                               */
&Scoped-define FIELDS-IN-QUERY-BR-dis-grp-rule {&sort-clmn_1} {&sort-clmn_3} {&sort-clmn_10} {&sort-clmn_4} {&sort-clmn_5} {&sort-clmn_6} {&sort-clmn_7} {&sort-clmn_8} {&sort-clmn_9} {&sort-clmn_11}
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-dis-grp-rule
&Scoped-define SELF-NAME BR-dis-grp-rule
&Scoped-define QUERY-STRING-BR-dis-grp-rule FOR EACH X_dis-grp-rule NO-LOCK  INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-dis-grp-rule OPEN QUERY {&SELF-NAME} FOR EACH X_dis-grp-rule NO-LOCK  INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-dis-grp-rule X_dis-grp-rule
&Scoped-define FIRST-TABLE-IN-QUERY-BR-dis-grp-rule X_dis-grp-rule


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-dis-grp-rule}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel b-grp b-dis-rule B-sch ~
B-print b-history B-Help BR-dis-grp-rule mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD full-grp-name Dialog-Frame
FUNCTION full-grp-name RETURNS CHARACTER
  ( INPUT p-classif-type AS CHARACTER
    ,INPUT p-node-code AS integer
    ,INPUT p-host-code AS INTEGER
    ,INPUT p-obj-type AS CHARACTER
    ,INPUT p-obj-code AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-dis-rule
     LABEL "Правило"
     SIZE 10 BY 1.

DEFINE BUTTON b-grp
     LABEL "&Группа"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-history
     LABEL "Ис&тория"
     SIZE 3 BY 1.

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
DEFINE QUERY BR-dis-grp-rule FOR X_dis-grp-rule SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-dis-grp-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-dis-grp-rule Dialog-Frame _FREEFORM
  QUERY BR-dis-grp-rule NO-LOCK DISPLAY
      {&sort-clmn_1} COLUMN-LABEL {&label-clmn_1} FORMAT "X(1)"
{&sort-clmn_3} COLUMN-LABEL {&label-clmn_3}
{&sort-clmn_10} COLUMN-LABEL {&label-clmn_10} FORMAT "X(255)" WIDTH 40
{&sort-clmn_4} COLUMN-LABEL {&label-clmn_4} FORMAT ">>>>>>>>9"
{&sort-clmn_5} COLUMN-LABEL {&label-clmn_5} FORMAT "X(20)"
{&sort-clmn_6} COLUMN-LABEL {&label-clmn_6} FORMAT "X(3)"
{&sort-clmn_7} COLUMN-LABEL {&label-clmn_7} FORMAT ">>>>9"
{&sort-clmn_8} COLUMN-LABEL {&label-clmn_8} FORMAT "X(70)"
{&sort-clmn_9} COLUMN-LABEL {&label-clmn_9} FORMAT ">>>>>>>>9"
{&sort-clmn_11} COLUMN-LABEL {&label-clmn_11} FORMAT ">>>>>>>>9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 20 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11 WIDGET-ID 4
     B-sel AT ROW 1 COL 21 WIDGET-ID 10
     b-grp AT ROW 1 COL 41 WIDGET-ID 14
     b-dis-rule AT ROW 1 COL 51 WIDGET-ID 16
     B-sch AT ROW 1 COL 86 WIDGET-ID 8
     B-print AT ROW 1 COL 89 WIDGET-ID 6
     b-history AT ROW 1 COL 92 WIDGET-ID 2
     B-Help AT ROW 1 COL 95
     BR-dis-grp-rule AT ROW 3 COL 1 WIDGET-ID 100
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     SPACE(78.59) SKIP(21.22)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Скидки на группы товаров"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_cli-grp B "?" ? ub cli-grp
      TABLE: X_clients-obj B "?" ? ub clients
      TABLE: X_dis-cfg-rule B "?" ? ub dis-cfg-rule
      TABLE: X_dis-grp-rule B "?" ? ub dis-grp-rule
      TABLE: X_sum-grp B "?" ? ub sum-grp
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-dis-grp-rule B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-dis-grp-rule
/* Query rebuild information for BROWSE BR-dis-grp-rule
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH X_dis-grp-rule NO-LOCK  INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY BR-dis-grp-rule FOR X_dis-grp-rule SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-dis-grp-rule */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Скидки на группы товаров */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Скидки на группы товаров */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dis-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dis-rule Dialog-Frame
ON CHOOSE OF b-dis-rule IN FRAME Dialog-Frame /* Правило */
DO:
  IF NOT AVAILABLE X_dis-grp-rule THEN RETURN NO-APPLY.
  run ref/show-dr.p ( INPUT parparentproc
                     ,INPUT X_dis-grp-rule.rule-num) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-grp Dialog-Frame
ON CHOOSE OF b-grp IN FRAME Dialog-Frame /* Группа */
DO:
DEFINE VARIABLE v-ref-rec AS RECID NO-UNDO.
define buffer buf_sum-grp for ub.sum-grp.
CASE p-classif-type:
  when {&table_sum-grp} then do:
    FIND FIRST buf_sum-grp No-LOCK WHERE
                buf_sum-grp.grp-code = X_dis-grp-rule.node-code no-error .
    if error-status:error then  return no-apply.
    v-ref-rec = recid( buf_sum-grp ) .
    run ref/sum-grpi.w (  input parparentproc
                        , input {&lookup}
                        , input-output v-ref-rec).
  end.
  when {&table_gds-grp} then do:

  end.

end case.
apply "entry" to br-dis-grp-rule in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-history Dialog-Frame
ON CHOOSE OF b-history IN FRAME Dialog-Frame /* История */
DO:
define variable v-loc-rid-list as character no-undo .
if not available X_dis-grp-rule then return no-apply.
  CASE X_dis-grp-rule.classif-type:
    when {&table_sum-grp} then do:
      run ref/csumgrps.w (
                     INPUT parparentproc
                    ,INPUT '':U /*bttns*/
                    ,INPUT 'subject':U
                    ,INPUT X_sum-grp.grp-code
                    ,input {&table_dis-grp-rule}
                    ,INPUT-OUTPUT v-loc-rid-list) NO-ERROR.
    end.
  end case.
APPLY "ENTRY" to br-dis-grp-rule.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  RUN proc-b-mark IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
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
  APPLY "ENTRY" to br-dis-grp-rule.

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
    if ( available X_dis-grp-rule ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_dis-grp-rule ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-dis-grp-rule
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-dis-grp-rule" }
{ gbl/brwrefre.i " v-doc-rec = recid(X_dis-grp-rule).  Run OpenBR in this-procedure ( input yes, input no, input '':U, input p-classif-type).  REPOSITION br-dis-grp-rule to recid v-doc-rec No-ERROR. ~
              apply 'value-changed' to br-dis-grp-rule.  " }

{ gbl/f2.i br-dis-grp-rule br-dis-grp-rule X_sum-grp  parparentproc }

{ gbl/setfltnm.i }
{ gbl/srt-clmd.i
  &browse-name    = "br-dis-grp-rule"
  &table-name    = "X_dis-grp-rule"
  &frame-name     = "{&frame-name}"
  &label-clmn_2  = "{&label-clmn_2}"
  &sort-clmn_2   = "{&sort-clmn_2}"
  &label-clmn_3  = "{&label-clmn_3}"
  &sort-clmn_3   = "{&sort-clmn_3}"
  &label-clmn_4  = "{&label-clmn_4}"
  &sort-clmn_4   = "{&sort-clmn_4}"
  &label-clmn_5  = "{&label-clmn_5}"
  &sort-clmn_5   = "{&sort-clmn_5}"
  &label-clmn_6  = "{&label-clmn_6}"
  &sort-clmn_6   = "{&sort-clmn_6}"
  &label-clmn_7  = "{&label-clmn_7}"
  &sort-clmn_7   = "{&sort-clmn_7}"
  &label-clmn_8  = "{&label-clmn_8}"
  &sort-clmn_8   = "{&sort-clmn_8}"
  &label-clmn_9  = "{&label-clmn_9}"
  &sort-clmn_9   = "{&sort-clmn_9}"
  &label-clmn_11  = "{&label-clmn_11}"
  &sort-clmn_11   = "{&sort-clmn_11}"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input no, input p-classif-type)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input no, p-classif-type)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "no"
  &mv-brw-default = "no"
}

{ gbl/brwrepos.i
  &line-num=5
}


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i GET }
  IF LOOKUP(p-classif-type, {&dis-grp-classif-list}) = 0 THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверный параметр вызова p-classif-type " p-classif-type
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.

  END.
  IF lookup(p-list-mode, ({&all} + {&delim-par} +
                          "pos" + {&delim-par} +
                          "templ-rl-root" + {&delim-par} +
                          "discnt-role" + {&delim-par} +
                          {&g___object} + {&delim-par} +
                          ({&g___Object} + {&comma-char} + "pos-type":U) + {&delim-par} +
                          ({&g___Object} + {&comma-char} + "templ-rl-root":U) + {&delim-par} +
                          ({&g___Object} + {&comma-char} + "discnt-role":U) + {&delim-par} +
                          "rule-num":U + {&delim-par} +
                          "rl-root":U) , {&delim-par}) = 0
  THEN DO:
     MESSAGE
     vss-workfile vss-revision vss-description skip
     "Неверный параметр вызова p-list-mode " p-list-mode
     VIEW-AS ALERT-BOX ERROR.
     UNDO, RETURN ERROR.
  END.
  IF lookup({&g___object} , p-list-mode) > 0 THEN DO:
    IF p-curr-obj-type <> {&stock}
    AND p-curr-obj-type <> {&shop} THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверный параметр вызова p-curr-obj-type " p-curr-obj-type
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.

    END.
    FIND FIRST X_clients-obj NO-LOCK WHERE
              X_clients-obj.obj-type = p-curr-obj-type
         AND  X_clients-obj.obj-code = p-curr-obj-code NO-ERROR.
    IF NOT AVAILABLE X_clients-obj THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверные параметры вызова p-curr-obj-type p-curr-obj-code" p-curr-obj-type p-curr-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
  end.
  IF LOOKUP( "templ-rl-root", p-list-mode) > 0 THEN DO:
      FIND FIRST PAR_dis-rule NO-LOCK WHERE
                par_dis-rule.rule-num = p-templ-rl-root no-error.
      IF NOT AVAILABLE par_Dis-rule THEN DO:
          MESSAGE
          vss-workfile vss-revision vss-description skip
          "Неверный параметр вызова p-templ-rl-root" p-templ-rl-root
          VIEW-AS ALERT-BOX ERROR.
          UNDO, RETURN ERROR.

      END.
  END.
  IF LOOKUP( "pos-type", p-list-mode) > 0
  AND lookup(p-pos-type, {&cd-type-codes-real}) = 0  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверный параметр вызова p-pos-type" p-pos-type
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  IF LOOKUP( "discnt-role", p-list-mode) > 0 THEN DO:
    FIND FIRST par_dis-cfg-rule NO-LOCK WHERE
              par_dis-cfg-rule.discnt-role = p-discnt-role
          AND par_dis-cfg-rule.TABLE-name = {&TABLE_dis-grp-rule} NO-ERROR.
    IF NOT AVAILABLE par_dis-cfg-rule  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверный параметр вызова p-discnt-role" p-discnt-role
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
    END.
  END.
  v-rid-list = p-rid-list.
  RUN Myenable IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
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
  ENABLE b-quit B-mark B-sel b-grp b-dis-rule B-sch B-print b-history B-Help
         BR-dis-grp-rule mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE variable v-h as handle no-undo .
define variable v-ii as integer no-undo .
v-h = BR-dis-grp-rule:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
DO while valid-handle(v-h)
and  v-ii < BR-dis-grp-rule:num-COLUMNs IN FRAME {&FRAME-NAME}
:
  v-ii = v-ii + 1.
  if v-h:LABEL = {&label-clmn_8}
  OR v-h:LABEL = {&label-clmn_10}
      then do:
    v-h:RESIZABLE = YES.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.

DISPLAY
mark-num
WITH FRAME {&frame-name}.
ENABLE
b-quit
B-mark WHEN LOOKUP("b-mark", bttn) > 0
B-sel WHEN LOOKUP("b-mark", bttn) > 0
b-grp
B-sch
B-print
b-history
B-Help
b-dis-rule
br-dis-grp-rule
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
hide b-grp
in frame {&frame-name} .
RUn Openbr in this-procedure ( input yes, input no, input '':U, INPUT p-classif-type).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define input parameter p-classif-type as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo .
define variable p-host-code like ub.sysconf.host-code no-undo .
run waitfram-show in this-procedure ( input "Ждите...").
define variable sort-column-phrase as character no-undo .
&scop dis-grp-classif-code p-classif-type
ASSIGN
title0 = {&dis-grp-classif-name}
.
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

if not( p-curr-obj-type = "":U and p-curr-obj-code = 0 ) then do:
{ gbl/hostcode.i p-curr-obj-type p-curr-obj-code p-host-code }
end.


&scop flt-open-open-query OPEN QUERY br-dis-grp-rule FOR EACH X_dis-grp-rule

&scop flt-open-dyn_open-query FOR EACH X_dis-grp-rule

&scop flt-open-query-handle QUERY br-dis-grp-rule:handle

&scop flt-open-open-query-tail


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_dis-grp-rule

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_dis-grp-rule


&scop flt-open-waitfram true

&scop flt-open-debug-file

define variable l-open-query as logical   no-undo .

filter-point = filter-point0 + p-list-mode.
CASE p-list-mode :
  WHEN {&all}        THEN DO:
    ASSIGN
    frame {&frame-name}:TITLE =
                                  substitute("&1"
                                  , title0
                                  )
   filter-label = substitute("&1", filter-label0)
                                  .
   { gbl/fltopend.i
      &where-cond = " X_dis-grp-rule.classif-type = p-classif-type "
      &where-cond = " substitute('X_dis-grp-rule.classif-type = &1&2&1', ~{&double-quote~}, p-classif-type) "
      &use-ind    = "  "
      &by         = "  "
      }
  END.
  WHEN {&g___object}        THEN DO:
      ASSIGN
      frame {&frame-name}:TITLE =
                                    substitute("&1 по объекту &@2 &3"
                                    , title0
                                    , p-curr-obj-type
                                    , p-curr-obj-code
                                    )
      filter-label = substitute("&1 по объекту", filter-label0)
                                    .
     { gbl/fltopend.i
      &where-cond = " X_dis-grp-rule.classif-type = p-classif-type and ~
                      X_dis-grp-rule.obj-type = p-curr-obj-type and X_dis-grp-rule.obj-code = p-curr-obj-code "
      &dyn_where-cond = " substitute('X_dis-grp-rule.classif-type = &1&2&1 and ~
                      X_dis-grp-rule.obj-type = &1&3&1 and X_dis-grp-rule.obj-code = &4 ', ~{&double-quote~},  p-classif-type, p-curr-obj-type, p-curr-obj-code)"

      &use-ind    = "  "
      &by         = "  "
      }
  END.
  WHEN ({&g___object} + {&comma-char} + "pos-type":U)       THEN DO:
      ASSIGN
      frame {&frame-name}:TITLE =
                                    substitute("&1 по объекту &@2 &3 для &4"
                                    , title0
                                    , p-curr-obj-type
                                    , p-curr-obj-code
                                    , p-pos-type
                                    )
      filter-label = substitute("&1 по объекту для кассы опред типа", filter-label0)
                                    .
     { gbl/fltopend.i
        &where-cond = " X_dis-grp-rule.classif-type = p-classif-type ~
                        and X_dis-grp-rule.obj-type = p-curr-obj-type and X_dis-grp-rule.obj-code = p-curr-obj-code ~
                        AND X_dis-grp-rule.pos-type = p-pos-type "
        &dyn_where-cond = " substitute('X_dis-grp-rule.classif-type = &1&2&1 ~
                        and X_dis-grp-rule.obj-type = &1&3&1 and X_dis-grp-rule.obj-code = &4 ~
                        AND X_dis-grp-rule.pos-type = &1&5&1 ', ~{&double-quote~}, p-classif-type, p-curr-obj-type, p-curr-obj-code, p-pos-type)"

        &use-ind    = "  "
        &by         = "  "
        }
  END.
  WHEN ({&g___object} + {&comma-char} + "templ-rl-root":U)       THEN DO:
      ASSIGN
      frame {&frame-name}:TITLE =
                                    substitute("&1 по объекту &@2 &3 тип правила &4"
                                    , title0
                                    , p-curr-obj-type
                                    , p-curr-obj-code
                                    , p-templ-rl-root
                                    )
       filter-label = substitute("&1 по объекту для правила опред типа", filter-label0)
                                    .
     { gbl/fltopend.i
      &where-cond = " X_dis-grp-rule.classif-type = p-classif-type ~
                      and X_dis-grp-rule.obj-type = p-curr-obj-type and X_dis-grp-rule.obj-code = p-curr-obj-code ~
                      AND X_dis-grp-rule.templ-rl-root = p-templ-rl-root "
      &dyn_where-cond = " substitute('X_dis-grp-rule.classif-type = &1&2&1 ~
                      and X_dis-grp-rule.obj-type = &1&3&1 and X_dis-grp-rule.obj-code = &4 ~
                      AND X_dis-grp-rule.templ-rl-root = &5 ', ~{&double-quote~}, p-classif-type, p-curr-obj-type, p-curr-obj-code, p-templ-rl-root)"

      &use-ind    = "  "
      &by         = "  "
      }
  END.
  WHEN ({&g___object} + {&comma-char} + "discnt-role":U)       THEN DO:
      ASSIGN
      frame {&frame-name}:TITLE =
                                    substitute("&1 по объекту &@2 &3 тип скидки &4"
                                    , title0
                                    , p-curr-obj-type
                                    , p-curr-obj-code
                                    , p-discnt-role
                                    )
     filter-label = substitute("&1 по объекту для опред типа скидки", filter-label0)
                                    .
     { gbl/fltopend.i
      &where-cond = " X_dis-grp-rule.classif-type = p-classif-type ~
                      and X_dis-grp-rule.obj-type = p-curr-obj-type and X_dis-grp-rule.obj-code = p-curr-obj-code ~
                      AND X_dis-grp-rule.discnt-role = p-discnt-role "
      &dyn_where-cond = " substitute('X_dis-grp-rule.classif-type = &1&2&1 ~
                      and X_dis-grp-rule.obj-type = &1&3&1 and X_dis-grp-rule.obj-code = &4 ~
                      AND X_dis-grp-rule.discnt-role = &1&5&1 ', ~{&double-quote~}, p-classif-type, p-curr-obj-type, p-curr-obj-code, p-discnt-role)"

      &use-ind    = "  "
      &by         = "  "
      }
  END.
  WHEN "templ-rl-root":U THEN DO:
    ASSIGN
    frame {&frame-name}:TITLE =
                                  substitute("&1 по шаблону &2"
                                  , title0
                                  , p-templ-rl-root
                                  )
     filter-label = substitute("&1 для шаблона", filter-label0)
                                  .
    { gbl/fltopend.i
      &where-cond = " X_dis-grp-rule.classif-type = p-classif-type ~
                      and X_dis-grp-rule.templ-rl-root = p-templ-rl-root "
      &dyn_where-cond = " substitute('X_dis-grp-rule.classif-type = &1&2&1 ~
                      and X_dis-grp-rule.templ-rl-root = &3 ', ~{&double-quote~}, p-classif-type, p-templ-rl-root)"

      &use-ind    = "  "
      &by         = "  "
      }

  END.
  WHEN "rule-num":U THEN DO:
    ASSIGN
    frame {&frame-name}:TITLE =
                                  substitute("&1 с номером правила &2"
                                  , title0
                                  , p-rule-num
                                  )
    filter-label = substitute("&1 по объекту для опред правила", filter-label0)
                                  .
    { gbl/fltopend.i
      &where-cond = " X_dis-grp-rule.rule-num = p-rule-num "
      &dyn_where-cond = " substitute('X_dis-grp-rule.rule-num = &1', p-rule-num )"
      &use-ind    = "  "
      &by         = "  "
      }

  END.
  WHEN "rl-root":U THEN DO:
      ASSIGN
      frame {&frame-name}:TITLE =
                                    substitute("&1 с номером корн.правила &2"
                                    , title0
                                    , p-rule-num
                                    )
      filter-label = substitute("&1 по объекту для опред правила", filter-label0)
                                    .
      { gbl/fltopend.i
        &where-cond = " X_dis-grp-rule.rl-root = p-rule-num "
        &dyn_where-cond = " substitute('X_dis-grp-rule.rl-root = &1', p-rule-num )"
        &use-ind    = "  "
        &by         = "  "
        }

  END.

  WHEN "pos":U THEN DO:
      ASSIGN
      frame {&frame-name}:TITLE =
                                    substitute("&1 пригодные для POS &2"
                                    , title0
                                    , p-pos-type)
     filter-label = substitute("&1 для опред типа POS", filter-label0)
                                    .
      { gbl/fltopend.i
        &where-cond = " X_dis-grp-rule.classif-type = p-classif-type ~
                        and X_dis-grp-rule.pos-type = p-pos-type "
        &dyn_where-cond = " substitute('X_dis-grp-rule.classif-type = &1&2&1 ~
                        and X_dis-grp-rule.pos-type = &1&3&1 ', ~{&double-quote~}, p-classif-type, p-pos-type)"

        &use-ind    = "  "
        &by         = "  "
        }

  END.
  WHEN "discnt-role":U THEN DO:
&SCOPED-DEFINE dis-grp-rule-code p-discnt-role
        ASSIGN
        frame {&frame-name}:TITLE =   substitute("&1 тип &2"
                                      , title0
                                      , {&dis-ggr-rule-name})
       filter-label = substitute("&1  для опред типа скидки", filter-label0)
                                      .
        { gbl/fltopend.i
          &where-cond = " X_dis-grp-rule.classif-type = p-classif-type ~
                          and X_dis-grp-rule.discnt-role = p-discnt-role "
          &dyn_where-cond = " substitute('X_dis-grp-rule.classif-type = &1&2&1 ~
                          and X_dis-grp-rule.discnt-role = &1&3&1 ', ~{&double-quote~}, p-classif-type, p-discnt-role)"

          &use-ind    = "  "
          &by         = "  "
          }

  END.
END CASE.

if not p-open-query then
REPOSITION br-dis-grp-rule to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-dis-grp-rule:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
if error-status:error then do:
  REPOSITION br-dis-grp-rule to row 1 No-ERROR.
end.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-dis-grp-rule in frame {&frame-name}.
APPLY "ENTRY" TO br-dis-grp-rule.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-mark Dialog-Frame
PROCEDURE proc-b-mark :
define variable loc#log as logical no-undo .
if available X_dis-grp-rule then do:
  { gbl/markstrn.i X_dis-grp-rule v-rid-list }
  loc#log = br-dis-grp-rule:refresh() IN FRAME {&FRAME-NAME} .
  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      loc#log = br-dis-grp-rule:select-next-row ().
      apply "VALUE-CHANGED" to br-dis-grp-rule in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-dis-grp-rule in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
define variable Line                as char         no-undo.
define variable v-rec as recid no-undo .
define variable ii as integer no-undo .
define variable v-mark as character no-undo .
define variable v-prod as character no-undo .
define variable v-d-name as character no-undo .
define variable v-pos-type as character no-undo .
Line = fill( "-" , 140 ) .
/*
{&sort-clmn_1} COLUMN-LABEL {&label-clmn_1} FORMAT "X(1)"
{&sort-clmn_5} COLUMN-LABEL {&label-clmn_5} FORMAT "X(12)"
{&sort-clmn_10} COLUMN-LABEL {&label-clmn_10} FORMAT "X(20)"
*/

define frame list
v-mark COLUMN-LABEL {&label-clmn_1} FORMAT "X(1)"
{&sort-clmn_3} COLUMN-LABEL {&label-clmn_3} FORMAT ">>>>9"
{&sort-clmn_4} COLUMN-LABEL {&label-clmn_4} FORMAT ">>>>>>>>9"
v-pos-type COLUMN-LABEL {&label-clmn_5}
{&sort-clmn_6} COLUMN-LABEL {&label-clmn_6} FORMAT "X(3)"
{&sort-clmn_7} COLUMN-LABEL {&label-clmn_7} FORMAT ">>>>>>>>9"
v-d-name COLUMN-LABEL {&label-clmn_8} FORMAT "X(20)"
{&sort-clmn_9} COLUMN-LABEL {&label-clmn_9} FORMAT ">>>>>>>>9"
{&sort-clmn_11} COLUMN-LABEL {&label-clmn_11} FORMAT ">>>>>>>>9"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>9") )
AT 86 format "X(15)" SKIP
Line format "x(130)" AT 1
with width {&DOS_CW} down use-text stream-io no-box .
v-rec = recid(X_dis-grp-rule).
DO WHILE available X_dis-grp-rule :
  GET prev br-dis-grp-rule NO-LOCK .
END.
GET next br-dis-grp-rule NO-LOCK .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

FORM HEADER
Line format "X(130)" SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS no-box.
VIEW stream PrnLibStream FRAME CliBottomFrame .
PUT stream PrnLibStream space(30)
frame {&frame-name}:title format "X(100)" SKIP(2) .
FORM with frame List .
DO WHILE available X_dis-grp-rule :
  DISPLAY stream PrnLibStream
  {&sort-clmn_1} @ v-mark
  {&sort-clmn_2}
  {&sort-clmn_3}
  {&sort-clmn_4}
  {&sort-clmn_5} @ v-pos-type
  {&sort-clmn_6}
  {&sort-clmn_7}
  {&sort-clmn_8} @ v-d-name
  {&sort-clmn_9}
  {&sort-clmn_11}
  with frame List .
  DOWN stream PrnLibStream 1 with frame List .
  ii =  ii + 1 .
  if ( ( ii modulo 10 ) = 0 ) AND ( ii >= 10 ) then
  run waitfram-show in this-procedure ( input ("Просмотрено строк : " + string( ii )) ) .
  GET next br-dis-grp-rule .
END.
run waitfram-hide in this-procedure .
PUT stream PrnLibStream Line format "X(130)" SKIP.
HIDE stream PrnLibStream FRAME BottomFrame .
output stream PrnLibStream close .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).

reposition br-dis-grp-rule to recid v-rec no-error.
if error-status:error then do:
  reposition br-dis-grp-rule to row 1 no-error.
end.
APPLy "ENTRY" to br-dis-grp-rule.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
assign
  tbl = 'dis-grp-rule'
  join-tbl = 'X_dis-grp-rule'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
  run fltfield-add in this-procedure('templ-rl-root', 'Номер типа(шаблона) правила', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('rule-num', '№ правила', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('rl-root', '№ корн.правила', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('pos-type', 'Место использ.', 'cd-types-discnt',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('discnt-role', 'Тип скидки', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('node-code', 'Код группы', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                     ,INPUT filter-point + {&delim-par} + filter-label
                     ,INPUT tbl
                     ,INPUT join-tbl
                     ,INPUT fld
                     ,INPUT lab
                     ,INPUT spr
                     ,INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U, input p-classif-type).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION full-grp-name Dialog-Frame
FUNCTION full-grp-name RETURNS CHARACTER
  ( INPUT p-classif-type AS CHARACTER
    ,INPUT p-node-code AS integer
    ,INPUT p-host-code AS INTEGER
    ,INPUT p-obj-type AS CHARACTER
    ,INPUT p-obj-code AS INTEGER) :
DEFINE VARIABLE v-node-name AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_sum-grp FOR ub.sum-grp.
DEFINE BUFFER buf_cli-grp FOR ub.cli-grp.
CASE p-classif-type:
    WHEN {&TABLE_sum-grp} THEN DO:
       FIND FIRST buf_sum-grp NO-LOCK WHERE
                 buf_sum-grp.grp-code = p-node-code NO-ERROR.
      IF NOT AVAILABLE buf_sum-grp  THEN RETURN substitute("[НЕИЗВЕСТНАЯ ГРУППА &1]", p-node-code).
      RETURN buf_sum-grp.grp-name.
    END.
    WHEN {&table_cli-grp} THEN DO:
        FIND FIRST buf_cli-grp NO-LOCK WHERE
                  buf_cli-grp.node-code = p-node-code NO-ERROR.
       IF NOT AVAILABLE buf_cli-grp  THEN RETURN substitute("[НЕИЗВЕСТНАЯ ГРУППА &1]", p-node-code).
       RUN cli-grplib-get-full-name  IN THIS-PROCEDURE ( INPUT p-node-code, OUTPUT v-node-name) NO-ERROR.
       IF ERROR-STATUS:ERROR THEN RETURN substitute("[НЕИЗВЕСТНАЯ ГРУППА &1]", p-node-code).
       RETURN v-node-name.

    END.
END CASE.
  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
