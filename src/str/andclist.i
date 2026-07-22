&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
/* DEFINE SHARED TEMP-TABLE dc-list NO-UNDO LIKE ub.dis-card */
/*      field to-del as logical                              */
/*      field order-num as integer                           */
/*      field fdec as decimal                                */
/*      field fint as integer                                */
/*      field flog as logical                                */
/*      field fchar as character                             */
/*      index pi  is primary unique d-card                   */
/*      index cn      card-num                               */
/*      index cli cli-type cli-code                          */
/*      index host-dscnt  emitent-host-code status_ d-pcnt   */
/*      index host-type  emitent-host-code type d-pcnt       */
/*      index oi order-num..                                 */
/*DEFINE SHARED TEMP-TABLE temp-list NO-UNDO LIKE ub.units   */
/*      field fname as character format "X(30)"              */
/*      field fvalue as character                            */
/*      field id as integer                                  */
/*      index pi is primary unique                           */
/*      id.                                                  */



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame

/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автоматизированное формирование списка дисконтных карт

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/24/01
Author: Bakhtadze Natalya
Creation date: 09/24/01

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
define variable vss-description as character no-undo init "Автоматизированное формирование списка дисконтных карт".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/dc-list.i {1} def shared }
{ gbl/getcntxt.i def }
define variable g#report-num as integer no-undo .
{ str/listhprc.i {1}  }
{ gbl/flt-def.i  }
{ cmp/operlist.i }
{ gbl/clntattr.i }
{ gbl/fltfield.i }
{ gbl/prn-lib.i  }
{ cmp/r-pril.i new }
{ cmp/r-page1.i  new }
{ cmp/getdpcnt.i {1} }
{ ref/cgrplbfn.i }
{ gbl/cur-time.i }
{ gbl/userobjs.i }
{ gbl/dct-algo.i }
{ gbl/waitfram.i }
{ ref/discprop.i }
{ gbl/key-rec.i }

define buffer l-{1} for {1}.
define variable old-mode as character no-undo .
define variable f-name as char init "default.dc" no-undo.
define variable grp-list as char no-undo.
define variable ref-list as char no-undo.
define variable num-rec as integer init 0 no-undo.
define variable tot-lns as integer init ? no-undo.
define stream sout.
define variable CLI-REC AS RECID NO-UNDO.
DEFine variable RS-list-method AS CHARACTER.
define variable lns-cnt as integer no-undo .
define variable lns-ignore as integer no-undo .
define variable v-num-add          as integer no-undo .
define variable v-num-ignored      as integer no-undo .
define variable v-seq as integer no-undo .
define variable v-no-hist as integer no-undo init -1.
define variable vtype1 as character no-undo.
define variable vvalue as character no-undo.
define variable vvalue1 as character no-undo.
define variable save-option as character no-undo.
define variable print-option as character no-undo.
define variable obj-d-pcnt like ub.dis-card.d-pcnt no-undo.
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable cli-name as char no-undo.
define variable line-mode as character no-undo .
define variable line-rec as recid no-undo .
define variable v-user-select as logical no-undo .
define variable v-sel-obj-type like ub.clients.obj-type no-undo .
define variable v-sel-obj-code like ub.clients.obj-code no-undo .
define variable macro-play-option as character no-undo .
define variable v-docs-all as logical no-undo .
define variable v-docs-cmp as logical no-undo .


define stream slog .

&scop  disp-hot-fields   display tot-lns @ f-tot-lns with frame ~{&frame-name~}.

&if "{1}" <> "dc-list" &then
&message andclist.i можно вызывать только для таблицы dc-list
&endif



&scop add-operation 1
&scop del-operation 2
&scop rest-operation 3
&scop cancel-operation 4

define temp-table temp-list no-undo
field fname as character format "X(40)"
field fvalue as character
field id as integer
index pi is primary unique
id
index ifvalue fvalue
.

{ cmp/listhist.i macro-list "new shared" }

&scop all-options                                     ~
"Текущая строка,single,                               ~
Карта,card,                                           ~
Клиент,cli,                                           ~
Группа клиентов,cli-grp,                              ~
Глобальные карты,global,                              ~
Карты фирмы,company,                                  ~
Карты определенного типа,type,                        ~
Все физ.&лица,person,                                 ~
Контрагенты по док-там,waybill,                       ~
С установл. &атр. кл-та,attr,                         ~
С атрибутом кл-та= ,attr-val,                         ~
Значения общих итогов,general-sum-id,                 ~
Значения частных итогов,partial-sum-id,               ~
Дата посл.изм.общих итогов,last-change-general-sum-id,~
Дата посл.изм.частных итогов,last-change-partial-sum-id,~
Карты со свойством,dcp,                               ~
Карты стоплиста,stop-list,                            ~
Удаленные,deleted,                                    ~
Карты по продаже,inkas,                               ~
Карты по чеку,chk-doc,                                ~
Карты кл-тов из списка,cli-list,                      ~
Карты док-тов из списка,doc-list,                     ~
Карты чеков из списка,chk-list,                       ~
Файл,file,                                            ~
Хранимый в БД список,clob-data,                         ~
Фильтр,filter,                                        ~
Все карты, all"

&glob no-browser-option '':U
&scop sel-obj ~
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
    run MyEnable in this-procedure . ~
    return no-apply. ~
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-list

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES {1} temp-list

/* Definitions for BROWSE BR-list                                       */
&Scoped-define FIELDS-IN-QUERY-BR-list {1}.d-card {1}.issue-code ~
{1}.issue-date ~
get-d-pcnt(buffer {1}, input p-curr-host-code, input p-curr-obj-type, input p-curr-obj-code, input {&ddctr-def-pcnt}, output obj-d-pcnt) ~
{1}.status_ {1}.emitent-host-code {1}.sourced-card obj-d-pcnt ~
{1}.valid-date {1}.type {1}.credit-card {1}.lim-kr ~
(cli-name) ~
({1}.cli-type + STRING ({1}.cli-code)) ~
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-list
&Scoped-define FIELD-PAIRS-IN-QUERY-BR-list
&Scoped-define QUERY-STRING-BR-list FOR EACH {1} ~
      WHERE {1}.emitent-host-code = p-curr-host-code NO-LOCK ~
    BY {1}.d-card INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-list OPEN QUERY BR-list FOR EACH {1} ~
      WHERE {1}.emitent-host-code = p-curr-host-code NO-LOCK ~
    BY {1}.d-card INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-list {1}
&Scoped-define FIRST-TABLE-IN-QUERY-BR-list {1}


/* Definitions for BROWSE BR-option                                    */
&Scoped-define FIELDS-IN-QUERY-BR-option temp-list.fname
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-option
&Scoped-define SELF-NAME BR-option
&Scoped-define QUERY-STRING-BR-option for each temp-list no-lock
&Scoped-define OPEN-QUERY-BR-option open query br-option for each temp-list no-lock .
&Scoped-define TABLES-IN-QUERY-BR-option temp-list
&Scoped-define FIRST-TABLE-IN-QUERY-BR-option temp-list

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-list} ~
    ~{&OPEN-QUERY-BR-option}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS dsp-rs BR-option B-exit B-save B-print ~
B-hist B-lkp B-clr B-Help B-add B-del B-rest B-macro B-stop B-clear-macro ~
B-record NameOrCode n-c RS-Status BR-list ed-notes f-tot-lns
&Scoped-Define DISPLAYED-OBJECTS dsp-rs NameOrCode n-c RS-Status ed-notes ~
f-tot-lns

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-num-chk Dialog-Frame
FUNCTION get-num-chk RETURNS CHARACTER
  ( buffer loc-dis-card for {1} )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD stat-line Dialog-Frame
FUNCTION stat-line RETURNS CHARACTER
  ( input p-status-chr AS character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-print
       MENU-ITEM m_main-print   LABEL "Простой формат"
       MENU-ITEM m_sel-print    LABEL "Выбор   полей" .

DEFINE MENU MENU-B-save
       MENU-ITEM m_dc-save      LABEL "Файл списка дисконтных карт"
       MENU-ITEM m_xls-save     LABEL "Таблица EXCEL"
       MENU-ITEM m_to-make      LABEL "Файл для изготовления"
       MENU-ITEM m-title-save   LABEL "Имя списка"
       MENU-ITEM m-macros-save  LABEL "Макрос формирования списка"
       MENU-ITEM m_dc-save-db   LABEL "Хранимый в БД список дисконтных карт"
       MENU-ITEM m-macros-save-db   LABEL "Хранимый в БД макрос формирования списка"
       .

DEFINE MENU m-play
      MENU-ITEM m-macro-file    LABEL "Сохраненный в файле макрос формирования списка карт"
      MENU-ITEM m-macro-lob     LABEL "Сохраненный в БД макрос формирования списка карт"
      .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&+Доб. строку"
     SIZE 20 BY 1 TOOLTIP "Добавление в список карт 1 строку".

DEFINE BUTTON B-clear-macro
     IMAGE-UP FILE "cmp/fstop.bmp":U
     IMAGE-DOWN FILE "cmp/fstopi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/fstopi.bmp":U
     LABEL "&[ ]"
     SIZE 4 BY 1.25 TOOLTIP "Удаление макроса формирования истории из памяти".

DEFINE BUTTON B-clr
     LABEL "Очи&стить"
     SIZE 10 BY 1 TOOLTIP "Удалить из списка все карты (строки)".

DEFINE BUTTON B-del
     LABEL "&-Удал. строку"
     SIZE 20 BY 1 TOOLTIP "Удаление из списка карт текущую строку".

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1 TOOLTIP "Выход из списка карт (передача списка другой программе)"
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1 TOOLTIP "Последовательность шагов, приведшая к заполнению данного списка".

DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр описания текущей карты".

DEFINE BUTTON B-macro
     IMAGE-UP FILE "cmp/run.bmp":U
     IMAGE-DOWN FILE "cmp/runi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/runi.bmp":U
     LABEL "&>"
     SIZE 4 BY 1.25 TOOLTIP "Выполнение макроса формирования истории".

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.

DEFINE BUTTON B-record
     IMAGE-UP FILE "cmp/record.bmp":U
     IMAGE-DOWN FILE "cmp/recordi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/recordi.bmp":U
     LABEL "&o"
     SIZE 4 BY 1.25 TOOLTIP "Запись макроса формирования истории".

DEFINE BUTTON B-rest
     LABEL "&*Остав. строку"
     SIZE 20 BY 1 TOOLTIP "Оставить в списке только текущую строку".

DEFINE BUTTON B-save
     LABEL "Со&хранить"
     SIZE 10 BY 1 TOOLTIP "Сохранить список карт в текстовом файле, EXCEL".

DEFINE BUTTON B-stop
     IMAGE-UP FILE "cmp/stop.bmp":U
     IMAGE-DOWN FILE "cmp/stopi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/stopi.bmp":U
     LABEL "&[ ]"
     SIZE 4 BY 1.25 TOOLTIP "Конец записи макроса формирования истории".

DEFINE VARIABLE ed-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 75.63 BY 1.54 NO-UNDO.

DEFINE VARIABLE dsp-rs AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 75.5 BY 1 TOOLTIP "Строка текущего состояния списка"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-tot-lns AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 10 BY .71 TOOLTIP "Кол. строк"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE NameOrCode AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 40.13 BY 1 NO-UNDO.

DEFINE VARIABLE n-c AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Карта", "1",
"Клиент", "2"
     SIZE 23 BY .79 NO-UNDO.

DEFINE VARIABLE RS-Status AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3",
"Item 4", "4"
     SIZE 48 BY .75 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-list FOR
      {1} SCROLLING.

DEFINE QUERY br-option FOR
      temp-list SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-list Dialog-Frame _STRUCTURED
  QUERY BR-list NO-LOCK DISPLAY
      {1}.d-card COLUMN-LABEL "Номер" FORMAT "X(19)":U
      {1}.issue-code COLUMN-LABEL "Маг-н" FORMAT "99999":U
      {1}.issue-date COLUMN-LABEL "Выдано" FORMAT "99/99/9999":U
      get-d-pcnt(buffer {1}, input p-curr-host-code, input p-curr-obj-type, input p-curr-obj-code, input {&ddctr-def-pcnt}, output obj-d-pcnt) COLUMN-LABEL "Скидка" FORMAT "X(12)":U
      {1}.status_ FORMAT "X(4)":U
      {1}.emitent-host-code COLUMN-LABEL "Фирма" FORMAT "99999":U
      {1}.sourced-card COLUMN-LABEL "К карте" FORMAT "X(16)":U
      obj-d-pcnt COLUMN-LABEL "Скидка на!объекте" FORMAT "->9.99%":U
      {1}.valid-date COLUMN-LABEL "Действ.по" FORMAT "99/99/9999":U
      {1}.type COLUMN-LABEL "Тип" FORMAT "X(8)":U
      {1}.credit-card FORMAT "+/":U
      {1}.lim-kr FORMAT ">>>,>>>,>>>,>>9.99":U
      (cli-name) COLUMN-LABEL "Название/ФИО" FORMAT "x(29)":U
      ({1}.cli-type + STRING ({1}.cli-code)) COLUMN-LABEL "Клиент" FORMAT "X(10)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 76.5 BY 15.13.

DEFINE BROWSE BR-option
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-option Dialog-Frame _FREEFORM
  QUERY BR-option DISPLAY
      temp-list.fname format "X(40)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-LABELS NO-ROW-MARKERS SEPARATORS SIZE 30 BY 21.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     dsp-rs AT ROW 1 COL 1 NO-LABEL
     BR-option AT ROW 2 COL 79
     B-exit AT ROW 2 COL 1
     B-save AT ROW 2 COL 11
     B-print AT ROW 2 COL 21
     B-hist AT ROW 2 COL 31
     B-lkp AT ROW 2 COL 41
     B-clr AT ROW 2 COL 51
     B-Help AT ROW 1 COL 61
     B-add AT ROW 3 COL 11
     B-del AT ROW 3 COL 31
     B-rest AT ROW 3 COL 51
     B-macro AT ROW 3 COL 71
     B-stop AT ROW 3 COL 75
     B-clear-macro AT ROW 3 COL 75
     B-record AT ROW 3 COL 75
     NameOrCode AT ROW 4.04 COL 34 COLON-ALIGNED NO-LABEL
     n-c AT ROW 4.08 COL 2.38 NO-LABEL
     RS-Status AT ROW 4.96 COL 3.25 NO-LABEL
     BR-list AT ROW 5.96 COL 1.13
     ed-notes AT ROW 21.38 COL 1 NO-LABEL
     f-tot-lns AT ROW 5 COL 66 COLON-ALIGNED NO-LABEL
     SPACE(22.00) SKIP(17.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список дисконтных карт"
         DEFAULT-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: dc-list T "SHARED" NO-UNDO ub dis-card
      ADDITIONAL-FIELDS:
          field to-del as logical
          field order-num as integer
          field fdec as decimal
          field fint as integer
          field flog as logical
          field fchar as character
          index pi  is primary unique d-card
          index cn      card-num
          index cli cli-type cli-code
          index host-dscnt  emitent-host-code status_ d-pcnt
          index host-type  emitent-host-code type d-pcnt
          index oi order-num.
      END-FIELDS.
      TABLE: temp-list T "SHARED" NO-UNDO ub units
      ADDITIONAL-FIELDS:
          field fname as character format "X(30)"
          field fvalue as character
          field id as integer
          index pi is primary unique
          id
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                              */
/* BROWSE-TAB BR-option 1 Dialog-Frame */
/* BROWSE-TAB BR-list RS-Status Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-print:HANDLE.

ASSIGN
       B-macro:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-play:HANDLE.

ASSIGN
       B-save:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-save:HANDLE.

/* SETTINGS FOR FILL-IN dsp-rs IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       ed-notes:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-list
/* Query rebuild information for BROWSE BR-list
     _TblList          = "Temp-Tables.dc-list"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _OrdList          = "Temp-Tables.dc-list.d-card|yes"
     _Where[1]         = "Temp-Tables.dc-list.emitent-host-code = p-curr-host-code"
     _FldNameList[1]   > Temp-Tables.dc-list.d-card
"dc-list.d-card" "Номер" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[2]   > Temp-Tables.dc-list.issue-code
"dc-list.issue-code" "Маг-н" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[3]   > Temp-Tables.dc-list.issue-date
"dc-list.issue-date" "Выдано" ? "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[4]   > "_<CALC>"
"get-d-pcnt(buffer Temp-Tables.dc-list, input p-curr-host-code, input p-curr-obj-type, input p-curr-obj-code, input {&ddctr-def-pcnt}, output obj-d-pcnt)" "Скидка" "X(12)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[5]   > Temp-Tables.dc-list.status_
"dc-list.status_" ? "X(4)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[6]   > Temp-Tables.dc-list.emitent-host-code
"dc-list.emitent-host-code" "Фирма" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[7]   > Temp-Tables.dc-list.sourced-card
"dc-list.sourced-card" "К карте" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[8]   > "_<CALC>"
"obj-d-pcnt" "Скидка на!объекте" "->9.99%" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[9]   > Temp-Tables.dc-list.valid-date
"dc-list.valid-date" "Действ.по" ? "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[10]   > Temp-Tables.dc-list.type
"dc-list.type" "Тип" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[11]   > Temp-Tables.dc-list.credit-card
"dc-list.credit-card" ? "+/" "logical" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[12]   = Temp-Tables.dc-list.lim-kr
     _FldNameList[13]   > "_<CALC>"
"(cli-name)" "Название/ФИО" "x(29)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[14]   > "_<CALC>"
"(Temp-Tables.dc-list.cli-type + STRING (Temp-Tables.dc-list.cli-code))" "Клиент" "X(10)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE BR-list */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-option
/* Query rebuild information for BROWSE BR-option
     _START_FREEFORM
open query br-option for each temp-list no-lock .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-option */
&ANALYZE-RESUME


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
on GO of frame {&frame-name} do:
  define variable glog as logical no-undo .
  &if "{2}" = "managed" &then
  if lookup({&lob-res-list}, bttns) > 0 then do:
    message
    "Хотите добавить/изменить хранимый список ДК?"
    view-as alert-box question
    buttons yes-no update glog
    .
    if glog then do:
      run m_dc-save-db-proc in this-procedure no-error.
    end.
  end.
  if lookup({&lob-res-list-macro}, bttns) > 0 then do:
    message
    "Хотите добавить/изменить хранимый макрос формирования списка ДК?"
    view-as alert-box question
    buttons yes-no update glog
    .
    if glog then do:
      run m-macros-save-db-proc in this-procedure no-error .
    end.
  end.
  &endif
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список дисконтных карт */
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
glog = no.
message
"Удаление всех строк списка. Вы уверены ?"
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
                                     , input "# Список карт очищен."
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
define buffer buf_{1}-hist for {1}-hist.
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).
find first buf_{1}-hist no-lock where buf_{1}-hist.id = 0 no-error .
PUT  STREAM PrnLibStream unformatted
SPACE(25) "История создания списка карт "
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
define variable v-ref-rec as recid no-undo .
  if not available {1} then do:
  message "Неправильно выбрана карта."
          view-as alert-box error.
  return no-apply.
end.
FIND FIRST ub.dis-card No-LOCK WHERE
            ub.dis-card.d-card = {1}.d-card no-error .
if error-status:error then  return no-apply.
v-ref-rec = recid( ub.dis-card ) .
run ref/dcardi.w (
               input parparentproc
              ,input {&lookup}
              ,input ub.dis-card.emitent-host-code
              ,input p-curr-host-code
              ,input p-curr-obj-type
              ,input p-curr-obj-code
              ,input ?
              ,input-output v-ref-rec ) .
apply "entry" to br-list in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
define variable v-frame-width as integer no-undo.
if print-option = "" then do:
    run gbl/pop-up.p (self:handle, no) no-error.
end.
run str/dcl-prn.p (
               input parparentproc
              ,input p-curr-host-code
              ,input p-curr-obj-type
              ,input p-curr-obj-code
              ,input print-option
              ,output v-Frame-Width) no-error.

print-option = "".

if v-frame-width <= 198 then do:
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input ( if v-frame-width <= 136
                                                    then 0
                                                    else 8)
                                            ).
end.
else do:
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input ( if v-frame-width <= 255
                                                    then 1
                                                    else 20)
                                            ).
end.
apply "entry" to br-list in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-save Dialog-Frame
ON CHOOSE OF B-save IN FRAME Dialog-Frame /* Сохранить */
DO:
  if save-option = "" then do:
      run gbl/pop-up.p (self:handle, no) no-error.
  end.
  run proc-b-save  in this-procedure (save-option) no-error.
  save-option = '':U.
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
ON VALUE-CHANGED OF br-option IN FRAME Dialog-Frame
DO:
  assign
  Rs-list-method = temp-list.fvalue
  .
  run proc-vc-rs-list-method in this-procedure no-error .
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_dc-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_dc-save Dialog-Frame
ON CHOOSE OF MENU-ITEM m_dc-save /* Файл списка дисконтных карт */
DO:
  assign
  save-option = "dc-list":U.
  apply "choose" to b-save in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_dc-save-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_dc-save-db Dialog-Frame
ON CHOOSE OF MENU-ITEM m_dc-save-db /* Хранимый файл списка дисконтных карт */
DO:
  assign
  save-option = "dc-list-db":U.
  apply "choose" to b-save in frame {&frame-name}.
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


&Scoped-define SELF-NAME m-macros-save-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-macros-save-db Dialog-Frame
ON CHOOSE OF MENU-ITEM m-macros-save-db /* Файл макрос */ DO:
  assign
  save-option = "dc-list-macros-db":U.
  apply "choose" to b-save in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_main-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_main-print Dialog-Frame
ON CHOOSE OF MENU-ITEM m_main-print /* Простой формат */
DO:
  assign
  print-option = "main":U.
  apply "choose" to b-print in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_sel-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_sel-print Dialog-Frame
ON CHOOSE OF MENU-ITEM m_sel-print /* Выбор   полей */
DO:
  assign
  print-option = "extended":U.
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
      'title=':u + "Введите ИМЯ СПИСКА КАРТ" + '\':u
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
frame {&frame-name}:title = substitute("СПИСОК  КАРТ &1", v-value).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_to-make
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_to-make Dialog-Frame
ON CHOOSE OF MENU-ITEM m_to-make /* Файл для изготовления */
DO:
  assign
  save-option = "to-make":U.
  apply "choose" to b-save in frame {&frame-name}.
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


&Scoped-define SELF-NAME n-c
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL n-c Dialog-Frame
ON VALUE-CHANGED OF n-c IN FRAME Dialog-Frame
DO:
    define variable loc#log as logical no-undo.
    if can-do( {&card}, n-c ) then do:
        assign
            NameOrCode:width-chars = 16
            NameOrCode:format = "x(16)" .
    end.
    else do:
        assign
            NameOrCode:width-chars = 9
            NameOrCode:format = "X(9)" .
    end.
    if nameorcode:visible in frame {&frame-name} then
    apply "entry" to NameOrCode in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME NameOrCode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL NameOrCode Dialog-Frame
ON CTRL-J OF NameOrCode IN FRAME Dialog-Frame
DO:
  assign
  n-c
  nameorcode.
  run proc-find-nameorcode in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL NameOrCode Dialog-Frame
ON RETURN OF NameOrCode IN FRAME Dialog-Frame
DO:
  assign
  n-c
  nameorcode.
  run proc-find-nameorcode  in this-procedure  no-error.
  if error-status:error then do:
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME RS-Status
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-Status Dialog-Frame
ON VALUE-CHANGED OF RS-Status IN FRAME Dialog-Frame
DO:
  assign
  RS-status.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define BROWSE-NAME BR-list
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame

{ gbl/hot-key.i b-print }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-del }

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



{ gbl/brwrepos.i
&browse-name=br-list
&line-num=5 }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
{ cmp/ex-dc.i {1} {&frame-name} }
&glob ui-on MyEnable
{ str/an-listp.i {1} dc-list dcm {2} }

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if lookup("automain", parparentproc:file-name, ".") > 0 then do:
    v-no-context = yes.
  end.
  else do:
    { gbl/getcntxt.i get }
  end.
 { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_documents_all':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  false
  v-docs-all
  }
 { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_documents_company':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  false
  v-docs-cmp
  }

  run get-report-num in parparentproc ( output g#report-num ).
  assign
    line-rec = ?
    .
    assign
    n-c:radio-buttons in frame {&frame-name} =
    "Номер" + {&comma-char} + {&card} + {&comma-char} +
    "Код кл." + {&comma-char} + {&client-cmp}
    /* + {&comma-char}  + "Назв./ФИО" + {&comma-char} + {&name}*/
    RS-status:radio-buttons = "Текущие&+" + {&comma-char} + {&current-status} + {&comma-char} +
                              "Все&!" + {&comma-char} + {&all} + {&comma-char} +
                              "Удаленные&-" + {&comma-char} + {&deleted-status} + {&comma-char} +
                              "Блокированные&0" + {&comma-char} + {&blocked-status}
    RS-status = {&current-status}
    .
  ASSIGN b-save:MENU-MOUSE = 1.
  ASSIGN b-print:MENU-MOUSE = 1.
  assign b-macro:menu-mouse = 1.
  /*заполним temp-list*/
  run proc-fill-temp-list in this-procedure .
&if "{2}" = "pre-macro" &then
  run request-create-macro-list-hist  in p-parent-handle ( input this-procedure:handle).
  run proc-macro-play in this-procedure ( input 0, input yes, input 0).
&endif
  if lookup(bttns, "hide") > 0 then do:
    return.
  end.

  RUN Myenable in this-procedure .
  APPLY "VALUE-CHANGED" to n-c.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb_fill-lob-res-list Dialog-Frame
procedure cb_fill-lob-res-list :
define input  parameter p-full-path as character no-undo .
output to value (p-full-path).
for each {1}:
  export
  {1}.d-card
  {1}.cli-type
  {1}.cli-code.

end.
output close.
end procedure. /* cb_save-file-db */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb_fill-lob-res-list-macro Dialog-Frame
procedure cb_fill-lob-res-list-macro :
define input  parameter p-full-path as character no-undo .
define buffer buf_{1}-hist for {1}-hist.
output to value (p-full-path).
for each buf_{1}-hist:
    export
    buf_{1}-hist.
end.
output close.
end procedure. /* cb_fill-lob-res-list-macro */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY dsp-rs NameOrCode n-c RS-Status ed-notes f-tot-lns
      WITH FRAME Dialog-Frame.
  ENABLE dsp-rs BR-option B-exit B-save B-print B-hist B-lkp B-clr B-Help B-add
         B-del B-rest B-macro B-stop B-clear-macro B-record NameOrCode n-c
         RS-Status BR-list ed-notes f-tot-lns
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
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
    f-name = "default.dcm"
    glog = yes
    .
  system-dialog get-file f-name
    filters "Макрос создания списка карт *.dcm" "*.dcm"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "dcm".
  if not glog then do:
    apply "entry" to br-list in frame {&frame-name}.
    return no-apply.
  end.
  run waitfram-show in this-procedure ("Сохранение макроса формирования списка карт.    ЖДИТЕ...").
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
procedure m_dc-save-db-proc :
define variable v-rid-list as character no-undo .
&if "{2}" = "managed" &then
if lookup("clobbnds_add", bttns) > 0 then do:
  run clobbnds_add in p-parent-handle
                  ( input this-procedure:handle
                   ,input {&lob-res-list}
                   ,input "dc-list"
                   ).
end.
if lookup("clobbnds_chg", bttns) > 0 then do:
  run clobbnds_chg in p-parent-handle
                  ( input this-procedure:handle
                   ).
end.
return.
&else
run ref/clobbnds.w ( input parparentproc
                    ,input this-procedure:handle
                    ,input 'b-add' /*bttns*/
                    ,input "uniq-key-rec" /*p-list-mode*/
                    ,input {&update}
                    ,input {&lob-res-list}
                    ,input 'dc-list' /*p-unique-key-rec*/
                    ,input -1 /*p-db-num*/
                    ,input-output v-rid-list) no-error.
&endif
end procedure. /* m_cli-save-db-proc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
procedure m-macros-save-db-proc :
define variable v-rid-list as character no-undo .
&if "{2}" = "managed" &then
if lookup("clobbnds_add", bttns) > 0 then do:
  run clobbnds_add in p-parent-handle
                  ( input this-procedure:handle
                   ,input {&lob-res-list-macro}
                   ,input "dc-list"
                   ).
end.
if lookup("clobbnds_chg", bttns) > 0 then do:
  run clobbnds_chg in p-parent-handle
                  ( input this-procedure:handle
                   ).
end.
return.
&else
run ref/clobbnds.w ( input parparentproc
                    ,input this-procedure:handle
                    ,input 'b-add' /*bttns*/
                    ,input "uniq-key-rec" /*p-list-mode*/
                    ,input {&update}
                    ,input {&lob-res-list-macro}
                    ,input 'dc-list' /*p-unique-key-rec*/
                    ,input -1 /*p-db-num*/
                    ,input-output v-rid-list) no-error.
&endif
end procedure. /* m-macros-save-db-proc */

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
define buffer buf_temp-list for temp-list.
define variable v-recid0 as recid no-undo.
define buffer buf_{1}-hist for {1}-hist.
find first buf_{1}-hist where buf_{1}-hist.id = 0 no-error.
if available buf_{1}-hist then
assign
frame {&frame-name}:title = substitute("СПИСОК  КАРТ &1",  string(buf_{1}-hist.des, "X(60)"))
.
br-option:column-scrolling in frame {&frame-name}  = no. /*чтобы работала прокрутка*/
&if "{2}" = "pre-macro" or "{2}" = "managed" &then
  assign
  frame {&frame-name}:title = p-title
  .
&endif

if tot-lns = ? then do:
  /* первоначальное заполнение истории списка при входе в него */
  v-start = yes.



  for each l-{1} :
    accumulate l-{1}.d-card (count).
  end.
  tot-lns = (accum count l-{1}.d-card).
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
                                          , input "# Исходный список карт пуст."
                                          , input tot-lns
                                          , input 'start':U
                                          , input '':U
                                          , input '':U
                                          , input '':U
                                          , input ?
                                          ).
  end.
end.
assign
nameorcode = ""
RS-list-method = "single".
find first buf_temp-list no-lock where
            buf_temp-list.fvalue = "single".
assign
v-recid0 = recid(buf_temp-list).
{&OPEN-QUERY-br-option}
  if v-seq > 1 then
  find last buf_{1}-hist no-lock where
            buf_{1}-hist.id = (v-seq - 1)
       and  buf_{1}-hist.line = 0 no-error .
  DISPLAY br-option
  (if available buf_{1}-hist
  then buf_{1}-hist.des
  else '') @ dsp-rs
  RS-Status WITH FRAME {&frame-name}.
  ENABLE
  b-macro  when v-start
  b-record when v-start
  b-exit b-add b-hist b-help br-option br-list RS-Status WITH FRAME {&frame-name}.
  &if "{2}" = "pre-macro" &then
  assign
  b-add:label = "Исходн.сп."
  .
  &endif
  if v-start then do:
    hide
    b-stop
    b-clear-macro
    in frame {&frame-name}.
  end.
  v-start = no.
  hide nameorcode in frame {&frame-name} .
&if "{2}" = "managed" &then
if lookup({&lob-res-list}, bttns) > 0 then do:
    menu-item m_dc-save-db:sensitive  in menu menu-b-save = no.
end.
if lookup({&lob-res-list-macro}, bttns) > 0 then do:
    menu-item m-macros-save-db:sensitive  in menu menu-b-save = no.
end.
&endif
  reposition br-option to recid v-recid0.
  if tot-lns > 0 then
    ENABLE
    b-print
    b-rest
    b-save
    b-del
    b-lkp
    b-clr
    n-c
    nameorcode
    WITH FRAME {&frame-name}.
else do:
  DISABLE b-print b-rest b-save b-del b-lkp b-clr nameorcode WITH FRAME {&frame-name}.
end.
  if tot-lns = ? or tot-lns = 0 then do:
    hide nameorcode in frame {&frame-name} .
  end.
  VIEW FRAME {&frame-name}.
  run openbr in this-procedure .
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
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
define input parameter rs-status as character no-undo .

line-mode = {&add-def}.
if rs-list-method = "single" then do:
  v-no-hist = - 1.
  if p-from-macro then do:
    find ub.dis-card where rowid(ub.dis-card) = p-rowid no-lock no-error .
  end.
  else do:
    run ref/discards.w ( input parparentproc
                        ,input "b-sel,b-add"
                        ,input {&all}
                        ,input p-curr-host-code
                        ,input p-curr-obj-type
                        ,input p-curr-obj-code
                        ,input '':U
                        ,input ?
                        ,output ref-list).
    apply "entry" to br-list in frame {&frame-name}.
    if ref-list = "" then return error.
    /* выбрана карта */
    find ub.dis-card where recid (ub.dis-card) = integer (ref-list) no-lock.
  end.
  if available dis-card then do:
    run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
    tot-lns = tot-lns + 1.
    run write-hist in this-procedure (p-from-macro, rs-list-method, rs-status, line-mode).
  end.
  else do:
    return error "Нет в БД такой карты".
  end.
  run Myenable in this-procedure .
end.
else do:
    run rs-do in this-procedure (no, no, rs-list-method, rs-status, line-mode, v-seq - 1).
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .

define variable glog as logical no-undo .
define variable v-rep-rec as recid no-undo .
line-mode = {&deletion}.
if rs-list-method = "single" then do:
  v-no-hist = - 1.
  if p-from-macro then do:
    find first ub.dis-card where rowid(ub.dis-card) = p-rowid no-error.
    if not available ub.dis-card then return error "Нет в БД такой карты".
    find first {1} where {1}.d-card = ub.dis-card.d-card no-error.
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
    run write-hist in this-procedure (p-from-macro, rs-list-method, rs-status, line-mode).
    delete {1}.
    line-rec = v-rep-rec.
    run Myenable in this-procedure .
  end.
  else do:
    tot-lns = tot-lns - 1.
    run Myenable  in this-procedure .
    return error "Нет в списке карт такой карты".
  end.
end.
else do:
  glog = no.
  message
  "Удалить карты из списка ПО заданному УСЛОВИЮ ?   Вы уверены ?"
   view-as alert-box question buttons OK-Cancel update glog.
  if not glog then  return error.
  run rs-do in this-procedure (no, no, rs-list-method, rs-status, line-mode, v-seq - 1).
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-rest Dialog-Frame
PROCEDURE proc-b-rest :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .

define variable glog as logical no-undo .
define buffer buf_{1}-hist for {1}-hist.
line-mode = {&leave}.
if rs-list-method = "single" then do:
  v-no-hist = - 1.
  if p-from-macro then do:
    find first ub.dis-card where rowid(ub.dis-card) = p-rowid no-error.
    if not available ub.dis-card then return error substitute("Нет в БД такой карты").
    find first {1} where {1}.d-card = ub.dis-card.d-card no-error.
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
    run write-hist in this-procedure (p-from-macro, rs-list-method, rs-status, line-mode).
    for each {1}:
      if line-rec <> recid ({1}) then delete {1}.
    end.
    tot-lns = 1.
    run Myenable  in this-procedure .
 end.
  else do:
    return error substitute("Нет в списке такой карты").
  end.
end.
else do:
  if not p-from-macro then do:
    glog = no.
    message "Оставить карты в списке ПО заданному УСЛОВИЮ и УДАЛИТЬ ВСЕ ОСТАЛЬНЫЕ ?   Вы уверены ?"
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then
      return no-apply.
  end.
  assign
  lns-cnt = 0
  lns-ignore = 0
  .
  run rs-do in this-procedure (no, no, rs-list-method, rs-status, line-mode, v-seq - 1).
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
  run Myenable  in this-procedure .
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-file-list-methods Dialog-Frame
procedure proc-file-list-methods :
define input parameter p-from-macro as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-id      as integer no-undo .
define variable ss as character no-undo .

define variable imp-type like ub.goods.prod-type no-undo.
define variable imp-code like ub.goods.prod-code no-undo.
define variable imp-art like ub.goods.artic no-undo.
define variable imp-doc-code like ub.trn-doc.doc-code no-undo.
define variable imp-doc-type as character no-undo.
define variable imp-chk-type as integer no-undo.
define variable imp-d-card as character no-undo.

define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-tbl-row          as rowid no-undo .
define variable v-tbl-name         as character no-undo .


define buffer buf_{1}-hist for {1}-hist.
define buffer buf_clob-data for ub.clob-data.
define buffer buf_clob-bind for ub.clob-bind.


do
on error undo, return error
:
  find first buf_{1}-hist where
          buf_{1}-hist.id = p-id
      AND buf_{1}-hist.item_ <> '':U .

if rs-list-method = "clob-data" then do:
  run gen-row-keyr in this-procedure (
   input  buf_{1}-hist.item_    /*p-uniq-key-rec*/
  ,input  ? /*p-key-handle  буфер записи которую будем искать. если ищем по key-rec то ? */
  ,input  "ub"
  ,input  ? /*p-tt-handle   буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
  ,input NO-LOCK
  ,output v-tbl-row
  ,output v-tbl-name  ) no-error.
  if error-status :error then do:
    message
    "Ошибка при поиске хранимого файла"
    view-as alert-box error.
    return error.
  end.
  find first buf_clob-bind no-lock where
            rowid(buf_clob-bind) = v-tbl-row .
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
                ,output v-file-name) .
  copy-lob from object buf_clob-data.cdata
  to file v-file-name.
end.

  run gbl/filename.p
  (input  (if rs-list-method = "clob-data" then v-file-name else buf_{1}-hist.item_  )/* p-search-file-name */
  ,output v-full-path         /* p-full-path        */
  ,output v-path              /* p-path             */
  ,output v-file-name         /* p-file-name        */
  ,output v-file-name-no-ext  /* p-file-name-no-ext */
  ,output v-file-name-ext     /* p-file-name-ext    */
  ) no-error .
  if error-status:error then do:
  end.
  else do:
    input stream sout from value (v-full-path).
      CASE rs-list-method:
        when "doc-list" then do:
          repeat:
          import stream sout imp-doc-code imp-doc-type no-error.
          if imp-doc-type <>  {&overvalue} then do:
            find first ub.trn-doc no-lock where
                      ub.trn-doc.doc-code = imp-doc-code No-error.
            if available ub.trn-doc
            and
            (ub.trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
             or ub.trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}) then do:
              for each ub.chk-doc no-lock where
                      ub.chk-doc.out-code = (if ub.trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
                                          then ub.trn-doc.doc-code
                                          else ub.trn-doc.out-code) and ub.chk-doc.d-card <> "":U,
                  first ub.dis-card no-lock where
                        ub.dis-card.d-card = ub.chk-doc.d-card:
                run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
              end.
            end.
            else if ub.trn-doc.d-card <> "":U and ub.trn-doc.d-card <> ? then do:
              find first ub.dis-card no-lock where
                        ub.dis-card.d-card = ub.trn-doc.d-card no-error .
              if available ub.dis-card then
                run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
            end.
          end.  /*    if imp-doc-type <>  {&overvalue} then do:*/
        end. /*repeate*/
      end. /*when doc-list*/
      when "cli-list" then do:
        repeat:
          import stream sout imp-type imp-code no-error.
          find ub.clients where
              ub.clients.obj-type = imp-type and
              ub.CLIENTS.OBJ-code = imp-code
              no-lock no-error.
          if available ub.CLIENTS then do:
            for each ub.dis-card No-LOCK WHERE
                      ub.dis-card.cli-type = ub.clients.obj-type AND
                      ub.dis-card.cli-code = ub.clients.obj-code:
              run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
            end.
          end.
        end. /*repeat*/
      end.
      when "chk-list" then do:
        repeat:
          import stream sout imp-doc-code imp-chk-type no-error.
          if imp-chk-type = integer({&rcpt-sale})
          or imp-chk-type = integer({&rcpt-return})
          or imp-chk-type = integer({&rcpt-return-write-off})
          or imp-chk-type = ? then do:
            find first ub.chk-doc no-lock where
                      ub.chk-doc.doc-code = imp-doc-code No-error.
            if available ub.chk-doc and ub.chk-doc.d-card <> "":U then do:
              find first ub.dis-card no-lock where
                        ub.dis-card.d-card = ub.chk-doc.d-card no-error.
              if available ub.dis-card then
              run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
            end.
          end.
        end. /*repeat*/
      end. /*when chk-list*/
      when "file"
      or
      when "clob-data"
      then do:
        repeat:
          import stream sout imp-d-card no-error.
          find ub.dis-card where
              ub.dis-card.d-card = imp-d-card no-lock no-error.
          if available ub.dis-card then run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
        end.
        if rs-list-method = "clob-data" then do:
          os-delete value(v-full-path) .
        end.
      end. /*when file*/
    end CASE.
  end.
  input stream sout close.
  {&assign-nums}.
end.
end procedure. /* proc-file-list-methods */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-save Dialog-Frame
PROCEDURE proc-b-save :
define input parameter loc-save-option as character no-undo.
define variable v-frame-width as integer no-undo.
define variable v-default-valid-date as date no-undo .
define variable v-codir as character no-undo .
define variable v-prefix as character no-undo .
define variable v-dopi as integer no-undo .
define variable v-default-valid-date-chr as character no-undo .
define variable glog as logical no-undo .
define variable v-full-number as character no-undo .
define variable v-rid-list as character no-undo .

define buffer buf_clients for ub.clients.
case loc-save-option:
  when "dc-list":U then do:
    assign
    f-name = "default.dc"
    glog = yes
    .
    system-dialog get-file f-name
    filters "Списки дисконтных карт *.dc" "*.dc"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "dc".
    if not glog then do:
      apply "entry" to br-list in frame {&frame-name}.
      return no-apply.
    end.
    output to value (f-name).
    for each {1}:
      export
      {1}.d-card
      {1}.cli-type
      {1}.cli-code
      .
    end.
    output close.
  end.
  when "dc-list-macros-db" then do:
    run m-macros-save-db-proc in this-procedure .
  end.
  when "dc-list-db" then do:
    run m_dc-save-db-proc in this-procedure .
  end.
  when "excel":U then do:
    do on stop  undo, return no-apply
        on error undo, return no-apply
        on quit  undo, return no-apply
      :
      run str/dcl-prn.p (
                       input parparentproc
                      ,input p-curr-host-code
                      ,input p-curr-obj-type
                      ,input p-curr-obj-code
                      ,input "excel":U
                      ,output v-Frame-Width) no-error.
        assign make-excel = no.
        run waitfram-hide in this-procedure .
    end.
  end.
  when "to-make":U then do:
    assign
    f-name = "default.crd"
    glog = yes
    .
    system-dialog get-file f-name
    filters "Списки ДК для изготовления *.crd" "*.crd"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "crd".
    if not glog then do:
      apply "entry" to br-list in frame {&frame-name}.
      return no-apply.
    end.
    run gbl/crd-file.w (output v-codir, output v-default-valid-date, output v-prefix) no-error .
    if error-status:error
    or return-value = "error" then do:
      apply "entry" to br-list in frame {&frame-name}.
      return no-apply.
    end.
    if session:set-wait-state( "COMPILER" )  then .
    CASE v-codir:
      when '':U
      or when "1251":U
      then do:
        output to value (f-name).
      end.
      when "koi8-r" then do:
        output to value (f-name) convert target "koi8-r".
      end.
      when "ibm866" then do:
        output to value (f-name) convert target "ibm866".
      end.
    END CASE.
    output stream slog to value("crd-file.log") .
    for each {1}:
      if {1}.mask-card then do:
        put stream slog unformatted substitute("карта &1 - маска: пропускаем..."
                                              , {1}.d-card) skip.
        next.
      end.
      find first buf_clients no-lock where
                buf_clients.obj-type = {1}.cli-type
            AND  buf_clients.obj-code = {1}.cli-code no-error .
      if available buf_clients
      and buf_Clients.obj-name <> '':U
      then do:
        if length({1}.d-card)  +  length(v-prefix) + 1 > 19 then do:
          put stream slog unformatted substitute("карта &1 - длина с учетом префикса &2 и КЦ больше 19 символов: пропускаем..."
                                                , {1}.d-card
                                                , v-prefix) skip.
          next.
        end.
        run gbl/pluhnalg.p (input (v-prefix + {1}.d-card + 'C')
                        ,output v-full-number) no-error .
        if error-status:error then do:
          put stream slog unformatted substitute("карта &1 - ошибка при вычислении КЦ &2: пропускаем..."
                                                , {1}.d-card
                                                , error-status:get-message(1) ) skip.
          next.
        end.
        if v-codir <> '':U then do:
          put unformatted
          substitute("~~1%&1?", string(buf_clients.obj-name, "X(30)")) skip
          .
        end.
        put unformatted
        substitute("~~2;&1=&2&3700&4?"
                  , v-full-number
                  , (if {1}.valid-date <> ?
                    then string(year({1}.valid-date) - 2000, "99")
                    else string(year(v-default-valid-date) - 2000, "99")
                    )
                  , (if {1}.valid-date <> ?
                    then string(month({1}.valid-date), "99")
                    else string(month(v-default-valid-date), "99")
                    )
                  , fill({&space-char}, 5 )
                  ) skip.
      end.
      else do:
        put stream slog unformatted
        substitute("карта &1 - не найден клиент &2&3 или нет фамилии/названия: пропускаем..."
                  , {1}.d-card
                  , {1}.cli-type
                  , {1}.cli-code) skip.
        next.
      end.
    end.
    output close.
    output stream slog close.
    if session:set-wait-state( "" )  then .
  end.
end case.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-nameorcode Dialog-Frame
PROCEDURE proc-find-nameorcode :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
case n-c:
    when {&card} then do:
    if last-event:label = "Ctrl-J" then
        find next l-{1} no-lock where
                  l-{1}.d-card begins nameorcode no-error.

    else
        find first l-{1} no-lock where
                  l-{1}.d-card begins nameorcode no-error.
    end.
    when {&client-cmp} then do:
    if last-event:label = "Ctrl-J" then
        find next l-{1} no-lock where
                  l-{1}.cli-code = integer(nameorcode) no-error.
    else
        find first l-{1} no-lock where
                  l-{1}.cli-code = integer(nameorcode) no-error.

    end.
end case.
if available l-{1} then do:
  line-rec = recid (l-{1}).
  reposition br-list to recid line-rec no-error.

    apply "value-changed" to br-list in frame {&frame-name}.

end.
else do:
  message "Строка не найдена."
          view-as alert-box error.

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-vc-rs-list-method Dialog-Frame
PROCEDURE proc-vc-rs-list-method :
define variable v-operation as integer no-undo .
define variable ii as integer no-undo.
define variable v-recs as integer no-undo .
define variable v-line as integer no-undo .
define variable v-item as character no-undo .
define variable v-tbl-name as character no-undo .
define variable v-bh as handle no-undo .
define variable v-tot-lns as integer no-undo .
define variable v-temp-seq as integer no-undo .
define variable v-message as character no-undo .
define variable grp-path as character no-undo .
define variable glog as logical no-undo .
define variable v-input-output as character no-undo .
define variable v-ref-rec as recid no-undo .
define variable v-grp-rec as recid no-undo .
define variable f-name as char init "default.trn" no-undo.
define variable v-host-name as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo.
define variable v-rid-list as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define buffer buf_stop-list for ub.stop-list.
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_{1}-hist for {1}-hist.
 v-no-hist = - 1.
if rs-list-method = "single" then
run Myenable  in this-procedure .
else do:
  v-no-hist = 0.
  case rs-list-method:
    when "company" then do:
      glog = yes.
      message
      substitute("Все карты с эмитентом-фирмой &1", p-curr-host-code)
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable  in this-procedure .
        return no-apply.
      end.
      v-no-hist = 1.
      { gbl/hostname.i p-curr-obj-type p-curr-obj-code v-host-code v-host-name }
      run create-{1}-hist in this-procedure(input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('Карты фирмы &1 &2', v-host-name, stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input "company"
                                          , input string(p-curr-host-code)
                                          , input ?
                                          ).
    end. /*when company*/
    when "global" then do:
      glog = yes.
      message
      substitute("Все глобальные карты")
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable in this-procedure .
        return no-apply.
      end.
      v-no-hist = 1.
      run create-{1}-hist in this-procedure(input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('Глобальные карты &1', stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input 'global'
                                          , input string(0)
                                          , input ?
                                          ).
    end. /*when global*/
    when "type" then do:
      glog = yes.
      message
      "Все карты выбранных типов."
       view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      GRP-list = "". /* кажется, при выходе по Esc не снимается */
      run ref/dc-types.w (
                       input parparentproc
                      ,input "":U /*p-mode*/
                      ,input "b-sel,b-mark":U
                      ,input 0
                      ,input p-curr-host-code
                      ,input p-curr-obj-type
                      ,input p-curr-obj-code
                      ,input-output ref-list
                      ).
      if ref-list = "" then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      dsp-rs = "".
      v-recs = num-entries(ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find ub.dis-card-type where recid (ub.dis-card-type) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Тип &1 Эмитент &2: &3"
                              , ub.dis-card-type.type
                              , ub.dis-card-type.emitent-host-code
                              , stat-line(rs-status)
                              )
          v-item     = '':U
          v-tbl-name = {&table_dis-card-type}
          v-bh       = buffer dis-card-type:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Тип &1:"
                                , stat-line(rs-status))
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
            dsp-rs = substitute("Тип &1 Эмитент &2"
                                , ub.dis-card-type.type
                                , ub.dis-card-type.emitent-host-code
                                )
            v-item     = '':U
            v-tbl-name = {&table_dis-card-type}
            v-bh       = buffer ub.dis-card-type:handle
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
    when "all" then do:
      glog = yes.
      message "Все карты из справочника карт."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      v-no-hist = 1.
      run create-{1}-hist in this-procedure(input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('Все карты &1', stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input 'all':U
                                          , input '':U
                                          , input ?
                                          ).
    end.
    when "card" then do:
      glog = yes.
      message "1 или несколько карт"
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      dsp-rs = "".
      run ref/discards.w (
                           input parparentproc
                          ,input "b-sel,b-mark"
                          ,input {&all}
                          ,input p-curr-host-code
                          ,input p-curr-obj-type
                          ,input p-curr-obj-code
                          ,input '':U
                          ,input ?
                          ,output ref-list).
      apply "entry" to br-list in frame {&frame-name}.
      if ref-list = "" then do:
          run MyEnable  in this-procedure .
          return error.
      end.
      /* выбраны карты */
      v-recs = num-entries (ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find ub.dis-card  where recid (ub.dis-card) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Карта :&1 &2", ub.dis-card.d-card, stat-line(rs-status))
          v-item     = '':U
          v-tbl-name = {&table_dis-card}
          v-bh       = buffer ub.dis-card:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Карты : &1", stat-line(rs-status))
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
            dsp-rs = substitute("№ карты &1 &2&3", ub.dis-card.d-card, ub.dis-card.cli-type, ub.dis-card.cli-code)
            v-item     = '':U
            v-tbl-name = {&table_dis-card}
            v-bh       = buffer ub.dis-card:handle
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
    when "cli" or WHEN "cli-grp" then do:
      if rs-list-method = "cli-grp" then do:
        glog = yes.
        message
        "Карты по 1-й или нескольким групп клиентов"
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run MyEnable  in this-procedure .
          return error.
        end.
        /* вызов справочника групп КЛИЕНТОВ для выбора */
        GRP-list = "". /* кажется, при выходе по Esc не снимается */
        ref-list = "".
        run ref/cli-grps.w ( input parparentproc
                            ,input "b-sel,b-mark"
                            ,input-output grp-list).
      end.
      else do:
        glog = yes.
        message
        "Карты 1-го или нескольких произвольных клиентов из справочника."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run MyEnable  in this-procedure .
          return error.
        end.
        run ref/cli-all.w ( input parparentproc
                        ,input "b-sel,b-mark,b-add"
                        ,input  ?
                        ,input  ?
                        ,input  ?
                        ,input  ?
                        ,input  ?
                        ,input  ?
                        ,output ref-list).
        grp-list = ?.
      end.
      if grp-list <> ? and
      grp-list <> "" then do:
        v-recs = num-entries (grp-list).
        do num-rec = 0 to v-recs:
          if v-recs = 1 then do:
            num-rec = 1 .
          end.
          if num-rec > 0 then do:
            v-grp-rec = integer (entry (num-rec, grp-list)).
            find ub.cli-grp where recid (ub.cli-grp) = v-grp-rec no-lock.
            run cli-grplib-get-full-name in this-procedure (ub.cli-grp.node-code, output grp-path).
          end.
          if v-recs = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Группа клиентов &1: &2", grp-path, stat-line(rs-status))
            v-item     = '':U
            v-tbl-name = {&table_cli-grp}
            v-bh       = buffer cli-grp:handle
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Группы клиентов: &1", stat-line(rs-status))
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
              dsp-rs = substitute("&1", grp-path)
              v-item     = '':U
              v-tbl-name = {&table_cli-grp}
              v-bh       = buffer ub.cli-grp:handle
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
        end.
      end.
      else if ref-list <> "" and  ref-list <> ? then do:
        v-recs = num-entries (ref-list) .
        do num-rec = 0 to v-recs:
          if v-recs = 1 then do:
            num-rec = 1 .
          end.
          if num-rec > 0 then do:
            v-ref-rec = integer (entry (num-rec, ref-list)).
            find ub.clients where recid (ub.clients) = v-ref-rec no-lock.
          end.
          if v-recs = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Клиент :&1 &2", ub.clients.obj-name, stat-line(rs-status))
            v-item     = '':U
            v-tbl-name = {&table_clients}
            v-bh       = buffer ub.clients:handle
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Клиент : &1", stat-line(rs-status))
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
              dsp-rs = substitute("&1", clients.obj-name)
              v-item     = '':U
              v-tbl-name = {&table_clients}
              v-bh       = buffer ub.clients:handle
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
        run MyEnable  in this-procedure .
        return error.
      end.
    end. /*when cli or cli-grp*/
    when "person" then do:
      glog = yes.
      message
      "Карты всех физических лиц."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure(input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('Карты ВСЕХ физические лиц. &1', stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input 'person':U
                                          , input '':U
                                          , input ?
                                          ).
    end. /*when person*/
    when "waybill" then do:
      glog = yes.
      message
      "Карты контрагентов выбранных документов."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      run str/all-docs.w (input parparentproc
                    ,input (if v-docs-all
                            then ?
                            else v-cntxt-host-code-obj)
                    ,input (if v-docs-all
                            then ?
                            else v-cntxt-obj-type)
                    ,input (if v-docs-all
                            then ?
                            else v-cntxt-obj-code)
                    ,input (if v-docs-all
                            then {&work}
                            else (if v-docs-cmp
                                  then {&company}
                                  else {&g___object})
                            )
                    ,input ? /*parstat*/
                    ,input ? /*partype*/
                    ,input ? /*parflag*/
                    ,input ? /*parinternal*/
                    ,input 'b-sel,b-mark':U /*bttns*/
                    ,input '':U /*parext-doc-type*/
                    ,input ? /*paris-hold*/
                    ,input ? /*doc-rec*/
                    ,output ref-list
                    ) no-error .
      if ref-list = "" then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      v-recs = num-entries(ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .

        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find ub.trn-doc where recid (ub.trn-doc) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Карты контрагента по документу : &1 &2 &3 &4 № &5 от &6 &7"
                              , ub.trn-doc.doc-type
                              , ub.trn-doc.status_
                              , ub.trn-doc.obj-type
                              , ub.trn-doc.obj-code
                              , ub.trn-doc.doc-code
                              , string (ub.trn-doc.doc-date, '99/99/9999')
                              , stat-line(rs-status)
                              )
          v-item     = '':U
          v-tbl-name = {&table_trn-doc}
          v-bh       = buffer ub.trn-doc:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Карты контрагентов по документам : &1", stat-line(rs-status))
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
            dsp-rs = substitute("&1 &2 &3 &4 № &5 от &6"
                                , ub.trn-doc.doc-type
                                , ub.trn-doc.status_
                                , ub.trn-doc.obj-type
                                , ub.trn-doc.obj-code
                                , ub.trn-doc.doc-code
                                , string (ub.trn-doc.doc-date, '99/99/9999')
                                )
            v-item     = '':U
            v-tbl-name = {&table_trn-doc}
            v-bh       = buffer ub.trn-doc:handle
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
    end. /*when waybill*/
    when "inkas" then do:
      glog = yes.
      message
      "Карты по выбранным продажам по объекту."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      {&sel-obj}
      { gbl/hostcode.i v-sel-obj-type v-sel-obj-code v-host-code }
      ref-list = ''.
      run str/salelist.w (
                      input parparentproc
                    , input "b-sel,b-mark"
                    , {&g___object}
                    , v-host-code
                    , v-sel-obj-type
                    , v-sel-obj-code
                    , input-output ref-list).
      if ref-list = "" then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      v-recs = num-entries(ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find ub.inkas where recid (ub.inkas) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Карты по чекам продажи &1&2 № &3 от &4 &5"
                              , ub.inkas.obj-type
                              , ub.inkas.obj-code
                              , ub.inkas.inkas-code
                              , string (ub.inkas.doc-date, '99/99/9999')
                              , stat-line(rs-status)
                              )
          v-item     = '':U
          v-tbl-name = {&table_inkas}
          v-bh       = buffer ub.inkas:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Карты контрагентов по продажам &1&2: &3", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
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
            dsp-rs = substitute("&1 &2 &3 &4 № &5 от &6"
                                , ub.inkas.inkas-code
                                , string (inkas.doc-date, '99/99/9999')
                                )
            v-item     = '':U
            v-tbl-name = {&table_inkas}
            v-bh       = buffer ub.inkas:handle
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
    end. /*when inkas*/
    when "stop-list" then do:
      glog = yes.
      message
      "Карты выбранных стоплистов."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      ref-list = '':U.
      run ref/stop-ls.w ( input parparentproc
                         ,input "b-sel,b-mark"
                         ,input {&all}
                         ,input-output ref-list
                    ) no-error .
      if ref-list = "" then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      v-recs = num-entries(ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .

        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find first buf_stop-list where recid (buf_stop-list) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Карты стоплиста : &1 от &2 &3"
                              , buf_stop-list.stop-list-code
                              , string (buf_stop-list.doc-date, '99/99/9999')
                              , stat-line(rs-status)
                              )
          v-item     = '':U
          v-tbl-name = {&table_stop-list}
          v-bh       = buffer buf_stop-list:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Карты стоплистов : &1", stat-line(rs-status))
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
            dsp-rs = substitute("&1 от &2"
                                , buf_stop-list.stop-list-code
                                , string (buf_stop-list.doc-date, '99/99/9999')
                                )
            v-item     = '':U
            v-tbl-name = {&table_stop-list}
            v-bh       = buffer buf_stop-list:handle
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
    end. /*when stop-list*/
    when "chk-doc" then do:
      glog = yes.
      message
      "Карты по выбранным чекам по объекту."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      {&sel-obj}
      ref-list = ''.
      run str/chk-docs.w (   input parparentproc
                      , input "b-sel,b-mark"
                      , input {&g___object}
                      , input ? /*pardoc-rec*/
                      , input v-sel-obj-type
                      , input v-sel-obj-code
                      , input "":U /*parout-code*/
                      , input "":U /*pard-card*/
                      , input 0 /*p-pay-desk*/
                      , input ? /*p-start-date*/
                      , input ? /*p-end-date*/
                      , input 0
                      , output ref-list).
      if ref-list = "" then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      v-recs = num-entries(ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find ub.chk-doc where recid (ub.chk-doc) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Карта чека &1&2 &3 от &4 &5"
                              , v-sel-obj-type
                              , v-sel-obj-code
                              , ub.chk-doc.doc-code
                              , string(ub.chk-doc.chk-date)
                              , stat-line(rs-status)
                              )
          v-item     = '':U
          v-tbl-name = {&table_chk-doc}
          v-bh       = buffer ub.chk-doc:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Карты чеков &1&2: &3", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
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
            dsp-rs = substitute("&1 от &2"
                                , ub.chk-doc.doc-code
                                , string (ub.chk-doc.chk-date, '99/99/9999')
                                )
            v-item     = '':U
            v-tbl-name = {&table_chk-doc}
            v-bh       = buffer ub.chk-doc:handle
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
    end. /*when chk-doc*/
    when "attr" or
    when "attr-val"
    then do:
      run trig-attr  in this-procedure (input rs-list-method) no-error.
      if error-status:error then do:
        run MyEnable  in this-procedure .
        return error.
      end.
    end. /*when attr*/
    when "dcp" or
    when "dcp-val"
    then do:
      run trig-dcp  in this-procedure (input rs-list-method) no-error.
      if error-status:error then do:
        run MyEnable  in this-procedure .
        return error.
      end.
    end. /*when attr*/
    when "general-sum-id"
    or
    when "partial-sum-id"
    or
    when "last-change-general-sum-id"
    or
    when "last-change-partial-sum-id" then do:
      run proc-sum-id in this-procedure ( input rs-list-method) no-error.
      if error-status:error then do:
        run MyEnable in this-procedure .
        return error.
      end.
    end.
    when "cli-list" then do:
      glog = yes.
      message
      "Все карты для клиентов из сохраненного в файле списка клиентов."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable  in this-procedure .
        return error.
      end.
      system-dialog get-file f-name
        filters "Списки клиентов *.cli" "*.cli"
        title "Выберите файл списка"
        INITIAL-DIR "."
        return-to-start-dir
        must-exist
        /* use-filename */
        update glog
        default-extension "cli".
      if not glog then do:
        run MYenable  in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure(input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute("Карты клиентов из списка: &1 &2", f-name, stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input f-name
                                          , input '':U
                                          , input ?
                                          ).
    end. /*when cli-list*/
    when "doc-list" then do:
      glog = yes.
      message
      "Все карты для документов из сохраненного в файле списка документов."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable  in this-procedure .
        return error.
      end.
      system-dialog get-file f-name
        filters "Списки документов *.trn" "*.trn"
        title "Выберите файл списка"
        INITIAL-DIR "."
        return-to-start-dir
        must-exist
        /* use-filename */
        update glog
        default-extension "trn".
      if not glog then do:
        run MYenable  in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure(input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute("Карты документов из списка: &1 &2", f-name, stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input f-name
                                          , input '':U
                                          , input ?
                                          ).
    end. /*when doc-list*/
    when "chk-list" then do:
      glog = yes.
      message
      "Все карты для чеков из сохраненного в файле списка чеков."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable  in this-procedure .
        return error.
      end.
      system-dialog get-file f-name
        filters "Списки документов *.chk" "*.chk"
        title "Выберите файл списка"
        INITIAL-DIR "."
        return-to-start-dir
        must-exist
        /* use-filename */
        update glog
        default-extension "chk".
      if not glog then do:
        run MYenable  in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure(input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute("Карты чеков из списка: &1 &2", f-name, stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input f-name
                                          , input '':U
                                          , input ?
                                          ).
    end. /*when chk-list*/
    when "deleted" then do:
      if RS-status = {&current} then do:
        message
        "Переключатель <СТАТУС> стоит в положениии <Текущие>" skip
        "Вы не cможете выбрать ни одну карту"
        view-as alert-box error .
        run MyENable  in this-procedure .
        return error.
      end.
      glog = yes.
      message
      "Все удаленные карты."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure(input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute("ВСЕ удаленные карты &1", stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input 'deleted':U
                                          , input '':U
                                          , input ?
                                          ).
    end. /*when deleted*/
    when "file" then do:
      glog = yes.
      message "Все карты из ранее сохраненного в файле списка."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable  in this-procedure .
        return error.
      end.
      system-dialog get-file f-name
        filters "Списки дисконтных карт *.dc" "*.dc"
        title "Выберите файл списка"
        INITIAL-DIR "."
        return-to-start-dir
        must-exist
        /* use-filename */
        update glog
        default-extension "dc".
      if not glog then do:
        run MyEnable  in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure(input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute("Файл списка : &1 &2", f-name, stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input f-name
                                          , input '':U
                                          , input ?
                                          ).
  end. /*when file*/
  when "clob-data" then do:
    glog = yes.
    message "Все карты из ранее сохраненного в БД списка"
    skip stat-line(rs-status)
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      run Myenable in this-procedure.
      return error.
    end.
    run ref/clobbnds.w ( input parparentproc
                        ,input this-procedure:handle
                        ,input 'b-sel' /*bttns*/
                        ,input "uniq-key-rec" /*p-list-mode*/
                        ,input "" /*p-mode*/
                        ,input {&lob-res-list}
                        ,input 'dc-list' /*p-unique-key-rec*/
                        ,input -1 /*p-db-num*/
                        ,input-output v-rid-list) no-error.
    if v-rid-list = '' then do:
      run Myenable in this-procedure.
      return error.
    end.

    find first buf_clob-bind no-lock where
              recid(buf_clob-bind) = integer(v-rid-list) .
    run gen-key-rec in this-procedure ( input {&table_clob-bind}
                                        ,input (buffer buf_clob-bind:handle)
                                        ,output v-uniq-key-rec).
    run create-{1}-hist in this-procedure (
                                          input {&add-def}
                                        , input-output v-seq
                                        , input 0
                                        , input '':U
                                        , input substitute("Хранимый Файл списка : &1 &2", buf_clob-bind.field-name_, stat-line(rs-status))
                                        , input tot-lns
                                        , input rs-list-method
                                        , input rs-status
                                        , input v-uniq-key-rec
                                        , input '':U
                                        , input ?)
                                        .
  end.
  WHEN "FILTER" THEN DO:
      run trig-filter  in this-procedure no-error.
      if error-status:error then do:
        run MyEnable  in this-procedure .
        return error.
      end.
  END. /*WHEN FILTER*/
end case.
if tot-lns <> 0 then do:
    run get-operation in this-procedure (input dsp-rs, output v-operation).
    CASE v-operation:
      when {&add-operation} then do:
        run proc-b-add in this-procedure(no, ?, rs-list-method, rs-status ).
      end.
      when {&del-operation} then do:
        run proc-b-del in this-procedure(no, ?, rs-list-method, rs-status ).
      end.
      when {&rest-operation} then do:
        run proc-b-rest in this-procedure(no, ?, rs-list-method, rs-status ).
      end.
      otherwise do:
        assign
        dsp-rs = "":U.
        run MyEnable in this-procedure .
        return error.
      end.
    END CASE.
  end.
  assign
  rs-list-method = temp-list.fvalue
  .
  find last buf_{1}-hist no-lock where
            buf_{1}-hist.id = (v-seq - 1)
      and  buf_{1}-hist.line = 0 no-error .
  DISPLAY
  (if available buf_{1}-hist
  then buf_{1}-hist.des
  else '') @ dsp-rs
  with frame {&frame-name}.
  if tot-lns = 0
  then do:
    run proc-b-add in this-procedure(no, ?, rs-list-method, rs-status)  .
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rs-do Dialog-Frame
PROCEDURE rs-do :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-from-macro as logical no-undo .
define input parameter p-step as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-id      as integer no-undo .

define variable v-rowid   as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-obj-type as character  no-undo.
define variable v-obj-code as integer    no-undo.
DEFINE VARIABLE v-attr-code          as character           no-undo .
define variable grp-path as character no-undo .
define variable v-host-code as integer no-undo .
define variable v-dt-code as integer no-undo .
define variable v-r-b as character no-undo .
define variable v-field as character no-undo .
define variable v-low as decimal no-undo .
define variable v-high as decimal no-undo .
define variable v-acc as decimal no-undo .
define variable v-next as logical no-undo .
define variable v-last-change-date as date no-undo .
define variable v-cond as character no-undo .
define variable v-dtm-code as integer no-undo .
define variable v-node-code as integer no-undo .
define buffer buf_dis-card-property for ub.dis-card-property.
define buffer buf_prop-map for ub.prop-map.
define buffer buf_stop-list for ub.stop-list.
define buffer buf_stop-list-line for ub.stop-list-line.


define buffer buf_{1}-hist for {1}-hist.

do
on error undo, return error return-value
:

assign
lns-cnt = 0
lns-ignore = 0
v-num-add  = 0
v-num-ignored = 0
tot-lns = (if line-mode = {&leave} then 0 else tot-lns)
.
run write-hist in this-procedure (p-from-macro, rs-list-method, rs-status, line-mode).
if session:set-wait-state( "COMPILER" )  then .
dsp-rs:fgcolor in frame {&frame-name} = 12.
case rs-list-method:
  when "card" then do:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      {&get-rowid} next.
      find ub.dis-card where rowid (ub.dis-card) = v-rowid no-lock.
      if available ub.dis-card then
      run ex-dc(input rs-list-method, input rs-status, input line-mode).
      {&assign-nums}.
    end.
  end.
  when "cli-grp" then do:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      {&get-rowid}  next.
      grp-path = "".
      find first ub.cli-grp no-lock where rowid(ub.cli-grp) = v-rowid.
      grp-path = ''.
      run cli-grplib-get-full-name in this-procedure (cli-grp.node-code, output grp-path).
      for each ub.clients no-lock where ub.clients.grp-name begins grp-path,
          each ub.dis-card no-lock where
                ub.dis-card.cli-type = ub.clients.obj-type
            AND ub.dis-card.cli-code = ub.clients.obj-code:
        run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
      end.
      {&assign-nums}.
    end. /*for each buf_*/
  end. /* when cli-grp*/
  when "cli" then do:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      {&get-rowid}  next.
      find first ub.clients no-lock where rowid(ub.clients) = v-rowid.
      for each ub.dis-card no-lock where
                ub.dis-card.cli-type = ub.clients.obj-type
            AND ub.dis-card.cli-code = ub.clients.obj-code:
        run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
      end.
      {&assign-nums}.
    end.
  end.
  when "global":U then do:
   find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
    for each ub.dis-card no-lock where ub.dis-card.emitent-host-code = 0:
      run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
    end.
    {&assign-nums}.
    end.
  when "company":U then do:
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
    for each ub.dis-card no-lock where ub.dis-card.emitent-host-code = p-curr-host-code:
      run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
    end.
    {&assign-nums}.
  end.
  when "type":U then do:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      {&get-rowid}  next.
      find ub.dis-card-type where
            rowid (ub.dis-card-type) = v-rowid no-lock.
      for each ub.dis-card where
                ub.dis-card.type = ub.dis-card-type.type no-lock:
          run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
      end.
      {&assign-nums}.
    END.
  end.
  when "person" then do:
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
    for each ub.clients where ub.clients.obj-type = {&prs} no-lock,
        each ub.dis-card where
            ub.dis-card.cli-type = ub.clients.obj-type AND
            ub.dis-card.cli-code = ub.clients.obj-code:
      run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
    end.
    {&assign-nums}.
  end.
  when "waybill" then do:
  for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
      and  buf_{1}-hist.item_ <> '':U:
    {&get-rowid}  next.
    find first ub.trn-doc no-lock where
              rowid(ub.trn-doc) = v-rowid no-error.
    if available ub.trn-doc then do:
      FIND FIRST ub.clients No-LOCK WHERE
                ub.clients.obj-type = ub.trn-doc.cli-type AND
                ub.clients.obj-code = ub.trn-doc.cli-code No-ERROR.
      if avail ub.clients then do:
        for each ub.dis-card No-LOCK WHERE
                ub.dis-card.cli-type = ub.clients.obj-type AND
                ub.dis-card.cli-code = ub.clients.obj-code:
          run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
        end.
      end.
    end.
    {&assign-nums}.
  end.
  end.
  when "stop-list" then do:
  for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
      and  buf_{1}-hist.item_ <> '':U:
    {&get-rowid}  next.
    find first buf_stop-list no-lock where
              rowid(buf_stop-list) = v-rowid no-error.
    if available buf_stop-list
    and buf_stop-list.classif-type = {&table_Dis-card}
    then do:
      for each buf_stop-list-line no-lock where
              buf_stop-list-line.classif-type = buf_stop-list.classif-type
          and buf_stop-list-line.stop-list-code = buf_stop-list.stop-list-code,
          first ub.dis-card no-lock where
                ub.dis-card.d-card = buf_stop-list-line.charkey_one:
          run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
      end.
    end.
    {&assign-nums}.
  end.
  end.
  when "inkas" then do:
  for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
      and  buf_{1}-hist.item_ <> '':U:
    {&get-rowid}  next.
    find first ub.inkas no-lock where
              rowid(ub.inkas) = v-rowid no-error.
    if available ub.inkas then do:
      for each ub.chk-doc no-lock where
              ub.chk-doc.out-code = ub.inkas.inkas-code and ub.chk-doc.d-card <> "":U,
        first ub.dis-card no-lock where ub.dis-card.d-card = ub.chk-doc.d-card:
        run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
      end.
    end. /*if availa inkas*/
    {&assign-nums}.
  end. /*for each buf_hist*/
  end.
  when "chk-doc" then do:
    for each buf_{1}-hist where
              buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      {&get-rowid}  next.
      find first ub.chk-doc no-lock where
                rowid(ub.chk-doc) = v-rowid no-error.
      if available ub.chk-doc then do:
        find first ub.dis-card no-lock where ub.dis-card.d-card = ub.chk-doc.d-card no-error .
        if available ub.dis-card then do:
          run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
        end.
      end. /*if availa chk-doc*/
      {&assign-nums}.
    end. /*for each buf_hist*/
  end.
  when "attr" or when "attr-val" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U no-error .
    assign
    v-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
    v-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
    v-attr-code = entry(3, buf_{1}-hist.item_, {&delim-key})
    vvalue = (if rs-list-method = "attr" then '':U else entry(4, buf_{1}-hist.item_, {&delim-key}))
    no-error
    .
    if error-status:error then do:
    end.
    else do:
      _attr:
      for each ub.clients-attr No-LOCK WHERE
                ub.clients-attr.attr-code = v-attr-code,
        each ub.dis-card no-lock where
            ub.dis-card.cli-type = ub.clients-attr.obj-type
        and ub.dis-card.cli-code = ub.clients-attr.obj-code:
        if rs-list-method = "attr-val" then do:
          run clntattr-value in this-procedure (input ub.clients-attr.obj-type,
                            input ub.clients-attr.obj-code,
                            input v-attr-code,
                            output vvalue1,
                            output vtype1).
          if vvalue1 <> vvalue then NEXT _attr.
        end. /*if rs-list-method = */
        run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
      end. /*for each clients-attr*/
      {&assign-nums}.
    end.
  end.
  when "dcp" or when "dcp-val" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U no-error .
    assign
    v-dtm-code = integer(entry(1, buf_{1}-hist.item_, {&delim-key}))
    v-dt-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
    v-node-code = integer(entry(3, buf_{1}-hist.item_, {&delim-key}))
    vvalue = (if rs-list-method = "dcp" then '':U else entry(4, buf_{1}-hist.item_, {&delim-key}))
    no-error
    .
    if error-status:error then do:
    end.
    else do:
      if rs-list-method = "dcp-val" then do:
        find first buf_prop-map no-lock where
                  buf_prop-map.dtm-code = v-dtm-code
              and buf_prop-map.node-code = v-node-code no-error.

      end.
      if rs-list-method = "dcp"
      or (rs-list-method = "dcp-val"
      and available buf_prop-map) then do:
      _attr:
        for each buf_dis-card-property No-LOCK WHERE
                  buf_dis-card-property.dtm-code = v-dtm-code
              and (v-dt-code = ? or buf_dis-card-property.dt-code = v-dt-code)
              and (v-node-code = ? or buf_dis-card-property.node-code = v-node-code),
          first ub.dis-card no-lock where
              ub.dis-card.d-card = buf_dis-card-property.d-card
          :
          if rs-list-method = "dcp-val" then do:
            case buf_prop-map.node-value-type:
              when {&abl-datatype-character} then do:
                  if buf_dis-card-property.property-value-character <> vvalue then next.
              end.
              when {&abl-datatype-date} then do:
                if buf_dis-card-property.property-value-date <> date(vvalue) then next.
              end.
              when {&abl-datatype-decimal} then do:
                if buf_dis-card-property.property-value-decimal <> decimal(vvalue) then next.
              end.
              when {&abl-datatype-integer} then do:
                if buf_dis-card-property.property-value-integer <> integer(vvalue) then next.
              end.
              when {&abl-datatype-character} then do:
                if buf_dis-card-property.property-value-logical <> logical(vvalue) then next.
              end.
            end case.
          end. /*if rs-list-method = */
          run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
        end. /*for each clients-attr*/
        {&assign-nums}.
      end.
    end. /*if es */
  end.
  when "general-sum-id"
  or
  when "partial-sum-id" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U no-error .
    assign
    v-dt-code = integer(entry(1, buf_{1}-hist.item_, {&delim-key}))
    v-host-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
    v-obj-type = entry(3, buf_{1}-hist.item_, {&delim-key})
    v-obj-code = integer(entry(4, buf_{1}-hist.item_, {&delim-key}))
    v-r-b = entry(5, buf_{1}-hist.item_, {&delim-key})
    v-field = entry(6, buf_{1}-hist.item_, {&delim-key})
    v-field = (if v-field = 'num-chk' then v-field else replace(v-field, {&r-b-rubl}, v-r-b))
    v-low = decimal(entry(7, buf_{1}-hist.item_, {&delim-key}))
    v-high = decimal(entry(8, buf_{1}-hist.item_, {&delim-key}))
    no-error
    .
    if error-status:error then do:
      message error-status:error error-status:get-message(1) view-as alert-box .
    end.
    else do:
      if v-obj-code = 0 then do:
        if v-host-code = 0 then do:
          _dh0:
          for each ub.dis-host no-lock where ub.dis-host.dt-code = v-dt-code
            break
            by ub.dis-host.d-card
            by ub.dis-host.dt-code
            by ub.dis-host.host-code :
            if first-of(ub.dis-host.d-card) then do:
              v-acc =0.
              v-next = no.
              if ub.dis-host.host-code = 0  then do:
                if buffer ub.dis-host:buffer-field(v-field):buffer-value >= v-low
                and buffer ub.dis-host:buffer-field(v-field):buffer-value <= v-high then do:
                    find first ub.dis-card no-lock where ub.dis-card.d-card = ub.dis-host.d-card.
                    run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
                end.
                v-next = yes.
              end.
            end. /*if first-of d-card*/
            if not v-next then do:
              v-acc = v-acc + buffer ub.dis-host:buffer-field(v-field):buffer-value.
            end.
            if last-of(ub.dis-host.d-card) then do:
              if v-next then do:
              end.
              else do:
                if v-acc >= v-low
                and v-acc <= v-high then do:
                    find first ub.dis-card no-lock where ub.dis-card.d-card = ub.dis-host.d-card.
                    run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
                end.
              end. /*not v-next*/
            end. /*if last-of dis-host.d-card*/
          end.
        end.
        _dh:
        for each ub.dis-host no-lock where
                ub.dis-host.host-code = v-host-code
             and ub.dis-host.dt-code = v-dt-code:
          if buffer ub.dis-host:buffer-field(v-field):buffer-value >= v-low
          and buffer ub.dis-host:buffer-field(v-field):buffer-value <= v-high then do:
              find first ub.dis-card no-lock where ub.dis-card.d-card = ub.dis-host.d-card.
              run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
          end.
        end.
      end.
      else do:
        _do:
        for each ub.dis-obj no-lock where
                ub.dis-obj.obj-type = v-obj-type
            and ub.dis-obj.obj-code = v-obj-code
            and ub.dis-obj.dt-code = v-dt-code :
          if buffer ub.dis-obj:buffer-field(v-field):buffer-value >= v-low
          and buffer ub.dis-obj:buffer-field(v-field):buffer-value <= v-high then do:
            find first ub.dis-card no-lock where ub.dis-card.d-card = ub.dis-obj.d-card.
             run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
          end.
        end.
      end.
      {&assign-nums}.
    end.
  end.
  when "last-change-general-sum-id"
  or
  when "last-change-partial-sum-id" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U no-error .
    assign
    v-dt-code= integer(entry(1, buf_{1}-hist.item_, {&delim-key}))
    v-host-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
    v-obj-type = entry(3, buf_{1}-hist.item_, {&delim-key})
    v-obj-code = integer(entry(4, buf_{1}-hist.item_, {&delim-key}))
    v-cond = entry(5, buf_{1}-hist.item_, {&delim-key})
    v-last-change-date = date(entry(6, buf_{1}-hist.item_, {&delim-key}))
    no-error
    .
    if error-status:error then do:
      message error-status:error error-status:get-message(1) view-as alert-box .
    end.
    else do:
      if v-obj-code = 0 then do:
        if v-host-code = 0 then do:
          _dh0:
          for each ub.dis-host no-lock where
                  ub.dis-host.dt-code = v-dt-code
            break
            by ub.dis-host.d-card
            by ub.dis-host.dt-code
            by ub.dis-host.host-code :
            if first-of(ub.dis-host.d-card) then do:
              v-next = no.
              if ub.dis-host.host-code = 0  then do:
                find last ub.c-dis-host no-lock where
                          ub.c-dis-host.d-card = ub.dis-host.d-card
                      and ub.c-dis-host.dt-code = ub.dis-host.dt-code
                      and ub.c-dis-host.host-code = ub.dis-host.host-code
                      and ub.c-dis-host.corr-user-db-num = 0 no-error.
                if not available ub.c-dis-host then next _dh0.
                if (v-cond = '=' and ub.c-dis-host.corr-date = v-last-change-date)
                or (v-cond = '>=' and ub.c-dis-host.corr-date >= v-last-change-date)
                or (v-cond = '<=' and ub.c-dis-host.corr-date <= v-last-change-date)
                or (v-cond = '>' and ub.c-dis-host.corr-date > v-last-change-date)
                or (v-cond = '<' and ub.c-dis-host.corr-date < v-last-change-date)  then do:
                  find first ub.dis-card no-lock where ub.dis-card.d-card = ub.dis-host.d-card.
                  run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
                  v-next = yes.
                end.
              end.
            end. /*if first-of d-card*/
            if last-of(dis-host.d-card) then do:
              if v-next then do:
              end.
              else do:
                find last ub.c-dis-host no-lock where
                          ub.c-dis-host.d-card = dis-host.d-card
                      and ub.c-dis-host.dt-code = dis-host.dt-code
                      and ub.c-dis-host.host-code = dis-host.host-code
                      and ub.c-dis-host.corr-user-db-num = 0 no-error.
                if not available ub.c-dis-host then next _dh0.
                if (v-cond = '=' and ub.c-dis-host.corr-date = v-last-change-date)
                or (v-cond = '>=' and ub.c-dis-host.corr-date >= v-last-change-date)
                or (v-cond = '<=' and ub.c-dis-host.corr-date <= v-last-change-date)
                or (v-cond = '>' and ub.c-dis-host.corr-date > v-last-change-date)
                or (v-cond = '<' and ub.c-dis-host.corr-date < v-last-change-date)  then do:
                  find first ub.dis-card no-lock where ub.dis-card.d-card = ub.dis-host.d-card.
                  run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
                  v-next = yes.
                end.
              end. /*not v-next*/
            end. /*if last-of dis-host.d-card*/
          end.
        end.
        _dh:
        for each ub.dis-host no-lock where
                ub.dis-host.host-code = v-host-code
            and ub.dis-host.dt-code = v-dt-code:
          find last ub.c-dis-host no-lock where
                    ub.c-dis-host.d-card = dis-host.d-card
                and ub.c-dis-host.dt-code = dis-host.dt-code
                and ub.c-dis-host.host-code = dis-host.host-code
                and ub.c-dis-host.corr-user-db-num = 0 no-error.
          if not available ub.c-dis-host then next _dh.
          if (v-cond = '=' and ub.c-dis-host.corr-date = v-last-change-date)
          or (v-cond = '>=' and ub.c-dis-host.corr-date >= v-last-change-date)
          or (v-cond = '<=' and ub.c-dis-host.corr-date <= v-last-change-date)
          or (v-cond = '>' and ub.c-dis-host.corr-date > v-last-change-date)
          or (v-cond = '<' and ub.c-dis-host.corr-date < v-last-change-date)  then do:
            find first ub.dis-card no-lock where ub.dis-card.d-card = ub.dis-host.d-card.
            run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
            v-next = yes.
          end.
        end.
      end.
      else do:
        _do:
        for each ub.dis-obj no-lock where
                ub.dis-obj.obj-type = v-obj-type
            and ub.dis-obj.obj-code = v-obj-code
            and ub.dis-obj.dt-code = v-dt-code,
            first ub.clients no-lock where
                 ub.clients.obj-type = ub.dis-obj.obj-type
             and ub.clients.obj-code = ub.dis-obj.obj-code:
          find last ub.c-dis-obj no-lock where
                    ub.c-dis-obj.d-card = ub.dis-obj.d-card
                and ub.c-dis-obj.dt-code = ub.dis-obj.dt-code
                and ub.c-dis-obj.obj-type = ub.dis-obj.obj-type
                and ub.c-dis-obj.obj-code = ub.dis-obj.obj-code
                and ub.c-dis-obj.corr-user-db-num = ub.clients.db-num no-error.
          if not available ub.c-dis-obj then next _do.
          if (v-cond = '=' and ub.c-dis-obj.corr-date = v-last-change-date)
          or (v-cond = '>=' and ub.c-dis-obj.corr-date >= v-last-change-date)
          or (v-cond = '<=' and ub.c-dis-obj.corr-date <= v-last-change-date)
          or (v-cond = '>' and ub.c-dis-obj.corr-date > v-last-change-date)
          or (v-cond = '<' and ub.c-dis-obj.corr-date < v-last-change-date)  then do:
            find first ub.dis-card no-lock where ub.dis-card.d-card = ub.dis-obj.d-card.
             run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
          end.
        end.
      end.
      {&assign-nums}.
    end.
  end.

  when "cli-list"
  or
  when "doc-list"
  or
  when "chk-list"
  or
  when "file"
  or
  when "clob-data"
  then do:
    run proc-file-list-methods in this-procedure(input p-from-macro, input rs-list-method, input rs-status, input line-mode, input p-id). .
  end.
  when "deleted" then do:
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
    for each ub.dis-card where ub.dis-card.status_ = {&deleted-status} no-lock:
      run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
    end.
  end.
  when "filter" then do:
    define variable v-filter-var as character no-undo .
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U .

    run proc-write-filter-expression-var in this-procedure ( input buf_{1}-hist.item_ , output v-filter-var ).
    run gbl/dc-fill.p (
                     input "Формирование списка по фильтру (без учета сортировки)"
                   , input rs-list-method
                   , input rs-status
                   , input line-mode
                   , input v-filter-var
                   , output lns-cnt
                   , output line-rec
                   )  .
     {&assign-nums}.
  end.
  when "all" then do:
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
    for each ub.dis-card no-lock:
      run ex-dc in this-procedure (input rs-list-method, input rs-status, input line-mode).
    end.
    {&assign-nums}.
  end.
END CASE.
dsp-rs:fgcolor in frame {&frame-name} = 4.
if session:set-wait-state( "" )  then .
case line-mode :
  when {&add-def} then do:
    tot-lns = tot-lns + lns-cnt.
    &if "{2}" <> "pre-macro" &then
    if not p-from-macro or p-step then
    message
    "Добавлено строк :" lns-cnt skip(0)
    string(if lns-ignore <> 0
    then ("Проигнорировано строк :" + string(lns-ignore))
    else "":U)
    .
    &endif
  end.
  when {&deletion} then do:
    tot-lns = tot-lns - lns-cnt.
    &if "{2}" <> "pre-macro" &then
    if not p-from-macro or p-step then
    message
    "Удалено строк :" lns-cnt skip(0)
    string(if lns-ignore <> 0
    then ("Проигнорировано строк :" + string(lns-ignore))
    else "":U)
    .
    &endif
  end.
end.
if line-mode <> {&leave} then
  run Myenable in this-procedure .
end. /*doe*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE trig-attr Dialog-Frame
PROCEDURE trig-attr :
define input parameter rs-list-method as character no-undo .
DEFINE VARIABLE vattr-codes          as character           no-undo.
DEFINE VARIABLE vattr-labels         as character           no-undo.
DEFINE VARIABLE vtooltip             as character           no-undo.
DEFINE VARIABLE vlabel               as character           no-undo .
DEFINE VARIABLE vtype                as character           no-undo .
DEFINE VARIABLE vformat              as character           no-undo .
DEFINE VARIABLE vuser-can-edit       as logical             no-undo .
DEFINE VARIABLE voutput-display      as logical             no-undo .
define variable v-range              as integer             no-undo .
DEFINE VARIABLE vother               as character           no-undo .
DEFINE VARIABLE v-ref-list           as character           no-undo .
DEFINE VARIABLE jj                   as integer             no-undo .
DEFINE VARIABLE v-spr                as character           no-undo .
DEFINE VARIABLE v-spr-param          as character           no-undo .
DEFINE VARIABLE v-setted             as logical             no-undo .
define variable v-init               as character           no-undo .
define variable ii as integer no-undo.
define variable v-item               as character           no-undo .
define variable glog                 as logical no-undo .
DEFINE VARIABLE v-attr-code          as character           no-undo .
assign
vattr-codes = ""
vattr-labels = "".
_ii:
DO ii = 1 to num-entries({&clntattr-list-to-dc-list}):
    if rs-list-method = "attr" or rs-list-method  = "attr-val" then do:
       run clntattr-code in this-procedure (input entry(ii, {&clntattr-list-to-dc-list}),
                       output vtype,
                        output vformat,
                        output vlabel,
                        output vuser-can-edit,
                        output voutput-display,
                        output vother) no-error.
    end.
    if NOT error-status:error anD VOUTPUT-DISPLAY = yes then do:
      if rs-list-method = "attr-val"
      and (lookup('compl=yes', vother, {&slash-char}) > 0
           or
           lookup('compl=true', vother, {&slash-char}) > 0) then next _ii.
      assign
      vattr-codes = vattr-codes + {&comma-char} + entry(ii, {&clntattr-list-to-dc-list})
      vattr-labels = vattr-labels + {&comma-char} + vlabel
      .
    end.
end.

run gbl/d-list.w ("b-sel":U,
            "Выберите атрибут",
             vattr-codes,
             vattr-labels,
             {&comma-char},
             "":U,
             output v-attr-code).

if v-attr-code = "" then do:
  return error.
end.

glog = yes.
if rs-list-method = "attr" then do:
    run clntattr-tooltip in this-procedure (input v-attr-code,
                         output vtooltip,
                         output vlabel).
    message
    "Карты клиентов с установленным атрибутом " + vlabel
     view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      return error.
    end.
    assign
    dsp-rs = substitute("Карты c установленным атрибутом &1: &2", vlabel, stat-line(rs-status))
    v-item = '':U + {&delim-key} + '':U + {&delim-key} + v-attr-code
    .
end.
if rs-list-method = "attr-val" then do:
    run clntattr-code in this-procedure (input v-attr-code,
                         output vtype,
                         output vformat,
                         output vlabel,
                         output vuser-can-edit,
                         output voutput-display,
                         output vother).
    run gbl/d-prompt.w (
      'title=':u + "Значение атрибута клиента" + '\':u
    + 'text1=':u + vlabel + '\':u
    + 'format=' + (if vtype = {&type-log} then "yes/no" else vformat) + '\':u
    + 'type=' + vtype + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=no\':u
    , input-output vvalue
    ).
    if return-value = 'false':U then do:
      return error.
    end.
    message ("Карты клиентов с атрибутом " + vlabel + " = ":U + vvalue)
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      return error.
    end.
    assign
    dsp-rs = substitute("Карты клиентов с атрибутом &1 =&2 &3", vlabel, vvalue, stat-line(rs-status))
    v-item = '':U + {&delim-key} + '':U + {&delim-key} + v-attr-code + {&delim-key} + vvalue
    .
end.
v-no-hist = 0.
run create-{1}-hist in this-procedure(input {&add-def}
                                    , input-output v-seq
                                    , input 0
                                    , input '':U
                                    , input dsp-rs
                                    , input tot-lns
                                    , input rs-list-method
                                    , input rs-status
                                    , input v-item
                                    , input '':U
                                    , input ?
                                    ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE trig-dcp Dialog-Frame
PROCEDURE trig-dcp :
define input parameter rs-list-method as character no-undo .
define variable v-dtm-code as integer no-undo init ?.
define variable v-dt-code as integer no-undo init ?.
define variable v-node-code as integer no-undo init ?.
define variable v-host-code as integer no-undo init 0.
define variable v-obj-type as integer no-undo init '':U.
define variable v-obj-code as integer no-undo init 0.
define variable v-cond as character no-undo .
define variable glog as logical no-undo .
define variable v-tool-tip as character no-undo .
define variable v-value as character no-undo .
define variable v-label as character no-undo .
define variable v-sum-id as character no-undo .
define variable v-item as character no-undo .
define variable v-value-character-low as character no-undo .
define variable v-value-date-low as date no-undo .
define variable v-value-decimal-low as decimal no-undo .
define variable v-value-integer-low as integer no-undo .
define variable v-value-logical-low as logical no-undo .
define variable v-value-character-high as character no-undo .
define variable v-value-date-high as date no-undo .
define variable v-value-decimal-high as decimal no-undo .
define variable v-value-integer-high as integer no-undo .
define variable v-value-logical-high as logical no-undo .
define variable v-ok as logical no-undo .
run ref/dcprpsel.w (
                     input parparentproc
                    ,input p-curr-host-code
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input-output v-dtm-code
                    ,input-output v-dt-code
                    ,input-output v-node-code
                    ,input-output v-host-code
                    ,input-output v-obj-type
                    ,input-output v-obj-code
                    ,input-output v-cond
                    ,output v-value-character-low
                    ,output v-value-character-high
                    ,output v-value-date-low
                    ,output v-value-date-high
                    ,output v-value-decimal-low
                    ,output v-value-decimal-high
                    ,output v-value-integer-low
                    ,output v-value-integer-high
                    ,output v-value-logical-low
                    ,output v-value-logical-high
                    ,output v-ok
                    ) no-error.
if error-status:error
or v-dtm-code = ?
or not v-ok
then undo, return error .
run discprop-node-name in this-procedure ( input (string(v-dtm-code) + {&delim-par} + (if v-node-code <> ? then string(v-node-code) else ''))
                                          ,output v-tool-tip
                                          ,output v-label).
if rs-list-method = "dcp" then do:
  message
  substitute("Карты, имеющие &1 &2"
             ,v-label
             ,(if v-dt-code <> ?
               then substitute(" Срез &1", v-sum-id)
               else '':U)
            )
  view-as alert-box question buttons OK-Cancel update glog.
  if not glog then do:
    return error.
  end.
  assign
  dsp-rs = substitute("Карты, имеющие &1 &2: &3"
                      , v-label
                      ,(if v-dt-code <> ?
                        then substitute(" Срез &1", v-sum-id)
                        else '':U)
                      , stat-line(rs-status))
  v-item = substitute("&2&1&3&1&4"
                      , {&delim-key}
                      , v-dtm-code
                      , v-dt-code
                      , v-node-code)
  .
end.
if rs-list-method = "dcp-val" then do:
  message
  substitute("Карты, имеющие &1 &2 = &3"
             ,v-label
             ,(if v-dt-code <> ?
               then substitute(" Срез &1", v-sum-id)
               else '':U)
            , v-value
            )
  view-as alert-box question buttons OK-Cancel update glog.
  if not glog then do:
    return error.
  end.

  assign
  dsp-rs = substitute("Карты, имеющие &1 &2 = &3: &4"
                      , v-label
                      ,(if v-dt-code <> ?
                        then substitute(" Срез &1", v-sum-id)
                        else '':U)
                      , v-value
                      , stat-line(rs-status))
  v-item = substitute("&2&1&3&1&4&1&5"
                      , {&delim-key}
                      , v-dtm-code
                      , v-dt-code
                      , v-node-code)
  .
end.
v-no-hist = 0.
run create-{1}-hist in this-procedure(input {&add-def}
                                    , input-output v-seq
                                    , input 0
                                    , input '':U
                                    , input dsp-rs
                                    , input tot-lns
                                    , input rs-list-method
                                    , input rs-status
                                    , input v-item
                                    , input '':U
                                    , input ?
                                    ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sum-id Dialog-Frame
PROCEDURE proc-sum-id :
define input parameter rs-list-method as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-obj-type  like ub.clients.obj-type no-undo .
define variable v-obj-code  like ub.clients.obj-code no-undo .
define variable v-dt-code    as integer no-undo .
define variable v-get-r-b as character no-undo .
define variable v-field as character no-undo .
define variable v-field-des as character no-undo .
define variable v-low as decimal no-undo .
define variable v-high as decimal no-undo .
define variable v-ok as logical no-undo .
define variable v-sum-id-type as character no-undo .
define variable v-item as character no-undo .
define variable v-cond as character no-undo init '>':U.
define variable v-last-change-date as date no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

v-sum-id-type = replace(rs-list-method, 'last-change-', '':U).
run cur-time in this-procedure ( output v-today, output v-time).
v-last-change-date = v-today - 2.


run ref/dcsumid.w (
                   input parparentproc
                  ,input this-procedure:handle
                  ,input (if rs-list-method begins "last-change" then 'last-change' else 'current-values') /*p-mode*/
                  ,input-output v-sum-id-type
                  ,input-output v-dt-code
                  ,input-output v-host-code /*p-host-code*/
                  ,input-output v-obj-type /*p-obj-type*/
                  ,input-output v-obj-code /*p-obj-code*/
                  ,input-output v-get-r-b
                  ,input-output v-field
                  ,input-output v-cond
                  ,input-output v-last-change-date
                  ,output v-field-des
                  ,output v-low
                  ,output v-high
                  ,output v-ok
                  ).

if not v-ok then return error.
if rs-list-method begins 'last' then do:
  assign
  dsp-rs = substitute("&1 &2 &3 &4 &5 &6 &7 "
                      ,(if v-sum-id-type = 'general-sum-id':U
                        then 'Общие итоги по карте'
                        else 'Частные итоги по карте')
                      , (if v-sum-id-type = 'general-sum-id':U
                          then '':U
                          else dct-algo-get-description-sum-id(v-dt-code) )
                      , (if v-host-code = 0
                          then 'Глобальные'
                          else substitute('Фирма &1', v-host-code))
                        , (if v-obj-code = 0 then '':u else substitute("&1&2", v-obj-type, v-obj-code))
                        , v-field-des
                        , v-cond
                        , v-last-change-date)
  v-item = string(v-dt-code) + {&delim-key} +
          string(v-host-code) + {&delim-key} +
          v-obj-type + {&delim-key} +
          string(v-obj-code) + {&delim-key} +
          v-cond + {&delim-key} +
          string(v-last-change-date, "99/99/9999")
          .
end.
else do:
  assign
  dsp-rs = substitute("&1 &2 &3 &4 &5 = &6 - &7 "
                      ,(if v-sum-id-type = 'general-sum-id':U
                        then 'Общие итоги по карте'
                        else 'Частные итоги по карте')
                      , (if v-sum-id-type = 'general-sum-id':U
                          then '':U
                          else dct-algo-get-description-sum-id(v-dt-code) )
                      , (if v-host-code = 0
                          then 'Глобальные'
                          else substitute('Фирма &1', v-host-code))
                        , (if v-obj-code = 0 then '':u else substitute("&1&2", v-obj-type, v-obj-code))
                        , v-field-des
                        , v-low
                        , v-high)
  v-item = string(v-dt-code) + {&delim-key} +
          string(v-host-code) + {&delim-key} +
          v-obj-type + {&delim-key} +
          string(v-obj-code) + {&delim-key} +
          v-get-r-b + {&delim-key} +
          v-field + {&delim-key} +
          string(v-low) + {&delim-key} +
          string(v-high).
end.
v-no-hist = 0.
run create-{1}-hist in this-procedure (
                                      input {&add-def}
                                    , input-output v-seq
                                    , input 0
                                    , input '':U
                                    , input dsp-rs
                                    , input tot-lns
                                    , input rs-list-method
                                    , input rs-status
                                    , input v-item
                                    , input '':U
                                    , input ?
                                    ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE trig-filter Dialog-Frame
PROCEDURE trig-filter :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable glog as logical no-undo .
define variable v-flt-rec as recid no-undo .
define variable v-filter-name as character no-undo .
define variable where-phrase as character no-undo .
define variable sort-phrase as character no-undo .
define variable where-phrase-rus as character no-undo .
define variable sort-phrase-rus as character no-undo .

glog = yes.
message
"Все карты выбранные в соответствии с заданным фильтром (без учета сортировки)."
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
assign
c-point = "dc-list":U + {&delim-par} + "Список дисконтных карт" + {&delim-par} + "no"
.

assign
tbl = 'dis-card'
join-tbl = ''
fld = ""
lab = ""
spr = ""
dim = '0'
.

run fltfield-add in this-procedure('cli-type{&delim-flt}cli-code', 'Клиент(один)', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-type', 'Тип клиента', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-code', 'Код клиента', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('d-card', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('d-pcnt', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('category', 'Категория', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('emitent-host-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('issue-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('issue-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('valid-date', 'Действ.до', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('type', 'Тип карты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('credit-card', 'Кредитная', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sourced-card', 'К карте', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('saldo-rubl', 'Сальдо {&abbr_rubli}', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('saldo-base', 'Сальдо баз_вал', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('main-card', 'Основная', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-subsid', 'Дополнительная', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('first-card', 'Первичная', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('first-main-card', 'Первичная основная', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sourced-card', 'Перевыпущена к', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('overissue-num', 'Порядок в цепочке перевыпуска', '',
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
  run MyENable in this-procedure .
  return error.
end.
else do:
  find ubflt.filter where recid (ubflt.filter) = v-flt-rec no-lock.
  run create-{1}-hist in this-procedure(input {&add-def}
                                      , input-output v-seq
                                      , input 0
                                      , input '':U
                                      , input substitute("Фильтр : &1 &2 &3", ubflt.filter.naim, ubflt.filter.where-ysl-rus, stat-line(rs-status))
                                      , input tot-lns
                                      , input rs-list-method
                                      , input rs-status
                                      , input ubflt.filter.where-ysl
                                      , input '':U
                                      , input ?
                                      ).
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-hist Dialog-Frame
PROCEDURE write-hist :
define input parameter p-from-macro as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define variable v-ii as integer no-undo .
define variable v-temp-seq as integer no-undo .
/* запись истории формирования списка */
if rs-list-method = "single" then do:
  if v-no-hist < 0 then do:
    run create-{1}-hist in this-procedure(input {&add-def}
                                        , input-output v-seq
                                        , input 0
                                        , input get-hist-mode(line-mode)
                                        , input substitute("КАРТА &1 &2&3", {1}.d-card, {1}.cli-type, {1}.cli-code)
                                        , input tot-lns
                                        , input rs-list-method
                                        , input rs-status
                                        , input ('dis-card':U + {&delim-key} + string({1}.d-card))
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
                                          , input substitute("КАРТА &1 &2&3", {1}.d-card, {1}.cli-type, {1}.cli-code)
                                          , input tot-lns
                                          , input '':U
                                          , input '':U
                                          , input ('dis-card':U + {&delim-key} + string({1}.d-card))
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-num-chk Dialog-Frame
FUNCTION get-num-chk RETURNS CHARACTER
  ( buffer loc-dis-card for {1} ) :
DEFINE VARIABLE var-cli-name as character no-undo .
define buffer loc-clients for ub.clients.

FIND loc-clients WHERE
     loc-clients.obj-type = loc-dis-card.cli-type AND
     loc-clients.obj-code = loc-dis-card.cli-code NO-LOCK .
if avail loc-clients then
var-cli-name = loc-clients.obj-name .

RETURN var-cli-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION stat-line Dialog-Frame
FUNCTION stat-line RETURNS CHARACTER
  ( input p-status-chr as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
 /*функция возвращает строку для message и для dsp-rs*/
DEFINE VARIABLE var-stat-line as character no-undo .

CASE p-status-chr:
  when {&all} then do:
    assign
    var-stat-line = "(текущие, удаленные и блокированные карты)"
    .
  end.
  when {&current-status} then do:
    assign
    var-stat-line = "(текущие карты)"
    .
  end.
  when {&deleted-status} then do:
    assign
    var-stat-line = "(удаленные карты)"
    .
  end.
  when {&blocked-status} then do:
    assign
    var-stat-line = "(блокированные карты)"
    .
  end.
END CASE.


return var-stat-line .


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME