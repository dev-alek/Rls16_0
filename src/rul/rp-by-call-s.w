&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_rp-by-call FOR ub.rp-by-call.
DEFINE BUFFER X_rule FOR ub.rule.
DEFINE BUFFER X_rule-by-profile FOR ub.rule-by-profile.
DEFINE BUFFER X_rule-profile FOR ub.rule-profile.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список rp-by-call

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
/*{&all} "profile-id" "profile-type" "call_id call_id,codex-id call-id,ruleset-id" */
DEFINE INPUT PARAMETER p-profile-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-profile-type as character NO-UNDO.
define input parameter p-call-id as character no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input-output parameter p-rid-list as character no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список rp-by-call".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ gbl/key-rec.i }
{ rul/calldscr.i }
{ gbl/color.i }
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable v-rid-list as character no-undo .
DEFINE VARIABLE template-recid as recid no-undo.
&SCOPED-DEFINE LABEL-call "Вызов"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-rp-by-call

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_rp-by-call X_rule-profile ~
X_rule-by-profile

/* Definitions for BROWSE br-rp-by-call                                 */
&Scoped-define FIELDS-IN-QUERY-br-rp-by-call mark-string(recid(X_rp-by-call), v-rid-list) X_rp-by-call.profile_id calldscr(X_rp-by-call.call_id) X_rule-profile.name X_rule-profile.profile-type X_rp-by-call.once-more
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-rp-by-call
&Scoped-define SELF-NAME br-rp-by-call
&Scoped-define QUERY-STRING-br-rp-by-call FOR EACH X_rp-by-call, ~
       FIRST X_rule-profile, ~
       FIRST X_rule-by-profile
&Scoped-define OPEN-QUERY-br-rp-by-call OPEN QUERY br-rp-by-call FOR EACH X_rp-by-call, ~
       FIRST X_rule-profile, ~
       FIRST X_rule-by-profile.
&Scoped-define TABLES-IN-QUERY-br-rp-by-call X_rp-by-call X_rule-profile ~
X_rule-by-profile
&Scoped-define FIRST-TABLE-IN-QUERY-br-rp-by-call X_rp-by-call
&Scoped-define SECOND-TABLE-IN-QUERY-br-rp-by-call X_rule-profile
&Scoped-define THIRD-TABLE-IN-QUERY-br-rp-by-call X_rule-by-profile


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-rp-by-call}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-del B-Help ~
br-rp-by-call EDITOR-1 mark-num
&Scoped-Define DISPLAYED-OBJECTS EDITOR-1 mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

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

DEFINE VARIABLE mark-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9 BY .67
     FGCOLOR 10  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-rp-by-call FOR
      X_rp-by-call,
      X_rule-profile,
      X_rule-by-profile SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-rp-by-call
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-rp-by-call Dialog-Frame _FREEFORM
  QUERY br-rp-by-call NO-LOCK DISPLAY
      mark-string(recid(X_rp-by-call), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_rp-by-call.profile_id COLUMN-LABEL "Профайл" FORMAT ">>>>>>>>9"
calldscr(X_rp-by-call.call_id) COLUMN-LABEL {&LABEL-call} FORMAT "X(255)" WIDTH 45
X_rule-profile.name COLUMN-LABEL "Название" FORMAT "X(255)" WIDTH 45
X_rule-profile.profile-type COLUMN-LABEL "Тип профайла" FORMAT "X(50)"
X_rp-by-call.once-more COLUMN-LABEL "№ привязки" FORMAT ">9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 17 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 24 WIDGET-ID 12
     b-sel AT ROW 1 COL 28 WIDGET-ID 10
     b-add AT ROW 1 COL 38 WIDGET-ID 2
     b-del AT ROW 1 COL 58 WIDGET-ID 8
     B-Help AT ROW 1 COL 95
     br-rp-by-call AT ROW 2.33 COL 1 WIDGET-ID 100
     EDITOR-1 AT ROW 19.5 COL 1 NO-LABEL WIDGET-ID 16
     mark-num AT ROW 1 COL 13 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     SPACE(75.24) SKIP(21.21)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Привязка профайлов"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_rp-by-call B "?" ? ub rp-by-call
      TABLE: X_rule B "?" ? ub rule
      TABLE: X_rule-by-profile B "?" ? ub rule-by-profile
      TABLE: X_rule-profile B "?" ? ub rule-profile
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-rp-by-call B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-rp-by-call
/* Query rebuild information for BROWSE br-rp-by-call
     _START_FREEFORM
OPEN QUERY br-rp-by-call FOR EACH X_rp-by-call, FIRST X_rule-profile, FIRST X_rule-by-profile.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-rp-by-call */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Привязка профайлов */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Привязка профайлов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  run proc-b-add in this-procedure no-error.
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
  if not available X_rp-by-call then return no-apply.
  v-rec = recid(X_rp-by-call).
  message "Вы уверены, что хотите удалить привязку ПРОФАЙЛА?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then return no-apply.
  run rul/rp-by-call3.p (
                            input no /*p-silent*/
                           ,input v-rec
                              ) no-error.
  if error-status:error then return no-apply.
  RUn Openbr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
    define variable glog as logical no-undo .
  if available X_rp-by-call then do:
 { gbl/markstrn.i X_rp-by-call v-rid-list }
  glog = br-rp-by-call:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-rp-by-call:select-next-row ().
      apply "VALUE-CHANGED" to br-rp-by-call in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-rp-by-call in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available X_rp-by-call then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_rp-by-call ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-rp-by-call
&Scoped-define SELF-NAME br-rp-by-call
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-rp-by-call Dialog-Frame
ON VALUE-CHANGED OF br-rp-by-call IN FRAME Dialog-Frame
DO:
  IF AVAILABLE X_rule-profile THEN DO:
    editor-1:SCREEN-VALUE = X_rule-profile.name.
  END.
  ELSE DO:
    editor-1:SCREEN-VALUE = '':U.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

ON ROW-DISPLAY OF br-rp-by-call IN frame {&frame-name}
DO:
  IF AVAIL X_rp-by-call THEN DO:
    RUN set-row-color IN THIS-PROCEDURE ( INPUT X_rp-by-call.parent-profile_id).
  END.
END.


{ gbl/brwrefre.i " v-doc-rec = recid(X_rp-by-call).  ~
  RUn OpenBR in this-procedure.  REPOSITION br-rp-by-call to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to br-rp-by-call. " }

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
  run gbl/dftempl.p ( input {&table_rule-by-profile}, output template-recid) no-error.
  run Myenable in this-procedure .
  if return-value = "return" then return.
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
  DISPLAY EDITOR-1 mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel b-add b-del B-Help br-rp-by-call EDITOR-1 mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIAble v-ch AS HANDLE NO-UNDO.
ASSIGN
v-ch = br-rp-by-call:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
REPEAT WHILE valid-handle(v-ch):
   IF v-ch:LABEL = {&label-call} THEN do:
     v-ch:resizable  = yes.
     if lookup("call-id", p-list-mode) > 0 then
     v-ch:visible = no.
   end.
   v-ch = v-ch:NEXT-COLUMN.

END.
case p-list-mode:
  when "profile-id" then do:
    X_rule-profile.profile-type:visible in browse br-rp-by-call = no.
  end.
  when "profile-type" then do:
    X_rule-profile.profile-type:visible in browse br-rp-by-call = no.
  end.
  when "call-id" then do:
    X_rule-profile.profile-type:visible in browse br-rp-by-call = no.
  end.
  when "call-id,codex-id" then do:
    X_rule-profile.profile-type:visible in browse br-rp-by-call = no.
  end.
  when "call-id,ruleset-id" then do:
    X_rule-profile.profile-type:visible in browse br-rp-by-call = no.
    X_rule-profile.name:width = 70.
  end.
end case.
assign
X_rule-profile.name:resizable in browse br-rp-by-call = yes
.
ENABLE
b-quit
b-add when (p-list-mode = "profile-id" and v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction)
b-del when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction)
B-Help
b-mark when lookup("b-mark", bttns) > 0
b-sel when lookup("b-sel", bttns) > 0
br-rp-by-call
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
run Openbr in this-procedure .
if return-value = "return" then do:
  return "return".
end.
APPLY "VALUE-CHANGED" to br-rp-by-call.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
define variable v-recid as recid no-undo .
define variable v-ii as integer no-undo .
CASE p-list-mode:
  WHEN {&ALL} THEN DO:
    frame {&frame-name} :title = "Все профайлы по всем типам вызовов".
    OPEN QUERY br-rp-by-call
    FOR EACH X_rp-by-call NO-LOCK
      , FIRST X_rule-profile NO-LOCK WHERE
              X_rule-profile.profile_id = X_rp-by-call.profile_id
      , first X_rule-by-profile no-lock where
             recid(X_rule-by-profile) = template-recid
    INDEXED-REPOSITION.
  END.
  WHEN "profile-id" THEN DO:
    frame {&frame-name} :title = substitute("Вызовы для профайла правил &1", p-profile-id).
    OPEN QUERY br-rp-by-call
    FOR EACH X_rp-by-call NO-LOCK WHERE
            X_rp-by-call.profile_id = p-profile-id
        , FIRST X_rule-profile NO-LOCK WHERE
             X_rule-profile.profile_id = X_rp-by-call.profile_id
      , first X_rule-by-profile no-lock where
             recid(X_rule-by-profile) = template-recid
        INDEXED-REPOSITION.
  END.
  WHEN "profile-type" THEN DO:
    frame {&frame-name} :title = substitute("Вызовы для профайла правил типа &1", p-profile-type).
    OPEN QUERY br-rp-by-call
    FOR EACH X_rp-by-call NO-LOCK WHERE
        , FIRST X_rule-profile NO-LOCK WHERE
             X_rule-profile.profile-type = p-profile-type
      , first X_rule-by-profile no-lock where
             recid(X_rule-by-profile) = template-recid
        INDEXED-REPOSITION.

  END.
  WHEN "call-id" THEN DO:
    frame {&frame-name} :title = substitute("Профайлы для &1", calldscr  ( input p-call-id)).
    OPEN QUERY br-rp-by-call
    FOR EACH X_rp-by-call NO-LOCK WHERE X_rp-by-call.call_id = p-call-id
        , FIRST X_rule-profile NO-LOCK WHERE
             X_rule-profile.profile_id = X_rp-by-call.profile_id
      , first X_rule-by-profile no-lock where
             recid(X_rule-by-profile) = template-recid
        INDEXED-REPOSITION.

  END.
  WHEN "call-id,codex-id" THEN DO:
    frame {&frame-name} :title = substitute("Профайлы для &1", calldscr  ( input p-call-id)).
    OPEN QUERY br-rp-by-call
    FOR EACH X_rp-by-call NO-LOCK WHERE X_rp-by-call.call_id = p-call-id
        , FIRST X_rule-profile NO-LOCK WHERE
             X_rule-profile.profile_id = X_rp-by-call.profile_id
      , first X_rule-by-profile no-lock where
             X_rule-by-profile.profile_id = X_rp-by-call.profile_id
         and X_rule-by-profile.codex_id = p-codex-id
        INDEXED-REPOSITION.

  END.
  WHEN "call-id,ruleset-id" THEN DO:
    frame {&frame-name} :title = substitute("Профайлы для &1", calldscr  ( input p-call-id)).
    if lookup("instant", bttns) > 0
    and lookup("b-sel", bttns) > 0
    then do:
      FOR EACH X_rp-by-call NO-LOCK WHERE X_rp-by-call.call_id = p-call-id
        , FIRST X_rule-profile NO-LOCK WHERE
             X_rule-profile.profile_id = X_rp-by-call.profile_id
      , first X_rule-by-profile no-lock where
             X_rule-by-profile.profile_id = X_rp-by-call.profile_id
         and X_rule-by-profile.codex_id = p-codex-id
         and X_rule-by-profile.ruleset_id = p-ruleset-id:
        v-recid = recid(X_rp-by-call).
        v-ii = v-ii + 1.
      end.
      if v-ii = 0 then do:
        message
        "Нет ни одного настроенного профайла!" skip(0)
        "Профайлы настраиваются в Группе меню Администратор - глобальные или объектный параметр <Машина правил (встраиваемые процедуры)>"
        view-as alert-box.
        return "return".
      end.
      if v-ii = 1 then do:
        find first X_rp-by-call where
                  recid(X_rp-by-call) = v-recid.
        apply "choose" to b-sel.
        return "return".
      end.
    end.
    OPEN QUERY br-rp-by-call
    FOR EACH X_rp-by-call NO-LOCK WHERE X_rp-by-call.call_id = p-call-id
        , FIRST X_rule-profile NO-LOCK WHERE
             X_rule-profile.profile_id = X_rp-by-call.profile_id
      , first X_rule-by-profile no-lock where
             X_rule-by-profile.profile_id = X_rp-by-call.profile_id
         and X_rule-by-profile.codex_id = p-codex-id
         and X_rule-by-profile.ruleset_id = p-ruleset-id
        INDEXED-REPOSITION.

  END.
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
define variable v-rid-list as character no-undo .
define variable v-rec as recid no-undo .
define variable v-ok as logical no-undo .
define buffer buf_rule-profile for dictdb.rule-profile.
if p-list-mode = "profile-id" then do:
  message "Еще не реализовано"
  view-as alert-box error .
  return error.
  /*
  if error-status:error then do:
    undo, return error .
  end.
  run openbr in this-procedure .
  reposition br-rp-by-call to recid v-rec no-error.
  APPLY "ENTRY" to browse br-rp-by-call.
  */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color Dialog-Frame
PROCEDURE set-row-color :
DEFINE INPUT PARAMETER p-parent-profile-id AS integer NO-UNDO.
if p-parent-profile-id > 0 then do:
  assign
  X_rule-profile.name:BGCOLOR IN BROWSE {&BROWSE-NAME} = GRAY_COLOR
    .
end.
else do:
  assign
  X_rule-profile.name:BGCOLOR IN BROWSE {&BROWSE-NAME} = ?
    .
end.

END PROCEDURE.