&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
/*
DEFINE SHARED TEMP-TABLE chk-list NO-UNDO LIKE ub.chk-doc
field is-wth-doc as logical
field sel-order  as integer
field znak       as integer
field to-del     as logical
index xpk is primary unique doc-code is-wth
index znak-order znak sel-order .

define temp-table temp-list no-undo
field fname as character format "X(30)"
field fvalue as character
field id as integer
index pi is primary unique
id
.
*/

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автоматизированное формирования списка чеков и чеков МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/02/04
Author: Bakhtadze Natalya
Creation date: 03/02/04

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Автоматизированное формирования списка чеков и чеков МЦ".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ cmp/showinf.i }
{ cmp/chk-list.i {1} def " SHARED " }
define variable g#report-num as integer no-undo .
{ str/listhprc.i {1} }
{ gbl/flt-def.i }
{ cmp/operlist.i }
{ gbl/fltfield.i }
{ ref/cgrplbfn.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ str/shftnmef.i {1} shift-name temp }
{ gbl/userobjs.i }


&scop sel-obj ~
  v-ref-list = "":u. ~
 ~{                       ~
   gbl/uobjsone.i         ~
    parparentproc         ~
    v-cntxt-db-num        ~
    v-cntxt-userid        ~
    v-cntxt-host-code-obj ~
    v-cntxt-obj-type      ~
    v-cntxt-obj-code      ~
    v-user-select         ~
    v-sel-obj-type        ~
    v-sel-obj-code        ~
  ~}                       ~
  if not v-user-select then do: ~
    run Myenable in this-procedure . ~
    return no-apply. ~
  end.

&scop sel-objm ~
 ~{ gbl/uobjsman.i             ~
      parparentproc           ~
      v-cntxt-db-num          ~
      v-cntxt-userid          ~
      v-cntxt-host-code-obj   ~
      v-cntxt-obj-type        ~
      v-cntxt-obj-code        ~
      v-user-select           ~
    ~}                         ~
  if not v-user-select then do: ~
    run Myenable in this-procedure. ~
    return no-apply. ~
  end.



&scop CHK-STATUS-all      assign ~
      CHK-STATUS = ~{&all~}. ~
      display ~
      CHK-STATUS ~
      with frame ~{&frame-name~}.


define buffer l-{1} for {1}.
define variable f-chk-name as char init "default.chk" no-undo.
define variable f-doc-name as char init "default.trn" no-undo.
define variable f-cli-name as char init "default.cli" no-undo.
define variable f-card-name as char init "default.dc" no-undo.
define variable f-gds-name as char init "default.gds" no-undo.
define variable grp-list as char no-undo.
define variable is-grp as logical no-undo.
define variable ref-list as char no-undo.
define variable num-rec as integer init 0 no-undo.
define variable num-rec2 as integer init 0 no-undo.
define variable tot-lns as integer init ? no-undo.
define variable v-num-add          as integer no-undo .
define variable v-num-ignored      as integer no-undo .
define variable line-mode as character no-undo .
define variable line-rec as recid no-undo .
define variable kk as integer no-undo .
define variable v-doc-code like ub.chk-doc.doc-code no-undo .
/*имеет смысл только при обработке чеков по подчиненной таблице - для того чтобы несколько раз не обработ один и тот же чек
см chk-fill.p
*/
define stream sout.
define variable CLI-REC AS RECID NO-UNDO.
DEFine VARiable RS-list-method AS CHARACTER.
define variable save-option as character no-undo.
define variable print-option as character no-undo.
define variable ddoc-PS like ub.clients.obj-name no-undo.
define variable glog as logical no-undo .
define variable v-ref-list as character no-undo .
/*define variable notes as character no-undo .*/
define variable v-seq as integer no-undo .
define variable v-no-hist as integer no-undo init -1.
define variable lns-cnt as integer no-undo .
define variable rs-status as character no-undo .
define variable lns-ignore as integer no-undo .
define variable v-rid-list as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-tab-order as character no-undo .
define variable v-user-select as logical no-undo .
define variable v-sel-obj-type like ub.clients.obj-type no-undo .
define variable v-sel-obj-code like ub.clients.obj-code no-undo .
define variable v-object-available as logical   no-undo .
define variable v-cpdoc-attr-val as character no-undo .  /* для атрибут оплаты = */

define buffer buf_chk-doc for ub.chk-doc.


&scop  disp-hot-fields   if avail {1} then do: ~
    assign ed-notes = ddoc-ps. ~
    display ed-notes ~
    tot-lns @ f-tot-lns with frame ~{&frame-name~}. ~
  end. ~
  else do: ~
    assign ed-notes = ''. ~
    display ed-notes ~
    tot-lns @ f-tot-lns with frame ~{&frame-name~}. ~
  end.


&scop add-operation 1
&scop del-operation 2
&scop rest-operation 3
&scop cancel-operation 4

define temp-table temp-list no-undo
field fname as character format "X(30)"
field fvalue as character
field id as integer
index pi is primary unique
id
index ifvalue fvalue
.

&scop all-options                             ~
"Текущая строка,single,                       ~
Чек (товарный),chk-doc,                       ~
Чек продажи,inkas,                            ~
Чек документа МЦ,wth-doc,                     ~
Чеки. с товаром,goods,                        ~
Чеки с типом касс. платежа,cash-pay,          ~
Чеки с ОСС,chk-oss,                           ~
Чеки по дисконтной карте,d-card,              ~
Чеки. с тов. из списка,gds-list,              ~
Чеки МЦ с определенной МЦ,wealth,             ~
Чеки с определенным кол-вом тов.строк,gds-line-num,             ~
Чеки (товарный) определенного типа,chk-type,  ~
Файл,file,                                    ~
Фильтр товарных строк чеков,filter-chk-gds,   ~
Фильтр строк оплат чеков,filter-chk-pay,      ~
Фильтр чеков,filter-chk-doc,                  ~
Фильтр чеков с разн.по запр.за нал,filter-chk-doc-autotank, ~
С атрибутом оплаты,cpdoc-attr,               ~
Атрибут оплаты =,cpdoc-attr-val"


&glob no-browser-option '':U

define variable f-name as char init "default.chk" no-undo.

FUNCTION get-table-name returns character(input p-is-wth as logical):
CASE p-is-wth:
  when yes then return {&table_chk-DOC}.
  otherwise return {&table_chk-doc}.

END CASE.
END FUNCTION.
&if "{1}" <> "chk-list" &then
&message anchlist.i можно вызывать только для таблицы chk-list
&endif


{ cmp/listhist.i macro-list "new shared" }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-list

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES {1} temp-list

/* Definitions for BROWSE BR-list                                       */
&Scoped-define FIELDS-IN-QUERY-BR-list {1}.doc-code {1}.obj-type ~
{1}.obj-code {1}.chk-date string({1}.chk-time, "hh:mm:ss":U) ~
{1}.chk-num {1}.pay-desk {1}.cashier {1}.cashier-psn-code ~
{1}.out-code {1}.shift-date shift-name-no-err(buffer {1}) ~
get-chk-type({1}.doc-code, {1}.chk-type, {1}.is-wth) {1}.d-card ~
{1}.netto {1}.discnt {1}.tot-doc {1}.doc-num {1}.doc-num2
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-list
&Scoped-define FIELD-PAIRS-IN-QUERY-BR-list
&Scoped-define OPEN-QUERY-BR-list OPEN QUERY BR-list FOR EACH {1} NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-list {1}
&Scoped-define FIRST-TABLE-IN-QUERY-BR-list {1}

/* Definitions for BROWSE BR-option                                    */
&Scoped-define FIELDS-IN-QUERY-BR-option temp-list.fname
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-option
&Scoped-define FIELD-PAIRS-IN-QUERY-br-option
&Scoped-define SELF-NAME br-option
&Scoped-define OPEN-QUERY-br-option open query br-option for each temp-list no-lock .
&Scoped-define TABLES-IN-QUERY-br-option temp-list
&Scoped-define FIRST-TABLE-IN-QUERY-br-option temp-list

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-list} ~
    ~{&OPEN-QUERY-BR-option}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS dsp-rs b-exit B-save B-print B-hist ~
B-lkp B-clr B-Help B-add B-del B-rest B-macro B-stop B-clear-macro ~
B-record br-option BR-list f-tot-lns sch-code sch-chk-date ~
sch-shift-date ED-notes CHK-STATUS v-end-date v-start-date
&Scoped-Define DISPLAYED-OBJECTS dsp-rs f-tot-lns sch-code sch-chk-date ~
sch-shift-date ED-notes CHK-STATUS v-end-date v-start-date

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-chk-type Dialog-Frame
FUNCTION get-chk-type RETURNS CHARACTER
  ( input loc-doc-code as character,
    input loc-chk-type as integer,
    input loc-is-wth as logical)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD stat-line Dialog-Frame
FUNCTION stat-line RETURNS CHARACTER
  (input p-status-chr as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-save
       MENU-ITEM m_chk-save     LABEL "Файл списка чеков"
       MENU-ITEM m_xls-save     LABEL "Таблица EXCEL"
       MENU-ITEM m_xls-save2     LABEL "Таблица EXCEL (с выбором полей)"
       MENU-ITEM m-title-save   LABEL "Имя списка"
       MENU-ITEM m-macros-save  LABEL "Макрос формирования списка".

DEFINE MENU MENU-B-print
       MENU-ITEM m_short   LABEL "Список чеков"
       MENU-ITEM m_gds     LABEL "Список строк чеков(товарных)"
       MENU-ITEM m_gds-excel LABEL "Список строк чеков(товарных) в EXCEL"
       MENU-ITEM m_gds-pay LABEL "Содержимое товар.чеков"
       MENU-ITEM m_one     LABEL "Один чек"
       /*
       MENU-ITEM m_doc     LABEL "Список чеков"
       MENU-ITEM m_pay     LABEL "Список строк оплат или список строк МЦ" */
       .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&+Доб. строку"
     SIZE 20 BY 1 TOOLTIP "Добавление в список чеков 1 строки".

DEFINE BUTTON B-clear-macro
     IMAGE-UP FILE "cmp/fstop.bmp":U
     IMAGE-DOWN FILE "cmp/fstopi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/fstopi.bmp":U
     LABEL "&[ ]"
     SIZE 4 BY 1.25 TOOLTIP "Удаление макроса формирования истории из памяти".

DEFINE BUTTON B-clr
     LABEL "Очи&стить"
     SIZE 10 BY 1 TOOLTIP "Удалить из списка все чеки (строки)".

DEFINE BUTTON B-del
     LABEL "&-Удал. строку"
     SIZE 20 BY 1 TOOLTIP "Удаление из списка чеков 1 строки".

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1 TOOLTIP "Последовательность шагов, приведшая к заполнению данного списка".

DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр текущего чека".

DEFINE BUTTON B-macro
     IMAGE-UP FILE "cmp/run.bmp":U
     IMAGE-DOWN FILE "cmp/runi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/runi.bmp":U
     LABEL "&>"
     SIZE 4 BY 1.25 TOOLTIP "Выполнение макроса формирования истории".

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1 TOOLTIP "Печать текущего чека".

DEFINE BUTTON B-record
     IMAGE-UP FILE "cmp/record.bmp":U
     IMAGE-DOWN FILE "cmp/recordi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/recordi.bmp":U
     LABEL "&o"
     SIZE 4 BY 1.25 TOOLTIP "Запись макроса формирования истории".

DEFINE BUTTON B-rest
     LABEL "&*Остав. строку"
     SIZE 20 BY 1 TOOLTIP "Оставить в списке чеков только текущую строку".

DEFINE BUTTON B-save
     LABEL "Со&хранить"
     SIZE 10 BY 1 TOOLTIP "Сохранить список чеков в текстовом файле, EXCEL".

DEFINE BUTTON B-stop
     IMAGE-UP FILE "cmp/stop.bmp":U
     IMAGE-DOWN FILE "cmp/stopi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/stopi.bmp":U
     LABEL "&[ ]"
     SIZE 4 BY 1.25 TOOLTIP "Конец записи макроса формирования истории".

DEFINE VARIABLE ED-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 71 BY 1.54 NO-UNDO.

DEFINE VARIABLE dsp-rs AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 75.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-tot-lns AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 10 BY .71 TOOLTIP "Кол. строк"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE CHK-STATUS AS character
    VIEW-AS RADIO-SET HORIZONTAL
    RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
    SIZE 34.75 BY 1 NO-UNDO.

DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Нач. №"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE sch-chk-date AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "Дата чека"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE sch-shift-date AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "Дата см.(учета)"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE v-end-date AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE v-start-date AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "С"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-list FOR
      {1} SCROLLING.
&ANALYZE-RESUME

&ANALYZE-SUSPEND
DEFINE QUERY br-option FOR
      temp-list SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-list Dialog-Frame _STRUCTURED
  QUERY BR-list DISPLAY
      {1}.doc-code format "X(22)"
      {1}.obj-type
      {1}.obj-code
      {1}.chk-date
      string({1}.chk-time, "hh:mm:ss":U)
      {1}.chk-num COLUMN-LABEL "№ чека!на кассе" format "->>>>99999"
      {1}.pay-desk
      {1}.cashier
      {1}.cashier-psn-code
      {1}.out-code
      {1}.shift-date COLUMN-LABEL "Дата смены!учета"
      shift-name-no-err(buffer {1}) COLUMN-LABEL "№ смены" FORMAT "X(6)"
      get-chk-type({1}.doc-code, {1}.chk-type, {1}.is-wth) COLUMN-LABEL "Тип чека" FORMAT "X(10)"
      {1}.d-card
      {1}.netto
      {1}.discnt
      {1}.tot-doc
      {1}.doc-num
      {1}.doc-num2      
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 70 BY 15.13.

DEFINE BROWSE BR-option
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-option Dialog-Frame _FREEFORM
  QUERY br-option 
  DISPLAY
    temp-list.fname format "X(40)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-LABELS SEPARATORS SIZE 26 BY 21 TOOLTIP "Условие для выбора чеков, которые будут добавлены/удалены/оставлены".

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     dsp-rs AT ROW 1 COL 1 NO-LABEL
     B-print AT ROW 1 COL 89
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     br-option AT ROW 2 COL 72
     B-exit AT ROW 2 COL 1
     B-save AT ROW 2 COL 11
     B-lkp AT ROW 2 COL 21
     B-clr AT ROW 2 COL 31
     B-macro AT ROW 2 COL 51
     B-stop AT ROW 2 COL 55
     B-clear-macro AT ROW 2 COL 55
     B-record AT ROW 2 COL 55
     f-tot-lns AT ROW 2 COL 60 COLON-ALIGNED NO-LABEL
     B-add AT ROW 3 COL 11
     B-del AT ROW 3 COL 31
     B-rest AT ROW 3 COL 51
     CHK-STATUS at row 4 col 2 no-label
     v-start-date at row 4 col 38
     v-end-date at row 4 col 53
     BR-list AT ROW 5.21 COL 1.25
     sch-code AT ROW 20.5 COL 1
     sch-chk-date AT ROW 20.5 COL 30 COLON-ALIGNED
     sch-shift-date AT ROW 20.5 COL 58 COLON-ALIGNED
     ED-notes AT ROW 21.54 COL 1 NO-LABEL
     SPACE(21.36) SKIP(0.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список чеков"
         DEFAULT-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: {1} T "SHARED" NO-UNDO ub chk-doc
      ADDITIONAL-FIELDS:
      field is-wth     as logical
      field sel-order  as integer
      field znak       as integer
      field to-del     as logical
      index xpk is primary unique doc-code is-wth
      index znak-order znak sel-order .
      END-FIELDS.
      TABLE: temp-list T "SHARED" NO-UNDO ub units
      ADDITIONAL-FIELDS:
          field fname as character format "X(30)"
          field fvalue as character
          field id as integer
          index pi is primary unique
          id
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BR-list B-rest Dialog-Frame */
/* BROWSE-TAB BR-list br-option Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame      = MENU MENU-B-print:HANDLE
       B-save:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-save:HANDLE.

/* SETTINGS FOR FILL-IN dsp-rs IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       ED-notes:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN sch-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-list
/* Query rebuild information for BROWSE BR-list
     _TblList          = "ub.{1}"
     _FldNameList[1]   = ub.{1}.doc-code
     _FldNameList[2]   = ub.{1}.obj-type
     _FldNameList[3]   = ub.{1}.obj-code
     _FldNameList[4]   = ub.{1}.chk-date
     _FldNameList[5]   > "_<CALC>"
"string({1}.chk-time, ""hh:mm:ss"":U)" ? ? ? ? ? ? ? ? ? no ?
     _FldNameList[6]   > ub.{1}.chk-num
"chk-num" "№ чека!на кассе" "-99999" "integer" ? ? ? ? ? ? no ?
     _FldNameList[7]   = ub.{1}.pay-desk
     _FldNameList[8]   = ub.{1}.cashier
     _FldNameList[9]   = ub.{1}.cashier-psn-code
     _FldNameList[10]   = ub.{1}.out-code
     _FldNameList[11]   > ub.{1}.shift-date
"shift-date" "Дата смены!учета" ? "date" ? ? ? ? ? ? no ?
     _FldNameList[12]   > "_<CALC>"
"shift-name-no-err(buffer {1})" "№" "X(6)" ? ? ? ? ? ? ? no ? no no "7" yes no no "U" "" ""
     _FldNameList[13]   > "_<CALC>"
"get-chk-type({1}.doc-code, {1}.chk-type, {1}.is-wth)" "Тип чека" "X(10)" ? ? ? ? ? ? ? no ?
     _FldNameList[14]   = ub.{1}.d-card
     _FldNameList[15]   = ub.{1}.netto
     _FldNameList[16]   = ub.{1}.discnt
     _FldNameList[17]   = ub.{1}.tot-doc
     _Query            is OPENED
*/  /* BROWSE BR-list */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-option
/* Query rebuild information for BROWSE br-option
     _START_FREEFORM
open query br-option for each temp-list no-lock .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-option */
&ANALYZE-RESUME




/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список чеков */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-clr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-clr Dialog-Frame
ON CHOOSE OF B-clr IN FRAME Dialog-Frame /* Очистить */
DO:
define variable glog as logical no-undo .
define buffer buf-{1}-hist for {1}-hist.
{ gbl/stdbtn.i }
  glog = no.
message "Удаление всех строк списка. Вы уверены ?"
        view-as alert-box question buttons OK-Cancel update glog.
if not glog then return no-apply.
if session:set-wait-state( "COMPILER" )  then .
for each {1}:
  delete {1}.
end.
if session:set-wait-state( "" )  then .
tot-lns = 0.
v-seq = 1.
for each buf-{1}-hist:
  delete buf-{1}-hist.
end.
run create-{1}-hist in this-procedure (input {&add-def}
                                     , input-output v-seq
                                     , input 0
                                     , input '0':U
                                     , input "# Список чеков очищен."
                                     , input 0
                                     , input "clear"
                                     , input '':U
                                     , input '':U
                                     , input '':U
                                     , input ?
                                     ).
ed-notes:screen-value = ''.
display
tot-lns @ f-tot-lns
with frame {&frame-name}.
run MyEnable in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
{ gbl/stdbtn.i }
define buffer buf_{1}-hist for {1}-hist.
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).
find first buf_{1}-hist no-lock where buf_{1}-hist.id = 0 no-error .
PUT  STREAM PrnLibStream unformatted
SPACE(25) "История создания списка чеков "
(if available buf_{1}-hist
then buf_{1}-hist.des
else "БЕЗЫМЯННЫЙ") skip(0)
space(25) cur-time-print() skip(1)
.
put stream PrnLibStream unformatted
string("№", "X(9)") {&space-char}
string("Действие", "X(9)") {&space-char}
string("записей", "X(9)") {&space-char}
string(" = итого", "X(12)") {&space-char}
string("Множество", "X(155)")
skip(0)
fill('-':U, 9) {&space-char}
fill('-':U, 9) {&space-char}
fill('-':U, 9) {&space-char}
fill('-':U, 12) {&space-char}
fill('-':U, 155)
skip(0)
.
for each buf_{1}-hist where buf_{1}-hist.id > 0
by buf_{1}-hist.id
:
  put stream PrnLibStream unformatted
  (if buf_{1}-hist.line = 0
   then string(buf_{1}-hist.id, ">>>>>>>>9")
   else fill({&space-char} , 9)
  )  {&space-char}
  (if buf_{1}-hist.item_ <> '':U
   then string(buf_{1}-hist.hist-mode, "X(8)")
   else fill( {&space-char}, 8)) {&space-char}
  string(buf_{1}-hist.num-add, ">>>>>>>>9") {&space-char} {&space-char} {&space-char} {&space-char}
  string(buf_{1}-hist.num-recs, ">>>>>>>>9")  {&space-char}
  string(buf_{1}-hist.des, "X(155)") skip.
end.
output stream prnlibstream close.
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 8
                                            ).


 apply "entry" to br-list in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp Dialog-Frame
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
{ gbl/stdbtn.i }
 if not available {1} then do:
  message "Неправильно выбран чек."
          view-as alert-box error.
  return no-apply.
 end.
 run str/showchk.p (
                 input parparentproc
                ,input {1}.doc-code
                ,input {1}.is-wth
                ,input this-procedure:handle
              ) no-error .
 apply "entry" to br-list in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
{ gbl/stdbtn.i }
define variable v-frame-width as integer no-undo.

if print-option = "" then do:
    run gbl/pop-up.p (self:handle, no) no-error.
    if error-status:error or print-option = "":U then return no-apply.
end.
CASE print-option:
  when "short":U then do:
    print-option = ''.
    run str/chkl-prn.p (
                   input parparentproc
                  ,input "":U
                  ,input "":U /*print-option  на будуещее будет здесь и печать строк чеков*/
                  ,input '':U /*p-notes*/
                  ,output v-Frame-Width) no-error.

    if v-frame-width <= 198 then do:
      run prn-lib-prn-file in this-procedure (
                                                input parParentProc
                                                ,input (if v-frame-width <= 136 then 0 else 8)
                                                ).
    end.
    else do:
      run prn-lib-prn-file in this-procedure (
                                                input parParentProc
                                                ,input (if v-frame-width <= 255 then 1 else 20)
                                                ).
    end.
  end.
  when {&table_chk-gds} then do:
    print-option = ''.
    run str/chklgprn.p (
                   input parparentproc
                  ,input "":U
                  ,input "":U /*print-option  на будуещее бует зедсь и печать строк чеков*/
                  ,output v-Frame-Width) no-error.

    if v-frame-width <= 198 then do:
      run prn-lib-prn-file in this-procedure (
                                                input parParentProc
                                                ,input (if v-frame-width <= 136 then 0 else 8)
                                                ).
    end.
    else do:
      run prn-lib-prn-file in this-procedure (
                                                input parParentProc
                                                ,input (if v-frame-width <= 255 then 1 else 20)
                                                ).
    end.
  end.
  when {&table_chk-gds} + {&comma-char} + {&output-type-excel} then do:
    print-option = ''.
    run str/chklgprx.p (
                   input parparentproc
                  ,input p-curr-obj-type
                  ,input p-curr-obj-code
                  ) no-error.
  end.
  when ({&table_chk-gds} + {&comma-char} + {&table_chk-pay}) then do:
    print-option = ''.
    run str/chklsprn.p (
                   input parparentproc
                  ,input "":U
                  ,input "":U /*print-option  на будуещее бует зедсь и печать строк чеков*/
                  ,output v-Frame-Width) no-error.

    if v-frame-width <= 198 then do:
      run prn-lib-prn-file in this-procedure (
                                                input parParentProc
                                                ,input (if v-frame-width <= 136 then 0 else 8)
                                                ).
    end.
    else do:
      run prn-lib-prn-file in this-procedure (
                                                input parParentProc
                                                ,input (if v-frame-width <= 255 then 1 else 20)
                                                ).
    end.
  end.

  when "one":U then do:
    print-option = "":U.
    if not available {1} then do:
      message
      "Нет чека для печати"
      view-as alert-box .
      apply "entry" to br-list in frame {&frame-name}.
    end.
    if {1}.is-wth then do:
      run str/checkwp.p (input parparentproc, {1}.doc-code) no-error.
    end.
    else do:
      run str/checkp.p (input parparentproc, {1}.doc-code) no-error.
    end.
  end.
END CASE.
assign
print-option = "":U.
apply "entry" to br-list in frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-save Dialog-Frame
ON CHOOSE OF B-save IN FRAME Dialog-Frame /* Сохранить */
DO:
{ gbl/stdbtn.i }
    if save-option = "" then do:
       run gbl/pop-up.p (self:handle, no) no-error.
   end.
   run proc-b-save in this-procedure(save-option) no-error.
   if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-list
&Scoped-define SELF-NAME BR-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-list Dialog-Frame
ON VALUE-CHANGED OF BR-list IN FRAME Dialog-Frame
DO:
  {&disp-hot-fields}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-option
&Scoped-define SELF-NAME br-option
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-option Dialog-Frame
ON RETURN, MOUSE-SELECT-DBLCLICK OF br-option IN FRAME Dialog-Frame /* Browse 2 */
DO:
  assign
  Rs-list-method = temp-list.fvalue
  .
  apply "VALUE-changed" to CHK-STATUS in frame {&frame-name} .
  run proc-vc-rs-list-method in this-procedure no-error .
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_chk-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_chk-save Dialog-Frame
ON CHOOSE OF MENU-ITEM m_chk-save /* Файл списка чеков */
DO:
    assign
  save-option = "chk-list":U.
  apply "choose" to b-save in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/*
&Scoped-define SELF-NAME m_doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_doc Dialog-Frame
ON CHOOSE OF MENU-ITEM m_doc /* Cписок товарных строк */
DO:
    assign
  print-option = "doc":U.
  apply "choose" to b-print in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
*/

&Scoped-define SELF-NAME m_gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_gds Dialog-Frame
ON CHOOSE OF MENU-ITEM m_gds /* Cписок товарных строк */
DO:
    assign
  print-option =  {&table_chk-gds}.
  apply "choose" to b-print in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_gds-excel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_gds-excel Dialog-Frame
ON CHOOSE OF MENU-ITEM m_gds-excel /* Cписок товарных строк в EXCEL*/
DO:
  assign
  print-option =  {&table_chk-gds} + {&comma-char} + {&output-type-excel}.
  apply "choose" to b-print in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME m_gds-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_gds Dialog-Frame
ON CHOOSE OF MENU-ITEM m_gds-pay /* Cписок товарных строк */
DO:
  assign
  print-option = {&table_chk-gds} + {&comma-char} + {&table_chk-pay}.
  apply "choose" to b-print in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_one Dialog-Frame
ON CHOOSE OF MENU-ITEM m_one /* Один чек */
DO:
    assign
  print-option = "one":U.
  apply "choose" to b-print in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m-macros-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-macros-save Dialog-Frame
ON CHOOSE OF MENU-ITEM m-macros-save /* Файл макрос */ DO:
{ gbl/stdbtn.i b-save "in frame {&frame-name}" }
run proc-macros in this-procedure no-error .
if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/*
&Scoped-define SELF-NAME m_pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_pay Dialog-Frame
ON CHOOSE OF MENU-ITEM m_pay /* Cписок строк оплат или список строк МЦ */
DO:
    assign
  print-option = "pay":U.
  apply "choose" to b-print in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
*/

&Scoped-define SELF-NAME m_short
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_short Dialog-Frame
ON CHOOSE OF MENU-ITEM m_short /* Cписок чеков */
DO:
    assign
  print-option = "short":U.
  apply "choose" to b-print in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-title-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-title-save Dialog-Frame
ON CHOOSE OF MENU-ITEM m-title-save /* ИМЯ СПИСКА */
DO:
define variable v-value as character no-undo .
  run gbl/d-prompt.w (
      'title=':u + "Введите ИМЯ СПИСКА ЧЕКОВ" + '\':u
    + 'format=' + "X(60)" + '\':u
    + 'type=' + {&type-char} + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=60\':u
    + 'fillin_height=1\':u
    + 'max-chars=60\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=no\':u
    , input-output v-value
    ).
if return-value = 'false':u then return NO-apply.
run create-{1}-hist in this-procedure (input 'title'
                                     , input-output v-seq
                                     , input 0
                                     , input 'N':U
                                     , input v-value
                                     , input tot-lns
                                     , input "title"
                                     , input '':U
                                     , input '':U
                                     , input '':U
                                     , input ?
                                     ).
assign
frame {&frame-name}:title = substitute("СПИСОК ЧЕКОВ &1", v-value).
END.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_xls-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_xls-save Dialog-Frame
ON CHOOSE OF MENU-ITEM m_xls-save /* Таблица EXCEL */
DO:
    assign
  save-option = "excel":U.
  apply "choose" to b-save in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_xls-save2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_xls-save2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_xls-save2 /* Таблица EXCEL2 */
DO:
    assign
  save-option = "excel2":U.
  apply "choose" to b-save in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME CHK-STATUS
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CHK-STATUS Dialog-Frame
ON VALUE-CHANGED OF CHK-STATUS IN FRAME {&frame-name} DO:
define variable v-today as date no-undo .
define variable v-time as integer no-undo .
define variable v-old-status as character no-undo .
  run cur-time in this-procedure (
                                  output v-today
                                 ,output v-time).
  assign
  v-old-status = CHK-STATUS
  CHK-STATUS
  .

    if CHK-STATUS = "chk-date":U
    then do:
      if v-start-date = ? or v-end-date = ? then
      assign
      v-start-date = date(month(v-today - 1), 1, year(v-today))
      v-end-date = v-today - 1.
      
      RS-STATUS = CHK-STATUS + {&delim-par} + string(v-start-date, "99/99/9999") + {&delim-par} + string(v-end-date, "99/99/9999")
      .
      display
      v-start-date
      v-end-date
      with frame {&frame-name} .
    end.
    else do:
      assign
      v-start-date = ?
      v-end-date = ?
      RS-STATUS = CHK-STATUS
      .
      hide
      v-start-date
      v-end-date
      in frame {&frame-name} .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* Начало номера */
DO:
  assign
  sch-code.
  run proc-find in this-procedure("doc-code":U) no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame /* Начало номера */
DO:
    assign
  sch-code.
  run proc-find in this-procedure("doc-code":U) no-error.
  if error-status:error then do:
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-chk-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-chk-date Dialog-Frame
ON CTRL-J OF sch-chk-date IN FRAME Dialog-Frame /* Факт. дата */
DO:
   assign
  sch-chk-date.
  run proc-find in this-procedure("chk-date":U) no-error.
  if error-status:error then do:
    return no-apply.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-chk-date Dialog-Frame
ON RETURN OF sch-chk-date IN FRAME Dialog-Frame /* Факт. дата */
DO:
   assign
  sch-chk-date.
  run proc-find in this-procedure("chk-date":U) no-error.
  if error-status:error then do:
    return no-apply.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-shift-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-shift-date Dialog-Frame
ON CTRL-J OF sch-shift-date IN FRAME Dialog-Frame /* Факт. дата */
DO:
   assign
  sch-shift-date.
  run proc-find in this-procedure("shift-date":U) no-error.
  if error-status:error then do:
    return no-apply.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-shift-date Dialog-Frame
ON RETURN OF sch-shift-date IN FRAME Dialog-Frame /* Факт. дата */
DO:
   assign
  sch-shift-date.
  run proc-find in this-procedure("shift-date":U) no-error.
  if error-status:error then do:
    return no-apply.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-end-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-end-date Dialog-Frame
ON LEAVE OF v-end-date IN FRAME Dialog-Frame /* Факт. дата */
DO:
{ gbl/stdbtn.i }
 assign
 v-end-date.
 RS-STATUS = CHK-STATUS + {&delim-par} + string(v-start-date, "99/99/9999") + {&delim-par} + string(v-end-date, "99/99/9999").

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-start-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-start-date Dialog-Frame
ON LEAVE OF v-start-date IN FRAME Dialog-Frame /* Факт. дата */
DO:
{ gbl/stdbtn.i }
  assign
  v-start-date.
  RS-STATUS = CHK-STATUS + {&delim-par} + string(v-start-date, "99/99/9999") + {&delim-par} + string(v-end-date, "99/99/9999").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame

{ gbl/hot-key.i b-print }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-del }


on any-printable of br-list in frame {&frame-name} do:
  apply "entry" to sch-code in frame {&frame-name}.
end.
ON RETURN, MOUSE-SELECT-DBLCLICK OF br-list IN FRAME {&frame-name} DO:
    apply "choose" to b-lkp in frame {&frame-name}.
END.


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i &disable_diasize=true }
{ gbl/diasize.i &browse-name="br-list" }

run diasize_add_browse in this-procedure
  (input  'height':u
  ,input  browse BR-option :handle
  ) .
run diasize_init in this-procedure .

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

{ cmp/ex-chk.i {1} {&frame-name} buf_chk-doc }
&glob ui-on MyEnable
{ str/an-listp.i {1} chk-list chm }
{ gbl/brwrepos.i
&browse-name=br-list
&line-num=5 }

{ gbl/ed_date.i sch-chk-date }
{ gbl/ed_date.i sch-shift-date }
{ gbl/ed_date.i v-start-date }
{ gbl/ed_date.i v-end-date }

{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }
{ ref/tabhndmv.i v-tab-order underline-tb }


MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }
 run get-report-num in parparentproc ( output g#report-num ).
  assign
  line-rec = ?
  .
  /*заполним temp-list*/
  run proc-fill-temp-list in this-procedure .
  ASSIGN
  b-print:MENU-MOUSE = 1
  b-save:MENU-MOUSE = 1
  .
  RUN Myenable in this-procedure.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  DISPLAY dsp-rs sch-code sch-chk-date sch-shift-date ED-notes f-tot-lns CHK-STATUS
          v-end-date v-start-date
      WITH FRAME Dialog-Frame.
  ENABLE dsp-rs B-exit B-save B-print B-hist B-lkp B-clr B-Help
         B-add B-del B-rest B-macro B-stop B-clear-macro B-record BR-list sch-code
         sch-chk-date sch-shift-date ED-notes f-tot-lns CHK-STATUS v-end-date
         v-start-date
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
define variable v-start as logical no-undo .
define variable v-recid0 as recid no-undo.
define buffer buf_temp-list for temp-list.
define buffer buf_{1}-hist for {1}-hist.
assign
CHK-STATUS:radio-buttons in frame {&frame-name}
= "Неучтенные&+" + {&comma-char} + "free":U + {&comma-char} +
                          "Все!" + {&comma-char} + {&all} + {&comma-char} +
                          "В диапазоне дат-" + {&comma-char} + "chk-date":U
CHK-STATUS = (if CHK-STATUS = "":U then {&all} else CHK-STATUS)
.
find first buf_{1}-hist where buf_{1}-hist.id = 0 no-error.
if available buf_{1}-hist then
assign
frame {&frame-name}:title = substitute("СПИСОК  ЧЕКОВ &1",  string(buf_{1}-hist.des, "X(60)"))
.
br-option:column-scrolling in frame {&frame-name}  = no. /*чтобы работала прокрутка*/

  if tot-lns = ? then do:
  /* первоначальное заполнение истории списка при входе в него */
  v-start = yes.
  for each l-{1} :
    accumulate l-{1}.obj-code (count).
  end.
  tot-lns = (accum count l-{1}.obj-code).
  if tot-lns > 0 then do:
    find last  buf_{1}-hist no-error .
    v-seq = (if available buf_{1}-hist then buf_{1}-hist.id else 0)  + 1.
    run create-{1}-hist in this-procedure (input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input 'S':U
                                          , input substitute("# Исходный список: &1 строк", tot-lns)
                                          , input tot-lns
                                          , input "start":U
                                          , input '':U
                                          , input '':U
                                          , input '':U
                                          , input ?
                                          ).
  end.
  else do:
    line-mode = {&add-def}.
    for each buf_{1}-hist:
      delete buf_{1}-hist.
    end.
    v-seq = 1.
    run create-{1}-hist in this-procedure (input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input "# Исходный список чеков пуст."
                                          , input tot-lns
                                          , input 'start':U
                                          , input '':U
                                          , input '':U
                                          , input '':U
                                          , input ?
                                          ).
  end.
end.
find first buf_temp-list no-lock where
            buf_temp-list.fvalue = "single".
assign
v-recid0 = recid(buf_temp-list).
{&OPEN-QUERY-br-option}
assign
RS-list-method = "single".
if v-seq > 1 then
find last buf_{1}-hist no-lock where
          buf_{1}-hist.id = (v-seq - 1)
      and  buf_{1}-hist.line = 0 no-error .
DISPLAY br-option
(if available buf_{1}-hist
then buf_{1}-hist.des
else '') @ dsp-rs
CHK-STATUS WITH FRAME {&frame-name}.
ENABLE
b-macro  when v-start
b-record when v-start
b-exit b-add b-hist b-help br-option br-list CHK-STATUS WITH FRAME {&frame-name}.
if v-start then do:
  hide
  b-stop
  b-clear-macro
  in frame {&frame-name}.
end.
v-start = no.
hide sch-code in frame {&frame-name}
sch-chk-date in frame {&frame-name}
sch-shift-date in frame {&frame-name}
.
ENABLE
b-exit
b-add
b-hist
b-help
br-list
br-option
CHK-STATUS
v-start-date
v-end-date
WITH FRAME {&frame-name}.
apply "VALUE-changed" to CHK-STATUS.
reposition br-option to recid v-recid0.
if tot-lns > 0 then
  ENABLE
  b-print
  b-rest
  b-save
  b-del
  b-lkp
  b-clr
  sch-code
  sch-chk-date
  sch-shift-date
  WITH FRAME {&frame-name}.
else do:
  DISABLE b-print b-rest b-save b-del b-lkp b-clr sch-code sch-chk-date sch-shift-date WITH FRAME {&frame-name}.
end.
if tot-lns = ? or tot-lns = 0 then do:
  hide sch-code sch-chk-date sch-shift-date in frame {&frame-name} .
end.
VIEW FRAME {&frame-name}.
apply "VALUE-changed" to CHK-STATUS.
run openbr in this-procedure.
if line-rec <> ? then
  reposition br-list to recid line-rec no-error.
/* Отключено, т.к. после reposition в updatable browse последняя строка выводится повторно на месте 1-й.
    Включается только в старом варианте списка */
/* Отключено, т.к. после reposition в updatable browse последняя строка выводится повторно на месте 1-й.
    Вместо этого скопирован следующий кусок кода из триггера на iteration-changed.
    apply "iteration-changed" to br-list in frame {&frame-name}. */
{&disp-hot-fields}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
        Open query br-list
        for each {1} No-LOCK indexed-reposition.
APPLY "ENTRY" to br-list in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter CHK-STATUS as character no-undo .

line-mode = {&add-def}.
if rs-list-method = "single" then do:
  v-no-hist = - 1.
  if p-from-macro then do:
    find ub.chk-doc where rowid(ub.chk-doc) = p-rowid no-lock no-error .
    if not available ub.chk-doc then do:
      return error "Нет в БД такого чека".
    end.
  end.
  else do:
    v-rid-list = ''.
    run str/chk-docs.w (
                 input parparentproc
                ,input "b-sel":U
                ,input {&g___object} /*par-mode*/
                ,input ?
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input ? /*parout-code*/
                ,input "":U /*pard-card*/
                ,input 0 /*p-pay-desk*/
                ,input ?
                ,input ?
                ,input 0
                ,output v-rid-list
                ).
    apply "entry" to br-list in frame {&frame-name}.
    if v-rid-list = "" then return error.
    /* выбран чек */
    find first chk-doc where recid (chk-doc) = integer (v-rid-list) no-lock no-error .
  end.
  if (not p-from-macro and available chk-doc)
  or (p-from-macro and  available chk-doc)
  then do:
    run ex-chk in this-procedure (
                                 input rs-list-method
                               , input rs-status
                               , input line-mode).
    tot-lns = tot-lns + 1.
    run write-hist in this-procedure (input p-from-macro, input rs-list-method, input CHK-STATUS, input line-mode).
  end.
  else do:
    return error "Нет в БД такого чека".
  end.
  run Myenable in this-procedure .
end.
else do:
    run rs-do in this-procedure (input no, input no, input rs-list-method, input CHK-STATUS, input line-mode, input v-seq - 1).
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter CHK-STATUS as character no-undo .
define variable v-rep-rec as recid no-undo .
line-mode = {&deletion}.
if rs-list-method = "single" then do:
  v-no-hist = - 1.
  if p-from-macro then do:
    find ub.chk-doc where rowid(ub.chk-doc) = p-rowid no-lock no-error .
    if not available ub.chk-doc then do:
      return error "Нет в БД такого чека".
    end.
    find first {1} where {1}.doc-code = chk-doc.doc-code no-error.
  end.
  if available {1} then do:
    line-rec = recid ({1}).
    get next br-list.
    if available {1} then v-rep-rec = recid ({1}).
    else do:
      reposition br-list to recid line-rec no-error.
      get prev br-list.
      if available {1} then v-rep-rec = recid ({1}).
    end.
    reposition br-list to recid line-rec no-error.
    tot-lns = tot-lns - 1.
    run write-hist in this-procedure (input p-from-macro, input rs-list-method, input CHK-STATUS, input line-mode).
    delete {1}.
    line-rec = v-rep-rec.
    run Myenable in this-procedure.
  end.
  else do:
    return error "Нет в списке чеков такого чека".
  end.
end.
else do:
  glog = no.
  message "Удалить чеки из списка ПО заданному УСЛОВИЮ ?   Вы уверены ?"
          view-as alert-box question buttons OK-Cancel update glog.
  if not glog then
    return error.
  run rs-do in this-procedure (input no, input no, input rs-list-method, input CHK-STATUS, input line-mode, input v-seq - 1).
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-rest Dialog-Frame
PROCEDURE proc-b-rest :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter CHK-STATUS as character no-undo .
define variable glog as logical no-undo .
define buffer buf_{1}-hist for {1}-hist.
line-mode = {&leave}.
if rs-list-method = "single" then do:
  v-no-hist = - 1.
  if p-from-macro then do:
    find ub.chk-doc where rowid(ub.chk-doc) = p-rowid no-lock no-error .
    if not available ub.chk-doc then do:
      return error "Нет в БД такого чека".
    end.
    find first {1} where {1}.doc-code = chk-doc.doc-code no-error.
  end.
  if available {1} then do:
    if p-from-macro then do:
       glog = yes.
    end.
    else do:
      glog = no.
      message "Оставить отмеченную строку и УДАЛИТЬ ВСЕ ОСТАЛЬНЫЕ ?   Вы уверены ?"
              view-as alert-box question buttons OK-Cancel update glog.
      if not glog then return no-apply.
    end.
    line-rec = recid ({1}).
    v-seq = 1.
    for each buf_{1}-hist:
      delete buf_{1}-hist.
    end.
    run write-hist in this-procedure (input p-from-macro, input rs-list-method, input RS-STATUS, input line-mode).
    for each {1}:
      if line-rec <> recid ({1}) then delete {1}.
    end.
    tot-lns = 1.
    run Myenable in this-procedure .
  end.
  else do:
    return error substitute("Нет в списке такого чека").
  end.
end.
else do:
  if not p-from-macro then do:
    glog = no.
    message "Оставить чеки в списке ПО заданному УСЛОВИЮ и УДАЛИТЬ ВСЕ ОСТАЛЬНЫЕ ?   Вы уверены ?"
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then
      return no-apply.
  end.
  assign
  lns-cnt = 0
  lns-ignore = 0
  .
  run rs-do in this-procedure (input no, input no, input rs-list-method, input CHK-STATUS, input line-mode, input v-seq - 1).
  for each {1}:
    if {1}.to-del = ? then do:
      assign
      {1}.to-del = no
      .
    end.
    else do:
      delete {1}.
    end.
  end.
  tot-lns = lns-cnt.
  run Myenable in this-procedure.
  message
  "Оставлено строк :" lns-cnt skip(0)
  string(if lns-ignore <> 0
  then ("Проигнорировано строк :" + string(lns-ignore))
  else "":U)
  .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-save Dialog-Frame
PROCEDURE proc-b-save :
define input parameter loc-save-option as character no-undo.
define variable v-frame-width as integer no-undo.
case loc-save-option:
  when "chk-list":U then do:
    assign
    f-chk-name = "default.chk"
    glog = yes
    .
    system-dialog get-file f-chk-name
    filters "Списки чеков *.chk" "*.chk"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "chk".
    if not glog then do:
      apply "entry" to br-list in frame {&frame-name}.
      return no-apply.
    end.
    run waitfram-show in this-procedure ("Ждите" ).
    output to value (f-chk-name).
    for each {1}:
      export
      {1}.doc-code
      {1}.chk-type
      {1}.obj-type
      {1}.obj-code
      {1}.chk-date
      {1}.chk-time
      {1}.chk-num
      {1}.pay-desk
      {1}.cashier
      {1}.out-code
      .
    end.
    output close.
    run waitfram-hide in this-procedure .
  end.
  when "excel":U then do:
    do on stop  undo, return no-apply
        on error undo, return no-apply
        on quit  undo, return no-apply
    :
      run str/chkl-prn.p ( input parparentproc
                      ,input "excel":U
                      ,input "":U
                      ,input '':U /*notes*/
                      ,output v-Frame-Width) no-error.
      run waitfram-hide in this-procedure .
    end.
  end.
  when "excel2":U then do:
    do on stop  undo, return no-apply
        on error undo, return no-apply
        on quit  undo, return no-apply
    :
      run str/chkl-prx.p (
                   input parparentproc
                  ,input p-curr-obj-type
                  ,input p-curr-obj-code
                  ) no-error.

      run waitfram-hide in this-procedure .
    end.
  end.

end case.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find Dialog-Frame
PROCEDURE proc-find :
define input parameter loc-find as character no-undo.

case loc-find:
  when "doc-code":U then do:
    if last-event:label = "Ctrl-J" then
        find next l-{1} no-lock where
                   l-{1}.doc-code begins sch-code no-error.

    else
        find first l-{1} no-lock where
                   l-{1}.doc-code begins sch-code no-error.
  end.
  when "chk-date":U then do:
    if last-event:label = "Ctrl-J" then
        find next l-{1} no-lock where
                   l-{1}.chk-date = sch-chk-date no-error.
    else
        find first l-{1} no-lock where
                   l-{1}.chk-date = sch-chk-date no-error.

  end.
  when "shift-date":U then do:
    if last-event:label = "Ctrl-J" then
        find next l-{1} no-lock where
                   l-{1}.shift-date = sch-shift-date no-error.
    else
        find first l-{1} no-lock where
                   l-{1}.shift-date = sch-shift-date no-error.

  end.
end case.
if available l-{1} then do:
  line-rec = recid (l-{1}).
  reposition br-list to recid line-rec no-error.
  apply "value-changed" to br-list in frame {&frame-name}.
end.
else do:
  message
  "Строка не найдена."
  view-as alert-box error.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-macros Dialog-Frame
procedure proc-macros :
define variable glog as logical no-undo .
define variable v-option as integer no-undo .
define buffer buf_{1}-hist for {1}-hist.
define buffer buf_macro-list-hist for macro-list-hist.
if can-find(first macro-list-hist) then do:
  run gbl/d-askw.w ( input "Сохранение макроса"
                ,input "Выберите какие действия по формированию списка Вы хотите сохранить"
                ,input "|"
                ,input "Посл.ЗАПИСЬ|Все|Отказ"
                ,input "Действия при нажатой кнопке ЗАПИСЬ|ВСЯ последовательность действий|Отказ"
                ,input 1
                ,input 3
                ,output v-option).
  if v-option = 3 then return no-apply.
  v-option = 1.
end.
else do:
  message
  "Будет сохранена в файл ВСЯ последовательность действий по формированию списка" skip
  view-as alert-box question buttons yes-no update glog.
  v-option = 2.
  if not glog then do:
    return no-apply.
  end.
end.

  do
  on error undo, return error
  :
  assign
    f-name = "default.chm"
    glog = yes
    .
  system-dialog get-file f-name
    filters "Макрос создания списка чеков *.chm" "*.chm"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "chm".
  if not glog then do:
    apply "entry" to br-list in frame {&frame-name}.
    return no-apply.
  end.
  run waitfram-show in this-procedure ("Сохранение макроса формирования списка чеков.    ЖДИТЕ...").
  output stream PrnLibStream to value (f-name).
  case v-option:
    when 1 then do:
      for each buf_macro-list-hist:
        export stream PrnLibStream
        buf_macro-list-hist.
      end.
    end.
    when 2 then do:
  for each buf_{1}-hist:
      export stream PrnLibStream
      buf_{1}-hist.
  end.
    end.
  end case.
  output stream PrnLibStream close.
  run waitfram-hide in this-procedure .
  end.
end procedure. /* proc-macro */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-vc-rs-list-method Dialog-Frame
PROCEDURE proc-vc-rs-list-method :
define variable v-operation as integer no-undo .
define variable v-chk-types as character no-undo .
define variable v-chk-names as character no-undo .
define variable ii as integer no-undo.
define variable glog as logical no-undo .
define variable v-recs as integer no-undo .
define variable v-recs2 as integer no-undo .
define variable v-line as integer no-undo .             /* для create-{1}-hist */
define variable v-item as character no-undo .           /* для create-{1}-hist */
define variable v-bh as handle no-undo .                /* для create-{1}-hist */
define variable v-tot-lns as integer no-undo .          /* для create-{1}-hist */
define variable v-temp-seq as integer no-undo .         /* для create-{1}-hist */
define variable v-message as character no-undo .
define variable grp-path as character no-undo .
define variable v-input-output as character no-undo .
define variable v-ref-rec as recid no-undo .
define variable v-ref-row as character no-undo .
define variable v-ref-rec2 as recid no-undo .
define variable v-grp-rec as recid no-undo .
define variable v-doc-rec as recid no-undo .
define variable f-name as char init "default.chk" no-undo.
define variable v-prev-type as character no-undo .
define variable v-prev-code as integer no-undo .
define variable v-tbl-name as character no-undo .       /* для create-{1}-hist */
define buffer buf_{1}-hist for {1}-hist.
define buffer buf_inkas for ub.inkas.
define buffer buf_wth-doc for ub.wth-doc.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_chk-gds-attr for ub.chk-gds-attr.
define buffer buf_wealth for ub.wealth.
define buffer buf_goods for ub.goods.
define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj.
define variable v-cpdoc-attr-code as character no-undo. /* наименование атрибута оплаты как в базе */
define variable v-cpdoc-attr-name as character no-undo. /* наименование атрибута оплаты */

v-no-hist = - 1.
if  temp-list.fvalue = "single" then
run Myenable in this-procedure.
else do:
  v-no-hist = 0.
  case  rs-list-method:
    when "chk-doc" then do:
      glog = yes.
      message
      "Один или несколько Чеков (товарных)"
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
      {&sel-obj}
      run str/chk-docs.w (
                     input parparentproc
                    ,input "b-sel,b-mark":U
                    ,INPUT (if CHK-STATUS = {&all}
                            then {&g___object}
                            else CHK-STATUS)
                            /*par-mode*/
                    ,input ?
                    ,input v-sel-obj-type
                    ,input v-sel-obj-code
                    ,input ? /*parout-code*/
                    ,input "":U /*pard-card*/
                    ,input 0 /*p-pay-desk*/
                    ,input v-start-date
                    ,input v-end-date
                    ,input 0
                    ,output v-rid-list
                    ).
      if v-rid-list <> "" and  v-rid-list <> ? then do:
        v-recs = num-entries (v-rid-list) .
        do num-rec = 0 to v-recs:
          if v-recs = 1 then do:
            num-rec = 1 .
          end.
          if num-rec > 0 then do:
            v-ref-rec = integer (entry (num-rec, v-rid-list)).
            find first buf_chk-doc where recid (buf_chk-doc) = v-ref-rec no-lock.
          end.
          if v-recs = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Чек(товарный) : &1 &2&3 &4 &5"
                           , buf_chk-doc.doc-code
                           , buf_chk-doc.obj-type
                           , buf_chk-doc.obj-code
                           , string (buf_chk-doc.chk-date)
                           , stat-line(CHK-STATUS)
                           )
            v-item     = '':U
            v-tbl-name = {&table_chk-doc}
            v-bh       = buffer buf_chk-doc:handle
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Чек : &1", stat-line(CHK-STATUS))
              v-item     = '':U
              v-tbl-name = '':U
              v-bh       = ?
              v-tot-lns = tot-lns
              .
            end.
            else do:
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1", buf_chk-doc.doc-code)
              v-item     = buf_chk-doc.doc-code
              v-tbl-name = {&table_chk-doc}
              v-bh       = buffer buf_chk-doc:handle
              v-tot-lns = tot-lns + num-rec
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 then 0 else num-rec).
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input v-tbl-name
                                              , input v-bh
                                              ).
          if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
        end. /*do num-rec*/
      end.
      else do:
        run MyEnable in this-procedure .
        return error.
      end.
    end. /*when chk-doc*/
    when "inkas" then do:
      glog = yes.
      {&CHK-STATUS-all}
      message "Все чеки одной или нескольких продаж."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
      {&sel-obj}
      v-rid-list = '':U.
      run str/salelist.w (
                     parparentproc
                   , "b-sel,b-mark"
                   , {&g___object}
                   , 0
                   , v-sel-obj-type
                   , v-sel-obj-code
                   , input-output v-rid-list).
      if v-rid-list = "" then do:
        run Myenable in this-procedure.
        return no-apply.
      end.
      if v-rid-list <> "" and  v-rid-list <> ? then do:
        v-recs = num-entries (v-rid-list) .
        do num-rec = 0 to v-recs:
          if v-recs = 1 then do:
            num-rec = 1 .
          end.
          if num-rec > 0 then do:
            v-ref-rec = integer (entry (num-rec, v-rid-list)).
            find first buf_inkas where recid (buf_inkas) = v-ref-rec no-lock.
          end.
          if v-recs = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Продажа: &1 &2&3 &4 &5"
                           , buf_inkas.inkas-code
                           , buf_inkas.obj-type
                           , buf_inkas.obj-code
                           , string (buf_inkas.doc-date)
                           , stat-line(CHK-STATUS)
                           )
            v-item     = '':U
            v-tbl-name = {&table_inkas}
            v-bh       = buffer buf_inkas:handle
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Продажа: &1", stat-line(CHK-STATUS))
              v-item     = '':U
              v-tbl-name = '':U
              v-bh       = ?
              v-tot-lns = tot-lns
              .
            end.
            else do:
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1", buf_inkas.inkas-code)
              v-item     = '':U
              v-tbl-name = {&table_inkas}
              v-bh       = buffer buf_inkas:handle
              v-tot-lns = tot-lns + num-rec
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 then 0 else num-rec).
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input v-tbl-name
                                              , input v-bh
                                              ).
          if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
        end. /*do num-rec*/
      end.
      else do:
        run MyEnable in this-procedure .
        return error.
      end.
    end. /*when inkas*/
    when "wth-doc" then do:
      glog = yes.
      {&CHK-STATUS-all}
      message
      "Чеки МЦ одного или нескольких Автодокументов МЦ."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
      {&sel-obj}
      { gbl/hostcode.i v-sel-obj-type v-sel-obj-code v-host-code }
       v-rid-list = '':U.
      run str/wth-docs.w (
                     input parparentproc
                   , input "b-sel,b-mark"
                   , input {&g___object}
                   , input v-host-code
                   , input v-sel-obj-type
                   , input v-sel-obj-code
                   , input "":U /*parcli-type*/
                   , input 0    /*parcli-code*/
                   , input {&income} /*par-type*/
                   , input '':U /*ext-doc-type*/
                   , input '':U  /*status*/
                   , input-output v-rid-list).
      if v-rid-list <> "" and  v-rid-list <> ? then do:
        v-recs = num-entries (v-rid-list) .
        do num-rec = 0 to v-recs:
          if v-recs = 1 then do:
            num-rec = 1 .
          end.
          if num-rec > 0 then do:
            v-ref-rec = integer (entry (num-rec, v-rid-list)).
            find first buf_wth-doc where recid (buf_wth-doc) = v-ref-rec no-lock.
          end.
          if v-recs = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Автодокумент МЦ: &1 &2&3 &4 &5"
                           , buf_wth-doc.doc-code
                           , buf_wth-doc.obj-type
                           , buf_wth-doc.obj-code
                           , string (buf_wth-doc.doc-date)
                           , stat-line(CHK-STATUS)
                           )
            v-item     = '':U
            v-tbl-name = {&table_wth-doc}
            v-bh       = buffer buf_wth-doc:handle
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Автодокумент МЦ: &1", stat-line(CHK-STATUS))
              v-item     = '':U
              v-tbl-name = '':U
              v-bh       = ?
              v-tot-lns = tot-lns
              .
            end.
            else do:
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1", buf_wth-doc.doc-code)
              v-item     = '':U
              v-tbl-name = {&table_wth-doc}
              v-bh       = buffer buf_wth-doc:handle
              v-tot-lns = tot-lns + num-rec
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 then 0 else num-rec).
          run create-{1}-hist in this-procedure (
                                                input {&add-def}
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input v-tbl-name
                                              , input v-bh
                                              ).
          if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
        end. /*do num-rec*/
      end.
      else do:
        run MyEnable in this-procedure .
        return error.
      end.
    end. /*when wth-doc*/
    when "d-card" then do:
      glog = yes.
      message "Чеки по одной или нескольким дисконтным картам."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
      { gbl/uobjclr.i  }
      {&sel-objm}
      run ref/discards.w (
                       input parparentproc
                      ,input "b-mark,b-sel":U
                      ,input {&all}
                      ,input p-curr-host-code
                      ,input p-curr-obj-type
                      ,input p-curr-obj-code
                      ,input '':U
                      ,input ?
                      ,output v-rid-list
                     ).
      if v-rid-list <> "" and  v-rid-list <> ? then do:
        assign
        v-recs = num-entries (v-rid-list)
        .
        { gbl/uobjcnt.i v-recs2 }
          _carta:
        do num-rec = 0 to v-recs: /*цикл по картам*/
        assign
        v-prev-type = '':U
        v-prev-code = 0
        .
        _object:
        do num-rec2 = 0 to v-recs2: /*цикл по объектам*/
          if v-recs = 1 and v-recs2 = 1 then do:
            assign
            num-rec = 1
            num-rec2 = 1
            .
          end.
          if num-rec > 0
          and num-rec2 > 0
          then do:
            v-ref-rec = integer (entry (num-rec, v-rid-list)).
            find first buf_dis-card where recid (buf_dis-card) = v-ref-rec no-lock.
            find first buf_userobjs_temp-user-obj where
                    (buf_userobjs_temp-user-obj.obj-type = v-prev-type
                 and buf_userobjs_temp-user-obj.obj-code > v-prev-code)
                or  buf_userobjs_temp-user-obj.obj-type > v-prev-type no-error .
          end.
          if v-recs = 1
          and v-recs2 = 1
          then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Дисконтная карта: &1 &2&3 &4&5 &6"
                           , buf_dis-card.d-card
                           , buf_dis-card.cli-type
                           , buf_dis-card.cli-code
                           , buf_userobjs_temp-user-obj.obj-type
                           , buf_userobjs_temp-user-obj.obj-code
                           , stat-line(CHK-STATUS)
                           )
            v-item     = buf_dis-card.d-card + {&delim-key} +
                         buf_userobjs_temp-user-obj.obj-type + {&delim-key} +
                         string(buf_userobjs_temp-user-obj.obj-code)
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0
            and num-rec2 = 0
            then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Дисконтная карта: &1", stat-line(CHK-STATUS))
              v-item     = '':U
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then NEXT _carta.
              if num-rec2 = 0 then NEXT _object .
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1 &2&3", buf_dis-card.d-card, buf_userobjs_temp-user-obj.obj-type, buf_userobjs_temp-user-obj.obj-code)
              v-item    = buf_dis-card.d-card + {&delim-key} + buf_userobjs_temp-user-obj.obj-type + {&delim-key} + string(buf_userobjs_temp-user-obj.obj-code)
              v-tot-lns = tot-lns + num-rec + num-rec2
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 and num-rec2 = 1 then 0 else (num-rec + num-rec2)).
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input '':U
                                              , input ?
                                              ).
          if num-rec = 0 and num-rec2 = 0
          or (v-recs = 1 and v-recs2 = 1 ) then v-seq  = v-temp-seq.
          assign
          v-prev-code = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-code else 0)
          v-prev-type = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-type else '')
          .
        end. /*do num-rec*/
        end. /*do num-rec*/
      end.
      else do:
        run MyEnable in this-procedure .
        return error.
      end.
    end. /*when d-card*/
    when "goods" then do:
      glog = yes.
      message
      "Чеки с определенными товарами."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
      { gbl/uobjclr.i  }
      {&sel-objm}
      { gbl/uobjcnt.i v-recs2 }
      if v-recs2 = 1 then do:
        find first userobjs_temp-user-obj no-lock.
      end.
      run ref/gds-ref.p (
                       input parparentproc
                     , input 'b-mark,b-sel'
                     , input ?
                     , input ?
                     , input (if v-recs2 = 1 then ? else {&all})
                     , input ?
                     , input ?
                     , input ?
                     , input ?
                     , input (if v-recs2 = 1 then userobjs_temp-user-obj.obj-type else p-curr-obj-type)
                     , input (if v-recs2 = 1 then userobjs_temp-user-obj.obj-code else p-curr-obj-code)
                     , input ?
                     , output v-rid-list).
      if v-rid-list <> "" and  v-rid-list <> ? then do:
        assign
        v-recs = num-entries (v-rid-list)
        .
        _tovar:
        do num-rec = 0 to v-recs: /*цикл по товарам*/
        assign
        v-prev-type = '':U
        v-prev-code = 0
        .
        _object:
        do num-rec2 = 0 to v-recs2: /*цикл по */
          if v-recs = 1 and v-recs2 = 1 then do:
            assign
            num-rec = 1
            num-rec2 = 1
            .
          end.
          if num-rec > 0
          and num-rec2 > 0
          then do:
            v-ref-rec = integer (entry (num-rec, v-rid-list)).
            find first buf_goods where recid (buf_goods) = v-ref-rec no-lock.
            find first buf_userobjs_temp-user-obj where
                    (buf_userobjs_temp-user-obj.obj-type = v-prev-type
                and  buf_userobjs_temp-user-obj.obj-code > v-prev-code)
                or  buf_userobjs_temp-user-obj.obj-type > v-prev-type no-error .
          end.
          if v-recs = 1
          and v-recs2 = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Товар: &1 &2 &3&4 &5 &6&7 &8"
                           , buf_goods.gds-code
                           , buf_goods.artic
                           , buf_goods.prod-type
                           , buf_goods.prod-code
                           , buf_goods.gds-name
                           , buf_userobjs_temp-user-obj.obj-type
                           , buf_userobjs_temp-user-obj.obj-code
                           , stat-line(CHK-STATUS)
                           )
            v-item    = string(buf_goods.gds-code) + {&delim-key} +
                         buf_userobjs_temp-user-obj.obj-type + {&delim-key} +
                         string(buf_userobjs_temp-user-obj.obj-code)
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0
            and num-rec2 = 0
            then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Товар: &1", stat-line(CHK-STATUS))
              v-item     = '':U
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then NEXT _tovar.
              if num-rec2 = 0 then  NEXT _object.
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1 &2&3", buf_goods.gds-code, buf_userobjs_temp-user-obj.obj-type, buf_userobjs_temp-user-obj.obj-code)
              v-item    = string(buf_goods.gds-code) + {&delim-key} +
                          buf_userobjs_temp-user-obj.obj-type + {&delim-key} +
                          string(buf_userobjs_temp-user-obj.obj-code)
              v-tot-lns = tot-lns + num-rec + num-rec2
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 and num-rec2 = 1 then 0 else num-rec).
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input '':U
                                              , input ?
                                              ).
          if num-rec = 0 and num-rec2 = 0
          or (v-recs = 1 and v-recs2 = 1 ) then v-seq  = v-temp-seq.
          assign
          v-prev-code = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-code else 0)
          v-prev-type = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-type else '')
          .
        end. /*do num-rec2*/
        end. /*do num-rec*/
      end.
      else do:
        run MyEnable in this-procedure .
        return error.
      end.
    end. /*when goods*/
    when "gds-list" then do:
      glog = yes.
      message "Чеки с товарами из сохраненного в файле списка товаров."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable in this-procedure.
        return no-apply.
      end.
      { gbl/uobjclr.i  }
      assign
      v-prev-type = '':U
      v-prev-code = 0
      .
      {&sel-objm}
      system-dialog get-file f-gds-name
      filters "Списки товаров *.gds" "*.gds"
      title "Выберите файл списка"
      INITIAL-DIR "."
      return-to-start-dir
      must-exist
      /* use-filename */
      update glog
      default-extension "gds".
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
      { gbl/uobjcnt.i v-recs2 }
      do num-rec = 0 to v-recs2:
        if v-recs2 = 1 then do: /*цикл по объектам*/
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
            find first buf_userobjs_temp-user-obj where
                    (buf_userobjs_temp-user-obj.obj-type = v-prev-type
                 and buf_userobjs_temp-user-obj.obj-code > v-prev-code)
                or  buf_userobjs_temp-user-obj.obj-type > v-prev-type no-error .
        end.
        if v-recs2 = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Чеки &1&2 с товарами из Файла списка товаров: &3 &4"
                                                             , buf_userobjs_temp-user-obj.obj-type
                                                             , buf_userobjs_temp-user-obj.obj-code
                                                             , f-gds-name
                                                             , stat-line(CHK-STATUS))
          v-item    = f-gds-name + {&delim-key} +
                      buf_userobjs_temp-user-obj.obj-type + {&delim-key} +
                      string(buf_userobjs_temp-user-obj.obj-code)
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Чеки с товарами из Файла списка товаров: &1 &2"
                                                              , f-gds-name
                                                              , stat-line(CHK-STATUS))
            v-item     = '':U
            v-tot-lns = tot-lns
            .
          end.
          else do:
            assign
            v-temp-seq = v-seq - 1
            v-line     = num-rec
            dsp-rs = substitute("&1&2", buf_userobjs_temp-user-obj.obj-type, buf_userobjs_temp-user-obj.obj-code)
            v-item     = f-gds-name + {&delim-key} + buf_userobjs_temp-user-obj.obj-type + {&delim-key} + string(buf_userobjs_temp-user-obj.obj-code)
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input '':U
                                            , input dsp-rs
                                            , input v-tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-item
                                            , input '':U
                                            , input ?
                                            ).
       if num-rec = 0 or v-recs2 = 1 then v-seq  = v-temp-seq.
       assign
       v-prev-code = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-code else 0)
       v-prev-type = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-type else '')
         .
      end. /*do num-rec*/
    end.
    when "cash-pay" then do:
      glog = yes.
      message "Чеки с определенными Типами кассового платежа."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
      { gbl/uobjclr.i  }
      {&sel-objm}
      { gbl/uobjcnt.i v-recs2 }
      run ref/cashpays.w ( input parparentproc
                    ,input "b-sel,b-mark":U
                    ,input {&all}
                    ,input p-curr-host-code
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,output v-rid-list).
      if v-rid-list <> "" and  v-rid-list <> ? then do:
        assign
        v-recs = num-entries (v-rid-list)
        .
        _cashpay:
        do num-rec = 0 to v-recs: /*цикл по типам кас платежей*/
        assign
        v-prev-type = '':U
        v-prev-code = 0
        .
        _object:
        do num-rec2 = 0 to v-recs2: /*цикл по объектам*/
          if v-recs = 1 and v-recs2 = 1 then do:
            assign
            num-rec = 1
            num-rec2 = 1
            .
          end.
          if num-rec > 0
          and num-rec2 > 0
          then do:
            v-ref-rec = integer (entry (num-rec, v-rid-list)).
            find first buf_cash-pay where recid (buf_cash-pay) = v-ref-rec no-lock.
            find first buf_userobjs_temp-user-obj where
                   (buf_userobjs_temp-user-obj.obj-type = v-prev-type
                and buf_userobjs_temp-user-obj.obj-code > v-prev-code)
                or  buf_userobjs_temp-user-obj.obj-type > v-prev-type no-error .

          end.
          if v-recs = 1
          and v-recs2 = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Тип кассового платежа: &1 (код валюты &3) &4&5 &6"
                           , buf_cash-pay.cdpay-code
                           , buf_cash-pay.curr-code
                           , buf_cash-pay.obj-name
                           , buf_userobjs_temp-user-obj.obj-type
                           , buf_userobjs_temp-user-obj.obj-code
                           , stat-line(CHK-STATUS)
                           )
            v-item = string(buf_cash-pay.cdpay-code) + {&delim-key} +
                     string(buf_cash-pay.curr-code) + {&delim-key} +
                    buf_userobjs_temp-user-obj.obj-type + {&delim-key} +
                    string(buf_userobjs_temp-user-obj.obj-code)
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0
            and num-rec2 = 0
            then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Тип кассового платежа: &1", stat-line(CHK-STATUS))
              v-item     = '':U
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then NEXT _cashpay.
              if num-rec2 = 0 then  NEXT _object.
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1&2 &3&4"
                                  , buf_cash-pay.cdpay-code
                                  , buf_cash-pay.curr-code
                                  , buf_userobjs_temp-user-obj.obj-type
                                  , buf_userobjs_temp-user-obj.obj-code)
              v-item = string(buf_cash-pay.cdpay-code) + {&delim-key} +
                       string(buf_cash-pay.curr-code) + {&delim-key} +
                       buf_userobjs_temp-user-obj.obj-type + {&delim-key} +
                       string(buf_userobjs_temp-user-obj.obj-code)
              v-tot-lns = tot-lns + num-rec + num-rec2
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 and num-rec2 = 1 then 0 else num-rec).
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input '':U
                                              , input ?
                                              ).
          if num-rec = 0 and num-rec2 = 0
          or (v-recs = 1 and v-recs2 = 1 ) then v-seq  = v-temp-seq.
          assign
          v-prev-code = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-code else 0)
          v-prev-type = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-type else '')
         .
        end. /*do num-rec2*/
        end. /*do num-rec*/
      end.
      else do:
        run MyEnable in this-procedure .
        return error.
      end.
    end. /*when cash-pay*/
    when "chk-oss" then do:
      glog = yes.
      message "Чеки с ОСС."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
      assign v-rid-list = "".
      { gbl/uobjclr.i  }
      {&sel-objm}
      { gbl/uobjcnt.i v-recs2 }
       run ref/oss-ref.w ( input parparentproc
                          ,input "v-sel":U
                          ,input 0
                          ,output v-rid-list).
      if v-rid-list <> "" and  v-rid-list <> ? then do:
        assign
        v-recs = num-entries (v-rid-list)
        .
        _oss:
        do num-rec = 0 to v-recs: /*цикл по типам осс*/
        assign
        v-prev-type = '':U
        v-prev-code = 0
        .
        _object:
        do num-rec2 = 0 to v-recs2: /*цикл по объектам*/
          if v-recs = 1 and v-recs2 = 1 then do:
            assign
            num-rec = 1
            num-rec2 = 1
            .
          end.
          if num-rec > 0
          and num-rec2 > 0
          then do:
            v-ref-row = entry (num-rec, v-rid-list).
            find first buf_ext-classif where rowid (buf_ext-classif) = to-rowid (v-ref-row) no-lock.
            find first buf_userobjs_temp-user-obj where
                   (buf_userobjs_temp-user-obj.obj-type = v-prev-type
                and buf_userobjs_temp-user-obj.obj-code > v-prev-code)
                or  buf_userobjs_temp-user-obj.obj-type > v-prev-type no-error .

          end.
          if v-recs = 1
          and v-recs2 = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("ОСС: &1  &3&4 &5"
                           , buf_ext-classif.CharKey_One
                           , buf_ext-classif.Key#_One
                           , buf_userobjs_temp-user-obj.obj-type
                           , buf_userobjs_temp-user-obj.obj-code
                           , stat-line(CHK-STATUS)
                           )
            v-item = string(buf_ext-classif.CharKey_One) + {&delim-key} +
                     string(buf_ext-classif.Key#_One) + {&delim-key} +
                    buf_userobjs_temp-user-obj.obj-type + {&delim-key} +
                    string(buf_userobjs_temp-user-obj.obj-code)
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0
            and num-rec2 = 0
            then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("ОСС: &1", stat-line(CHK-STATUS))
              v-item     = '':U
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then NEXT _oss.
              if num-rec2 = 0 then  NEXT _object.
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1&2 &3&4"
                                  , buf_ext-classif.CharKey_One
                                  , buf_ext-classif.Key#_One
                                  , buf_userobjs_temp-user-obj.obj-type
                                  , buf_userobjs_temp-user-obj.obj-code)
              v-item = string(buf_ext-classif.CharKey_One) + {&delim-key} +
                       string(buf_ext-classif.Key#_One) + {&delim-key} +
                       buf_userobjs_temp-user-obj.obj-type + {&delim-key} +
                       string(buf_userobjs_temp-user-obj.obj-code)
              v-tot-lns = tot-lns + num-rec + num-rec2
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 and num-rec2 = 1 then 0 else num-rec).
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-temp-seq
                                              , input v-line
/*                                              , input {&table_chk-doc}*/
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input '':U
                                              , input ?
                                              ).
          if num-rec = 0 and num-rec2 = 0
          or (v-recs = 1 and v-recs2 = 1 ) then v-seq  = v-temp-seq.
          assign
          v-prev-code = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-code else 0)
          v-prev-type = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-type else '')
         .
        end. /*do num-rec2*/
        end. /*do num-rec*/
      end.
      else do:
        run MyEnable in this-procedure .
        return error.
      end.
    end. /*when chk-oss*/
    when "wealth" then do:
      glog = yes.
      message "Чеки МЦ с определенными МЦ."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
      { gbl/uobjclr.i  }
      {&sel-objm}
      v-rid-list = '':U.
      run ref/wth-ref.w ( input parparentproc
                         ,input "b-mark,b-sel":U
                         ,input p-curr-host-code
                         ,input p-curr-obj-type
                         ,input p-curr-obj-code
                         ,input {&all}
                         ,input-output v-rid-list).
      if v-rid-list <> "" and  v-rid-list <> ? then do:
        assign
        v-recs = num-entries (v-rid-list)
        .
        { gbl/uobjcnt.i v-recs2 }
        _wth:
        do num-rec = 0 to v-recs: /*цкил по МЦ*/
        assign
        v-prev-type = '':U
        v-prev-code = 0
        .

        _object:
        do num-rec2 = 0 to v-recs2:  /*цеил по объектам*/
          if v-recs = 1 and v-recs2 = 1 then do:
            assign
            num-rec = 1
            num-rec2 = 1
            .
          end.
          if num-rec > 0
          and num-rec2 > 0
          then do:
            v-ref-rec = integer (entry (num-rec, v-rid-list)).
            find first buf_wealth where recid (buf_wealth) = v-ref-rec no-lock.
            find first buf_userobjs_temp-user-obj where
                   (buf_userobjs_temp-user-obj.obj-type = v-prev-type
                and buf_userobjs_temp-user-obj.obj-code > v-prev-code)
                or  buf_userobjs_temp-user-obj.obj-type > v-prev-type no-error .
          end.
          if v-recs = 1
          and v-recs2 = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Материальная ценность: &1 &2 &3&4 &5"
                           , buf_wealth.wth-code
                           , buf_wealth.wth-name
                           , buf_userobjs_temp-user-obj.obj-type
                           , buf_userobjs_temp-user-obj.obj-code
                           , stat-line(CHK-STATUS)
                           )
            v-item     = string(buf_wealth.wth-code) + {&delim-key} +
                         buf_userobjs_temp-user-obj.obj-type + {&delim-key} + string(buf_userobjs_temp-user-obj.obj-code)
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0
            and num-rec2 = 0
            then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Материальные ценности: &1", stat-line(CHK-STATUS))
              v-item     = '':U
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then NEXT _wth.
              if num-rec2 = 0 then  NEXT _object.
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1 &2&3", buf_wealth.wth-code, buf_userobjs_temp-user-obj.obj-type, buf_userobjs_temp-user-obj.obj-code)
              v-item = string(buf_wealth.wth-code) + {&delim-key} +
                       buf_userobjs_temp-user-obj.obj-type + {&delim-key} + string(buf_userobjs_temp-user-obj.obj-code)
              v-tot-lns = tot-lns + num-rec + num-rec2
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 and num-rec2 = 1 then 0 else num-rec).
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input '':U
                                              , input ?
                                              ).
          if num-rec = 0 and num-rec2 = 0
          or (v-recs = 1 and v-recs2 = 1 ) then v-seq  = v-temp-seq.
          assign
          v-prev-code = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-code else 0)
          v-prev-type = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-type else '')
         .
        end. /*do num-rec2*/
        end. /*do num-rec*/
      end.
      else do:
        run MyEnable in this-procedure .
        return error.
      end.
    end. /*when wealth*/
    when "gds-line-num" then do:
      glog = yes.
      message "Количество товарных строк."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
      { gbl/uobjclr.i  }
      {&sel-objm}
      assign
      v-rid-list = "0"
      .
      run gbl/d-prompt.w (
        'title=':u + "Количество товарных строк" + '\':u
      + 'format=>9' + '\':u
      + 'type=' + {&type-int} + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=20\':u
      + 'fillin_height=1\':u
      + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
      + 'readonly=no' + '\':u
      , input-output v-rid-list
      ).
      if return-value = 'false':u then do:
        run Myenable in this-procedure.
        return no-apply.
      end.
      { gbl/uobjcnt.i v-recs }
      assign
      v-prev-type = '':U
      v-prev-code = 0
      .
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, v-ref-list)).
          find first buf_userobjs_temp-user-obj where
                  (buf_userobjs_temp-user-obj.obj-type = v-prev-type
              and buf_userobjs_temp-user-obj.obj-code > v-prev-code)
              or  buf_userobjs_temp-user-obj.obj-type > v-prev-type no-error .

        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Чеки &1&2 с количеством товарных строк = &3 &4"
                                                             , buf_userobjs_temp-user-obj.obj-type
                                                             , buf_userobjs_temp-user-obj.obj-code
                                                             , v-rid-list
                                                             , stat-line(CHK-STATUS))
          v-item    = v-rid-list + {&delim-key} + buf_userobjs_temp-user-obj.obj-type +
                     {&delim-key} + string(buf_userobjs_temp-user-obj.obj-code)
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Чеки с числом товарных строк = &1 &2"
                                                              , v-rid-list
                                                              , stat-line(CHK-STATUS))
            v-item     = '':U
            v-tot-lns = tot-lns
            .
          end.
          else do:
            assign
            v-temp-seq = v-seq - 1
            v-line     = num-rec
            dsp-rs = substitute("&1&2", buf_userobjs_temp-user-obj.obj-type, buf_userobjs_temp-user-obj.obj-code)
            v-item     = v-rid-list + {&delim-key} +
                         buf_userobjs_temp-user-obj.obj-type + {&delim-key} +
                         string(buf_userobjs_temp-user-obj.obj-code)
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input '':U
                                            , input dsp-rs
                                            , input v-tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-item
                                            , input '':U
                                            , input ?
                                            ).
        if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
        assign
        v-prev-code = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-code else 0)
        v-prev-type = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-type else '')
        .
      end. /*do num-rec*/
    end. /*when gds-line-num*/
    when "chk-type" then do:
      glog = yes.
      message "Чеки (товарные) определенного типа."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
      { gbl/uobjclr.i  }
      {&sel-objm}
      assign
      v-rid-list = ""
      .
      assign
      v-chk-types = {&receipt-codes}
      v-chk-names = {&receipt-codes-full}
      .
      run gbl/d-list.w (
              INPUT "b-sel,b-mark":U
              ,INPUT "Выберите типы чеков"
              ,INPUT v-chk-types
              ,INPUT v-chk-names
              ,INPUT {&comma-char}
              ,INPUT "":U
              ,output v-rid-list).
      if v-rid-list <> "" and  v-rid-list <> ? then do:
        assign
        v-recs = num-entries (v-rid-list)
        .
        { gbl/uobjcnt.i v-recs2 }
        _receipt:
        do num-rec = 0 to v-recs: /*цкил по типам чеков*/
        assign
        v-prev-type = '':U
        v-prev-code = 0
        .

        _object:
        do num-rec2 = 0 to v-recs2: /*цеил по объектам*/
          if v-recs = 1 and v-recs2 = 1 then do:
            assign
            num-rec = 1
            num-rec2 = 1
            .
          end.
          if num-rec > 0
          and num-rec2 > 0
          then do:
&SCOP RECEipt-code entry(num-rec, v-rid-list)
            find first buf_userobjs_temp-user-obj where
                    (buf_userobjs_temp-user-obj.obj-type = v-prev-type
                and buf_userobjs_temp-user-obj.obj-code > v-prev-code)
                or  buf_userobjs_temp-user-obj.obj-type > v-prev-type no-error .

          end.
          if v-recs = 1
          and v-recs2 = 1 then do:
&SCOP RECEipt-code entry(1, v-rid-list)
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Тип чека: &1 &2&3 &4"

                           , {&receipt-name}
                           , buf_userobjs_temp-user-obj.obj-type
                           , buf_userobjs_temp-user-obj.obj-code
                           , stat-line(CHK-STATUS)
                           )
            v-item     = entry(num-rec, v-rid-list) + {&delim-key} +
                         buf_userobjs_temp-user-obj.obj-type + {&delim-key} + string(buf_userobjs_temp-user-obj.obj-code)
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0
            and num-rec2 = 0
            then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Тип чека: &1"
                                 , stat-line(CHK-STATUS))
              v-item     = '':U
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then NEXT _receipt.
              if num-rec2 = 0 then  NEXT _object.
&SCOP RECEipt-code entry(num-rec, v-rid-list)
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1 &2&3", {&receipt-name}, buf_userobjs_temp-user-obj.obj-type, buf_userobjs_temp-user-obj.obj-code)
              v-item     = entry(num-rec, v-rid-list) + {&delim-key} +
                         buf_userobjs_temp-user-obj.obj-type + {&delim-key} + string(buf_userobjs_temp-user-obj.obj-code)
              v-tot-lns = tot-lns + num-rec + num-rec2
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 and num-rec2 = 1 then 0 else num-rec).
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input '':U
                                              , input ?
                                              ).
          if num-rec = 0 and num-rec2 = 0
          or (v-recs = 1 and v-recs2 = 1 ) then v-seq  = v-temp-seq.
          assign
          v-prev-code = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-code else 0)
          v-prev-type = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-type else '')
        .
        end. /*do num-rec2*/
        end. /*do num-rec*/
      end.
      else do:
        run MyEnable in this-procedure .
        return error.
      end.
      do ii = 1 to num-entries(v-rid-list):
&SCOP RECEipt-code entry(ii, v-rid-list)
        v-chk-names = v-chk-names + (if v-chk-names = '':U then '':U else ({&comma-char} + {&space-char})) +
                      {&receipt-name}.
      end.
      dsp-rs = dsp-rs + {&space-char} + substitute("Чеки (товарные) типа: &1", v-chk-names).
    end. /*when chk-type*/
    when "wth-chk-type" then do:
      glog = yes.
      message "Чеки МЦ определенного типа."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
      { gbl/uobjclr.i  }
      {&sel-objm}
      assign
      v-rid-list = ""
      .
      assign
      v-chk-types = {&wth-receipt-codes}
      v-chk-names = {&wth-receipt-codes-full}
      .
      run gbl/d-list.w (
              INPUT "b-sel,b-mark":U
              ,INPUT "Выберите типы чеков МЦ"
              ,INPUT v-chk-types
              ,INPUT v-chk-names
              ,INPUT {&comma-char}
              ,INPUT "":U
              ,output v-rid-list).
      IF v-rid-list = "":u THEN do:
        run Myenable in this-procedure.
        return no-apply.
      end.
      if v-rid-list <> "" and  v-rid-list <> ? then do:
        { gbl/uobjcnt.i v-recs2 }
        assign
        v-recs = num-entries (v-rid-list)
        .
        _chk-type:
        do num-rec = 0 to v-recs: /*цеил по типам чеков МЦ*/
        assign
        v-prev-type = '':U
        v-prev-code = 0
        .

        _object:
        do num-rec2 = 0 to v-recs2: /*цеил по объектам*/
          if v-recs = 1 and v-recs2 = 1 then do:
            assign
            num-rec = 1
            num-rec2 = 1
            .
          end.
          if num-rec > 0
          and num-rec2 > 0
          then do:
&SCOP wth-RECEipt-code entry(num-rec, v-rid-list)
            find first buf_userobjs_temp-user-obj where
                    (buf_userobjs_temp-user-obj.obj-type = v-prev-type
                and buf_userobjs_temp-user-obj.obj-code > v-prev-code)
                or  buf_userobjs_temp-user-obj.obj-type > v-prev-type no-error .
          end.
          if v-recs = 1
          and v-recs2 = 1 then do:
&SCOP wth-RECEipt-code entry(1, v-rid-list)
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Тип чека: &1 &2&3 &4"
                           , {&wth-receipt-name}
                           , buf_userobjs_temp-user-obj.obj-type
                           , buf_userobjs_temp-user-obj.obj-code
                           , stat-line(CHK-STATUS)
                           )
            v-item     = entry(num-rec, v-rid-list) + {&delim-key} +
                         buf_userobjs_temp-user-obj.obj-type + {&delim-key} +
                         string(buf_userobjs_temp-user-obj.obj-code)
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0
            and num-rec2 = 0
            then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Тип чека: &1"
                                 , stat-line(CHK-STATUS))
              v-item     = '':U
              v-tot-lns = tot-lns
              .
            end.
            else do:
&SCOP wth-RECEipt-code entry(num-rec, v-rid-list)
              if num-rec = 0 then NEXT _chk-type.
              if num-rec2 = 0 then  NEXT _object.
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1 &2&3", {&wth-receipt-name}, buf_userobjs_temp-user-obj.obj-type, buf_userobjs_temp-user-obj.obj-code)
              v-item     = entry(num-rec, v-rid-list) + {&delim-key} +
                         buf_userobjs_temp-user-obj.obj-type + {&delim-key} + string(buf_userobjs_temp-user-obj.obj-code)
              v-tot-lns = tot-lns + num-rec + num-rec2
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 and num-rec2 = 1 then 0 else num-rec).
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input '':U
                                              , input ?
                                              ).
          if num-rec = 0 and num-rec2 = 0
          or (v-recs = 1 and v-recs2 = 1 ) then v-seq  = v-temp-seq.
          assign
          v-prev-code = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-code else 0)
          v-prev-type = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-type else '')
        .
        end. /*do num-rec2*/
        end. /*do num-rec*/
      end.
      else do:
        run MyEnable in this-procedure .
        return error.
      end.
    end. /*when wth-chk-type*/

    when "cpdoc-attr":U then do: /* Чеки с атрибутом оплаты */
        glog = yes.
        message "Чеки с атрибутом оплаты"
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
            run Myenable in this-procedure.
            return no-apply.
        end.
        { gbl/uobjclr.i}
        {&sel-objm}
        assign v-rid-list = "".
        v-cpdoc-attr-code = {&cpdoc-attr-code}.
        v-cpdoc-attr-name = {&cpdoc-attr-name}.
        
        /* прописано в /str/str-glbl.i и нужно чтобы последовательность была одинаковой code и name*/
        
        run gbl/d-list.w ( input "b-sel":U
                    ,input "Выберите атрибут"
                    ,input v-cpdoc-attr-code     /* тут - наименование аттрибута как оно хранится в базе */
                    ,input v-cpdoc-attr-name     /* тут - наименование аттрибута*/
                    ,input {&comma-char}
                    ,input "":U
                    ,output v-rid-list).
         /* здесь мы создадим запись в истории создания списка чеков */
          dsp-rs = "Чеки с атрибутом оплаты " + entry ( lookup (v-rid-list,v-cpdoc-attr-code),v-cpdoc-attr-name) + " на объектах ".

          for each buf_userobjs_temp-user-obj no-lock :
              dsp-rs = dsp-rs + buf_userobjs_temp-user-obj.obj-type + string(buf_userobjs_temp-user-obj.obj-code) + " ".
          end.
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-seq
                                              , input 0
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input '':U
                                              , input ?
                                              ).
    
    end. /* when "cpdoc-attr" */

    when "cpdoc-attr-val":U then do: /* Атрибут оплаты =*/
        glog = yes.
        message "Чеки с атрибутом оплаты ="
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
            run Myenable in this-procedure.
            return no-apply.
        end.
        { gbl/uobjclr.i}
        {&sel-objm}
        assign v-rid-list = "".
        v-cpdoc-attr-code = {&cpdoc-attr-code}.
        v-cpdoc-attr-name = {&cpdoc-attr-name}.
                        
        run gbl/d-list.w ( input "b-sel":U
                    ,input "Выберите атрибут"
                    ,input v-cpdoc-attr-code     /* тут - наименование аттрибута как оно хранится в базе */
                    ,input v-cpdoc-attr-name     /* тут - наименование аттрибута*/
                    ,input {&comma-char}
                    ,input "":U
                    ,output v-rid-list).
            
        run gbl/d-prompt.w (
        'title=':u + "Значение атрибута товара на объекте" + '\':u
      + 'text1=':u + "Значение атрибута " + entry ( lookup (v-rid-list,v-cpdoc-attr-code),v-cpdoc-attr-name) + '\':u
      + 'format=' + "" + '\':u
      + 'type=' + "CHAR" + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=20\':u
      + 'fillin_height=1\':u
      + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
      + 'readonly=no\':u
      , input-output v-cpdoc-attr-val
      ).
        /* здесь мы создадим запись в истории создания списка чеков */
          dsp-rs = "Чеки с атрибутом оплаты " + entry ( lookup (v-rid-list,v-cpdoc-attr-code),v-cpdoc-attr-name) + "=" + v-cpdoc-attr-val + " на объектах ".

          for each buf_userobjs_temp-user-obj no-lock :
              dsp-rs = dsp-rs + buf_userobjs_temp-user-obj.obj-type + string(buf_userobjs_temp-user-obj.obj-code) + " ".
          end.
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-seq
                                              , input 0
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input '':U
                                              , input ?
                                              ).
    
    end. /* when "cpdoc-attr-val" */

    when "file":U then do:
      glog = yes.
      message "Чеки из ранее сохраненного в файле списка."
      skip stat-line(CHK-STATUS)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable in this-procedure.
        return no-apply.
      end.
      system-dialog get-file f-chk-name
      filters "Списки чеков *.chk" "*.chk"
      title "Выберите файл списка"
      INITIAL-DIR "."
      return-to-start-dir
      must-exist
      /* use-filename */
      update glog
      default-extension "chk".
      if not glog then do:
        run MyEnable in this-procedure.
        return error.
      end.
      run create-{1}-hist in this-procedure(input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute("Все чеки из сохраненного в файле списка чеков &1 &2", f-chk-name, stat-line(CHK-STATUS))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input f-chk-name
                                          , input '':U
                                          , input ?
                                          ).
    end. /*when file*/
    WHEN "FILTER-chk-doc" or
    when "filter-chk-gds" or
    when "filter-chk-pay" or
    when "FILTER-chk-doc-autotank"
    THEN DO:
      { gbl/uobjclr.i  }
      assign
      v-prev-type = '':U
      v-prev-code = 0
      .
      {&sel-objm}
      { gbl/uobjcnt.i v-recs2 }
      CASE rs-list-method:
        when "filter-chk-doc" then
        do:
           run trig-filter-chk-doc  in this-procedure (input v-ref-list,input 0) no-error.
        end.
        when "filter-chk-doc-autotank" then
        do:
          run trig-filter-chk-doc  in this-procedure (input v-ref-list,input 1) no-error.
        end.

        when "filter-chk-gds" then run trig-filter-chk-gds  in this-procedure (input v-ref-list) no-error.
        when "filter-chk-pay" then run trig-filter-chk-pay  in this-procedure (input v-ref-list) no-error.
      END CASE.
      if error-status:error then do:
        run MyEnable in this-procedure.
        return error.
      end.
    END. /*WHEN ubflt.filter*/
  end case.
  if tot-lns <> 0 then do:
    run get-operation in this-procedure (input dsp-rs, output v-operation).
    CASE v-operation:
      when {&add-operation} then do:
        run proc-b-add in this-procedure(input no, input ?, input rs-list-method, input CHK-STATUS) no-error  .
      end.
      when {&del-operation} then do:
        run proc-b-del in this-procedure(input no, input ?, input rs-list-method, input CHK-STATUS ) no-error  .
      end.
      when {&rest-operation} then do:
        run proc-b-rest in this-procedure(input no, input ?, input rs-list-method, input CHK-STATUS) no-error  .
      end.
      otherwise do:
        assign
        dsp-rs = "":U.
        run Myenable in this-procedure.
        return error.
      end.
    END CASE.
  end.
  assign
  rs-list-method =  temp-list.fvalue
  .
  find last buf_{1}-hist no-lock where
            buf_{1}-hist.id = (v-seq - 1)
      and  buf_{1}-hist.line = 0 no-error .
  DISPLAY
  (if available buf_{1}-hist
  then buf_{1}-hist.des
  else '') @ dsp-rs
  with frame {&frame-name}.
  if tot-lns = 0 and v-operation = 0 then do:
    run proc-b-add in this-procedure(input no, input ?, input rs-list-method, input CHK-STATUS) .
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rs-do Dialog-Frame
PROCEDURE rs-do :
define input parameter p-from-macro as logical no-undo .
define input parameter p-step as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter CHK-STATUS as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-id      as integer no-undo .

define variable grp-path like ub.goods.grp-name no-undo.
define variable imp-ART like ub.goods.ARTIC no-undo.
define variable scan-qnty as dec no-undo.  /*ДЛЯ ИМПОРТА ИЗ СПИсКА ТОВАРА*/
define variable imp-type like ub.goods.prod-type no-undo.
define variable imp-code like ub.goods.prod-code no-undo.
define variable v-report-num as integer no-undo .
define variable glog as logical no-undo .

define variable v-rowid   as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-obj-type as character  no-undo.
define variable v-obj-code as integer    no-undo.
DEFINE VARIABLE v-attr-code          as character           no-undo .
define variable v-start-date as date no-undo .
define variable v-end-date as date no-undo .
define variable v-d-card like ub.dis-card.d-card no-undo .
define variable v-gds-code like ub.goods.gds-code no-undo .
define variable v-cdpay-code like ub.cash-pay.cdpay-code no-undo .
define variable v-oss-code like ub.chk-gds-attr.attr-code no-undo .
define VARIABLE v-oss-type like ub.chk-gds-attr.attr-value no-undo .
define variable v-curr-code like ub.cash-pay.curr-code no-undo .
define variable v-wth-code like ub.wealth.wth-code no-undo .
define variable v-line-num as integer no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-chk-type as character no-undo .
define variable imp-doc-code       as character no-undo .
define variable imp-chk-type       as character no-undo .


define buffer buf_{1}-hist for {1}-hist.
define buffer buf_inkas for ub.inkas.
define buffer buf_wth-doc for ub.wth-doc.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_chk-gds-attr for ub.chk-gds-attr.
define buffer buf_wealth for ub.wealth.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj.


do
on error undo, return error return-value
:

assign
lns-cnt = 0
lns-ignore = 0
tot-lns = (if line-mode = {&leave} then 0 else tot-lns)
.
run write-hist in this-procedure (input p-from-macro, input rs-list-method, input CHK-STATUS, input line-mode).

if session:set-wait-state( "COMPILER" )  then .
dsp-rs:fgcolor in frame {&frame-name} = 12.
case rs-list-method:
  WHEN "chk-doc" THEN DO:
    _kk:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      {&get-rowid}  next.
      find first ub.chk-doc no-lock where rowid(ub.chk-doc) = v-rowid.
      run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
      {&assign-nums}.
    end.
  END. /*"chk-DOC"*/
  WHEN "wth-DOC" THEN DO:
   for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
      and  buf_{1}-hist.item_ <> '':U:
      {&get-rowid}  next.
      find first buf_wth-doc no-lock where
                rowid(buf_wth-doc) = v-rowid no-error.
      if available buf_wth-doc then do:
        for each ub.chk-doc No-LOCK WHERE
                 ub.chk-doc.out-code = buf_wth-doc.doc-code :
          run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
        end.
      end. /* do num-rec = 1 to */
      {&assign-nums}.
    end.
  END. /*"wth-doc"*/
  WHEN "inkas" THEN DO:
   for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
      and  buf_{1}-hist.item_ <> '':U:
      {&get-rowid}  next.
      find first buf_inkas no-lock where
                rowid(buf_inkas) = v-rowid no-error.
      if available buf_inkas then do:
        for each chk-doc No-LOCK WHERE
                 chk-doc.out-code = buf_inkas.inkas-code :
          run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
        end.
      end. /* do num-rec = 1 to */
      {&assign-nums}.
    end.
  END. /*WHEN "inkas"*/
  when "d-card" then do:
   _d-card:
   for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
      and  buf_{1}-hist.item_ <> '':U:
      assign
      v-d-card   = entry(1, buf_{1}-hist.item_, {&delim-key})
      v-obj-type = entry(2, buf_{1}-hist.item_, {&delim-key})
      v-obj-code = integer(entry(3, buf_{1}-hist.item_, {&delim-key}))
      no-error
      .
      if error-status:error then  next _d-card.
      { gbl/usobjava.i
        v-cntxt-db-num
        {&action-head-code-main}
        v-cntxt-userid
        v-obj-type
        v-obj-code
        v-object-available
      }
      if v-object-available <> true then next _d-card.
      find first buf_dis-card no-lock where
                buf_dis-card.d-card = v-d-card no-error.
      if not avail buf_dis-card then next _d-card.
      CASE entry(1, buf_{1}-hist.status_, {&delim-par}):
        when {&all} then do:
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code
              and chk-doc.d-card = buf_dis-card.d-card:
            run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
          end.
        end.
        when "free":U then do:
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code
              AND chk-doc.out-code = ?
              and chk-doc.d-card = buf_dis-card.d-card:
            run ex-chk in this-procedure( input rs-list-method, input rs-status, input line-mode).
          end.
        end.
        when "chk-date":U then do:
          ASSIGN
          V-START-DATE = DATE(ENTRY(2, buf_{1}-hist.status_, {&delim-par}))
          V-END-DATE = DATE(ENTRY(3, buf_{1}-hist.status_, {&delim-par}))
          .
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code
              AND chk-doc.chk-date >= v-start-date
              AND chk-doc.chk-date <= v-end-date
              and chk-doc.d-card = buf_dis-card.d-card:
            run ex-chk in this-procedure( input rs-list-method, input rs-status, input line-mode).
          end.
        end.
      END CASE.
      {&assign-nums}.
    end.
  end.
  when "goods" then do:
   _gds:
   for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
      and  buf_{1}-hist.item_ <> '':U:
      assign
      v-gds-code   = integer(entry(1, buf_{1}-hist.item_, {&delim-key}))
      v-obj-type = entry(2, buf_{1}-hist.item_, {&delim-key})
      v-obj-code = integer(entry(3, buf_{1}-hist.item_, {&delim-key}))
      no-error
      .
      if error-status:error then  next _gds.

      { gbl/usobjava.i
        v-cntxt-db-num
        {&action-head-code-main}
        v-cntxt-userid
        v-obj-type
        v-obj-code
        v-object-available
      }
      if v-object-available <> true then next _gds.
      find first buf_goods no-lock where
                buf_goods.gds-code = v-gds-code no-error.
      if not avail buf_goods then next _gds.
      for each buf_bar-code no-lock where
              buf_bar-code.gds-code = buf_goods.gds-code,
        each buf_chk-gds no-lock where
            buf_chk-gds.b-code = buf_bar-code.b-code,
        first chk-doc No-LOCK WHERE
                chk-doc.doc-code = buf_chk-gds.doc-code
          AND  chk-doc.obj-type = v-obj-type
          AND  chk-doc.obj-code = v-obj-code:
          run ex-chk in this-procedure( input rs-list-method, input rs-status, input line-mode).
      end.
      {&assign-nums}.
    end.
  end.
  when "gds-list" then do:
    _gds-list:
    for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
        and buf_{1}-hist.item_ <> '':U:
      assign
      f-gds-name = entry(1, buf_{1}-hist.item_, {&delim-key})
      v-obj-type = entry(2, buf_{1}-hist.item_, {&delim-key})
      v-obj-code = integer(entry(3, buf_{1}-hist.item_, {&delim-key}))
      no-error
      .
      if error-status:error then  next _gds-list.

      { gbl/usobjava.i
        v-cntxt-db-num
        {&action-head-code-main}
        v-cntxt-userid
        v-obj-type
        v-obj-code
        v-object-available
      }
      if v-object-available <> true then next _gds-list.
      run gbl/filename.p
                    (input  f-gds-name /* p-search-file-name */
                    ,output v-full-path         /* p-full-path        */
                    ,output v-path              /* p-path             */
                    ,output v-file-name         /* p-file-name        */
                    ,output v-file-name-no-ext  /* p-file-name-no-ext */
                    ,output v-file-name-ext     /* p-file-name-ext    */
                    ) no-error .
      if error-status:error then do: end. else do:
      input stream sout from value (v-full-path).
      repeat while true:
        import stream sout  imp-type imp-code imp-art no-error.
        find first buf_goods no-lock where
                  buf_goods.artic = imp-art
            AND buf_goods.prod-type = imp-type
            AND buf_goods.prod-code = imp-code no-error .
        if avail buf_goods then do:
          _kk:
          for each buf_bar-code no-lock where
                buf_bar-code.gds-code = buf_goods.gds-code,
            each buf_chk-gds no-lock where
                buf_chk-gds.b-code = buf_bar-code.b-code,
            first chk-doc No-LOCK WHERE
                buf_chk-gds.doc-code = chk-doc.doc-code
            AND  chk-doc.obj-type = v-obj-type
            AND  chk-doc.obj-code = v-obj-code:
            run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
          end. /*for each buf_bar-code no-lock where*/
        end. /*if avail buf_goods then do:*/
      end. /*repeat*/
      input stream sout close.
    end.
    end. /*for each buf_{1}-hist where*/
  end. /*when */
  when "cash-pay" then do:
   _cash-pay:
   for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
      and  buf_{1}-hist.item_ <> '':U:
      assign
      v-cdpay-code   = integer(entry(1, buf_{1}-hist.item_, {&delim-key}))
      v-curr-code   = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
      v-obj-type = entry(3, buf_{1}-hist.item_, {&delim-key})
      v-obj-code = integer(entry(4, buf_{1}-hist.item_, {&delim-key}))
      no-error
      .
      if error-status:error then  next _cash-pay.
      { gbl/usobjava.i
        v-cntxt-db-num
        {&action-head-code-main}
        v-cntxt-userid
        v-obj-type
        v-obj-code
        v-object-available
      }
      if v-object-available <> true then next _cash-pay.
      find first buf_cash-pay no-lock where
                buf_cash-pay.cdpay-code = v-cdpay-code
            AND buf_cash-pay.curr-code = v-curr-code no-error.
      if not avail buf_cash-pay then next _cash-pay.
      CASE entry(1, buf_{1}-hist.STATUS_, {&delim-par}):
        when {&all} then do:
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code,
              each buf_chk-pay no-lock where
                buf_chk-pay.pay-code  = buf_cash-pay.cdpay-code
            AND buf_chk-pay.curr-code  = buf_cash-pay.curr-code
            AND chk-doc.doc-code = buf_chk-pay.doc-code:
                run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
          end.
        end.
        when "free":U then do:
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code
              and chk-doc.out-code = ?,
              each buf_chk-pay no-lock where
                buf_chk-pay.pay-code  = buf_cash-pay.cdpay-code
            AND buf_chk-pay.curr-code  = buf_cash-pay.curr-code
            AND chk-doc.doc-code = buf_chk-pay.doc-code:
                run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
          end.
        end.
        when "chk-date":U then do:
          assign
          v-start-date = date(entry(2, buf_{1}-hist.status_, {&delim-par}))
          v-end-date = date(entry(3, buf_{1}-hist.status_, {&delim-par}))
          .
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code
              AND chk-doc.chk-date >= v-start-date
              AND chk-doc.chk-date <= v-end-date,
              each buf_chk-pay no-lock where
                buf_chk-pay.pay-code  = buf_cash-pay.cdpay-code
            AND buf_chk-pay.curr-code  = buf_cash-pay.curr-code
            AND chk-doc.doc-code = buf_chk-pay.doc-code:
                run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
          end.
        end.
      END CASE.
      {&assign-nums}.
    end.
  end. /*when cash-pay*/
  when "chk-oss" then do:
   _chk-oss:
   for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
      and  buf_{1}-hist.item_ <> '':U:
      assign
      v-oss-type   = entry(1, buf_{1}-hist.item_, {&delim-key})
      v-oss-code   = entry(2, buf_{1}-hist.item_, {&delim-key})
      v-obj-type = entry(3, buf_{1}-hist.item_, {&delim-key})
      v-obj-code = integer(entry(4, buf_{1}-hist.item_, {&delim-key}))
      no-error
      .
      if error-status:error then  next _chk-oss.
      { gbl/usobjava.i
        v-cntxt-db-num
        {&action-head-code-main}
        v-cntxt-userid
        v-obj-type
        v-obj-code
        v-object-available
      }
      if v-object-available <> true then next _chk-oss.
      find first buf_chk-gds-attr no-lock where 
      buf_chk-gds-attr.attr-value = v-oss-code 
      and buf_chk-gds-attr.attr-code = "oss-code" no-error.
      if not avail buf_chk-gds-attr then next _chk-oss.
      CASE entry(1, buf_{1}-hist.STATUS_, {&delim-par}):
        when {&all} then do:
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code,
              each buf_chk-gds-attr no-lock where
                chk-doc.doc-code = buf_chk-gds-attr.doc-code and buf_chk-gds-attr.attr-value = v-oss-code and buf_chk-gds-attr.attr-code = "oss-code":
                run ex-chk in this-procedure(input rs-list-method, input rs-status, input line-mode).
          end.
        end.
        when "free":U then do:
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code
              and chk-doc.out-code = ?,
              each buf_chk-gds-attr no-lock where
                chk-doc.doc-code = buf_chk-gds-attr.doc-code and buf_chk-gds-attr.attr-value = v-oss-code and buf_chk-gds-attr.attr-code = "oss-code":
                run ex-chk in this-procedure(input rs-list-method, input rs-status, input line-mode).
          end.
        end.
        when "chk-date":U then do:
          assign
          v-start-date = date(entry(2, buf_{1}-hist.status_, {&delim-par}))
          v-end-date = date(entry(3, buf_{1}-hist.status_, {&delim-par}))
          .
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code
              AND chk-doc.chk-date >= v-start-date
              AND chk-doc.chk-date <= v-end-date,
              each buf_chk-gds-attr no-lock where
                chk-doc.doc-code = buf_chk-gds-attr.doc-code and buf_chk-gds-attr.attr-value = v-oss-code and buf_chk-gds-attr.attr-code = "oss-code":
                run ex-chk in this-procedure(input rs-list-method, input rs-status, input line-mode).
          end.
      end.
      END CASE.
      {&assign-nums}.
    end.
  end. /*when chk-oss*/
  when "wealth" then do:
   _wealth:
   for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
      and  buf_{1}-hist.item_ <> '':U:
      assign
      v-wth-code   = integer(entry(1, buf_{1}-hist.item_, {&delim-key}))
      v-obj-type = entry(2, buf_{1}-hist.item_, {&delim-key})
      v-obj-code = integer(entry(3, buf_{1}-hist.item_, {&delim-key}))
      no-error
      .
      if error-status:error then  next _wealth.
      { gbl/usobjava.i
        v-cntxt-db-num
        {&action-head-code-main}
        v-cntxt-userid
        v-obj-type
        v-obj-code
        v-object-available
      }
      if v-object-available <> true then next _wealth.
      find first buf_wealth no-lock where
                buf_wealth.wth-code = v-wth-code no-error.
      if not avail buf_wealth then next _wealth.
      CASE entry(1, buf_{1}-hist.STATUS_, {&delim-par}):
        when {&all} then do:
          for each chk-doc where
                chk-doc.obj-type = v-obj-type
            AND  chk-doc.obj-code = v-obj-code,
              each buf_chk-pay no-lock where
                  buf_chk-pay.doc-code = chk-doc.doc-code,
              first buf_cash-pay no-lock where
                  buf_cash-pay.cdpay-code = buf_chk-pay.pay-code
              AND buf_cash-pay.curr-code = buf_chk-pay.curr-code
              AND buf_cash-pay.wth-code = buf_wealth.wth-code:
            if lookup(string(chk-doc.chk-type), {&wth-receipt-codes}) = 0 then next.
            run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
          end.
        end.
        when "free":U then do:
          for each chk-doc where
                chk-doc.obj-type = v-obj-type
            AND  chk-doc.obj-code = v-obj-code
            AND chk-doc.out-code = ? ,
              each buf_chk-pay no-lock where
                  buf_chk-pay.doc-code = chk-doc.doc-code,
              first buf_cash-pay no-lock where
                  buf_cash-pay.cdpay-code = buf_chk-pay.pay-code
              AND buf_cash-pay.curr-code = buf_chk-pay.curr-code
              AND buf_cash-pay.wth-code = buf_wealth.wth-code:
            if lookup(string(chk-doc.chk-type), {&wth-receipt-codes}) = 0 then next.
            run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
          end.
        end.
        when "chk-date":u then do:
          assign
          v-start-date = date(entry(2, buf_{1}-hist.status_, {&delim-par}))
          v-end-date = date(entry(3, buf_{1}-hist.status_, {&delim-par}))
          .
          for each chk-doc where
                chk-doc.obj-type = v-obj-type
            AND  chk-doc.obj-code = v-obj-code
            AND  chk-doc.chk-date >= v-start-date
            AND  chk-doc.chk-date  <= v-end-date  ,
              each buf_chk-pay no-lock where
                  buf_chk-pay.doc-code = chk-doc.doc-code,
              first buf_cash-pay no-lock where
                  buf_cash-pay.cdpay-code = buf_chk-pay.pay-code
              AND buf_cash-pay.curr-code = buf_chk-pay.curr-code
              AND buf_cash-pay.wth-code = buf_wealth.wth-code:
            if lookup(string(chk-doc.chk-type), {&wth-receipt-codes}) = 0 then next.
            run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
          end.
        end.
      END CASE.
      {&assign-nums}.
    end. /*for each buf_*/
  end. /*wealth*/
  when "gds-line-num" then do:
   _gds-line-num:
   for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
      and  buf_{1}-hist.item_ <> '':U:
      assign
      v-line-num   = integer(entry(1, buf_{1}-hist.item_, {&delim-key}))
      v-obj-type = entry(2, buf_{1}-hist.item_, {&delim-key})
      v-obj-code = integer(entry(3, buf_{1}-hist.item_, {&delim-key}))
      no-error
      .
      if error-status:error then  next _gds-line-num.
      { gbl/usobjava.i
        v-cntxt-db-num
        {&action-head-code-main}
        v-cntxt-userid
        v-obj-type
        v-obj-code
        v-object-available
      }
      if v-object-available <> true then next _gds-line-num.
      CASE entry(1, buf_{1}-hist.STATUS_, {&delim-par}):
        when {&all} then do:
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code,
              each buf_chk-gds no-lock where
                  buf_chk-gds.doc-code = chk-doc.doc-code
          break
          by buf_chk-gds.doc-code:
            if first-of(buf_chk-gds.doc-code) then do:
              assign
              num-rec = 0
              .
            end.
            assign
            num-rec = num-rec + 1
            .
            if last-of(buf_chk-gds.doc-code) then do:
              if num-rec = v-line-num then do:
                run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
              end.
            end.
          end.
        end.
        when "free":U then do:
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code
              AND chk-doc.out-code = ?            ,
              each buf_chk-gds no-lock where
                  buf_chk-gds.doc-code = chk-doc.doc-code
          break
          by buf_chk-gds.doc-code:
            if first-of(buf_chk-gds.doc-code) then do:
              assign
              num-rec = 0
              .
            end.
            assign
            num-rec = num-rec + 1
            .
            if last-of(buf_chk-gds.doc-code) then do:
              if num-rec = v-line-num then do:
                run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
              end.
            end.
          end.
        end.
        when "chk-date":U then do:
          assign
          v-start-date = date(entry(2, buf_{1}-hist.status_, {&delim-par}))
          v-end-date = date(entry(3, buf_{1}-hist.status_, {&delim-par}))
          .
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code
              AND chk-doc.chk-date >= v-start-date
              AND chk-doc.chk-date <= v-end-date,
              each buf_chk-gds no-lock where
                  buf_chk-gds.doc-code = chk-doc.doc-code
          break
          by buf_chk-gds.doc-code:
            if first-of(buf_chk-gds.doc-code) then do:
              assign
              num-rec = 0
              .
            end.
            assign
            num-rec = num-rec + 1
            .
            if last-of(buf_chk-gds.doc-code) then do:
              if num-rec = integer(v-rid-list) then do:
                run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
              end.
            end.
          end.
        end.
      END CASE.
      {&assign-nums}.
    end.
  end.
  when "chk-type" then do:
   _chk-type:
   for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
      and  buf_{1}-hist.item_ <> '':U:
      assign
      v-chk-type = entry(1, buf_{1}-hist.item_, {&delim-key})
      v-obj-type = entry(2, buf_{1}-hist.item_, {&delim-key})
      v-obj-code = integer(entry(3, buf_{1}-hist.item_, {&delim-key}))
      no-error
      .
      if error-status:error then  next _chk-type.
      { gbl/usobjava.i
        v-cntxt-db-num
        {&action-head-code-main}
        v-cntxt-userid
        v-obj-type
        v-obj-code
        v-object-available
      }
      if v-object-available <> true then next _chk-type.
      CASE entry(1, buf_{1}-hist.STATUS_, {&delim-par}):
        when {&all} then do:
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code:
            if lookup(string(chk-doc.chk-type), v-chk-type) > 0 then do:
              run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
            end.
          end.
        end.
        when "free":U then do:
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code
              AND chk-doc.out-code = ?:
            if lookup(string(chk-doc.chk-type), v-chk-type) > 0 then do:
              run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
            end.
          end.
        end.
        when "chk-date":U then do:
          assign
          v-start-date = date(entry(2, buf_{1}-hist.status_, {&delim-par}))
          v-end-date = date(entry(3, buf_{1}-hist.status_, {&delim-par}))
          .
          for each chk-doc no-lock where
                  chk-doc.obj-type = v-obj-type
              AND chk-doc.obj-code = v-obj-code
              AND chk-doc.chk-date >= v-start-date
              AND chk-doc.chk-date <= v-end-date:
            if lookup(string(chk-doc.chk-type), v-chk-type) > 0 then do:
              run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
            end.
          end.
        end.
      END CASE.
      {&assign-nums}.
    end.
  end. /*chk-type*/
  when "cpdoc-attr":U then do: 
      
      if v-rid-list = "" then do:
            return error.
        end.

        /* здесь мы поместим в temp table чеки с выбранным атрибутом */

        else do: /* начало результирующей выборки */

        find first buf_{1}-hist where buf_{1}-hist.id = p-id.
        
        for each buf_userobjs_temp-user-obj no-lock : /* для всех выбранных объектов */
        
            for each  ub.chk-pay no-lock /* для всех чеков выбранных объектов */ 
                where ub.chk-pay.obj-type = buf_userobjs_temp-user-obj.obj-type
                and   ub.chk-pay.obj-code = buf_userobjs_temp-user-obj.obj-code :
                    
                    for each  ub.chk-pay-attr no-lock /* для всех аттрибутов выбранных чеков где attr-code = v-attr-code */
                        where ub.chk-pay-attr.doc-code  = ub.chk-pay.doc-code
                        and   ub.chk-pay-attr.attr-code = v-rid-list :
                            /* тут у нас итог всей выборки */
                            for each chk-doc no-lock where ub.chk-doc.doc-code = ub.chk-pay.doc-code : /* для всех chk-doc, которые в итоге будут */
                                run ex-chk in this-procedure ( input rs-list-method, 
                                                               input rs-status, 
                                                               input line-mode ).
                            end. /* для всех chk-doc, которые в итоге будут */
                    end. /* для всех аттрибутов выбранных чеков где attr-code = v-attr-code */
            end. /* для всех чеков выбранных объектов */
        end. /* для всех выбранных объектов */
        end. /* начало результирующей выборки */
        {&assign-nums}.
        buf_chk-list-hist.num-add  = lns-cnt.
  end. /*when "cpdoc-attr":U then do: */
  when "cpdoc-attr-val":U then do: 
      
      if v-rid-list = "" then do:
            return error.
        end.

        /* здесь мы поместим в temp table чеки с выбранным атрибутом */

        else do: /* начало результирующей выборки */

        find first buf_{1}-hist where buf_{1}-hist.id = p-id.
        
        for each buf_userobjs_temp-user-obj no-lock : /* для всех выбранных объектов */
        
            for each  ub.chk-pay no-lock /* для всех чеков выбранных объектов */ 
                where ub.chk-pay.obj-type = buf_userobjs_temp-user-obj.obj-type
                and   ub.chk-pay.obj-code = buf_userobjs_temp-user-obj.obj-code :
                    
                    for each  ub.chk-pay-attr no-lock /* для всех аттрибутов выбранных чеков где attr-code = v-attr-code и attr-code = v-cpdoc-attr-val*/
                        where ub.chk-pay-attr.doc-code   = ub.chk-pay.doc-code
                        and   ub.chk-pay-attr.attr-code  = v-rid-list
                        and   ub.chk-pay-attr.attr-value = v-cpdoc-attr-val :
                            /* тут у нас итог всей выборки */
                            for each chk-doc no-lock where ub.chk-doc.doc-code = ub.chk-pay.doc-code : /* для всех chk-doc, которые в итоге будут */
                                run ex-chk in this-procedure ( input rs-list-method, 
                                                               input rs-status, 
                                                               input line-mode ).
                            end. /* для всех chk-doc, которые в итоге будут */
                    end. /* для всех аттрибутов выбранных чеков где attr-code = v-attr-code */
            end. /* для всех чеков выбранных объектов */
        end. /* для всех выбранных объектов */
        end. /* начало результирующей выборки */
        {&assign-nums}.
        buf_chk-list-hist.num-add  = lns-cnt.
  end. /*when "cpdoc-attr-val":U then do: */
  when "file" then do:
    find first buf_{1}-hist where
              buf_{1}-hist.id = p-id
          AND buf_{1}-hist.item_ <> '':U .
    run gbl/filename.p
      (input  buf_{1}-hist.item_ /* p-search-file-name */
      ,output v-full-path         /* p-full-path        */
      ,output v-path              /* p-path             */
      ,output v-file-name         /* p-file-name        */
      ,output v-file-name-no-ext  /* p-file-name-no-ext */
      ,output v-file-name-ext     /* p-file-name-ext    */
      ) no-error .
      if error-status:error then do: end. else do:
    input stream sout from value (v-full-path).
    repeat:
      import stream sout imp-doc-code imp-chk-type no-error.
      if lookup(string(imp-chk-type), {&receipt-codes}) > 0
      or imp-chk-type = ?
      then do:
        find first chk-doc no-lock where
                  chk-doc.doc-code = imp-doc-code No-error.
        if available chk-doc then run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
      end.
    end.
    input stream sout close.
    {&assign-nums}.
    end.
  end. /*when file*/
  when "filter-chk-doc"
  or
  when "filter-chk-gds"
  or
  when "filter-chk-pay"
  or
  when "filter-chk-doc-autotank"
  then do:
    define variable v-filter-var as character no-undo .
    _filter:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U .
      if entry(1, buf_{1}-hist.status_, {&delim-par}) = "chk-date" then do:
        assign
        v-start-date = date(entry(2, buf_{1}-hist.status_, {&delim-par}))
        v-end-date = date(entry(3, buf_{1}-hist.status_, {&delim-par}))
        .
      end.
      assign
      v-obj-type = entry(1, buf_{1}-hist.item, {&delim-key})
      v-obj-code = integer(entry(2, buf_{1}-hist.item, {&delim-key}))
      no-error .
      if error-status:error then next _filter.
      run proc-write-filter-expression-var in this-procedure ( input entry(3, buf_{1}-hist.item_, {&delim-key}), output v-filter-var  ).
      { gbl/usobjava.i
        v-cntxt-db-num
        {&action-head-code-main}
        v-cntxt-userid
        v-obj-type
        v-obj-code
        v-object-available
      }
      if v-object-available <> true then next _filter.

      CASE rs-list-method:
        when "filter-chk-doc" then do:
          run gbl/chk-fill.p (
                         input 1
                        ,input rs-list-method
                        ,input "Формирование списка чеков по фильтру (без учета сортировки)"
                        ,input RS-STATUS
                        ,input v-start-date
                        ,input v-end-date
                        ,input v-obj-type
                        ,input v-obj-code
                        ,input line-mode
                        ,input {&table_chk-doc}
                        ,input v-filter-var
                        ,input (if RS-STATUS = {&all}
                              then " true "
                              else (if RS-STATUS = "free":U
                                    then " chk-doc.out-code = ? "
                                    else substitute(" chk-doc.chk-date >= &1 and chk-doc.chk-date <= &2"
                                                    , string(v-start-date, "99/99/9999")
                                                    , string(v-end-date, "99/99/9999")
                                                    )
                                  )
                              )
                        ,input-output lns-cnt
                        ,output line-rec
                        )
                        .
        end.
        when "filter-chk-gds" then do:
          run gbl/chk-fill.p (
                         input 1
                        ,input rs-list-method
                        ,input "Формирование списка чеков по фильтру товарных строк (без учета сортировки)"
                        ,input RS-STATUS
                        ,input v-start-date
                        ,input v-end-date
                        ,input v-obj-type
                        ,input v-obj-code
                        ,input line-mode
                        ,input {&table_chk-gds}
                        ,input v-filter-var
                        ,input (if RS-STATUS = {&all}
                                then " true "
                                else (if RS-STATUS = "free":U
                                      then " chk-doc.out-code = ? "
                                      else substitute(" chk-doc.chk-date >= &1 and chk-doc.chk-date <= &2"
                                                    , string(v-start-date, "99/99/9999")
                                                    , string(v-end-date, "99/99/9999")
                                                    )
                                    )
                                )
                        ,input-output lns-cnt
                        ,output line-rec
                        )
                          .
        end.
        when "filter-chk-pay" then do:
          run gbl/chk-fill.p (
                         input 1
                        ,input rs-list-method
                        ,input "Формирование списка чеков по фильтру cтрок оплат (без учета сортировки)"
                        ,input RS-STATUS
                        ,input v-start-date
                        ,input v-end-date
                        ,input v-obj-type
                        ,input v-obj-code
                        ,input line-mode
                        ,input {&table_chk-pay}
                        ,input v-filter-var
                        ,input (if RS-STATUS = {&all}
                                then " true "
                                else (if RS-STATUS = "free":U
                                      then " chk-doc.out-code = ? "
                                      else substitute(" chk-doc.chk-date >= &1 and chk-doc.chk-date <= &2"
                                                    , string(v-start-date, "99/99/9999")
                                                    , string(v-end-date, "99/99/9999")
                                                    )
                                    )
                                )
                        ,input-output lns-cnt
                        ,output line-rec
                        )
                          .
        end.
        when "filter-chk-doc-autotank" then do:
          run gbl/chk-fill.p (input 1
                        ,input rs-list-method
                        ,input "Формирование списка чеков по фильтру (без учета сортировки)"
                        ,input RS-STATUS
                        ,input v-start-date
                        ,input v-end-date
                        ,input v-obj-type
                        ,input v-obj-code
                        ,input line-mode
                        ,input {&table_chk-pay-attr}
                        ,input v-filter-var
                        ,input (if RS-STATUS = {&all}
                              then " true "
                              else (if RS-STATUS = "free":U
                                    then " chk-doc.out-code = ? "
                                    else substitute(" chk-doc.chk-date >= &1 and chk-doc.chk-date <= &2"
                                                    , string(v-start-date, "99/99/9999")
                                                    , string(v-end-date, "99/99/9999")
                                                    )
                                  )
                              )
                        ,input-output lns-cnt
                        ,output line-rec
                        )
                        .
        end.

      END CASE.
      {&assign-nums}.
    end.
  end.
END CASE.
dsp-rs:fgcolor in frame {&frame-name} = 4.
if session:set-wait-state( "" )  then .
case line-mode :
  when {&add-def} then do:
    tot-lns = tot-lns + lns-cnt.
    if not p-from-macro or p-step then
    message
    "Добавлено строк :" lns-cnt skip(0)
    string(if lns-ignore <> 0
    then ("Проигнорировано строк :" + string(lns-ignore))
    else "":U)
    .
  end.
  when {&deletion} then do:
    tot-lns = tot-lns - lns-cnt.
    if not p-from-macro or p-step then
    message
    "Удалено строк :" lns-cnt skip(0)
    string(if lns-ignore <> 0
    then ("Проигнорировано строк :" + string(lns-ignore))
    else "":U)
    .
  end.
end CASE.
if line-mode <> {&leave} then
  run Myenable in this-procedure.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE trig-filter-chk-doc Dialog-Frame
PROCEDURE trig-filter-chk-doc :
define input parameter v-ref-list as character no-undo .
define input parameter p-reg      as integer   no-undo .  /* 0-chk-doc,1-chk-doc-autotank  */
/*список объектов*/
define variable glog as logical no-undo .
define variable v-flt-rec as recid no-undo .
define variable v-filter-name as character no-undo .
define variable where-phrase as character no-undo .
define variable sort-phrase as character no-undo .
define variable where-phrase-rus as character no-undo .
define variable sort-phrase-rus as character no-undo .
glog = yes.
if p-reg = 0 then
do:
  message
   "Чеки(товарные), выбранные в соответствии с заданным фильтром (без учета сортировки)."
   skip stat-line(CHK-STATUS)
   view-as alert-box question buttons OK-Cancel update glog.

end.
else
do:
  message
   "Чеки(автотанк) в которых есть разн.по запр.за нал, выбранные в соответствии с заданным фильтром (без учета сортировки)."
   skip stat-line(CHK-STATUS)
   view-as alert-box question buttons OK-Cancel update glog.

end.

if not glog then do:
  return error.
end.

if p-reg = 0 then
do:
 assign
   c-point = "chk-list_chk-doc":U + {&delim-par} + "Список чеков" + {&delim-par} + "no"
   .
 assign
  tbl = {&table_chk-doc}
  join-tbl = "":U
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .

end.
else
do:
 assign
   c-point = "chk-list_chk-doc-autotank":U + {&delim-par} + "Список чеков" + {&delim-par} + "no"
   .
 assign
 c-point = "chk-list_chk-doc":U + {&delim-par} + "Список чеков" + {&delim-par} + "no"
 .
 assign
  tbl = {&table_chk-doc}
  join-tbl = "":U
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
end .

run fltfield-add in this-procedure('doc-code', 'Номер в базе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-time', '', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-type', 'Тип чека', 'receipt-code',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('office', 'Т или у', 'gds-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-date', 'Смена от', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', 'Порядок смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-num', 'Номер по кассе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-desk', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cashier', '', 'Код кассира',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sales-man', '', 'Код продавца',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cashier-psn-code', 'Кассир-код в справочнике клиентов', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('salesman-psn-code', 'Продавец-код в справочнике клиентов', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-doc', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sub-discnt', 'Списания', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('netto', 'Нетто сумма (выручка)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('out-code', 'Номер продажи', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('d-card', 'N дис.карты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('z-number', 'N Z-отчета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-num', 'N док-та', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-num2', 'N заказа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run gbl/filter.w ( input parparentproc
                  ,input c-point
                  ,input tbl
                  ,input join-tbl
                  ,input fld
                  ,input lab
                  ,input spr
                  ,input dim).
run gbl/flt-get.p (
                 input  c-point
                ,output v-flt-rec
                ,output v-filter-name
                ,output where-phrase
                ,output sort-phrase
                ,output where-phrase-rus
                ,output sort-phrase-rus  ).
if v-flt-rec = ? then do:
  run MyEnable in this-procedure .
  return error.
end.
else do:
  find ubflt.filter where recid (ubflt.filter) = v-flt-rec no-lock.
  run trig-filter-create  in this-procedure (
                                               input "Фильтр чеков"
                                              ,input ubflt.filter.NAiM
                                              ,input ubflt.filter.where-ysl
                                              ,input ubflt.filter.where-ysl-rus
                                                ).
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE trig-filter-chk-gds Dialog-Frame
PROCEDURE trig-filter-chk-gds :
define input parameter v-ref-list as character no-undo .
define variable glog as logical no-undo .
define variable v-flt-rec as recid no-undo .
define variable v-filter-name as character no-undo .
define variable where-phrase as character no-undo .
define variable sort-phrase as character no-undo .
define variable where-phrase-rus as character no-undo .
define variable sort-phrase-rus as character no-undo .

glog = yes.
message
"Чеки(товарные) cо строками товара, выбранными в соответствии с заданным фильтром."
skip stat-line(CHK-STATUS)
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
assign
c-point = "chk-list_chk-gds"  + {&delim-par} + "Список товарных строк" + {&delim-par} + "no"
.
assign
  tbl = 'chk-gds'
  join-tbl = "":U
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .

run fltfield-add in this-procedure('b-code', 'Бар-код в БД', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-date', 'Дата', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('depart-type{&delim-flt}depart-code', 'Подразделение(кухня) в БД', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('depart-id', 'ID подразделения', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt', 'Скидка в БД', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-qnty', 'Количество в БД', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-error', 'Ош?', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('line-num', 'Номер строки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('line-sign', 'Знак строки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('line-type', 'Тип (т или у)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pass-gds', 'Ввод кода (вручную=1 авто=0)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('price-base', 'Цена', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('(pump modulo 1000)', 'Номер ТРК', 'function_integer',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sales-man', '№ продавца на кассе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('salesman-psn-code', 'Код продавца в БД', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('src-code', 'Исходный бар-код', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('src-discnt', 'Скидка в чеке', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('src-price', 'Цена чека', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('src-qnty', 'Количество в чеке', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('src-sum', 'Сумма строки в чеке', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sum-base', 'Сумма строки в БД', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('time-oper', 'Время', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('write-off-code', 'Код списания', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run gbl/filter.w ( input parparentproc
                  ,input c-point
                  ,input tbl
                  ,input join-tbl
                  ,input fld
                  ,input lab
                  ,input spr
                  ,input dim).
run gbl/flt-get.p (
                input  c-point
                ,output v-flt-rec
                ,output v-filter-name
                ,output where-phrase
                ,output sort-phrase
                ,output where-phrase-rus
                ,output sort-phrase-rus  ).
if v-flt-rec = ? then do:
  run MyEnable in this-procedure .
  return error.
end.
else do:
  find ubflt.filter where recid (ubflt.filter) = v-flt-rec no-lock.
  run trig-filter-create  in this-procedure (
                                               input "Фильтр товарных строк"
                                              ,input ubflt.filter.NAiM
                                              ,input ubflt.filter.where-ysl
                                              ,input ubflt.filter.where-ysl-rus
                                                ).

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE trig-filter-chk-pay Dialog-Frame
PROCEDURE trig-filter-chk-pay :
define input parameter v-ref-list as character no-undo .
define variable glog as logical no-undo .
define variable v-flt-rec as recid no-undo .
define variable v-filter-name as character no-undo .
define variable where-phrase as character no-undo .
define variable sort-phrase as character no-undo .
define variable where-phrase-rus as character no-undo .
define variable sort-phrase-rus as character no-undo .

glog = yes.
message
"Чеки(товарные) cо строками оплат, выбранными в соответствии с заданным фильтром."
skip stat-line(CHK-STATUS)
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
assign
c-point = "chk-list_chk-pay"  + {&delim-par} + "Список строк оплат" + {&delim-par} + "no"
.
assign
tbl = 'chk-pay'
join-tbl = "":U
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('curr-code', 'Код валюты оплаты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-code', 'Тип касс.платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-card', '№ платежной карты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-rubl', 'Сумма оплаты в нац.вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-base', 'Сумма оплаты в б.в.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-sum', 'Сумма оплаты в вал. платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run gbl/filter.w ( input parparentproc
                 ,input c-point
                 ,input tbl
                 ,input join-tbl
                 ,input fld
                 ,input lab
                 ,input spr
                 ,input dim).
run gbl/flt-get.p (
                input  c-point
                ,output v-flt-rec
                ,output v-filter-name
                ,output where-phrase
                ,output sort-phrase
                ,output where-phrase-rus
                ,output sort-phrase-rus  ).
if v-flt-rec = ? then do:
  run MyEnable in this-procedure .
  return error.
end.
else do:
  find ubflt.filter where recid (ubflt.filter) = v-flt-rec no-lock.
  run trig-filter-create  in this-procedure (
                                               input "Фильтр строк оплат"
                                              ,input ubflt.filter.NAiM
                                              ,input ubflt.filter.where-ysl
                                              ,input ubflt.filter.where-ysl-rus
                                                ).

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-hist Dialog-Frame   &ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE trig-filter-create Dialog-Frame
PROCEDURE trig-filter-create :
define input parameter p-title as character no-undo .
define input parameter p-naim as character no-undo .
define input parameter p-where-ysl as character no-undo .
define input parameter p-where-ysl-rus as character no-undo .

define variable num-rec as integer no-undo .
define variable v-recs as integer no-undo .
define variable v-temp-seq as integer no-undo .
define variable v-line as integer no-undo .
define variable v-item as character no-undo .
define variable v-tbl-name as character no-undo .
define variable v-tot-lns as integer no-undo .
define variable v-bh as handle no-undo  .
define variable v-prev-type as character no-undo .
define variable v-prev-code as integer no-undo .
define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj.

  { gbl/uobjcnt.i v-recs }
    assign
    v-prev-type = '':U
    v-prev-code = 0
    .
  _do:
  do num-rec = 0 to v-recs:
    if v-recs = 0 then do:
      num-rec = 1 .
    end.
    if num-rec > 0
    or v-recs =  1
    then do:
      find first buf_userobjs_temp-user-obj where
              (buf_userobjs_temp-user-obj.obj-type = v-prev-type
          and buf_userobjs_temp-user-obj.obj-code > v-prev-code)
          or  buf_userobjs_temp-user-obj.obj-type > v-prev-type no-error .
      if not available buf_userobjs_temp-user-obj then next _do.
    end.
    if v-recs = 1 then do:
      assign
      v-temp-seq = v-seq
      v-line     = 0
      dsp-rs = substitute("&1: &2 &4 &5&6 &6", p-title, p-naim, p-where-ysl-rus, buf_userobjs_temp-user-obj.obj-type, buf_userobjs_temp-user-obj.obj-code, stat-line(CHK-STATUS))
      v-item     =  buf_userobjs_temp-user-obj.obj-type + {&delim-key} +
                    string(buf_userobjs_temp-user-obj.obj-code ) + {&delim-key} +
                    ubflt.filter.where-ysl
      v-tbl-name = {&table_chk-doc}
      v-bh       = ?
      v-tot-lns = tot-lns
      .
    end.
    else do:
      if num-rec = 0 then do:
        assign
        v-temp-seq = v-seq
        v-line     = 0
        dsp-rs = substitute("&1: &2 &3 &4", p-title, p-naim, p-where-ysl-rus, stat-line(CHK-STATUS))
        v-item     = '':U
        v-tbl-name = '':U
        v-bh       = ?
        v-tot-lns = tot-lns
        .
      end.
      else do:
        assign
        v-temp-seq = v-seq - 1
        v-line     = num-rec
        dsp-rs = substitute("&1&2", buf_userobjs_temp-user-obj.obj-type , buf_userobjs_temp-user-obj.obj-code )
        v-item     =  buf_userobjs_temp-user-obj.obj-type  + {&delim-key} +
                      string(buf_userobjs_temp-user-obj.obj-code ) + {&delim-key} +
                      p-where-ysl
         v-tbl-name = {&table_chk-doc}
         v-bh       = ?
         v-tot-lns  = tot-lns + num-rec
        .
      end.
    end.
    v-no-hist = (if num-rec = 1 then 0 else num-rec).
    run create-{1}-hist in this-procedure(input {&add-def}
                                        , input-output v-temp-seq
                                        , input v-line
                                        , input '':U
                                        , input dsp-rs
                                        , input v-tot-lns
                                        , input rs-list-method
                                        , input rs-status
                                        , input v-item
                                        , input '':U
                                        , input v-bh
                                        ).
    if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
    if available buf_userobjs_temp-user-obj then
    assign
    v-prev-code = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-code else 0)
    v-prev-type = (if available buf_userobjs_temp-user-obj then buf_userobjs_temp-user-obj.obj-type else '')
    .
  end. /*do num-rec = 0 to v-recs:*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



PROCEDURE write-hist :
/* запись истории формирования списка */
define input parameter p-from-macro as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter CHK-STATUS as character no-undo .
define input parameter line-mode as character no-undo .
define variable v-ii as integer no-undo .
define variable v-temp-seq as integer no-undo .
if rs-list-method = "single" then do:
  if v-no-hist < 0 then do:
    run create-{1}-hist in this-procedure(input {&add-def}
                                        , input-output v-seq
                                        , input 0
                                        , input get-hist-mode(line-mode)
                                        , input substitute("Чек &1 от &2 &3&4"
                                                          , {1}.doc-code
                                                          , string({1}.chk-date), {1}.obj-type, {1}.obj-code)
                                        , input tot-lns
                                        , input rs-list-method
                                        , input rs-status
                                        , input ({&table_chk-doc} + {&delim-key} + {1}.doc-code)
                                        , input '':U
                                        , input ?
                                        ).
  end.
  else do:
    v-temp-seq = v-seq - 1.
    do v-ii = 0 to v-no-hist:
      run create-{1}-hist in this-procedure(input ({&update} + {&delim-par} + 'mode':U)
                                          , input-output v-temp-seq
                                          , input v-ii
                                          , input get-hist-mode(line-mode)
                                          , input substitute("Чек &1 от &2 &3&4"
                                                            , {1}.doc-code
                                                            , string({1}.chk-date), {1}.obj-type, {1}.obj-code)
                                          , input tot-lns
                                          , input '':U
                                          , input '':U
                                          , input ({&table_chk-doc} + {&delim-key} + {1}.doc-code)
                                          , input '':U
                                          , input ?
                                          ).
    end.
  end.
end.
else do:
  v-temp-seq = v-seq - 1.
  do v-ii = 0 to v-no-hist:
    run create-{1}-hist in this-procedure(input ({&update} + {&delim-par} + 'mode':U)
                                        , input-output  v-temp-seq
                                        , input v-ii
                                        , input get-hist-mode(line-mode)
                                        , input '':U
                                        , input tot-lns
                                        , input rs-list-method
                                        , input '':U
                                        , input '':U
                                        , input '':U
                                        , input ?
                                        ).
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-chk-type Dialog-Frame
FUNCTION get-chk-type RETURNS CHARACTER
  ( LOC-DOC-CODE AS CHARACTER, loc-chk-type as integer, loc-is-wth as logical ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define variable v-str as character no-undo.
CASE loc-is-wth:
    when yes then do:
&scop wth-receipt-code string(loc-chk-type)
    assign
    v-str = {&wth-receipt-name}
    no-error
    .
    end.
    when no then do:
&scop receipt-code string(loc-chk-type)
      if loc-chk-type = ?
      or loc-chk-type = 0
      then do:
        find first buf_chk-doc no-lock where
                  buf_chk-doc.doc-code = loc-doc-code no-error .
        if available buf_chk-doc then do:
          assign
          loc-chk-type = integer(if buf_chk-doc.netto >= 0
                  then {&rcpt-sale}
                  else {&rcpt-return})
          .
        end.
      end.
      assign
      v-str = {&receipt-name}
      no-error
      .
    end.
END CASE.
  RETURN v-str.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION stat-line Dialog-Frame
FUNCTION stat-line RETURNS CHARACTER(input p-status-chr as character):
/*функция возвращает строку для message и для dsp-rs*/
DEFINE VARIABLE var-stat-line as character no-undo .

CASE p-status-chr:
  when {&all} then do:
    assign
    var-stat-line = "(все чеки)"
    .
  end.
  when "free":U then do:
    assign
    var-stat-line = "(неучтенные чеки)"
    .
  end.
  when "chk-date":U then do:
    assign
    var-stat-line = substitute("(чеки с датой с &1 по &2)", v-start-date, v-end-date)
    .
  end.
END CASE.
return var-stat-line .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME 

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-chk-doc Dialog-Frame
PROCEDURE reposition-chk-doc :
define input  parameter p-direction   as character no-undo .
define output parameter p-chk-doc-recid as recid no-undo .

  /* перемещение на первую, последнюю, предыдущую, следующую */
  case p-direction :
    when "first":U
    then do:
      get first BR-list.
    end.
    when "last":U
    then do:
      get last BR-list.
    end.
    when "prev":U
    then do:
      get prev BR-list.
      if not available {1} then do:
        message
        "Это первый чек списка"
        view-as alert-box.
      end.
    end.
    when "next":U
    then do:
      get next BR-list.
      if not available {1} then do:
        message
        "Это последний чек списка"
        view-as alert-box.
      end.
    end.
  end case . /* p-direction */
  find first buf_chk-doc no-lock where buf_chk-doc.doc-code = {1}.doc-code no-error.
  if available buf_chk-doc then do :
    assign
      p-chk-doc-recid = recid(buf_chk-doc)
    .
  end.
  run reposition-query in this-procedure
    (input    recid({1})
    ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-query Dialog-Frame
PROCEDURE reposition-query :
define input parameter p-recid as recid no-undo .

  if p-recid <> ?
  then do:
    reposition BR-list to recid p-recid no-error.
  end.

  do with frame Dialog-Frame:
    apply "entry":u to browse BR-list .
    apply "VALUE-CHANGED":u to browse BR-list .
  end. /* do with frame */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME