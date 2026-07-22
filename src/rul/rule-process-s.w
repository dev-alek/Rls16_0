&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_rule-process FOR ub.rule-process.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список rule-process

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/15/08
Author: Bakhtadze Natalya
Creation date: 07/15/08

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns as character no-undo.
define input parameter p-list-mode as character no-undo .
/*{&all}  pchain-type*/
define input parameter p-pchain-type as character no-undo .
define input-output parameter p-rid-list as character no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список rule-process".
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
DEFINE VARIABLE lkp-option AS CHARACTER NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-rule-process

/* Definitions for BROWSE br-rule-process                               */
&Scoped-define FIELDS-IN-QUERY-br-rule-process mark-string(recid(X_rule-process), v-rid-list) X_rule-process.pchain-type X_rule-process.pchain-id X_rule-process.start-from X_rule-process.link-id X_rule-process.codex_id X_rule-process.ruleset_id X_rule-process.run-db0 X_rule-process.run-rdb X_rule-process.link-btwn-profiles X_rule-process.is-export X_rule-process.is-import X_rule-process.needs-efile X_rule-process.needs-ifile
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-rule-process
&Scoped-define SELF-NAME br-rule-process
&Scoped-define OPEN-QUERY-br-rule-process RUN openbr IN THIS-PROCEDURE.

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-rule-process}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-copy b-chg b-del ~
b-lkp B-Help br-rule-process mark-num
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

DEFINE BUTTON b-copy
     LABEL "&Копия"
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
DEFINE QUERY br-rule-process FOR
      X_rule-process SCROLLING.
&ANALYZE-RESUME



/* Browse definitions                                                   */
DEFINE BROWSE br-rule-process
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-rule-process Dialog-Frame _FREEFORM
 QUERY br-rule-process NO-LOCK  DISPLAY
      mark-string(recid(X_rule-process), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_rule-process.pchain-type COLUMN-LABEL "Тип процесса" FORMAT "X(20)"
X_rule-process.pchain-id COLUMN-LABEL "ID" FORMAT "X(30)"
X_rule-process.start-from COLUMN-LABEL "Стар из" FORMAT "99"
X_rule-process.link-id COLUMN-LABEL "LinkID" FORMAT "99"
X_rule-process.codex_id COLUMN-LABEL "Кодекс" FORMAT ">>>>9"
X_rule-process.ruleset_id COLUMN-LABEL "Набор правил" FORMAT ">>>>9"
X_rule-process.run-db0 COLUMN-LABEL "в ГБД" FORMAT "9"
X_rule-process.run-rdb COLUMN-LABEL "в УБД" FORMAT "9"
X_rule-process.link-btwn-profiles COLUMN-LABEL "связь!между!профайлами" FORMAT "9"
X_rule-process.is-export COLUMN-LABEL "Экспорт" FORMAT "9"
X_rule-process.is-import COLUMN-LABEL "Импорт" FORMAT "9"
X_rule-process.needs-efile COLUMN-LABEL "Нужен вых.файл" FORMAT "9"
X_rule-process.needs-ifile COLUMN-LABEL "Нужен вх.файл" FORMAT "9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 20.53 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 20 WIDGET-ID 12
     b-sel AT ROW 1 COL 24 WIDGET-ID 10
     b-add AT ROW 1 COL 34 WIDGET-ID 2
     b-copy AT ROW 1 COL 44 WIDGET-ID 16
     b-chg AT ROW 1 COL 54 WIDGET-ID 4
     b-del AT ROW 1 COL 64 WIDGET-ID 8
     b-lkp AT ROW 1 COL 74 WIDGET-ID 6
     B-Help AT ROW 1 COL 95
     br-rule-process AT ROW 2.33 COL 1.5 WIDGET-ID 100
     mark-num AT ROW 1 COL 11 NO-LABEL WIDGET-ID 14
     SPACE(78.59) SKIP(21.19)
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
      TABLE: X_rule-process B "?" ? ub rule-process
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-rule-process B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-rule-process
/* Query rebuild information for BROWSE br-rule-process
     _START_FREEFORM
RUN openbr IN THIS-PROCEDURE.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-rule-process */
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


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
 define variable v-rec as recid no-undo.
  run rul/rule-process-i.w ( input parparentproc
                       ,input {&add-def}
                       ,input '' /*p-pchain-type*/
                       ,INPUT '' /*p-pchain-id*/
                       ,INPUT 0 /*p-start-from*/
                       ,INPUT 0 /* p-link-id*/
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
    RUN openbr IN THIS-PROCEDURE.
    reposition br-rule-process to recid v-rec no-error.
    apply "entry" to br-rule-process.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  define variable v-rec as recid no-undo.
  if not available X_rule-process then return no-apply.
  v-rec = recid(X_rule-process).
  run rul/rule-process-i.w ( input parparentproc
                       ,input {&update}
                       ,input X_rule-process.pchain-type
                       ,INPUT X_rule-process.pchain-id
                       ,INPUT X_rule-process.start-from
                       ,INPUT X_rule-process.link-id
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
     br-rule-process:refresh().
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-copy Dialog-Frame
ON CHOOSE OF b-copy IN FRAME Dialog-Frame /* Копия */
DO:
 define variable v-rec as recid no-undo.
  if not available X_rule-process then return no-apply.
  v-rec = recid(X_rule-process).
  run rul/rule-process-i.w ( input parparentproc
                       ,input {&add-copy}
                       ,input X_rule-process.pchain-type
                       ,INPUT X_rule-process.pchain-i
                       ,INPUT X_rule-process.start-from
                       ,INPUT X_rule-process.link-id
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
    RUN openbr IN THIS-PROCEDURE.
    reposition br-rule-process to recid v-rec no-error.
    apply "entry" to br-rule-process.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  define variable v-rec as recid no-undo.
  define variable glog as logical no-undo.
  if not available X_rule-process then return no-apply.
  v-rec = recid(X_rule-process).
  message
  "Вы уверены, что хотите удалить профайл?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then return no-apply.
 run rul/rule-process3.p (
                           input no /*p-silent*/
                          ,input v-rec
                          ) no-error.
 if error-status:error then return no-apply.
 run Openbr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:

if not available X_rule-process then return no-apply.
run proc-b-lkp IN THIS-PROCEDURE ( INPUT {&table_rule-process}) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
    lkp-option = '':U.
    RETURN NO-APPLY.
END.
lkp-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable glog as logical no-undo .
  if available X_rule-process then do:
 { gbl/markstrn.i X_rule-process v-rid-list }
  glog = br-rule-process:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-rule-process:select-next-row ().
      apply "VALUE-CHANGED" to br-rule-process in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-rule-process in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available X_rule-process then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_rule-process ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-rule-process
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/brwrefre.i " v-doc-rec = recid(X_rule-process).  ~
  RUn OpenBR in this-procedure.  REPOSITION br-rule-process to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to br-rule-process. " }

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
  ENABLE b-quit b-mark b-sel b-add b-copy b-chg b-del b-lkp B-Help
         br-rule-process mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
X_rule-process.pchain-type:RESIZABLE IN BROWSE br-rule-process = YES
X_rule-process.pchain-id:RESIZABLE IN BROWSE br-rule-process = YES
.
ENABLE
b-quit
b-add when (lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0)
b-copy when (lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0)
b-chg when (lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0)
b-del when (lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0)
b-lkp
B-Help
b-mark when lookup("b-mark", bttns) > 0
b-sel when lookup("b-sel", bttns) > 0
br-rule-process
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
if p-list-mode = "pchain-type" then do:
  assign
  X_rule-process.pchain-type:visible in browse br-rule-process = no.
end.
run Openbr in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
CASE p-list-mode:
   when {&all} then do:
      frame {&frame-name} :title = "Все звенья процессов".
      OPEN QUERY br-rule-process
      FOR EACH X_rule-process NO-LOCK INDEXED-REPOSITION.
   end.
   when "pchain-type" then do:
      frame {&frame-name} :title = substitute("Звенья процессов типа &1", p-pchain-type).
      OPEN QUERY br-rule-process
      FOR EACH X_rule-process NO-LOCK where
               X_rule-process.pchain-type = p-pchain-type
     INDEXED-REPOSITION
      .
   end.

end case.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lkp Dialog-Frame
PROCEDURE proc-b-lkp :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
define variable v-rec as recid no-undo.
CASE p-option:
  WHEN {&TABLE_rule-process} THEN DO:
      run rul/rule-process-i.w ( input parparentproc
                           ,input {&lookup}
                           ,input X_rule-process.pchain-type
                           ,INPUT X_rule-process.pchain-id
                           ,INPUT X_rule-process.start-from
                           ,INPUT X_rule-process.link-id
                           ,input-output v-rec) no-error.

  END.
END CASE.
IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME