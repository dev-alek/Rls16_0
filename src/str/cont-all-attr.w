&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник договоров

Автор: Чернова Светлана Александровна
Дата создания: 09/14/05
Author: Svetlana Chernova
Creation date: 09/14/05

    ! ! !  В Н И М А Н И Е  ! ! !   не забудь: после исправления файла в UIB   САМОЕ ГЛАВНОЕ - подставить new shared в DEFINE QUERY contr-list !!!!!!!
*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-host-code    as integer   no-undo . /* надо передавать фирму */
define input  parameter bttns          as character no-undo . /*кнопки для нажатия*/
define input  parameter p-mode         as character no-undo . /* {&company} или {&all} или "contract-type=... или firm-curr " */
define input  parameter p-cli-type     as character no-undo . /* ? - все контрагенты, или указать */
define input  parameter p-cli-code     as integer   no-undo . /* ? - все контрагенты, или указать */
define input  parameter p-mngr-type    as character no-undo . /* ? - все исполнители, или {&prs} */
define input  parameter p-mngr-code    as integer   no-undo . /* ? - все исполнители, или указать */
define input  parameter p-status       as character no-undo . /* "all", "current" "deleted" */
define input  parameter p-doc-type     as character no-undo . /* "all", {&income} {&expense} */
define input  parameter p-attr-code    as character no-undo . /* атрибут */
define input-output param p-rid-list   as character no-undo . /* recid выбранных договоров */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Список договоров" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ ref/ficr-db.i  }
{ gbl/getcntxt.i def }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
{ gbl/thbjattr.i}
{ str/cont-ms.i}

define NEW SHARED  buffer buf_contract for ub.contract.
define NEW shared  buffer buf_contract-attr for ub.contract-attr .

define new shared variable br-handle as handle  no-undo .
define new shared variable next-prev as logical no-undo .
define variable p-contr-type as character no-undo .

function fo return character ( input p-cr-fo as logical, input p-fo-date as date, input p-need-fo as integer ) .
 if p-cr-fo = yes then do:
   return string (p-fo-date, "99/99/99").
 end.
 else do:
   if p-need-fo = 0 then return "--------".
   if p-need-fo = 1 then return "".
   if p-need-fo = 2 then return "не опред".
 end.
end function.


define variable agnt-list as character no-undo .
define variable org-list  as character no-undo .
define variable g-log     as logical   no-undo .
define variable  p-sys-date     as date      no-undo .
define variable  p-sys-time     as character no-undo .
define variable  p-sys-time-int as integer   no-undo .
define variable v-type as character no-undo .
/* */
define variable v-doc-rec as recid no-undo .
define variable filter-point as character no-undo init "Список договоров" .
define variable filter-point0 as character no-undo init "Список договоров" .
define variable sort-column-name as character no-undo .
define variable vari as integer   no-undo .
/*  */
DEFINE VARIABLE v-Character   AS CHARACTER  NO-UNDO .
DEFINE VARIABLE v-Date        AS DATE       NO-UNDO .
DEFINE VARIABLE v-Decimal     AS DECIMAL    NO-UNDO .
DEFINE VARIABLE v-iMcMode     AS INTEGER    NO-UNDO . /* параметр fin-global/fo-mc-mode */
DEFINE VARIABLE v-Logical     AS LOGICAL    NO-UNDO .
DEFINE VARIABLE v-Param-Type  AS CHARACTER  NO-UNDO .
/*  */
DEFINE VARIABLE iTmp-Host-Code     AS INTEGER   NO-UNDO INITIAL 0.
DEFINE VARIABLE iTmp-Contract-Code AS INTEGER   NO-UNDO INITIAL 0.
DEFINE VARIABLE cTmp-Mode-W        AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE i-Cont-Ret         AS INTEGER   NO-UNDO INITIAL 0 EXTENT 3.
DEFINE VARIABLE iTmp               AS INTEGER   NO-UNDO INITIAL 0.
define variable v-contract-code    as integer   no-undo .
/* для импорта цен поставки к задаче 4826 */
define temp-table t-imp-price no-undo
  field contract-code as integer /* A1 = Номер договора в ТН (системный код) */
  field firm-code     as integer /* B1 = Код контрагента (системный код) */
  field gds-code      as integer /* С1 = Код товара в ТН */
  field price-rubl    as decimal /* D1 = Цена товара с НДС */
  field vat-pc        as decimal /* E1 = Ставка НДС */
  field prc-up        as decimal /* F1 = % отклонения в большую сторону */
  field prc-dn        as decimal /* G1 = % отклонения в меньшую сторону */
  field gds-name      as character /* H1 = Наименование товара */
  field firm-name     as character /* I1 = Наименование контрагента */
  field line-num      as integer /* номер строки в импортируемом excel-файле */
.
define stream f-log-imp .

/*  */
/* Переменная определяющая дополнительный фильтр контрактов
   для Master/Slave договоров
   Берем ее из ENTRY(2, p-Mode, "|")
   "0" - свободный договор
   "1" - мастер договор
   "2" - подчиненный договор
*/
DEFINE VARIABLE v-MS-Can-Do-List as CHARACTER NO-UNDO INITIAL "".


/* сразу переопределяем p-Mode и устанавливаем  v-MS-Can-Do-List  */
ASSIGN
   v-MS-Can-Do-List  = (if NUM-ENTRIES(p-Mode, "|") >= 2 THEN  ENTRY(2, p-Mode, "|") ELSE "")
   p-Mode            = ENTRY(1, p-Mode, "|")
   .


/* Снимаем глобальные настройки fo-mc-mode  */
RUN adm/shattri.p (
      INPUT  "get":U,
      INPUT  "",            /* тип объекта  */
      INPUT  0,             /* код объекта  */
      INPUT  "fin-global",  /* название секции   */
      INPUT  "fo-mc-mode",  /* название параметра   */
      OUTPUT v-Character,
      OUTPUT v-Date,
      OUTPUT v-Decimal,
      OUTPUT v-iMcMode,     /* Здесь возвращается параметр fo-mc-mode 0 - старая схема  */
      OUTPUT v-Logical,
      OUTPUT v-Param-Type,
      INPUT-OUTPUT TABLE thbjattr_thbj-attr
    ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
   MESSAGE
      "Ошибка определения глобалоного параметра fin-global/fo-mc-mode" SKIP
      PROGRAM-NAME(1) ERROR-STATUS:GET-MESSAGE(1) RETURN-VALUE
      VIEW-AS ALERT-BOX.
END.


/* VISIBLE или нет эта колонка определяется дальше, поиск колонки по LABEL  */
&SCOPED-DEFINE MC_LABEL_COLUMN 'Мастер!Договор'

&Scoped-define line-num 9

&SCOP label-clmn_1   '*'
&SCOP clmn_1         mark-string(recid(buf_contract), p-rid-list)
&SCOP label-clmn_2   'Ста!тус'
&SCOP clmn_2         buf_contract.status_
&SCOP label-clmn_3   'Номер'
&SCOP clmn_3         buf_contract.contract-prn-code
&SCOP label-clmn_4   'Дата!договора'
&SCOP clmn_4         buf_contract.contract-date
&SCOP label-clmn_5   'Заголовок'
&SCOP clmn_5         buf_contract.contract-name
&SCOP label-clmn_6   'Тип/код!контрагента'
&SCOP clmn_6         (if buf_contract.cli-type = '' then '' else TRIM (buf_contract.cli-type + ' ' + STRING (buf_contract.cli-code) ))
&SCOP label-clmn_7   'Контрагент'
&SCOP clmn_7         buf_contract.cli-name
&SCOP label-clmn_8   'Тип договора'
&SCOP clmn_8         buf_contract.contract-type
&SCOP label-clmn_9   'Условия!оплаты'
&SCOP clmn_9         buf_contract.usl-opl
&SCOP label-clmn_10  'Отс-!роч.'
&SCOP clmn_10        (if buf_contract.srok-opl > 0 then string(buf_contract.srok-opl) else '')
&SCOP label-clmn_11  'Город'
&SCOP clmn_11        buf_contract.contract-city
&SCOP label-clmn_12  'Начало!действия'
&SCOP clmn_12        buf_contract.contract-date-beg
&SCOP label-clmn_13  'Окончание!действия'
&SCOP clmn_13        buf_contract.contract-date-end
&SCOP label-clmn_14  'Вал'
&SCOP clmn_14        get-currency(buf_contract.curr-code)
&SCOP dyn_clmn_14    substitute('dynamic-function(&1get-currency&1, &1&2&1)', ~{&double-quote~}, buf_contract.curr-code)
&SCOP label-clmn_15  'Тип/код!посредника'
&SCOP clmn_15        (if buf_contract.posr-type = '' then '' else TRIM (buf_contract.posr-type + ' ' + STRING (buf_contract.posr-code)))
&SCOP label-clmn_16  'Посредник'
&SCOP clmn_16        buf_contract.posr-name
&SCOP label-clmn_17  'Тип/код!агента'
&SCOP clmn_17        (if buf_contract.agnt-type = '' then '' else TRIM (buf_contract.agnt-type + ' ' + STRING (buf_contract.agnt-code)))
&SCOP label-clmn_18  'Агент'
&SCOP clmn_18        buf_contract.agnt-name
&SCOP label-clmn_19  'Исполнитель'
&SCOP clmn_19        get-agent( buf_contract.mngr-code)
&SCOP dyn_clmn_19    substitute('dynamic-function(&1get-agent&1, &1&2&1)', ~{&double-quote~}, buf_contract.mngr-code)
&SCOP label-clmn_20  'Вид'
&SCOP clmn_20        buf_contract.doc-type
&SCOP label-clmn_21  'Вн.н.'
&SCOP clmn_21        buf_contract.contract-code
&SCOP label-clmn_22  'Фин.об.'
&SCOP clmn_22        fo( buf_contract.cr-fo, buf_contract.fo-date, buf_contract.need-fo )
&SCOP dyn_clmn_22    substitute('dynamic-function(&1fo&1, &1&2&1, &1&3&1, &1&4&1)', ~{&double-quote~}, buf_contract.cr-fo, buf_contract.fo-date, buf_contract.need-fo)
&SCOP label-clmn_23   'БД'
&SCOP clmn_23         buf_contract.db-num
&SCOP label-clmn_24   {&MC_LABEL_COLUMN}
&SCOP clmn_24         Is-Master-Slave-Contract( BUFFER buf_Contract)



&SCOP disp-list ~
 {&clmn_1 }            column-label {&label-clmn_1 } format "x(1)" ~
 {&clmn_2 }            column-label {&label-clmn_2 } format "x(4)" ~
 {&clmn_3 }            column-label {&label-clmn_3 } format "x(48)" ~
 {&clmn_4 }            column-label {&label-clmn_4 } format "99/99/99" ~
 {&clmn_5 }            column-label {&label-clmn_5 } format "x(20)"  ~
 {&clmn_6 }   @ v-type column-label {&label-clmn_6 } format "x(13)" ~
 {&clmn_7 }            column-label {&label-clmn_7 } ~
 {&clmn_8 }            column-label {&label-clmn_8 } format "x(23)" ~
 {&clmn_9 }            column-label {&label-clmn_9 } format "X(32)" ~
 {&clmn_10 }           column-label {&label-clmn_10 } format "X(4)" ~
 {&clmn_11 }           column-label {&label-clmn_11 } format "X(14)" ~
 {&clmn_12 }           column-label {&label-clmn_12 } format "99/99/99" ~
 {&clmn_13 }           column-label {&label-clmn_13 } format "99/99/99" ~
 {&clmn_14 }           column-label {&label-clmn_14 } format "X(3)" ~
 {&clmn_15 }           column-label {&label-clmn_15 } format "x(13)" ~
 {&clmn_16 }           column-label {&label-clmn_16 } ~
 {&clmn_17 }           column-label {&label-clmn_17 } format "x(13)" ~
 {&clmn_18 }           column-label {&label-clmn_18 } ~
 {&clmn_19 }           column-label {&label-clmn_19 } format "x(40)" ~
 {&clmn_20 }           column-label {&label-clmn_20 } ~
 {&clmn_21 }           column-label {&label-clmn_21 } format ">>>>>>>>>9"  ~
 {&clmn_22 }           column-label {&label-clmn_22 } format "x(8)" ~
 {&clmn_23 }           column-label {&label-clmn_23 } ~
 {&clmn_24 }           column-label {&label-clmn_24 } format "x(10)"


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME Contr-List

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_contract buf_contract-attr

/* Definitions for BROWSE Contr-List                                    */
&Scoped-define FIELDS-IN-QUERY-Contr-List (mark-string(recid(buf_contract), p-rid-list)) buf_contract.status_ buf_contract.contract-prn-code buf_contract.contract-date buf_contract.contract-name if buf_contract.cli-type = "" then "" else TRIM (buf_contract.cli-type + " " + STRING (buf_contract.cli-code)) buf_contract.cli-name buf_contract.contract-type buf_contract.usl-opl if buf_contract.srok-opl > 0 then string(buf_contract.srok-opl) else "" buf_contract.contract-city buf_contract.contract-date-beg buf_contract.contract-date-end (get-currency(buf_contract.curr-code)) if buf_contract.posr-type = "" then "" else TRIM (buf_contract.posr-type + " " + STRING (buf_contract.posr-code)) buf_contract.posr-name if buf_contract.agnt-type = "" then "" else TRIM (buf_contract.agnt-type + " " + STRING (buf_contract.agnt-code)) buf_contract.agnt-name (get-agent(buf_contract.mngr-code)) buf_contract.doc-type
&Scoped-define ENABLED-FIELDS-IN-QUERY-Contr-List buf_contract.status_
&Scoped-define FIELD-PAIRS-IN-QUERY-Contr-List~
 ~{&FP1}{&clmn_8 } ~{&FP2}{&clmn_8 } ~{&FP3}
&Scoped-define ENABLED-TABLES-IN-QUERY-Contr-List buf_contract
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Contr-List buf_contract
&Scoped-define SELF-NAME Contr-List
&Scoped-define OPEN-QUERY-Contr-List OPEN QUERY {&SELF-NAME} FOR EACH buf_contract NO-LOCK indexed-reposition, ~
first buf_contract-attr where buf_contract-attr.host-code = buf_contract.host-code and buf_contract-attr.attr-code = p-attr-code and ~
buf_contract-attr.attr-value = string(true).
&Scoped-define TABLES-IN-QUERY-Contr-List buf_contract
&Scoped-define FIRST-TABLE-IN-QUERY-Contr-List buf_contract
&Scoped-define SECOND-TABLE-IN-QUERY-Contr-List buf_contract-attr


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit RECT-status B-mark B-sel b-gen ~
b-sch b-SlaveConract b-spec b-specgrp B-Help B-lkp b-chg b-del b-open B-fin-ob B-fin-doc b-hist B-add ~
Contr-List sch-code sch-date Cli-Types Agnt-Types Cli-Status mark-num B-exp
&Scoped-Define DISPLAYED-OBJECTS sch-code sch-date Cli-Types Agnt-Types ~
Cli-Status mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-agent Dialog-Frame
FUNCTION get-agent RETURNS CHARACTER
  ( input agnt-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-char-to-dec Dialog-Frame
FUNCTION func-char-to-dec RETURNS DECIMAL
  ( input iCh AS CHARACTER) forward .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-currency Dialog-Frame
FUNCTION get-currency RETURNS CHARACTER
  ( input curr-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid, input mark-list as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-b-gen
       MENU-ITEM m_gen-1        LABEL "Фин. обязательство"
       MENU-ITEM m_gen-2        LABEL "Отказаться от генерации ФО"
       MENU-ITEM m_gen-3        LABEL "Снять признак - есть генерация ФО"
       MENU-ITEM m_gen-4        LABEL "Снять 'не опред'".

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Закрыть"
     SIZE 10 BY 1.

DEFINE BUTTON B-fin-doc
     LABEL "П&латежи"
     SIZE 10 BY 1.

DEFINE BUTTON B-exp
     LABEL "&Экспорт"
     SIZE 10 BY 1.

DEFINE BUTTON B-imp
     LABEL "Импорт"
     SIZE 10 BY 1.

DEFINE BUTTON B-fin-ob
     LABEL "Фи&н.обяз."
     SIZE 10 BY 1.

DEFINE BUTTON b-trn-doc
     LABEL "&Скл.док."
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-open
     LABEL "&Открыть"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit  AUTO-GO   /* AUTO-END-KEY */
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 10 BY 1.

DEFINE BUTTON b-SlaveContract
     LABEL "Под&чДог"
     SIZE 10 BY 1.

DEFINE BUTTON b-spec
     LABEL "Спе&цификация"
     SIZE 15 BY 1.

DEFINE BUTTON b-specgrp
     LABEL "Специф&Груп"
     SIZE 15 BY 1.


DEFINE BUTTON b-order
     LABEL "&Заказы"
     SIZE 10 BY 1.

DEFINE BUTTON b-gen
     LABEL "&Генерация"
     SIZE 10 BY 1.


DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE user-name AS CHARACTER FORMAT "X(18)"
     LABEL "Опер"
      VIEW-AS TEXT
     SIZE 18 BY 1 NO-UNDO.

DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(14)"
     LABEL "&Начало номера"
     VIEW-AS FILL-IN
     SIZE 15 BY .92 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-date AS DATE FORMAT "99/99/9999"
     LABEL "Д&ата"
     VIEW-AS FILL-IN
     SIZE 11.5 BY .92 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE Agnt-Types AS CHARACTER INITIAL "all"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", "all",
"Выбор", "sel"
     SIZE 15 BY .79 NO-UNDO.

DEFINE VARIABLE Cli-Status AS CHARACTER INITIAL "current"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущие&+", "current",
"Все&!", "all",
"Закрытые&-", "deleted"
     SIZE 30 BY .79 NO-UNDO.

DEFINE VARIABLE Cli-Types AS CHARACTER INITIAL "all"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", "all",
"Выбор", "sel"
     SIZE 15.38 BY .79 NO-UNDO.

DEFINE RECTANGLE RECT-status
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98.8 BY 1.13.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Contr-List FOR  buf_contract,buf_contract-attr SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE Contr-List
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS Contr-List Dialog-Frame _FREEFORM
  QUERY Contr-List DISPLAY {&disp-list}
      enable {&clmn_8 }
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.88 BY 17.79.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit    AT ROW 1 COL 1
     B-mark    AT ROW 1 COL 11
     B-sel     AT ROW 1 COL 21
     B-add     AT ROW 1 COL 31
     B-lkp     AT ROW 1 COL 41
     b-chg     AT ROW 1 COL 51
     b-open    AT ROW 1 COL 61
     b-del     AT ROW 1 COL 71
     b-gen     AT ROW 1 COL 81
     B-Help    AT ROW 1 COL 91
     b-spec    AT ROW 2 COL 1
     b-specgrp    AT ROW 2 COL 16
     b-trn-doc AT ROW 2 COL 31
     b-order   at row 2 col 41
     B-fin-ob  AT ROW 2 COL 51
     B-fin-doc AT ROW 2 COL 61
     b-exp     AT ROW 2 COL 71
     b-imp     AT ROW 2 COL 81
     b-sch     AT ROW 2 COL 91
     b-SlaveContract AT ROW 2 COL 91  /* Подчиненные договоры */
     b-hist    AT ROW 2 COL 101

     Contr-List AT ROW 3 COL 1.25
     sch-code AT ROW 21 COL 23.25 COLON-ALIGNED
     sch-date AT ROW 21 COL 45.5 COLON-ALIGNED
     Cli-Types AT ROW 22.21 COL 14.13 NO-LABEL
     Agnt-Types AT ROW 22.21 COL 43.63 NO-LABEL
     Cli-Status AT ROW 22.21 COL 67.25 NO-LABEL
     mark-num AT ROW 1 COL 14 NO-LABEL
/*     user-nm  at row 21 COL 80*/
     user-name at row 21 col 80 COLON-ALIGNED LABEL "Опер" VIEW-AS FILL-IN SIZE 18 BY 1 fgcolor 4
     "Статус:" VIEW-AS TEXT
          SIZE 7.38 BY .79 AT ROW 22.21 COL 59.63
          FGCOLOR 4
     RECT-status AT ROW 22.13 COL 1
     "Поиск:" VIEW-AS TEXT
          SIZE 7.38 BY .92 AT ROW 21 COL 2.5
          FGCOLOR 4
     "Исполнители:" VIEW-AS TEXT
          SIZE 12.38 BY .79 AT ROW 22.21 COL 30.88
          FGCOLOR 4
     "Контрагенты:" VIEW-AS TEXT
          SIZE 12.13 BY .79 AT ROW 22.21 COL 1.88
          FGCOLOR 4
     SPACE(84.86) SKIP(0.37)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Договоры"
         DEFAULT-BUTTON b-quit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB Contr-List B-add Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-gen:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-gen:HANDLE.
/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE Contr-List
/* Query rebuild information for BROWSE Contr-List
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_contract NO-LOCK indexed-reposition.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE Contr-List */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON END-ERROR OF FRAME Dialog-Frame /* Договоры */
DO:
  run gbl/markqwa.p (input b-mark:sensitive, input p-rid-list) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ENDKEY OF FRAME Dialog-Frame /* Договоры */
DO:
  run gbl/markqwa.p (input b-mark:sensitive, input p-rid-list) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Договоры */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Agnt-Types
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Agnt-Types Dialog-Frame
ON VALUE-CHANGED OF Agnt-Types IN FRAME Dialog-Frame
DO:
  assign Agnt-Types .
  if Agnt-Types = "sel" then  do:
    run proc-sel-agent in this-procedure .
  end.
  RUN OpenBr(yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_add-def':U
    {&cntxt-firm}
    p-host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then return no-apply .

  run run-contr in this-procedure ({&add-def}, no) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-order
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-order Dialog-Frame
ON CHOOSE OF B-order IN FRAME Dialog-Frame /* Заказ */
DO:

define variable v-list as character no-undo .
if not avail buf_contract then return no-apply.
  run cus/zakz-rcv.w (
   input   parparentproc
  ,input   "all":U
  ,input   "all":U
  ,input   "contract":U
  ,input   recid( buf_contract )
  ,input   "b-lkp,nob-exec,nob-copy"
  ,input   ""
  ,output  v-list )
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  if not avail buf_contract then return no-apply.


  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_update':U
    {&cntxt-firm}
    p-host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then return no-apply .

  /* Проверка прав на измениение Мастер или Slave договора */
  ASSIGN
     iTmp = Is-MS-Contract-Int (BUFFER buf_Contract).
  /*  */
  CASE iTmp:
       WHEN 1 THEN DO:      /* Мастер  */
             { gbl/chk-actg.i
                   v-cntxt-db-num
                   v-cntxt-userid
                   {&action-head-code-main}
                   'actn_fo-mc_master-modify':U
                   {&cntxt-firm}
                   p-host-code
                   '':U
                   0
                   0
                   0
                   0
                   true
                   g-log
             }
             if not g-log then return no-apply.

       END.
       /*  */
       WHEN 2 THEN DO:     /* Подчиненный */
             { gbl/chk-actg.i
                   v-cntxt-db-num
                   v-cntxt-userid
                   {&action-head-code-main}
                   'actn_fo-mc_slave-modify':U
                   {&cntxt-firm}
                   p-host-code
                   '':U
                   0
                   0
                   0
                   0
                   true
                   g-log
             }
             if not g-log then return no-apply.
       END.
  END CASE.
  /*  */
  run run-contr in this-procedure ({&update}, no) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Закрыть */
DO:
  if not avail buf_contract then return no-apply.
  run proc-del in this-procedure no-error .
  if error-status:error then return no-apply.

  if Cli-Status = "current" then do:
    g-log = Contr-List:select-next-row().
    if not g-log then g-log = Contr-List:select-prev-row().
    v-doc-rec = recid( buf_contract ).
  end.
  RUN OpenBr(yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-fin-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-fin-doc Dialog-Frame
ON CHOOSE OF B-fin-doc IN FRAME Dialog-Frame /* Платежи */
DO:
  define variable ri as character no-undo .
  if available  buf_contract then do:
    run ref/findocs.w (input parParentProc, input p-host-code,  input "b-add,b-upd,b-del", input "contract-host":U, input {&all},
                  input p-host-code, input "":U, input 0, input ?, input ?, input ?, input ?, input ?, input ?, input ?, input ?, input ?,
                  input ?, input ?,  input ?, input ?, input ?, input ?, input buf_contract.contract-code,
                  input ?, input ?, input ?, input ?, input-output ri ) no-error .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
&Scoped-define SELF-NAME B-fin-ob
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-fin-ob Dialog-Frame
ON CHOOSE OF B-fin-ob IN FRAME Dialog-Frame /* Фин. обяз. */
DO:
  define variable ri as character no-undo .
  if available buf_contract THEN do:
    run str/fin-liab.w ( input parParentProc, input "b-chg,b-del,b-mark", input "contract":U, input ?, input p-host-code,
                     input ?, input ?, string(buf_contract.contract-code), output ri) no-error .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-trn-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-trn-doc Dialog-Frame
ON CHOOSE OF B-trn-doc IN FRAME Dialog-Frame /* Скл. ljc. */
DO:
  define variable ri as character no-undo .
  if available buf_contract THEN do:
    run str/strncntr.w ( input buf_contract.host-code, input buf_contract.contract-code).
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exp Dialog-Frame
ON CHOOSE OF B-exp IN FRAME Dialog-Frame /* Экспорт */
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_export':U
    {&cntxt-firm}
    p-host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .
  RUN proc-b-exp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-imp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-imp Dialog-Frame
ON CHOOSE OF B-imp IN FRAME Dialog-Frame /* Импорт */
DO:
  RUN proc-b-imp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
ON CHOOSE OF b-hist IN FRAME Dialog-Frame /* История */
DO:
  define variable v-ri as character initial "" no-undo .
  if available buf_contract then run str/contr-c.w (input parparentproc,input p-host-code, input buf_contract.contract-code,input "",input-output v-ri) .
/*  apply "entry" to Contr-List .*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-spec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-spec Dialog-Frame
ON CHOOSE OF b-spec IN FRAME Dialog-Frame /* Спецификация */
DO:
  define variable v-rid-list as char no-undo.
  if available buf_contract then DO:
     /* устанавливаем переменные запуска интерфейса спецификации,
        если договор закрыт - спецификацию только на просмотр   */
     ASSIGN
        iTmp-Host-Code       = p-host-code
        iTmp-Contract-Code   = buf_contract.contract-code
        cTmp-Mode-W          = (IF buf_contract.status_ = {&close-contr} THEN {&lookup} ELSE {&update})
        .
     /* Если работаем по схеме с матер договорами, в случае работы с подчиненным договором
        устанавливаем параметры от мастер договора !!!  */
     IF v-iMcMode = 1 OR v-iMcMode = 2 THEN DO:
        /* Проверяем договор !!!  */
        RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
            INPUT  p-Host-Code,
            INPUT  buf_contract.contract-code,
            OUTPUT i-Cont-Ret
            ).
        /* Если у договора есть мастер договор -
           переназначаем Host-code и Contract-code,\
           чтобы спецификация бралась из мастер договора
        */
        IF i-Cont-Ret[1] = 2 THEN DO: /* подчиненный договор  */
           ASSIGN
              iTmp-Host-Code       = i-Cont-Ret[2]
              iTmp-Contract-Code   = i-Cont-Ret[3]
              cTmp-Mode-W          = {&lookup}
              .
        END.
     END.
     /*  */
     RUN str/contspec.w (
         INPUT  parparentproc,
         INPUT  "b-mark",
         INPUT  cTmp-Mode-W,
         INPUT  iTmp-Host-Code,
         INPUT  iTmp-Contract-Code,
         OUTPUT v-rid-list
         ).
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-specgrp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-specgrp Dialog-Frame
ON CHOOSE OF b-specgrp IN FRAME Dialog-Frame /* Спецификация по группам */
DO:
  define variable v-rid-list as char no-undo.
  if available buf_contract then do:
     /* устанавливаем переменные запуска интерфейса */
     ASSIGN
        iTmp-Host-Code       = p-host-code
        iTmp-Contract-Code   = buf_contract.contract-code
        cTmp-Mode-W          = {&update}
        .
     /* Если работаем по схеме с матер договорами, в случае работы с подчиненным договором
        устанавливаем параметры от мастер договора !!!  */
     IF v-iMcMode = 1 OR v-iMcMode = 2 THEN DO:
        /* Проверяем договор !!!  */
        RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
            INPUT  p-Host-Code,
            INPUT  buf_contract.contract-code,
            OUTPUT i-Cont-Ret
            ).
        /* Если у договора есть мастер договор -
           переназначаем Host-code и Contract-code,\
           чтобы спецификация бралась из мастер договора
        */
        IF i-Cont-Ret[1] = 2 THEN DO: /* подчиненный договор  */
           ASSIGN
              iTmp-Host-Code       = i-Cont-Ret[2]
              iTmp-Contract-Code   = i-Cont-Ret[3]
              cTmp-Mode-W          = {&lookup}
              .
        END.
     END.
     /*  */
     run str/specgrp.w
       ( input parparentproc,
         INPUT iTmp-Host-Code /* p-host-code */ ,
         INPUT iTmp-Contract-code  /* buf_contract.contract-code */ ,
         input "b-mark",
         input v-cntxt-obj-type,
         input v-cntxt-obj-code,
         input-output v-rid-list) .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp Dialog-Frame
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  if not avail buf_contract then return no-apply.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_lookup':U
    {&cntxt-firm}
    p-host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then return no-apply .
  run run-contr in this-procedure ({&lookup}, yes) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_gen-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_gen-1 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_gen-1 /* Генерация */
DO:
run proc-m_gen-1 no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_gen-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_gen-2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_gen-2 /* Отказаться от генерации счета-фактуры */
DO:
run proc-m_gen-2 no-error .
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_gen-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_gen-3 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_gen-3 /* Снять признак - есть генерация счета-фактуры */
DO:
run proc-m_gen-3 no-error .
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_gen-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_gen-4 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_gen-4 /* Снять 'не опред' */
DO:
run proc-m_gen-4 no-error .
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  if available buf_contract then   do:
    if can-do( p-rid-list, string( recid( buf_contract ) ) ) then  do:
            p-rid-list = replace( p-rid-list, {&comma-char} + string( recid( buf_contract ) ), "") .
            p-rid-list = replace( p-rid-list, string( recid( buf_contract ) ) + {&comma-char}, "") .
            p-rid-list = replace( p-rid-list, string( recid( buf_contract ) ), "") .
    end.
    else  p-rid-list = p-rid-list + ( if p-rid-list = "" then "" else {&comma-char} ) + string( recid( buf_contract ) ) .
    g-log = Contr-List:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then  do:
      g-log = Contr-List:select-next-row ().
      apply "value-changed" to Contr-List in frame {&frame-name}.
    end.
    if num-entries( p-rid-list ) = 0 then hide mark-num in frame {&frame-name}.
    else   display num-entries( p-rid-list ) @ mark-num  with frame {&frame-name}.
  end.
  apply "entry" to Contr-List .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-open
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-open Dialog-Frame
ON CHOOSE OF b-open IN FRAME Dialog-Frame /* Открыть */
DO:
  if not avail buf_contract then return no-apply.

  run proc-open in this-procedure no-error .
  if error-status:error then return no-apply.

  if Cli-Status = "deleted" then do:
    g-log = Contr-List:select-next-row().
    if not g-log then g-log = Contr-List:select-prev-row().
    v-doc-rec = recid( buf_contract ).
  end.

  RUN OpenBr(yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Contr-List Dialog-Frame
ON ROW-DISPLAY OF  {&browse-name} IN FRAME Dialog-Frame
DO:
  if available buf_contract then do:
     if buf_contract.contract-date-end < today then do:
        buf_contract.contract-date-end:bgcolor  in browse {&browse-name} =  8.
        {&clmn_2}:bgcolor  in browse {&browse-name} =  8.
        {&clmn_3}:bgcolor  in browse {&browse-name} =  8.
        {&clmn_4}:bgcolor  in browse {&browse-name} =  8.
        v-type:bgcolor  in browse {&browse-name} =  8.
        {&clmn_5}:bgcolor  in browse {&browse-name} =  8.
        {&clmn_7}:bgcolor  in browse {&browse-name} =  8.
     end.
     else do:
        buf_contract.contract-date-end:bgcolor  in browse {&browse-name} =  ?.
        {&clmn_2}:bgcolor  in browse {&browse-name} =  ?.
        {&clmn_3}:bgcolor  in browse {&browse-name} =  ?.
        {&clmn_4}:bgcolor  in browse {&browse-name} =  ?.
        {&clmn_5}:bgcolor  in browse {&browse-name} =  ?.
        {&clmn_7}:bgcolor  in browse {&browse-name} =  ?.
        v-type:bgcolor  in browse {&browse-name} =  ?.
     end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-m_gen-1 Dialog-Frame
PROCEDURE proc-m_gen-1 :
  do on error undo, return error return-value :
    if p-rid-list = "" then do:
      if available buf_contract then assign p-rid-list = string(recid(buf_contract)).
      else do:
        return error "Не выделено ни одного договора для генерации ФО !". .
      end.
    end.
    define buffer bf_contract for ub.contract.
    g-log = yes.
    message "Выбрано " + string( num-entries( p-rid-list)  ) + " договоров . Провести генерацию ФО ?" skip
    view-as alert-box question buttons OK-Cancel update g-log.
    if not g-log then return no-apply.

    define variable res as character no-undo .
    run str/gen-flsp.p ( INPUT parParentProc, input p-host-code, input ?, input 0, input p-rid-list, input-output res) no-error .
    if error-status:error then  message "Ошибка создания ФО " view-as alert-box.
    if  res <> "" then message res view-as alert-box information .
    assign p-rid-list = "" .
    RUN OpenBr(yes, no, '':U) .
  end. /* do */
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-m_gen-2 Dialog-Frame
PROCEDURE proc-m_gen-2 :

define buffer bf_contract for ub.contract.

do on error undo, return error return-value
:
    if p-rid-list = "" then do:
      if available buf_contract then assign p-rid-list = string(recid(buf_contract)).
    end.
vari-cycle:
  do vari = 1 to num-entries (p-rid-list):
    find first bf_contract where recid(bf_contract) = integer(entry (vari, p-rid-list)) exclusive-lock.
    if bf_contract.status_ <> {&current-contr} then do:
      message "Договор " bf_contract.contract-prn-code " не в статусе " {&current-contr} " . Пропускаем." view-as alert-box.
      next vari-cycle.
    end.
    if bf_contract.cr-fo = yes then do:
      message "По договору " bf_contract.contract-prn-code " уже создавалось ФО от " bf_contract.fo-date " числа." view-as alert-box.
      next vari-cycle.
    end.
    else do:
      if bf_contract.need-fo = 1 or bf_contract.need-fo = 2 then assign  bf_contract.need-fo = 0.
      else do:
        message "Данный договор не нуждался в генерации ФО." view-as alert-box.
        next vari-cycle.
      end.
      reposition {&browse-name} to recid recid(bf_contract) no-error.
      if not error-status:error then do:
/*        display fo (buffer bf_contract) @ varfo with browse {&browse-name}.*/
      end.
    end.
  end.
  assign p-rid-list = "".
end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-m_gen-3 Dialog-Frame
PROCEDURE proc-m_gen-3 :

define buffer bf_contract for ub.contract.
define buffer buf_fin-ob-trn for ub.fin-ob-trn.

do on error undo, return error return-value
:
  if p-rid-list = "" then do:
    if available buf_contract then assign p-rid-list = string(recid(buf_contract)).
  end.

vari-cycle:
  do vari = 1 to num-entries (p-rid-list):
    find first bf_contract where recid(bf_contract) = integer(entry (vari, p-rid-list)) exclusive-lock.
    if bf_contract.status_ <> {&current-contr} then do:
      message "Договор " bf_contract.contract-prn-code " не в статусе " {&current-contr} " . Пропускаем." view-as alert-box.
      next vari-cycle.
    end.
    find first buf_fin-ob-trn no-lock
      where buf_fin-ob-trn.host-code      = p-host-code
        and buf_fin-ob-trn.doc-type       = "spc"
        and buf_fin-ob-trn.trn-doc-code   = string(bf_contract.contract-code)
    no-error .
    if bf_contract.cr-fo = yes or available buf_fin-ob-trn then do:
      assign g-log = no.
      message "По договору " bf_contract.contract-prn-code " было создано ФО от " bf_contract.fo-date " . Для правильной работы удалите его или создайте корректирующее ФО!" skip
                "Вы действительно хотите снять признак, что по этому договору было ФО?"
      view-as alert-box question buttons yes-no update g-log.
      if g-log <> yes then  next vari-cycle.
      assign
        bf_contract.cr-fo   = no
        bf_contract.fo-date = 01/01/1990
      .
      reposition {&browse-name} to recid recid(bf_contract) no-error.
    end.
    else do:
      message "По договору " bf_contract.contract-prn-code " не было генерации."
      view-as alert-box.
   end.
 end.
 assign p-rid-list = "".
end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-m_gen-4 Dialog-Frame
PROCEDURE proc-m_gen-4 :
  do on error undo, return error return-value :
    if p-rid-list = "" then do:
      if available buf_contract then assign p-rid-list = string(recid(buf_contract)).
    end.

    define buffer bf_contract for ub.contract.

vari-cycle:
    do vari = 1 to num-entries (p-rid-list):
      find first bf_contract where recid(bf_contract) = integer(entry (vari, p-rid-list)) exclusive-lock.
      if bf_contract.status_ <> {&current-contr} then do:
        message "Договор " bf_contract.contract-prn-code " не в статусе " {&current-contr} " . Пропускаем."  view-as alert-box.
        next.
      end.
      if bf_contract.need-fo = 2 /*and bf_contract.usl-opl = {&contr-pay-spec} or bf_contract.usl-opl = {&contr-pay-spec-delay} */ then do:
        assign bf_contract.need-fo = 1  .
        reposition {&browse-name} to recid recid(bf_contract) no-error.
    /*      if not error-status:error then display fo (buffer bf_contract) /*@ varfo*/ with browse {&browse-name}.*/
      end.
      else do:
        message "Договор " bf_contract.contract-prn-code "не имеет признака 'не опред' генерация ФО."
        view-as alert-box.
        next vari-cycle.
      end.
    end.
    assign p-rid-list = "" .
  end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
  run gbl/markqwa.p (input b-mark:sensitive, input p-rid-list) no-error.
  if error-status:error then return no-apply.
  if can-do( bttns, "b-sel") then p-rid-list = "" .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  assign
    tbl = 'contract'
    join-tbl = 'buf_contract'
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
  .

  run fltfield-add in this-procedure('contract-code', 'Вн.Номер', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-date', 'Дата', '',       input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-prn-code', 'Номер', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-type', 'Тип', 'contract-type',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('usl-opl', 'Условия генерации ФО', 'usl-opl', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
/*  run fltfield-add in this-procedure('auto-pay', 'Статус генерации', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
  run fltfield-add in this-procedure('str-uslov-oplat', 'Условия оплаты', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('srok-opl', 'Отсрочка', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
/*  run fltfield-add in this-procedure('status_', 'Статус', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
  run fltfield-add in this-procedure('contract-name', 'Заголовок', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-city', 'Город', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-date-beg', 'Дата начала договора', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-date-end', 'Дата конца договора', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('curr-code', 'Валюта', 'curr',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
/*  run fltfield-add in this-procedure('user-db-num', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
  run fltfield-add in this-procedure('user-name', 'Имя оператора', 'usr',                input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-type{&delim-flt}cli-code'  , 'Контрагент' , 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-type{&delim-flt}posr-code'  , 'Посредник' , 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-type{&delim-flt}agnt-code'  , 'Агент' , 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  RUN OpenBr(yes, no, '':U).
END. /* Filter-Block */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-SlaveContract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-SlaveContract Dialog-Frame
ON CHOOSE OF b-SlaveContract IN FRAME Dialog-Frame /* подчиненные договоры */
DO:
  DEFINE VARIABLE v-cError AS CHARACTER NO-UNDO INITIAL "".
  DEFINE VARIABLE iTmp     AS INTEGER   NO-UNDO INITIAL 0.
  /*  */
  IF AVAILABLE buf_Contract THEN DO:
  /*  */
  ASSIGN
     iTmp = Is-MS-Contract-Int (BUFFER buf_Contract).
     /* Если договор является подчиненным - эта кнопка не должна работать  */
     IF iTmp = 2 THEN DO:
        MESSAGE
            "Текущий договор является подчиненным !" SKIP
            "Нельзя привязывать к подчиненному договору другие договора !" SKIP
            VIEW-AS ALERT-BOX INFO BUTTONS OK.
        RETURN NO-APPLY.
     END.
     /* Обычный договор уже закрыт !!!  */
     IF iTmp = 0 AND buf_contract.status_ = {&close-contr} THEN DO:
        MESSAGE
            "Договор уже закрыт !"
            VIEW-AS ALERT-BOX INFO BUTTONS OK.
        RETURN NO-APPLY.
     END.
     /*  */
     RUN str/cont-slave.w  (
         input  parparentproc,
         "",
         "" /* input  {&update} */ ,
         input  p-host-code,
         BUFFER buf_Contract,
         OUTPUT v-cError    /* на всякий случай  */
         ) NO-ERROR.

     IF ERROR-STATUS:ERROR THEN DO:
        MESSAGE ERROR-STATUS:GET-MESSAGE(1) RETURN-VALUE VIEW-AS ALERT-BOX.
        /* RETURN NO-APPLY. */
     END.
     /* */
     IF v-cError <> "" THEN DO:
        MESSAGE v-cError VIEW-AS ALERT-BOX.
        /* RETURN NO-APPLY. */
     END.
     /* Освежим !!! */
     Contr-list:REFRESH().
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if b-mark:sensitive = no or p-rid-list = "" then do:
    if available buf_contract then p-rid-list = string( recid( buf_contract ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Cli-Status
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Cli-Status Dialog-Frame
ON VALUE-CHANGED OF Cli-Status IN FRAME Dialog-Frame
DO:
  assign Cli-Status .
  case Cli-Status :
    when "all"     then assign p-status = ? .
    when "current" then assign p-status = {&current-contr} .
    when "deleted" then assign p-status = {&close-contr} .
  end.
  RUN OpenBr(yes, no, '':U).
  apply "entry" to Contr-List .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Cli-Types
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Cli-Types Dialog-Frame
ON VALUE-CHANGED OF Cli-Types IN FRAME Dialog-Frame
DO:
  assign Cli-Types .
  if Cli-Types = "sel" then do:
    run ref/cli-all.w (parParentProc, "b-sel", {&cmp}, {&all}, {&current}, ?, ",,,,,,NO,,":u, "without-obj":U, output org-list ) .
    if org-list = "" then do:
      assign Cli-Types = "all" .
      disp Cli-Types with frame {&frame-name}.
    end.
    else do:
      find first ub.clients no-lock where recid(ub.clients) = int(org-list) no-error .
      assign
        p-cli-type = ub.clients.obj-type
        p-cli-code = ub.clients.obj-code
      .
    end.
  end .
  RUN OpenBr(yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME Contr-List
&Scoped-define SELF-NAME Contr-List
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Contr-List Dialog-Frame
ON value-changed OF Contr-List IN FRAME Dialog-Frame
DO:
  if available buf_contract then do:
    assign
      user-name = usrfulnf(buf_contract.user-name)
    .
    disp user-name with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME Contr-List
&Scoped-define SELF-NAME Contr-List
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Contr-List Dialog-Frame
ON RETURN OF Contr-List IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF Contr-List IN FRAME Dialog-Frame
DO:
  if b-sel:sensitive in frame {&frame-name} then do:
    if b-mark:sensitive then apply "choose" to b-mark in frame {&frame-name}.
    else                     apply "choose" to b-sel in frame {&frame-name}.
  end.
  else if B-lkp:sensitive then apply "choose" to B-lkp in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* Начало номера */
DO:
  run proc-find-code  in this-procedure(yes, input frame {&frame-name} sch-code ) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame /* Начало номера */
DO:
  run proc-find-code  in this-procedure(no, input frame {&frame-name} sch-code ) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON CTRL-J OF sch-date IN FRAME Dialog-Frame /* Дата */
DO:
  run proc-find-date in this-procedure(yes, input frame {&frame-name} sch-date) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON RETURN OF sch-date IN FRAME Dialog-Frame /* Дата */
DO:
  run proc-find-date in this-procedure(no, input frame {&frame-name} sch-date) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
b-gen:menu-mouse = 1.

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-sel }

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/brwrepos.i
  &line-num=15
}

{ gbl/ed_date.i sch-date }

/* сорт  колонок*/
{ gbl/srt-clmd.i
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &browse-name = "Contr-List"
  &frame-name = "{&frame-name}"
  &ext-col = 22
  &open-query     = "run OpenBr(yes, no, no)."
  &open-query-otherwise = "run OpenBr(yes, no, no)."
  &sort-column-name = "sort-column-name"
  &start-column         = "5"
  &label-clmn_1         = "{&label-clmn_2 }"
  &sort-clmn_1          = "{&clmn_2 }"
  &label-clmn_2         = "{&label-clmn_3 }"
  &sort-clmn_2          = "{&clmn_3 }"
  &label-clmn_3         = "{&label-clmn_4 }"
  &sort-clmn_3          = "{&clmn_4 }"
  &label-clmn_4         = "{&label-clmn_5 }"
  &sort-clmn_4          = "{&clmn_5 }"
  &label-clmn_5         = "{&label-clmn_6 }"
  &sort-clmn_5          = "{&clmn_6 }"
  &label-clmn_6         = "{&label-clmn_7 }"
  &sort-clmn_6          = "{&clmn_7 }"
  &label-clmn_7         = "{&label-clmn_8 }"
  &sort-clmn_7          = "{&clmn_8 }"
  &label-clmn_8         = "{&label-clmn_9 }"
  &sort-clmn_8          = "{&clmn_9 }"
  &label-clmn_9         = "{&label-clmn_10 }"
  &sort-clmn_9          = "{&clmn_10 }"
  &label-clmn_10        = "{&label-clmn_11 }"
  &sort-clmn_10         = "{&clmn_11 }"
  &label-clmn_11        = "{&label-clmn_12 }"
  &sort-clmn_11         = "{&clmn_12 }"
  &label-clmn_12        = "{&label-clmn_13 }"
  &sort-clmn_12         = "{&clmn_13 }"
  &label-clmn_13        = "{&label-clmn_15 }"
  &sort-clmn_13         = "{&clmn_15 }"
  &label-clmn_14        = "{&label-clmn_16 }"
  &sort-clmn_14         = "{&clmn_16 }"
  &label-clmn_15        = "{&label-clmn_17 }"
  &sort-clmn_15         = "{&clmn_17 }"
  &label-clmn_16        = "{&label-clmn_18 }"
  &sort-clmn_16         = "{&clmn_18 }"
  &label-clmn_17        = "{&label-clmn_20 }"
  &sort-clmn_17         = "{&clmn_20 }"
  &label-clmn_18        = "{&label-clmn_21 }"
  &sort-clmn_18         = "{&clmn_21 }"
  &label-clmn_19        = "{&label-clmn_23 }"
  &sort-clmn_19         = "{&clmn_23 }"
  &label-clmn_20        = "{&label-clmn_14 }"
  &sort-clmn_20         = "{&clmn_14 }"
  &dyn_sort-clmn_20     = "{&dyn_clmn_14 }"
  &label-clmn_21        = "{&label-clmn_19 }"
  &sort-clmn_21         = "{&clmn_19 }"
  &dyn_sort-clmn_21     = "{&dyn_clmn_19 }"
  &label-clmn_22        = "{&label-clmn_22 }"
  &sort-clmn_22         = "{&clmn_22 }"
  &dyn_sort-clmn_22     = "{&dyn_clmn_22 }"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
 }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }
  { gbl/setfltnm.i }


  /* проверка входных параметров */
  if p-cli-code <> ? and p-cli-type <> ? then do:
    find first ub.clients no-lock where ub.clients.obj-type = p-cli-type and ub.clients.obj-code = p-cli-code no-error .
    if available ub.clients then assign Cli-Types  = "sel" .
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-cli-type " p-cli-type " и p-cli-code" p-cli-code
      view-as alert-box ERROR.
      return.
    end.
  end.
  if p-mngr-code <> ? and p-mngr-type <> ? then do:
    find first ub.clients no-lock where ub.clients.obj-type = p-mngr-type and ub.clients.obj-code = p-mngr-code no-error .
    if available ub.clients then assign Agnt-Types  = "sel" .
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-mngr-type " p-mngr-type " и p-mngr-code" p-mngr-code
      view-as alert-box ERROR.
      return.
    end.
  end.

  case p-doc-type :
    when "all" or when {&income} or when {&expense}  then .
    OTHERWISE do:
      message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-doc-type"  p-doc-type
      view-as alert-box ERROR.
      return.
    end.
  end.

  assign
    Contr-List:MAX-DATA-GUESS IN FRAME {&FRAME-NAME}     = 200
    Contr-List:num-locked-columns = 4
    {&clmn_8}:read-only in browse Contr-List = yes
  .

  assign Cli-Status = p-status .
  case Cli-Status :
    when "all"     then assign p-status = ? .
    when "current" then assign p-status = {&current-contr} .
    when "deleted" then assign p-status = {&close-contr} .
    OTHERWISE do:
      message
       vss-workfile vss-revision vss-description skip
       "Неверное значение параметра вызова p-status"  p-status
      view-as alert-box ERROR.
      return.
    end.
  end.
/*Права на просмотр списка */
define variable v-right-supp as logical no-undo .
define variable v-right-buyer as logical   no-undo .
  v-right-supp = true .
  v-right-buyer = true .

  if p-doc-type = "all"  or p-doc-type =  {&income} then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-supp':U
    {&cntxt-firm}
    p-host-code
    ''
    0
    0
    0
    0
    true
    v-right-supp
    no-error
  }
   if error-status :error then v-right-supp = false .
  end.
  if p-doc-type = "all"  or p-doc-type =  {&expense} then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-buyer':U
    {&cntxt-firm}
    p-host-code
    ''
    0
    0
    0
    0
    true
    v-right-buyer
    no-error
  }
  if error-status :error then v-right-buyer = false .
  end.


  if v-right-supp = false or v-right-buyer = false  then return .

  RUN enable_UI in this-procedure .

  RUN StartProc in this-procedure.

  apply "entry" to Contr-List .

  { gbl/mv-clmn.i
    &browse-name = "Contr-List"
    &frame-name = "{&frame-name}"
    &ext-col = 20
    &start-column = "5"
  }

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .

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
  DISPLAY sch-code sch-date Cli-Types Agnt-Types Cli-Status mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit RECT-status B-mark B-sel b-gen b-sch b-SlaveContract b-spec b-specgrp B-Help B-lkp b-chg b-del
         b-open b-trn-doc B-fin-ob B-fin-doc b-hist b-exp b-imp B-add Contr-List sch-code sch-date
         Cli-Types Agnt-Types Cli-Status mark-num b-order
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
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
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  run OpenBr2 ( p-open-query, p-find-next, p-find-condition) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr2 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .

  define variable l-query-was-opened as logical no-undo .
  define variable title0 as character no-undo.
  title0 = "Список договоров" + {&space-char}.
  if p-contr-type <> chr(1) then title0 = title0 + p-contr-type  + {&space-char}.
  {&SetCursorWait}

  define variable sort-column-phrase as character no-undo .

  case sort-column-name :
    when "" then assign  sort-column-phrase = ""  .
    otherwise    assign  sort-column-phrase = "by " + sort-column-name .
  end case.

  define variable l-open-query as logical   no-undo .

  filter-point = filter-point0 + p-mode.

  find first ub.clients no-lock where ub.clients.obj-type = {&cmp} and ub.clients.obj-code = p-host-code .
  if p-doc-type = {&income} then ASSIGN title0  = title0 + "с поставщиками." + {&space-char} .
  else                           ASSIGN title0  = title0 + "с покупателями." + {&space-char} .
  ASSIGN title0  = title0 + " Фирма: (" + string(p-host-code) + ")":U + {&space-char} + ub.clients.obj-name .
      if Agnt-Types = "all" and Cli-Types = "sel" then do:
        find first ub.clients no-lock where ub.clients.obj-type = p-cli-type and ub.clients.obj-code = p-cli-code .
        
        ASSIGN  frame {&frame-name}:TITLE = title0 + " Контрагент: (" + p-cli-type + " " + string(p-cli-code) + ")":U + {&space-char} + ub.clients.obj-name .
        
          OPEN QUERY Contr-List
              FOR EACH buf_contract no-lock
              where buf_contract.host-code  = p-host-code and buf_contract.doc-type = p-doc-type and buf_contract.status_ = p-status  and buf_contract.cli-type = p-cli-type 
              and buf_contract.cli-code = p-cli-code and ( p-contr-type = chr(1) or buf_contract.contract-type = p-contr-type) 
              and (buf_contract.contract-date-end >= today or buf_contract.contract-date-end = ?)
              and buf_contract.contract-date-beg <= today
              , first buf_contract-attr no-lock where buf_contract-attr.contract-code = buf_contract.contract-code and buf_contract-attr.attr-code = p-attr-code and
              buf_contract-attr.host-code = buf_contract.host-code and buf_contract-attr.attr-value = string(true)
                 
            .     
/*                 first temp_filter-fields                                                                                                                                                                                                                                                                                                                                                                                                                */
/*                   where temp_filter-fields.user-id   = buf_init_user-account.user-id                                                                                                                                                                                                                                                                                                                                                                    */
/*                     and temp_filter-fields.fld-record-visible = yes                                                                                                                                                                                                                                                                                                                                                                                     */
/*                     and ( temp_filter-fields.flt-record-visible = yes or tb-filter = no )                                                                                                                                                                                                                                                                                                                                                               */
/*                      by buf_init_user-account.last-name                                                                                                                                                                                                                                                                                                                                                                                                 */
/*                      by buf_init_user-account.first-name                                                                                                                                                                                                                                                                                                                                                                                                */
/*                      by buf_init_user-account.second-name                                                                                                                                                                                                                                                                                                                                                                                               */
/*            .                                                                                                                                                                                                                                                                                                                                                                                                                                            */
/*                                                                                                                                                                                                                                                                                                                                                                                                                                                         */
/*        for each buf_contract-attr no-lock where buf_contract-attr.attr-code = p-attr-code and                                                                                                                                                                                                                                                                                                                                                           */
/*        buf_contract-attr.host-code = p-host-code and buf_contract-attr.attr-value = string(true):                                                                                                                                                                                                                                                                                                                                                       */
/*                                                                                                                                                                                                                                                                                                                                                                                                                                                         */
/*        { gbl/fltopend.i                                                                                                                                                                                                                                                                                                                                                                                                                                 */
/*          &where-cond = " buf_contract.contract-code = buf_contract-attr.contract-code and buf_contract.host-code  = p-host-code and buf_contract.doc-type = p-doc-type and buf_contract.status_ = p-status  and buf_contract.cli-type = p-cli-type and buf_contract.cli-code = p-cli-code and ( p-contr-type = chr(1) or buf_contract.contract-type = p-contr-type), first buf_contract-attr no-lock where buf_contract-attr.attr-code = p-attr-code and*/
/*        buf_contract-attr.host-code = p-host-code and buf_contract-attr.attr-value = string(true)"                                                                                                                                                                                                                                                                                                                                                       */
/*        }                                                                                                                                                                                                                                                                                                                                                                                                                                                */
/*        end.                                                                                                                                                                                                                                                                                                                                                                                                                                             */
      end.

  if v-doc-rec = ? then do:
    { gbl/brwrepos.i }
  end.
  else do:
    REPOSITION Contr-List to recid v-doc-rec No-ERROR.
    if error-status:error then do:
      { gbl/brwrepos.i }
    end.
  end.
  {&SetCursorNo}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-code Dialog-Frame
PROCEDURE proc-find-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter p-next as logical no-undo.
  define input parameter p-code as character no-undo .

  display "  /  /":U @ sch-date with frame {&frame-name}.
  assign p-code = {&double-quote} + p-code + {&double-quote}.

  if p-code = '""' then do:
    run OpenBr in this-procedure
      (input false /* p-open-query */
      ,input p-next  /* p-find-next  */
      ,input substitute("and buf_contract.contract-prn-code = '' " )
    ).
  end.
  else do:
    run OpenBr in this-procedure
      (input false /* p-open-query */
      ,input p-next  /* p-find-next  */
      ,input substitute("and buf_contract.contract-prn-code  begins &1 "
      , p-code)
      ).
  end.
  apply "entry":u to sch-code in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-date Dialog-Frame
PROCEDURE proc-find-date :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter p-next as logical no-undo.
  define input parameter par-date as date    no-undo .

  display "":U @ sch-code with frame {&frame-name}.
  define variable var-datechr as character no-undo .
  assign var-datechr = string(day(par-date)) + {&slash-char} + string(month(par-date)) + {&slash-char} + string(year(par-date)) .
  run OpenBr in this-procedure (input false ,input p-next ,input substitute("and buf_contract.contract-date = &1 ", var-datechr)).
  apply "entry":u to sch-date in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE StartProc Dialog-Frame
PROCEDURE StartProc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  DEFINE VARIABLE v-hdl AS HANDLE NO-UNDO .
  /* Для снятия глобальных настроек fo-mc-mode  */

  DISABLE
    b-sel   when  NOT can-do( bttns, "b-sel" )
    b-mark  when  NOT can-do( bttns, "b-mark")
    b-add   when (NOT can-do( bttns, "b-add" ) or p-doc-type = "all")
    b-chg   when  NOT can-do( bttns, "b-chg" )
    b-del   when  NOT can-do( bttns, "b-del" )
    b-open  when  NOT can-do( bttns, "b-open")
    b-SlaveContract when v-MS-Can-Do-List = "1"
  WITH FRAME {&frame-name}.

  if p-doc-type <> {&income} then DISABLE b-gen WITH FRAME {&frame-name}.

  define variable v-db-num  as integer no-undo .
  define variable v-ret as logical no-undo .
  { gbl/curdbnum.i  v-db-num}
  run ver-db (input p-host-code,  input v-db-num, input false, output v-ret ) no-error .
  if error-status :error or v-ret = false then do:
     disable   B-fin-ob    B-fin-doc  b-specgrp   with frame {&frame-name}.
  end.

  if mark-num = 0 then hide mark-num in frame {&frame-name}.

  if p-rid-list <> "":U then assign v-doc-rec = integer(entry(1, p-rid-list)) .


  p-contr-type = chr(1) .
  if num-entries(p-mode,"=") = 2 then do:
     if entry(1,p-mode,"=") = "contract-type" then do:
        p-contr-type = entry(2,p-mode,"=") .
     end.
  end.

  /* Гасим колонку "Мастер договор" если работаем по старой схеме !!! (когда v-iMcMode = 0 )
    и кнопку "Подчиненные договоры"
  */
  IF v-iMcMode = 0 THEN DO:
     v-hdl = Contr-list:FIRST-COLUMN .
     DO WHILE VALID-HANDLE(v-hdl):
         IF v-hdl:LABEL = {&MC_LABEL_COLUMN}:U THEN v-hdl:VISIBLE = NO.
            v-hdl = v-hdl:NEXT-COLUMN .
     END.
     /* */
     ASSIGN
        b-SlaveContract:HIDDEN = TRUE.

  END.
  /* */
  Run OpenBR in this-procedure (yes, no, '':U) no-error  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE run-contr Dialog-Frame
PROCEDURE run-contr :
define input parameter p-stat as character no-undo .
define input parameter p-fict as logical   no-undo .

  define variable v-doc-tp as character no-undo .
  define variable ri as recid no-undo .
  if p-stat <> {&add-def} then do:
    assign
      ri = recid( buf_contract )
      v-doc-tp = buf_contract.doc-type
    .
  end.
  else assign v-doc-tp = p-doc-type .

  if p-stat = {&lookup} then do:
    br-handle = {&browse-name}:handle in frame {&frame-name} .
    next-prev = no.
    do while next-prev <> ?:
      if not available buf_contract then do:
        message "Неправильный выбор документа.".
        return.
      end.
      run str/contr.w ( input parParentProc,input p-host-code, input p-stat, input v-doc-tp, input-output ri) no-error.
      if error-status:error then return no-apply.
      if br-handle = ? then reposition {&browse-name} to recid ri no-error.
    end.
  end.
  else do:
    if p-contr-type = chr(1) then
       run str/contr.w ( input parParentProc,input p-host-code, input p-stat, input v-doc-tp, input-output ri) no-error.
    else
       run str/contr.w ( input parParentProc,input p-host-code, input p-stat, input "contract-type=" + p-contr-type, input-output ri) no-error.
    if error-status:error then return no-apply.
  end.

  v-doc-rec = ri .

  run openbr in this-procedure (yes, no, '':u).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-del Dialog-Frame
procedure proc-del :
  /*  */
  DEFINE VARIABLE v-cError as CHARACTER NO-UNDO INITIAL "".
  DEFINE VARIABLE iTmp        as INTEGER   NO-UNDO INITIAL 0.
  /*  */
  do on error undo, return error return-value :
    if buf_contract.status_ = {&close-contr} then do:
      message "Договор уже закрыт!" view-as alert-box.
      return .
    end.

    /* Проверка прав на измениение Мастер или Slave договора */
    ASSIGN
       iTmp = Is-MS-Contract-Int (BUFFER buf_Contract).

    CASE iTmp:
         WHEN 1 THEN DO:      /* Мастер  */
               { gbl/chk-actg.i
                     v-cntxt-db-num
                     v-cntxt-userid
                     {&action-head-code-main}
                     'actn_fo-mc_master-open-close':U
                     {&cntxt-firm}
                     p-host-code
                     '':U
                     0
                     0
                     0
                     0
                     true
                     g-log
               }
               if not g-log then return no-apply.

         END.
         /*  */
         WHEN 2 THEN DO:     /* Подчиненный */
               { gbl/chk-actg.i
                     v-cntxt-db-num
                     v-cntxt-userid
                     {&action-head-code-main}
                     'actn_fo-mc_slave-open-close':U
                     {&cntxt-firm}
                     p-host-code
                     '':U
                     0
                     0
                     0
                     0
                     true
                     g-log
               }
               if not g-log then return no-apply.
         END.
    END CASE.

    message
      "Закрыть договор №" buf_contract.contract-prn-code "от" buf_contract.contract-date "?"
      view-as alert-box QUESTION BUTTONS YES-NO update g-log .
    if g-log = no then return .

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_fin-contract_deletion':U
      {&cntxt-firm}
      p-host-code
      '':U
      0
      0
      0
      0
      true
      g-log
    }
    if not g-log then return .

    v-doc-rec = recid( buf_contract ).

    do transaction :
       find first contract exclusive-lock where recid(contract) = recid(buf_contract) no-error .
       if available contract then do:
          { gbl/curdburt.i
            buf_contract.user-db-num
            buf_contract.user-name
            p-sys-date
            p-sys-time
            p-sys-time-int
          }
          ASSIGN
             contract.status_ = {&close-contr}
             .
       end.
       /* Если мастер договор - изменение статуса по всем подчиненным договорам */
       if Is-MS-Contract-Int (BUFFER buf_Contract) = 1 THEN DO:

          RUN Change-Stat-Slave-Contract in THIS-PROCEDURE(
              BUFFER buf_Contract,
              {&close-contr},
              OUTPUT v-cError
              ).
          /*  */
          if v-cError <> "" THEN DO:
             MESSAGE
                v-cError
                VIEW-AS ALERT-BOX INFO BUTTONS OK.
             RETURN ERROR v-cError.
          END.
       END.

    end.
  end.
end procedure. /* proc-del */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sel-agent Dialog-Frame
procedure proc-sel-agent :
  do on error undo, return error return-value :
    run ref/cli-all.w ( parParentProc, "b-sel", {&prs}, {&all}, {&current}, ?, ",,,,,,NO,,":u, "without-obj":U, output agnt-list ) .
    if agnt-list = "" then do:
      assign Agnt-Types = "all"  .
      DISPLAY Agnt-Types with frame {&frame-name} .
    end.
    else do:
      find first ub.clients no-lock where recid(ub.clients) = int(agnt-list) no-error .
      assign
        p-mngr-code = ub.clients.obj-code
        p-mngr-type = ub.clients.obj-type
      .
    end.
  end.
end procedure. /* proc-sel-agent */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-open Dialog-Frame
procedure proc-open :
  /*  */
  DEFINE VARIABLE v-cError    as CHARACTER NO-UNDO INITIAL "".
  DEFINE VARIABLE iTmp        as INTEGER   NO-UNDO INITIAL 0.
  /*  */
  do on error undo, return error return-value :
    if buf_contract.status_ = {&current-contr} then do:
      message "Договор уже открыт!" view-as alert-box.
      return no-apply.
    end.
    /*добавлены проверки по типу договора между членами ТПСИ - NVB*/
    if can-find(first ub.contract no-lock where
                      ub.contract.host-code = buf_contract.host-code
                  AND ub.contract.cli-type = buf_contract.cli-type
                  AND ub.contract.cli-code = buf_contract.cli-code
                  and ub.contract.contract-type = {&contr-tpsi}
                  and ub.contract.status_       = {&current-contr}
                  ) then do:
        message
        "Нельзя открыть договор типа <Продажа через ТПСИ>," skip
        "уже есть действующий договор этого типа с фирмой" buf_contract.cli-code
        view-as alert-box error .
        return error .
    end.


    /* Проверка прав на измениение Мастер или Slave договора */
    ASSIGN
       iTmp = Is-MS-Contract-Int (BUFFER buf_Contract).

    CASE iTmp:
         WHEN 1 THEN DO:      /* Мастер  */
               { gbl/chk-actg.i
                     v-cntxt-db-num
                     v-cntxt-userid
                     {&action-head-code-main}
                     'actn_fo-mc_master-open-close':U
                     {&cntxt-firm}
                     p-host-code
                     '':U
                     0
                     0
                     0
                     0
                     true
                     g-log
               }
               if not g-log then return no-apply.

         END.
         WHEN 2 THEN DO:     /* Подчиненный */
               { gbl/chk-actg.i
                     v-cntxt-db-num
                     v-cntxt-userid
                     {&action-head-code-main}
                     'actn_fo-mc_slave-open-close':U
                     {&cntxt-firm}
                     p-host-code
                     '':U
                     0
                     0
                     0
                     0
                     true
                     g-log
               }
               if not g-log then return no-apply.
         END.
    END CASE.
    /*  */
    message
      "Открыть договор №" buf_contract.contract-prn-code "от" buf_contract.contract-date "?"
      view-as alert-box QUESTION BUTTONS YES-NO update g-log .
    if g-log = no then return no-apply.

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_fin-contract_deletion':U
      {&cntxt-firm}
      p-host-code
      '':U
      0
      0
      0
      0
      true
      g-log
    }
    if not g-log then return no-apply.

    v-doc-rec = recid( buf_contract ).

    do transaction :
      find first contract exclusive-lock where recid(contract) = recid(buf_contract) no-error .
      if available contract then do:
         {gbl/curdburt.i
          buf_contract.user-db-num
          buf_contract.user-name
          p-sys-date
          p-sys-time
          p-sys-time-int
         }
         ASSIGN
            contract.status_ = {&current-contr}
            .
       /* Если мастер договор - изменение статуса по всем подчиненным договорам */
       /* if Is-MS-Contract-Int (BUFFER buf_Contract) = 1 THEN DO: */
       IF iTmp = 1 THEN DO:
          /*  */
          RUN Change-Stat-Slave-Contract in THIS-PROCEDURE(
              BUFFER buf_Contract,
              {&current-contr},
              OUTPUT v-cError
              ).
          /*  */
          if v-cError <> "" THEN DO:
             MESSAGE
                v-cError
                VIEW-AS ALERT-BOX INFO BUTTONS OK.
             RETURN ERROR v-cError.
          END.
       END.

      end.
    end.

  end.
end procedure. /* proc-open */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-exp Dialog-Frame
PROCEDURE proc-b-exp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable v-file-name as character no-undo .

  if not available buf_contract then return no-apply.

  define variable v-sys-key   as character         no-undo.
  { gbl/currsysk.i
    v-sys-key
    no-error
  }

  assign  v-file-name = /*"f":U + string(X_fin-doc.fin-doc-code) + ".xml"*/ ? .
  run str/xmlcontr.p (input buf_contract.host-code, buf_contract.contract-code, input-output v-file-name, yes, yes) no-error .

  if error-status:error then do:
    message   "Ошибка при выгрузке платежа в XML-формате"  view-as alert-box .
    return error .
  end.

  if search ("exmldoc.bat") <> ? then do:
    os-command silent value(search ("exmldoc.bat") + " " + v-file-name + " " + v-sys-key).
  end.
  else do:
    if search (v-file-name ) <> ? then message "Документ(-ы) выгружен(-ы) в файл " v-file-name view-as alert-box.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-imp Dialog-Frame
PROCEDURE proc-b-imp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/* 1. открыть файл Excel */
define variable mFileName         as character        no-undo.
define variable vFileName         as character no-undo.
define variable v-log-file-name   as character no-undo .
define variable v-last-slash-pos  as integer no-undo .
define variable varlog            as logical   no-undo.
define variable mExcelApplication as component-handle no-undo. /* ССЫЛКА НА ПРИЛОЖЕНИЕ */
define variable mWorkBook         as component-handle no-undo. /* ССЫЛКА НА РАБОЧУЮ КНИГУ */
define variable mWorkSheet        as component-handle no-undo. /* ССЫЛКА НА РАБОЧИЙ ЛИСТ */
define variable mRange            as component-handle no-undo . /* область для чтения */

  system-dialog get-file mFileName title "Выберите файл с ценами поставки"
    filters "MS Excel (*.xls,*.xlsx)" "*.xls,*.xlsx",
            "Все файлы" "*.*"
    initial-filter 1
    must-exist             
    update varlog.
  if not varlog then return error "Отказ от импорта" .

  ASSIGN
    FILE-INFO:FILE-NAME = mFileName
    vFilename           = FILE-INFO:FULL-PATHNAME
  .
  IF LENGTH(vFileName) > 0 THEN .
  ELSE RETURN ERROR SUBSTITUTE("Не найден файл &1", mFileName).
/*
 Формулировки ТЗ "импорта цен поставки для всех договоров в АСУ GAS Complex System":

В случае неуспешного импорта лог-файл должен формироваться в директорию указанную в ini-файле в секции log-dir.
(@NOTE параметр logDir секции [REP-SETS] доступен только в версии 16.0)
В случае отсутствия секции лог-файл сохраняется в рабочую директорию.
*/

  v-last-slash-pos = max (
    r-index(vFilename, "/"),
    r-index(vFilename, "\")
                         ) .
  v-log-file-name  = substitute("&1&2.log"
    , ibs.th.gbl.gbl-inipar:logDir
    , entry(1, substring(vFileName, v-last-slash-pos + 1), ".")
                                ) .

  empty temp-table t-imp-price .

  create "Excel.Application":U mExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.  
  assign
    mExcelApplication:DisplayAlerts = no
    mWorkbook                       = mExcelApplication:WorkBooks:Add(vFileName)
    mWorkSheet                      = mWorkbook:Sheets:Item(1)
  .

/* 2. прочесть файл во временную таблицу */
  define variable vLine   as integer   no-undo.
  define variable vsContractCode as character no-undo . /* A1 = Номер договора в ТН (системный код) */
  define variable vContractCode  as integer no-undo .
  define variable vsFirmCode     as character no-undo . /* B1 = Код контрагента (системный код) */
  define variable vFirmCode      as integer no-undo .
  define variable vsGdsCode      as character no-undo . /* С1 = Код товара в ТН */
  define variable vGdsCode       as integer no-undo .
  define variable vsPriceRubl    as character no-undo . /* D1 = Цена товара с НДС */
  define variable vPriceRubl     as decimal no-undo .
  define variable vsVatPc        as character no-undo . /* E1 = Ставка НДС */
  define variable vVatPc         as decimal no-undo .
  define variable vsPrcUp        as character no-undo . /* F1 = % отклонения в большую сторону */
  define variable vPrcUp         as decimal no-undo .
  define variable vsPrcDn        as character no-undo . /* G1 = % отклонения в меньшую сторону */
  define variable vPrcDn         as decimal no-undo .
  define variable vsGdsName      as character no-undo . /* H1 = Наименование товара */
  define variable vsFirmName     as character no-undo . /* I1 = Наименование контрагента */
&scoped-define decimal-zerro 0.00000000005
  
  loopbl:
  do vLine = 2 to 1000000:
    
    mRange = mWorkSheet:Range(  substitute("A&1":U, vLine)  ) .
    vsContractCode = mRange:formula .
    mRange = mWorkSheet:Range(  substitute("B&1":U, vLine)  ) .
    vsFirmCode     = mRange:formula .
    mRange = mWorkSheet:Range(  substitute("C&1":U, vLine)  ) .
    vsGdsCode      = mRange:formula .
    assign
      vContractCode = integer (vsContractCode)
      vFirmCode     = integer (vsFirmCode)
      vGdsCode      = integer (vsGdsCode)
    no-error .
    if (not error-status:error) and (vContractCode > 0) and (vFirmCode > 0) and (vGdsCode > 0) then .
    else leave loopbl.                

    mRange = mWorkSheet:Range(  substitute("D&1":U, vLine)  ) .
    vPriceRubl     = mRange:value no-error .
    if vPriceRubl = ? then assign
      vsPriceRubl = mRange:formula
      vPriceRubl  = func-char-to-dec( vsPriceRubl )
    .
    mRange = mWorkSheet:Range(  substitute("E&1":U, vLine)  ) .
    vVatPc         = mRange:value no-error .
    if vVatPc = ? then assign
      vsVatPc = mRange:formula
      vVatPc  = func-char-to-dec( vsVatPc )
    .
    mRange = mWorkSheet:Range(  substitute("F&1":U, vLine)  ) .
    vPrcUp         = mRange:value no-error .
    if vPrcUp = ? then assign
      vsPrcUp = mRange:formula
      vPrcUp  = func-char-to-dec( vsPrcUp )
    .
    mRange = mWorkSheet:Range(  substitute("G&1":U, vLine)  ) .
    vPrcDn         = mRange:value no-error .
    if vPrcDn = ? then assign
      vsPrcDn = mRange:formula
      vPrcDn  = func-char-to-dec( vsPrcDn )
    .
    mRange = mWorkSheet:Range(  substitute("H&1":U, vLine)  ) .
    vsGdsName = mRange:formula .
    mRange = mWorkSheet:Range(  substitute("I&1":U, vLine)  ) .
    vsFirmName = mRange:formula .
   
    create t-imp-price .
    assign
      t-imp-price.contract-code = vContractCode
      t-imp-price.firm-code     = vFirmCode
      t-imp-price.gds-code      = vGdsCode
      t-imp-price.price-rubl    = (if vPriceRubl > {&decimal-zerro} then vPriceRubl else 0)
      t-imp-price.vat-pc        = (if vVatPc     > {&decimal-zerro} then vVatPc     else 0)
      t-imp-price.prc-up        = (if vPrcUp     > {&decimal-zerro} then vPrcUp     else 0)
      t-imp-price.prc-dn        = (if vPrcDn     > {&decimal-zerro} then vPrcDn     else 0)
      t-imp-price.gds-name      = vsGdsName
      t-imp-price.firm-name     = vsFirmName
      t-imp-price.line-num      = vLine
    no-error .
    if error-status:error then leave loopbl.                
  end.   

/* 3. закрыть файл Excel */
  mWorkbook:Close(true) no-error.
  release object mWorkSheet no-error.
  release object mWorkbook no-error.
  mExcelApplication:QUIT() no-error.
  release object mExcelApplication no-error.
  
/* 4. записать временную таблицу в БД
      Уникальность в договорах = host-code + contract-code.
      Поэтому загружем только часть, относящуюся к фирме текущего объекта.

      Сопоставление проводится по трём полям:
      - № договора в Trade House (системный код);
      - код контрагента (системный код);
      - код товара.

      Формулировки ТЗ "импорта цен поставки для всех договоров в АСУ GAS Complex System":
        
Проверке подлежат только текущие на момент загрузки договоры,
  исключая закрытие и договоры с истекшим сроком действия.
Если в процессе загрузки для одной из строк не найдено полного соответствия,
  то для такой строки изменений не производится, но продолжается проверка по другим строкам.
Если в Системе найдена запись, в которой все три поля совпадают,
... но значение цены товара с НДС равно нулю либо не указано значение в соответствии с файлом,
    то для такой строки изменений не производится, проверка продолжается по другим строкам.
... но значение допустимого процента отклонения в соответствии с файлом равно нулю,
    то для такой строки производится изменение
    - цены поставки,
    - ставки НДС в соответствии со значениями из файла,
    - значение допустимого процента отклонения остаётся в соответствии со значением в спецификации,
    проверка продолжается по другим строкам.
... (если никаких "но")
    то в спецификации к договору производится изменение
    - цены поставки,
    - ставки НДС и
    - процента отклонения в соответствии со значениями из файла.

Форматы сообщений в лог-файле:
(1) если в Системе не найден текущий договор с указанным в файле номером
- «Ошибка в строке №_. В Системе не найдено текущего договора с № – (номер договора из файла)»;
(2) если в Системе не найден контрагент с указанным в файле кодом
- «Ошибка в строке № _. В Системе отсутствует контрагент с кодом – (код контрагента из файла)»;
(3) если в Системе не найден товар с кодом
- «Ошибка в строке №_. В Системе отсут-ствует товар с кодом – (код товара из файла)»;
(4) если для указанного в файле договора в Системе найден другой код контрагента
– «Ошибка в строке №_. Для договора (№ договора из файла) указан некорректный контрагент (код контрагента из файла)»;
(5) если в указанном в файле договоре не найден товар
– «Ошибка в строке №. Данный товар не привязан к договору (№ договора из файла)»;
(6) если в указанном файле цена товара с НДС не указана либо равна нулю
- «Ошибка в строке №  . Не указана/ Равна нулю цена товара с НДС»;
(7) если в указанном файле процент отклонения равен нулю
- «Ошибка в строке №  . Допустимый % отклонения равен нулю».
*/
/*define variable v-is-contr   as logical no-undo .*/
/*define variable v-is-contr0  as logical no-undo .*/
/*define variable v-is-contr1  as logical no-undo .*/
/*define variable v-is-contr2  as logical no-undo .*/
/*define variable v-is-contr3  as logical no-undo .*/
define variable v-today      as date no-undo .
define variable v-i-retry    as integer no-undo .
/*define variable v-prc-max    as decimal no-undo .*/
define variable v-prc-min    as decimal no-undo .
define variable v-num-passed as integer no-undo .
define variable v-num-count  as integer no-undo .
define variable v-has-errors as logical no-undo .
define variable v-is-firm    as logical no-undo .
define variable v-host-code  as integer no-undo .
define variable v-contract-code as integer no-undo .
define buffer imp_buf_contract             for ub.contract .
define buffer imp_buf_contract-specif      for ub.contract-specif .
define buffer imp_buf_contract-specif-attr for ub.contract-specif-attr .
/*define buffer imp_buf_clients              for ub.clients .*/
define buffer imp_buf_goods                for ub.goods .

  assign
    v-today      = today
    v-num-passed = 0
    v-num-count  = 0
    v-has-errors = false
  .
  output stream f-log-imp to value (v-log-file-name) .
  for each t-imp-price by t-imp-price.line-num :
/* 18/XII-2018
  break by t-imp-price.contract-code : - пришлось отказаться от группировки по номеру договора:
  - в логе ошибка по строке с меньшим номером должна быть выше, чем ошибка по строке с большим номером
*/
    v-num-count = v-num-count + 1 .
   
    if t-imp-price.price-rubl > 0 then . else do :
      put stream f-log-imp unformatted
        /* (6) */ substitute("Ошибка в строке №&1. Не указана/ Равна нулю цена товара с НДС",
                     t-imp-price.line-num)
        skip
      .
      v-has-errors = true .
      next .  
    end .
    if not can-find (first imp_buf_goods where imp_buf_goods.gds-code = t-imp-price.gds-code) then do :
      put stream f-log-imp unformatted
        /* (3) */ substitute("Ошибка в строке №&1. В Системе отсутствует товар с кодом &2",
                   t-imp-price.line-num, t-imp-price.gds-code)
        skip
      .
      v-has-errors = true .
      next .  
    end .
      
    find first imp_buf_contract no-lock
         where imp_buf_contract.host-code     = p-host-code
           and imp_buf_contract.contract-code = t-imp-price.contract-code no-error .
    if not available imp_buf_contract then do :
      put stream f-log-imp unformatted
        /* (1) */ substitute("Ошибка в строке №&1. В Системе не найдено текущего договора с № &2",
                   t-imp-price.line-num, t-imp-price.contract-code)
        skip
      .
      v-has-errors = true .
      next .  
    end .
    else do :
      v-host-code     = imp_buf_contract.host-code .
      v-contract-code = imp_buf_contract.contract-code .
    end .
    
    /* если бы использовался первичный индекс:
    find first imp_buf_clients no-lock
         where imp_buf_clients.obj-type = imp_buf_contract.cli-type
           and imp_buf_clients.obj-code = imp_buf_contract.cli-code no-error .
       ... но т.к. тип контрагента в файле импорта отсутствует - используем половинку первичного индекса.
    */       
    if not can-find (first clients where clients.obj-code = t-imp-price.firm-code) then do :
      put stream f-log-imp unformatted
        /* (2) */ substitute("Ошибка в строке №&1. В Системе отсутствует контрагент с кодом &2",
                   t-imp-price.line-num, t-imp-price.firm-code)
        skip
      .
      v-has-errors = true .
      next .  
    end .
    
    if imp_buf_contract.cli-code <> t-imp-price.firm-code then do :
      put stream f-log-imp unformatted
        /* (4) */ substitute("Ошибка в строке №&1. Для договора &2 указан некорректный контрагент &3",
                   t-imp-price.line-num, t-imp-price.contract-code, t-imp-price.firm-code)
        skip
      .
      v-has-errors = true .
      next .  
    end .
    /* есть требование рассматривать только текущие непросроченные договоры,
       но нет формата ошибки, если договор найден, но он не текущий, либо просроченный:
       "Проверке подлежат только текущие на момент загрузки договоры,
        исключая закрытие и договоры с истекшим сроком действия."
    */
    if imp_buf_contract.status_ <> {&current-contr} then do :
      put stream f-log-imp unformatted
        /* (-) */ substitute("Ошибка в строке №&1. Договор &2 закрыт и не подлежит изменению.",
                   t-imp-price.line-num, t-imp-price.contract-code)
        skip
      .
      v-has-errors = true .
      next .  
    end .
    if imp_buf_contract.contract-date-end < v-today then do :
      put stream f-log-imp unformatted
        /* (-) */ substitute("Ошибка в строке №&1. У договора &2 истёк срок действия &3.",
                   t-imp-price.line-num, t-imp-price.contract-code, imp_buf_contract.contract-date-end)
        skip
      .
      v-has-errors = true .
      next .  
    end .
    
    /* после выполнения заголовочных проверок пытаемся обновить запись,
       и выполняем проверки, связанные с обновляемой строкой спецификации */
    v-i-retry = 0 .
do transaction :  
    repeat :
      find first imp_buf_contract-specif exclusive-lock
           where imp_buf_contract-specif.host-code    = v-host-code
             and imp_buf_contract-specif.contract-num = v-contract-code
             and imp_buf_contract-specif.gds-code     = t-imp-price.gds-code no-error no-wait .
      if available imp_buf_contract-specif then do :
        if (t-imp-price.prc-dn > 0) then do :
          find first imp_buf_contract-specif-attr exclusive-lock
               where imp_buf_contract-specif-attr.host-code    = v-host-code
                 and imp_buf_contract-specif-attr.contract-num = v-contract-code
                 and imp_buf_contract-specif-attr.gds-code     = t-imp-price.gds-code
                 and imp_buf_contract-specif-attr.attr-code    = {&contract-specif-prc-min} no-error .
          if locked imp_buf_contract-specif-attr then do :
            v-i-retry = v-i-retry + 1 .
            if v-i-retry > 5 then leave .
            pause 1 no-message .
            next .
          end .
        end .
        /* 18/XII-2018 - пока не заказывали
        if imp_buf_contract-specif.price-rubl > 0 then do :
            ...
        end .
        else do :
            put stream f-log-imp unformatted
              /* (-) */ substitute("Ошибка в строке №&1. Товар &2. Значение цены товара с НДС в спецификации договора равно нулю.",
                         t-imp-price.line-num, t-imp-price.gds-code)
              skip
            .
            v-has-errors = true .
        end .
        */
        if (t-imp-price.prc-up > 0) and (t-imp-price.prc-dn > 0) then . else do :
          put stream f-log-imp unformatted
            /* (7) */ substitute("Ошибка в строке №&1. Допустимый % отклонения равен нулю и остается прежним в Системе.",
                       t-imp-price.line-num)
            skip
          .
          v-has-errors = true .
          /* отклонение цены не сохраняем, остальные поля сохраняем */
        end .
        if imp_buf_contract-specif.price-cli <> t-imp-price.price-rubl then assign
           imp_buf_contract-specif.price-cli  = t-imp-price.price-rubl
           imp_buf_contract-specif.sum-cli    = imp_buf_contract-specif.price-cli * imp_buf_contract-specif.qnty 
        .
        assign
          imp_buf_contract-specif.VAT-pc      = t-imp-price.vat-pc
    when (imp_buf_contract-specif.VAT-pc     <> t-imp-price.vat-pc)
          imp_buf_contract-specif.prc         = t-imp-price.prc-up
    when (
         (t-imp-price.prc-up > 0) and 
         (imp_buf_contract-specif.prc        <> t-imp-price.prc-up)
         )
          v-num-passed = v-num-passed + 1   
        .
        if (t-imp-price.prc-dn > 0) and (available imp_buf_contract-specif-attr) then do :
          v-prc-min = decimal (imp_buf_contract-specif-attr.attr-value) no-error .
          assign
            imp_buf_contract-specif-attr.attr-value = string(t-imp-price.prc-dn)
              when ( v-prc-min <> t-imp-price.prc-dn )
          .
        end .
        leave .
      end . /* end_of_available_imp_buf_contract-specif */
      else if locked imp_buf_contract-specif then do :
        v-i-retry = v-i-retry + 1 .
        if v-i-retry > 5 then leave .
        pause 1 no-message .
        next .
      end .
      else do :
        put stream f-log-imp unformatted
          /* (5) */ substitute("Ошибка в строке №&1. Товар &2 не привязан к договору &3",
                     t-imp-price.line-num, t-imp-price.gds-code, t-imp-price.contract-code)
          skip
        .
        v-has-errors = true .
        leave .
      end .
    end . /* end_of_repeat */
end . /* end_of_transaction */
    
  end . /* end_of for_each_timpprice */
  output stream f-log-imp close .
  
/* 5. посмотреть результаты вывода в разном формате

 Формулировки ТЗ "импорта цен поставки для всех договоров в АСУ GAS Complex System":

Для пользователя предлагается вывод отчета на просмотр с последующим сохранением в текстовом формате.

После окончания импорта пользователю в диалоговом окне выводится
- статус загрузки
- сообщение о количестве обработанных и загруженных в систему строк из файла импорта.

*/

define variable v-user-action as character no-undo .
define variable v-printed     as logical no-undo .
define variable r-var1        as character no-undo initial "прочитайте" . /* действие_с_файлом */
define variable r-var2        as character no-undo initial "!!!" .        /* важность_действия */
define variable v-global-panic as character no-undo initial "" .
if (v-num-passed < v-num-count) or v-has-errors then do :
    case r-var1 :
      when "прочитайте" then do :
    v-global-panic = "При проверке информации произошли ошибки" + r-var2 + {&new-line} +
            r-var2 + "Внимательно " + r-var1 + " Log-file" + r-var2 .
      end .
      when "съешьте" then do :
    v-global-panic = "При проверке информации произошли ошибки" + r-var2 + {&new-line} +
            r-var2 + "Аккуратно " + r-var1 + " Log-file" + r-var2 .
      end .
      otherwise do :
        /* ой... */
      end .
    end case .
end .
    
message
 "Статус загрузки - завершена." skip
 substitute ("Обработанно &1 строк из файла импорта, загруженно в систему &2 строк.",
             v-num-count, v-num-passed) skip(1)
 v-global-panic             
view-as alert-box .

if (v-num-passed < v-num-count) or v-has-errors then do :
    run gbl/prnfilen.w (
          input "Ошибки, возникшие при проверке импортируемого файла":U
        , input 7   /* if DisabledOptions >= 8 then v-landscape = true else v-landscape = false . */
        , input v-log-file-name
        , input 7
        , output v-user-action
        , output v-printed
    ).
end .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-agent Dialog-Frame
FUNCTION get-agent RETURNS CHARACTER
  ( input agnt-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define variable var-cli-name as character no-undo.
define buffer buf_clients for ub.clients.
  find first buf_clients no-lock where buf_clients.obj-type = {&prs} and buf_clients.obj-code = agnt-code no-error .
  if available buf_clients then assign var-cli-name = STRING (agnt-code) + "   " + TRIM (buf_clients.obj-name) .
RETURN var-cli-name.   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-char-to-dec Dialog-Frame
FUNCTION func-char-to-dec RETURNS DECIMAL (iCh AS CHARACTER):
    /* Строка в число; скопировано из bge/clb-xlsigetxml.p */
    DEFINE VARIABLE vI       AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vCh      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vNumeric AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vResult  AS DECIMAL   NO-UNDO.
    IF LENGTH(iCh) > 0 THEN
    DO:
        DO vI = 1 TO LENGTH(iCh):
            vCh = SUBSTRING(iCh, vI, 1).
            IF INDEX("-+0123456789,.":U, vCh) > 0 THEN 
                vNumeric = vNumeric + vCh.
        END.
        ASSIGN
            vNumeric = REPLACE(vNumeric, 
                                SESSION:NUMERIC-SEPARATOR,
                                SESSION:NUMERIC-DECIMAL-POINT)
            vResult  = DECIMAL(vNumeric)
            NO-ERROR.
    END.
    ELSE vResult = 0.
    
    RETURN vResult.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-currency Dialog-Frame
FUNCTION get-currency RETURNS CHARACTER
  ( input curr-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define variable var-curr-name as character no-undo.
define buffer buf_currency for ub.currency.
  find first buf_currency no-lock where buf_currency.curr-code = curr-code no-error .
  if available buf_currency then assign var-curr-name = buf_currency.curr-abbr .

RETURN var-curr-name.   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid, input mark-list as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

RETURN ( IF LOOKUP( STRING( par-recid ), mark-list ) > 0 THEN "*" ELSE "":U ).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME