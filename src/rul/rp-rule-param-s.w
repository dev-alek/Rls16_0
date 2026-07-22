&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_rp-rule-param FOR ub.rp-rule-param.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список rp-rule-param


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
define input parameter p-list-mode as character no-undo .
/*{&all} profile-id rule-id*/
define input parameter p-profile-id as integer no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-rp-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input-output parameter p-rid-list as character no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список rp-rule-param".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/mrk-strf.i }
{ gbl/getcntxt.i def }
{ gbl/key-rec.i }
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
DEFINE VARIABLE link-option AS CHARACTER NO-UNDO.
define variable v-rid-list as character no-undo .
DEFINE TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE ub.rule-call-param.

define temp-table for-copy-rp-rule-param no-undo like ub.rp-rule-param.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-rp-rule-param

/* Definitions for BROWSE br-rp-rule-param                              */
&Scoped-define FIELDS-IN-QUERY-br-rp-rule-param mark-string(recid(X_rp-rule-param), v-rid-list) X_rp-rule-param.profile_id X_rp-rule-param.codex_id X_rp-rule-param.ruleset_id X_rp-rule-param.rp_order_id X_rp-rule-param.rule-param-name X_rp-rule-param.rp-param-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-rp-rule-param
&Scoped-define SELF-NAME br-rp-rule-param
&Scoped-define OPEN-QUERY-br-rp-rule-param RUN openbr IN THIS-PROCEDURE.

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-rp-rule-param}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-chg b-link B-Help ~
br-rp-rule-param mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-link
       MENU-ITEM m_rule         LABEL "Правила"
       MENU-ITEM m_rule-profile LABEL "Профайл"       .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-link
     LABEL "Связи"
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

DEFINE VARIABLE mark-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9 BY .67
     FGCOLOR 10  NO-UNDO.


/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-rp-rule-param FOR
      X_rp-rule-param SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-rp-rule-param
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-rp-rule-param Dialog-Frame _FREEFORM
QUERY br-rp-rule-param NO-LOCK DISPLAY
      mark-string(recid(X_rp-rule-param), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_rp-rule-param.profile_id COLUMN-LABEL "ID" FORMAT ">>>>>>>>9"
X_rp-rule-param.codex_id COLUMN-LABEL "Кодекс" FORMAT ">>>>>>>>9"
X_rp-rule-param.ruleset_id COLUMN-LABEL "Набор!правил" FORMAT ">>>>>>>>9"
X_rp-rule-param.rp_order_id COLUMN-LABEL "Порядок!вызова" FORMAT ">>>>>>>>9"
X_rp-rule-param.rule-param-name COLUMN-LABEL "Имя!пар-ра!в правиле" FORMAT "X(32)"
X_rp-rule-param.rp-param-name COLUMN-LABEL "Имя!пар-ра!в профайле" FORMAT "X(32)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 20.54 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 24 WIDGET-ID 12
     b-sel AT ROW 1 COL 28 WIDGET-ID 10
     b-chg AT ROW 1 COL 48 WIDGET-ID 4
     b-link AT ROW 1 COL 78 WIDGET-ID 16
     B-Help AT ROW 1 COL 95
     br-rp-rule-param AT ROW 2.25 COL 1.5 WIDGET-ID 100
     mark-num AT ROW 1 COL 13 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     SPACE(74.50) SKIP(21.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_rp-rule-param B "?" ? ub rp-rule-param
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-rp-rule-param B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-link:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-link:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-rp-rule-param
/* Query rebuild information for BROWSE br-rp-rule-param
     _START_FREEFORM
RUN openbr IN THIS-PROCEDURE.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-rp-rule-param */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  RUN proc-b-chg IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-link
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-link Dialog-Frame
ON CHOOSE OF b-link IN FRAME Dialog-Frame /* Связи */
DO:
IF NOT AVAILABLE X_rp-rule-param THEN RETURN NO-APPLY.
IF link-option = '':U THEN DO:
   run gbl/pop-up.p ( INPUT SELF:handle, input no ) no-error.
   if error-status :error then do: return no-apply. end.
end.
if link-option = "":U then do:
      return no-apply.
end.
run proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
    link-option = '':U.
    RETURN NO-APPLY.
END.
link-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
    define variable glog as logical no-undo .
  if available X_rp-rule-param then do:
 { gbl/markstrn.i X_rp-rule-param v-rid-list }
  glog = br-rp-rule-param:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-rp-rule-param:select-next-row ().
      apply "VALUE-CHANGED" to br-rp-rule-param in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-rp-rule-param in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available X_rp-rule-param then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_rp-rule-param ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_rule Dialog-Frame
ON CHOOSE OF MENU-ITEM m_rule /* Правила */
DO:
  ASSIGN
  link-option = {&TABLE_rule}.
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      link-option = '':U.
      RETURN NO-APPLY.
  END.
  link-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_rule-profile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_rule-profile Dialog-Frame
ON CHOOSE OF MENU-ITEM m_rule-profile /* Профайл */
DO:
    ASSIGN
  link-option = {&TABLE_rule-profile}.
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      link-option = '':U.
      RETURN NO-APPLY.
  END.
  link-option = '':U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-rp-rule-param
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/brwrefre.i " v-doc-rec = recid(X_rp-rule-param).  ~
  RUn OpenBR in this-procedure.  REPOSITION br-rp-rule-param to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to br-rp-rule-param. " }

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
  run Myenable in this-procedure .
  v-rid-list = p-rid-list.
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
  ENABLE b-quit b-mark b-sel b-chg b-link B-Help br-rp-rule-param mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
b-link:MENU-MOUSE IN FRAME {&FRAME-NAME} = 1
.
ENABLE
b-quit
b-chg when (lookup("b-chg", bttns) > 0 and v-cntxt-db-num = 0)
B-Help
b-mark when lookup("b-mark", bttns) > 0
b-sel when lookup("b-sel", bttns) > 0
b-link
br-rp-rule-param
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
run Openbr in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
CASE p-list-mode:
   when {&all} then do:
      frame {&frame-name} :title = "Все профайлы".
      OPEN QUERY br-rp-rule-param FOR EACH X_rp-rule-param NO-LOCK INDEXED-REPOSITION.
   end.
   when "profile-id" THEN do:
      frame {&frame-name} :title = substitute("Профайл &1", p-profile-id).
      OPEN QUERY br-rp-rule-param
      FOR EACH X_rp-rule-param NO-LOCK where
               X_rp-rule-param.profile_id = p-profile-id
      by X_rp-rule-param.profile_id
     INDEXED-REPOSITION
      .
   end.
   when "rule-id" THEN do:
      frame {&frame-name} :title = substitute("Профайл &1 Кодекс &2 Набор правил &3 Порядок вызова &4 Правило &5"
                                              , p-profile-id
                                              , p-codex-id
                                              ,p-ruleset-id
                                              ,p-rp-order-id
                                              ,p-rule-id
                                              ).
      OPEN QUERY br-rp-rule-param
      FOR EACH X_rp-rule-param NO-LOCK where
               X_rp-rule-param.profile_id = p-profile-id
           and X_rp-rule-param.codex_id = p-codex-id
           and X_rp-rule-param.ruleset_id = p-ruleset-id
           and X_rp-rule-param.rp_order_id = p-rp-order-id
           and X_rp-rule-param.rule_id = p-rule-id
      by X_rp-rule-param.profile_id
     INDEXED-REPOSITION
      .
   end.


end case.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg :
define variable v-rid-list as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_rule-profile for ub.rule-profile.
define buffer buf_rp-rule-param for ub.rp-rule-param.
define buffer buf2_rp-rule-param for ub.rp-rule-param.
if not available X_rp-rule-param then return no-apply.

find first buf_rp-rule-param where
      recid(buf_rp-rule-param) = recid(X_rp-rule-param).
find first buf_rule-profile where
      buf_rule-profile.profile_id = X_rp-rule-param.profile_id.
run gen-key-rec in this-procedure ( input {&table_rule-profile}
                                  ,input buffer buf_rule-profile:handle
                                  ,output v-uniq-key-rec).
find first buf_ruledict where
      buf_ruledict.entry-type = {&rdict-etype-rule-profile}
  and buf_ruledict.uniq-key-rec = v-uniq-key-rec.
run rul/ruledict-param-s.w ( INPUT parparentproc
                        ,input this-procedure:handle /*p-update-proc-handle*/
                        ,INPUT "b-sel"
                        ,INPUT "entry-id"
                        ,INPUT buf_ruledict.entry-id
                        ,input {&rdict-etype-rule-profile}
                        ,INPUT-OUTPUT v-rid-list) NO-ERROR.
IF ERROR-STATUS:ERROR
or v-rid-list = '':U
THEN DO:
UNDO, RETURN no-apply.
END.
find first buf_ruledict-param no-lock where
       recid( buf_ruledict-param) = integer(v-rid-list) no-error.
if available buf_ruledict-param then do transaction:
 create for-copy-rp-rule-param .
 buffer-copy buf_rp-rule-param
 except rp-param-name
 to for-copy-rp-rule-param
 assign
 for-copy-rp-rule-param.rp-param-name = buf_ruledict-param.param-name.
 delete buf_rp-rule-param.
 create buf2_rp-rule-param.
 buffer-copy for-copy-rp-rule-param to buf2_rp-rule-param.
 delete for-copy-rp-rule-param.
 release buf2_rp-rule-param.
end.
br-rp-rule-param:refresh() in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-link Dialog-Frame
PROCEDURE proc-b-link :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
DEFINE variable v-rid-list AS CHARACTER NO-undo.
DEFINE variable v-rec AS recid NO-undo.
DEFINE variable v-uniq-key-rec AS CHARACTER NO-undo.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_rule-call-param for ub.rule-call-param.
CASE p-option:
  WHEN {&TABLE_rule} THEN DO:
    run rul/rule-i.w ( INPUT parparentproc
                              ,INPUT {&LOOKUP}
                              ,INPUT X_rp-rule-param.rule_id
                              ,INPUT-OUTPUT v-rec) NO-ERROR.

  END.
  WHEN {&TABLE_rule-profile} THEN DO:
    run rul/rule-profile-i.w ( INPUT parparentproc
                            ,INPUT {&LOOKUP}
                            ,INPUT X_rp-rule-param.profile_id
                            ,INPUT-OUTPUT v-rec
                            ) NO-ERROR.
  END.
   WHEN {&TABLE_rule-call-param} THEN DO:
    for each tt0-rule-call-param:
      delete tt0-rule-call-param.
    end.

    FOR each buf_rule-by-call no-lock where
            buf_rule-by-call.profile_id = X_rp-rule-param.profile_id,
           each buf_rule-call-param no-lock where
              buf_Rule-call-param.call#_id = buf_rule-by-call.call#_id
          and buf_Rule-call-param.codex_id = buf_rule-by-call.codex_id
          and buf_Rule-call-param.ruleset_id = buf_rule-by-call.ruleset_id
          and buf_Rule-call-param.order_id = buf_rule-by-call.order_id:
        create tt0-rule-call-param.
        buffer-copy buf_rule-call-param to tt0-rule-call-param.
    end.
    run ref/rulercps.w ( INPUT parparentproc
                        ,input this-procedure:handle
                        ,INPUT "":U /*bttns*/
                        ,input {&lookup}
                        ,input {&table_rp-rule-param}
                        ,input X_rp-rule-param.profile_id
                        ,input ? /*once-more*/
                        ,input '':U /*p-call-id*/
                        ,input 0 /*codex_id*/
                        ,input 0 /*p-ruleset-id*/
                        ,input ? /*p-order-id*/
                        ,input 0 /*p-rule-id*/
                        ,input substitute("Параметры вызова профайла &1"
                                          , X_rp-rule-param.profile_id
                                          )
                        ,input-output table tt0-rule-call-param ) no-error.

  END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME