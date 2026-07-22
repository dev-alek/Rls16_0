&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_rule FOR ub.rule.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список правил

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
/*{&all} codex */
define input parameter p-codex-id as integer no-undo .
define input parameter p-sts as integer no-undo .
/*если статус не важен но надо передавать -999999999*/
define input-output parameter p-rid-list as character no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список правил".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/fltopend.i defproc }
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
DEFINE VARIABL link-option AS CHARACTER NO-UNDO.
DEFINE VARIABL lkp-option AS CHARACTER NO-UNDO.
DEFINE TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE ub.rule-call-param.

define variable sort-column-name as character no-undo .
define variable filter-point-label as character no-undo init "Правила RULE-машины" .
define variable filter-point0 as character no-undo init "rule-s" .
define variable filter-point as character no-undo init "rule-s" .
define variable v-rid-list as character no-undo .
DEFINE VARIABLE status-option AS integer NO-UNDO.
&SCOPED-DEFINE status-code STRING(X_rule.sts)
DEFINE variable cmp-OPTION AS CHARACTER NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-rule

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_rule

/* Definitions for BROWSE br-rule                                       */
&Scoped-define FIELDS-IN-QUERY-br-rule mark-string(recid(X_rule), v-rid-list) X_rule.rule_id {&rule-status-int-name} X_rule.name X_rule.reusable-params (X_rule.hidden-content > 0)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-rule
&Scoped-define SELF-NAME br-rule
&Scoped-define QUERY-STRING-br-rule FOR EACH X_rule NO-LOCK indexed-reposition
&Scoped-define OPEN-QUERY-br-rule OPEN QUERY {&SELF-NAME} FOR EACH X_rule NO-LOCK indexed-reposition.
&Scoped-define TABLES-IN-QUERY-br-rule X_rule
&Scoped-define FIRST-TABLE-IN-QUERY-br-rule X_rule


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-rule}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-chg b-del b-lkp ~
b-links b-sch B-Help B-copy b-status b-cmp b-replace br-rule EDITOR-1 ~
mark-num
&Scoped-Define DISPLAYED-OBJECTS EDITOR-1 mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-cmp
       MENU-ITEM m_one          LABEL "Одно правило"
       MENU-ITEM m_codex        LABEL "По кодексу"
       MENU-ITEM m_list         LABEL "По списку"
       MENU-ITEM m_rule-profile LABEL "Профайл"       .

DEFINE MENU MENU-b-link
       MENU-ITEM m_ruleset      LABEL "Наборы правил"
       MENU-ITEM m_rule-i-script LABEL "Используемые скрипты"
       MENU-ITEM m_rule-profile LABEL "Профайлы"
       MENU-ITEM m_rule-by-call LABEL "Точки вызова"
       MENU-ITEM m_ruledict-param LABEL "Параметры"
       MENU-ITEM m_rule-call-param LABEL "Значения параметров".

DEFINE MENU MENU-b-lkp
       MENU-ITEM m_simple       LABEL "Форма"
       MENU-ITEM m_text         LABEL "Текст"
       MENU-ITEM m_graph        LABEL "Схема"         .

DEFINE MENU MENU-b-status
       MENU-ITEM m_-10          LABEL "Новое"
       MENU-ITEM m_-1           LABEL "Готово"
       MENU-ITEM m_98           LABEL "Удалить"       .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-cmp
     LABEL "Скомпилить"
     SIZE 10 BY 1.

DEFINE BUTTON B-copy
     LABEL "Копировать"
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

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-replace
     LABEL "&Заменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1.

DEFINE BUTTON b-status
     LABEL "Статус"
     SIZE 10 BY 1.

DEFINE VARIABLE EDITOR-1 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2.87 NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9 BY .67
     FGCOLOR 10  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-rule FOR
      X_rule SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-rule Dialog-Frame _FREEFORM
  QUERY br-rule NO-LOCK DISPLAY
      mark-string(recid(X_rule), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_rule.rule_id COLUMN-LABEL "Код правила" FORMAT ">>>>>>>>9"
{&rule-status-int-name} COLUMN-LABEL "Статус" FORMAT "X(8)"
X_rule.name COLUMN-LABEL "Имя объекта" format "X(255)" width 60
X_rule.reusable-params COLUMN-LABEL "Выполнимо!многократно?" format "X(20)"
(X_rule.hidden-content > 0) COLUMN-LABEL "Скрыто" FORMAT "Скрыто/"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16.53 FIT-LAST-COLUMN.


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
     b-sch AT ROW 1 COL 92 WIDGET-ID 22
     B-Help AT ROW 1 COL 95
     B-copy AT ROW 2 COL 38 WIDGET-ID 28
     b-status AT ROW 2 COL 48 WIDGET-ID 26
     b-cmp AT ROW 2 COL 58 WIDGET-ID 18
     b-replace AT ROW 2 COL 68 WIDGET-ID 24
     br-rule AT ROW 3.33 COL 1 WIDGET-ID 100
     EDITOR-1 AT ROW 20 COL 1 NO-LABEL WIDGET-ID 20
     mark-num AT ROW 1 COL 13 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     SPACE(75.24) SKIP(21.21)
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
      TABLE: X_rule B "?" ? ub rule
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-rule b-replace Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-cmp:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-cmp:HANDLE.

ASSIGN
       b-links:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-link:HANDLE.

ASSIGN
       b-lkp:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-lkp:HANDLE.

ASSIGN
       b-status:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-status:HANDLE.

ASSIGN
       EDITOR-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-rule
/* Query rebuild information for BROWSE br-rule
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_rule NO-LOCK indexed-reposition.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-rule */
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
   run rul/rule-i.w ( input parparentproc
                       ,input {&add-def}
                       ,input 0 /*p-rule-id*/
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
    RUN openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
    REPOSITION br-rule TO RECID v-rec NO-ERROR.
    APPLY "value-changed" to br-rule.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  define variable v-rec as recid no-undo.
  if not available X_rule then return no-apply.
  v-rec = recid(X_rule).
  run rul/rule-i.w ( input parparentproc
                       ,input ({&update} + {&comma-char} + (if lookup("b-add", bttns) > 0 then "yes" else "no"))
                       ,input X_rule.rule_id /*p-rule-id*/
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
     br-rule:refresh().
  end.
  APPLY "entry" to br-rule.
  APPLY "VALUE-CHANGED" to br-rule.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cmp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cmp Dialog-Frame
ON CHOOSE OF b-cmp IN FRAME Dialog-Frame /* Скомпилить */
DO:
  DEFINE variable v-rec as recid no-undo.
  if cmp-option = '':U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status:error then do: return no-apply. end.
    if cmp-option = '':U then return no-apply.
    run proc-b-cmp in this-procedure ( input cmp-option) no-error.
    if error-status:error then do:
      cmp-option = '':U.
      return no-apply.
    end.
    cmp-option = '':U.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-copy Dialog-Frame
ON CHOOSE OF B-copy IN FRAME Dialog-Frame /* Копировать */
DO:
DEFINE VARIABLE v-new-rule-id AS INTEGER NO-UNDO.
DEFINE VARIABLE v-rec AS recid NO-UNDO.
DEFINE BUFFER buf_rule FOR ub.RULE.
if not available X_rule then return no-apply.

run rul/rule5.p ( input X_rule.rule_id
                 ,OUTPUT v-new-rule-id) NO-ERROR.
if v-new-rule-id <> 0 then do:
   MESSAGE
   substitute("В результате копирования появилось новое правило &1", v-new-rule-id)
   VIEW-AS ALERT-BOX.
   FIND FIRST buf_rule NO-LOCK WHERE
            buf_rule.RULE_id = v-new-rule-id .
   v-rec = recid(buf_rule).
   RUN openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
   REPOSITION br-rule TO RECID v-rec NO-ERROR.
   APPLY "value-changed" to br-rule.
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
  if not available X_rule then return no-apply.
  v-rec = recid(X_rule).
  message "Вы уверены, что хотите удалить Правило?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then return no-apply.
 run rul/rule3.p ( input no /*p-silent*/
                       ,input v-rec) no-error.
 if error-status:error then return no-apply.
 run Openbr in this-procedure ( input yes, input no, input '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-links
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-links Dialog-Frame
ON CHOOSE OF b-links IN FRAME Dialog-Frame /* Связи */
DO:
  define variable v-rec as recid no-undo.
  if not available X_rule then return no-apply.
  IF link-option = '':U THEN DO:
    run gbl/pop-up.p ( INPUT SELF :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if link-option = "":U then do:
      return no-apply.
  end.
  run proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN DO:
     link-option = ''.
     RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  define variable v-rec as recid no-undo.
  if not available X_rule then return no-apply.
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
  if available X_rule then do:
 { gbl/markstrn.i X_rule v-rid-list }
  glog = br-rule:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-rule:select-next-row ().
      apply "VALUE-CHANGED" to br-rule in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-rule in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-replace
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-replace Dialog-Frame
ON CHOOSE OF b-replace IN FRAME Dialog-Frame /* Заменить */
DO:
  IF NOT AVAILABLE X_rule THEN RETURN NO-APPLY.
  RUN proc-b-replace IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  RUN proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available X_rule then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_rule ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-status
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-status Dialog-Frame
ON CHOOSE OF b-status IN FRAME Dialog-Frame /* Статус */
DO:
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
IF NOT AVAILABLE X_rule THEN RETURN NO-APPLY.
IF status-option = ? THEN DO:
    run gbl/pop-up.p ( INPUT SELF :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if status-option = ? then do:
      return no-apply.
  end.
  run proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      status-option = ?.
      RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-rule
&Scoped-define SELF-NAME br-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-rule Dialog-Frame
ON VALUE-CHANGED OF br-rule IN FRAME Dialog-Frame
DO:
  IF AVAILABLE X_rule THEN DO:
    editor-1:SCREEN-VALUE = X_rule.documentation.
  END.
  ELSE DO:
    editor-1:SCREEN-VALUE = '':U.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_-1 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_-1 /* Готово */
DO:
  ASSIGN
  status-option = -1.
  RUN proc-b-status IN THIS-PROCEDURE ( INPUT status-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      status-option = ?.
      RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_-10
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_-10 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_-10 /* Новое */
DO:
    ASSIGN
  status-option = -10.
  RUN proc-b-status IN THIS-PROCEDURE ( INPUT status-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      status-option = ?.
      RETURN NO-APPLY.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_98
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_98 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_98 /* Удалить */
DO:
    ASSIGN
  status-option = 98.
  RUN proc-b-status IN THIS-PROCEDURE ( INPUT status-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      status-option = ?.
      RETURN NO-APPLY.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_codex
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_codex Dialog-Frame
ON CHOOSE OF MENU-ITEM m_codex /* По кодексу */
DO:
    ASSIGN
  cmp-option = "codex".
  run proc-b-cmp IN THIS-PROCEDURE ( INPUT cmp-option) NO-ERROR.
  ASSIGN
  cmp-option = '':U.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_graph
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_graph Dialog-Frame
ON CHOOSE OF MENU-ITEM m_graph /* Схема */
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


&Scoped-define SELF-NAME m_list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_list Dialog-Frame
ON CHOOSE OF MENU-ITEM m_list /* По списку */
DO:
    ASSIGN
   cmp-option = "list".
   run proc-b-cmp IN THIS-PROCEDURE ( INPUT cmp-option) NO-ERROR.
   ASSIGN
   cmp-option = '':U.
   IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_one Dialog-Frame
ON CHOOSE OF MENU-ITEM m_one /* Одно правило */
DO:
    ASSIGN
  cmp-option = "one".
  run proc-b-cmp IN THIS-PROCEDURE ( INPUT cmp-option) NO-ERROR.
  ASSIGN
  cmp-option = '':U.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_rule-by-call
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_rule-by-call Dialog-Frame
ON CHOOSE OF MENU-ITEM m_rule-by-call /* Точки вызова */
DO:
   ASSIGN
  link-option = {&TABLE_rule-by-call}.
  run proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  ASSIGN
  link-option = '':U.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
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


&Scoped-define SELF-NAME m_rule-i-script
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_rule-i-script Dialog-Frame
ON CHOOSE OF MENU-ITEM m_rule-i-script /* Используемые скрипты */
DO:
    ASSIGN
  link-option = {&TABLE_rule-i-script}.
  run proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  ASSIGN
  link-option = '':U.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_rule-profile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_rule-profile Dialog-Frame
ON CHOOSE OF MENU-ITEM m_rule-profile /* Профайлы */
in menu menu-b-link
DO:
    ASSIGN
  link-option = {&TABLE_rule-by-profile}.
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
in menu menu-b-cmp
DO:
    ASSIGN
   cmp-option = "rule-profile".
   run proc-b-cmp IN THIS-PROCEDURE ( INPUT cmp-option) NO-ERROR.
   ASSIGN
   cmp-option = '':U.
   IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

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


&Scoped-define SELF-NAME m_ruleset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_ruleset Dialog-Frame
ON CHOOSE OF MENU-ITEM m_ruleset /* Наборы правил */
DO:
    ASSIGN
  link-option = {&TABLE_ruleset}.
  run proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  ASSIGN
  link-option = '':U.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_simple
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_simple Dialog-Frame
ON CHOOSE OF MENU-ITEM m_simple /* Форма */
DO:
    ASSIGN
   lkp-option = "simple".
   run proc-b-lkp IN THIS-PROCEDURE ( INPUT lkp-option) NO-ERROR.
   ASSIGN
   lkp-option = '':U.
   IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_text
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_text Dialog-Frame
ON CHOOSE OF MENU-ITEM m_text /* Текст */
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

{ gbl/brwrefre.i " v-doc-rec = recid(X_rule).  ~
  run OpenBR in this-procedure ( input yes, input no, input '':U).  REPOSITION br-rule to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to br-rule. " }

{ gbl/setfltnm.i }
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
  if lookup(p-list-mode, {&all} + {&comma-char} + "codex") = 0 then do:
    message
    substitute("Неверное значение p-list-mode=&1", p-list-mode)
    view-as alert-box error .
    undo main-block, return error .
  end.
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
  DISPLAY EDITOR-1 mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel b-add b-chg b-del b-lkp b-links b-sch B-Help
         B-copy b-status b-cmp b-replace br-rule EDITOR-1 mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable Dialog-Frame
PROCEDURE Myenable :
assign
X_rule.name:resizable in browse br-rule = yes
b-links:MENU-MOUSE in frame {&frame-name} = 1
b-lkp:MENU-MOUSE in frame {&frame-name} = 1
b-status:MENU-MOUSE in frame {&frame-name} = 1
b-cmp:MENU-MOUSE in frame {&frame-name} = 1
.
ENABLE
b-quit
b-add when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-chg when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-del when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-copy when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-lkp
b-links
B-Help
b-mark when lookup("b-mark", bttns) > 0
b-sel when lookup("b-sel", bttns) > 0
b-cmp when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-sch
b-replace when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-status when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
br-rule
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
run openbr in this-procedure ( input yes, input no, input '':U).
APPLY "VALUE-CHANGED" to br-rule.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ("Ждите...").
define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&scop flt-open-open-query OPEN QUERY br-rule FOR EACH X_rule

&scop flt-open-dyn_open-query FOR EACH X_rule

&scop flt-open-query-handle QUERY br-rule:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_rule

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_rule

&scop flt-open-waitfram true

define variable l-open-query as logical   no-undo .

filter-point = filter-point0 + p-list-mode.
CASE p-list-mode :
  WHEN {&all}        THEN DO:
&SCOPED-DEFINE status-code string(p-sts)
    assign
    filter-point-label = substitute("Все правила RULE-машины &1"
                                   , (IF p-sts = -999999999 THEN '':U ELSE {&rule-status-int-name})
                                    )
    frame {&frame-name}:title = filter-point-label
    .
    { gbl/fltopend.i
        &where-cond = " X_rule.upper_rule_id = 0 ~
                        and (p-sts = -999999999 or X_rule.sts = p-sts)"
        &dyn_where-cond = " substitute('X_rule.upper_rule_id = 0 ~
                        and (&1 = -999999999 or X_rule.sts = &1)', p-sts)"

        &use-ind    = "  "
        &by         = " by X_rule.rule_id " }
    END.
    when "codex" then do:
&SCOPED-DEFINE status-code string(p-sts)
      assign
      filter-point-label = substitute("Правила для кодекса &1 &2"
                                      , p-codex-id
                                      , (IF p-sts = -999999999 THEN '':U ELSE {&rule-status-int-name})
                                      )
      frame {&frame-name}:title = filter-point-label
      .
        { gbl/fltopend.i
            &where-cond = " X_rule.upper_rule_id = 0  ~
                           and X_rule.codex_id = p-codex-id ~
                           and (p-sts = -999999999 or X_rule.sts = p-sts)"
            &dyn_where-cond = " substitute('X_rule.upper_rule_id = 0  ~
                           and X_rule.codex_id = &1 ~
                           and (&2 = -999999999 or X_rule.sts = &2)', p-codex-id, p-sts)"

            &use-ind    = "  "
            &by         = " by X_rule.rule_id " }

  END.
END CASE.
if not p-open-query then
REPOSITION br-rule to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-rule:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "ENTRY" TO br-rule.
APPLY "VALUE-CHANGED" TO br-rule in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-cmp Dialog-Frame
PROCEDURE proc-b-cmp :
DEFINe INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-ii-ok AS INTEGER NO-UNDO.
define variable v-rid-list as character no-undo .
DEFINE BUFFER buf_rule FOR ub.RULE.
define buffer buf_ruleset for ub.ruleset.
define buffer buf_rule-profile for ub.rule-profile.

CASE p-option:
  WHEN "one":U  THEN DO:
     IF NOT AVAILABLE X_rule THEN RETURN error.
     v-rid-list = string(RECID(X_rule)).
  END.
  WHEN "codex":U  THEN DO:
      run rul/ruleset-s.w ( input parparentproc
                            ,input "b-sel"
                            ,input "only-codex"
                            ,input 0 /*p-codex-id*/
                            ,input-output v-rid-list) no-error.
     if v-rid-list = '':u then return error.
     find first buf_ruleset no-lock where
              recid(buf_ruleset) = integer(v-rid-list) no-error.
     IF NOT AVAILABLE buf_ruleset THEN RETURN error.
     v-rid-list = '':U.
     for each buf_rule no-lock where
             buf_rule.codex_id = buf_ruleset.codex_id
         and buf_rule.upper_rule_id = 0 :
       v-rid-list = v-rid-list +
                    (if v-rid-list = '':U
                    then '':U
                    else {&comma-char}) + string(recid(buf_rule)).
     end.
  END.
  WHEN "list" THEN DO:
    run rul/rule-s.w ( INPUT parparentproc
                  ,INPUT "b-sel,b-mark" /* bttns */
                  ,INPUT {&ALL} /*p-list-mode */
                  ,INPUT 0 /* p-codex-id */
                  ,INPUT 0 /* p-sts */
                  ,input-output v-rid-list ) NO-ERROR.
    IF v-rid-list = '':U THEN RETURN error.
  END.
  WHEN "rule-profile" THEN DO:
    run rul/rule-profile-s.w ( INPUT parparentproc
                  ,INPUT "b-sel" /* bttns */
                  ,INPUT {&ALL} /*p-list-mode */
                  ,INPUT '':U /* p-general-view */
                  ,input-output v-rid-list ) NO-ERROR.
    IF v-rid-list = '':U THEN RETURN error.
    find first buf_rule-profile no-lock where
              recid(buf_rule-profile) = integer(v-rid-list) no-error.
    if buf_rule-profile.profile-type <> {&table_trn-doc}
    and entry(1, buf_rule-profile.profile-type, "_") <> {&table_chk-doc}
    then do:
      message
      substitute("Компиляция по профайлам предназначена для профайлов типа &1, &2"
                 ,{&table_trn-doc}
                 ,{&table_chk-doc})
      view-as alert-box error .
      return error.
    end.
  END.
END CASE.

run waitfram-show in this-procedure ( input "Ждите..." ).
case p-option:
  when "rule-profile" then do:
    run waitfram-show in this-procedure ( substitute("Компиляция профайла &1", buf_rule-profile.profile_id) ).
    run rul/rp-prep.p ( input buf_rule-profile.profile_id ) no-error.
    if error-status:error then do:
        run waitfram-hide in this-procedure .
        message
        substitute("Ошибка при компиляции профайла&1&2" +
                  "&3&2&4&2"
                  , buf_rule-profile.profile_id
                  , {&new-line}
                  , error-status:error
                  , return-value
                  )
        view-as alert-box error .
    end.
    run waitfram-hide in this-procedure .
  end.
  otherwise do:
    _rule:
    DO v-ii = 1 TO NUM-ENTRIES(v-rid-list):
      FIND FIRST buf_rule NO-LOCK WHERE
                recid(buf_rule) = INTEGER(ENTRY(v-ii, v-rid-list)) NO-ERROR.
      IF NOT AVAILABLE buf_rule THEN DO:
        MESSAGE
        substitute("Не найдено правило с recid &1", INTEGER(ENTRY(v-ii, v-rid-list)))
        VIEW-AS ALERT-BOX ERROR.
      END.
      run waitfram-show in this-procedure ( substitute("Компиляция правила &1", buf_rule.rule_id) ).
      run rul/ruleprep.p ( INPUT buf_rule.RULE_id) no-error.
      if error-status:error then do:
          run waitfram-hide in this-procedure .
          message
          substitute("Ошибка при компиляции правила &1&2" +
                    "&3&2&4&2"
                    , X_rule.rule_id
                    , {&new-line}
                    , error-status:error
                    , return-value
                    )
          view-as alert-box error .
          NEXT _rule.
        end.
        ELSE DO:
          v-ii-ok = v-ii-ok + 1.
        END.
    END.
  end.
end case.

run waitfram-hide in this-procedure .
MESSAGE
SUBSTITUTE("Из выбранных Вами &1 правил удалось откомпилить &2"
           ,v-ii - 1
           ,v-ii-ok)
VIEW-AS ALERT-BOX WARNING.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-link Dialog-Frame
PROCEDURE proc-b-link :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_ruledict FOR ub.ruledict.
DEFINE BUFFER buf_rule-call-param FOR ub.rule-call-param.
IF NOT AVAILABLE X_rule THEN DO:
  undo, RETURN ERROR.
END.
v-rec = recid(X_rule).
CASE p-option:
  WHEN {&TABLE_ruleset} THEN DO:
    run rul/rule-by-set-s.w ( INPUT parparentproc
                            ,INPUT (if (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
                                    then "b-add"
                                    else '':U) /*bttns*/
                            ,INPUT "rule"
                            ,INPUT X_rule.codex_id
                            ,input 0 /*ruleset-id*/
                            ,INPUT X_rule.rule_id /*p-rule-id*/
                            ,INPUT-OUTPUT v-rid-list) NO-ERROR.

  END.
  WHEN {&TABLE_rule-by-call} THEN DO:
      run rul/rule-by-call-s.w ( input parparentproc
                             ,INPUT "":U /*bttns*/
                             ,input "rule"
                             ,input '':U /*call_id*/
                             ,input X_rule.codex_id /*p-codex-is*/
                             ,input 0 /*p-ruleset-id*/
                             ,input X_rule.rule_id
                             ,input-output v-rec) no-error.

  END.
  WHEN {&TABLE_rule-i-script} THEN DO:
      run rul/rule-i-script-s.w ( input parparentproc
                             ,INPUT (if (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
                                    then "b-del":U
                                    else '':U) /*bttns*/
                             ,input "rule"
                             ,input X_rule.rule_id
                             ,INPUT '':U /*script-type*/
                             ,INPUT '':U /*script-name*/
                             ,input-output v-rec) no-error.

  END.
  WHEN {&TABLE_rule-by-profile} THEN DO:
      run rul/rule-by-profile-s.w ( INPUT parparentproc
                                ,INPUT "":U /*bttns*/
                                ,INPUT "rule"
                                ,INPUT 0 /*profile_id*/
                                ,INPUT 0 /*codex_id*/
                                ,INPUT 0 /*ruleset_id*/
                                ,INPUT X_rule.rule_id /*rule_id*/
                                ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  END.
  WHEN {&TABLE_rule-call-param} THEN DO:
    for each tt0-rule-call-param:
      delete tt0-rule-call-param.
    end.

    FOR each buf_rule-call-param no-lock where
              buf_Rule-call-param.rule_id = X_rule.rule_id:
        create tt0-rule-call-param.
        buffer-copy buf_rule-call-param to tt0-rule-call-param.
    end.
    run ref/rulercps.w ( INPUT parparentproc
                        ,input this-procedure:handle
                        ,INPUT "":U /*bttns*/
                        ,input {&lookup}
                        ,input {&table_rule-call-param}
                        ,input 0 /*profile_id*/
                        ,input ? /*once-more*/
                        ,input '':U /*p-call-id*/
                        ,input X_rule.codex_id
                        ,input 0 /*p-ruleset-id*/
                        ,input ? /*p-order-id*/
                        ,input X_rule.RULE_id
                        ,input substitute("Параметры вызова правила: кодекс &1 правило &2"
                                          , X_rule.codex_id
                                          , X_rule.rule_id)
                        ,input-output table tt0-rule-call-param ) no-error.

  END.
  WHEN {&TABLE_ruledict-param} THEN DO:
    FIND FIRST buf_ruledict NO-LOCK WHERE
              buf_ruledict.entry-type = {&rdict-etype-rule}
          AND buf_ruledict.uniq-key-rec = X_rule.uniq-key-rec.
    run rul/ruledict-param-s.w ( INPUT parparentproc
                              ,input ? /*p-update-proc-handle*/
                              ,INPUT "":U /*bttns*/
                              ,INPUT "entry-id"
                              ,INPUT buf_ruledict.entry-id
                              ,input {&rdict-etype-rule}
                              ,INPUT-OUTPUT v-rid-list) NO-ERROR.


  END.

END CASE.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lkp Dialog-Frame
PROCEDURE proc-b-lkp :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
define variable v-rec as recid no-undo.
IF NOT AVAILABLE X_rule THEN DO:
  undo, RETURN ERROR.
END.
IF p-option = "simple" THEN DO:
  v-rec = recid(X_rule).
  run rul/rule-i.w ( input parparentproc
                       ,input {&LOOKUP}
                       ,input X_rule.rule_id /*p-rule-id*/
                       ,input-output v-rec) no-error.
END.
ELSE DO:
    run rul/disprule.p (
                           input p-option
                          ,input X_rule.rule_id
                          ,input 0 /*p-codex-id*/
                          ,input 0 /*p-ruleset-id*/
                          ,input 0 /*p-call-id*/
                          ,input 0 /*p-order-id*/
                           ) no-error .

END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-replace Dialog-Frame
PROCEDURE proc-b-replace :
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-rid-list AS character NO-UNDO.
DEFINE BUFFER buf_rule FOR ub.RULE.
MESSAGE
substitute("Выберите из списка правило, на которое Вы хотите заменить правило &1"
           , X_rule.RULE_id)
VIEW-AS ALERT-BOX.
run rul/rule-s.w ( INPUT parparentproc
                  ,INPUT "b-sel"
                  ,INPUT p-list-mode
                  ,INPUT p-codex-id
                  ,INPUT p-sts
                  ,INPUT-OUTPUT v-rid-list) NO-ERROR.
IF ERROR-STATUS:ERROR
OR v-rid-list = '':U THEN RETURN NO-APPLY.
FIND FIRST buf_rule NO-LOCK WHERE
        recid(buf_rule) = INTEGER(v-rid-list) no-error.
if NOT AVAILABLE buf_rule THEN RETURN NO-APPLY.
run waitfram-show in this-procedure ( input "Ждите..." ).
run rul/rule4.p (
                INPUT X_rule.rule_id
               ,INPUT buf_rule.rule_id
               ) NO-ERROR.
IF error-status:ERROR THEN DO:
  run waitfram-hide in this-procedure .
  message
  error-status:get-message(1)  skip
  return-value
  view-as alert-box error .
  undo, RETURN error.
END.
run waitfram-hide in this-procedure .
v-rec = recid(X_rule).
RUN openbr IN THIS-PROCEDURE ( INPUT YES
                            ,INPUT NO
                            ,INPUT '':U).
REPOSITION br-rule to RECID v-rec NO-ERROR.
APPLY "entry" TO br-rule IN FRAME {&FRAME-NAME}.
APPLY "VALUE-CHANGED" TO br-rule.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
assign
  tbl = 'rule'
  join-tbl = 'X_rule'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('rule_id', 'Код правила', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('name', 'Название', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('documentation', 'Описание', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('reusable-params', 'Выполнимо многократно', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('codex_id', 'Кодекс правил', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                   , INPUT filter-point + {&delim-par} + filter-point-label
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  RUN OpenBr IN THIS-PROCEDURE (INPUT yes
                               ,INPUT no
                               ,INPUT '':U).
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-status Dialog-Frame
PROCEDURE proc-b-status :
DEFINE INPUT PARAMETER p-status AS INTEGER NO-UNDO.
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
run rul/rule2.p ( INPUT NO
               ,INPUT RECID(X_rule)
               ,INPUT p-status) NO-ERROR.
IF error-status:ERROR THEN DO:
 undo, RETURN error.
END.
v-rec = recid(X_rule).
RUN openbr IN THIS-PROCEDURE ( INPUT YES
                            ,INPUT NO
                            ,INPUT '':U).
REPOSITION br-rule to RECID v-rec NO-ERROR.
APPLY "entry" TO br-rule IN FRAME {&FRAME-NAME}.
APPLY "VALUE-CHANGED" TO br-rule.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME