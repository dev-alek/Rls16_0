&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_rule FOR ub.rule.
DEFINE BUFFER X_rule-i-script FOR ub.rule-i-script.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список rule-i-script


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
/*{&all} "rule" "script-name"*/
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-script-type AS character NO-UNDO.
DEFINE INPUT PARAMETER p-script-name AS character NO-UNDO.
define input-output parameter p-rid-list as character no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список rule-i-script".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable v-rid-list as character no-undo .
DEFINE VARIABLE rule-script-language AS CHARACTER NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-rule-i-script

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_rule-i-script X_rule

/* Definitions for BROWSE br-rule-i-script                              */
&Scoped-define FIELDS-IN-QUERY-br-rule-i-script mark-string(recid(X_rule-i-script), v-rid-list) X_rule-i-script.script_id X_rule-i-script.i-script-type X_rule-i-script.i-script-name X_rule-i-script.script-type X_rule-i-script.script-name X_rule-i-script.root_rule_id X_rule-i-script.dtm-code X_rule-i-script.class-dtm-code X_rule.name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-rule-i-script
&Scoped-define SELF-NAME br-rule-i-script
&Scoped-define QUERY-STRING-br-rule-i-script FOR EACH X_rule-i-script, ~
       FIRST X_rule
&Scoped-define OPEN-QUERY-br-rule-i-script OPEN QUERY br-rule-i-script FOR EACH X_rule-i-script, ~
       FIRST X_rule.
&Scoped-define TABLES-IN-QUERY-br-rule-i-script X_rule-i-script X_rule
&Scoped-define FIRST-TABLE-IN-QUERY-br-rule-i-script X_rule-i-script
&Scoped-define SECOND-TABLE-IN-QUERY-br-rule-i-script X_rule


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-rule-i-script}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-del b-text-2 b-text ~
b-rule-script B-Help br-rule-i-script EDITOR-2 EDITOR-1 mark-num
&Scoped-Define DISPLAYED-OBJECTS EDITOR-2 EDITOR-1 mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-rule-scirpt
       MENU-ITEM m_abl          LABEL "ABL"
       MENU-ITEM m_rus          LABEL "RUS"           .


/* Definitions of the field level widgets                               */
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

DEFINE BUTTON b-rule-script
     LABEL "Изм rule-script"
     SIZE 12 BY 1
     FONT 4.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1.

DEFINE BUTTON b-text
     LABEL "Изм.scirpt-name"
     SIZE 12 BY 1
     FONT 4.

DEFINE BUTTON b-text-2
     LABEL "Изм.i-script-name"
     SIZE 12 BY 1
     FONT 4.

DEFINE VARIABLE EDITOR-1 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2.42 NO-UNDO.

DEFINE VARIABLE EDITOR-2 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2.42 NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 10  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-rule-i-script FOR
      X_rule-i-script,
      X_rule SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-rule-i-script
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-rule-i-script Dialog-Frame _FREEFORM
  QUERY br-rule-i-script NO-LOCK DISPLAY
      mark-string(recid(X_rule-i-script), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_rule-i-script.script_id COLUMN-LABEL "Код" FORMAT ">>>>>>>>9"
X_rule-i-script.i-script-type COLUMN-LABEL "Тип!скрипта!в правиле" FORMAT "X(255)" WIDTH 20
X_rule-i-script.i-script-name COLUMN-LABEL "Скрипт!в правиле" FORMAT "X(255)"  WIDTH 45
X_rule-i-script.script-type COLUMN-LABEL "Тип!скрипта" FORMAT "X(255)" WIDTH 20
X_rule-i-script.script-name COLUMN-LABEL "Скрипт" FORMAT "X(255)"  WIDTH 45
X_rule-i-script.root_rule_id COLUMN-LABEL "№ правила" FORMAT ">>>>>>>>9"
X_rule-i-script.dtm-code COLUMN-LABEL "Код объекта!операнда" FORMAT ">>9"
X_rule-i-script.class-dtm-code COLUMN-LABEL "Код объекта!операнда!обслуж.класса" FORMAT ">>9"
X_rule.name COLUMN-LABEL "Правило" FORMAT "X(255)"  WIDTH 45
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 20 WIDGET-ID 12
     b-sel AT ROW 1 COL 24 WIDGET-ID 10
     b-del AT ROW 1 COL 34 WIDGET-ID 18
     b-text-2 AT ROW 1 COL 44 WIDGET-ID 24
     b-text AT ROW 1 COL 56 WIDGET-ID 22
     b-rule-script AT ROW 1 COL 68 WIDGET-ID 26
     B-Help AT ROW 1 COL 95
     br-rule-i-script AT ROW 2 COL 1 WIDGET-ID 100
     EDITOR-2 AT ROW 18 COL 1 NO-LABEL WIDGET-ID 20
     EDITOR-1 AT ROW 20.46 COL 1 NO-LABEL WIDGET-ID 16
     mark-num AT ROW 1 COL 10 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     SPACE(79.50) SKIP(21.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Привязка правил к наборам"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_rule B "?" ? ub rule
      TABLE: X_rule-i-script B "?" ? ub rule-i-script
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-rule-i-script B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-rule-script:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-rule-scirpt:HANDLE.

ASSIGN
       EDITOR-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       EDITOR-2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-rule-i-script
/* Query rebuild information for BROWSE br-rule-i-script
     _START_FREEFORM
OPEN QUERY br-rule-i-script FOR EACH X_rule-i-script, FIRST X_rule.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-rule-i-script */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Привязка правил к наборам */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Привязка правил к наборам */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
define buffer buf_rule-i-script for ub.rule-i-script.
IF NOT AVAILABLE X_rule-i-script THEN RETURN NO-APPLY.
MESSAGE
"Вы уверены, что хотите удалить привязку?"
VIEW-AS ALERT-BOX QUESTION
BUTTONS YES-NO UPDATE glog.
IF NOT glog THEN DO:
  RETURN NO-APPLY.
END.
find first buf_rule-i-script exclusive-lock where
          recid(buf_rule-i-script) = recid(X_rule-i-script).
DELETE buf_rule-i-script.
RUN openbr IN THIS-PROCEDURE .
REPOSITION br-rule-i-script TO ROW 1 NO-ERROR.
APPLY "ENTRY" TO br-rule-i-script.
APPLY "VALUE-CHANGE" TO br-rule-i-script.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
    define variable glog as logical no-undo .
  if available X_rule-i-script then do:
 { gbl/markstrn.i X_rule-i-script v-rid-list }
  glog = br-rule-i-script:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-rule-i-script:select-next-row ().
      apply "VALUE-CHANGED" to br-rule-i-script in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-rule-i-script in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-rule-script
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rule-script Dialog-Frame
ON CHOOSE OF b-rule-script IN FRAME Dialog-Frame /* Изм rule-script */
DO:

  if not available X_rule-i-script then return no-apply.
  IF rule-script-language = '':U THEN DO:
    run gbl/pop-up.p ( INPUT SELF :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if rule-script-language = '':U then do:
      return no-apply.
  end.
  run proc-b-rule-script IN THIS-PROCEDURE ( INPUT rule-script-language) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rule-script-language = ?.
      RETURN NO-APPLY.
  END.
  rule-script-language = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available X_rule-i-script then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_rule-i-script ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-text
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-text Dialog-Frame
ON CHOOSE OF b-text IN FRAME Dialog-Frame /* Изм.scirpt-name */
DO:
  DEFINE VARIABLE v-longchar AS LONGCHAR NO-UNDO.
  DEFINE VARIABLE v-ok AS LOGical NO-UNDO.
  DEFINE BUFFER buf_rule-i-script FOR ub.rule-i-script.
  if not available X_rule-i-script then return no-apply.
  v-longchar = X_rule-i-script.script-name.
     run gbl/d-longchar.w (
                           INPUT ? /*h-callback*/
                          ,INPUT '':U      /*p-parameters*/
                          ,input-output v-longchar
                          ,output v-ok
                           ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   OR NOT v-ok THEN undo, RETURN NO-apply.
   FIND FIRST buf_rule-i-script WHERE
            recid(buf_rule-i-script) = RECID(X_rule-i-script).
   ASSIGN
   buf_rule-i-script.script-name = v-longchar.
   v-longchar = '':U.
   br-rule-i-script:REFRESH()
   .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-text-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-text-2 Dialog-Frame
ON CHOOSE OF b-text-2 IN FRAME Dialog-Frame /* Изм.i-script-name */
DO:
  DEFINE VARIABLE v-longchar AS LONGCHAR NO-UNDO.
  DEFINE VARIABLE v-ok AS LOGical NO-UNDO.
  DEFINE BUFFER buf_rule-i-script FOR ub.rule-i-script.
  if not available X_rule-i-script then return no-apply.
  v-longchar = X_rule-i-script.i-script-name.
     run gbl/d-longchar.w (
                           INPUT ? /*h-callback*/
                          ,INPUT '':U      /*p-parameters*/
                          ,input-output v-longchar
                          ,output v-ok
                           ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   OR NOT v-ok THEN undo, RETURN NO-apply.
   FIND FIRST buf_rule-i-script WHERE
            recid(buf_rule-i-script) = RECID(X_rule-i-script).
   ASSIGN
   buf_rule-i-script.i-script-name = v-longchar.
   v-longchar = '':U.
   br-rule-i-script:REFRESH().

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-rule-i-script
&Scoped-define SELF-NAME br-rule-i-script
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-rule-i-script Dialog-Frame
ON VALUE-CHANGED OF br-rule-i-script IN FRAME Dialog-Frame
DO:
  IF AVAILABLE X_rule THEN DO:
    editor-1:SCREEN-VALUE = X_rule.documentation.
  END.
  ELSE DO:
    editor-1:SCREEN-VALUE = '':U.
  END.
IF AVAILABLE X_rule-i-script THEN DO:
    editor-2:SCREEN-VALUE = X_rule-i-script.script-name.
  END.
  ELSE DO:
    editor-2:SCREEN-VALUE = '':U.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_abl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_abl Dialog-Frame
ON CHOOSE OF MENU-ITEM m_abl /* ABL */
DO:
    ASSIGN
  rule-script-language = "ABL".
  RUN proc-b-rule-script IN THIS-PROCEDURE ( INPUT rule-script-language) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rule-script-language = '':U.
      RETURN NO-APPLY.
  END.
  rule-script-language = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_rus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_rus Dialog-Frame
ON CHOOSE OF MENU-ITEM m_rus /* RUS */
DO:
    ASSIGN
  rule-script-language = "RUS".
  RUN proc-b-rule-script IN THIS-PROCEDURE ( INPUT rule-script-language) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rule-script-language = '':U.
      RETURN NO-APPLY.
  END.
  rule-script-language = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/brwrefre.i " v-doc-rec = recid(X_rule-i-script).  ~
  RUn OpenBR in this-procedure.  REPOSITION br-rule-i-script to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to br-rule-i-script. " }

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
  ENABLE b-quit b-mark b-sel b-del b-text-2 b-text b-rule-script B-Help
         br-rule-i-script EDITOR-2 EDITOR-1 mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable Dialog-Frame
PROCEDURE Myenable :
assign
X_rule.name:resizable in browse br-rule-i-script = yes
X_rule.name:visible in browse br-rule-i-script = (p-list-mode <> "rule")
X_rule-i-script.script-name:resizable in browse br-rule-i-script = yes
X_rule-i-script.i-script-name:resizable in browse br-rule-i-script = yes
X_rule-i-script.script-type:resizable in browse br-rule-i-script = yes
X_rule-i-script.i-script-type:resizable in browse br-rule-i-script = yes
b-rule-script:menu-mouse in frame {&frame-name} = 1
.
ENABLE
b-quit
B-Help
b-mark when lookup("b-mark", bttns) > 0
b-sel when lookup("b-sel", bttns) > 0
b-del when lookup("b-del", bttns) > 0
b-text when lookup("b-del", bttns) > 0
b-text-2 when lookup("b-del", bttns) > 0
b-rule-script when lookup("b-del", bttns) > 0
editor-1
editor-2
br-rule-i-script
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
run Openbr in this-procedure .
APPLY "VALUE-CHANGED" to br-rule-i-script.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
CASE p-list-mode:
  WHEN {&ALL} THEN DO:
    frame {&frame-name} :title = "Все привязки скриптов по всем правилам".
    OPEN QUERY br-rule-i-script
    FOR EACH X_rule-i-script NO-LOCK
      , FIRST X_rule NO-LOCK  where
              X_rule.RULE_id = X_rule-i-script.root_rule_id
    INDEXED-REPOSITION.
  END.
  WHEN "script-name" THEN DO:
    frame {&frame-name} :title = substitute("Привязка к правилам скрипта &1 &2", p-script-type, p-script-name).
    OPEN QUERY br-rule-i-script
    FOR EACH X_rule-i-script NO-LOCK WHERE
             X_rule-i-script.i-script-type = p-script-type
        and  X_rule-i-script.script-name = p-script-name
        , FIRST X_rule NO-LOCK  where
                X_rule.RULE_id = X_rule-i-script.root_rule_id
        INDEXED-REPOSITION.

  END.
  WHEN "rule" THEN DO:
    frame {&frame-name} :title = substitute("Привязка скриптов к правилу &1", p-rule-id).
    OPEN QUERY br-rule-i-script
    FOR EACH X_rule-i-script NO-LOCK WHERE
            X_rule-i-script.root_rule_id = p-rule-id
        , FIRST X_rule NO-LOCK  where
                X_rule.RULE_id = X_rule-i-script.root_rule_id
        INDEXED-REPOSITION.

 END.

END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-rule-script Dialog-Frame
PROCEDURE proc-b-rule-script :
DEFINE INPUT PARAMETER p-language AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-longchar AS LONGCHAR NO-UNDO.
DEFINE VARIABLE v-ok AS LOGical NO-UNDO.
DEFINE BUFFER buf_rule-script FOR ub.rule-script.
FIND FIRST buf_rule-script WHERE
          buf_rule-script.root_rule_id = X_rule-i-script.root_rule_id
     AND  buf_rule-script.script_id = X_rule-i-script.script_id
     AND  buf_rule-script.language = p-language.
v-longchar = buf_rule-script.script.
     run gbl/d-longchar.w (
                           INPUT ? /*h-callback*/
                          ,INPUT '':U      /*p-parameters*/
                          ,input-output v-longchar
                          ,output v-ok
                           ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   OR NOT v-ok THEN undo, RETURN NO-apply.
   ASSIGN
   buf_rule-script.script = v-longchar.
   .
   v-longchar = '':U.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME