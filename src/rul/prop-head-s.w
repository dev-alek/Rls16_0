&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_prop-head FOR ub.prop-head.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список объектов-операндо RUM


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
/*{&all} " general-view*/
define input parameter p-general-view as character no-undo .
define input-output parameter p-rid-list as character no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список объектов-операндов RUM".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
DEFINE VARIABL link-option AS CHARACTER NO-UNDO.
define variable v-rid-list as character no-undo .
define variable storage-option as character no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-prop-head

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_prop-head

/* Definitions for BROWSE br-prop-head                                  */
&Scoped-define FIELDS-IN-QUERY-br-prop-head mark-string(recid(X_prop-head), v-rid-list) X_prop-head.dtm-code X_prop-head.prop-name X_prop-head.prop-label
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-prop-head
&Scoped-define SELF-NAME br-prop-head
&Scoped-define QUERY-STRING-br-prop-head FOR EACH X_prop-head NO-LOCK BY X_prop-head.dtm-code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-prop-head OPEN QUERY {&SELF-NAME} FOR EACH X_prop-head NO-LOCK BY X_prop-head.dtm-code INDEXED-REPOSITION .
&Scoped-define TABLES-IN-QUERY-br-prop-head X_prop-head
&Scoped-define FIRST-TABLE-IN-QUERY-br-prop-head X_prop-head


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-prop-head}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-chg b-del b-lkp ~
b-links b-storage B-Help b-prop br-prop-head mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-link
       MENU-ITEM m_prop-map     LABEL "Хранимые свойства"
       MENU-ITEM m_prop-script  LABEL "Скрипты"
       MENU-ITEM m_prop-ruleset LABEL "Привязка к кодексам и наборам правил".

DEFINE MENU MENU-b-storage
       MENU-ITEM m_object       LABEL "Объект"
       MENU-ITEM m_host         LABEL "Фирма"
       MENU-ITEM m_global       LABEL "Глобально"     .


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

DEFINE BUTTON b-links
     LABEL "Связи"
     SIZE 10 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 4 BY 1.

DEFINE BUTTON b-prop
     LABEL "Свойства"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1.

DEFINE BUTTON b-storage
     LABEL "Данные"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9 BY .67
     FGCOLOR 10  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-prop-head FOR
      X_prop-head SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-prop-head
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-prop-head Dialog-Frame _FREEFORM
  QUERY br-prop-head NO-LOCK DISPLAY
      mark-string(recid(X_prop-head), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_prop-head.dtm-code COLUMN-LABEL "Код объекта" FORMAT ">>>>>>>>9"
X_prop-head.prop-name COLUMN-LABEL "Имя объекта" format "X(255)" width 32
X_prop-head.prop-label COLUMN-LABEL "Лейбл объекта" format "X(255)" width 45
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 19.53 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 20 WIDGET-ID 12
     b-sel AT ROW 1 COL 24 WIDGET-ID 10
     b-add AT ROW 1 COL 34 WIDGET-ID 2
     b-chg AT ROW 1 COL 44 WIDGET-ID 4
     b-del AT ROW 1 COL 54 WIDGET-ID 8
     b-lkp AT ROW 1 COL 64 WIDGET-ID 6
     b-links AT ROW 1 COL 74 WIDGET-ID 16
     b-storage AT ROW 1 COL 84 WIDGET-ID 18
     B-Help AT ROW 1 COL 95
     b-prop AT ROW 2 COL 74 WIDGET-ID 20
     br-prop-head AT ROW 3.33 COL 1.5 WIDGET-ID 100
     mark-num AT ROW 1 COL 9 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     SPACE(78.50) SKIP(21.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Объекты"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_prop-head B "?" ? ub prop-head
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-prop-head b-prop Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-links:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-link:HANDLE.

ASSIGN
       b-storage:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-storage:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-prop-head
/* Query rebuild information for BROWSE br-prop-head
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_prop-head NO-LOCK BY X_prop-head.dtm-code INDEXED-REPOSITION .
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-prop-head */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Объекты */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Объекты */
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
  v-rec = recid(X_prop-head).
  run rul/prop-head-i.w ( input parparentproc
                       ,input {&add-def}
                       ,input 0 /*p-dtm-code*/
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
    RUN openbr IN THIS-PROCEDURE.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  define variable v-rec as recid no-undo.
  if not available X_prop-head then return no-apply.
  v-rec = recid(X_prop-head).
  run rul/prop-head-i.w ( input parparentproc
                       ,input {&update}
                       ,input X_prop-head.dtm-code /*p-dtm-code*/
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
     br-prop-head:refresh().
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
  if not available X_prop-head then return no-apply.
  v-rec = recid(X_prop-head).
  message "Вы уверены, что хотите удалить Объект?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then return no-apply.
 run rul/prop-head3.p ( input no /*p-silent*/
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
  if not available X_prop-head then return no-apply.
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
  if not available X_prop-head then return no-apply.
  run proc-b-lkp IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
    define variable glog as logical no-undo .
  if available X_prop-head then do:
 { gbl/markstrn.i X_prop-head v-rid-list }
  glog = br-prop-head:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-prop-head:select-next-row ().
      apply "VALUE-CHANGED" to br-prop-head in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-prop-head in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prop Dialog-Frame
ON CHOOSE OF b-prop IN FRAME Dialog-Frame /* Свойства */
DO:
define variable v-rec as recid no-undo .
if not available X_prop-head then return no-apply.
if not (X_prop-head.storage-place = {&table_dis-card-property}
        or
        X_prop-head.storage-place-host = {&table_dis-card-property}
        or
        X_prop-head.storage-place-obj = {&table_dis-card-property}) then do:
  message
  substitute("Свойства можно настроить только если место хранения &1", {&table_dis-card-property})
  view-as alert-box error .
  return no-apply.
end.
v-rec = recid(X_prop-head).
run utl/attrprps.w ( input parparentproc
                    ,input {&update}
                    ,input {&table_dis-card-property}
                    ,input X_prop-head.dtm-code
                    ,output v-rec) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available X_prop-head then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_prop-head ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-storage
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-storage Dialog-Frame
ON CHOOSE OF b-storage IN FRAME Dialog-Frame /* Данные */
DO:
  IF NOT AVAILABLE X_prop-head THEN RETURN NO-APPLY.
  IF storage-option = '':U THEN DO:
    run gbl/pop-up.p ( INPUT SELF :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if link-option = "":U then do:
      return no-apply.
  end.
  RUN proc-b-storage IN THIS-PROCEDURE( input storage-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
      storage-option = '':U.
      RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-prop-head
&Scoped-define SELF-NAME br-prop-head
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-prop-head Dialog-Frame
ON VALUE-CHANGED OF br-prop-head IN FRAME Dialog-Frame
DO:
  RUN proc-value-change IN THIS-PROCEDURE NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_global
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_global Dialog-Frame
ON CHOOSE OF MENU-ITEM m_global /* Глобально */
DO:
  ASSIGN
  storage-option = "global".
  run proc-b-storage IN THIS-PROCEDURE ( INPUT storage-option) NO-ERROR.
  ASSIGN
  link-option = '':U.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_host
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_host Dialog-Frame
ON CHOOSE OF MENU-ITEM m_host /* Фирма */
DO:
   ASSIGN
    storage-option = {&company}.
    run proc-b-storage IN THIS-PROCEDURE ( INPUT storage-option) NO-ERROR.
    ASSIGN
    link-option = '':U.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_object
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_object Dialog-Frame
ON CHOOSE OF MENU-ITEM m_object /* Объект */
DO:
    ASSIGN
   storage-option = {&g___object}.
   run proc-b-storage IN THIS-PROCEDURE ( INPUT storage-option) NO-ERROR.
   ASSIGN
   link-option = '':U.
   IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_prop-map
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_prop-map Dialog-Frame
ON CHOOSE OF MENU-ITEM m_prop-map /* Хранимые свойства */
DO:
    ASSIGN
  link-option = {&TABLE_prop-map}.
  run proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  ASSIGN
  link-option = '':U.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_prop-ruleset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_prop-ruleset Dialog-Frame
ON CHOOSE OF MENU-ITEM m_prop-ruleset /* Привязка к кодексам и наборам правил */
DO:
    ASSIGN
  link-option = {&TABLE_prop-ruleset}.
  run proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  ASSIGN
  link-option = '':U.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_prop-script
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_prop-script Dialog-Frame
ON CHOOSE OF MENU-ITEM m_prop-script /* Скрипты */
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


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/brwrefre.i " v-doc-rec = recid(X_prop-head).  ~
  run OpenBR in this-procedure.  REPOSITION br-prop-head to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to br-prop-head. " }

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
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel b-add b-chg b-del b-lkp b-links b-storage B-Help
         b-prop br-prop-head mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
assign
X_prop-head.prop-name:resizable in browse br-prop-head = yes
X_prop-head.prop-label:resizable in browse br-prop-head = yes
b-links:MENU-MOUSE in frame {&frame-name} = 1
b-storage:MENU-MOUSE in frame {&frame-name} = 1
.
ENABLE
b-quit
b-add when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-chg when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-del when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-prop when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-storage when lookup("b-storage", bttns) > 0
b-lkp
b-links
B-Help
b-mark when lookup("b-mark", bttns) > 0
b-sel when lookup("b-sel", bttns) > 0
br-prop-head
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF NOT (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0) THEN DO:
  HIDE
  b-prop
  IN FRAME {&FRAME-NAME}.
END.
if lookup("b-add", bttns) = 0 then do:
  X_prop-head.prop-name:visible in browse br-prop-head = no.
end.
run openbr in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
CASE p-list-mode:
  WHEN {&ALL} THEN DO:
    OPEN QUERY br-prop-head
    FOR EACH X_prop-head NO-LOCK
    by X_prop-head.dtm-code INDEXED-REPOSITION.
  END.
  WHEN "general-view" THEN DO:
    OPEN QUERY br-prop-head
    FOR EACH X_prop-head NO-LOCK  where
            X_prop-head.general-view contains p-general-view
            by X_prop-head.dtm-code
    INDEXED-REPOSITION.
  END.
END CASE.
if v-rid-list <> '':U then do:
  reposition br-prop-head to recid integer(entry(1, v-rid-list)) no-error .
  APPLY "ENTRY" to br-prop-head in frame {&frame-name} .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-link Dialog-Frame
PROCEDURE proc-b-link :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
CASE p-option:
 WHEN {&TABLE_prop-map} THEN DO:
    run rul/prop-map-s.w (
                           input parparentproc
                          ,INPUT (IF (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
                                  THEN 'b-add':U
                                  ELSE '':U) /* bttns */
                          ,INPUT "dtm-code" /* p-list-mode */
                          ,INPUT X_prop-head.dtm-code
                          ,INPUT-OUTPUT v-rid-list) NO-ERROR.

  END.
  WHEN {&TABLE_prop-script} THEN DO:
    run rul/prop-script-s.w (
                           input parparentproc
                           ,INPUT (IF (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
                                   THEN 'b-add':U
                                   ELSE '':U) /* bttns */
                          ,INPUT "dtm-code" /* p-list-mode */
                          ,INPUT '':U /*p-language*/
                          ,INPUT X_prop-head.dtm-code
                          ,INPUT "":U /* p-proc-type */
                          ,INPUT "":U /* p-script-type */
                           ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  END.
  WHEN {&TABLE_prop-ruleset} THEN DO:
      run rul/prop-ruleset-s.w (
                             input parparentproc
                             ,INPUT (IF (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
                                   THEN 'b-add':U
                                   ELSE '':U) /* bttns */
                            ,INPUT "dtm-code" /* p-list-mode */
                            ,INPUT 0 /*codex_id*/
                            ,INPUT 0 /*ruleset_id*/
                            ,INPUT X_prop-head.dtm-code
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
    run rul/prop-head-i.w ( input parparentproc
                           ,input {&lookup}
                           ,input X_prop-head.dtm-code
                           ,input-output v-rec) no-error.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-storage Dialog-Frame
PROCEDURE proc-b-storage :
DEFINE INPUT PARAMETER p-storage AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-storage AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
CASE p-storage:
  WHEN {&g___object} THEN DO:
     ASSIGN
     v-storage = X_prop-head.storage-place-obj.
  END.
  WHEN {&company} THEN DO:
      ASSIGN
      v-storage = X_prop-head.storage-place-host.

  END.
  WHEN "global" THEN DO:
      ASSIGN
      v-storage = X_prop-head.storage-place.

  END.
END CASE.
CASE v-storage:
  WHEN {&TABLE_dis-obj}
  or
  WHEN {&TABLE_dis-host} THEN DO:
    run ref/dis-tots.w (
                        INPUT parparentproc
                       ,INPUT '':U /*bttns*/
                       ,INPUT v-cntxt-host-code-obj
                       ,INPUT v-cntxt-obj-type
                       ,INPUT v-cntxt-obj-code
                       ,INPUT "dtm-code" /*p-list-mode*/
                       ,INPUT p-storage
                       ,INPUT X_prop-head.dtm-code /* p-dtm-code */
                       ,INPUT 0 /*p-dt-code */
                       ,INPUT-OUTPUT v-rid-list ) NO-ERROR.
  END.
  WHEN {&TABLE_dis-CARD-PROPERTY} THEN DO:
    run ref/discprps.w (
                        INPUT parparentproc
                       ,INPUT '':U /*bttns*/
                       ,INPUT v-cntxt-host-code-obj
                       ,INPUT v-cntxt-obj-type
                       ,INPUT v-cntxt-obj-code
                       ,INPUT "dtm-code" /*p-list-mode*/
                       ,INPUT p-storage
                       ,INPUT X_prop-head.dtm-code /* p-dtm-code */
                       ,INPUT 0 /*p-dt-code */
                       ,INPUT-OUTPUT v-rid-list ) NO-ERROR.
  END.
  when {&table_chk-doc}  then do:
    define buffer buf_shop for ub.shop.
    run adm/shops.w ( input parparentproc
                   ,  input "b-sel"
                   , input-output v-rid-list
                   , no).
    if v-rid-list = '':u then return no-apply.
     find first buf_shop no-lock where
           recid(buf_shop) = integer(v-rid-list) no-error.
    if not available buf_shop  then undo, return error.
    v-rid-list = '':U.
    run str/chk-docs.w (
                    input parparentproc
                    ,input '':U
                    ,input {&table_dis-card}
                    ,input ?
                    ,input {&shop}
                    ,input buf_shop.obj-code
                    ,input '':U  /*out-code*/
                    ,input '':U /*dis-card*/
                    ,input 0 /*p-pay-desk*/
                    ,input ? /*start-date*/
                    ,input ? /*end-date*/
                    ,input 0
                    ,output v-rid-list) no-error.

  end.
  when {&table_chk-discnt} then do:
    if X_prop-head.dtm-code <> 15 then do:
      MESSAGE
      substitute("Неизвестное хранилище данных &1", v-storage).
    end.
    run adm/shops.w ( input parparentproc
                   ,  input "b-sel"
                   , input-output v-rid-list
                   , no).
    if v-rid-list = '':u then return no-apply.
     find first buf_shop no-lock where
           recid(buf_shop) = integer(v-rid-list) no-error.
    if not available buf_shop  then undo, return error.
    v-rid-list = '':U.
    run str/chkbonus.w (
                    input parparentproc
                    ,input '':U
                    ,input {&g___object}
                    ,input {&shop}
                    ,input buf_shop.obj-code
                    ,input ? /*start-date*/
                    ,input ? /*end-date*/
                    ,output v-rid-list) no-error.
  end.
  OTHERWISE DO:
    MESSAGE
    substitute("Неизвестное хранилище данных &1", v-storage).
  END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-value-change Dialog-Frame
PROCEDURE proc-value-change :
IF NOT AVAILABLE X_prop-head  THEN DO:
   ASSIGN
   MENU-ITEM m_global:SENSITIVE IN MENU menu-b-storage = NO
   MENU-ITEM m_host:SENSITIVE IN MENU menu-b-storage = NO
   MENU-ITEM m_object:SENSITIVE IN MENU menu-b-storage = NO
   .
END.
ELSE DO:
    ASSIGN
    MENU-ITEM m_global:SENSITIVE IN MENU menu-b-storage = (IF X_prop-head.storage-place = '':U
                                                           OR X_prop-head.storage-place = {&question-mark}
                                                           THEN NO
                                                           ELSE YES)
    MENU-ITEM m_host:SENSITIVE IN MENU menu-b-storage = (IF X_prop-head.storage-place-host = '':U
                                                      OR X_prop-head.storage-place-host = {&question-mark}
                                                      THEN NO
                                                      ELSE YES)

    MENU-ITEM m_object:SENSITIVE IN MENU menu-b-storage =  (IF X_prop-head.storage-place-obj = '':U
                                                           OR X_prop-head.storage-place-obj = {&question-mark}
                                                           THEN NO
                                                           ELSE YES)

    .

END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME