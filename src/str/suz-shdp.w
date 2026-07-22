&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-rp-by-call NO-UNDO LIKE ub.rp-by-call.
DEFINE TEMP-TABLE tt-rule-by-call NO-UNDO LIKE ub.rule-by-call.
DEFINE TEMP-TABLE tt-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE TEMP-TABLE tt0-rp-by-call NO-UNDO LIKE ub.rp-by-call.
DEFINE TEMP-TABLE tt0-rule-by-call NO-UNDO LIKE ub.rule-by-call.
DEFINE TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE TEMP-TABLE tt2-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE BUFFER X_rp-by-call FOR ub.rp-by-call.
DEFINE BUFFER X_rule-profile FOR ub.rule-profile.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Настройка параметров автоматического выполнения отчетов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/17/09
Author: Bakhtadze Natalya
Creation date: 06/17/09

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-cre-db-num  as integer   no-undo .
define input  parameter p-task-type   as character no-undo .
define input  parameter p-task-num    as integer   no-undo .
define output parameter p-cancel      as logical   no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Настройка параметров автоматического выполнения отчетов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ gbl/waitfram.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ ref/shd-attr.i }
{ cmp/showinf.i }
{ gbl/key-rec.i }
{ rul/calldscr.i }
{ adm/thbj-rum.i }
DEFINE VARIABLE rule-display-option AS CHARACTER NO-UNDO.
define variable v-uniq-key-rec as character no-undo .
define variable v-call#-id as integer no-undo .
define variable v-param-action as character no-undo .
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_schedule for ub.schedule.
define buffer buf_schedule-attr for schedule-attr .

{ gbl/getcntxt.i def }

&SCOPED-DEFINE LABEL_1 "Название правила"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-rule-by-call

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt0-rule-by-call X_rule-profile

/* Definitions for BROWSE br-rule-by-call                               */
&Scoped-define FIELDS-IN-QUERY-br-rule-by-call tt0-rule-by-call.can-calc get-rule-name(tt0-rule-by-call.rule_id) tt0-rule-by-call.is_dynamic tt0-rule-by-call.codex_id tt0-rule-by-call.ruleset_id tt0-rule-by-call.order_id tt0-rule-by-call.rule_id
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-rule-by-call
&Scoped-define SELF-NAME br-rule-by-call
&Scoped-define QUERY-STRING-br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = v-uniq-key-rec, ~
           FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-rule-by-call OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = v-uniq-key-rec, ~
           FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-rule-by-call tt0-rule-by-call ~
X_rule-profile
&Scoped-define FIRST-TABLE-IN-QUERY-br-rule-by-call tt0-rule-by-call
&Scoped-define SECOND-TABLE-IN-QUERY-br-rule-by-call X_rule-profile


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame X_rule-profile.profile_id ~
X_rule-profile.name
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
X_rule-profile.profile_id X_rule-profile.name
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame X_rule-profile
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame X_rule-profile
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-rule-by-call}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH X_rule-profile SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH X_rule-profile SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame X_rule-profile
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame X_rule-profile


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS X_rule-profile.profile_id X_rule-profile.name
&Scoped-define ENABLED-TABLES X_rule-profile
&Scoped-define FIRST-ENABLED-TABLE X_rule-profile
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-params B-Help ED-profile ~
b-rule-on-off br-rule-by-call E-rule-name
&Scoped-Define DISPLAYED-FIELDS X_rule-profile.profile_id ~
X_rule-profile.name
&Scoped-define DISPLAYED-TABLES X_rule-profile
&Scoped-define FIRST-DISPLAYED-TABLE X_rule-profile
&Scoped-Define DISPLAYED-OBJECTS ED-profile E-rule-name fi-rep-dir ~
fi-rep-dir-xml

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-rule-name Dialog-Frame
FUNCTION get-rule-name RETURNS CHARACTER
  ( p-rule_id AS integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-params
       MENU-ITEM m_lookup       LABEL "Просмотр"
       MENU-ITEM m_update       LABEL "Изменение"     .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-params
     LABEL "Параметры"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-rep DEFAULT
     LABEL "Выбор отчета":L
     SIZE 20 BY 1.

DEFINE BUTTON b-rule-on-off
     LABEL "Вкл"
     SIZE 5 BY 1.

DEFINE BUTTON b-sel-dir DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 4 BY 1.

DEFINE BUTTON b-sel-dir-xml DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 4 BY 1.

DEFINE VARIABLE E-rule-name AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE ED-profile AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98.5 BY 4 NO-UNDO.

DEFINE VARIABLE fi-rep-dir AS CHARACTER FORMAT "X(256)":U
     LABEL "Директория"
     VIEW-AS FILL-IN NATIVE
     SIZE 77.5 BY 1
     FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE fi-rep-dir-xml AS CHARACTER FORMAT "X(256)":U
     LABEL "Дир-я для XML"
     VIEW-AS FILL-IN NATIVE
     SIZE 77.5 BY 1
     FGCOLOR 0  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-rule-by-call FOR
      tt0-rule-by-call,
      X_rule-profile SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      X_rule-profile SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-rule-by-call
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-rule-by-call Dialog-Frame _FREEFORM
  QUERY br-rule-by-call NO-LOCK DISPLAY
      tt0-rule-by-call.can-calc COLUMN-LABEL "Вкл." FORMAT "+/":U
get-rule-name(tt0-rule-by-call.rule_id) COLUMN-LABEL {&label_1} FORMAT "X(255)":U WIDTH 50
tt0-rule-by-call.is_dynamic COLUMN-LABEL "Отклю!чаемое?" FORMAT "+/":U
tt0-rule-by-call.codex_id COLUMN-LABEL "Кодекс!правил" FORMAT ">,>>>,>>9":U
tt0-rule-by-call.ruleset_id COLUMN-LABEL "Набор!правил" FORMAT ">,>>>,>>9":U
tt0-rule-by-call.order_id COLUMN-LABEL "Порядок!вызова" FORMAT ">>9":U WIDTH 9
tt0-rule-by-call.rule_id COLUMN-LABEL "Код!правила" FORMAT ">>>,>>>,>>9":U WIDTH 9
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6
         FONT 4 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1 WIDGET-ID 2
     b-quit AT ROW 1 COL 11
     b-rep AT ROW 1 COL 40 WIDGET-ID 6
     b-params AT ROW 1 COL 60 WIDGET-ID 26
     B-Help AT ROW 1 COL 95
     X_rule-profile.profile_id AT ROW 2 COL 26.5 COLON-ALIGNED WIDGET-ID 30
          LABEL "Код профайла" FORMAT ">,>>9"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     X_rule-profile.name AT ROW 3 COL 1.5 NO-LABEL WIDGET-ID 28 FORMAT "X(256)"
          VIEW-AS FILL-IN NATIVE
          SIZE 98 BY 1
          FGCOLOR 0
     ED-profile AT ROW 3.93 COL 1 NO-LABEL WIDGET-ID 32
     b-rule-on-off AT ROW 8 COL 94.5 WIDGET-ID 24
     br-rule-by-call AT ROW 9 COL 1.5 WIDGET-ID 100
     E-rule-name AT ROW 15 COL 1 NO-LABEL WIDGET-ID 14
     fi-rep-dir AT ROW 18 COL 14 COLON-ALIGNED WIDGET-ID 10
     b-sel-dir AT ROW 18 COL 94 WIDGET-ID 8
     fi-rep-dir-xml AT ROW 19.5 COL 14 COLON-ALIGNED WIDGET-ID 36
     b-sel-dir-xml AT ROW 19.5 COL 94 WIDGET-ID 38
     "Если директория не задана, вывод производится в текущую директорию" VIEW-AS TEXT
          SIZE 78 BY 1 AT ROW 17 COL 13 WIDGET-ID 34
          FGCOLOR 4
     "Если задание директории не требуется, ее можно не задавать" VIEW-AS TEXT
          SIZE 78 BY 1 AT ROW 21 COL 13.5 WIDGET-ID 40
          FGCOLOR 4
     SPACE(8.19) SKIP(0.22)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры автозапуска отчетов"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-rp-by-call T "?" NO-UNDO ub rp-by-call
      TABLE: tt-rule-by-call T "?" NO-UNDO ub rule-by-call
      TABLE: tt-rule-call-param T "?" NO-UNDO ub rule-call-param
      TABLE: tt0-rp-by-call T "?" NO-UNDO ub rp-by-call
      TABLE: tt0-rule-by-call T "?" NO-UNDO ub rule-by-call
      TABLE: tt0-rule-call-param T "?" NO-UNDO ub rule-call-param
      TABLE: tt2-rule-call-param T "?" NO-UNDO ub rule-call-param
      TABLE: X_rp-by-call B "?" ? ub rp-by-call
      TABLE: X_rule-profile B "?" ? ub rule-profile
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-rule-by-call b-rule-on-off Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-params:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-params:HANDLE.

/* SETTINGS FOR BUTTON b-rep IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-sel-dir IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-sel-dir-xml IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       E-rule-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       ED-profile:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN fi-rep-dir IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-rep-dir-xml IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN X_rule-profile.name IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT                                         */
ASSIGN
       X_rule-profile.name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN X_rule-profile.profile_id IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
ASSIGN
       X_rule-profile.profile_id:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-rule-by-call
/* Query rebuild information for BROWSE br-rule-by-call
     _START_FREEFORM
OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE
    tt0-rule-by-call.call_id = v-uniq-key-rec,
    FIRST X_rule-profile NO-LOCK WHERE
        X_rule-profile.profile_id = tt0-rule-by-call.profile_id
  BY tt0-rule-by-call.codex_id
 BY tt0-rule-by-call.ruleset_id
 BY tt0-rule-by-call.order_id
 INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "Temp-Tables.tt-rule-by-call.emitent-host-code = 0
 AND Temp-Tables.tt-rule-by-call.type = ""66"""
     _Query            is OPENED
*/  /* BROWSE br-rule-by-call */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.X_rule-profile"
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры автозапуска отчетов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  run proc-save in THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-params
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-params Dialog-Frame
ON CHOOSE OF b-params IN FRAME Dialog-Frame /* Параметры */
DO:
  if v-param-action = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if v-param-action = "":U then do:
      return no-apply.
  end.
  RUN proc-b-params IN THIS-PROCEDURE ( INPUT v-param-action) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
      v-param-action = ''.
      RETURN NO-APPLY.
  END.
   v-param-action = ''.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
      assign
        p-cancel = yes
    .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-rep
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rep Dialog-Frame
ON CHOOSE OF b-rep IN FRAME Dialog-Frame /* Выбор отчета */
DO:
    run utl/thbjrumr.w (
                        input parparentproc
                       ,input this-procedure:handle
                       ,input ? /*p-log-handle*/
                       ,input ({&rep} + {&delim-par} + {&rep-proc_rep-batchwork} ) /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
    ) no-error.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-rule-on-off
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rule-on-off Dialog-Frame
ON CHOOSE OF b-rule-on-off IN FRAME Dialog-Frame /* Вкл */
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
  IF X_rule-profile.IS_dynamic = NO  THEN DO:
     MESSAGE
     substitute("Данное правило не может быть включено/выключено,&1" +
                "так как принадлежит алгоритму ПО УМОЛЧАНИЮ!"
                , {&NEW-LINE})
     VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.
  END.
  if tt0-rule-by-call.is_dynamic = no then do:
     MESSAGE
     substitute("Данное правило не может быть включено/выключено,&1" +
                "согласно определенной профайлом логике!"
                , {&NEW-LINE})
     VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.

  end.
  IF tt0-rule-by-call.can-calc THEN DO:
    MESSAGE
    "Вы уверены, что хотите выключить правило?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE gLOG.
    IF NOT glog THEN RETURN NO-APPLY.
  END.
  ELSE DO:
      MESSAGE
      "Вы уверены, что хотите включить правило?"
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE gLOG.
      IF NOT glog THEN RETURN NO-APPLY.
  END.
  ASSIGN
  tt0-rule-by-call.can-calc = NOT (tt0-rule-by-call.can-calc).
  glog = br-rule-by-call:REFRESH() IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-dir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-dir Dialog-Frame
ON CHOOSE OF b-sel-dir IN FRAME Dialog-Frame
DO:

  define variable v-dir-name  as character no-undo .
  define variable v-dir-type  as character no-undo .
  define variable v-can-write as logical   no-undo .


  run gbl/dir-sel.p ( output v-dir-name
                , output v-dir-type
                , output v-can-write
                ) no-error .
  if error-status :error
  then do:
    message
        vss-workfile vss-revision vss-description
        skip(1)
        skip "Ошибка процедуры выбора каталога"
        skip "Введите имя каталога вручную."
        skip return-value
        skip trim( error-status :get-message( 1 ) )
              trim( error-status :get-message( 2 ) )
              trim( error-status :get-message( 3 ) )
    view-as alert-box error.
/*    undo, return no-apply.*/
  end.
  if v-dir-name = "":U
  then do:
    /* Отмена выбора каталога */
  end.
  else do:
    if v-can-write = no then do:
      message
        "Каталог недоступен для записи"
        skip (1)
        skip "Был выбран каталог:"
        skip v-dir-name
      view-as alert-box error
      title "Каталог защищён от записи".
    end.
    else do:
      assign
        fi-rep-dir = v-dir-name
      .
      display
        fi-rep-dir
      with frame {&frame-name} .
    end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-dir-xml
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-dir-xml Dialog-Frame
ON CHOOSE OF b-sel-dir-xml IN FRAME Dialog-Frame
DO:

  define variable v-dir-name  as character no-undo .
  define variable v-dir-type  as character no-undo .
  define variable v-can-write as logical   no-undo .


  run gbl/dir-sel.p ( output v-dir-name
                , output v-dir-type
                , output v-can-write
                ) no-error .
  if error-status :error
  then do:
    message
        vss-workfile vss-revision vss-description
        skip(1)
        skip "Ошибка процедуры выбора каталога"
        skip "Введите имя каталога вручную."
        skip return-value
        skip trim( error-status :get-message( 1 ) )
              trim( error-status :get-message( 2 ) )
              trim( error-status :get-message( 3 ) )
    view-as alert-box error.
/*    undo, return no-apply.*/
  end.
  if v-dir-name = "":U
  then do:
    /* Отмена выбора каталога */
  end.
  else do:
    if v-can-write = no then do:
      message
        "Каталог недоступен для записи"
        skip (1)
        skip "Был выбран каталог:"
        skip v-dir-name
      view-as alert-box error
      title "Каталог защищён от записи".
    end.
    else do:
      assign
        fi-rep-dir-xml = v-dir-name
      .
      display
        fi-rep-dir-xml
      with frame {&frame-name} .
    end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-rule-by-call
&Scoped-define SELF-NAME br-rule-by-call
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-rule-by-call Dialog-Frame
ON VALUE-CHANGED OF br-rule-by-call IN FRAME Dialog-Frame
DO:
  DEFINE BUFFER buf_rule FOR ub.RULE.
  IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
  FIND FIRST buf_rule NO-LOCK WHERE
            buf_rule.RULE_id = tt0-rule-by-call.RULE_id NO-ERROR.
  IF NOT AVAILABLE buf_rule THEN DO:
     e-rule-name:SCREEN-VALUE = SUBSTITUTE("!!!Правило &1 не найдено", tt0-rule-by-call.RULE_Id).
  END.
  ELSE DO:
    e-rule-name:SCREEN-VALUE =  buf_rule.documentation.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_lookup Dialog-Frame
ON CHOOSE OF MENU-ITEM m_lookup /* Просмотр */
DO:
  v-param-action = {&lookup}.
  RUN proc-b-params IN THIS-PROCEDURE ( INPUT {&lookup}) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
      v-param-action = ''.
      RETURN NO-APPLY.
  END.
  v-param-action = ''.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_update
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_update Dialog-Frame
ON CHOOSE OF MENU-ITEM m_update /* Изменение */
DO:
  v-param-action = {&update}.
  RUN proc-b-params IN THIS-PROCEDURE ( INPUT {&update}) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
      v-param-action = ''.
      RETURN NO-APPLY.
  END.
  v-param-action = ''.

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
{ rul/rcpscont.i tt0-rule-by-call ~{&OPEN-QUERY-br-rule-by-call~} }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }
  find first buf_schedule share-lock where
            buf_schedule.cre-db-num = p-cre-db-num
        and buf_schedule.task-type = p-task-type
        and buf_schedule.task-num = p-task-num
        no-error .
        
  if not available buf_schedule
  and p-task-num = -1
  then do :
    find last buf_schedule no-lock where
              buf_schedule.cre-db-num = p-cre-db-num
          and buf_schedule.task-type = p-task-type
          no-error .
  end .
  run init-param-values in this-procedure
    (input  p-cre-db-num
    ,input  p-task-type
    ,input  (if available buf_schedule then buf_schedule.task-num else p-task-num)
    ,output v-uniq-key-rec
    ,output v-call#-id
    ).
  RUN thbj-rum_FILL-table IN THIS-PROCEDURE (
                                              input {&rep}
                                             ,input {&update}
                                             ,input no /*p-silent*/
                                             ,input v-uniq-key-rec)
                                             no-error .
  if error-status:error then do:
    message
    error-status:get-message(1) return-value
    view-as alert-box error .
    undo main-block, return error .
  end.
  run set-rule-profile in this-procedure .
  {&OPEN-QUERY-br-rule-by-call}
  APPLY "value-changed" TO br-rule-by-call IN FRAME {&FRAME-NAME}.
  
  RUN Myenable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb_set-rp-by-call Dialog-Frame
PROCEDURE cb_set-rp-by-call :
/*не удалять - callback*/
define input parameter p-call-id as character no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
define input parameter table for tt-rule-call-param.
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_tt-rule-call-param for tt-rule-call-param.
define buffer buf_tt0-rp-by-call for tt0-rp-by-call.
define buffer buf_tt0-rule-by-call for tt0-rule-by-call.
define buffer buf_tt0-rule-call-param for tt0-rule-call-param.
main-block:
do
on error  undo main-block, retry main-block
on stop   undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    RUN thbj-rum_FILL-table IN THIS-PROCEDURE (
                                                input {&rep}
                                              ,input {&update}
                                              ,input no /*p-silent*/
                                              ,input v-uniq-key-rec)
                                              no-error .
    run set-rule-profile in this-procedure .
    {&OPEN-QUERY-br-rule-by-call}
    APPLY "value-changed" TO br-rule-by-call IN FRAME {&FRAME-NAME}.
    message
    "НЕ удалось"
    view-as alert-box error.
    return.
  end.
  empty temp-table tt0-rule-call-param.
  empty temp-table tt0-rp-by-call.
  empty temp-table tt0-rule-by-call.

  for each  buf_rp-by-call where
          buf_rp-by-call.call_id = p-call-id
      and buf_rp-by-call.profile_id = p-profile-id
      and buf_rp-by-call.once-more = p-once-more
  on error  undo main-block, retry main-block
  on stop   undo main-block, retry main-block
  on endkey undo main-block, retry main-block
  :
    create buf_tt0-rp-by-call.
    buffer-copy buf_rp-by-call
    except once-more call_id call#_id
    to buf_tt0-rp-by-call
    assign
    buf_tt0-rp-by-call.call_id = v-uniq-key-rec
    buf_tt0-rp-by-call.call#_id = v-call#-id
    buf_tt0-rp-by-call.once-more = 1
    .
    RELEASE buf_tt0-rp-by-call.
  end.
  for each  buf_rule-by-call where
          buf_rule-by-call.call_id = p-call-id
      and buf_rule-by-call.profile_id = p-profile-id
      and buf_rule-by-call.once-more = p-once-more
  on error  undo main-block, retry main-block
  on stop   undo main-block, retry main-block
  on endkey undo main-block, retry main-block
  :
    create buf_tt0-rule-by-call.
    buffer-copy buf_rule-by-call
    except once-more call_id call#_id
    to buf_tt0-rule-by-call
    assign
    buf_tt0-rule-by-call.call_id = v-uniq-key-rec
    buf_tt0-rule-by-call.call#_id = v-call#-id
    buf_tt0-rule-by-call.once-more = 1
    .
    RELEASE buf_tt0-rule-by-call.
  end.
  for each  buf_tt-rule-call-param
  on error  undo main-block, retry main-block
  on stop   undo main-block, retry main-block
  on endkey undo main-block, retry main-block
  :
    create buf_tt0-rule-call-param.
    buffer-copy buf_tt-rule-call-param
    except once-more call_id call#_id
    to buf_tt0-rule-call-param
    assign
    buf_tt0-rule-call-param.call_id = v-uniq-key-rec
    buf_tt0-rule-call-param.call#_id = v-call#-id
    buf_tt0-rule-call-param.once-more = 1
    .
    RELEASE buf_tt0-rule-call-param.
  end.
end.
run set-rule-profile in this-procedure .
{&OPEN-QUERY-br-rule-by-call}
APPLY "value-changed" TO br-rule-by-call IN FRAME {&FRAME-NAME}.
{&OPEN-QUERY-br-rule-by-call}
APPLY "value-changed" TO br-rule-by-call IN FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY ED-profile E-rule-name fi-rep-dir fi-rep-dir-xml
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_rule-profile THEN
    DISPLAY X_rule-profile.profile_id X_rule-profile.name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-params B-Help X_rule-profile.profile_id
         X_rule-profile.name ED-profile b-rule-on-off br-rule-by-call
         E-rule-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-param-values Dialog-Frame
PROCEDURE init-param-values :
define input  parameter p-cre-db-num  as integer   no-undo .
define input  parameter p-task-type   as character no-undo .
define input  parameter p-task-num    as integer   no-undo .
define output parameter p-uniq-key-rec as character no-undo .
define output parameter p-call#-id as integer no-undo .


do
on error undo, return error
:

define variable v-ii       as integer       no-undo.
define variable v-param-list    as character     no-undo.
define variable v-param-type         as character no-undo .
define variable v-uniq-key-rec as character no-undo .
run schedule-attr-value in this-procedure
      (input  p-cre-db-num
      ,input  p-task-type
      ,input  p-task-num
      ,input  {&attr-schedule-param-list-h}
      ,output v-param-list
      ,output v-param-type
      ) no-error.
DO v-ii = 1 TO NUM-ENTRIES(v-param-list, {&vertical-line}):
   IF v-ii = 1  THEN DO:
     fi-rep-dir = entry(v-ii, v-param-list, {&vertical-line}).
   END.
   IF v-ii = 2  THEN DO:
     fi-rep-dir-xml = entry(v-ii, v-param-list, {&vertical-line}).
   END.
END.



if available buf_schedule
then do :
  run gen-key-rec in this-procedure ( input {&table_schedule}
                                      ,input (buffer buf_schedule:handle)
                                      , output v-uniq-key-rec).
end.
else do :
  v-uniq-key-rec = "schedule" + {&delim-key} + string(p-cre-db-num) + {&delim-key} + p-task-type + {&delim-key} + string(p-task-num) .
end.                                      
run rul/g-callid.p ( input {&rep}
                  ,input v-uniq-key-rec
                  ,output p-call#-id).
/*заполняем данными по вызову стопки отчетов - одного профайла*/
p-uniq-key-rec = v-uniq-key-rec.

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable Dialog-Frame
PROCEDURE Myenable :
DEFINE VARIABLE v-type AS CHARACTER NO-UNDO.

DEFINE VARIABLE clh AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE ii AS integer NO-UNDO.

DO ii = 1 TO br-rule-by-call:NUM-COLUMNS IN FRAME {&FRAME-NAME}:
    clh = BROWSE br-rule-by-call:get-browse-column(ii).
    IF clh:LABEL BEGINS {&label_1} THEN DO:
      ASSIGN
      clh:RESIZABLE = YES
     .
    END.
END.

assign
frame {&frame-name} :title = SUBSTITUTE("&1: Задача номер &2"
                                       ,frame {&frame-name} :title
                                       ,p-task-num)
b-params:MENU-MOUSE = 1
.
IF AVAILABLE X_rule-profile
THEN do:
  DISPLAY
  X_rule-profile.profile_id
  X_rule-profile.name
  WITH FRAME {&frame-name}.
  assign
  ed-profile:screen-value = X_rule-profile.documentation.
end.
DISPLAY
fi-rep-dir
fi-rep-dir-xml
WITH FRAME {&frame-name}.
ENABLE
B-exit
b-rep
b-sel-dir
b-sel-dir-xml
b-quit
B-Help
b-rule-on-off
b-params
br-rule-by-call
e-rule-name
ed-profile
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
APPLY "VALUE-CHANGED" to br-rule-by-call.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-params Dialog-Frame
PROCEDURE proc-b-params :
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
  define variable v-param-form as character no-undo .
  define buffer buf_rule-profile for ub.rule-profile.
  DEFINE BUFFER buf_tt0-rule-call-param FOR tt0-rule-call-param.
  if not available tt0-rp-by-call then do:
    message
    "Не выбраны отчеты!"
    view-as alert-box error .
    undo, return no-apply.
  end.
  FIND FIRST buf_tt0-rule-call-param NO-LOCK NO-ERROR.
  IF NOT AVAILABLE buf_tt0-rule-call-param THEN DO:
     MESSAGE
     "В данном профайле параметры не используются"
     VIEW-AS ALERT-BOX WARNING.
     RETURN NO-APPLY.
  END.

  if search( substitute("rul/rcps-&1.w", tt0-rp-by-call.profile_id)) <> ?
  or search( substitute("rul/rcps-&1.r", tt0-rp-by-call.profile_id)) <> ? then do:
    v-param-form = substitute("rul/rcps-&1.w", tt0-rp-by-call.profile_id).
  end.
  else do:
     v-param-form = "ref/rulercps.w" .
  end.
  run value(v-param-form) (
                        input parparentproc
                        ,input this-procedure:handle
                        ,input 'b-chg':U
                        ,input p-mode
                        ,input {&table_rp-rule-param}
                        ,input tt0-rp-by-call.profile_id /*p-profile-id*/
                        ,input tt0-rp-by-call.once-more /*p-once-more*/
                        ,input tt0-rp-by-call.call_id /*p-call-id*/
                        ,input 0 /*p-codex-id*/
                        ,input 0 /*p-codex-id*/
                        ,input ? /*p-order-id*/
                        ,input 0 /*p-rule-id*/
                        ,INput substitute("Профайл &1 № привязки &2 &3"
                                          ,tt0-rp-by-call.profile
                                          ,tt0-rp-by-call.once-more
                                          ,calldscr(tt0-rp-by-call.call_id)
                                          )  /**/
                        ,input-output table tt0-rule-call-param  ) no-error.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
define variable v-attr-value as character no-undo .
DEFINE VARIABLE v-mode AS CHARACTER no-undo.

define buffer buf_schedule      for schedule .
define buffer buf_schedule-attr for schedule-attr .

do
on error undo, return error
:
assign
frame {&frame-name}
fi-rep-dir
fi-rep-dir-xml
.
find first buf_schedule no-lock
  where buf_schedule.cre-db-num = p-cre-db-num
    and buf_schedule.task-type  = p-task-type
    and buf_schedule.task-num   = p-task-num
  no-error.
if not available buf_schedule
and (  p-task-type   <> {&btpr-type-autosuz}
    or p-task-num    <> -1 )
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Не найдена строка расписания." skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
 
v-mode = (IF AVAILABLE buf_rp-by-call
          AND buf_rp-by-call.profile_id = tt0-rp-by-call.profile_id
          AND buf_rp-by-call.once-more = tt0-rp-by-call.once-more
          THEN {&UPDATE}
          ELSE {&add-def}).
if p-task-num = - 1
then do :
  find first buf_schedule-attr no-lock
       where buf_schedule-attr.cre-db-num = p-cre-db-num
         and buf_schedule-attr.task-type  = p-task-type
         and buf_schedule-attr.task-num   = p-task-num
         no-error .
  if not available buf_schedule-attr then v-mode = {&add-def} .       
end.          
run rul/thbjrum1.p (
                 input v-mode
                ,input {&rep}
                ,input v-uniq-key-rec
                ,input 0
                ,input "":U
                ,input 0
                ,input ? /*v-logical-value*/
                ,INPUT TABLE tt0-rp-by-call
                ,INPUT TABLE tt0-rule-by-call
                ,INPUT TABLE tt0-rule-call-param) no-error .
if error-status :error then do:
  message
  error-status:get-message(1)  skip
  return-value
  view-as alert-box error .
  return error.
end.
/*запишем атрибут для директории*/
run schedule-attr-write in this-procedure
  (input p-cre-db-num
  ,input p-task-type
  ,input p-task-num
  ,input {&attr-schedule-param-list-h}
  ,INPUT (fi-rep-dir + {&vertical-line} + fi-rep-dir-xml)
  ).
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-rule-profile Dialog-Frame
PROCEDURE set-rule-profile :
FOR EACH tt0-rp-by-call WHERE
          tt0-rp-by-call.call_id = v-uniq-key-rec,
       FIRST X_rule-profile NO-LOCK WHERE
           X_rule-profile.profile_id = tt0-rp-by-call.profile_id   :
    leave.
end.
if available X_rule-profile then do:
  display
  X_rule-profile.profile_id
  X_rule-profile.name
  with frame {&frame-name} .
  ed-profile:screen-value = X_rule-profile.documentation.
end.
else do:
  display
  ? @ X_rule-profile.profile_id
  '' @ X_rule-profile.name
  with frame {&frame-name} .
  ed-profile:screen-value = ''.

end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-rule-name Dialog-Frame
FUNCTION get-rule-name RETURNS CHARACTER
  ( p-rule_id AS integer ) :
DEFINE BUFFER buf_rule FOR ub.rule.
FIND FIRST buf_rule NO-LOCK WHERE
          buf_rule.rule_id = p-rule_id NO-ERROR.
IF NOT AVAILABLE buf_rule THEN RETURN {&question-mark}.   /* Function return value. */
RETURN buf_rule.NAME.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
