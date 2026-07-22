&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_cash-desk FOR cash-desk.
DEFINE TEMP-TABLE tt-cash-desk NO-UNDO LIKE cash-desk.
DEFINE BUFFER X_cash-desk FOR cash-desk.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование параметров кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/27/03
Author: Bakhtadze Natalya
Creation date: 11/27/03

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input        parameter parparentproc AS HANDLE no-undo.
/* parparentproc не используется. Передаётся в:
- ref/cda-cc.w
- ref/cd-atti.w
- ref/cda-29.w
- ref/cda-31.w
- value(v-spr) из thbjattr_code:attr-other
- ref/ccshlist.w
*/
define input        parameter p-mode as character  no-undo.
define input        parameter p-db-num like ub.cash-desk.db-num  no-undo.
define input        parameter p-obj-code like ub.cash-desk.obj-code  no-undo.
define input        parameter p-pos-type like ub.cash-desk.pos-type no-undo .
define input        parameter p-cash-num like ub.cash-desk.cash-num  no-undo.
define input-output parameter p-rid  as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование параметров кассы".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i  }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ str/wth-lib.i }
{ gbl/thbjattr.i }
{ gbl/cd-attr.i }
define variable v-db-num like ub.db.db-num no-undo.
define variable tcode as integer no-undo.
define variable dflt-cd as character no-undo init {&cd-type-ibm}.
define variable conf-attr as character no-undo.
define variable conf-par as character no-undo.
define variable par-type as character no-undo.
define variable v-host-code like ub.sysconf.host-code no-undo .
DEFINE VARIABLE v-fr-type-list-items-full AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-fr-type-list-items AS CHARACTER NO-UNDO.
define variable l-shift-on as logical no-undo .
define buffer buf_cash-desk for ub.cash-desk.
define variable mCashDevice      as ibs.th.str.cash.CashDevice no-undo.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-cash-desk cash-desk

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-cash-desk.cash-num ~
tt-cash-desk.db-num tt-cash-desk.obj-code tt-cash-desk.addr-path ~
tt-cash-desk.pos-type tt-cash-desk.cash-os tt-cash-desk.autonomy ~
tt-cash-desk.version tt-cash-desk.registration-code ~
tt-cash-desk.serial-code 
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-cash-desk.obj-code ~
tt-cash-desk.addr-path tt-cash-desk.pos-type tt-cash-desk.cash-os ~
tt-cash-desk.autonomy tt-cash-desk.version tt-cash-desk.registration-code ~
tt-cash-desk.serial-code 
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-cash-desk
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-cash-desk
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-cash-desk SHARE-LOCK, ~
      EACH cash-desk WHERE TRUE /* Join to tt-cash-desk incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-cash-desk SHARE-LOCK, ~
      EACH cash-desk WHERE TRUE /* Join to tt-cash-desk incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-cash-desk cash-desk
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-cash-desk
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame cash-desk


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-cash-desk.obj-code tt-cash-desk.addr-path ~
tt-cash-desk.pos-type tt-cash-desk.cash-os tt-cash-desk.autonomy ~
tt-cash-desk.version tt-cash-desk.registration-code ~
tt-cash-desk.serial-code 
&Scoped-define ENABLED-TABLES tt-cash-desk
&Scoped-define FIRST-ENABLED-TABLE tt-cash-desk
&Scoped-Define ENABLED-OBJECTS B-exit RECT-1 b-quit B-attr B-attr-2 ~
B-cli-attr B-hist B-Help f-obj-name COMBO-protocol-maria COMBO-protocol ~
cb-device-kind CB-fr-type f-fr-type T-remote 
&Scoped-Define DISPLAYED-FIELDS tt-cash-desk.cash-num tt-cash-desk.db-num ~
tt-cash-desk.obj-code tt-cash-desk.addr-path tt-cash-desk.pos-type ~
tt-cash-desk.cash-os tt-cash-desk.autonomy tt-cash-desk.version ~
tt-cash-desk.registration-code tt-cash-desk.serial-code 
&Scoped-define DISPLAYED-TABLES tt-cash-desk
&Scoped-define FIRST-DISPLAYED-TABLE tt-cash-desk
&Scoped-Define DISPLAYED-OBJECTS f-obj-name f-cash-num-char f-pswd ~
COMBO-protocol-maria COMBO-protocol cb-device-kind CB-fr-type f-fr-type ~
T-remote 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-attr 
     LABEL "&Оп.данные" 
     SIZE 10 BY 1.

DEFINE BUTTON B-attr-2 
     LABEL "&Настройки" 
     SIZE 10 BY 1 TOOLTIP "Параметры данной кассы".

DEFINE BUTTON B-cli-attr 
     LABEL "&Пар-тры типа кассы" 
     SIZE 20 BY 1.

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist 
     LABEL "Ис&тория" 
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE cb-device-kind AS INTEGER FORMAT ">9":U 
     LABEL "Признак исполнения кассы" 
     VIEW-AS COMBO-BOX INNER-LINES 4
     LIST-ITEM-PAIRS "Стандартное",0,
                     "ТСО Элекснет",1,
                     "ТСО Auto GC",2,
                     "Мобильное приложение",3
     DROP-DOWN-LIST
     SIZE 25 BY 1.

DEFINE VARIABLE CB-fr-type AS CHARACTER FORMAT "x(15)" 
     LABEL "Тип ФР" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1","Item 1",
                     "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 30 BY 1 TOOLTIP "Модель (класс, тип, марка) ККМ, Тип ФР".

DEFINE VARIABLE COMBO-protocol AS CHARACTER FORMAT "X(256)":U 
     LABEL "Протокол" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "","ftp","http","samba","SMTP" 
     DROP-DOWN-LIST
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE COMBO-protocol-maria AS CHARACTER FORMAT "X(256)":U 
     LABEL "Протокол" 
     VIEW-AS COMBO-BOX INNER-LINES 4
     LIST-ITEMS "","local","remote","ftp","shared" 
     DROP-DOWN-LIST
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE f-cash-num-char AS CHARACTER FORMAT "X(256)":U 
     LABEL "Зав.#" 
     VIEW-AS FILL-IN 
     SIZE 27 BY 1 NO-UNDO.

DEFINE VARIABLE f-fr-type AS CHARACTER FORMAT "X(256)":U 
     LABEL "Модель ККМ" 
     VIEW-AS FILL-IN 
     SIZE 30 BY 1 TOOLTIP "Модель (класс, тип, марка) ККМ, Тип ФР" NO-UNDO.

DEFINE VARIABLE f-obj-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 40.8 BY .95 NO-UNDO.

DEFINE VARIABLE f-pswd AS CHARACTER FORMAT "X(256)":U 
     LABEL "Пароль" 
     VIEW-AS FILL-IN 
     SIZE 27 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 1 GRAPHIC-EDGE  NO-FILL   
     SIZE 77 BY 2.14.

DEFINE VARIABLE T-remote AS LOGICAL INITIAL no 
     LABEL "Удаленная" 
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR 
      tt-cash-desk, 
      cash-desk SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-attr AT ROW 1 COL 31
     B-attr-2 AT ROW 1 COL 41 WIDGET-ID 6
     B-cli-attr AT ROW 1 COL 51
     B-hist AT ROW 1 COL 77
     B-Help AT ROW 1 COL 81
     tt-cash-desk.cash-num AT ROW 2.52 COL 11.4 COLON-ALIGNED
          LABEL "Номер"
          VIEW-AS FILL-IN 
          SIZE 6 BY 1
     tt-cash-desk.db-num AT ROW 2.5 COL 32.63 COLON-ALIGNED
          LABEL "Номер БД"
          VIEW-AS FILL-IN 
          SIZE 5.63 BY 1
     tt-cash-desk.obj-code AT ROW 3.75 COL 11.63 COLON-ALIGNED
          LABEL "Магазин"
          VIEW-AS FILL-IN 
          SIZE 6.38 BY 1
          BGCOLOR 15 FGCOLOR 0 
     f-obj-name AT ROW 3.75 COL 22.75 COLON-ALIGNED NO-LABEL
     f-cash-num-char AT ROW 5 COL 11.63 COLON-ALIGNED
     f-pswd AT ROW 5 COL 50 COLON-ALIGNED
     tt-cash-desk.addr-path AT ROW 7.5 COL 27 COLON-ALIGNED
          LABEL "Адрес/путь"
          VIEW-AS FILL-IN 
          SIZE 25 BY 1
          BGCOLOR 15 FGCOLOR 0 
     COMBO-protocol-maria AT ROW 7.5 COL 64 COLON-ALIGNED
     COMBO-protocol AT ROW 7.5 COL 64 COLON-ALIGNED
     cb-device-kind  AT ROW 6.29 COL 27 COLON-ALIGNED WIDGET-ID 14
     tt-cash-desk.cash-os AT ROW 6.29 COL 64 COLON-ALIGNED
          LABEL "Тип ОС"
          VIEW-AS COMBO-BOX INNER-LINES 4
          LIST-ITEMS "","DOS","LINUX","WINDOWS" 
          DROP-DOWN-LIST
          SIZE 10 BY 1
          BGCOLOR 15 FGCOLOR 0 
     tt-cash-desk.autonomy AT ROW 9.75 COL 13.63 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS 
                    "Item 1", 1,
"Item 2", 2,
"Item 3", 3
          SIZE 66 BY 1
     tt-cash-desk.pos-type AT ROW 11.29 COL 60.2 COLON-ALIGNED
          LABEL "Тип POS"
          VIEW-AS COMBO-BOX INNER-LINES 11
          LIST-ITEM-PAIRS "1","1",
                     "2","2",
                     "3","3",
                     "4","4",
                     "5","5",
                     "6","6",
                     "7","7"
          DROP-DOWN-LIST
          SIZE 24 BY 1
          BGCOLOR 15 FGCOLOR 0 
     CB-fr-type AT ROW 13.67 COL 11.2 COLON-ALIGNED WIDGET-ID 4
     tt-cash-desk.version AT ROW 13.67 COL 60.2 COLON-ALIGNED
          LABEL "Версия протокола"
          VIEW-AS FILL-IN 
          SIZE 24 BY 1
     f-fr-type AT ROW 14.81 COL 49.6 COLON-ALIGNED WIDGET-ID 8
     T-remote AT ROW 14.95 COL 13
     tt-cash-desk.registration-code AT ROW 16.14 COL 11.8 COLON-ALIGNED
          LABEL "Регистр. №"
          VIEW-AS FILL-IN 
          SIZE 30 BY 1
     tt-cash-desk.serial-code AT ROW 16.14 COL 51.6 COLON-ALIGNED
          LABEL "Сер. №"
          VIEW-AS FILL-IN 
          SIZE 30 BY 1
     RECT-1 AT ROW 9.14 COL 3 WIDGET-ID 10
     SPACE(3.99) SKIP(7.76)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Касса"
         DEFAULT-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_cash-desk B "?" NO-UNDO ub cash-desk
      TABLE: tt-cash-desk T "?" NO-UNDO ub cash-desk
      TABLE: X_cash-desk B "?" ? ub cash-desk
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-cash-desk.addr-path IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-cash-desk.cash-num IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR COMBO-BOX tt-cash-desk.cash-os IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN 
       COMBO-protocol:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN 
       COMBO-protocol-maria:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-cash-desk.db-num IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN f-cash-num-char IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-pswd IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-cash-desk.obj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX tt-cash-desk.pos-type IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-cash-desk.registration-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-cash-desk.serial-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-cash-desk.version IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-cash-desk,ub.cash-desk WHERE Temp-Tables.tt-cash-desk ..."
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Касса */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-device-kind
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-device-kind Dialog-Frame
ON VALUE-CHANGED OF cb-device-kind IN FRAME Dialog-Frame
DO:
  if p-mode = {&lookup} then return no-apply.

  ASSIGN
  cb-device-kind.
  tt-cash-desk.pos-type = if    cb-device-kind eq mCashDevice:Tanker:keyint
                             or cb-device-kind eq mCashDevice:TankerIntegr:keyint
                          then {&cd-type-Autotank}
                          else {&cd-type-IBM-XML}.
  DISPLAY
     tt-cash-desk.pos-type
  WITH FRAME {&FRAME-NAME}.
     
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME tt-cash-desk.autonomy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-cash-desk.autonomy Dialog-Frame
ON VALUE-CHANGED OF tt-cash-desk.autonomy IN FRAME Dialog-Frame
DO:
  if p-mode = {&lookup} then return no-apply.

  ASSIGN
  tt-cash-desk.autonomy.
  CASE tt-cash-desk.autonomy:
      WHEN INTEGER({&cd-manager}) THEN DO:
          ASSIGN
          tt-cash-desk.cash-num = 0
          .
          DISPLAY
          tt-cash-desk.cash-num
          cb-device-kind 
          WITH FRAME {&FRAME-NAME}.
          DISABLE
          tt-cash-desk.cash-num
          WITH FRAME {&FRAME-NAME}.
      END.
      OTHERWISE DO:
          ASSIGN
          tt-cash-desk.cash-num = tcode.
          DISPLAY
          tt-cash-desk.cash-num
          cb-device-kind
          WITH FRAME {&FRAME-NAME}.
          ENABLE
          tt-cash-desk.cash-num when p-mode = {&add-def}
          cb-device-kind
          WITH FRAME {&FRAME-NAME}.
      END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr Dialog-Frame
ON CHOOSE OF B-attr IN FRAME Dialog-Frame /* Оп.данные */
DO:
define variable v-rid-list as character no-undo .
  v-rid-list = string(recid(locked_cash-desk)).
  if tt-cash-desk.pos-type = {&cd-type-ibs-th} then do:
    if p-mode <> {&lookup} then do:
      message
      "Для данного типа кассы режим ИЗМЕНЕНИЕ для оперативных данных недоступен" skip
      "предалагаем Оперативные данные в режиме ПРОСМОТР" skip
      view-as alert-box .
    end.
    run ref/cda-cc.w ( input parparentproc
                      ,input tt-cash-desk.db-num
                      ,input {&shop}

                      ,input tt-cash-desk.obj-code
                      ,input tt-cash-desk.pos-type
                      ,input tt-cash-desk.cash-num
                      ,input '' /*bttns*/
                      ,input-output v-rid-list) no-error.
  end.
  else do:
    run ref/cd-atti.w (   input parparentproc
                    ,input {&lookup}
                    ,input "oper"
                    ,input tt-cash-desk.db-num
                    ,input tt-cash-desk.obj-code
                    ,input tt-cash-desk.pos-type
                    ,input tt-cash-desk.cash-num
                                        ,input no
                  ).
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr-2 Dialog-Frame
ON CHOOSE OF B-attr-2 IN FRAME Dialog-Frame /* Настройки */
DO:
define variable v-setted as logical no-undo .
  case tt-cash-desk.pos-type:
    when {&cd-type-ibs-th} then do:
        run ref/cda-29.w ( input parparentproc
                          ,input {&lookup}
                          ,input tt-cash-desk.db-num
                          ,input tt-cash-desk.obj-code
                          ,input tt-cash-desk.pos-type
                          ,input tt-cash-desk.cash-num
                          ,input ""
                          ,input ''
                          ,output v-setted) no-error.
    end.
    when {&cd-type-ibs-th-mob} then do:
        run ref/cda-31.w ( input parparentproc
                          ,input {&lookup}
                          ,input tt-cash-desk.db-num
                          ,input tt-cash-desk.obj-code
                          ,input tt-cash-desk.pos-type
                          ,input tt-cash-desk.cash-num
                          ,input ""
                          ,input ''
                          ,output v-setted) no-error.

    end.
    otherwise do:
      run ref/cd-atti.w (   input parparentproc
                      ,input {&lookup}
                      ,input "ref"
                      ,input tt-cash-desk.db-num
                      ,input tt-cash-desk.obj-code
                      ,input tt-cash-desk.pos-type
                      ,input tt-cash-desk.cash-num
                                          ,input no
                    ).
    end.
  end case.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cli-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cli-attr Dialog-Frame
ON CHOOSE OF B-cli-attr IN FRAME Dialog-Frame /* Пар-тры типа кассы */
DO:
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
define variable attr-value as char no-undo .              /*для знач по умолч*/
define variable attr-prop-list      as character no-undo . /*список членов секции*/
define variable attr-prop-type-list as character no-undo . /*список типов членов секции*/
define variable attr-prop-label-list as character no-undo . /*список лейблов членов секции*/
define variable attr-global          as logical no-undo .   /*может ли быть задан в глобальном контексте*/
define variable attr-host           as logical no-undo .    /*может ли быть задан в контексте фирмы*/
define variable attr-shop           as logical no-undo .    /*может ли быть задан в контексте маг*/
define variable attr-store          as logical no-undo .    /*может ли быть задан в контексте склад*/
define variable attr-db             as logical no-undo .    /*может ли быть задан в контексте БД*/

define variable v-spr as character no-undo .
define variable ii as integer no-undo .

  /*найдем какой справочник запускать для кассы данного типа*/
  run  thbjattr_code in this-procedure (
                                         input   "cd-type-":U + locked_cash-desk.pos-type
                                         ,input ''
                                         ,output attr-label
                                         ,output attr-user-can-edit
                                         ,output attr-output-display
                                         ,output attr-other
                                         ,output attr-prop-list
                                         ,output attr-prop-type-list
                                         ,output attr-prop-label-list
                                         ,output attr-global
                                         ,output attr-host
                                         ,output attr-shop
                                         ,output attr-store
                                         ,output attr-db ).
  do ii = 1 to num-entries(attr-other, {&slash-char}):
    if entry(ii, attr-other, {&slash-char}) begins "spr-ext=":U then do:
      assign
      v-spr = entry(2, entry(ii, attr-other, {&slash-char}), "=").
    end.
  end.
    run value(v-spr)(
                  input parparentproc
                ,{&lookup}
                ,{&shop}
                ,locked_cash-desk.obj-code
                ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  assign
    frame {&frame-name}
    tt-cash-desk.pos-type
  .
  if tt-cash-desk.pos-type = {&cd-type-r-keeper} then do :
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
    then do:
      message
        "В системе запрещена работа с кассами R-Keeper либо отсутсвует конфигурационный параметр is-rkeep" skip
        "Обратитесь к администратору" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return no-apply.
    end.
  end.
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
define variable rid-list as character no-undo.
      run ref/ccshlist.w (
                         INPUT parparentproc
                       , INPUT "":U /*bttns*/
                       , INPUT "one":U /*parref-mode*/
                       , OUTPUT  rid-list
                       , INPUT tt-cash-desk.db-num
                       , INPUT {&shop}
                       , INPUT tt-cash-desk.obj-code
                       , input tt-cash-desk.pos-type
                       , input tt-cash-desk.cash-num
                       , input "":U /*p-subject*/
                        ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-cash-desk.cash-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-cash-desk.cash-num Dialog-Frame
ON LEAVE OF tt-cash-desk.cash-num IN FRAME Dialog-Frame /* Номер */
DO:
  assign tt-cash-desk.cash-num .
  assign tcode = tt-cash-desk.cash-num .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-cash-desk.obj-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-cash-desk.obj-code Dialog-Frame
ON LEAVE OF tt-cash-desk.obj-code IN FRAME Dialog-Frame /* Магазин */
DO:
   define buffer buf_shop for ub.shop.
  define buffer buf_clients for ub.clients.
  find first buf_shop no-lock where
                buf_shop.obj-code = input frame {&frame-name} tt-cash-desk.obj-code no-error.
  if available buf_shop then do:
    find first buf_clients no-lock where
                buf_clients.obj-type = {&shop}
           AND buf_clients.obj-code = buf_shop.obj-code .
    assign
    tt-cash-desk.obj-code
    f-obj-name = buf_clients.obj-name.
    display
   tt-cash-desk.obj-code
   f-obj-name
    with frame {&frame-name}.
  end.
  else do:
      assign
        tt-cash-desk.obj-code = 0
        f-obj-name = "":U.
      return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-cash-desk.pos-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-cash-desk.pos-type Dialog-Frame
ON VALUE-CHANGED OF tt-cash-desk.pos-type IN FRAME Dialog-Frame /* Тип POS */
DO:
  if p-mode = {&lookup} then return no-apply.
  
  assign
  tt-cash-desk.pos-type.
  if lookup(tt-cash-desk.pos-type,
            ({&cd-type-IBM} + {&comma-char} +
             {&cd-type-IBm-XML} + {&comma-char} +
             {&cd-type-maria})) = 0 then do:
      disable
      t-remote
      with frame {&frame-name}.
  end.
  else do:
      enable
      t-remote when (p-mode <> {&lookup} and not l-shift-on)
      with frame {&frame-name}.
  end.
  
  if lookup(tt-cash-desk.pos-type
            , ({&cd-type-IBm-XML} + {&comma-char} +
               {&cd-type-autotank})) > 0
      then do:
      if p-mode <> {&lookup} then do:
        view
        combo-protocol
        in frame {&frame-name}.
      end.
      enable
      combo-protocol when (p-mode <> {&lookup} and not l-shift-on)
      with frame {&frame-name}.
  end.
  else do:
      disable
      combo-protocol
      with frame {&frame-name}.
      HIDE
      combo-protocol
      in frame {&frame-name}.

  end.
  if lookup({&cd-type-maria}, tt-cash-desk.pos-type) > 0
      then do:
      if p-mode <> {&lookup} then do:
        view
        combo-protocol-maria
        in frame {&frame-name}.
      end.
      enable
      combo-protocol-maria when (p-mode <> {&lookup} and not l-shift-on)
      with frame {&frame-name}.
  end.
  else do:
      disable
      combo-protocol-maria
      with frame {&frame-name}.
      HIDE
      combo-protocol-maria
      in frame {&frame-name}.

  end.

  if lookup({&cd-type-maria}, tt-cash-desk.pos-type) > 0
      then do:
      enable
      f-cash-num-char when (p-mode <> {&lookup} and not l-shift-on)
      with frame {&frame-name}.
  end.
  else do:
      disable
      f-cash-num-char
      with frame {&frame-name}.
      HIDE
      f-cash-num-char
      in frame {&frame-name}.

  end.
  if lookup({&cd-type-maria}, tt-cash-desk.pos-type) > 0
      then do:
      enable
      f-pswd when (p-mode <> {&lookup} and not l-shift-on)
      with frame {&frame-name}.
  end.
  else do:
      disable
      f-pswd
      with frame {&frame-name}.
      HIDE
      f-pswd
      in frame {&frame-name}.

  end.

  if lookup(tt-cash-desk.pos-type,
           ({&cd-type-IBm-XML} + {&comma-char} +
            {&cd-type-NCR-GM} + {&comma-char} +
            {&cd-type-magia-xml} + {&comma-char} +
            {&cd-type-NCR-AS-R} + {&comma-char} +
            {&cd-type-autotank}
            )) > 0 then do:
      enable
      tt-cash-desk.autonomy when (p-mode <> {&lookup} and not l-shift-on)
      with frame {&frame-name}.
  end.
  else do:
      ASSIGN
      tt-cash-desk.autonomy = 0.
      DISPLAY
      tt-cash-desk.autonomy
      with frame {&frame-name}.
      disable
      tt-cash-desk.autonomy
      with frame {&frame-name}.

  end.
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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 if num-entries(p-mode, {&delim-par}) > 1 then do:
   assign
   l-shift-on = logical(entry(2, p-mode, {&delim-par}))
   p-mode = entry(1, p-mode, {&delim-par})
   .
 end.
 if p-mode  <> {&add-def}
 and p-mode <> {&update}
 and p-mode <> {&lookup}
 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
 end.
 v-db-num = ibs.th.gbl.gbl-var:g#db-num .
 { gbl/hostcode.i ~{&shop~} p-obj-code v-host-code }

  empty temp-table tt-cash-desk .
  case p-mode :
    when {&update} then do:
      find first locked_cash-desk EXclusive-lock
           where recid(locked_cash-desk) = p-rid no-wait no-error.
      if locked locked_cash-desk then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись КАССЫ занята"
        view-as alert-box error .
        undo, return error.
      end.
      if not available locked_cash-desk then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись КАССА"
      view-as alert-box error .
      undo, return error.
      end.
      if locked_cash-desk.db-num <> v-db-num then do:
            message
            vss-workfile vss-revision vss-description skip
            "Нельзя изменять кассу чужой БД"
            view-as alert-box error .
            undo, return error.
      end.
      IF LOCKED_cash-desk.is-del THEN DO:
        message
        vss-workfile vss-revision vss-description skip
        "Нельзя изменять кассу? которая логически удалена"
        view-as alert-box error .
        undo, return error.
      END.
      create tt-cash-desk.
      buffer-copy locked_cash-desk to tt-cash-desk .
      tcode = tt-cash-desk.cash-num .
    end.
    when {&lookup} then do :
      find first locked_cash-desk no-lock
           where recid(locked_cash-desk) = p-rid no-error .
      if not available locked_cash-desk then do:
        find first locked_cash-desk no-lock
             where locked_cash-desk.db-num   = p-db-num
               AND Locked_Cash-desk.obj-code = p-obj-code
               AND locked_cash-desk.cash-num = p-cash-num
               AND locked_cash-desk.pos-type = p-pos-type    no-error.
        if not available locked_cash-desk then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись КАССА"
      view-as alert-box error .
      undo, return error.
        end.
      end.
      create tt-cash-desk.
      buffer-copy locked_cash-desk to tt-cash-desk .
      tcode = tt-cash-desk.cash-num .
    end .
    when {&add-def} then do:
      { gbl/dflt-cd.i {&shop} p-obj-code dflt-cd }
      for each buf_cash-desk NO-LOCK
         where buf_cash-desk.db-num = v-db-num
             BY buf_cash-desk.cash-num :
        tcode = buf_cash-desk.cash-num.
      end.
      tcode = tcode + 1.
      
      create tt-cash-desk.
      assign
    tt-cash-desk.db-num    = v-db-num
    tt-cash-desk.obj-code  = p-obj-code
    tt-cash-desk.cash-num  = tcode
    tt-cash-desk.pos-type  = dflt-cd
    tt-cash-desk.addr-path = (if dflt-cd = {&cd-type-IBM} or dflt-cd = {&cd-type-omron} then "192.1.1.1":U else "":U)
    tt-cash-desk.cash-os   = "OS/2"
    tt-cash-desk.cash-on   = no
      .
    end.
    otherwise do :
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error .
    end .
  end case .
  
  RUN MyENable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
delete object mCashDevice.
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
  DISPLAY f-obj-name f-cash-num-char f-pswd COMBO-protocol-maria COMBO-protocol 
          cb-device-kind CB-fr-type f-fr-type T-remote 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-cash-desk THEN 
    DISPLAY tt-cash-desk.cash-num tt-cash-desk.db-num tt-cash-desk.obj-code 
          tt-cash-desk.addr-path tt-cash-desk.pos-type tt-cash-desk.cash-os 
          tt-cash-desk.autonomy tt-cash-desk.version 
          tt-cash-desk.registration-code tt-cash-desk.serial-code 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit RECT-1 b-quit B-attr B-attr-2 B-cli-attr B-hist B-Help 
         tt-cash-desk.obj-code f-obj-name tt-cash-desk.addr-path 
         COMBO-protocol-maria COMBO-protocol tt-cash-desk.pos-type 
         tt-cash-desk.cash-os tt-cash-desk.autonomy cb-device-kind CB-fr-type 
         tt-cash-desk.version f-fr-type T-remote tt-cash-desk.registration-code 
         tt-cash-desk.serial-code 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
/* ----- тип POS ----- */
DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii         AS INTEGER   NO-UNDO.
 define variable objType    as ibs.th.gbl.propmap no-undo.
   
   mCashDevice      = new ibs.th.str.cash.CashDevice().
   do v-ii = 1 to mCashDevice:mapType:GetItem(v-ii):
      objType = mCashDevice:CurrProp.
      v-list-items = v-list-items + {&comma-char} + objType:Label_ + {&comma-char} + string(objType:KeyIntDB) .
   end.
   cb-device-kind:LIST-ITEM-PAIRS  in frame {&frame-name} = trim(v-list-items,{&comma-char}) .
   
v-list-items = "".
DO v-ii = 1 TO NUM-ENTRIES({&cd-type-codes-real}):
    ASSIGN
    v-list-items = v-list-items + (IF v-ii > 1 THEN  {&comma-char} ELSE "":U) +
                   ENTRY(v-ii, {&cd-type-codes-real-full}) + {&comma-char} +
                   ENTRY(v-ii, {&cd-type-codes-real}).
END.
tt-cash-desk.pos-type:list-item-pairs in frame {&frame-name} = v-list-items .
  /* ----- end_of тип POS ----- */


  /* ----- тип ФР ----- */
define variable v-fr-type-list-item-pairs as character no-undo .
DO v-ii = 1 TO NUM-ENTRIES({&fr-type-codes}):
    ASSIGN
    v-fr-type-list-item-pairs = v-fr-type-list-item-pairs + (IF v-ii > 1 THEN  {&comma-char} ELSE "":U) +
                                      ENTRY(v-ii, {&fr-type-codes-full}) +
                                      {&comma-char} +
                                      ENTRY(v-ii, {&fr-type-codes})
    v-fr-type-list-items-full = v-fr-type-list-items-full + (IF v-ii > 1 THEN  {&comma-char} ELSE "":U) +
                                      ENTRY(v-ii, {&fr-type-codes-full})
    v-fr-type-list-items = v-fr-type-list-items + (IF v-ii > 1 THEN  {&comma-char} ELSE "":U) +
                                      ENTRY(v-ii, {&fr-type-codes})
    .
END.
assign
cb-fr-type:LIST-ITEM-pairs IN FRAME {&FRAME-NAME} = trim(v-fr-type-list-item-pairs, {&comma-char})
cb-fr-type = tt-cash-desk.fr-type
f-fr-type = tt-cash-desk.fr-type
f-fr-type:column = cb-fr-type:column
f-fr-type:row = cb-fr-type:row
f-fr-type:side-label-handle:row = f-fr-type:row
f-fr-type:side-label-handle:column = f-fr-type:column
.
  /* ----- end_of тип ФР ----- */


  /* ----- признак исполнения кассы ----- */
  /* признак какая это касса: ТСО, обычная касса или мобильная.
     Признак не зависит от pos-type, хранится в cash-desk-attr,
     и он там такой один, который вызывается прямо из формы редактирования,
     минуя фильтрацию по pos-type.
  */
  cb-device-kind = tt-cash-desk.device-kind .

  /* ----- end_of признак исполнения кассы ----- */


  /* ----- остальное ----- */
assign
t-remote = (tt-cash-desk.remote = 1)
tt-cash-desk.autonomy:radio-buttons = "&Автономная касса"  + {&comma-char} + {&cd-self} +  {&comma-char} +
                                      "&Подчиненная касса" + {&comma-char} + {&cd-slave} + {&comma-char} +
                                      "&Касс.менеджер"     + {&comma-char} + {&cd-manager}
.

DISPLAY
f-obj-name
cb-device-kind
T-remote
WITH FRAME {&frame-name} .
IF AVAILABLE tt-cash-desk THEN DO:
 combo-protocol:SCREEN-VALUE = (IF num-entries(tt-cash-desk.addr-path, {&delim-par}) > 1
                                and (tt-cash-desk.pos-type = {&cd-type-IBM-XML}
                                     or tt-cash-desk.pos-type = {&cd-type-autotank})
                                THEN ENTRY(1, tt-cash-desk.addr-path, {&delim-par})
                                ELSE {&space-char}) .
 combo-protocol-maria:SCREEN-VALUE = (IF num-entries(tt-cash-desk.addr-path, {&delim-par}) > 1
                                      and tt-cash-desk.pos-type = {&cd-type-maria}
                                      THEN ENTRY(1, tt-cash-desk.addr-path, {&delim-par})
                                      ELSE {&space-char}) .
DISPLAY
f-fr-type
tt-cash-desk.cash-num
tt-cash-desk.db-num
tt-cash-desk.obj-code
(IF num-entries(tt-cash-desk.addr-path, {&delim-par}) > 1
THEN ENTRY(2, tt-cash-desk.addr-path, {&delim-par})
ELSE tt-cash-desk.addr-path) @ tt-cash-desk.addr-path
tt-cash-desk.pos-type
tt-cash-desk.cash-os
tt-cash-desk.version
tt-cash-desk.autonomy
tt-cash-desk.registration-code
tt-cash-desk.serial-code
WITH FRAME {&frame-name} .
IF NUM-ENTRIES(tt-cash-desk.addr-path, {&delim-par}) > 2
AND tt-cash-desk.pos-type = {&cd-type-maria}
    THEN DO:
    DISPLAY
    ENTRY(3, tt-cash-desk.addr-path, {&delim-par}) @ f-cash-num-char
    WITH FRAME {&FRAME-NAME}.
END.
IF NUM-ENTRIES(tt-cash-desk.addr-path, {&delim-par}) > 3
AND tt-cash-desk.pos-type = {&cd-type-maria}
    THEN DO:
    DISPLAY
    ENTRY(4, tt-cash-desk.addr-path, {&delim-par}) @ f-pswd
    WITH FRAME {&FRAME-NAME}.
END.
END.
ENABLE
b-quit
B-exit
b-attr when (p-mode <> {&add-def} and not l-shift-on)
b-attr-2 when (p-mode <> {&add-def} and not l-shift-on)
b-cli-attr when (p-mode <> {&add-def} and not l-shift-on)
b-hist when p-mode <> {&add-def}
B-Help
tt-cash-desk.cash-num when (p-mode = {&add-def} and not l-shift-on)
tt-cash-desk.obj-code  when (p-mode = {&add-def} and not l-shift-on)
tt-cash-desk.addr-path when (p-mode <> {&lookup})
tt-cash-desk.pos-type  when (p-mode = {&add-def} and not l-shift-on)
tt-cash-desk.cash-os when (p-mode <> {&lookup} and not l-shift-on)
tt-cash-desk.version when p-mode <> {&lookup}
tt-cash-desk.registration-code when p-mode <> {&lookup} /*when (p-mode <> {&lookup} and not l-shift-on)*/
tt-cash-desk.serial-code when p-mode <> {&lookup} /*when (p-mode <> {&lookup} and not l-shift-on)*/
T-remote when (p-mode <> {&lookup} and not l-shift-on)
tt-cash-desk.autonomy when (p-mode <> {&lookup} and not l-shift-on)
cb-device-kind when (p-mode <> {&lookup})
WITH FRAME {&frame-name}.
if p-mode = {&lookup} then do:
    assign
    b-quit:label = "&Выход"
    .
    hide
    b-exit
    in frame {&frame-name}.
end.
APPLY "VALUE-CHANGED" to tt-cash-desk.pos-type.
enable tt-cash-desk.pos-type WITH FRAME {&frame-name}.
APPLY "VALUE-CHANGED" to tt-cash-desk.autonomy.
VIEW FRAME {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

IF COMBO-protocol:visible in FRAME {&FRAME-NAME} THEN
ASSIGN
COMBO-protocol
.
ELSE
combo-protocol = "":U.

IF COMBO-protocol-maria:visible in FRAME {&FRAME-NAME} THEN
ASSIGN
COMBO-protocol-maria
.
ELSE
combo-protocol-maria = "":U.


IF f-cash-num-char:visible in FRAME {&FRAME-NAME} THEN
ASSIGN
f-cash-num-char
.
ELSE
f-cash-num-char = "":U.
IF f-pswd:visible in FRAME {&FRAME-NAME} THEN
ASSIGN
f-pswd
.
ELSE
f-pswd = "":U.

IF cb-FR-TYPE:SENSITIVE in FRAME {&FRAME-NAME} THEN do:
  ASSIGN
  cb-FR-TYPE
  tt-cash-desk.fr-type = cb-FR-TYPE
  .
end.
ELSE do:
  cb-FR-TYPE = "":U.
end.
IF f-FR-TYPE:SENSITIVE in FRAME {&FRAME-NAME} THEN do:
  ASSIGN
  f-FR-TYPE
  tt-cash-desk.fr-type = f-FR-TYPE
  .
end.
ELSE do:
  f-FR-TYPE = "":U.
end.

if cb-device-kind:sensitive in frame {&frame-name}
  then assign cb-device-kind .
  else cb-device-kind = 0 .
  
assign
frame {&frame-name} tt-cash-desk.addr-path
tt-cash-desk.addr-path = (IF combo-protocol <> "":U
                          THEN (combo-protocol + {&delim-par})
                          ELSE '':U) +
                          tt-cash-desk.addr-path
tt-cash-desk.addr-path =   (IF combo-protocol-maria <> "":U
                          THEN (combo-protocol-maria + {&delim-par})
                          ELSE '':U) +
                          tt-cash-desk.addr-path
tt-cash-desk.addr-path = tt-cash-desk.addr-path +
                        (IF f-cash-num-char <> "":U
                        THEN ({&delim-par} + f-cash-num-char )
                        ELSE '':U)
tt-cash-desk.addr-path = tt-cash-desk.addr-path +
                        (IF f-pswd <> "":U
                        THEN ({&delim-par} + f-pswd )
                        ELSE '':U)
tt-cash-desk.cash-num
tt-cash-desk.cash-os
tt-cash-desk.obj-code
tt-cash-desk.pos-type
tt-cash-desk.version
T-remote
tt-cash-desk.remote = (if T-remote and T-remote:sensitive then 1 else 0)
tt-cash-desk.autonomy
tt-cash-desk.serial-code
tt-cash-desk.registration-code
.
run ref/cashdsk1.p (
 input-output p-rid
,input p-mode
,input tt-cash-desk.db-num
,input tt-cash-desk.obj-code
,input tt-cash-desk.pos-type
,input tt-cash-desk.cash-num
,input tt-cash-desk.autonomy
,input tt-cash-desk.addr-path
,input tt-cash-desk.cash-on
,input tt-cash-desk.cash-os
,input tt-cash-desk.is-del
,input tt-cash-desk.remote
,input tt-cash-desk.version
,input tt-cash-desk.registration-code
,input tt-cash-desk.serial-code
,input tt-cash-desk.fr-type
,input cb-device-kind
) no-error .
if error-status:error then do:
  if num-entries(return-value, " ") > 1 then message
    substitute("&1&2&3", error-status:get-message(1) , {&new-line}, return-value)
  view-as alert-box error .
  else if return-value > "" then do:
    /* здесь, наверное, предполагалось выполнить 
       apply "entry" to value(return-value) in frame {&FRAME-NAME} no-error.
    */
  end .
  undo, return error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

