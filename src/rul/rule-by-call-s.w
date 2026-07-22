&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_rule FOR ub.rule.
DEFINE BUFFER X_rule-by-call FOR ub.rule-by-call.
DEFINE BUFFER X_ruleset FOR ub.ruleset.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список rule-by-call

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns as character no-undo.
DEFINE INPUT PARAMETER p-list-mode AS CHARACTER NO-UNDO.
/*{&all} "ruleset" "codex" rule call_id*/
DEFINE INPUT PARAMETER p-call-id AS character NO-UNDO.
DEFINE INPUT PARAMETER p-codex-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-ruleset-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
define input-output parameter p-rid-list as character no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список rule-by-call".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ gbl/key-rec.i }
{ rul/calldscr.i }
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable v-rid-list as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-rule-by-call

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_rule-by-call X_ruleset X_rule

/* Definitions for BROWSE br-rule-by-call                               */
&Scoped-define FIELDS-IN-QUERY-br-rule-by-call mark-string(recid(X_rule-by-call), v-rid-list) X_rule-by-call.call_id X_rule-by-call.call#_id X_rule-by-call.codex_id X_rule-by-call.ruleset_id X_rule-by-call.order_id X_ruleset.name X_rule-by-call.rule_id X_rule.name X_rule-by-call.is_dynamic X_rule-by-call.can-calc X_rule-by-call.profile_id X_rule-by-call.once-more   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-rule-by-call   
&Scoped-define SELF-NAME br-rule-by-call
&Scoped-define QUERY-STRING-br-rule-by-call FOR EACH X_rule-by-call, ~
       FIRST X_ruleset, ~
       FIRST X_rule
&Scoped-define OPEN-QUERY-br-rule-by-call OPEN QUERY br-rule-by-call FOR EACH X_rule-by-call, ~
       FIRST X_ruleset, ~
       FIRST X_rule.
&Scoped-define TABLES-IN-QUERY-br-rule-by-call X_rule-by-call X_ruleset ~
X_rule
&Scoped-define FIRST-TABLE-IN-QUERY-br-rule-by-call X_rule-by-call
&Scoped-define SECOND-TABLE-IN-QUERY-br-rule-by-call X_ruleset
&Scoped-define THIRD-TABLE-IN-QUERY-br-rule-by-call X_rule


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-rule-by-call}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-chg b-lkp B-Help ~
br-rule-by-call EDITOR-2 EDITOR-1 mark-num 
&Scoped-Define DISPLAYED-OBJECTS EDITOR-2 EDITOR-1 mark-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chg 
     LABEL "&Изменить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp 
     LABEL "&Просмотр" 
     SIZE 10 BY 1.

DEFINE BUTTON b-mark 
     LABEL "&*" 
     SIZE 4 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel AUTO-GO 
     LABEL "Выбор" 
     SIZE 10 BY 1.

DEFINE VARIABLE EDITOR-1 AS CHARACTER 
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 98 BY 3.37 NO-UNDO.

DEFINE VARIABLE EDITOR-2 AS CHARACTER 
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 98 BY 2.87 NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 9 BY .67
     FGCOLOR 10  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-rule-by-call FOR 
      X_rule-by-call, 
      X_ruleset, 
      X_rule SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-rule-by-call
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-rule-by-call Dialog-Frame _FREEFORM
  QUERY br-rule-by-call NO-LOCK DISPLAY
      mark-string(recid(X_rule-by-call), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_rule-by-call.call_id COLUMN-LABEL "Точка вызова" FORMAT "X(255)" WIDTH 45
X_rule-by-call.call#_id COLUMN-LABEL "Точка вызова" FORMAT ">>>>>>>>9"
X_rule-by-call.codex_id COLUMN-LABEL "Кодекс!правил" FORMAT ">>>>>>>>9"
X_rule-by-call.ruleset_id COLUMN-LABEL "Набор!правил" FORMAT ">>>>>>>>9"
X_rule-by-call.order_id COLUMN-LABEL "Порядок!вызова" FORMAT ">>>>>>>>9"
X_ruleset.name COLUMN-LABEL "Кодекс/набор правил" FORMAT "X(255)" WIDTH 45
X_rule-by-call.rule_id COLUMN-LABEL "№ правила" FORMAT ">>>>>>>>9"
X_rule.name COLUMN-LABEL "Правило" FORMAT "X(255)"  WIDTH 45
X_rule-by-call.is_dynamic COLUMN-LABEL "Отклю!чемое" FORMAT "+/"
X_rule-by-call.can-calc COLUMN-LABEL "Включено" FORMAT "+/"
X_rule-by-call.profile_id COLUMN-LABEL "Профайл" FORMAT ">>>>>>>>9"
X_rule-by-call.once-more COLUMN-LABEL "№ привязки" FORMAT ">9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 14 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 24 WIDGET-ID 12
     b-sel AT ROW 1 COL 28 WIDGET-ID 10
     b-chg AT ROW 1 COL 48 WIDGET-ID 4
     b-lkp AT ROW 1 COL 68 WIDGET-ID 6
     B-Help AT ROW 1 COL 95
     br-rule-by-call AT ROW 2.33 COL 1 WIDGET-ID 100
     EDITOR-2 AT ROW 16.5 COL 1 NO-LABEL WIDGET-ID 18
     EDITOR-1 AT ROW 19.5 COL 1 NO-LABEL WIDGET-ID 16
     mark-num AT ROW 1 COL 13 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     SPACE(75.24) SKIP(21.21)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Привязка правил к точкам вызова"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_rule B "?" ? ub rule
      TABLE: X_rule-by-call B "?" ? ub rule-by-call
      TABLE: X_ruleset B "?" ? ub ruleset
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-rule-by-call B-Help Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-rule-by-call
/* Query rebuild information for BROWSE br-rule-by-call
     _START_FREEFORM
OPEN QUERY br-rule-by-call FOR EACH X_rule-by-call, FIRST X_ruleset, FIRST X_rule.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-rule-by-call */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Привязка правил к точкам вызова */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Привязка правил к точкам вызова */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  define variable v-rec as recid no-undo.
  if not available X_rule-by-call then return no-apply.
  run proc-b-chg in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  define variable v-rec as recid no-undo.
  if not available X_rule-by-call then return no-apply.
  v-rec = recid(X_rule-by-call).
  run rul/rule-by-call-i.w ( input parparentproc
                       ,input {&lookup}
                       ,input X_rule-by-call.CALL#_id
                       ,input X_rule-by-call.codex_id
                       ,input X_rule-by-call.ruleset_id
                       ,input X_rule-by-call.order_id
                       ,input-output v-rec) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
    define variable glog as logical no-undo .
  if available X_rule-by-call then do:
 { gbl/markstrn.i X_rule-by-call v-rid-list }
  glog = br-rule-by-call:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-rule-by-call:select-next-row ().
      apply "VALUE-CHANGED" to br-rule-by-call in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-rule-by-call in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available X_rule-by-call then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_rule-by-call ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-rule-by-call
&Scoped-define SELF-NAME br-rule-by-call
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-rule-by-call Dialog-Frame
ON VALUE-CHANGED OF br-rule-by-call IN FRAME Dialog-Frame
DO:
    IF AVAILABLE X_rule THEN DO:
    editor-1:SCREEN-VALUE = X_rule.documentation.
    editor-2:SCREEN-VALUE = X_rule-by-call.algo-des.

  END.
  ELSE DO:
    editor-1:SCREEN-VALUE = '':U.
    editor-2:SCREEN-VALUE = '':U.

  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

{ gbl/brwrefre.i " v-doc-rec = recid(X_rule-by-call).  ~
  RUn OpenBR in this-procedure.  REPOSITION br-rule-by-call to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to br-rule-by-call. " }

{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  v-rid-list = p-rid-list.
  run Myenable in this-procedure .
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
  DISPLAY EDITOR-2 EDITOR-1 mark-num 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel b-chg b-lkp B-Help br-rule-by-call EDITOR-2 
         EDITOR-1 mark-num 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
assign
X_rule.name:resizable in browse br-rule-by-call = yes
X_ruleset.name:resizable in browse br-rule-by-call = yes
X_ruleset.name:visible in browse br-rule-by-call = (p-list-mode <> "codex" and p-list-mode <> "ruleset")
X_rule.name:visible in browse br-rule-by-call = (p-list-mode <> "rule")
.
ENABLE
b-quit
b-chg WHEN (LOOKUP("b-add", bttns) > 0 AND v-cntxt-db-num = 0)
b-lkp
B-Help
b-mark when lookup("b-mark", bttns) > 0
b-sel when lookup("b-sel", bttns) > 0
br-rule-by-call
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
run Openbr in this-procedure .
APPLY "VALUE-CHANGED" to br-rule-by-call.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame 
PROCEDURE Openbr :
CASE p-list-mode:
  WHEN {&ALL} THEN DO:
    frame {&frame-name} :title = "Все вызовы всех правил".
    OPEN QUERY br-rule-by-call
    FOR EACH X_rule-by-call NO-LOCK
      , FIRST X_ruleset NO-LOCK WHERE
              X_ruleset.codex_id = X_rule-by-call.codex_id
          AND X_ruleset.ruleset_id = X_rule-by-call.ruleset_id
      , FIRST X_rule NO-LOCK  where
              X_rule.RULE_id = X_rule.RULE_id
    INDEXED-REPOSITION.
  END.
  WHEN "call_id" THEN DO:
    frame {&frame-name} :title = substitute("Вызовы правил в точке вызова &1", calldscr( p-call-id)).
    if p-codex-id > 0 then do:
      frame {&frame-name} :title = substitute("&1: кодекс &2", frame {&frame-name} :title, p-codex-id).
    end.
    if p-ruleset-id > 0 then do:
      frame {&frame-name} :title = substitute("&1: набор правил &2", frame {&frame-name} :title, p-ruleset-id).
    end.
    if p-rule-id > 0 then do:
      frame {&frame-name} :title = substitute("&1: правило &2", frame {&frame-name} :title, p-rule-id).
    end.
    OPEN QUERY br-rule-by-call
    FOR EACH X_rule-by-call NO-LOCK where
             X_rule-by-call.call_Id = p-call-Id
         and (p-codex-id = 0 or X_rule-by-call.codex_id = p-codex-id)
         and (p-ruleset-id = 0 or X_rule-by-call.ruleset_id = p-ruleset-id)
         and (p-rule-id = 0 or X_rule-by-call.rule_id = p-rule-id)
      , FIRST X_ruleset NO-LOCK WHERE
              X_ruleset.codex_id = X_rule-by-call.codex_id
          AND X_ruleset.ruleset_id = X_rule-by-call.ruleset_id
      , FIRST X_rule NO-LOCK  where
              X_rule.RULE_id = X_rule.RULE_id
    INDEXED-REPOSITION.
  END.
  WHEN "ruleset" THEN DO:
    frame {&frame-name} :title = substitute("Вызовы правил для &1 набора правил &2", p-codex-id, p-ruleset-id).
    OPEN QUERY br-rule-by-call
    FOR EACH X_rule-by-call NO-LOCK WHERE
             X_rule-by-call.codex_id = p-codex-id
         AND X_rule-by-call.ruleset_id = p-codex-id
        , FIRST X_ruleset NO-LOCK WHERE
                X_ruleset.codex_id = X_rule-by-call.codex_id
            AND X_ruleset.ruleset_id = X_rule-by-call.ruleset_id
        , FIRST X_rule NO-LOCK  where
                X_rule.RULE_id = X_rule.RULE_id
        INDEXED-REPOSITION.

  END.
  WHEN "codex" THEN DO:
    frame {&frame-name} :title = substitute("Вызовы правил для кодекса правил &1", p-codex-id).
    OPEN QUERY br-rule-by-call
    FOR EACH X_rule-by-call NO-LOCK WHERE
             X_rule-by-call.codex_id = p-codex-id
        , FIRST X_ruleset NO-LOCK WHERE
                X_ruleset.codex_id = X_rule-by-call.codex_id
            AND X_ruleset.ruleset_id = X_rule-by-call.ruleset_id
        , FIRST X_rule NO-LOCK  where
                X_rule.RULE_id = X_rule.RULE_id
        INDEXED-REPOSITION.

  END.
  WHEN "rule" THEN DO:
    frame {&frame-name} :title = substitute("Вызовы правила &1", p-rule-id).
    OPEN QUERY br-rule-by-call
    FOR EACH X_rule-by-call NO-LOCK WHERE
            X_rule-by-call.rule_id = p-rule-id
        , FIRST X_ruleset NO-LOCK WHERE
                X_ruleset.codex_id = X_rule-by-call.codex_id
            AND X_ruleset.ruleset_id = X_rule-by-call.ruleset_id
        , FIRST X_rule NO-LOCK  where
                X_rule.RULE_id = X_rule.RULE_id
        INDEXED-REPOSITION.

 END.

END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame 
PROCEDURE proc-b-chg :
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
run rul/rule-by-call-i.w ( input parparentproc
                     ,input {&update}
                     ,input X_rule-by-call.CALL#_id
                     ,input X_rule-by-call.codex_id
                     ,input X_rule-by-call.ruleset_id
                     ,input X_rule-by-call.order_id
                     ,input-output v-rec) no-error.

if error-status:error then do:
  undo, return error .
end.
run openbr in this-procedure .
reposition br-rule-by-call to recid v-rec no-error.
APPLY "ENTRY" to browse br-rule-by-call.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

