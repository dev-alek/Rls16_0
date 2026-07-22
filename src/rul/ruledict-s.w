&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_ruledict FOR ub.ruledict.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Словарь Rule-машины

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
define input parameter p-entry-type as character no-undo .
define input parameter p-uniq-key-rec as character no-undo .
define input-output parameter p-rid-list as character no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Словарь Rule-машины".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/color.i }
{ gbl/getcntxt.i def }
{ gbl/key-rec.i }
{ cmp/mrk-strf.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/fltopend.i defproc }

DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
DEFINE VARIABLE link-option AS CHARACTER NO-UNDO.
define variable sort-column-name as character no-undo .
define variable filter-point-label as character no-undo init "Словарь RULE-машины" .
define variable filter-point0 as character no-undo init "ruledict-s" .
define variable filter-point as character no-undo init "ruledict-s" .
define variable p-word-script-al as character no-undo .
define variable p-word-script-nl as character no-undo .
define variable v-rid-list as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-ruledict

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_ruledict

/* Definitions for BROWSE br-ruledict                                   */
&Scoped-define FIELDS-IN-QUERY-br-ruledict mark-string(recid(X_ruledict), v-rid-list) X_ruledict.entry-id X_ruledict.entry-type X_ruledict.script-al X_ruledict.script-nl X_ruledict.uniq-key-rec
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-ruledict
&Scoped-define SELF-NAME br-ruledict
&Scoped-define QUERY-STRING-br-ruledict FOR EACH X_ruledict
&Scoped-define OPEN-QUERY-br-ruledict OPEN QUERY br-ruledict FOR EACH X_ruledict .
&Scoped-define TABLES-IN-QUERY-br-ruledict X_ruledict
&Scoped-define FIRST-TABLE-IN-QUERY-br-ruledict X_ruledict


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-ruledict}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-chg b-del b-lkp ~
b-links b-sch B-Help b-copy b-uniq-key-rec cb-entry-type rs-find-al ~
f-script-al rs-find-nl f-script-nl br-ruledict mark-num
&Scoped-Define DISPLAYED-OBJECTS cb-entry-type rs-find-al f-script-al ~
rs-find-nl f-script-nl mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-links
       MENU-ITEM m_ruledict-param LABEL "Параметры"
       MENU-ITEM m_correspondent LABEL "Корреспондент" .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-copy
     LABEL "&Копировать"
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

DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1.

DEFINE BUTTON b-uniq-key-rec
     LABEL "Связать"
     SIZE 10 BY 1.

DEFINE VARIABLE cb-entry-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 97.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-script-al AS CHARACTER FORMAT "X(256)":U
     LABEL "Термин"
     VIEW-AS FILL-IN
     SIZE 65 BY 1 NO-UNDO.

DEFINE VARIABLE f-script-nl AS CHARACTER FORMAT "X(256)":U
     LABEL "Перевод"
     VIEW-AS FILL-IN
     SIZE 65 BY 1 NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9 BY .67
     FGCOLOR 10  NO-UNDO.

DEFINE VARIABLE rs-find-al AS CHARACTER INITIAL "begins"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Нач.назв.", "begins",
"Нач.слова", "contains"
     SIZE 23 BY 1 NO-UNDO.

DEFINE VARIABLE rs-find-nl AS CHARACTER INITIAL "begins"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Нач.назв.", "begins",
"Нач.слова", "contains"
     SIZE 23 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE  QUERY br-ruledict FOR
                X_ruledict SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-ruledict
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-ruledict Dialog-Frame _FREEFORM
  QUERY br-ruledict NO-LOCK DISPLAY
      mark-string(recid(X_ruledict), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_ruledict.entry-id COLUMN-LABEL "ID" FORMAT "->>>>>>>>9"
X_ruledict.entry-type COLUMN-LABEL "Тип" FORMAT "X(16)"
X_ruledict.script-al COLUMN-LABEL "Название" FORMAT "X(255)" WIDTH 60
X_ruledict.script-nl COLUMN-LABEL "Название" FORMAT "X(255)" WIDTH 60
X_ruledict.uniq-key-rec COLUMN-LABEL "Корреспондент" FORMAT "X(255)" WIDTH 60
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 16.54 FIT-LAST-COLUMN.


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
     b-sch AT ROW 1 COL 92 WIDGET-ID 20
     B-Help AT ROW 1 COL 95
     b-copy AT ROW 2 COL 38 WIDGET-ID 62
     b-uniq-key-rec AT ROW 2 COL 58 WIDGET-ID 60
     cb-entry-type AT ROW 3 COL 1 NO-LABEL WIDGET-ID 18
     rs-find-al AT ROW 4 COL 1.5 NO-LABEL WIDGET-ID 52
     f-script-al AT ROW 4 COL 25.5 WIDGET-ID 22
     rs-find-nl AT ROW 5 COL 1.5 NO-LABEL WIDGET-ID 56
     f-script-nl AT ROW 5 COL 24.5 WIDGET-ID 24
     br-ruledict AT ROW 6 COL 1.5 WIDGET-ID 100
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
      TABLE: X_ruledict B "?" ? ub ruledict
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-ruledict f-script-nl Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-links:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-links:HANDLE.

/* SETTINGS FOR COMBO-BOX cb-entry-type IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-script-al IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-script-nl IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-ruledict
/* Query rebuild information for BROWSE br-ruledict
     _START_FREEFORM
OPEN QUERY br-ruledict FOR EACH X_ruledict .
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE  QUERY br-ruledict FOR
                X_ruledict SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-ruledict */
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
run rul/ruledict-i.w ( input parparentproc
                       ,input {&add-def}
                       ,input (if p-list-mode = "entry-type" then p-entry-type else '':U)
                       ,input 0 /*p-entry-id*/
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
    RUN openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
    reposition br-ruledict to recid v-rec no-error.
    apply "entry" to br-ruledict.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  define variable v-rec as recid no-undo.
  if not available X_ruledict then return no-apply.
  v-rec = recid(X_ruledict).
  run rul/ruledict-i.w ( input parparentproc
                       ,input {&update}
                       ,input X_ruledict.entry-type
                       ,input X_ruledict.entry-id /*p-codex-id*/
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
     br-ruledict:refresh().
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-copy Dialog-Frame
ON CHOOSE OF b-copy IN FRAME Dialog-Frame /* Копировать */
DO:
 define variable v-rec as recid no-undo.
  if not available X_ruledict then return no-apply.
  v-rec = recid(X_ruledict).
  run rul/ruledict-i.w ( input parparentproc
                       ,input {&add-copy}
                       ,input (if p-list-mode = "entry-type" then p-entry-type else '':U)
                       ,input X_ruledict.entry-id /*p-entry-id*/
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
    RUN openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
    reposition br-ruledict to recid v-rec no-error.
    apply "entry" to br-ruledict.
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
  if not available X_ruledict then return no-apply.
  v-rec = recid(X_ruledict).
  message "Вы уверены, что хотите удалить термин из словаря?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then return no-apply.
  run rul/ruledict3.p (
                       input no /*p-silent*/
                      ,input v-rec

                      ) no-error.
 if error-status:error then return no-apply.
 run OpenBr in this-procedure ( input yes, input no, input '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-links
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-links Dialog-Frame
ON CHOOSE OF b-links IN FRAME Dialog-Frame /* Связи */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  IF NOT AVAILABLE X_ruledict THEN RETURN NO-APPLY.
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
  if not available X_ruledict then return no-apply.
  v-rec = recid(X_ruledict).
  run rul/ruledict-i.w ( input parparentproc
                       ,input {&lookup}
                       ,input X_ruledict.entry-type
                       ,input X_ruledict.entry-id
                       ,input-output v-rec) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
   define variable glog as logical no-undo .
  if available X_ruledict then do:
 { gbl/markstrn.i X_ruledict v-rid-list }
  glog = br-ruledict:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-ruledict:select-next-row ().
      apply "VALUE-CHANGED" to br-ruledict in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-ruledict in frame {&frame-name}.
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
  if available X_ruledict then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_ruledict ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-uniq-key-rec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-uniq-key-rec Dialog-Frame
ON CHOOSE OF b-uniq-key-rec IN FRAME Dialog-Frame /* Связать */
DO:
 DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
 define variable v-rec as recid no-undo .
 DEFINE BUFFER buf_prop-script FOR ub.prop-script.
 IF NOT AVAILABLE X_ruledict THEN RETURN NO-APPLY.
 v-rec = recid(X_ruledict).
run rul/prop-script-s.w (
                   input parparentproc
                   ,INPUT 'b-sel' /* bttns */
                  ,INPUT {&all} /* p-list-mode */
                  ,INPUT '':U /*p-language*/
                  ,INPUT 0
                  ,INPUT "":U /* p-proc-type */
                  ,INPUT "":U /* p-script-type */
                  ,INPUT-OUTPUT v-rid-list) NO-ERROR.
IF NOT ERROR-STATUS:ERROR
AND v-rid-list <> '':U THEN DO:
  FIND FIRST buf_prop-script NO-LOCK WHERE

      RECID(buf_prop-script) = INTEGER(v-rid-list) NO-ERROR .
  IF NOT AVAILABLE buf_prop-script THEN RETURN NO-APPLY.
  run rul/ruledict4.p ( INPUT NO
                   ,INPUT RECID(X_ruledict)
                   ,INPUT buf_prop-script.uniq-key-rec) no-error .
  if not error-status:error then do:
    RUN openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
    reposition br-ruledict to recid v-rec no-error.
    apply "entry" to br-ruledict.
  end.
END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-entry-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-entry-type Dialog-Frame
ON VALUE-CHANGED OF cb-entry-type IN FRAME Dialog-Frame
DO:
  ASSIGN cb-entry-type.
  RUN Openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-script-al
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-script-al Dialog-Frame
ON CTRL-J OF f-script-al IN FRAME Dialog-Frame /* Термин */
DO:
  run proc-find-script-al in this-procedure ( input YES
                                            , input frame {&frame-name} f-script-al
                                            , input rs-find-al) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-script-al Dialog-Frame
ON RETURN OF f-script-al IN FRAME Dialog-Frame /* Термин */
DO:
    run proc-find-script-al in this-procedure ( input NO
                                              , input frame {&frame-name} f-script-al
                                              , input rs-find-al) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-script-nl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-script-nl Dialog-Frame
ON CTRL-J OF f-script-nl IN FRAME Dialog-Frame /* Перевод */
DO:
    run proc-find-script-nl in this-procedure ( input YES
                                              , input frame {&frame-name} f-script-nl
                                              , input rs-find-nl) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-script-nl Dialog-Frame
ON RETURN OF f-script-nl IN FRAME Dialog-Frame /* Перевод */
DO:
    run proc-find-script-nl in this-procedure ( input NO
                                              , input frame {&frame-name} f-script-nl
                                              , input rs-find-al) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_correspondent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_correspondent Dialog-Frame
ON CHOOSE OF MENU-ITEM m_correspondent /* Корреспондент */
DO:
    IF NOT AVAILABLE X_ruledict THEN RETURN NO-APPLY.
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT "uniq-key-rec") NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_ruledict-param
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_ruledict-param Dialog-Frame
ON CHOOSE OF MENU-ITEM m_ruledict-param /* Параметры */
DO:
 IF NOT AVAILABLE X_ruledict THEN RETURN NO-APPLY.
 RUN proc-b-link IN THIS-PROCEDURE ( INPUT {&table_ruledict-param}) NO-ERROR.
 IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-find-al
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-find-al Dialog-Frame
ON VALUE-CHANGED OF rs-find-al IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-find-al.
  apply "ENTRY" to f-script-al.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-find-nl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-find-nl Dialog-Frame
ON VALUE-CHANGED OF rs-find-nl IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-find-nl.
  apply "ENTRY" to f-script-nl.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-ruledict
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
ON ROW-DISPLAY OF br-ruledict IN frame {&frame-name}
DO:
  IF AVAIL X_ruledict THEN DO:
    RUN set-row-color IN this-procedure  ( INPUT X_ruledict.entry-type).
  END.
END.

{ gbl/brwrefre.i " v-doc-rec = recid(X_ruledict).  ~
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).  REPOSITION br-ruledict to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to br-ruledict. " }

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
  DISPLAY cb-entry-type rs-find-al f-script-al rs-find-nl f-script-nl mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel b-add b-chg b-del b-lkp b-links b-sch B-Help
         b-copy b-uniq-key-rec cb-entry-type rs-find-al f-script-al rs-find-nl
         f-script-nl br-ruledict mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable Dialog-Frame
PROCEDURE Myenable :
ASSIGN
cb-entry-type:LIST-ITEMs  IN FRAME {&frame-name} = {&comma-char} + {&rdict-etype-list}
X_ruledict.script-nl:RESIZABLE IN BROWSE br-ruledict = YES
X_ruledict.script-al:RESIZABLE IN BROWSE br-ruledict = YES
X_ruledict.uniq-key-rec:RESIZABLE IN BROWSE br-ruledict = YES
b-links:MENU-MOUSE IN FRAME {&FRAME-NAME} = 1
cb-entry-type = '':U
rs-find-al = "begins"
rs-find-nl = "begins"
.
ENABLE
b-quit
b-add when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-copy when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-chg when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-del when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-lkp
B-Help
b-mark when lookup("b-mark", bttns) > 0
b-sel when lookup("b-sel", bttns) > 0
b-sch
b-links
b-uniq-key-rec
br-ruledict
cb-entry-type WHEN p-list-mode = {&ALL}
f-script-al
f-script-nl
rs-find-al
rs-find-nl
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF p-list-mode = "entry-type" THEN DO:
  HIDE
  cb-entry-type IN FRAME {&FRAME-NAME}.
END.
run OpenBr in this-procedure  ( input yes, input no, input '':U).
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

&scop flt-open-open-query OPEN QUERY br-ruledict FOR EACH X_ruledict

&scop flt-open-dyn_open-query FOR EACH X_ruledict

&scop flt-open-query-handle QUERY br-ruledict:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_ruledict

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_ruledict

&scop flt-open-waitfram true

define variable l-open-query as logical   no-undo .

filter-point = filter-point0 + p-list-mode.
CASE p-list-mode :
  WHEN {&all}        THEN DO:
    if cb-entry-type = '':U then do:
      assign
      filter-point-label = substitute("Все термины в словаре RULE-машины")
      .
      if p-open-query then do:
        frame {&frame-name} :title = filter-point-label
        .
      end.
      if p-word-script-nl = '':U
      and p-word-script-al = '':U then do:
        { gbl/fltopend.i
            &where-cond = " true "
            &use-ind    = "  "
            &by         = "  " }
      end.
      if p-word-script-nl = '':U
      and p-word-script-al <> '':U then do:
        { gbl/fltopend.i
            &where-cond = " X_ruledict.script-al contains p-word-script-al "
            &dyn_where-cond = " substitute('X_ruledict.script-al contains &1&2&1', ~{&double-quote~}, p-word-script-al) "
            &use-ind    = "  "
            &by         = "  " }
      end.
      if p-word-script-nl <> '':U
      and p-word-script-al = '':U then do:
        { gbl/fltopend.i
            &where-cond = " X_ruledict.script-nl contains p-word-script-nl "
            &dyn_where-cond = " substitute('X_ruledict.script-nl contains &1&2&1', ~{&double-quote~}, p-word-script-nl )"
            &use-ind    = "  "
            &by         = "  " }
      end.
      if p-word-script-nl <> '':U
      and p-word-script-al <> '':U then do:
        { gbl/fltopend.i
            &where-cond = " X_ruledict.script-al contains p-word-script-al ~
                           and X_ruledict.script-nl contains p-word-script-nl "
            &dyn_where-cond = " substitute('X_ruledict.script-al contains &1&2&1 ~
                           and X_ruledict.script-nl contains &1&3&1 ', ~{&double-quote~}, p-word-script-al, p-word-script-nl)"

            &use-ind    = "  "
            &by         = "  " }
      end.
    end.
    else do:
      assign
      filter-point-label = substitute("Все термины в словаре RULE-машины - с типом &1", cb-entry-type)
      frame {&frame-name} :title = filter-point-label
      .
      if p-word-script-nl = '':U
      and p-word-script-al = '':U then do:
        { gbl/fltopend.i
            &where-cond = "  X_ruledict.entry-type = cb-entry-type "
            &dyn_where-cond = "  substitute('X_ruledict.entry-type = &1&2&1', ~{&double-quote~}, cb-entry-type )"
            &use-ind    = "  "
            &by         = "  " }
      end.
      if p-word-script-nl = '':U
      and p-word-script-al <> '':U then do:
        { gbl/fltopend.i
            &where-cond = " X_ruledict.entry-type = cb-entry-type  ~
                            and X_ruledict.script-al contains p-word-script-al "
            &dyn_where-cond = " substitute('X_ruledict.entry-type = &1&2&1  ~
                            and X_ruledict.script-al contains &1&3&1 ', ~{&double-quote~}, cb-entry-type, p-word-script-al)"

            &use-ind    = "  "
            &by         = "  " }
      end.
      if p-word-script-nl <> '':U
      and p-word-script-al = '':U then do:
        { gbl/fltopend.i
            &where-cond = " X_ruledict.entry-type = cb-entry-type  ~
                            and X_ruledict.script-nl contains p-word-script-nl "
            &dyn_where-cond = " substitute('X_ruledict.entry-type = &1&2&1  ~
                            and X_ruledict.script-nl contains &1&3&1 ', ~{&double-quote~}, cb-entry-type, p-word-script-nl)"

            &use-ind    = "  "
            &by         = "  " }
      end.
      if p-word-script-nl <> '':U
      and p-word-script-al <> '':U then do:
        { gbl/fltopend.i
            &where-cond = " X_ruledict.entry-type = cb-entry-type  ~
                           and X_ruledict.script-al contains p-word-script-al ~
                           and X_ruledict.script-nl contains p-word-script-nl "
            &dyn_where-cond = " substitute('X_ruledict.entry-type = &1&2&1  ~
                           and X_ruledict.script-al contains &1&3&1 ~
                           and X_ruledict.script-nl contains &1&4&1 ', ~{&double-quote~}, cb-entry-type, p-word-script-al, p-word-script-nl)"

            &use-ind    = "  "
            &by         = "  " }
      end.
    end.
  END.
  when "entry-type" then do:
      assign
      filter-point-label = substitute("Термины в словаре RULE-машины с типом &1", p-entry-type)
      .
      if p-open-query then do:
        frame {&frame-name} :title = filter-point-label
        .
      end.
      if p-word-script-nl = '':U
      and p-word-script-al = '':U then do:
        { gbl/fltopend.i
            &where-cond = " X_ruledict.entry-type = p-entry-type "
            &dyn_where-cond = " substitute('X_ruledict.entry-type = &1&2&1', p-entry-type )"
            &use-ind    = "  "
            &by         = "  " }
      end.
      if p-word-script-nl = '':U
      and p-word-script-al <> '':U then do:
        { gbl/fltopend.i
            &where-cond = " X_ruledict.entry-type = p-entry-type ~
                            and X_ruledict.script-al contains p-word-script-al "
            &dyn_where-cond = " substitute('X_ruledict.entry-type = &1&2&1 ~
                            and X_ruledict.script-al contains &1&3&1 ', ~{&double-quote~}, p-entry-type, p-word-script-al)"

            &use-ind    = "  "
            &by         = "  " }
      end.
      if p-word-script-nl <> '':U
      and p-word-script-al = '':U then do:
        { gbl/fltopend.i
            &where-cond = " X_ruledict.entry-type = p-entry-type ~
                            and X_ruledict.script-nl contains p-word-script-nl "
            &dyn_where-cond = " substitute('X_ruledict.entry-type = &1&2&1 ~
                            and X_ruledict.script-nl contains &1&3&1 ', ~{&double-quote~}, p-entry-type, p-word-script-nl)"

            &use-ind    = "  "
            &by         = "  " }
      end.
      if p-word-script-nl <> '':U
      and p-word-script-al <> '':U then do:
        { gbl/fltopend.i
            &where-cond = " X_ruledict.entry-type = p-entry-type ~
                          and X_ruledict.script-al contains p-word-script-al ~
                           and X_ruledict.script-nl contains p-word-script-nl "
            &dyn_where-cond = " substitute('X_ruledict.entry-type = &1&2&1 ~
                          and X_ruledict.script-al contains &1&3&1 ~
                           and X_ruledict.script-nl contains &1&4&1 ', ~{&double-quote~}, p-entry-type, p-word-script-al, p-word-script-nl)"

            &use-ind    = "  "
            &by         = "  " }
      end.


  END.
END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-ruledict to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-ruledict:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-ruledict in frame {&frame-name}.
APPLY "ENTRY" TO br-ruledict.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-link Dialog-Frame
PROCEDURE proc-b-link :
define variable v-rid-list as character no-undo .
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
define variable v-rec as recid no-undo .
define variable v-dtm-code as integer no-undo .
define variable v-node-code as integer no-undo .
define variable v-language as character no-undo .
define variable v-script-name as character no-undo .
define variable v-dt-code as integer no-undo .
define variable v-revis-id as integer no-undo .
define variable v-rule-id as integer no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define buffer buf_ruledict-param for ub.ruledict-param.
CASE p-option:
  WHEN {&table_ruledict-param} THEN DO:
    find first buf_ruledict-param no-lock where
              buf_ruledict-param.entry-id = X_ruledict.entry-id no-error.
    if not available buf_ruledict-param then do:
      message
      "Нет параметров!"
      view-as alert-box error .
      undo, return error .
    end.
    run rul/ruledict-param-s.w ( INPUT parparentproc
                              ,input ? /*p-update-proc-handle*/
                              ,INPUT "":U /*bttns*/
                              ,INPUT "entry-id"
                              ,INPUT X_ruledict.entry-id
                              ,input X_ruledict.entry-type
                              ,INPUT-OUTPUT v-rid-list) NO-ERROR.

  END.
  WHEN "uniq-key-rec" then do:
    CASE X_ruledict.entry-type:
      WHEN {&rdict-etype-constant}
      or when {&rdict-etype-operator}
      or when {&rdict-etype-control}
      THEN DO:
        MESSAGE
        "Нет просмотра!"
        VIEW-AS ALERT-BOX WARNING.
        RETURN NO-APPLY.
      END.
      when {&rdict-etype-prop-name-global}
      or
      when {&rdict-etype-prop-name-host}
      or
      when {&rdict-etype-prop-name-obj}
      then do:
        run gen-key-fv in this-procedure ( input X_ruledict.uniq-key-rec
                                          ,output v-field-list
                                          ,output v-value-list).
        v-dtm-code = integer(entry(lookup("dtm-code":U
                                            , v-field-list
                                            , {&delim-key})
                                      , v-value-list, {&delim-key})).
        run rul/prop-head-i.w ( input parparentproc
                               ,input {&lookup}
                               ,input v-dtm-code
                               ,input-output v-rec ) no-error.
      end.
      when {&rdict-etype-node-name-global}
      or
      when {&rdict-etype-node-name-host}
      or
      when {&rdict-etype-node-name-obj}
      then do:
        run gen-key-fv in this-procedure ( input X_ruledict.uniq-key-rec
                                          ,output v-field-list
                                          ,output v-value-list).
        assign
        v-dtm-code = integer(entry(lookup("dtm-code":U
                                            , v-field-list
                                            , {&delim-key})
                                      , v-value-list, {&delim-key}))
        v-node-code = integer(entry(lookup("node-code":U
                                            , v-field-list
                                            , {&delim-key})
                                      , v-value-list, {&delim-key})).
        run rul/prop-map-i.w ( input parparentproc
                               ,input {&lookup}
                               ,input v-dtm-code
                               ,input v-node-code
                               ,input-output v-rec ) no-error.
      end.
      when {&rdict-etype-prop-script}
      or
      when {&rdict-etype-datatype}
      then do:
        run gen-key-fv in this-procedure ( input X_ruledict.uniq-key-rec
                                          ,output v-field-list
                                          ,output v-value-list).
        assign
        v-dtm-code = integer(entry(lookup("dtm-code":U
                                            , v-field-list
                                            , {&delim-key})
                                      , v-value-list, {&delim-key}))
        v-language = entry(lookup("language":U
                                            , v-field-list
                                            , {&delim-key})
                                      , v-value-list, {&delim-key})
        v-script-name = entry(lookup("script-name":U
                                            , v-field-list
                                            , {&delim-key})
                                      , v-value-list, {&delim-key})
        v-revis-id = integer(entry(lookup("revis_id":U
                                            , v-field-list
                                            , {&delim-key})
                                      , v-value-list, {&delim-key})) no-error.

        run rul/prop-script-i.w ( input parparentproc
                               ,input {&lookup}
                               ,input v-dtm-code
                               ,input v-language
                               ,input v-script-name
                               ,input v-revis-id
                               ,input-output v-rec ) no-error.

      end.
      when {&rdict-etype-sum-id} then do:
        run gen-key-fv in this-procedure ( input X_ruledict.uniq-key-rec
                                          ,output v-field-list
                                          ,output v-value-list).
        assign
        v-dt-code = integer(entry(lookup("dt-code":U
                                            , v-field-list
                                            , {&delim-key})
                                      , v-value-list, {&delim-key}))
        v-dtm-code = integer(entry(lookup("dtm-code":U
                                            , v-field-list
                                            , {&delim-key})
                                      , v-value-list, {&delim-key}))

                                      .
        run rul/prop-ref-i.w ( input parparentproc
                               ,input {&lookup}
                               ,input v-dtm-code
                               ,input v-dt-code
                               ,input '':U /*p-call-id*/
                               ,input-output v-rec ) no-error.

      end.
      when {&rdict-etype-rule} then do:
        run gen-key-fv in this-procedure ( input X_ruledict.uniq-key-rec
                                          ,output v-field-list
                                          ,output v-value-list).
        assign
        v-rule-id = integer(entry(lookup("rule_id":U
                                            , v-field-list
                                            , {&delim-key})
                                      , v-value-list, {&delim-key})).
        run rul/rule-i.w ( input parparentproc
                               ,input {&lookup}
                               ,input v-rule-id
                               ,input-output v-rec ) no-error.
      end.
    END CASE.
  END.
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
assign
  tbl = 'ruledict'
  join-tbl = 'X_ruledict'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('script-al', 'Термин', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('script-nl', 'Перевод', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('language', 'Язык', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('entry-id', '№ статьи', '',
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-script-al Dialog-Frame
PROCEDURE proc-find-script-al :
define input parameter p-next as logical no-undo.
define input parameter p-script-al AS CHARACTER no-undo.
define input parameter p-find-option as character no-undo .
define variable old-word-script-al as character no-undo .
define variable old-word-script-nl as character no-undo .
define variable v-w-script-name as character no-undo .
assign
frame {&frame-name} f-script-al.
if rs-find-nl = "begins" then
display
"":U @ f-script-nl
with frame {&frame-name}.
assign
p-script-al = replace(p-script-al, {&double-quote}, "":U)
p-script-al = replace(p-script-al, {&single-quote}, {&single-quote} + {&single-quote})
v-w-script-name = p-script-al
p-script-al = {&double-quote} + p-script-al + {&double-quote}.
CASE p-find-option:
  WHEN "begins" THEN DO:
    old-word-script-al = p-word-script-al.
    p-word-script-al = '':U.
    v-doc-rec = ?.
    if old-word-script-al <> p-word-script-al
    then do:
      run OpenBr in this-procedure
          (input yes /* p-open-query */
          ,input no  /* p-find-next  */
          ,input '':U
          ).
    end.
    run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input p-next  /* p-find-next  */
        ,input substitute("and X_ruledict.script-al begins &1 "
          , p-script-al)
        ).
  end.
  when "contains":U then do:
    p-word-script-al = v-w-script-name.
        run OpenBr in this-procedure
            (input yes /* p-open-query */
            ,input NO  /* p-find-next  */
            ,input '':U
            ).
  END.
end case.
apply "entry":u to f-script-al in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-script-nl Dialog-Frame
PROCEDURE proc-find-script-nl :
define input parameter p-next as logical no-undo.
define input parameter p-script-nl AS CHARACTER no-undo.
define input parameter p-find-option as character no-undo .
define variable old-word-script-nl as character no-undo .
define variable old-word-script-al as character no-undo .
define variable v-w-script-name as character no-undo .

assign
frame {&frame-name} f-script-nl.
if rs-find-al = "begins" then
display
"":U @ f-script-al
with frame {&frame-name}.
assign
p-script-nl = replace(p-script-nl, {&double-quote}, "":U)
p-script-nl = replace(p-script-nl, {&single-quote}, {&single-quote} + {&single-quote})
v-w-script-name = p-script-nl
p-script-nl = {&double-quote} + p-script-nl + {&double-quote}.
CASE p-find-option:
  WHEN "begins" THEN DO:
    old-word-script-nl = p-word-script-nl.
    p-word-script-nl = '':U.
    v-doc-rec = ?.
    if old-word-script-nl <> p-word-script-nl
    then do:
      run OpenBr in this-procedure
          (input yes /* p-open-query */
          ,input no  /* p-find-next  */
          ,input '':U
          ).
    end.
    run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input p-next  /* p-find-next  */
        ,input substitute("and X_ruledict.script-nl begins &1 "
          , p-script-nl)
        ).
  end.
  when "contains":U then do:
    p-word-script-nl = v-w-script-name.
        run OpenBr in this-procedure
            (input yes /* p-open-query */
            ,input NO  /* p-find-next  */
            ,input '':U
            ).
  END.
end case.
apply "entry":u to f-script-nl in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color Dialog-Frame
PROCEDURE set-row-color :
DEFINE INPUT PARAMETER p-ruledict-type AS character.
DEFINE VARIABLE iFGColor AS INTEGER NO-UNDO.
DEFINE VARIABLE iBGColor AS INTEGER NO-UNDO.

CASE p-ruledict-type:
  WHEN {&rdict-etype-constant} THEN DO:
    ASSIGN
    iFGColor = WHITE_COLOR
    iBGColor = DARK_GREEN_COLOR
    .
  end.
  when {&rdict-etype-operator} then do:
    ASSIGN
    iFGColor = WHITE_COLOR
    iBGColor = BLUE_COLOR
    .
  end.
  when {&rdict-etype-control} then do:
    ASSIGN
    iFGColor = WHITE_COLOR
    iBGColor = YELLOW_COLOR
    .
  end.
  when {&rdict-etype-prop-name-global}
  or
  when {&rdict-etype-prop-name-host}
  or
  when {&rdict-etype-prop-name-obj}
  then do:
    ASSIGN
    iFGColor = BLACK_COLOR
    iBGColor = BLUE_COLOR
    .
  end.
  when {&rdict-etype-node-name-global}
  or
  when {&rdict-etype-node-name-host}
  or
  when {&rdict-etype-node-name-obj}
  then do:
    ASSIGN
      iFGColor = BLACK_COLOR
      iBGColor = GREY_COLOR
    .
  end.
  when {&rdict-etype-prop-script} then do:
    ASSIGN
      iFGColor = BLACK_COLOR
      iBGColor = RED_COLOR
    .
  end.
  when {&rdict-etype-sum-id} then do:
    ASSIGN
      iFGColor = RED_COLOR
      iBGColor = WHITE_COLOR
    .
  end.
  when {&rdict-etype-sum-id} then do:
    ASSIGN
      iFGColor = DARK_GREEN_COLOR
      iBGColor = WHITE_COLOR
    .
  end.
  when {&rdict-etype-rule} then do:
    ASSIGN
      iFGColor = RED_COLOR
      iBGColor = WHITE_COLOR
    .
  end.
  when {&rdict-etype-datatype} then do:
    ASSIGN
      iFGColor = BLACK_COLOR
      iBGColor = GREEN_COLOR
    .
  end.
  otherwise do:
    ASSIGN
      iFGColor = Black_COLOR
      iBGColor = White_COLOR
    .
  end.
END CASE.
ASSIGN
X_ruledict.entry-type:FGCOLOR IN BROWSE {&BROWSE-NAME} = iFGColor
X_ruledict.entry-type:BGCOLOR IN BROWSE {&BROWSE-NAME} = iBGColor
.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
