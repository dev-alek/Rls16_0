&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_prop-head FOR ub.prop-head.
DEFINE BUFFER X_prop-map FOR ub.prop-map.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список  хранимых свойств объектов-операндов RUM


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
/*{&all} dtm-code */
DEFINE INPUT PARAMETER p-dtm-code AS integer NO-UNDO.
define input-output parameter p-rid-list as character no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список  хранимых свойств объектов-операндов RUM".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
DEFINE VARIABL link-option AS CHARACTER NO-UNDO.
define variable v-rid-list as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-prop-map

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_prop-map X_prop-head

/* Definitions for BROWSE br-prop-map                                   */
&Scoped-define FIELDS-IN-QUERY-br-prop-map mark-string(recid(X_prop-map), v-rid-list) X_prop-head.dtm-code X_prop-map.node-code X_prop-map.node-name X_prop-map.node-label X_prop-map.node-value-type X_prop-map.rw-option X_prop-head.prop-name X_prop-head.prop-label
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-prop-map
&Scoped-define SELF-NAME br-prop-map
&Scoped-define QUERY-STRING-br-prop-map FOR EACH X_prop-map NO-LOCK, ~
       FIRST X_prop-head NO-LOCK  indexed-reposition
&Scoped-define OPEN-QUERY-br-prop-map OPEN QUERY {&SELF-NAME} FOR EACH X_prop-map NO-LOCK, ~
       FIRST X_prop-head NO-LOCK  indexed-reposition.
&Scoped-define TABLES-IN-QUERY-br-prop-map X_prop-map X_prop-head
&Scoped-define FIRST-TABLE-IN-QUERY-br-prop-map X_prop-map
&Scoped-define SECOND-TABLE-IN-QUERY-br-prop-map X_prop-head


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-prop-map}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-chg b-del b-lkp ~
b-links B-Help br-prop-map mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-link
       MENU-ITEM m_prop-head    LABEL "Объект"
       MENU-ITEM m_prop-script  LABEL "Скприпты"      .


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

DEFINE BUTTON b-links
     LABEL "Связи"
     SIZE 10 BY 1.

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
DEFINE QUERY br-prop-map FOR
      X_prop-map,
      X_prop-head SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-prop-map
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-prop-map Dialog-Frame _FREEFORM
  QUERY br-prop-map NO-LOCK DISPLAY
      mark-string(recid(X_prop-map), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_prop-head.dtm-code COLUMN-LABEL "Код объекта" FORMAT ">>>>>>>>9"
X_prop-map.node-code COLUMN-LABEL "Код свойства" FORMAT ">>>>>>>>9"
X_prop-map.node-name COLUMN-LABEL "Имя свойства" format "X(255)" width 32
X_prop-map.node-label COLUMN-LABEL "Лейбл свойства" format "X(255)" width 32
X_prop-map.node-value-type COLUMN-LABEL "Тип знач." format "X(20)"
X_prop-map.rw-option COLUMN-LABEL "RW" format "X(6)"
X_prop-head.prop-name COLUMN-LABEL "Имя объекта" format "X(255)" width 32
X_prop-head.prop-label COLUMN-LABEL "Лейбл объекта" format "X(255)" width 45
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
     b-links AT ROW 1 COL 78 WIDGET-ID 16
     B-Help AT ROW 1 COL 88
     br-prop-map AT ROW 2.33 COL 1.5 WIDGET-ID 100
     mark-num AT ROW 1 COL 13 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     SPACE(74.50) SKIP(21.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Хранимые свойства объектов"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_prop-head B "?" ? ub prop-head
      TABLE: X_prop-map B "?" ? ub prop-map
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-prop-map B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-links:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-link:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-prop-map
/* Query rebuild information for BROWSE br-prop-map
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_prop-map NO-LOCK, FIRST X_prop-head NO-LOCK  indexed-reposition.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-prop-map */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Свойства объектов */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Свойства объектов */
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
  run rul/prop-map-i.w ( input parparentproc
                       ,input {&add-def}
                       ,input (if p-list-mode = "dtm-code" then p-dtm-code else 0) /*p-dtm-code*/
                       ,input 0
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
    RUN openbr IN THIS-PROCEDURE.
    reposition br-prop-map to recid v-rec no-error.
    apply "ENTRY" to br-prop-map.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  define variable v-rec as recid no-undo.
  if not available X_prop-map then return no-apply.
  v-rec = recid(X_prop-map).
  run rul/prop-map-i.w ( input parparentproc
                       ,input {&update}
                       ,input X_prop-map.dtm-code /*p-dtm-code*/
                       ,input X_prop-map.node-code /*p-dtm-code*/
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
     br-prop-map:refresh().
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
  if not available X_prop-map then return no-apply.
  v-rec = recid(X_prop-map).
  message "Вы уверены, что хотите удалить Свойство?"
  view-as alert-box QUESTION buttons YES-No update glog .
  if not glog then return no-apply.
 run rul/prop-map3.p ( input no /*p-silent*/
                       ,input v-rec) no-error.
 if error-status:error then return no-apply.
 run Openbr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-links
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-links Dialog-Frame
ON CHOOSE OF b-links IN FRAME Dialog-Frame /* Связи */
DO:
  define variable v-rec as recid no-undo.
  if not available X_prop-map then return no-apply.
  IF link-option = '':U THEN DO:
    run gbl/pop-up.p ( INPUT SELF :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if link-option = "":U then do:
      return no-apply.
  end.
  run proc-b-link IN THIS-PROCEDURE ( INPUT link-option).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  define variable v-rec as recid no-undo.
  if not available X_prop-map then return no-apply.
  run proc-b-lkp IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable glog as logical no-undo .
  if available X_prop-map then do:
 { gbl/markstrn.i X_prop-map v-rid-list }
  glog = br-prop-map:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-prop-map:select-next-row ().
      apply "VALUE-CHANGED" to br-prop-map in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-prop-map in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available X_prop-map then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_prop-map ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_prop-head
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_prop-head Dialog-Frame
ON CHOOSE OF MENU-ITEM m_prop-head /* Объект */
DO:
    ASSIGN
  link-option = {&TABLE_prop-head}.
  run proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  ASSIGN
  link-option = '':U.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_prop-script
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_prop-script Dialog-Frame
ON CHOOSE OF MENU-ITEM m_prop-script /* Скприпты */
DO:
    ASSIGN
  link-option = {&TABLE_prop-script}.
  run proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  ASSIGN
  link-option = '':U.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-prop-map
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/brwrefre.i " v-doc-rec = recid(X_prop-map).  ~
  run OpenBR in this-procedure.  REPOSITION br-prop-map to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to br-prop-map. " }

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
  ENABLE b-quit b-mark b-sel b-add b-chg b-del b-lkp b-links B-Help br-prop-map
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
X_prop-map.node-name:resizable in browse br-prop-map = yes
X_prop-map.node-label:resizable in browse br-prop-map = yes
X_prop-head.prop-name:resizable in browse br-prop-map = yes
X_prop-head.prop-label:resizable in browse br-prop-map = yes
b-links:MENU-MOUSE in frame {&frame-name} = 1
.
ENABLE
b-quit
b-add when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-chg when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-del when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-lkp
b-links
B-Help
b-mark when lookup("b-mark", bttns) > 0
b-sel when lookup("b-sel", bttns) > 0
br-prop-map
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
run openbr in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
CASE p-list-mode:
  WHEN {&ALL} THEN DO:
    frame {&frame-name}:title = "Свойства объектов-операндов".
    OPEN QUERY br-prop-map
    FOR EACH X_prop-map NO-LOCK,
        FIRST X_prop-head NO-LOCK WHERE
             X_prop-head.dtm-code = X_prop-map.dtm-code INDEXED-REPOSITION.
  END.
  WHEN "dtm-code" THEN DO:
    frame {&frame-name}:title = substitute("Свойства объектов-операндов для объекта-операнда &1", p-dtm-code).
    OPEN QUERY br-prop-map
    FOR EACH X_prop-map NO-LOCK WHERE X_prop-map.dtm-code = p-dtm-code,
        FIRST X_prop-head NO-LOCK WHERE
             X_prop-head.dtm-code = X_prop-map.dtm-code INDEXED-REPOSITION.
  END.

END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-link Dialog-Frame
PROCEDURE proc-b-link :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
CASE p-option:
  WHEN {&TABLE_prop-head} THEN DO:
    v-rec = recid(X_prop-head).
    run rul/prop-head-i.w ( input parparentproc
                           ,input {&lookup}
                           ,input X_prop-head.dtm-code
                           ,input-output v-rec) no-error.

  END.
  WHEN {&TABLE_prop-script} THEN DO:
    run rul/prop-script-s.w (
                           input parparentproc
                          ,INPUT (if (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
                                  then 'b-add'
                                  else '':U)     /* bttns */
                          ,INPUT "dtm-code" /* p-list-mode */
                          ,INPUT '':U /*p-language*/
                          ,INPUT X_prop-head.dtm-code
                          ,INPUT "":U /* p-proc-type */
                          ,INPUT "":U /* p-script-type */
                           ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  END.
END CASE.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lkp Dialog-Frame
PROCEDURE proc-b-lkp :
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
    v-rec = recid(X_prop-head).
    run rul/prop-map-i.w ( input parparentproc
                           ,input {&lookup}
                           ,input X_prop-map.dtm-code
                           ,input X_prop-map.node-code
                           ,input-output v-rec) no-error.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME