&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER find_fin-doc FOR fin-doc.
DEFINE BUFFER X_clients-host FOR clients.
DEFINE NEW SHARED BUFFER X_fin-doc FOR fin-doc.
DEFINE BUFFER X_sysconf FOR sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список платежей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/02/03
Author: Bakhtadze Natalya
Creation date: 11/02/03

*/

/*
         ! ! !  В Н И М А Н И Е  ! ! !
   не забудь: после исправления файла в UIB

   САМОЕ ГЛАВНОЕ - подставить new shared в DEFINE QUERY br-fin-doc !!!!!!!
*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.

define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/

define input parameter p-mode  as char   no-undo .
/*{&all}
{&company}
{&g___object}
"receiver":U
"receiver-host":U
"receiver-r-schet":U
"payer":U
"payer-host"
"payer-r-schet":U
"currency":U
"contract-host":U
"receiver-schet":U
"payer-schet":U
"type":U
"type-object":U
"type-stat":U
"type-stat-object":U
"type-stat-date":U
"type-date":U
"ext-type":U
"ext-type-stat":U
"ext-type-stat-date":U
"ext-type-date":U
"schet-fact-order-expense-cashless":U
"schet-fact-order-income-cashless":U

*/

define input parameter p-list as character no-undo.
/*может быть {&all} 'cor-acc';U 'an-uchet-code':U 'cel-nazn-code':U  соответствующие    input parameter
должны быть заполнены правильными значениями*/
define input parameter p-host-code like ub.fin-doc.host-code no-undo .
define input parameter p-obj-type  like ub.fin-doc.obj-type no-undo .
define input parameter p-obj-code  like ub.fin-doc.obj-code no-undo .
define input parameter p-status_ like ub.fin-doc.status_ no-undo.
define input parameter p-fin-doc-type like ub.fin-doc.fin-doc-type no-undo.
define input parameter p-fin-ext-doc-type like ub.fin-doc.fin-ext-doc-type no-undo.
define input parameter p-start-date   like ub.fin-doc.doc-date no-undo .
define input parameter p-end-date   like ub.fin-doc.doc-date no-undo .
define input parameter p-trn-doc-code like ub.fin-doc.trn-doc-code no-undo.
define input parameter p-receiver-type like ub.fin-doc.receiver-type no-undo.
define input parameter p-receiver-code like ub.fin-doc.receiver-code no-undo.
define input parameter p-receiver-r-schet like ub.fin-doc.receiver-r-schet no-undo.
define input parameter p-payer-type like ub.fin-doc.payer-type no-undo.
define input parameter p-payer-code like ub.fin-doc.payer-code no-undo.
define input parameter p-payer-r-schet like ub.fin-doc.payer-r-schet no-undo.
define input parameter p-curr-code like ub.fin-doc.curr-code no-undo.
define input parameter p-receiver-code-schet like ub.fin-doc.receiver-code-schet no-undo.
define input parameter p-payer-code-schet like ub.fin-doc.payer-code-schet no-undo.
define input parameter p-contract-code like ub.fin-doc.contract-code no-undo.
define input parameter p-cor-acc like ub.fin-doc.cor-acc no-undo.
define input parameter p-cor-acc1 like ub.fin-doc.cor-acc1 no-undo.
define input parameter p-an-uchet-code like ub.fin-doc.an-uchet-code no-undo.
define input parameter p-cel-nazn-code like ub.fin-doc.cel-nazn-code no-undo.


/*банки в выборке*/
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список платежей":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/fltfield.i }
{ gbl/prn-lib.i  }
{ gbl/usr-flt.i  }
{ trg/factord.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ str/lib-trn.i }

FUNCTION uf-convert-mode returns character(
                                            input p-mode as character):
CASE p-mode:
  when {&all}
  or
  when "receiver":U
  or
  when "receiver-host":U
  or
  when "receiver-r-schet":U
  or
  when "payer":U
  or
  when "payer-host"
  or
  when "payer-r-schet":U
  or
  when "currency":U
  or
  when "receiver-schet":U
  or
  when "payer-schet":U
  then do:
    return p-mode.
  end.
  when "type":U
  or
  when "type-date":U
  or
  when "type-object":U
  then do:
    return (p-mode + {&delim-par} + p-fin-doc-type).
  end.
  when "ext-type":U
  or
  when "ext-type-date":U
  then do:
    return (p-mode + {&delim-par} + p-fin-ext-doc-type).
  end.
  when "type-stat":U
  or
  when "type-stat-date":U
  or
  when "type-stat-object"
  then do:
     return (p-mode + {&delim-par} + p-fin-doc-type + p-status_).
  end.
  when "ext-type-stat":U
  or
  when "ext-type-stat-date":U
  then do:
    return (p-mode + {&delim-par} + p-fin-ext-doc-type + p-status_).
  end.
  when {&company} then do:
    return (p-mode + {&delim-par} + string(p-host-code)).
  end.
  when {&g___object} then do:
    return (p-mode + {&delim-par} + p-obj-type + string(p-obj-code)).
  end.

END CASE.
END FUNCTION.


define variable filter-point as character no-undo init "findocs" .
define variable filter-point0 as character no-undo init "findocs" .
define variable filter-label as character no-undo init "Список платежей" .
define variable filter-label0 as character no-undo init "Список платежей" .
define variable v-rid-list as character no-undo .
define variable sort-column-name as character no-undo .
define variable print-option as character no-undo.
define variable add-option as character no-undo.
define variable client-option as character no-undo.
define variable schet-option as character no-undo.
define variable factura-option as character no-undo.
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-obj-db-num as integer no-undo init -1.
define variable v-list as character no-undo .
/*начальное значение RS-list взятое из последнего где работал польз*/
define variable v-doc-rec as recid no-undo .
define variable v-for-title as character no-undo.
define variable is-type-mode as logical no-undo .
define variable is-direction as integer no-undo .
define variable is-cash-mode as logical no-undo init ?.
define variable is-fact-mode as logical no-undo .
define variable is-stat-mode as logical no-undo init ?.
define variable is-cli-mode  as logical no-undo .
define variable is-obj-mode  as logical no-undo .
define variable is-fin as logical   no-undo .
DEFINE VARIABLE v-fin-doc-shift-name-num AS CHARACTER NO-UNDO.

/*вспомогат*/
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".

DEFINE BUFFER X_cli-fin-schet FOR ub.fin-schet.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_clients-obj FOR ub.clients.
DEFINE BUFFER X_contract FOR ub.contract.
DEFINE BUFFER X_currency FOR ub.currency.
DEFINE BUFFER X_fin-schet FOR ub.fin-schet.
define buffer X_curr_sysconf for ub.sysconf.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-fin-doc

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_fin-doc

/* Definitions for BROWSE br-fin-doc                                    */
&Scoped-define FIELDS-IN-QUERY-br-fin-doc mark-string(recid(X_fin-doc), v-rid-list) X_fin-doc.host-code X_fin-doc.prn-doc-code X_fin-doc.fin-doc-type X_fin-doc.doc-date X_fin-doc.status_ X_fin-doc.receiver-type + string(X_fin-doc.receiver-code) X_fin-doc.receiver-name X_fin-doc.perm-date X_fin-doc.pay-date X_fin-doc.fact-date X_fin-doc.sttm-code X_fin-doc.sum-doc X_fin-doc.fin-ext-doc-type get-contract(buffer X_fin-doc) X_fin-doc.payer-type + string(X_fin-doc.payer-code) X_fin-doc.payer-name get-currency(buffer X_fin-doc) if X_fin-doc.obj-code <> 0 then (X_fin-doc.obj-type + string(X_fin-doc.obj-code)) else "":U X_fin-doc.fin-doc-code f-factur(buffer X_fin-doc) get-shift(BUFFER X_fin-doc, OUTPUT v-fin-doc-shift-name-num) v-fin-doc-shift-name-num X_fin-doc.trn-doc-code get-CashbookName(X_fin-doc.cashbookid)   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-fin-doc X_fin-doc.prn-doc-code   
&Scoped-define ENABLED-TABLES-IN-QUERY-br-fin-doc X_fin-doc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-fin-doc X_fin-doc
&Scoped-define SELF-NAME br-fin-doc
&Scoped-define QUERY-STRING-br-fin-doc FOR EACH X_fin-doc NO-LOCK
&Scoped-define OPEN-QUERY-br-fin-doc OPEN QUERY {&SELF-NAME} FOR EACH X_fin-doc NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-fin-doc X_fin-doc
&Scoped-define FIRST-TABLE-IN-QUERY-br-fin-doc X_fin-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-add b-lookup B-chg ~
B-del B-factura B-print B-hist B-sch B-Help T-batch B-close B-open B-reject ~
B-client B-schet B-attr B-exp b-incas br-fin-doc ED-notes RS-list ~
sch-prn-doc-code sch-curr-code B-curr sch-doc-date sch-fact-date ~
sch-pay-date sch-c-schet RS-receiver-payer sch-r-schet sch-BIK sch-cli-code ~
RS-cli-type sch-name B-cli mark-num 
&Scoped-Define DISPLAYED-OBJECTS T-batch ED-notes RS-list sch-prn-doc-code ~
sch-curr-code sch-doc-date sch-fact-date sch-pay-date sch-c-schet ~
RS-receiver-payer sch-r-schet sch-BIK sch-cli-code RS-cli-type sch-name ~
mark-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-factur Dialog-Frame 
FUNCTION f-factur RETURNS CHARACTER
  ( buffer loc-t-doc for ub.fin-doc )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD factur Dialog-Frame 
FUNCTION factur RETURNS CHARACTER
  ( BUFFER loc-fin-doc FOR ub.fin-doc )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cashbookname Dialog-Frame 
FUNCTION get-cashbookname RETURNS CHARACTER
  ( input iCashbookID as int64)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-contract Dialog-Frame 
FUNCTION get-contract RETURNS CHARACTER
  ( BUFFER loc-fin-doc FOR ub.fin-doc )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-currency Dialog-Frame 
FUNCTION get-currency RETURNS CHARACTER
  ( BUFFER loc-fin-doc FOR ub.fin-doc )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-shift Dialog-Frame 
FUNCTION get-shift RETURNS DATE
  ( BUFFER buf_fin-doc FOR ub.fin-doc, OUTPUT p-shift-name-num AS CHARACTER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-add 
       MENU-ITEM income-cash    LABEL "Приход наличные"
       MENU-ITEM income-cashless LABEL "Приход безнал" 
       MENU-ITEM income-payoff  LABEL "Приход погашение"
       MENU-ITEM expense-cash   LABEL "Расход наличные"
       MENU-ITEM expense-cashless LABEL "Расход безнал" 
       MENU-ITEM expense-payoff LABEL "Расход погашение"
       RULE
       MENU-ITEM m_copy         LABEL "Копия"         .

DEFINE MENU MENU-B-client 
       MENU-ITEM receiver       LABEL "Получатель"    
       MENU-ITEM payer          LABEL "Плательщик"    .

DEFINE MENU MENU-B-factura 
       MENU-ITEM m_s-f          LABEL "Просмотр Счетов-фактур"
       RULE
       MENU-ITEM m_gen-1        LABEL "Генерация"     
       MENU-ITEM m_gen-2        LABEL "Отказаться от генерации счета-фактуры"
       MENU-ITEM m_gen-3        LABEL "Снять признак - есть генерация счета-фактуры"
       MENU-ITEM m_gen-4        LABEL "Снять 'не опред'".

DEFINE MENU MENU-B-print 
       MENU-ITEM m_one          LABEL "Выбранные (форма по умолчанию)"
       MENU-ITEM m_one-graphics LABEL "Выбранные-графика (форма по умолчанию)"
       MENU-ITEM m_list         LABEL "Список"        
       MENU-ITEM m_form         LABEL "Один с выбором формы".

DEFINE MENU MENU-B-schet 
       MENU-ITEM receiver-schet LABEL "Получатель"    
       MENU-ITEM payer-schet    LABEL "Плательщик"    .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add 
     LABEL "&Добавить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-attr 
     LABEL "&Атриб." 
     SIZE 10 BY 1.

DEFINE BUTTON B-chg 
     LABEL "&Изменить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-cli 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 3 BY 1.

DEFINE BUTTON B-client 
     LABEL "&Контраг." 
     SIZE 10 BY 1.

DEFINE BUTTON B-close 
     LABEL "&Закрыть" 
     SIZE 10 BY 1.

DEFINE BUTTON B-curr 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 3 BY 1.

DEFINE BUTTON B-del 
     LABEL "&Удалить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-exp 
     LABEL "&Экспорт" 
     SIZE 10 BY 1.

DEFINE BUTTON B-factura 
     LABEL "Счет-факт" 
     SIZE 10 BY 1.

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist 
     LABEL "Ис&тория" 
     SIZE 3 BY 1.

DEFINE BUTTON b-incas 
     LABEL "Инкассация" 
     SIZE 14 BY 1.

DEFINE BUTTON b-lookup 
     LABEL "&Просмотр" 
     SIZE 10 BY 1.

DEFINE BUTTON B-mark 
     LABEL "&*" 
     SIZE 3 BY 1.

DEFINE BUTTON B-open 
     LABEL "&Открыть" 
     SIZE 10 BY 1.

DEFINE BUTTON B-print 
     LABEL "Пе&чать" 
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-reject 
     LABEL "&-Отказ" 
     SIZE 10 BY 1.

DEFINE BUTTON B-sch 
     LABEL "&Фильтр" 
     SIZE 3 BY 1.

DEFINE BUTTON B-schet 
     LABEL "&Счета" 
     SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
     LABEL "Вы&бор" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE ED-notes AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sch-BIK AS CHARACTER FORMAT "X(9)":U 
     LABEL "БИК" 
     VIEW-AS FILL-IN 
     SIZE 12 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-c-schet AS CHARACTER FORMAT "X(9)":U 
     LABEL "Корр.счет" 
     VIEW-AS FILL-IN 
     SIZE 22 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-cli-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0 
     LABEL "код" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .91 NO-UNDO.

DEFINE VARIABLE sch-curr-code AS INTEGER FORMAT ">>9":U INITIAL 0 
     LABEL "коду вал" 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE sch-doc-date AS DATE FORMAT "99/99/9999":U 
     LABEL "Дате док-та" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE sch-fact-date AS DATE FORMAT "99/99/9999":U 
     LABEL "Дате факт." 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE sch-name AS CHARACTER FORMAT "X(35)":U 
     LABEL "нач.назв." 
     VIEW-AS FILL-IN 
     SIZE 31 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-pay-date AS DATE FORMAT "99/99/9999":U 
     LABEL "Дате плат." 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE sch-prn-doc-code AS CHARACTER FORMAT "X(16)":U 
     LABEL "номеру" 
     VIEW-AS FILL-IN 
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-r-schet AS CHARACTER FORMAT "X(35)":U 
     LABEL "Расч.счет" 
     VIEW-AS FILL-IN 
     SIZE 22 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE RS-cli-type AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Item 1", "1",
"Item 1", "2"
     SIZE 14.2 BY 1.05 NO-UNDO.

DEFINE VARIABLE RS-list AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3",
"Item 4", "4"
     SIZE 72.2 BY .86
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE RS-receiver-payer AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Item 1", "1",
"Item 1", "2"
     SIZE 26.8 BY 1 NO-UNDO.

DEFINE VARIABLE T-batch AS LOGICAL INITIAL no 
     LABEL "Пктн.рж" 
     VIEW-AS TOGGLE-BOX
     SIZE 10.6 BY 1 TOOLTIP "Пакетная обработка выбранных платежей" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE NEW SHARED QUERY br-fin-doc FOR
                X_fin-doc SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-fin-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-fin-doc Dialog-Frame _FREEFORM
  QUERY br-fin-doc DISPLAY
      mark-string(recid(X_fin-doc), v-rid-list) FORMAT "X(1)":U
X_fin-doc.host-code COLUMN-LABEL "Код!фирмы" FORMAT "999999999":U
X_fin-doc.prn-doc-code FORMAT "X(16)":U
X_fin-doc.fin-doc-type FORMAT "X(3)":U
X_fin-doc.doc-date FORMAT "99/99/9999":U
X_fin-doc.status_ FORMAT "X(8)":U
X_fin-doc.receiver-type + string(X_fin-doc.receiver-code) COLUMN-LABEL "Получатель" FORMAT "X(12)":U
X_fin-doc.receiver-name COLUMN-LABEL "Название ПОЛУЧАТЕЛЯ" FORMAT "X(40)":U
X_fin-doc.perm-date FORMAT "99/99/9999":U
X_fin-doc.pay-date COLUMN-LABEL "Дата платежа!(пост.в банк)" FORMAT "99/99/9999":U
X_fin-doc.fact-date FORMAT "99/99/9999":U
X_fin-doc.sttm-code COLUMn-LABEL "Выписка"
X_fin-doc.sum-doc FORMAT ">,>>>,>>>,>>>,>>9.99":U
X_fin-doc.fin-ext-doc-type COLUMN-LABEL "Расш.тип" FORMAT "X(8)":U
get-contract(buffer X_fin-doc) COLUMN-LABEL "Договор" FORMAT "X(16)":U
X_fin-doc.payer-type + string(X_fin-doc.payer-code) COLUMN-LABEL "Плательщик" FORMAT "X(12)":U
X_fin-doc.payer-name COLUMN-LABEL "Название ПЛАТЕЛЬЩИКА" FORMAT "X(40)":U
get-currency(buffer X_fin-doc) COLUMN-LABEL "Вал" FORMAT "X(3)":U
if X_fin-doc.obj-code <> 0 then (X_fin-doc.obj-type + string(X_fin-doc.obj-code)) else "":U COLUMN-LABEL "Объект" FORMAT "X(12)":U
X_fin-doc.fin-doc-code COLUMN-LABEL "Вн.N" FORMAT "999999999":U
f-factur(buffer X_fin-doc) COLUMN-LABEL "Счет-фактура" FORMAT "X(8)":U
get-shift(BUFFER X_fin-doc, OUTPUT v-fin-doc-shift-name-num) COLUMN-LABEL "Дата смены" FORMAT "99/99/9999":U
v-fin-doc-shift-name-num COLUMN-LABEL "Смена" FORMAT "X(6)"
X_fin-doc.trn-doc-code COLUMN-LABEL "Опер.касса" FORMAT "X(8)"
get-CashbookName(X_fin-doc.cashbookid) COLUMN-LABEL "Кассовая книга" FORMAT "x(30)":U
ENABLE
X_fin-doc.prn-doc-code
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.6 BY 12.38.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-add AT ROW 1 COL 31
     b-lookup AT ROW 1 COL 41
     B-chg AT ROW 1 COL 51
     B-del AT ROW 1 COL 61
     B-factura AT ROW 1 COL 71
     B-print AT ROW 1 COL 86
     B-hist AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     T-batch AT ROW 2 COL 1
     B-close AT ROW 2 COL 11
     B-open AT ROW 2 COL 21
     B-reject AT ROW 2 COL 31
     B-client AT ROW 2 COL 41
     B-schet AT ROW 2 COL 51
     B-attr AT ROW 2 COL 61
     B-exp AT ROW 2 COL 71
     b-incas AT ROW 2 COL 81 WIDGET-ID 2
     br-fin-doc AT ROW 3.05 COL 1.4
     ED-notes AT ROW 15.52 COL 1 NO-LABEL
     RS-list AT ROW 17.57 COL 1.2 NO-LABEL
     sch-prn-doc-code AT ROW 17.57 COL 88.6 COLON-ALIGNED
     sch-curr-code AT ROW 18.57 COL 9 COLON-ALIGNED
     B-curr AT ROW 18.57 COL 15.6
     sch-doc-date AT ROW 18.57 COL 38.2 COLON-ALIGNED
     sch-fact-date AT ROW 18.57 COL 62 COLON-ALIGNED
     sch-pay-date AT ROW 18.57 COL 86 COLON-ALIGNED
     sch-c-schet AT ROW 19.76 COL 40.8 COLON-ALIGNED
     RS-receiver-payer AT ROW 19.81 COL 1.6 NO-LABEL
     sch-r-schet AT ROW 19.81 COL 75.2 COLON-ALIGNED
     sch-BIK AT ROW 20.91 COL 7.6 COLON-ALIGNED
     sch-cli-code AT ROW 20.91 COL 26 COLON-ALIGNED
     RS-cli-type AT ROW 20.91 COL 39.6 NO-LABEL
     sch-name AT ROW 20.91 COL 66.2 COLON-ALIGNED
     B-cli AT ROW 20.95 COL 53
     mark-num AT ROW 1 COL 12.6 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 8.4 BY 1 AT ROW 17.57 COL 73.8
     SPACE(17.10) SKIP(3.46)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Список платежей"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_fin-doc B "?" NO-UNDO ub fin-doc
      TABLE: X_clients-host B "?" ? ub clients
      TABLE: X_fin-doc B "NEW SHARED" ? ub fin-doc
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-fin-doc b-incas Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       B-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add:HANDLE.

ASSIGN 
       B-client:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-client:HANDLE.

ASSIGN 
       B-factura:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-factura:HANDLE.

ASSIGN 
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-print:HANDLE.

ASSIGN 
       B-schet:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-schet:HANDLE.

ASSIGN 
       br-fin-doc:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-fin-doc
/* Query rebuild information for BROWSE br-fin-doc
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_fin-doc NO-LOCK.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE NEW SHARED QUERY br-fin-doc FOR
                X_fin-doc SCROLLING.
     _END_FREEFORM_DEFINE
     _Query            is NOT OPENED
*/  /* BROWSE br-fin-doc */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ENDKEY OF FRAME Dialog-Frame /* Список платежей */
DO:
    run gbl/markqwa.p (
                           input b-mark:sensitive
                          , input v-rid-list) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Список платежей */
DO:
  p-rid-list = v-rid-list.
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
  if add-option = '':U then return no-apply.
  run proc-b-add in this-procedure ( input add-option) no-error.
  if error-status:error then do:
    add-option = (if is-type-mode then p-fin-doc-type else  '':U).
    return no-apply.
  end.
  add-option = (if is-type-mode then p-fin-doc-type else "":U).
  APPLY "ENTRY" to br-fin-doc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr Dialog-Frame
ON CHOOSE OF B-attr IN FRAME Dialog-Frame /* Атриб. */
DO:
define variable loc-doc-rec as recid no-undo .

  if NOT available X_fin-doc then do:
    message
    "Неправильно выбран платеж."
    view-as alert-box ERROR.
    return no-apply.
  end.
  run ref/fd-atti.w (   input parparentproc
                  ,input {&lookup}
                  ,input X_fin-doc.host-code
                  ,input X_fin-doc.fin-doc-code
                 ) NO-ERROR.
  apply "entry" to br-fin-doc in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
if not available X_fin-doc then return no-apply.
run proc-b-chg-lookup in this-procedure ( input {&update}) no-error.
if error-status:error then do:
  return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cli Dialog-Frame
ON CHOOSE OF B-cli IN FRAME Dialog-Frame /* Btn 1 */
DO:
define variable ref-list as character no-undo.
define variable ref-rec as recid no-undo.
define buffer buf_clients for ub.clients.
  run ref/cli-all.w (
                    input parParentProc
                  ,input "b-sel"
                  ,input RS-cli-type
                  ,input ?
                  ,input ?
                  ,input ?
                  ,input ?
                  ,input "without-obj":U
                  ,output ref-list) .
    if ref-list = "" then   do:
      apply "entry" to b-cli in frame {&frame-name}.
      return no-apply.
     end.
    ref-rec = integer( ref-list ).
    FIND FIRST buf_clients WHERE recid (buf_clients) = ref-rec NO-LOCK .
    if NOT (buf_clients.obj-type = {&cmp}
            or
            buf_clients.obj-type = {&prs} ) then do:
      message
      "Выберите контрагента типа" {&cmp} "или" {&prs}
      view-as alert-box error .
      return no-apply.
    end.
    assign
    RS-cli-type =  buf_clients.obj-type
    sch-cli-code = buf_clients.obj-code
    .
    display
    RS-cli-type
    sch-cli-code
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-client
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-client Dialog-Frame
ON CHOOSE OF B-client IN FRAME Dialog-Frame /* Контраг. */
DO:
define variable v-rid-list as character no-undo.
if not available X_fin-doc then return no-apply.

if client-option = '':U then do:
        run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if client-option = '':U then return no-apply.

  run ref/showcli.p ( input parParentProc
               ,input (if client-option = "receiver" then X_fin-doc.receiver-type else X_fin-doc.payer-type)
               ,input (if client-option = "receiver" then X_fin-doc.receiver-code else X_fin-doc.payer-code)
                                ) no-error.
 client-option = '':U.
 APPLY "ENTRY" to br-fin-doc.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-close Dialog-Frame
ON CHOOSE OF B-close IN FRAME Dialog-Frame /* Закрыть */
DO:
  if not available X_fin-doc then return no-apply.
  run proc-close-open in this-procedure ( input {&close-doc}, input t-batch) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-curr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-curr Dialog-Frame
ON CHOOSE OF B-curr IN FRAME Dialog-Frame /* Btn 1 */
DO:
define variable rr as recid no-undo.
define buffer buf_currency for ub.currency.
    rr = ? .
    run ref/currency.w ( input parparentproc, input "b-sel", input-output rr ).
    if rr <> ? then do:
      FIND FIRST buf_currency WHERE
            recid( buf_currency ) = rr NO-LOCK .
      DISPLAY
      buf_currency.curr-code @ sch-curr-code
      with frame {&frame-name} .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  run proc-b-del in this-procedure ( input t-batch) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exp Dialog-Frame
ON CHOOSE OF B-exp IN FRAME Dialog-Frame /* Экспорт */
DO:
  RUN proc-b-exp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-factura
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-factura Dialog-Frame
ON CHOOSE OF B-factura IN FRAME Dialog-Frame /* Счет-факт */
DO:
  if factura-option = '':U then do:
  run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if factura-option = '':U then return no-apply.
IF NOT AVAILABLE X_fin-doc THEN RETURN NO-APPLY.
RUN proc-factura IN THIS-PROCEDURE NO-ERROR.
factura-option = '':U.
APPLY "ENTRY" to br-fin-doc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
define variable loc-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo.
  if NOT available X_fin-doc then do:
    message
    "Неправильно выбран платеж."
    view-as alert-box ERROR.
    return no-apply.
  end.
  loc-doc-rec = recid (X_fin-doc).
  .
  run ref/fincdocs.w
                (
                 input parParentProc
                ,input p-curr-host-code
                ,input "":U /*bttns*/
                ,input "one":U
                ,input X_fin-doc.host-code
                ,input p-obj-type
                ,input p-obj-code
                ,input X_fin-doc.fin-doc-code
                ,input-output v-rid-list
                              )
  .
  reposition br-fin-doc to recid loc-doc-rec no-error.
  apply "entry" to br-fin-doc in frame {&frame-name}.
  apply "value-changed" to br-fin-doc in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-incas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-incas Dialog-Frame
ON CHOOSE OF b-incas IN FRAME Dialog-Frame /* Инкассация */
DO:
  def var loc#log as logical no-undo.
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-doc_add-def':U
  {&cntxt-firm}
  p-curr-host-code
  '':U
  0
  0
  0
  0
  true
  loc#log
}
if not loc#log then return .
  run utl/rkocollection.p(parparentproc,this-procedure,?) no-error.
  if error-status:error then
    message if return-value <> "" 
            then return-value
            else if error-status:get-message(1) <> "" 
                 then error-status:get-message(1)
                 else "Неизвестная ошибка" 
    view-as alert-box error.
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lookup Dialog-Frame
ON CHOOSE OF b-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
if not available X_fin-doc then return no-apply.
run proc-b-chg-lookup in this-procedure ( input {&lookup}) no-error.
if error-status:error then do:
  return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available X_fin-doc then do:
    { gbl/markstrn.i X_fin-doc v-rid-list }
    loc#log = br-fin-doc:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-fin-doc:select-next-row ().
        apply "VALUE-CHANGED" to br-fin-doc in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-fin-doc in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-open
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-open Dialog-Frame
ON CHOOSE OF B-open IN FRAME Dialog-Frame /* Открыть */
DO:
  if not available X_fin-doc then return no-apply.
  run proc-close-open in this-procedure( input {&open-doc}, input t-batch ) no-error .
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  if not avail X_fin-doc then return no-apply.
  if print-option = '':U then do:
        run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if print-option = '':U then return no-apply.
  run proc-b-print in this-procedure ( input print-option) no-error.
  if error-status:error then do:
    print-option = '':U.
    return no-apply.
  end.
  APPLY "ENTRY" to br-fin-doc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
    assign
    v-uf-List_ = Rs-list + {&delim-par} + string(recid(X_fin-doc))
    .
    run uf-set in this-procedure (
      input  ({&uf-findocs-p} + {&delim-par} + uf-convert-mode(p-mode))
      ,input  v-cntxt-userid
      ,input v-uf-List_
      ,input v-uf-Naim
      ,input v-uf-print-graft
      ,input v-uf-sort-gr
      ,input v-uf-type-price
      ,input v-uf-type-val
  )  no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-reject
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-reject Dialog-Frame
ON CHOOSE OF B-reject IN FRAME Dialog-Frame /* -Отказ */
DO:
  if not available X_fin-doc then return no-apply.
  run proc-close-open in this-procedure ( input {&reject-doc}, input t-batch) no-error .
  if error-status:error then return no-apply.
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


&Scoped-define SELF-NAME B-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-schet Dialog-Frame
ON CHOOSE OF B-schet IN FRAME Dialog-Frame /* Счета */
DO:
define variable loc-doc-rec as recid no-undo.
if not available X_fin-doc then return no-apply.

if schet-option = '':U then do:
  run gbl/pop-up.p ( input  self:handle, no) no-error.
end.
if schet-option = '':U then return no-apply.
&scop fin-doc-type-code X_fin-doc.fin-doc-type
if X_fin-doc.fin-doc-type = {&income-cash}
or X_fin-doc.fin-doc-type = {&income-payoff}
or X_fin-doc.fin-doc-type = {&expense-cash}
or X_fin-doc.fin-doc-type = {&expense-payoff}
then do:
  message
  "Нельзя посмотреть счет по платежу" skip
  "платеж имеет тип" {&fin-doc-type-name}
  view-as alert-box.
  return no-apply.
end.
run ref/finschti.w
              (
                 input parParentProc
                ,input p-curr-host-code /*p-curr-host-code*/
                ,input {&lookup}
                ,input X_fin-doc.host-code
                ,input (if schet-option = "payer":U
                        then X_fin-doc.payer-code-schet
                        else X_fin-doc.receiver-code-schet )
                        /*p-code-schet*/
                ,input 0 /*code-bank*/
                ,input (if schet-option = "payer":U
                       then X_fin-doc.payer-type
                       else X_fin-doc.receiver-type)
                ,input (if schet-option = "payer":U
                       then X_fin-doc.payer-code
                       else X_fin-doc.receiver-code)
                ,input X_fin-doc.curr-code
                ,input-output loc-doc-rec
                            )
.
 schet-option = '':U.
 APPLY "ENTRY" to br-fin-doc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available X_fin-doc ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_fin-doc ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-fin-doc
&Scoped-define SELF-NAME br-fin-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-fin-doc Dialog-Frame
ON RETURN OF br-fin-doc IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-fin-doc IN FRAME Dialog-Frame
DO:
  run proc-br-fin-doc no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-fin-doc Dialog-Frame
ON VALUE-CHANGED OF br-fin-doc IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE dops as character no-undo .
  dops = if available X_fin-doc then X_fin-doc.ps else '':U.
  ED-notes:screen-value = dops.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ED-notes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ED-notes Dialog-Frame
ON LEAVE OF ED-notes IN FRAME Dialog-Frame
DO:
  define buffer ps_fin-doc for ub.fin-doc.
  if not available X_fin-doc then return no-apply.

   DO on stop undo, return no-apply:
      FIND PS_fin-doc where
           recid (ps_fin-doc) = recid(X_fin-doc) exclusive.
      if ps_fin-doc.PS <> input frame {&frame-name} ed-notes then
      assign
      ps_fin-doc.PS = input frame {&frame-name} ed-notes
      .
   END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME expense-cash
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL expense-cash Dialog-Frame
ON CHOOSE OF MENU-ITEM expense-cash /* Расход наличные */
DO:
  assign
  add-option = {&expense-cash}.
  APPLY "CHOOSE" to b-add  in frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME expense-cashless
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL expense-cashless Dialog-Frame
ON CHOOSE OF MENU-ITEM expense-cashless /* Расход безнал */
DO:
  assign
  add-option = {&expense-cashless}.
  APPLY "CHOOSE" to b-add  in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME expense-payoff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL expense-payoff Dialog-Frame
ON CHOOSE OF MENU-ITEM expense-payoff /* Расход погашение */
DO:
  assign
  add-option = {&expense-payoff}.
  APPLY "CHOOSE" to b-add  in frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME income-cash
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL income-cash Dialog-Frame
ON CHOOSE OF MENU-ITEM income-cash /* Приход наличные */
DO:
   assign
  add-option = {&income-cash}.
  APPLY "CHOOSE" to b-add  in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME income-cashless
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL income-cashless Dialog-Frame
ON CHOOSE OF MENU-ITEM income-cashless /* Приход безнал */
DO:
  assign
  add-option = {&income-cashless}.
  APPLY "CHOOSE" to b-add  in frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME income-payoff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL income-payoff Dialog-Frame
ON CHOOSE OF MENU-ITEM income-payoff /* Приход погашение */
DO:
   assign
  add-option = {&income-payoff}.
  APPLY "CHOOSE" to b-add  in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_copy Dialog-Frame
ON CHOOSE OF MENU-ITEM m_copy /* Копия */
DO:
  assign
  add-option = {&add-copy}.
  APPLY "CHOOSE" to b-add  in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_form
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_form Dialog-Frame
ON CHOOSE OF MENU-ITEM m_form /* Один с выбором формы */
DO:
   assign
  print-option = 'form':U.
  APPLY "CHOOSE" to b-print  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_gen-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_gen-1 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_gen-1 /* Генерация */
DO:
  ASSIGN
  factura-option = "option1":U.
  APPLY "CHOOSE" to b-factura in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_gen-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_gen-2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_gen-2 /* Отказаться от генерации счета-фактуры */
DO:
  ASSIGN
  factura-option = "option2":U.
  APPLY "CHOOSE" to b-factura in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_gen-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_gen-3 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_gen-3 /* Снять признак - есть генерация счета-фактуры */
DO:
  ASSIGN
  factura-option = "option3":U.
  APPLY "CHOOSE" to b-factura in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_gen-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_gen-4 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_gen-4 /* Снять 'не опред' */
DO:
  ASSIGN
  factura-option = "option4":U.
  APPLY "CHOOSE" to b-factura in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_list Dialog-Frame
ON CHOOSE OF MENU-ITEM m_list /* Список */
DO:
   assign
  print-option = 'LIST':U.
  APPLY "CHOOSE" to b-print  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_one Dialog-Frame
ON CHOOSE OF MENU-ITEM m_one /* Выбранные (форма по умолчанию) */
DO:
   assign
  print-option = 'ONE':U.
  APPLY "CHOOSE" to b-print  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_one-graphics
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_one-graphics Dialog-Frame
ON CHOOSE OF MENU-ITEM m_one-graphics /* Выбранные-графика (форма по умолчанию) */
DO:
   assign
  print-option = 'ONE-GRAPHICS':U.
  APPLY "CHOOSE" to b-print  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_s-f
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_s-f Dialog-Frame
ON CHOOSE OF MENU-ITEM m_s-f /* Просмотр Счетов-фактур */
DO:
  ASSIGN
  factura-option = "option-lkp":U.
  APPLY "CHOOSE" to b-factura in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME payer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL payer Dialog-Frame
ON CHOOSE OF MENU-ITEM payer /* Плательщик */
DO:
    assign
  client-option = "payer":U.
  APPLY "CHOOSE" to b-client in frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME payer-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL payer-schet Dialog-Frame
ON CHOOSE OF MENU-ITEM payer-schet /* Плательщик */
DO:
    assign
  schet-option = "payer":U.
  APPLY "CHOOSE" to b-schet in frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME receiver
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL receiver Dialog-Frame
ON CHOOSE OF MENU-ITEM receiver /* Получатель */
DO:
  assign
  client-option = "receiver":U.
  APPLY "CHOOSE" to b-client in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME receiver-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL receiver-schet Dialog-Frame
ON CHOOSE OF MENU-ITEM receiver-schet /* Получатель */
DO:
  assign
  schet-option = "receiver":U.
  APPLY "CHOOSE" to b-schet in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-cli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-cli-type Dialog-Frame
ON VALUE-CHANGED OF RS-cli-type IN FRAME Dialog-Frame
DO:
  assign
  RS-cli-type.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-list Dialog-Frame
ON VALUE-CHANGED OF RS-list IN FRAME Dialog-Frame
DO:
define variable i-rs-list like rs-list no-undo .
define variable old-rs-list like rs-list no-undo .
define variable rid-list as character no-undo.
define buffer buf_fin-code-cor-acc for ub.fin-code-cor-acc.
define buffer buf_fin-code-cel-nazn for ub.fin-code-cel-nazn.
define buffer buf_fin-code-an-uchet for ub.fin-code-an-uchet.

assign
old-rs-list = rs-list
i-rs-list = input frame {&frame-name} rs-list .
CASE i-rs-list :
    when {&all} then do:
        assign
        rs-list
        p-list = rs-list
        v-for-title = "":U
        .
    end.
    when 'cor-acc':U or when 'cor-acc1':U then do:
        rid-list = "":U .
        run ref/fwcode-1.w (
                        input parParentProc
                      ,input "b-sel"
                      ,input (if p-mode = {&all} then {&all}  else {&company})
                      ,input ?
                      ,input p-curr-host-code
                      ,output rid-list ).
        if rid-list <> "":U then do:
            FIND FIRST buf_fin-code-cor-acc WHERE
                recid( buf_fin-code-cor-acc ) = integer(entry(1, rid-list)) NO-LOCK .
            assign
            p-cor-acc = (if i-rs-list = 'cor-acc':U
                        then buf_fin-code-cor-acc.fin-code
                        else 0)
            p-cor-acc1 = (if i-rs-list = 'cor-acc1':U
                        then buf_fin-code-cor-acc.fin-code
                        else 0)
            rs-list
            p-list =  rs-list
            v-for-title = (if i-rs-list = 'cor-acc':U
                           then "Корреспонд. счет"
                           else "Код кассы")
                           + {&space-char} + buf_fin-code-cor-acc.code-value
            .
        end.
        else do:
            assign
            rs-list:screen-value = old-rs-list.
            return no-apply.
        end.
    end.
    when 'an-uchet-code':U then do:
        rid-list = "":U .
        run ref/fwcode-3.w (
                        input  parParentProc
                       ,input "b-sel"
                       ,input (if p-mode = {&all} then {&all}  else {&company})
                       ,input ?
                       ,input p-curr-host-code
                       ,output rid-list ).
        if rid-list <> "":U then do:
            FIND FIRST buf_fin-code-an-uchet WHERE
                 recid( buf_fin-code-an-uchet ) = integer(entry(1, rid-list)) NO-LOCK .
            assign
            p-an-uchet-code = buf_fin-code-an-uchet.fin-code
            rs-list
            p-list =  rs-list
           v-for-title = "Код ан. учета" + {&space-char} + buf_fin-code-an-uchet.code-value
            .
        end.
        else do:
           assign
            rs-list:screen-value = old-rs-list.
            return no-apply.
        end.
    end.
    when 'cel-nazn-code':U then do:
            rid-list = "":U .
        run ref/fwcode-2.w (
                         parParentProc
                       ,"b-sel"
                       ,(if p-mode = {&all} then {&all}  else {&company})
                       ,input ?
                       ,input p-curr-host-code
                       ,output rid-list ).
        if rid-list <> "":U then do:
            FIND FIRST buf_fin-code-cel-nazn WHERE
                 recid( buf_fin-code-cel-nazn ) = integer(entry(1, rid-list)) NO-LOCK .
            assign
            p-cel-nazn-code = buf_fin-code-cel-nazn.fin-code
            rs-list
            p-list =  rs-list
            v-for-title = "Код целев.назнач." + {&space-char} + buf_fin-code-cel-nazn.code-value
            .
        end.
        else do:
           assign
            rs-list:screen-value = old-rs-list.
            return no-apply.
        end.

    end.

END CASE.
RUn OpenBR in this-procedure ( input yes, input no, input '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-receiver-payer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-receiver-payer Dialog-Frame
ON VALUE-CHANGED OF RS-receiver-payer IN FRAME Dialog-Frame
DO:
  assign
  Rs-receiver-payer.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-BIK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-BIK Dialog-Frame
ON CTRL-J OF sch-BIK IN FRAME Dialog-Frame /* БИК */
DO:
  run proc-find-bik in this-procedure ( input yes, input frame {&frame-name} sch-bik) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-BIK Dialog-Frame
ON RETURN OF sch-BIK IN FRAME Dialog-Frame /* БИК */
DO:
  run proc-find-bik in this-procedure ( input no, input frame {&frame-name} sch-bik) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-c-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-c-schet Dialog-Frame
ON CTRL-J OF sch-c-schet IN FRAME Dialog-Frame /* Корр.счет */
DO:
  run proc-find-c-schet in this-procedure ( input yes, input frame {&frame-name} sch-c-schet) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-c-schet Dialog-Frame
ON RETURN OF sch-c-schet IN FRAME Dialog-Frame /* Корр.счет */
DO:
  run proc-find-c-schet in this-procedure ( input no, input frame {&frame-name} sch-c-schet) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-cli-code Dialog-Frame
ON CTRL-J OF sch-cli-code IN FRAME Dialog-Frame /* код */
DO:
  run proc-find-cli-code in this-procedure ( input yes, input frame {&frame-name} sch-cli-code) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-cli-code Dialog-Frame
ON RETURN OF sch-cli-code IN FRAME Dialog-Frame /* код */
DO:
  run proc-find-cli-code in this-procedure ( input yes, input frame {&frame-name} sch-cli-code) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-curr-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-curr-code Dialog-Frame
ON CTRL-J OF sch-curr-code IN FRAME Dialog-Frame /* коду вал */
DO:
  run proc-find-curr-code in this-procedure ( input yes, input frame {&frame-name} sch-curr-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-curr-code Dialog-Frame
ON RETURN OF sch-curr-code IN FRAME Dialog-Frame /* коду вал */
DO:
   run proc-find-curr-code in this-procedure ( input no, input frame {&frame-name} sch-curr-code) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-doc-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-doc-date Dialog-Frame
ON CTRL-J OF sch-doc-date IN FRAME Dialog-Frame /* Дате док-та */
DO:
   run proc-find-date in this-procedure ( input yes, input frame {&frame-name} sch-doc-date, "doc-date":U) no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-doc-date Dialog-Frame
ON RETURN OF sch-doc-date IN FRAME Dialog-Frame /* Дате док-та */
DO:
  run proc-find-date in this-procedure ( input no, input frame {&frame-name} sch-doc-date, "doc-date":U) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-fact-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-fact-date Dialog-Frame
ON CTRL-J OF sch-fact-date IN FRAME Dialog-Frame /* Дате факт. */
DO:
  run proc-find-date in this-procedure ( input yes, input frame {&frame-name} sch-fact-date, "fact-date":U) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-fact-date Dialog-Frame
ON RETURN OF sch-fact-date IN FRAME Dialog-Frame /* Дате факт. */
DO:
   run proc-find-date in this-procedure ( input no, input frame {&frame-name} sch-fact-date, "fact-date":U) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-name Dialog-Frame
ON CTRL-J OF sch-name IN FRAME Dialog-Frame /* нач.назв. */
DO:
  run proc-find-name in this-procedure ( input yes, input frame {&frame-name} sch-name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-name Dialog-Frame
ON RETURN OF sch-name IN FRAME Dialog-Frame /* нач.назв. */
DO:
  run proc-find-name in this-procedure ( input no, input frame {&frame-name} sch-name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-pay-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-pay-date Dialog-Frame
ON CTRL-J OF sch-pay-date IN FRAME Dialog-Frame /* Дате плат. */
DO:
  run proc-find-date in this-procedure ( input no, input frame {&frame-name} sch-pay-date, "pay-date":U) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-pay-date Dialog-Frame
ON RETURN OF sch-pay-date IN FRAME Dialog-Frame /* Дате плат. */
DO:
  run proc-find-date in this-procedure ( input yes, input frame {&frame-name} sch-pay-date, "pay-date":U) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-prn-doc-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-prn-doc-code Dialog-Frame
ON CTRL-J OF sch-prn-doc-code IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-prn-doc-code in this-procedure ( input yes, input frame {&frame-name} sch-prn-doc-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-prn-doc-code Dialog-Frame
ON RETURN OF sch-prn-doc-code IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-prn-doc-code in this-procedure ( input no, input frame {&frame-name} sch-prn-doc-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-r-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-r-schet Dialog-Frame
ON CTRL-J OF sch-r-schet IN FRAME Dialog-Frame /* Расч.счет */
DO:
  run proc-find-r-schet in this-procedure ( input yes, input frame {&frame-name} sch-r-schet) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-r-schet Dialog-Frame
ON RETURN OF sch-r-schet IN FRAME Dialog-Frame /* Расч.счет */
DO:
  run proc-find-r-schet in this-procedure ( input no, input frame {&frame-name} sch-r-schet) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-batch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-batch Dialog-Frame
ON VALUE-CHANGED OF T-batch IN FRAME Dialog-Frame /* Пктн.рж */
DO:
define variable GLOG as logical no-undo .
  assign
  t-batch.
  run proc-buttons in this-procedure ( input  t-batch).
  if t-batch = no
  and b-mark:sensitive = no then do:
    assign
    v-rid-list = "":U.
    if avail X_fin-doc then
    GLOG = br-fin-doC:refresh().
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
{ gbl/setfltnm.i }

{ gbl/srt-clmn.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_fin-doc.prn-doc-code"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input  yes, input no, input '':U )."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/brwrefre.i "v-doc-rec = recid(X_fin-doc). run OpenBr in this-procedure ( input yes, input no, input '':U). reposition br-fin-doc to recid v-doc-rec no-error. v-doc-rec = ?. " }

{ gbl/ed_date.i sch-doc-date }
{ gbl/ed_date.i sch-pay-date }
{ gbl/ed_date.i sch-fact-date }

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel  }
&scop b-lookup ~{&b-lkp~}
{ gbl/hot-key.i b-lookup }
{ gbl/hot-key.i b-add  }
{ gbl/hot-key.i b-chg  }
{ gbl/hot-key.i b-del  }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-close }
{ gbl/hot-key.i b-open }
{ gbl/hot-key.i b-print }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  v-rid-list = p-rid-list.
  run Mainproc in this-procedure no-error .
  if error-status:error then return error .
  RUN MyEnable in this-procedure .
  RUn OpenBR ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if v-doc-rec <> ? then
  REPOSITION br-fin-doc to recid v-doc-rec No-ERROR.
  { gbl/mv-clmn.i
    &browse-name = "br-fin-doc"
    &frame-name = "{&frame-name}"
    &ext-col = 23
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23'"
    &prev-order-column-condition_1 = " p-mode = ~{&all~} "
    &prev-order-column_2 =  "'1,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,2,18,19,20,21,22,23'"
    &prev-order-column-condition_2 = " p-mode = ~{&company~} "
    &prev-order-column_3 =  "'1,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,2,18,19,20,21,22,23'"
    &prev-order-column-condition_3 = " is-type-mode = yes and is-direction = - 1 "
    &prev-order-column_4 = "'1,3,4,5,7,8,9,10,11,12,13,14,15,16,17,6,2,18,19,20,21,22,23'"
    &prev-order-column-condition_4 = " p-mode = 'status' "
    &prev-order-column_5 =  "'1,3,4,5,6,16,17,9,10,11,12,13,14,18,7,8,10,2,18,19,20,21,22,23'"
    &prev-order-column-condition_5 = " is-type-mode = yes and is-direction = 1 "
    &prev-order-column_6 = "'1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,21,22,23,15'"
    &prev-order-column-condition_6 = " p-mode = 'trn-doc' "
    }
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
  DISPLAY T-batch ED-notes RS-list sch-prn-doc-code sch-curr-code sch-doc-date 
          sch-fact-date sch-pay-date sch-c-schet RS-receiver-payer sch-r-schet 
          sch-BIK sch-cli-code RS-cli-type sch-name mark-num 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-add b-lookup B-chg B-del B-factura B-print 
         B-hist B-sch B-Help T-batch B-close B-open B-reject B-client B-schet 
         B-attr B-exp b-incas br-fin-doc ED-notes RS-list sch-prn-doc-code 
         sch-curr-code B-curr sch-doc-date sch-fact-date sch-pay-date 
         sch-c-schet RS-receiver-payer sch-r-schet sch-BIK sch-cli-code 
         RS-cli-type sch-name B-cli mark-num 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MainProc Dialog-Frame 
PROCEDURE MainProc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  find first X_curr_sysconf no-lock where
                  X_curr_sysconf.host-code = p-curr-host-code no-error.
  if not available X_curr_sysconf then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-curr-host-code"
    p-curr-host-code
    view-as alert-box ERROR.
    return error .
  end.
if LOOKUP(p-mode, ({&all} + {&delim-par} +
                  {&company} + {&delim-par} +
                  {&g___object} + {&delim-par} +
                "fin-doc-type":U + {&delim-par} +
                "status_":U + {&delim-par} +
                "receiver-host":U + {&delim-par} +
                "receiver-r-schet":U + {&delim-par} +
                "payer-host":U + {&delim-par} +
                "payer-r-schet":U + {&delim-par} +
                "currency":U + {&delim-par} +
                "receiver":U + {&delim-par} +
                "payer":U + {&delim-par} +
                "contract-host":U +  {&delim-par} +
                "receiver-schet":U + {&delim-par} +
                "payer-schet":U + {&delim-par} +
                "type":U + {&delim-par} +
                "type-object":U + {&delim-par} +
                "type-stat":U + {&delim-par} +
                "type-stat-object":U + {&delim-par} +
                "type-stat-date":U + {&delim-par} +
                "type-date":U + {&delim-par} +
                "ext-type":U + {&delim-par} +
                "ext-type-stat":U + {&delim-par} +
                "ext-type-stat-date":U + {&delim-par} +
                "ext-type-date":U + {&delim-par} +
                "trn-doc":U + {&delim-par} +
                "schet-fact-order-expense-cashless":U + {&delim-par} +
                "schet-fact-order-income-cashless":U
                ),
                {&delim-par}) = 0
    then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return error .
end.
run uf-get in this-procedure(
    input  ({&uf-findocs-p} + {&delim-par} + uf-convert-mode(p-mode))
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
if not error-status:error
and num-entries(v-uf-List_, {&delim-par}) = 2 then do:
  assign
  v-list = (if p-list = ? then entry(1, v-uf-List_, {&delim-par}) else p-list)
  v-doc-rec = (if v-rid-list = "":U
              then integer(entry(2, v-uf-List_, {&delim-par}))
              else integer(entry(2, v-uf-List_, v-rid-list)) )
  .
end.
if LOOKUP(p-list, ({&all} + {&delim-par} +
                          'cor-acc':U + {&delim-par} +
                            'cel-nazn-code':U + {&delim-par} +
                            'an-uchet-code':U + {&delim-par}), {&delim-par})  = 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-list"
    p-list
    view-as alert-box ERROR.
    return error .
end.
if lOOKUP(p-mode,
                (
                "type":U + {&delim-par} +
                "type-object":U + {&delim-par} +
                "type-stat":U + {&delim-par} +
                "type-stat-object":U + {&delim-par} +
                "type-stat-date":U + {&delim-par} +
                "type-date":U), {&delim-par} ) > 0 then do:
  if p-fin-doc-type = "cash" then do:
  end.
  else do:
  assign
  is-type-mode = yes
  .
  if LOOKUP(p-fin-doc-type , {&fin-doc-types}) = 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-fin-doc-type"
    p-fin-doc-type
    view-as alert-box ERROR.
    return error .
  end.
end.
end.
if lOOKUP(p-mode,
                (
                "type-stat":U + {&delim-par} +
                "type-stat-object":U + {&delim-par} +
                "type-stat-date":U + {&delim-par} +
                "ext-type-stat":U + {&delim-par} +
                "ext-type-stat-date":U + {&delim-par}  +
                "schet-fact-order-expense-cashless":U + {&delim-par}  +
                "schet-fact-order-income-cashless":U
                ), {&delim-par} ) > 0 then do:
  assign
  is-stat-mode = yes
  .
  if p-status_ = {&fin-fact} then do:
    assign
    is-fact-mode = yes
    .
  end.
end.

find first X_clients-host no-lock where
            X_clients-host.obj-type = {&cmp}
        and X_clients-host.obj-code = p-host-code no-error.
if not available X_clients-host then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-host-code"
    p-host-code
    view-as alert-box ERROR.
    return error .
end.
if lookup(p-mode,
                (
                "type-stat":U + {&delim-par} +
                "type-stat-object":U + {&delim-par} +
                "type-stat-date":U + {&delim-par} +
                "ext-type-stat":U + {&delim-par} +
                "ext-type-stat-date":U + {&delim-par} +
                "schet-fact-order-expense-cashless":U + {&delim-par}  +
                "schet-fact-order-income-cashless":U
                ), {&delim-par} ) > 0
AND
lookup(p-status_, {&fin-status-all}) = 0 then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметра вызова p-status_"
  p-status_
  view-as alert-box ERROR.
  return error .
end.

if lookup(p-mode,
                (
                "type":U + {&delim-par} +
                "type-object":U + {&delim-par} +
                "type-stat":U + {&delim-par} +
                "type-stat-object":U + {&delim-par} +
                "type-stat-date":U + {&delim-par} +
                "type-date":U + {&delim-par} +
                "ext-type":U + {&delim-par} +
                "ext-type-stat":U + {&delim-par} +
                "ext-type-stat-date":U + {&delim-par} +
                "ext-type-date":U + {&delim-par} +
                "schet-fact-order-expense-cashless":U + {&delim-par}  +
                "schet-fact-order-income-cashless":U
                ), {&delim-par} ) > 0 then do:
  if p-fin-doc-type = {&income-cash} or
    p-fin-doc-type = {&income-cashless} or
    p-fin-doc-type = {&income-payoff}
    then do:
    assign
    is-direction = 1
    .
  end.
  else do:
    assign
    is-direction = - 1
    .
  end.
end.
assign
is-cash-mode =  if is-type-mode = yes
                then (if p-fin-doc-type = {&income-cash}
                        or
                        p-fin-doc-type = {&expense-cash}
                        or
                        p-fin-doc-type = {&expense-payoff}
                        or
                        p-fin-doc-type = {&income-payoff}
                    then yes
                    else no)
                else (if p-fin-doc-type = "cash"
                      then yes
                      else is-cash-mode)
.


/*  todo */
/*проверить валидность параметра p-fin-ext-doc-type*/


  if LOOKUP(p-mode, (
                {&company} + {&delim-par } +
                "currency":U + {&delim-par} +
                "contract-host":U +  {&delim-par} +
                "type":U + {&delim-par } +
                "type-object":U + {&delim-par } +
                "type-stat":U + {&delim-par } +
                "type-stat-object":U + {&delim-par } +
                "type-stat-date":U + {&delim-par } +
                "type-date":U + {&delim-par } +
                "ext-type":U + {&delim-par } +
                "ext-type-stat":U + {&delim-par } +
                "ext-type-stat-date":U + {&delim-par } +
                "ext-type-date":U + {&delim-par } +
                "receiver-host":U + {&delim-par} +
                "receiver-r-schet":U + {&delim-par} +
                "receiver-schet":U + {&delim-par} +
                "payer-host":U + {&delim-par} +
                "payer-r-schet":U + {&delim-par} +
                "payer-schet":U + {&delim-par} +
                "trn-doc":U + {&delim-par} +
                "schet-fact-order-expense-cashless":U + {&delim-par}  +
                "schet-fact-order-income-cashless":U
                ),
                {&delim-par}) > 0 then do:
    find first X_sysconf no-lock where
                    X_sysconf.host-code = p-host-code no-error.
    if not available X_sysconf then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-host-code"
      p-host-code
      view-as alert-box ERROR.
      return error .
    end.
  end.

  if p-mode = "type-object"
  or p-mode = "type-stat-object" then do:
    find first X_clients-obj no-lock where
                  X_clients-obj.obj-type = p-obj-type
              and X_clients-obj.obj-code = p-obj-code no-error.
    if not available X_clients-obj then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-obj-type и/или p-obj-code"
        p-obj-type p-obj-code
        view-as alert-box ERROR.
        return error .
    end.
    assign
    is-obj-mode = yes
    .
    { gbl/objdbnum.i p-obj-type p-obj-code v-obj-db-num }
  end.
  if lookup(p-mode, {&g___object}) > 0 then do:
    find first X_clients-obj no-lock where
                  X_clients-obj.obj-type = p-obj-type
              and X_clients-obj.obj-code = p-obj-code no-error.
    if not available X_clients-obj then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-obj-type и/или p-obj-code"
        p-obj-type p-obj-code
        view-as alert-box ERROR.
        return error .
    end.
    assign
    is-obj-mode = yes
    .
    { gbl/objdbnum.i p-obj-type p-obj-code v-obj-db-num }
  end.
  if LOOKUP(p-mode, (
                "receiver":U + {&delim-par} +
                "receiver-host":U + {&delim-par} +
                "receiver-r-schet":U
                ),
                {&delim-par}) > 0 then do:
  find first X_clients no-lock where
                X_clients.obj-type = p-receiver-type
            and X_clients.obj-code = p-receiver-code no-error.
    if not available X_clients then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-receiver-type и/или p-receiver-code"
        p-receiver-type p-receiver-code
        view-as alert-box ERROR.
        return error .
    end.
    assign
    is-cli-mode = yes
    .
  end.
  if LOOKUP(p-mode, (
                "payer-host":U + {&delim-par} +
                "payer":U + {&delim-par} +
                "payer-r-schet":U
                ),
                {&delim-par}) > 0 then do:
  find first X_clients no-lock where
                X_clients.obj-type = p-payer-type
            and X_clients.obj-code = p-payer-code no-error.
    if not available X_clients then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-payer-type и/или p-payer-code"
        p-payer-type p-payer-code
        view-as alert-box ERROR.
        return error .
    end.
    assign
    is-cli-mode = yes
    .
  end.
  if lookup(p-mode
          , "receiver-r-schet":U
          , {&delim-par}) > 0 then do:
    find first X_cli-fin-schet no-lock where
              X_cli-fin-schet.host-code = p-curr-host-code
          AND  X_cli-fin-schet.r-schet = p-receiver-r-schet no-error.
    if not available X_cli-fin-schet then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-receiver-r-schet"
        p-receiver-r-schet
        view-as alert-box ERROR.
        return error .
    end.
  end.
  if lookup(p-mode
          , "payer-r-schet":U
          , {&delim-par}) > 0 then do:
    find first X_cli-fin-schet no-lock where
              X_cli-fin-schet.host-code = p-curr-host-code
          AND  X_cli-fin-schet.r-schet = p-payer-r-schet no-error.
    if not available X_cli-fin-schet then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-payer-r-schet"
        p-receiver-r-schet
        view-as alert-box ERROR.
        return error .
    end.
  end.
  if lookup(p-mode
          , "currency":U
          , {&delim-par}) > 0 then do:
    find first X_currency no-lock where
              X_currency.curr-code = p-curr-code no-error.
    if not available X_currency then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-curr-code"
        p-curr-code
        view-as alert-box ERROR.
        return error .
    end.
  end.
  if lookup(p-mode
          , "contract-host":U
          , {&delim-par}) > 0 then do:
    find first X_contract no-lock where
              X_contract.contract-code = p-contract-code
          AND  X_contract.host-code = p-host-code no-error.
    if not available X_contract then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-contract-code"
        p-contract-code
        view-as alert-box ERROR.
        return error .
    end.
  end.
  if lookup(p-mode
          , ("reciever-schet":U + {&delim-par} +
            "schet-fact-order-expense-cashless":U + {&delim-par}  +
            "schet-fact-order-income-cashless":U)
          , {&delim-par}) > 0 then do:
    find first X_fin-schet no-lock where
              X_fin-schet.host-code = p-curr-host-code
          AND  X_fin-schet.code-schet = p-receiver-code-schet no-error.
    if not available X_fin-schet then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-receiver-code-schet"
        p-receiver-code-schet
        view-as alert-box ERROR.
        return error .
    end.
  end.
  if lookup(p-mode
          , ("payer-schet":U + {&delim-par} +
            "schet-fact-order-expense-cashless":U + {&delim-par}  +
            "schet-fact-order-income-cashless":U)
          , {&delim-par}) > 0 then do:
    find first X_fin-schet no-lock where
              X_fin-schet.host-code = p-curr-host-code
          AND  X_fin-schet.code-schet = p-payer-code-schet no-error.
    if not available X_fin-schet then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-payer-code-schet"
        p-payer-code-schet
        view-as alert-box ERROR.
        return error .
    end.
  end.
  if v-rid-list <> "" then do:
      FIND FIRST find_fin-doc No-LOCK where
                recid(find_fin-doc) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_fin-doc then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова v-rid-list" v-rid-list
        view-as alert-box error .
        return error.
      end.
      v-doc-rec = integer(entry(1, v-rid-list)).
    end.
  { gbl/curdbnum.i v-db-num }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
define variable is-finvalue as character no-undo .
define variable is-fintype as character no-undo .
{ gbl/conf-rd.i
"'is-fin'"
"''"
"''"
0
"''"
"''"
"''"
no
is-finvalue
is-fintype
no-error }
is-fin = logical(is-finvalue).
  assign
  b-print:MENU-MOUSE in frame {&frame-name} = 1
  b-add:MENU-MOUSE in frame {&frame-name} = 1
  b-client:MENU-MOUSE in frame {&frame-name} = 1
  b-schet:MENU-MOUSE in frame {&frame-name} = 1
  b-factura:MENU-MOUSE in frame {&frame-name} = 1
  br-fin-doc:num-locked-columns = 1
  X_fin-doc.prn-doc-code:read-only in browse br-fin-doc = yes
  RS-cli-type:radio-buttons = {&CMp} + {&comma-char} + {&cmp} + {&comma-char} + {&prs} + {&comma-char} + {&prs}
  RS-receiver-payer:radio-buttons = "Получатель" + {&comma-char} + "receiver":U + {&comma-char} + "Плательщик" + {&comma-char} + "payer":U
  RS-list:radio-buttons = "Все" + {&comma-char} + {&all} + {&comma-char} +
  "Корреспонд.счет" + {&comma-char} + 'cor-acc':U + {&comma-char} +
  "Код кассы" + {&comma-char} + 'cor-acc1':U + {&comma-char} +
  "Код цел. назнач." + {&comma-char} + 'cel-nazn-code':U + {&comma-char} +
  "Код анал. учета" + {&comma-char} + 'an-uchet-code':U
  RS-list = p-list
  add-option = p-fin-doc-type
  .
  if
  LOOKUP(p-mode, ("schet-fact-order-expense-cashless":U + {&delim-par} +
                  "schet-fact-order-income-cashless":U), {&delim-par}) > 0 then do:
    assign
    rs-list:sensitive in frame {&frame-name} = no.
  end.
  if
  LOOKUP(p-mode, ("type":U + {&delim-par} +
                "type-object":U + {&delim-par} +
                  "type-stat":U + {&delim-par} +
                "type-stat-object":U + {&delim-par} +
                  "type-stat-date":U + {&delim-par} +
                "type-date":U
                ), {&delim-par}) > 0
  or is-type-mode then do:
    CASE p-fin-doc-type:
        when {&income-cash} then do:
            assign
            menu-item income-cashless:sensitive in menu menu-b-add = no
            menu-item income-payoff:sensitive in menu menu-b-add = no
            menu-item expense-cash:sensitive in menu menu-b-add = no
            menu-item expense-cashless:sensitive in menu menu-b-add = no
            menu-item expense-payoff:sensitive in menu menu-b-add = no
            .
        end.
        when {&income-cashless} then do:
            assign
            menu-item income-cash:sensitive in menu menu-b-add = no
            menu-item income-payoff:sensitive in menu menu-b-add = no
            menu-item expense-cash:sensitive in menu menu-b-add = no
            menu-item expense-cashless:sensitive in menu menu-b-add = no
            menu-item expense-payoff:sensitive in menu menu-b-add = no
            .
        end.
        when {&expense-cashless} then do:
            assign
            menu-item income-cash:sensitive in menu menu-b-add = no
            menu-item income-cashless:sensitive in menu menu-b-add = no
            menu-item income-payoff:sensitive in menu menu-b-add = no
            menu-item expense-cash:sensitive in menu menu-b-add = no
            menu-item expense-payoff:sensitive in menu menu-b-add = no
            .
        end.
        when {&expense-cash} then do:
            assign
            menu-item income-cash:sensitive in menu menu-b-add = no
            menu-item income-cashless:sensitive in menu menu-b-add = no
            menu-item income-payoff:sensitive in menu menu-b-add = no
            menu-item expense-cashless:sensitive in menu menu-b-add = no
            menu-item expense-payoff:sensitive in menu menu-b-add = no
            .
        end.
        when {&income-payoff} then do:
            assign
            menu-item income-cash:sensitive in menu menu-b-add = no
            menu-item income-cashless:sensitive in menu menu-b-add = no
            menu-item expense-cash:sensitive in menu menu-b-add = no
            menu-item expense-cashless:sensitive in menu menu-b-add = no
            menu-item expense-payoff:sensitive in menu menu-b-add = no
            .
        end.
        when {&expense-payoff} then do:
            assign
            menu-item income-cash:sensitive in menu menu-b-add = no
            menu-item income-cashless:sensitive in menu menu-b-add = no
            menu-item income-payoff:sensitive in menu menu-b-add = no
            menu-item expense-cash:sensitive in menu menu-b-add = no
            menu-item expense-cashless:sensitive in menu menu-b-add = no
            .
        end.
      when "cash" then do:
          assign
          menu-item income-cash:sensitive in menu menu-b-add = yes
          menu-item income-cashless:sensitive in menu menu-b-add = no
          menu-item income-payoff:sensitive in menu menu-b-add = no
          menu-item expense-cash:sensitive in menu menu-b-add = yes
          menu-item expense-cashless:sensitive in menu menu-b-add = no
          menu-item expense-payoff:sensitive in menu menu-b-add = no
          .
      end.
    END CASE.
  end.
  DISPLAY
  ED-notes
  sch-prn-doc-code
  sch-cli-code
  sch-c-schet when not is-cash-mode
  sch-curr-code
  sch-doc-date
  sch-fact-date
  sch-pay-date
  sch-r-schet when not is-cash-mode
  sch-BIK when not is-cash-mode
  sch-name
  mark-num
  RS-cli-type
  RS-receiver-payer
  RS-list
  WITH FRAME Dialog-Frame.
  run proc-buttons in this-procedure ( input no).
  ENABLE
B-factura when logical(is-finvalue) and  X_sysconf.firm-db-num = v-db-num
  b-quit
  b-lookup
  b-sel when lookup("b-sel":U, bttns) > 0
B-del when (p-curr-host-code = p-host-code  AND available X_sysconf AND (X_sysconf.firm-db-num = v-db-num or v-db-num = v-obj-db-num))
  B-sch
  B-print
  b-exp
  B-client
  B-schet
  B-Help
  b-hist
  b-attr
  br-fin-doc
  b-curr
  b-cli
  T-batch when (
                (p-curr-host-code = p-host-code  AND available X_sysconf AND X_sysconf.firm-db-num = v-db-num)
              )
  ED-notes
  sch-prn-doc-code
  sch-cli-code
  sch-c-schet  when not is-cash-mode
  sch-curr-code
  sch-doc-date
  sch-fact-date
  sch-pay-date
  sch-r-schet  when not is-cash-mode
  sch-BIK when not is-cash-mode
  sch-name
  mark-num
  RS-cli-type
  RS-receiver-payer
  RS-list
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  if is-cash-mode then do:
    hide
    sch-bik
    sch-r-schet
    sch-c-schet
    in frame {&frame-name} .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

define variable title0 as character no-undo.
define variable v-filter-name as character no-undo .
title0 = "Список платежей" + {&space-char}.

&scop run-file   input  p-open-query ~
, input  p-find-next ~
,  input  p-find-condition ~
~
,  INPUT parParentProc ~
,  INPUT this-procedure:handle ~
,  input p-curr-host-code ~
~
,  input p-mode ~
,  input p-list  ~
~
,  input p-host-code ~
,  input p-obj-type ~
,  input p-obj-code ~
,  input p-status_    ~
,  input p-fin-doc-type ~
,  input p-fin-ext-doc-type ~
,  input p-start-date ~
,  input p-end-date    ~
,  input p-trn-doc-code ~
,  input p-receiver-type ~
,  input p-receiver-code  ~
,  input p-receiver-r-schet ~
,  input p-payer-type ~
,  input p-payer-code  ~
,  input p-payer-r-schet ~
,  input p-curr-code  ~
,  input p-receiver-code-schet ~
,  input p-payer-code-schet ~
,  input p-contract-code ~
,  input p-cor-acc ~
,  input p-cor-acc1  ~
,  input p-an-uchet-code ~
,  input p-cel-nazn-code ~
,  input-output v-rid-list ~
~
,  input filter-point  ~
,  input filter-point0 ~
,  input sort-column-name ~
,  output v-filter-name ~
,  input-output v-doc-rec ~
~
) .
filter-point = filter-point0 + p-mode.
if lookup(p-mode,
(
{&all}               + {&delim-par} +
{&company}           + {&delim-par} +
"currency":U
), {&delim-par}) > 0 then do:
  run ref/findcsq1.p ( {&run-file}
end.
if lookup(p-mode,
(
{&g___object}
), {&delim-par}) > 0 then do:
  run ref/findcsqb.p ( {&run-file}
end.
if lookup(p-mode,
                "contract-host":U ,
                {&delim-par}) > 0 then do:
  run ref/findcsq2.p ( {&run-file}
end.
if lookup(p-mode,
("type":U               + {&delim-par} +
"type-stat":U
  ) , {&delim-par}) > 0 then do:
  run ref/findcsq3.p ( {&run-file}
end.
if lookup(p-mode,
("type-stat-date":U       + {&delim-par} +
"type-date":U            ) , {&delim-par}) > 0 then do:
  run ref/findcsq7.p ( {&run-file}
end.
if lookup(p-mode,
("ext-type":U             + {&delim-par} +
"ext-type-stat":U
  ) , {&delim-par}) > 0 then do:
  run ref/findcsq4.p ( {&run-file}
end.
if lookup(p-mode,

(
"schet-fact-order-income-cashless":U + {&delim-par} +
"schet-fact-order-expense-cashless":U + {&delim-par} +
"ext-type-stat-date":U   + {&delim-par} +
"ext-type-date":U        ) , {&delim-par}) > 0 then do:
  run ref/findcsq8.p ( {&run-file}
end.
if lookup(p-mode,
("receiver":U         + {&delim-par} +
"receiver-host":U
), {&delim-par}) > 0 then do:
  run ref/findcsq5.p ( {&run-file}
end.
if lookup(p-mode,
("receiver-r-schet":U + {&delim-par} +
"receiver-schet":U    ), {&delim-par}) > 0 then do:
  run ref/findcsq9.p ( {&run-file}
end.

if lookup(p-mode,
("payer":U            + {&delim-par} +
"payer-schet"
  ), {&delim-par}) > 0 then do:
  run ref/findcsq6.p ( {&run-file}
end.
if lookup(p-mode,
("payer-r-schet":U    + {&delim-par} +
"payer-host":U       ), {&delim-par}) > 0 then do:
  run ref/findcsqa.p ( {&run-file}
end.
if lookup(p-mode,
("type-object":U               + {&delim-par} +
"type-stat-object":U
  ) , {&delim-par}) > 0 then do:
  run ref/findcsqc.p ( {&run-file}
end.

&scop fin-doc-type-code p-fin-doc-type
if p-open-query then do:
  CASE p-mode :
    WHEN {&company} THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2", p-host-code, X_clients-host.obj-name).
    END.
    WHEN {&g___object} THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3&4", p-host-code, X_clients-host.obj-name, p-obj-type, p-obj-code).
    END.
    WHEN "receiver-host":U THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 Получатель &3&4 &5",
                                    p-host-code, X_clients-host.obj-name,
                                    p-receiver-type, p-receiver-code, X_clients.obj-name) .
    END.
    WHEN "receiver":U THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Получатель &1&2 &3",
                                    p-receiver-type, p-receiver-code, X_clients.obj-name) .
    END.
    WHEN "receiver-r-schet":U THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Получатель &1&2 &3 Р/с ?4",
                                    p-receiver-type, p-receiver-code, X_clients.obj-name, p-receiver-r-schet) .
    END.
    WHEN "payer-r-schet":U THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Плательщик &1&2 &3 Р/с ?4",
                                    p-payer-type, p-payer-code, X_clients.obj-name, p-payer-r-schet) .
    END.
    WHEN "payer-host":U THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 Плательщик &3&4 &5",
                                    p-host-code, X_clients-host.obj-name,
                                    p-payer-type, p-payer-code, X_clients.obj-name) .
    END.
    WHEN "payer":U THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Плательщик &1&2 &3",
                                    p-payer-type, p-payer-code, X_clients.obj-name) .
    END.
    WHEN "currency":U THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3",
                                    p-host-code, X_clients-host.obj-name, X_currency.curr-abbr).
    END.
    WHEN "contract-host":U THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 Контракт &3",
                                    p-host-code, X_clients-host.obj-name, X_contract.contract-prn-code).
    END.
    WHEN "receiver-schet":U THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 Р/c Получателя &3",
                                    p-host-code,  X_clients-host.obj-name, X_fin-schet.r-schet).
    END.
    WHEN "payer-schet":U THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 Р/c Плательщика &3",
                                    p-host-code,  X_clients-host.obj-name, X_fin-schet.r-schet).
    END.
    WHEN 'type' THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3",
                                    p-host-code, X_clients-host.obj-name, {&fin-doc-type-name}).
    END.
    WHEN 'type-stat' THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3 &4",
                                    p-host-code, X_clients-host.obj-name, {&fin-doc-type-name}, p-status_).
    END.
    WHEN 'type-object' THEN DO:
      case p-fin-doc-type:
        when "cash" then do:
          ASSIGN
          frame {&frame-name}:TITLE = title0 +
                                      substitute(" Фирма: (&1) &2 &3 &4&5 Наличные платежи",
                                      p-host-code, X_clients-host.obj-name, {&fin-doc-type-name}, p-obj-type, p-obj-code).

        end.
        otherwise do:
          ASSIGN
          frame {&frame-name}:TITLE = title0 +
                                      substitute(" Фирма: (&1) &2 &3 &4&5",
                                      p-host-code, X_clients-host.obj-name, {&fin-doc-type-name}, p-obj-type, p-obj-code).

        end.
      end case.
    END.
    WHEN 'type-stat-object' THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3 &4&5 &6",
                                    p-host-code, X_clients-host.obj-name, {&fin-doc-type-name}, p-obj-type, p-obj-code, p-status_).
    END.

    WHEN 'type-stat-date' THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3 &4 &5-&6",
                                    p-host-code, X_clients-host.obj-name, {&fin-doc-type-name}, p-status_,
                                    p-start-date, "99/99/9999",
                                    p-end-date, "99/99/9999").
    END.
    WHEN 'type-date' THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3 &5-&6",
                                    p-host-code, X_clients-host.obj-name, {&fin-doc-type-name},
                                    p-start-date, "99/99/9999",
                                    p-end-date, "99/99/9999").
    END.
    WHEN 'ext-type' THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3",
                                    p-host-code, X_clients-host.obj-name, p-fin-ext-doc-type).
    END.
    WHEN 'ext-type-stat' THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3 &4",
                                    p-host-code, X_clients-host.obj-name, p-fin-ext-doc-type, p-status_).
    END.
    WHEN 'ext-type-stat-date' THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3 &4 &5-&6",
                                    p-host-code, X_clients-host.obj-name, p-fin-ext-doc-type, p-status_,
                                    string(p-start-date, "99/99/9999"),
                                    string(p-end-date, "99/99/9999")).
    END.
    WHEN 'ext-type-date' THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3 &4-&5",
                                    p-host-code, X_clients-host.obj-name, p-fin-ext-doc-type,
                                    string(p-start-date, "99/99/9999"),
                                    string(p-end-date, "99/99/9999")).

    END.
    WHEN 'schet-fact-order-income-cashless'
    or
    WHEN 'schet-fact-order-expense-cashless'
    THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 СЧЕТ &3 &4 &5 &6-&7"
                                              ,p-host-code
                                              ,X_clients-host.obj-name
                                              ,X_fin-schet.r-schet
                                              ,p-fin-ext-doc-type
                                              ,p-status_
                                              ,string(p-start-date, "99/99/9999")
                                              ,string(p-end-date, "99/99/9999")).

    END.
  END CASE.
  ASSIGN frame {&frame-name}:TITLE =
  frame {&frame-name}:TITLE + {&space-char} + v-for-title.
  run set-filter-name in this-procedure ( INPUT v-filter-name) no-error .
end.

if not p-open-query and v-doc-rec <> ? then
REPOSITION br-fin-doc to recid v-doc-rec No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-fin-doc in frame {&frame-name}.
APPLY "ENTRY" TO br-fin-doc.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame 
PROCEDURE proc-b-add :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-option as character no-undo.
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
define variable v-contract-code like ub.fin-doc.contract-code no-undo .
define variable v-ob-doc-code like ub.fin-ob.doc-code no-undo .
define variable v-receiver-type like ub.fin-doc.receiver-type no-undo .
define variable v-receiver-code like ub.fin-doc.receiver-code no-undo .
define variable v-payer-type like ub.fin-doc.payer-type no-undo .
define variable v-payer-code like ub.fin-doc.payer-code no-undo .
define variable v-receiver-code-schet like ub.fin-doc.receiver-code-schet no-undo.
define variable v-payer-code-schet like ub.fin-doc.payer-code-schet no-undo.
define variable v-curr-code like ub.fin-doc.curr-code no-undo .
define variable v-obj-type like ub.fin-doc.obj-type no-undo .
define variable v-obj-code like ub.fin-doc.obj-code no-undo .
define variable v-cor-acc like ub.fin-doc.cor-acc no-undo.
define variable v-cor-acc1 like ub.fin-doc.cor-acc1 no-undo.
define variable v-an-uchet-code like ub.fin-doc.an-uchet-code no-undo.
define variable v-cel-nazn-code like ub.fin-doc.cel-nazn-code no-undo.
define variable v-mode as character no-undo.
define variable vlog as logical no-undo .
define variable choice as integer no-undo .
define variable v-rid-list as character no-undo .
define variable v-contract-type as character no-undo .
define variable v-contract-cli-type like ub.contract.cli-type no-undo .
define variable v-contract-cli-code like ub.contract.cli-code no-undo .
define variable lock-obj as logical no-undo .
define buffer buf_contract for ub.contract.

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-doc_add-def':U
  {&cntxt-firm}
  p-curr-host-code
  '':U
  0
  0
  0
  0
  true
  loc#log
}
if not loc#log then return error.
if p-option = {&add-copy} then do:
    assign
    p-option = X_fin-doc.fin-doc-type
    v-mode = {&add-copy}
    loc-doc-rec = recid(X_fin-doc)
    .
end.
else do:
    assign
    v-mode = {&add-def}
    .
end.
CASE RS-list :
  when {&all} then do:
    assign
    v-cor-acc = 0
    v-cor-acc1 = 0
    v-an-uchet-code = 0
    v-cel-nazn-code  = 0
    .
  end.
  when 'cor-acc':U  then do:
    assign
    v-cor-acc = p-cor-acc
    v-cor-acc1 = 0
    v-an-uchet-code = 0
    v-cel-nazn-code  = 0
    .
  end.
  when 'cor-acc1':U then do:
    assign
    v-cor-acc = 0
    v-cor-acc1 = p-cor-acc1
    v-an-uchet-code = 0
    v-cel-nazn-code  = 0
    .
  end.
  when 'an-uchet-code':U then do:
    assign
    v-cor-acc = 0
    v-cor-acc1 = 0
    v-an-uchet-code = p-an-uchet-code
    v-cel-nazn-code  = 0
    .
  end.
  when 'cel-nazn-code':U then do:
    assign
    v-cor-acc = 0
    v-cor-acc1 = 0
    v-an-uchet-code = 0
    v-cel-nazn-code  = p-cel-nazn-code
    .
  end.
END CASE.
CASE p-mode :
  WHEN {&company} THEN DO:
    assign
    v-contract-code = 0
    v-receiver-type = "":U
    v-receiver-code = 0
    v-payer-type = "":U
    v-payer-code = 0
    v-receiver-code-schet = 0
    v-payer-code-schet = 0
    v-curr-code     = ?
    v-obj-type = "":U
    v-obj-code = 0
    .
  END.
  WHEN {&g___object}
  or
  when "type-object"
  or
  when "type-stat-object"
  THEN DO:
    assign
    v-contract-code = 0
    v-receiver-type = "":U
    v-receiver-code = 0
    v-payer-type = "":U
    v-payer-code = 0
    v-receiver-code-schet = 0
    v-payer-code-schet = 0
    v-curr-code     = ?
    v-obj-type = p-obj-type
    v-obj-code = p-obj-code
    lock-obj = yes
    .
  END.
  WHEN "receiver-host":U THEN DO:
    assign
    v-contract-code = 0
    v-receiver-type = p-receiver-type
    v-receiver-code = p-receiver-code
    v-payer-type = "":U
    v-payer-code = 0
    v-receiver-code-schet = 0
    v-payer-code-schet = 0
    v-curr-code     = ?
    v-obj-type = "":U
    v-obj-code = 0
    .
  END.
  WHEN "payer-host":U THEN DO:
    assign
    v-contract-code = 0
    v-receiver-type = "":U
    v-receiver-code = 0
    v-payer-type = p-payer-type
    v-payer-code = p-payer-code
    v-receiver-code-schet = 0
    v-payer-code-schet = 0
    v-curr-code     = ?
    v-obj-type = "":U
    v-obj-code = 0
    .
  END.
  WHEN "currency":U THEN DO:
    assign
    v-contract-code = 0
    v-receiver-type = "":U
    v-receiver-code = 0
    v-payer-type = "":U
    v-payer-code = 0
    v-receiver-code-schet = 0
    v-payer-code-schet = 0
    v-curr-code     = p-curr-code
    v-obj-type = "":U
    v-obj-code = 0
    .
  END.
  WHEN "contract-host":U THEN DO:
    assign
    v-contract-code = p-contract-code
    v-receiver-type = "":U
    v-receiver-code = 0
    v-payer-type = "":U
    v-payer-code = 0
    v-receiver-code-schet = 0
    v-payer-code-schet = 0
    v-curr-code     = ?
    v-obj-type = "":U
    v-obj-code = 0
    .
  END.
  WHEN "receiver-schet":U THEN DO:
    assign
    v-contract-code = 0
    v-receiver-type = "":U
    v-receiver-code = 0
    v-payer-type = "":U
    v-payer-code = 0
    v-receiver-code-schet = p-receiver-code-schet
    v-payer-code-schet = 0
    v-curr-code     = ?
    v-obj-type = "":U
    v-obj-code = 0
    .
  END.
  WHEN "payer-schet":U THEN DO:
    assign
    v-contract-code = 0
    v-receiver-type = "":U
    v-receiver-code = 0
    v-payer-type = "":U
    v-payer-code = 0
    v-receiver-code-schet = 0
    v-payer-code-schet = p-payer-code-schet
    v-curr-code     = ?
    v-obj-type = "":U
    v-obj-code = 0
    .
  END.
END CASE.
if v-contract-code = 0
and v-mode <> {&add-copy}
and (not is-obj-mode  or is-fin)
then do:
  run gbl/d-askw.w
               ( input "Выбор договора для платежа",
                        input  ("Выберите договор, по которому Вы будете создавать платеж" + {&new-line}
                                + "или создайте платеж без указания договора"),
                        input "|",
                        input "Выбрать договор с поставщиком|Выбрать договор с покупателем|Без договора|Отменить",
                        input "|||",
                        input 3,
                        input 4,
                        output choice).
  if choice = 4 then return.
  if choice = 1 or
  choice = 2 then do:
    assign
    v-contract-type = if choice = 1
                      then {&income}
                      else (if choice = 2
                            then {&expense}
                            else "all":U
                            )
    v-contract-cli-type = if v-contract-type = {&income}
                          then v-payer-type
                          else (if v-contract-type = {&expense}
                                then v-receiver-type
                                else "":U)
    v-contract-cli-code = if v-contract-type = {&income}
                          then v-payer-code
                          else (if v-contract-type = {&expense}
                                then v-receiver-code
                                else 0)
    .
    run str/cont-all.w (
                    input  parParentProc
                   , input  p-curr-host-code     /* надо передавать фирму */
                   , input  "b-sel":U           /*кнопки для нажатия*/
                   , input  {&company}      /* {&company} или {&all} */
                   , input  (if is-cli-mode then v-contract-cli-type else ?)               /* ? - все контрагенты, или указать */
                   , input  (if is-cli-mode then v-contract-cli-code else ?)               /* ? - все контрагенты, или указать */
                   , input  ?               /* ? - все исполнители, или {&prs} */
                   , input  ?               /* ? - все исполнители, или указать */
                   , input  "current"      /* "all", "current" "deleted" */
                   , input  v-contract-type     /* "all", {&income} {&expense} */
                   , input-output v-rid-list   ) no-error .
   if error-status:error then undo, return error.
   if v-rid-list = "":U then do:
     message
     "Хотите создать платеж без указания договора?"
     view-as alert-box QUESTION buttons YES-NO update vlog.
     if not vlog then undo, return .
   end.
   else do:
      find first buf_contract no-lock where
                recid(buf_contract) = integer(v-rid-list)  no-error .
      if error-status:error then do:
        undo, return error .
      end.
      assign
      v-contract-code = buf_contract.contract-code
      .
   end.
  end.
end.
CASE p-option:
    when {&income-cash} then do:
        run ref/findoci1.w
                      (
                        input parParentProc
                        ,input p-curr-host-code /*p-curr-host-code*/
                        ,input v-mode
                        ,input p-host-code /*p-host-code*/
                        ,input 0 /*p-fin-doc-code*/
                        ,input v-obj-type
                        ,input v-obj-code
                        ,input "":U /*p-fin-ext-doc-type*/
                        ,input v-contract-code
                        ,input '':U /*p-ob-doc-code*/
                        ,input v-payer-type
                        ,input v-payer-code
                        ,input v-curr-code
                        ,input v-cor-acc
                        ,input v-cor-acc1
                        ,input v-an-uchet-code
                        ,input v-cel-nazn-code
                        ,input (if lock-obj then "lock-obj":U else '') /*p-other*/
                        ,input-output loc-doc-rec
                                    ) no-error
        .
    end.
    when {&expense-cash} then do:
        run ref/findoci2.w
                      (
                        input parParentProc
                        ,input p-curr-host-code /*p-curr-host-code*/
                        ,input v-mode
                        ,input p-host-code /*p-host-code*/
                        ,input 0 /*p-fin-doc-code*/
                        ,input v-obj-type
                        ,input v-obj-code
                        ,input "":U /*p-fin-ext-doc-type*/
                        ,input v-contract-code
                        ,input '':U /*p-ob-doc-code*/
                        ,input v-receiver-type
                        ,input v-receiver-code
                        ,input v-curr-code
                        ,input v-cor-acc
                        ,input v-cor-acc1
                        ,input v-an-uchet-code
                        ,input v-cel-nazn-code
                        ,input (if lock-obj then "lock-obj":U else '') /*p-other*/
                        ,input-output loc-doc-rec
                                    ) no-error
        .
    end.
    when {&income-cashless} then do:
            run ref/findoci3.w
                      (
                        input parParentProc
                        ,input p-curr-host-code /*p-curr-host-code*/
                        ,input v-mode
                        ,input p-host-code /*p-host-code*/
                        ,input 0 /*p-fin-doc-code*/
                        ,input v-obj-type
                        ,input v-obj-code
                        ,input "":U /*p-fin-ext-doc-type*/
                        ,input v-contract-code
                        ,input '':U /*p-ob-doc-code*/
                        ,input v-payer-type
                        ,input v-payer-code
                        ,input v-receiver-code-schet
                        ,input v-payer-code-schet
                        ,input v-curr-code
                        ,input v-cor-acc
                        ,input v-cor-acc1
                        ,input v-an-uchet-code
                        ,input v-cel-nazn-code
                        ,input "":U /*p-other*/
                        ,input-output loc-doc-rec
                                    ) no-error
        .
    end.
    when {&expense-cashless} then do:
            run ref/findoci4.w
                      (
                        input parParentProc
                        ,input p-curr-host-code /*p-curr-host-code*/
                        ,input v-mode
                        ,input p-host-code /*p-host-code*/
                        ,input 0 /*p-fin-doc-code*/
                        ,input v-obj-type
                        ,input v-obj-code
                                                ,input "":U /*p-fin-ext-doc-type*/
                        ,input v-contract-code
                        ,input '':U /*p-ob-doc-code*/
                        ,input v-receiver-type
                        ,input v-receiver-code
                        ,input v-receiver-code-schet
                        ,input v-payer-code-schet
                        ,input v-curr-code
                        ,input v-cor-acc
                        ,input v-cor-acc1
                        ,input v-an-uchet-code
                        ,input v-cel-nazn-code
                        ,input "":U /*p-other*/
                        ,input-output loc-doc-rec
                                    ) no-error
        .
    end.
    when {&income-payoff} then do:
        run ref/findoci5.w
                      (
                        input parParentProc
                        ,input p-curr-host-code /*p-curr-host-code*/
                        ,input v-mode
                        ,input p-host-code /*p-host-code*/
                        ,input 0 /*p-fin-doc-code*/
                        ,input v-obj-type
                        ,input v-obj-code
                        ,input "":U /*p-fin-ext-doc-type*/
                        ,input v-contract-code
                        ,input '':U /*p-ob-doc-code*/
                        ,input v-payer-type
                        ,input v-payer-code
                        ,input v-curr-code
                        ,input v-cor-acc
                        ,input v-cor-acc1
                        ,input v-an-uchet-code
                        ,input v-cel-nazn-code
                        ,input "":U /*p-other*/
                        ,input-output loc-doc-rec
                                    ) no-error
        .
    end.
    when {&expense-payoff} then do:
        run ref/findoci6.w
                      (
                        input parParentProc
                        ,input p-curr-host-code /*p-curr-host-code*/
                        ,input v-mode
                        ,input p-host-code /*p-host-code*/
                        ,input 0 /*p-fin-doc-code*/
                        ,input v-obj-type
                        ,input v-obj-code
                        ,input "":U /*p-fin-ext-doc-type*/
                        ,input v-contract-code
                        ,input '':U /*p-ob-doc-code*/
                        ,input v-receiver-type
                        ,input v-receiver-code
                        ,input v-curr-code
                        ,input v-cor-acc
                        ,input v-cor-acc1
                        ,input v-an-uchet-code
                        ,input v-cel-nazn-code
                        ,input "":U /*p-other*/
                        ,input-output loc-doc-rec
                                    ) no-error
        .
    end.
END CASE.
if error-status:error then do:
  undo, return error .
end.
if loc-doc-rec <> ? then do:
    RUn OpenBR in this-procedure ( input yes, input no, input '':U).
    reposition br-fin-doc to recid loc-doc-rec no-error.
end.
apply "entry" to br-fin-doc in frame {&frame-name}.
apply "value-changed" to br-fin-doc in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg-lookup Dialog-Frame 
PROCEDURE proc-b-chg-lookup :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-change-mode as character no-undo.
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
define variable lock-obj as logical no-undo .

if p-change-mode = {&update}
then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-doc_update':U
    {&cntxt-firm}
    p-curr-host-code
    '':U
    0
    0
    0
    0
    true
    loc#log
  }
end.
else do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-doc_lookup':U
    {&cntxt-firm}
    p-curr-host-code
    '':U
    0
    0
    0
    0
    true
    loc#log
  }
end.
if not loc#log then return error.
case p-mode:
  WHEN {&g___object}
  or
  when "type-object"
  or
  when "type-stat-object"
  THEN DO:
    assign
    lock-obj = yes
    .
  END.
end.
assign
loc-doc-rec = recid(X_fin-doc).
CASE X_fin-doc.fin-doc-type:
    when {&income-cash} then do:
            run ref/findoci1.w
                          (
                            input parParentProc
                            ,input p-curr-host-code /*p-curr-host-code*/
                            ,input p-change-mode
                            ,input X_fin-doc.host-code /*p-host-code*/
                            ,input X_fin-doc.fin-doc-code /*p-fin-doc-code*/
                            ,input X_fin-doc.obj-type /*p-obj-type*/
                            ,input X_fin-doc.obj-code /*p-obj-type*/
                            ,input X_fin-doc.fin-ext-doc-type
                            ,input 0
                            ,input '':U /*p-ob-doc-code*/
                            ,input "":U
                            ,input 0
                            ,input ?
                            ,input 0
                            ,input 0
                            ,input 0
                            ,input 0
                            ,input (if lock-obj then "lock-obj":U else '') /*p-other*/
                            ,input-output loc-doc-rec
                                        ) no-error
            .
    end.
    when {&expense-cash} then do:
            run ref/findoci2.w
                          (
                            input parParentProc
                            ,input p-curr-host-code /*p-curr-host-code*/
                            ,input p-change-mode
                            ,input X_fin-doc.host-code /*p-host-code*/
                            ,input X_fin-doc.fin-doc-code /*p-fin-doc-code*/
                            ,input X_fin-doc.obj-type /*p-obj-type*/
                            ,input X_fin-doc.obj-code /*p-obj-type*/
                            ,input X_fin-doc.fin-ext-doc-type
                            ,input 0
                            ,input '':U /*p-ob-doc-code*/
                            ,input "":U
                            ,input 0
                            ,input ?
                            ,input 0
                            ,input 0
                            ,input 0
                            ,input 0
                            ,input (if lock-obj then "lock-obj":U else '') /*p-other*/
                            ,input-output loc-doc-rec
                                        ) no-error
            .
    end.
    when {&income-cashless} then do:
            run ref/findoci3.w
                          (
                            input parParentProc
                            ,input p-curr-host-code /*p-curr-host-code*/
                            ,input p-change-mode
                            ,input X_fin-doc.host-code /*p-host-code*/
                            ,input X_fin-doc.fin-doc-code /*p-fin-doc-code*/
                            ,input X_fin-doc.obj-type /*p-obj-type*/
                            ,input X_fin-doc.obj-code /*p-obj-type*/
                            ,input X_fin-doc.fin-ext-doc-type
                            ,input 0
                            ,input '':U /*p-ob-doc-code*/
                            ,input "":U
                            ,input 0
                            ,input 0
                            ,input 0
                            ,input ?
                            ,input 0
                            ,input 0
                            ,input 0
                            ,input 0
                            ,input "":U /*p-other*/
                            ,input-output loc-doc-rec
                                        ) no-error
            .
    end.
    when {&expense-cashless} then do:
            run ref/findoci4.w
                          (
                            input parParentProc
                            ,input p-curr-host-code /*p-curr-host-code*/
                            ,input p-change-mode
                            ,input X_fin-doc.host-code /*p-host-code*/
                            ,input X_fin-doc.fin-doc-code /*p-fin-doc-code*/
                            ,input X_fin-doc.obj-type /*p-obj-type*/
                            ,input X_fin-doc.obj-code /*p-obj-type*/
                            ,input X_fin-doc.fin-ext-doc-type
                            ,input 0
                            ,input '':U /*p-ob-doc-code*/
                            ,input "":U
                            ,input 0
                            ,input 0
                            ,input 0
                            ,input ?
                            ,input 0
                            ,input 0
                            ,input 0
                            ,input 0
                            ,input "":U /*p-other*/
                            ,input-output loc-doc-rec
                                        ) no-error
            .
    end.
    when {&income-payoff} then do:
            run ref/findoci5.w
                          (
                            input parParentProc
                            ,input p-curr-host-code /*p-curr-host-code*/
                            ,input p-change-mode
                            ,input X_fin-doc.host-code /*p-host-code*/
                            ,input X_fin-doc.fin-doc-code /*p-fin-doc-code*/
                            ,input X_fin-doc.obj-type /*p-obj-type*/
                            ,input X_fin-doc.obj-code /*p-obj-type*/
                            ,input X_fin-doc.fin-ext-doc-type
                            ,input 0
                            ,input '':U /*p-ob-doc-code*/
                            ,input "":U
                            ,input 0
                            ,input ?
                            ,input 0
                            ,input 0
                            ,input 0
                            ,input 0
                            ,input "":U /*p-other*/
                            ,input-output loc-doc-rec
                                        ) no-error
            .
    end.
    when {&expense-payoff} then do:
            run ref/findoci6.w
                          (
                            input parParentProc
                            ,input p-curr-host-code /*p-curr-host-code*/
                            ,input p-change-mode
                            ,input X_fin-doc.host-code /*p-host-code*/
                            ,input X_fin-doc.fin-doc-code /*p-fin-doc-code*/
                            ,input X_fin-doc.obj-type /*p-obj-type*/
                            ,input X_fin-doc.obj-code /*p-obj-type*/
                            ,input X_fin-doc.fin-ext-doc-type
                            ,input 0
                            ,input '':U /*p-ob-doc-code*/
                            ,input "":U
                            ,input 0
                            ,input ?
                            ,input 0
                            ,input 0
                            ,input 0
                            ,input 0
                            ,input "":U /*p-other*/
                            ,input-output loc-doc-rec
                                        ) no-error
            .
    end.
END CASE.
if error-status:error then do:
  undo, return error .
end.
if loc-doc-rec <> ? and p-change-mode = {&update} then do:
    RUn OpenBR ( input yes, input no, input '':U).
    reposition br-fin-doc to recid loc-doc-rec no-error.
end.
apply "entry" to br-fin-doc in frame {&frame-name}.
apply "value-changed" to br-fin-doc in frame {&frame-name}.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame 
PROCEDURE proc-b-del :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-is-batch as logical no-undo .
define variable loc#log as logical no-undo.
define variable ii as integer no-undo .
define variable ok-ii as integer no-undo .
define variable v-new-rid-list as character no-undo .
define variable v-doc-rec as recid no-undo.
define variable v-found-fact as integer no-undo .
define buffer buf_fin-doc for ub.fin-doc.

if not available X_fin-doc then return error.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-doc_deletion':U
  {&cntxt-firm}
  p-curr-host-code
  '':U
  0
  0
  0
  0
  true
  loc#log
}
if not loc#log then return error.
CASE p-is-batch:
  when no then do:
      find first buf_fin-doc exclusive-lock where
      recid(buf_fin-doc) = recid(X_fin-doc) NO-ERROR.
      if not avail buf_fin-doc then return no-apply.
      IF buf_fin-doc.status_ <> {&fin-new}
      and buf_fin-doc.status_ <> {&fin-fact}
      THEN DO:
        MESSAGE
        "Платеж закрыт - удалять нельзя!"
        VIEW-AS ALERT-BOX ERROR.
        RETURN error.
      END.
      loc#log = no.
      MESSAGE
      "Вы уверены, что хотите удалить платеж?" skip(0)
      string(if buf_fin-doc.status_ = {&fin-fact} then "Платеж закрыт до статуса <факт>, удаление повлечет за собой перерасчет архивов" else "")
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE loc#log.
      IF loc#log <> YES THEN DO:
        RETURN error.
      END.
    do
    on error undo, return error
    on stop undo, return error

    :
      if buf_fin-doc.status_ = {&fin-fact} then do:
        run trg/findocdl.p (
                        input parparentproc
                       ,input buf_fin-doc.host-code
                       ,input buf_fin-doc.fin-doc-code
                       ,input yes /*удаление закртого на факт*/
                       ,input no) no-error.
        if error-status:error then do:
          message
          "Ошибка при удалении платежа, закрытого до статуса факт" skip
          error-status:get-message(1) skip
          return-value
          view-as alert-box error .
        end.
      end.
      else do:
        run trg/findocdl.p (
                        input parparentproc
                       ,input buf_fin-doc.host-code
                       ,input buf_fin-doc.fin-doc-code
                       ,input no /*удаление закртого на факт*/
                       ,input no) no-error.
      end.
    end.
    RUN OpenBr in this-procedure ( input yes, input no, input '':U).
    reposition br-fin-doc to row 1 No-ERROR.
  end.
  when yes then do:
      loc#log = no.
      MESSAGE
      "Вы уверены, что хотите удалить ВСЕ отмеченные ВАМИ платеж?"
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE loc#log.
      IF loc#log <> YES THEN DO:
        RETURN error.
      END.
    do
    on error undo, return error
    on stop undo, return error

    :
      _do:
      do ii = 1 to num-entries(v-rid-list):
        run waitfram-show in this-procedure ( substitute("Обрабатывается &1 платеж списка", ii)).
        find first buf_fin-doc where
            recid(buf_fin-doc) = integer(entry(ii, v-rid-list)) exclusive-lock no-error .
        if ii = 1 then do:
          assign
          v-doc-rec = recid(buf_fin-doc)
          .
        end.
        if not avail buf_fin-doc
        or (buf_fin-doc.status_ <> {&fin-new}
        and buf_fin-doc.status_ <> "":U)
        then do:
          assign
          v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else {&comma-char}) + entry(ii, v-rid-list)
          .
          if buf_fin-doc.status_ = {&fin-fact} then do:
            v-found-fact = v-found-fact + 1.
          end.
          NEXT _do.
        end.
        run trg/findocdl.p (
                       input parparentproc
                      ,input buf_fin-doc.host-code
                      ,input buf_fin-doc.fin-doc-code
                      ,input no
                      ,input yes ) no-error.
        if error-status:error then do:
          assign
          v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else {&comma-char}) + entry(ii, v-rid-list)
          .
          NEXT _do.
        end.
        else do:
          assign
          ok-ii = ok-ii + 1
          .
        end.
      end.
    end.
    run waitfram-hide in this-procedure .
    assign
    v-rid-list = v-new-rid-list
    .
    RUN OpenBr in this-procedure ( input yes, input no, input '':U).
    reposition br-fin-doc to recid integer(entry(1, v-rid-list)) No-ERROR.
    message
    substitute("Из &1 выбранных Вами платежей удалось удалить &2&3"
          , ii - 1
          , ok-ii
          , {&new-line})
    (if v-found-fact > 0
    then substitute("В т.ч. было выбрано &1 платежей в статусе <факт>,&2Удаление платежей в статусе <факт> в  пакетном режиме ЗАПРЕЩЕНО"
                    , v-found-fact
                    , {&new-line}
                    )
    else '':U
    )

    view-as alert-box.
  end. /*when yes*/
END CASE.
APPLY "Value-CHanged" to br-fin-doc in frame {&frame-name}.
APPLY "ENTRY" to br-fin-doc in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-exp Dialog-Frame 
PROCEDURE proc-b-exp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable varxmldocfl      as character no-undo.
define variable varxmldocfl-type as character no-undo.
define variable varpar-type as character no-undo.
define variable v-file-name as character no-undo .
define variable for-dir as character no-undo .
define variable accum-count as integer no-undo .
define variable accum-count-ok as integer no-undo .
define variable loclog as logical no-undo .
define variable ii as integer no-undo .
define variable ii0 as integer no-undo .
define buffer buf_fin-doc for ub.fin-doc.
if not available X_fin-doc then do:
  message "Неправильный выбор документа.".
  return no-apply.
end.
define variable v-sys-key   as character         no-undo.
{ gbl/currsysk.i
  v-sys-key
  no-error
}
CASE t-batch:
  when no then do:
    assign
    v-file-name = /*"f":U + string(X_fin-doc.fin-doc-code) + ".xml"*/ ?
    .
    run str/xmlfdoc.p ( input X_fin-doc.host-code
                       ,input  X_fin-doc.fin-doc-code
                       ,input-output v-file-name
                       ,input  yes
                       ,input  yes) no-error .
  end.
  when  yes then do:
    if v-rid-list = "":U then do:
        message
        "Вы не отметили ни одного платежа"
        view-as alert-box error.
        return error.
    end.
    run gbl/d-file.p
      (
       input-output v-file-name             /* p-file-id           */
      ,input-output for-dir                 /* p-file-directory    */
      ,input  (" Все файлы XML (*.xml) ") /* p-filter-names      */
      ,input  ("*.xml":U)                   /* p-filter-values     */
      ,input  {&comma-char}                 /* p-filter-delimiter  */
      ,input  (".xml":U)                    /* p-default-extension */
      ,input  no                            /* p-must-exist        */
      ,input  yes                           /* p-save-as           */
      ,input  yes                           /* p-use-filename      */
      ,input  "Введите имя файла"           /* p-title             */
      ,output loclog                       /* p-choose            */
      ) .
    if not loclog then do:
      return .
    end.
    run waitfram-show in this-procedure ( input "Ждите...").
    assign
    v-doc-rec = recid(X_fin-doc)
    ii0 = num-entries(v-rid-list)
    .

    _do:
    do ii = 1 to ii0:
      find first buf_fin-doc no-lock where
                recid(buf_fin-doc) = integer(entry(ii, v-rid-list)) no-error .

      if available buf_fin-doc then do:
        assign
        accum-count = accum-count + 1
        .
        run str/xmlfdoc.p (
                        input buf_fin-doc.host-code
                      , input buf_fin-doc.fin-doc-code
                      , input-output v-file-name
                      , input (accum-count-ok = 0)
                      , input ii = ii0
                      ) no-error .
        if not error-status:error then
        assign
        accum-count-ok = accum-count-ok + 1
        .
      end.
    end. /*do ii*/
    run waitfram-hide in this-procedure .
  end.
END CASE.
if error-status:error
or (t-batch and accum-count <> accum-count-ok)
then do:
  message
  "Ошибка при выгрузке платежа(-ей) в XML-формате" skip
  string(if t-batch then substitute("Выгружено &1 платежей из &2", accum-count-ok, accum-count) else "":U)
  view-as alert-box .
  if not t-batch then
  return error .
end.

if search ("exmldoc.bat") <> ? then do:
  os-command silent value(search ("exmldoc.bat") + " " + v-file-name + " " + v-sys-key).
end.
else do:
  if search (v-file-name ) <> ? then do:
    message "Документ(-ы) выгружен(-ы) в файл " v-file-name view-as alert-box.
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame 
PROCEDURE proc-b-print :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER loc-option as character no-undo.
if loc-option = '':U then return error.
CASE loc-option:
when 'ONE':U then do:
  run proc-print-one in this-procedure .
end.
when 'ONE-GRAPHICS':U then do:
  RUN proc-print-one-graphics IN THIS-PROCEDURE.
end.
when 'LIST':U then do:
  run proc-print-list no-error.
end.
when 'form':U then do:
  if available X_fin-doc then do:
    run ref/fdoc-prn.p (
          input parparentproc
        , input this-procedure
        , input string(recid(X_fin-doc))
    ).
  end.

end.
end case.
loc-option = ''.
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
  tbl = 'fin-doc'
  join-tbl = 'X_fin-doc'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('fin-doc-code', 'Вн.№ платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('prn-doc-code', 'Номер', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
 input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('contract-code', 'Вн.№ договора', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('trn-doc-code', 'ОП.Касса', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('doc-date', 'Дата док-та', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name-doc', 'Создал', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', 'Дата факт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name-fact', 'Закрыл на факт', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('perm-date', 'Дата разр', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name-perm', 'Закрыл на разр', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-date', 'Дата платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name-pl', 'Закрыл на опл', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


run fltfield-add in this-procedure('fin-doc-type', 'Тип документа', 'fin-doc-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fin-ext-doc-type', 'Расширен. тип документа', 'fin-ext-doc-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', '', 'fin-doc-stat',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('curr-code', '', 'curr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sum-doc', 'Сумма в валюте платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sum-base', 'Сумма в баз.вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sum-rubl', 'Сумма в {&abbr_rublyah}', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('(X_fin-doc.sum-contr - X_fin-doc.con-sum-contr)', 'Свободный остаток', 'function_decimal',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('cor-acc', 'Внутр. код корреспонд.счета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cor-acc-value', 'Корреспонд.счет', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cor-acc1', 'Внутр. код корреспонд.счета2', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cor-acc1-value', 'Корреспонд.счет2', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('an-uchet-code', 'Внутр код анал.учета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('an-uchet-value', 'Код анал.учета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cel-nazn-code', 'Внутр. код целевого назначения', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cel-nazn-value', 'Код целевого назначения', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('vid-plat', 'Вид платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('stat-pl', 'Статус плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('vid-opl', 'Вид операции', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('nazn-pl', 'Назначение платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('nazn-pl', 'Срок платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ocher-pl', 'Очередность платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('receiver-type{&delim-flt}receiver-code', 'Получатель', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-name', 'Название получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-bik', 'БИК получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-inn', '{&abbr_inn_allshift} получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-kpp', '{&abbr_kpp_allshift} получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-bank-name', 'Банк получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-bank-city', 'Город банка получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-r-schet', 'Расч.счет получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-c-schet', 'Корр.счет получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-code-schet', 'Код счета получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-type{&delim-flt}payer-code', 'Плательщик', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-name', 'Название плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-bik', 'БИК плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-inn', '{&abbr_inn_allshift} плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-kpp', '{&abbr_kpp_allshift} плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-bank-name', 'Банк плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-bank-city', 'Город банка плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-r-schet', 'Расч.счет плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-c-schet', 'Корр.счет плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-code-schet', 'Код счета плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('PS', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('factur-date', 'Дата генерации счета-фактуры', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('CashBookId', 'Кассовая книга', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                   , INPUT (filter-point + {&delim-par} + FILTER-LABEL)
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-fin-doc Dialog-Frame 
PROCEDURE proc-br-fin-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  { ref/brwsretr.i }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-buttons Dialog-Frame 
PROCEDURE proc-buttons :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-is-batch as logical no-undo.
ENABLE
b-close when (is-fact-mode = no
              AND not transaction
              AND
              (not p-is-batch
              or
              (
              is-stat-mode = yes
                AND
              is-type-mode = yes
              ))
              AND (p-curr-host-code = p-host-code
                  AND available X_sysconf
                  AND (X_sysconf.firm-db-num = v-db-num or v-cntxt-db-num = v-obj-db-num)))
b-open when (is-fact-mode = no
            AND not transaction
            AND
              (not p-is-batch
              or
              (
              is-stat-mode = yes
                AND
              is-type-mode = yes
              ))
            AND (p-curr-host-code = p-host-code
                AND available X_sysconf
                AND (X_sysconf.firm-db-num = v-db-num or v-cntxt-db-num = v-obj-db-num)) )
b-reject when (is-fact-mode = no
              AND not transaction
              AND
              (not p-is-batch
              or
              (
              is-stat-mode = yes
                AND
              is-type-mode = yes
              ))
              AND (p-curr-host-code = p-host-code
                    AND available X_sysconf
                    AND X_sysconf.firm-db-num = v-db-num) )
with frame {&frame-name} .
CASE p-is-batch:
    when yes then do:
        ENABLE
        B-mark
        with frame {&frame-name}.
        disable
        b-add
        b-incas
        b-chg with frame {&frame-name}.
      assign
      menu-item m_one:sensitive in menu menu-b-print = (is-type-mode = yes).
      menu-item m_one-graphics:sensitive in menu menu-b-print = (is-type-mode = yes).
      menu-item m_form:sensitive in menu menu-b-print = no.
    end.
    when no then do:
        ENABLE
        B-mark when lookup("b-mark":U, bttns) > 0
        B-add  when (p-curr-host-code = p-host-code
                    AND available X_sysconf
                    AND (X_sysconf.firm-db-num = v-db-num or v-cntxt-db-num = v-obj-db-num)
                    AND not p-is-batch
                    AND not(is-stat-mode = yes and p-status_ <> {&fin-new})
                    AND not transaction
                    )
        b-incas when (p-curr-host-code = p-host-code
                    AND available X_sysconf
                    AND (X_sysconf.firm-db-num = v-db-num or v-cntxt-db-num = v-obj-db-num)
                    AND not p-is-batch
                    AND not(is-stat-mode = yes and p-status_ <> {&fin-new})
                    AND not transaction
                    )
        B-chg when (p-curr-host-code = p-host-code
                    AND available X_sysconf
                    AND (X_sysconf.firm-db-num = v-db-num or v-cntxt-db-num = v-obj-db-num)
                    AND not transaction
                    )
        with frame {&frame-name}.
        DISABLE
        b-mark when lookup("b-mark":U, bttns) = 0
        with frame {&frame-name}.
        assign
      menu-item m_one:sensitive in menu menu-b-print = no.
      menu-item m_one-graphics:sensitive in menu menu-b-print = no.
      menu-item m_form:sensitive in menu menu-b-print = yes.
    end.
END CASE.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-close-open Dialog-Frame 
PROCEDURE proc-close-open :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-close-mode as character no-undo .
define input parameter p-is-batch as logical no-undo .

define variable v-status_ as character no-undo .
/*куда перейдет*/
define variable v-old-status_ as character no-undo .
/*статус первой записи*/
define variable v-fin-doc-type as character no-undo .
/*тип первой записи*/
define variable v-ask-date as logical no-undo .
/*дата перехода статуса*/
define variable v-ask-message as character no-undo .
/*подтверждающий запрос пользователю */
define variable v-status-date-chr as character no-undo.
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable ok as logical no-undo .
define variable ii as integer no-undo.
define variable ok-ii as integer no-undo.
define variable v-new-rid-list as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable glog as logical no-undo .

define buffer buf_fin-doc for ub.fin-doc.
if t-batch = no then do:
    if not available X_fin-doc then return error.
    assign
    v-doc-rec = recid(X_fin-doc).
end.
if t-batch = yes then do:
if v-rid-list = "":U then do:
    message
    "Вы не отметили ни одного платежа"
    view-as alert-box error.
    return error.
  end.
end.
do
on error undo, return error
:
  CASE t-batch:
    when no then do:
      find first buf_fin-doc where
                recid(buf_fin-doc) = recid(X_fin-doc) exclusive-lock no-error .
      if not avail buf_fin-doc then return error.
      assign
      v-old-status_ = buf_fin-doc.status_
      .
    end.
    when yes then do:
      _do:
      do ii = 1 to num-entries(v-rid-list):
        find first buf_fin-doc where
            recid(buf_fin-doc) = integer(entry(ii, v-rid-list)) exclusive-lock no-error .
        if ii = 1 then do:
          assign
          v-old-status_ = buf_fin-doc.status_
          V-FIN-DOC-TYPE = BUF_FIN-DOC.fin-doc-type
          v-doc-rec = recid(buf_fin-doc)
          .
        end.
        if not avail buf_fin-doc
        or (avail buf_fin-doc and v-old-status_ <> "":U and buf_fin-doc.status_ <> v-old-status_)
        or (avail buf_fin-doc and v-fin-doc-type <> "":U aND buf_fin-doc.fin-doc-type <> v-fin-doc-type)
        then NEXT _do.
        LEAVE _do.
      end.
    end.
  END CASE.
end. /*doe*/
run trg/findgraf.p (
                input  buf_fin-doc.host-code
                ,input  buf_fin-doc.fin-doc-code
                ,input  p-close-mode
                ,input  '' /*много платежей неизвестно можн и ли нет*/
                ,input  v-old-status_
                ,input  ?                     /*p-status-date*/
                ,output v-status_
                ,output v-ask-date
                ,output v-ask-message
                ) no-error.
if error-status:error then do:
  message
  "Ошибка при проверке возможности" p-close-mode skip
  return-value
  view-as alert-box error.
  return error.
end.

if v-status_ = {&fin-fact}
then do:
  case buf_fin-doc.fin-doc-type
  :
    when {&income-cash}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_income-cash_close-fact':U
        {&cntxt-firm}
        buf_fin-doc.host-code
        '':U
        0
        0
        0
        0
        true
        OK
      }
    end.
    when {&expense-cash}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_expense-cash_close-fact':U
        {&cntxt-firm}
        buf_fin-doc.host-code
        '':U
        0
        0
        0
        0
        true
        OK
      }
    end.
    when {&income-cashless}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_income-cashless_close-fact':U
        {&cntxt-firm}
        buf_fin-doc.host-code
        '':U
        0
        0
        0
        0
        true
        OK
      }
    end.
    when {&expense-cashless}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_expense-cashless_close-fact':U
        {&cntxt-firm}
        buf_fin-doc.host-code
        '':U
        0
        0
        0
        0
        true
        OK
      }
    end.
    when {&income-payoff}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_income-payoff_close-fact':U
        {&cntxt-firm}
        buf_fin-doc.host-code
        '':U
        0
        0
        0
        0
        true
        OK
      }
    end.
    when {&expense-payoff}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_expense-payoff_close-fact':U
        {&cntxt-firm}
        buf_fin-doc.host-code
        '':U
        0
        0
        0
        0
        true
        OK
      }
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестный тип финансового документа для режима закрытия на факт" skip
        "Тип финансового документа" buf_fin-doc.fin-doc-type skip
        "Фирма" buf_fin-doc.host-code skip
        "Внутренний номер" buf_fin-doc.fin-doc-code skip
        "Номер" buf_fin-doc.prn-doc-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .
end.
else do:
  case p-close-mode
  :
    when {&close-doc}
    then do:
      case buf_fin-doc.fin-doc-type
      :
        when {&income-cash}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_income-cash_close-doc':U
            {&cntxt-firm}
            buf_fin-doc.host-code
            '':U
            0
            0
            0
            0
            true
            OK
          }
        end.
        when {&expense-cash}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_expense-cash_close-doc':U
            {&cntxt-firm}
            buf_fin-doc.host-code
            '':U
            0
            0
            0
            0
            true
            OK
          }
        end.
        when {&income-cashless}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_income-cashless_close-doc':U
            {&cntxt-firm}
            buf_fin-doc.host-code
            '':U
            0
            0
            0
            0
            true
            OK
          }
        end.
        when {&expense-cashless}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_expense-cashless_close-doc':U
            {&cntxt-firm}
            buf_fin-doc.host-code
            '':U
            0
            0
            0
            0
            true
            OK
          }
        end.
        when {&income-payoff}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_income-payoff_close-doc':U
            {&cntxt-firm}
            buf_fin-doc.host-code
            '':U
            0
            0
            0
            0
            true
            OK
          }
        end.
        when {&expense-payoff}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_expense-payoff_close-doc':U
            {&cntxt-firm}
            buf_fin-doc.host-code
            '':U
            0
            0
            0
            0
            true
            OK
          }
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный тип финансового документа для данного режима закрытия" skip
            "Режим закрытия" p-close-mode skip
            "Тип финансового документа" buf_fin-doc.fin-doc-type skip
            "Фирма" buf_fin-doc.host-code skip
            "Внутренний номер" buf_fin-doc.fin-doc-code skip
            "Номер" buf_fin-doc.prn-doc-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .
    end.
    when {&open-doc}
    then do:
      case buf_fin-doc.fin-doc-type
      :
        when {&income-cash}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_income-cash_open-doc':U
            {&cntxt-firm}
            buf_fin-doc.host-code
            '':U
            0
            0
            0
            0
            true
            OK
          }
        end.
        when {&expense-cash}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_expense-cash_open-doc':U
            {&cntxt-firm}
            buf_fin-doc.host-code
            '':U
            0
            0
            0
            0
            true
            OK
          }
        end.
        when {&income-cashless}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_income-cashless_open-doc':U
            {&cntxt-firm}
            buf_fin-doc.host-code
            '':U
            0
            0
            0
            0
            true
            OK
          }
        end.
        when {&expense-cashless}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_expense-cashless_open-doc':U
            {&cntxt-firm}
            buf_fin-doc.host-code
            '':U
            0
            0
            0
            0
            true
            OK
          }
        end.
        when {&income-payoff}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_income-payoff_open-doc':U
            {&cntxt-firm}
            buf_fin-doc.host-code
            '':U
            0
            0
            0
            0
            true
            OK
          }
        end.
        when {&expense-payoff}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_expense-payoff_open-doc':U
            {&cntxt-firm}
            buf_fin-doc.host-code
            '':U
            0
            0
            0
            0
            true
            OK
          }
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный тип финансового документа для данного режима закрытия" skip
            "Режим закрытия" p-close-mode skip
            "Тип финансового документа" buf_fin-doc.fin-doc-type skip
            "Фирма" buf_fin-doc.host-code skip
            "Внутренний номер" buf_fin-doc.fin-doc-code skip
            "Номер" buf_fin-doc.prn-doc-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .
    end.
    when {&reject-doc}
    then do:
      case buf_fin-doc.fin-doc-type
      :
        when {&income-cashless}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_income-cashless_reject-doc':U
            {&cntxt-firm}
            buf_fin-doc.host-code
            '':U
            0
            0
            0
            0
            true
            OK
          }
        end.
        when {&expense-cashless}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_expense-cashless_reject-doc':U
            {&cntxt-firm}
            buf_fin-doc.host-code
            '':U
            0
            0
            0
            0
            true
            OK
          }
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный тип финансового документа для данного режима закрытия" skip
            "Режим закрытия" p-close-mode skip
            "Тип финансового документа" buf_fin-doc.fin-doc-type skip
            "Фирма" buf_fin-doc.host-code skip
            "Внутренний номер" buf_fin-doc.fin-doc-code skip
            "Номер" buf_fin-doc.prn-doc-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Неизвестное значение переменной p-close-mode" skip
        "p-close-mode" p-close-mode skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .
end.
if not ok then return error.
ok = no.
message
v-ask-message skip(1)
(if t-batch
then
substitute("Все платежи, которые Вы отметили, но которые к настоящему моменту не находятся в статусе <&1>,&2 &3 обработаны не будут "
            , v-old-status_
            , {&new-line}
            , (if is-type-mode = no
              then substitute("или не имеют типа <&1>,", v-fin-doc-type)
              else "":U)
            )
  else "":U
)
view-as alert-box QUESTION buttons Yes-NO update ok.
if not ok then return error.

if v-ask-date then do:
  run cur-time in this-procedure ( output v-date, output v-time).
  assign
  v-status-date-chr = string(v-date, "99/99/9999":U)
  .
  run gbl/d-prompt.w (
      'title=':u + "Введите дату смены статуса платежа" + '\':u
    + 'text1=':u + "Дата смены статуса" + '\':u
    + 'format=99/99/9999\'
    + 'type=' + {&type-date} + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=no\'
    , input-output v-status-date-chr
    ).
  if return-value = 'false':u then return error.
  assign
  v-date = date(integer(substr(v-status-date-chr, 4, 2)),
                integer(substr(v-status-date-chr, 1, 2)),
                integer(substr(v-status-date-chr, 7, 4))
               )
  no-error .
  if error-status:error then do:
    message
    "Неверная дата для смены статуса"
    view-as alert-box error .
    return error.
  end.
end. /*v-ask-date*/
else do:
  DEFINE VARIABLE v-today as date no-undo .
  DEFINE VARIABLE v-to-time as integer no-undo .
  if not (buf_fin-doc.obj-type = ''
  and buf_fin-doc.obj-code = 0) then do:
    { gbl/curobjdt.i
        buf_fin-doc.obj-type
        buf_fin-doc.obj-code
        v-today
        no-error
    }
  end.
  else do:
    run cur-time in this-procedure ( output v-today, output v-to-time).
  end.
  if buf_fin-doc.doc-date = v-today
  then do:
    /*nothing*/
  end.
  else do:
  message
  "Дата смены статуса платежа будет установлена равной дате составления документа"
  view-as alert-box QUESTION buttons YES-no update glog.
  if not glog then undo, return error .
end.
end.
run waitfram-show in this-procedure ( input "Ждите..." ).
CASE t-batch:
  when no then do:
    define variable v-date1 as date no-undo .
    v-date1 = (if v-ask-date then v-date else buf_fin-doc.doc-date).
    run trg/findstat.p (
                     input parparentproc
                    ,input buf_fin-doc.host-code
                    ,input buf_fin-doc.fin-doc-code
                    ,input p-close-mode
                    ,input '':U /*не из cl-bank*/
                    ,input v-status_
                    ,input-output v-date1
                    ,input no /*p-silent*/
                   ) no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      if error-status:get-message(1) <> "":u then
      message
      error-status:get-message(1)  skip
      return-value view-as alert-box .
      return error .
    end.
    run waitfram-hide in this-procedure .
    RUN OpenBr in this-procedure ( input yes, input no, input '':U).
    reposition br-fin-doc to recid v-doc-rec No-ERROR.
  end.
  when yes then do:
    _do1:
    do ii = 1 to num-entries(v-rid-list):
      run waitfram-show in this-procedure ( substitute("Обрабатывается &1 платеж списка", ii)).
      find first buf_fin-doc where
                recid(buf_fin-doc) = integer(entry(ii, v-rid-list)) exclusive-lock no-error .
      if not avail buf_fin-doc
      or (avail buf_fin-doc and buf_fin-doc.status_ <> v-old-status_)
      or (avail buf_fin-doc and buf_fin-doc.fin-doc-type <> v-fin-doc-type)
      then DO:
        assign
        v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else {&comma-char}) + entry(ii, v-rid-list)
        .
        NEXT _do1.
      END.
      run trg/findstat.p (
                       input parparentproc
                      ,input buf_fin-doc.host-code
                      ,input buf_fin-doc.fin-doc-code
                      ,input p-close-mode
                      ,input '':U /*не из cl-bank*/
                      ,input v-status_
                      ,input-output v-date
                      ,input no /*p-silent*/
                    ) no-error .
      if error-status:error then do:
        assign
        v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else {&comma-char}) + entry(ii, v-rid-list)
        .
        NEXT _do1 .
      end.
      assign
      ok-ii = ok-ii + 1
      v-new-rid-list = v-new-rid-list
      .
    end.
    run waitfram-hide in this-procedure .
    assign
    v-rid-list = v-new-rid-list
    .
    RUN OpenBr in this-procedure ( input yes, input no, input '':U).
    reposition br-fin-doc to recid v-doc-rec No-ERROR.
    message
    substitute("Из &1 выбранных Вами платежей удалось сменить статус на &2 у &3 платежей", ii - 1, v-status_, ok-ii)
    view-as alert-box.
  end.
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-factura Dialog-Frame 
PROCEDURE proc-factura :
do on error undo, return error return-value :
define buffer bf_fin-doc  for ub.fin-doc .
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
define variable v-loc-rid-list as character no-undo .

    if factura-option = "option-lkp":U then do:
        run str/s-f-docs.w
          ( input parparentproc
            ,input v-cntxt-host-code-obj
            ,input ?
            ,input ?
            ,input ?
            ,input "fd"
            ,input X_fin-doc.fin-doc-type
            ,input X_fin-doc.fin-doc-code
            ,input ""
            ,input "in-doc"
            ,input-output v-loc-rid-list
            ) .
    end.
    else do:
    if factura-option = "option1":U then do:
      if t-batch = no then do:
        message "Не выделено ни одного ФО для генерации счетов-фактур !".
        return error .
      end.
      define variable varlog as logical   no-undo .
      varlog = yes.
      message
      substitute("Выбрано &1 платежей . Провести генерацию счетов-фактур?&2"
                 ,num-entries( v-rid-list)
                 ,{&new-line}
                 )
      view-as alert-box question buttons OK-Cancel update varlog.
      if not varlog then return no-apply.

      do vari = 1 to num-entries (v-rid-list):
        assign vardoc-code = integer(entry (vari, v-rid-list)).
        find first bf_fin-doc where recid(bf_fin-doc) = vardoc-code no-lock.
        if bf_fin-doc.status_ <> {&fin-fact} then do:
          message
          substitute("Документ &1 статус &2 не в статусе &3 . Пропускаем."
                     ,bf_fin-doc.prn-doc-code
                     ,bf_fin-doc.status_
                     ,{&fin-fact})
          view-as alert-box.
          next .
        end.
        if bf_fin-doc.cr-factur = yes then do:
          message
          substitute("По документу &1 уже создавался счет-фактура от &2."
                    ,bf_fin-doc.prn-doc-code
                    ,string(bf_fin-doc.factur-date, "99/99/9999"))
          view-as alert-box.
        end.
        else do:
          if bf_fin-doc.need-factur = 1 or bf_fin-doc.need-factur = 2 then do :
            define variable v-list as character no-undo .
            run str/gen-scf.p ( input parParentProc, input vardoc-code, input "fin-doc", output v-list) no-error .
            if error-status:error then message
            substitute("Ошибка создания счета-фактуры по платежу &1"
                     , bf_fin-doc.prn-doc-code)
            return-value view-as alert-box.
            assign v-rid-list = "" .
          end.
          else do:
            message "Данный документ не нуждался в генерации счета-фактуры." view-as alert-box.
          end.
        end.
      end.
    end.
    else do:
      if v-rid-list = "" then do:
        if available X_fin-doc then assign v-rid-list = string(recid(X_fin-doc)).
      end.
vari-cycle:
      do vari = 1 to num-entries (v-rid-list):
        find first bf_fin-doc where recid(bf_fin-doc) = integer(entry (vari, v-rid-list)) exclusive-lock.
        if bf_fin-doc.status_ <> {&fin-fact} then do:
          message
          substitute("Документ &1 не в статусе &2. Пропускаем."
                     ,bf_fin-doc.status_
                     ,{&fin-fact}
                     )
          view-as alert-box.
          next vari-cycle.
        end.
        if bf_fin-doc.user-db-num-doc <> v-db-num then do:
          message
          substitute("БД документа с кодом &1 не coвпадает с текущей БД.&2" +
                     "Текущая БД: &3&2БД док-та: &4&2.Пропускаем."
                    ,bf_fin-doc.fin-doc-code
                    ,{&new-line}
                    ,v-db-num
                    ,bf_fin-doc.user-db-num-doc
                    )
          view-as alert-box error.
          next vari-cycle.
        end.
        case factura-option :
          when "option2":U then do:
            if bf_fin-doc.cr-factur = yes then do:
              message
              substitute("По документу &1 уже генерился счет-фактура от &2."
                       ,bf_fin-doc.fin-doc-code
                       ,bf_fin-doc.factur-date
                       )
              view-as alert-box.
              next vari-cycle.
            end.
            else do:
              if bf_fin-doc.need-factur = 1 or bf_fin-doc.need-factur = 2 then assign  bf_fin-doc.need-factur = 0.
              else do:
                message
                "Данный документ не нуждался в генерации счета-фактуры."
                view-as alert-box.
                next vari-cycle.
              end.
              reposition {&browse-name} to recid recid(bf_fin-doc) no-error.
/*              if not error-status:error then display factur (buffer bf_fin-doc) with browse {&browse-name}.*/
            end.
          end.
          when "option3":U then do:
            if bf_fin-doc.cr-factur = yes then do:
              assign varlog = no.
              message
              substitute("По документу &1 был создан счет-фактура от &2.&3" +
                         "Вы действительно хотите снять признак, что по этому документу был счет-фактура?"
                        ,bf_fin-doc.fin-doc-code
                        ,string(bf_fin-doc.factur-date, "99/99/9999")
                        ,{&new-line})
              view-as alert-box question buttons yes-no update varlog.
              if varlog <> yes then  next vari-cycle.
              assign
                bf_fin-doc.cr-factur   = no
                bf_fin-doc.factur-date = 01/01/1990
              .
              reposition {&browse-name} to recid recid(bf_fin-doc) no-error.
/*              if not error-status:error then display factur (buffer bf_fin-doc) with browse {&browse-name}.*/
            end.
            else message
                 substitute("По документу &1 не было генерации."
                           , bf_fin-doc.fin-doc-code)
                 view-as alert-box.
          end.
          when "option4":U then do:
            if bf_fin-doc.need-factur = 2 then do:
              if bf_fin-doc.contract-code <> 0 then do:
                if X_contract.gen-factur = 3 or X_contract.gen-factur = 13 or X_contract.gen-factur = 103 or X_contract.gen-factur = 113 then do:
                  assign bf_fin-doc.need-factur = 1  .
                  reposition {&browse-name} to recid recid(bf_fin-doc) no-error.
                  /*if not error-status:error then display factur (buffer bf_fin-doc) @ varfactur with browse {&browse-name}.*/
                end.
                else message
                     substitute("По документу &1 нет договоров для генерации счета-фактуры."
                                ,bf_fin-doc.fin-doc-code
                                )
                     view-as alert-box.

              end.
            end.
            else do:
              message
              substitute("Документ &1 не имеет признака 'не опред' генерация счета-фактуры."
                         ,bf_fin-doc.fin-doc-code)
              view-as alert-box.
              next vari-cycle.
            end.
          end.
        end. /* case */
      end.

    end.
  end.
  end.
end procedure. /* proc-factura */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-bik Dialog-Frame 
PROCEDURE proc-find-bik :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-bik like ub.fin-doc.receiver-bik no-undo.
assign
frame {&frame-name} Rs-receiver-payer.
assign
sch-doc-date = ?
sch-pay-date = ?
sch-fact-date = ?
.
display
"":U @ sch-prn-doc-code
"":U @ sch-name
0 @ sch-cli-code
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-pay-date
with frame {&frame-name}.
if not is-cash-mode then
display
"":U @ sch-r-schet
"":U @ sch-c-schet
with frame {&frame-name} .
assign
p-bik = replace(p-bik, {&double-quote}, "":U)
p-bik = replace(p-bik, {&single-quote}, {&single-quote} + {&single-quote})
p-bik = {&double-quote} + p-bik + {&double-quote}.
if RS-receiver-payer = "receiver":U then do:
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_fin-doc.receiver-bik   begins &1 "
      , p-bik)
    ).
end.
if RS-receiver-payer = "payer":U then do:
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_fin-doc.payer-bik   begins &1 "
      , p-bik)
    ).
end.
apply "entry":u to sch-bik in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-c-schet Dialog-Frame 
PROCEDURE proc-find-c-schet :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-c-schet like ub.fin-schet.c-schet no-undo.
assign
frame {&frame-name} RS-receiver-payer .
assign
sch-doc-date = ?
sch-pay-date = ?
sch-fact-date = ?
.
display
"":U @ sch-prn-doc-code
"":U @ sch-name
0 @ sch-cli-code
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-pay-date
with frame {&frame-name}.
if not is-cash-mode then
display
"":U @ sch-BIK
"":U @ sch-r-schet
with frame {&frame-name}.
assign
p-c-schet = replace(p-c-schet, {&double-quote}, "":U)
p-c-schet = replace(p-c-schet, {&single-quote}, {&single-quote} + {&single-quote})
p-c-schet = {&double-quote} + p-c-schet + {&double-quote}.
if rs-receiver-payer = "receiver":U then do:
    run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input p-next  /* p-find-next  */
        ,input substitute("and X_fin-doc.receiver-c-schet   begins &1 "
          , p-c-schet)
        ).
end.
if Rs-receiver-payer = "payer":U then do:
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_fin-doc.payer-c-schet   begins &1 "
      , p-c-schet)
    ).
end.

apply "entry":u to sch-c-schet in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-cli-code Dialog-Frame 
PROCEDURE proc-find-cli-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-cli-code like ub.fin-schet.cli-code no-undo.
define variable v-cli-code as character no-undo.
assign
frame {&frame-name} RS-cli-type .
assign
frame {&frame-name} Rs-receiver-payer.
assign
sch-doc-date = ?
sch-pay-date = ?
sch-fact-date = ?
.

display
"":U @ sch-prn-doc-code
"":U @ sch-name
"":U @ sch-bik
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-pay-date
"":U @ sch-r-schet
"":U @ sch-c-schet
with frame {&frame-name}.
assign
v-cli-code = string(p-cli-code)
.
if RS-receiver-payer = "receiver":U then do:
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_fin-doc.receiver-type = '&1' and X_fin-doc.receiver-code = &2"
      , RS-cli-type, v-cli-code )
    ).
end.
if RS-receiver-payer = "payer":U then do:
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_fin-doc.payer-type = '&1' and X_fin-doc.payer-code = &2"
      , RS-cli-type, v-cli-code )
    ).
end.

apply "entry":u to sch-cli-code in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-curr-code Dialog-Frame 
PROCEDURE proc-find-curr-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-curr-code like ub.fin-doc.curr-code no-undo.
define variable v-curr-code-chr as character no-undo.
assign
sch-doc-date = ?
sch-pay-date = ?
sch-fact-date = ?
.

display
"":U @ sch-prn-doc-code
"":U @ sch-BIK
"":U @ sch-name
0 @ sch-cli-code
"":U @ sch-c-schet
sch-doc-date
sch-fact-date
sch-pay-date
"":U @ sch-r-schet
with frame {&frame-name}.
assign
v-curr-code-chr = string(p-curr-code)
.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_fin-doc.curr-code = &1 "
      , v-curr-code-chr)
    ).
apply "entry":u to sch-curr-code in frame {&frame-name} .

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
define input parameter p-date like ub.fin-doc.doc-date no-undo.
define input parameter p-what-date as character no-undo.
define variable v-date-chr as character no-undo.
if p-date = ? then return .
display
"":U @ sch-BIK
"":U @ sch-name
0 @ sch-cli-code
"":U @ sch-c-schet
0 @ sch-curr-code
"":U @ sch-prn-doc-code
"":U @ sch-r-schet
with frame {&frame-name}.

CASE p-what-date:
    when "doc-date":U then do:
      assign
      sch-pay-date = ?
      sch-fact-date = ?
      .
      display
      sch-fact-date
      sch-pay-date
      with frame {&frame-name}.
    end.
    when "fact-date":U then do:
      assign
      sch-doc-date = ?
      sch-pay-date = ?
      .
      display
      sch-doc-date
      sch-pay-date
      with frame {&frame-name}.
    end.
    when "pay-date":U then do:
      assign
      sch-doc-date = ?
      sch-fact-date = ?
      .
      display
      sch-fact-date
      sch-doc-date
      with frame {&frame-name}.
    end.
END CASE.

assign
v-date-chr = string(day(p-date)) + {&slash-char} +
                 string(month(p-date)) + {&slash-char} +
                 string(year(p-date)).

CASE p-what-date:
    when "doc-date":U then do:
       run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input true  /* p-find-next  */
        ,input substitute("and X_fin-doc.doc-date = &1 "
          , v-date-chr)
        ).
      apply "entry":u to sch-doc-date in frame {&frame-name}.
    end.
    when "fact-date":U then do:
       run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input true  /* p-find-next  */
        ,input substitute("and X_fin-doc.fact-date = &1 "
          , v-date-chr)
        ).
      apply "entry":u to sch-fact-date in frame {&frame-name}.
    end.
        when "pay-date":U then do:
       run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input true  /* p-find-next  */
        ,input substitute("and X_fin-doc.pay-date = &1 "
          , v-date-chr)
        ).
      apply "entry":u to sch-pay-date in frame {&frame-name}.
    end.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-name Dialog-Frame 
PROCEDURE proc-find-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-name as character no-undo.
assign
frame {&frame-name} Rs-receiver-payer.
assign
sch-doc-date = ?
sch-pay-date = ?
sch-fact-date = ?
.

display
"":U @ sch-prn-doc-code
0 @ sch-cli-code
"":U @ sch-bik
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-pay-date
"":U @ sch-r-schet
"":U @ sch-c-schet
with frame {&frame-name}.
assign
p-name = replace(p-name, {&single-quote}, {&single-quote} + {&single-quote})
p-name = {&double-quote} + p-name + {&double-quote}.
if RS-receiver-payer = "receiver":U then do:
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_fin-doc.receiver-name   begins &1 "
      , p-name)
    ).
end.
if RS-receiver-payer = "payer":U then do:
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_fin-doc.payer-name   begins &1 "
      , p-name)
    ).
end.


apply "entry":u to sch-name in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-prn-doc-code Dialog-Frame 
PROCEDURE proc-find-prn-doc-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-prn-doc-code like ub.fin-doc.prn-doc-code no-undo.
assign
sch-doc-date = ?
sch-pay-date = ?
sch-fact-date = ?
.

display
"":U @ sch-BIK
"":U @ sch-name
0 @ sch-cli-code
"":U @ sch-c-schet
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-pay-date
"":U @ sch-r-schet
with frame {&frame-name}.

assign
  p-prn-doc-code = replace(p-prn-doc-code, {&single-quote}, {&single-quote} + {&single-quote})
.

run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_fin-doc.prn-doc-code = '&1'"
      ,p-prn-doc-code)
    ).
apply "entry":u to sch-prn-doc-code in frame {&frame-name} .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-r-schet Dialog-Frame 
PROCEDURE proc-find-r-schet :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-r-schet like ub.fin-schet.r-schet no-undo.
assign
frame {&frame-name} RS-receiver-payer .
assign
sch-doc-date = ?
sch-pay-date = ?
sch-fact-date = ?
.
display
"":U @ sch-prn-doc-code
"":U @ sch-name
0 @ sch-cli-code
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-pay-date
with frame {&frame-name}.
display
"":U @ sch-BIK
"":U @ sch-c-schet
with frame {&frame-name}.
assign
p-r-schet = replace(p-r-schet, {&double-quote}, "":U)
p-r-schet = replace(p-r-schet, {&single-quote}, {&single-quote} + {&single-quote})
p-r-schet = {&double-quote} + p-r-schet + {&double-quote}.
if rs-receiver-payer = "receiver":U then do:
    run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input p-next  /* p-find-next  */
        ,input substitute("and X_fin-doc.receiver-r-schet   begins &1 "
          , p-r-schet)
        ).
end.
if Rs-receiver-payer = "payer":U then do:
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_fin-doc.payer-r-schet   begins &1 "
      , p-r-schet)
    ).
end.

apply "entry":u to sch-r-schet in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print-list Dialog-Frame 
PROCEDURE proc-print-list :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      char    no-undo.
define variable Line            as      char    no-undo.
define variable v-receiver as character no-undo.
define variable v-payer as character no-undo.
define variable v-contract as character no-undo.
define variable v-curr-abbr as character no-undo.
define variable v-obj as character no-undo .

run rep/g-fin-doc-list.p (parParentProc) no-error.

/*
DEFINE FRAME fin-doc-list
X_fin-doc.host-code COLUMN-LABEL "Код!фирмы" format "99999999999999"
X_fin-doc.prn-doc-code FORMAT "X(16)"
v-receiver /*   X_fin-doc.receiver-type + string(X_fin-doc.receiver-code) */ COLUMN-LABEL "Получатель" FORMAT "X(12)"
X_fin-doc.receiver-name COLUMN-LABEL "Назв.!получателя" FORMAT "X(17)"
v-contract /*  get-contract(buffer X_fin-doc) */ COLUMN-LABEL "Договор" FORMAT "X(16)"
X_fin-doc.fin-doc-type format "X(3)"
X_fin-doc.doc-date
X_fin-doc.fin-ext-doc-type COLUMN-LABEL "Расш.!тип" format "X(3)"
X_fin-doc.perm-date COLUMn-LABEL "Дата разр"
X_fin-doc.pay-date  COLUMn-LABEL "Дата прин!банком"
X_fin-doc.fact-date COLUMn-LABEL "Дата факт"
X_fin-doc.status_
X_fin-doc.sum-doc
v-payer /*X_fin-doc.payer-type + string(X_fin-doc.payer-code) */ COLUMN-LABEL "Плательщик" FORMAT "X(12)"
X_fin-doc.payer-name COLUMN-LABEL "Назв.!плательщика" FORMAT "X(16)"
v-curr-abbr /*get-currency(buffer X_fin-doc) */ COLUMN-LABEL "Вал" FORMAT "X(3)"
v-obj COLUMN-LABEL "Объект" FORMAT "X(8)"
HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(198)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 198).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title + {&space-char} + "Только отмеченные записи")
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(195)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME fin-doc-list  .
run waitfram-show in this-procedure ( input "Ждите...").
v-doc-rec = recid(X_fin-doc).
DO WHILE available X_fin-doc :
  GET prev br-fin-doc.
END.
GET next br-fin-doc.
DO WHILE available X_fin-doc :
  if not t-batch or
  mark-string (recid(X_fin-doc), input v-rid-list) = "*":U then do:
    Display STREAM PrnLibStream
    X_fin-doc.host-code
    X_fin-doc.prn-doc-code
    string( X_fin-doc.receiver-type + string(X_fin-doc.receiver-code)) @ v-receiver
    X_fin-doc.receiver-name
    get-contract(buffer X_fin-doc) @ v-contract
    X_fin-doc.fin-doc-type
    X_fin-doc.doc-date
    X_fin-doc.fin-ext-doc-type
    X_fin-doc.perm-date
    X_fin-doc.fact-date
    X_fin-doc.pay-date
    X_fin-doc.status_
    X_fin-doc.sum-doc
    string(X_fin-doc.payer-type + string(X_fin-doc.payer-code)) @ v-payer
    X_fin-doc.payer-name
    get-currency(buffer X_fin-doc) @ v-curr-abbr
    (if X_fin-doc.obj-code > 0 then (X_fin-doc.obj-type + string(X_fin-doc.obj-code)) else "":U) @ v-obj
    with FRAME fin-doc-list .
    DOWN STREAM PrnLibStream 1
    with FRAME fin-doc-list  .
  end.
  assign
  accum-count = accum-count + 1
  .
  GET next br-fin-doc.
END.
UNDERLINE  STREAM PrnLibStream
X_fin-doc.host-code
X_fin-doc.prn-doc-code
v-receiver
X_fin-doc.receiver-name
v-contract
X_fin-doc.fin-doc-type
X_fin-doc.doc-date
X_fin-doc.fin-ext-doc-type
X_fin-doc.fact-date
X_fin-doc.pay-date
X_fin-doc.status_
X_fin-doc.sum-doc
v-payer
X_fin-doc.payer-name
v-curr-abbr
v-obj
with FRAME fin-doc-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_fin-doc.host-code
accum-count @ X_fin-doc.prn-doc-code
with frame fin-doc-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME fin-doc-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-fin-doc to recid v-doc-rec no-error.
APPLY "entry" to br-fin-doc.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print-one Dialog-Frame 
PROCEDURE proc-print-one :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer no-undo .
define variable v-format as integer no-undo .
define variable ii as integer no-undo .
if not available X_fin-doc then return error.
define buffer buf_fin-doc  for ub.fin-doc.

CASE t-batch:
  when no then do:
    run rep/findocp.p (
                    INPUT parParentProc
                    ,input X_fin-doc.host-code
                    ,input X_fin-doc.fin-doc-code
                    ,input T-batch /*p-append*/
                    ,input no /*p-is-last*/
                    ,input no /*not from forms*/
                    ,input-output v-format
                  ) no-error.
    if error-status:error then do:
      return error.
    end.
  end.
  when  yes then do:
    if v-rid-list = "":U then do:
        message
        "Вы не отметили ни одного платежа"
        view-as alert-box error.
        return error.
    end.
    run waitfram-show in this-procedure ( input "Ждите...").
    v-doc-rec = recid(X_fin-doc).
    run prn-lib-open-stream  in this-procedure (
                                                input parParentProc
                                                ,input {&LS_PS_A4}
                                                ,input yes /*p-is-stream*/
                                                ,input no /*p-append*/
                                                ).
    output  STREAM PrnLibStream CLOSE.
    assign
    v-format = ?
    .
    _do:
    do ii = 1 to num-entries(v-rid-list):
      find first buf_fin-doc no-lock where
                recid(buf_fin-doc) = integer(entry(ii, v-rid-list)) no-error .
      if available buf_fin-doc then do:
        run rep/findocp.p (
                        INPUT parParentProc
                        ,input buf_fin-doc.host-code
                        ,input buf_fin-doc.fin-doc-code
                        ,input T-batch
                        ,input (if T-batch and (ii = num-entries(v-rid-list))
                          then yes
                          else no)
                        ,input no /*not from forms*/
                        ,input-output v-format
                      ) no-error.
        if error-status:error or v-format = ? then do:
          next _do .
        end.
        assign
        accum-count = accum-count + 1
        .
      end.
    end. /*do ii*/
    run prn-lib-prn-file in this-procedure (
                                                   input parParentProc
                                                  ,input (if v-format = 0 then 0 else 8)
                                                 ).
    run waitfram-hide in this-procedure .
    APPLY "entry" to br-fin-doc in frame {&frame-name} .
  end.
END CASE.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print-one-graphics Dialog-Frame 
PROCEDURE proc-print-one-graphics :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable varxmldocfl      as character no-undo.
define variable varxmldocfl-type as character no-undo.
define variable varpar-type as character no-undo.
define variable for-dir as character no-undo .
define variable accum-count as integer no-undo .
define variable accum-count-ok as integer no-undo .
define variable loclog as logical no-undo .
define variable ii as integer no-undo .
define variable ii0 as integer no-undo .
define variable v-template-code as character no-undo .
define variable v-copy-nums as integer no-undo .
define variable v-add-info as character no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .

define buffer buf_fin-doc for ub.fin-doc.
if not available X_fin-doc then do:
  message "Неправильный выбор документа.".
  return no-apply.
end.
run gbl/filename.p (
                input "fxmldoc.bat"
                ,output v-full-path
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
if error-status:error  = ? then do:
  message
  substitute("Не найден командный файл для графической печати платежей fxmldoc.bat:&1 &2", {&new-line}, return-value )
  view-as alert-box error .
  return error .
end.
if t-batch then
ii0 = num-entries(v-rid-list).
else ii0 = 1.
run ref/findocgp.w (
                input X_fin-doc.fin-doc-type
               ,input X_fin-doc.fin-ext-doc-type
               ,input ii0
               ,output v-template-code
               ,output v-copy-nums
               ,output v-add-info) no-error.
if error-status:error
or v-template-code = "":U
then do:
  undo, return error.
end.
CASE t-batch:
  when no then do:
    assign
    v-file-name = ?
                        /*"f":U + string(X_fin-doc.fin-doc-code) + ".xml"*/
    .
    run str/xmlfdoc.p ( input X_fin-doc.host-code
                       ,input  X_fin-doc.fin-doc-code
                       ,input-output v-file-name
                       ,input  yes
                       ,input  yes) no-error .
    if not error-status:error then do:
      os-command silent value(search ("fxmldoc.bat") + {&space-char}
                                     + v-full-path + {&space-char}
                                     + v-file-name + {&space-char}
                                     + v-template-code + {&space-char}
                                     + string(v-copy-nums) + {&space-char}
                                     + v-add-info
                                     ).
      if os-error = 0 then
      assign
      accum-count-ok = accum-count-ok + 1
      .
    end.
  end.
  when  yes then do:
    if v-rid-list = "":U then do:
        message
        "Вы не отметили ни одного платежа"
        view-as alert-box error.
        return error.
    end.
    run waitfram-show in this-procedure ( input "Ждите...").
    assign
    v-doc-rec = recid(X_fin-doc)
    .
    _do:
    do ii = 1 to ii0:
      run waitfram-show in this-procedure ( substitute("Ждите... Обрабатывается &1-й документ, всего &2", accum-count + 1, ii0)).
      find first buf_fin-doc no-lock where
                recid(buf_fin-doc) = integer(entry(ii, v-rid-list)) no-error .

      if available buf_fin-doc then do:
        assign
        accum-count = accum-count + 1
        .
        assign
        v-file-name = ?
                        /*"f":U + string(X_fin-doc.fin-doc-code) + ".xml"*/
        .
        run str/xmlfdoc.p (
                        input buf_fin-doc.host-code
                      , input buf_fin-doc.fin-doc-code
                      , input-output v-file-name
                      , input yes
                      , input yes
                      ) no-error .
        if not error-status:error then do:
          os-command silent value(search ("fxmldoc.bat") + {&space-char}
                                        + v-full-path + {&space-char}
                                        + v-file-name + {&space-char}
                                        + v-template-code + {&space-char}
                                        + string(v-copy-nums) + {&space-char}
                                        + v-add-info
                                        ).
          if os-error = 0 then
          assign
          accum-count-ok = accum-count-ok + 1
          .
        end.
      end.
    end. /*do ii*/
    run waitfram-hide in this-procedure .
  end.
END CASE.
if error-status:error
or (t-batch and accum-count <> accum-count-ok)
then do:
  message
  "Ошибка при печати платежа(-ей) в графике" skip
  string(if t-batch then substitute("Напечатано &1 платежей из &2", accum-count-ok, accum-count) else "":U)
  view-as alert-box .
  if not t-batch then
  return error .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION f-factur Dialog-Frame 
FUNCTION f-factur RETURNS CHARACTER
  ( buffer loc-t-doc for ub.fin-doc ) :
 if loc-t-doc.cr-factur = yes then do:
   return string (loc-t-doc.factur-date, "99/99/99").
 end.
 else do:
   if loc-t-doc.need-factur = 0 then return "--------".
   if loc-t-doc.need-factur = 1 then return "".
   if loc-t-doc.need-factur = 2 then return "не опред".
 end.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION factur Dialog-Frame 
FUNCTION factur RETURNS CHARACTER
  ( BUFFER loc-fin-doc FOR ub.fin-doc ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
 if loc-fin-doc.cr-factur = yes then do:
   return string (loc-fin-doc.factur-date, "99/99/99").
 end.
 else do:
   if loc-fin-doc.need-factur = 0 then return "--------".
   if loc-fin-doc.need-factur = 1 then return "".
   if loc-fin-doc.need-factur = 2 then return "не опред".
 end.
 RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cashbookname Dialog-Frame 
FUNCTION get-cashbookname RETURNS CHARACTER
  ( input iCashbookID as int64) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_cashbook for ub.cashbook.
  find first buf_cashbook no-lock where
                buf_cashbook.id = iCashbookID
     no-error.
  if available buf_cashbook 
  then return buf_cashbook.CashBookName.
  else return string(iCashbookID).   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-contract Dialog-Frame 
FUNCTION get-contract RETURNS CHARACTER
  ( BUFFER loc-fin-doc FOR ub.fin-doc ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_contract for ub.contract.
  find first buf_contract no-lock where
                buf_contract.host-code = loc-fin-doc.host-code
            AND buf_contract.contract-code = loc-fin-doc.contract-code no-error.
    if available buf_contract then return buf_contract.contract-prn-code.

  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-currency Dialog-Frame 
FUNCTION get-currency RETURNS CHARACTER
  ( BUFFER loc-fin-doc FOR ub.fin-doc ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

 define buffer buf_currency for ub.currency.
  find first buf_currency no-lock where
                buf_currency.curr-code = loc-fin-doc.curr-code no-error.
    if available buf_currency then return buf_currency.curr-abbr.

  RETURN string(loc-fin-doc.curr-code).   /* Function return value. */


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-shift Dialog-Frame 
FUNCTION get-shift RETURNS DATE
  ( BUFFER buf_fin-doc FOR ub.fin-doc, OUTPUT p-shift-name-num AS CHARACTER) :
define variable v-fin-doc-shift-name-num as character no-undo.
define variable v-fin-doc-shift-name as character no-undo .
IF buf_fin-doc.shift-date = ? THEN DO:
   RETURN ?.
END.
 { str/shiftnam.i
     buf_fin-doc.obj-type
     buf_fin-doc.obj-code
     buf_fin-doc.shift-date
     buf_fin-doc.shift-num
     v-fin-doc-shift-name
     v-fin-doc-shift-name-num
     no-error
  }

ASSIGN
p-shift-name-num = v-fin-doc-shift-name-num
 .
RETURN buf_fin-doc.shift-date.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

