&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
/* DEFINE SHARED TEMP-TABLE cli-list NO-UNDO LIKE ub.clients */
/*  field to-del as logical                                  */
/*  index obj  is primary unique obj-type obj-code           */
/*  index cli-name      obj-name.                            */
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

Автоматизированное формирование списка клиентов

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
define variable vss-description as character no-undo init "Автоматизированное формирование списка клиентов".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/cli-list.i {1} def SHARED }
{ gbl/getcntxt.i def }
define variable g#report-num as integer no-undo .
{ str/listhprc.i {1}  }
{ gbl/flt-def.i }
{ cmp/operlist.i }
{ gbl/clntattr.i }
{ gbl/fltfield.i }
{ gbl/prn-lib.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i  new }
{ ref/cgrplbfn.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ gbl/gbclcode.i }
{ gbl/key-rec.i }
&glob ui-on MyEnable

define buffer l-{1} for {1}.
define variable f-name as char init "default.cli" no-undo.
define variable grp-list as char no-undo.
define variable ref-list as char no-undo.
define variable v-input-output as character no-undo .
define variable num-rec as integer init 0 no-undo.
define variable tot-lns as integer init ? no-undo.
define stream sout.
define variable CLI-REC AS RECID NO-UNDO.
DEFine VARiable RS-list-method AS CHARACTER.
define variable v-seq as integer no-undo .
define variable v-no-hist as integer no-undo init -1.
define variable lns-ignore as integer no-undo .
define variable v-num-add          as integer no-undo .
define variable v-num-ignored      as integer no-undo .
define variable vvalue as character no-undo.
define variable vtype1 as character no-undo.
define variable vvalue1 as character no-undo.
define variable save-option as character no-undo.
define variable print-option as character no-undo.
define variable macro-play-option as character no-undo .
define variable v-docs-all as logical no-undo .
define variable v-docs-cmp as logical no-undo .


define variable lns-cnt as integer no-undo .
define variable ref-rec as recid no-undo .


define variable line-mode as character no-undo .
define variable line-rec as recid no-undo .
/*
define variable list-mode as character no-undo .

*/

&if "{1}" <> "cli-list" &then
&message anyclist.i можно вызывать только для таблицы cli-list
&endif



&scop  disp-hot-fields   if avail {1} then do: ~
    assign ed-notes = {1}.ps. ~
    display ed-notes ~
     tot-lns @ f-tot-lns ~
    with frame ~{&frame-name~}. ~
  end. ~
  else do: ~
    assign ed-notes = ''. ~
    display ed-notes ~
     tot-lns @ f-tot-lns ~
    with frame ~{&frame-name~}. ~
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

{ cmp/listhist.i macro-list "new shared" }

{ ref/t-l-b.i }

&scop all-options                                     ~
"Текущая строка,single,                              ~
Клиент,cli,                                          ~
Группа клиентов,cli-grp,                             ~
Группа покупателей,grp-buy,                          ~
Оборот покупателя с - по,turnov-buy,                 ~
Все производители,prod,                              ~
Все поставщики товаров,sup-gds,                      ~
Все консигнанты,sup-cons,                            ~
Все покупатели товаров,buy-gds,                      ~
Все покупатели конс. товаров,buy-cons,               ~
Все покупатели услуг,buy-serv,                       ~
Все влад-цы диск.карт,dis-card,                      ~
Все кассиры,cashiers,                                ~
Все продавцы,sellers,                                ~
Все  организации,firm,                               ~
Все физ.лица,person,                                 ~
Все магазины,shop,                                   ~
Все склады,store,                                    ~
Контрагенты по док-там,waybill,                      ~
С установл. атрибутом,attr,                          ~
С атрибутом = ,attr-val,                             ~
Произ-ли товаров списка,gds-list,                    ~
Контрагенты док-тов списка,doc-list,                 ~
Удаленные,deleted,                                   ~
Файл,file,                                           ~
Хранимый в БД список,clob-data,                        ~
Фильтр,filter,                                       ~
Все клиенты,all"

&glob no-browser-option '':U

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
&Scoped-define INTERNAL-TABLES {1}  temp-list

/* Definitions for BROWSE BR-list                                       */
&Scoped-define FIELDS-IN-QUERY-BR-list {1}.obj-type {1}.obj-code ~
IF ({1}.stts = 0) THEN ({1}.obj-name) ELSE (substring ({1}.obj-name, 1, 25) +       FILL({&space-char}, 25 -       LENGTH(substring ({1}.obj-name, 1, 25)) ) +       {&deleted-stat_}) ~
{1}.grp-name {1}.is-prod {1}.sup-gds {1}.sup-cons ~
{1}.buy-gds {1}.buy-cons {1}.buy-serv ~
is-dis-cardc({1}.obj-type, {1}.obj-code) ~
is-cashierc({1}.obj-type, {1}.obj-code) {1}.db-num ~
is-sellerc({1}.obj-type, {1}.obj-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-list
&Scoped-define FIELD-PAIRS-IN-QUERY-BR-list
&Scoped-define OPEN-QUERY-BR-list OPEN QUERY BR-list FOR EACH {1} NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-list {1}
&Scoped-define FIRST-TABLE-IN-QUERY-BR-list {1}


/* Definitions for BROWSE BR-option                                     */
&Scoped-define FIELDS-IN-QUERY-BR-option temp-list.fname
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-option
&Scoped-define FIELD-PAIRS-IN-QUERY-br-option
&Scoped-define SELF-NAME BR-option
&Scoped-define OPEN-QUERY-br-option open query br-option for each temp-list no-lock .
&Scoped-define TABLES-IN-QUERY-BR-option temp-list
&Scoped-define FIRST-TABLE-IN-QUERY-BR-option temp-list

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-list} ~
    ~{&OPEN-QUERY-BR-option}

&Scoped-Define ENABLED-OBJECTS dsp-rs B-exit B-save B-print ~
B-hist B-lkp B-clr B-Help B-add B-del B-rest B-macro B-stop B-clear-macro ~
B-record NameOrCode n-c RS-Status BR-list BR-option ed-notes f-tot-lns
&Scoped-Define DISPLAYED-OBJECTS dsp-rs NameOrCode n-c ~
RS-Status f-tot-lns ed-notes

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD is-cashierc Dialog-Frame
FUNCTION is-cashierc RETURNS CHARACTER
( input loc-type as character, input loc-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD is-dis-cardc Dialog-Frame
FUNCTION is-dis-cardc RETURNS CHARACTER
( input loc-type as character, input loc-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD is-sellerc Dialog-Frame
FUNCTION is-sellerc RETURNS CHARACTER
( input loc-type as character, input loc-code as integer )  FORWARD.

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
DEFINE MENU MENU-B-save
       MENU-ITEM m_cli-save     LABEL "Файл списка клиентов"
       MENU-ITEM m_xls-save     LABEL "Таблица EXCEL"
       MENU-ITEM m-title-save   LABEL "Имя списка"
       MENU-ITEM m-macros-save  LABEL "Макрос формирования списка"
       MENU-ITEM m_cli-save-db  LABEL "Хранимый в БД список клиентов"
       MENU-ITEM m-macros-save-db   LABEL "Хранимый в БД макрос формирования списка"
       RULE
       MENU-ITEM m-rum           LABEL "Операции над списком"
       .

DEFINE MENU m-play
      MENU-ITEM m-macro-file    LABEL "Сохраненный в файле макрос формирования списка клиентов"
      MENU-ITEM m-macro-lob     LABEL "Сохраненный в БД макрос формирования списка клиентов"
      .

DEFINE MENU MENU-B-print
       MENU-ITEM m_main-print    LABEL  "Простой формат"
       MENU-ITEM m_sel-print     LABEL  "Выбор   полей"
       MENU-ITEM m_art-print     LABEL  "Печать артикулов поставщика".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&+Доб. строку"
     SIZE 20 BY 1 TOOLTIP "Добавить в список клиентов 1 строку".

DEFINE BUTTON B-clear-macro
     IMAGE-UP FILE "cmp/fstop.bmp":U
     IMAGE-DOWN FILE "cmp/fstopi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/fstopi.bmp":U
     LABEL "&[ ]"
     SIZE 4 BY 1.25 TOOLTIP "Удаление макроса формирования истории из памяти".

DEFINE BUTTON B-clr
     LABEL "Очи&стить"
     SIZE 10 BY 1 TOOLTIP "Удалить из списка всех клиентов".

DEFINE BUTTON B-del
     LABEL "&-Удал. строку"
     SIZE 20 BY 1 TOOLTIP "Удаленить из списка клиентов текукую строку".

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1 TOOLTIP "Выход из списка клиентов (передача списка другой программе)"
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
     SIZE 10 BY 1 TOOLTIP "Просмотр описания текущего клиента".

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
     LABEL "&Оставить"
     SIZE 20 BY 1 TOOLTIP "Оставить в списке только текущую строку".

DEFINE BUTTON B-save
     LABEL "Со&хр/Вып."
     SIZE 10 BY 1 TOOLTIP "Сохр. список клиентов в текст.файле, EXCEL; операции над списком".

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

DEFINE VARIABLE n-c AS CHARACTER INITIAL "1"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Название", "1",
"Код", "2"
     SIZE 23 BY .79 NO-UNDO.

DEFINE VARIABLE RS-Status AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 36.13 BY .75 NO-UNDO.

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
  QUERY BR-list NO-LOCK DISPLAY
      {1}.obj-type
      {1}.obj-code
      IF ({1}.stts = 0) THEN ({1}.obj-name)
ELSE (substring ({1}.obj-name, 1, 25) +
      FILL({&space-char}, 25 -
      LENGTH(substring ({1}.obj-name, 1, 25)) ) +       {&deleted-stat_}) COLUMN-LABEL "Название" FORMAT "x(40)"
      {1}.grp-name FORMAT "X(60)"
      {1}.is-prod COLUMN-LABEL "Пр-ль" FORMAT "+/"
      {1}.sup-gds COLUMN-LABEL "Пост-к/т" FORMAT "+/"
      {1}.sup-cons COLUMN-LABEL "Пост-к/к" FORMAT "+/"
      {1}.buy-gds COLUMN-LABEL "Пок-ль/т" FORMAT "+/"
      {1}.buy-cons COLUMN-LABEL "Пок-ль/к" FORMAT "+/"
      {1}.buy-serv COLUMN-LABEL "Пок-ль/у" FORMAT "+/"
      is-dis-cardc({1}.obj-type, {1}.obj-code) COLUMN-LABEL "Дисконтная карта" FORMAT "X(16)"
      is-cashierc({1}.obj-type, {1}.obj-code) COLUMN-LABEL "Кассир" FORMAT "X(6)"
      {1}.db-num
      is-sellerc({1}.obj-type, {1}.obj-code) COLUMN-LABEL "Прод-ц" FORMAT "X(6)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 79 BY 15.13.


DEFINE BROWSE BR-option
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-option Dialog-Frame _FREEFORM
  QUERY br-option DISPLAY
      temp-list.fname format "X(40)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-LABELS NO-ROW-MARKERS SEPARATORS SIZE 29 BY 21 TOOLTIP "Условие для выбора клиентов, которые будут добавлены/удалены/оставле".

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     dsp-rs AT ROW 1 COL 1 NO-LABEL
     br-option AT ROW 2 COL 80
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
     RS-Status AT ROW 5 COL 3.25 NO-LABEL
     f-tot-lns AT ROW 5 COL 66 COLON-ALIGNED NO-LABEL
     BR-list AT ROW 6 COL 1.13
     ed-notes AT ROW 21.38 COL 1 NO-LABEL
     SPACE(23.00) SKIP(0.15)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список клиентов"
         DEFAULT-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: {1} T "SHARED" NO-UNDO ub clients
      ADDITIONAL-FIELDS:
          field to-del as logical
          index obj  is primary unique obj-type obj-code
          index cli-name obj-name
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
/* BROWSE-TAB BR-option 1 Dialog-Frame */
/* BROWSE-TAB BR-list RS-Status Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-save:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-save:HANDLE.

ASSIGN
       B-macro:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-play:HANDLE.

ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-print:HANDLE.

/* SETTINGS FOR FILL-IN dsp-rs IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       ed-notes:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-list
/* Query rebuild information for BROWSE BR-list
     _TblList          = "Temp-Tables.{1}"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   = Temp-Tables.{1}.obj-type
     _FldNameList[2]   = Temp-Tables.{1}.obj-code
     _FldNameList[3]   > "_<CALC>"
"IF ({1}.stts = 0) THEN ({1}.obj-name)
ELSE (substring ({1}.obj-name, 1, 25) +
      FILL({&space-char}, 25 -
      LENGTH(substring ({1}.obj-name, 1, 25)) ) +       {&deleted-stat_})" "Название" "x(40)" ? ? ? ? ? ? ? no ?
     _FldNameList[4]   > Temp-Tables.{1}.grp-name
"{1}.grp-name" ? "X(60)" "character" ? ? ? ? ? ? no ?
     _FldNameList[5]   > Temp-Tables.{1}.is-prod
"{1}.is-prod" "Пр-ль" "+/" "logical" ? ? ? ? ? ? no ?
     _FldNameList[6]   > Temp-Tables.{1}.sup-gds
"{1}.sup-gds" "Пост-к/т" "+/" "logical" ? ? ? ? ? ? no ?
     _FldNameList[7]   > Temp-Tables.{1}.sup-cons
"{1}.sup-cons" "Пост-к/к" "+/" "logical" ? ? ? ? ? ? no ?
     _FldNameList[8]   > Temp-Tables.{1}.buy-gds
"{1}.buy-gds" "Пок-ль/т" "+/" "logical" ? ? ? ? ? ? no ?
     _FldNameList[9]   > Temp-Tables.{1}.buy-cons
"{1}.buy-cons" "Пок-ль/к" "+/" "logical" ? ? ? ? ? ? no ?
     _FldNameList[10]   > Temp-Tables.{1}.buy-serv
"{1}.buy-serv" "Пок-ль/у" "+/" "logical" ? ? ? ? ? ? no ?
     _FldNameList[11]   > "_<CALC>"
"is-dis-cardc({1}.obj-type, {1}.obj-code)" "Дисконтная карта" "X(16)" ? ? ? ? ? ? ? no ?
     _FldNameList[12]   > "_<CALC>"
"is-cashierc({1}.obj-type, {1}.obj-code)" "Кассир" ? ? ? ? ? ? ? ? no ?
     _FldNameList[13]   = Temp-Tables.{1}.db-num
     _FldNameList[14]   > "_<CALC>"
"is-sellerc({1}.obj-type, {1}.obj-code)" "Прод-ц" "X(6)" ? ? ? ? ? ? ? no ?
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
on GO of frame {&frame-name} do:
  define variable glog as logical no-undo .
  &if "{2}" = "managed" &then
  if lookup({&lob-res-list}, bttns) > 0 then do:
    message
    "Хотите добавить/изменить хранимый список клиентов?"
    view-as alert-box question
    buttons yes-no update glog
    .
    if glog then do:
      run m_cli-save-db-proc in this-procedure no-error.
    end.
  end.
  if lookup({&lob-res-list-macro}, bttns) > 0 then do:
    message
    "Хотите добавить/изменить хранимый макрос формирования списка клиентов?"
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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список клиентов */
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
run create-{1}-hist in this-procedure (
                                       input {&add-def}
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
SPACE(25) "История создания списка клиентов "
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
  if not available {1} then do:
  message "Неправильно выбран клиент."
          view-as alert-box error.
  return no-apply.
end.
 run ref/showcli.p (
             input parparentproc
            ,input {1}.obj-type /* p-obj-type */
            ,input {1}.obj-code /* p-obj-code */
            ).
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
    run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if print-option = "artic":U then do:
  run str/cliartpr.p ( input parparentproc
                 ,output v-frame-width ) no-error.
end.
else do:
  run str/clil-prn.p ( input parparentproc
                 ,input print-option
                 ,output v-Frame-Width) no-error.
end.
print-option = "".

if v-frame-width <= {&A4_LS} then do:
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input (if v-frame-width <= {&A4_CW0} then 0 else 8)
                                            ).
end.
else do:
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input (if v-frame-width <= 255 then 1 else 20)
                                            ).
end.
make-excel = no.
apply "entry" to br-list in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-save Dialog-Frame
ON CHOOSE OF B-save IN FRAME Dialog-Frame /* Сохранить */
DO:
  if save-option = "" then do:
       run gbl/pop-up.p ( input self:handle, input no) no-error.
   end.
   run proc-b-save in this-procedure ( input save-option) no-error.
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
ON VALUE-CHANGED OF br-option IN FRAME Dialog-Frame /* Browse 2 */
DO:
  assign
  Rs-list-method = temp-list.fvalue
  .
  run proc-vc-rs-list-method in this-procedure no-error .
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_art-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_main-print Dialog-Frame
ON CHOOSE OF MENU-ITEM m_art-print /* Выбор полей */
DO:
  assign
  print-option = "artic":U.
  apply "choose" to b-print in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_cli-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_cli-save Dialog-Frame
ON CHOOSE OF MENU-ITEM m_cli-save /* Файл списка клиентов */
DO:
  assign
  save-option = "cli-list":U.
  apply "choose" to b-save in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_cli-save-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_cli-save-db Dialog-Frame
ON CHOOSE OF MENU-ITEM m_cli-save-db /* Файл списка клиентов */
DO:
  assign
  save-option = "cli-list-db":U.
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
ON CHOOSE OF MENU-ITEM m-macros-save-db /* Файл списка клиентов */
DO:
  assign
  save-option = "cli-list-macros-db":U.
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

&Scoped-define SELF-NAME m-rum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-rum Dialog-Frame
ON CHOOSE OF MENU-ITEM m-rum /* Операции над списком */ DO:
define variable glog as logical no-undo .
{ gbl/stdbtn.i b-save "in frame {&frame-name}" }
run str/diallog.w (
      input parParentProc
    , input this-procedure
    , input "utl/thbjrumr.w":U
    , input {&table_clients} + {&delim-par} +
            ({&clients-proc_batchwork-export} + {&comma-char} + {&clients-proc_batchwork-routing}) /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
    , input no /*p-auto-go*/
    , input "&Стоп"
    , input substitute("Операции над списком клиентов") ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_sel-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_main-print Dialog-Frame
ON CHOOSE OF MENU-ITEM m_sel-print /* Выбор полей */
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
run create-{1}-hist in this-procedure (
                                       input 'title'
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
    if can-do( {&g___code}, n-c ) then do:
        assign
            NameOrCode:width-chars = 10
            NameOrCode:format = "x(9)" .
    end.
    else do:
        assign
            NameOrCode:width-chars = 34.63
            NameOrCode:format = "X(40)" .
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
  run proc-find-nameorcode in this-procedure no-error.
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
{ str/an-listp.i {1} cli-list clm {2} }
if lookup(bttns, "hide") = 0 then do:
run diasize_add_browse in this-procedure
  (input  'height':u
  ,input  browse BR-option :handle
  ) .
run diasize_init in this-procedure .
end.



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

{ cmp/ex-cli.i {1} {&frame-name} }

{ gbl/brwrepos.i
&browse-name=br-list
&line-num=5 }

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
    "Название" + {&comma-char} + {&name} + {&comma-char} +
                    "Код" + {&comma-char} + {&g___code}
    RS-status:radio-buttons = "Текущие&+" + {&comma-char} + {&current} + {&comma-char} +
                              "Все!" + {&comma-char} + {&all} + {&comma-char} +
                              "Удаленные-" + {&comma-char} + {&deleted}
    RS-status = {&current}
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
RUN disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb_fill-lob-res-list Dialog-Frame
procedure cb_fill-lob-res-list :
define input  parameter p-full-path as character no-undo .
output to value (p-full-path).
for each {1}:
  export
  {1}.obj-type
  {1}.obj-code.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb_get-next-cli-by-obj-type-code Dialog-Frame
procedure cb_get-next-cli-by-obj-type-code :
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-bh as handle no-undo .
define buffer buf_cli-list for {1}.
find first buf_cli-list no-lock where
          (buf_cli-list.obj-type = p-obj-type
     and  buf_cli-list.obj-code = p-obj-code) no-error.
find next buf_cli-list use-index obj no-error.
if available buf_cli-list then do:
  p-bh:buffer-create().
  p-bh:buffer-copy(buffer buf_cli-list:handle).
end.
else do:
end.
end procedure. /* cb_get-next-cli-by-obj-type-code */

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
  ENABLE dsp-rs B-exit B-save B-print B-hist B-lkp B-clr B-Help B-add
         B-del B-rest B-macro B-stop B-clear-macro B-record NameOrCode
         n-c RS-Status BR-list ed-notes f-tot-lns
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
procedure m_cli-save-db-proc :
define variable v-rid-list as character no-undo .
&if "{2}" = "managed" &then
if lookup("clobbnds_add", bttns) > 0 then do:
  run clobbnds_add in p-parent-handle
                  ( input this-procedure:handle
                   ,input {&lob-res-list}
                   ,input "cli-list"
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
                    ,input 'cli-list' /*p-unique-key-rec*/
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
                   ,input "cli-list"
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
                    ,input 'cli-list' /*p-unique-key-rec*/
                    ,input -1 /*p-db-num*/
                    ,input-output v-rid-list) no-error.
&endif
end procedure. /* m-macros-save-db-proc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable v-start as logical no-undo .
define variable v-recid0 as recid no-undo .
define buffer buf_temp-list for temp-list.
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
    accumulate l-{1}.obj-code (count).
  end.
  tot-lns = (accum count l-{1}.obj-code).
  if tot-lns > 0 then do:
    find last  buf_{1}-hist no-error .
    v-seq = (if available buf_{1}-hist then buf_{1}-hist.id else 0)  + 1.
    run create-{1}-hist in this-procedure (
                                            input {&add-def}
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
    run create-{1}-hist in this-procedure ( input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input "# Исходный список клиентов пуст."
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
    menu-item m_cli-save-db:sensitive  in menu menu-b-save = no.
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
  DISABLE b-print b-rest b-save b-del b-lkp b-clr n-c nameorcode WITH FRAME {&frame-name}.
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
    find ub.clients where rowid(ub.clients) = p-rowid no-lock no-error .
  end.
  else do:
  run ref/cli-all.w (
                      input parparentproc
                    , input "b-sel,b-add"
                    , input ?
                    , input ?
                    , input ?
                    , input ?
                    , input ?
                    , input ?
                    , output ref-list).
    apply "entry" to br-list in frame {&frame-name}.
    if ref-list = "" then return error.
    /* выбран клиент */
    find ub.clients where recid (ub.clients) = integer (ref-list) no-lock.
  end.
  if available ub.clients then do:
    run ex-cli in this-procedure ( input rs-list-method, input rs-status, input line-mode).
    tot-lns = tot-lns + 1.
    run write-hist in this-procedure ( input p-from-macro, input rs-list-method, input rs-status, input line-mode).
  end.
  else do:
    return error "Нет в БД такого клиента".
  end.
  run Myenable in this-procedure .
end.
else do:
    run rs-do in this-procedure ( input no, input no, input rs-list-method, input rs-status, input line-mode, input (v-seq - 1)).
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
define variable rep-rec as recid no-undo .
define variable glog as logical no-undo .
line-mode = {&deletion}.
if rs-list-method = "single" then do:
  v-no-hist = - 1.
  if p-from-macro then do:
    find first ub.clients where rowid(ub.clients) = p-rowid no-error.
    if not available ub.clients then return error "Нет в БД такой клиента".
    find first {1} where
             {1}.obj-type = ub.clients.obj-type
         AND {1}.obj-code = ub.clients.obj-code no-error.
  end.
  if available {1} then do:
    line-rec = recid ({1}).
    get next br-list.
    if available {1} then rep-rec = recid ({1}).
    else do:
      reposition br-list to recid line-rec no-error.
      get prev br-list.
      if available {1} then rep-rec = recid ({1}).
    end.
    reposition br-list to recid line-rec no-error.
    tot-lns = tot-lns - 1.
    run write-hist in this-procedure ( input p-from-macro, input rs-list-method, input rs-status, input line-mode).
    delete {1}.
    line-rec = rep-rec.
    run Myenable in this-procedure .
  end.
end.
else do:
  glog = no.
  message "Удалить клиентов из списка ПО заданному УСЛОВИЮ ?   Вы уверены ?"
          view-as alert-box question buttons OK-Cancel update glog.
  if not glog then
    return error.
  run rs-do in this-procedure ( input no, input no, input rs-list-method, input rs-status, input line-mode, input (v-seq - 1)).
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
    find first ub.clients where rowid(ub.clients) = p-rowid no-error.
    if not available ub.clients then return error substitute("Нет в БД такого клиента").
    find first {1} where
              {1}.obj-type = ub.clients.obj-type
          AND {1}.obj-code = ub.clients.obj-code no-error.
  end.
  if available {1} then do:
    if p-from-macro then do:
       glog = yes.
    end.
    else do:
      glog = no.
      message
      "Оставить отмеченную строку и УДАЛИТЬ ВСЕ ОСТАЛЬНЫЕ ?   Вы уверены ?"
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then return no-apply.
    end.
    line-rec = recid ({1}).
    v-seq = 1.
    for each buf_{1}-hist:
      delete buf_{1}-hist.
    end.
    run write-hist in this-procedure ( input p-from-macro, input rs-list-method, input rs-status, input line-mode).
    for each {1}:
      if line-rec <> recid ({1}) then delete {1}.
    end.
    tot-lns = 1.
    run Myenable in this-procedure .
  end.
  else do:
    return error substitute("Нет в списке такой клиента").
  end.
end.
else do:
  if not p-from-macro then do:
    glog = no.
    message
    "Оставить клиентов в списке ПО заданному УСЛОВИЮ и УДАЛИТЬ ВСЕХ ОСТАЛЬНЫХ ?   Вы уверены ?"
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then
      return no-apply.
  end.
  assign
  lns-cnt = 0
  lns-ignore = 0
  .
  run rs-do in this-procedure ( input no, input no, input rs-list-method, input rs-status, input line-mode, input (v-seq - 1)).
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
  run Myenable in this-procedure .
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

  run gbl/filename.p (
   input  (if rs-list-method = "clob-data" then v-file-name else buf_{1}-hist.item_  )/* p-search-file-name */
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
            if available ub.trn-doc  then do:
              find first ub.clients no-lock where
                        ub.clients.obj-type = ub.trn-doc.cli-type
                    AND ub.clients.obj-code = ub.trn-doc.cli-code no-error.
               if available ub.clients then
               run ex-cli in this-procedure ( input rs-list-method, input rs-status, input line-mode).
            end. /*if available trn-doc*/
          end.  /*    if imp-doc-type <>  {&overvalue} then do:*/
        end. /*repeate*/
      end. /*when doc-list*/
      when "file"
      or
      when "clob-data"
      then do:
        repeat:
          import stream sout imp-type imp-code no-error.
          find clients where
              clients.obj-type = imp-type and
              CLIENTS.OBJ-code = imp-code
              no-lock no-error.
          if available CLIENTS then do:
            run ex-cli in this-procedure ( input rs-list-method, input rs-status, input line-mode).
          end.
        end. /*repeat*/
        if rs-list-method = "clob-data" then do:
          os-delete value(v-full-path) .
        end.
      end. /*file*/
      when "gds-list" then do:
        repeat:
          import stream sout imp-type imp-code imp-art no-error.
          find ub.goods where ub.goods.prod-type = imp-type
                    and ub.goods.prod-code = imp-code
                    and ub.goods.artic     = imp-art no-lock no-error.
          if available ub.goods then do:
            find first ub.clients no-lock where
                      ub.clients.obj-type = ub.goods.prod-type
                  AND ub.clients.obj-code = ub.goods.prod-code no-error.
            if available ub.clients then do:
              run ex-cli in this-procedure ( input rs-list-method, input rs-status, input line-mode).
            end. /*avail-clients*/
          end. /*aavail goods*/
        end. /*repeat*/
      end. /*gds-list*/
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
define variable glog as logical no-undo .
define variable v-rid-list as character no-undo .
case loc-save-option:
  when "cli-list":U then do:
    assign
    f-name = "default.cli"
    glog = yes
    .
    system-dialog get-file f-name
    filters "Списки клиентов *.cli" "*.cli"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "cli".
    if not glog then do:
      apply "entry" to br-list in frame {&frame-name}.
      return no-apply.
    end.
    output to value (f-name).
    for each {1}:
      export
      {1}.obj-type
      {1}.obj-code
      .
    end.
    output close.
  end.
  when "cli-list-macros-db" then do:
    run m-macros-save-db-proc in this-procedure .
  END.
  when "cli-list-db" then do:
    run m_cli-save-db-proc in this-procedure .
  end.
  when "excel":U then do:
    do on stop  undo, return no-apply
        on error undo, return no-apply
        on quit  undo, return no-apply
    :
      run str/clil-prn.p (
                       input parparentproc
                      ,input "excel":U
                      ,output v-Frame-Width) no-error.
      run waitfram-hide in this-procedure .
    end.
  end.
end case.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-nameorcode Dialog-Frame
PROCEDURE proc-find-nameorcode :
case n-c:
  when {&name} then do:
    if last-event:label = "Ctrl-J" then
        find next l-{1} no-lock where
                   l-{1}.obj-name begins nameorcode no-error.

    else
        find first l-{1} no-lock where
                   l-{1}.obj-name begins nameorcode no-error.
  end.
  when {&g___code} then do:
    if last-event:label = "Ctrl-J" then
        find next l-{1} no-lock where
                   l-{1}.obj-code = integer(nameorcode) no-error.
    else
        find first l-{1} no-lock where
                   l-{1}.obj-code = integer(nameorcode) no-error.

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
    f-name = "default.clm"
    glog = yes
    .
  system-dialog get-file f-name
    filters "Макрос создания списка клиентов *.clm" "*.clm"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "clm".
  if not glog then do:
    apply "entry" to br-list in frame {&frame-name}.
    return no-apply.
  end.
  run waitfram-show in this-procedure ( input "Сохранение макроса формирования списка клиентов.    ЖДИТЕ...").
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
define variable ii as integer no-undo.
define variable glog as logical no-undo .
define variable v-recs as integer no-undo .
define variable v-line as integer no-undo .
define variable v-item as character no-undo .
define variable v-tbl-name as character no-undo .
define variable v-bh as handle no-undo .
define variable v-tot-lns as integer no-undo .
define variable v-temp-seq as integer no-undo .
define variable v-message as character no-undo .
define variable grp-path as character no-undo .
define variable v-input-output as character no-undo .
define variable v-ref-rec as recid no-undo .
define variable v-grp-rec as recid no-undo .
define variable v-rid-list as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable f-name as char init "default.cli" no-undo.
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_{1}-hist for {1}-hist.
v-no-hist = - 1.
if  rs-list-method = "single" then
run Myenable in this-procedure .
else do:
   v-no-hist = 0.
  case rs-list-method:
    when "all" then do:
      glog = yes.
      message "Все клиенты из справочника клиентов"
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      v-no-hist = 1.
      run create-{1}-hist in this-procedure (
                                            input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('Все клиенты &1', stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input 'all':U
                                          , input '':U
                                          , input ?
                                          ).
    end.
    when "cli"
    or
    WHEN "cli-grp" then do:
      if rs-list-method = "cli-grp" then do:
        glog = yes.
        message "1 или несколько групп клиентов"
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run MyEnable in this-procedure .
          return error.
        end.
        /* вызов справочника групп КЛИЕНТОВ для выбора */
        GRP-list = "". /* кажется, при выходе по Esc не снимается */
        ref-list = "".
        run ref/cli-grps.w ( input parparentproc
                           , input "b-sel,b-mark"
                           , input-output grp-list).
      end.
      else do:
        glog = yes.
        message "1 или несколько произвольных клиентов из справочника."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run MyEnable in this-procedure .
          return error.
        end.
        run ref/cli-all.w ( input parparentproc
                        , input "b-sel,b-mark,b-add"
                        , input ?
                        , input ?
                        , input ?
                        , input ?
                        , input ?
                        , input ?
                        , output ref-list).
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
            run cli-grplib-get-full-name in this-procedure ( input ub.cli-grp.node-code, output grp-path).
          end.
          if v-recs = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Группа клиентов &1 &2", grp-path, stat-line(rs-status))
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
              v-bh       = buffer cli-grp:handle
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
              v-bh       = buffer clients:handle
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
    end. /*when cli or cli-grp*/
    when "prod" then do:
      glog = yes.
      message "Все производители товаров."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure (
                                            input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('ВСЕ производители. &1', stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input 'prod':U
                                          , input '':U
                                          , input ?
                                          ).
    end. /*when prod*/
    when "sup-gds" then do:
      glog = yes.
      message "Все поставщики товаров."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure (
                                            input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('ВСЕ поставщики товаров. &1', stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input 'sup-gds':U
                                          , input '':U
                                          , input ?
                                          ).
    end. /*when sup-gds*/
    when "sup-cons" then do:
      glog = yes.
      message "Все поставщики консигнационных товаров."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure (
                                            input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('ВСЕ поставщики консигнационных товаров. &1', stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input 'sup-cons':U
                                          , input '':U
                                          , input ?
                                          ).
    end. /*when sup-cons*/
    when "buy-gds" then do:
      glog = yes.
      message "Все покупатели товаров."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure (
                                            input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('ВСЕ покупатели товаров. &1', stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input 'buy-gds':U
                                          , input '':U
                                          , input ?
                                          ).
    end. /*when buy-gds*/
    when "buy-cons" then do:
      glog = yes.
      message "Все покупатели консигнационных товаров."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure (
                                            input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('ВСЕ покупатели консигнационных товаров. &1', stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input 'buy-cons':U
                                          , input '':U
                                          , input ?
                                          ).
    end. /*when buy-cons*/
    when "buy-serv" then do:
      glog = yes.
      message "Все покупатели услуг."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure (
                                            input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('ВСЕ покупатели услуг. &1', stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input 'buy-serv':U
                                          , input '':U
                                          , input ?
                                          ).
    end. /*when buy-serv*/
    when "dis-card" then do:
      glog = yes.
      message "Все обладатели дисконтных карт."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure (
                                            input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('ВСЕ обладатели дисконтных карт. &1', stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input 'dis-card':U
                                          , input '':U
                                          , input ?
                                          ).
    end. /*when dis-card*/
    when "cashiers" then do:
      glog = yes.
      message "Все кассиры."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure (
                                            input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('ВСЕ кассиры. &1', stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input 'cashiers':U
                                          , input '':U
                                          , input ?
                                          ).
    end. /*when cashiers*/
    when "sellers" then do:
      glog = yes.
      message "Все продавцы."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure (
                                            input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('ВСЕ продавцы. &1', stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input 'sellers':U
                                          , input '':U
                                          , input ?
                                          ).
    end. /*when sellers*/
    when "firm" then do:
      glog = yes.
      message "Все организации."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure (
                                            input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('ВСЕ организации. &1', stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input 'firm':U
                                          , input '':U
                                          , input ?
                                          ).
    end. /*when firm*/
    when "person" then do:
      glog = yes.
      message "Все физические лица."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure (
                                            input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('ВСЕ физические лица. &1', stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input 'person':U
                                          , input '':U
                                          , input ?
                                          ).
    end. /*when person*/
    when "shop" then do:
      glog = yes.
      message "Все магазины."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure (
                                            input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('ВСЕ магазины. &1', stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input 'shop':U
                                          , input '':U
                                          , input ?
                                          ).
    end. /*when shop*/
    when "store" then do:
      glog = yes.
      message "Все склады."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure (
                                            input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('ВСЕ склады. &1', stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input 'store':U
                                          , input '':U
                                          , input ?
                                          ).
    end. /*when store*/
    when "waybill" then do:
      if v-cntxt-level <>  {&cntxt-object} then do:
        message
        "Не установлен текущий объект" skip
        "Выбор невозможен"
        view-as alert-box error .
        run MyEnable in this-procedure .
        return error.
      end.
      glog = yes.
      message "Контрагенты выбранных документов."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
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
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input "b-sel,b-mark"
                     ,input ?
                     ,input ?
                     ,input ?
                     ,output ref-list).
      if ref-list = "" then do:
        run MyEnable in this-procedure .
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
          dsp-rs = substitute("Контрагенты по документу : &1 &2 &3 &4 № &5 от &6 &7"
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
            dsp-rs = substitute("Контрагенты по документам : &1", stat-line(rs-status))
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
    end. /*when waybill*/
    when "attr" or when "attr-val" then do:
      run trig-attr in this-procedure ( input rs-list-method) no-error.
      if error-status:error then do:
        run MyEnable in this-procedure .
        return error.
      end.
    end. /*when attr*/
    when "grp-buy"  then do:
      run trig-grp-buy in this-procedure no-error.
      if error-status:error then do:
        run MyEnable in this-procedure .
        return error.
      end.
    end. /*when grp-buy*/
    when "turnov-buy"  then do:
      run trig-turnov-buy in this-procedure no-error.
      if error-status:error then do:
        run MyEnable in this-procedure .
        return error.
      end.
    end. /*when turnov-buy*/
    when "doc-list" then do:
      glog = yes.
      message "Все контрагенты документов из сохраненного в файле списка документов"
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable in this-procedure .
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
        run MyEnable in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure (
                                            input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute("Контрагенты документов списка: &1 &2", f-name, stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input f-name
                                          , input '':U
                                          , input ?
                                          ).
    end.
    when "gds-list" then do:
      glog = yes.
      message "Все производители товаров из сохраненного в файле списка товаров"
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable in this-procedure .
        return error.
      end.
      system-dialog get-file f-name
      filters "Списки товаров *.gds" "*.gds"
      title "Выберите файл списка"
      INITIAL-DIR "."
      return-to-start-dir
      must-exist
      /* use-filename */
      update glog
      default-extension "gds".
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure (
                                            input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute("Производители товаров из списка: &1 &2", f-name, stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input f-name
                                          , input '':U
                                          , input ?
                                          ).
    end. /*when gds-list*/
    when "deleted" then do:
      if RS-status = {&current} then do:
        message
        "Переключатель <СТАТУС> стоит в положениии <Текущие>" skip
        "Вы не cможете выбрать ни одного клиента"
        view-as alert-box error .
        run MyENable in this-procedure .
        return error.
      end.
      glog = yes.
      message "Все удаленные клиенты."
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure (
                                            input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute('Все удаленные клиенты. &1', stat-line(rs-status))
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
      message "Все клиенты из ранее сохраненного в файле списка"
      skip stat-line(rs-status)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable in this-procedure .
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
        run MyEnable in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure (
                                            input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute("Все клиенты из сохраненного в файле списка клиентов &1 &2", f-name, stat-line(rs-status))
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
      message "Все клиенты из ранее сохраненного в БД списка"
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
                          ,input 'cli-list' /*p-unique-key-rec*/
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
      run create-{1}-hist in this-procedure(input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input substitute("Хранимый Файл списка : &1 &2", buf_clob-bind.field-name, stat-line(rs-status))
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input v-uniq-key-rec
                                          , input '':U
                                          , input ?
                                          ).

    end.
    WHEN "FILTER" THEN DO:
      run trig-filter in this-procedure no-error.
      if error-status:error then do:
        run MyEnable in this-procedure .
        return error.
      end.
    END. /*WHEN FILTER*/
  end case.
  if tot-lns <> 0 then do:
    run get-operation in this-procedure ( input dsp-rs, output v-operation).
    CASE v-operation:
      when {&add-operation} then do:
        run proc-b-add in this-procedure ( input no, input ?, input rs-list-method, input rs-status) no-error  .
      end.
      when {&del-operation} then do:
        run proc-b-del in this-procedure ( input no, input ?, input rs-list-method, input rs-status ) no-error  .
      end.
      when {&rest-operation} then do:
        run proc-b-rest in this-procedure ( input no, input ?, input rs-list-method, input rs-status) no-error  .
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
  if tot-lns = 0
  then do:
    run proc-b-add in this-procedure ( input no, input ?, input rs-list-method, input rs-status)  .
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
define input parameter rs-status as character no-undo .
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
define variable v-sum-1 as decimal no-undo .
define variable v-sum-2 as decimal no-undo .
define variable v-cashier-role-string as character no-undo .
define variable v-seller-role-string as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .



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
run write-hist in this-procedure ( input p-from-macro, input rs-list-method, input rs-status, input line-mode).
if session:set-wait-state( "COMPILER" )  then .
dsp-rs:fgcolor in frame {&frame-name} = 12.
case rs-list-method:
  when "cli-grp" then do:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      {&get-rowid}  next.
      grp-path = "".
      find first ub.cli-grp no-lock where rowid(ub.cli-grp) = v-rowid.
      grp-path = ''.
      run cli-grplib-get-full-name in this-procedure ( input ub.cli-grp.node-code, output grp-path).
      for each ub.clients no-lock where ub.clients.grp-name begins grp-path:
        run ex-CLI in this-procedure ( input rs-list-method, input rs-status, input line-mode).
      end.
      {&assign-nums}.
    end. /*for each buf_*/
  end. /*when cli-grp*/
  when "cli"  then do:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      {&get-rowid}  next.
      find first ub.clients no-lock where rowid(ub.clients) = v-rowid.
      run ex-cli in this-procedure ( input rs-list-method, input rs-status, input line-mode).
      {&assign-nums}.
    end.
  end. /* when cli or cli-grp*/
  when "prod" then do:
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
    for each ub.clients where ub.clients.is-prod = yes no-lock:
      run ex-cli in this-procedure ( input rs-list-method, input rs-status, input line-mode).
    end.
    {&assign-nums}.
  end.
  when "sup-gds" then do:
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
      for each ub.clients where ub.clients.sup-gds = yes no-lock:
      run ex-cli in this-procedure ( input rs-list-method, input rs-status, input line-mode).
    end.
    {&assign-nums}.
  end.
  when "sup-cons" then do:
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
    for each ub.clients where ub.clients.sup-cons = yes no-lock:
      run ex-cli in this-procedure ( input rs-list-method, input rs-status, input line-mode).
    end.
    {&assign-nums}.
  end.
  when "buy-gds" then do:
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
    for each ub.clients where ub.clients.buy-gds = yes no-lock:
      run ex-cli in this-procedure ( input rs-list-method, input rs-status, input line-mode).
    end.
    {&assign-nums}.
  end.
  when "buy-cons" then do:
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
    for each ub.clients where ub.clients.buy-cons = yes no-lock:
      run ex-cli in this-procedure ( input rs-list-method, input rs-status, input line-mode).
    end.
    {&assign-nums}.
  end.
  when "buy-serv" then do:
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
    for each ub.clients where ub.clients.buy-serv = yes no-lock:
      run ex-cli in this-procedure ( input rs-list-method, input rs-status, input line-mode).
    end.
    {&assign-nums}.
  end.
  when "dis-card" then do:
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
    for each ub.clients no-lock,
        first ub.dis-card no-lock where
              ub.dis-card.cli-type = ub.clients.obj-type AND
              ub.dis-card.cli-code = ub.clients.obj-code:
      run ex-cli in this-procedure ( input rs-list-method, input rs-status, input line-mode).
    end.
    {&assign-nums}.
  end.
  when "cashiers" then do:
    if v-cntxt-db-num <> 0 then do:
      v-cashier-role-string = gbclcode-get-work-place  (
                                                  input {&role-cashier}
                                                ,input {&role-level-db}
                                                ,input v-cntxt-db-num
                                                ,input 0 /*p-host-code*/
                                                ,input '':U /*p-obj-type*/
                                                ,input 0 /*p-obj-code*/ ).
    end.
    run cur-time in this-procedure ( output v-today, output v-time).
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
    for each ub.staff no-lock where
            ub.staff.role = {&role-cashier}
        and ub.staff.role-leve = {&role-level-db}
        and (v-cntxt-db-num = 0 or ub.staff.work-place = v-cashier-role-string)
        and ub.staff.date-end >= v-today,
       first ub.clients no-lock where
              ub.clients.obj-type = {&prs} AND
              ub.clients.obj-code = staff.psn-code:
      run ex-cli in this-procedure ( input rs-list-method, input rs-status, input line-mode).
    end.
    {&assign-nums}.
  end.
  when "sellers" then do:
    if v-cntxt-db-num <> 0  then do:
      v-cashier-role-string = gbclcode-get-work-place  (
                                                  input {&role-cashier}
                                                ,input {&role-level-db}
                                                ,input v-cntxt-db-num
                                                ,input 0 /*p-host-code*/
                                                ,input '':U /*p-obj-type*/
                                                ,input 0 /*p-obj-code*/ ).
    end.
    run cur-time in this-procedure ( output v-today, output v-time).
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
    for each ub.staff no-lock where
            ub.staff.role =  {&role-seller}
        and ub.staff.role-leve = {&role-level-db}
        and (v-cntxt-db-num = 0 or ub.staff.work-place = v-cashier-role-string)
        and ub.staff.date-end >= v-today,
            first ub.clients no-lock where
              ub.clients.obj-type = {&prs} AND
              ub.clients.obj-code = ub.staff.psn-code:
      run ex-cli in this-procedure ( input rs-list-method, input rs-status, input line-mode).
    end.
    {&assign-nums}.
  end.
  when "firm" then do:
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
    for each ub.clients where ub.clients.obj-type = {&cmp} no-lock:
      run ex-cli in this-procedure ( input rs-list-method, input rs-status, input line-mode).
    end.
    {&assign-nums}.
  end.
  when "person" then do:
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
    for each ub.clients where ub.clients.obj-type = {&prs} no-lock:
      run ex-cli in this-procedure ( input rs-list-method, input rs-status, input line-mode).
    end.
    {&assign-nums}.
  end.
  when "shop" then do:
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
    for each ub.clients where ub.clients.obj-type = {&shop} no-lock:
      run ex-cli in this-procedure ( input rs-list-method, input rs-status, input line-mode).
    end.
    {&assign-nums}.
  end.
  when "store" then do:
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
    for each ub.clients where ub.clients.obj-type = {&stock} no-lock:
      run ex-cli in this-procedure ( input rs-list-method, input rs-status, input line-mode).
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
        if avail ub.clients then
        run ex-cli in this-procedure ( input rs-list-method, input rs-status, input line-mode).
      end. /* do num-rec = 1 to */
      {&assign-nums}.
    end.
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
      for each ub.clients no-lock,
        first ub.clients-attr No-LOCK WHERE
              ub.clients-attr.obj-type = ub.clients.obj-type AND
              ub.clients-attr.obj-code = ub.clients.obj-code AND
             ub.clients-attr.attr-code = v-attr-code
        :
        if rs-list-method = "attr-val" then do:
          run clntattr-value in this-procedure (
                            input ub.clients.obj-type
                           ,input ub.clients.obj-code
                           ,input v-attr-code
                           ,output vvalue1
                           ,output vtype1).
          if vvalue1 <> vvalue then NEXT.
        end.
        run ex-cli in this-procedure ( input rs-list-method, input rs-status, input line-mode).
      end. /*for each clients no-lock,*/
      {&assign-nums}.
    end.
  end. /*when attr*/
  when "grp-buy"  then do:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      {&get-rowid}  next.
      grp-path = "".
      find first ub.buyer-group no-lock where rowid(ub.buyer-group) = v-rowid.
      for each ub.clients no-lock,
          first ub.buyer-in-buyer-group No-LOCK WHERE
                ub.buyer-in-buyer-group.stts         = 0
            and ub.buyer-in-buyer-group.bbg-obj-type = ub.clients.obj-type
            and ub.buyer-in-buyer-group.bbg-obj-code = ub.clients.obj-code
            and ub.buyer-in-buyer-group.bgr-id       = ub.buyer-group.bgr-id
            and ub.buyer-in-buyer-group.bgr-db-num   = ub.buyer-group.bgr-db-num:
        run ex-CLI in this-procedure ( input rs-list-method, input rs-status, input line-mode).
      end.
      {&assign-nums}.
    end. /*for each buf_*/
  end. /*grp-buy*/
  when "turnov-buy"  then do:
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id
        and    buf_{1}-hist.item_ <> '':U.
    assign
    v-sum-1 = decimal(entry(1, buf_{1}-hist.item_, {&delim-key}))
    v-sum-2 = decimal(entry(2, buf_{1}-hist.item_, {&delim-key}))
    no-error
    .
    if error-status:error then do:
    end.
    else do:
      run str/two-sum.w (  input  'calc'
                      ,input-output v-sum-1
                      ,input-output v-sum-2
                      ,output table temp-list-buyer
                  ) .

      if not can-find(first temp-list-buyer) then return.
      for each temp-list-buyer,
          first clients no-lock where
              clients.obj-type = temp-list-buyer.obj-type
          and clients.obj-code = temp-list-buyer.obj-code:
        run ex-CLI in this-procedure ( input rs-list-method, input rs-status, input line-mode).
      end.
      empty temp-table temp-list-buyer.
      {&assign-nums}.
    end.
  end. /*turnov-buy*/
  when "doc-list"
  or
  when "gds-list"
  or
  when "file"
  or
  when "clob-data"
  then do:
    run proc-file-list-methods in this-procedure ( input p-from-macro, input rs-list-method, input rs-status, input line-mode, input p-id).
  end.
  when "deleted" then do:
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
    for each clients where clients.stts <> 0 no-lock:
      run ex-cli in this-procedure ( input rs-list-method, input rs-status, input line-mode).
    end.
    {&assign-nums}.
  end.
  when "filter" then do:
    define variable v-filter-var as character no-undo .
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U .
    run proc-write-filter-expression-var in this-procedure ( input buf_{1}-hist.item_, output v-filter-var ).
    run gbl/cli-fill.p (
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
    for each clients no-lock:
      run ex-cli in this-procedure ( input rs-list-method, input rs-status, input line-mode).
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
define variable ii as integer no-undo.
define variable glog as logical no-undo .
DEFINE VARIABLE vattr-codes          as character           no-undo.
DEFINE VARIABLE vattr-labels         as character           no-undo.
DEFINE VARIABLE vtooltip             as character           no-undo.
DEFINE VARIABLE vlabel               as character           no-undo .
DEFINE VARIABLE vtype                as character           no-undo .
DEFINE VARIABLE vformat              as character           no-undo .
DEFINE VARIABLE vuser-can-edit       as logical             no-undo .
DEFINE VARIABLE voutput-display      as logical             no-undo .
DEFINE VARIABLE vother               as character           no-undo .
DEFINE VARIABLE v-ref-list           as character           no-undo .
DEFINE VARIABLE jj                   as integer             no-undo .
DEFINE VARIABLE v-spr                as character           no-undo .
DEFINE VARIABLE v-spr-param          as character           no-undo .
DEFINE VARIABLE v-setted             as logical             no-undo .
define variable v-init               as character           no-undo .
define variable v-item               as character           no-undo .
DEFINE VARIABLE v-attr-code          as character           no-undo .

assign
ref-list = ""
vattr-codes = ""
vattr-labels = ""
vvalue = ""
.
DO ii = 1 to num-entries({&clntattr-list}):
    run clntattr-code in this-procedure (
                                         input entry(ii, {&clntattr-list})
                                        ,output vtype
                                        ,output vformat
                                        ,output vlabel
                                        ,output vuser-can-edit
                                        ,output voutput-display
                                        ,output vother) no-error.
    if NOT error-status:error anD VOUTPUT-DISPLAY = yes then do:
        assign
        vattr-codes = vattr-codes + {&delim-par} + entry(ii, {&clntattr-list})
        vattr-labels = vattr-labels + {&delim-par} + vlabel
        .
    end.
end.
run gbl/d-list.w (
                   input "b-sel":U
                  ,input "Выберите атрибут"
                  ,input vattr-codes
                  ,input vattr-labels
                  ,input {&delim-par}
                  ,input "":U
                  ,output v-attr-code).

if v-attr-code = "" then do:
  return error.
end.

glog = yes.
if rs-list-method = "attr" then do:
    run clntattr-tooltip in this-procedure ( input v-attr-code,
                         output vtooltip,
                         output vlabel).
    message "Все клиенты с установленным атрибутом " + vlabel
            view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      return error.
    end.
    assign
    dsp-rs = substitute("ВСЕ клиенты с установленным атрибутом &1: &2", vlabel, stat-line(rs-status))
    v-item = '':U + {&delim-key} + '':U + {&delim-key} + v-attr-code
    .
end.
else do:
    run clntattr-code in this-procedure (
                                          input v-attr-code
                                        ,output vtype
                                        ,output vformat
                                        ,output vlabel
                                        ,output vuser-can-edit
                                        ,output voutput-display
                                        ,output vother).
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
    message ("Все клиенты с атрибутом " + vlabel + " = ":U + vvalue)
            view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      return error.
    end.
    assign
    dsp-rs = substitute("Все клиенты с атрибутом &1 =&2 &3", vlabel, vvalue, stat-line(rs-status))
    v-item = '':U + {&delim-key} + '':U + {&delim-key} + v-attr-code + {&delim-key} + vvalue
    .
end.
v-no-hist = 0.
run create-{1}-hist in this-procedure ( input {&add-def}
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
define variable glog as logical no-undo .
define variable v-flt-rec as recid no-undo .
define variable v-filter-name as character no-undo .
define variable where-phrase as character no-undo .
define variable sort-phrase as character no-undo .
define variable where-phrase-rus as character no-undo .
define variable sort-phrase-rus as character no-undo .
glog = yes.
message
"Все клиенты, выбранные в соответствии с заданным фильтром  (без учета сортировки)."
 view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
assign
c-point = "cli-list" + {&delim-par} + "Список клиентов" + {&delim-par} + "no"
.

 assign
    tbl = 'clients'
    join-tbl = ''
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
    .
    run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Клиент', 'cli',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('obj-type', 'Тип', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('obj-code', 'Код', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure ('obj-name', 'Название', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('stts', 'Статус', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('is-prod', 'Производитель', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('grp-name', 'Название группы', 'cligrp',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('sup-gds', 'Поставщик товаров', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('sup-cons', 'Консигнант', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('buy-gds', 'Покупатель товаров', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('buy-cons', 'Покупатель консигнационных товаров', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('buy-serv', 'Покупатель услуг', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('lim-kr', 'Лимит кредита', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('PS', 'Примечание', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('db-num', 'Номер БД', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    /* todo
    dim = dim + {&comma-char} + '0':U.
    run fltfield-add in this-procedure('attr-code', 'Атрибут клиента', 'cli-attr',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('attr-val', 'Значение атрибута', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    */
run gbl/filter.w ( input parparentproc
                 , input c-point
                 , input tbl
                 , input join-tbl
                 , input fld
                 , input lab
                 , input spr
                 , input dim).
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
  run create-{1}-hist in this-procedure (
                                        input {&add-def}
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE trig-grp-buy Dialog-Frame
PROCEDURE trig-grp-buy :
define variable glog as logical no-undo .
define variable ii as integer no-undo.
define variable v-ref-list as character no-undo .
define variable v-recs as integer no-undo.
define variable v-ref-rec as recid no-undo .
define variable v-temp-seq as integer no-undo .
define variable v-line as integer no-undo .
define variable v-item as character no-undo .
define variable v-tbl-name as character no-undo .
define variable v-bh as handle no-undo .
define variable v-tot-lns as integer no-undo .
define buffer buf_buyer-group for ub.buyer-group.

glog = yes.
message "Все покупатели по группе."
skip stat-line(rs-status)
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.

run ref/gr-bupr.w (
     input parparentproc
    ,input "b-sel":U
    ,input-output v-ref-list )
    .

if v-ref-list = "" then do:
  return error.
end.
v-recs = num-entries (v-ref-list) .
do num-rec = 0 to v-recs:
  if v-recs = 1 then do:
    num-rec = 1 .
  end.
  if num-rec > 0 then do:
    v-ref-rec = integer (entry (num-rec, v-ref-list)).
    find first buf_buyer-group no-lock where recid (buf_buyer-group) = v-ref-rec no-error .
  end.
  if v-recs = 1 then do:
    assign
    v-temp-seq = v-seq
    v-line     = 0
    dsp-rs = substitute("Из группы покупателей :&1 &2", buf_buyer-group.name, stat-line(rs-status))
    v-item     = '':U
    v-tbl-name = {&table_buyer-group}
    v-bh       = buffer buf_buyer-group:handle
    v-tot-lns = tot-lns
    .
  end.
  else do:
    if num-rec = 0 then do:
      assign
      v-temp-seq = v-seq
      v-line     = 0
      dsp-rs = substitute("Из групп покупателей : &1", stat-line(rs-status))
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
      dsp-rs = substitute("&1", buf_buyer-group.name)
      v-item     = '':U
      v-tbl-name = {&table_buyer-group}
      v-bh       = buffer buf_buyer-group:handle
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
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE trig-turnov-buy Dialog-Frame
PROCEDURE trig-turnov-buy :
define variable glog as logical no-undo .
define variable ii as integer no-undo.
define variable v-ref-list as character no-undo .
define variable v-sum-1 as decimal   no-undo .
define variable v-sum-2 as decimal   no-undo .

for each temp-list-buyer :
  delete temp-list-buyer.
end.
run str/two-sum.w (  input 'sums'
                ,input-output v-sum-1
                ,input-output v-sum-2
                ,output table temp-list-buyer
                ) .
if v-sum-2 = ?  then do:
  return error.
end.

glog = yes.
message
"Все покупатели c оборотом в интервале " skip
v-sum-1 " " v-sum-2 skip
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
run create-{1}-hist in this-procedure (
                input {&add-def}
              , input-output v-seq
              , input 0
              , input '':U
              , input substitute ('Все покупатели c оборотом в интервале с &1 по &2: &3'
                                  , v-sum-1
                                  , v-sum-2
                                  , stat-line(rs-status))
              , input tot-lns
              , input rs-list-method
              , input rs-status
              , input (string(v-sum-1) + {&delim-key} + string(v-sum-2))
              , input ""
              , input ?
              ).
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
    run create-{1}-hist in this-procedure (
                                          input {&add-def}
                                        , input-output v-seq
                                        , input 0
                                        , input get-hist-mode(line-mode)
                                        , input substitute("КЛИЕНТ &1&2 ", {1}.obj-type, {1}.obj-code)
                                        , input tot-lns
                                        , input rs-list-method
                                        , input rs-status
                                        , input ('clients':U + {&delim-key} + {1}.obj-type + {&delim-key} + string({1}.obj-code))
                                        , input '':U
                                        , input ?
                                        ).
  end.
  else do:
    v-temp-seq = v-seq - 1.
    do v-ii = 0 to v-no-hist:
      run create-{1}-hist in this-procedure ( input ({&update} + {&delim-par} + 'mode':U)
                                          , input-output v-temp-seq
                                          , input v-ii
                                          , input get-hist-mode(line-mode)
                                          , input substitute("КЛИЕНТ &12", {1}.obj-type, {1}.obj-code)
                                          , input tot-lns
                                          , input '':U
                                          , input '':U
                                          , input ('clients':U + {&delim-key} + {1}.obj-type + {&delim-key} + string({1}.obj-code))
                                          , input '':U
                                          , input ?
                                          ).
    end.
  end.
end.
else do:
  v-temp-seq = v-seq - 1.
  do v-ii = 0 to v-no-hist:
    run create-{1}-hist in this-procedure (
                                          input ({&update} + {&delim-par} + 'mode':U)
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION is-cashierc Dialog-Frame
FUNCTION is-cashierc RETURNS CHARACTER
( input loc-type as character, input loc-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  if loc-type <> {&prs}
  then return "".
  return string( gbclcode-is-psn-role ( input {&role-cashier}, input loc-code, input ?)).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION is-dis-cardc Dialog-Frame
FUNCTION is-dis-cardc RETURNS CHARACTER
( input loc-type as character, input loc-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  FIND ub.dis-card No-LOCK WHERE
       ub.dis-card.cli-type = loc-type AND
       ub.dis-card.cli-code = loc-code No-ERROR.
  if avail ub.dis-card then return ub.dis-card.d-card.
  else do:
    if AMBIGUOUS dis-card then do:
        return "............":U.
    end.
    else return "".
  end.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION is-sellerc Dialog-Frame
FUNCTION is-sellerc RETURNS CHARACTER
( input loc-type as character, input loc-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  if loc-type <> {&prs}
  then return "".
  return string( gbclcode-is-psn-role ( input {&role-seller}, input loc-code, input ?)).

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
    var-stat-line = "(текущие и удаленные клиенты)"
    .
  end.
  when {&current} then do:
    assign
    var-stat-line = "(текущие клиенты)"
    .
  end.
  when {&deleted} then do:
    assign
    var-stat-line = "(удаленные клиенты)"
    .
  end.
END CASE.


return var-stat-line .


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* $Workfile$ e n d */