&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-ruleset NO-UNDO LIKE ub.ruleset.
DEFINE BUFFER X_ruleset FOR ub.ruleset.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список ruleset


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
/*{&all} codex only-codex only-ruleset profile-type*/
define input parameter p-codex-id as integer no-undo .
define input-output parameter p-rid-list as character no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список ruleset".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/color.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
DEFINE VARIABLE link-option AS CHARACTER NO-UNDO.
define variable v-rid-list as character no-undo .
define temp-table tt0-rule-call-param no-undo  like ub.rule-call-param.
DEFINE VARIABLE v-browse-mode as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-ruleset

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_ruleset tt-ruleset

/* Definitions for BROWSE br-ruleset                                    */
&Scoped-define FIELDS-IN-QUERY-br-ruleset mark-string(recid(X_ruleset), v-rid-list) X_ruleset.codex_id X_ruleset.ruleset_id X_ruleset.name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-ruleset
&Scoped-define SELF-NAME br-ruleset
&Scoped-define QUERY-STRING-br-ruleset FOR EACH X_ruleset
&Scoped-define OPEN-QUERY-br-ruleset OPEN QUERY br-ruleset FOR EACH X_ruleset.
&Scoped-define TABLES-IN-QUERY-br-ruleset X_ruleset
&Scoped-define FIRST-TABLE-IN-QUERY-br-ruleset X_ruleset


/* Definitions for BROWSE br-temp-ruleset                               */
&Scoped-define FIELDS-IN-QUERY-br-temp-ruleset tt-ruleset.codex_id tt-ruleset.ruleset_id tt-ruleset.name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-temp-ruleset
&Scoped-define SELF-NAME br-temp-ruleset
&Scoped-define QUERY-STRING-br-temp-ruleset FOR EACH tt-ruleset
&Scoped-define OPEN-QUERY-br-temp-ruleset OPEN QUERY br-temp-ruleset FOR EACH tt-ruleset.
&Scoped-define TABLES-IN-QUERY-br-temp-ruleset tt-ruleset
&Scoped-define FIRST-TABLE-IN-QUERY-br-temp-ruleset tt-ruleset


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-ruleset}~
    ~{&OPEN-QUERY-br-temp-ruleset}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-chg b-del b-lkp ~
b-links B-Help br-temp-ruleset br-ruleset mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-links
       MENU-ITEM m_prop-ruleset LABEL "Объекты-операнды"
       MENU-ITEM m_rule         LABEL "Правила"
       MENU-ITEM m_pscript-ruleset LABEL "Скрипты для объектов"
       MENU-ITEM m_rule-by-profile LABEL "Правила профайлов"
       MENU-ITEM m_rule-call-param LABEL "Параметры вызова правил".


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
DEFINE QUERY br-ruleset FOR
      X_ruleset SCROLLING.

DEFINE QUERY br-temp-ruleset FOR
      tt-ruleset SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-ruleset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-ruleset Dialog-Frame _FREEFORM
  QUERY br-ruleset NO-LOCK DISPLAY
      mark-string(recid(X_ruleset), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_ruleset.codex_id COLUMN-LABEL "Кодекс!правил" FORMAT ">>>>>>>>9"
X_ruleset.ruleset_id COLUMN-LABEL "Набор!правил" FORMAT ">>>>>>>>9"
X_ruleset.name COLUMN-LABEL "Название" FORMAT "X(255)" WIDTH 60
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 20.53 FIT-LAST-COLUMN.

DEFINE BROWSE br-temp-ruleset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-temp-ruleset Dialog-Frame _FREEFORM
  QUERY br-temp-ruleset NO-LOCK DISPLAY
      tt-ruleset.codex_id COLUMN-LABEL "Кодекс!правил" FORMAT ">>>>>>>>9"
tt-ruleset.ruleset_id COLUMN-LABEL "Набор!правил" FORMAT ">>>>>>>>9"
tt-ruleset.name COLUMN-LABEL "Название" FORMAT "X(255)" WIDTH 60
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
     B-Help AT ROW 1 COL 95
     br-temp-ruleset AT ROW 2.33 COL 1.5 WIDGET-ID 200
     br-ruleset AT ROW 2.33 COL 1.5 WIDGET-ID 100
     mark-num AT ROW 1 COL 13 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     SPACE(74.50) SKIP(21.20)
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
      TABLE: tt-ruleset T "?" NO-UNDO ub ruleset
      TABLE: X_ruleset B "?" ? ub ruleset
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-temp-ruleset B-Help Dialog-Frame */
/* BROWSE-TAB br-ruleset br-temp-ruleset Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-links:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-links:HANDLE.

ASSIGN
       br-temp-ruleset:HIDDEN  IN FRAME Dialog-Frame                = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-ruleset
/* Query rebuild information for BROWSE br-ruleset
     _START_FREEFORM
OPEN QUERY br-ruleset FOR EACH X_ruleset.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-ruleset */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-temp-ruleset
/* Query rebuild information for BROWSE br-temp-ruleset
     _START_FREEFORM
OPEN QUERY br-temp-ruleset FOR EACH tt-ruleset.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-temp-ruleset */
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
  v-rec = recid(X_ruleset).
  run rul/ruleset-i.w ( input parparentproc
                       ,input {&add-def}
                       ,input 0 /*p-codex-id*/
                       ,input 0 /*p-ruleset-id*/
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
    RUN openbr IN THIS-PROCEDURE.
    reposition br-ruleset to recid v-rec no-error.
    apply "Entry" to br-ruleset.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  define variable v-rec as recid no-undo.
  if not available X_ruleset then return no-apply.
  v-rec = recid(X_ruleset).
  run rul/ruleset-i.w ( input parparentproc
                       ,input {&update}
                       ,input X_ruleset.codex_id /*p-codex-id*/
                       ,input X_ruleset.ruleset_id /*p-ruleset-id*/
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
     br-ruleset:refresh().
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
  if not available X_ruleset then return no-apply.
  v-rec = recid(X_ruleset).
  message "Вы уверены, что хотите удалить Кодекс или набор правил?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then return no-apply.
  run rul/ruleset3.p ( input no /*p-silent*/
                      ,input v-rec
                      ) no-error.
 if error-status:error then return no-apply.
 run OpenBr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-links
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-links Dialog-Frame
ON CHOOSE OF b-links IN FRAME Dialog-Frame /* Связи */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
case v-browse-mode:
  when "temp" then do:
    IF NOT AVAILABLE tt-ruleset THEN RETURN NO-APPLY.
  end.
  otherwise do:
    IF NOT AVAILABLE X_ruleset THEN RETURN NO-APPLY.
  end.
end case.
IF link-option = '':U THEN DO:
  run gbl/pop-up.p ( input self :handle, input no ) no-error.
  if error-status :error then do: return no-apply. end.
END.
if link-option = "":U then do:
   return no-apply.
end.
RUN proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
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
  define variable v-rec as recid no-undo.
  define buffer buf_ruleset for ub.ruleset.
  if v-browse-mode = "temp" then do:
    if not available tt-ruleset then return no-apply.
    find first buf_ruleset no-lock where
              buf_ruleset.codex_id = tt-ruleset.codex_id
          and buf_ruleset.ruleset_id = tt-ruleset.ruleset_id.
   v-rec = recid(buf_ruleset).
    run rul/ruleset-i.w ( input parparentproc
                        ,input {&lookup}
                        ,input buf_ruleset.codex_id
                        ,input buf_ruleset.ruleset_id
                        ,input-output v-rec) no-error.

  end.
  else do:

    if not available X_ruleset then return no-apply.
    v-rec = recid(X_ruleset).
    run rul/ruleset-i.w ( input parparentproc
                        ,input {&lookup}
                        ,input X_ruleset.codex_id
                        ,input X_ruleset.ruleset_id
                        ,input-output v-rec) no-error.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
    define variable glog as logical no-undo .
  if available X_ruleset then do:
 { gbl/markstrn.i X_ruleset v-rid-list }
  glog = br-ruleset:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-ruleset:select-next-row ().
      apply "VALUE-CHANGED" to br-ruleset in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-ruleset in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
define buffer buf_ruleset for ub.ruleset.
  case v-browse-mode:
    when "temp" then do:
      if available tt-ruleset then do:
        find first buf_ruleset no-lock where buf_ruleset.codex_id = tt-ruleset.codex_id and
        buf_ruleset.ruleset_id = tt-ruleset.ruleset_id.
        if  ( v-rid-list = "" ) or b-mark:sensitive = no
        then  v-rid-list = string( recid( buf_ruleset ) ) .
      end.

    end.
    otherwise do:
      if available X_ruleset then do:
        if  ( v-rid-list = "" ) or b-mark:sensitive = no
        then  v-rid-list = string( recid( X_ruleset ) ) .
      end.
    end.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-ruleset
&Scoped-define SELF-NAME br-ruleset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-ruleset Dialog-Frame
ON VALUE-CHANGED OF br-ruleset IN FRAME Dialog-Frame
DO:
   IF AVAILABLE X_ruleset and X_ruleset.ruleset_id = 0 THEN DO:
      ASSIGN
      MENU-ITEM m_prop-ruleset:SENSITIVE IN MENU menu-b-links = NO
      MENU-ITEM m_pscript-ruleset:SENSITIVE IN MENU menu-b-links = no
      .
  END.
  ELSE DO:
      ASSIGN
      MENU-ITEM m_prop-ruleset:SENSITIVE  IN MENU menu-b-links = YES
      MENU-ITEM m_pscript-ruleset :SENSITIVE IN MENU menu-b-links = (lookup("b-add", bttns) > 0)
      .
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-temp-ruleset
&Scoped-define SELF-NAME br-temp-ruleset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-temp-ruleset Dialog-Frame
ON VALUE-CHANGED OF br-temp-ruleset IN FRAME Dialog-Frame
DO:
  IF AVAILABLE X_ruleset and X_ruleset.ruleset_id = 0 THEN DO:
      ASSIGN
      MENU-ITEM m_prop-ruleset:SENSITIVE IN MENU menu-b-links = NO
      MENU-ITEM m_pscript-ruleset:SENSITIVE IN MENU menu-b-links = NO
      .
  END.
  ELSE DO:
      ASSIGN
      MENU-ITEM m_prop-ruleset:SENSITIVE  IN MENU menu-b-links = YES
      MENU-ITEM m_pscript-ruleset :SENSITIVE IN MENU menu-b-links = (lookup("b-add", bttns) > 0)
      .
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_prop-ruleset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_prop-ruleset Dialog-Frame
ON CHOOSE OF MENU-ITEM m_prop-ruleset /* Объекты-операнды */
DO:
case v-browse-mode:
  when "temp" then do:
    IF NOT AVAILABLE tt-ruleset THEN RETURN NO-APPLY.
    if tt-ruleset.ruleset_id = 0 then do:
        message
        "Доступно только для наборов правил, но не для кодексов"
        view-as alert-box .
        return no-apply.
    end.
  end.
  otherwise do:
    IF NOT AVAILABLE X_ruleset THEN RETURN NO-APPLY.
    if X_ruleset.ruleset_id = 0 then do:
        message
        "Доступно только для наборов правил, но не для кодексов"
        view-as alert-box .
        return no-apply.
    end.
  end.
end case.
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT {&table_prop-ruleset}) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_pscript-ruleset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_pscript-ruleset Dialog-Frame
ON CHOOSE OF MENU-ITEM m_pscript-ruleset /* Скрипты для объектов */
DO:
  case v-browse-mode:
    when "temp" then do:
      IF NOT AVAILABLE tt-ruleset THEN RETURN NO-APPLY.
      if tt-ruleset.ruleset_id = 0 then do:
          message
          "Доступно только для наборов правил, но не для кодексов"
          view-as alert-box .
          return no-apply.
      end.
    end.
    otherwise do:
      IF NOT AVAILABLE X_ruleset THEN RETURN NO-APPLY.
      if X_ruleset.ruleset_id = 0 then do:
          message
          "Доступно только для наборов правил, но не для кодексов"
          view-as alert-box .
          return no-apply.
      end.
    end.
  end case.
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT {&table_pscript-ruleset}) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_rule Dialog-Frame
ON CHOOSE OF MENU-ITEM m_rule /* Правила */
DO:
define variable v-ruleset-id as integer no-undo .
  case v-browse-mode:
    when "temp" then do:
      IF NOT AVAILABLE tt-ruleset THEN RETURN NO-APPLY.
      v-ruleset-id = tt-ruleset.ruleset_Id.
    end.
    otherwise do:
      IF NOT AVAILABLE X_ruleset THEN RETURN NO-APPLY.
      v-ruleset-id = X_ruleset.ruleset_Id.
    end.
  end case.
  IF v-ruleset-id = 0  THEN DO:
    RUN proc-b-link IN THIS-PROCEDURE ( INPUT {&table_rule}) NO-ERROR.
  END.
  ELSE DO:
    RUN proc-b-link IN THIS-PROCEDURE ( INPUT {&table_rule-by-set}) NO-ERROR.
  END.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_rule-by-profile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_rule-by-profile Dialog-Frame
ON CHOOSE OF MENU-ITEM m_rule-by-profile /* Правила профайлов */
DO:
  case v-browse-mode:
    when "temp" then do:
      IF NOT AVAILABLE tt-ruleset THEN RETURN NO-APPLY.
    end.
    otherwise do:
      IF NOT AVAILABLE X_ruleset THEN RETURN NO-APPLY.
    end.
  end case.
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT {&table_rule-by-profile}) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_rule-call-param
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_rule-call-param Dialog-Frame
ON CHOOSE OF MENU-ITEM m_rule-call-param /* Параметры вызова правил */
DO:
  case v-browse-mode:
    when "temp" then do:
      IF NOT AVAILABLE tt-ruleset THEN RETURN NO-APPLY.
    end.
    otherwise do:
      IF NOT AVAILABLE X_ruleset THEN RETURN NO-APPLY.
    end.
  end case.
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT {&table_rule-call-param}) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-ruleset
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
ON ROW-DISPLAY OF br-ruleset IN frame {&frame-name}
DO:
  case v-browse-mode:
    when "temp" then do:
      IF AVAIL tt-ruleset THEN DO:
        RUN set-row-color IN this-procedure  ( INPUT tt-ruleset.ruleset_id).
      END.
    end.
    otherwise do:
      IF AVAIL X_ruleset THEN DO:
        RUN set-row-color IN this-procedure  ( INPUT X_ruleset.ruleset_id).
      END.
    end.
  end case.

END.

{ gbl/brwrefre.i " run refresh in this-procedure . " }

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
  if lookup( entry(1, p-list-mode, {&delim-par}), {&all} + {&comma-char} +
                          "codex" + {&comma-char} +
                          "only-codex" + {&comma-char} +
                          "only-ruleset" + {&comma-char} +
                          "profile-type") = 0 then do:
    message
    substitute("Неверное значение параметра p-list-mode=&1", p-list-mode)
    view-as alert-box error .
    undo main-block, return error .
  end.
  v-rid-list = p-rid-list.
  if entry(1, p-list-mode, {&delim-par}) = "profile-type" then do:
    run fill-table in this-procedure ( input entry(2, p-list-mode, {&delim-par})).
  end.
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
  ENABLE b-quit b-mark b-sel b-add b-chg b-del b-lkp b-links B-Help
         br-temp-ruleset br-ruleset mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-table Dialog-Frame
PROCEDURE fill-table :
DEFINE INPUT PARAMETER p-profile-type AS CHARACTER NO-UNDO.
DEFINE buffer buf_rule-profile FOR ub.rule-profile.
DEFINE buffer buf_rule-by-profile FOR ub.rule-by-profile.
DEFINE buffer buf_ruleset FOR ub.ruleset.
DEFINE buffer buf_tt-ruleset FOR tt-ruleset.
FOR EACH buf_tt-ruleset:
    DELETE buf_tt-ruleset.
END.
FOR EACH buf_rule-profile NO-LOCK WHERE
        buf_rule-profile.profile-type begins (entry(1, p-profile-type, "_") + "_")
        or buf_rule-profile.profile-type = p-profile-type
        ,
    EACH buf_rule-by-profile NO-LOCK WHERE
        buf_rule-by-profile.profile_id = buf_rule-profile.profile_id
BREAK
BY buf_rule-by-profile.codex_id
BY buf_rule-by-profile.ruleset_id:
   IF FIRST-OF(buf_rule-by-profile.ruleset_id) THEN DO:
     case entry(3, p-list-mode, {&delim-par}):
       when "ruleset" then do:
          FIND FIRST buf_tt-ruleset NO-LOCK WHERE
                    buf_tt-ruleset.codex_id = buf_rule-by-profile.codex_id
              AND buf_tt-ruleset.ruleset_id = buf_rule-by-profile.ruleset_id NO-ERROR.
          IF NOT AVAILABLE( buf_tt-ruleset) THEN DO:
              FIND FIRST buf_ruleset NO-LOCK WHERE
                  buf_ruleset.codex_id = buf_rule-by-profile.codex_id
            AND buf_ruleset.ruleset_id = buf_rule-by-profile.ruleset_id NO-ERROR.
            IF AVAILABLE buf_ruleset THEN DO:
                CREATE buf_tt-ruleset.
                BUFFER-COPY buf_ruleset TO buf_tt-ruleset.
            END.
          END.
       end.
       when "codex" then do:
          FIND FIRST buf_tt-ruleset NO-LOCK WHERE
                    buf_tt-ruleset.codex_id = buf_rule-by-profile.codex_id
              AND buf_tt-ruleset.ruleset_id = 0 NO-ERROR.
          IF NOT AVAILABLE( buf_tt-ruleset) THEN DO:
              FIND FIRST buf_ruleset NO-LOCK WHERE
                  buf_ruleset.codex_id = buf_rule-by-profile.codex_id
            AND buf_ruleset.ruleset_id = 0 NO-ERROR.
            IF AVAILABLE buf_ruleset THEN DO:
                CREATE buf_tt-ruleset.
                BUFFER-COPY buf_ruleset TO buf_tt-ruleset.
            END.
          END.
       end.
       when "all" then do:
          FIND FIRST buf_tt-ruleset NO-LOCK WHERE
                    buf_tt-ruleset.codex_id = buf_rule-by-profile.codex_id
              AND buf_tt-ruleset.ruleset_id = buf_rule-by-profile.ruleset_id NO-ERROR.
          IF NOT AVAILABLE( buf_tt-ruleset) THEN DO:
              FIND FIRST buf_ruleset NO-LOCK WHERE
                  buf_ruleset.codex_id = buf_rule-by-profile.codex_id
            AND buf_ruleset.ruleset_id = buf_rule-by-profile.ruleset_id NO-ERROR.
            IF AVAILABLE buf_ruleset THEN DO:
                CREATE buf_tt-ruleset.
                BUFFER-COPY buf_ruleset TO buf_tt-ruleset.
            END.
          END.
          FIND FIRST buf_tt-ruleset NO-LOCK WHERE
                    buf_tt-ruleset.codex_id = buf_rule-by-profile.codex_id
              AND buf_tt-ruleset.ruleset_id = 0 NO-ERROR.
          IF NOT AVAILABLE( buf_tt-ruleset) THEN DO:
              FIND FIRST buf_ruleset NO-LOCK WHERE
                  buf_ruleset.codex_id = buf_rule-by-profile.codex_id
            AND buf_ruleset.ruleset_id = 0 NO-ERROR.
            IF AVAILABLE buf_ruleset THEN DO:
                CREATE buf_tt-ruleset.
                BUFFER-COPY buf_ruleset TO buf_tt-ruleset.
            END.
          END.
       end.
     end case.
   END.

END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
b-links:MENU-MOUSE IN FRAME {&FRAME-NAME} = 1.
if entry(1, p-list-mode, {&delim-par}) = "profile-type" THEN DO:
  v-browse-mode = "temp".
    ASSIGN
    tt-ruleset.NAME:RESIZABLE IN BROWSE br-temp-ruleset = YES.
    ENABLE
    b-quit
    b-lkp
    B-Help
    b-links
    b-sel when lookup("b-sel", bttns) > 0
    br-temp-ruleset
    WITH FRAME {&frame-name}.
    VIEW FRAME {&frame-name}.
    run OpentempBr in this-procedure .
    DISABLE
    b-add
    b-chg
    b-del
    br-ruleset
    WITH FRAME {&FRAME-NAME}.
    HIDE
    br-ruleset
    IN FRAME {&FRAME-NAME}.
    assign
    menu-item m_prop-ruleset:sensitive in menu menu-b-links = no
    menu-item m_pscript-ruleset:sensitive in menu menu-b-links = no
    .
  apply "entry" to br-ruleset in frame {&frame-name} .
  apply "VALUE-CHANGED" to br-ruleset in frame {&frame-name} .

END.
ELSE DO:
    ASSIGN
    X_ruleset.NAME:RESIZABLE IN BROWSE br-ruleset = YES .
    ENABLE
    b-quit
    b-add when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
    b-chg when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
    b-del when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
    b-lkp
    B-Help
    b-mark when lookup("b-mark", bttns) > 0
    b-sel when lookup("b-sel", bttns) > 0
    b-links
    br-ruleset
    WITH FRAME {&frame-name}.
    VIEW FRAME {&frame-name}.
    DISABLE
    br-temp-ruleset
    WITH FRAME {&FRAME-NAME}.
    HIDE
    br-temp-ruleset
    IN FRAME {&FRAME-NAME}.
    run OpenBr in this-procedure .
  apply "entry" to br-temp-ruleset in frame {&frame-name} .
  apply "VALUE-CHANGED" to br-temp-ruleset in frame {&frame-name} .

