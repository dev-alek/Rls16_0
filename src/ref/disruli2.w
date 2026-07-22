&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_dis-rule FOR ub.dis-rule.
DEFINE BUFFER root_dis-rule FOR ub.dis-rule.
DEFINE BUFFER template_dis-rule FOR ub.dis-rule.
DEFINE BUFFER term_dis-rule FOR ub.dis-rule.
DEFINE TEMP-TABLE tt-bc-dis-rule NO-UNDO LIKE ub.bar-code
       field rule-num like ub.dis-rule.rule-num
       field price-brutto like ub.gds-obj.price-sale
       field price-netto like ub.gds-obj.price-sale
       field price-discnt like ub.gds-obj.price-sale
       field sum-brutto like ub.trn-doc.tot-sale
       field sum-netto like ub.trn-doc.tot-sale
       field sum-discnt like ub.trn-doc.tot-sale
       field d-pcnt like ub.dis-rule.discnt-value
       field sale-qnty like ub.dis-rule.doc-qnty
       index pi is unique primary rule-num.
DEFINE TEMP-TABLE tt-dis-rule NO-UNDO LIKE ub.dis-rule.
DEFINE TEMP-TABLE tt0-term_dis-rule NO-UNDO LIKE ub.dis-rule.
DEFINE BUFFER X_bar-code FOR ub.bar-code.
DEFINE BUFFER X_dis-time-rule FOR ub.dis-time-rule.
DEFINE BUFFER X_goods FOR ub.goods.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование правил скидок по шаблону 75

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/02/04
Author: Bakhtadze Natalya
Creation date: 09/02/04

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS widget-handle NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS character NO-UNDO.
DEFINE INPUT PARAMETER p-templ-rl-root like ub.dis-rule.templ-rl-root NO-UNDO.
DEFINE INPUT PARAMETER p-host-code LIKE ub.sysconf.host-code NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code LIKE ub.clients.obj-code NO-UNDO.
DEFINE INPUT PARAMETER p-rule-num LIKE ub.dis-rule.rule-num NO-UNDO.
define input parameter p-upper-rule-num like ub.dis-rule.upper-rule-num no-undo .
define input parameter p-b-code like ub.bar-code.b-code no-undo .
define input parameter p-time-templ-rl-root as integer no-undo .
define input parameter p-pos-type as character no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-recid AS recid NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование правил скидок по шаблону 75".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/disrules.i "work" }
{ ref/gtregion.i }
define variable  v-rule-num          like ub.dis-rule.rule-num          no-undo .
define variable  v-des               like ub.dis-rule.des               no-undo .
define variable  v-discnt-type       like ub.dis-rule.discnt-type       no-undo .
define variable  v-subject-type      like ub.dis-rule.subject-type      no-undo .
define variable  v-level-1           as character no-undo .
define variable  v-level-2           as character no-undo .
define variable  v-value-type        like ub.dis-rule.value-type        no-undo .
define variable  v-dis-kat-tree      as logical no-undo .
define variable  v-doc-qnty-tree     as logical no-undo .
define variable  v-tot-sum-tree      as logical no-undo .
define variable  v-charkey_one-tree  as logical no-undo .
define variable  v-charkey_two-tree  as logical no-undo .
define variable  v-charkey_three-tree  as logical no-undo .
define variable  v-deckey_one-tree  as logical no-undo .
define variable  v-deckey_two-tree  as logical no-undo .
define variable  v-deckey_three-tree  as logical no-undo .
define variable  v-key#_one-tree  as logical no-undo .
define variable  v-key#_two-tree  as logical no-undo .
define variable  v-key#_three-tree  as logical no-undo .
define variable  v-time-rule-num-tree as logical no-undo .
define variable  v-output-display as logical   no-undo . /* виден в броусе */
define variable  v-global         as integer no-undo .
define variable  v-host           as integer no-undo .
define variable  v-object         as integer no-undo .
define variable  v-tree              as character no-undo .
define variable  v-other          as character no-undo . /* еще чего - нибудь */
DEFINE VARIABLE v-tab-order       AS CHARACTER NO-UNDO.
define variable  is-good-mode as logical   no-undo . /* виден в броусе */
define variable v-meas as integer no-undo init 3.
DEFINE VARIABLE v-price-sale LIKE ub.price-list.price-sale NO-UNDO.
DEFINE VARIABLE v-doc-num LIKE ub.price-list.doc-num NO-UNDO.
DEFINE VARIABLE v-road-tax LIKE ub.price-list.road-tax NO-UNDO.
DEFINE VARIABLE v-excise LIKE ub.price-list.excise NO-UNDO.
define variable v-doc-rec as recid no-undo .
define variable v-radio-integer-handle as handle no-undo .
define variable v-pos-type as character no-undo .
define variable v-is-copy as logical no-undo .
define variable v-ref-dr-templ-rl-root  as integer no-undo .

DEFINE BUFFER X_sysconf FOR ub.sysconf.
DEFINE BUFFER X_cli-obj FOR ub.clients.
DEFINE BUFFER buf_dis-time-rule FOR ub.dis-time-rule.
define buffer buf_units for ub.units.
define buffer buf_temp-drt-prop for temp-drt-prop.
DEFINE BUFFER dr-chk_dis-rule FOR ub.dis-rule.

&SCOPED-DEFINE dr-chk-host-code p-host-code
&SCOPED-DEFINE dr-chk-obj-type p-obj-type
&SCOPED-DEFINE dr-chk-obj-code p-obj-code

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-dis-rule locked_dis-rule

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-dis-rule.des ~
tt-dis-rule.value-type tt-dis-rule.Key#_One tt-dis-rule.time-rule-num ~
tt-dis-rule.rule-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-dis-rule.des ~
tt-dis-rule.value-type tt-dis-rule.Key#_One tt-dis-rule.time-rule-num ~
tt-dis-rule.rule-num
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-dis-rule
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-dis-rule
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-dis-rule SHARE-LOCK, ~
      EACH locked_dis-rule WHERE TRUE /* Join to tt-dis-rule incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-dis-rule SHARE-LOCK, ~
      EACH locked_dis-rule WHERE TRUE /* Join to tt-dis-rule incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-dis-rule locked_dis-rule
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-dis-rule
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame locked_dis-rule


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-dis-rule.des tt-dis-rule.value-type ~
tt-dis-rule.Key#_One tt-dis-rule.time-rule-num tt-dis-rule.rule-num
&Scoped-define ENABLED-TABLES tt-dis-rule
&Scoped-define FIRST-ENABLED-TABLE tt-dis-rule
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-time-rule-lookup B-hist ~
B-Help f-pos-type B-dis-rule b-rule-lookup B-dis-time-rule F-region
&Scoped-Define DISPLAYED-FIELDS tt-dis-rule.des tt-dis-rule.value-type ~
tt-dis-rule.Key#_One tt-dis-rule.time-rule-num tt-dis-rule.rule-num
&Scoped-define DISPLAYED-TABLES tt-dis-rule
&Scoped-define FIRST-DISPLAYED-TABLE tt-dis-rule
&Scoped-Define DISPLAYED-OBJECTS s-discnt-type f-pos-type s-subject-type ~
key#_one-name F-region

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-dis-rule
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-dis-time-rule
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-rule-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-time-rule-lookup
     LABEL "&Распис."
     SIZE 10 BY 1.

DEFINE VARIABLE f-pos-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Место исп."
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 21 BY 1 NO-UNDO.

DEFINE VARIABLE s-discnt-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип скидки"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 19 BY 1 NO-UNDO.

DEFINE VARIABLE s-subject-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Объект скидки"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE F-region AS CHARACTER FORMAT "X(256)":U
     LABEL "Действует"
      VIEW-AS TEXT
     SIZE 22.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE key#_one-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 96.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-dis-rule,
      locked_dis-rule SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-time-rule-lookup AT ROW 1 COL 41
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-dis-rule.des AT ROW 2 COL 10 COLON-ALIGNED
          LABEL "Описание"
          VIEW-AS FILL-IN
          SIZE 84 BY 1
          FGCOLOR 4
     tt-dis-rule.value-type AT ROW 3 COL 10 COLON-ALIGNED WIDGET-ID 2
          LABEL "Тип знач."
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "0",1
          DROP-DOWN-LIST
          SIZE 31 BY 1
     s-discnt-type AT ROW 3.93 COL 14 COLON-ALIGNED
     f-pos-type AT ROW 3.93 COL 46 COLON-ALIGNED WIDGET-ID 6
     s-subject-type AT ROW 4.93 COL 14 COLON-ALIGNED
     tt-dis-rule.Key#_One AT ROW 6.6 COL 28 COLON-ALIGNED WIDGET-ID 10
          LABEL "ИПоле1"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     B-dis-rule AT ROW 6.6 COL 41 WIDGET-ID 16
     b-rule-lookup AT ROW 6.6 COL 45 WIDGET-ID 18
     key#_one-name AT ROW 7.93 COL 2 NO-LABEL WIDGET-ID 12
     tt-dis-rule.time-rule-num AT ROW 9.53 COL 11 COLON-ALIGNED
          LABEL "№ распис."
          VIEW-AS FILL-IN
          SIZE 8 BY 1
     B-dis-time-rule AT ROW 9.53 COL 21.5
     tt-dis-rule.rule-num AT ROW 1.27 COL 71.5 COLON-ALIGNED
          LABEL "№ правила"
           VIEW-AS TEXT
          SIZE 14 BY .67
          FGCOLOR 4
     F-region AT ROW 3 COL 74.5 COLON-ALIGNED
     SPACE(0.29) SKIP(18.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Правило скидки ТИПА:"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_dis-rule B "?" ? ub dis-rule
      TABLE: root_dis-rule B "?" ? ub dis-rule
      TABLE: template_dis-rule B "?" ? ub dis-rule
      TABLE: term_dis-rule B "?" ? ub dis-rule
      TABLE: tt-bc-dis-rule T "?" NO-UNDO ub bar-code
      ADDITIONAL-FIELDS:
          field rule-num like ub.dis-rule.rule-num
          field price-brutto like ub.gds-obj.price-sale
          field price-netto like ub.gds-obj.price-sale
          field price-discnt like ub.gds-obj.price-sale
          field sum-brutto like ub.trn-doc.tot-sale
          field sum-netto like ub.trn-doc.tot-sale
          field sum-discnt like ub.trn-doc.tot-sale
          field d-pcnt like ub.dis-rule.discnt-value
          field sale-qnty like ub.dis-rule.doc-qnty
          index pi is unique primary rule-num
      END-FIELDS.
      TABLE: tt-dis-rule T "?" NO-UNDO ub dis-rule
      TABLE: tt0-term_dis-rule T "?" NO-UNDO ub dis-rule
      TABLE: X_bar-code B "?" ? ub bar-code
      TABLE: X_dis-time-rule B "?" ? ub dis-time-rule
      TABLE: X_goods B "?" ? ub goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-dis-rule:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-dis-time-rule:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-time-rule-lookup:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-rule.des IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-dis-rule.Key#_One IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-rule.Key#_One:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN key#_one-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
ASSIGN
       key#_one-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-rule.rule-num IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX s-discnt-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR COMBO-BOX s-subject-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-dis-rule.time-rule-num IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-rule.time-rule-num:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR COMBO-BOX tt-dis-rule.value-type IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-dis-rule,Temp-Tables.locked_dis-rule WHERE Temp-Tables.tt-dis-rule ..."
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Правило скидки ТИПА: */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-dis-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-dis-rule Dialog-Frame
ON CHOOSE OF B-dis-rule IN FRAME Dialog-Frame
DO:
   RUN local-dr-chk ("key#_one", "button").
  apply "entry" to tt-dis-rule.key#_one in FRAME {&FRAME-NAME}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-dis-time-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-dis-time-rule Dialog-Frame
ON CHOOSE OF B-dis-time-rule IN FRAME Dialog-Frame
DO:
 run proc-b-dis-time-rule in this-procedure no-error.
 if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
  define variable v-rid-list as character no-undo.
  if NOT available locked_dis-rule then return no-apply.
  run ref/discruls.w (
                   INPUT parParentProc
                  ,input "":U /*bttns*/
                  ,input "rl-root":U /**p-mode*/
                  ,input tt-dis-rule.rule-num
                  ,input tt-dis-rule.upper-rule-num
                  ,input "":U /*p-curr-obj-type*/
                  ,input 0 /*p-curr-obj-code*/
                  ,input-output v-rid-list ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-rule-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rule-lookup Dialog-Frame
ON CHOOSE OF b-rule-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
  IF AVAILABLE dr-chk_dis-rule THEN DO:
    run ref/show-dr.p ( input parparentproc
                      ,input dr-chk_dis-rule.rule-num) no-error.

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-time-rule-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-time-rule-lookup Dialog-Frame
ON CHOOSE OF B-time-rule-lookup IN FRAME Dialog-Frame /* Распис. */
DO:
  RUN proc-time-rule-lookup IN THIS-PROCEDURE (V-TREE) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-dis-rule.Key#_One
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-dis-rule.Key#_One Dialog-Frame
ON LEAVE OF tt-dis-rule.Key#_One IN FRAME Dialog-Frame /* ИПоле1 */
DO:
    { gbl/stdbtn.i }

  if input frame {&frame-name} tt-dis-rule.key#_one <> tt-dis-rule.key#_one then do:
    run local-dr-chk ("key#_one", "leave-message").
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-dis-rule.Key#_One Dialog-Frame
ON RETURN OF tt-dis-rule.Key#_One IN FRAME Dialog-Frame /* ИПоле1 */
DO:
  run local-dr-chk ("key#_one", "ret-mouse").
  apply "entry" to tt-dis-rule.key#_one in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-dis-rule.time-rule-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-dis-rule.time-rule-num Dialog-Frame
ON LEAVE OF tt-dis-rule.time-rule-num IN FRAME Dialog-Frame /* № распис. */
DO:
{ gbl/stdbtn.i }
    if   input frame {&frame-name} tt-dis-rule.time-rule-num <> 0 then do:
    run check-time-rule in this-procedure no-error.
    if error-status:error then do:
       return no-apply.
    end.
  end.


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
{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }
{ gbl/disrules.i "interface" "no-br-term-dr" }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF p-mode <> {&add-def}
  and p-mode <> {&lookup}
  and p-mode <> {&update}
  and p-mode <> {&add-copy}
  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-mode" p-mode
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  IF p-mode <> {&add-def} THEN DO:

  END.
  if p-mode = {&add-copy} then do:
    v-is-copy = yes.
    p-mode = {&add-def}.
  end.
  for each tt-dis-rule:
    delete tt-dis-rule.
  end.
  for each tt0-term_dis-rule:
    delete tt0-term_dis-rule.
  end.
  run dr-code  in this-procedure (
     input  p-templ-rl-root
    ,output v-des
    ,output v-discnt-type
    ,output v-subject-type
    ,output v-value-type
    ,output v-level-1
    ,output v-level-2
    ,output v-global
    ,output v-host
    ,output v-object
    ,output v-output-display
    ,output v-tree
    ,output v-other
                               ) no-error .
  IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра p-templ-rl-root" p-templ-rl-root SKIP
     error-status:get-message(1) SKIP
     RETURN-VALUE
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.

  END.
  run disrules-fill-properties in this-procedure ( input p-templ-rl-root).
  /*для BOSCI мы не можем посчитать конерктные скидки - они зависят от скидки на ДК*/
  if can-find(first temp-drt-prop where
                   temp-drt-prop.templ-rl-root = p-templ-rl-root
               and temp-drt-prop.prop-code = "CalcGoodsPrice":U
               and temp-drt-prop.upper-prop-code = "":U
               and temp-drt-prop.property-value  = "no") then do:
    assign
    p-b-code = 0
    .
  end.
  IF p-b-code <> 0  THEN DO:

    IF v-subject-type <> INTEGER({&discnt-gds}) THEN DO:
        MESSAGE
            vss-workfile vss-revision vss-description skip
            "Неверное значение параметра p-b-code" p-b-code SKIP
             error-status:get-message(1) SKIP
             RETURN-VALUE
            VIEW-AS ALERT-BOX ERROR.
            UNDO, RETURN ERROR.
    END.
    FIND FIRST X_bar-code NO-LOCK WHERE
                X_bar-code.b-code = p-b-code NO-ERROR.
    IF NOT AVAILABLE X_bar-code THEN DO:
      MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-b-code" p-b-code SKIP
         error-status:get-message(1) SKIP
         RETURN-VALUE
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
     END.
     FIND FIRST X_goods NO-LOCK WHERE X_goods.gds-code = X_bar-code.gds-code NO-ERROR.
     IF NOT AVAILABLE X_goods THEN DO:
    MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-b-code" p-b-code SKIP
         error-status:get-message(1) SKIP
         RETURN-VALUE
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
     END.
    ASSIGN
    is-good-mode = YES.
    find first buf_units no-lock where
               buf_units.unit-name = X_goods.unit-base no-error.
    if available buf_units then do:
      assign
      v-meas = if( LOOKUP({&pieces}, buf_units.type) > 0 or LOOKUP({&serial}, buf_units.type) > 0 )
               then 0
               else v-meas.
    end.
    { gbl/bcodeprc.i
        p-obj-type
        p-obj-code
        p-b-code
        0
        0
        v-doc-num
        v-price-sale
        v-road-tax
        v-excise
        no-error }
  END.
  run fill-main-table in this-procedure.
  if p-upper-rule-num > {&max-num-dr-template} then do:
    assign
    v-tree = "":U.
  end.
  RUN fill-tables IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-time-rule Dialog-Frame
PROCEDURE check-time-rule :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
              buf_dis-time-rule.time-rule-num = input frame {&frame-name} tt-dis-rule.time-rule-num
         no-error.
if not available buf_dis-time-rule then do:
  if input frame {&frame-name} tt-dis-rule.time-rule-num <> ?  then
    message "Неправильный номер расписания" .
  apply "entry" to tt-dis-rule.time-rule-num in frame {&frame-name}.
  return error.
end.
find first X_dis-time-rule no-lock where recid(X_dis-time-rule) = recid(buf_dis-time-rule).
assign
tt-dis-rule.time-rule-num = buf_dis-time-rule.time-rule-num
tt-dis-rule.time-templ-rl-root = buf_dis-time-rule.templ-rl-root
.

display
tt-dis-rule.time-rule-num
with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-hide-fields Dialog-Frame
PROCEDURE display-hide-fields :
DEFINE INPUT PARAMETER p-tree AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-main AS LOGICAL NO-UNDO. /*какую записб редактируем 1 - main 0 терминальную - подчин*/
DEFINE INPUT PARAMETER p-display-hide AS integer NO-UNDO. /*1 - display 0 hide*/
CASE p-display-hide:
  WHEN 1 THEN DO:
    IF lookup("time-rule-num":U, v-level-1) > 0 THEN DO:
      ASSIGN
      b-time-rule-lookup:ROW in frame {&frame-name} = 1
      b-time-rule-lookup:column = b-hist:COLUMN - 10
      .
      DISPLAY
      tt-dis-rule.time-rule-num
      b-dis-time-rule
      b-time-rule-lookup
      WITH FRAME {&FRAME-NAME}.
      ENABLE
      tt-dis-rule.time-rule-num WHEN p-mode <> {&LOOKUP}
      b-dis-time-rule WHEN p-mode <> {&LOOKUP}
      b-time-rule-LOOKUP
      WITH FRAME {&FRAME-NAME}.
    END.
    else do:
      hide
      tt-dis-rule.time-rule-num
      b-dis-time-rule
      b-time-rule-lookup
      in FRAME {&FRAME-NAME}.
    END.
    DISPLAY
    tt-dis-rule.key#_one
    WITH FRAME {&FRAME-NAME}.
    ENABLE
    tt-dis-rule.key#_one WHEN p-mode <> {&LOOKUP}
    b-dis-rule WHEN p-mode <> {&LOOKUP}
    b-rule-LOOKUP
    WITH FRAME {&FRAME-NAME}.
  END. /*when 1 = display*/
  WHEN 0 THEN DO:
    HIDE
    tt-dis-rule.key#_one
    tt-dis-rule.time-rule-num
    b-time-rule-lookup
    b-dis-time-rule
    b-dis-rule
    b-rule-lookup
    in FRAME {&FRAME-NAME}.
  END.
END CASE.

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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY s-discnt-type f-pos-type s-subject-type key#_one-name F-region
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-dis-rule THEN
    DISPLAY tt-dis-rule.des tt-dis-rule.value-type tt-dis-rule.Key#_One
          tt-dis-rule.time-rule-num tt-dis-rule.rule-num
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-time-rule-lookup B-hist B-Help tt-dis-rule.des
         tt-dis-rule.value-type f-pos-type tt-dis-rule.Key#_One B-dis-rule
         b-rule-lookup tt-dis-rule.time-rule-num B-dis-time-rule
         tt-dis-rule.rule-num F-region
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-main-table Dialog-Frame
PROCEDURE fill-main-table :
if p-mode = {&update}
or p-mode = {&lookup}
or (p-mode = {&add-def} and v-is-copy)
then do:
  find first locked_dis-rule no-lock where
          recid(locked_dis-rule) = p-recid no-error .
  if not available locked_dis-rule then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найдена запись ПРАВИЛО СКИДОК с номером" p-rule-num
    view-as alert-box error .
    undo, return error.
  end.
  if locked_dis-rule.root = no then do:
    message
    substitute("Невозможен просмотр не корневого правила &1", p-rule-num)
    view-as alert-box error .
    undo, return error .
  end.
  if p-mode = {&update} then do:
    find first locked_dis-rule EXclusive-lock where
                  recid(locked_dis-rule) = p-recid no-wait no-error.
    if locked locked_dis-rule then do:
      message
      vss-workfile vss-revision vss-description skip
        "Запись ПРАВИЛО СКИДОК занята"
      view-as alert-box error .
      undo, return error.
    end.
  end.
  else do:
    find first locked_dis-rule no-lock where
                      recid(locked_dis-rule) = p-recid no-error .
    if not avail locked_dis-rule then do:
      find first locked_dis-rule no-lock where
                  locked_dis-rule.rule-num = p-rule-num no-error .
    end.
  end.
  if locked_dis-rule.rule-num <= {&max-num-dr-template}
  and p-mode = {&update} then do:
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя редактировать ШАБЛОНЫ СКИДОК"
    view-as alert-box error .
    undo, return error.
  end.
  create tt-dis-rule.
  buffer-copy locked_dis-rule to tt-dis-rule
  .
  if p-mode = {&add-def}
  and v-is-copy = yes then do:
    assign
    tt-dis-rule.rule-num = locked_dis-rule.templ-rl-root
    tt-dis-rule.host-code = p-host-code
    tt-dis-rule.obj-type = p-obj-type
    tt-dis-rule.obj-code = p-obj-code
    .
  end.
  end.
  else do:
      FIND FIRST template_dis-rule NO-LOCK WHERE
                  template_dis-rule.rule-num = p-templ-rl-root .
      create tt-dis-rule.
      BUFFER-COPY template_dis-rule TO tt-dis-rule
      ASSIGN
      tt-dis-rule.upper-rule-num = template_dis-rule.rule-num
      tt-dis-rule.templ-rl-root  = template_dis-rule.rule-num
      tt-dis-rule.root        = yes
      tt-dis-rule.host-code = p-host-code
      tt-dis-rule.obj-type = p-obj-type
      tt-dis-rule.obj-code = p-obj-code
      tt-dis-rule.des = trim(template_dis-rule.des, "@":U)
      tt-dis-rule.lvl-num = 1
      .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
define variable glog as logical no-undo .
define variable v-ii as integer no-undo .
DEFINE BUFFER buf_tt0-term_dis-rule FOR tt0-term_dis-rule.
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
IF p-mode = {&add-def} AND tt-dis-rule.is-term = no and not v-is-copy then  RETURN.
IF tt-dis-rule.time-rule-num <> 0 THEN
FIND FIRST X_dis-time-rule WHERE X_dis-time-rule.time-rule-num = tt-dis-rule.time-rule-num NO-ERROR.

FOR EACH buf_tt0-term_dis-rule:
    DELETE buf_tt0-term_dis-rule.
END.
run ref/dcr-pos.p (
                   input p-mode
                  ,input no /*p-silent*/
                  ,input p-templ-rl-root
                  ,input tt-dis-rule.host-code
                  ,input tt-dis-rule.obj-type
                  ,input tt-dis-rule.obj-code
                  ,input tt-dis-rule.sts
                  ,input tt-dis-rule.rule-num
                  ,output v-pos-type) no-error.
if error-status:error then do:
message
 error-status:get-message(1) skip
 return-value
 view-as alert-box error .
 undo, return error .
end.
find first buf_dis-cfg-rule no-lock where
          buf_Dis-cfg-rule.pos-type = v-pos-type
      and buf_Dis-cfg-rule.table-name = {&table_dis-thbj-rule}
      and buf_Dis-cfg-rule.link-prop = integer({&dr-rule-ref-object}) no-error.
if available buf_dis-cfg-rule then do:
  assign
  v-ref-dr-templ-rl-root = buf_Dis-cfg-rule.templ-rl-root
  .
end.
else do:
  message
  "Не удается определить типа шаблона для правила по умолчанию"
  view-as alert-box error .
  undo, return error .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-dr-chk Dialog-Frame
PROCEDURE local-dr-chk :
define input parameter p-man    as character no-undo.
define input parameter p-action as character no-undo.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
if p-man = "key#_one" and p-action = "ret-mouse" then do:
   { ref/dr-chk.i key#_one ret-mouse tt-dis-rule v-ref-dr-templ-rl-root  }
end.
if p-man = "key#_one" and p-action = "button" then do:
   { ref/dr-chk.i key#_one button tt-dis-rule v-ref-dr-templ-rl-root  }
end.
if p-man = "key#_one" and p-action = "leave-message" then do:
   { ref/dr-chk.i key#_one leave-message tt-dis-rule v-ref-dr-templ-rl-root  }
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable ii AS INTEGER NO-UNDO.
define variable v-lookup-dtr1 AS CHARACTER NO-UNDO.
define variable v-lookup-dtr2 AS CHARACTER NO-UNDO.
define variable v-dop as character no-undo .
define variable v-entry as character no-undo .
define variable jj as integer no-undo .
DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii         AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-h AS handle NO-UNDO.

v-list-items = "":U + {&comma-char} + "":U.
DO v-ii = 1 TO NUM-ENTRIES({&cd-type-codes-discnt}):
    ASSIGN
    v-list-items = v-list-items +  {&comma-char} +
                   ENTRY(v-ii, {&cd-type-codes-discnt-full}) + {&comma-char} +
                   ENTRY(v-ii, {&cd-type-codes-discnt}).
END.
assign
f-pos-type:list-item-pairs in frame {&frame-name} = v-list-items.

if can-find( first ub.dis-cfg-rule no-lock where
                   ub.dis-cfg-rule.templ-rl-root = p-templ-rl-root
               and ub.dis-cfg-rule.table-name = {&table_dis-thbj-rule})
or p-mode = {&add-def} then do:
  f-pos-type = v-pos-type.
  f-pos-type:VISIBLE IN FRAME {&FRAME-NAME} = YES.
  display f-pos-type
  with frame {&frame-name} .
END.
ASSIGN
v-lookup-dtr1 = IF lookup("time-rule-num":U, v-level-1) > 0 THEN "b-time-rule-lookup"
                ELSE "":U
v-lookup-dtr2 = if lookup("time-rule-num":U, v-level-2) > 0 THEN "b-time-rule-lookup"
                ELSE "":U
v-tab-order = "b-exit,b-quit," + v-lookup-dtr1 +
              "des," + v-lookup-dtr2 +
              "key#_one,b-rule-num,time-rule-num,b-dis-time-rule"
              s-discnt-type:LIST-ITEMS IN FRAME {&FRAME-NAME} = {&discnt-type-list-full}
s-discnt-type:PRIVATE-DATA = {&discnt-type-list}
S-subject-type:LIST-ITEMS = {&discnt-target-list-full}
s-subject-type:PRIVATE-DATA = {&discnt-target-list}
FRAME {&FRAME-NAME}:TITLE = FRAME {&FRAME-NAME}:TITLE + {&space-char} + v-des
f-region = gtregion(tt-dis-rule.host-code, tt-dis-rule.obj-type, tt-dis-rule.obj-code, no)
.

DO ii = 1 TO NUM-ENTRIES({&discnt-v-list}):
    ASSIGN
    tt-dis-rule.value-type:list-item-pairs = (if ii = 1 then "":U else tt-dis-rule.value-type:list-item-pairs) +
                                           (IF ii = 1 THEN "":U ELSE {&comma-char}) +
                                           ENTRY(ii, {&discnt-v-list-full}) + {&comma-char} +
                                           ENTRY(ii, {&discnt-v-list})
    .
END.
RUN display-hide-fields IN THIS-PROCEDURE ( v-tree, YES /*main record*/, 1 /*display*/).

&scop discnt-type-code  string(tt-dis-rule.discnt-type)

assign
s-discnt-type = {&discnt-type-name}
.
&scop discnt-target-code string(tt-dis-rule.subject-type)

ASSIGN
s-subject-type =  {&discnt-target-name}
.

DISPLAY
S-discnt-type
S-subject-type
f-region
WITH FRAME {&frame-name}.
  IF AVAILABLE tt-dis-rule THEN
  DISPLAY
  tt-dis-rule.des
  tt-dis-rule.rule-num
  tt-dis-rule.value-type
  WITH FRAME {&frame-name}.
  ENABLE
  b-quit
  B-exit WHEN p-mode <> {&lookup}
  b-hist when p-mode <> {&add-def}
  B-Help
  tt-dis-rule.des WHEN p-mode <> {&lookup}
  WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
  HIDE
  b-exit
  B-dis-time-rule
  b-dis-rule
  IN FRAME {&FRAME-NAME}.
  ASSIGN
  b-quit:LABEL = "&Выход"
  b-quit:column = 1
.
END.
IF p-mode = {&LOOKUP} THEN APPLY "ENTRY" TO b-exit.
run disrules-override-labels(input p-templ-rl-root) no-error .
{ ref/dr-chk.i key#_one on tt-dis-rule v-ref-dr-templ-rl-root  }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-dis-time-rule Dialog-Frame
PROCEDURE proc-b-dis-time-rule :
define variable v-time-rule-num like ub.dis-rule.time-rule-num no-undo .
DEFINE VARIABLE v-sts AS INTEGER NO-UNDO INIT -1.
DEFINE VARIABLE v-rid-list AS character NO-UNDO  .
DEFINE BUFFER buf_dis-time-rule FOR ub.dis-time-rule .
{ gbl/stdbtn.i }
if input frame {&frame-name} tt-dis-rule.time-rule-num <> 0
and input frame {&frame-name} tt-dis-rule.time-rule-num <> ? then do:
  find first buf_dis-time-rule no-lock where
            buf_dis-time-rule.time-rule-num = input frame {&frame-name} tt-dis-rule.time-rule-num no-error .
  if available buf_dis-time-rule then do:
    assign
    v-rid-list = string(recid(buf_dis-time-rule)).
  end.
end.
/* показываем те, которые могут использоваться*/
run ref/dist-rls.w (
                input parparentproc
              ,input "b-sel,b-add"
              ,input "dis-rule"
              ,input tt-dis-rule.templ-rl-root
              ,input 0
              ,input ''
              ,input-output v-sts
              ,input-output v-rid-list) no-error .
IF v-rid-list = "":U THEN RETURN ERROR.
FIND FIRST buf_dis-time-rule NO-LOCK WHERE
          RECID(buf_dis-time-rule) = INTEGER(ENTRY(1, v-rid-list)) NO-ERROR.
if error-status:error
  then  do:
  return error.
end.
ASSIGN
v-time-rule-num = buf_dis-time-rule.time-rule-num.

find first X_dis-time-rule no-lock where
          X_dis-time-rule.time-rule-num = v-time-rule-num NO-ERROR.
      .
assign
tt-dis-rule.time-rule-num =  X_dis-time-rule.time-rule-num
tt-dis-rule.time-templ-rl-root = X_dis-time-rule.templ-rl-root
.
display
tt-dis-rule.time-rule-num
with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-log AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-dub-rule-num LIKE ub.dis-rule.rule-num NO-UNDO.
if p-mode = {&lookup} then do:
    return error.
end.

if not available tt-dis-rule then do:
    create tt-dis-rule.
end.

assign frame {&frame-name}
tt-dis-rule.des
.


  IF tt-dis-rule.time-rule-num:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.time-rule-num
    .
  else do:
    if lookup("time-rule-num", v-level-1) = 0 then do:
      assign
      tt-dis-rule.time-rule-num = 0
      tt-dis-rule.time-templ-rl-root = 0
      .
    end.
  end.
  IF tt-dis-rule.key#_one:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.key#_one
    .

run ref/diffdisr.p ( input p-mode
              , INPUT TABLE tt-dis-rule
              , INPUT TABLE tt0-term_dis-rule
              , OUTPUT v-dub-rule-num) NO-ERROR.
IF ERROR-STATUS:ERROR
OR v-dub-rule-num <> 0 THEN DO:
   MESSAGE
    substitute("В системе уже существует точно такое же правило скидок (правило № &1)", v-dub-rule-num) SKIP
    "Вы уверены, что хотите создать еще одно такое же правило?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE v-log.
    IF NOT v-log THEN undo, RETURN ERROR.
END.
run ref/dis-rul1.p (
input (IF p-mode = {&ADD-DEF} THEN ? ELSE tt-dis-rule.rule-num )/* p-rule-num */
,input v-pos-type
,input p-templ-rl-root
,input p-templ-rl-root
,input tt-dis-rule.des
,input tt-dis-rule.dis-kat
,input tt-dis-rule.discnt-type
,input tt-dis-rule.doc-qnty
,input tt-dis-rule.tot-sum
,input tt-dis-rule.charkey_one
,input tt-dis-rule.charkey_two
,input tt-dis-rule.charkey_three
,input tt-dis-rule.deckey_one
,input tt-dis-rule.deckey_two
,input tt-dis-rule.deckey_three
,input tt-dis-rule.key#_one
,input tt-dis-rule.key#_two
,input tt-dis-rule.key#_three
,input tt-dis-rule.subject-type
,input tt-dis-rule.time-templ-rl-root
,input tt-dis-rule.time-rule-num
,input tt-dis-rule.upper-rule-num
,input tt-dis-rule.value-type
,input tt-dis-rule.host-code
,INPUT tt-dis-rule.obj-type
,INPUT tt-dis-rule.obj-code
,INPUT tt-dis-rule.discnt-value
,input table tt0-term_dis-rule
,input-output p-recid
,input p-mode
,input NO /*p-silent */
) NO-ERROR.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-time-rule-lookup Dialog-Frame
PROCEDURE proc-time-rule-lookup :
DEFINE INPUT PARAMETER p-tree AS CHARACTER NO-UNDO.
DEFINE VARIABLE loc-doc-rec AS RECID NO-UNDO.
IF lookup("time-rule-num", v-level-1) > 0
or lookup("time-rule-num", v-level-2) > 0
tHEN DO:
  IF lookup("time-rule-num":U, v-level-1) > 0 THEN DO:
        run ref/dis-timi.w (
                   input parParentProc
                  ,input {&lookup}
                  ,input 0 /*p-templ-rl-root*/
                  ,input tt-dis-rule.time-rule-num
                  ,input 0 /*p-upper-time-rule-num*/
                  ,input-output loc-doc-rec
                  ) no-error .
  END.
  ELSE DO:
   IF AVAILABLE tt0-term_dis-rule THEN DO:
     run ref/dis-timi.w (
                   input parParentProc
                  ,input {&lookup}
                  ,input 0 /*p-templ-rl-root*/
                  ,input tt0-term_dis-rule.time-rule-num
                  ,input 0 /*p-upper-time-rule-num*/
                  ,input-output loc-doc-rec
                  ) no-error .
    END.
  END.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME