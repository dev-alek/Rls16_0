&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER down-rule FOR ub.rule.
DEFINE BUFFER locked_rule FOR ub.rule.
DEFINE BUFFER locked_ruledict FOR ub.ruledict.
DEFINE NEW SHARED TEMP-TABLE tt-rule NO-UNDO LIKE ub.rule
       field level as integer.
DEFINE NEW SHARED TEMP-TABLE tt-rule-i-script NO-UNDO LIKE ub.rule-i-script.
DEFINE NEW SHARED TEMP-TABLE tt-rule-script NO-UNDO LIKE ub.rule-script
       field level as integer
       field gen-order as character
       field upper_rule_id as integer.
DEFINE NEW SHARED TEMP-TABLE tt-ruledict-param NO-UNDO LIKE ub.ruledict-param.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование одного правила RUM

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование одного правила RUM".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }

DEFINE VARIABLE v-level AS INTEGER NO-UNDO.
define variable v-mess as character no-undo .
define variable v-ok as logical no-undo .
DEFINE BUFFER FIRST_rule FOR ub.RULE.
DEFINE VARIABLE add-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE move-option AS CHARACTER NO-UNDO.
&SCOPED-DEFINE main-column-name "Выражение"
DEFINE VARIABLE v-param-num-list AS CHARACTER NO-UNDO.
define variable v-is-admin-mode as logical no-undo .
DEFINE BUFFER MOVE_tt-rule-script FOR tt-rule-script.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-rule-script

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-rule-script tt-rule

/* Definitions for BROWSE br-rule-script                                */
&Scoped-define FIELDS-IN-QUERY-br-rule-script tt-rule-script.rule_id tt-rule-script.gen-order tt-rule-script.level tt-rule-script.upper_rule_id tt-rule-script.script-type tt-rule-script.script_id tt-rule-script.salience (fill({&space-char}, tt-rule-script.level * 2) + tt-rule-script.script)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-rule-script
&Scoped-define SELF-NAME br-rule-script
&Scoped-define QUERY-STRING-br-rule-script FOR EACH tt-rule-script WHERE     tt-rule-script.root_RULE_id  = tt-rule.RULE_id AND tt-rule-script.LANGUAGE = rs-language NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-rule-script OPEN QUERY {&SELF-NAME} FOR EACH tt-rule-script WHERE     tt-rule-script.root_RULE_id  = tt-rule.RULE_id AND tt-rule-script.LANGUAGE = rs-language NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-rule-script tt-rule-script
&Scoped-define FIRST-TABLE-IN-QUERY-br-rule-script tt-rule-script


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-rule.rule_id ~
tt-rule.codex_id tt-rule.reusable-params tt-rule.name ~
tt-rule.image-file-name tt-rule.documentation
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-rule.reusable-params ~
tt-rule.name tt-rule.documentation
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-rule
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-rule
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-rule-script}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-rule SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-rule SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-rule
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-rule


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-rule.reusable-params tt-rule.name ~
tt-rule.documentation
&Scoped-define ENABLED-TABLES tt-rule
&Scoped-define FIRST-ENABLED-TABLE tt-rule
&Scoped-Define ENABLED-OBJECTS B-exit b-quit T-hidden b-print B-Help ~
B-codex b-image b-sel B-add B-del B-chg b-move B-text b-params RS-language ~
br-rule-script
&Scoped-Define DISPLAYED-FIELDS tt-rule.rule_id tt-rule.codex_id ~
tt-rule.reusable-params tt-rule.name tt-rule.image-file-name ~
tt-rule.documentation
&Scoped-define DISPLAYED-TABLES tt-rule
&Scoped-define FIRST-DISPLAYED-TABLE tt-rule
&Scoped-Define DISPLAYED-OBJECTS T-hidden RS-language

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-add
       MENU-ITEM m_cond0        LABEL "Условие"
       MENU-ITEM m_cons0        LABEL "Следствие"
       MENU-ITEM m_goto0        LABEL "Переход"
       MENU-ITEM m_cycle-cond0  LABEL "Цикл-Условие"
       MENU-ITEM m_rule         LABEL "Подправило"
       MENU-ITEM m_else-rule    LABEL "Иначе-Подправило"
       MENU-ITEM m_cond         LABEL "Условие в подправило"
       MENU-ITEM m_cons         LABEL "Следствие в подправило"
       MENU-ITEM m_goto         LABEL "Переход в подправило"
       MENU-ITEM m_cycle-cond   LABEL "Цикл-Условие"  .

DEFINE MENU MENU-b-sel
       MENU-ITEM m_script0      LABEL "Скрипт в правило"
       MENU-ITEM m_script       LABEL "Скрипт в подправило".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-codex
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-image
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 2.5 BY 1.

DEFINE BUTTON b-move
     LABEL "Перенести"
     SIZE 10 BY 1.

DEFINE BUTTON b-params
     LABEL "Параметры"
     SIZE 10 BY 1.

DEFINE BUTTON b-print
     LABEL "Button 1"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel
     LABEL "Выбор"
     SIZE 10 BY 1.

DEFINE BUTTON B-text
     LABEL "Изм.текст"
     SIZE 10 BY 1.

DEFINE VARIABLE RS-language AS CHARACTER INITIAL "ABL"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "ABL", "ABL",
"lan", "lan"
     SIZE 14.5 BY .77 NO-UNDO.

DEFINE VARIABLE T-hidden AS LOGICAL INITIAL no
     LABEL "Скрытое содержание"
     VIEW-AS TOGGLE-BOX
     SIZE 22 BY .8 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-rule-script FOR
      tt-rule-script SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      tt-rule SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-rule-script
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-rule-script Dialog-Frame _FREEFORM
  QUERY br-rule-script NO-LOCK DISPLAY
      tt-rule-script.rule_id    COLUMN-LABEL "Код!подправила" FORMAT ">>>>>>>>9"
tt-rule-script.gen-order  COLUMN-LABEL "ПОР" FORMAT "X(255)" WIDTH 12
tt-rule-script.level    COLUMN-LABEL "Уро!вень" FORMAT ">9"
tt-rule-script.upper_rule_id  COLUMN-LABEL "Вышест.!Правило" FORMAT ">>>>>>>>9"
tt-rule-script.script-type COLUMN-LABEL "Тип" FORMAT "X(4)" WIDTH 4
tt-rule-script.script_id COLUMN-LABEL "Код!скрипта" FORMAT ">>>>>>>>9" WIDTH 4
tt-rule-script.salience  COLUMN-LABEL "Пор." FORMAT ">>9"
(fill({&space-char}, tt-rule-script.level * 2)  + tt-rule-script.script)
COLUMN-LABEL {&main-column-name} FORMAT "X(255)" WIDTH 60
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 14.5
         FONT 4 ROW-HEIGHT-CHARS .54 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     tt-rule.rule_id AT ROW 1 COL 33.5 COLON-ALIGNED WIDGET-ID 2
          LABEL "Код правила" FORMAT ">>>>>>>9"
          VIEW-AS FILL-IN NATIVE
          SIZE 10 BY 1
          FGCOLOR 4
     T-hidden AT ROW 1 COL 48.5 WIDGET-ID 46
     b-print AT ROW 1 COL 92 WIDGET-ID 44
     B-Help AT ROW 1 COL 95
     tt-rule.codex_id AT ROW 2 COL 33.5 COLON-ALIGNED WIDGET-ID 4
          LABEL "Кодекс" FORMAT ">>>>>>9"
          VIEW-AS FILL-IN NATIVE
          SIZE 10 BY 1
          FGCOLOR 4
     tt-rule.reusable-params AT ROW 2 COL 69.5 COLON-ALIGNED WIDGET-ID 40
          LABEL "Повторно используемо"
          VIEW-AS FILL-IN NATIVE
          SIZE 27.5 BY 1
     B-codex AT ROW 2.07 COL 46 WIDGET-ID 28
     tt-rule.name AT ROW 3 COL 1 NO-LABEL WIDGET-ID 32
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 1.87
     tt-rule.image-file-name AT ROW 5 COL 41.5 COLON-ALIGNED WIDGET-ID 48
          LABEL "Файл изображ." FORMAT "x(24)"
          VIEW-AS FILL-IN NATIVE
          SIZE 40 BY 1
     b-image AT ROW 5 COL 96 WIDGET-ID 50
     tt-rule.documentation AT ROW 6 COL 1 NO-LABEL WIDGET-ID 8
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 1.8
     b-sel AT ROW 7.77 COL 25 WIDGET-ID 38
     B-add AT ROW 7.77 COL 35 WIDGET-ID 18
     B-del AT ROW 7.77 COL 45 WIDGET-ID 20
     B-chg AT ROW 7.77 COL 55 WIDGET-ID 22
     b-move AT ROW 7.77 COL 65 WIDGET-ID 36
     B-text AT ROW 7.77 COL 75 WIDGET-ID 42
     b-params AT ROW 7.77 COL 85 WIDGET-ID 30
     RS-language AT ROW 8 COL 1 NO-LABEL WIDGET-ID 14
     br-rule-script AT ROW 8.77 COL 1 WIDGET-ID 100
     "Описание" VIEW-AS TEXT
          SIZE 13.5 BY .77 AT ROW 5 COL 1 WIDGET-ID 10
     "Название" VIEW-AS TEXT
          SIZE 13.5 BY .77 AT ROW 2 COL 1 WIDGET-ID 34
     SPACE(84.50) SKIP(20.50)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Правило"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: down-rule B "NEW SHARED" NO-UNDO ub rule
      TABLE: locked_rule B "?" ? ub rule
      TABLE: locked_ruledict B "?" ? ub ruledict
      TABLE: tt-rule T "NEW SHARED" NO-UNDO ub rule
      ADDITIONAL-FIELDS:
          field level as integer
      END-FIELDS.
      TABLE: tt-rule-i-script T "NEW SHARED" NO-UNDO ub rule-i-script
      TABLE: tt-rule-script T "NEW SHARED" NO-UNDO ub rule-script
      ADDITIONAL-FIELDS:
          field level as integer
          field gen-order as character
          field upper_rule_id as integer
      END-FIELDS.
      TABLE: tt-ruledict-param T "NEW SHARED" NO-UNDO ub ruledict-param
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-rule-script RS-language Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add:HANDLE.

ASSIGN
       b-sel:HIDDEN IN FRAME Dialog-Frame           = TRUE
       b-sel:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-sel:HANDLE.

ASSIGN
       br-rule-script:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

/* SETTINGS FOR FILL-IN tt-rule.codex_id IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN tt-rule.image-file-name IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN tt-rule.reusable-params IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-rule.rule_id IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-rule-script
/* Query rebuild information for BROWSE br-rule-script
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-rule-script WHERE
    tt-rule-script.root_RULE_id  = tt-rule.RULE_id
AND tt-rule-script.LANGUAGE = rs-language NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-rule-script */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-rule"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON END-ERROR OF FRAME Dialog-Frame /* Правило */
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  DEFINE BUFFER buf_tt-rule-script FOR tt-rule-script.
  IF p-mode = {&add-def} THEN do:
    FIND FIRST buf_tt-rule-script NO-LOCK WHERE
                buf_tt-rule-script.RULE_id = tt-rule.RULE_id NO-ERROR.
    IF AVAILABLE buf_tt-rule-script THEN DO:
      MESSAGE
      "Выйти из режима редактирования и не сохранять правило"
      VIEW-AS ALERT-BOX ERROR BUTTONS YES-NO UPDATE glog.
      IF NOT glog  THEN DO:
         RETURN NO-APPLY.
      END.
    END.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Правило */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Правило */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
 IF add-option = '':U  THEN DO:
    run gbl/pop-up.p ( INPUT self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if add-option = "":U then do:
      return no-apply.
  end.
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option
                                    ,INPUT '':U /*p-move-script-al*/
                                    ,INPUT '':U /*p-move-script-nl*/
                                    ,input 0 /*p-move-script-id*/
                                    ,input 0 /*p-mode-rule-id*/
                                    ,input 0 /*p-move-cond-id*/
                                    ) NO-ERROR.
  IF error-status:ERROR THEN DO:
      add-option = '':u.
      RETURN NO-APPLY.
  END.
  add-option = '':u.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  if not available tt-rule-script then return no-apply.
  IF tt-rule.codex_id = 0  THEN DO:
     MESSAGE
     "Для редактирования необходима сначала выбрать кодекс правил"
      VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.
  END.

  run rul/updrule.w (
                      INPUT parparentproc
                     ,input {&update}
                     ,INPUT tt-rule.codex_id
                     ,input tt-rule.root_rule_id /*p-root-rule-id*/
                     ,input tt-rule.upper_rule_id /*p-upper-rule-id*/
                     ,input tt-rule-script.rule_id
                     ,input tt-rule-script.script-type
                     ,input tt-rule-script.salience
                     ,input-output tt-rule-script.script_id
                     ) no-error.
  if error-status:error then do:
    return no-apply.
  end.
  br-rule-script:refresh().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-codex
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-codex Dialog-Frame
ON CHOOSE OF B-codex IN FRAME Dialog-Frame /* Btn 1 */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_ruleset FOR ub.ruleset.
if tt-rule.codex_id <> 0 then do:
  find first buf_ruleset no-lock where
          buf_ruleset.codex_id = tt-rule.codex_id
      and buf_ruleset.ruleset_id = 0 .
  v-rid-list = string(recid(buf_ruleset)).
end.
run rul/ruleset-s.w ( INPUT parparentproc
                     ,INPUT 'b-sel':U /*bttns*/
                     ,input "only-codex"
                     ,input 0 /*p-codex-id*/
                     ,INPUT-OUTPUT v-rid-list) NO-ERROR.
IF v-rid-list <> '':U THEN DO:
   FIND FIRST buf_ruleset NO-LOCK WHERE
            recid(buf_ruleset) = INTEGER(v-rid-list) NO-ERROR.
  IF NOT AVAILABLE buf_RULESET THEN RETURN NO-APPLY.
  ASSIGN
  tt-rule.codex_id = buf_ruleset.codex_id.
  DISPLAY
  tt-rule.CODEx_id
  WITH FRAME {&FRAME-NAME}.
END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
 DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  IF NOT AVAILABLE tt-rule-script THEN RETURN NO-APPLY.
  MESSAGE
  substitute("Вы уверены, что хотите удалить данный скрипт&1"  +
             "&2&1" +
             "код подправила &3, уровень &4 тип скрипта &5 код скрипта &6 порядок &7"
             , {&NEW-LINE}
             ,tt-rule-script.script
             ,tt-rule-script.rule_id
             ,tt-rule-script.level
             ,tt-rule-script.script-type
             ,tt-rule-script.script_id
             ,tt-rule-script.salience  )
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO  UPDATE glog.
  IF not glog THEN RETURN NO-APPLY.
  RUN proc-b-del IN THIS-PROCEDURE ( input tt-rule-script.rule_id
                                    ,input tt-rule-script.script_id) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-image
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-image Dialog-Frame
ON CHOOSE OF b-image IN FRAME Dialog-Frame /* Btn 1 */
DO:
 define variable v_os-file   AS CHAR NO-UNDO INIT "".
define variable ll_commit AS LOG    NO-UNDO INIT NO.
define variable file-name        as character no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable glog as logical no-undo .
  SYSTEM-DIALOG GET-FILE v_os-file
  TITLE "Задайте файла изображения"
  FILTERS
    " Все bmp файлы (*.bmp) " "*.bmp",
    " Все ico файлы (*.ico) " "*.ico",
    " Все gif файлы (*.gif) " "*.gif",
    " Все jpg файлы (*.jpg) " "*.jpg",
    " Все файлы (*.*) "                      "*.*"
  INITIAL-FILTER 1
  DEFAULT-EXTENSION ".xml"
  USE-FILENAME
  MUST-EXIST
  UPDATE ll_commit
  .
  IF ll_commit <> YES THEN do:
      RETURN NO-APPLY.
  end.
  IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
      BELL.
      MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
  END.
  ASSIGN file-name = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) ).
  run gbl/filename.p (
                  input  v_os-file
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
  if error-status:error  = ? then do:
    return no-apply.
  end.
  assign
  file-name = v-full-path.
  DISPlay
  file-name @ tt-rule.image-file-name WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-move
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-move Dialog-Frame
ON CHOOSE OF b-move IN FRAME Dialog-Frame /* Перенести */
DO:
  IF NOT AVAILABLE tt-rule-script THEN DO:
      RETURN NO-APPLY.
  END.
  RUN proc-b-move IN THIS-PROCEDURE ( input tt-rule-script.rule_id
                                    ,input tt-rule-script.script_id) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-params
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-params Dialog-Frame
ON CHOOSE OF b-params IN FRAME Dialog-Frame /* Параметры */
DO:
  RUN proc-b-params IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      UNDO, RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Button 1 */
DO:
  RUN proc-b-print IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  DEFINE VARIABLE v-cont AS LOGICAL NO-UNDO.
  IF NOT AVAILABLE tt-rule-script THEN DO:
  END.
  IF RECID(tt-rule-script) = recid(move_tt-rule-script) THEN DO:
     MESSAGE
     "Используйте стрелки"
     VIEW-AS ALERT-BOX.
  END.
  ELSE DO:
   IF move-option = '':U THEN DO:
      run gbl/pop-up.p ( INPUT b-sel:handle, input no ) no-error.
      IF ERROR-STATUS:ERROR
      OR move-option = '':U THEN DO:

      END.
      ELSE DO:
         v-cont = YES.
      END.
   END.
   else do:
     v-cont = yes.
   end.
   IF v-cont = YES THEN
      MESSAGE
      substitute("Вы уверены, что хотите перенести скрипт&1"  +
                 "&2&1" +
                 "код подправила &3, уровень &4 тип скрипта &5 код скрипта &6 порядок &7&1"
                 , {&NEW-LINE}
                 ,move_tt-rule-script.script
                 ,move_tt-rule-script.rule_id
                 ,move_tt-rule-script.level
                 ,move_tt-rule-script.script-type
                 ,move_tt-rule-script.script_id
                 ,move_tt-rule-script.salience  )
      SUBSTITUTE("после скрипта&1" +
                 "&2&1" +
                 "код подправила &3, уровень &4 тип скрипта &5 код скрипта &6 порядок &7"
                 , {&NEW-LINE}
                 ,tt-rule-script.script
                 ,tt-rule-script.rule_id
                 ,tt-rule-script.level
                 ,tt-rule-script.script-type
                 ,tt-rule-script.script_id
                 ,tt-rule-script.salience  )
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO  UPDATE glog.
      IF not glog THEN do:
        v-cont = NO.
      END.
  END.
  IF v-cont = YES then DO:
    RUN proc-aff-move IN THIS-PROCEDURE ( input move_tt-rule-script.rule_id
                                             ,input move_tt-rule-script.script_id
                                             ,INPUT tt-rule-script.RULE_id
                                             ,INPUT tt-rule-script.script_id
                                             ,INPUT move-option) NO-ERROR.
  END.
  RUN proc-cancel-move IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-text
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-text Dialog-Frame
ON CHOOSE OF B-text IN FRAME Dialog-Frame /* Изм.текст */
DO:
  DEFINE VARIABLE v-longchar AS LONGCHAR NO-UNDO.
  DEFINE VARIABLE v-ok AS LOGical NO-UNDO.
  if not available tt-rule-script then return no-apply.
  v-longchar = tt-rule-script.script.
     run gbl/d-longchar.w (
                           INPUT ? /*h-callback*/
                          ,INPUT (if v-is-admin-mode then 'readonly=no\' else '')     /*p-parameters*/
                          ,input-output v-longchar
                          ,output v-ok
                           ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   OR NOT v-ok THEN undo, RETURN NO-apply.
   ASSIGN
   tt-rule-script.script = v-longchar.
   br-rule-script:REFRESH().
   v-longchar = '':U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-rule-script
&Scoped-define SELF-NAME br-rule-script
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-rule-script Dialog-Frame
ON VALUE-CHANGED OF br-rule-script IN FRAME Dialog-Frame
DO:
  RUN switch-rule IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_cond
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_cond Dialog-Frame
ON CHOOSE OF MENU-ITEM m_cond /* Условие в подправило */
DO:
  ASSIGN
  add-option = {&rule-script-cond}.
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option
                                    ,INPUT '':U
                                    ,INPUT '':U
                                    ,input 0 /*p-move-script-id*/
                                    ,input 0 /*p-mode-rule-id*/
                                    ,input 0 /*p-move-cond-id*/
                                    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     ASSIGN
     add-option = '':U.
     RETURN NO-APPLY.
  END.
  ASSIGN
  add-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_cond0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_cond0 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_cond0 /* Условие */
DO:
   ASSIGN
  add-option = ({&rule-script-cond} + {&comma-char} + "0").
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option
                                    ,INPUT '':U
                                    ,INPUT '':U
                                    ,input 0 /*p-move-script-id*/
                                    ,input 0 /*p-mode-rule-id*/
                                    ,input 0 /*p-move-cond-id*/
                                    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     ASSIGN
     add-option = '':U.
     RETURN NO-APPLY.
  END.
  ASSIGN
  add-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_cons
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_cons Dialog-Frame
ON CHOOSE OF MENU-ITEM m_cons /* Следствие в подправило */
DO:
    ASSIGN
  add-option = {&rule-script-cons}.
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option
                                    ,INPUT '':U
                                    ,INPUT '':U
                                    ,input 0 /*p-move-script-id*/
                                    ,input 0 /*p-mode-rule-id*/
                                    ,input 0 /*p-move-cond-id*/
                                    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     ASSIGN
     add-option = '':U.
     RETURN NO-APPLY.
  END.
  ASSIGN
  add-option = '':U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_cons0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_cons0 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_cons0 /* Следствие */
DO:
    ASSIGN
  add-option = ({&rule-script-cons} + {&comma-char} + "0").
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option
                                    ,INPUT '':U
                                    ,INPUT '':U
                                    ,input 0 /*p-move-script-id*/
                                    ,input 0 /*p-mode-rule-id*/
                                    ,input 0 /*p-move-cond-id*/
                                    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     ASSIGN
     add-option = '':U.
     RETURN NO-APPLY.
  END.
  ASSIGN
  add-option = '':U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_cycle-cond
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_cycle-cond Dialog-Frame
ON CHOOSE OF MENU-ITEM m_cycle-cond /* Цикл-Условие */
DO:
  ASSIGN
  add-option = {&rule-script-cycle-cond}.
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option
                                    ,INPUT '':U
                                    ,INPUT '':U
                                    ,input 0 /*p-move-script-id*/
                                    ,input 0 /*p-mode-rule-id*/
                                    ,input 0 /*p-move-cond-id*/
                                    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     ASSIGN
     add-option = '':U.
     RETURN NO-APPLY.
  END.
  ASSIGN
  add-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_cycle-cond0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_cycle-cond0 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_cycle-cond0 /* Цикл-Условие */
DO:
   ASSIGN
  add-option = ({&rule-script-cycle-cond} + {&comma-char} + "0").
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option
                                    ,INPUT '':U
                                    ,INPUT '':U
                                    ,input 0 /*p-move-script-id*/
                                    ,input 0 /*p-mode-rule-id*/
                                    ,input 0 /*p-move-cond-id*/
                                    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     ASSIGN
     add-option = '':U.
     RETURN NO-APPLY.
  END.
  ASSIGN
  add-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_else-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_else-rule Dialog-Frame
ON CHOOSE OF MENU-ITEM m_else-rule /* Иначе-Подправило */
DO:
  ASSIGN
  add-option = {&rule-script-else-RULE}.
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option
                                    ,INPUT '':U
                                    ,INPUT '':U
                                    ,input 0 /*p-move-script-id*/
                                    ,input 0 /*p-mode-rule-id*/
                                    ,input 0 /*p-move-cond-id*/
                                    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     ASSIGN
     add-option = '':U.
     RETURN NO-APPLY.
  END.
  ASSIGN
  add-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_goto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_goto Dialog-Frame
ON CHOOSE OF MENU-ITEM m_goto /* Переход в подправило */
DO:
    ASSIGN
  add-option = {&rule-script-goto}.
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option
                                    ,INPUT '':U
                                    ,INPUT '':U
                                    ,input 0 /*p-move-script-id*/
                                    ,input 0 /*p-mode-rule-id*/
                                    ,input 0 /*p-move-cond-id*/
                                    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     ASSIGN
     add-option = '':U.
     RETURN NO-APPLY.
  END.
  ASSIGN
  add-option = '':U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_goto0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_goto0 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_goto0 /* Переход */
DO:
    ASSIGN
  add-option = ({&rule-script-goto} + {&comma-char} + "0").
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option
                                    ,INPUT '':U
                                    ,INPUT '':U
                                    ,input 0 /*p-move-script-id*/
                                    ,input 0 /*p-mode-rule-id*/
                                    ,input 0 /*p-move-cond-id*/
                                    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     ASSIGN
     add-option = '':U.
     RETURN NO-APPLY.
  END.
  ASSIGN
  add-option = '':U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_rule Dialog-Frame
ON CHOOSE OF MENU-ITEM m_rule /* Подправило */
DO:
  ASSIGN
  add-option = {&rule-script-RULE}.
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option
                                    ,INPUT '':U
                                    ,INPUT '':U
                                    ,input 0 /*p-move-script-id*/
                                    ,input 0 /*p-mode-rule-id*/
                                    ,input 0 /*p-move-cond-id*/
                                    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     ASSIGN
     add-option = '':U.
     RETURN NO-APPLY.
  END.
  ASSIGN
  add-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_script
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_script Dialog-Frame
ON CHOOSE OF MENU-ITEM m_script /* Скрипт в подправило */
DO:

  ASSIGN
  move-option = "script".
  APPLY "CHOOSE" TO b-sel IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_script0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_script0 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_script0 /* Скрипт в правило */
DO:

  ASSIGN
  move-option = "script0".
  APPLY "CHOOSE" TO b-sel IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-language
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-language Dialog-Frame
ON VALUE-CHANGED OF RS-language IN FRAME Dialog-Frame
DO:
  ASSIGN
   rs-language.
  RUN openbr IN THIS-PROCEDURE NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-hidden
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-hidden Dialog-Frame
ON VALUE-CHANGED OF T-hidden IN FRAME Dialog-Frame /* Скрытое содержание */
DO:
  ASSIGN
  t-hidden.
  CASE t-hidden:
    WHEN YES THEN DO:
        DISABLE
        b-add
        b-chg
        b-move
        b-del
        b-text
        WITH FRAME {&FRAME-NAME}.
    END.
    WHEN NO THEN DO:
      IF p-mode <> {&LOOKUP} THEN DO:

        enable
        b-add
        b-chg
        b-move
        b-del
        b-text
        WITH FRAME {&FRAME-NAME}.
      END.
    END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if num-entries(p-mode) > 1 then do:
    assign
    v-is-admin-mode = logical(entry(2, p-mode)) no-error .
    p-mode = entry(1, p-mode).
  end.
  RUN fill-main-table IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
  IF p-mode <> {&add-def}  THEN DO:
    RUN fill-tables IN THIS-PROCEDURE (  INPUT tt-rule.RULE_id
                                    ,INPUT tt-rule.root_RULE_id
                                    ,INPUT-OUTPUT v-level
                                    ,INPUT "") no-error.

    IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
  END.
  RUN Myenable.
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY T-hidden RS-language
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-rule THEN
    DISPLAY tt-rule.rule_id tt-rule.codex_id tt-rule.reusable-params tt-rule.name
          tt-rule.image-file-name tt-rule.documentation
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit T-hidden b-print B-Help tt-rule.reusable-params B-codex
         tt-rule.name b-image tt-rule.documentation b-sel B-add B-del B-chg
         b-move B-text b-params RS-language br-rule-script
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-main-table Dialog-Frame
PROCEDURE fill-main-table :
DEFINE BUFFER buf_tt-ruledict-param FOR tt-ruledict-param.
DEFINE BUFFER buf_ruledict-param FOR ub.ruledict-param.
DEFINE BUFFER buf_ruledict FOR ub.ruledict.
define buffer buf_rule-i-script for ub.rule-i-script.
define buffer buf_tt-rule-i-script for tt-rule-i-script.

FOR EACH tt-rule:
  DELETE tt-rule.
END.
FOR EACH tt-rule-script:
  DELETE tt-rule-script.
END.
FOR EACH tt-rule-i-script:
  DELETE tt-rule-i-script.
END.
FOR EACH tt-ruledict-param:
  DELETE tt-ruledict-param.
END.

IF p-mode = {&add-def} THEN DO:
    /*заблокируем*/
    FIND FIRST first_rule EXCLUSIVE-LOCK.
    CREATE tt-rule.
    ASSIGN
    tt-rule.upper_rule_id = 0
    tt-rule.RULE_id = next-value(s-rule-id, {&db-name_schema})
    tt-rule.root_rule_id = tt-rule.rule_id
    .
END.
else do:
  IF p-mode = {&UPDATE} THEN DO:
    FIND FIRST LOCKED_rule EXCLUSIVE-LOCK WHERE
              LOCKED_rule.RULE_id = p-rule-id.
    if locked_rule.upper_rule_id <> 0 then do:
      message
      "Нельзя вызвать интерейс редактирования для НЕКОРНЕВОГО (upper_rule_id <> 0) правила"
      view-as alert-box error .
      undo, return error .
    end.
    if v-is-admin-mode = no then do:
      run trg/rule-chk.p ( input {&update}
                          ,input p-rule-id
                          ,output v-ok
                          ,output v-mess) no-error.
      if error-status:error
      or not v-ok then do:
        message
        "Нельзя изменить правило" skip
        error-status:get-message(1) skip
        v-mess
        view-as alert-box error .
        undo, return error .
      end.
    end.
    for each buf_rule-i-script where
            buf_rule-i-script.root_rule_id = p-rule-id:
      create buf_tt-rule-i-script.
      buffer-copy buf_rule-i-script
      to buf_tt-rule-i-script.

    end.
    FIND FIRST locked_ruledict EXCLUSIVE-LOCK WHERE
              locked_ruledict.ENTRY-type = {&rdict-etype-rule}
        AND locked_ruledict.uniq-key-rec = locked_rule.uniq-key-rec NO-ERROR.
  END.
  IF p-mode = {&LOOKUP} THEN DO:
      FIND FIRST LOCKED_rule no-lock WHERE
                LOCKED_rule.rule_id = p-rule-id.
      FIND FIRST locked_ruledict NO-LOCK WHERE
                locked_ruledict.ENTRY-type = {&rdict-etype-rule}
          AND locked_ruledict.uniq-key-rec = locked_rule.uniq-key-rec NO-ERROR.
      IF NOT AVAILABLE locked_ruledict THEN DO:
        MESSAGE
        substitute("Для правила &1 не найден термин в словаре", p-rule-id)
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
      END.
  END.
  create tt-rule.
  buffer-copy locked_rule to tt-rule.
  FOR EACH buf_ruledict-param NO-LOCK WHERE
        buf_ruledict-param.entry-id = locked_ruledict.ENTRY-id:
    CREATE buf_tt-ruledict-param.
    BUFFER-COPY buf_ruledict-param TO buf_tt-ruledict-param.
  END.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-root-rule-id AS INTEGER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-level AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-gen-order AS character NO-UNDO.
DEFINE BUFFER buf_rule FOR ub.RULE.
DEFINE BUFFER buf_rule-script FOR ub.RULE-script.
DEFINE BUFFER buf_tt-rule FOR tt-RULE.
DEFINE BUFFER buf_tt-rule-script FOR tt-RULE-script.
p-level = p-level + 1.
FOR EACH buf_rule NO-LOCK WHERE
        buf_rule.UPPER_rule_id = p-rule-id:
   find first buf_tt-rule where
            buf_tt-rule.rule_id = buf_rule.rule_id no-error.
   if not available buf_tt-rule then do:
    CREATE buf_tt-rule.
    buffer-copy buf_rule to buf_tt-rule.
    ASSIGN
    buf_tt-rule.root_rule_id = p-root-rule-id
    .
   end.
   buf_tt-rule.level = p-level.
   RUN fill-tables IN THIS-PROCEDURE (  INPUT buf_tt-rule.RULE_id
                                       ,INPUT p-root-rule-id
                                       ,INPUT-OUTPUT p-level
                                       ,INPUT (p-gen-order +
                                        STRING(p-level, "99") +
                                        STRING(buf_tt-rule.salience, "999"))).

END.
FOR EACH buf_rule-script NO-LOCK WHERE
        buf_rule-script.rule_id = p-rule-id:
   find first buf_tt-rule-script where
            buf_tt-rule-script.script_id = buf_rule-script.script_id
       AND  buf_tt-rule-script.LANGUAGE = buf_rule-script.LANGUAGE
       no-error.
   if not available buf_tt-rule-script
   then do:
    find first buf_tt-rule no-lock where
              buf_tt-rule.rule_id = buf_rule-script.rule_id.
    CREATE buf_tt-rule-script.
    buffer-copy buf_rule-script to buf_tt-rule-script.
    ASSIGN
    buf_tt-rule-script.root_rule_id = p-root-rule-id
    buf_tt-rule-script.upper_rule_id = buf_tt-rule.upper_rule_id
    .
   end.
   assign
   buf_tt-rule-script.level = p-level
   buf_tt-rule-script.gen-order = p-gen-order +
                                  STRING(buf_tt-rule-script.level, "99") +
                                  STRING(buf_tt-rule-script.salience, "999").
   .
END.

p-level = p-level - 1.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tt-ruledict-param Dialog-Frame
PROCEDURE fill-tt-ruledict-param :
DEFINE INPUT PARAMETER p-bh AS HANDLE NO-UNDO.
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
FOR EACH tt-ruledict-param
ON error  UNDO, RETURN ERROR
ON stop  UNDO, RETURN ERROR:
  ASSIGN
  glog = p-bh:BUFFER-CREATE() NO-ERROR.
  IF NOT glog THEN DO:
     UNDO, RETURN ERROR substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  END.
  ASSIGN
  glog = p-bh:BUFFER-Copy( BUFFER tt-ruledict-param:HANDLE) NO-ERROR.
  IF NOT glog THEN DO:
     UNDO, RETURN ERROR substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tt-tables Dialog-Frame
PROCEDURE fill-tt-tables :
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-root-rule-id AS INTEGER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-level AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-gen-order AS character NO-UNDO.
DEFINE BUFFER buf_tt-rule FOR tt-RULE.
DEFINE BUFFER buf_tt-rule-script FOR tt-RULE-script.
p-level = p-level + 1.
FOR EACH buf_tt-rule NO-LOCK WHERE
        buf_tt-rule.UPPER_rule_id = p-rule-id:
   buf_tt-rule.level = p-level.
   RUN fill-tt-tables IN THIS-PROCEDURE (  INPUT buf_tt-rule.RULE_id
                                       ,INPUT p-root-rule-id
                                       ,INPUT-OUTPUT p-level
                                       ,INPUT (p-gen-order +
                                        STRING(p-level, "99") +
                                        STRING(buf_tt-rule.salience, "999"))).

END.
OUTPUT TO kk.txt.
FOR EACH buf_tt-rule-script NO-LOCK WHERE
        buf_tt-rule-script.rule_id = p-rule-id,
   FIRST buf_tt-rule WHERE buf_tt-rule.RULE_id = buf_tt-rule-script.RULE_id:

   assign
   buf_tt-rule-script.UPPER_rule_id = buf_tt-rule.UPPER_rule_id
   buf_tt-rule-script.level = p-level
   buf_tt-rule-script.gen-order = p-gen-order +
                                  STRING(buf_tt-rule-script.level, "99") +
                                  STRING(buf_tt-rule-script.salience, "999").
   .
   EXPORT buf_tt-rule-script.
END.
OUTPUT CLOSE.
p-level = p-level - 1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-h AS WIDGET-HANDLE NO-UNDO.
assign
rs-language:radio-buttons in frame {&frame-name} = "ABL" + {&comma-char} + "ABL" + {&comma-char} +
                                                   "{&language}" + {&comma-char} + "{&language}"
v-h = br-rule-script:FIRST-COLUMN IN FRAME {&FRAME-NAME}
b-add:menu-mouse IN FRAME {&FRAME-NAME} = 1
b-sel:menu-mouse IN FRAME {&FRAME-NAME} = 1
.
tt-rule-script.gen-order:RESIZABLE IN BROWSE br-rule-script = YES.
DO while valid-handle(v-h) :
  if v-h:LABEL = {&main-column-name} then do:
    v-h:RESIZABLE = YES.
    LEAVE.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.
ASSIGN
t-hidden = tt-rule.HIDDEN-content > 0
.
DISPLAY RS-language
WITH FRAME {&frame-name} .
IF AVAILABLE tt-rule THEN
DISPLAY
tt-rule.rule_id
tt-rule.reusable-params
tt-rule.codex_id
tt-rule.documentation
tt-rule.name
t-HIDDEN
tt-rule.image-file-name
WITH FRAME {&frame-name} .
ENABLE
B-exit  when p-mode <> {&lookup}
b-quit
tt-rule.reusable-params when p-mode <> {&lookup}
B-Help
tt-rule.name
tt-rule.documentation
b-image when p-mode <> {&lookup}
RS-language
B-add   when p-mode <> {&lookup}
B-del   when p-mode <> {&lookup}
B-chg   when p-mode <> {&lookup}
B-move   when p-mode <> {&lookup}
B-text   when p-mode <> {&lookup}
t-hIDDEN WHEN p-mode <> {&lookup}
b-print
b-codex WHEN (p-mode <> {&LOOKUP}
              AND NOT CAN-FIND (FIRST ub.rule-i-script WHERE
                                      ub.rule-script.RULE_id = tt-rule.RULE_id)
              AND NOT CAN-FIND (FIRST ub.rule WHERE
                                      ub.rule.upper_RULE_id = tt-rule.RULE_id)
              AND NOT CAN-FIND (FIRST ub.rule-script WHERE
                                      ub.rule-script.RULE_id = tt-rule.RULE_id)
             )
br-rule-script
b-params
WITH FRAME {&frame-name} .
ASSIGN
tt-rule.documentation:READ-ONLY IN FRAME {&FRAME-NAME} = (p-mode = {&LOOKUP})
tt-rule.name:READ-ONLY IN FRAME {&FRAME-NAME} = (p-mode = {&LOOKUP}).
if p-mode = {&lookup} then do:
  hide
  b-exit
  b-add
  b-chg
  b-del
  b-move
  in frame {&frame-name} .
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1.
  if tt-rule.codex_id <> 19 then do:
    hide
    b-image
    tt-rule.image-file-name
    in frame {&frame-name} .
  end.
end.
VIEW FRAME {&frame-name} .
APPLY "VALUE-CHANGED" to t-hidden.
RUN Openbr IN THIS-PROCEDURE NO-ERROR.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openbr Dialog-Frame
PROCEDURE openbr :
OPEN QUERY br-rule-script FOR EACH tt-rule-script NO-LOCK  WHERE
    tt-rule-script.root_RULE_id  = tt-rule.RULE_id
AND tt-rule-script.LANGUAGE = rs-language
BY tt-rule-script.gen-order
INDEXED-REPOSITION.
APPLY "ENTRY" to browse br-rule-script .
APPLY "VALUE-CHANGED" to browse br-rule-script.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-aff-move Dialog-Frame
PROCEDURE proc-aff-move :
define input parameter p-move-rule-id as integer no-undo .
define input parameter p-move-script-id as integer no-undo .
define input parameter p-dest-rule-id as integer no-undo .
define input parameter p-dest-script-id as integer no-undo .
define input parameter p-move-option as character no-undo .
DEFINE VARIABLE v-add-option AS CHARACTER NO-UNDO extent 3.
DEFINE VARIABLE v-script-al AS CHARACTER NO-UNDO  extent 3.
DEFINE VARIABLE v-script-nl AS CHARACTER NO-UNDO extent 3.
define variable v-script-type as character no-undo  extent 3.
define variable v-script-id as integer no-undo extent 3.
define variable v-rule-id as integer no-undo extent 3.
DEFINE BUFFER MOVE_tt-rule-script FOR tt-rule-script.
DEFINE BUFFER MOVE2_tt-rule-script FOR tt-rule-script.
DEFINE BUFFER dest_tt-rule-script FOR tt-rule-script.
define buffer move_tt-rule  for tt-rule.

FOR each MOVE_tt-rule-script WHERE
           MOVE_tt-rule-script.RULE_id = p-move-rule-id
      AND  MOVE_tt-rule-script.script_id = p-move-script-id:
  IF MOVE_tt-rule-script.LANGUAGE = "ABL" THEN DO:
     v-script-al[1] = MOVE_tt-rule-script.script.
     v-script-type[1] = move_tt-rule-script.script-type.
  END.
  IF MOVE_tt-rule-script.LANGUAGE = "{&language}" THEN DO:
     v-script-nl[1] = MOVE_tt-rule-script.script.
  END.
  case  move_tt-rule-script.script-type:
    when {&rule-script-cond}
    or
    when {&rule-script-cycle-cond}
    then do:
      for each move2_tt-rule-script where
          move2_tt-rule-script.rule_id = move_tt-rule-script.rule_id
      and move2_tt-rule-script.salience > move_tt-rule-script.salience :
        if move2_tt-rule-script.script-type = {&rule-script-rule}
        and v-script-type[2] = '':U
        then do:
          v-add-option[2] = {&rule-script-rule}.
          v-script-al[2] = MOVE2_tt-rule-script.script.
          v-script-type[2] = move2_tt-rule-script.script-type.
          v-script-nl[2] = MOVE2_tt-rule-script.script.
          v-script-id[2] = MOVE2_tt-rule-script.script_id.
          find first move_tt-rule  where
                    move_tt-rule.upper_rule_id = move2_tt-rule-script.rule_id
               and  move_tt-rule.salience = move2_tt-rule-script.salience.
          v-rule-id[2] = move_tt-rule.rule_id.
        end.
        if move2_tt-rule-script.script-type = {&rule-script-else-rule}
        and v-script-type[3] = '':U
        then do:
          v-add-option[3] = {&rule-script-else-rule}.
          v-script-al[3] = MOVE2_tt-rule-script.script.
          v-script-type[3] = move2_tt-rule-script.script-type.
          v-script-nl[3] = MOVE2_tt-rule-script.script.
          v-script-id[3] = MOVE2_tt-rule-script.script_id.
          find first move_tt-rule  where
                    move_tt-rule.upper_rule_id = move2_tt-rule-script.rule_id
               and  move_tt-rule.salience = move2_tt-rule-script.salience.
          v-rule-id[3] = move_tt-rule.rule_id.

        end.
      end. /*      for each move2_tt-rule-script where*/
    end.
  end case.
END.
FIND FIRST dest_tt-rule-script WHERE
           dest_tt-rule-script.RULE_id = p-dest-rule-id
      AND  dest_tt-rule-script.script_id = p-dest-script-id.
case p-move-option:
  WHEN "script" THEN DO:
    IF v-script-type[1] = {&rule-script-cond} THEN DO:
      v-add-option[1] = {&rule-script-cond}.
    END.
    IF v-script-type[1] = {&rule-script-cycle-cond} THEN DO:
      v-add-option[1] = {&rule-script-cycle-cond}.
    END.
    IF v-script-type[1] = {&rule-script-cons} THEN DO:
      v-add-option[1] = {&rule-script-cons}.
    END.
    IF v-script-type[1] = {&rule-script-goto} THEN DO:
      v-add-option[1] = {&rule-script-goto}.
    END.
  END.
  WHEN "script0" THEN DO:
    IF v-script-type[1] = {&rule-script-cond} THEN DO:
        v-add-option[1] = ({&rule-script-cond} + {&comma-char} + "0").
    END.
    IF v-script-type[1] = {&rule-script-cycle-cond} THEN DO:
        v-add-option[1] = ({&rule-script-cycle-cond} + {&comma-char} + "0").
    END.
    IF v-script-type[1] = {&rule-script-cons} THEN DO:
        v-add-option[1] = ({&rule-script-cons} + {&comma-char} + "0").
    END.
    IF v-script-type[1] = {&rule-script-goto} THEN DO:
        v-add-option[1] = ({&rule-script-goto} + {&comma-char} + "0").
    END.
  END.
END CASE.
do transaction:
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT v-add-option[1]
                                    ,INPUT v-script-al[1]
                                    ,INPUT v-script-nl[1]
                                    ,input p-move-script-id
                                    ,input 0 /*p-mode-rule-id*/
                                    ,input 0 /*p-move-cond-id*/
                                    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    RETURN.
  END.
  if v-add-option[2] <> '':U then do:

    RUN proc-b-add IN THIS-PROCEDURE ( INPUT v-add-option[2]
                                      ,INPUT v-script-al[2]
                                      ,INPUT v-script-nl[2]
                                      ,input v-script-id[2]
                                      ,input v-rule-id[2]
                                      ,input p-move-script-id /*p-move-cond-id*/
                                      ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      RETURN.
    END.
  end.
  if v-add-option[3] <> '':U then do:
    RUN proc-b-add IN THIS-PROCEDURE ( INPUT v-add-option[3]
                                      ,INPUT v-script-al[3]
                                      ,INPUT v-script-nl[3]
                                      ,input v-script-id[3]
                                      ,input v-rule-id[3]
                                      ,input p-move-script-id /*p-move-cond-id*/
                                      ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      RETURN.
    END.
  end.
  if not v-add-option[1] begins {&rule-script-cond}
  and not v-add-option[1] begins {&rule-script-cycle-cond}
  then do:
    FOR each MOVE_tt-rule-script WHERE
              MOVE_tt-rule-script.RULE_id = p-move-rule-id
          AND  MOVE_tt-rule-script.script_id = p-move-script-id:
      RUN proc-b-del IN THIS-PROCEDURE ( INPUT p-move-rule-id
                                        ,INPUT p-move-script-id).
    END.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
DEFINE INPUT PARAMETER p-add-option AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-move-script-al AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-move-script-nl AS CHARACTER NO-UNDO.
define input parameter p-move-script-id as integer no-undo .
define input parameter p-move-rule-id as integer no-undo .
define input parameter p-move-cond-id as integer no-undo .
DEFINE VARIABLE v-add-option AS character NO-UNDO.
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-upper-rule-id AS INTEGER.
DEFINE VARIABLE v-rule-id AS INTEGER.
DEFINE VARIABLE v-script-id AS INTEGER.
define variable v-salience as integer no-undo .
define variable v-level as integer no-undo .
DEFINE BUFFER buf_tt-rule FOR tt-rule.
DEFINE BUFFER buf2_tt-rule FOR tt-rule.
DEFINE BUFFER buf_tt-rule-script FOR tt-rule-script.
DEFINE BUFFER buf2_tt-rule-script FOR tt-rule-script.
DEFINE BUFFER buf_tt-l_rule-script FOR tt-rule-script.
DEFINE BUFFER bufm_tt-l_rule-script FOR tt-rule-script.
DEFINE BUFFER bufm_tt-rule-script FOR tt-rule-script.
define buffer buf_tt-rule-i-script for tt-rule-i-script.
define buffer bufm_tt-rule-i-script for tt-rule-i-script.
IF tt-rule.codex_id = 0  THEN DO:
     MESSAGE
     "Для редактирования необходимо сначала выбрать кодекс правил"
      VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.
 END.
IF AVAILABLE tt-rule-script THEN DO:
  v-rec = RECID(tt-rule-script).
END.
CASE p-add-option:
  WHEN {&rule-script-RULE} THEN DO:
    v-add-option = {&rule-script-RULE}.
    if p-move-rule-id = 0 then do:
      IF NOT AVAILABLE tt-rule-script THEN DO:
        assign
        v-upper-rule-id = tt-rule.rule_id
        v-rule-id = 0
        v-salience =0
        .
      END.
      ELSE DO:
        assign
        v-upper-rule-id = tt-rule-script.rule_id
        v-rule-id = 0
        v-salience = tt-rule-script.salience + 1
        .
      END.
      create buf_tt-rule.
      assign
      buf_tt-rule.upper_rule_id = v-upper-rule-id
      buf_tt-rule.root_rule_id = tt-rule.root_rule_id
      buf_tt-rule.name = '':U
      buf_tt-rule.documentation = '':U
      buf_tt-rule.salience = v-salience
      buf_tt-rule.codex_id = tt-rule.codex_id
      buf_tt-rule.RULE_id = next-value(s-rule-id, {&db-name_schema})
      .
      IF NOT AVAILABLE tt-rule-script THEN DO:
        assign
        v-rule-id = tt-rule.rule_id
        v-salience =0
        .
      END.
      ELSE DO:
        assign
        v-rule-id = tt-rule-script.rule_id
        v-salience = tt-rule-script.salience + 1
        .
      END.
      CREATE buf_tt-rule-script.
      ASSIGN
      v-script-id = next-value(s-rule-script-id, {&db-name_schema})
      buf_tt-rule-script.script_id = v-script-id
      buf_tt-rule-script.RULE_id = v-rule-id
      buf_tt-rule-script.root_RULE_id = buf_tt-rule.root_rule_id
      buf_tt-rule-script.salience = v-salience
      buf_tt-rule-script.script-type = {&rule-script-RULE}
      buf_tt-rule-script.LANGUAGE = "ABL".
      RELEASE buf_tt-rule-script.
      CREATE buf_tt-l_rule-script.
      ASSIGN
      buf_tt-l_rule-script.script_id = v-script-id
      buf_tt-l_rule-script.RULE_id = v-rule-id
      buf_tt-l_rule-script.root_RULE_id = tt-rule.root_rule_id
      buf_tt-l_rule-script.salience = v-salience
      buf_tt-l_rule-script.script-type = {&rule-script-RULE}
      buf_tt-l_rule-script.LANGUAGE = "{&language}".
      RELEASE buf_tt-l_rule-script.
    end. /*if p-move-rule-id = 0 then do:*/
    else do:
      /*если переносим блок надо найти скрипт к которому относится правило и взять с него upper-rule и салиенсе*/
      find first buf_tt-rule-script where
                buf_tt-rule-script.script_id = p-move-cond-id .
      assign
      v-upper-rule-id = buf_tt-rule-script.rule_id
      v-salience = buf_tt-rule-script.salience + 1
      .
      find first buf_tt-rule where buf_tt-rule.rule_id = p-move-rule-id.
      assign
      buf_tt-rule.upper_rule_id = v-upper-rule-id
      buf_tt-rule.salience = v-salience
      .
      find first buf_tt-rule-script where
                buf_tt-rule-script.script_id = p-move-script-id
            and buf_tt-rule-script.language = "ABL".
      ASSIGN
      buf_tt-rule-script.RULE_id = v-rule-id
      buf_tt-rule-script.salience = v-salience
      .
      RELEASE buf_tt-rule-script.
      find first buf_tt-l_rule-script where
                buf_tt-l_rule-script.script_id = p-move-script-id
            and buf_tt-l_rule-script.language = "{&language}".
      ASSIGN
      buf_tt-l_rule-script.RULE_id = v-rule-id
      buf_tt-l_rule-script.salience = v-salience.
      RELEASE buf_tt-l_rule-script.
    end. /*else  p-move-rule-id = 0 then do:*/
  END.
  WHEN {&rule-script-else-RULE} THEN DO:
    v-add-option = {&rule-script-else-RULE}.
    IF NOT AVAILABLE tt-rule-script THEN DO:
      message "Нельзя создать" view-as alert-box error .
      return error.
    END.
    ELSE DO:
      assign
      v-upper-rule-id = tt-rule-script.rule_id
      v-rule-id = 0
      v-salience = tt-rule-script.salience + 1
      .
    END.
    if p-move-rule-id = 0 then do:
      create buf_tt-rule.
      assign
      buf_tt-rule.upper_rule_id = v-upper-rule-id
      buf_tt-rule.root_rule_id = tt-rule.root_rule_id
      buf_tt-rule.name = '':U
      buf_tt-rule.documentation = '':U
      buf_tt-rule.salience = v-salience
      buf_tt-rule.codex_id = tt-rule.codex_id
      buf_tt-rule.RULE_id = next-value(s-rule-id, {&db-name_schema})
      .
      assign
      v-rule-id = tt-rule-script.rule_id
      v-salience = tt-rule-script.salience + 1
      .
      CREATE buf_tt-rule-script.
      ASSIGN
      v-script-id = next-value(s-rule-script-id, {&db-name_schema})
      buf_tt-rule-script.script_id = v-script-id
      buf_tt-rule-script.RULE_id = v-rule-id
      buf_tt-rule-script.root_RULE_id = buf_tt-rule.root_rule_id
      buf_tt-rule-script.salience = v-salience
      buf_tt-rule-script.script-type = {&rule-script-else-RULE}
      buf_tt-rule-script.LANGUAGE = "ABL".
      RELEASE buf_tt-rule-script.
      CREATE buf_tt-l_rule-script.
      ASSIGN
      buf_tt-l_rule-script.script_id = v-script-id
      buf_tt-l_rule-script.RULE_id = v-rule-id
      buf_tt-l_rule-script.root_RULE_id = tt-rule.root_rule_id
      buf_tt-l_rule-script.salience = v-salience
      buf_tt-l_rule-script.script-type = {&rule-script-else-RULE}
      buf_tt-l_rule-script.LANGUAGE = "{&language}".
      RELEASE buf_tt-l_rule-script.
    end. /*if p-move-rule-id = 0 then do:*/
    else do: /*else if p-move-rule-id = 0 then do:*/
      find first buf_tt-rule where buf_tt-rule.rule_id = p-move-rule-id.
      assign
      buf_tt-rule.upper_rule_id = v-upper-rule-id
      buf_tt-rule.salience = v-salience
      .
      assign
      v-rule-id = tt-rule-script.rule_id
      v-salience = tt-rule-script.salience + 1
      .
      find first buf_tt-rule-script where
                buf_tt-rule-script.script_id = p-move-script-id
            and buf_tt-rule-script.language = "ABL".
      ASSIGN
      buf_tt-rule-script.RULE_id = v-rule-id
      buf_tt-rule-script.salience = v-salience.
      RELEASE buf_tt-rule-script.
      find first buf_tt-l_rule-script where
                buf_tt-l_rule-script.script_id = p-move-script-id
            and buf_tt-l_rule-script.language = "{&language}".
      ASSIGN
      buf_tt-l_rule-script.RULE_id = v-rule-id
      buf_tt-l_rule-script.salience = v-salience.
      RELEASE buf_tt-l_rule-script.
    end. /*else if p-move-rule-id = 0 then do:*/
  END.
  WHEN {&rule-script-cons}
  or
  WHEN ({&rule-script-cons} + {&comma-char} + "0")
  or
  WHEN {&rule-script-goto}
  or
  WHEN ({&rule-script-goto} + {&comma-char} + "0")
  THEN DO:
     if p-add-option begins {&rule-script-cons} then do:
       v-add-option = {&rule-script-cons}.
     end.
     if p-add-option begins {&rule-script-goto} then do:
       v-add-option = {&rule-script-goto}.
     end.
     IF NOT AVAILABLE tt-rule-script THEN DO:
       assign
       v-upper-rule-id = tt-rule.UPPER_rule_id
       v-rule-id = tt-rule.RULE_id
       v-salience = 0
       .
     END.
     ELSE DO:
       if (tt-rule-script.script-type = {&rule-script-RULE}
       or tt-rule-script.script-type = {&rule-script-else-RULE})
       AND (p-add-option = {&rule-script-cons}
            or
            p-add-option = {&rule-script-goto})
       then do:
         find first buf_tt-rule no-lock where
                   buf_tt-rule.upper_RULE_id = tt-rule-script.RULE_id
              and  buf_tt-rule.salience = tt-rule-script.salience  .
         assign
         v-upper-rule-id = buf_tt-rule.UPPER_rule_id
         v-rule-id = buf_tt-rule.RULE_id
         v-salience = 0.
       end.
       else do:
         FIND FIRST buf_tt-rule NO-LOCK WHERE
                   buf_tt-rule.RULE_id = tt-rule-script.RULE_id.
        assign
        v-upper-rule-id = buf_tt-rule.UPPER_rule_id.
        v-rule-id = buf_tt-rule.RULE_id.
        v-salience = tt-rule-script.salience + 1
       .
      end.
    eND.
  END.
  WHEN {&rule-script-cond}
  or
  WHEN ({&rule-script-cond} + {&comma-char} + "0")
  or
  when {&rule-script-cycle-cond}
  or
  when ({&rule-script-cycle-cond} + {&comma-char} + "0")
  THEN DO:
     v-add-option = entry(1, p-add-option).
     IF NOT AVAILABLE tt-rule-script THEN DO:
       assign
       v-upper-rule-id = tt-rule.upper_rule_id
       v-rule-id = tt-rule.RULE_id
       v-salience =  0
       .
     END.
     ELSE DO:
       if (tt-rule-script.script-type = {&rule-script-RULE}
       or tt-rule-script.script-type = {&rule-script-else-RULE})
       AND (p-add-option = {&rule-script-cond}
            or
            p-add-option = {&rule-script-cycle-cond})
       then do:
         find first buf_tt-rule no-lock where
                   buf_tt-rule.upper_RULE_id = tt-rule-script.RULE_id
              and  buf_tt-rule.salience = tt-rule-script.salience  .
         assign
         v-upper-rule-id = buf_tt-rule.UPPER_rule_id
         v-rule-id = buf_tt-rule.RULE_id
         v-salience = 0.
       end.
       else do:
        FIND FIRST buf_tt-rule NO-LOCK WHERE
            buf_tt-rule.RULE_id = tt-rule-script.RULE_id.
        assign
        v-upper-rule-id = buf_tt-rule.UPPER_rule_id
        v-rule-id = buf_tt-rule.RULE_id
        v-salience = tt-rule-script.salience + 1
        .
      end.
    END.
  END.
END CASE.
 IF p-add-option = {&rule-script-RULE}
 or p-add-option = {&rule-script-else-RULE}
 THEN DO:
   ERROR-STATUS:ERROR = NO.
 END.
 ELSE DO:
   IF p-move-script-id = 0 THEN DO:
      /*простое добавление*/
       run rul/updrule.w ( INPUT parparentproc
                              ,input  {&add-def}
                              ,INPUT tt-rule.codex_id
                              ,input tt-rule.root_rule_id /*p-root-rule-id*/
                              ,input v-upper-rule-id  /*p-upper-rule-id*/
                              ,input v-rule-id        /*p-rule-id*/
                              ,INPUT v-add-option
                              ,input v-salience
                              ,INPUT-OUTPUT v-script-id
                              ) NO-ERROR.

   END.
   ELSE DO:
     if p-move-script-id = 0
     or p-add-option begins {&rule-script-cons}
     or p-add-option begins {&rule-script-goto}
     then do:
      v-script-id = next-value(s-rule-script-id, {&db-name_schema}).
      CREATE bufm_tt-rule-script.
      ASSIGN
      bufm_tt-rule-script.script_id = v-script-id
      bufm_tt-rule-script.RULE_id = v-rule-id
      bufm_tt-rule-script.root_RULE_id = tt-rule.root_rule_id
      bufm_tt-rule-script.salience = v-salience
      bufm_tt-rule-script.script-type = v-add-option
      bufm_tt-rule-script.LANGUAGE = "ABL"
      bufm_tt-rule-script.script = p-move-script-al
      .
      CREATE bufm_tt-l_rule-script.
      ASSIGN
      bufm_tt-l_rule-script.script_id = v-script-id
      bufm_tt-l_rule-script.RULE_id = v-rule-id
      bufm_tt-l_rule-script.root_RULE_id = tt-rule.root_rule_id
      bufm_tt-l_rule-script.salience = v-salience
      bufm_tt-l_rule-script.script-type = v-add-option
      bufm_tt-l_rule-script.LANGUAGE = "{&language}"
      bufm_tt-l_rule-script.script = p-move-script-nl
      .
      for each bufm_tt-rule-i-script where
              bufm_tt-rule-i-script.root_rule_id = tt-rule.root_rule_id
          and bufm_tt-rule-i-script.script_id = p-move-script-id
      on error undo, return error:
        create  buf_tt-rule-i-script.
        buffer-copy bufm_tt-rule-i-script
        except script_id to buf_tt-rule-i-script
        assign
        buf_tt-rule-i-script.script_id = v-script-id
        .
        delete bufm_tt-rule-i-script.
      end.
      RELEASE bufm_tt-l_rule-script.
      RELEASE bufm_tt-rule-script.
    END.
    else do:
      find first bufm_tt-rule-script where
                bufm_tt-rule-script.script_id = p-move-script-id
            and bufm_tt-rule-script.LANGUAGE = "ABL".
      ASSIGN
      bufm_tt-rule-script.RULE_id = v-rule-id
      bufm_tt-rule-script.salience = v-salience
      .
      find first bufm_tt-l_rule-script where
                bufm_tt-l_rule-script.script_id = p-move-script-id
            and bufm_tt-l_rule-script.LANGUAGE = "{&language}".
      ASSIGN
      bufm_tt-l_rule-script.RULE_id = v-rule-id
      bufm_tt-l_rule-script.salience = v-salience
      .
      RELEASE bufm_tt-l_rule-script.
      RELEASE bufm_tt-rule-script.
    end.
  end.
 END.
 IF NOT ERROR-STATUS:ERROR THEN DO:
   repeat preselect each buf_tt-rule-script WHERE
           buf_tt-rule-script.rule_id = v-rule-id:
     find next buf_tt-rule-script.
     if available buf_tt-rule-script
     and  buf_tt-rule-script.salience >= v-salience then do:
       if buf_tt-rule-script.script_id = v-script-id then do:
         next.
       end.
       else do:
         if buf_tt-rule-script.script-type = {&rule-script-RULE}
         or buf_tt-rule-script.script-type = {&rule-script-else-RULE}
         then do:
           find first buf2_tt-rule where
                     buf2_tt-rule.upper_rule_id = buf_tt-rule-script.rule_id
                and  buf2_tt-rule.salience = buf_tt-rule-script.salience no-error .
         end.
         ASSIGN
         buf_tt-rule-script.salience = buf_tt-rule-script.salience + 1
         .
         if available buf2_tt-rule then do:
          ASSIGN
          buf2_tt-rule.salience = buf2_tt-rule.salience + 1
          .
          release buf2_tt-rule.

         end.
       end.
     end. /*if available buf_tt-rule-script then do:*/
   END.
   RUN fill-tt-tables IN THIS-PROCEDURE (  INPUT tt-rule.RULE_id
                                        ,INPUT tt-rule.root_RULE_id
                                        ,INPUT-OUTPUT v-level
                                        ,INPUT "") no-error.

END.
ASSIGN
add-option = '':U.
RUN openbr IN THIS-PROCEDURE NO-ERROR.
REPOSITION br-rule-script TO RECID v-rec NO-ERROR.
APPLY "VALUE-CHANGED" to browse br-rule-script.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
define input parameter p-rule-id as integer no-undo .
define input parameter p-script-id as integer no-undo .
define variable v-delete-rule as logical no-undo .
define buffer buf_tt-rule for tt-rule.
define buffer buf2_tt-rule for tt-rule.
DEFINE BUFFER buf_tt-rule-script FOR tt-rule-script.
DEFINE BUFFER buf2_tt-rule-script FOR tt-rule-script.
define buffer buf_tt-rule-i-script for tt-rule-i-script.
do
on error undo, return error
:
  find first buf_tt-rule where buf_tt-rule.rule_id = p-rule-id.
  find first buf_tt-rule-script where
            buf_tt-rule-script.script_id = p-script-id.
  if buf_tt-rule-script.script-type = {&rule-script-RULE}
  or buf_tt-rule-script.script-type = {&rule-script-else-RULE}
  then do:
     find first buf2_tt-rule where
              buf2_tt-rule.upper_rule_id = p-rule-id
         and  buf2_tt-rule.salience = buf_tt-rule-script.salience.
     v-delete-rule = yes.
  end.
  if (buf_tt-rule-script.script-type = {&rule-script-cond}
      or
      buf_tt-rule-script.script-type = {&rule-script-cycle-cond})
  and buf_tt-rule-script.rule_id <> buf_tt-rule-script.root_rule_id
  then do:
    for each buf2_tt-rule-script where
            buf2_tt-rule-script.rule_id = buf_tt-rule-script.rule_id
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      if buf2_tt-rule-script.script_id = p-script-id
      or buf2_tt-rule-script.script-type = {&rule-script-RULE}
      or buf2_tt-rule-script.script-type = {&rule-script-else-RULE}
      or buf2_tt-rule-script.salience < buf_tt-rule-script.salience
      or buf2_tt-rule-script.salience >  buf_tt-rule-script.salience + 1
      then do:
        next.
      end.
      message
      substitute("Вы пытаетесь удалить условие (1-ю строку) подправила  &1, которое содержит другие строки(&2)&3" +
                 "это недопустимо"
                 ,buf_tt-rule-script.rule_id
                 ,buf2_tt-rule-script.script_id
                 , {&new-line})
      view-as alert-box error .
      undo, return error .
    end.
  end.
  FIND last buf2_tt-rule-script WHERE
      buf2_tt-rule-script.root_RULE_id  = buf_tt-rule.RULE_id
  AND buf2_tt-rule-script.LANGUAGE = rs-language
  AND ((buf2_tt-rule-script.level = buf_tt-rule.level
  AND buf2_tt-rule-script.salience < buf_tt-rule-script.salience)
      OR
      buf2_tt-rule-script.level < buf_tt-rule.level ) NO-ERROR.
  for each buf_tt-rule-i-script where
          buf_tt-rule-i-script.root_rule_id = tt-rule.rule_id
      and buf_tt-rule-i-script.script_id = p-script-id
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    delete buf_tt-rule-i-script.
  end.
  for each buf_tt-rule-script where
          buf_tt-rule-script.script_id = p-script-id
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    DELETE buf_tt-rule-script.
  end.
  if v-delete-rule then do:
    delete buf2_tt-rule.
  end.
end. /*doe*/
RUN OpenBr IN THIS-PROCEDURE NO-ERROR.
IF AVAILABLE buf2_tt-rule-script  THEN DO:
  REPOSITION br-rule-script TO RECID RECID(buf2_tt-rule-script) NO-ERROR.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-move Dialog-Frame
PROCEDURE proc-b-move :
define input parameter p-rule-id as integer no-undo .
define input parameter p-script-id as integer no-undo .
FIND FIRST MOVE_tt-rule-script WHERE
          recid(MOVE_tt-rule-script) = RECID(tt-rule-script).
IF MOVE_tt-rule-script.script-type = {&rule-script-RULE}
or MOVE_tt-rule-script.script-type = {&rule-script-else-RULE} THEN DO:
  MESSAGE
  substitute("Нельзя переносить скрипты типа &1", MOVE_tt-rule-script.script-type)
  VIEW-AS ALERT-BOX ERROR.
  RELEASE MOVE_tt-rule-script.
  RETURN ERROR.
END.
HIDE
b-add IN FRAME {&FRAME-NAME}
b-del
b-params
b-move
IN FRAME {&FRAME-NAME}.
ENABLE
b-sel
WITH FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-params Dialog-Frame
PROCEDURE proc-b-params :
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-return-value as character no-undo .
DEFINE BUFFER buf_tt-ruledict-param FOR tt-ruledict-param.
IF p-mode = {&LOOKUP} THEN DO:
  FIND FIRST buf_tt-ruledict-param NO-ERROR.
  IF NOT AVAILABLE buf_tt-ruledict-param THEN DO:
    MESSAGE
    "У этого правила нет параметров"
    VIEW-AS ALERT-BOX.
    RETURN.
  END.
END.
ELSE DO:
  v-param-num-list = '':U.
END.
run rul/ruledict-param-s.w ( INPUT parparentproc
                            ,input this-procedure:handle /*p-update-proc-handle*/
                            ,INPUT (IF p-mode = {&UPDATE}
                                    OR p-mode = {&add-def}
                                    THEN "b-add"
                                    ELSE "":U)
                            ,INPUT (if p-mode = {&lookup}
                                    then "entry-id"
                                    else {&UPDATE})  /*p-list-mode*/
                            ,INPUT (if p-mode = {&update}
                                    or p-mode = {&lookup}
                                    then locked_ruledict.entry-id
                                    else 0)
                            ,input {&rdict-etype-rule}
                            ,INPUT-OUTPUT v-rid-list) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
   UNDO, RETURN ERROR.
END.
v-return-value = return-value .
if (p-mode = {&update}
or p-mode = {&add-def})
and v-return-value <> "quit" then do:
  FOR EACH tt-ruledict-param:
    IF LOOKUP(string(tt-ruledict-param.param-num), v-param-num-list) = 0 THEN DO:
        DELETE tt-ruledict-param.
    END.
  END.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
run waitfram-show in this-procedure ( "Ждите..." ).
output to value (string(p-rule-id, "999999999") + ".rul-str").
DEFINE BUFFER buf_tt-rule-script FOR tt-rule-script.
for each buf_tt-rule-script no-lock where
        buf_tt-rule-script.root_rule_id = p-rule-id
    and buf_tt-rule-script.language = rs-language
   by buf_tt-rule-script.gen-order:
  export
  buf_tt-rule-script.rule_id    "~t"
  buf_tt-rule-script.gen-order        "~t"
  buf_tt-rule-script.level            "~t"
  buf_tt-rule-script.upper_rule_id    "~t"
  buf_tt-rule-script.script-type      "~t"
  buf_tt-rule-script.script_id        "~t"
  buf_tt-rule-script.salience         "~t"
  (fill({&space-char}, buf_tt-rule-script.level * 2)  + buf_tt-rule-script.script) skip.

end.
output close.
run waitfram-hide in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-cancel-move Dialog-Frame
PROCEDURE proc-cancel-move :
move-option = '':U.
RELEASE MOVE_tt-rule-script.
HIDE
b-sel IN FRAME {&FRAME-NAME}.
ENABLE
b-add
b-del
b-chg
b-params
b-move
WITH FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
IF p-mode = {&LOOKUP} THEN DO:
  RETURN error.
END.
IF p-mode = {&update} THEN DO:
  v-rec = p-rec.
END.

ASSIGN
FRAME {&FRAME-NAME}
tt-rule.NAME
tt-rule.codex_id
tt-rule.reusable-params
tt-rule.documentation
tt-rule.image-file-name
t-hidden
tt-rule.hidden-content = (IF t-hidden = YES THEN 1 ELSE 0)
.
run rul/rule1.p ( INPUT (p-mode + {&comma-char} + string(v-is-admin-mode))
                ,INPUT NO /*p-silent*/
                ,INPUT-OUTPUT v-rec
                ,INPUT tt-rule.rule_id
                ,INPUT tt-rule.codex_id
                ,INPUT tt-rule.upper_rule_id
                ,INPUT tt-rule.root_rule_id
                ,INPUT tt-rule.reusable-params
                ,INPUT tt-rule.salience
                ,INPUT tt-rule.name
                ,INPUT tt-rule.documentation
                ,input tt-rule.no-save-mode
                ,INPUT tt-rule.hidden-content
                ,input tt-rule.image-file-name
                ,input table tt-rule
                ,input table tt-rule-script
                ,input table tt-rule-i-script
                ,input table tt-ruledict-param
              ) no-error.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
p-rec = v-rec.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-tt-ruledict-param Dialog-Frame
PROCEDURE save-tt-ruledict-param :
DEFINE INPUT PARAMETER p-bh AS HANDLE NO-UNDO.
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
FIND FIRST tt-ruledict-param WHERE
           tt-ruledict-param.param-num = p-bh::param-num NO-ERROR.
IF NOT AVAILABLE tt-ruledict-param THEN DO:
   CREATE tt-ruledict-param.
END.
ASSIGN
glog = BUFFER tt-ruledict-param:handle:BUFFER-Copy( p-bh) NO-ERROR.
IF NOT glog THEN DO:
  UNDO, RETURN ERROR substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
END.
v-param-num-list = v-param-num-list + {&comma-char} + STRING( tt-ruledict-param.param-num).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE switch-rule Dialog-Frame
PROCEDURE switch-rule :
IF NOT AVAILABLE tt-rule-script
OR not (tt-rule-script.script-type = {&rule-script-cond}
       or
       tt-rule-script.script-type = {&rule-script-cycle-cond}) THEN DO:
  MENU-ITEM m_rule:SENSITIVE IN MENU menu-b-add = NO .
END.
ELSE DO:
   MENU-ITEM m_rule:SENSITIVE IN MENU menu-b-add = yes .
END.
IF NOT AVAILABLE tt-rule-script
OR not tt-rule-script.script-type = {&rule-script-rule} then do:
  MENU-ITEM m_else-rule:SENSITIVE IN MENU menu-b-add = NO .
end.
else do:
  MENU-ITEM m_else-rule:SENSITIVE IN MENU menu-b-add = yes .
end.

IF AVAILABLE tt-rule-script
AND (tt-rule-script.script-type = {&rule-script-RULE}
or  tt-rule-script.script-type = {&rule-script-else-RULE} )
THEN DO:
  ASSIGN
  MENU-ITEM m_cond:SENSITIVE IN MENU menu-b-add = YES
  MENU-ITEM m_cons:SENSITIVE IN MENU menu-b-add = YES.
  MENU-ITEM m_goto:SENSITIVE IN MENU menu-b-add = YES.
  MENU-ITEM m_script:SENSITIVE IN MENU menu-b-sel = YES.
END.
ELSE DO:
  MENU-ITEM m_cond:SENSITIVE IN MENU menu-b-add = NO .
  MENU-ITEM m_cons:SENSITIVE IN MENU menu-b-add = NO .
  MENU-ITEM m_goto:SENSITIVE IN MENU menu-b-add = NO .
  MENU-ITEM m_script:SENSITIVE IN MENU menu-b-sel = NO.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
