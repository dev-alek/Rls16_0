&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_cli FOR ub.clients.
DEFINE BUFFER for-cash-desk FOR ub.cash-desk.
DEFINE BUFFER X_cash-desk   FOR ub.cash-desk.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник касс

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/19/05
Author: Bakhtadze Natalya
Creation date: 09/19/05

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT  PARAMETER bttns  as character  no-undo .
DEFINE INPUT  PARAMETER parref-mode as character no-undo.
DEFINE INPUT  PARAMETER pardb-num like ub.sys-ctrl.db-num no-undo.
DEFINE INPUT  PARAMETER parhost-code like ub.sysconf.host-code no-undo.
DEFINE INPUT  PARAMETER parobj-type like ub.clients.obj-type no-undo.
DEFINE INPUT  PARAMETER parobj-code like ub.clients.obj-code no-undo.
define input  parameter p-rec       as recid no-undo .
DEFINE OUTPUT PARAMETER  p-rid-list    as  char no-undo . /* список recid'ов выбранных аписей */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник касс" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ gbl/thbjattr.i }
{ gbl/getcntxt.i DEF }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }
{ gbl/key-rec.i }
{ gbl/cd-attr.i }
{ rep/html-conv.i }
define stream Out-Stream .
define stream OutStr-html.
define variable log-res          as log       no-undo.
define variable rr               as recid     no-undo.
define variable jj               as integer   no-undo .
define variable str              as char      no-undo.
define variable conf-attr        as character no-undo .
define variable conf-par         as char      no-undo.                  /* для чтения параметра конфигурации */
define variable par-type         as char      no-undo.
define variable vartbl-name      as char      no-undo.
define variable varact           as char      no-undo.
/*использовать смены на объекте*/
define variable l-shift-on       as logical   no-undo.
/*текущая смена*/
define variable v-shift-date     as date      no-undo.
define variable v-shift-num      as integer   no-undo.
define variable v-shift-name     as character no-undo.
define variable filter-point0    as character no-undo init "cashlist" .
define variable filter-point     as character no-undo INIT "cashlist".
define variable filter-label     as character no-undo INIT "Справочник_касс_".
define variable filter-label0    as character no-undo init "Справочник_касс_" .

define variable sort-column-name as character no-undo .
define variable glog             as logical   no-undo .
define variable v-glog           as logical   no-undo .
DEFINE VARIABLE attr-option      AS CHARACTER NO-UNDO.
define VARIABLE v-mode           AS CHARACTER NO-UNDO .
define VARIABLE del-mode         AS logical   NO-UNDO .
define variable v-rid-list       as character no-undo .

define variable mdevice          as class     ibs.th.str.cash.CashDevice
  no-undo.
mdevice = new ibs.th.str.cash.CashDevice().

&SCOPED-DEFINE cd-type-code X_cash-desk.pos-type

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-cash-desk

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_cash-desk

/* Definitions for BROWSE BR-cash-desk                                  */
&Scoped-define FIELDS-IN-QUERY-BR-cash-desk mark-string( recid(X_cash-desk), v-rid-list ) X_cash-desk.cash-on X_cash-desk.obj-code X_cash-desk.db-num X_cash-desk.cash-num {&cd-type-name} cash-desk-auto(X_cash-desk.autonomy) if X_cash-desk.pos-type = {&cd-type-ibm-xml} or X_cash-desk.pos-type = {&cd-type-autotank} then (if num-entries(X_cash-desk.addr-path, {&delim-par}) > 1 then (entry(1, X_cash-desk.addr-path, {&delim-par}) + ":\\":U + entry(2, X_cash-desk.addr-path, {&delim-par})) else X_cash-desk.addr-path) else X_cash-desk.addr-path X_cash-desk.cash-os string(if X_cash-desk.is-del then {&deleted-status} else {&current-status}) (if X_cash-desk.remote = 1 then yes else no) X_cash-desk.version get-ffd-version(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num) get-kkt-schema(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num) ~
get-fo-version(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num)~
get-OptVer(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num)~
get-GISMT_TIMEOUT(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num)~
get-GISMT_FAST(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num)~
get-date(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num) + " " + get-time(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-cash-desk
&Scoped-define SELF-NAME BR-cash-desk
&Scoped-define QUERY-STRING-BR-cash-desk FOR EACH X_cash-desk NO-LOCK
&Scoped-define OPEN-QUERY-BR-cash-desk OPEN QUERY {&SELF-NAME} FOR EACH X_cash-desk NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-cash-desk X_cash-desk
&Scoped-define FIRST-TABLE-IN-QUERY-BR-cash-desk X_cash-desk


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-add B-chg B-del B-on ~
B-shft B-attr B-print B-hist B-sch B-Help mark-num Rs-object Rs-del ~
B-cli-attr B-attr-2 b-version BR-cash-desk b-tso
&Scoped-Define DISPLAYED-OBJECTS mark-num Rs-object Rs-del

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD cash-desk-auto Dialog-Frame
FUNCTION cash-desk-auto RETURNS CHARACTER
  ( p-autonomy AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD signExecution Dialog-Frame
FUNCTION signExecution RETURNS CHARACTER
  ( INPUT p-device-kind AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-fo-version Dialog-Frame
FUNCTION get-fo-version RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-OptVer Dialog-Frame
FUNCTION get-OptVER RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT p-cash-num AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-ffd-version Dialog-Frame
FUNCTION get-ffd-version RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-kkt-schema Dialog-Frame
FUNCTION get-kkt-schema RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-date Dialog-Frame
FUNCTION get-date RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-time Dialog-Frame
FUNCTION get-time RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-GISMT_FAST Dialog-Frame
FUNCTION get-GISMT_FAST RETURNS INTEGER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-GISMT_TIMEOUT Dialog-Frame
FUNCTION get-GISMT_TIMEOUT RETURNS INTEGER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-attr
  MENU-ITEM m_lookup-attr  LABEL "Просмотр"
  MENU-ITEM m_update-attr  LABEL "Изменение"     .

DEFINE MENU MENU-B-attr-2
  MENU-ITEM m_lookup-attr-2 LABEL "Просмотр"
  MENU-ITEM m_update-attr-2 LABEL "Изменение"     .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
  LABEL "&Добавить"
  SIZE 10 BY 1.

DEFINE BUTTON B-attr
  LABEL "&Оп.данные"
  SIZE 10 BY 1.

DEFINE BUTTON B-attr-2
  LABEL "&Настройки"
  SIZE 10 BY 1.

DEFINE BUTTON B-chg
  LABEL "&Изменить"
  SIZE 10 BY 1.

DEFINE BUTTON B-cli-attr
  LABEL "&Пар-тры типа кассы"
  SIZE 20 BY 1.

DEFINE BUTTON B-del
  LABEL "&Удалить"
  SIZE 10 BY 1.

DEFINE BUTTON B-Help
  LABEL "Помо&щь"
  SIZE 3 BY 1
  BGCOLOR 8 .

DEFINE BUTTON B-hist
  LABEL "Ис&тория"
  SIZE 3 BY 1.

DEFINE BUTTON B-mark
  LABEL "&*"
  SIZE 3 BY 1.

DEFINE BUTTON B-on
  LABEL "Вкл/В&ыкл"
  SIZE 10 BY 1.

DEFINE BUTTON B-print
  LABEL "Пе&чать"
  SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
  LABEL "&Выход"
  SIZE 10 BY 1
  BGCOLOR 8 .

DEFINE BUTTON B-sch
  LABEL "&Фильтр"
  SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
  LABEL "Вы&бор"
  SIZE 10 BY 1.

DEFINE BUTTON B-shft
  LABEL "С&мены"
  SIZE 10 BY 1.

DEFINE BUTTON b-version
  LABEL "Версия?"
  SIZE 10 BY 1.
     
DEFINE BUTTON b-tso
  LABEL "Управление ТСО"
  SIZE 15 BY 1.

DEFINE VARIABLE mark-num  AS CHARACTER FORMAT "X(256)":U
  VIEW-AS FILL-IN
  SIZE 9 BY 1
  FGCOLOR 4 NO-UNDO.

DEFINE VARIABLE Rs-del    AS LOGICAL
  VIEW-AS RADIO-SET HORIZONTAL
  RADIO-BUTTONS
  "Тек.", no,
  "Все", ?
  SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE Rs-object AS CHARACTER
  VIEW-AS RADIO-SET HORIZONTAL
  RADIO-BUTTONS
  "БД", "db",
  "Объект", "object"
  SIZE 19 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-cash-desk FOR
  X_cash-desk SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-cash-desk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-cash-desk Dialog-Frame _FREEFORM
  QUERY BR-cash-desk DISPLAY
  mark-string( recid(X_cash-desk), v-rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
  X_cash-desk.cash-on COLUMN-LABEL "Вкл" FORMAT "+/":U
  X_cash-desk.obj-code COLUMN-LABEL "Магазин" FORMAT "99999":U
  X_cash-desk.db-num FORMAT ">>>>9":U
  X_cash-desk.cash-num FORMAT ">>>9":U
  {&cd-type-name} COLUMN-LABEL "Тип POS" FORMAT "X(15)":U
  cash-desk-auto(X_cash-desk.autonomy) COLUMN-LABEL "Активность" FORMAT "X(20)":U
  if X_cash-desk.pos-type = {&cd-type-ibm-xml}
  or X_cash-desk.pos-type = {&cd-type-autotank}
  then
  (if num-entries(X_cash-desk.addr-path, {&delim-par}) > 1
  then (entry(1, X_cash-desk.addr-path, {&delim-par}) + ":\\":U +
  entry(2, X_cash-desk.addr-path, {&delim-par}))
  else X_cash-desk.addr-path)
  else X_cash-desk.addr-path COLUMN-LABEL "Адрес (путь к кассе)" FORMAT "X(35)":U
  X_cash-desk.cash-os FORMAT "X(12)":U
  signExecution(X_cash-desk.device-kind) COLUMN-LABEL "Признак исполнения" FORMAT "X(25)":U
  string(if X_cash-desk.is-del then {&deleted-status} else {&current-status}) COLUMN-LABEL "Статус" FORMAT "X(8)":U
  (if X_cash-desk.remote = 1 then yes else no) COLUMN-LABEL "Удаленная!дистанционно" FORMAT "+/":U
  X_cash-desk.version COLUMN-LABEL "Версия!протокола" FORMAT "X(17)":U
  get-fo-version(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num)  COLUMN-LABEL "Версия кассовой программы" FORMAT "X(35)":U
  get-OptVer(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num)  COLUMN-LABEL 'Версия "ПО Коннектор" ' FORMAT "X(35)":U
  get-ffd-version(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num)  COLUMN-LABEL "Версия ФФД" FORMAT "X(15)":U
  get-kkt-schema(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num)  COLUMN-LABEL "Схема интеграции ККТ" FORMAT "X(20)":U
  string(get-GISMT_TIMEOUT(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num))  COLUMN-LABEL "Таймаут ответа! ГИСМТ" FORMAT "X(15)":U
  string(get-GISMT_FAST(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num))  COLUMN-LABEL "Быстрый ответ! ГИСМТ" FORMAT "X(15)":U
  string(get-date(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num)) + " " + string(get-time(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num))  COLUMN-LABEL "Дата/время!последнего опроса касс" FORMAT "X(20)":U
  X_cash-desk.registration-code COLUMN-LABEL "Регистрационный номер" FORMAT "X(30)":U
  X_cash-desk.serial-code       COLUMN-LABEL "Номер производителя"   FORMAT "X(30)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS DROP-TARGET SIZE 98 BY 18.3.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
  b-quit AT ROW 1 COL 1
  B-mark AT ROW 1 COL 11
  b-sel AT ROW 1 COL 14
  B-add AT ROW 1 COL 24
  B-chg AT ROW 1 COL 34
  B-del AT ROW 1 COL 44
  B-on AT ROW 1 COL 54
  B-shft AT ROW 1 COL 64
  B-attr AT ROW 1 COL 74
  B-print AT ROW 1 COL 86
  B-hist AT ROW 1 COL 89
  B-sch AT ROW 1 COL 92
  B-Help AT ROW 1 COL 95
  mark-num AT ROW 2 COL 1 NO-LABEL
  Rs-object AT ROW 2 COL 5 NO-LABEL
  Rs-del AT ROW 2 COL 21.5 NO-LABEL
  B-cli-attr AT ROW 2 COL 54
  B-attr-2 AT ROW 2 COL 74 WIDGET-ID 4
  b-version AT ROW 2 COL 84 WIDGET-ID 2
  b-tso AT ROW 2 COL 39
  BR-cash-desk AT ROW 3.43 COL 1
  SPACE(0.24) SKIP(0.30)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
  TITLE "Справочник касс"
  CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_cli B "?" ? ub clients
      TABLE: for-cash-desk B "?" ? ub cash-desk
      TABLE: X_cash-desk B "?" ? ub cash-desk
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-cash-desk b-version Dialog-Frame */
ASSIGN
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.

ASSIGN
  B-attr:POPUP-MENU IN FRAME Dialog-Frame = MENU MENU-B-attr:HANDLE.

ASSIGN
  B-attr-2:POPUP-MENU IN FRAME Dialog-Frame = MENU MENU-B-attr-2:HANDLE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-cash-desk
/* Query rebuild information for BROWSE BR-cash-desk
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_cash-desk NO-LOCK.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-cash-desk */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Справочник касс */
  DO:
    p-rid-list = v-rid-list.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Справочник касс */
  DO:
    APPLY "END-ERROR":U TO SELF.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
  DO:

    glog = FALSE.
    define variable v-cash-desk-host-code as integer no-undo .
    { gbl/hostcode.i
      {&shop}
      parobj-code
      v-cash-desk-host-code
     }
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_cashdesk-reference_input-deletion-updating':U
    {&cntxt-object}
    v-cash-desk-host-code
    {&shop}
    parobj-code
    0
    0
    0
    true
    glog
    }

    if NOT glog then  return no-apply .
    rr = ?.
    jj = br-cash-desk:FOCUSED-ROW .
    run ref/cashlsti.w (
      input parparentproc
      ,input {&add-def}
      ,input v-cntxt-db-num
      ,input parobj-code
      ,input "":U
      ,input 0
      ,input-output rr ).
    if rr <> ? then 
    do:
      run OpenBr in this-procedure  ( input yes, input no, input '':U).
      glog = br-cash-desk:SET-REPOSITIONED-ROW( jj, "ALWAYS" ).
      REPOSITION br-cash-desk TO RECID RR.
    end.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr Dialog-Frame
ON CHOOSE OF B-attr IN FRAME Dialog-Frame /* Оп.данные */
  DO:
    define variable v-by-section as logical   no-undo .
    define variable v-rid-list   as character no-undo .
    if not available X_cash-desk THEN return no-apply.
    DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
    if attr-option = "":U then 
    do:
      run gbl/pop-up.p ( input self :handle, input no ) no-error.
      if error-status :error then 
      do: 
        return no-apply. 
      end.
    end.
    if attr-option = "":U then 
    do:
      return no-apply.
    end.
    IF attr-option = {&UPDATE} THEN 
    DO:
      define variable v-cash-desk-host-code as integer no-undo .
    
      { gbl/hostcode.i
      {&shop}
      X_cash-desk.obj-code
      v-cash-desk-host-code
     }
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_cashdesk-change_date_time':U
        {&cntxt-object}
        v-cash-desk-host-code
        {&shop}
        X_cash-desk.obj-code
        0
        0
        0
        false
        v-glog
        }
      if v-glog then 
      do:
        { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_cashdesk-reference_input-deletion-updating':U
      {&cntxt-object}
      v-cash-desk-host-code
      {&shop}
      X_cash-desk.obj-code
      0
      0
      0
      true
      glog
      }
        if NOT glog then return no-apply .
      end.
    END.
    if X_cash-desk.pos-type = {&cd-type-ibs-th} then 
    do:
      run ref/cda-cc.w ( input parparentproc
        ,input X_cash-desk.db-num
        ,input {&shop}

        ,input X_cash-desk.obj-code
        ,input X_cash-desk.pos-type
        ,input X_cash-desk.cash-num
        ,input '' /*bttns*/
        ,input-output v-rid-list) no-error.
    end.
    else 
    do:
      run ref/cd-atti.w (   input parparentproc
        ,input attr-option
        ,input "oper"
        ,input X_cash-desk.db-num
        ,input X_cash-desk.obj-code
        ,input X_cash-desk.pos-type
        ,input X_cash-desk.cash-num
        ,input v-glog
        ) NO-ERROR.
    end.
    attr-option = ''.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-2 Dialog-Frame
ON CHOOSE OF B-attr-2 IN FRAME Dialog-Frame /* Настройки */
  DO:
    define variable v-setted as logical no-undo .
    if not available X_cash-desk THEN return no-apply.
    DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
    if attr-option = "":U then 
    do:
      run gbl/pop-up.p ( input self :handle, input no ) no-error.
      if error-status :error then 
      do: 
        return no-apply. 
      end.
    end.
    if attr-option = "":U then 
    do:
      return no-apply.
    end.
    IF attr-option = {&UPDATE} THEN 
    DO:
      define variable v-cash-desk-host-code as integer no-undo .
    { gbl/hostcode.i
      {&shop}
      X_cash-desk.obj-code
      v-cash-desk-host-code
     }
      { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_cashdesk-reference_input-deletion-updating':U
      {&cntxt-object}
      v-cash-desk-host-code
      {&shop}
      X_cash-desk.obj-code
      0
      0
      0
      true
      glog
      }
      if NOT glog then return no-apply .
    END.
    case X_cash-desk.pos-type:
      when {&cd-type-ibs-th} then 
        do:
          run ref/cda-29.w ( input parparentproc
            ,input attr-option
            ,input X_cash-desk.db-num
            ,input X_cash-desk.obj-code
            ,input X_cash-desk.pos-type
            ,input X_cash-desk.cash-num
            ,input ""
            ,input ''
            ,output v-setted) no-error.
        end.
      when {&cd-type-ibs-th-mob} then 
        do:
          run ref/cda-31.w ( input parparentproc
            ,input attr-option
            ,input X_cash-desk.db-num
            ,input X_cash-desk.obj-code
            ,input X_cash-desk.pos-type
            ,input X_cash-desk.cash-num
            ,input ""
            ,input ''
            ,output v-setted) no-error.

        end.
      otherwise 
      do:
        run ref/cd-atti.w (   input parparentproc
          ,input attr-option
          ,input "ref"
          ,input X_cash-desk.db-num
          ,input X_cash-desk.obj-code
          ,input X_cash-desk.pos-type
          ,input X_cash-desk.cash-num
          ) NO-ERROR.
      end.
    end case.
    attr-option = ''.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
  DO:
    define variable v-shift-on as character no-undo .
    if not available X_cash-desk THEN return no-apply.
    if X_cash-desk.db-num <> pardb-num then 
    do:
      message "Касса принадлежит другой БД"
        view-as alert-box error .
      return no-apply.
    end.
    define variable v-cash-desk-host-code as integer no-undo .
    { gbl/hostcode.i
    {&shop}
    X_cash-desk.obj-code
    v-cash-desk-host-code
    }
    { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_cashdesk-reference_input-deletion-updating':U
  {&cntxt-object}
  v-cash-desk-host-code
  {&shop}
  X_cash-desk.obj-code
  0
  0
  0
  true
  glog
  }
    if NOT glog then return no-apply .
  /*найдем параметр - использовать смены глобально на объекте или нет*/
    { gbl/objat.i
    {&shop}
    X_cash-desk.obj-code
    "'shift-on=request'"
    l-shift-on
  }
    if l-shift-on then 
    do:
      run curshift in this-procedure ( input X_cash-desk.obj-code
        , input no)  no-error.
      if not error-status:error and v-shift-num > 0 then 
      do:
        message
          substitute("   Внимание, на объекте &1 открыта смена! &2В этом режиме для редактирования доступны не все свойства ККМ.
                    &2 &2 Продолжить?"
          , X_cash-desk.obj-code
          ,{&new-line}
          )
          view-as alert-box question buttons YES-NO update glog.
        if not glog then return no-apply.
        v-shift-on = string(l-shift-on).
      end.
      else 
      do:
        v-shift-on = string(no).
      end.
    end.
    rr = recid( X_cash-desk ).
    run ref/cashlsti.w (
      input parparentproc
      ,input {&update} + (if v-shift-on = '' then '' else {&delim-par}) + v-shift-on
      ,input X_cash-desk.db-num
      ,input X_cash-desk.obj-code
      ,input X_cash-desk.pos-type
      ,input X_cash-desk.cash-num
      , input-output rr ).
    run OpenBr in this-procedure  ( input yes, input no, input '':U).
    reposition br-cash-desk to recid rr .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cli-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cli-attr Dialog-Frame
ON CHOOSE OF B-cli-attr IN FRAME Dialog-Frame /* Пар-тры типа кассы */
  DO:
    define variable attr-type           as character no-undo . /*тип атрибута*/
    define variable attr-format         as character no-undo .  /* формат атрибута*/
    define variable attr-label          as character no-undo .         /*лабел атрибута */
    define variable attr-user-can-edit  as logical   no-undo .  /*пользователь может изменять в броусе*/
    define variable attr-output-display as logical   no-undo .  /*виден в броусе*/
    define variable attr-other          as char      no-undo .              /*еще чего - нибудь*/
    define variable attr-value          as char      no-undo .              /*для знач по умолч*/
    define variable v-prop-list         as character no-undo .
    define variable v-prop-type-list    as character no-undo .
    define variable v-prop-label-list   as character no-undo .
    define variable v-global            as logical   no-undo .
    define variable v-host              as logical   no-undo .
    define variable v-shop              as logical   no-undo .
    define variable v-store             as logical   no-undo .
    define variable v-db                as logical   no-undo .

    define variable v-spr               as character no-undo .
    define variable ii                  as integer   no-undo .
    IF NOT AVAILABLE X_cash-desk  THEN RETURN NO-APPLY.
    /*найдем какой справочник запускать для кассы данного типа*/
    run thbjattr_code in this-procedure (
      input ("cd-type-":U +
      (if X_cash-desk.pos-type = {&cd-type-ncr-as-r}
      then "ncr-as-r"
      else (if X_cash-desk.pos-type = {&cd-type-ipc-servispl}
      then "ipc-servispl"
      else X_cash-desk.pos-type))) /*p-upper-code*/
      ,input '':U                               /*p-code*/
      ,output attr-label
      ,output attr-user-can-edit
      ,output attr-output-display
      ,output attr-other
      ,output v-prop-list  /*список членов секции*/
      ,output v-prop-type-list  /*список членов секции*/
      ,output v-prop-label-list /*список типов членов секции*/
      ,output v-global  /*может ли быть задан в глобальном контексте*/
      ,output v-host /*может ли быть задан в контексте фирмы*/
      ,output v-shop  /*может ли быть задан в контексте маг*/
      ,output v-store /*может ли быть задан в контексте склад*/
      ,output v-db /*может ли быть задан в контексте БД*/
      ).

    do ii = 1 to num-entries(attr-other, {&slash-char}):
      if entry(ii, attr-other, {&slash-char}) begins "spr-ext=":U then 
      do:
        assign
          v-spr = entry(2, entry(ii, attr-other, {&slash-char}), "=").
      end.
    end.
    run value(v-spr)(
      input parparentproc
      ,input {&LOOKUP}
      ,input {&shop}
      ,input X_cash-desk.obj-code
      ).
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
  DO:
    define buffer check_cash-desk for Ub.cash-desk.
    define buffer buf_db          for ub.db.
    if not available X_cash-desk then return no-apply.
    FIND FIRST check_cash-desk where
      recid(check_cash-desk) = recid(X_cash-desk) no-error.
    if not avail check_cash-desk then return no-apply.

    if check_cash-desk.db-num <> pardb-num then 
    do:
      find first buf_db no-lock where
        buf_db.db-num = check_cash-desk.db-num no-error.
      if available buf_db then 
      do:
        message "Касса принадлежит другой БД"
          view-as alert-box error .
        return no-apply.
      end.
    end.
    glog = FALSE.
    define variable v-cash-desk-host-code as integer no-undo .
    { gbl/hostcode.i
      {&shop}
      X_cash-desk.obj-code
      v-cash-desk-host-code
     }
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_cashdesk-reference_input-deletion-updating':U
    {&cntxt-object}
    v-cash-desk-host-code
    {&shop}
    X_cash-desk.obj-code
    0
    0
    0
    true
    glog
    }
    if NOT glog then return no-apply .
    message
      "Вы уверены?"
      view-as alert-box buttons YES-NO update glog.
    if not glog then return no-apply.
    run ref/cashdsk3.p ( input recid(check_cash-desk)) no-error .
    if error-status:error then 
    do:
      message
        substitute("Ошибка при удалении кассы&1&2&1&3"
        ,{&new-line}
        , error-status:get-message(1)
        , return-value )
        view-as alert-box error .
      return no-apply.
    end.
    Run Openbr in this-procedure  ( input yes, input no, input '':U).
    APPLY "ENTRY" To browse {&browse-name}.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
  DO:
    define variable v-rid-list as character no-undo .
    if available X_cash-desk THEN
      run ref/ccshlist.w (
        input parparentproc
        , INPUT "":U /*bttns*/
        , INPUT "one":U /*parref-mode*/
        , OUTPUT  v-rid-list
        , INPUT X_cash-desk.db-num
        , INPUT {&shop}
        , INPUT X_cash-desk.obj-code
        , input X_cash-desk.pos-type
        , input X_cash-desk.cash-num
        , input "":U /*p-subject*/
        ).
    apply "entry" to br-cash-desk.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
  DO:
    if not available X_cash-desk then return no-apply.
    { gbl/markstrn.i X_cash-desk v-rid-list }
    glog = br-cash-desk  :refresh( ) in frame {&frame-name}.
    if not can-do ("MOUSE-SELECT-DBLCLICK,Return", last-event:function) then 
    do:
      glog = br-cash-desk:select-next-row () in frame {&frame-name}.
      apply "value-changed" to br-cash-desk in frame {&frame-name}.
    end.
    if num-entries (v-rid-list) = 0 then
      hide mark-num in frame {&frame-name}.
    else
      disp num-entries (v-rid-list) @ mark-num
        with frame {&frame-name}.
    apply "entry" to br-cash-desk in frame {&frame-name}.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-on
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-on Dialog-Frame
ON CHOOSE OF B-on IN FRAME Dialog-Frame /* Вкл/Выкл */
  DO:
    define variable v-on like ub.cash-desk.cash-on no-undo .
    if not avail X_cash-desk then return no-apply.
    define buffer check_cash-desk for ub.cash-desk.
    if X_cash-desk.db-num <> pardb-num then 
    do:
      message "Касса принадлежит другой БД"
        view-as alert-box error .
      return no-apply.
    end.
    /*для выключения надо находится на объекте кассы!*/
    FIND FIRST check_cash-desk where
      recid(check_cash-desk) = recid(X_cash-desk) no-error.
    if not avail check_cash-desk then return no-apply.
    if check_cash-desk.obj-code <> parobj-code then 
    do:
      message
        "Для включения/выключения кассы " check_cash-desk.cash-num
        "текущим объектом должен быть магазин " check_cash-desk.obj-code
        view-as alert-box ERROR.
      return no-apply.
    end.
    if check_cash-desk.pos-type = {&cd-type-r-keeper} then 
    do :
    { gbl/conf-rd.i
      "'is-rkeep':U"
      "'':U"
      "'':U"
      0
      "'':U"
      "'':U"
      "'':U"
      no
      conf-par
      par-type
      no-error
    }
      if error-status :error
        or conf-par <> 'yes'
        then 
      do:
        message
          "В системе запрещена работа с кассами R-Keeper либо отсутсвует конфигурационный параметр is-rkeep" skip
          "Обратитесь к администратору" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return no-apply.
      end.
    end.
    glog = FALSE.
    define variable v-cash-desk-host-code as integer no-undo .
  { gbl/hostcode.i
    {&shop}
    X_cash-desk.obj-code
    v-cash-desk-host-code
    }
    { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_cashdesk-reference_on-off':U
  {&cntxt-object}
  v-cash-desk-host-code
  {&shop}
  X_cash-desk.obj-code
  0
  0
  0
  true
  glog
  }
    if NOT glog then return no-apply .
    message
      "Вы уверены?"
      view-as alert-box buttons YES-NO update glog.
    if not glog then return no-apply.
    rr = recid( check_cash-desk ).
    v-on = ?.
    run ref/cashdsk2.p ( input parparentproc
      , input recid(check_cash-desk)
      , input-output v-on) no-error .
    if error-status:error then 
    do:
      if return-value <> "":U then
        message
          return-value
          view-as alert-box .
      return no-apply.
    end.
    Browse br-cash-desk:REFRESH().
    APPLY "ENTRY" To browse br-cash-desk.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
  DO:
    run proc-b-print in this-procedure no-error.
    if error-status:error then return no-apply.
    apply "ENTRY" to br-cash-desk.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
  DO:
    run proc-b-sch in this-procedure no-error.
    if error-status:error then return no-apply.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
  DO:
    if ( available X_cash-desk ) AND ( v-rid-list = "" ) then
      v-rid-list = string( recid( X_cash-desk ) ) .

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-shft
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-shft Dialog-Frame
ON CHOOSE OF B-shft IN FRAME Dialog-Frame /* Смены */
  DO:
    define variable old-list-mode as char.
    define variable v-shft        as integer no-undo init 0.
    define variable cas-shft      as logical no-undo.

    define buffer check_cash-desk for ub.cash-desk.

    if not available X_cash-desk then return no-apply.
    FIND FIRST check_cash-desk where
      recid(check_cash-desk) = recid(X_cash-desk) no-error.
    if not avail check_cash-desk then return no-apply.

    FIND FIRST ub.shop No-LOCK WHERE
      ub.shop.obj-code = check_cash-desk.obj-code No-ERROR.
    if not avail ub.shop then return no-apply.
    find first ub.sysconf No-LOCK WHERE
      ub.sysconf.host-code = ub.shop.host-code.
  /*найдем параметр - использовать виртуальные смены*/
    { gbl/cas-shft.i {&shop} ub.shop.obj-code cas-shft }
    if cas-shft then 
    do:
      { gbl/v-shft.i {&shop} ub.shop.obj-code v-shft }
    end.
    if cas-shft  then 
    do:
      run ref/shftcshs.w (  input parparentproc
        ,input (if lookup("b-add", bttns) > 0 then {&update} else {&lookup})
        ,input {&cash-desk} /*p-list-mode*/
        ,input recid( check_cash-desk )
        ,input  ?
        ,input check_cash-desk.obj-code ) .
    end.
    else 
    do:
      message
        "Для магазина, к которому относится касса," skip
        "не ведется таблица кассовых смен!"
        view-as alert-box ERROR.
    end.
    apply "entry" to br-cash-desk.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-version
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-version Dialog-Frame
ON CHOOSE OF b-version IN FRAME Dialog-Frame /* Версия? */
  DO:
    RUN proc-b-version IN THIS-PROCEDURE NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-tso
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-tso Dialog-Frame
ON CHOOSE OF b-tso IN FRAME Dialog-Frame /* Управление ТСО */
  DO:
    run ref/tso-ctrl.w (input parparentproc,
      input parref-mode) .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-cash-desk
&Scoped-define SELF-NAME BR-cash-desk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-cash-desk Dialog-Frame
ON DEFAULT-ACTION OF BR-cash-desk IN FRAME Dialog-Frame
  DO:
    if b-chg:sensitive THEN apply "CHOOSE":U to b-chg.
    else if b-sel:sensitive then apply "CHOOSE":U to b-sel. /* Арн. Реакция на клавишу ENTER при добавления касс. ТН-#3046 (виртуально "нажимаем" кнопку b-sel) */
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-cash-desk Dialog-Frame
ON RETURN OF BR-cash-desk IN FRAME Dialog-Frame
  DO:
    apply "DEFAULT-ACTION":U to self.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-cash-desk Dialog-Frame
ON VALUE-CHANGED OF BR-cash-desk IN FRAME Dialog-Frame
  DO:
    assign
      MENU-ITEM m_lookup-attr:sensitive in menu menu-b-attr     = no
      MENU-ITEM m_update-attr:sensitive in menu menu-b-attr     = no
      MENU-ITEM m_lookup-attr-2:sensitive in menu menu-b-attr-2 = no
      MENU-ITEM m_update-attr-2:sensitive in menu menu-b-attr-2 = no

      .
    IF NOT AVAILABLE X_cash-desk THEN 
    DO:
      DISABLE
        b-version
        with FRAME {&FRAME-NAME}.
    END.
    ELSE 
    DO:
      CASE X_cash-desk.pos-type:
        WHEN {&cd-type-ibm-xml} OR 
        WHEN {&cd-type-autotank} THEN 
          DO:
            enable
              b-version 
              when parref-mode <> {&all}
              with FRAME {&FRAME-NAME}.
            assign
              MENU-ITEM m_lookup-attr:sensitive in menu menu-b-attr     = yes
              MENU-ITEM m_update-attr:sensitive in menu menu-b-attr     = yes
              MENU-ITEM m_lookup-attr-2:sensitive in menu menu-b-attr-2 = yes
              MENU-ITEM m_update-attr-2:sensitive in menu menu-b-attr-2 = yes

              .
          END.
        when {&cd-type-ibs-th} then 
          do:
            assign
              MENU-ITEM m_lookup-attr:sensitive in menu menu-b-attr     = yes
              MENU-ITEM m_update-attr:sensitive in menu menu-b-attr     = no
              MENU-ITEM m_lookup-attr-2:sensitive in menu menu-b-attr-2 = yes
              MENU-ITEM m_update-attr-2:sensitive in menu menu-b-attr-2 = yes
              .
          end.
        OTHERWISE 
        DO:
          DISABLE
            b-version
            with FRAME {&FRAME-NAME}.
          assign
            MENU-ITEM m_lookup-attr:sensitive in menu menu-b-attr     = yes
            MENU-ITEM m_update-attr:sensitive in menu menu-b-attr     = yes
            MENU-ITEM m_lookup-attr-2:sensitive in menu menu-b-attr-2 = yes
            MENU-ITEM m_update-attr-2:sensitive in menu menu-b-attr-2 = yes
            .
        END.
      END CASE.
    END.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_lookup-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_lookup-attr Dialog-Frame
ON CHOOSE OF MENU-ITEM m_lookup-attr /* Просмотр */
  DO:
    assign
      ATTR-option = {&LOOKUP}
      .
    APPLY "CHOOSE" TO b-attr IN FRAME {&FRAME-NAME}.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_lookup-attr-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_lookup-attr-2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_lookup-attr-2 /* Просмотр */
  DO:
    assign
      ATTR-option = {&LOOKUP}
      .
    APPLY "CHOOSE" TO b-attr-2 IN FRAME {&FRAME-NAME}.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_update-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_update-attr Dialog-Frame
ON CHOOSE OF MENU-ITEM m_update-attr /* Изменение */
  DO:
    assign
      ATTR-option = {&UPDATE}
      .
    APPLY "CHOOSE" TO b-attr IN FRAME {&FRAME-NAME}.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_update-attr-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_update-attr-2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_update-attr-2 /* Изменение */
  DO:
    assign
      ATTR-option = {&UPDATE}
      .
    APPLY "CHOOSE" TO b-attr-2 IN FRAME {&FRAME-NAME}.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Rs-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Rs-del Dialog-Frame
ON VALUE-CHANGED OF Rs-del IN FRAME Dialog-Frame
  DO:
    DEFINE VARIABLE v-rec AS RECID NO-UNDO.
    ASSIGN
      rs-del
      del-mode = rs-del.
    IF AVAILABLE X_cash-desk  THEN 
    DO:
      v-rec = RECID(X_cash-desk).
    END.
    run openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
    REPOSITION br-cash-desk  TO RECID v-rec NO-ERROR.
    APPLY "entry" TO br-cash-desk.


  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Rs-object
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Rs-object Dialog-Frame
ON VALUE-CHANGED OF Rs-object IN FRAME Dialog-Frame
  DO:
    DEFINE VARIABLE v-rec AS RECID NO-UNDO.
    ASSIGN
      rs-object
      v-mode = rs-object.
    IF AVAILABLE X_cash-desk  THEN 
    DO:
      v-rec = RECID(X_cash-desk).
    END.
    RUN openbr IN THIS-PROCEDURE  ( input yes, input no, input '':U).
    REPOSITION br-cash-desk  TO RECID v-rec NO-ERROR.
    APPLY "entry" TO br-cash-desk.


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
{ gbl/brwrepos.i
&browse-name=br-cash-desk
&line-num=5
}

{ gbl/setfltnm.i }
{ gbl/brwrefre.i " if available X_cash-desk then p-rec = recid(X_cash-desk). Run openbr in this-procedure  ( input yes, input no, input '':U). " }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  FIND FIRST buf_cli No-LOCK WHERE
    buf_cli.obj-type = parobj-type and
    buf_cli.obj-code = parobj-code No-ERROR.
  if not avail buf_cli then 
  do:
    message
      vss-workfile vss-revision vss-description skip
      "Неверный вызов - parobj-type=" parobj-type "parobj-code=" parobj-code

      view-as alert-box ERROR.
    return.
  end.
  CASE parref-mode:
    WHEN {&all}        THEN 
      DO:
      END.
    WHen {&g___object} then 
      do:
      end.
    when "db":U then 
      do:
      end.
    otherwise 
    do:
      message vss-workfile vss-revision vss-description skip
        "Неверный вызов - parref-mode=" parref-mode
        view-as alert-box ERROR.
      return.
    end.
  end case.
  v-mode = parref-mode.
  if v-mode = {&all} then del-mode = ?.
  else del-mode = no.
  RUN MyEnable in this-procedure .
  HIDE mark-num in frame {&frame-name} .
  run OpenBR in this-procedure  ( input yes, input no, input '':U).
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE curshift Dialog-Frame
PROCEDURE curshift :
  /*------------------------------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  ------------------------------------------------------------------------------*/
  DEFINE INPUT PARAMETER shop-code like ub.cash-desk.obj-code no-undo.
  DEFINE INPUT PARAMETER silence as logical no-undo.
  { gbl/curshift.i {&shop} shop-code v-shift-date v-shift-num v-shift-name no-error}
  if error-status:error then 
  do:
    if silence then
      message return-value view-as alert-box ERROR.
    return error return-value.
  end.

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
  DISPLAY mark-num Rs-object Rs-del
    WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-add B-chg B-del B-on B-shft B-attr B-print
    B-hist B-sch B-Help mark-num Rs-object Rs-del B-cli-attr B-attr-2
    b-version BR-cash-desk b-tso
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
  /*------------------------------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  ------------------------------------------------------------------------------*/
  ASSIGN
    b-attr:MENU-MOUSE IN frame {&FRAME-NAME}       = 1
    b-attr-2:MENU-MOUSE IN frame {&FRAME-NAME}     = 1
    rs-object:RADIO-BUTTONS IN FRAME {&FRAME-NAME} = (IF parref-mode = {&ALL} AND v-cntxt-db-num = 0
                                                  THEN ("Все" + {&comma-char} + {&all} + {&comma-char} +
                                                      "БД" + {&comma-char} + 'db':U + {&comma-char} +
                                                        parobj-type + string(parobj-code) + {&comma-char} + {&g___object})
                                                  ELSE ("БД" + {&comma-char} + 'db':U + {&comma-char} +
                                                        parobj-type + string(parobj-code) + {&comma-char} + {&g___object}))
    rs-del                                         = del-mode.
  DISPLAY
    mark-num
    rs-del
    WITH FRAME {&frame-name} .
  ENABLE
    B-quit
    B-mark 
    when lookup('b-mark':U, bttns) >0
    B-sel 
    when lookup('b-sel':U, bttns) >0
    B-add 
    when lookup('b-add':U, bttns) >0 and parref-mode <> {&all} AND NOT TRANSACTION
    B-chg 
    when lookup('b-add':U, bttns) >0 and parref-mode <> {&all} AND NOT TRANSACTION
    B-del 
    when lookup('b-add':U, bttns) >0 and parref-mode <> {&all} AND NOT TRANSACTION
    B-on 
    when lookup('b-on':U, bttns) >0 and parref-mode <> {&all} AND NOT TRANSACTION
    B-version 
    when lookup('b-add':U, bttns) >0 and parref-mode <> {&all} AND NOT TRANSACTION
    b-tso
    b-attr
    b-attr-2
    b-cli-attr
    B-shft
    B-sch
    B-print
    B-hist
    B-Help
    rs-object
    rs-del 
    WHEN parref-mode <> {&all}
    BR-cash-desk
    mark-num
    WITH FRAME {&frame-name} .
  VIEW FRAME {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .

  define variable l-query-was-opened as logical   no-undo .


  define variable sort-column-phrase as character no-undo .

  case sort-column-name :
    when "" then 
      do:
        assign
          sort-column-phrase = ""
          .
      end.
    otherwise 
    do:
      assign
        sort-column-phrase = "by " + sort-column-name
        .
    end.
  end case.

&scop flt-open-debug-file

&scop flt-open-open-query OPEN QUERY br-cash-desk FOR EACH X_cash-desk

&scop flt-open-dyn_open-query  FOR EACH X_cash-desk

&scop flt-open-query-handle query br-cash-desk:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-find-buffer-name X_cash-desk

&scop flt-open-waitfram yes

  CASE v-mode:
    when {&all} then 
      do:
        CASE del-mode :
          WHEN ? THEN 
            DO:
              ASSIGN
                frame {&frame-name}:TITLE = "Справочник касс"
                filter-point              = filter-point0 + parref-mode.
              { gbl/fltopend.i
          &where-cond = " TRUE "
          &use-ind = "  "
          &by = " by X_cash-desk.db-num by X_cash-desk.obj-code "
        }
            END.
          WHEN NO THEN 
            DO:
              ASSIGN
                frame {&frame-name}:TITLE = "Справочник касс - неудаленные"
                filter-point              = filter-point0 + parref-mode.
              { gbl/fltopend.i
            &where-cond = " X_cash-desk.is-del = no "
            &use-ind = "  "
            &by = " by X_cash-desk.db-num by X_cash-desk.obj-code "
          }
            END.
        END CASE.
      end. /*when {&all} then do:*/
    when {&g___object} then 
      do:
        CASE del-mode:
          WHEN ? THEN 
            DO:
              ASSIGN 
                frame {&frame-name}:TITLE = substitute("Справочник касс &1&2 &3"
                                                      ,parobj-type
                                                      ,parobj-code
                                                      ,buf_cli.obj-name).
              filter-point = filter-point0 + parref-mode.
              { gbl/fltopend.i
            &where-cond = " X_cash-desk.obj-code = parobj-code "
            &dyn_where-cond = " substitute('X_cash-desk.obj-code = &1', parobj-code) "
            &use-ind = "  "
            &by = " by X_cash-desk.cash-num "
          }
            END.
          WHEN NO THEN 
            DO:
              ASSIGN 
                frame {&frame-name}:TITLE = substitute("Справочник касс &1&2 &3 - неудаленные"
                                                        ,parobj-type
                                                        ,parobj-code
                                                        ,buf_cli.obj-name).
              filter-point = filter-point0 + parref-mode.
              { gbl/fltopend.i
              &where-cond = " X_cash-desk.obj-code = parobj-code and X_cash-desk.is-del = no "
              &dyn_where-cond = " substitute('X_cash-desk.obj-code = &1 and X_cash-desk.is-del = no', parobj-code) "
              &use-ind = "  "
              &by = " by X_cash-desk.cash-num "
            }

            END.
        END CASE.
      end.
    when "db":U then 
      do:
        CASE del-mode:
          WHEN ?  THEN 
            DO:
              ASSIGN 
                frame {&frame-name}:TITLE = substitute("Справочник касс БД: &1", pardb-num).
              filter-point = filter-point0 + parref-mode.
              { gbl/fltopend.i
               &where-cond = " X_cash-desk.db-num = pardb-num "
               &dyn_where-cond = " substitute('X_cash-desk.db-num = &1', pardb-num) "
               &use-ind = "  "
               &by = " by X_cash-desk.db-num by X_cash-desk.obj-code by X_cash-desk.cash-num "
             }

            END.
          WHEN NO THEN 
            DO:
              ASSIGN 
                frame {&frame-name}:TITLE = substitute("Справочник касс БД: &1 - неудаленные", pardb-num).
              filter-point = filter-point0 + parref-mode.
              { gbl/fltopend.i
                &where-cond = " X_cash-desk.db-num = pardb-num and X_cash-desk.is-del = no "
                &dyn_where-cond = " substitute('X_cash-desk.db-num = &1 and X_cash-desk.is-del = no ', pardb-num) "
                &use-ind = "  "
                &by = " by X_cash-desk.db-num by X_cash-desk.is-del by X_cash-desk.obj-code by X_cash-desk.cash-num "
              }
            END.
        END CASE.
      end.
  END CASE.

  apply "entry" to br-cash-desk in frame {&frame-name}.
  if p-rec <> ? then reposition br-cash-desk to recid p-rec no-error.
  if error-status:error then 
  do:
    reposition br-cash-desk to row 1 no-error.
  end.
  run waitfram-hide in this-procedure .
  if avail X_cash-desk then
    APPLY "VALUE-CHANGED":U to br-cash-desk.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :

  define VARIABLE p-report-id         as character no-undo .
  define variable v-file-name-rep-htm as character no-undo .

  /*печать*/
  run get-report-num (output p-report-id).
    
  v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".   
    
  define variable ii              as integer   no-undo.
  define variable StartRecid      as integer   no-undo.
  define variable v-fo-version    as CHARACTER no-undo.
  define variable v-OptVer        as CHARACTER no-undo.
  define variable v-ffd-version   as CHARACTER no-undo.
  define variable v-GISMT_TIMEOUT as CHARACTER no-undo.
  define variable v-GISMT_FAST    as CHARACTER no-undo.
  define variable v-date          as CHARACTER no-undo.
  define variable v-time          as CHARACTER no-undo.
  define variable v-kkt-schema    as CHARACTER no-undo.
  define variable v-autonomy      as character no-undo .
  define variable v-addr-path     as character no-undo .
  define variable v-signExecution as character no-undo .


  output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
  put stream OutStr-html unformatted
    "<!DOCTYPE HTML>" skip
    ' <html>' skip
    '  <head>' skip
    '   <meta charset="utf-8">' skip
    '    <style type="text/css">' skip
                        
    '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
    '   </style>' skip
    '  </head>' skip
    .

  put stream OutStr-html unformatted
    '<body>' skip
    /*Первая таблица*/
    '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
    .

  put stream OutStr-html unformatted
    '<tr class="set_columns">' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 20px;"></td>' skip
    '<td style="width: 40px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '</tr>' skip

    .     
        
  put stream OutStr-html unformatted
    '<TR><TD colspan="18"></TD></TR>' skip
    '<TR>' skip
    '<Td colspan="18" style="height: 14px; text-align: center; font-weight: bold;">СПРАВОЧНИК КАСС</Td>' skip
    '</TR>'skip
    '</thead>' skip
    '<tbody>' skip
    '<tr>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Магазин</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">БД</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Номер</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Тип POS</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Активность</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Адрес (путь к кассе)</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Тип ОС</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Признак исполнения</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Статус</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Удаленная дистанционно</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Версия протокола</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Версия кассовой программы</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Версия ПО «Коннектор»</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Схема интеграции ККТ</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Версия ФФД</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Таймаут ответа ГИСМТ</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Быстрый ответ ГИСМТ</th>' skip
    '<th colspan="2" text_wrap="true" style="text-align: center;">Дата/время последнего опроса касс</th>' skip
    '</tr>' skip
    '<tr>' skip
    '<td text_wrap="true" style="text-align: center;">Дата</td>' skip
    '<td text_wrap="true" style="text-align: center;">Время</td>' skip
    '</tr>' skip   
    .                           
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td style="text-align: center;">1</td>' skip
    '<td style="text-align: center;">2</td>' skip
    '<td style="text-align: center;">3</td>' skip
    '<td style="text-align: center;">4</td>' skip
    '<td style="text-align: center;">5</td>' skip
    '<td style="text-align: center;">6</td>' skip
    '<td style="text-align: center;">7</td>' skip
    '<td style="text-align: center;">8</td>' skip
    '<td style="text-align: center;">9</td>' skip
    '<td style="text-align: center;">10</td>' skip
    '<td style="text-align: center;">11</td>' skip
    '<td style="text-align: center;">12</td>' skip
    '<td style="text-align: center;">13</td>' skip
    '<td style="text-align: center;">14</td>' skip
    '<td style="text-align: center;">15</td>' skip
    '<td style="text-align: center;">16</td>' skip
    '<td style="text-align: center;">17</td>' skip
    '<td style="text-align: center;">18</td>' skip
    '<td style="text-align: center;">19</td>' skip
    '</tr>' skip
    .     

  /*   for each X_cash-desk :*/

  define variable vQuery as handle no-undo. 
  vQuery = query br-cash-desk:handle.
  do while available X_cash-desk:

    put stream OutStr-html unformatted
      '<tr>' skip
      '<td text_wrap="true" style="text-align: center;">' + string(X_cash-desk.obj-code) + '</td>' skip
      '<td text_wrap="true" style="text-align: center;">' + string(X_cash-desk.db-num) + '</td>' skip
      '<td text_wrap="true" style="text-align: center;">' + string(X_cash-desk.cash-num) + '</td>' skip
      '<td text_wrap="true" style="text-align: center;">' + string(X_cash-desk.pos-type) + '</td>' skip
      .
    case X_cash-desk.autonomy:
      when 0 then 
        v-autonomy = {&cd-self-full} .
      when 1 then 
        v-autonomy = {&cd-slave-full} .
      when 2 then 
        v-autonomy = {&cd-manager-full} .
    end case .
    put stream OutStr-html unformatted
      '<td text_wrap="true" style="text-align: center;">' + v-autonomy  + '</td>' skip .
    if X_cash-desk.pos-type = {&cd-type-ibm-xml} or X_cash-desk.pos-type = {&cd-type-autotank} then 
    do:
      if num-entries(X_cash-desk.addr-path, {&delim-par}) > 1 then 
        v-addr-path = (entry(1, X_cash-desk.addr-path, {&delim-par}) + ":\\":U + entry(2, X_cash-desk.addr-path, {&delim-par})) .
      else v-addr-path = X_cash-desk.addr-path .
    end. 
    else v-addr-path = X_cash-desk.addr-path .

    put stream OutStr-html unformatted
      '<td text_wrap="true" style="text-align: center;">' + string(v-addr-path) + '</td>' skip
      '<td text_wrap="true" style="text-align: center;">' + string(X_cash-desk.cash-os) + '</td>' skip
      .
    v-signExecution = signExecution(X_cash-desk.device-kind) .
    put stream OutStr-html unformatted    
      '<td text_wrap="true" style="text-align: center;">' + string(v-signExecution) + '</td>' skip
      .         
    put stream OutStr-html unformatted
      '<td text_wrap="true" style="text-align: center;">' + string(if X_cash-desk.is-del then {&deleted-status} else {&current-status}) + '</td>' skip
      '<td text_wrap="true" style="text-align: center;">' + string((if X_cash-desk.remote = 1 then '+' else ' ')) + '</td>' skip
      '<td text_wrap="true" style="text-align: center;">' + if X_cash-desk.version <> ? then string(X_cash-desk.version) + '</td>' else "" + '</td>'skip
      /*         '<td text_wrap="true" rowspan="2" style="text-align: right;">' + string(X_cash-desk.registration-code) + '</td>' skip*/
      /*         '<td text_wrap="true" rowspan="2" style="text-align: right;">' + string(X_cash-desk.serial-code) + '</td>' skip      */
      .
    
    v-fo-version = get-fo-version( X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num) .
    if v-fo-version = ? then v-fo-version = "" .
    put stream OutStr-html unformatted    
      '<td text_wrap="true" style="text-align: center;">' + string(v-fo-version) + '</td>' skip
      .  
    v-OptVer = get-OptVer( X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num) .
    if (v-OptVer = ? or v-OptVer = '?') then v-OptVer = "" .
    put stream OutStr-html unformatted    
      '<td text_wrap="true" style="text-align: center;">' + v-OptVer + '</td>' skip
      .
    v-kkt-schema = get-kkt-schema( X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num) .
    if v-kkt-schema = ? then v-kkt-schema = " - " .
    put stream OutStr-html unformatted    
      '<td text_wrap="true" style="text-align: center;">' + string(v-kkt-schema) + '</td>' skip
      .
    v-ffd-version = get-ffd-version( X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num) .
    if v-ffd-version = ? then v-ffd-version = " - " .
    put stream OutStr-html unformatted    
      '<td text_wrap="true" style="text-align: center;">' + string(v-ffd-version) + '</td>' skip
      .
    v-GISMT_TIMEOUT = string(get-GISMT_TIMEOUT( X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num)) .
    if v-GISMT_TIMEOUT = ? then v-GISMT_TIMEOUT = " - " .
    put stream OutStr-html unformatted    
      '<td text_wrap="true" style="text-align: center;">' + string(v-GISMT_TIMEOUT) + '</td>' skip
      .
    v-GISMT_FAST = string(get-GISMT_FAST( X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num)) .
    if v-GISMT_FAST = ? then v-GISMT_FAST = " - " .
    put stream OutStr-html unformatted    
      '<td text_wrap="true" style="text-align: center;">' + string(v-GISMT_FAST) + '</td>' skip
      .
    v-date = get-date( X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num) .
    if v-date = "" then v-date = " - " .
    put stream OutStr-html unformatted    
      '<td text_wrap="true" style="text-align: center;">' + string(v-date) + '</td>' skip
      .
    v-time = get-time( X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num) .
    if v-time = "" then v-time = " - " .
    put stream OutStr-html unformatted    
      '<td text_wrap="true" style="text-align: center;">' + string(v-time) + '</td>' skip
      .                  
    put stream OutStr-html unformatted                   
      '</tr>' skip
      .
    ii =  ii + 1 .
    if ( ( ii modulo 10 ) = 0 ) AND ( ii >= 10 ) then 
    do:
      run waitfram-show in this-procedure ( "Просмотрено строк : " + string( ii ) ) .
    end.

    GET NEXT br-cash-desk. 
  /*vQuery:get-next().*/
            


  END.


  put stream OutStr-html unformatted 
    '</tbody>' skip                                                     
    '</table>' skip
    '</body>' skip
    '</html>' skip                                                                                                                                                                                    
    .                                                                                                    
  output stream OutStr-html close.
        
  run prn-lib-reportviewer-report-name in this-procedure (
    input parparentproc
    ,input v-file-name-rep-htm
    ) .
  if error-status:error then
  do:
    message return-value view-as alert-box.
    return .
  end.

  run waitfram-hide in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
  /*------------------------------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  ------------------------------------------------------------------------------*/
  assign
    tbl      = 'cash-desk'
    join-tbl = 'X_cash-desk'
    fld      = ""
    lab      = ""
    spr      = ""
    dim      = '0'
    .
  run fltfield-add in this-procedure('autonomy', 'Активность', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('db-num', 'БД', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('obj-code', 'Код объекта', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cash-num', 'Номер', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('pos-type', 'Тип POS', 'cd-types-real',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cash-on', 'Вкл', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('addr-path', 'Адрес (путь к кассе)', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('is-del', 'Удал.?', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('registration-code', 'Регистрационный №', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('serial-code', 'Серийный №', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('device-kind', 'Признак исполнения', 'cd-device-kind',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    
  DO on stop undo, leave:
    run gbl/filter.w ( input parparentproc
      ,input (filter-point0 + parref-mode + {&delim-par} +
      filter-label  + {&delim-par} +
      string(yes))
      ,input tbl
      ,input join-tbl
      ,input fld
      ,input lab
      ,input spr
      ,input dim).
    RUN OpenBr in this-procedure ( input yes, input no, input '':U).
  END .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-version Dialog-Frame
PROCEDURE proc-b-version :
  define variable v-uniq-key-rec as character no-undo .
  define variable glog           as logical   no-undo .
  message
    substitute("Проверить и изменить в справочнике касс (если неверная) версию ПО для кассы &1", X_cash-desk.cash-num)
    view-as alert-box question buttons yes-no update glog.
  if not glog then return.
  run gen-key-rec in this-procedure ( input {&table_cash-desk}
    ,input (buffer X_cash-desk:handle)
    ,output v-uniq-key-rec).
  run str/diallog.w ( input parparentproc
    ,input this-procedure
    ,input 'str/get-chkf.p':U
    ,input (v-cntxt-obj-type + {&delim-par} +
    string(v-cntxt-obj-code) + {&delim-par} +
    string(0) + {&delim-par} +  /*p-remote */
    string(0) + {&delim-par} + /*p-shft-close*/
    {&delim-par} +
    {&delim-par} +
    {&delim-par} +
    substitute("&1=version,&2"
    ,X_cash-desk.pos-type
    ,v-uniq-key-rec)
    )
    ,input no
    ,input ''
    ,input 'Получение версии ПО кассы') .
  run OpenBr in this-procedure  ( input yes, input no, input '':U).
END PROCEDURE.

PROCEDURE get-report-num :

  define output parameter p-report-num as integer no-undo .

  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION cash-desk-auto Dialog-Frame
FUNCTION cash-desk-auto RETURNS CHARACTER
  ( p-autonomy AS INTEGER ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
&SCOPED-DEFINE autonomy-code string(p-autonomy)


  RETURN {&cd-autonomy-name}.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION signExecution Dialog-Frame
FUNCTION signExecution RETURNS CHARACTER
  ( INPUT p-device-kind AS INTEGER) :

  return mdevice:GetLabel(integer(p-device-kind)).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-fo-version Dialog-Frame
FUNCTION get-fo-version RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER) :
  DEFINE VARIABLE v-dop        AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-fo-version AS CHARACTER NO-UNDO.
  define variable v-date       as date      no-undo .
  define variable v-decimal    as decimal   no-undo .
  define variable v-integer    as integer   no-undo .
  define variable v-logical    as logical   no-undo .

  run cd-attr-value in this-procedure (
    input   p-db-num
    ,input  p-obj-code
    ,input  p-pos-type
    ,input  p-cash-num
    ,input  (if p-pos-type = {&cd-type-IBM-XML}
    then {&cda-IBM-XML_operative}
    else {&cda-AUTOTANK_operative})
    ,input  (if p-pos-type = {&cd-type-IBM-XML}
    then {&cda-IBM-XML_operative_fo-version}
    else {&cda-AUTOTANK_operative_fo-version})
    ,output v-fo-version
    ,output v-date
    ,output v-decimal
    ,output v-integer
    ,output v-logical
    ,output v-dop) no-error.
  RETURN v-fo-version.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-OptVer Dialog-Frame
FUNCTION get-OptVer RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT p-cash-num AS INTEGER) :
  DEFINE VARIABLE v-dop        AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-OptVer     AS CHARACTER NO-UNDO.
  define variable v-date       as date      no-undo .
  define variable v-decimal    as decimal   no-undo .
  define variable v-integer    as integer   no-undo .
  define variable v-logical    as logical   no-undo .

/*  message p-db-num p-obj-code p-pos-type p-cash-num view-as alert-box. */

  run cd-attr-value in this-procedure (
    input   p-db-num
    ,input  p-obj-code
    ,input  p-pos-type
    ,input  p-cash-num
    ,input  (if p-pos-type = {&cd-type-IBM-XML}
    then {&cda-IBM-XML_operative}
    else {&cda-AUTOTANK_operative})
    ,input  (if p-pos-type = {&cd-type-IBM-XML}
    then {&cda-IBM-XML_operative_OptVer}
    else {&cda-AUTOTANK_operative_OptVer})
    ,output v-OptVer
    ,output v-date
    ,output v-decimal
    ,output v-integer
    ,output v-logical
    ,output v-dop) no-error.
  RETURN v-OptVer.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-ffd-version Dialog-Frame
FUNCTION get-ffd-version RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER) :
  DEFINE VARIABLE v-dop          AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-ffd-version  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-kkt-version  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-ffd-version_ AS CHARACTER NO-UNDO.

  define variable v-date         as date      no-undo .
  define variable v-decimal      as decimal   no-undo .
  define variable v-integer      as integer   no-undo .
  define variable v-logical      as logical   no-undo .
    
  run cd-attr-value in this-procedure (
    input   p-db-num
    ,input  p-obj-code
    ,input  p-pos-type
    ,input  p-cash-num
    ,input  (if p-pos-type = {&cd-type-IBM-XML}
    then {&cda-IBM-XML_operative}
    else {&cda-AUTOTANK_operative})
    ,input  {&cda-IBM-XML_operative_USE_FFD_VERSION}
    ,output v-ffd-version
    ,output v-date
    ,output v-decimal
    ,output v-integer
    ,output v-logical
    ,output v-dop) no-error.

                            
  case v-ffd-version :
    when "0" then 
      do:
        run cd-attr-value in this-procedure (
          input   p-db-num
          ,input  p-obj-code
          ,input  p-pos-type
          ,input  p-cash-num
          ,input  (if p-pos-type = {&cd-type-IBM-XML}
          then {&cda-IBM-XML_operative}
          else {&cda-AUTOTANK_operative})
          ,input  {&cda-IBM-XML_operative_KKT_FFD_VERSION}
          ,output v-kkt-version
          ,output v-date
          ,output v-decimal
          ,output v-integer
          ,output v-logical
          ,output v-dop) no-error.             

        if error-status:error or v-kkt-version = "0" or v-kkt-version = "" then v-ffd-version_ = "авт" .
        else 
        do:
          case v-kkt-version:
            when "2" then 
              v-ffd-version_ = "1.05(авт)" .
            when "3" then 
              v-ffd-version_ = "1.1(авт)" .
            when "4" then 
              v-ffd-version_ = "1.2(авт)" .
          end case.
        end.   
      end.
    when "2" then 
      v-ffd-version_ = "1.05" .
    when "3" then 
      v-ffd-version_ = "1.1" .
    when "4" then 
      v-ffd-version_ = "1.2" .
    otherwise 
    v-ffd-version_ = " - " .
  end case .
  RETURN v-ffd-version_.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-kkt-schema Dialog-Frame
FUNCTION get-kkt-schema RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER) :
  DEFINE VARIABLE v-dop         AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-kkt-schema  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-kkt-schema_ AS CHARACTER NO-UNDO.
  define variable v-date        as date      no-undo .
  define variable v-decimal     as decimal   no-undo .
  define variable v-integer     as integer   no-undo .
  define variable v-logical     as logical   no-undo .
  run cd-attr-value in this-procedure (
    input   p-db-num
    ,input  p-obj-code
    ,input  p-pos-type
    ,input  p-cash-num
    ,input  (if p-pos-type = {&cd-type-IBM-XML}
    then {&cda-IBM-XML_operative}
    else {&cda-AUTOTANK_operative})
    ,input  {&cda-IBM-XML_operative_KKT_SCHEMA}
    ,output v-kkt-schema
    ,output v-date
    ,output v-decimal
    ,output v-integer
    ,output v-logical
    ,output v-dop) no-error.  

  case v-kkt-schema :
    when "0" then 
      v-kkt-schema_ = "с ожиданием ответа" .
    when "1" then 
      v-kkt-schema_ = "без ожидания ответа" .
    otherwise 
    v-kkt-schema_ = " - " .
  end case .          

  RETURN v-kkt-schema_.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-date Dialog-Frame
FUNCTION get-date RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER) :
  DEFINE VARIABLE v-dop             AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-last-date-polls AS CHARACTER NO-UNDO.
  define variable v-date            as date      no-undo .
  define variable v-decimal         as decimal   no-undo .
  define variable v-integer         as integer   no-undo .
  define variable v-logical         as logical   no-undo .

  run cd-attr-value in this-procedure (
    input   p-db-num
    ,input  p-obj-code
    ,input  p-pos-type
    ,input  p-cash-num
    ,input  (if p-pos-type = {&cd-type-IBM-XML}
    then {&cda-IBM-XML_operative}
    else {&cda-AUTOTANK_operative})
    ,input  {&cda-IBM-XML_operative_last-date-polls}
    ,output v-last-date-polls
    ,output v-date
    ,output v-decimal
    ,output v-integer
    ,output v-logical
    ,output v-dop) no-error.  
  RETURN v-last-date-polls.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-time Dialog-Frame
FUNCTION get-time RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER) :
  DEFINE VARIABLE v-dop             AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-last-time-polls AS CHARACTER NO-UNDO.
  define variable v-date            as date      no-undo .
  define variable v-decimal         as decimal   no-undo .
  define variable v-integer         as integer   no-undo .
  define variable v-logical         as logical   no-undo .

  run cd-attr-value in this-procedure (
    input   p-db-num
    ,input  p-obj-code
    ,input  p-pos-type
    ,input  p-cash-num
    ,input  (if p-pos-type = {&cd-type-IBM-XML}
    then {&cda-IBM-XML_operative}
    else {&cda-AUTOTANK_operative})
    ,input  {&cda-IBM-XML_operative_last-time-polls}
    ,output v-last-time-polls
    ,output v-date
    ,output v-decimal
    ,output v-integer
    ,output v-logical
    ,output v-dop) no-error.  

  RETURN v-last-time-polls.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-GISMT_FAST Dialog-Frame
FUNCTION get-GISMT_FAST RETURNS INTEGER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER) :
  DEFINE VARIABLE v-dop               AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-GISMT_FAST_ANSWER AS INTEGER   no-undo init ?.

  find first ub.cash-desk-attr no-lock where ub.cash-desk-attr.attr-code = {&cda-IBM-XML_operative_GISMT_FAST_ANSWER} and
    ub.cash-desk-attr.cash-num = p-cash-num and
    ub.cash-desk-attr.db-num = p-db-num and
    ub.cash-desk-attr.obj-code = p-obj-code no-error .
  if available (ub.cash-desk-attr) then v-GISMT_FAST_ANSWER = integer(ub.cash-desk-attr.attr-value-character) .                                            
        

  RETURN v-GISMT_FAST_ANSWER.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-GISMT_TIMEOUT Dialog-Frame
FUNCTION get-GISMT_TIMEOUT RETURNS INTEGER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER) :
  DEFINE VARIABLE v-dop                   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-GISMT_CHECK_TIMEOUT   AS INTEGER   no-undo init ?.
  DEFINE VARIABLE v-GISMT_OPENCON_TIMEOUT AS INTEGER   no-undo init ?.
  DEFINE VARIABLE v-GISMT_TIMEOUT         AS INTEGER   no-undo init ?.
  find first ub.cash-desk-attr no-lock where ub.cash-desk-attr.attr-code = {&cda-IBM-XML_operative_GISMT_CHECK_TIMEOUT} and
    ub.cash-desk-attr.cash-num = p-cash-num and
    ub.cash-desk-attr.db-num = p-db-num and
    ub.cash-desk-attr.obj-code = p-obj-code no-error .
  if available (ub.cash-desk-attr) then v-GISMT_CHECK_TIMEOUT = integer(ub.cash-desk-attr.attr-value-character) .                                            

  find first ub.cash-desk-attr no-lock where ub.cash-desk-attr.attr-code = {&cda-IBM-XML_operative_GISMT_OPENCON_TIMEOUT} and
    ub.cash-desk-attr.cash-num = p-cash-num and
    ub.cash-desk-attr.db-num = p-db-num and
    ub.cash-desk-attr.obj-code = p-obj-code no-error .
  if available (ub.cash-desk-attr) then v-GISMT_OPENCON_TIMEOUT = integer(ub.cash-desk-attr.attr-value-character) .        

  v-GISMT_TIMEOUT = v-GISMT_OPENCON_TIMEOUT + v-GISMT_CHECK_TIMEOUT .
  RETURN v-GISMT_TIMEOUT.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME