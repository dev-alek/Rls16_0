&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_rule FOR ub.rule.
DEFINE BUFFER X_rule-by-profile FOR ub.rule-by-profile.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список rule-by-profile


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
/*{&all} "ruleset" "codex"  rule_id*/
DEFINE INPUT PARAMETER p-profile-id AS INTEGER NO-UNDO.
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
define variable vss-description as character no-undo init "Список rule-by-profile".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
DEFINE VARIABLE lkp-option AS CHARACTER NO-UNDO.
define variable v-rid-list as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-rule-by-profile

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_rule-by-profile X_rule

/* Definitions for BROWSE br-rule-by-profile                            */
&Scoped-define FIELDS-IN-QUERY-br-rule-by-profile mark-string(recid(X_rule-by-profile), v-rid-list) X_rule-by-profile.PROFILE_id X_rule-by-profile.codex_id X_rule-by-profile.ruleset_id X_rule-by-profile.rp_order_id X_rule-by-profile.rule_id X_rule-by-profile.is_dynamic X_rule-by-profile.dflt-can-calc X_rule.name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-rule-by-profile
&Scoped-define SELF-NAME br-rule-by-profile
&Scoped-define QUERY-STRING-br-rule-by-profile FOR EACH X_rule-by-profile NO-LOCK, ~
       first X_rule NO-LOCK indexed-reposition
&Scoped-define OPEN-QUERY-br-rule-by-profile OPEN QUERY br-rule-by-profile FOR EACH X_rule-by-profile NO-LOCK, ~
       first X_rule NO-LOCK indexed-reposition.
&Scoped-define TABLES-IN-QUERY-br-rule-by-profile X_rule-by-profile X_rule
&Scoped-define FIRST-TABLE-IN-QUERY-br-rule-by-profile X_rule-by-profile
&Scoped-define SECOND-TABLE-IN-QUERY-br-rule-by-profile X_rule


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-rule-by-profile}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-chg b-del b-lkp ~
B-params B-Help br-rule-by-profile e-profile mark-num
&Scoped-Define DISPLAYED-OBJECTS e-profile mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-lkp
       MENU-ITEM m_ruleset      LABEL "Кодекс/Набор правил"
       MENU-ITEM m_profile      LABEL "Профайл"
       MENU-ITEM m_text         LABEL "Правило-Текст"
       MENU-ITEM m_graph        LABEL "Правило-Граф"  .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
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

DEFINE BUTTON B-params
     LABEL "Пар-ры"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1.

DEFINE VARIABLE e-profile AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 97.5 BY 2.46 NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9 BY .67
     FGCOLOR 10  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-rule-by-profile FOR
      X_rule-by-profile,
      X_rule SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-rule-by-profile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-rule-by-profile Dialog-Frame _FREEFORM
  QUERY br-rule-by-profile NO-LOCK DISPLAY
      mark-string(recid(X_rule-by-profile), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_rule-by-profile.PROFILE_id COLUMN-LABEL "Профайл" FORMAT ">>>>>>>>9"
X_rule-by-profile.codex_id COLUMN-LABEL "Кодекс!правил" FORMAT ">>>>>>>>9"
X_rule-by-profile.ruleset_id COLUMN-LABEL "Набор!правил" FORMAT ">>>>>>>>9"
X_rule-by-profile.rp_order_id COLUMN-LABEL "Порядок!вызова" FORMAT ">>9"
X_rule-by-profile.rule_id COLUMN-LABEL "№ правила" FORMAT ">>>>>>>>9"
X_rule-by-profile.is_dynamic COLUMN-LABEL "Отклю!чаемое" FORMAT "+/"
X_rule-by-profile.dflt-can-calc COLUMN-LABEL "По умолч!включ" FORMAT "+/"
X_rule.name COLUMN-LABEL "Название правила" FORMAT "X(255)" WIDTH 45
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 18 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 24 WIDGET-ID 12
     b-sel AT ROW 1 COL 28 WIDGET-ID 10
     b-add AT ROW 1 COL 38 WIDGET-ID 2
     b-chg AT ROW 1 COL 48 WIDGET-ID 4
     b-del AT ROW 1 COL 58 WIDGET-ID 8
     b-lkp AT ROW 1 COL 68 WIDGET-ID 6
     B-params AT ROW 1 COL 78 WIDGET-ID 16
     B-Help AT ROW 1 COL 95
     br-rule-by-profile AT ROW 2.33 COL 1 WIDGET-ID 100
     e-profile AT ROW 20.42 COL 1 NO-LABEL WIDGET-ID 18
     mark-num AT ROW 1 COL 13 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     SPACE(74.51) SKIP(21.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Привязка правил к профайлам"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_rule B "?" ? ub rule
      TABLE: X_rule-by-profile B "?" ? ub rule-by-profile
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-rule-by-profile B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-lkp:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-lkp:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-rule-by-profile
/* Query rebuild information for BROWSE br-rule-by-profile
     _START_FREEFORM
OPEN QUERY br-rule-by-profile
FOR EACH X_rule-by-profile NO-LOCK,
first X_rule NO-LOCK indexed-reposition.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-rule-by-profile */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Привязка правил к профайлам */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Привязка правил к профайлам */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  run proc-b-add-chg in this-procedure ( input yes) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  define variable v-rec as recid no-undo.
  if not available X_rule-by-profile then return no-apply.
  run proc-b-add-chg in this-procedure ( input no) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  define variable v-rec as recid no-undo.
  define variable glog as logical no-undo.
  if not available X_rule-by-profile then return no-apply.
  v-rec = recid(X_rule-by-profile).
  message "Вы уверены, что хотите удалить привязку ПРАВИЛА К наборам профайлам?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then return no-apply.
  run rul/rule-by-profile3.p (
                            input no /*p-silent*/
                           ,input v-rec
                              ) no-error.
  if error-status:error then return no-apply.
  run openbr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  define variable v-rec as recid no-undo.
  if not available X_rule-by-profile then return no-apply.
  v-rec = recid(X_rule-by-profile).
    if lkp-option = '':U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status:error then do: return no-apply. end.
    if lkp-option = '':U then return no-apply.
    run proc-b-lkp in this-procedure ( input lkp-option) no-error.
    if error-status:error then do:
      lkp-option = '':U.
      return no-apply.
    end.
    lkp-option = '':U.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
    define variable glog as logical no-undo .
  if available X_rule-by-profile then do:
 { gbl/markstrn.i X_rule-by-profile v-rid-list }
  glog = br-rule-by-profile:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-rule-by-profile:select-next-row ().
      apply "VALUE-CHANGED" to br-rule-by-profile in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-rule-by-profile in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-params
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-params Dialog-Frame
ON CHOOSE OF B-params IN FRAME Dialog-Frame /* Пар-ры */
DO:
 DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  IF NOT AVAILABLE X_rule-by-profile THEN RETURN NO-APPLY.
  run rul/rp-rule-param-s.w ( INPUT parparentproc
                             ,INPUT (IF (v-cntxt-db-num = 0  and lookup("b-add", bttns) > 0) THEN "b-chg" ELSE '')
                             ,INPUT "rule-id"
                             ,INPUT X_rule-by-profile.profile_id
                             ,INPUT X_rule-by-profile.codex_id
                             ,INPUT X_rule-by-profile.ruleset_id
                             ,INPUT X_rule-by-profile.rp_order_id
                             ,INPUT X_rule-by-profile.rule_id
                             ,INPUT-OUTPUT v-rid-list) NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available X_rule-by-profile then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_rule-by-profile ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-rule-by-profile
&Scoped-define SELF-NAME br-rule-by-profile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-rule-by-profile Dialog-Frame
ON VALUE-CHANGED OF br-rule-by-profile IN FRAME Dialog-Frame
DO:
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
  IF AVAILABLE X_rule-by-profile THEN DO:
     FIND FIRST buf_rule-profile NO-LOCK WHERE
            buf_rule-profile.profile_id = X_rule-by-profile.profile_id NO-ERROR.
     IF AVAILABLE buf_rule-profile  THEN DO:
         e-profile:screen-value = buf_rule-profile.NAME.
     END.
     ELSE DO:
         e-profile:screen-value = "".
     END.
  END.
  ELSE DO:
     e-profile:screen-value = "".
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_graph
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_graph Dialog-Frame
ON CHOOSE OF MENU-ITEM m_graph /* Правило-Граф */
DO:
  ASSIGN
  lkp-option = "graph".
  run proc-b-lkp IN THIS-PROCEDURE ( INPUT lkp-option) NO-ERROR.
  ASSIGN
  lkp-option = '':U.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_profile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_profile Dialog-Frame
ON CHOOSE OF MENU-ITEM m_profile /* Профайл */
DO:
    ASSIGN
  lkp-option = "profile".
  run proc-b-lkp IN THIS-PROCEDURE ( INPUT lkp-option) NO-ERROR.
  ASSIGN
  lkp-option = '':U.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_ruleset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_ruleset Dialog-Frame
ON CHOOSE OF MENU-ITEM m_ruleset /* Кодекс/Набор правил */
DO:
    ASSIGN
  lkp-option = "ruleset".
  run proc-b-lkp IN THIS-PROCEDURE ( INPUT lkp-option) NO-ERROR.
  ASSIGN
  lkp-option = '':U.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_text
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_text Dialog-Frame
ON CHOOSE OF MENU-ITEM m_text /* Правило-Текст */
DO:
  ASSIGN
  lkp-option = "text".
  run proc-b-lkp IN THIS-PROCEDURE ( INPUT lkp-option) NO-ERROR.
  ASSIGN
  lkp-option = '':U.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/brwrefre.i " v-doc-rec = recid(X_rule-by-profile).  ~
  RUn OpenBR in this-procedure.  REPOSITION br-rule-by-profile to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to br-rule-by-profile. " }

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
  DISPLAY e-profile mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel b-add b-chg b-del b-lkp B-params B-Help
         br-rule-by-profile e-profile mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
X_rule.NAME:RESIZABLE IN BROWSE br-rule-by-profile = YES
b-lkp:MENU-MOUSE in frame {&frame-name} = 1.
case p-list-mode:
  when "ruleset" then do:
    assign
    X_rule-by-profile.codex_id:visible in browse br-rule-by-profile = no
    X_rule-by-profile.ruleset_id:visible in browse br-rule-by-profile = no
    .
  end.
  when "codex" then do:
    assign
    X_rule-by-profile.codex_id:visible in browse br-rule-by-profile = no
    .
  end.
  when "profile" then do:
    assign
    X_rule-by-profile.profile_id:visible in browse br-rule-by-profile = no
    .
    HIDE
    e-profile
    IN FRAME {&FRAME-NAME}.
    ASSIGN
    br-rule-by-profile:HEIGHT = br-rule-by-profile:HEIGHT  + 2.47
    .
  end.
  when "rule" then do:
    assign
    X_rule-by-profile.rule_id:visible in browse br-rule-by-profile = no
    .
  end.
end.
ENABLE
b-quit
b-add when ( p-list-mode = "profile" and v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-del when (v-cntxt-db-num = 0  and lookup("b-add", bttns) > 0)
b-chg when (v-cntxt-db-num = 0  and lookup("b-add", bttns) > 0)
b-lkp
B-Help
b-mark when lookup("b-mark", bttns) > 0
b-sel when lookup("b-sel", bttns) > 0
b-params
br-rule-by-profile
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
run Openbr in this-procedure .
APPLY "VALUE-CHANGED" TO br-rule-by-profile.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
CASE p-list-mode:
  WHEN {&ALL} THEN DO:
    frame {&frame-name}:title = "Все правила всех профайлов".
    OPEN QUERY br-rule-by-profile
    FOR EACH X_rule-by-profile NO-LOCK,
        FIRST X_rule NO-LOCK WHERE X_rule.rule_id = X_rule-by-profile.rule_id INDEXED-REPOSITION.
  END.
  WHEN "ruleset" THEN DO:
    frame {&frame-name}:title = substitute("Все правила профайлов для кодекса правил &1 набора правил &2"
                                           , p-codex-id
                                           , p-ruleset-id).
    OPEN QUERY br-rule-by-profile
    FOR EACH X_rule-by-profile NO-LOCK WHERE
             X_rule-by-profile.codex_id = p-codex-id
          AND X_rule-by-profile.ruleset_id = p-ruleset-id,
        FIRST X_rule NO-LOCK WHERE X_rule.rule_id = X_rule-by-profile.rule_id INDEXED-REPOSITION.

  END.
  WHEN "codex" THEN DO:
    frame {&frame-name}:title = substitute("Все правила профайлов для кодекса правил &1"
                                          , p-codex-id).
    OPEN QUERY br-rule-by-profile
    FOR EACH X_rule-by-profile NO-LOCK WHERE
             X_rule-by-profile.codex_id = p-codex-id,
        FIRST X_rule NO-LOCK WHERE X_rule.rule_id = X_rule-by-profile.rule_id INDEXED-REPOSITION.

  END.
  WHEN "profile" THEN DO:
    frame {&frame-name}:title = substitute("Все правила для профайла &1"
                                          , p-profile-id).
    OPEN QUERY br-rule-by-profile
    FOR EACH X_rule-by-profile NO-LOCK WHERE
             X_rule-by-profile.profile_id = p-profile-id,
        FIRST X_rule NO-LOCK WHERE X_rule.rule_id = X_rule-by-profile.rule_id INDEXED-REPOSITION.

  END.
  WHEN "rule" THEN DO:
    frame {&frame-name}:title = substitute("Все профайлы для правила &1"
                                          , p-rule-id).
    OPEN QUERY br-rule-by-profile
    FOR EACH X_rule-by-profile NO-LOCK WHERE
            X_rule-by-profile.rule_id = p-rule-id,
        FIRST X_rule NO-LOCK WHERE X_rule.rule_id = X_rule-by-profile.rule_id INDEXED-REPOSITION.

 END.

END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add-chg Dialog-Frame
PROCEDURE proc-b-add-chg :
define input parameter p-add as logical no-undo .
define variable v-rid-list as character no-undo .
define variable v-rec as recid no-undo .
define variable v-is-dynamic as logical no-undo .
define variable v-dflt-can-calc as logical   no-undo .
define variable v-ok as logical no-undo .
define buffer buf_rule-by-set for ub.rule-by-set.
define buffer buf_rule-by-profile for ub.rule-by-profile.
define buffer buf_ruleset for ub.ruleset.
IF p-list-mode <> "profile" THEN DO:
   MESSAGE
   "Нельзя добавлять в моде " p-list-mode
   VIEW-AS ALERT-BOX ERROR.
   RETURN.
END.
CASE p-add:
  when yes then do:
    MESSAGE
    "Выберите набор правил"
    VIEW-AS ALERT-BOX .
    run rul/ruleset-s.w ( input parparentproc
                        ,input "b-sel"
                        ,input {&all}
                        ,input 0
                        ,input-output v-rid-list) no-error.
      if v-rid-list = '':U then do:
        return.
      end.
    find first buf_ruleset no-lock where
                recid(buf_ruleset) = integer(v-rid-list).
    .
    v-rid-list  = '':U.
    run rul/rule-by-set-s.w ( input parparentproc
                        ,input "b-sel"
                        ,input "ruleset"
                        ,input buf_ruleset.codex_id  /*p-codex-id*/
                        ,input buf_ruleset.ruleset_id  /*p-ruleset-id*/
                        ,input 0  /*p-rule-id*/
                        ,input-output v-rid-list) no-error.
      if v-rid-list = '':U then do:
        return.
      end.
    find first buf_rule-by-set no-lock where
                recid(buf_rule-by-set) = integer(v-rid-list).
    .
    run rul/rule-by-profile1.p ( input {&add-def}
                              ,input no /*p-silent*/
                              ,input-output v-rec
                              ,input p-profile-id
                              ,input buf_ruleset.codex_id
                              ,input buf_ruleset.ruleset_id
                              ,input buf_rule-by-set.rule_id
                              ,input yes
                              ,input yes
                              ) no-error.
    if error-status:error then do:
      undo, return error .
    end.
    run openbr in this-procedure .
    reposition br-rule-by-profile to recid v-rec no-error.
    APPLY "ENTRY" to browse br-rule-by-profile.
  end.
  when no then do:
    find first buf_rule-by-profile exclusive-lock where
              recid(buf_rule-by-profile) = recid(X_rule-by-profile).
    v-is-dynamic = X_rule-by-profile.is_dynamic.
    run gbl/d-logical.w ( input ? /*h-callback*/
                        ,input 'title=':u + "Задайте свойство ОТКЛЮЧАЕМОЕ" + '\':u
                        ,input-output v-is-dynamic
                        ,output v-ok ) no-error.
    if error-status:error
    or not v-ok then do:
      undo, return error .
    end.
    if v-is-dynamic then do:
      v-ok = no.
      v-dflt-can-calc = X_rule-by-profile.dflt-can-calc.
      run gbl/d-logical.w ( input ? /*h-callback*/
                          ,input 'title=':u + "Задайте свойство ПО УМОЛЧАНИЮ ВКЛЮЧЕНО" + '\':u
                          ,input-output v-dflt-can-calc
                          ,output v-ok ) no-error.
      if error-status:error
      or not v-ok then do:
        undo, return error .
      end.
    end.
    else do:
       v-dflt-can-calc = yes.
    end.
    v-rec = recid(x_rule-by-profile).
    run rul/rule-by-profile1.p ( input {&update}
                              ,input no /*p-silent*/
                              ,input-output v-rec
                              ,input X_rule-by-profile.profile_id
                              ,input X_rule-by-profile.codex_id
                              ,input X_rule-by-profile.ruleset_id
                              ,input X_rule-by-profile.rule_id
                              ,input v-is-dynamic
                              ,input v-dflt-can-calc
                              ) no-error.
    if error-status:error then do:
      message error-status:get-message(1) view-as alert-box .
      undo, return error .
    end.
    run openbr in this-procedure .
    reposition br-rule-by-profile to recid v-rec no-error.
    APPLY "ENTRY" to browse br-rule-by-profile.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lkp Dialog-Frame
PROCEDURE proc-b-lkp :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
define variable v-rec as recid no-undo .
CASE p-option:
    WHEN "text"
    OR WHEN "graph" THEN DO:
        run rul/disprule.p (
                       input p-option
                      ,input X_rule-by-profile.rule_id
                      ,input 0 /*p-codex-id*/
                      ,input 0 /*p-ruleset-id*/
                      ,input 0 /*p-call-id*/
                      ,input 0 /*p-order-id*/
                       ).

    END.
    WHEN "profile" THEN DO:
        run rul/rule-profile-i.w ( INPUT parparentproc
                             ,INPUT {&lookup}
                             ,INPUT X_rule-by-profile.profile_id
                             ,INPUT-OUTPUT v-rec ) NO-ERROR.

    END.
    WHEN "ruleset" THEN DO:
        run rul/ruleset-i.w ( INPUT parparentproc
                             ,INPUT {&lookup}
                             ,INPUT X_rule-by-profile.codex_id
                             ,INPUT X_rule-by-profile.ruleset_id
                             ,INPUT-OUTPUT v-rec ) NO-ERROR.


    END.
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
