&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-ruledict-param NO-UNDO LIKE ub.ruledict-param.
DEFINE BUFFER X_ruledict-param FOR ub.ruledict-param.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список ruledict-param


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
define input parameter p-update-proc-handle as handle no-undo .
define input parameter bttns as character no-undo.
define input parameter p-list-mode as character no-undo .
define input parameter p-entry-id as integer no-undo .
define input parameter p-entry-type as character no-undo .
define input-output parameter p-rid-list as character no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список ruledict-param".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/color.i }
{ gbl/getcntxt.i def }
{ gbl/key-rec.i }
{ cmp/mrk-strf.i }
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
DEFINE VARIABLE link-option AS CHARACTER NO-UNDO.
define temp-table tt0-rule-call-param no-undo like ub.rule-call-param.
define variable v-rid-list as character no-undo .
define variable v-return-value as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-ruledict-param

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_ruledict-param tt-ruledict-param

/* Definitions for BROWSE br-ruledict-param                             */
&Scoped-define FIELDS-IN-QUERY-br-ruledict-param mark-string(recid(X_ruledict-param), v-rid-list) X_ruledict-param.entry-id X_ruledict-param.param-num X_ruledict-param.param-data-type X_ruledict-param.param-2-data-type X_ruledict-param.param-3-data-type X_ruledict-param.param-mode X_ruledict-param.param-name X_ruledict-param.param-label
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-ruledict-param
&Scoped-define SELF-NAME br-ruledict-param
&Scoped-define QUERY-STRING-br-ruledict-param FOR EACH X_ruledict-param
&Scoped-define OPEN-QUERY-br-ruledict-param OPEN QUERY br-ruledict-param FOR EACH X_ruledict-param.
&Scoped-define TABLES-IN-QUERY-br-ruledict-param X_ruledict-param
&Scoped-define FIRST-TABLE-IN-QUERY-br-ruledict-param X_ruledict-param


/* Definitions for BROWSE br-tt-ruledict-param                          */
&Scoped-define FIELDS-IN-QUERY-br-tt-ruledict-param mark-string(recid(tt-ruledict-param), v-rid-list) tt-ruledict-param.entry-id tt-ruledict-param.param-num tt-ruledict-param.param-data-type tt-ruledict-param.param-2-data-type tt-ruledict-param.param-3-data-type tt-ruledict-param.param-mode tt-ruledict-param.param-name tt-ruledict-param.param-label
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-tt-ruledict-param
&Scoped-define SELF-NAME br-tt-ruledict-param
&Scoped-define QUERY-STRING-br-tt-ruledict-param FOR EACH tt-ruledict-param
&Scoped-define OPEN-QUERY-br-tt-ruledict-param OPEN QUERY br-tt-ruledict-param FOR EACH tt-ruledict-param.
&Scoped-define TABLES-IN-QUERY-br-tt-ruledict-param tt-ruledict-param
&Scoped-define FIRST-TABLE-IN-QUERY-br-tt-ruledict-param tt-ruledict-param


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-ruledict-param}~
    ~{&OPEN-QUERY-br-tt-ruledict-param}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-mark b-sel b-add b-chg b-del ~
b-lkp b-links B-Help br-tt-ruledict-param br-ruledict-param mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-links
       MENU-ITEM m_rule-call-param LABEL "ЗАДАННЫЕ Параметры".


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

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 2 BY 1
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
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 8 BY .67
     FGCOLOR 10  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-ruledict-param FOR
      X_ruledict-param SCROLLING.

DEFINE QUERY br-tt-ruledict-param FOR
      tt-ruledict-param SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-ruledict-param
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-ruledict-param Dialog-Frame _FREEFORM
  QUERY br-ruledict-param NO-LOCK DISPLAY
      mark-string(recid(X_ruledict-param), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_ruledict-param.entry-id COLUMN-LABEL "ID" FORMAT ">>>>>>>>9"
X_ruledict-param.param-num COLUMN-LABEL "№ пар-ра" FORMAT ">>>>>>>>9"
X_ruledict-param.param-data-type COLUMN-LABEL "Тип" FORMAT "X(16)"
X_ruledict-param.param-2-data-type COLUMN-LABEL "Тип2" FORMAT "X(16)"
X_ruledict-param.param-3-data-type COLUMN-LABEL "Тип3" FORMAT "X(16)"
X_ruledict-param.param-mode COLUMN-LABEL "Мода" FORMAT "X(16)"
X_ruledict-param.param-name COLUMN-LABEL "Название" FORMAT "X(255)" WIDTH 60
X_ruledict-param.param-label COLUMN-LABEL "Название" FORMAT "X(255)" WIDTH 60
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 20.54 ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.

DEFINE BROWSE br-tt-ruledict-param
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-tt-ruledict-param Dialog-Frame _FREEFORM
  QUERY br-tt-ruledict-param NO-LOCK DISPLAY
      mark-string(recid(tt-ruledict-param), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
tt-ruledict-param.entry-id COLUMN-LABEL "ID" FORMAT ">>>>>>>>9"
tt-ruledict-param.param-num COLUMN-LABEL "№ пар-ра" FORMAT ">>>>>>>>9"
tt-ruledict-param.param-data-type COLUMN-LABEL "Тип" FORMAT "X(16)"
tt-ruledict-param.param-2-data-type COLUMN-LABEL "Тип2" FORMAT "X(16)"
tt-ruledict-param.param-3-data-type COLUMN-LABEL "Тип3" FORMAT "X(16)"
tt-ruledict-param.param-mode COLUMN-LABEL "Мода" FORMAT "X(16)"
tt-ruledict-param.param-name COLUMN-LABEL "Название" FORMAT "X(255)" WIDTH 60
tt-ruledict-param.param-label COLUMN-LABEL "Название" FORMAT "X(255)" WIDTH 60
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 20.54 ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1 WIDGET-ID 18
     b-quit AT ROW 1 COL 11
     b-mark AT ROW 1 COL 30 WIDGET-ID 12
     b-sel AT ROW 1 COL 34 WIDGET-ID 10
     b-add AT ROW 1 COL 44 WIDGET-ID 2
     b-chg AT ROW 1 COL 54 WIDGET-ID 4
     b-del AT ROW 1 COL 64 WIDGET-ID 8
     b-lkp AT ROW 1 COL 74 WIDGET-ID 6
     b-links AT ROW 1 COL 84 WIDGET-ID 16
     B-Help AT ROW 1 COL 96
     br-tt-ruledict-param AT ROW 2.33 COL 1.5 WIDGET-ID 200
     br-ruledict-param AT ROW 2.33 COL 1.5 WIDGET-ID 100
     mark-num AT ROW 1 COL 20 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     SPACE(68.50) SKIP(21.20)
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
      TABLE: tt-ruledict-param T "?" NO-UNDO ub ruledict-param
      TABLE: X_ruledict-param B "?" ? ub ruledict-param
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-tt-ruledict-param B-Help Dialog-Frame */
/* BROWSE-TAB br-ruledict-param br-tt-ruledict-param Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-links:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-links:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-ruledict-param
/* Query rebuild information for BROWSE br-ruledict-param
     _START_FREEFORM
OPEN QUERY br-ruledict-param FOR EACH X_ruledict-param.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-ruledict-param */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-tt-ruledict-param
/* Query rebuild information for BROWSE br-tt-ruledict-param
     _START_FREEFORM
OPEN QUERY br-tt-ruledict-param FOR EACH tt-ruledict-param.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-tt-ruledict-param */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame
DO:
define buffer buf_tt-ruledict-param for tt-ruledict-param.
 p-rid-list = v-rid-list.
 if p-list-mode = {&update} then do:
   for each buf_tt-ruledict-param
     BY buf_tt-ruledict-param.param-num
     :
     run save-tt-ruledict-param in p-update-proc-handle ( input buffer buf_tt-ruledict-param:handle) no-error .
     if error-status:error then do:
       MESSAGE
       substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
       VIEW-AS ALERT-BOX ERROR.
       RETURN no-apply.
     end.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  assign
  v-return-value = "quit".
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
 define variable v-rec as recid no-undo.
 if p-list-mode = {&update} then do:
   v-rec = recid(tt-ruledict-param).
 end.
 else do:
   v-rec = recid(X_ruledict-param).
 end.
  run rul/ruledict-param-i.w ( input parparentproc
                       ,input this-procedure:handle /*p-update-proc-handel*/
                       ,input {&add-def}
                       ,input p-entry-id /*p-entry-id*/
                       ,input (if p-list-mode = {&update}
                               then p-entry-type
                               else '':U)
                               /*p-entry-type*/
                       ,input '':U /*p-language*/
                       ,input 0
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
  if p-list-mode = {&update} then do:
    if not available tt-ruledict-param then return no-apply.
    v-rec = recid(tt-ruledict-param).
    run rul/ruledict-param-i.w ( input parparentproc
                        ,input this-procedure:handle /*p-update-proc-handel*/
                        ,input {&update}
                        ,input tt-ruledict-param.entry-id /*p-codex-id*/
                        ,input p-entry-type
                        ,input tt-ruledict-param.language /*p-language*/
                        ,input tt-ruledict-param.param-num /*p-param-num*/
                        ,input-output v-rec) no-error.
    if v-rec <> ? then do:
      br-tt-ruledict-param:refresh().
    end.
  end.
  else do:
    if not available X_ruledict-param then return no-apply.
    v-rec = recid(X_ruledict-param).
    run rul/ruledict-param-i.w ( input parparentproc
                        ,input ? /*p-update-proc-handel*/
                        ,input {&update}
                        ,input X_ruledict-param.entry-id /*p-codex-id*/
                        ,input '':U
                        ,input X_ruledict-param.language /*p-language*/
                        ,input X_ruledict-param.param-num /*p-param-num*/
                        ,input-output v-rec) no-error.
    if v-rec <> ? then do:
      br-ruledict-param:refresh().
    end.
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
  if p-list-mode = {&update} then do:
    if not available tt-ruledict-param then return no-apply.
    v-rec = recid(tt-ruledict-param).
    message "Вы уверены, что хотите удалить параметр?"
    view-as alert-box question buttons yes-no update glog.
    if not glog then return no-apply.
    delete tt-ruledict-param.
  end.
  else do:
    if not available X_ruledict-param then return no-apply.
    v-rec = recid(X_ruledict-param).
    message "Вы уверены, что хотите удалить параметр?"
    view-as alert-box question buttons yes-no update glog.
    if not glog then return no-apply.
    run rul/ruledict-param3.p ( input no /*p-silent*/
                        ,input v-rec
                        ) no-error.
 end.
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
if p-list-mode = {&update} then do:
  IF NOT AVAILABLE tt-ruledict-param THEN RETURN NO-APPLY.
end.
else do:
  IF NOT AVAILABLE X_ruledict-param THEN RETURN NO-APPLY.
end.
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
  if p-list-mode = {&update} then do:
    if not available tt-ruledict-param then return no-apply.
    v-rec = recid(tt-ruledict-param).
    run rul/ruledict-param-i.w ( input parparentproc
                        ,input this-procedure:handle /*p-update-proc-handel*/
                        ,input {&lookup}
                        ,input tt-ruledict-param.entry-id
                        ,input p-entry-type
                        ,input tt-ruledict-param.language
                        ,input tt-ruledict-param.param-num
                        ,input-output v-rec) no-error.
  end.
  else do:
    if not available X_ruledict-param then return no-apply.
    v-rec = recid(X_ruledict-param).
    run rul/ruledict-param-i.w ( input parparentproc
                        ,input ? /*p-update-proc-handel*/
                        ,input {&lookup}
                        ,input X_ruledict-param.entry-id
                        ,input '':U /*entry-type*/
                        ,input X_ruledict-param.language
                        ,input X_ruledict-param.param-num
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
if p-list-mode = {&update} then do:
  if available tt-ruledict-param then do:
   { gbl/markstrn.i tt-ruledict-param v-rid-list }
    glog = br-tt-ruledict-param:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        glog = br-tt-ruledict-param:select-next-row ().
        apply "VALUE-CHANGED" to br-tt-ruledict-param in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
end.
else do:
  if available X_ruledict-param then do:
   { gbl/markstrn.i X_ruledict-param v-rid-list }
    glog = br-ruledict-param:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        glog = br-ruledict-param:select-next-row ().
        apply "VALUE-CHANGED" to br-ruledict-param in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.

end.
apply "entry" to br-ruledict-param in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
  v-return-value = "quit".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
if p-list-mode = {&update} then do:
  if available tt-ruledict-param then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( tt-ruledict-param ) ) .
  end.
end.
else do:
  if available X_ruledict-param then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_ruledict-param ) ) .
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_rule-call-param
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_rule-call-param Dialog-Frame
ON CHOOSE OF MENU-ITEM m_rule-call-param /* ЗАДАННЫЕ Параметры */
DO:
if p-list-mode = {&update} then do:
  IF NOT AVAILABLE tt-ruledict-param THEN RETURN NO-APPLY.
end.
else do:
  IF NOT AVAILABLE X_ruledict-param THEN RETURN NO-APPLY.
end.
RUN proc-b-link IN THIS-PROCEDURE ( INPUT {&table_rule-call-param}) NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-ruledict-param
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
ON ROW-DISPLAY OF br-ruledict-param IN frame {&frame-name}
DO:
if p-list-mode = {&update} then do:
  IF AVAIL tt-ruledict-param THEN DO:
    RUN set-row-color IN this-procedure  ( INPUT tt-ruledict-param.param-data-type).
  END.
end.
else do:
  IF AVAIL X_ruledict-param THEN DO:
    RUN set-row-color IN this-procedure  ( INPUT X_ruledict-param.param-data-type).
  END.
end.
END.

{ gbl/brwrefre.i "RUN brwrefre IN THIS-PROCEDURE NO-ERROR." }

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
  if p-list-mode = {&update} then do:
     run fill-tt-ruledict-param in p-update-proc-handle ( input buffer tt-ruledict-param:handle) no-error .
     if error-status:error then do:
       MESSAGE
       substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
       VIEW-AS ALERT-BOX ERROR.
       undo main-block, return error.
     end.
  end.
  v-rid-list = p-rid-list.
  run Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.

END.
RUN disable_UI.
if v-return-value = "quit" then return "quit".

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE brwrefre Dialog-Frame
PROCEDURE brwrefre :
CASE p-list-mode:
  WHEN {&UPDATE} THEN DO:
      v-doc-rec = recid(tt-ruledict-param).
      RUn OpenBR in this-procedure.
      REPOSITION br-tt-ruledict-param to recid v-doc-rec No-ERROR.
      apply 'value-changed' to br-tt-ruledict-param IN FRAME {&FRAME-NAME}.

  END.
  OTHERWISE DO:
    v-doc-rec = recid(X_ruledict-param).
    RUn OpenBR in this-procedure.
    REPOSITION br-ruledict-param to recid v-doc-rec No-ERROR.
    apply 'value-changed' to br-ruledict-param  IN FRAME {&FRAME-NAME}.
  END.
END CASE.
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
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-mark b-sel b-add b-chg b-del b-lkp b-links B-Help
         br-tt-ruledict-param br-ruledict-param mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-ruledict-param Dialog-Frame
PROCEDURE fill-ruledict-param :
define input parameter p-bh as handle no-undo .
define input parameter p-mode as character no-undo .
define variable glog as logical no-undo .
if p-mode = {&add-def} then do:
  assign
  glog = p-bh:buffer-create no-error.
  if error-status:error then do:
    UNDO, RETURN ERROR substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
end.
if p-mode <> {&add-def} then do:
  assign
  glog = p-bh:buffer-copy(buffer tt-ruledict-param:handle) no-error.
  if error-status:error then do:
    UNDO, RETURN ERROR substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
X_ruledict-param.param-label:RESIZABLE IN BROWSE br-ruledict-param = YES
X_ruledict-param.param-name:RESIZABLE IN BROWSE br-ruledict-param = YES
tt-ruledict-param.param-label:RESIZABLE IN BROWSE br-tt-ruledict-param = YES
tt-ruledict-param.param-name:RESIZABLE IN BROWSE br-tt-ruledict-param = YES
b-links:MENU-MOUSE IN FRAME {&FRAME-NAME} = 1.
ENABLE
b-quit
b-exit when (p-list-mode = {&update})
b-add when (lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0)
b-chg when (lookup("b-add", bttns) > 0 and  v-cntxt-db-num = 0)
b-del when (lookup("b-add", bttns) > 0 and  v-cntxt-db-num = 0)
b-lkp
B-Help
b-mark when lookup("b-mark", bttns) > 0
b-sel when lookup("b-sel", bttns) > 0
b-links WHEN (p-entry-id <> 0)
br-ruledict-param when p-list-mode <> {&update}
br-tt-ruledict-param when p-list-mode = {&update}
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
if p-list-mode = {&update} then do:
  hide
  br-ruledict-param
  in frame {&frame-name} .
end.
else do:
  hide
  br-tt-ruledict-param
  b-exit
  in frame {&frame-name} .
  ASSIGN
  b-quit:LABEL = "&Выход"
  b-quit:COLUMN = 1
  .
end.
run OpenBr in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
CASE p-list-mode:
  WHEN {&ALL} THEN DO:
    frame {&frame-name} :title = "Все параметры терминов словаря RULE-машины".
    OPEN QUERY br-ruledict-param
    FOR EACH X_ruledict-param NO-LOCK INDEXED-REPOSITION.
  END.
  WHEN "entry-id" THEN DO:
    frame {&frame-name} :title = substitute("Все параметры для термина RULE-машины &1", p-entry-id).
    OPEN QUERY br-ruledict-param
    FOR EACH X_ruledict-param NO-LOCK WHERE X_ruledict-param.entry-id = p-entry-id INDEXED-REPOSITION.
  END.
  WHEN {&UPDATE} THEN DO:
    frame {&frame-name} :title = substitute("Все параметры для термина RULE-машины &1", p-entry-id).
    OPEN QUERY br-tt-ruledict-param
    FOR EACH tt-ruledict-param NO-LOCK WHERE
            tt-ruledict-param.entry-id = p-entry-id INDEXED-REPOSITION.
  END.
END CASE.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-link Dialog-Frame
PROCEDURE proc-b-link :
define variable v-rid-list as character no-undo .
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
define variable v-rec as recid no-undo .
define variable v-rule-id as integer no-undo .
define variable v-profile-id as integer no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_rp-rule-param for ub.rp-rule-param.
IF p-list-mode = {&UPDATE}
AND p-entry-id = 0 THEN DO:
  MESSAGE
  substitute("Просмотр невозможен&1Термина словаря еще не существует"
             , {&NEW-LINE})
  VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
END.
CASE p-option:
  WHEN {&table_rule-call-param} THEN DO:
    find first buf_ruledict no-lock where
              buf_Ruledict.entry-id = (IF p-list-mode = {&update}
                                       THEN tt-ruledict-param.entry-id
                                       ELSE X_ruledict-param.entry-id ) no-error.
    if not available buf_Ruledict
    or not (buf_ruledict.entry-type = {&rdict-etype-rule}
            or
            buf_ruledict.entry-type = {&rdict-etype-rule-profile}
            )
    then do:
      message
      substitute("Термин словаря не найден или не является термином типа &1&2Просмотр невозможен"
                , {&rdict-etype-rule}
                , {&new-line})
      view-as alert-box error .
      undo, return error .
    end.
    /*найдем все вызорвы rule*/
    for each tt0-rule-call-param:
      delete tt0-rule-call-param.
    end.
    case buf_ruledict.entry-type :
      when {&rdict-etype-rule} then do:
        run gen-key-fv in this-procedure ( input buf_ruledict.uniq-key-rec
                                          ,output v-field-list
                                          ,output v-value-list).
        assign
        v-rule-id = integer(entry(lookup("rule_id":U
                                            , v-field-list
                                            , {&delim-key})
                                      , v-value-list, {&delim-key})).
        for each buf_rule-call-param no-lock where
                buf_Rule-call-param.rule_id = v-rule-id:
          create tt0-rule-call-param.
          buffer-copy buf_rule-call-param to tt0-rule-call-param.
        end.
        run ref/rulercps.w ( INPUT parparentproc
                            ,input this-procedure:handle
                            ,INPUT "":U /*bttns*/
                            ,input {&lookup}
                            ,input {&table_rule-call-param}
                            ,input 0  /*profile_id*/
                            ,input ? /**once-more*/
                            ,input '':U /*p-call-id*/
                            ,input 0 /*p-codex-id*/
                            ,input 0 /*p-ruleset-id*/
                            ,input ? /*order_id*/
                            ,input v-rule-id
                            ,input substitute("Параметры вызова правила &1", v-rule-id)
                            ,input-output table tt0-rule-call-param ) no-error.
      end.
      when {&rdict-etype-rule-profile} then do:
        run gen-key-fv in this-procedure ( input buf_ruledict.uniq-key-rec
                                          ,output v-field-list
                                          ,output v-value-list).
        assign
        v-profile-id = integer(entry(lookup("profile_id":U
                                            , v-field-list
                                            , {&delim-key})
                                      , v-value-list, {&delim-key})).
         for each buf_rp-rule-param no-lock where
                  buf_rp-rule-param.profile_id = v-profile-id
             and  buf_rp-rule-param.rp-param-name = X_ruledict-param.param-name,
            each buf_rule-call-param no-lock where
                buf_Rule-call-param.profile_id = v-profile-id
            and buf_Rule-call-param.codex_id = buf_rp-rule-param.codex_id
            and buf_Rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
            and  buf_rule-call-param.rule_id = buf_rp-rule-param.rule_id
            and  buf_rule-call-param.param-name = buf_rp-rule-param.rule-param-name:
          create tt0-rule-call-param.
          buffer-copy buf_rule-call-param to tt0-rule-call-param.
        end.
        run ref/rulercps.w ( INPUT parparentproc
                            ,input this-procedure:handle
                            ,INPUT "":U /*bttns*/
                            ,input {&lookup}
                            ,input {&table_rp-rule-param} + {&comma-char} + {&all}
                            ,input v-profile-id  /*profile_id*/
                            ,input ? /**once-more*/
                            ,input '':U /*p-call-id*/
                            ,input 0 /*p-codex-id*/
                            ,input 0 /*p-ruleset-id*/
                            ,input ? /*order_id*/
                            ,input 0
                            ,input substitute("Параметры вызова профайла &1 для параметра &2", v-profile-id, IF p-list-mode = {&update}
                                       THEN tt-ruledict-param.param-name else X_ruledict-param.param-name)
                            ,input-output table tt0-rule-call-param ) no-error.
if error-status:error
then
   message return-value error-status:get-message(1)  view-as alert-box.

      end.
    end case.
  END.
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-ruledict-param Dialog-Frame
PROCEDURE save-ruledict-param :
define input parameter p-bh as handle no-undo .
define input parameter p-mode as character no-undo .
define output parameter p-rec as recid no-undo .
define variable glog as logical no-undo .
define variable v-ii as integer no-undo .
define buffer buf_tt-ruledict-param for tt-ruledict-param.
if p-mode = {&add-def} then do:
  do v-ii = 1 to 999999999:
    assign
    glog = buffer buf_tt-ruledict-param:find-first( substitute( "where param-num = &1", v-ii)) no-error.
    if not glog then do:
       leave.
    end.
  end.
  assign
  glog = buffer buf_tt-ruledict-param:buffer-create no-error.
  if error-status:error then do:
    UNDO, RETURN ERROR substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  assign
  glog = buffer buf_tt-ruledict-param:buffer-copy(p-bh) no-error.
  p-rec = recid(buf_tt-ruledict-param).
  buf_tt-ruledict-param.entry-id = p-entry-id.
  buf_tt-ruledict-param.param-num = v-ii.
end.
else do:
  assign
  glog = buffer tt-ruledict-param:buffer-copy(p-bh) no-error.
  p-rec = recid(tt-ruledict-param).
  tt-ruledict-param.entry-id = p-entry-id.
end.
if error-status:error then do:
  UNDO, RETURN ERROR substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color Dialog-Frame
PROCEDURE set-row-color :
DEFINE INPUT PARAMETER p-ruledict-param-type AS character.
DEFINE VARIABLE iFGColor AS INTEGER NO-UNDO.
DEFINE VARIABLE iBGColor AS INTEGER NO-UNDO.

CASE p-ruledict-param-type:
  WHEN {&abl-datatype-integer} THEN DO:
    ASSIGN
    iFGColor = BLUE_COLOR
    iBGColor = WHITE_COLOR
    .
  end.
  when {&abl-datatype-character} then do:
    ASSIGN
    iFGColor = BLACK_COLOR
    iBGColor = WHITE_COLOR
    .
  end.
  when {&abl-datatype-decimal} then do:
    ASSIGN
    iFGColor = GREEN_COLOR
    iBGColor = WHITE_COLOR
    .
  end.
  when {&abl-datatype-date} then do:
    ASSIGN
    iFGColor = GRAY_COLOR
    iBGColor = WHITE_COLOR
    .
  end.
  when {&abl-datatype-logical} then do:
    ASSIGN
    iFGColor = RED_COLOR
    iBGColor = WHITE_COLOR
    .
  end.
  otherwise do:
    ASSIGN
      iFGColor = Black_COLOR
      iBGColor = White_COLOR
    .
  end.
END CASE.
if p-list-mode = {&update} then do:
  ASSIGN
  tt-ruledict-param.param-data-type:FGCOLOR IN BROWSE br-tt-ruledict-param = iFGColor
  tt-ruledict-param.param-data-type:BGCOLOR IN BROWSE br-tt-ruledict-param = iBGColor
  .
end.
else do:
  ASSIGN
  X_ruledict-param.param-data-type:FGCOLOR IN BROWSE br-ruledict-param = iFGColor
  X_ruledict-param.param-data-type:BGCOLOR IN BROWSE br-ruledict-param = iBGColor
  .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME