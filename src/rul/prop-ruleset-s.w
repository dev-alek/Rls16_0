&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_prop-head FOR ub.prop-head.
DEFINE BUFFER X_prop-ruleset FOR ub.prop-ruleset.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список prop-ruleset


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
/*{&all} "ruleset" "dtm-code"*/
DEFINE INPUT PARAMETER p-codex-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-ruleset-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-dtm-code AS INTEGER NO-UNDO.
define input-output parameter p-rid-list as character no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список prop-ruleset".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
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
&Scoped-define BROWSE-NAME br-prop-ruleset

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_prop-head X_prop-ruleset

/* Definitions for BROWSE br-prop-ruleset                               */
&Scoped-define FIELDS-IN-QUERY-br-prop-ruleset mark-string(recid(X_prop-ruleset), v-rid-list) X_prop-ruleset.codex_id X_prop-ruleset.ruleset_id X_prop-ruleset.dtm-code X_prop-head.prop-name X_prop-head.prop-label X_prop-ruleset.is_dynamic
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-prop-ruleset
&Scoped-define SELF-NAME br-prop-ruleset
&Scoped-define QUERY-STRING-br-prop-ruleset FOR EACH X_prop-ruleset NO-LOCK, first X_prop-head NO-LOCK indexed-reposition
&Scoped-define OPEN-QUERY-br-prop-ruleset OPEN QUERY {&SELF-NAME} FOR EACH X_prop-ruleset NO-LOCK, first X_prop-head NO-LOCK indexed-reposition.
&Scoped-define TABLES-IN-QUERY-br-rule X_prop-head X_prop-ruleset
&Scoped-define FIRST-TABLE-IN-QUERY-br-rule X_prop-ruleset
&Scoped-define SECOND-TABLE-IN-QUERY-br-rule X_prop-head

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-prop-ruleset}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-chg b-del b-lkp ~
B-Help br-prop-ruleset mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

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

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
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

DEFINE VARIABLE mark-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9 BY .67
     FGCOLOR 10  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-prop-ruleset FOR
      X_prop-ruleset, X_prop-head SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-prop-ruleset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-prop-ruleset Dialog-Frame _FREEFORM
 QUERY br-prop-ruleset  DISPLAY
      mark-string(recid(X_prop-ruleset), v-rid-list)
X_prop-ruleset.codex_id COLUMN-LABEL "Кодекс!правил" FORMAT ">>>>>>>>9"
X_prop-ruleset.ruleset_id COLUMN-LABEL "Набор!правил" FORMAT ">>>>>>>>9"
X_prop-ruleset.dtm-code COLUMN-LABEL "Код!объекта" FORMAT ">>>>>>>>9"
X_prop-head.prop-name COLUMN-LABEL "Имя объекта" format "X(32)"
X_prop-head.prop-label COLUMN-LABEL "Лейбл объекта" format "X(255)"
     width 45
X_prop-ruleset.is_dynamic COLUMN-LABEL "Отключаемый" FORMAT "+/"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 20.53 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 24 WIDGET-ID 12
     b-sel AT ROW 1 COL 28 WIDGET-ID 10
     b-add AT ROW 1 COL 38 WIDGET-ID 2
     b-chg AT ROW 1 COL 48 WIDGET-ID 4
     b-del AT ROW 1 COL 58 WIDGET-ID 8
     b-lkp AT ROW 1 COL 68 WIDGET-ID 6
     B-Help AT ROW 1 COL 88
     br-prop-ruleset AT ROW 2.33 COL 1.5 WIDGET-ID 100
     mark-num AT ROW 1 COL 13 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     SPACE(74.50) SKIP(21.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Привязка объектов-операндов к кодексам/наборам правил"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_prop-head B "?" ? ub prop-head
      TABLE: X_prop-ruleset B "?" ? ub prop-ruleset
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-prop-ruleset B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-prop-ruleset
/* Query rebuild information for BROWSE br-prop-ruleset
     _START_FREEFORM
RUN openbr IN THIS-PROCEDURE.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-prop-ruleset */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Привязка объектов к ruleset */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Привязка объектов к ruleset */
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
  if not available X_prop-ruleset then return no-apply.
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
  if not available X_prop-ruleset then return no-apply.
  v-rec = recid(X_prop-ruleset).
  message "Вы уверены, что хотите удалить привязку СКРИПТА К наборам правил?"
  view-as alert-box QUESTION buttons yes-no  update glog.
  if not glog then return no-apply.
  run rul/prop-ruleset3.p ( input v-rec
                           ,input no /*p-silent*/
                              ) no-error.
  if error-status:error then return no-apply.
  Run Openbr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  define variable v-rec as recid no-undo.
  if not available X_prop-ruleset then return no-apply.
  v-rec = recid(X_prop-ruleset).
  run rul/prop-head-i.w ( input parparentproc
                       ,input {&lookup}
                       ,input X_prop-ruleset.dtm-code
                       ,input-output v-rec) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
define variable glog as logical no-undo .
  if available X_prop-ruleset then do:
 { gbl/markstrn.i X_prop-ruleset v-rid-list }
  glog = br-prop-ruleset:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-prop-ruleset:select-next-row ().
      apply "VALUE-CHANGED" to br-prop-ruleset in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-prop-ruleset in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available X_prop-ruleset then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_prop-ruleset ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-prop-ruleset
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/brwrefre.i " v-doc-rec = recid(X_prop-ruleset).  ~
  RUn OpenBR in this-procedure.  REPOSITION br-prop-ruleset to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to br-prop-ruleset. " }

{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  v-rid-list = p-rid-list.
  { gbl/getcntxt.i get }
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
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel b-add b-chg b-del b-lkp B-Help br-prop-ruleset
         mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
assign
X_prop-head.prop-name :resizable in browse br-prop-ruleset = yes
X_prop-head.prop-label:resizable in browse br-prop-ruleset = yes
.
ENABLE
b-quit
b-add when ((p-list-mode = "ruleset" or p-list-mode = "dtm-code" and v-cntxt-db-num = 0) and lookup("b-add", bttns) > 0)
b-chg when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-del when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-lkp
B-Help
b-mark when (v-cntxt-db-num = 0 and lookup("b-mark", bttns) > 0)
b-sel when (v-cntxt-db-num = 0 and lookup("b-sel", bttns) > 0)
br-prop-ruleset
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
run Openbr in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
CASE p-list-mode:
  WHEN {&ALL} THEN DO:
    OPEN QUERY br-prop-ruleset
    FOR EACH X_prop-ruleset NO-LOCK,
       FIRST X_prop-head NO-LOCK WHERE
            X_prop-head.dtm-code = X_prop-ruleset.dtm-code INDEXED-REPOSITION.
  END.
  WHEN "ruleset" THEN DO:
    OPEN QUERY br-prop-ruleset
    FOR EACH X_prop-ruleset NO-LOCK WHERE
             X_prop-ruleset.codex_id = p-codex-id
          AND X_prop-ruleset.ruleset_id = p-codex-id,
        FIRST X_prop-head NO-LOCK WHERE
            X_prop-head.dtm-code = X_prop-ruleset.dtm-code INDEXED-REPOSITION.

  END.
  WHEN "dtm-code" THEN DO:
    OPEN QUERY br-prop-ruleset
    FOR EACH X_prop-ruleset NO-LOCK WHERE
            X_prop-ruleset.dtm-code = p-dtm-code,
        FIRST X_prop-head NO-LOCK WHERE
            X_prop-head.dtm-code = X_prop-ruleset.dtm-code INDEXED-REPOSITION.

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
define variable v-ok as logical no-undo .
define variable v-ii as integer no-undo .
define variable v-is-dynamic as logical no-undo .
define buffer buf_prop-head for dictdb.prop-head.
define buffer buf_ruleset for dictdb.ruleset.
CASE p-add:
  when yes then do:
    if p-list-mode = "ruleset" then do:
      run rul/prop-head-s.w ( input parparentproc
                            ,input "b-sel,b-mark"
                            ,input {&all}
                            ,input '':U /*p-general-view*/
                            ,input-output v-rid-list) no-error.
      if v-rid-list = '':U then do:
        return.
      end.
      do v-ii = 1 to num-entries(v-rid-list ):
        find first buf_prop-head no-lock where
                  recid(buf_prop-head) = integer(entry(v-ii, v-rid-list)).
        run gbl/d-logical.w ( input ? /*h-callback*/
                            ,input ('title=':u +
                                    substitute("Привязка объекта &1 к кодексу &2 набор правил &3"
                                               , buf_prop-head.prop-name
                                               , p-codex-id
                                               , p-ruleset-id) + '\':u
                                    +  'text1=':u + "Свойство ОТКЛЮЧАЕМЫЙ" + '\':u)
                            ,input-output v-is-dynamic
                            ,output v-ok ) no-error.
        if error-status:error
        or not v-ok then do:
          undo, return error .
        end.
        run rul/prop-ruleset1.p ( input {&add-def}
                                  ,input no /*p-silent*/
                                  ,input-output v-rec
                                  ,input p-codex-id
                                  ,input p-ruleset-id
                                  ,input buf_prop-head.dtm-code
                                  ,input v-is-dynamic) no-error.
        if error-status:error then do:
          undo, return error .
        end.
      end.
    end.
    if p-list-mode = "dtm-code" then do:
      run rul/ruleset-s.w ( input parparentproc
                            ,input "b-sel,b-mark"
                            ,input "only-ruleset"
                            ,input 0 /*p-codex-id*/
                            ,input-output v-rid-list) no-error.
      if v-rid-list = '':U then do:
        return.
      end.
      do v-ii = 1 to num-entries(v-rid-list):
        find first buf_ruleset no-lock where
                recid(buf_ruleset) = integer(entry(v-ii, v-rid-list)).
        run gbl/d-logical.w ( input ? /*h-callback*/
                            ,input ('title=':u +
                                    substitute("Привязка объекта &1 к кодексу &2 набор правил &3"
                                               , p-dtm-code
                                               , buf_ruleset.codex_id
                                               , buf_ruleset.ruleset_id) + '\':u
                                    +  'text1=':u + "Свойство ОТКЛЮЧАЕМЫЙ" + '\':u)
                            ,input-output v-is-dynamic
                            ,output v-ok ) no-error.
        if error-status:error
        or not v-ok then do:
          undo, return error .
        end.
        run rul/prop-ruleset1.p ( input {&add-def}
                                  ,input no /*p-silent*/
                                  ,input-output v-rec
                                  ,input buf_ruleset.codex_id
                                  ,input buf_ruleset.ruleset_id
                                  ,input p-dtm-code
                                  ,input v-is-dynamic) no-error.
        if error-status:error then do:
          undo, return error .
        end.
      end.
    end.
    run openbr in this-procedure .
    reposition br-prop-ruleset to recid v-rec no-error.
    APPLY "ENTRY" to browse br-prop-ruleset.
  end.
  when no then do:
    run gbl/d-logical.w ( input ? /*h-callback*/
                        ,input 'title=':u + "Задайте свойство ОТКЛЮЧАЕМЫЙ" + '\':u
                        ,input-output v-is-dynamic
                        ,output v-ok ) no-error.
    if error-status:error
    or not v-ok then do:
      undo, return error .
    end.
    v-rec = recid(x_prop-ruleset).
    run rul/prop-ruleset1.p ( input {&update}
                              ,input no /*p-silent*/
                              ,input-output v-rec
                              ,input X_prop-ruleset.codex_id
                              ,input X_prop-ruleset.ruleset_id
                              ,input X_prop-ruleset.dtm-code
                              ,input v-is-dynamic) no-error.
    if error-status:error then do:
      undo, return error .
    end.
    run openbr in this-procedure .
    reposition br-prop-ruleset to recid v-rec no-error.
    APPLY "ENTRY" to browse br-prop-ruleset.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME