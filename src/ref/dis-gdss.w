&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_clients-obj FOR ub.clients.
DEFINE BUFFER X_dis-cfg-rule FOR ub.dis-cfg-rule.
DEFINE BUFFER X_dis-gds-rule FOR ub.dis-gds-rule.
DEFINE BUFFER X_goods FOR ub.goods.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список скидок по товарам

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
define variable vss-description as character no-undo init "Список скидок по товарам".
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
{ gbl/fltopend.i defproc }
{ gbl/disrules.i work} 
{ ref/disgdsru.i "interface" parparentproc }

&SCOPED-DEFINE dis-gds-rule-code X_dis-gds-rule.discnt-role

DEFINE VARIABLE gds-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable filter-label as character no-undo init "Скидки по товарам" .
define variable filter-label0 as character no-undo init "Скидки по товарам" .
define variable filter-point0 as character no-undo init "dis-gdss" .
define variable filter-point as character no-undo init "dis-gdss" .
define variable sort-column-name as character no-undo .
define variable v-rid-list as character no-undo .
DEFINE BUFFER par_dis-rule FOR ub.dis-rule.
DEFINE BUFFER par_dis-cfg-rule FOR ub.dis-cfg-rule.
&SCOPED-DEFINE cd-type-code X_dis-gds-rule.pos-type
&SCOPED-DEFINE sort-clmn_1 mark-string(recid(X_dis-gds-rule), v-rid-list)
&scoped-define label-clmn_1 '*'
&SCOPED-DEFINE sort-clmn_2 X_dis-gds-rule.gds-code
&scoped-define label-clmn_2 'Код товара'
&SCOPED-DEFINE sort-clmn_3 X_goods.gds-name
&scoped-define label-clmn_3 'Название'
&SCOPED-DEFINE sort-clmn_4 X_goods.artic
&scoped-define label-clmn_4 'Артикул'
&SCOPED-DEFINE sort-clmn_5 (X_goods.prod-type + string(X_goods.prod-code))
&scoped-define label-clmn_5 'Пр-ль'
&SCOPED-DEFINE sort-clmn_13 X_dis-gds-rule.nonunique
&scoped-define label-clmn_13 'Детализ.'
&SCOPED-DEFINE sort-clmn_6 X_dis-gds-rule.templ-rl-root
&scoped-define label-clmn_6 'Тип правила'
&SCOPED-DEFINE sort-clmn_7 {&cd-type-name}
&scoped-define label-clmn_7 'Место использ.'
&SCOPED-DEFINE sort-clmn_8 X_dis-gds-rule.obj-type
&scoped-define label-clmn_8 'Тип объ'
&SCOPED-DEFINE sort-clmn_9 X_dis-gds-rule.obj-code
&scoped-define label-clmn_9 'Код объ'
&SCOPED-DEFINE sort-clmn_10 ~{&dis-gds-rule-name~}
&scoped-define label-clmn_10 'Тип скидки'
&SCOPED-DEFINE sort-clmn_11 X_dis-gds-rule.rule-num
&scoped-define label-clmn_11 '№ правила'
&SCOPED-DEFINE sort-clmn_12 X_dis-gds-rule.rule-num
&scoped-define label-clmn_12 '№ корн.!правила'

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-dis-gds-rule

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_dis-gds-rule X_goods

/* Definitions for BROWSE BR-dis-gds-rule                               */
&Scoped-define FIELDS-IN-QUERY-BR-dis-gds-rule {&sort-clmn_1} {&sort-clmn_2} {&sort-clmn_3} {&sort-clmn_4} {&sort-clmn_5} {&sort-clmn_13} {&sort-clmn_6} {&sort-clmn_7} {&sort-clmn_8} {&sort-clmn_9} {&sort-clmn_10} {&sort-clmn_11} {&sort-clmn_12}   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-dis-gds-rule   
&Scoped-define SELF-NAME BR-dis-gds-rule
&Scoped-define QUERY-STRING-BR-dis-gds-rule FOR EACH X_dis-gds-rule NO-LOCK , ~
           FIRST X_goods NO-LOCK WHERE           X_goods.gds-code = X_dis-gds-rule.gds-code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-dis-gds-rule OPEN QUERY {&SELF-NAME} FOR EACH X_dis-gds-rule NO-LOCK , ~
           FIRST X_goods NO-LOCK WHERE           X_goods.gds-code = X_dis-gds-rule.gds-code INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-dis-gds-rule X_dis-gds-rule X_goods
&Scoped-define FIRST-TABLE-IN-QUERY-BR-dis-gds-rule X_dis-gds-rule
&Scoped-define SECOND-TABLE-IN-QUERY-BR-dis-gds-rule X_goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-dis-gds-rule}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel b-gds b-dis-rule B-sch ~
B-print b-history B-Help BR-dis-gds-rule mark-num 
&Scoped-Define DISPLAYED-OBJECTS mark-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-dis-rule 
     LABEL "&Правило" 
     SIZE 10 BY 1.

DEFINE BUTTON b-gds 
     LABEL "&Товар" 
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
DEFINE QUERY BR-dis-gds-rule FOR X_dis-gds-rule,
      X_goods SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-dis-gds-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-dis-gds-rule Dialog-Frame _FREEFORM
  QUERY BR-dis-gds-rule NO-LOCK DISPLAY
      {&sort-clmn_1} COLUMN-LABEL {&label-clmn_1} FORMAT "X(1)"
{&sort-clmn_2} COLUMN-LABEL {&label-clmn_2}
{&sort-clmn_3} COLUMN-LABEL {&label-clmn_3} FORMAT "X(25)"
{&sort-clmn_4} COLUMN-LABEL {&label-clmn_4}
{&sort-clmn_5} COLUMN-LABEL {&label-clmn_5} FORMAT "X(12)"
{&sort-clmn_13} COLUMN-LABEL {&label-clmn_13} FORMAT "X(9)"
{&sort-clmn_6} COLUMN-LABEL {&label-clmn_6} FORMAT ">>>>>>>>9"
{&sort-clmn_7} COLUMN-LABEL {&label-clmn_7} FORMAT "X(10)"
{&sort-clmn_8} COLUMN-LABEL {&label-clmn_8} FORMAT "X(3)"
{&sort-clmn_9} COLUMN-LABEL {&label-clmn_9} FORMAT ">>>>>>>>9"
{&sort-clmn_10} COLUMN-LABEL {&label-clmn_10} FORMAT "X(70)"
{&sort-clmn_11} COLUMN-LABEL {&label-clmn_11} FORMAT ">>>>>>>>9"
{&sort-clmn_12} COLUMN-LABEL {&label-clmn_12} FORMAT ">>>>>>>>9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 20 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11 WIDGET-ID 4
     B-sel AT ROW 1 COL 21 WIDGET-ID 10
     b-gds AT ROW 1 COL 41 WIDGET-ID 18
     b-dis-rule AT ROW 1 COL 51 WIDGET-ID 16
     B-sch AT ROW 1 COL 86 WIDGET-ID 8
     B-print AT ROW 1 COL 89 WIDGET-ID 6
     b-history AT ROW 1 COL 92 WIDGET-ID 2
     B-Help AT ROW 1 COL 95
     BR-dis-gds-rule AT ROW 3 COL 1 WIDGET-ID 100
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     SPACE(78.50) SKIP(21.22)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Скидки по товарам"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_clients-obj B "?" ? ub clients
      TABLE: X_dis-cfg-rule B "?" ? ub dis-cfg-rule
      TABLE: X_dis-gds-rule B "?" ? ub dis-gds-rule
      TABLE: X_goods B "?" ? ub goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-dis-gds-rule B-Help Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-dis-gds-rule
/* Query rebuild information for BROWSE BR-dis-gds-rule
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH X_dis-gds-rule NO-LOCK ,
    FIRST X_goods NO-LOCK WHERE
          X_goods.gds-code = X_dis-gds-rule.gds-code INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY BR-dis-gds-rule FOR X_dis-gds-rule,
      X_goods SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-dis-gds-rule */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Скидки по товарам */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Скидки по товарам */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dis-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dis-rule Dialog-Frame
ON CHOOSE OF b-dis-rule IN FRAME Dialog-Frame /* Правило */
DO:
  IF NOT AVAILABLE X_dis-gds-rule THEN RETURN NO-APPLY.
/*  run ref/show-dr.p ( INPUT parparentproc
                     ,INPUT X_dis-gds-rule.rule-num) NO-ERROR.
                     */
  run dsp-dis-rule in this-procedure  (
                                       input X_dis-gds-rule.gds-code
                                      ,input X_dis-gds-rule.nonunique
                                      ,input X_dis-gds-rule.obj-type
                                      ,input X_dis-gds-rule.obj-code
                                      ,input X_dis-gds-rule.discnt-role
                                      ,input X_dis-gds-rule.pos-type
                                      ,input X_dis-gds-rule.rule-num) .

  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gds Dialog-Frame
ON CHOOSE OF b-gds IN FRAME Dialog-Frame /* Товар */
DO:
    IF NOT AVAILABLE X_dis-gds-rule THEN RETURN NO-APPLY.
    run str/showgds.p ( input parparentproc
                   ,input ? /*p-call-handle*/
                   ,INPUT X_dis-gds-rule.gds-code
                   ,INPUT {&LOOKUP}
                   ) NO-ERROR.  
                   
                   
   IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-history Dialog-Frame
ON CHOOSE OF b-history IN FRAME Dialog-Frame /* История */
DO:
define variable v-rid-list as character no-undo .
define variable v-host-code as integer no-undo .
if not available X_dis-gds-rule then return no-apply.
if p-curr-obj-type = {&shop}
or p-curr-obj-type = {&stock} then do:
  { gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }
end.

run ref/cgdshist.w (
                  input parparentproc
                , input v-host-code /*p-curr-host-code*/
                , input p-curr-obj-type  /*p-curr-obj-type*/
                , input p-curr-obj-code  /*p-curr-obj-code*/
                , input "":U /*bttns*/
                , "subject":U /*p-mode*/
                , input X_dis-gds-rule.gds-code
                , input ? /*p-host-code*/
                , input X_dis-gds-rule.obj-type /*p-obj-type*/
                , input X_dis-gds-rule.obj-code /*p-obj-code*/
                , input ? /* p-corr-user-db-num  */
                , input "":U /* p-corr-user-name  */
                , input {&table_dis-gds-rule} /* p-subject  */
                , input v-cntxt-db-num /* p-db-num */
                , input-output v-rid-list  ) no-error .

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
  APPLY "ENTRY" to br-dis-gds-rule.

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
    if ( available X_dis-gds-rule ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_dis-gds-rule ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-dis-gds-rule
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-dis-gds-rule" }
{ gbl/brwrefre.i " v-doc-rec = recid(X_dis-gds-rule).  Run OpenBR in this-procedure ( input yes, input no, input '':U).  REPOSITION br-dis-gds-rule to recid v-doc-rec No-ERROR. ~
              apply 'value-changed' to br-dis-gds-rule.  " }

{ gbl/f2.i br-dis-gds-rule br-dis-gds-rule X_goods  parparentproc }

{ gbl/setfltnm.i }
{ gbl/srt-clmd.i
  &browse-name    = "br-dis-gds-rule"
  &table-name    = "X_dis-gds-rule"
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
  &label-clmn_10  = "{&label-clmn_10}"
  &sort-clmn_10   = "{&sort-clmn_10}"
  &label-clmn_11  = "{&label-clmn_11}"
  &sort-clmn_11   = "{&sort-clmn_11}"
  &label-clmn_12  = "{&label-clmn_12}"
  &sort-clmn_12   = "{&sort-clmn_12}"
  &label-clmn_13  = "{&label-clmn_13}"
  &sort-clmn_13   = "{&sort-clmn_13}"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input no)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input no)."
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
  v-rid-list = p-rid-list.
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
          AND par_dis-cfg-rule.TABLE-name = {&TABLE_dis-gds-rule} NO-ERROR.
    IF NOT AVAILABLE par_dis-cfg-rule  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверный параметр вызова p-discnt-role" p-discnt-role
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
    END.
  END.
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
  ENABLE b-quit B-mark B-sel b-gds b-dis-rule B-sch B-print b-history B-Help 
         BR-dis-gds-rule mark-num 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
define variable v-h as handle no-undo .
define variable v-ii as integer no-undo .
v-h = BR-dis-gds-rule:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
DO while valid-handle(v-h)
and  v-ii < br-dis-gds-rule:num-COLUMNs IN FRAME {&FRAME-NAME}:
  v-ii = v-ii + 1.
  if v-h:LABEL = {&label-clmn_6}
  or v-h:LABEL = {&label-clmn_10}
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
B-sch
B-print
b-history
B-Help
b-dis-rule
b-gds
BR-dis-gds-rule
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
RUn Openbr in this-procedure ( input yes, input no, input '':U).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo init "Скидки на товар".
define variable p-host-code like ub.sysconf.host-code no-undo .
run waitfram-show in this-procedure ( input "Ждите...").
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

if not( p-curr-obj-type = "":U and p-curr-obj-code = 0 ) then do:
{ gbl/hostcode.i p-curr-obj-type p-curr-obj-code p-host-code }
end.


&scop flt-open-open-query OPEN QUERY br-dis-gds-rule FOR EACH X_dis-gds-rule no-lock

&scop flt-open-DYN_open-query FOR EACH X_dis-gds-rule no-lock

&scop flt-open-query-HANDLE QUERY br-dis-gds-rule:HANDLE

&scop flt-open-open-query-tail , FIRST X_goods no-lock where X_goods.gds-code = X_dis-gds-rule.gds-code

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_dis-gds-rule

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-NAME  X_dis-gds-rule


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
      &where-cond = " X_dis-gds-rule.rule-num > 0 "
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
      filter-label = substitute("&1 Один объект", filter-label0)
                                    .
     { gbl/fltopend.i
      &where-cond = " X_dis-gds-rule.rule-num > 0 ~
                    AND X_dis-gds-rule.obj-type = p-curr-obj-type and X_dis-gds-rule.obj-code = p-curr-obj-code "
      &DYN_where-cond = " substitute('X_dis-gds-rule.rule-num > 0 ~
                    AND X_dis-gds-rule.obj-type = &1&2&1 and X_dis-gds-rule.obj-code = &3 ', ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code)"

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
     filter-label = substitute("&1 Один объект, одно место использ", filter-label0)
                                    .
     { gbl/fltopend.i
      &where-cond = " X_dis-gds-rule.rule-num > 0 ~
                      AND X_dis-gds-rule.obj-type = p-curr-obj-type and X_dis-gds-rule.obj-code = p-curr-obj-code ~
                      AND X_dis-gds-rule.pos-type = p-pos-type "
      &DYN_where-cond = " substitute('X_dis-gds-rule.rule-num > 0 ~
                      AND X_dis-gds-rule.obj-type = &1&2&1 and X_dis-gds-rule.obj-code = &2 ~
                      AND X_dis-gds-rule.pos-type = &1&4&1 ', ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, p-pos-type)"

      &use-ind    = "  "
      &by         = "  "
      }
  END.
  WHEN ({&g___object} + {&comma-char} + "templ-rl-root":U)       THEN DO:
      ASSIGN
      frame {&frame-name}:TITLE =
                                    substitute("&1 по объекту &@2 &3 шаблон &4"
                                    , title0
                                    , p-curr-obj-type
                                    , p-curr-obj-code
                                    , p-templ-rl-root
                                    )
      filter-label = substitute("&1 Один объект, один шаблон", filter-label0)
                                    .
     { gbl/fltopend.i
      &where-cond = "  X_dis-gds-rule.rule-num > 0 ~
                      AND X_dis-gds-rule.obj-type = p-curr-obj-type and X_dis-gds-rule.obj-code = p-curr-obj-code ~
                      AND X_dis-gds-rule.templ-rl-root = p-templ-rl-root "
      &dyn_where-cond = "  substitute('X_dis-gds-rule.rule-num > 0 ~
                      AND X_dis-gds-rule.obj-type = &1&2&1 and X_dis-gds-rule.obj-code = &3 ~
                      AND X_dis-gds-rule.templ-rl-root = &4 ', ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, p-templ-rl-root)"

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
      filter-label = substitute("&1 Один объект, один тип скидки", filter-label0)
                                    .
     { gbl/fltopend.i
      &where-cond = "  X_dis-gds-rule.rule-num > 0 ~
                      AND X_dis-gds-rule.obj-type = p-curr-obj-type and X_dis-gds-rule.obj-code = p-curr-obj-code ~
                      AND X_dis-gds-rule.discnt-role = p-discnt-role "
      &dyn_where-cond = "  substitute('X_dis-gds-rule.rule-num > 0 ~
                      AND X_dis-gds-rule.obj-type = &1&2&1 and X_dis-gds-rule.obj-code = &3 ~
                      AND X_dis-gds-rule.discnt-role = &1&4&1 ', ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, p-discnt-role)"

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
    filter-label = substitute("&1 Один шаблон", filter-label0)
                                  .
    { gbl/fltopend.i
      &where-cond = "  X_dis-gds-rule.rule-num > 0 ~
                        AND X_dis-gds-rule.templ-rl-root = p-templ-rl-root "
      &dyn_where-cond = "  substitute('X_dis-gds-rule.rule-num > 0 ~
                        AND X_dis-gds-rule.templ-rl-root = &1', p-templ-rl-root )"

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
   filter-label = substitute("&1 Одно правило", filter-label0)
                                  .
    { gbl/fltopend.i
      &where-cond = "  X_dis-gds-rule.rule-num > 0 ~
                        AND X_dis-gds-rule.rule-num = p-rule-num "
      &dyn_where-cond = "  substitute('X_dis-gds-rule.rule-num > 0 ~
                        AND X_dis-gds-rule.rule-num = &1', p-rule-num )"

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
   filter-label = substitute("&1 Одно правило", filter-label0)
                                  .
    { gbl/fltopend.i
    &where-cond = "  X_dis-gds-rule.rule-num > 0 ~
                      AND X_dis-gds-rule.rl-root = p-rule-num "
    &dyn_where-cond = "  substitute('X_dis-gds-rule.rule-num > 0 ~
                      AND X_dis-gds-rule.rl-root = &1', p-rule-num )"

    &use-ind    = "  "
    &by         = "  "
    }

  END.
  WHEN "pos":U THEN DO:
      ASSIGN
      frame {&frame-name}:TITLE =
                                    substitute("&1, место использования &2"
                                    , title0
                                    , p-pos-type)
     filter-label = substitute("&1 Одно место использ", filter-label0)
                                    .
      { gbl/fltopend.i
        &where-cond = "  X_dis-gds-rule.rule-num > 0 ~
                          AND X_dis-gds-rule.pos-type = p-pos-type "
        &dyn_where-cond = "  substitute('X_dis-gds-rule.rule-num > 0 ~
                          AND X_dis-gds-rule.pos-type = &1&2&1', ~{&double-quote~}, p-pos-type )"

        &use-ind    = "  "
        &by         = "  "
        }

  END.
  WHEN "discnt-role":U THEN DO:
&SCOPED-DEFINE dis-gds-rule-code p-discnt-role
        ASSIGN
        frame {&frame-name}:TITLE =   substitute("&1 тип &2"
                                      , title0
                                      , {&dis-gds-rule-name})
        filter-label = substitute("&1 Один тип скидки", filter-label0)
                                      .
        { gbl/fltopend.i
        &where-cond = "  X_dis-gds-rule.rule-num > 0 ~
                          AND X_dis-gds-rule.discnt-role = p-discnt-role "
        &dyn_where-cond = "  substitute('X_dis-gds-rule.rule-num > 0 ~
                          AND X_dis-gds-rule.discnt-role = &1&2&1', ~{&double-quote~}, p-discnt-role )"

        &use-ind    = "  "
        &by         = "  "
        }

  END.
END CASE.

if not p-open-query then
REPOSITION br-dis-gds-rule to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-dis-gds-rule:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
if error-status:error then do:
  REPOSITION br-dis-gds-rule to row 1 No-ERROR.
end.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-dis-gds-rule in frame {&frame-name}.
APPLY "ENTRY" TO br-dis-gds-rule.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-mark Dialog-Frame 
PROCEDURE proc-b-mark :
define variable loc#log as logical no-undo .
if available X_dis-gds-rule then do:
  { gbl/markstrn.i X_dis-gds-rule v-rid-list }
  loc#log = br-dis-gds-rule:refresh() IN FRAME {&FRAME-NAME} .
  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      loc#log = br-dis-gds-rule:select-next-row ().
      apply "VALUE-CHANGED" to br-dis-gds-rule in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-dis-gds-rule in frame {&frame-name}.
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
{&sort-clmn_2} COLUMN-LABEL {&label-clmn_2}
{&sort-clmn_3} COLUMN-LABEL {&label-clmn_3} FORMAT "X(25)"
{&sort-clmn_4} COLUMN-LABEL {&label-clmn_4}
v-prod COLUMN-LABEL {&label-clmn_5} FORMAT "X(12)"
{&sort-clmn_6} COLUMN-LABEL {&label-clmn_6} FORMAT ">>>>>>>>9"
v-pos-type COLUMN-LABEL {&label-clmn_7} FORmat "X(20)"
{&sort-clmn_8} COLUMN-LABEL {&label-clmn_8} FORMAT "X(3)"
{&sort-clmn_9} COLUMN-LABEL {&label-clmn_9} FORMAT ">>>>>>>>9"
v-d-name COLUMN-LABEL {&label-clmn_10} FORMAT "X(60)"
{&sort-clmn_11} COLUMN-LABEL {&label-clmn_11} FORMAT ">>>>>>>>9"
{&sort-clmn_12} COLUMN-LABEL {&label-clmn_12} FORMAT ">>>>>>>>9"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>9") )
AT 86 format "X(15)" SKIP
Line format "x(130)" AT 1
with width {&DOS_CW} down use-text stream-io no-box .
v-rec = recid(X_dis-gds-rule).
DO WHILE available X_dis-gds-rule :
  GET prev br-dis-gds-rule NO-LOCK .
END.
GET next br-dis-gds-rule NO-LOCK .
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
DO WHILE available X_dis-gds-rule :
  DISPLAY stream PrnLibStream
  {&sort-clmn_1} @ v-mark
  {&sort-clmn_2}
  {&sort-clmn_3}
  {&sort-clmn_4}
  {&sort-clmn_5} @ v-prod
  {&sort-clmn_6}
  {&sort-clmn_7} @ v-pos-type
  {&sort-clmn_8}
  {&sort-clmn_9}
  {&sort-clmn_10} @ v-d-name
  {&sort-clmn_11}
  {&sort-clmn_12}
  with frame List .
  DOWN stream PrnLibStream 1 with frame List .
  ii =  ii + 1 .
  if ( ( ii modulo 10 ) = 0 ) AND ( ii >= 10 ) then
  run waitfram-show in this-procedure ( input ("Просмотрено строк : " + string( ii )) ) .
  GET next br-dis-gds-rule .
END.
run waitfram-hide in this-procedure .
PUT stream PrnLibStream Line format "X(130)" SKIP.
HIDE stream PrnLibStream FRAME BottomFrame .
output stream PrnLibStream close .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).

reposition br-dis-gds-rule to recid v-rec no-error.
if error-status:error then do:
  reposition br-dis-gds-rule to row 1 no-error.
end.
APPLy "ENTRY" to br-dis-gds-rule.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame 
PROCEDURE proc-b-sch :
assign
  tbl = 'dis-gds-rule'
  join-tbl = 'X_dis-gds-rule'
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
  run fltfield-add in this-procedure('gds-code', 'Товар', 'gds',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

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

