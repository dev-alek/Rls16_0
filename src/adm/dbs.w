&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-db 
/*

$Revision: 19b15f56f81d, 2201, rls $
$Author: druban $
$Date: Wed Dec 25 15:23:58 2019 +0300 $
$Workfile: dbs.w $
$Archive: adm/dbs.w $

Справочник баз данных

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/27/02
Author: Dmitry Ukhanov
Creation date: 03/27/02

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-mode as char  no-undo.        /* "{&lookup}, {&update}" */
define output parameter rid  as recid no-undo init ?. /* выбранная запись */

define variable vss-revision    as character no-undo init "$Revision: 19b15f56f81d, 2201, rls $":u .
define variable vss-author      as character no-undo init "$Author: druban $":u .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:23:58 2019 +0300 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: dbs.w $":u .
define variable vss-archive     as character no-undo init "$Archive: adm/dbs.w $":u .
define variable vss-description as character no-undo init "Справочник баз данных" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/waitfram.i }
{ gbl/cur-time.i }
{ gbl/key-rec.i  }
{ adm/db-key.i   }
{ adm/unloaddb.i }
{ nws/check-tc.i }
{ cmp/library.i  }
{ gbl/thbjattr.i }
{ adm/shattrg.i  db }
{ nws/lib-nws.i  }

/* Local Variable Definitions ---                                       */
define buffer buf_sys-ctrl for ub.sys-ctrl .

define variable log-res       as logical   no-undo .
define variable v-rowid       as rowid     no-undo .
define variable v-type-unload as character no-undo .
DEFINE VARIABLE hn-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE attr-option AS CHARACTER NO-UNDO.
define variable select-list       as longchar  no-undo .


&scop my-refresh ~
  assign ~
    log-res = browse br-db :set-repositioned-row( browse br-db :focused-row, 'CONDITIONAL':u) ~
    v-rowid = rowid( ub.db ) ~
  . ~
  ~{&open-query-br-db~} ~
  reposition br-db to rowid v-rowid no-error. ~
  apply "ENTRY":U to br-db. ~
  apply "VALUE-CHANGED":U to br-db. ~

define variable v-str as character no-undo .
define variable v-ind as integer   no-undo .
define frame f-info
  v-str format "x(50)" NO-LABEL skip
  v-ind label "Записей" format ">>>>>>>>9" skip
  with view-as dialog-box side-labels 1 columns three-d title ""
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-db
&Scoped-define BROWSE-NAME br-clients

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.clients ub.db

/* Definitions for BROWSE br-clients                                    */
&Scoped-define FIELDS-IN-QUERY-br-clients ub.clients.obj-type ~
ub.clients.obj-code ub.clients.obj-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-clients
&Scoped-define QUERY-STRING-br-clients FOR EACH ub.clients ~
      WHERE clients.db-num = ub.db.db-num ~
 NO-LOCK
&Scoped-define OPEN-QUERY-br-clients OPEN QUERY br-clients FOR EACH ub.clients ~
      WHERE clients.db-num = ub.db.db-num ~
 NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-clients ub.clients
&Scoped-define FIRST-TABLE-IN-QUERY-br-clients ub.clients


/* Definitions for BROWSE br-db                                         */
&Scoped-define FIELDS-IN-QUERY-br-db ub.db.db-num ub.db.db-name ~
ub.db.add-clients ub.db.add-goods ub.db.remote-stock ub.db.send-check ~
ub.db.on-line-rest ub.db.max-p-queue ub.db.max-p-time ub.db.max-p-size ~
ub.db.db-key ub.db.stts get-infodb-date( ub.db.db-num) get-infodb-ver( ub.db.db-num)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-db
&Scoped-define QUERY-STRING-br-db FOR EACH ub.db NO-LOCK
&Scoped-define OPEN-QUERY-br-db OPEN QUERY br-db FOR EACH ub.db NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-db ub.db
&Scoped-define FIRST-TABLE-IN-QUERY-br-db ub.db


/* Definitions for DIALOG-BOX d-db                                      */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-db ~
    ~{&OPEN-QUERY-br-db}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-sel b-lkp b-chg b-add b-unld b-del ~
b-unld-list b-print b-hist b-help b-mark b-sel-all b-unmark b-attr b-param ~
b-send b-hn br-db br-clients 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-infodb-date d-db 
FUNCTION get-infodb-date RETURNS DATE
  ( INPUT p-db-num as integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-infodb-ver d-db
FUNCTION get-infodb-ver RETURNS character 
  ( INPUT p-db-num as integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

function get-mark returns character
  (buffer local-db for ub.db ):
  if lookup (string (recid (local-db)), select-list) > 0  then return "*".
  else return "".
end function.


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-hn 
       MENU-ITEM m_hn-lookup    LABEL "Просмотр"      
       MENU-ITEM m_hn-update    LABEL "Изменить"      
       MENU-ITEM m_hn-copy      LABEL "Копировать"    .

DEFINE MENU MENU-b-param 
       MENU-ITEM m_lookup       LABEL "Просмотр"      
       MENU-ITEM m_update       LABEL "Изменение"     
       MENU-ITEM m_copy         LABEL "Копирование"   .

DEFINE MENU POPUP-MENU-b-print 
       MENU-ITEM m_b-print-RC LABEL "Отчет по версиям RC на БД"
       MENU-ITEM m_b-print-hist LABEL "Историческая справка по версиям RC на выбранной БД"  
       .

DEFINE MENU POPUP-MENU-b-unld 
       MENU-ITEM m_online-unload LABEL "online-выгрузка" ACCELERATOR "в"
       MENU-ITEM m_prep-copy    LABEL "Подготовка копии" ACCELERATOR "к".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
     LABEL "&Создать" 
     SIZE 10 BY 1.

DEFINE BUTTON b-attr 
     LABEL "&Атрибуты" 
     SIZE 10 BY 1.

DEFINE BUTTON b-chg 
     LABEL "&Изменить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-del 
     LABEL "У&далить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-help 
     LABEL "Помо&щь":L 
     SIZE 3 BY 1.

DEFINE BUTTON b-hist 
     LABEL "Ис&тория":L 
     SIZE 3 BY 1.

DEFINE BUTTON b-hn 
     LABEL "Ист+маршр" 
     SIZE 10 BY 1.

DEFINE BUTTON b-lkp 
     LABEL "&Просмотр" 
     SIZE 10 BY 1.

DEFINE BUTTON b-print 
     LABEL "Печать" 
     SIZE 3 BY 1.
     
DEFINE BUTTON b-param
     LABEL "Парамет&ры"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
     LABEL "Вы&бор ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-send
     LABEL "&Остатки"
     SIZE 10 BY 1.

DEFINE BUTTON b-turn-off 
     LABEL "От&ключить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-unld 
     LABEL "Вы&грузка" 
     SIZE 10 BY 1.
     
DEFINE BUTTON b-unld-list
     LABEL "&Мультивыгрузка"
     SIZE 15 BY 1
     tooltip "Выгрузка УБД по списку из онлайн-копии" .
     
define button b-mark 
  label "&*" 
  size 3 by 1.13.
  
define button b-sel-all 
  label "&+":L 
  size 3 by 1.13 tooltip "Отметить все БД".
  
define button b-unmark 
  label "&-":L 
  size 3 by 1.13 tooltip "Снять все отметки".

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-clients FOR
      ub.clients SCROLLING.

DEFINE QUERY br-db FOR
      ub.db SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-clients
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-clients d-db _STRUCTURED
  QUERY br-clients NO-LOCK DISPLAY
      clients.obj-type FORMAT "X(3)":U
      clients.obj-code FORMAT ">>>>>>>>9":U
      clients.obj-name COLUMN-LABEL "Название" FORMAT "X(40)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 35.13 BY 16.5
         TITLE "Объекты БД".

DEFINE BROWSE br-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-db d-db _STRUCTURED
  QUERY br-db NO-LOCK DISPLAY
      get-mark(BUFFER ub.db) column-label "*"  format "X(1)":U
      ub.db.db-num FORMAT ">>>>>>>>9":U
      ub.db.db-name FORMAT "X(25)":U
      ub.db.add-clients COLUMN-LABEL "Клиенты" FORMAT "+/-":U
      ub.db.add-goods COLUMN-LABEL "Товары" FORMAT "+/-":U
      ub.db.remote-stock COLUMN-LABEL "Чужие" FORMAT "+/-":U
      ub.db.send-check COLUMN-LABEL "Чеки" FORMAT "+/-":U
      ub.db.on-line-rest COLUMN-LABEL "Мгнов" FORMAT "+/-":U
      ub.db.max-p-queue COLUMN-LABEL "Неподтв" FORMAT "->>>9":U
      ub.db.max-p-time FORMAT ">>>>>9":U
      ub.db.max-p-size FORMAT ">>>,>>9":U
      ub.db.db-key FORMAT "X(12)":U
      ub.db.reserve1-char COLUMN-LABEL "БД вер." FORMAT "X(12)":U
      ub.db.stts FORMAT "->>>>>>9":U
      get-infodb-date( ub.db.db-num) COLUMN-LABEL "Дата!актуальности!инф. о БД" FORMAT "99/99/9999":U
      get-infodb-ver ( ub.db.db-num) COLUMN-LABEL "Версия r кодов." FORMAT "X(30)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 62 BY 16.5
         TITLE "Базы данных".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-db
     b-quit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 11
     b-lkp AT ROW 1 COL 21
     b-chg AT ROW 1 COL 31
     b-add AT ROW 1 COL 41
     b-unld AT ROW 1 COL 51
     b-del AT ROW 1 COL 61
     b-unld-list AT ROW 1 COL 71
     b-print AT ROW 1 COL 88.88 WIDGET-ID 62
     b-hist AT ROW 1 COL 92 WIDGET-ID 10
     b-help AT ROW 1 COL 95
     b-mark AT ROW 2 COL 1
     b-sel-all AT ROW 2 COL 4
     b-unmark AT ROW 2 COL 7
     b-attr AT ROW 2 COL 21
     b-param AT ROW 2 COL 31 WIDGET-ID 4
     b-send AT ROW 2 COL 41
     b-hn AT ROW 2 COL 51
     b-turn-off AT ROW 2 COL 61 WIDGET-ID 2
     br-db AT ROW 3.5 COL 1
     br-clients AT ROW 3.5 COL 63.5
     SPACE(0.36) SKIP(0.26)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Базы данных":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-db
   FRAME-NAME                                                           */
/* BROWSE-TAB br-db b-turn-off d-db */
/* BROWSE-TAB br-clients br-db d-db */
ASSIGN 
       FRAME d-db:SCROLLABLE       = FALSE.

ASSIGN 
       b-hn:POPUP-MENU IN FRAME d-db       = MENU MENU-b-hn:HANDLE.

ASSIGN 
       b-param:POPUP-MENU IN FRAME d-db       = MENU MENU-b-param:HANDLE.

ASSIGN 
       b-print:POPUP-MENU IN FRAME d-db       = MENU POPUP-MENU-b-print:HANDLE.
ASSIGN b-print :MENU-MOUSE = 1.
/* SETTINGS FOR BUTTON b-turn-off IN FRAME d-db
   NO-ENABLE                                                            */
ASSIGN 
       b-turn-off:HIDDEN IN FRAME d-db           = TRUE.

ASSIGN 
       b-unld:POPUP-MENU IN FRAME d-db       = MENU POPUP-MENU-b-unld:HANDLE.

ASSIGN 
       br-db:NUM-LOCKED-COLUMNS IN FRAME d-db     = 1.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-clients
/* Query rebuild information for BROWSE br-clients
     _TblList          = "ub.clients"
     _Options          = "NO-LOCK"
     _Where[1]         = "clients.db-num = ub.db.db-num
"
     _FldNameList[1]   = ub.clients.obj-type
     _FldNameList[2]   = ub.clients.obj-code
     _FldNameList[3]   > ub.clients.obj-name
"clients.obj-name" "Название" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is NOT OPENED
*/  /* BROWSE br-clients */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-db
/* Query rebuild information for BROWSE br-db
     _TblList          = "ub.db"
     _Options          = "NO-LOCK"
     _FldNameList[1]   = ub.db.db-num
     _FldNameList[2]   > ub.db.db-name
"db.db-name" ? "X(25)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > ub.db.add-clients
"db.add-clients" "Клиенты" "+/-" "logical" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > ub.db.add-goods
"db.add-goods" "Товары" "+/-" "logical" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > ub.db.remote-stock
"db.remote-stock" "Чужие" "+/-" "logical" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > ub.db.send-check
"db.send-check" "Чеки" "+/-" "logical" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > ub.db.on-line-rest
"db.on-line-rest" "Мгнов" "+/-" "logical" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > ub.db.max-p-queue
"db.max-p-queue" "Неподтв" "->>9" "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   > ub.db.max-p-time
"db.max-p-time" ? ">>>>>9" "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[10]   = ub.db.max-p-size
     _FldNameList[11]   > ub.db.db-key
"db.db-key" ? "X(12)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[12]   = ub.db.stts
     _FldNameList[13]   > "_<CALC>"
"get-infodb-date( ub.db.db-num)" "Дата!актуальности!инф. о БД" "99/99/9999" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
"get-infodb-ver ( ub.db.db-num)" "Версия r кодов" "x(30)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no

     _Query            is OPENED
*/  /* BROWSE br-db */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-db
ON CHOOSE OF b-add IN FRAME d-db /* Создать */
DO:
  define variable v-unload-history as logical no-undo .
  define buffer buf-new_db for ub.db .
  assign
    rid = ?
  .
  run adm/dbi.w ( input "add"
             ,input-output rid
             ,output v-unload-history
            ) no-error .
  if error-status :error
  or rid = ?
  then do:
    return no-apply.
  end.
  {&open-query-br-db}
  reposition br-db to recid rid.
  apply "ENTRY" to br-db.
  apply "VALUE-CHANGED":U to br-db.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-attr d-db
ON CHOOSE OF b-attr IN FRAME d-db /* Атрибуты */
DO:
 IF NOT AVAILABLE ub.db THEN RETURN NO-APPLY.
  run adm/db-atti.w ( INPUT parparentproc
                     ,INPUT {&LOOKUP}
                     ,INPUT ub.db.db-num ) NO-ERROR.
  IF ERROR-STATUS:error THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg d-db
ON CHOOSE OF b-chg IN FRAME d-db /* Изменить */
DO:
define variable v-unload-history as logical no-undo .
  if not available ub.db
  then do:
    message
      "Неправильно выбрана строка."
      view-as alert-box .
    return no-apply.
  end.
  rid = recid (db).
  run adm/dbi.w ( input "upd"
             ,input-output rid
             ,output v-unload-history
            ) no-error .

  {&my-refresh}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del d-db
ON CHOOSE OF b-del IN FRAME d-db /* Удалить */
DO:
  define buffer buf_db for ub.db .

  define variable v-log as logical no-undo .

  if not available ub.db
  then do:
    message
      "Не выбрана БД для удаления."
      view-as alert-box .
    return no-apply.
  end.

  find first buf_db exclusive-lock
    where buf_db.db-num = ub.db.db-num
    no-error
  .
  if not available buf_db
  then do:
    message
      substitute( "БД &1 уже удалена.", ub.db.db-num ) skip
      view-as alert-box information
    .
  end.
  else do:
    if buf_db.db-num = 0
    then do:
      message
        "Нельзя удалить ГБД !!!"
        view-as alert-box error.
      return no-apply.
    end.

    assign
      v-log = false
    .
    message
      substitute( "Вы действительно хотите удалить БД &1?",  buf_db.db-num )
      view-as alert-box question buttons yes-no update v-log.
    if v-log = false
    then do:
      return no-apply.
    end.

    delete buf_db no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при удалении БД" ) skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
      return no-apply .
    end.
  end.

  {&my-refresh}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist d-db
ON CHOOSE OF b-hist IN FRAME d-db /* История */
DO:
   if available ub.db then do:
    run adm/db-hist.w
      ( input parparentproc
      , input ub.db.db-num
      ).
   end.
  apply "entry" to browse {&browse-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hn d-db
ON CHOOSE OF b-hn IN FRAME d-db /* Ист+маршр */
DO:
 IF hn-option = '':U THEN DO:
    run gbl/pop-up.p ( INPUT self:handle, INPUT no) NO-ERROR.
  END.
  IF hn-option = '':U THEN RETURN NO-APPLY.

  RUN proc-hn IN THIS-PROCEDURE ( INPUT hn-option).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp d-db
ON CHOOSE OF b-lkp IN FRAME d-db /* Просмотр */
DO:
define variable v-unload-history as logical no-undo .
  define buffer buf_db for ub.db .

  if not available ub.db
  then do:
    message
      "Неправильно выбрана строка."
      view-as alert-box .
    return no-apply.
  end.

  rid = recid (db).
  run adm/dbi.w
    ( input "lkp"
    , input-output rid
    , output v-unload-history
    ) no-error .

  {&my-refresh}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark d-db
ON choose OF b-mark IN FRAME d-db /* * */
do:
    
    run proc-b-mark in this-procedure no-error.

  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print d-db
ON CHOOSE OF b-print IN FRAME d-db /* Печать */
DO:
      run gbl/pop-up.p (self:handle, no) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit d-db
ON CHOOSE OF b-quit IN FRAME d-db /* Выход  */
DO:
  assign
    rid = ?.
  .

END.

&Scoped-define SELF-NAME b-param
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-param d-db
ON CHOOSE OF b-param IN FRAME d-db /* Параметры */
DO:
define variable v-param as character no-undo .
define variable v-db-num like ub.db.db-num no-undo .
if not available ub.db then return no-apply.

if attr-option = '':U then do:
   run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if attr-option = '':U then return no-apply.
if attr-option = {&update}
or attr-option = {&add-copy}
then do:
  if buf_sys-ctrl.db-num <> 0
  then do:
    if ub.db.db-num <> buf_sys-ctrl.db-num then do:
      message
      "Нельзя менять параметры в чужой БД"
      view-as alert-box error .
      return no-apply.
    end.
  end.
end.
run proc-b-attrdb in this-procedure (
                                    input attr-option
                                   ,input {&db}
                                   ,input ub.db.db-num) no-error .
if error-status:error then do:
  assign
  attr-option = "":u.
  return no-apply.
end.
attr-option = "":u.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-db
ON CHOOSE OF b-sel IN FRAME d-db /* Выбор  */
DO:
  define buffer buf_db for ub.db .

  find first buf_db no-lock
    where buf_db.db-num = ub.db.db-num
    no-error
  .
  if available buf_db
  then do:
    assign
      rid = recid (db).
    .
  end.
  else do:
    message
      substitute( "БД &1 удалена", ub.db.db-num )
      view-as alert-box information
    .
    {&my-refresh}
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-all d-db
ON choose OF b-sel-all IN FRAME d-db /* + */
do:
    assign 
      select-list = "".
    if not available ub.db then return.
    for each ub.db no-lock :
      { gbl/markstrn.i ub.db select-list }
    end.
    br-db:refresh() in frame {&frame-name} .
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-send
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-send d-db
ON CHOOSE OF b-send IN FRAME d-db /* Остатки */
DO:
  if not available ub.db
  then do:
    message
      "Неправильно выбрана строка."
      view-as alert-box .
    return no-apply.
  end.

  run trg/sendrest.p
    (input ub.db.db-num
    ) no-error .

  {&my-refresh}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-turn-off
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-turn-off d-db
ON CHOOSE OF b-turn-off IN FRAME d-db /* Отключить */
DO:
  define buffer buf_db for ub.db .
  define buffer buf_pck-sent for ub.pck-sent .
  define buffer buf_pck-rcvd for ub.pck-rcvd .
  define buffer buf_route for ub.route .

  define variable v-log as logical no-undo .

  if not available ub.db then do:
    message
      "Не выбрана БД."
      view-as alert-box .
    return no-apply.
  end.

  if ub.db.db-num = 0 then do:
    message
      "Нельзя отключить СПН для ГБД."
      view-as alert-box.
    return no-apply.
  end.

  if transaction then do:
    message
      vss-workfile vss-revision vss-description skip
      "Действует транзакция!" skip
      "Выполнение действия недопустимо!" skip
      view-as alert-box error.
    undo, return no-apply .
  end.

  assign
    v-log = false
  .
  if db.db-key = "":U
    or db.db-key = ?
  then do:
    message
      substitute( "СПН для БД &1 уже отключена!",  db.db-num )
      substitute( "Вы хотите удалить записи маршрутизации для БД &1?",  db.db-num )
        view-as alert-box question buttons yes-no update v-log.
    if v-log = false then do:
      return no-apply.
    end.
  end.
  else do:
    message
      substitute( "Восстановить обмен пакетами с УБД можно будет только ВЫГРУЗИВ ее!!!" ) skip
      substitute( "Вы действительно хотите отключить СПН для БД &1?",  db.db-num )
        view-as alert-box question buttons yes-no update v-log.
    if v-log = false then do:
      return no-apply.
    end.

    assign
      v-log = false
    .

    run gbl/authoriz.p
      (input "Run information dialog"
      ,output v-log
      ).
  end.

  if v-log = true then do:
    do transaction
    on error  undo, return no-apply
    on stop   undo, return no-apply
    on endkey undo, return no-apply
    :
      find first buf_db exclusive-lock
        where buf_db.db-num = db.db-num
        no-error
      .
      if not available buf_db then do:
        message
          substitute( "БД &1 удалена.", db.db-num ) skip
          view-as alert-box information
        .
        return no-apply .
      end.
      assign
        buf_db.db-key     = "":U
        buf_db.db-key-enc = "":U
      .
    end.
    view frame f-info.
    assign
      v-ind = 0
    .
    for each buf_pck-sent
      where buf_pck-sent.db-num = db.db-num
        and buf_pck-sent.rcvd   = false
    on error  undo, return no-apply
    on stop   undo, return no-apply
    on endkey undo, return no-apply
    :
      assign
        buf_pck-sent.rcvd = true
        v-ind = v-ind + 1
      .
      do with frame f-info
      :
        assign
          v-ind :screen-value   = string( v-ind, v-ind :format)
          v-str :screen-value   = string( "Подтверждение отправленных пакетов", v-str :format)
        .
      end.
    end.
    assign
      v-ind = 0
    .
    for each buf_pck-rcvd
      where buf_pck-rcvd.db-num = db.db-num
        and buf_pck-rcvd.rcvd   = false
    on error  undo, return no-apply
    on stop   undo, return no-apply
    on endkey undo, return no-apply
    :
      assign
        buf_pck-rcvd.rcvd = true
        v-ind = v-ind + 1
      .
      do with frame f-info
      :
        assign
          v-ind :screen-value   = string( v-ind, v-ind :format)
          v-str :screen-value   = string( "Подтверждение полученных пакетов", v-str :format)
        .
      end.
    end.
    assign
      v-ind = 0
    .
    for each buf_route
      where buf_route.db-num = db.db-num
    on error  undo, return no-apply
    on stop   undo, return no-apply
    on endkey undo, return no-apply
    :
      delete buf_route .
      assign
        v-ind = v-ind + 1
      .
      do with frame f-info
      :
        assign
          v-ind :screen-value   = string( v-ind, v-ind :format)
          v-str :screen-value   = string( "Удаление маршрутизации", v-str :format)
        .
      end.
    end.
    hide frame f-info.

    message
      substitute( "СПН для БД &1 отключена.", ub.db.db-num )
      view-as alert-box information.
  end.

  {&my-refresh}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-unld
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-unld d-db
ON CHOOSE OF b-unld IN FRAME d-db /* Выгрузка */
DO:
  define buffer buf-new_db      for ub.db .
  define buffer buf-chk_db      for ub.db .
  define buffer buf_clients     for ub.clients .

  define variable v-log  as logical   no-undo .
  define variable v-lock as logical   no-undo .
  define variable v-msg  as character no-undo .
  define variable v-ok   as logical   no-undo .

  if  v-type-unload = "":U
  and buf_sys-ctrl.status_ = {&sttsDB-copy}
  then do:
    assign
      v-type-unload = {&unload-copy}
    .
  end.

  case v-type-unload :
    when {&unload-online} or
    when {&unload-copy}
    then do:
      if not available ub.db
      then do:
        message
          "Не выбрана БД для выгрузки."
          view-as alert-box .
        return no-apply.
      end.
      assign
        rid = recid (db)
      .
      if db.db-num = 0
      then do:
        message
          "Нельзя выгрузить ГБД!!!"
          view-as alert-box error.
        return no-apply.
      end.

      define variable v-can-unload as logical   no-undo .
      define variable v-message    as character no-undo .

      run adm/unlddbck.p
        (input  db.db-num
        ,output v-can-unload
        ,output v-message
        ) .
      if v-can-unload <> true
      then do:
        message
          "Нельзя произвести выгрузку базы данных" skip
          "База данных" db.db-num skip
          v-message skip
          view-as alert-box error.
      end.
      else do:
        if v-type-unload = {&unload-copy}
        and ( db.db-key = "":U
              or db.db-key = ?
            )
        then do:
          message
            "Из копии нельзя выгрузить БД не имеющую ключа!!!"
            view-as alert-box error.
        end.
        else do:
          run fill-two-commit-command in this-procedure.
          find first temp_db-rec-attr
            where temp_db-rec-attr.db-num = ?
            no-error .
          if available temp_db-rec-attr
          then do:
            message
              vss-workfile vss-revision vss-description skip
              substitute( "Нельзя выгрузить БД!" ) skip
              substitute( "Есть незавершенные распределенные команды при которых выгрузка недопустима!" ) skip
              view-as alert-box error
            .
          end.
          else do:
            assign
              v-log = FALSE
            .
            message
              "При выгрузке необходимо задать НОВЫЙ ключ БД." skip
              "Продолжить?"
              view-as alert-box question buttons yes-no update v-log
            .
            if not v-log
            then do:
              return no-apply.
            end.

            run adm/unload-m.p
              (input  db.db-num
              ) no-error.

            run adm/unloaddc.p
              no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                substitute( "Не удалось отключить БД" ) skip
                return-value skip
                error-status :get-message ( error-status :num-messages )
                view-as alert-box error .
            end.

            assign
              v-lock = true
            .
            { nws/lock-rt.i
              "'unlock'"
              ub.db.db-num
              0
              "''"
              v-msg
              v-lock
              v-ok
              no-error
            }
            if error-status :error
            or v-lock = true
            or v-ok   = false
            then do:
              message
                vss-workfile vss-revision vss-description skip
                substitute( "&1", v-msg ) skip
                return-value skip
                error-status :get-message ( error-status :num-messages )
                view-as alert-box error
              .
              return no-apply.
            end.
          end.
        end.
      end.
    end.
    when {&prep-copy}
    then do:

      assign
        v-msg = "":U
      .

      for each buf-chk_db
      on error undo, return no-apply
      :
        if buf-chk_db.db-key = "":U
        or buf-chk_db.db-key = ?
        then do:
          assign
            v-msg = v-msg + " ":U + string( buf-chk_db.db-num )
          .
        end.
      end.
      if v-msg <> "":U
      then do:
        message
          substitute( "Из копии нельзя будет выгрузить БД &1", v-msg ) skip
          substitute( "Продолжить подготовку копии?" ) skip
          view-as alert-box question buttons yes-no update v-ok .
        if v-ok <> true
        then do:
          return no-apply.
        end.
      end.
      run adm/copyprep.w
        ( input parparentproc
        , output v-log
        ) no-error.
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Ошибка при подготовке копии ГБД!" ) skip
          return-value skip
          error-status :get-message ( error-status :num-messages )
          view-as alert-box error
        .
        return no-apply .
      end.
      if v-log = true
      then do:
        message
          substitute( "Копия ГБД подготовлена!" )
          view-as alert-box information
        .
      end.
      else do:
        message
          substitute( "Копия ГБД НЕ ПОДГОТОВЛЕНА!" ) skip
          return-value skip
          view-as alert-box error
        .
        return no-apply .
      end.
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( 'Нет обработки "&1"', v-type-unload ) skip
        view-as alert-box error
      .
      return no-apply .
    end.
  end case.

  {&my-refresh}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-unld-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-unld-list d-db
ON CHOOSE OF b-unld-list IN FRAME d-db /* Мультивыгрузка */
DO:
  define buffer buf-new_db      for ub.db .
  define buffer buf-lst_db      for ub.db .
  define buffer buf_clients     for ub.clients .

  define variable v-log  as logical   no-undo .
  define variable v-lock as logical   no-undo .
  define variable v-msg  as character no-undo .
  define variable v-ok   as logical   no-undo .
  define variable v-ii   as integer   no-undo .
  define variable v-list as character no-undo .
  
  if trim(select-list) = ""
  then do :
    message "Не отмечена ни одна БД." view-as alert-box .
    return no-apply .
  end.

  assign
    v-type-unload = {&unload-online}
  .
  
  run fill-two-commit-command in this-procedure.
  
  do v-ii = 1 to num-entries (select-list):
    v-list = entry(v-ii, select-list) no-error .

    find first buf-lst_db where recid(buf-lst_db) = integer(v-list) .
    if buf-lst_db.db-num = 0
    then do:
      message
        "Нельзя выгрузить ГБД!!!"
        view-as alert-box error.
      return no-apply.
    end.

    define variable v-can-unload as logical   no-undo .
    define variable v-message    as character no-undo .

    run adm/unlddbck.p
      (input  buf-lst_db.db-num
      ,output v-can-unload
      ,output v-message
      ) .
    if v-can-unload <> true
    then do:
      message
        "Нельзя произвести выгрузку базы данных" skip
        "База данных" db.db-num skip
        v-message skip
        view-as alert-box error.
    end.
    find first temp_db-rec-attr
      where temp_db-rec-attr.db-num = ?
      no-error .
    if available temp_db-rec-attr
    then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Нельзя выгрузить БД!" ) skip
        substitute( "Есть незавершенные распределенные команды при которых выгрузка недопустима!" ) skip
        view-as alert-box error
      .
    end.
  end .
  
  assign
    v-log = FALSE
  .
  message
    "При выгрузке необходимо задать НОВЫЙ ключ БД." skip
    "Продолжить?"
    view-as alert-box question buttons yes-no update v-log
  .
  if not v-log
  then do:
    return no-apply.
  end.

  run adm/unload-m2.p
    (input  select-list
    ) no-error.
  if return-value = "not-create":U
  then do :
    return no-apply .
  end.

  run adm/unloaddc.p
    no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Не удалось отключить БД" ) skip
      return-value skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error .
  end.
  
  do v-ii = 1 to num-entries (select-list):
    v-list = entry(v-ii, select-list) no-error .

    find first buf-lst_db where recid(buf-lst_db) = integer(v-list) .

    assign
      v-lock = true
    .
    { nws/lock-rt.i
      "'unlock'"
      buf-lst_db.db-num
      0
      "''"
      v-msg
      v-lock
      v-ok
      no-error
    }
    if error-status :error
    or v-lock = true
    or v-ok   = false
    then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "&1", v-msg ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
      return no-apply.
    end.
  
  end.   

  {&my-refresh}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-unmark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-unmark d-db
ON choose OF b-unmark IN FRAME d-db /* - */
do:
    select-list  = "".
    br-db:refresh() in frame {&frame-name} .
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-db
&Scoped-define SELF-NAME br-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-db d-db
ON DEFAULT-ACTION OF br-db IN FRAME d-db /* Базы данных */
DO:
  case p-mode:
    when {&lookup}
    then do:
      apply "CHOOSE" to b-sel.
    end.
    when {&update}
    then do:
      if buf_sys-ctrl.db-num = 0
      then do:
        apply "CHOOSE" to b-chg.
      end.
      else do:
        apply "CHOOSE" to b-lkp.
      end.
    end.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-db d-db
ON RETURN OF br-db IN FRAME d-db /* Базы данных */
DO:
  apply "default-action" to b-sel.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-db d-db
ON VALUE-CHANGED OF br-db IN FRAME d-db /* Базы данных */
DO:
  if available ub.db
  then do:
    assign
      rid = recid (db)
    .
    {&open-query-br-clients}
  end.
 END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_b-print-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_b-print-list d-db
ON CHOOSE OF MENU-ITEM m_b-print-RC /*  */
DO:
  run rep/printRC.w (parparentproc).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_b-print-prava
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_b-print-prava d-db
ON CHOOSE OF MENU-ITEM m_b-print-hist /*  */
DO:
  
run rep/histRC.w (parparentproc, string (select-list)).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_copy d-db
ON CHOOSE OF MENU-ITEM m_copy /* Копирование */
DO:
    assign
  attr-option = {&add-copy}.
  APPLY "CHOOSE" to b-param  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_hn-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_hn-copy d-db
ON CHOOSE OF MENU-ITEM m_hn-copy /* Копировать */
DO:
  RUN proc-hn IN THIS-PROCEDURE ( INPUT {&ADD-COPY}) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:

      RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_hn-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_hn-lookup d-db
ON CHOOSE OF MENU-ITEM m_hn-lookup /* Просмотр */
DO:
    RUN proc-hn IN THIS-PROCEDURE ( INPUT {&LOOKUP}) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:

      RETURN NO-APPLY.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_hn-update
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_hn-update d-db
ON CHOOSE OF MENU-ITEM m_hn-update /* Изменить */
DO:
  RUN proc-hn IN THIS-PROCEDURE ( INPUT {&UPDATE}) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:

      RETURN NO-APPLY.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_lookup d-db
ON CHOOSE OF MENU-ITEM m_lookup /* Просмотр */
DO:
    assign
  attr-option = {&lookup}.
  APPLY "CHOOSE" to b-param  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_online-unload
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_online-unload d-db
ON CHOOSE OF MENU-ITEM m_online-unload /* online-выгрузка */
DO:
  assign
    v-type-unload = {&unload-online}
  .
  apply "choose" to b-unld in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_prep-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_prep-copy d-db
ON CHOOSE OF MENU-ITEM m_prep-copy /* Подготовка копии */
DO:
  assign
    v-type-unload = {&prep-copy}
  .
  apply "choose" to b-unld in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_update
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_update d-db
ON CHOOSE OF MENU-ITEM m_update /* Изменение */
DO:
    assign
  attr-option = {&update}.
  APPLY "CHOOSE" to b-param in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-clients
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-db 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/app_help.i &disable_diasize=true }

{ gbl/diasize.i &browse-name="br-db" }

run diasize_add_browse in this-procedure
  (input  'height':u
  ,input  browse br-clients :handle
  ) .
run diasize_init in this-procedure .

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  find first buf_sys-ctrl no-lock .
  RUN MyEnable IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus b-quit.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-db  _DEFAULT-DISABLE
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
  HIDE FRAME d-db.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable d-db
PROCEDURE MyEnable :
define variable v-userid       as character no-undo .
  define variable v-curr-db-num  as integer   no-undo .
  define variable v-curr-user-id as character no-undo .
  define variable v-user-admin   as logical   no-undo .

  ENABLE
    b-quit
    b-hist
    b-help
    br-db
    br-clients
    b-lkp
    b-print
    b-attr when valid-handle( parparentproc )
    b-param when valid-handle( parparentproc )
    b-hn when valid-handle( parparentproc )
    with frame {&frame-name}.
  b-hn:menu-mouse in frame {&frame-name} = 1.
  b-param:menu-mouse in frame {&frame-name} = 1.

  if p-mode = {&update}
  then do:
    if buf_sys-ctrl.db-num = 0
    then do:
      enable
        b-chg
        b-send
        b-add
        b-unld
        b-del
        b-mark
        b-sel-all
        b-unmark
        b-unld-list
        with frame {&frame-name}.
      assign
        b-unld:menu-mouse = 1
      .
      if buf_sys-ctrl.status_ = {&sttsDB-copy}
      then do:
        assign
          b-unld:popup-menu = ?
        .
      end.
      { gbl/getcurus.i
        v-curr-db-num
        v-curr-user-id
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении текущей базы и текущего пользователя" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      { gbl/user-adm.i
        v-curr-db-num
        v-curr-user-id
        v-user-admin
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении является ли пользователем администратор" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if v-user-admin = true then do:
        enable
          b-turn-off
          with frame {&frame-name}.
      end.

      menu-item m_hn-copy:sensitive in menu menu-b-hn = (buf_sys-ctrl.db-num = 0).
    end.
  end. /*if p-mode = {&update}*/
  else do:
    enable
      b-sel
      with frame {&frame-name}.
    assign
      menu-item m_hn-update:sensitive in menu menu-b-hn = no
      menu-item m_hn-copy:sensitive in menu menu-b-hn = no
    .
  end.
  {&OPEN-BROWSERS-IN-QUERY-d-db}
  apply "VALUE-CHANGED":U to br-db.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-hn d-db
PROCEDURE proc-hn :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
DEFINE variable v-rid AS RECID NO-UNDO.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

DEFINE BUFFER buf_db FOR ub.db.
DEFINE BUFFER buf_hist-nws-option FOR ub.hist-nws-option.
DEFINE BUFFER buft_hist-nws-option FOR ub.hist-nws-option.

IF NOT AVAILABLE ub.db THEN UNDO, RETURN ERROR.
IF buf_sys-ctrl.db-num <> 0
AND buf_sys-ctrl.db-num <> db.db-num
and p-option <> {&lookup}
THEN DO:
   MESSAGE
   "Нельзя изменять настройки записи истории и маршрутизации в чужой УБД"
    VIEW-AS ALERT-BOX.
   UNDO, RETURN ERROR.
END.
CASE p-option:
  WHEN {&UPDATE} THEN DO:
    run adm/db-hn.w ( input parparentproc
                , input {&update}
                , input db.db-num /*p-db-num*/
                ).

  END.
  WHEN {&lookup} THEN DO:
      run adm/db-hn.w ( input parparentproc
                  , input {&lookup}
                  , input db.db-num /*p-db-num*/
                  ).

  END.
  WHEN {&add-copy} THEN DO:
     MESSAGE
     substitute("Выберите БД, с которой Вы хотите скопировать&1настройки записи истории и маршрутизации на БД &2"
                , {&NEW-LINE}
                , db.db-num)
     VIEW-AS ALERT-BOX.
   run adm/dbs.w ( INPUT parparentproc
      ,INPUT {&LOOKUP}
      ,OUTPUT v-rid) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN ERROR.
    FIND FIRST buf_db NO-LOCK WHERE
          recid(buf_db) = v-rid .
    FIND FIRST buf_hist-nws-option NO-LOCK WHERE
              buf_hist-nws-option.db-num = buf_db.db-num NO-ERROR.
    IF NOT AVAILABLE buf_hist-nws-option THEN DO:
       MESSAGE
       substitute("Для БД &1 настройки записи истории и маршрутизации не заданы"
                  , buf_db.db-num)
       VIEW-AS ALERT-BOX error .
       UNDO, RETURN ERROR.
    END.
    DO TRANSACTION ON ERROR UNDO, RETURN ERROR:
        FOR EACH buf_hist-nws-option NO-LOCK WHERE
                buf_hist-nws-option.db-num = buf_db.db-num
             AND buf_hist-nws-option.hn-id > 0
        ON error UNDO, RETURN error :
           FIND FIRST buft_hist-nws-option WHERE
                    buft_hist-nws-option.db-num = db.db-num
                AND buft_hist-nws-option.hn-id = buf_hist-nws-option.hn-id NO-ERROR.
           IF NOT AVAILABLE buft_hist-nws-option THEN DO:
               CREATE buft_hist-nws-option.
               BUFFER-COPY buf_hist-nws-option
               EXCEPT db-num
               TO buft_hist-nws-option.
           END.
        END.
        run cur-time in THIS-PROCEDURE
          (output v-today
          ,output v-time
          ).
        FIND FIRST buft_hist-nws-option WHERE
                 buft_hist-nws-option.db-num = db.db-num
             AND buft_hist-nws-option.hn-id = 0 NO-ERROR.
        IF NOT AVAILABLE buft_hist-nws-option THEN DO:
            CREATE buft_hist-nws-option.
            BUFFER-COPY buf_hist-nws-option
            EXCEPT option-descr
            TO buft_hist-nws-option
            ASSIGN
            buft_hist-nws-option.option-descr = substitute("&1 &2"
                                                             , string(v-today, "99/99/9999")
                                                             , string(v-time, "HH:MM:SS"))
            .
        END.
    END. /*transaction*/
  END. /*when copy*/
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-mark Dialog-Frame 
procedure local-mark :
  /* -----------------------------------------------------------
          Purpose:
          Parameters:  <none>
          Notes:
        -------------------------------------------------------------*/
  
  if not available ub.db then 
  do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
  { gbl/markstrn.i ub.db select-list }

  br-db:refresh() in frame {&frame-name} .

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-mark Dialog-Frame 
procedure proc-b-mark :
  /* -----------------------------------------------------------
          Purpose:
          Parameters:  <none>
          Notes:
        -------------------------------------------------------------*/
  define variable varlog as logical no-undo .
  if not available ub.db then return.
  run local-mark in this-procedure.
  assign 
    varlog = br-db:select-next-row( ) in frame {&frame-name}.
  apply "ENTRY":U to br-db in frame {&frame-name}.
  br-db:refresh() in frame {&frame-name} .

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-infodb-date d-db 
FUNCTION get-infodb-date RETURNS DATE
  ( INPUT p-db-num as integer) :
DEFINE BUFFER buf_db-info FOR ub.db-info.
find last buf_db-info no-lock where
        buf_db-info.db-num = p-db-num use-index  pi no-error.
IF AVAILABLE buf_db-info  THEN RETURN buf_db-info.date-info.
RETURN ?.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-infodb-ver d-db
FUNCTION get-infodb-ver RETURNS character 
  ( INPUT p-db-num as integer) :
DEFINE BUFFER upgrade FOR upgrade.
 block-step:
for each upgrade where upgrade.db-num   eq p-db-num
   no-lock by upgrade.db-num descending 
           by upgrade.step-num descending :
      leave block-step.        
   end.
   
return if available upgrade then  entry(1,upgrade.version-num,{&delim-par}) else "?".

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME