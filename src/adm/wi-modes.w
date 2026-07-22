&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_wi-mode FOR ub.wi-mode.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список РЕЖИМОВ РАБОТЫ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/30/08
Author: Bakhtadze Natalya
Creation date: 09/30/08

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns as character no-undo.
define input parameter p-list-mode as character no-undo .
/*{&all}  mode-type*/
define input parameter p-mode-type as character no-undo .
define input-output parameter p-rid-list as character no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список режимов работы".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/mrk-strf.i }
{ gbl/getcntxt.i def }
{ gbl/key-rec.i }
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable v-admin as logical no-undo .
DEFINE VARIABLE link-option AS CHARACTER NO-UNDO.
define variable v-rid-list as character no-undo .
DEFINE VARIABLE lkp-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE vh-mode-type-name AS HANDLE NO-UNDO.

&SCOPED-DEFINE wi-mode-type-code X_wi-mode.mode-type
&SCOPED-DEFINE label-1 "Тип режима"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-wi-mode

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_wi-mode

/* Definitions for BROWSE br-wi-mode                                    */
&Scoped-define FIELDS-IN-QUERY-br-wi-mode mark-string(recid(X_wi-mode), v-rid-list) {&wi-mode-type-name} X_wi-mode.mode-id X_wi-mode.prev-mode-id X_wi-mode.mode-name X_wi-mode.codex_id X_wi-mode.ruleset_id
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-wi-mode
&Scoped-define SELF-NAME br-wi-mode
&Scoped-define QUERY-STRING-br-wi-mode FOR EACH X_wi-mode NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-wi-mode OPEN QUERY {&SELF-NAME} FOR EACH X_wi-mode NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-wi-mode X_wi-mode
&Scoped-define FIRST-TABLE-IN-QUERY-br-wi-mode X_wi-mode


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-chg b-del b-lkp ~
B-Help br-wi-mode e-des mark-num
&Scoped-Define DISPLAYED-OBJECTS e-des mark-num

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

DEFINE VARIABLE e-des AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 97 BY 4.27 NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9 BY .67
     FGCOLOR 10  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-wi-mode FOR
      X_wi-mode SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-wi-mode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-wi-mode Dialog-Frame _FREEFORM
  QUERY br-wi-mode NO-LOCK DISPLAY
      mark-string(recid(X_wi-mode), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
{&wi-mode-type-name} COLUMN-LABEL {&label-1} FORMAT "X(255)" WIDTH 30
X_wi-mode.mode-id COLUMN-LABEL "ID режима" FORMAT "X(10)"
X_wi-mode.prev-mode-id COLUMN-LABEL "ID пред.!режима" FORMAT "X(10)"
X_wi-mode.mode-name COLUMN-LABEL "Название" FORMAT "X(255)" WIDTH 35
X_wi-mode.codex_id COLUMN-LABEL "Кодекс" FORMAT ">>9"
X_wi-mode.ruleset_id COLUMN-LABEL "Набор!правил" FORMAT ">>>9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 16 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 20 WIDGET-ID 12
     b-sel AT ROW 1 COL 24 WIDGET-ID 10
     b-add AT ROW 1 COL 34 WIDGET-ID 2
     b-chg AT ROW 1 COL 44 WIDGET-ID 4
     b-del AT ROW 1 COL 54 WIDGET-ID 8
     b-lkp AT ROW 1 COL 64 WIDGET-ID 6
     B-Help AT ROW 1 COL 95
     br-wi-mode AT ROW 2.33 COL 1.5 WIDGET-ID 100
     e-des AT ROW 18.6 COL 1.5 NO-LABEL WIDGET-ID 16
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
      TABLE: X_wi-mode B "?" ? ub wi-mode
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-wi-mode B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       e-des:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-wi-mode
/* Query rebuild information for BROWSE br-wi-mode
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_wi-mode NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-wi-mode */
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
  run adm/wi-modei.w ( input parparentproc
                       ,input {&add-def} + {&comma-char} + (if v-admin then "admin" else '')
                       ,input '' /*p-mode-type*/
                       ,input '' /*p-mode-id*/
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
    RUN openbr IN THIS-PROCEDURE.
    APPLY "VALUE-CHANGED" TO br-wi-mode.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  define variable v-rec as recid no-undo.
  if not available X_wi-mode then return no-apply.
  v-rec = recid(X_wi-mode).
  run adm/wi-modei.w ( input parparentproc
                       ,input {&update} + {&comma-char} + (if v-admin then "admin" else '')
                       ,input X_wi-mode.mode-type /*p-mode-type*/
                       ,input X_wi-mode.mode-id
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
     br-wi-mode:refresh().
     APPLY "VALUE-CHANGED" TO br-wi-mode.
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
  if not available X_wi-mode then return no-apply.
  v-rec = recid(X_wi-mode).
  message
  "Вы уверены, что хотите удалить режим?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then return no-apply.
 run adm/wi-mode3.p (
                           input no /*p-silent*/
                          ,input v-rec
                          ) no-error.
 if error-status:error then return no-apply.
 run Openbr in this-procedure .
 APPLY "VALUE-CHANGED" TO br-wi-mode.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:

if not available X_wi-mode then return no-apply.
run proc-b-lkp IN THIS-PROCEDURE ( INPUT {&table_wi-mode}) NO-ERROR.
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
  if available X_wi-mode then do:
 { gbl/markstrn.i X_wi-mode v-rid-list }
  glog = br-wi-mode:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-wi-mode:select-next-row ().
      apply "VALUE-CHANGED" to br-wi-mode in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-wi-mode in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available X_wi-mode then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_wi-mode ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-wi-mode
&Scoped-define SELF-NAME br-wi-mode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-wi-mode Dialog-Frame
ON VALUE-CHANGED OF br-wi-mode IN FRAME Dialog-Frame
DO:
  IF AVAILABLE X_wi-mode THEN DO:
     ASSIGN
     e-des:SCREEN-VALUE = X_wi-mode.des.
  END.
  ELSE DO:
      ASSIGN
      e-des:SCREEN-VALUE = ''.

  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/brwrefre.i " v-doc-rec = recid(X_wi-mode).  ~
  RUn OpenBR in this-procedure.  REPOSITION br-wi-mode to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to br-wi-mode. " }

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
  v-admin = lookup('admin', bttns) > 0.
  if p-list-mode = "mode-type"
  and lookup(p-mode-type, {&wi-mode-type-list}) = 0 then do:
    message
    substitute("Неверное значение параметра p-mode-type = &1", p-mode-type)
    view-as alert-box error .
    undo main-block, return error .
  end.
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
  DISPLAY e-des mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel b-add b-chg b-del b-lkp B-Help br-wi-mode e-des
         mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
define variable v-h as handle no-undo .
define variable vh-mode-type-name as handle no-undo .
ASSIGN
v-h = br-wi-mode:FIRST-COLUMN in frame {&frame-name}
.
DO while valid-handle(v-h) :
  if v-h:LABEL = {&label-1} then do:
    vh-mode-type-name = v-h.
    leave.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.

ASSIGN
X_wi-mode.mode-name:RESIZABLE IN BROWSE br-wi-mode = YES
vh-mode-type-name:RESIZABLE = YES
vh-mode-type-name:visible = not (p-list-mode = "mode-type")
.
ENABLE
b-quit
b-add when (lookup("b-add", bttns) > 0)
b-chg when (lookup("b-add", bttns) > 0)
b-del when (lookup("b-add", bttns) > 0)
b-lkp
B-Help
b-mark when lookup("b-mark", bttns) > 0
b-sel when lookup("b-sel", bttns) > 0
br-wi-mode
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
run Openbr in this-procedure .
APPLY "VALUE-CHANGED" TO br-wi-mode.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame 
PROCEDURE Openbr :
CASE p-list-mode:
   when {&all} then do:
      frame {&frame-name} :title = "Все режимы".
      OPEN QUERY br-wi-mode
      FOR EACH X_wi-mode NO-LOCK where X_wi-mode.mode-id > '' INDEXED-REPOSITION.
   end.
   when "mode-type" then do:
      frame {&frame-name} :title = substitute("Режимы типа &1", p-mode-type).
      OPEN QUERY br-wi-mode
      FOR EACH X_wi-mode NO-LOCK where
               X_wi-mode.mode-type = p-mode-type
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
  WHEN {&TABLE_wi-mode} THEN DO:
      run adm/wi-modei.w ( input parparentproc
                           ,input {&lookup} + {&comma-char} + (if v-admin then "admin" else '')
                           ,input X_wi-mode.mode-type /*p-mode-type*/
                           ,input X_wi-mode.mode-id
                           ,input-output v-rec) no-error.

  END.
END CASE.
IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

