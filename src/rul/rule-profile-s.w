&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_rule-profile FOR ub.rule-profile.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список rule-profile


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
/*{&all} general-view term */
define input parameter p-general-view as character no-undo .
define input-output parameter p-rid-list as character no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список rule-profile".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/mrk-strf.i }
{ gbl/getcntxt.i def }
{ gbl/key-rec.i }
{ gbl/color.i }
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
&Scoped-define BROWSE-NAME br-rule-profile

/* Definitions for BROWSE br-rule-profile                               */
&Scoped-define FIELDS-IN-QUERY-br-rule-profile mark-string(recid(X_rule-profile), v-rid-list) X_rule-profile.profile_id X_rule-profile.profile-type X_rule-profile.name X_rule-profile.param-code X_rule-profile.param-value
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-rule-profile
&Scoped-define SELF-NAME br-rule-profile
&Scoped-define OPEN-QUERY-br-rule-profile RUN openbr IN THIS-PROCEDURE.

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-rule-profile}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-chg b-del b-lkp ~
b-link B-cmp B-Help br-rule-profile mark-num
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
       MENU-ITEM m_rp-by-call   LABEL "Привязки"
       MENU-ITEM m_ruledict-param LABEL "Параметры"
       MENU-ITEM m_rule-call-param LABEL "Значения параметров"
       MENU-ITEM m_term-rule-profile LABEL "Подчиненные профайлы".

DEFINE MENU MENU-b-lkp
       MENU-ITEM m_rule-profile LABEL "Профайл"
       MENU-ITEM m_ruleproc_text LABEL "Процессы-Текст"
       MENU-ITEM m_ruleproc_graph LABEL "Процессы-Графика".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-cmp
     LABEL "&Компилить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-link
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
DEFINE QUERY br-rule-profile FOR
      X_rule-profile SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-rule-profile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-rule-profile Dialog-Frame _FREEFORM
QUERY br-rule-profile NO-LOCK  DISPLAY
      mark-string(recid(X_rule-profile), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_rule-profile.profile_id COLUMN-LABEL "ID" FORMAT ">>>>>>>>9"
X_rule-profile.profile-type COLUMN-LABEL "Тип" FORMAT "X(20)"
X_rule-profile.name COLUMN-LABEL "Название" FORMAT "X(255)" WIDTH 80
X_rule-profile.param-code COLUMN-LABEL "Конф.пар-р" FORMAT "X(8)"
X_rule-profile.param-value COLUMN-LABEL "Значение конф.пар-ра" FORMAT "X(255)"  WIDTH 40
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 20.53 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 20 WIDGET-ID 12
     b-sel AT ROW 1 COL 24 WIDGET-ID 10
     b-add AT ROW 1 COL 34 WIDGET-ID 2
     b-chg AT ROW 1 COL 44 WIDGET-ID 4
     b-del AT ROW 1 COL 54 WIDGET-ID 8
     b-lkp AT ROW 1 COL 64 WIDGET-ID 6
     b-link AT ROW 1 COL 74 WIDGET-ID 16
     B-cmp AT ROW 1 COL 84 WIDGET-ID 18
     B-Help AT ROW 1 COL 95
     br-rule-profile AT ROW 2.33 COL 1.5 WIDGET-ID 100
     mark-num AT ROW 1 COL 11 NO-LABEL WIDGET-ID 14
     SPACE(78.50) SKIP(21.19)
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
      TABLE: X_rule-profile B "?" ? ub rule-profile
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-rule-profile B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-link:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-link:HANDLE.

ASSIGN
       b-lkp:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-lkp:HANDLE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-rule-profile
/* Query rebuild information for BROWSE br-rule-profile
     _START_FREEFORM
RUN openbr IN THIS-PROCEDURE.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-rule-profile */
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
  if p-list-mode = "term" then do:
    run proc-b-term in this-procedure ( input integer(p-general-view)
                                      , input {&add-def}
                                      , output v-rec
                                       ) no-error.
    if error-status:error then return no-apply.
  end.
  else do:
  run rul/rule-profile-i.w ( input parparentproc
                       ,input {&add-def}
                       ,input 0 /*p-rule-profile-id*/
                       ,input-output v-rec) no-error.
  end.
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
  if not available X_rule-profile then return no-apply.
  v-rec = recid(X_rule-profile).
  run rul/rule-profile-i.w ( input parparentproc
                       ,input {&update}
                       ,input X_rule-profile.profile_id /*p-profile-id*/
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
     br-rule-profile:refresh().
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cmp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cmp Dialog-Frame
ON CHOOSE OF B-cmp IN FRAME Dialog-Frame /* Компилить */
DO:
  IF NOT AVAILABLE X_rule-profile THEN RETURN NO-APPLY.
  if X_rule-profile.profile-type <> {&table_trn-doc}
  and entry(1, X_rule-profile.profile-type, "_") <> {&table_chk-doc}
  then do:
    message
    "Компилиться по правилам!"
    view-as alert-box error .
    return no-apply.
  end.
    run waitfram-show in this-procedure ( substitute("Компиляция профайла &1", X_rule-profile.profile_id) ).
    run rul/rp-prep.p ( input X_rule-profile.profile_id ) no-error.
    if error-status:error then do:
        run waitfram-hide in this-procedure .
        message
        substitute("Ошибка при компиляции профайла&1&2" +
                  "&3&2&4&2"
                  , X_rule-profile.profile_id
                  , {&new-line}
                  , error-status:error
                  , return-value
                  )
        view-as alert-box error .
    end.
    run waitfram-hide in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  define variable v-rec as recid no-undo.
  define variable glog as logical no-undo.
  if not available X_rule-profile then return no-apply.
  v-rec = recid(X_rule-profile).
  if p-list-mode = "term" then do:
    run proc-b-term in this-procedure ( input integer(p-general-view)
                                       , input {&deletion}
                                       , output v-rec
                                       ) no-error.
  end.
  else do:
  message
  "Вы уверены, что хотите удалить профайл?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then return no-apply.
 run rul/rule-profile3.p (
                           input no /*p-silent*/
                          ,input v-rec
                          ) no-error.
  end.
 if error-status:error then return no-apply.
 run Openbr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-link
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-link Dialog-Frame
ON CHOOSE OF b-link IN FRAME Dialog-Frame /* Связи */
DO:
IF NOT AVAILABLE X_rule-profile THEN RETURN NO-APPLY.
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


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:

  if not available X_rule-profile then return no-apply.
IF lkp-option = '':U THEN DO:
   run gbl/pop-up.p ( INPUT SELF:handle, input no ) no-error.
   if error-status :error then do: return no-apply. end.
end.
if lkp-option = "":U then do:
      return no-apply.
end.
run proc-b-lkp IN THIS-PROCEDURE ( INPUT lkp-option) NO-ERROR.
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
  if available X_rule-profile then do:
 { gbl/markstrn.i X_rule-profile v-rid-list }
  glog = br-rule-profile:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-rule-profile:select-next-row ().
      apply "VALUE-CHANGED" to br-rule-profile in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-rule-profile in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available X_rule-profile then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_rule-profile ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-rule-profile
&Scoped-define SELF-NAME br-rule-profile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-rule-profile Dialog-Frame
ON VALUE-CHANGED OF br-rule-profile IN FRAME Dialog-Frame
DO:
  IF AVAILABLE X_rule-profile
  and X_rule-profile.profile-type = {&cmb}
  THEN DO:
    assign
    menu-item m_term-rule-profile:sensitive in menu menu-b-link = yes.
  END.
  ELSE DO:
    assign
    menu-item m_term-rule-profile:sensitive in menu menu-b-link = no.

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_rp-by-call
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_rp-by-call Dialog-Frame
ON CHOOSE OF MENU-ITEM m_rp-by-call /* Привязки */
DO:
    ASSIGN
  link-option = {&TABLE_rp-by-call}.
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      link-option = '':U.
      RETURN NO-APPLY.
  END.
  link-option = '':U.

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


&Scoped-define SELF-NAME m_term-rule-profile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_term-rule-profile Dialog-Frame
ON CHOOSE OF MENU-ITEM m_term-rule-profile /* Подчиненные профайлы */
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


&Scoped-define SELF-NAME m_rule-call-param
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_rule-call-param Dialog-Frame
ON CHOOSE OF MENU-ITEM m_rule-call-param /* Значения параметров */
DO:
  ASSIGN
  link-option = {&TABLE_rule-call-param}.
  run proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  ASSIGN
  link-option = '':U.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_rule-profile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_rule-profile Dialog-Frame
ON CHOOSE OF MENU-ITEM m_rule-profile /* Профайл */
DO:
  ASSIGN
  lkp-option = {&TABLE_rule-profile}.
  RUN proc-b-lkp IN THIS-PROCEDURE ( INPUT lkp-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      lkp-option = '':U.
      RETURN NO-APPLY.
  END.
  lkp-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_ruledict-param
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_ruledict-param Dialog-Frame
ON CHOOSE OF MENU-ITEM m_ruledict-param /* Параметры */
DO:
  ASSIGN
  link-option = {&TABLE_ruledict-param}.
  run proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  ASSIGN
  link-option = '':U.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_ruleproc_graph
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_ruleproc_graph Dialog-Frame
ON CHOOSE OF MENU-ITEM m_ruleproc_graph /* Процессы-Графика */
DO:

   ASSIGN
  lkp-option = "ruleproc-graph".
  RUN proc-b-lkp IN THIS-PROCEDURE ( INPUT lkp-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      lkp-option = '':U.
      RETURN NO-APPLY.
  END.
  lkp-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_ruleproc_text
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_ruleproc_text Dialog-Frame
ON CHOOSE OF MENU-ITEM m_ruleproc_text /* Процессы-Текст */
DO:
   ASSIGN
  lkp-option = "ruleproc-text".
  RUN proc-b-lkp IN THIS-PROCEDURE ( INPUT lkp-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      lkp-option = '':U.
      RETURN NO-APPLY.
  END.
  lkp-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-rule-profile
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

ON ROW-DISPLAY OF br-rule-profile IN frame {&frame-name}
DO:
  IF AVAIL X_rule-profile THEN DO:
    RUN set-row-color IN THIS-PROCEDURE ( INPUT X_rule-profile.parent-feature).
  END.
END.


{ gbl/brwrefre.i " v-doc-rec = recid(X_rule-profile).  ~
  RUn OpenBR in this-procedure.  REPOSITION br-rule-profile to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to br-rule-profile. " }

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
  ENABLE b-quit b-mark b-sel b-add b-chg b-del b-lkp b-link B-cmp B-Help
         br-rule-profile mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
X_rule-profile.NAME:RESIZABLE IN BROWSE br-rule-profile = YES
X_rule-profile.param-value:RESIZABLE IN BROWSE br-rule-profile = YES
b-link:MENU-MOUSE IN FRAME {&FRAME-NAME} = 1
b-lkp:MENU-MOUSE IN FRAME {&FRAME-NAME} = 1
.
if p-list-mode = "general-view" then do:
  case p-general-view:
    when {&table_dis-card-type} then do:
      assign
      frame {&frame-name} :title = substitute("Профайлы работы с ДК").
    end.
    when {&table_chk-doc} then do:
      assign
      frame {&frame-name} :title = substitute("Профайлы для расчета скидок и бонусов на POS IBS TH").
    end.
  end case.
end.
ENABLE
b-quit
b-add when (lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0)
b-chg when (lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0 and p-list-mode <> "term")
b-del when (lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0 and p-list-mode = "term")
b-lkp
B-Help
b-mark when lookup("b-mark", bttns) > 0
b-sel when lookup("b-sel", bttns) > 0
b-link
b-cmp when (lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0 and p-list-mode <> "term")
br-rule-profile
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
if p-list-mode = "general-view" then do:
  assign
  X_rule-profile.profile-type:visible in browse br-rule-profile = no.
end.
if p-list-mode = "term" then do:
  assign
  frame {&frame-name}:title = substitute("Профайлы, подчиненные профайлу &1", p-general-view).
end.
if lookup("b-add", bttns) = 0 then do:
  hide
  b-cmp in frame {&frame-name} .
end.
run Openbr in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
define variable v-term-rp-list as character no-undo .
define buffer buf_profile-by-profile for ub.profile-by-profile.
CASE p-list-mode:
   when {&all} then do:
      frame {&frame-name} :title = "Все профайлы".
      OPEN QUERY br-rule-profile
      FOR EACH X_rule-profile NO-LOCK INDEXED-REPOSITION.
   end.
   when "general-view" then do:
      frame {&frame-name} :title = substitute("Профайлы типа &1", p-general-view).
      OPEN QUERY br-rule-profile
      FOR EACH X_rule-profile NO-LOCK where
               entry(1, X_rule-profile.profile-type, "_")  = p-general-view
      by X_rule-profile.profile_id
     INDEXED-REPOSITION
      .
   end.
   when "term" then do:
         frame {&frame-name} :title = substitute("Профайлы подчиненные профайлу &1", p-general-view).
      for each buf_profile-by-profile no-lock where
              buf_profile-by-profile.profile_id = integer(p-general-view):
        v-term-rp-list = v-term-rp-list + (if v-term-rp-list = '' then '' else {&comma-char}) + string(buf_profile-by-profile.child-profile_id).
      end.
      OPEN QUERY br-rule-profile
      FOR EACH X_rule-profile NO-LOCK where
               lookup(string(X_rule-profile.profile_id), v-term-rp-list) > 0
      by X_rule-profile.profile_id
     INDEXED-REPOSITION
      .
   end.
end case.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-link Dialog-Frame
PROCEDURE proc-b-link :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
DEFINE variable v-rid-list AS CHARACTER NO-undo.
DEFINE variable v-uniq-key-rec AS CHARACTER NO-undo.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_rp-rule-param for ub.rp-rule-param.
CASE p-option:
  WHEN {&TABLE_rule-profile} THEN DO:
    run rul/rule-profile-s.w ( INPUT parparentproc
                              ,INPUT (if v-cntxt-db-num = 0
                                      and lookup("b-add", bttns) > 0
                                      then "b-add":U
                                      else "") /*bttns*/
                              ,INPUT "term"
                              ,INPUT string(X_rule-profile.profile_id) /*p-general-view*/
                              ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  end.
  WHEN {&TABLE_rule} THEN DO:
    run rul/rule-by-profile-s.w ( INPUT parparentproc
                              ,INPUT (if v-cntxt-db-num = 0
                                      and lookup("b-add", bttns) > 0
                                      then "b-add":U
                                      else "") /*bttns*/
                              ,INPUT "profile"
                              ,INPUT X_rule-profile.profile_id
                              ,INPUT 0 /*codex_id*/
                              ,INPUT 0 /*ruleset_id*/
                              ,INPUT 0 /*rule_id*/
                              ,INPUT-OUTPUT v-rid-list) NO-ERROR.

  END.
  WHEN {&TABLE_rp-by-call} THEN DO:
    run rul/rp-by-call-s.w ( INPUT parparentproc
                            ,INPUT "":U
                            ,INPUT "profile-id"
                            ,INPUT X_rule-profile.profile_id
                            ,INPUT '':U /*p-profile-type*/
                            ,input '' /*p-call-id*/
                            ,input 0 /*codex*/
                            ,input 0 /*ruleset*/
                            ,INPUT-OUTPUT v-rid-list
                            ) NO-ERROR.
  END.
  WHEN {&TABLE_ruledict-param} THEN DO:
    run gen-key-rec in this-procedure (
                                        input {&table_rule-profile}
                                        ,input  buffer X_rule-profile:handle
                                        ,output v-uniq-key-rec
                                        ).
    FIND FIRST buf_ruledict NO-LOCK WHERE
              buf_ruledict.entry-type = {&rdict-etype-rule-profile}
          AND buf_ruledict.uniq-key-rec = v-uniq-key-rec.
    run rul/ruledict-param-s.w ( INPUT parparentproc
                              ,input ? /*p-update-proc-handle*/
                              ,INPUT "":U /*bttns*/
                              ,INPUT "entry-id"
                              ,INPUT buf_ruledict.entry-id
                              ,input {&rdict-etype-rule}
                              ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  END.
   WHEN {&TABLE_rule-call-param} THEN DO:
    for each tt0-rule-call-param:
      delete tt0-rule-call-param.
    end.
    define variable jj as integer no-undo .
    define buffer buf_tt0-rule-call-param for tt0-rule-call-param.
    for each buf_rule-by-call no-lock where
            buf_rule-by-call.profile_id = X_rule-profile.profile_id,
      each buf_rp-rule-param no-lock where
            buf_rp-rule-param.profile_id = X_rule-profile.profile_id,
      each buf_rule-call-param no-lock where
              buf_Rule-call-param.call#_id = buf_rule-by-call.call#_id
          and buf_Rule-call-param.codex_id = buf_rule-by-call.codex_id
          and buf_Rule-call-param.ruleset_id = buf_rule-by-call.ruleset_id
          and buf_Rule-call-param.order_id = buf_rule-by-call.order_id
          and buf_Rule-call-param.param-name = buf_rp-rule-param.rule-param-name
    break
    by  buf_rule-call-param.call_id
    by  buf_rp-rule-param.profile_id
    by  buf_rp-rule-param.rp-param-name
    :
      find first tt0-rule-call-param where
                tt0-rule-call-param.call_id = buf_rule-call-param.call_id
            and tt0-rule-call-param.codex_id = buf_rule-call-param.codex_id
            and tt0-rule-call-param.ruleset_id = buf_rule-call-param.ruleset_id
            and tt0-rule-call-param.order_id = buf_rule-call-param.order_id
            and tt0-rule-call-param.param-name = buf_rule-call-param.param-name no-error .
      if not available tt0-rule-call-param then do:
        find first buf_tt0-rule-call-param no-lock where
                buf_tt0-rule-call-param.call_id = buf_rule-call-param.call_id
            and buf_tt0-rule-call-param.whole-send-news = jj no-error.
        create tt0-rule-call-param.
        buffer-copy buf_rule-call-param to tt0-rule-call-param.
        release tt0-rule-call-param.
      end.
    end.
    run ref/rulercps.w ( INPUT parparentproc
                        ,input this-procedure:handle
                        ,INPUT "":U /*bttns*/
                        ,input {&lookup}
                        ,input {&table_rp-rule-param} + {&comma-char} + {&all}
                        ,input X_rule-profile.profile_id
                        ,input ? /*once-more*/
                        ,input '':U /*p-call-id*/
                        ,input 0 /*codex_id*/
                        ,input 0 /*p-ruleset-id*/
                        ,input ? /*p-order-id*/
                        ,input 0 /*p-rule-id*/
                        ,input substitute("Параметры вызова профайла &1"
                                          , X_rule-profile.profile_id
                                          )
                        ,input-output table tt0-rule-call-param ) no-error.

  END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lkp Dialog-Frame
PROCEDURE proc-b-lkp :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
define variable v-rec as recid no-undo.
CASE p-option:
  WHEN {&TABLE_rule-profile} THEN DO:
      v-rec = recid(X_rule-profile).
      run rul/rule-profile-i.w ( input parparentproc
                           ,input {&lookup}
                           ,input X_rule-profile.profile_id
                           ,input-output v-rec) no-error.

  END.
  WHEN "ruleproc-text" THEN DO:
    run rul/run-rule-proc-view.p ( INPUT X_rule-profile.profile-type
                                  ,INPUT '':U /*p-call-id*/
                                  ,INPUT X_rule-profile.profile_id /*p-profile-id*/
                                  ,INPUT "text"
                                  ) NO-ERROR.

  END.
  WHEN "ruleproc-graph" THEN DO:
    run rul/run-rule-proc-view.p ( INPUT X_rule-profile.profile-type
                                  ,INPUT '':U /*p-call-id*/
                                  ,INPUT X_rule-profile.profile_id /*p-profile-id*/
                                  ,INPUT "graph"
                                  ) NO-ERROR.

  END.
END CASE.
IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-term Dialog-Frame
PROCEDURE proc-b-term :
define input parameter p-parent-profile-id as integer no-undo .
define input parameter p-mode as character no-undo .
define output parameter p-rec as recid no-undo .
define variable v-rid-list as character no-undo .
define variable v-rec as recid no-undo .
define buffer buf_rule-profile for ub.rule-profile.
if p-list-mode <> "term" then do:
  message
  "Нельзя добавлять/удалять в этом режиме"
  view-as alert-box .
  return error.
end.
case p-mode :
  when {&add-def} then do:
    message
    "Выберите подчиненный профайл"
    view-as alert-box .
    run rul/rule-profile-s.w ( INPUT parparentproc
                              ,INPUT "b-sel" /*bttns*/
                              ,INPUT {&all}
                              ,INPUT "" /*p-general-view*/
                              ,INPUT-OUTPUT v-rid-list) NO-ERROR.
    if v-rid-list <> '' then do:
        find first buf_rule-profile no-lock where
                    recid(buf_rule-profile) = integer(v-rid-list).
            run rul/profile-by-profile1.p ( input {&add-def}
                                  ,input no /*p-silent*/
                                  ,input-output v-rec
                                  ,input p-parent-profile-id
                                  ,input buf_rule-profile.profile_id
                                  ) no-error.
        if error-status:error then do:
          undo, return error .
        end.
        p-rec = v-rec.
    end.
  end.
  when {&deletion} then do:
    define buffer buf_profile-by-profile for ub.profile-by-profile.
    find first buf_profile-by-profile no-lock where
              buf_profile-by-profile.profile_id = integer(p-general-view)
         and  buf_profile-by-profile.child-profile_id = X_rule-profile.profile_id.
    v-rec = recid(buf_profile-by-profile).
    run rul/profile-by-profile3.p ( input no
                                ,input v-rec) no-error.

    if error-status:error then do:
      undo, return error .
    end.
  end.
end case.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color Dialog-Frame
PROCEDURE set-row-color :
DEFINE INPUT PARAMETER p-parent-feature AS integer NO-UNDO.
if p-parent-feature = integer({&rp-parentf-only-in-combo}) then do:
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME