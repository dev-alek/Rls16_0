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
DEFINE TEMP-TABLE tt-dis-rule NO-UNDO LIKE ub.dis-rule.
DEFINE TEMP-TABLE tt0-term_dis-rule NO-UNDO LIKE ub.dis-rule.
DEFINE BUFFER X_dis-time-rule FOR ub.dis-time-rule.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование правил скидок - временная скидка, задаваемая через ТПЛ

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
define variable vss-description as character no-undo init "Редактирование правил скидок - временная скидка, задаваемая через ТПЛ".
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
define variable  v-term-value-type   like ub.dis-rule.value-type        no-undo .
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
DEFINE VARIABLE v-doc-num LIKE ub.price-list.doc-num NO-UNDO.
DEFINE VARIABLE v-road-tax LIKE ub.price-list.road-tax NO-UNDO.
DEFINE VARIABLE v-excise LIKE ub.price-list.excise NO-UNDO.
define variable v-doc-rec as recid no-undo .
define variable v-radio-integer-handle as handle no-undo .
define variable v-pos-type as character no-undo .
define variable v-is-copy as logical no-undo .
define variable v-start-br-term-dr-format as logical no-undo init yes.

DEFINE BUFFER X_sysconf FOR ub.sysconf.
DEFINE BUFFER X_cli-obj FOR ub.clients.
DEFINE BUFFER buf_dis-time-rule FOR ub.dis-time-rule.
define buffer buf_temp-drt-prop for temp-drt-prop.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-term-dr

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt0-term_dis-rule tt-dis-rule ~
locked_dis-rule

/* Definitions for BROWSE BR-term-dr                                    */
&Scoped-define FIELDS-IN-QUERY-BR-term-dr entry (lookup (string(tt0-term_dis-rule.value-type), {&discnt-v-list}), {&discnt-v-list-full}) tt0-term_dis-rule.time-rule-num tt0-term_dis-rule.charkey_one tt0-term_dis-rule.des tt0-term_dis-rule.rule-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-term-dr
&Scoped-define SELF-NAME BR-term-dr
&Scoped-define QUERY-STRING-BR-term-dr FOR EACH tt0-term_dis-rule OF ub.tt-dis-rule NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-term-dr OPEN QUERY {&SELF-NAME} FOR EACH tt0-term_dis-rule OF ub.tt-dis-rule NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-term-dr tt0-term_dis-rule
&Scoped-define FIRST-TABLE-IN-QUERY-BR-term-dr tt0-term_dis-rule


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-dis-rule.des ~
tt-dis-rule.value-type tt-dis-rule.time-rule-num tt-dis-rule.CharKey_One ~
tt-dis-rule.rule-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-dis-rule.des ~
tt-dis-rule.value-type tt-dis-rule.time-rule-num tt-dis-rule.CharKey_One ~
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
tt-dis-rule.time-rule-num tt-dis-rule.CharKey_One tt-dis-rule.rule-num
&Scoped-define ENABLED-TABLES tt-dis-rule
&Scoped-define FIRST-ENABLED-TABLE tt-dis-rule
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-hist B-Help f-pos-type B-plt ~
B-dis-time-rule B-exit-1 B-quit-1 B-add B-del b-plt-lookup ~
B-time-rule-lookup BR-term-dr F-region
&Scoped-Define DISPLAYED-FIELDS tt-dis-rule.des tt-dis-rule.value-type ~
tt-dis-rule.time-rule-num tt-dis-rule.CharKey_One tt-dis-rule.rule-num
&Scoped-define DISPLAYED-TABLES tt-dis-rule
&Scoped-define FIRST-DISPLAYED-TABLE tt-dis-rule
&Scoped-Define DISPLAYED-OBJECTS s-discnt-type f-pos-type s-subject-type ~
charkey_one-name F-region

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

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

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

DEFINE BUTTON B-exit-1
     LABEL "Ввод"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON B-plt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON b-plt-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit-1
     LABEL "Отмена"
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

DEFINE VARIABLE charkey_one-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 96.5 BY 1 NO-UNDO.

DEFINE VARIABLE F-region AS CHARACTER FORMAT "X(256)":U
     LABEL "Действует"
      VIEW-AS TEXT
     SIZE 22.5 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-term-dr FOR
      tt0-term_dis-rule SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      tt-dis-rule,
      locked_dis-rule SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-term-dr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-term-dr Dialog-Frame _FREEFORM
  QUERY BR-term-dr NO-LOCK DISPLAY
      entry (lookup (string(tt0-term_dis-rule.value-type), {&discnt-v-list}), {&discnt-v-list-full}) COLUMN-LABEL "Тип" FORMAT "X(10)":U
tt0-term_dis-rule.time-rule-num FORMAT "->>>>>>>>9":U
tt0-term_dis-rule.charkey_one FORMAT "X(12)":U
tt0-term_dis-rule.des FORMAT "X(255)":U
tt0-term_dis-rule.rule-num FORMAT ">>>>>>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 56.5 BY 13.29
         FONT 4
         TITLE "Детализация" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
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
     s-discnt-type AT ROW 3.92 COL 14 COLON-ALIGNED
     f-pos-type AT ROW 3.92 COL 46 COLON-ALIGNED WIDGET-ID 6
     s-subject-type AT ROW 4.92 COL 14 COLON-ALIGNED
     B-plt AT ROW 5.92 COL 50.5 WIDGET-ID 16
     tt-dis-rule.time-rule-num AT ROW 5.92 COL 65.5 COLON-ALIGNED
          LABEL "№ расп."
          VIEW-AS FILL-IN
          SIZE 8 BY 1
     B-dis-time-rule AT ROW 5.92 COL 76
     tt-dis-rule.CharKey_One AT ROW 6 COL 31 COLON-ALIGNED WIDGET-ID 8
          LABEL "Поле1"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     charkey_one-name AT ROW 6.92 COL 2.5 NO-LABEL WIDGET-ID 12
     B-exit-1 AT ROW 7.92 COL 22
     B-quit-1 AT ROW 7.92 COL 32
     B-add AT ROW 7.92 COL 59
     B-del AT ROW 7.92 COL 69
     b-plt-lookup AT ROW 7.92 COL 79 WIDGET-ID 18
     B-time-rule-lookup AT ROW 7.92 COL 89
     BR-term-dr AT ROW 8.92 COL 42.5
     tt-dis-rule.rule-num AT ROW 1.25 COL 71.5 COLON-ALIGNED
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
      TABLE: tt-dis-rule T "?" NO-UNDO ub dis-rule
      TABLE: tt0-term_dis-rule T "?" NO-UNDO ub dis-rule
      TABLE: X_dis-time-rule B "?" ? ub dis-time-rule
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-term-dr B-time-rule-lookup Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-add:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-del:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-dis-time-rule:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-exit-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-plt:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-quit-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-time-rule-lookup:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-rule.CharKey_One IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-rule.CharKey_One:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN charkey_one-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
ASSIGN
       charkey_one-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-rule.des IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-term-dr
/* Query rebuild information for BROWSE BR-term-dr
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt0-term_dis-rule OF ub.tt-dis-rule NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-term-dr */
&ANALYZE-RESUME

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


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  { gbl/stdbtn.i }
  IF b-exit-1:VISIBLE IN FRAME {&FRAME-NAME} THEN DO:
      BELL.
      RETURN NO-APPLY.
  END.
  RUN proc-b-add IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
      RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
{ gbl/stdbtn.i }
IF b-exit-1:VISIBLE IN FRAME {&FRAME-NAME} THEN DO:
    BELL.
    RETURN NO-APPLY.
END.

  RUN proc-b-del IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
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


&Scoped-define SELF-NAME B-exit-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit-1 Dialog-Frame
ON CHOOSE OF B-exit-1 IN FRAME Dialog-Frame /* Ввод */
DO:
    { gbl/stdbtn.i }
  RUN proc-b-exit-1 IN THIS-PROCEDURE NO-ERROR.
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


&Scoped-define SELF-NAME B-plt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-plt Dialog-Frame
ON CHOOSE OF B-plt IN FRAME Dialog-Frame
DO:

 DEFINE VARIABLE v-charkey_one AS CHARACTER NO-UNDO.
 DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
 DEFINE BUFFER local_price-list-type FOR ub.price-list-type.
 DEFINE BUFFER local2_price-list-type FOR ub.price-list-type.
 IF AVAILABLE tt0-term_dis-rule
 and tt0-term_dis-rule.charkey_one <> '' then do:
    find first local_price-list-type no-lock where
              local_price-list-type.plt-id = integer(entry(1, tt0-term_dis-rule.charkey_one, "-") )
          and local_price-list-type.plt-db-num = integer(entry(2, tt0-term_dis-rule.charkey_one, "-") ) no-error.
    if available local_price-list-type then do:
      v-rid-list = STRING(RECID(local_price-list-type)).
      charkey_one-name =     local_price-list-type.NAME .
      display
      tt0-term_dis-rule.charkey_one @ tt-dis-rule.charkey_one
      charkey_one-name
      with frame {&frame-name} .
    end.
 END.
 v-rid-list = string(p-templ-rl-root).
 run ref/typepric.w (
                      input  parParentProc
                     ,INPUT "b-sel,mode=ban-discnt"
                     ,INPUT-OUTPUT v-rid-list ) NO-ERROR.
IF error-status:error 
or v-rid-list = ""
THEN RETURN NO-APPLY.
 IF (available local_price-list-type and v-rid-list <> string(p-templ-rl-root))
 or not available local_price-list-type
 THEN DO:
     FIND FIRST local2_price-list-type NO-LOCK WHERE
                recid(local2_price-list-type) = INTEGER(v-rid-list) NO-ERROR.
    IF AVAILABLE local2_price-list-type THEN DO:
        ASSIGN
        tt-dis-rule.charkey_one = SUBSTITUTE("&1-&2"
                                             , local2_price-list-type.plt-id
                                             , local2_price-list-type.plt-db-num)
        charkey_one-name =     local2_price-list-type.NAME
        .

        DISPLAY
        tt-dis-rule.charkey_one
        charkey_one-name
        WITH FRAME {&FRAME-NAME}.
    END.
    ELSE DO:
        MESSAGE
        substitute("Не удалось найти ТПЛ с recid=&1", v-rid-list)
        VIEW-AS ALERT-BOX ERROR.

    END.
 END.
 apply "entry" to tt-dis-rule.charkey_one in FRAME {&FRAME-NAME}.
 return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-plt-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-plt-lookup Dialog-Frame
ON CHOOSE OF b-plt-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
DEFINE VARIABLE v-recid AS RECID NO-UNDO.
define buffer loc_price-list-type for ub.price-list-type.
  IF AVAILABLE tt0-term_dis-rule then do:
    if tt0-term_dis-rule.charkey_one <> '' then do:
        find first loc_price-list-type where
                  loc_price-list-type.plt-id = integer(entry(1, tt0-term_dis-rule.charkey_one, "-"))
               and loc_price-list-type.plt-db-num = integer(entry(2, tt0-term_dis-rule.charkey_one, "-")) no-error.
        if available loc_price-list-type then do:
            v-recid = RECID(loc_price-list-type).
            run ref/tp-price.w ( input parparentproc
                              ,input NO /*p-main-price*/
                              ,INPUT {&LOOKUP}
                               ,INPUT-OUTPUT v-recid ) NO-ERROR.
        end.
        ELSE DO:
           MESSAGE
           "Тип прайс-листа не определен, возможно удален"
           VIEW-AS ALERT-BOX ERROR.
         END.

    end.
    ELSE DO:
      MESSAGE
      "Тип прайс-листа не определен"
      VIEW-AS ALERT-BOX ERROR.
    END.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-quit-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-quit-1 Dialog-Frame
ON CHOOSE OF B-quit-1 IN FRAME Dialog-Frame /* Отмена */
DO:
  { gbl/stdbtn.i }
  RUN proc-b-quit-1 IN THIS-PROCEDURE.
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


&Scoped-define BROWSE-NAME BR-term-dr
&Scoped-define SELF-NAME BR-term-dr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-term-dr Dialog-Frame
ON VALUE-CHANGED OF BR-term-dr IN FRAME Dialog-Frame /* Детализация */
DO:
  IF AVAILABLE tt0-term_dis-rule
  AND tt0-term_dis-rule.time-rule-num > 0
  AND lookup("time-rule-num", v-level-2) > 0 THEN DO:
     ENABLE
     b-time-rule-lookup
     WITH FRAME {&FRAME-NAME}.
  END.
  if available tt0-term_dis-rule then do:
    assign
    v-term-value-type = tt0-term_dis-rule.value-type.
  end.
  else do:
    assign
    v-term-value-type = v-value-type.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-dis-rule.time-rule-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-dis-rule.time-rule-num Dialog-Frame
ON LEAVE OF tt-dis-rule.time-rule-num IN FRAME Dialog-Frame /* № расп. */
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
{ gbl/disrules.i "interface" }


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
  v-term-value-type = v-value-type.
  run disrules-fill-properties in this-procedure ( input p-templ-rl-root).
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
    IF p-main THEN DO:
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
      IF lookup("charkey_one":U, v-level-1) > 0 THEN DO:
         DISPLAY
         tt-dis-rule.charkey_one
         WITH FRAME {&FRAME-NAME}.
         ENABLE
         tt-dis-rule.charkey_one WHEN p-mode <> {&LOOKUP}
         WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.charkey_one
        in FRAME {&FRAME-NAME}.
      end.
      /*
      IF lookup("time-rule-num":U, v-level-1) > 0  THEN DO:
          ASSIGN
          b-time-rule-lookup:ROW = b-add:ROW
          b-time-rule-lookup:column = b-add:COLUMN + 20
          .
          DISPLAY
          b-time-rule-lookup
          WITH FRAME {&FRAME-NAME}.
          ENABLE
          b-time-rule-LOOKUP
          WITH FRAME {&FRAME-NAME}.

      END.
    END.  */
    END. /*p-main = 1*/
    ELSE DO: /*p-main = 0*/
      IF lookup("time-rule-num", v-level-2) > 0 THEN DO:
        view
        tt-dis-rule.time-rule-num
        b-dis-time-rule
        in FRAME {&FRAME-NAME}.
        ENABLE
        tt-dis-rule.time-rule-num WHEN p-mode <> {&LOOKUP}
        b-dis-time-rule WHEN p-mode <> {&LOOKUP}
        B-time-rule-lookup
        WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.time-rule-num
        b-dis-time-rule
        B-time-rule-lookup
        in FRAME {&FRAME-NAME}.
      end.
      IF lookup("charkey_one", v-level-2) > 0 THEN DO:
        view
        tt-dis-rule.charkey_one
        in FRAME {&FRAME-NAME}.
        ENABLE
        tt-dis-rule.charkey_one WHEN p-mode <> {&LOOKUP}
        WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.charkey_one
        in FRAME {&FRAME-NAME}.
      end.
    END. /*p-main = 0*/
  END. /*when 1 = display*/
  WHEN 0 THEN DO:
    HIDE
    tt-dis-rule.charkey_one
    tt-dis-rule.time-rule-num
    b-time-rule-lookup
    b-dis-time-rule
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
  DISPLAY s-discnt-type f-pos-type s-subject-type charkey_one-name F-region
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-dis-rule THEN
    DISPLAY tt-dis-rule.des tt-dis-rule.value-type tt-dis-rule.time-rule-num
          tt-dis-rule.CharKey_One tt-dis-rule.rule-num
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-hist B-Help tt-dis-rule.des tt-dis-rule.value-type
         f-pos-type B-plt tt-dis-rule.time-rule-num B-dis-time-rule
         tt-dis-rule.CharKey_One B-exit-1 B-quit-1 B-add B-del b-plt-lookup
         B-time-rule-lookup BR-term-dr tt-dis-rule.rule-num F-region
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
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
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
  undo,  return error.
end.
assign
v-dis-kat-tree   = lookup("dis-kat":U, v-tree) > 0
v-doc-qnty-tree  = lookup("doc-qnty":U, v-tree) > 0
v-tot-sum-tree   = lookup("tot-sum":U,  v-tree) > 0
v-time-rule-num-tree = lookup("time-rule-num":U, v-tree) > 0
v-charkey_one-tree = lookup("charkey_one":U, v-tree) > 0
v-charkey_two-tree = lookup("charkey_two":U, v-tree) > 0
v-charkey_three-tree = lookup("charkey_three":U, v-tree) > 0
v-deckey_one-tree = lookup("deckey_one":U, v-tree) > 0
v-deckey_two-tree = lookup("deckey_two":U, v-tree) > 0
v-deckey_three-tree = lookup("deckey_three":U, v-tree) > 0
v-key#_one-tree = lookup("key#_one":U, v-tree) > 0
v-key#_two-tree = lookup("key#_two":U, v-tree) > 0
v-key#_three-tree = lookup("key_#three":U, v-tree) > 0
.


v-ii = 0.
if tt-dis-rule.is-term = no then do:
  FOR EACH buf_dis-rule NO-LOCK WHERE
          buf_dis-rule.upper-rule-num = (if v-is-copy then p-rule-num else tt-dis-rule.rule-num):
    v-ii = v-ii + 1.
    CREATE buf_tt0-term_dis-rule.
    BUFFER-COPY buf_dis-rule
    except rule-num upper-rule-num
    TO buf_tt0-term_dis-rule
    ASSIGN
    buf_tt0-term_dis-rule.rule-num = (if v-is-copy then v-ii else buf_dis-rule.rule-num)
    buf_tt0-term_dis-rule.upper-rule-num = (if v-is-copy then abs(tt-dis-rule.rule-num) else buf_dis-rule.upper-rule-num)
    buf_tt0-term_dis-rule.doc-qnty = (IF lookup("discnt-value":U, v-level-2) = 0
                                      THEN 0
                                      ELSE buf_dis-rule.discnt-value)
    buf_tt0-term_dis-rule.doc-qnty = (IF lookup("doc-qnty":U, v-level-2) = 0
                                      THEN 0
                                      ELSE buf_dis-rule.doc-qnty)
    buf_tt0-term_dis-rule.dis-kat = (IF lookup("dis-kat":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.dis-kat)
    buf_tt0-term_dis-rule.tot-sum = (IF lookup("tot-sum":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.tot-sum)
    buf_tt0-term_dis-rule.time-rule-num = (IF lookup("time-rule-num":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.time-rule-num)
    buf_tt0-term_dis-rule.charkey_one = (IF lookup("charkey_one":U, v-level-2) = 0
                                          THEN "":U
                                          ELSE buf_dis-rule.charkey_one)
    buf_tt0-term_dis-rule.charkey_two = (IF lookup("charkey_two":U, v-level-2) = 0
                                          THEN "":U
                                          ELSE buf_dis-rule.charkey_two)
    buf_tt0-term_dis-rule.charkey_three = (IF lookup("charkey_three":U, v-level-2) = 0
                                          THEN "":U
                                          ELSE buf_dis-rule.charkey_three)
    buf_tt0-term_dis-rule.deckey_one = (IF lookup("deckey_one":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.deckey_one)
    buf_tt0-term_dis-rule.deckey_two = (IF lookup("deckey_two":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.deckey_two)
    buf_tt0-term_dis-rule.deckey_three = (IF lookup("deckey_three":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.deckey_three)
    buf_tt0-term_dis-rule.key#_one = (IF lookup("key#_one":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.key#_one)
    buf_tt0-term_dis-rule.key#_two = (IF lookup("key#_two":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.key#_two)
    buf_tt0-term_dis-rule.key#_three = (IF lookup("key#_three":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.key#_three)
    .
  END.
end.
else do:
  FOR EACH buf_dis-rule NO-LOCK WHERE
          buf_dis-rule.rule-num = (if v-is-copy then p-rule-num else tt-dis-rule.rule-num):
    leave.
  end.
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
define buffer buf_temp-drt-prop for temp-drt-prop.

v-h = br-term-dr:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
DO while valid-handle(v-h) :
  find first buf_temp-drt-prop no-lock where
            buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
        and buf_temp-drt-prop.upper-prop-code = v-h:name
        and buf_temp-drt-prop.prop-code = "column-label" no-error.
  if available buf_temp-drt-prop then do:
    assign
    v-h:label = buf_temp-drt-prop.property-value.
  end.
  if v-h:LABEL = "Тип" then do:
    v-h:RESIZABLE = YES.
    v-h:visible = (v-value-type = integer({&discnt-v-hybrid1})).
  end.
  /*
  find first buf_temp-drt-prop no-lock where
            buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
        and buf_temp-drt-prop.upper-prop-code = v-h:name
        and buf_temp-drt-prop.prop-code = "format":U no-error.
  if available buf_temp-drt-prop then do:
    assign
    v-h:format = buf_temp-drt-prop.property-value.
  end.
  */
  v-h = v-h:NEXT-COLUMN.

END.

v-list-items = "":U + {&comma-char} + "":U.
DO v-ii = 1 TO NUM-ENTRIES({&cd-type-codes-discnt}):
    ASSIGN
    v-list-items = v-list-items +  {&comma-char} +
                   ENTRY(v-ii, {&cd-type-codes-discnt-full}) + {&comma-char} +
                   ENTRY(v-ii, {&cd-type-codes-discnt}).
END.
assign
f-pos-type:list-item-pairs in frame {&frame-name} = v-list-items.

ASSIGN
tt0-term_dis-rule.time-rule-num:VISIBLE IN BROWSE BR-term-dr = FALSE
tt0-term_dis-rule.charkey_one:VISIBLE IN BROWSE BR-term-dr = FALSE
tt0-term_dis-rule.time-rule-num:auto-resize IN BROWSE BR-term-dr = true
tt0-term_dis-rule.charkey_one:auto-resize IN BROWSE BR-term-dr = true
.
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
              "des,b-add,b-del," + v-lookup-dtr2 +
              "time-rule-num,b-dis-time-rule,"  +
              "charkey_one," +
              "b-exit-1,b-quit-1"
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
IF v-tree = "":U THEN DO:
  HIDE
  br-term-dr
  b-exit-1
  b-quit-1
  b-add
  b-del
  in FRAME {&FRAME-NAME}.
END.
ELSE DO:
    DO ii = 1 TO NUM-ENTRIES(v-level-2):
      case ENTRY(ii, v-level-2):
        WHEN "time-rule-num":U THEN DO:
          ASSIGN
          tt0-term_dis-rule.time-rule-num:VISIBLE IN BROWSE br-term-dr = YES
          .
        END.
        WHEN "charkey_one":U THEN DO:
          ASSIGN
          tt0-term_dis-rule.charkey_one:VISIBLE IN BROWSE br-term-dr = YES
          .
        END.
      END CASE.
    END. /*do ii*/
    ENABLE
    b-add WHEN p-mode <> {&LOOKUP}
    b-DEL WHEN p-mode <> {&LOOKUP}
    b-plt-lookup
    WITH FRAME {&FRAME-NAME}.
END.

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
  /*
  DISPLAY
  tt-dis-rule.time-rule-num WHEN  tt-dis-rule.time-rule-num <> 0
  WITH FRAME {&frame-name}.
  */
  ENABLE
  b-quit
  B-exit WHEN p-mode <> {&lookup}
  b-hist when p-mode <> {&add-def}
  B-Help
  tt-dis-rule.des WHEN p-mode <> {&lookup}
  WITH FRAME {&frame-name}.
  /*
  ENABLE
  tt-dis-rule.time-rule-num WHEN p-mode <> {&LOOKUP} AND tt-dis-rule.time-rule-num <> 0
  B-dis-time-rule WHEN p-mode <> {&LOOKUP} AND tt-dis-rule.time-rule-num <>  0
  WITH FRAME {&frame-name}.
  */
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
  HIDE
  b-exit
  B-dis-time-rule IN FRAME {&FRAME-NAME}.
  ASSIGN
  b-quit:LABEL = "&Выход"
  b-quit:column = 1
  .
END.
IF v-tree <> "":u THEN DO:
  ENABLE
  br-term-dr
  WITH FRAME {&FRAME-NAME}.
  RUN openbr-term-dr in this-procedure .
  APPLY "VALUE-CHANGED" TO br-term-dr IN FRAME {&FRAME-NAME}.
END.
IF p-mode = {&LOOKUP} THEN APPLY "ENTRY" TO b-exit.

ELSE do:
  IF v-tree <> "":U THEN
  APPLY "entry" to b-add.
END.
run disrules-override-labels(input p-templ-rl-root) no-error .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr-term-dr Dialog-Frame
PROCEDURE OpenBr-term-dr :
define variable v-h as widget-handle no-undo .
v-h = br-term-dr:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
OPEN QUERY BR-term-dr
  FOR  EACH tt0-term_dis-rule WHERE
          tt0-term_dis-rule.upper-rule-num = tt-dis-rule.rule-num
BY tt0-term_dis-rule.time-rule-num
.

if available tt0-term_dis-rule
and v-start-br-term-dr-format
then do:
  v-start-br-term-dr-format = no.
  DO while valid-handle(v-h) :
    find first buf_temp-drt-prop no-lock where
              buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
          and buf_temp-drt-prop.upper-prop-code = v-h:name
          and buf_temp-drt-prop.prop-code = "format":U no-error.
    if available buf_temp-drt-prop then do:
      assign
      v-h:format = buf_temp-drt-prop.property-value.
    end.
    v-h = v-h:NEXT-COLUMN.
  END.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
define variable choice as integer no-undo .
IF v-tree = "":U THEN RETURN ERROR.
IF tt-dis-rule.time-rule-num:SENSITIVE IN FRAME {&FRAME-NAME} THEN
ASSIGN
tt-dis-rule.time-rule-num
.
IF tt-dis-rule.charkey_one:SENSITIVE IN FRAME {&FRAME-NAME} THEN
ASSIGN
tt-dis-rule.charkey_one
.
RUN display-hide-fields IN THIS-PROCEDURE ( v-tree, NO /*main record*/, 1 /*display*/).
IF v-time-rule-num-tree
AND tt-dis-rule.time-rule-num:sensitive  IN FRAME {&FRAME-NAME} THEN DO:
   DISPLAY
   0 @ tt-dis-rule.time-rule-num
   WITH FRAME {&FRAME-NAME}.
END.
IF v-charkey_one-tree
AND tt-dis-rule.charkey_one:sensitive  IN FRAME {&FRAME-NAME} THEN DO:
   DISPLAY
   '':U @ tt-dis-rule.charkey_one
   WITH FRAME {&FRAME-NAME}.
END.
ENABLE
b-exit-1
b-quit-1
b-plt
WITH FRAME {&FRAME-NAME}.
hide
b-add
b-del
b-plt-lookup
in frame {&frame-name}.
disable
b-exit
with frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
DEFINE BUFFER buf_tt0-term_dis-rule FOR tt0-term_dis-rule.
IF v-tree = "":U THEN RETURN ERROR.
IF NOT AVAILABLE tt0-term_dis-rule THEN RETURN.
FIND first buf_tt0-term_dis-rule WHERE RECID(buf_tt0-term_dis-rule) = RECID(tt0-term_dis-rule).
DELETE buf_tt0-term_dis-rule.
RUN rename-term_dis-rule in this-procedure .
RUN openbr-term-dr in this-procedure .
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
              ,input ( if p-mode = {&add-def} or not available buf_dis-time-rule then {&table_dis-rule} else ("rule-num" + {&comma-char} + {&update}))
              ,input (if p-mode = {&add-def} or not available buf_dis-time-rule then tt-dis-rule.templ-rl-root else tt-dis-rule.rule-num)
              ,input ( if p-mode = {&add-def} or not available buf_dis-time-rule then 0 else tt-dis-rule.time-templ-rl-root)
              ,input p-pos-type
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-exit-1 Dialog-Frame
PROCEDURE proc-b-exit-1 :
DEFINE VARIABLE v-doc-qnty LIKE ub.dis-rule.doc-qnty NO-UNDO.
DEFINE VARIABLE v-dis-kat LIKE ub.dis-rule.dis-kat NO-UNDO.
DEFINE VARIABLE v-tot-sum LIKE ub.dis-rule.tot-sum NO-UNDO.
DEFINE VARIABLE v-time-rule-num LIKE ub.dis-rule.time-rule-num NO-UNDO.
define variable v-charkey_one like ub.dis-rule.charkey_one no-undo .
define variable v-charkey_two like ub.dis-rule.charkey_two no-undo .
define variable v-charkey_three like ub.dis-rule.charkey_three no-undo .
define variable v-deckey_one like ub.dis-rule.deckey_one no-undo .
define variable v-deckey_two like ub.dis-rule.deckey_two no-undo .
define variable v-deckey_three like ub.dis-rule.deckey_three no-undo .
define variable v-key#_one like ub.dis-rule.key#_one no-undo .
define variable v-key#_two like ub.dis-rule.key#_two no-undo .
define variable v-key#_three like ub.dis-rule.key#_three no-undo .
DEFINE VARIABLE v-discnt-value LIKE ub.dis-rule.discnt-value NO-UNDO.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-rule-num LIKE ub.dis-rule.rule-num NO-UNDO.

DEFINE VARIABLE v-dub AS LOGICAL NO-UNDO.
DEFINE BUFFER buf_tt0-term_dis-rule FOR tt0-term_dis-rule.
IF v-tree = "":U  THEN RETURN ERROR.
/*проверим что такого нет*/
ASSIGN
v-doc-qnty = tt-dis-rule.doc-qnty
v-dis-kat = tt-dis-rule.dis-kat
v-tot-sum = tt-dis-rule.tot-sum
v-time-rule-num = tt-dis-rule.time-rule-num
v-charkey_one = tt-dis-rule.charkey_one
v-charkey_two = tt-dis-rule.charkey_two
v-charkey_three = tt-dis-rule.charkey_three
v-deckey_one = tt-dis-rule.deckey_one
v-deckey_two = tt-dis-rule.deckey_two
v-deckey_three = tt-dis-rule.deckey_three
v-key#_one = tt-dis-rule.key#_one
v-key#_two = tt-dis-rule.key#_two
v-key#_three = tt-dis-rule.key#_three
.


IF tt-dis-rule.time-rule-num:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  v-time-rule-num = INPUT FRAME {&frame-name} tt-dis-rule.time-rule-num
  .
END.
IF tt-dis-rule.charkey_one:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  v-charkey_one = INPUT FRAME {&frame-name} tt-dis-rule.charkey_one
  .
END.
define variable v-entry-entry as character no-undo .
define variable v-entry as character no-undo .
define variable v-entry-list as character no-undo .
define variable v-new-entry as character no-undo .
define variable nn as integer no-undo .
do nn = 1 to num-entries(v-tree):
  v-entry-entry = '':U.
  case entry(nn, v-tree):
    when "time-rule-num" then do:
      if v-time-rule-num <> -1
      then do:
        v-entry-entry = string(v-time-rule-num).
      end.
    end.
    when "charkey_one" then do:
      if v-charkey_one <> ?
      then do:
        v-entry-entry = string(v-charkey_one).
      end.
    end.
  end case.
  v-new-entry = v-new-entry +
            (if v-new-entry = '':U then "" else {&delim-par}) + v-entry-entry.
end.

_dub:
FOR EACH buf_tt0-term_dis-rule WHERE
        buf_tt0-term_dis-rule.upper-rule-num = tt-dis-rule.rule-num:
  ASSIGN
  v-rule-num = max(buf_tt0-term_dis-rule.rule-num, v-rule-num)
  .
  v-entry = '':U.

  do nn = 1 to num-entries(v-tree):
    assign
    v-entry-entry = string(buffer buf_tt0-term_dis-rule:buffer-field(entry(nn, v-tree)):buffer-value)
    .
    assign
    v-entry = v-entry +
              (if v-entry = '':U then "" else {&delim-par}) + v-entry-entry.
    v-entry-list = v-entry-list + (if v-entry-list = '':U then "" else {&delim-key}) + v-entry.
    if lookup(v-new-entry, v-entry-list, {&delim-key}) > 0 then do:
      assign
      v-dub = yes
      .
      MESSAGE
      substitute("Уже есть такое подправило с той же областью действия или параметрами")
      VIEW-AS ALERT-BOX.
      LEAVE _dub.
    end.
  end.
END.
IF v-dub THEN UNDO, RETURN ERROR.
CREATE buf_tt0-term_dis-rule.
BUFFER-COPY tt-dis-rule
EXCEPT rule-num
    upper-rule-num des
    lvl-num
    is-term
    root
TO buf_tt0-term_dis-rule
ASSIGN
buf_tt0-term_dis-rule.rule-num = v-rule-num + 1
buf_tt0-term_dis-rule.upper-rule-num = tt-dis-rule.rule-num
buf_tt0-term_dis-rule.doc-qnty = (IF v-doc-qnty = - 1 THEN 0 ELSE v-doc-qnty)
buf_tt0-term_dis-rule.dis-kat = (IF v-dis-kat = - 1 THEN 0 ELSE v-dis-kat)
buf_tt0-term_dis-rule.tot-sum = (IF v-tot-sum = -1 THEN 0 ELSE v-tot-sum)
buf_tt0-term_dis-rule.time-rule-num = (IF v-time-rule-num = 0 THEN 0 ELSE v-time-rule-num)
buf_tt0-term_dis-rule.key#_one = (IF v-key#_one = ? THEN 0 ELSE v-key#_one)
buf_tt0-term_dis-rule.key#_two = (IF v-key#_two = ? THEN 0 ELSE v-key#_two)
buf_tt0-term_dis-rule.key#_three = (IF v-key#_three = ? THEN 0 ELSE v-key#_three)
buf_tt0-term_dis-rule.charkey_one = (IF v-charkey_one = ? THEN "":U ELSE v-charkey_one)
buf_tt0-term_dis-rule.charkey_two = (IF v-charkey_two = ? THEN "":U ELSE v-charkey_two)
buf_tt0-term_dis-rule.charkey_three = (IF v-charkey_three = ? THEN "":U ELSE v-charkey_three)
buf_tt0-term_dis-rule.deckey_one = (IF v-deckey_one = ? THEN 0 ELSE v-deckey_one)
buf_tt0-term_dis-rule.deckey_two = (IF v-deckey_two = ? THEN 0 ELSE v-deckey_two)
buf_tt0-term_dis-rule.deckey_three = (IF v-deckey_three = ? THEN 0 ELSE v-deckey_three)
buf_tt0-term_dis-rule.discnt-value = v-discnt-value
buf_tt0-term_dis-rule.sts   = INTEGER({&non-root-status-int})
buf_tt0-term_dis-rule.root   = no
buf_tt0-term_dis-rule.is-term   = yes
buf_tt0-term_dis-rule.lvl-num   = tt-dis-rule.lvl-num + 1
buf_tt0-term_dis-rule.value-type = v-term-value-type
.
RELEASE buf_tt0-term_dis-rule.
RUN display-hide-fields IN THIS-PROCEDURE(v-tree, NO, 0).


HIDE
b-exit-1
IN FRAME {&FRAME-NAME}
b-quit-1
b-plt
charkey_one-name
IN FRAME {&FRAME-NAME}.
display
b-add when p-mode <> {&lookup}
b-del when p-mode <> {&lookup}
b-plt-lookup
b-time-rule-lookup
with frame {&frame-name}.

RUN rename-term_dis-rule in this-procedure .
RUN openbr-term-dr in this-procedure .
RUN display-hide-fields IN THIS-PROCEDURE(v-tree, yes, 1).
if p-mode <> {&lookup}
then
enable
b-exit
with frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-quit-1 Dialog-Frame
PROCEDURE proc-b-quit-1 :
RUN display-hide-fields IN THIS-PROCEDURE ( v-tree, NO /*main record*/, 0 /*display*/).

HIDE
b-exit-1
IN FRAME {&FRAME-NAME}
b-quit-1
b-plt
charkey_one-name
IN FRAME {&FRAME-NAME}.
display
b-add when p-mode <> {&lookup}
b-del when p-mode <> {&lookup}
b-plt-lookup
b-time-rule-lookup
with frame {&frame-name}.

if p-mode <> {&lookup}
then
enable
b-exit
with frame {&frame-name} .

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
IF v-tree = "":U THEN DO:
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
  IF tt-dis-rule.charkey_one:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.charkey_one
    .
END.
ELSE DO:
  IF tt-dis-rule.time-rule-num:VISIBLE  IN FRAME {&FRAME-NAME} THEN do:
    ASSIGN
    tt-dis-rule.time-rule-num
    .
  end.
  else do:
    if lookup("time-rule-num", v-level-1) = 0 then do:
      assign
      tt-dis-rule.time-rule-num = 0
      tt-dis-rule.time-templ-rl-root = 0
      .
    end.
  end.
  IF tt-dis-rule.charkey_one:VISIBLE  IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.charkey_one
    .
  ASSIGN
  tt-dis-rule.discnt-value = 0
  .
END.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rename-term_dis-rule Dialog-Frame
PROCEDURE rename-term_dis-rule :
DEFINE VARIABLE v-doc-qnty LIKE ub.dis-rule.doc-qnty NO-UNDO.
DEFINE VARIABLE v-dis-kat LIKE ub.dis-rule.dis-kat NO-UNDO.
DEFINE VARIABLE v-tot-sum LIKE ub.dis-rule.tot-sum NO-UNDO.
DEFINE VARIABLE v-time-rule-num LIKE ub.dis-rule.time-rule-num NO-UNDO.
define variable v-charkey_one like ub.dis-rule.charkey_one no-undo .
define variable v-charkey_two like ub.dis-rule.charkey_two no-undo .
define variable v-charkey_three like ub.dis-rule.charkey_three no-undo .
define variable v-deckey_one like ub.dis-rule.deckey_one no-undo .
define variable v-deckey_two like ub.dis-rule.deckey_two no-undo .
define variable v-deckey_three like ub.dis-rule.deckey_three no-undo .
define variable v-key#_one like ub.dis-rule.key#_one no-undo .
define variable v-key#_two like ub.dis-rule.key#_two no-undo .
define variable v-key#_three like ub.dis-rule.key#_three no-undo .
DEFINE VARIABLE v-discnt-value LIKE ub.dis-rule.discnt-value NO-UNDO.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-rule-num LIKE ub.dis-rule.rule-num NO-UNDO.
define variable v-label as character no-undo .
define variable v-label0 as character no-undo .
DEFINE BUFFER buf_tt0-term_dis-rule FOR tt0-term_dis-rule.
define buffer buf_temp-drt-prop for temp-drt-prop.
define buffer upper_temp-drt-prop for temp-drt-prop.
define buffer loc_Price-list-type for ub.price-list-type.
IF v-tree = "":U  THEN RETURN ERROR.

&scop find-label ~
  assign ~
  ii = 0 ~
  v-label0 = ~{&branch-label~} ~
  v-label = v-label0. ~
  for each buf_temp-drt-prop no-lock where ~
            buf_temp-drt-prop.templ-rl-root = p-templ-rl-root ~
        and buf_temp-drt-prop.prop-code = "Label":U ~
        and buf_temp-drt-prop.upper-prop-code = ~{&branch-code~}, ~
      first upper_temp-drt-prop no-lock where ~
          upper_temp-drt-prop.templ-rl-root = p-templ-rl-root ~
      and upper_temp-drt-prop.prop-code = buf_temp-drt-prop.upper-prop-code ~
      and upper_temp-drt-prop.upper-prop-code = "Level2_UsingFields":U: ~
    assign ~
    v-label = buf_temp-drt-prop.property-value. ~
    leave. ~
  end


FOR EACH buf_tt0-term_dis-rule:
  buf_tt0-term_dis-rule.des = "".
END.
IF LOOKUP("time-rule-num", v-tree) > 0 THEN DO:
&scop branch-label "Расписание"
&scop branch-code "time-rule-num":U
{&find-label}.
  FOR EACH buf_tt0-term_dis-rule
  BY buf_tt0-term_dis-rule.time-rule-num:
    find first loc_price-list-type no-lock where
              loc_price-list-type.plt-id = integer(entry(1, buf_tt0-term_dis-rule.charkey_one, "-"))
          and loc_price-list-type.plt-db-num = integer(entry(2, buf_tt0-term_dis-rule.charkey_one, "-")) no-error.
    ASSIGN
    ii = ii + 1
    buf_tt0-term_dis-rule.des = buf_tt0-term_dis-rule.des + (IF buf_tt0-term_dis-rule.des = "":U THEN "@":U ELSE "":U) +
                                substitute("&1 №&2 &3"
                                          , v-label
                                          , buf_tt0-term_dis-rule.time-rule-num
                                          , (if available loc_price-list-type then loc_price-list-type.name else '')
                                          )
    .
  END.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