END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
case p-list-mode:
  when {&all} then do:
    frame {&frame-name} :title = "Все кодексы и наборы правил RULE машины".
    OPEN QUERY br-ruleset FOR EACH X_ruleset NO-LOCK INDEXED-REPOSITION.
  end.
  when "codex" then do:
    frame {&frame-name} :title = substitute("Все наборы правил для кодекса &1", p-codex-id).
    OPEN QUERY br-ruleset
    FOR EACH X_ruleset NO-LOCK where
           X_ruleset.codex_id = p-codex-id
       and X_ruleset.ruleset_id > 0 INDEXED-REPOSITION.
  end.
  when "only-codex" then do:
    frame {&frame-name} :title = substitute("Кодексы правил").
    OPEN QUERY br-ruleset FOR EACH X_ruleset NO-LOCK where X_ruleset.ruleset_id = 0 INDEXED-REPOSITION.
  end.
  when "only-ruleset" then do:
    frame {&frame-name} :title = substitute("Наборы правил").
    OPEN QUERY br-ruleset FOR EACH X_ruleset NO-LOCK where X_ruleset.ruleset_id > 0 INDEXED-REPOSITION.
  end.

END CASE.
APPLY "ENTRY" to br-ruleset.
APPLY "VALUE-CHANGED" to br-ruleset.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Opentempbr Dialog-Frame
PROCEDURE Opentempbr :
define variable v-call-type as character no-undo .
case entry(2, p-list-mode, {&delim-par}):
  when {&table_dis-card-type} then do:
    v-call-type = "для типов ДК".
  end.
  when {&table_clients} then do:
    v-call-type = "для клиентов".
  end.
  when {&table_goods} then do:
    v-call-type = "для товаров".
  end.
  when {&table_gds-grp} then do:
    v-call-type = "для групп товаров".
  end.
  when {&table_cli-grp} then do:
    v-call-type = "для групп клиентов".
  end.
end.
case entry(1, p-list-mode, {&delim-par}):
  WHEN "profile-type" THEN DO:
    case entry(3, p-list-mode, {&delim-par}) :
      when "ruleset" then do:
        frame {&frame-name} :title = SUBSTITUTE("Все наборы правил RULE машины (точки вызова правил) при работе с профайлами &1", v-call-type).
      end.
      when "codex" then do:
        frame {&frame-name} :title = SUBSTITUTE("Все кодексы правил RULE машины (точки вызова правил) при работе с профайлами &1", v-call-type).
      end.
      when "all" then do:
        frame {&frame-name} :title = SUBSTITUTE("Все кодексы и наборы правил RULE машины (точки вызова правил) при работе с профайлами &1", v-call-type).
      end.
    end case.
    OPEN QUERY br-temp-ruleset FOR EACH tt-ruleset NO-LOCK INDEXED-REPOSITION.
  end.
END CASE.
APPLY "ENTRY" to br-temp-ruleset.
APPLY "VALUE-CHANGED" to br-temp-ruleset.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-link Dialog-Frame
PROCEDURE proc-b-link :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
define variable v-rid-list as character no-undo .
define variable v-ruleset-id as integer no-undo .
define variable v-codex-id as integer no-undo .
define buffer buf_rule-by-set for ub.rule-by-set.
define buffer buf_rule for ub.rule.
define buffer buf_rule-call-param for ub.rule-call-param.
case v-browse-mode:
  when "temp" then do:
    assign
    v-ruleset-id = tt-ruleset.ruleset_id
    v-codex-id = tt-ruleset.codex_id
    .
  end.
  otherwise do:
    assign
    v-ruleset-id = X_ruleset.ruleset_id
    v-codex-id = X_ruleset.codex_id
    .
  end.
end.
CASE p-option:
  WHEN {&table_prop-ruleset} THEN DO:
    run rul/prop-ruleset-s.w ( INPUT parparentproc
                              ,INPUT "":U /*bttns*/
                              ,INPUT "ruleset"
                              ,INPUT v-codex-id
                              ,INPUT v-ruleset-id
                              ,INPUT 0 /*p-dtm-code*/
                              ,INPUT-OUTPUT v-rid-list) NO-ERROR.

  END.
  when {&table_pscript-ruleset} then do:
    run rul/pscript-ruleset-s.w ( INPUT parparentproc
                              ,INPUT "":U /*bttns*/
                              ,INPUT "ruleset"
                              ,INPUT v-codex-id
                              ,INPUT v-ruleset-id
                              ,INPUT 0 /*p-dtm-code*/
                              ,input '':U /*p-language*/
                              ,input '':U /*script-name*/
                              ,INPUT-OUTPUT v-rid-list) NO-ERROR.

  end.
  when {&table_rule} then do:
    run rul/rule-by-set-s.w ( INPUT parparentproc
                      ,INPUT "":U /*bttns*/
                      ,INPUT "codex"
                      ,INPUT v-codex-id
                      ,input 0 /*codex-id*/
                      ,INPUT 0 /*p-rule-id*/
                      ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  end.
  when {&table_rule-by-set} then do:
    run rul/rule-by-set-s.w ( INPUT parparentproc
                      ,INPUT "":U /*bttns*/
                      ,INPUT "ruleset"
                      ,INPUT v-codex-id
                      ,INPUT v-ruleset-id
                      ,input 0 /*rule-id*/
                      ,INPUT-OUTPUT v-rid-list) NO-ERROR.

  end.
  when {&table_rule-by-profile} then do:
    run rul/rule-by-profile-s.w ( INPUT parparentproc
                      ,INPUT "":U /*bttns*/
                      ,INPUT "ruleset"
                      ,INPUT 0 /*profile-id*/
                      ,INPUT v-codex-id
                      ,INPUT v-ruleset-id
                      ,INPUT 0 /*rule-id*/
                      ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  end.
  when {&table_rule-call-param} then do:
    /*найдем все вызовы rule*/
    for each tt0-rule-call-param:
      delete tt0-rule-call-param.
    end.
    if v-ruleset-id <> 0 then do:
      for each buf_rule-by-set where
              buf_rule-by-set.codex_id = v-codex-id
          and buf_rule-by-set.ruleset_id = v-ruleset-id,
          each buf_rule-call-param no-lock where
              buf_Rule-call-param.rule_id = buf_rule-by-set.rule_id:
        create tt0-rule-call-param.
        buffer-copy buf_rule-call-param to tt0-rule-call-param.
      end.
    end.
    else do:
      for each buf_rule where
              buf_rule.codex_id = v-codex-id,
          each buf_rule-call-param no-lock where
              buf_Rule-call-param.rule_id = buf_rule.rule_id:
        create tt0-rule-call-param.
        buffer-copy buf_rule-call-param to tt0-rule-call-param.
      end.
    end.
    run ref/rulercps.w ( INPUT parparentproc
                        ,input this-procedure:handle
                        ,INPUT "":U /*bttns*/
                        ,input {&lookup}
                        ,input {&table_rule-call-param}
                        ,input 0 /*profile-id*/
                        ,input ? /*once-more*/
                        ,input '':U /*p-call-id*/
                        ,input v-codex-id /*p-codex-id*/
                        ,input v-ruleset-id /*p-ruleset-id*/
                        ,input ? /*p-order-id*/
                        ,input 0 /*p-rule-id*/
                        ,input substitute("Параметры вызова правил: кодекс &1 набор правил &2"
                                          , v-codex-id
                                          , v-ruleset-id)
                        ,input-output table tt0-rule-call-param ) no-error.
  end.
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh Dialog-Frame
PROCEDURE refresh :
if v-browse-mode  = "temp" THEN DO:
    v-doc-rec = recid(tt-ruleset).
    RUn OpentempBR in this-procedure.
    REPOSITION br-temp-ruleset to recid v-doc-rec No-ERROR.
    apply 'value-changed' to br-temp-ruleset in frame {&frame-name} .
END.
ELSE DO:
    v-doc-rec = recid(X_ruleset).
    RUn OpenBR in this-procedure.
    REPOSITION br-ruleset to recid v-doc-rec No-ERROR.
    apply 'value-changed' to br-ruleset in frame {&frame-name} .
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color Dialog-Frame
PROCEDURE set-row-color :
DEFINE INPUT PARAMETER p-ruleset-id AS INTEGER.
DEFINE VARIABLE iFGColor AS INTEGER NO-UNDO.
DEFINE VARIABLE iBGColor AS INTEGER NO-UNDO.

CASE p-ruleset-id:
  WHEN 0 THEN DO:

  IF p-ruleset-id = 0 THEN DO:
      ASSIGN
        iFGColor = WHITE_COLOR
        iBGColor = DARK_GREEN_COLOR
      .
    end.
    ELSE do:
      ASSIGN
        iFGColor = Black_COLOR
        iBGColor = White_COLOR
      .
    end.
    if v-browse-mode = "temp" then do:
      ASSIGN
      tt-ruleset.name:FGCOLOR IN BROWSE br-temp-ruleset = iFGColor
      tt-ruleset.name:BGCOLOR IN BROWSE br-temp-ruleset = iBGColor
      .
    end.
    else do:
      ASSIGN
      X_ruleset.name:FGCOLOR IN BROWSE br-ruleset = iFGColor
      X_ruleset.name:BGCOLOR IN BROWSE br-ruleset = iBGColor
      .
    end.

  END.
  OTHERWISE DO:

  END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME