&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED TEMP-TABLE x-contract NO-UNDO LIKE ub.contract.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список фин.обязательств

Автор: Чернова Светлана Александровна
Дата создания: 10/24/03
Author: Svetlana Chernova
Creation date: 10/24/03

*/

/* ***************************  Definitions  ************************** */

define input parameter parparentproc  as widget-handle no-undo.
define input parameter bttns          as character   no-undo .
define input parameter par-mode       as character   no-undo .
define input parameter pardoc-rec     as recid no-undo.
define input parameter par-host-code  like ub.clients.obj-code no-undo.
define input parameter p-doc-type     as character no-undo .
define input parameter p-status_      as character no-undo .
define input parameter p-char         as character no-undo .
define output parameter rid-list      as character no-undo . /* список recid'ов выбранных */


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список фин.обязательств".
{ cmp/vssrevis.i }

/* Parameters Definitions ---                                           */

define variable varfactur          as   character             no-undo.

define variable g-log as logical no-undo .
define variable doc-rec as recid no-undo .
define variable g#report-num as integer no-undo .

define variable p-base-code as integer no-undo .
define variable l-curr as character no-undo .
define variable p-mark as character no-undo .
define variable p-contr as character no-undo .
define variable p-type as character no-undo .
define variable p-obj as character no-undo .
define variable p-gen as character no-undo .
define variable p-debts as decimal   no-undo .
define variable p-doc-type-full   as character no-undo .
define variable var-fin-calc as integer no-undo .

define variable hard-flt-cli-code  as integer   no-undo .
define variable hard-flt-cli-type  as character no-undo .
define variable r-31 as integer   no-undo init 1.
define variable r-32 as integer   no-undo init 1.
define variable d-1 as integer   no-undo init 1.
define variable d-2 as integer   no-undo init 1.

/* Local Variable Definitions ---                                       */

{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/fltfield.i }
{ gbl/prn-lib.i  }
{ gbl/waitfram.i }
{ str/libofarh.i }
{ str/fo-clos.i  }
{ gbl/usr-flt.i  }
{ gbl/getcntxt.i def }
{ gbl/userhsts.i }
{ gbl/thbjattr.i }
{ gbl/fltopend.i defproc }
{ cmp/mrk-strf.i }


&Scoped-Define main-file fin-ob

&scop col-l0  '*'
&scop col-l1  'Статус'
&scop col-l2  '№ док-та'
&scop col-l3  'Создан'
&scop col-l4  'Закрыт'
&scop col-l5  'Договор'
&scop col-l6  'Получатель'
&scop col-l7  'Плательщик'
&scop col-l8  'Платеж'
&scop col-l9  'Вал'
&scop col-l10 'Сумма в валюте!док-та'
&scop col-l12 'Внутр.№'
&scop col-l13 'Тип'
&scop col-l14 'Непогаш.задолж!({&abbr_rub}.)'
&scop col-l15 'Объект'
&scop col-l16 'Наименование'
&scop col-l17 'Условие генерации'
&scop col-l18 'Счет-фактура'

&scop head-col ~
 {&col-l0} + '#' + ~
 {&col-l1} + '#' + ~
 {&col-l2} + '#' + ~
 {&col-l3} + '#' + ~
 {&col-l4} + '#' + ~
 {&col-l5} + '#' + ~
 {&col-l6} + '#' + ~
 {&col-l7} + '#' + ~
 {&col-l8} + '#' + ~
 {&col-l9} + '#' + ~
 {&col-l10} + '#' + ~
 {&col-l12} + '#' + ~
 {&col-l13} + '#' + ~
 {&col-l14} + '#' + ~
 {&col-l15} + '#' + ~
 {&col-l16} + '#' + ~
 {&col-l17} + '#' + ~
 {&col-l18}

&scop cop-l0      mark-string(recid( buf_fin-liab), rid-list)
&scop dyn_cop-l0  substitute('dynamic-function(&1mark-string&1, recid(buf_fin-liab), &1&2&1)', ~{&double-quote~}, rid-list)
&scop cop-l1    buf_fin-liab.status_
&scop cop-l2    buf_fin-liab.prn-doc-code
&scop cop-l3    buf_fin-liab.doc-date
&scop cop-l4    buf_fin-liab.fact-date
&scop cop-l5    contract-id(recid( buf_fin-liab))
&scop dyn_cop-l5  substitute('dynamic-function(&1contract-id&1, recid(buf_fin-liab))', ~{&double-quote~})
&scop cop-l6    (buf_fin-liab.receiver-type + ' ' + string(buf_fin-liab.receiver-code))
&scop cop-l7    (buf_fin-liab.payer-type + ' ' + string(buf_fin-liab.payer-code))
&scop cop-l8    buf_fin-liab.pay-date
&scop cop-l9    val-abbr-type(recid( buf_fin-liab))
&scop dyn_cop-l9  substitute('dynamic-function(&1val-abbr-type&1, recid(buf_fin-liab))', ~{&double-quote~})
&scop cop-l10   buf_fin-liab.sum-doc
&scop cop-l12   buf_fin-liab.doc-code
&scop cop-l13   if buf_fin-liab.doc-type = {&income} then 'с покупателем' else 'с поставщиком'
&scop cop-l14   debts(recid (buf_fin-liab))
&scop dyn_cop-l14  substitute('dynamic-function(&1debts&1, recid(buf_fin-liab))', ~{&double-quote~})
&scop cop-l15   (buf_fin-liab.obj-type + ' ' + string(buf_fin-liab.obj-code))
&scop cop-l16   buf_fin-liab.receiver-name
&scop cop-l17   contract-gen(recid(buf_fin-liab))
&scop dyn_cop-l17  substitute('dynamic-function(&1contract-gen&1, recid(buf_fin-liab))', ~{&double-quote~})
&scop cop-l18   f-factur(recid(buf_fin-liab))
&scop dyn_cop-l18  substitute('dynamic-function(&1f-factur&1, recid(buf_fin-liab))', ~{&double-quote~})

&scop cop-l300  buf_fin-liab.doc-date
&scop cop-l600  buf_fin-liab.receiver-name
&scop cop-l700  buf_fin-liab.payer-name
&scop cop-l1300 buf_fin-liab.doc-type
&scop cop-l1500 buf_fin-liab.obj-code

&scop ver-paket ~
  if num-entries(rid-list) = 0  then do: ~
  message "Не отмечено ни одной записи !!!" . ~
  return .                                    ~
  end.                                         ~
  message "Запускать пакетный режим обработки для " num-entries(rid-list) "записей ?" ~
           view-as alert-box question                                                  ~
           buttons yes-no                                                              ~
           update g-ok                                                                 ~
           .                                                                           ~
  if g-ok = false then return.



define variable filter-point as character no-undo init "Список финобязательства" .
define variable filter-point0 as character no-undo init "Фин_обязательства_" .
define variable sort-column-name as character no-undo .
define variable print-type as character no-undo.
define variable del-type as character no-undo.
define variable deleted as logical no-undo init no.
DEFINE VARIABLE change-type as character init "" no-undo .

define new shared variable br-handle as handle  no-undo .
define new shared variable next-prev as logical no-undo .
DEFINE NEW SHARED BUFFER buf_fin-liab FOR ub.fin-ob.
DEFINE NEW SHARED BUFFER xx-contract for x-contract .
define buffer find_code for ub.fin-ob .

define variable v-order-col as character no-undo .
define variable v-size-col1 as decimal   no-undo .
define variable v-size-col2 as decimal   no-undo .
define variable v-size-col3 as decimal   no-undo .
define variable v-size-col4 as decimal   no-undo .
define variable v-size-col5 as decimal   no-undo .
define variable v-size-col6 as decimal   no-undo .

define temp-table tt-val no-undo
field val as character
field s1  as decimal
field s2  as decimal
field KOL  as decimal
index pi val .


{ gbl/getcntxt.i get }



run uf-get in this-procedure(
     input  {&uf-fin-ob}
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
  if error-status :error
  then do:
    message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .

  end.

if not error-status:error then do:
   v-order-col  = entry ( 1, v-uf-List_ ,{&delim-par} ) no-error.
   v-size-col1  = decimal (entry(2, v-uf-List_ ,{&delim-par})) no-error.
   v-size-col2  = decimal (entry(3, v-uf-List_ ,{&delim-par})) no-error.
   v-size-col3  = decimal (entry(4, v-uf-List_ ,{&delim-par})) no-error.
   v-size-col4  = decimal (entry(5, v-uf-List_ ,{&delim-par})) no-error.
   v-size-col5  = decimal (entry(6, v-uf-List_ ,{&delim-par})) no-error.
   if v-size-col1 = 0 or v-size-col1 = ? then v-size-col1 = 10.
   if v-size-col2 = 0 or v-size-col2 = ? then v-size-col2 = 15.
   if v-size-col3 = 0 or v-size-col3 = ? then v-size-col3 = 10.
   if v-size-col4 = 0 or v-size-col4 = ? then v-size-col4 = 10.
   if v-size-col5 = 0 or v-size-col5 = ? then v-size-col5 = 6.

   if v-order-col = "" or v-order-col = ? then v-order-col = "4,5,6,7,8,9,10,11,12,13,14,15,16,17,18".
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-docs

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_fin-liab xx-contract

/* Definitions for BROWSE BR-docs                                       */
&Scoped-define FIELDS-IN-QUERY-BR-docs {&cop-l0} @ p-mark {&cop-l1} {&cop-l2} {&cop-l3} {&cop-l4} {&cop-l5} @ p-contr {&cop-l6} {&cop-l7} {&cop-l8} {&cop-l9} @ l-curr {&cop-l10} {&cop-l12} {&cop-l13} @ p-type {&cop-l14} {&cop-l15} @ p-obj {&cop-l16} {&cop-l17} @ p-gen {&cop-l18} @ varfactur
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-docs {&cop-l1}
&Scoped-define SELF-NAME BR-docs
&Scoped-define QUERY-STRING-BR-docs FOR EACH buf_fin-liab  NO-LOCK , ~
       FIRST xx-contract
&Scoped-define OPEN-QUERY-BR-docs OPEN QUERY {&SELF-NAME} FOR EACH buf_fin-liab  NO-LOCK , ~
       FIRST xx-contract .
&Scoped-define TABLES-IN-QUERY-BR-docs buf_fin-liab xx-contract
&Scoped-define FIRST-TABLE-IN-QUERY-BR-docs buf_fin-liab
&Scoped-define SECOND-TABLE-IN-QUERY-BR-docs xx-contract


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-docs}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit RECT-1 B-sel B-close B-Export b-fact ~
B-trn B-parts B-PFO B-Help B-sch B-History B-mark B-add B-lkp B-chg B-del ~
b-exec-fo b-exec-pay B-print R-1 R-2 v-date-doc-1 v-date-pay-1 R-3 ~
v-date-doc-2 v-date-pay-2 B-reopen-br sch-code p-desc p-date BR-docs ~
T-paket FILL-IN-20 FILL-IN-21 FILL-IN-22 FILL-IN-24 FILL-IN-26 s-name ~
FILL-IN-1 loc_receiver-name loc_sum-doc d-abbr loc_user-name loc_payer-name ~
loc_sum-rubl r-abbr loc_sum-base v-abbr mark-num loc_sum-contr v-abbr-contr
&Scoped-Define DISPLAYED-OBJECTS R-1 R-2 v-date-doc-1 v-date-pay-1 R-3 ~
v-date-doc-2 v-date-pay-2 sch-code p-desc p-date T-paket FILL-IN-20 ~
FILL-IN-21 FILL-IN-22 FILL-IN-24 FILL-IN-26 s-name FILL-IN-1 ~
loc_receiver-name loc_sum-doc d-abbr loc_user-name loc_payer-name ~
loc_sum-rubl r-abbr loc_sum-base v-abbr mark-num loc_sum-contr v-abbr-contr

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD contract-gen Dialog-Frame
FUNCTION contract-gen RETURNS CHARACTER
(input p-rec as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD contract-id Dialog-Frame
FUNCTION contract-id RETURNS CHARACTER
  ( input p-rec as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD debts Dialog-Frame
FUNCTION debts RETURNS DECIMAL
  ( input p-rec as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-factur Dialog-Frame
FUNCTION f-factur RETURNS CHARACTER
  (input p-rec as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD sel-abbr Dialog-Frame
FUNCTION sel-abbr RETURNS CHARACTER
 ( p-curr-code as int )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD val-abbr-type Dialog-Frame
FUNCTION val-abbr-type RETURNS CHARACTER
  ( input p-rec as recid)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-b-fact
       MENU-ITEM m_gen-1        LABEL "Генерация"
       MENU-ITEM m_gen-2        LABEL "Отказаться от генерации счета-фактуры"
       MENU-ITEM m_gen-3        LABEL "Снять признак - есть генерация счета-фактуры"
       MENU-ITEM m_gen-4        LABEL "Снять 'не опред'"
       MENU-ITEM m_sf           LABEL "Просмотр Счета-фактуры"
       .

DEFINE MENU POPUP-MENU-b-print
       MENU-ITEM m_print-1      LABEL "Финансовые обязательства"
       MENU-ITEM m_print-2      LABEL "Заявка на оплату".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавление записи"
     BGCOLOR 8 .

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменение записи"
     BGCOLOR 8 .

DEFINE BUTTON B-close
     LABEL "&Закрыть"
     SIZE 10 BY 1 TOOLTIP "Перевод в другой статус финансовых обязательств"
     BGCOLOR 8 .

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1 TOOLTIP "Удаление записи"
     BGCOLOR 8 .

DEFINE BUTTON b-exec-fo
     LABEL "&Генерация"
     SIZE 10 BY 1 TOOLTIP "Создание фин.обязательств"
     BGCOLOR 8 .

DEFINE BUTTON b-exec-pay
     LABEL "Плате&ж"
     SIZE 10 BY 1 TOOLTIP "Создание платежей"
     BGCOLOR 8 .

DEFINE BUTTON B-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 13 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Export
     LABEL "&Экспорт"
     SIZE 10 BY 1 TOOLTIP "Экспорт в XML"
     BGCOLOR 8 .

DEFINE BUTTON b-fact
     LABEL "С&чет-факт":L
     SIZE 10 BY 1 TOOLTIP "Счет-фактура".

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-History
     LABEL "Ис&тория"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр записи".

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1 TOOLTIP "Отметить строки списка"
     BGCOLOR 8 .

DEFINE BUTTON B-parts
     LABEL "Па&ртии"
     SIZE 10 BY 1 TOOLTIP "Просмотр складского документа"
     BGCOLOR 8 .

DEFINE BUTTON B-PFO
     LABEL "ПФ&О"
     SIZE 10 BY 1 TOOLTIP "ПредФинОбязательства"
     BGCOLOR 8 .

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1 TOOLTIP "Печать текущего списка"
     BGCOLOR 8 .

DEFINE BUTTON B-reopen-br
     LABEL "Применит&ь"
     SIZE 10 BY 1 TOOLTIP "Сделать выборку по заданным параметрам".

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 10 BY 1 TOOLTIP "Фильтрация списка"
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1 TOOLTIP "Выбор отмеченных или текущей записи"
     BGCOLOR 8 .

DEFINE BUTTON B-trn
     LABEL "Д&окум."
     SIZE 10 BY 1 TOOLTIP "Просмотр складских документов, породивших ФО"
     BGCOLOR 8 .

DEFINE VARIABLE d-abbr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "ПОИСК ПО"
      VIEW-AS TEXT
     SIZE 8.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-20 AS CHARACTER FORMAT "X(256)":U INITIAL "Получатели"
      VIEW-AS TEXT
     SIZE 11.5 BY .67
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-21 AS CHARACTER FORMAT "X(256)":U INITIAL "Договоры"
      VIEW-AS TEXT
     SIZE 11.5 BY .67
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-22 AS CHARACTER FORMAT "X(256)":U INITIAL "Дата создания"
      VIEW-AS TEXT
     SIZE 13.5 BY .67
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-24 AS CHARACTER FORMAT "X(256)":U INITIAL "Дата платежа"
      VIEW-AS TEXT
     SIZE 12.5 BY .67
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-26 AS CHARACTER FORMAT "X(256)":U INITIAL "Задолжен."
      VIEW-AS TEXT
     SIZE 9 BY .67 TOOLTIP "Непогашеная задолженность"
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE loc_payer-name AS CHARACTER FORMAT "X(40)"
     LABEL "Плательщик"
      VIEW-AS TEXT
     SIZE 21.13 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc_receiver-name AS CHARACTER FORMAT "X(40)"
     LABEL "Получатель"
      VIEW-AS TEXT
     SIZE 21.13 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc_sum-base AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма б.в."
      VIEW-AS TEXT
     SIZE 17.5 BY .67 NO-UNDO.

DEFINE VARIABLE loc_sum-contr AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма дог."
      VIEW-AS TEXT
     SIZE 17.5 BY .67 TOOLTIP "Сумма в валюте договора" NO-UNDO.

DEFINE VARIABLE loc_sum-doc AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма док."
      VIEW-AS TEXT
     SIZE 17.5 BY .67 NO-UNDO.

DEFINE VARIABLE loc_sum-rubl AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма abbr_rub."
      VIEW-AS TEXT
     SIZE 17.5 BY .67 NO-UNDO.

DEFINE VARIABLE loc_user-name AS CHARACTER FORMAT "X(10)"
     LABEL "Создал"
      VIEW-AS TEXT
     SIZE 12.88 BY .67
     FGCOLOR 4
     NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE p-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата фин.об."
     VIEW-AS FILL-IN
     SIZE 11 BY 1 TOOLTIP "Поиск по дате создания фин.об. (Поиск первой записи - <ВВОД>; поиск следующей -<CTRL-J>)"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE p-desc AS CHARACTER FORMAT "X(80)":U
     LABEL "№ договора"
     VIEW-AS FILL-IN
     SIZE 20.63 BY 1 TOOLTIP "Поиск по № договора. (Поиск первой записи - <ВВОД>; поиск следующей -<CTRL-J>)"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE r-abbr AS CHARACTER FORMAT "X(256)":U INITIAL "abbr_rub_allshift"
      VIEW-AS TEXT
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE s-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 23.5 BY .58
     FONT 2 NO-UNDO.

DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(12)":U
     LABEL "№ фин.обяз"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Поиск по номеру ФО. (Поиск первой записи - <ВВОД>; поиск следующей -<CTRL-J>)"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-abbr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-abbr-contr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-date-doc-1 AS DATE FORMAT "99/99/99":U
     LABEL "c"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Параметры для выборки . Интервал дат"
     FGCOLOR 1 FONT 2 NO-UNDO.

DEFINE VARIABLE v-date-doc-2 AS DATE FORMAT "99/99/99":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Параметры для выборки . Интервал дат"
     FGCOLOR 1 FONT 2 NO-UNDO.

DEFINE VARIABLE v-date-pay-1 AS DATE FORMAT "99/99/99":U
     LABEL "c"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Параметры для выборки . Интервал дат"
     FGCOLOR 1 FONT 2 NO-UNDO.

DEFINE VARIABLE v-date-pay-2 AS DATE FORMAT "99/99/99":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Параметры для выборки . Интервал дат"
     FGCOLOR 1 FONT 2 NO-UNDO.

DEFINE VARIABLE R-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 12 BY 1.25 TOOLTIP "Параметры для выборки"
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE R-2 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 11.5 BY 1.25 TOOLTIP "Параметры для выборки"
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE R-3 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Есть", 2,
"Нет", 3
     SIZE 7 BY 2 TOOLTIP "Параметры для выборки. Непогашеная задолженность"
     FGCOLOR 1  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 93 BY 3.5 TOOLTIP "Параметры для выборки ФО".

DEFINE VARIABLE S-tt AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE NO-DRAG SCROLLBAR-VERTICAL
     SIZE 19.5 BY 3.5 TOOLTIP "Список договоров"
     BGCOLOR 8 FGCOLOR 0 FONT 2 NO-UNDO.

DEFINE VARIABLE T-paket AS LOGICAL INITIAL no
     LABEL "П&акетный режим"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY .83 TOOLTIP "Работа с выделенным списком финобязательств" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE new shared QUERY BR-docs FOR
      buf_fin-liab except ,
      xx-contract SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-docs Dialog-Frame _FREEFORM
  QUERY BR-docs DISPLAY
     {&cop-l0} @ p-mark  COLUMN-LABEL {&col-l0}   FORMAT "x(1)"
     {&cop-l1}    COLUMN-LABEL {&col-l1}          Format "x(6)"
     {&cop-l2}    COLUMN-LABEL {&col-l2}          Format "x(10)"
     {&cop-l3}    COLUMN-LABEL {&col-l3}          format "99/99/99"
     {&cop-l4}    COLUMN-LABEL {&col-l4}          format "99/99/99"
     {&cop-l5} @ p-contr   COLUMN-LABEL {&col-l5}          Format "x(16)"
     {&cop-l6}    COLUMN-LABEL {&col-l6}          Format "x(10)"
     {&cop-l7}    COLUMN-LABEL {&col-l7}          Format "x(10)"
     {&cop-l8}   COLUMN-LABEL {&col-l8}           format "99/99/99"
     {&cop-l9}  @ l-curr COLUMN-LABEL {&col-l9}         Format "x(3)"
     {&cop-l10}   COLUMN-LABEL {&col-l10}
     {&cop-l12}   COLUMN-LABEL {&col-l12}         Format "99999999"
     {&cop-l13} @ p-type   COLUMN-LABEL {&col-l13}          Format "x(13)"
     {&cop-l14} @ p-debts  COLUMN-LABEL {&col-l14}          Format  "->>>>>>>>>>>9.99"
     {&cop-l15} @ p-obj  COLUMN-LABEL {&col-l15}   Format "x(9)"
     {&cop-l16}   COLUMN-LABEL {&col-l16}          Format "x(40)"
     {&cop-l17} @ p-gen  COLUMN-LABEL {&col-l17}          Format "x(40)"
     {&cop-l18} @ varfactur column-label {&col-l18} format "x(8)"

      enable {&cop-l1}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 93.75 BY 12.5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-sel AT ROW 1 COL 14
     B-close AT ROW 1 COL 24
     B-Export AT ROW 1 COL 34
     b-fact AT ROW 1 COL 44
     B-trn AT ROW 1 COL 54
     B-parts AT ROW 1 COL 64
     B-PFO AT ROW 1 COL 74
     B-Help AT ROW 1 COL 84
     B-sch AT ROW 1 COL 84
     B-History AT ROW 1 COL 85
     B-mark AT ROW 2 COL 1
     B-add AT ROW 2 COL 4
     B-lkp AT ROW 2 COL 14
     B-chg AT ROW 2 COL 24
     B-del AT ROW 2 COL 34
     b-exec-fo AT ROW 2 COL 44
     b-exec-pay AT ROW 2 COL 64
     B-print AT ROW 2 COL 84
     S-tt AT ROW 3 COL 25 NO-LABEL
     R-1 AT ROW 3.75 COL 1 NO-LABEL
     R-2 AT ROW 3.75 COL 13.5 NO-LABEL
     v-date-doc-1 AT ROW 3.75 COL 47.5 COLON-ALIGNED
     v-date-pay-1 AT ROW 3.75 COL 60.75 COLON-ALIGNED
     R-3 AT ROW 3.75 COL 72 NO-LABEL
     v-date-doc-2 AT ROW 4.75 COL 47.5 COLON-ALIGNED
     v-date-pay-2 AT ROW 4.75 COL 60.75 COLON-ALIGNED
     B-reopen-br AT ROW 5 COL 84
     sch-code AT ROW 6.58 COL 10.87
     p-desc AT ROW 6.58 COL 37.13
     p-date AT ROW 6.58 COL 70
     BR-docs AT ROW 7.71 COL 1.5
     T-paket AT ROW 21.08 COL 73.75
     FILL-IN-20 AT ROW 3 COL 1 NO-LABEL
     FILL-IN-21 AT ROW 3 COL 13.5 NO-LABEL
     FILL-IN-22 AT ROW 3 COL 44.5 NO-LABEL
     FILL-IN-24 AT ROW 3 COL 58.75 NO-LABEL
     FILL-IN-26 AT ROW 3 COL 72 NO-LABEL
     s-name AT ROW 5.25 COL 1 NO-LABEL
     FILL-IN-1 AT ROW 6.75 COL 1.5 NO-LABEL
     loc_receiver-name AT ROW 20.25 COL 1.5
     loc_sum-doc AT ROW 20.25 COL 44.5 COLON-ALIGNED
     d-abbr AT ROW 20.25 COL 62.88 COLON-ALIGNED NO-LABEL
     loc_user-name AT ROW 20.25 COL 79.13 COLON-ALIGNED
     loc_payer-name AT ROW 21.08 COL 1.5
     loc_sum-rubl AT ROW 21.08 COL 44.5 COLON-ALIGNED
     r-abbr AT ROW 21.08 COL 62.88 COLON-ALIGNED NO-LABEL
     loc_sum-base AT ROW 21.92 COL 44.5 COLON-ALIGNED
     v-abbr AT ROW 21.92 COL 62.88 COLON-ALIGNED NO-LABEL
     mark-num AT ROW 22.5 COL 74 NO-LABEL
     loc_sum-contr AT ROW 22.71 COL 44.5 COLON-ALIGNED
     v-abbr-contr AT ROW 22.71 COL 62.88 COLON-ALIGNED NO-LABEL
     RECT-1 AT ROW 3 COL 1
     SPACE(1.63) SKIP(17.08)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Финансовые обязательства"
         DEFAULT-BUTTON B-sel CANCEL-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: x-contract T "NEW SHARED" NO-UNDO ub contract
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-docs p-date Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-fact:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-fact:HANDLE.

ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-print:HANDLE.

ASSIGN
       BR-docs:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.

/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-20 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-21 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-22 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-24 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-26 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN loc_payer-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN loc_receiver-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       mark-num:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN p-date IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN p-desc IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN s-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR SELECTION-LIST S-tt IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       S-tt:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN sch-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-docs
/* Query rebuild information for BROWSE BR-docs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_fin-liab  NO-LOCK , FIRST xx-contract .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-docs */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Финансовые обязательства */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  define variable g-log as logical no-undo .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-liability_add-def':U
  {&cntxt-firm}
  par-host-code
  '':U
  0
  0
  0
  0
  true
  g-log
}
if not g-log then  return .
  run add-proc in this-procedure .
END.

ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Добавить */
DO:

define variable cur-clmn-loc as integer   no-undo .
define variable column-handle as handle no-undo .
define variable v-list as character no-undo .

  assign
    cur-clmn-loc  = 1
    column-handle = {&browse-name}:first-column
    v-list        = column-handle:label + "#"
  .

  do while valid-handle(column-handle) :
    if cur-clmn-loc = {&browse-name}:num-columns then do:
      leave .
    end.
    assign
      column-handle = column-handle:NEXT-COLUMN
      cur-clmn-loc  = cur-clmn-loc + 1
      v-list        = v-list + column-handle:label + "#"
    .
  end.

   v-list = trim(v-list, "#") .
   define variable v-i as integer   no-undo .
   define variable v-pos as integer   no-undo .
   define variable v-list-new as character no-undo .
   define variable v-elem as character no-undo .

   repeat v-i = 1 to {&browse-name}:num-columns :
      v-elem = entry( v-i, v-list , "#") .

      v-pos = lookup( v-elem, {&head-col} , "#") .
      v-list-new = v-list-new + string(v-pos) + "," .
   end.

   define variable v-list-str as character no-undo .
   define variable v-1 as integer   no-undo .
   v-list-str = "" .
   v-1 = num-entries(v-list-new)  .
   repeat v-i = 1 to v-1 :
      v-elem = entry(v-i , v-list-new ) .
      if int(v-elem) > 3 then
      v-list-str  = v-list-str + v-elem + "," .
   end.

   v-list-new = trim(v-list-str ,",")  +  {&delim-par}
              + string(decimal( buf_fin-liab.receiver-name:width in browse {&browse-name})) +  {&delim-par}
              + string(decimal( p-gen:width                    in browse {&browse-name})) +  {&delim-par}
              + string(decimal( buf_fin-liab.sum-doc:width     in browse {&browse-name})) +  {&delim-par}
              + string(decimal( p-contr:width                  in browse {&browse-name})) +  {&delim-par}
              + string(decimal( buf_fin-liab.status_:width     in browse {&browse-name})) +  {&delim-par}  .


/*
   message v-list-new +
   "update ?"
   view-as alert-box question
   buttons yes-no
   update vv-ok as logical
   .
   if vv-ok then v-list-new  = "4,5,6,7,8,9,10,11,12,13,14,15,16,17,18" +  {&delim-par}  +  {&delim-par}.
*/

run uf-set in this-procedure(
    input  {&uf-fin-ob}
    ,input v-cntxt-userid
    ,input v-list-new
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
) no-error    .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "uf-set"
      view-as alert-box error
    .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-liability_update':U
    {&cntxt-firm}
    par-host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }

if not g-log then  return .
if not available buf_fin-liab then return .

if  buf_fin-liab.status_ = {&fin-fact} then do:
    message "Финансовое обязательство в статусе " buf_fin-liab.status_ " изменять нельзя !!!"
    view-as alert-box information .
    return no-apply.
end.

define variable rr as recid no-undo .
    if available buf_fin-liab then do:
        rr = recid( buf_fin-liab ).
        p-doc-type = buf_fin-liab.doc-type .
        p-status_  = buf_fin-liab.status_  .
        run str/fi-liabi.w
           (input parParentProc ,
            input {&update} ,
            input-output rr ,
            input par-host-code  ,
            input p-doc-type,
            input p-status_
            ).
        g-log =  {&BROWSE-NAME}:refresh() .
        apply "VALUE-CHANGED" TO BR-docs IN FRAME Dialog-Frame.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-close Dialog-Frame
ON CHOOSE OF B-close IN FRAME Dialog-Frame /* Закрыть */
DO:
  run proc-close in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:

if not available buf_fin-liab then return .
define buffer buf_del-fin-ob for ub.fin-ob .

/* Право на удаление */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-liability_deletion':U
    {&cntxt-firm}
    par-host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }
if not g-log then  return .
  else do:
      message "Удалить запись ?"
      view-as alert-box question
      buttons yes-no
      update g-log.
      if g-log = false then return no-apply.
  end.
  define variable v-recid as integer no-undo .
  define variable ii as integer no-undo .

  assign
  t-paket
  .

  if t-paket then do:
    define variable rr as integer init 0 no-undo .
    define variable v-2 as integer   no-undo .
    v-2 = num-entries (rid-list) .
    repeat ii = 1 to v-2 :
       v-recid = integer(entry(ii, rid-list)).
       find first buf_del-fin-ob no-lock where recid(buf_del-fin-ob) = v-recid no-error .
        if error-status :error then next.
        if  buf_del-fin-ob.status_ = {&fin-fact} then next.
        find first buf_del-fin-ob  exclusive-lock   where recid(buf_del-fin-ob) = v-recid no-error .
        if available buf_del-fin-ob then do:
          delete buf_del-fin-ob .
          rr = rr + 1.
        end.
    end.
  end.
  else do:
/*        if  buf_fin-liab.status_ = {&fin-fact}  then do:                               */
/*            message "Финансовое обязательство в статусе ФАКТ не может быть удалено !!!"*/
/*            view-as alert-box information .                                            */
/*            return no-apply.                                                           */
/*        end.                                                                           */
        find current buf_fin-liab  exclusive-lock  no-error .
        v-recid = recid ( buf_fin-liab ) .
        if available buf_fin-liab then do:
           delete buf_fin-liab  .
        end.
   end.

    define variable g#log as logical no-undo .
    define variable v-doc-rec as recid no-undo .

  br-handle = {&browse-name}:handle in frame {&frame-name} .
  if valid-handle (br-handle) then do:
    g#log = br-handle:select-next-row().
    if not g#log then g#log = br-handle:select-prev-row().
    v-doc-rec = recid (buf_fin-liab) .
  end.

   run OpenBr in this-procedure (yes, no, '':U).
   apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
   reposition {&browse-name} to recid v-doc-rec no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exec-fo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exec-fo Dialog-Frame
ON CHOOSE OF b-exec-fo IN FRAME Dialog-Frame /* Генерация */
DO:
  define variable g-log as logical no-undo .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-liability_add-def':U
  {&cntxt-firm}
  par-host-code
  '':U
  0
  0
  0
  0
  true
  g-log
}
if not g-log then  return .
if p-doc-type = {&income} then
  run str/gen-fbuy.w
  ( input parParentProc,
    input par-host-code,
    input ? ,
    input ""
    ).

else
  run str/gen-fl.w
  ( input parParentProc,
    input par-host-code,
    input ? ,
    input ""
    ).
  run OpenBr in this-procedure (yes, no, '':U).
  apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Export Dialog-Frame
ON CHOOSE OF B-Export IN FRAME Dialog-Frame /* Экспорт */
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-liability_export':U
    {&cntxt-firm}
    par-host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }
if not g-log then  return .

  run proc-b-exp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-History
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-History Dialog-Frame
ON CHOOSE OF B-History IN FRAME Dialog-Frame /* История */
DO:
if available buf_fin-liab then do:
       run str/fincliab.w
         (input  parparentproc          ,
          input  ""                      ,
          input  {&company}                  ,
          input  par-host-code           ,
          input  buf_fin-liab.doc-code   ,
          output rid-list       ).
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp Dialog-Frame
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-liability_lookup':U
    {&cntxt-firm}
    par-host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }
if not g-log then  return .
define variable rr as recid no-undo .
    if available buf_fin-liab then do:
        rr = recid( buf_fin-liab ).
        p-doc-type = buf_fin-liab.doc-type .
        p-status_  = buf_fin-liab.status_  .

      br-handle = {&browse-name}:handle in frame {&frame-name} .
      next-prev = no.
      do while next-prev <> ?:
        if not available buf_fin-liab then do:
          message "Неправильный выбор документа.".
          return no-apply.
        end.

        run str/fi-liabi.w
           ( parParentProc,
           {&lookup} ,
           input-output rr ,
           input par-host-code  ,
           input p-doc-type,
           input p-status_
           ).
        if br-handle = ? then reposition {&browse-name} to recid rr no-error.
      end.
     end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
      if available buf_fin-liab then do:
        { gbl/markstrn.i buf_fin-liab rid-list }

        g-log = br-docs:refresh() .
        if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            g-log = br-docs:select-next-row ().
            apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
        end.
        if num-entries( rid-list ) = 0
        then
            hide mark-num in frame {&frame-name}.
        else do:
           /*
            mark-num:screen-value in frame {&frame-name}  = string (num-entries( rid-list )) .
            enable mark-num with frame {&frame-name}.
            */
            end.
    end.
    apply "entry" to br-docs in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-parts Dialog-Frame
ON CHOOSE OF B-parts IN FRAME Dialog-Frame /* Партии */
DO:
    if not available buf_fin-liab then return .
    run str/fi-parts.w
      ( input parParentProc ,
        input buf_fin-liab.doc-code ,
        input par-host-code  ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-PFO
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-PFO Dialog-Frame
ON CHOOSE OF B-PFO IN FRAME Dialog-Frame /* ПФО */
DO:
if available buf_fin-liab then do:
run str/fin-pob.w
(   input parParentProc ,
    input "" /*bttns */       ,
    input "fin-ob":u   ,
    input ?   ,
    input par-host-code,
    input p-doc-type   ,
    input p-status_    ,
    input string(buf_fin-liab.doc-code) ,
    output rid-list    ) no-error  .

  if error-status:error then return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-reopen-br
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-reopen-br Dialog-Frame
ON CHOOSE OF B-reopen-br IN FRAME Dialog-Frame /* Применить */
DO:
  run set-selection in this-procedure .
  run OpenBr in this-procedure (yes, no, '':U).

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


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available buf_fin-liab ) AND ( rid-list = "" ) then
    rid-list = string( recid( buf_fin-liab ) ) .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-trn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-trn Dialog-Frame
ON CHOOSE OF B-trn IN FRAME Dialog-Frame /* Докум. */
DO:

if not available buf_fin-liab then return .

   run str/fi-trns.w
    ( input parParentProc ,
      input par-host-code,
      input buf_fin-liab.doc-code,
      input ? ,
      input "fin-ob":U
      ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-docs
&Scoped-define SELF-NAME BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON DELETE-CHARACTER OF BR-docs IN FRAME Dialog-Frame
DO:
   if b-mark:sensitive in frame {&frame-name} then
  APPLY "CHOOSE" to b-mark.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON INSERT-MODE OF BR-docs IN FRAME Dialog-Frame
DO:
    if b-mark:sensitive in frame {&frame-name} then
  APPLY "CHOOSE" to b-mark.
    else do:
      if b-sel:sensitive in frame {&frame-name} then
      APPLY "CHOOSE" to b-sel.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON RETURN OF BR-docs IN FRAME Dialog-Frame
OR MOUSE-SELECT-DBLCLICK OF {&self-name} IN FRAME {&frame-name}
DO:
      if b-sel:sensitive in frame {&frame-name}  = yes then
        apply "choose" to b-sel in frame {&frame-name}.
    else
        apply "choose" to B-lkp in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON VALUE-CHANGED OF BR-docs IN FRAME Dialog-Frame
DO:
if available buf_fin-liab then do:
    assign
    loc_receiver-name  = buf_fin-liab.receiver-name
    loc_payer-name        = buf_fin-liab.payer-name
    loc_sum-base  = buf_fin-liab.sum-base
    loc_sum-doc   = buf_fin-liab.sum-doc
    loc_sum-rubl  = buf_fin-liab.sum-rubl
    loc_sum-contr  =  buf_fin-liab.sum-contract
    d-abbr        = sel-abbr(buf_fin-liab.curr-code)
    v-abbr        = sel-abbr(p-base-code)
    v-abbr-contr    = sel-abbr(buf_fin-liab.contract-curr)
  .
  { gbl/usrfulnm.i
  buf_fin-liab.user-name-doc
  loc_user-name
  }
end.

else
 assign
   loc_receiver-name  = ""
   loc_payer-name        = ""
   loc_sum-base            = 0
   loc_sum-doc             = 0
   loc_sum-rubl            = 0
   loc_user-name           = ""
   d-abbr                         = ""
   loc_sum-contr            = 0
      v-abbr-contr  = ""
    .

display
  loc_receiver-name
  loc_payer-name
  loc_sum-base
  loc_sum-doc
  loc_sum-rubl
  loc_sum-contr
  r-abbr
  v-abbr
  d-abbr
  loc_user-name
  v-abbr-contr
  with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_gen-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_gen-1 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_gen-1 /* Генерация */
DO:
run proc-m_gen-1 in this-procedure  no-error .
  if error-status :error then do:
     message
       error-status :get-message(1) skip
       return-value skip
       view-as alert-box error
     .
     return no-apply.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_gen-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_gen-2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_gen-2 /* Отказаться от генерации счета-фактуры */
DO:
run proc-m_gen-2 in this-procedure  no-error .
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_gen-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_gen-3 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_gen-3 /* Снять признак - есть генерация счета-фактуры */
DO:
run proc-m_gen-3 in this-procedure  no-error .
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_gen-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_gen-4 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_gen-4 /* Снять 'не опред' */
DO:
run proc-m_gen-4 in this-procedure  no-error .
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_sf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_sf Dialog-Frame
ON CHOOSE OF MENU-ITEM m_sf /* Снять 'не опред' */
DO:
define variable v-rid-list as character no-undo .
if not available buf_fin-liab then  return .
  run str/s-f-docs.w
    ( input parparentproc,
      input v-cntxt-host-code-obj,
      ?,
      ?,
      ?,
      "fo" ,
      buf_fin-liab.doc-type,
      buf_fin-liab.doc-code,
      "" ,
      input "in-doc",
      input-output v-rid-list
      ) no-error .
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_print-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_print-1 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_print-1 /* Финансовые обязательства */
DO:
  run print-proc in this-procedure  no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_print-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_print-2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_print-2 /* Заявка на оплату */
DO:
  if not available buf_fin-liab then  return .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-liability_print':U
    {&cntxt-firm}
    par-host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .
  run rep/prn-zay.p ( input parParentProc
                    , input recid (buf_fin-liab)
                    , input "fo"
                    , input no
                    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME p-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL p-date Dialog-Frame
ON LEAVE OF p-date IN FRAME Dialog-Frame /* Дата фин.об. */
DO:
END.

ON CTRL-J OF p-date IN FRAME Dialog-Frame
DO:
assign p-date no-error .
  if error-status:error then return no-apply.
  run proc-find-date in this-procedure(yes, p-date) no-error.
  if error-status:error then return no-apply.

END.

ON RETURN OF p-date IN FRAME Dialog-Frame
DO:
assign p-date no-error .
  if error-status:error then return no-apply.
  run proc-find-date in this-procedure(no, p-date) no-error.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME p-desc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL p-desc Dialog-Frame
ON LEAVE OF p-desc IN FRAME Dialog-Frame /* № договора */
DO:
END.

ON CTRL-J OF p-desc IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-desc in this-procedure ( yes, input frame {&frame-name} p-desc) no-error.
    if error-status:error then return no-apply.

END.

ON RETURN OF p-desc IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-desc in this-procedure ( no, input frame {&frame-name} p-desc) no-error.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-1 Dialog-Frame
ON VALUE-CHANGED OF R-1 IN FRAME Dialog-Frame
DO:
       hard-flt-cli-code = ?.
       hard-flt-cli-type = ?.
       s-name = "" .

  assign r-1 .
  if r-1 = 1 then
     hide s-name in frame {&frame-name} .
  else do :


  def buffer b#clients for ub.clients.
       run ref/cli-all.w ( parparentproc, input "b-sel", {&cmp}, ?, ?, ?, ?, ?, output  rid-list).
           find first b#clients where recid(b#clients) = integer(rid-list) no-lock no-error.
   if available  b#clients then do:
       hard-flt-cli-code = b#clients.obj-code.
       hard-flt-cli-type = b#clients.obj-type.
       s-name = b#clients.obj-name.
   end.
   else do:
     r-1 = 1.
   end.
   display  r-1 s-name with frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-2 Dialog-Frame
ON VALUE-CHANGED OF R-2 IN FRAME Dialog-Frame
DO:

define buffer buf_contract for ub.contract  .
define variable ii as integer   no-undo .
define variable v-tt as character no-undo .
define variable p-rid-list as character no-undo .
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer   no-undo .



assign r-2 .
for each x-contract : delete x-contract . end.

  if r-2 = 1 then do:   /* все договора */
     hide s-tt in frame {&frame-name} .
      FIND FIRST buf_contract no-lock  no-error .
      if available buf_contract then do:
              CREATE x-contract.
              BUFFER-COPY buf_contract TO x-contract  .
      end.
      else  do:
        CREATE x-contract.
        assign
          x-contract.contract-code = 1
          x-contract.host-code = 1
        .
      end.
  end.
  else do:  /* выборочно */
      if r-1 = 2 then do:  /* по контрагенту */
        assign
          v-cli-type = hard-flt-cli-type
          v-cli-code = hard-flt-cli-code
        .
      end.
      else do: /* контрагент не определен */
        assign
          v-cli-type = ?
          v-cli-code = ?
          .
      end.

      run str/cont-all.w
      (   input   parParentProc   ,
          input   par-host-code   ,
          input   "b-sel,b-mark"  ,
          input   {&company}      ,
          input   v-cli-type      ,
          input   v-cli-code      ,
          input   ?               ,
          input   ?               ,
          input   "current"       ,
          input  ( if p-doc-type = {&income} then {&expense} else {&income} ) ,
          input-output p-rid-list )
          .

          if p-rid-list = "" then do:
            CREATE x-contract.
            assign
              x-contract.contract-code = 1
              x-contract.host-code = 1
            .
            r-2 = 1.
          end.

          v-tt =  "".
          define variable v-3 as integer   no-undo .
          v-3 = num-entries (p-rid-list) .
          repeat ii = 1 to v-3 :
            find first buf_contract no-lock where recid(buf_contract) =  integer( entry(ii, p-rid-list)) no-error .
            if available buf_contract then do:
                  CREATE x-contract.
                  BUFFER-COPY buf_contract TO x-contract  .
                  v-tt = v-tt + buf_contract.contract-prn-code + "(" + string (buf_contract.contract-code) + "),".

            end.
          end.
        s-tt:LIST-ITEMS  = trim (v-tt, ",") .
        display s-tt r-2 with frame {&frame-name} .
        enable s-tt with frame {&frame-name} .
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-3 Dialog-Frame
ON VALUE-CHANGED OF R-3 IN FRAME Dialog-Frame
DO:
  ASSIGN r-3 .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame /* № фин.обяз */
DO:
  run proc-find-code in this-procedure ( no, input frame {&frame-name} sch-code) no-error.
  return no-apply.
END.

ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-code in this-procedure ( yes, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-paket
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-paket Dialog-Frame
ON VALUE-CHANGED OF T-paket IN FRAME Dialog-Frame /* Пакетный режим */
DO:
  assign T-paket.
  rid-list = "" .
  g-log = br-docs:SELECT-ROW(1) no-error  .
  if error-status :get-message(1) = "" then
     g-log = br-docs:refresh()  .


  IF t-paket= TRUE THEN DO:
      ENABLE B-close
             B-del 
             B-lkp when LOOKUP("b-lkp":U,  bttns) > 0
             B-mark
             with frame {&frame-name} .
      disable
         B-add     when LOOKUP("b-add":U,  bttns) > 0
         B-chg     when LOOKUP("b-chg":U,  bttns) > 0
         B-sel     when LOOKUP("b-sel":U,  bttns) > 0
         b-exec-fo
         B-History
         B-parts
         B-PFO
         B-print
         B-trn
      with frame {&frame-name} .

  END.
  ELSE DO:
      disable
             B-mark when LOOKUP("b-mark":U,  bttns) = 0
             with frame {&frame-name} .
      enable
         B-add     when LOOKUP("b-add":U,  bttns) > 0
         B-chg     when LOOKUP("b-chg":U,  bttns) > 0
         B-sel     when LOOKUP("b-sel":U,  bttns) > 0
         b-exec-fo when LOOKUP("b-exec-fo":U,  bttns) > 0
         B-History
         B-parts
         B-PFO
         B-print
         B-trn
      with frame {&frame-name} .

  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-date-doc-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-date-doc-1 Dialog-Frame
ON LEAVE OF v-date-doc-1 IN FRAME Dialog-Frame /* c */
DO:
  /**/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-date-doc-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-date-doc-2 Dialog-Frame
ON LEAVE OF v-date-doc-2 IN FRAME Dialog-Frame /* по */
DO:
  /**/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-date-pay-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-date-pay-1 Dialog-Frame
ON LEAVE OF v-date-pay-1 IN FRAME Dialog-Frame /* c */
DO:
  /**/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-date-pay-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-date-pay-2 Dialog-Frame
ON LEAVE OF v-date-pay-2 IN FRAME Dialog-Frame /* по */
DO:
  /**/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
b-fact:menu-mouse = 1.
b-print:menu-mouse = 1.
{ gbl/brwrefre.i  "run OpenBr in this-procedure (yes, no, '':U)." }

define buffer buf_contract for ub.contract  .

/* Права на просмотр списка */
define variable v-right-supp as logical no-undo .
define variable v-right-buyer as logical   no-undo .
v-right-supp = true .
v-right-buyer = true .

  case p-doc-type :
    when {&expense} then do:
      p-doc-type-full = " c ПОСТАВЩИКАМИ ".
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-supp':U
    {&cntxt-firm}
    par-host-code
    ''
    0
    0
    0
    0
    true
    v-right-supp
  }

    end.
    when {&income} then do:
      p-doc-type-full = " с ПОКУПАТЕЛЯМИ ".
      hide b-pfo in frame {&frame-name} .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-buyer':U
    {&cntxt-firm}
    par-host-code
    ''
    0
    0
    0
    0
    true
    v-right-buyer
  }

    end.
    otherwise do:
      p-doc-type-full = " ".
    end.
  end.
if v-right-supp = false or v-right-buyer = false  then return .

  { str/crfinob.i  fin-ob }

{ gbl/brwrepos.i
  &line-num=8
}

 { gbl/ed_date.i p-date}
 { gbl/ed_date.i v-date-doc-1}
 { gbl/ed_date.i v-date-doc-2}
 { gbl/ed_date.i v-date-pay-1}
 { gbl/ed_date.i v-date-pay-2}

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "ub.fin-ob"
  &label-clmn_1     =   "{&col-l0}"
  &label-clmn_2     =   "{&col-l1}"
  &label-clmn_3     =   "{&col-l2}"
  &label-clmn_4     =   "{&col-l3}"
  &label-clmn_5     =   "{&col-l4}"
  &label-clmn_6     =   "{&col-l5}"
  &label-clmn_7     =   "{&col-l6}"
  &label-clmn_8     =   "{&col-l7}"
  &label-clmn_9     =   "{&col-l8}"
  &label-clmn_10    =   "{&col-l9}"
  &label-clmn_11    =   "{&col-l10}"
  &label-clmn_12    =   "{&col-l12}"
  &label-clmn_13    =   "{&col-l13}"
  &label-clmn_14    =   "{&col-l14}"
  &label-clmn_15    =   "{&col-l15}"
  &label-clmn_16    =   "{&col-l16}"
  &label-clmn_17    =   "{&col-l17}"
  &label-clmn_18    =   "{&col-l18}"
  &sort-clmn_1      =   "{&cop-l0}"
  &dyn_sort-clmn_1  =   "{&dyn_cop-l0}"
  &sort-clmn_2    =   "{&cop-l1}"
  &sort-clmn_3    =   "{&cop-l2}"
  &sort-clmn_4    =   "{&cop-l3}"
  &sort-clmn_5    =   "{&cop-l4}"
  &sort-clmn_6    =   "{&cop-l5}"
  &dyn_sort-clmn_6    =   "{&dyn_cop-l5}"
  &sort-clmn_7    =   "{&cop-l600}"
  &sort-clmn_8    =   "{&cop-l700}"
  &sort-clmn_9    =   "{&cop-l8}"
  &sort-clmn_10   =   "{&cop-l9}"
  &dyn_sort-clmn_10   =   "{&dyn_cop-l9}"
  &sort-clmn_11   =   "{&cop-l10}"
  &sort-clmn_12   =   "{&cop-l12}"
  &sort-clmn_13    =  "{&cop-l1300}"
  &sort-clmn_14    =  "{&cop-l14}"
  &dyn_sort-clmn_14    =  "{&dyn_cop-l14}"
  &sort-clmn_15    =  "{&cop-l1500}"
  &sort-clmn_16    =  "{&cop-l16}"
  &sort-clmn_17    =  "{&cop-l17}"
  &dyn_sort-clmn_17    =  "{&dyn_cop-l17}"
  &sort-clmn_18    =  "{&cop-l18}"
  &dyn_sort-clmn_18    =  "{&dyn_cop-l18}"
&open-query     = "run OpenBr (yes, no, '':U)."
&open-query-otherwise = "run OpenBr (yes, no, '':U)."
&sort-column-name     = "sort-column-name"
&re-move-clmn         = "yes"
&mv-brw-default       = "yes" }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
/* зацикливание формы */

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  find first ub.sysconf no-lock where ub.sysconf.host-code = par-host-code no-error .
  var-fin-calc = ub.sysconf.fin-calc   .

buf_fin-liab.receiver-name:resizable in browse {&browse-name}   = true .
p-gen:resizable                      in browse {&browse-name}   = true .
buf_fin-liab.sum-doc:resizable in browse {&browse-name}   = true .
p-contr:resizable              in browse {&browse-name}   = true .
buf_fin-liab.status_:resizable in browse {&browse-name}   = true .
buf_fin-liab.receiver-name:width     in browse {&browse-name}   = v-size-col1 .
p-gen:width                          in browse {&browse-name}   = v-size-col2 .
buf_fin-liab.sum-doc:width     in browse {&browse-name}   = v-size-col3 .
p-contr:width                  in browse {&browse-name}   = v-size-col4 .
buf_fin-liab.status_:width     in browse {&browse-name}   = v-size-col5 .


{&cop-l1}:read-only in browse {&browse-name} = true .

 if var-fin-calc = {&fin-calc-firm} then
    p-obj:visible in browse {&browse-name} = false .

/* Нaзвание таблицы */
define variable p-file-label as character no-undo .

p-file-label =  "Финансовые обязательства".
r-abbr  =  "{&abbr_rub_allshift}".

define buffer buf_clients for  ub.clients .
CASE par-mode:
    WHEN {&company} THEN DO:
      find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = {&cmp} no-error .
      if not available buf_clients then  return .
    END.
    WHEN "doc-type":U THEN DO:
      find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = {&cmp} no-error .
      if not available buf_clients then  return .
        if p-char <> "" then do:
            assign
            r-31 = 2
            r-32 = 1
            d-2 = 2
            v-date-pay-1 = 01/01/91
            v-date-pay-2 = date(p-char).
        end.
    END.
    WHEN "status":U THEN DO:
      find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = {&cmp} no-error .
      if not available buf_clients then  return .
    END.
    WHEN "contract":U THEN DO:
    end.
    otherwise do:
      message vss-workfile vss-revision vss-description skip
      "Неверный вызов - par-mode=" par-mode
      view-as alert-box ERROR.
      return.
    end.
  end CASE.
    if pardoc-rec <> ? then do:
      FIND FIRST find_code No-LOCK where
                 recid(find_code) = pardoc-rec No-ERROR.
      if not avail find_code then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова pardoc-rec" pardoc-rec
        view-as alert-box error .
        return error.
      end.
      doc-rec = pardoc-rec.
    end.
    
  run my-enable_UI in this-procedure .

  r-1 = 1 .
  r-2 = 1 .
  r-3 = 1 .
  FIND FIRST buf_contract no-lock  no-error .
if available buf_contract then do:
        CREATE xx-contract.
        BUFFER-COPY buf_contract TO xx-contract  .
    end.
    else  do:
      CREATE xx-contract.
      assign
        xx-contract.contract-code = 1
        xx-contract.host-code = 1
      .
    end.

  run OpenBR in this-procedure (yes, no, '':U).

{ gbl/mv-clmn.i
 &ext-col = 19
 &start-column = 4
 &frame-name = {&frame-name}
 &browse-name = {&browse-name}
 &prev-order-column_1 = v-order-col
 &prev-order-column-condition_1 = " true = true  "
}

  hide mark-num in frame {&frame-name} .
  if pardoc-rec <> ? then
     reposition br-docs to recid doc-rec no-error.
  apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-docs.

END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-proc Dialog-Frame
PROCEDURE add-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-doc-rec as recid no-undo .
if  p-doc-type = ?   then do:
  message  "Добавление финансовых обязательств возможно только  по типам !" view-as alert-box information .
  return .
end.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-liability_add-def':U
    {&cntxt-firm}
    par-host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }
if not g-log then  return .
define variable rr as recid no-undo .
  run str/fi-liabi.w ( parParentProc, {&add-def} , input-output rr , input par-host-code  , input p-doc-type, input p-status_).
  v-doc-rec = rr .
  run OpenBr in this-procedure (yes, no, '':U).
  reposition br-docs to recid v-doc-rec no-error .
  apply "VALUE-CHANGED" TO BR-docs IN FRAME Dialog-Frame.
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
  DISPLAY R-1 R-2 v-date-doc-1 v-date-pay-1 R-3 v-date-doc-2 v-date-pay-2
          sch-code p-desc p-date T-paket FILL-IN-20 FILL-IN-21 FILL-IN-22
          FILL-IN-24 FILL-IN-26 s-name FILL-IN-1 loc_receiver-name loc_sum-doc
          d-abbr loc_user-name loc_payer-name loc_sum-rubl r-abbr loc_sum-base
          v-abbr mark-num loc_sum-contr v-abbr-contr
      WITH FRAME Dialog-Frame.
  ENABLE B-exit RECT-1 B-sel B-close B-Export b-fact B-trn B-parts B-PFO B-Help
         B-sch B-History B-mark B-add B-lkp B-chg B-del b-exec-fo b-exec-pay
         B-print R-1 R-2 v-date-doc-1 v-date-pay-1 R-3 v-date-doc-2
         v-date-pay-2 B-reopen-br sch-code p-desc p-date BR-docs T-paket
         FILL-IN-20 FILL-IN-21 FILL-IN-22 FILL-IN-24 FILL-IN-26 s-name
         FILL-IN-1 loc_receiver-name loc_sum-doc d-abbr loc_user-name
         loc_payer-name loc_sum-rubl r-abbr loc_sum-base v-abbr mark-num
         loc_sum-contr v-abbr-contr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable_UI Dialog-Frame
PROCEDURE my-enable_UI :
{ gbl/basecode.i par-host-code p-base-code }
assign
loc_sum-rubl:label in frame {&frame-name} = "Сумма {&abbr_rub}."
.


DISPLAY sch-code p-desc   p-date mark-num FILL-IN-1 FILL-IN-20 FILL-IN-21 FILL-IN-22 FILL-IN-24
     FILL-IN-26

      WITH FRAME Dialog-Frame.
  ENABLE B-exit
         B-lkp
         B-add       when LOOKUP("b-add":U,  bttns) > 0
         B-chg       when LOOKUP("b-chg":U,  bttns) > 0
         /* b-exec-pay */
         b-exec-fo   when LOOKUP("b-exec-fo":U,  bttns) > 0
         B-Export
         B-close
         B-PFO       when LOOKUP("no-B-PFO":U,  bttns) = 0
         B-History
         b-trn
         b-parts
         B-sch
         B-print
         B-Help
         b-sel       when LOOKUP("b-sel":U,  bttns) > 0
         b-mark      when LOOKUP("b-mark":U, bttns) > 0
         b-del    
         b-fact
         BR-docs sch-code p-desc p-date  mark-num
         T-paket

      B-reopen-br R-1 R-2 r-3  v-date-doc-1 v-date-doc-2 v-date-pay-1 v-date-pay-2

      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.

  hide b-exec-pay  in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
define buffer buff_contract for ub.contract.
define variable loc_contract-code as character no-undo .


title0 = caps(p-file-label) + {&space-char}.

{&SetCursorWait}
define variable sort-column-phrase as character no-undo .

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

&scop flt-open-open-query OPEN QUERY br-docs FOR EACH buf_fin-liab no-lock

&scop flt-open-dyn_open-query  FOR EACH buf_fin-liab

&scop flt-open-query-handle query br-docs:handle

&scop flt-open-find-buffer-name buf_fin-liab

&scop flt-open-open-query-tail      , FIRST xx-contract

&scop flt-open-query-was-opened     l-query-was-opened

&scop flt-open-sort-column-phrase   sort-column-phrase

&scop flt-open-call-point           filter-point

&scop flt-open-set-filter-name      set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-query               p-open-query

&scop flt-open-table-name          buf_fin-liab

&scop flt-open-search-option       no-lock

&scop flt-open-find-next           p-find-next

&scop flt-open-find-recid          doc-rec

&scop flt-open-find-condition       p-find-condition

&scop flt-open-find-buffer-def      define buffer buf_fin-liab for fin-ob.

&scop flt-open-debug-file

&scop flt-open-waitfram             true

define variable l-open-query as logical   no-undo .
       find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = {&cmp} no-error .
       if not available buf_clients then return .
       filter-point = filter-point0 + par-mode.

  CASE par-mode :
    WHEN {&company} THEN DO:
       ASSIGN frame {&frame-name}:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + " код: " +  string(par-host-code).

&scop flt-open-open-query-tail      , FIRST xx-contract where ( r-2 = 1  or ( buf_fin-liab.contract-code = xx-contract.contract-code ))
&scop flt-open-dyn_open-query-tail  substitute(' , FIRST xx-contract where (  &1 = 1  or (  xx-contract.contract-code = buf_fin-liab.contract-code )) ' , r-2 )

  { gbl/fltopend.i
    &where-cond = " ~
    buf_fin-liab.host-code = par-host-code  and  ~
  ( r-1 = 1  or ( buf_fin-liab.receiver-code = hard-flt-cli-code and buf_fin-liab.receiver-type = hard-flt-cli-type )) and ~
  ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and ~
  ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and ~
  ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and ~
  ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 ))  ~
  "
    &dyn_where-cond = " ~
         substitute('  ~
         buf_fin-liab.host-code = &2  and  ~
         ( &3 = 1 or ( buf_fin-liab.receiver-code = &4 and buf_fin-liab.receiver-type = &1&5&1 )) and ~
         ( &6 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and ~
         ( &7 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and ~
         ' , ~{&double-quote~} , par-host-code , r-1 , hard-flt-cli-code , hard-flt-cli-type , r-31 ,r-32) + ~
         substitute('  ~
         ( &2 = 1  or ( &3 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= &4 )) and ~
         ( &5 = 1  or ( &6 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= &7 ))  ~
         ' , ~{&double-quote~} , d-1  , v-date-doc-1 , v-date-doc-2 , d-2 , v-date-pay-1 , v-date-pay-2 ) ~
         "
        &use-ind    = " "
        &by         = " " }
         /* USE-INDEX by_date*/
    END.

    WHEN "doc-type":U THEN DO:
       ASSIGN frame {&frame-name}:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + " код: " +  string(par-host-code)
                                          + " Тип: " +  p-doc-type-full .
&scop flt-open-open-query-tail      , FIRST xx-contract where ( r-2 = 1  or ( buf_fin-liab.contract-code = xx-contract.contract-code ))
&scop flt-open-dyn_open-query-tail  substitute(' , FIRST xx-contract where (  &1 = 1  or (  xx-contract.contract-code = buf_fin-liab.contract-code )) ' , r-2 )

{ gbl/fltopend.i
  &where-cond = " buf_fin-liab.host-code = par-host-code ~
  and buf_fin-liab.doc-type = p-doc-type and ~
  ( r-1 = 1  or ( buf_fin-liab.receiver-code = hard-flt-cli-code and buf_fin-liab.receiver-type = hard-flt-cli-type )) and ~
  ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and ~
  ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and ~
  ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and ~
  ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 )) ~
  "
    &dyn_where-cond = " ~
         substitute('  ~
         buf_fin-liab.host-code = &2  and  ~
         ( &3 = 1 or ( buf_fin-liab.receiver-code = &4 and buf_fin-liab.receiver-type = &1&5&1 )) and ~
         ( &6 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and ~
         ( &7 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and ~
         ' , ~{&double-quote~} , par-host-code , r-1 , hard-flt-cli-code , hard-flt-cli-type , r-31 , r-32 ) + ~
         substitute('  ~
         ( &2 = 1  or ( &3 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= &4 )) and ~
         ( &5 = 1  or ( &6 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= &7 ))  and ~
           buf_fin-liab.doc-type = &1&8&1 ~
         ' , ~{&double-quote~} , d-1  , v-date-doc-1 , v-date-doc-2 , d-2 , v-date-pay-1 , v-date-pay-2 , p-doc-type ) ~
         "

  &use-ind    = " "
  &by         = " " }

    END.

    WHEN "status":U THEN DO:
       ASSIGN frame {&frame-name}:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + " код: " +  string(par-host-code)
                                          + " Тип: "    +  p-doc-type-full
                                          + " Статус: " +  string(p-status_) .

&scop flt-open-open-query-tail      , FIRST xx-contract where ( r-2 = 1  or ( buf_fin-liab.contract-code = xx-contract.contract-code ))
&scop flt-open-dyn_open-query-tail  substitute(' , FIRST xx-contract where (  &1 = 1  or (  xx-contract.contract-code = buf_fin-liab.contract-code )) ' , r-2 )

{ gbl/fltopend.i
  &where-cond = " buf_fin-liab.host-code = par-host-code  and buf_fin-liab.doc-type = p-doc-type  and buf_fin-liab.status_= p-status_ and ~
  ( r-1 = 1  or ( buf_fin-liab.receiver-code = hard-flt-cli-code and buf_fin-liab.receiver-type = hard-flt-cli-type )) and ~
  ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and ~
  ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and ~
  ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and ~
  ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 )) ~
  "
    &dyn_where-cond = " ~
         substitute('  ~
         buf_fin-liab.host-code = &2  and  ~
         ( &3 = 1 or ( buf_fin-liab.receiver-code = &4 and buf_fin-liab.receiver-type = &1&5&1 )) and ~
         ( &6 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and ~
         ( &7 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and ~
         ' , ~{&double-quote~} , par-host-code , r-1 , hard-flt-cli-code , hard-flt-cli-type , r-31 , r-32 ) + ~
         substitute('  ~
         ( &2 = 1  or ( &3 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= &4 )) and ~
         ( &5 = 1  or ( &6 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= &7 )) and ~
           buf_fin-liab.doc-type = &1&8&1 and ~
           buf_fin-liab.status_  = &1&9&1 ~
         ' , ~{&double-quote~} , d-1  , v-date-doc-1 , v-date-doc-2 , d-2 , v-date-pay-1 , v-date-pay-2 , p-doc-type , p-status_ ) ~
         "

        &use-ind    = "  "
        &by         = "  " }
        /* USE-INDEX by_status*/
        /* ИЗМЕНИТЬ ИНДЕКС !!! */
    END.
    WHEN "contract":U THEN DO:
    hide r-1 r-2 s-tt FILL-IN-20  FILL-IN-21  in frame {&frame-name} .
    find first buff_contract no-lock where buff_contract.host-code     = par-host-code and
                                           buff_contract.contract-code = integer(p-char) no-error .

    if available buff_contract then
       loc_contract-code        =  buff_contract.contract-prn-code .
       else loc_contract-code   = "".

       ASSIGN frame {&frame-name}:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + " код: " +  string(par-host-code)
                                                 + " Договор: " + loc_contract-code     + " ( вн.№ " + string(p-char) +  " )" .

&scop flt-open-open-query-tail      , FIRST xx-contract
&scop flt-open-dyn_open-query-tail  substitute(' , FIRST xx-contract ' )

      { gbl/fltopend.i
        &where-cond = " buf_fin-liab.host-code = par-host-code  and buf_fin-liab.contract-code = integer(p-char) and ~
  ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and ~
  ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and ~
  ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and ~
  ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 )) ~
   "
    &dyn_where-cond = " ~
         substitute('  ~
         buf_fin-liab.host-code = &2  and  ~
         ( &3 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and ~
         ( &4 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and ~
         ( &5 = 1 or ( &6 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= &7 )) and ~
         ( &8 = 1 or ( &9 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= &1 )) and ~
         ' , v-date-pay-2 , par-host-code , r-31 , r-32  , d-1  , v-date-doc-1 , v-date-doc-2 , d-2 , v-date-pay-1  ) + ~
         substitute(' buf_fin-liab.contract-code = integer(&1)  ' , p-char)   "

        &use-ind    = "  "
        &by         = "  " }
        /* USE-INDEX cont */

        /* ИЗМЕНИТЬ ИНДЕКС !!! */
    END.



END CASE.

if not p-open-query then
reposition br-docs to recid doc-rec no-error.

if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) no-error.

{&SetCursorNo}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-proc Dialog-Frame
PROCEDURE print-proc :
{ gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-liability_print':U
    {&cntxt-firm}
    par-host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }
if not g-log then  return .
define variable v-kol   as integer   no-undo .
define variable v-i-sum as decimal   no-undo .
define variable v-d as decimal   no-undo .
v-kol   = 0 .
v-i-sum = 0 .
v-d = 0 .

 EMPTY TEMP-TABLE tt-val .

define variable sym1  as char format "X(1)" init ":".
define variable sym2  as char format "X(1)" init ":".
define variable sym3  as char format "X(1)" init ":".
define variable sym4  as char format "X(1)" init ":".
define variable sym5  as char format "X(1)" init ":".
define variable sym6  as char format "X(1)" init ":".
define variable sym7  as char format "X(1)" init ":".
define variable sym8  as char format "X(1)" init ":".
define variable sym9  as char format "X(1)" init ":".
define variable sym10 as char format "X(1)" init ":".
define variable sym11 as char format "X(1)" init ":".
define variable sym12 as char format "X(1)" init ":".

define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable vv-val as character no-undo .
define variable v-i as integer   no-undo .
define variable p-delta as decimal format "->,>>>,>>>,>>>,>>9.99"  no-undo .

DEFINE FRAME prt-frame
     {&cop-l1}    COLUMN-LABEL {&col-l1}        Format "x(6)"
     {&cop-l2}    COLUMN-LABEL {&col-l2}        Format "x(10)"
     {&cop-l300}    COLUMN-LABEL {&col-l3}      format "99/99/99"
     {&cop-l4}    COLUMN-LABEL {&col-l4}        format "99/99/99"
     p-contr   COLUMN-LABEL {&col-l5}           Format "x(16)"
     {&cop-l600}    COLUMN-LABEL {&col-l6}      Format "x(10)"
     {&cop-l700}    COLUMN-LABEL {&col-l7}      Format "x(10)"
     {&cop-l8}   COLUMN-LABEL {&col-l8}         format "99/99/99"
     l-curr COLUMN-LABEL {&col-l9}              Format "x(3)"
     {&cop-l10}   COLUMN-LABEL "Сумма в вал.док"
     p-delta   COLUMN-LABEL "Задолженность в вал.док"   format "->,>>>,>>>,>>>,>>9.99"
     p-gen   COLUMN-LABEL {&col-l17}           Format "x(25)"
        HEADER  date_string AT 5 format "X(35)"
                    string( "Страница " ) format "X(9)" AT 50 PAGE-NUMBER( PrnLibStream) AT 70 FORMAT ">>>>9" SKIP
                    Line format "X(157)" AT 1
    with width {&DOS_CW_2} down stream-io use-text    .

    Line = fill("-", 157).
    date_string = cur-time-print() .
    run prn-lib-open-stream in this-procedure
    (  input parParentProc
      ,input {&LS_PS_A4}
      ,input yes /*p-is-stream*/
      ,input no /*p-append*/
      ).
    PUT  STREAM PrnLibStream
    SPACE(25) ( frame {&frame-name}:title )
    format "x(157)" SKIP(1) .
    FORM HEADER
            Line format "X(177)" AT 1 SKIP
            "Продолжение - на следующей странице" AT 30 SKIP
            with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW  STREAM PrnLibStream FRAME BottomFrame .

    FORM with FRAME prt-frame  .
    run waitfram-show in this-procedure ("Ждите печатаю...").

    run OpenBR in this-procedure (yes, no, '':U).
     DO WHILE available buf_fin-liab :
       v-kol    = v-kol   + 1 .
       v-i-sum = v-i-sum + {&cop-l10} .
       v-d =  (buf_fin-liab.sum-DOC - buf_fin-liab.con-sum-DOC) .
       vv-val = {&cop-l9} .

       find first tt-val where
                  tt-val.val = vv-val no-error .
        if not available tt-val then create tt-val.
            assign
              tt-val.val = vv-val
              tt-val.s1  = tt-val.s1  + {&cop-l10}
              tt-val.s2  = tt-val.s2  + (buf_fin-liab.sum-DOC - buf_fin-liab.con-sum-DOC)
              tt-val.kol = tt-val.kol + 1
            .
        Display STREAM PrnLibStream
              {&cop-l1}
              {&cop-l2}
              {&cop-l300}
              {&cop-l4}
              {&cop-l5}   @ p-contr
              {&cop-l600}
              {&cop-l700}
              {&cop-l8}
              {&cop-l9}  @ l-curr
              {&cop-l10}
              v-d @ p-delta
              {&cop-l17} @ p-gen
            with FRAME prt-frame .
            DOWN STREAM PrnLibStream 1 with FRAME prt-frame  .
            GET next br-docs.
      END.
      UNDERLINE  STREAM PrnLibStream
        {&cop-l1}
        {&cop-l2}
        {&cop-l300}
        {&cop-l4}
        p-contr
        {&cop-l600}
        {&cop-l700}
        {&cop-l8}
        l-curr
        {&cop-l10}
        p-delta
        p-gen
    with FRAME prt-frame .

    v-i = 0 .
    for each tt-val :
        v-i = v-i + 1.
    end.

    if v-i > 1 then do:
        Display STREAM PrnLibStream
        "Итого"    @  {&cop-l1}
        "док.шт."  @  {&cop-l2}
         v-kol     @  {&cop-l300}

        with FRAME prt-frame .
    end.
        DOWN STREAM PrnLibStream 1 with FRAME prt-frame  .
        for each tt-val :
            Display STREAM PrnLibStream
            "Итого "       @ {&cop-l1}

             tt-val.val    @ {&cop-l2}
             tt-val.kol     @  {&cop-l300}
                tt-val.s1  @ {&cop-l10}
                tt-val.s2  @ p-delta
            with FRAME prt-frame .
        DOWN STREAM PrnLibStream 1 with FRAME prt-frame  .

        end.
      UNDERLINE  STREAM PrnLibStream
        {&cop-l1}
        {&cop-l2}
        {&cop-l300}
        {&cop-l4}
        p-contr
        {&cop-l600}
        {&cop-l700}
        {&cop-l8}
        l-curr
        {&cop-l10}
        p-delta
        p-gen
    with FRAME prt-frame .

    HIDE  STREAM PrnLibStream FRAME BottomFrame .
    HIDE  STREAM PrnLibStream FRAME CheckList.
    output  STREAM PrnLibStream CLOSE.
    run waitfram-hide in this-procedure .
    run prn-lib-prn-file in this-procedure (
        input parParentProc
       ,input 8
        ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-exp Dialog-Frame
PROCEDURE proc-b-exp :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable varxmldocfl      as character no-undo.
define variable varxmldocfl-type as character no-undo.
define variable v-file-name as character no-undo .
define variable for-dir as character no-undo .
define variable accum-count as integer no-undo init 0.
define variable accum-count-ok as integer no-undo init 0 .
define variable loclog as logical no-undo .
define variable ii as integer no-undo .
define variable ii0 as integer no-undo .

define buffer buf_fin-ob for ub.fin-ob.


if not available buf_fin-liab then do:
  message "Неправильный выбор документа.".
  return no-apply.
end.

CASE T-paket:
  when no then do:
    assign
    v-file-name =  ?
    .
    run bge/xmlfo.p ( input buf_fin-liab.host-code, buf_fin-liab.doc-code, input-output v-file-name, yes, yes) no-error .

  end.

  when  yes then do:
    if rid-list = "":U then do:
        message
        "Вы не отметили ни одного ФО"
        view-as alert-box error.
        return error.
    end.

    run gbl/d-file.p
      (input-output v-file-name             /* p-file-id           */
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
    run waitfram-show in this-procedure ("Ждите...").
    assign
     ii0 = num-entries(rid-list)
    .

    repeat  ii = 1 to ii0 :
      find first buf_fin-ob no-lock where
                recid(buf_fin-ob) = integer(entry(ii, rid-list)) no-error .
      if available buf_fin-ob then do:
        assign
          accum-count = accum-count + 1
        .
        /* message
          (accum-count-ok = 0)
          ii = ii0
        .  */
        run bge/xmlfo.p
        (               input buf_fin-ob.host-code
                      , input buf_fin-ob.doc-code
                      , input-output v-file-name
                      , input (accum-count-ok = 0)
                      , input ii = ii0
                      ) no-error .
        if not error-status:error then
        assign
          accum-count-ok = accum-count-ok + 1
        .
      end.
    run waitfram-hide in this-procedure .
  end.
end.
END CASE.

if error-status:error
or (t-paket and accum-count <> accum-count-ok)
then do:
  message
  "Ошибка при выгрузке ФО в XML-формате" skip
  string(if t-paket then substitute("Выгружено &1 ФО из &2", accum-count-ok, accum-count) else "":U) skip
  error-status :get-message(1)
  view-as alert-box .
  if not t-paket then
  return error .
end.

define variable v-sys-key as character no-undo.
{ gbl/currsysk.i
  v-sys-key
  no-error
}

if search ("exmldoc.bat") <> ? then do:
  os-command silent value(search ("exmldoc.bat") + " " + v-file-name + " " + v-sys-key).
end.
else do:
  if search (v-file-name ) <> ? then do:
    if accum-count-ok  > 1 then
       message "ФО выгружены в файл " v-file-name view-as alert-box.
    else
      message "ФО выгружен в файл " v-file-name view-as alert-box.
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
assign
  tbl = 'fin-ob'
  join-tbl = 'buf_fin-liab'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure ('doc-code', 'Внутр.№', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('contract-code', 'Внутр.№ договора', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('prn-doc-code', '№ документа ', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('status_', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('host-code', 'Код фирмы', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('curr-code', 'Код валюты', 'curr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('corr-doc', 'Корр ФО', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('doc-date', 'Создан(дата)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('fact-date', 'Закрыт(дата)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('pay-date', 'Дата Платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('user-name-doc', 'Кто создал', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('user-name-fact', 'Кто закрыл на факт', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('payer-type{&delim-flt}payer-code', 'Плательщик', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('receiver-type{&delim-flt}receiver-code', 'Получатель', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  run OpenBr in this-procedure (yes, no, '':U).
END. /* Filter-Block */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-close Dialog-Frame
PROCEDURE proc-close :
define variable rr as recid no-undo .
define variable ii as integer no-undo .
define variable g-ok as logical no-undo .
define variable v-recid  as recid no-undo .

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-liability_close-fact':U
    {&cntxt-firm}
    par-host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }
if not g-log then  return .

{&SetCursorWait}
  if t-paket then do:
   {&ver-poket}
    define variable v-4 as integer   no-undo .
    v-4 = num-entries(rid-list) .
    repeat ii = 1 to v-4 :
      v-recid = integer(entry(ii, rid-list)).
      run proc-close-one-fin-ob in this-procedure ( input v-recid ) .
    end.
  end.
  else do:
    find current   buf_fin-liab no-lock no-error .
    v-recid = recid( buf_fin-liab ).
    run proc-close-one-fin-ob in this-procedure ( input v-recid ) .
  end.
  run OpenBr in this-procedure (yes, no, '':U) .
  reposition br-docs  TO RECID v-recid NO-ERROR .
  if error-status :error then  reposition br-docs  TO row 1 NO-ERROR .
  apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.


END PROCEDURE.


PROCEDURE proc-open :
define variable rr as recid no-undo .
define variable ii as integer no-undo .
define variable v-recid  as recid no-undo .

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-liability_close-fact':U
    {&cntxt-firm}
    par-host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }
if not g-log then  return .

  if t-paket then do:
  {&ver-poket}
    define variable v-6 as integer   no-undo .
    v-6 = num-entries(rid-list).
    repeat ii = 1 to v-6 :
      v-recid = integer(entry(ii, rid-list)).
      run proc-open-one in this-procedure ( input v-recid ) .
    end.
  end.
  else do:
    find current   buf_fin-liab no-lock no-error .
    v-recid = recid( buf_fin-liab ).
    run proc-open-one in this-procedure ( input v-recid ) .
  end.
  run OpenBr in this-procedure (yes, no, '':U) .
  reposition br-docs  TO RECID v-recid NO-ERROR .
  apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
END PROCEDURE.

PROCEDURE proc-open-one :
define input parameter p-recid  as recid no-undo .

find first  buf_fin-liab exclusive-lock  where recid(buf_fin-liab) = p-recid  no-error .
if available buf_fin-liab then do:
    if buf_fin-liab.status_ = {&fin-new} then do:
      message "Финансовое обязательство " buf_fin-liab.prn-doc-code " находится в статусе НОВЫЙ".
      return.
    end.
   buf_fin-liab.status_ = {&fin-new} .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-copy Dialog-Frame
PROCEDURE proc-copy :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable p-doc-code          as integer no-undo.
define variable p-out-host-code     like ub.sysconf.host-code       no-undo.
define variable p-ok                as logical no-undo.
define variable j                   as integer no-undo.
define variable k                   as integer no-undo.
define variable p-ret               as logical no-undo.
define variable p-doc-date          like ub.fin-ob.doc-date         no-undo.
define variable p-payer-name        like ub.fin-ob.payer-name       no-undo.
define variable p-receiver-name     like ub.fin-ob.receiver-name    no-undo.
define variable p-curr-code         like ub.fin-ob.curr-code        no-undo.
define variable p-sum-doc           like ub.fin-ob.sum-doc          no-undo.
define variable p-user-db-num-doc   like ub.fin-ob.user-db-num-doc  no-undo.
define variable p-user-name-doc     like ub.fin-ob.user-name-doc    no-undo.
define variable p-base-rate         like ub.fin-ob.base-rate        no-undo.
define variable p-base-scale        like ub.fin-ob.base-scale       no-undo.
define variable p-receiver-code     like ub.fin-ob.receiver-code    no-undo.
define variable p-receiver-type     like ub.fin-ob.receiver-type    no-undo.
define variable p-contract-code     like ub.fin-ob.contract-code    no-undo.
define variable p-exch-rate         like ub.fin-ob.exch-rate        no-undo.
define variable p-exch-scale        like ub.fin-ob.exch-scale       no-undo.
define variable p-fact-date         like ub.fin-ob.fact-date        no-undo.
define variable p-fact-order        like ub.fin-ob.fact-order       no-undo.
define variable p-host-code         like ub.fin-ob.host-code        no-undo.
define variable p-payer-code        like ub.fin-ob.payer-code       no-undo.
define variable p-payer-type        like ub.fin-ob.payer-type       no-undo.
define variable p-pay-date          like ub.fin-ob.pay-date         no-undo.
define variable p-prn-doc-code      like ub.fin-ob.prn-doc-code     no-undo.
define variable p-sum-base-orig     like ub.fin-ob.sum-base-orig    no-undo.
define variable p-sum-base          like ub.fin-ob.sum-base         no-undo.
define variable p-sum-doc-orig      like ub.fin-ob.sum-doc-orig     no-undo.
define variable p-sum-rubl-orig     like ub.fin-ob.sum-rubl-orig    no-undo.
define variable p-sum-rubl          like ub.fin-ob.sum-rubl         no-undo.
define variable p-trn-doc-code      like ub.fin-ob.trn-doc-code     no-undo.
define variable p-user-db-num-fact  like ub.fin-ob.user-db-num-fact no-undo.
define variable p-user-db-num-pay   like ub.fin-ob.user-db-num-pay  no-undo.
define variable p-user-name-fact    like ub.fin-ob.user-name-fact   no-undo.
define variable p-user-name-pay     like ub.fin-ob.user-name-pay    no-undo.
define variable p-ri                as recid no-undo.

define buffer buf2_fin-liab for ub.fin-ob.

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-liability_export':U
    {&cntxt-firm}
    par-host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }
if not g-log then  return .
if not g-log then  return .
if num-entries(rid-list) = 0 then do:
   message "Не отмечены записи для копирования !!!" .
   return .
end.



  define variable v-user-select as logical   no-undo .
  { gbl/uhstsman.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-cntxt-host-code-obj
    v-user-select
  }
  if v-user-select <> true
  then do:
    return no-apply .
  end.

  define variable v-total-select as integer   no-undo .

  run userhsts_object-count in this-procedure
    (output v-total-select
    ) .

  if v-total-select  = 0
  then do:
    message "Не выбрана фирма для копирования !!!" .
    return .
  end.

  message
    "Отмечено фирм:" v-total-select skip
    "Скопировать выбранные значения справочника в эти фирмы ?"
    view-as alert-box question
    buttons yes-no
    update p-ok.

  k = 0.
  if p-ok = false then return.
  define variable v-8 as integer   no-undo .
  v-8 = num-entries(rid-list) .

    define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .
    for each buf_userhsts_temp-user-host
    :
        /* список recid справочника */
        repeat j = 1 to v-8
        :
          for each buf2_fin-liab where recid(buf2_fin-liab) =  integer(entry(j,rid-list)):
          if not can-find ( first buf_fin-liab no-lock where
                              buf_fin-liab.host-code      = buf_userhsts_temp-user-host.host-code and
                              buf_fin-liab.doc-code       = buf2_fin-liab.doc-code) then do:

                  /* Проверка на то что выбранная фирма с текущей БД */
                  run current-db  in this-procedure
                  (   input buf_fin-liab.host-code,
                      input par-host-code,
                      output p-ret ) .
                  if p-ret = no then next.
                  run fin-ob-code     in this-procedure (input g#db-num , output p-doc-code ).
                  run create-fin-liab in this-procedure
                  (   input yes ,
                      input  p-doc-code            ,
                      input  today            ,
                      input  buf2_fin-liab.doc-type            ,
                      input  buf2_fin-liab.payer-name            ,
                      input  buf2_fin-liab.receiver-name            ,
                      input  buf2_fin-liab.curr-code           ,
                      input  buf2_fin-liab.sum-doc             ,
                      input  buf2_fin-liab.user-db-num-doc     ,
                      input  buf2_fin-liab.user-name-doc       ,
                      input  buf2_fin-liab.base-rate           ,
                      input  buf2_fin-liab.base-scale          ,
                      input  buf2_fin-liab.receiver-code       ,
                      input  buf2_fin-liab.receiver-type       ,
                      input  buf2_fin-liab.contract-code       ,
                      input  buf2_fin-liab.exch-rate           ,
                      input  buf2_fin-liab.exch-scale          ,
                      input  buf2_fin-liab.contract-curr       ,
                      input  buf2_fin-liab.contract-rate       ,
                      input  buf2_fin-liab.contract-scale      ,
                      input  buf2_fin-liab.fact-date           ,
                      input  buf2_fin-liab.fact-order          ,
                      input  par-host-code           ,
                      input  buf2_fin-liab.payer-code          ,
                      input  buf2_fin-liab.payer-type          ,
                      input  buf2_fin-liab.pay-date            ,
                      input  buf2_fin-liab.prn-doc-code        ,
                      input  {&fin-new}          ,
                      input  buf2_fin-liab.sum-base-orig       ,
                      input  buf2_fin-liab.sum-base            ,
                      input  buf2_fin-liab.sum-doc-orig        ,
                      input  buf2_fin-liab.sum-rubl-orig       ,
                      input  buf2_fin-liab.sum-rubl            ,
                      input  buf2_fin-liab.sum-contract        ,
                      input  buf2_fin-liab.trn-doc-code        ,
                      input  buf2_fin-liab.user-db-num-fact    ,
                      input  buf2_fin-liab.user-db-num-pay        ,
                      input  buf2_fin-liab.user-name-fact         ,
                      input  buf2_fin-liab.user-name-pay          ,
                      input  buf2_fin-liab.in-type                ,
                      input  buf2_fin-liab.sum-tax-base           ,
                      input  buf2_fin-liab.sum-tax-doc            ,
                      input  buf2_fin-liab.sum-tax-rubl           ,
                      input  buf2_fin-liab.sum-tax-contract       ,
                      input  ""                       ,
                      output p-ri ).
                      k = k + 1.
                  end.
          end.
        end.
     end.

message "Скопировано " k  "обязательств" view-as alert-box .

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
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as char no-undo.
display "" @ p-desc with frame {&frame-name}.
display "" @ p-date with frame {&frame-name}.
  doc-rec = ? .
  find first  buf_fin-liab no-lock where  buf_fin-liab.prn-doc-code = pardoc-code no-error  .
  if available buf_fin-liab then doc-rec = recid(buf_fin-liab) .
  reposition {&browse-name} to recid doc-rec no-error .

  if not error-status :error then apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
  else do:
       message " Запись не найдена " view-as alert-box information .
  end.



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
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as date no-undo.
define variable ppp as character no-undo .

display "" @ p-desc with frame {&frame-name}.
display "" @ sch-code with frame {&frame-name}.
  doc-rec = ? .
  if par-next = true then find next buf_fin-liab no-lock where  buf_fin-liab.doc-date = pardoc-code no-error  .
  else  find first  buf_fin-liab no-lock where  buf_fin-liab.doc-date = pardoc-code no-error  .
  if available buf_fin-liab then doc-rec = recid(buf_fin-liab) .
  reposition {&browse-name} to recid doc-rec no-error .

  if not error-status :error then apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
  else do:
       message " Запись не найдена " view-as alert-box information .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-desc Dialog-Frame
PROCEDURE proc-find-desc :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as char no-undo.
define variable pp as integer no-undo.
define buffer b_contract for ub.contract.
display "" @ sch-code with frame {&frame-name}.
display "" @ p-date with frame {&frame-name}.
if  par-next = true then
    find next b_contract no-lock where b_contract.host-code = par-host-code and b_contract.contract-prn-code = pardoc-code use-index num no-error .
else
  find first b_contract no-lock where b_contract.host-code = par-host-code and b_contract.contract-prn-code = pardoc-code  use-index num no-error .

if available b_contract
then do:
  doc-rec = ? .
  if par-next = true then find next buf_fin-liab no-lock where  buf_fin-liab.contract-code = b_contract.contract-code no-error  .
  else  find first  buf_fin-liab no-lock where  buf_fin-liab.contract-code = b_contract.contract-code no-error  .
  if available buf_fin-liab then doc-rec = recid(buf_fin-liab) .
  reposition {&browse-name} to recid doc-rec no-error .

  if not error-status :error then apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
  else do:
       message " Запись не найдена " view-as alert-box information .
  end.
end.
else do:
  message "Договор с таким номером не найден !!!" .
  apply "entry":u to p-desc in frame {&frame-name} .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-m_gen-1 Dialog-Frame
PROCEDURE proc-m_gen-1 :
define buffer bf_fin-ob for ub.fin-ob.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
define variable varlog as logical   no-undo .
define variable v-list as character no-undo .
define variable v-9 as integer   no-undo .

do on error undo, return error return-value :

  if num-entries(rid-list) = 0 then do:
    message "Не выделено ни одного ФО для генерации счета-фактуры !".
    return .
  end.

    varlog = yes.
    message "Выбрано " + string( num-entries( rid-list)  ) +  " ФО . Провести генерацию счетов-фактур?" skip
            view-as alert-box question buttons OK-Cancel update varlog.
    if not varlog then return.

    v-9 = num-entries (rid-list).
    do vari = 1 to v-9 :
        assign vardoc-code = integer(entry (vari, rid-list)).
        find first bf_fin-ob where recid(bf_fin-ob) = vardoc-code no-lock no-error .
        if not available bf_fin-ob then next.

        if bf_fin-ob.status_ <> {&fin-fact} then do:
          message "Документ " bf_fin-ob.prn-doc-code " статус " bf_fin-ob.status_ " не в статусе " {&fin-fact} " . Пропускаем." view-as alert-box.
          next .
        end.

        if bf_fin-ob.cr-factur = yes then do:
          message "По документу " bf_fin-ob.doc-code " уже создавался счет-фактура от " bf_fin-ob.factur-date " числа." view-as alert-box.
        end.
        else do:
          run str/gen-scf.p ( input parParentProc, input vardoc-code, "fin-ob", output v-list) no-error .
          if error-status:error then  return error substitute(" Ошибка создания счета-фактуры по ФО &1 &2 &3" ,bf_fin-ob.prn-doc-code, return-value , error-status :get-message(1)) .
        end.
    end.

    assign rid-list = "" .
    run OpenBr in this-procedure (yes, no, '':U) .
  end. /* do */
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-m_gen-2 Dialog-Frame
PROCEDURE proc-m_gen-2 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_fin-ob for ub.fin-ob.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.

do on error undo, return error return-value
:
define variable v-10 as integer   no-undo .
v-10 = num-entries (rid-list) .
    if rid-list = "" then do:
      if available buf_fin-liab then assign rid-list = string(recid(buf_fin-liab)).
    end.
vari-cycle:
  do vari = 1 to v-10 :
    assign vardoc-code = integer(entry (vari, rid-list)).
    find first bf_fin-ob where recid(bf_fin-ob) = vardoc-code exclusive-lock.
    if bf_fin-ob.status_ <> {&fin-fact} then do:
      message "Документ " bf_fin-ob.status_ " не в статусе " {&fin-fact} " . Пропускаем." view-as alert-box.
      next vari-cycle.
    end.
    find first bf_sysconf where bf_sysconf.host-code = bf_fin-ob.host-code no-lock.
    if bf_fin-ob.user-db-num-doc <> g#db-num then do:
      message "БД документа с кодом " bf_fin-ob.doc-code " не coвпадает с текущей БД." skip
              "Текущая БД: " v-cntxt-db-num skip "БД док-та: " bf_fin-ob.user-db-num-doc  " . Пропускаем."
      view-as alert-box error.
      next vari-cycle.
    end.
    if bf_fin-ob.cr-factur = yes then do:
      message "По документу " bf_fin-ob.doc-code " уже создавался счет-фактура от " bf_fin-ob.factur-date " числа." view-as alert-box.
      next vari-cycle.
    end.
    else do:
      if bf_fin-ob.need-factur = 1 or bf_fin-ob.need-factur = 2 then assign  bf_fin-ob.need-factur = 0.
      else do:
        message "Данный документ не нуждался в генерации счета-фактуры." view-as alert-box.
        next vari-cycle.
      end.
      reposition {&browse-name} to recid recid(bf_fin-ob) no-error.
      if not error-status:error then do:
        display f-factur (recid( bf_fin-ob)) @ varfactur with browse {&browse-name}.
      end.
    end.
  end.
  assign rid-list = "".
end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-m_gen-3 Dialog-Frame
PROCEDURE proc-m_gen-3 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_fin-ob for ub.fin-ob.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
define variable varlog as logical   no-undo .

do on error undo, return error return-value
:
  if rid-list = "" then do:
    if available buf_fin-liab then assign rid-list = string(recid(buf_fin-liab)).
  end.
define variable v-11 as integer   no-undo .
v-11 = num-entries (rid-list) .
vari-cycle:
  do vari = 1 to v-11 :
    assign vardoc-code = integer(entry (vari, rid-list)).
    find first bf_fin-ob where recid(bf_fin-ob) = vardoc-code exclusive-lock.
    find first bf_sysconf where bf_sysconf.host-code = bf_fin-ob.host-code no-lock.
    if bf_fin-ob.status_ <> {&fin-fact} then do:
      message "Документ " bf_fin-ob.status_ " не в статусе " {&fin-fact} " . Пропускаем." view-as alert-box.
      next vari-cycle.
    end.
    if bf_fin-ob.user-db-num-doc <> g#db-num then do:
      message "БД документа с кодом " bf_fin-ob.doc-code " не coвпадает с текущей БД." skip
              "Текущая БД: " v-cntxt-db-num skip "БД док-та: " bf_fin-ob.user-db-num-doc  " . Пропускаем."
      view-as alert-box error.
      next vari-cycle.
    end.
    if bf_fin-ob.cr-factur = yes then do:
      assign
        varlog = no.
        message "По документу " bf_fin-ob.doc-code " был создан счет-фактура от " bf_fin-ob.factur-date " ." skip
                "Вы действительно хотите снять признак, чтобы по этому документу был счет-фактура?"
        view-as alert-box question buttons yes-no update varlog.
       if varlog <> yes then  next vari-cycle.
       assign
         bf_fin-ob.cr-factur   = no
         bf_fin-ob.factur-date = 01/01/1990
       .
       reposition {&browse-name} to recid recid(bf_fin-ob) no-error.
      if not error-status:error then do:
        display f-factur (recid( bf_fin-ob)) @ varfactur with browse {&browse-name}.
      end.
    end.
    else do:
      message "По документу " bf_fin-ob.doc-code " не было генерации."
      view-as alert-box.
   end.
 end.
 assign rid-list = "".
end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-m_gen-4 Dialog-Frame
PROCEDURE proc-m_gen-4 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_fin-ob for ub.fin-ob.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
define variable varneed-factur as logical no-undo.
define buffer bf_contract for ub.contract.

do on error undo, return error return-value
:
  if rid-list = "" then do:
    if available buf_fin-liab then assign rid-list = string(recid(buf_fin-liab)).
  end.
define variable v-12 as integer   no-undo .
v-12 = num-entries (rid-list).

vari-cycle:
  do vari = 1 to v-12:
    assign vardoc-code = integer(entry (vari, rid-list)) .
    find first bf_fin-ob where recid(bf_fin-ob) = vardoc-code exclusive-lock.
    find first bf_sysconf where bf_sysconf.host-code = bf_fin-ob.host-code no-lock.
    if bf_fin-ob.status_ <> {&fin-fact} then do:
      message "Документ " bf_fin-ob.status_ " не в статусе " {&fin-fact} " . Пропускаем."  view-as alert-box.
      next.
    end.
    if bf_fin-ob.user-db-num-doc <> g#db-num then do:
      message "БД документа с кодом " bf_fin-ob.doc-code " не coвпадает с текущей БД." skip
              "Текущая БД: " v-cntxt-db-num skip "БД док-та: " bf_fin-ob.user-db-num-doc  " . Пропускаем."
      view-as alert-box error.
      return error.
    end.
    if bf_fin-ob.need-factur = 2 then do:
      if bf_fin-ob.contract-code <> 0 then do:
        find first bf_contract where bf_contract.host-code     = bf_fin-ob.host-code   and
                                     bf_contract.contract-code = bf_fin-ob.contract-code no-lock no-error.
        if available bf_contract then do:
          if bf_contract.gen-factur = 2 or bf_contract.gen-factur = 12 or bf_contract.gen-factur = 102 or bf_contract.gen-factur = 112 then do:
            assign bf_fin-ob.need-factur = 1  .
            reposition {&browse-name} to recid recid(bf_fin-ob) no-error.
            if not error-status:error then display f-factur (recid( bf_fin-ob)) @ varfactur with browse {&browse-name}.
          end.
          else message "По документу " bf_fin-ob.doc-code " нет договоров для генерации счета-фактуры."  view-as alert-box.
        end.
      end.
    end.
    else do:
      message "Документ " bf_fin-ob.doc-code "не имеет признака 'не опред' генерация счета-фактуры."
      view-as alert-box.
      next vari-cycle.
    end.
  end.
  assign rid-list = "" .
end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-filter-name Dialog-Frame
PROCEDURE set-filter-name :
define input parameter p-filter-name as character no-undo .

  do with frame {&frame-name}:
    if p-filter-name > "" then do:
      assign
        frame {&frame-name}:title
          = frame {&frame-name}:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :TOOLTIP = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :TOOLTIP = ""
      .
    end.

  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-selection Dialog-Frame
PROCEDURE set-selection :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer buf_clients for ub.clients  .
assign frame {&frame-name}
  r-1
  r-2
  r-3
  v-date-doc-1
  v-date-doc-2
  v-date-pay-1
  v-date-pay-2
  .

/* даты */
if v-date-doc-1 = ? and v-date-doc-2 = ? then d-1 = 1 .
                                         else d-1 = 2 .
if v-date-pay-1 = ? and v-date-pay-2 = ? then d-2 = 1 .
                                         else d-2 = 2 .

if v-date-doc-1 = ? then v-date-doc-1 = 01/01/91 .
if v-date-pay-1 = ? then v-date-pay-1 = 01/01/91 .

if v-date-doc-2 = ? then v-date-doc-2 = today + 3 .
if v-date-pay-2 = ? then v-date-pay-2 = today + 3 .


if d-1 = 2 then do:
  if v-date-doc-1 > v-date-doc-2 then do: message "Не верно задан интервал дат создания ФО ! " view-as alert-box error .
  return error return-value .
  end.
end.

if d-2 = 2 then do:
  if v-date-pay-1 > v-date-pay-2 then do: message "Не верно задан интервал дат платежа ! " view-as alert-box error .
  return error return-value .
  end.
end.

/* контрагенты */
if r-1 = 2 then do:
      find first buf_clients no-lock where
                  buf_clients.obj-code = hard-flt-cli-code  and
                  buf_clients.obj-type = hard-flt-cli-type  no-error .
                  if error-status :error then r-1 = 1 .
end.

/* договоры */
if r-2 = 2 then do:
      find first x-contract no-lock  no-error .
      if error-status :error then r-2 = 1 .
end.

case r-3 :
  when 1 then do: /* все */
     r-31 = 1.
     r-32 = 1.
  end.
  when 2 then do: /* есть непогаш.задолженность  */
     r-31 = 2.
     r-32 = 1.
  end.
  when 3 then do: /* нет непогаш.задолженности  */
     r-31 = 1.
     r-32 = 2.
  end.
end case.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION contract-gen Dialog-Frame
FUNCTION contract-gen RETURNS CHARACTER
( input p-rec as recid ) :
define BUFFER loc-fin-liab FOR ub.fin-ob.
find first loc-fin-liab no-lock where recid (loc-fin-liab) = p-rec no-error.
if error-status :error then return ''.

  define variable rr as character no-undo .
  define buffer buf-f_contract for ub.contract.

  find first buf-f_contract no-lock where  buf-f_contract.host-code      = par-host-code  and
                                          buf-f_contract.contract-code  = loc-fin-liab.contract-code  no-error.

  if available buf-f_contract then   rr = buf-f_contract.usl-opl .
     else rr = "".
  RETURN rr.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION contract-id Dialog-Frame
FUNCTION contract-id RETURNS CHARACTER
( input p-rec as recid ) :
define  BUFFER loc-fin-liab FOR ub.fin-ob.
find first loc-fin-liab no-lock where recid (loc-fin-liab) = p-rec no-error .
if error-status :error then return '' .

  define variable rr as character no-undo .
  define buffer buf-f_contract for ub.contract.


  find first buf-f_contract no-lock where  buf-f_contract.host-code      = par-host-code  and
                                          buf-f_contract.contract-code  = loc-fin-liab.contract-code  no-error.

  if available buf-f_contract then   rr = buf-f_contract.contract-prn-code.
     else rr = "".
  RETURN rr.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION debts Dialog-Frame
FUNCTION debts RETURNS DECIMAL
( input p-rec as recid ) :
define  BUFFER buf_fin-liab FOR ub.fin-ob .
find first  buf_fin-liab no-lock where recid (buf_fin-liab) = p-rec no-error .
if error-status :error then return ? .

  RETURN buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl .
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION f-factur Dialog-Frame
FUNCTION f-factur RETURNS CHARACTER
( input p-rec as recid ) :
define buffer loc-t-doc for ub.fin-ob .
find first loc-t-doc no-lock where recid (loc-t-doc) = p-rec no-error .
if error-status :error then return '' .

 if loc-t-doc.cr-factur = yes then do:
   return string (loc-t-doc.factur-date, "99/99/99").
 end.
 else do:
   if loc-t-doc.need-factur = 0 then do:
     return "--------".
   end.
   if loc-t-doc.need-factur = 1 then do:
     return " ".
   end.
   if loc-t-doc.need-factur = 2 then do:
     return "не опред".
   end.
 end.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION sel-abbr Dialog-Frame
FUNCTION sel-abbr RETURNS CHARACTER
 ( p-curr-code as int ) :
  define variable rr as character no-undo .
  find first ub.currency no-lock where  ub.currency.curr-code  = p-curr-code no-error.
  rr = ub.currency.curr-abbr.
  RETURN rr.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION val-abbr-type Dialog-Frame
FUNCTION val-abbr-type RETURNS CHARACTER
( input p-rec as recid ) :
define  BUFFER loc-fin-liab FOR ub.fin-ob.
find first loc-fin-liab no-lock where recid (loc-fin-liab) = p-rec no-error .
if error-status :error then return '' .

  define variable rr as character no-undo .
     find first ub.currency no-lock where ub.currency.curr-code  = loc-fin-liab.curr-code no-error.
/*      if error-status then return "". */
  rr = currency.curr-abbr .
if available ub.currency then  rr = ub.currency.curr-abbr.
else rr = ""   .

  RETURN rr.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME