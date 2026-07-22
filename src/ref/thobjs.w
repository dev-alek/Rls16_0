&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_clients FOR ub.clients.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список объектов ТН

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input        parameter parparentproc     as widget-handle no-undo .
define input        parameter p-callback-handle as handle no-undo .
define input        parameter p-bttns             as character     no-undo . /* список включенных кнопок */
DEFINE INPUT        PARAMETER p-list-mode       AS CHARACTER     NO-UNDO.
/*{&all} {&db} {&company} "cli-type"*/
DEFINE INPUT        PARAMETER p-obj-type        AS character     NO-UNDO.
DEFINE INPUT        PARAMETER p-db-num          AS INTEGER       NO-UNDO.
DEFINE INPUT        PARAMETER p-host-code       AS INTEGER       NO-UNDO.
define input-output parameter p-rid-list        as character     no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список объектов ТН".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i }
{ gbl/thbjattr.i }
{ adm/shattrg.i }
{ gbl/getcntxt.i def }
{ ref/xobjgrp.i  }
{ ref/aobjgrp.i  }
{ ref/pricegrp.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/fltopend.i defproc }

define variable attr-option as character no-undo .
define variable add-option as character no-undo .
define variable cli-attr-option as character no-undo .
define variable v-is-deploy as logical no-undo .
define variable v-rid-list as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-grp as character no-undo .
define variable v-exist-price-grp as logical   no-undo .
define variable sort-column-name as character no-undo.
define variable filter-point     as character NO-UNDO INIT "thobjs".
define variable filter-label     as character NO-UNDO INIT "Объекты TH".
define variable filter-point0     as character NO-UNDO INIT "thobjs".
define variable filter-label0     as character NO-UNDO INIT "Объекты TH".
define variable v-new-selection-flag as logical no-undo .
DEFINE VARIABLE v-list-mode AS CHARACTER NO-UNDO.
define variable v-shop as character no-undo .
define variable v-stock as character no-undo .
DEFINE VARIABLE v-all AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-list-option AS CHARACTER NO-UNDO.

define stream sout.
DEFINE BUFFER buf_db FOR ub.db.
DEFINE BUFFER buf_sysclients FOR ub.clients.
v-shop = {&shop}.
v-stock = {&stock}.
v-all = {&ALL}.

&SCOPED-DEFINE label-clmn_1 '*'
&SCOPED-DEFINE sort-clmn_1 mark-string(recid(X_clients), v-rid-list)
&SCOPED-DEFINE dyn_sort-clmn_1 substitute('dynamic-function(&1mark-string&1, recid(X_clients), &1&2&1)', ~{&double-quote~}, v-rid-list)
&SCOPED-DEFINE label-clmn_6 'Фирма'
&scoped-define sort-clmn_7 (if X_clients.stts = 0 then ' ' else '+' )
&scoped-define dyn_sort-clmn_7 substitute('(if X_clients.stts = 0 then &1&2&1 else &1&3&1)', ~{&double-quote~}, ~{&space-char~}, '+')
&SCOPED-DEFINE label-clmn_7 'Удал'

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-objects

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_clients

/* Definitions for BROWSE br-objects                                    */
&Scoped-define FIELDS-IN-QUERY-br-objects {&sort-clmn_1} X_clients.obj-type X_clients.obj-code X_clients.obj-name X_clients.host-code get-host-name(INPUT X_clients.host-code) {&sort-clmn_7} X_clients.db-num get-shift-on ( INPUT X_clients.obj-type, INPUT X_clients.obj-code) X_clients.grp-name price-grp ( buffer X_clients ) @ v-grp
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-objects X_clients.grp-name
&Scoped-define ENABLED-TABLES-IN-QUERY-br-objects X_clients
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-objects X_clients
&Scoped-define SELF-NAME br-objects
&Scoped-define QUERY-STRING-br-objects FOR EACH X_clients NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-objects OPEN QUERY {&SELF-NAME} FOR EACH X_clients NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-objects X_clients
&Scoped-define FIRST-TABLE-IN-QUERY-br-objects X_clients


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-objects}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-add B-lkp B-chg B-del ~
B-attr B-right b-sch B-print B-hist B-Help B-list sch-code B-cli-attr ~
B-price B-dis-rule B-grp rs-cli-type f-host-code B-host f-host-name ~
f-db-num B-db f-db-name br-objects mark-num
&Scoped-Define DISPLAYED-OBJECTS sch-code rs-cli-type f-host-code ~
f-host-name f-db-num f-db-name mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-host-name Dialog-Frame
FUNCTION get-host-name RETURNS CHARACTER
  ( INPUT p-host-code AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-shift-on Dialog-Frame
FUNCTION get-shift-on RETURNS LOGICAL
  ( INPUT p-obj-type AS CHARACTER, INPUT p-obj-code AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
( input p-recid as recid, input mark-list as character  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-add
       MENU-ITEM m_add-shop     LABEL "Магазин"
       MENU-ITEM m_add-store    LABEL "Склад"         .

DEFINE MENU MENU-B-attr
       MENU-ITEM m_lookup       LABEL "&Просмотр"
       MENU-ITEM m_update       LABEL "&Изменение"
       MENU-ITEM m_copy         LABEL "&Копирование"
       RULE
       MENU-ITEM m_price-grp    LABEL "Группа &ценообразования".

DEFINE MENU MENU-B-cli-attr
       MENU-ITEM m_lookup-cli   LABEL "&Просмотр"
       MENU-ITEM m_update-cli   LABEL "&Изменение"    .

DEFINE MENU MENU-B-list
       MENU-ITEM m_list-export  LABEL "Сохранить"
       MENU-ITEM m_list-import  LABEL "Загрузить"
       RULE
       MENU-ITEM m_list-export-db LABEL "Сохранить в хранимом списке"
       MENU-ITEM m_list-import-db LABEL "Загрузить из хранимого списка".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-attr
     LABEL "&Параметры"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-cli-attr
     LABEL "&Атрибуты"
     SIZE 10 BY 1.

DEFINE BUTTON B-db
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-dis-rule
     LABEL "&Скидки"
     SIZE 10 BY 1.

DEFINE BUTTON B-grp
     LABEL "&Группа"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON B-host
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-list
     LABEL "С&писок"
     SIZE 10 BY 1.

DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-price
     LABEL "&Цены"
     SIZE 10 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-right
     LABEL "&Права"
     SIZE 10 BY 1.

DEFINE BUTTON b-sch
     LABEL "Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE f-db-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE f-db-num AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "БД"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE f-host-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Фирма"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE f-host-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 10 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sch-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Код"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE rs-cli-type AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1"
     SIZE 17 BY .8 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-objects FOR
      X_clients SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-objects
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-objects Dialog-Frame _FREEFORM
  QUERY br-objects NO-LOCK DISPLAY
      {&sort-clmn_1} Format "X(1)" COLUMN-LABEL {&label-clmn_1}
X_clients.obj-type COLUMN-LABEL "Тип " FORMAT "X(3)"
X_clients.obj-code COLUMN-LABEL "Код " FORMAT ">>>>>>>>9"
X_clients.obj-name COLUMN-LABEL "Название " FORMAT "x(80)" width 25
X_clients.host-code COLUMN-LABEL "Код фирмы " FORMAT ">>>>>>>>9"
get-host-name(INPUT X_clients.host-code) COLUMN-LABEL {&label-clmn_6} FORMAT "x(80)" width 25
{&sort-clmn_7} format "x(1)" column-label {&label-clmn_7}
X_clients.db-num COLUMN-LABEL "БД"
get-shift-on ( INPUT X_clients.obj-type, INPUT X_clients.obj-code) COLUMN-LABEL "Смены":L format " + / - "
X_clients.grp-name COLUMN-LABEL "Группа" format "X(255)" width 25
price-grp ( buffer X_clients ) @ v-grp COLUMN-LABEL "Группа ценообразования" FORMAT "x(80)" width 25
ENABLE
X_clients.grp-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 19 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11 WIDGET-ID 16
     B-sel AT ROW 1 COL 14 WIDGET-ID 20
     B-add AT ROW 1 COL 24 WIDGET-ID 4
     B-lkp AT ROW 1 COL 34 WIDGET-ID 14
     B-chg AT ROW 1 COL 44 WIDGET-ID 6
     B-del AT ROW 1 COL 54 WIDGET-ID 8
     B-attr AT ROW 1 COL 64 WIDGET-ID 26
     B-right AT ROW 1 COL 74 WIDGET-ID 24
     b-sch AT ROW 1 COL 86 WIDGET-ID 40
     B-print AT ROW 1 COL 89 WIDGET-ID 18
     B-hist AT ROW 1 COL 92 WIDGET-ID 12
     B-Help AT ROW 1 COL 95
     B-list AT ROW 2 COL 14 WIDGET-ID 54
     sch-code AT ROW 2 COL 27.5 COLON-ALIGNED WIDGET-ID 36
     B-cli-attr AT ROW 2 COL 54 WIDGET-ID 32
     B-price AT ROW 2 COL 64 WIDGET-ID 30
     B-dis-rule AT ROW 2 COL 74 WIDGET-ID 28
     B-grp AT ROW 2 COL 84 WIDGET-ID 34
     rs-cli-type AT ROW 2.08 COL 36.5 NO-LABEL WIDGET-ID 38
     f-host-code AT ROW 3 COL 7 COLON-ALIGNED WIDGET-ID 46
     B-host AT ROW 3 COL 15.5 WIDGET-ID 48
     f-host-name AT ROW 3 COL 17 COLON-ALIGNED NO-LABEL WIDGET-ID 50
     f-db-num AT ROW 3 COL 51 COLON-ALIGNED WIDGET-ID 42
     B-db AT ROW 3 COL 59.5 WIDGET-ID 44
     f-db-name AT ROW 3 COL 63.5 COLON-ALIGNED NO-LABEL WIDGET-ID 52
     br-objects AT ROW 4 COL 1 WIDGET-ID 100
     mark-num AT ROW 2 COL 1.5 NO-LABEL WIDGET-ID 22
     SPACE(88.20) SKIP(20.22)
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
      TABLE: X_clients B "?" ? ub clients
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-objects f-db-name Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add:HANDLE.

ASSIGN
       B-attr:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-attr:HANDLE.

ASSIGN
       B-cli-attr:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-cli-attr:HANDLE.

ASSIGN
       B-list:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-list:HANDLE.

ASSIGN
       f-db-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       f-db-num:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       f-host-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       f-host-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-objects
/* Query rebuild information for BROWSE br-objects
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_clients NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-objects */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
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


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
if add-option = '':U then do:
   run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
IF add-option = '' THEN RETURN NO-APPLY.
RUN proc-b-add IN THIS-PROCEDURE NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
    add-option = ''.
    RETURN no-apply.
END.
add-option = ''.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr Dialog-Frame
ON CHOOSE OF B-attr IN FRAME Dialog-Frame /* Параметры */
DO:
define variable v-param as character no-undo .
define variable v-db-num like ub.db.db-num no-undo .
if not available X_clients then return no-apply.
if attr-option = '':U then do:
   run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if attr-option = '':U then return no-apply.
if attr-option = {&update}
or attr-option = {&add-copy}
then do:
  if v-cntxt-db-num <> 0
  then do:
    { gbl/objdbnum.i X_clients.obj-type X_clients.obj-code v-db-num }
    if v-db-num <> v-cntxt-db-num then do:
      message
      "Нельзя менять ПАРАМЕТРЫ в чужой УБД"
      view-as alert-box error .
      return no-apply.
    end.
  end.
end.
run proc-b-attr in this-procedure (
                                    input attr-option
                                   ,input X_clients.obj-type
                                   ,input X_clients.obj-code) no-error .
if error-status:error then do:
  assign
  attr-option = "":u.
  return no-apply.
end.
attr-option = "":u.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  define variable ri as recid no-undo.
  if available X_clients then do:
    CASE X_clients.obj-type:
      WHEN {&shop} THEN DO:
          ri = recid (X_clients).
          run adm/shopi.w ( input parparentproc
                           ,input  X_clients.host-code
                           ,input X_clients.obj-code
                           ,INPUT {&update}
                           ,input-output ri).
          display
          X_clients.obj-name
          X_clients.grp-name
          with browse br-objects.

      END.
      WHEN {&stock} THEN DO:
      ri = recid (X_clients).
      run adm/storei.w ( input parparentproc
                        ,input v-cntxt-host-code-obj
                        ,input X_clients.obj-code
                        ,input {&update}
                        ,input-output ri).
      display
      X_clients.obj-name
      X_clients.grp-name
      with browse br-objects.

      END.
    END CASE.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cli-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cli-attr Dialog-Frame
ON CHOOSE OF B-cli-attr IN FRAME Dialog-Frame /* Атрибуты */
DO:
 define variable v-updated as logical no-undo .
 define variable v-is-error as logical no-undo .
 define variable v-db-num as integer no-undo .
 define variable ri as recid no-undo .
  if not available X_clients then do:
    return no-apply.
  end.
  ri = recid(X_clients).
  if cli-attr-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if cli-attr-option = "":U then do:
      return no-apply.
  end.
  if cli-attr-option = {&update}
  or cli-attr-option = {&add-copy} then do:
    if v-cntxt-db-num > 0 then do:
      { gbl/objdbnum.i X_clients.obj-type X_clients.obj-code v-db-num }
      if v-db-num <> v-cntxt-db-num then do:
        message
        "Нельзя менять АТРИБУТЫ в чужой УБД"
        view-as alert-box error .
        return no-apply.
      end.
    end.
  end.
  run ref/ca-attrr.p (
                    input parparentproc
                   ,input (if lookup("b-add", p-bttns) > 0
                          AND cli-attr-option = {&update}
                          then {&update}
                          else {&lookup})
                   ,input X_clients.obj-type
                   ,input X_clients.obj-code
                   ,input yes /*p-update-on-exit*/
                   ,output v-updated
                   ,output v-is-error
                   ) no-error.
  if error-status:error
  or v-is-error then do:
    message
    "Ошибка при вызове списка атрибутов клиента" skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box .
    assign
    cli-attr-option = "":U
    .
    undo, return no-apply.
  end.
  cli-attr-option = "":U.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-db Dialog-Frame
ON CHOOSE OF B-db IN FRAME Dialog-Frame
DO:
  run proc-b-db IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  IF NOT AVAILABLE X_clients THEN RETURN NO-APPLY.
  run proc-b-del in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-dis-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-dis-rule Dialog-Frame
ON CHOOSE OF B-dis-rule IN FRAME Dialog-Frame /* Скидки */
DO:
define variable v-sts as integer no-undo .
define variable v-loc-rid-list as character no-undo .
if not available X_clients then return no-apply.
assign
v-sts = integer({&used-status-int}).
run ref/dis-ruls.w (
              input parparentproc
            , input 0 /*p-host-code*/
            , input X_clients.obj-type
            , input X_clients.obj-code
            , input "b-add":U
            , input "cli-type"
            , input 0       /*p-upper-rule-num*/
            , input ?       /*p-time-templ-rl-root*/
            , input 0 /*p-r-b-code*/
            , input-output v-sts
            , input-output v-loc-rid-list ) no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-grp Dialog-Frame
ON CHOOSE OF B-grp IN FRAME Dialog-Frame /* Группа */
DO:
define variable lns-cnt as integer no-undo .
define variable g-grp as character no-undo .
define variable v-gds-rec as recid no-undo.
define variable ri as recid no-undo .
define variable glog as logical no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_cli-grp for ub.cli-grp.
if not available X_clients then return no-apply.
ri = recid(X_clients).
glog = yes.
message
"Выберите группу, в которую нужно" skip
"переместить объект(-ы)."
view-as alert-box question buttons OK-Cancel update glog.
if not glog then   do:
  apply "entry" to br-objects in frame {&frame-name}.
  return no-apply.
end.
g-grp = "".
run ref/cli-grps.w (
                   input parparentproc
                 , input {&g#term} + ",b-sel"
                 , input-output g-grp ) .
if g-grp = "" then  do:
  apply "ENTRY" to br-objects.
  return no-apply.
end.
else do transaction:
    FIND buf_cli-grp where recid( buf_cli-grp ) = integer( g-grp ) .
    if v-rid-list = "" then
    v-rid-list = string( recid( X_clients) ) .
    lns-cnt = 1.
    DO WHILE lns-cnt <= num-entries( v-rid-list ) :
      v-gds-rec = integer( entry( lns-cnt, v-rid-list ) ) .
      if lns-cnt = 1 then ri = v-gds-rec.
       FOR FIRST buf_clients WHERE RECID(buf_clients) = v-gds-rec
      on error  undo , next
      on stop   undo , next
      on endkey undo , next
      :
        buf_clients.grp-code = buf_cli-grp.node-code.
        lns-cnt = lns-cnt + 1.
      end.
    END .
    if lns-cnt < num-entries(v-rid-list) + 1 then do:
      message
      substitute("Удалось сменить группу для &1 объектов", lns-cnt - 1)
      view-as alert-box error.
    end.
    v-rid-list = "".
    mark-num = 0.
    hide mark-num in frame {&frame-name}.
end. /*end transaction*/
run Openbr in this-procedure ( input yes, input no, input '':U).
reposition br-objects to recid ri no-error.
apply "ENTRY" to br-objects.
apply "value-changed" to br-objects.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
   define variable v-loc-rid-list as character no-undo .
  if not available X_clients then return no-apply.
     run ref/cclihist.w (
                      input parparentproc
                    , input 0 /*p-curr-host-code*/
                    , input "":U  /*p-curr-obj-type*/
                    , input 0  /*p-curr-obj-code*/
                    , input "":U /*bttns*/
                    , input "one":U /*p-mode*/
                    , input X_clients.obj-type /*p-obj-type*/
                    , input X_clients.obj-code /*p-obj-code*/
                    , input ? /*p-host-code*/
                    , input ? /* p-corr-user-db-num  */
                    , input "":U /* p-corr-user-name  */
                    , input "":U /* p-subject  */
                    , input v-cntxt-db-num /* p-db-num */
                    , input-output v-loc-rid-list  ) no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-host
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-host Dialog-Frame
ON CHOOSE OF B-host IN FRAME Dialog-Frame
DO:
  run proc-b-host IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-list Dialog-Frame
ON CHOOSE OF B-list IN FRAME Dialog-Frame /* Список */
DO:
  if v-list-option = ""
  then do:
    run gbl/pop-up.p (self:handle, no) no-error.
    if error-status:error then return no-apply.
  end.
  if v-list-option = ""
  then do:
    return no-apply.
  end.
  run proc-b-list in this-procedure
    (input v-list-option
    ) no-error.
  if error-status :error
  then do:
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp Dialog-Frame
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
if not available X_clients then return no-apply.

 run ref/showcli.p (
     input parParentProc
    ,input X_clients.obj-type /* p-obj-type */
    ,input X_clients.obj-code /* p-obj-code */
    ).

apply "entry" to br-objects in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
 if v-new-selection-flag then do:
    run choose-mark in this-procedure  no-error .
    if error-status :error
    then do:
      return no-apply .
    end.
  end.
  if available X_clients then do:
    if not v-new-selection-flag then do:
    { gbl/markstrn.i X_clients v-rid-list }
    end.
    loc#log = br-objects:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-objects:select-next-row ().
        apply "VALUE-CHANGED" to br-objects in frame {&frame-name}.
    end.
    if not v-new-selection-flag then do:
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  end.
  apply "entry" to br-objects in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-price
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-price Dialog-Frame
ON CHOOSE OF B-price IN FRAME Dialog-Frame /* Цены */
DO:
  if not available X_clients then return no-apply.
  define variable v-rec-list as character no-undo .
  run str/pdfobj.w
        ( input parparentproc
         ,input "all"
         ,input X_clients.obj-type
         ,input X_clients.obj-code
         ,input ?
         ,input ?
         ,input "b-add,b-del,b-chg"
         ,input-output v-rec-list
          ) no-error.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run rep/obj-prt.p ( input parparentproc) NO-ERROR.
  APPLY "ENTRY" to br-objects.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-right
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-right Dialog-Frame
ON CHOOSE OF B-right IN FRAME Dialog-Frame /* Права */
DO:
  IF AVAILABLE X_clients THEN DO:

       run adm/obj-usr.w
      (input  parparentproc
      ,input  v-cntxt-db-num
      ,input  X_clients.obj-type
      ,input  X_clients.obj-code
      ).

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available X_clients ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive in frame {&frame-name} = no
    then
    v-rid-list = string( recid( X_clients ) ) .
    if v-new-selection-flag then do:
      run choose-select in this-procedure  no-error .
      if error-status :error
      then do:
        undo, return no-apply .
      end.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-objects
&Scoped-define SELF-NAME br-objects
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-objects Dialog-Frame
ON RETURN OF br-objects IN FRAME Dialog-Frame
OR MOUSE-SELECT-DBLCLICK of br-objects in frame {&frame-name} DO:

  if b-sel:sensitive then
    if b-mark:sensitive then apply "choose" to b-mark in frame {&frame-name}.
    else apply "choose" to b-sel in frame {&frame-name}.
  else if b-chg:sensitive then apply "choose" to b-chg in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_add-shop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_add-shop Dialog-Frame
ON CHOOSE OF MENU-ITEM m_add-shop /* Магазин */
DO:
  assign
  add-option = {&shop}.
  APPLY "CHOOSE" to b-add  in frame {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_add-store
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_add-store Dialog-Frame
ON CHOOSE OF MENU-ITEM m_add-store /* Склад */
DO:
  assign
  add-option = {&stock}.
  APPLY "CHOOSE" to b-add  in frame {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_copy Dialog-Frame
ON CHOOSE OF MENU-ITEM m_copy /* Копирование */
DO:
  assign
  attr-option = {&add-copy}.
  APPLY "CHOOSE" to b-attr  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_list-export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_list-export Dialog-Frame
ON CHOOSE OF MENU-ITEM m_list-export /* Сохранить */
DO:
  assign
    v-list-option = "save":U
  .
  run proc-b-list
    (input v-list-option
    ) no-error.
  if error-status :error
  then do:
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_list-export-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_list-export-db Dialog-Frame
ON CHOOSE OF MENU-ITEM m_list-export-db /* Сохранить в хранимом списке */
DO:
  assign
    v-list-option = "save-clob":U
  .
  run proc-b-list
    (input v-list-option
    ) no-error.
  if error-status :error
  then do:
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_list-import
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_list-import Dialog-Frame
ON CHOOSE OF MENU-ITEM m_list-import /* Загрузить */
DO:
  assign
    v-list-option = "load":U
  .
  run proc-b-list in this-procedure
    (input v-list-option
    ) no-error.
  if error-status :error
  then do:
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_list-import-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_list-import-db Dialog-Frame
ON CHOOSE OF MENU-ITEM m_list-import-db /* Загрузить из хранимого списка */
DO:
  assign
    v-list-option = "load-clob":U
  .
  run proc-b-list in this-procedure
    (input v-list-option
    ) no-error.
  if error-status :error
  then do:
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_lookup Dialog-Frame
ON CHOOSE OF MENU-ITEM m_lookup /* Просмотр */
DO:
  assign
  attr-option = {&lookup}.
  APPLY "CHOOSE" to b-attr  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_lookup-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_lookup-cli Dialog-Frame
ON CHOOSE OF MENU-ITEM m_lookup-cli /* Просмотр */
DO:
  assign
  cli-attr-option = {&lookup}.
  APPLY "CHOOSE" to b-cli-attr  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_price-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_price-grp Dialog-Frame
ON CHOOSE OF MENU-ITEM m_price-grp /* Группа ценообразования */
DO:
  run ref/c-tppr.p
   ( input parParentProc,
     input x_clients.obj-type ,
     input x_clients.obj-code ).
  v-exist-price-grp = true .
  run metod-gop-obj-all (input v-cntxt-db-num) .
  v-grp:visible in browse br-objects = true  .
  run enable_UI.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_update
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_update Dialog-Frame
ON CHOOSE OF MENU-ITEM m_update /* Изменение */
DO:
  assign
  attr-option = {&update}.
  APPLY "CHOOSE" to b-attr  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_update-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_update-cli Dialog-Frame
ON CHOOSE OF MENU-ITEM m_update-cli /* Изменение */
DO:
  assign
  cli-attr-option = {&update}.
  APPLY "CHOOSE" to b-cli-attr  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-cli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-cli-type Dialog-Frame
ON VALUE-CHANGED OF rs-cli-type IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-cli-type.
  RUN Openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* Код */
DO:

    run proc-find-code in this-procedure ( input YES, input frame {&frame-name} sch-code) no-error.
    if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame /* Код */
DO:
run proc-find-code in this-procedure ( input no, input frame {&frame-name} sch-code) no-error.
if error-status:error then return no-apply.

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
{ gbl/setfltnm.i }
{ ref/cli-allh.i def }
{ ref/cli-allh.i procedures }

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }

{ gbl/brwrefre.i " v-doc-rec = recid(X_clients).  ~
  run OpenBR in this-procedure ( input yes, input no, input '':U).   REPOSITION br-objects to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to br-objects. " }

{ gbl/brwrepos.i
  &line-num=5
  &browse-name=br-objects
}

{ gbl/srt-clmd.i
  &browse-name     = "br-objects"
  &frame-name      = "{&frame-name}"
  &table-name      = "X_clients"
  &label-clmn_1    = "{&label-clmn_1}"
  &sort-clmn_1     = "{&sort-clmn_1}"
  &dyn_sort-clmn_1 = "{&dyn_sort-clmn_1}"
  &sort-clmn_2     = "X_clients.obj-type"
  &sort-clmn_3     = "X_clients.obj-code"
  &sort-clmn_4     = "X_clients.obj-name"
  &sort-clmn_5     = "X_clients.host-code"
  &label-clmn_7    = "{&label-clmn_7}"
  &sort-clmn_7     = "{&sort-clmn_7}"
  &dyn_sort-clmn_7 = "{&dyn_sort-clmn_7}"
  &sort-clmn_8     = "X_clients.db-num"
  &sort-clmn_10    = "X_clients.grp-name"
  &open-query      = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "no"
  &mv-brw-default = "no"
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i GET }
  IF LOOKUP(p-list-mode, {&ALL} + {&comma-char} +
                         "db" + {&comma-char} +
                          {&company} + {&comma-char} +
                         "cli-type") = 0  THEN DO:
     MESSAGE
     SUBSTITUTE("Неверное значение параметра p-list-mode = &1", p-list-mode)
     VIEW-AS ALERT-BOX ERROR.
     undo, RETURN ERROR.
  END.
  IF p-list-mode = "db" THEN DO:
     FIND FIRST buf_db WHERE buf_db.db-num = p-db-num NO-ERROR.
     IF NOT AVAILABLE buf_db THEN DO:
         MESSAGE
         substitute("Неверное значение параметра p-db-num = &1", p-db-num)
         VIEW-AS ALERT-BOX ERROR.
       undo, RETURN ERROR.
     END.
  END.
  ELSE DO:
    p-db-num = ?.
  END.
  IF p-list-mode = {&company} THEN DO:
     IF NOT CAN-FIND(FIRST ub.sysconf WHERE ub.sysconf.host-code = p-host-code) THEN DO:
         MESSAGE
         substitute("Неверное значение параметра p-host-code = &1", p-host-code)
         VIEW-AS ALERT-BOX ERROR.
              undo, RETURN ERROR.
     END.
     FIND FIRST buf_sysclients NO-LOCK WHERE
               buf_sysclients.obj-type = {&cmp}
        AND    buf_sysclients.obj-code = p-host-code.
  END.
  ELSE DO:
     p-host-code = ?.
  END.
  IF p-list-mode = "cli-type" THEN DO:
     IF NOT (p-obj-type = {&shop}
             OR p-obj-type = {&stock} ) THEN DO:
        MESSAGE
         substitute("Неверное значение параметра p-oj-type = &1", p-obj-type)
         VIEW-AS ALERT-BOX ERROR.
             undo, RETURN ERROR.
     END.
  END.
  ELSE DO:
    p-obj-type = {&ALL}.
  END.
  if lookup('s-deploy', p-bttns) > 0 then do:
    assign
    v-is-deploy = yes.
  end.
  v-exist-price-grp = false  .
  v-rid-list = p-rid-list.
  v-list-mode = p-list-mode.
  f-host-code = p-host-code.
  f-db-num = p-db-num.
  RUN Myenable IN THIS-PROCEDURE.
  { gbl/mv-clmn.i
    &browse-name = "br-objects"
    &frame-name = "{&frame-name}"
    &ext-col = 11
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11'"
    &prev-order-column-condition_1 = " p-list-mode = {&all} "
    }


  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb_fill-lob-res-list Dialog-Frame
PROCEDURE cb_fill-lob-res-list :
define input  parameter p-full-path as character no-undo .
define buffer buf_temp-user-obj for temp-user-obj.
output stream sout to value (p-full-path).
for each buf_temp-user-obj
on error undo, return error return-value
:
  export stream sout
  buf_temp-user-obj.obj-type
  buf_temp-user-obj.obj-code
  .
end.
output stream sout close.
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
  DISPLAY sch-code rs-cli-type f-host-code f-host-name f-db-num f-db-name
          mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-add B-lkp B-chg B-del B-attr B-right b-sch
         B-print B-hist B-Help B-list sch-code B-cli-attr B-price B-dis-rule
         B-grp rs-cli-type f-host-code B-host f-host-name f-db-num B-db
         f-db-name br-objects mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-ch0 AS HANDLE NO-UNDO.
CASE p-list-mode:
  WHEN "db" THEN do:
    f-db-num = p-db-num.
    f-db-name = buf_db.db-name.
  END.
  WHEN {&company} THEN do:
    f-host-code = p-host-code.
    f-host-name = buf_sysclients.obj-name.
  END.
  WHEN "cli-type" THEN DO:
    rs-cli-type = p-obj-type.
  END.
END CASE.
ASSIGN
v-ch0 = br-objects:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
REPEAT WHILE valid-handle(v-ch0):
  IF v-ch0:LABEL = {&label-clmn_6} THEN DO:
    v-ch0:resizable = yes.
    leave.
  END.
  v-ch0 = v-ch0:NEXT-COLUMN.
END.
rs-cli-type:RADIO-BUTTONS IN FRAME {&FRAME-NAME} = {&all} + {&comma-char} + {&all} + {&comma-char} +
                                                   {&shop} + {&comma-char} + {&shop} + {&comma-char} +
                                                   {&stock} + {&comma-char} + {&stock}.
rs-cli-type = {&all}.
v-grp:VISIBLE IN BROWSe br-objects = v-exist-price-grp .
ASSIGN
B-attr:POPUP-MENU IN FRAME {&frame-name}       = MENU MENU-B-attr:HANDLE
b-attr:MENU-MOUSE in frame {&frame-name} = 1
B-cli-attr:POPUP-MENU IN FRAME {&frame-name}       = MENU MENU-B-cli-attr:HANDLE
b-cli-attr:MENU-MOUSE in frame {&frame-name} = 1
b-list:menu-mouse in frame {&frame-name} = 1
X_clients.obj-name:resizable  in browse br-objects = true
X_clients.grp-name:resizable  in browse br-objects = true
X_clients.grp-name:read-only  in browse br-objects = true
v-grp:resizable  in browse br-objects = true
.
assign
menu-item m_update:sensitive in menu menu-b-attr = (v-cntxt-db-num = 0 and can-do (p-bttns, "b-add") AND NOT TRANSACTION)
menu-item m_copy:sensitive in menu menu-b-attr = (v-cntxt-db-num = 0 and can-do (p-bttns, "b-add") AND NOT TRANSACTION)
menu-item m_update-cli:sensitive in menu menu-b-cli-attr = (v-cntxt-db-num = 0 and can-do (p-bttns, "b-add") AND NOT TRANSACTION)
.

DISPLAY
sch-code
rs-cli-type
mark-num
f-host-code
f-host-name
f-db-num
f-db-name
WITH FRAME {&frame-name}.
ENABLE
b-quit
B-mark WHEN LOOKUP("b-mark", p-bttns) > 0
B-sel  WHEN LOOKUP("b-sel", p-bttns) > 0
b-add WHEN v-cntxt-db-num = 0 and can-do (p-bttns, "b-add") AND NOT TRANSACTION
b-chg WHEN v-cntxt-db-num = 0 and can-do (p-bttns, "b-add") AND NOT TRANSACTION
b-del WHEN v-cntxt-db-num = 0 and can-do (p-bttns, "b-add") AND NOT TRANSACTION
b-grp WHEN v-cntxt-db-num = 0 and can-do (p-bttns, "b-add") AND NOT TRANSACTION
b-list when LOOKUP("b-mark", p-bttns) > 0
B-lkp
B-attr  when not v-is-deploy
B-right
B-print when not v-is-deploy
B-hist  when not v-is-deploy
B-Help
sch-code
b-cli-attr when not v-is-deploy
B-price
B-dis-rule  when not v-is-deploy
b-sch
rs-cli-type when p-list-mode <> "cli-type"
b-db WHEN p-list-mode <> "db"
b-host WHEN p-list-mode <> {&company}
br-objects
WITH FRAME {&frame-name}.
VIEW FRAME {&FRAME-NAME}.
/* запрашиваем список объектов */
if (lookup("b-mark", p-bttns) > 0
or  lookup("b-mark-hidden", p-bttns) > 0)
and valid-handle(p-callback-handle)
and lookup( "userobjs_transfer", p-callback-handle:internal-entries ) > 0
then do:
  v-new-selection-flag = yes.
  run userobjs_transfer in p-callback-handle
    (input this-procedure :handle
    ) .

  run display-select-num in this-procedure .
end.
else do:
  hide mark-num in frame {&frame-name}.
end.
RUN Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo init "Объекты TH".

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
&scop flt-open-debug-file

&scop flt-open-open-query         OPEN QUERY br-objects FOR EACH X_clients no-lock

&scop flt-open-dyn_open-query     FOR EACH X_clients no-lock


&scop flt-open-query-handle      QUERY br-objects:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened   l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point         filter-point

&scop flt-open-set-filter-name    set-filter-name

&scop flt-open-indexed-reposition INDEXED-REPOSITION

&scop flt-open-waitfram yes

filter-point = filter-point0 + v-list-mode .

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_clients

&scop flt-open-query p-open-query

&scop flt-open-table-name X_clients

&scop flt-open-debug-file kkk.txt

case v-list-mode:
  when {&all} then do:
    ASSIGN
    frame {&frame-name}:title = substitute("&1", title0)
    filter-label = SUBSTITUTE("&1"
                              , frame {&frame-name}:title
                              )
    .
   end.
   when "db" then do:
    ASSIGN
    frame {&frame-name}:title = substitute("&1 - БД &2", title0, p-db-num)
    filter-label = SUBSTITUTE("&1"
                              , frame {&frame-name}:title
                              )
    .

   end.
   when {&company} then do:
    ASSIGN
    frame {&frame-name}:title = substitute("&1 - Фирма &2", title0, p-host-code)
    filter-label = SUBSTITUTE("&1"
                              , frame {&frame-name}:title
                              )
    .

   end.
   when "cli-type" then do:
    ASSIGN
    frame {&frame-name}:title = substitute("&1 - &2", title0, p-obj-type)
    filter-label = SUBSTITUTE("&1"
                              , frame {&frame-name}:title
                              )
    .

   end.


end case.
if f-db-num = ? then do:
  if f-host-code = ? then do:
  { gbl/fltopend.i
    &where-cond = "((rs-cli-type = {&all} and (X_clients.obj-type = {&shop} or X_clients.obj-type = {&stock}) ) ~
                    OR X_clients.obj-type = rs-cli-type) "
    &dyn_where-cond = " substitute(' ((&7&1&7 = &7&4&7 and (X_clients.obj-type = &7&5&7 or X_clients.obj-type = &7&6&7) ) ~
                    OR X_clients.obj-type = &7&1&7)' ~
                  , rs-cli-type , f-db-num, f-host-code, ~{&all~}, ~{&shop~}, ~{&stock~}, ~{&double-quote~}) "

    &use-ind    = "  "
    &by         = "  " }
  end.
  else do:
  { gbl/fltopend.i
    &where-cond = "((rs-cli-type = {&all} and (X_clients.obj-type = {&shop} or X_clients.obj-type = {&stock}) ) ~
                    OR X_clients.obj-type = rs-cli-type) and ~
                    X_clients.host-code = f-host-code "
    &dyn_where-cond = " substitute(' ((&7&1&7 = &7&4&7 and (X_clients.obj-type = &7&5&7 or X_clients.obj-type = &7&6&7) ) ~
                    OR X_clients.obj-type = &7&1&7) and ~
                    X_clients.host-code = &3 '~
                  , rs-cli-type , f-db-num, f-host-code, ~{&all~}, ~{&shop~}, ~{&stock~}, ~{&double-quote~}) "

    &use-ind    = "  "
    &by         = "  " }

  end.
end. /*if f-db-num = ? then do:*/
else do:
  if f-host-code = ? then do:
    { gbl/fltopend.i
    &where-cond = "((rs-cli-type = {&all} and (X_clients.obj-type = {&shop} or X_clients.obj-type = {&stock}) ) ~
                    OR X_clients.obj-type = rs-cli-type) and ~
                    X_clients.db-num = f-db-num "
    &dyn_where-cond = " substitute(' ((&7&1&7 = &7&4&7 and (X_clients.obj-type = &7&5&7 or X_clients.obj-type = &7&6&7) ) ~
                    OR X_clients.obj-type = &7&1&7) and ~
                    X_clients.db-num = &2' ~
                  , rs-cli-type , f-db-num, f-host-code, ~{&all~}, ~{&shop~}, ~{&stock~}, ~{&double-quote~}) "

    &use-ind    = "  "
    &by         = "  " }
  end.
  else do:
    { gbl/fltopend.i
    &where-cond = "((rs-cli-type = {&all} and (X_clients.obj-type = {&shop} or X_clients.obj-type = {&stock}) ) ~
                    OR X_clients.obj-type = rs-cli-type) and ~
                    X_clients.db-num = f-db-num and ~
                    X_clients.host-code = f-host-code "
    &dyn_where-cond = " substitute(' ((&7&1&7 = &7&4&7 and (X_clients.obj-type = &7&5&7 or X_clients.obj-type = &7&6&7) ) ~
                    OR X_clients.obj-type = &7&1&7) and ~
                    X_clients.db-num = &2 and ~
                    X_clients.host-code = &3' ~
                  , rs-cli-type , f-db-num, f-host-code, ~{&all~}, ~{&shop~}, ~{&stock~}, ~{&double-quote~}) "

    &use-ind    = "  "
    &by         = "  " }

  end.
end. /*else if f-db-num = ? then do:*/
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-objects to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-objects:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-objects in frame {&frame-name}.
APPLY "ENTRY" TO br-objects.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
define variable ri as recid no-undo.
define buffer buf_clients for ub.clients.
CASE p-obj-type:
  WHEN {&shop} THEN DO:
  run adm/shopi.w ( input parparentproc
                   ,input v-cntxt-host-code-obj
                   ,input 0
                   ,input {&add-def}
                   ,input-output ri).
  if ri <> ? then do:
      find buf_clients where
           recid (buf_clients) = ri no-lock.
      ri = recid (buf_clients).
      run enable_UI.
      reposition br-objects to recid ri no-error.
      apply "ENTRY" to br-objects in frame {&frame-name} .
  end.
  return no-apply.

  END.
  WHEN {&stock} THEN DO:
      run adm/storei.w ( input parparentproc
                        ,input v-cntxt-host-code-obj
                        ,input 0
                        ,input {&add-def}
                        ,input-output ri).
      if ri <> ? then do:
          find buf_clients where
             recid (buf_clients) = ri no-lock.
          ri = recid (buf_clients).
          run enable_UI.
          reposition br-objects to recid ri no-error.
          apply "ENTRY" to br-objects.
      end.
      return no-apply.
  END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-db Dialog-Frame
PROCEDURE proc-b-db :
define variable v-ri as recid no-undo .

do
  on error undo, return error
  :

  run adm/dbs.w (
             input parparentproc
           , INPUT {&lookup}
           , output v-ri).
  if v-ri <> ?
  then do:
    find buf_db where recid (buf_db) = v-ri .
    assign
    f-db-num = buf_db.db-num
    f-db-name = buf_db.db-name
    .
    DISPLAY
    f-db-num
    f-db-name
    WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
    ASSIGN
    f-db-num = ?
    f-db-name = ''
    .
    DISPLAY
    f-db-num
    f-db-name
    WITH FRAME {&FRAME-NAME}.

  END.
  RUN Openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
define variable  ri as recid no-undo.
CASE X_clients.obj-type:
  WHEN {&shop} THEN DO:
    run ref/clients2.p ( input parparentproc
                        ,input recid(X_clients)
                        ,input ? /*p-stts*/
                        ,input no /*p-silent*/
                        ,input yes /*отсюда можно удалить и {&shop}*/
                        ,input '':U /*p-mode2*/
                        ,input '':U /*p-source-type*/
                        ,input '':U /*p-source-ref*/
                        ) no-error .
  END.
  WHEN {&stock} THEN DO:
    run ref/clients2.p ( input parparentproc
                        ,input recid(X_clients)
                        ,input ? /*p-stts*/
                        ,input no /*p-silent*/
                        ,input yes /*отсюда можно удалить и {&shop}*/
                        ,input '':U /*p-mode2*/
                        ,input '':U /*p-source-type*/
                        ,input '':U /*p-source-ref*/
                        ) no-error .
  END.
END CASE.
if error-status:error then do:
  return no-apply.
end.
run Openbr in this-procedure ( input yes, input no, input '':U).
reposition br-objects to recid ri no-error.
apply "ENTRY" to br-objects in frame {&frame-name} .
apply "value-changed" to br-objects.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-host Dialog-Frame
PROCEDURE proc-b-host :
define variable ref-list as char no-undo.
DEFINE VARIABLE new-host-code AS INTEGE no-undo.

  run adm/sconfs.w (
                 input parParentProc
                ,input "b-sel":U
                ,input no
                ,input v-cntxt-host-code-obj
                ,output new-host-code
                ,input-output ref-list ) .
  .
if new-host-code = ?
or new-host-code = 0
then do:
   ASSIGN
   f-host-code = ?
   f-host-name = ''
   .
END.
ELSE DO:

  find first buf_sysclients where
            buf_sysclients.obj-type = {&cmp}
        and buf_sysclients.obj-code = new-host-code no-lock.
    ASSIGN
    f-host-code = buf_sysclients.obj-code
    f-host-name = buf_sysclients.obj-name
    .
END.
DISPLAY
f-host-code
f-host-name
WITH FRAME {&FRAME-NAME}.
RUN Openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PROC-B-LIST Dialog-Frame
PROCEDURE PROC-B-LIST :
define input parameter loc-list-option as character no-undo.

define variable f-name as char init "default.cli" no-undo.
define variable imp-type like goods.prod-type no-undo.
define variable imp-code like goods.prod-code no-undo.
define variable v-ok as logical no-undo .

define buffer buf_temp-user-obj for temp-user-obj .
define buffer buf_clients for clients .
define buffer buf_clob-data for ub.clob-data.
define buffer buf_clob-bind for ub.clob-bind.


do
on error undo, return error return-value
:
  case loc-list-option:
    when "save":U
    or
    when "save-clob"
    then do:
      case loc-list-option:
        when "save" then do:
          assign
          v-ok = true
          .
          message
          "Сохранить все отмеченные объекты в файле списка" skip
          "Продолжить" skip
          view-as alert-box question buttons OK-Cancel update v-ok .
          if v-ok <> true
          then do:
            assign
            v-list-option = "":U
            .
            return .
          end.
          assign
          f-name = "default.cli"
          v-ok   = true
          .
          system-dialog get-file f-name
          filters "Списки клиентов *.cli" "*.cli"
          ask-overwrite
          save-as
          use-filename
          update v-ok
          default-extension "cli".
          if v-ok <> true
          then do:
            assign
            v-list-option = "":U
            .
            return .
          end.
          output stream sout to value (f-name).

          for each buf_temp-user-obj
          on error undo, return error return-value
          :
            export stream sout
              buf_temp-user-obj.obj-type
              buf_temp-user-obj.obj-code
            .
          end.

          output stream sout close.
        end. /*when "save" then do:*/
        when "save-clob" then do:
          run ref/clobbnds.w ( input parparentproc
                              ,input this-procedure:handle
                              ,input 'b-add' /*bttns*/
                              ,input "uniq-key-rec" /*p-list-mode*/
                              ,input {&update}
                              ,input {&lob-res-list}
                              ,input 'cli-list' /*p-unique-key-rec*/
                              ,input -1 /*p-db-num*/
                              ,input-output v-rid-list) no-error.
        end.
      end case. /*case loc-list-option:*/
    end.
    when "load":U
    or
    when "load-clob"
    then do:
      case loc-list-option:
        when "load" then do:
          assign
          v-ok = yes
          .
          message
          "Отметить все объекты из ранее сохраненного в файле списка" skip
          "Продолжить?" skip
          view-as alert-box question buttons ok-cancel update v-ok .
          if v-ok <> true
          then do:
            assign
            v-list-option = "":U
            .
            return.
          end.
          system-dialog get-file f-name
          filters "Списки клиентов *.cli" "*.cli"
          title "Выберите файл списка?"
          initial-dir "."
          return-to-start-dir
          must-exist
          /* use-filename */
          update v-ok
          default-extension "cli".
          if v-ok <> true
          then do:
            assign
            v-list-option = "":U
            .
            return.
          end.
        end. /*when load*/
        when "load-clob" then do:
          message
          "Отметить все объекты из хранимого списка" skip
          "Продолжить?" skip
          view-as alert-box question buttons ok-cancel update v-ok .
          if v-ok <> true
          then do:
            assign
            v-list-option = "":U
            .
            return.
          end.
          run ref/clobbnds.w ( input parparentproc
                              ,input this-procedure:handle
                              ,input 'b-sel' /*bttns*/
                              ,input "uniq-key-rec" /*p-list-mode*/
                              ,input ""
                              ,input {&lob-res-list}
                              ,input 'cli-list' /*p-unique-key-rec*/
                              ,input -1 /*p-db-num*/
                              ,input-output v-rid-list) no-error.
          if v-rid-list = ''
          then do:
            assign
            v-list-option = "":U
            .
            return.
          end.
          find first buf_clob-bind where
                  recid(buf_clob-bind) = integer(v-rid-list) no-error.
          if not available buf_clob-bind then do:
            message
            "Ошибка при пополучении хранимого файла"
            view-as alert-box error.
            assign
            v-list-option = "":U
            .
            return.
          end.
          else do:
            find first buf_clob-data no-lock where
                      buf_clob-data.db-num = buf_clob-bind.db-num
                  and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
            if error-status :error then do:
              message
              "Ошибка при пополучении хранимого файла"
              view-as alert-box error.
              return error.
            end.
            run gbl/_tmpfile.p ( input ""
                          ,input "tmp"
                          ,output f-name) .
            copy-lob from object buf_clob-data.cdata
            to file f-name.
          end.
        end.
      end case.
      input stream sout from value (f-name).
      repeat
      :
        assign
        imp-type = '':U
        imp-code = 0
        .
        import stream sout imp-type imp-code .
        find first buf_clients no-lock
          where buf_clients.obj-type = imp-type
            and buf_clients.obj-code = imp-code
          no-error .
        if available buf_clients
        and (buf_clients.obj-type = {&shop}
        or buf_clients.obj-type = {&stock})
        then do:
          run userobjs_append in this-procedure
            (input  buf_clients.obj-type
            ,input  buf_clients.obj-code
            ) .
        end.
      end.
      input stream sout close.

      run display-select-num in this-procedure .
      br-objects:refresh() in frame {&frame-name} .
      apply "entry" to br-objects in frame {&frame-name}.
    end.
    otherwise do:

    end.
  END CASE.
  loc-list-option = "":U.

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
define variable v-ri as recid no-undo .
assign
v-ri = (if avail X_clients then recid(X_clients) else ?)
.
assign
tbl = {&table_clients}
join-tbl = 'X_clients'
fld = ""
lab = ""
spr = ""
dim = '0'
.

run fltfield-add in this-procedure('obj-type', 'Тип клиента', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-code', 'Код клиента', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-name', 'Названиеклиента', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('db-num', 'БД', 'db',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', 'Код фирмы', 'db',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

DO on stop undo, leave:
    run gbl/filter.w ( INPUT parparentproc
                 ,INPUT filter-point + {&delim-par} + filter-label
                 ,INPUT tbl
                 ,INPUT join-tbl
                 ,INPUT fld
                 ,INput lab
                 ,INPUT spr
                 ,INPUT  dim).
    run OpenBr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
    if v-ri <> ? then do:
      reposition br-objects to recid v-ri no-error.
    end.
    APPLY "ENTRY" to br-objects in frame {&frame-name} .
    APPLY "VALUE-CHANGED" to br-objects.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-code Dialog-Frame
PROCEDURE proc-find-code :
define input parameter p-next as logical no-undo.
define input parameter p-code AS INTEGER no-undo.
DEFINE VARIABLE v-code AS CHARACTER NO-UNDO.

assign
v-code = string(p-code).
if rs-cli-type = {&all} then do:
  run OpenBr in this-procedure
      (input false /* p-open-query */
      ,input p-next  /* p-find-next  */
      ,input substitute(" and X_clients.obj-code = &1 "
        , v-code
        , {&double-quote}
        , rs-cli-type
        )
      ).
end.
else do:
  run OpenBr in this-procedure
      (input false /* p-open-query */
      ,input p-next  /* p-find-next  */
      ,input substitute(" and X_clients.obj-code = &1 and X_clients.obj-type = &2&3&2"
        , v-code
        , {&double-quote}
        , rs-cli-type
        )
      ).

end.
apply "entry":u to sch-code in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-host-name Dialog-Frame
FUNCTION get-host-name RETURNS CHARACTER
  ( INPUT p-host-code AS INTEGER ) :
DEFINE BUFFER buf_sysclients FOR ub.clients.
FIND FIRST buf_sysclients NO-LOCK WHERE
            buf_sysclients.obj-type = {&cmp}
     AND buf_sysclients.obj-code  = p-host-code NO-ERROR.
IF AVAILABLE buf_sysclients THEN RETURN buf_sysclients.obj-name.

RETURN "!!!Неизвестная фирма".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-shift-on Dialog-Frame
FUNCTION get-shift-on RETURNS LOGICAL
  ( INPUT p-obj-type AS CHARACTER, INPUT p-obj-code AS INTEGER ) :
DEFINE VARIABLE l-shift-on AS LOGICAL NO-UNDO.
l-shift-on = no.
{ gbl/objat.i
p-obj-type
p-obj-code
"'shift-on=request'"
l-shift-on
no-error
}
RETURN l-shift-on.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
( input p-recid as recid, input mark-list as character  ) :
define variable v-mark-string as character no-undo .
if v-new-selection-flag then do:
    run get-mark-string in this-procedure
      (input  X_clients.obj-type
      ,input  X_clients.obj-code
      ,output v-mark-string
      ) .
    return v-mark-string .
END.
ELSE DO:
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
