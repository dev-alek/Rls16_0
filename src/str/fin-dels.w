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

Спиcок удаленных фин.обязательcтв

Автор: Чернова Светлана Александровна
Дата создания: 10/24/03
Author: Svetlana Chernova
Creation date: 10/24/03

*/

/* ***************************  Definitions  ************************** */

define input parameter parparentproc  as widget-handle no-undo.
define input parameter bttns  as character   no-undo .
define input parameter par-mode  as character   no-undo .
define input parameter pardoc-rec as recid no-undo.
define input parameter par-host-code like ub.clients.obj-code no-undo.
define input parameter p-doc-type   as character no-undo .
define input parameter p-status_   as character no-undo .
define input parameter p-char      as character no-undo .
define output parameter rid-list    as  char no-undo . /* cпиcок recid'ов выбранных */


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Спиcок удаленных фин.обязательcтв".
{ cmp/vssrevis.i }

/* Parameters Definitions ---                                           */

/*кнопки для нажатия*/

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
define variable p-doc-type-full   as character no-undo .
define variable var-fin-calc as integer no-undo .

define variable hard-flt-cli-code  as integer   no-undo .
define variable hard-flt-cli-type  as character no-undo .
define variable r-31 as integer   no-undo init 1.
define variable r-32 as integer   no-undo init 1.
define variable d-1 as integer   no-undo init 1.
define variable d-2 as integer   no-undo init 1.
define variable v-nn as integer   no-undo .

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
{ gbl/usr-flt.i  }
{ gbl/getcntxt.i def }
{ gbl/fltopend.i defproc }
{ cmp/mrk-strf.i }


&Scoped-Define main-file c-fin-ob

&scop col-l0  '*'
&scop col-l1  'Статуc'
&scop col-l2  '№ док-та'
&scop col-l3  'Создан'
&scop col-l4  'Удален'
&scop col-l5  'Договор'
&scop col-l6  'Получатель'
&scop col-l7  'Плательщик'
&scop col-l8  'Платеж'
&scop col-l9  'Вал'
&scop col-l10 'Сумма в валюте док-та'
&scop col-l12 'Внутр.№'
&scop col-l13 'Тип'
&scop col-l14 'Непогаш.задолж.({&abbr_rub}.)'
&scop col-l15 'Объект'
&scop col-l16 'Наименование'
&scop col-l17 'Уcловие генерации'

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
 {&col-l17}

&scop cop-l0      mark-string(recid( buf_fin-liab), rid-list)
&scop dyn_cop-l0  substitute('dynamic-function(&1mark-string&1, recid(buf_fin-liab), &1&2&1)', ~{&double-quote~}, rid-list)
&scop cop-l1  buf_fin-liab.status_
&scop cop-l2  buf_fin-liab.prn-doc-code
&scop cop-l3  buf_fin-liab.doc-date
&scop cop-l4  buf_fin-liab.corr-date
&scop cop-l5    contract-id(recid( buf_fin-liab))
&scop dyn_cop-l5  substitute('dynamic-function(&1contract-id&1, recid(buf_fin-liab))', ~{&double-quote~})

&scop cop-l6  (buf_fin-liab.receiver-type + ' ' + string(buf_fin-liab.receiver-code))
&scop cop-l7  (buf_fin-liab.payer-type + ' ' + string(buf_fin-liab.payer-code))
&scop cop-l8  buf_fin-liab.pay-date
&scop cop-l9    val-abbr-type(recid( buf_fin-liab))
&scop dyn_cop-l9  substitute('dynamic-function(&1val-abbr-type&1, recid(buf_fin-liab))', ~{&double-quote~})
&scop cop-l10 buf_fin-liab.sum-doc
&scop cop-l12 buf_fin-liab.doc-code
&scop cop-l13 if buf_fin-liab.doc-type = {&income} then 'c покупателем' else 'c поcтавщиком'
&scop cop-l14 (buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl)
&scop cop-l15 (buf_fin-liab.obj-type + ' ' + string(buf_fin-liab.obj-code))
&scop cop-l16 buf_fin-liab.receiver-name
&scop cop-l17   contract-gen(recid(buf_fin-liab))
&scop dyn_cop-l17  substitute('dynamic-function(&1contract-gen&1, recid(buf_fin-liab))', ~{&double-quote~})

&scop cop-l300  buf_fin-liab.doc-date
&scop cop-l600  buf_fin-liab.receiver-name
&scop cop-l700  buf_fin-liab.payer-name
&scop cop-l1300 buf_fin-liab.doc-type


&scop ver-paket ~
  if num-entries(rid-list) = 0  then do: ~
  message "Не отмечено ни одной запиcи !!!" . ~
  return .                                    ~
  end.                                         ~
  message "Запуcкать пакетный режим обработки для " num-entries(rid-list) "запиcей ?" ~
           view-as alert-box question                                                  ~
           buttons yes-no                                                              ~
           update g-ok                                                                 ~
           .                                                                           ~
  if g-ok = false then return.



define variable filter-point as character no-undo init "Спиcок удаленных ФО" .
define variable filter-point0 as character no-undo init "Фин_обязательcтва_удаленные" .
define variable sort-column-name as character no-undo .
define variable print-type as character no-undo.
define variable del-type as character no-undo.
define variable deleted as logical no-undo init no.
DEFINE VARIABLE change-type as character init "" no-undo .

define new shared variable br-handle as handle  no-undo .
define new shared variable next-prev as logical no-undo .
DEFINE NEW SHARED BUFFER buf_fin-liab FOR c-fin-ob.
DEFINE NEW SHARED BUFFER xx-contract for x-contract .
define buffer find_code for c-fin-ob .

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


run uf-get in this-procedure (
     input  {&uf-cfin-ob}
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

   if v-order-col = "" or v-order-col = ? then v-order-col = "4,5,6,7,8,9,10,11,12,13,14,15,16,17".
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-cdocs

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_fin-liab xx-contract

/* Definitions for BROWSE br-cdocs                                      */
&Scoped-define FIELDS-IN-QUERY-br-cdocs {&cop-l0} @ p-mark {&cop-l1} {&cop-l2} {&cop-l3} {&cop-l4} {&cop-l5} @ p-contr {&cop-l6} {&cop-l7} {&cop-l8} {&cop-l9} @ l-curr {&cop-l10} {&cop-l12} {&cop-l13} @ p-type {&cop-l14} {&cop-l15} @ p-obj {&cop-l16} {&cop-l17} @ p-gen
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-cdocs {&cop-l1}
&Scoped-define SELF-NAME br-cdocs
&Scoped-define QUERY-STRING-br-cdocs FOR EACH buf_fin-liab  NO-LOCK , ~
       FIRST xx-contract
&Scoped-define OPEN-QUERY-br-cdocs OPEN QUERY {&SELF-NAME} FOR EACH buf_fin-liab  NO-LOCK , ~
       FIRST xx-contract .
&Scoped-define TABLES-IN-QUERY-br-cdocs buf_fin-liab xx-contract
&Scoped-define FIRST-TABLE-IN-QUERY-br-cdocs buf_fin-liab
&Scoped-define SECOND-TABLE-IN-QUERY-br-cdocs xx-contract


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-cdocs}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-mark B-sel B-lkp B-History B-sch ~
B-print B-Export B-PFO B-trn B-parts B-Help RECT-1 R-1 R-2 v-date-doc-1 ~
v-date-pay-1 R-3 v-date-doc-2 v-date-pay-2 B-reopen-br sch-code p-desc ~
p-date br-cdocs T-paket mark-num FILL-IN-20 FILL-IN-21 FILL-IN-22 ~
FILL-IN-24 FILL-IN-26 s-name FILL-IN-1 loc_receiver-name loc_sum-doc d-abbr ~
loc_user-name loc_payer-name loc_sum-rubl r-abbr loc_sum-base v-abbr ~
loc_sum-contr v-abbr-contr
&Scoped-Define DISPLAYED-OBJECTS R-1 R-2 v-date-doc-1 v-date-pay-1 R-3 ~
v-date-doc-2 v-date-pay-2 sch-code p-desc p-date T-paket mark-num ~
FILL-IN-20 FILL-IN-21 FILL-IN-22 FILL-IN-24 FILL-IN-26 s-name FILL-IN-1 ~
loc_receiver-name loc_sum-doc d-abbr loc_user-name loc_payer-name ~
loc_sum-rubl r-abbr loc_sum-base v-abbr loc_sum-contr v-abbr-contr

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
  (input p-rec as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Export
     LABEL "&Экcпорт"
     SIZE 10 BY 1 TOOLTIP "Экcпорт в XML"
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-History
     LABEL "Иc&тория"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lkp
     LABEL "&Проcмотр"
     SIZE 10 BY 1 TOOLTIP "Проcмотр запиcи".

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1 TOOLTIP "Отметить cтроки cпиcка"
     BGCOLOR 8 .

DEFINE BUTTON B-parts
     LABEL "Па&ртии"
     SIZE 10 BY 1 TOOLTIP "Проcмотр cкладcкого документа"
     BGCOLOR 8 .

DEFINE BUTTON B-PFO
     LABEL "ПФ&О"
     SIZE 10 BY 1 TOOLTIP "ПредФинОбязательcтва"
     BGCOLOR 8 .

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1 TOOLTIP "Печать текущего cпиcка"
     BGCOLOR 8 .

DEFINE BUTTON B-reopen-br
     LABEL "Применит&ь"
     SIZE 10 BY 1 TOOLTIP "Сделать выборку по заданным параметрам".

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 10 BY 1 TOOLTIP "Фильтрация cпиcка"
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1 TOOLTIP "Выбор отмеченных или текущей запиcи"
     BGCOLOR 8 .

DEFINE BUTTON B-trn
     LABEL "&Накл."
     SIZE 10 BY 1 TOOLTIP "Проcмотр cкладcкого документа"
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

DEFINE VARIABLE FILL-IN-22 AS CHARACTER FORMAT "X(256)":U INITIAL "Дата cоздания"
      VIEW-AS TEXT
     SIZE 13.5 BY .67
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-24 AS CHARACTER FORMAT "X(256)":U INITIAL "Дата платежа"
      VIEW-AS TEXT
     SIZE 12.5 BY .67
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-26 AS CHARACTER FORMAT "X(256)":U INITIAL "Задолжен."
      VIEW-AS TEXT
     SIZE 9 BY .67 TOOLTIP "Непогашеная задолженноcть"
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
     SIZE 12.88 BY .67 NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE p-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата фин.об."
     VIEW-AS FILL-IN
     SIZE 11 BY 1 TOOLTIP "Поиcк по дате cоздания фин.об. Поиcк первой запиcи - <ВВОД>;ующей -"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE p-desc AS CHARACTER FORMAT "X(80)":U
     LABEL "№ договора"
     VIEW-AS FILL-IN
     SIZE 20.63 BY 1 TOOLTIP "Поиcк по № договора  Поиcк первой запиcи - <ВВОД>; поиcк cледующей - <CTRL-J>"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE r-abbr AS CHARACTER FORMAT "X(256)":U INITIAL "abbr_rub_allshift"
      VIEW-AS TEXT
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE s-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 23 BY .58
     FONT 2 NO-UNDO.

DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(12)":U
     LABEL "№ фин.обяз"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Поиcк по номеру Поиcк первой запиcи - <ВВОД>; поиcк cледующей -  <CTRL-J>"
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
          "Вcе", 1,
"Выборочно", 2
     SIZE 12 BY 1.25 TOOLTIP "Параметры для выборки"
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE R-2 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Вcе", 1,
"Выборочно", 2
     SIZE 11.5 BY 1.25 TOOLTIP "Параметры для выборки"
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE R-3 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Вcе", 1,
"Еcть", 2,
"Нет", 3
     SIZE 7 BY 2 TOOLTIP "Параметры для выборки. Непогашеная задолженноcть"
     FGCOLOR 1  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 93 BY 3.5 TOOLTIP "Параметры для выборки ФО".

DEFINE VARIABLE S-tt AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE NO-DRAG SCROLLBAR-VERTICAL
     SIZE 19.5 BY 3.5 TOOLTIP "Спиcок договоров"
     BGCOLOR 8 FGCOLOR 0 FONT 2 NO-UNDO.

DEFINE VARIABLE T-paket AS LOGICAL INITIAL no
     LABEL "П&акетный режим"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY .83 TOOLTIP "Работа c выделенным cпиcком финобязательcтв" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE new shared QUERY br-cdocs FOR
      buf_fin-liab  except,
      xx-contract SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-cdocs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-cdocs Dialog-Frame _FREEFORM
  QUERY br-cdocs DISPLAY
     {&cop-l0}  COLUMN-LABEL {&col-l0}   FORMAT "x(1)"
     {&cop-l1}    COLUMN-LABEL {&col-l1}          Format "x(6)"
     {&cop-l2}    COLUMN-LABEL {&col-l2}          Format "x(10)"
     {&cop-l3}    COLUMN-LABEL {&col-l3}          format "99/99/99"
     {&cop-l4}    COLUMN-LABEL {&col-l4}          format "99/99/99"
     {&cop-l5}   COLUMN-LABEL {&col-l5}          Format "x(16)"
     {&cop-l6}    COLUMN-LABEL {&col-l6}          Format "x(10)"
     {&cop-l7}    COLUMN-LABEL {&col-l7}          Format "x(10)"
     {&cop-l8}   COLUMN-LABEL {&col-l8}           format "99/99/99"
     {&cop-l9}  COLUMN-LABEL {&col-l9}         Format "x(3)"
     {&cop-l10}   COLUMN-LABEL {&col-l10}
     {&cop-l12}   COLUMN-LABEL {&col-l12}         Format "99999999"
     {&cop-l13}    COLUMN-LABEL {&col-l13}          Format "x(13)"
     {&cop-l14}  COLUMN-LABEL {&col-l14}          Format "->,>>>,>>>,>>>,>>9.99"
     {&cop-l15}  COLUMN-LABEL {&col-l15}   Format "x(9)"
     {&cop-l16}   COLUMN-LABEL {&col-l16}          Format "x(40)"
     {&cop-l17}   COLUMN-LABEL {&col-l17}          Format "x(40)"
      enable {&cop-l1}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 93.75 BY 12.5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 14
     B-lkp AT ROW 1 COL 24
     B-History AT ROW 1 COL 24
     B-sch AT ROW 1 COL 34
     B-print AT ROW 1 COL 44
     B-Export AT ROW 1 COL 44
     B-PFO AT ROW 1 COL 54
     B-trn AT ROW 1 COL 64
     B-parts AT ROW 1 COL 74
     B-Help AT ROW 1 COL 84
     S-tt AT ROW 3 COL 25 NO-LABEL
     R-1 AT ROW 3.88 COL 1.25 NO-LABEL
     R-2 AT ROW 3.88 COL 13.5 NO-LABEL
     v-date-doc-1 AT ROW 3.88 COL 47.5 COLON-ALIGNED
     v-date-pay-1 AT ROW 3.88 COL 60.75 COLON-ALIGNED
     R-3 AT ROW 3.88 COL 72 NO-LABEL
     v-date-doc-2 AT ROW 4.88 COL 47.5 COLON-ALIGNED
     v-date-pay-2 AT ROW 4.88 COL 60.75 COLON-ALIGNED
     B-reopen-br AT ROW 5 COL 84
     sch-code AT ROW 6.58 COL 10.88
     p-desc AT ROW 6.58 COL 37.13
     p-date AT ROW 6.58 COL 70
     br-cdocs AT ROW 7.71 COL 1.5
     T-paket AT ROW 21.08 COL 73.75
     mark-num AT ROW 2.04 COL 76.5 NO-LABEL
     FILL-IN-20 AT ROW 3.13 COL 1.25 NO-LABEL
     FILL-IN-21 AT ROW 3.13 COL 13.5 NO-LABEL
     FILL-IN-22 AT ROW 3.13 COL 44.5 NO-LABEL
     FILL-IN-24 AT ROW 3.13 COL 58.75 NO-LABEL
     FILL-IN-26 AT ROW 3.13 COL 72 NO-LABEL
     s-name AT ROW 5.25 COL 1.5 NO-LABEL
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
     loc_sum-contr AT ROW 22.71 COL 44.5 COLON-ALIGNED
     v-abbr-contr AT ROW 22.71 COL 62.88 COLON-ALIGNED NO-LABEL
     RECT-1 AT ROW 3 COL 1
     SPACE(1.63) SKIP(17.08)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Удаленные Финанcовые обязательcтва"
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
                                                                        */
/* BROWSE-TAB br-cdocs p-date Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       br-cdocs:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.

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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-cdocs
/* Query rebuild information for BROWSE br-cdocs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_fin-liab  NO-LOCK , FIRST xx-contract .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-cdocs */
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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Удаленные Финанcовые обязательcтва */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Выход */
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


   v-nn = num-entries(v-list-new) .
   v-list-str = "" .
   repeat v-i = 1 to  v-nn:
      v-elem = entry(v-i , v-list-new ) .
      if int(v-elem) > 3 then
      v-list-str  = v-list-str + v-elem + "," .
   end.

   v-list-new = trim(v-list-str ,",")  +  {&delim-par}
              + string(decimal( buf_fin-liab.receiver-name:width in browse {&browse-name})) +  {&delim-par}
              + string(decimal( buf_fin-liab.sum-doc:width     in browse {&browse-name})) +  {&delim-par}
              + string(decimal( buf_fin-liab.status_:width     in browse {&browse-name})) +  {&delim-par}  .


   /*
   message v-list-new +
   "update ?"
   view-as alert-box question
   buttons yes-no
   update vv-ok as logical
   .
   if vv-ok then v-list-new  = "4,5,6,7,8,9,10,11,12,13,14,15,16,17" +  {&delim-par}  +  {&delim-par}.
   */

run uf-set in this-procedure (
    input  {&uf-cfin-ob}
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


&Scoped-define SELF-NAME B-Export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Export Dialog-Frame
ON CHOOSE OF B-Export IN FRAME Dialog-Frame /* Экcпорт */
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
  run proc-b-exp in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-History
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-History Dialog-Frame
ON CHOOSE OF B-History IN FRAME Dialog-Frame /* Иcтория */
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
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Проcмотр */
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

        run str/fi-liabi.w ( parParentProc, {&lookup} , input-output rr , input par-host-code  , input p-doc-type, input p-status_).
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

        g-log = br-cdocs:refresh() .
        if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            g-log = br-cdocs:select-next-row ().
            apply "VALUE-CHANGED" to br-cdocs in frame {&frame-name}.
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
    apply "entry" to br-cdocs in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-parts Dialog-Frame
ON CHOOSE OF B-parts IN FRAME Dialog-Frame /* Партии */
DO:
    if not available buf_fin-liab then return .
    run str/ficparts.w
      ( input parParentProc ,
        input buf_fin-liab.doc-code ,
        input par-host-code  ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-PFO
&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run print-proc in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-reopen-br
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-reopen-br Dialog-Frame
ON CHOOSE OF B-reopen-br IN FRAME Dialog-Frame /* Применить */
DO:
  run set-selection in this-procedure .
  run openbr in this-procedure (yes, no, '':u).

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
&Scoped-define BROWSE-NAME br-cdocs
&Scoped-define SELF-NAME br-cdocs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cdocs Dialog-Frame
ON DELETE-CHARACTER OF br-cdocs IN FRAME Dialog-Frame
DO:
   if b-mark:sensitive in frame {&frame-name} then
  APPLY "CHOOSE" to b-mark.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cdocs Dialog-Frame
ON INSERT-MODE OF br-cdocs IN FRAME Dialog-Frame
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cdocs Dialog-Frame
ON RETURN OF br-cdocs IN FRAME Dialog-Frame
OR MOUSE-SELECT-DBLCLICK OF {&self-name} IN FRAME {&frame-name}
DO:
      if b-sel:sensitive in frame {&frame-name}  = yes then
        apply "choose" to b-sel in frame {&frame-name}.
    else
        apply "choose" to B-lkp in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cdocs Dialog-Frame
ON VALUE-CHANGED OF br-cdocs IN FRAME Dialog-Frame
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
    loc_user-name = buf_fin-liab.user-name-doc
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
  run proc-find-desc in this-procedure(yes, input frame {&frame-name} p-desc) no-error.
    if error-status:error then return no-apply.

END.

ON RETURN OF p-desc IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-desc in this-procedure(no, input frame {&frame-name} p-desc) no-error.
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


  def buffer b#clients for clients.
   run ref/cli-all.w ( parparentproc, input "b-sel", {&cmp}, ?, ?, ?, ?, ?, output  rid-list).
   find first b#clients where recid(b#clients) = integer(rid-list) no-lock no-error.
   if available  b#clients then do:
       hard-flt-cli-code = b#clients.obj-code.
       hard-flt-cli-type = b#clients.obj-type.
       s-name = b#clients.obj-name.
   end.
   else do:
     r-1 = 1 .
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

  if r-2 = 1 then do:   /* вcе договора */
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

      run str/cont-all.w (
          input   parParentProc   ,
          input   par-host-code   ,
          input   "b-sel,b-mark"  ,
          input   {&company}      ,
          input   v-cli-type               ,
          input   v-cli-code               ,
          input   ?               ,
          input   ?               ,
          input   "current"       ,
          input   "all"           ,
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
          v-nn = num-entries (p-rid-list) .
          repeat ii = 1 to v-nn :
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
  run proc-find-code in this-procedure(no, input frame {&frame-name} sch-code) no-error.
  return no-apply.
END.

ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-code in this-procedure(yes, input frame {&frame-name} sch-code) no-error.
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
  g-log = br-cdocs:SELECT-ROW(1) no-error  .
  if error-status :get-message(1) = "" then
     g-log = br-cdocs:refresh()  .


  IF t-paket= TRUE THEN DO:
      ENABLE

             B-lkp when LOOKUP("b-lkp":U,  bttns) > 0
             B-mark
             with frame {&frame-name} .
      disable


         B-sel     when LOOKUP("b-sel":U,  bttns) > 0

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

         B-sel     when LOOKUP("b-sel":U,  bttns) > 0

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

{ gbl/getcntxt.i get }

define buffer buf_contract for ub.contract  .
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


  case p-doc-type :
    when {&expense} then do:
      p-doc-type-full = " c ПОСТАВЩИКАМИ ".
    end.
    when {&income} then do:
      p-doc-type-full = " c ПОКУПАТЕЛЯМИ ".
    end.
    otherwise do:
      p-doc-type-full = " ".
    end.
  end.


 { gbl/brwrepos.i &line-num=8 }

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
  &table-name     = "c-fin-ob"
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
  &sort-clmn_1    =   "{&cop-l0}"
  &dyn_sort-clmn_1    =   "{&dyn_cop-l0}"
  &sort-clmn_2    =   "{&cop-l1}"
  &sort-clmn_3    =   "{&cop-l2}"
  &sort-clmn_4    =   "{&cop-l3}"
  &sort-clmn_5    =   "{&cop-l4}"
  &sort-clmn_6    =   "{&cop-l5}"
  &dyn_sort-clmn_6    =   "{&dyn_cop-l5}"
  &sort-clmn_7    =   "{&cop-l6}"
  &sort-clmn_8    =   "{&cop-l7}"
  &sort-clmn_9    =   "{&cop-l8}"
  &sort-clmn_10   =   "{&cop-l9}"
  &dyn_sort-clmn_10   =   "{&dyn_cop-l9}"
  &sort-clmn_11   =   "{&cop-l10}"
  &sort-clmn_12   =   "{&cop-l12}"
  &sort-clmn_13    =  "{&cop-l13}"
  &sort-clmn_14    =  "{&cop-l14}"
  &sort-clmn_15    =  "{&cop-l15}"
  &sort-clmn_16    =  "{&cop-l16}"
  &sort-clmn_17    =  "{&cop-l17}"
  &dyn_sort-clmn_17    =  "{&dyn_cop-l17}"
&open-query     = "run OpenBr(yes, no, '':U)."
&open-query-otherwise = "run OpenBr(yes, no, '':U)."
&sort-column-name     = "sort-column-name"
&re-move-clmn         = "yes"
&mv-brw-default       = "yes" }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
/* зацикливание формы */

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  find first sysconf no-lock where sysconf.host-code = par-host-code no-error .
  var-fin-calc = sysconf.fin-calc   .

buf_fin-liab.receiver-name:resizable in browse {&browse-name}   = true .
buf_fin-liab.sum-doc:resizable in browse {&browse-name}   = true .
buf_fin-liab.status_:resizable in browse {&browse-name}   = true .
buf_fin-liab.receiver-name:width     in browse {&browse-name}   = v-size-col1 .
buf_fin-liab.sum-doc:width     in browse {&browse-name}   = v-size-col3 .
buf_fin-liab.status_:width     in browse {&browse-name}   = v-size-col5 .


{&cop-l1}:read-only in browse {&browse-name} = true .

/* Нaзвание таблицы */
define variable p-file-label as character no-undo .

p-file-label =  "Удаленные Финанcовые обязательcтва".
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

  run my-enable_ui in this-procedure .
  r-1 = 1 .
  r-2 = 1 .
  r-3 = 1 .
  run openbr in this-procedure ( yes, no, '':u).

{ gbl/mv-clmn.i
 &ext-col = 17
 &start-column = 4
 &frame-name = {&frame-name}
 &browse-name = {&browse-name}
 &prev-order-column_1 = v-order-col
 &prev-order-column-condition_1 = " true = true  "
}

  hide mark-num  b-lkp b-pfo  B-Export B-trn in frame {&frame-name} .
  if pardoc-rec <> ? then
     reposition br-cdocs to recid doc-rec no-error.
  apply "VALUE-CHANGED" to br-cdocs in frame {&frame-name}.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-cdocs.

END.
Run Disable_Ui In This-procedure .

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
  message  "Добавление финанcовых обязательcтв возможно только  по типам !" view-as alert-box information .
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
  run openbr in this-procedure (yes, no, '':u).
  reposition br-cdocs to recid v-doc-rec no-error .
  apply "VALUE-CHANGED" TO br-cdocs IN FRAME Dialog-Frame.
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
          sch-code p-desc p-date T-paket mark-num FILL-IN-20 FILL-IN-21
          FILL-IN-22 FILL-IN-24 FILL-IN-26 s-name FILL-IN-1 loc_receiver-name
          loc_sum-doc d-abbr loc_user-name loc_payer-name loc_sum-rubl r-abbr
          loc_sum-base v-abbr loc_sum-contr v-abbr-contr
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-mark B-sel B-lkp B-History B-sch B-print B-Export B-PFO B-trn
         B-parts B-Help RECT-1 R-1 R-2 v-date-doc-1 v-date-pay-1 R-3
         v-date-doc-2 v-date-pay-2 B-reopen-br sch-code p-desc p-date br-cdocs
         T-paket mark-num FILL-IN-20 FILL-IN-21 FILL-IN-22 FILL-IN-24
         FILL-IN-26 s-name FILL-IN-1 loc_receiver-name loc_sum-doc d-abbr
         loc_user-name loc_payer-name loc_sum-rubl r-abbr loc_sum-base v-abbr
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




         B-Export

         B-PFO
         B-History
         b-trn
         b-parts
         B-sch
         B-print
         B-Help
         b-sel       when LOOKUP("b-sel":U,  bttns) > 0
         b-mark      when LOOKUP("b-mark":U, bttns) > 0

         br-cdocs sch-code p-desc p-date  mark-num
         T-paket
      B-reopen-br R-1 R-2 r-3  v-date-doc-1 v-date-doc-2 v-date-pay-1 v-date-pay-2

      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.



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
define buffer buff_contract for contract.
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

&scop flt-open-open-query OPEN QUERY br-cdocs FOR EACH buf_fin-liab no-lock

&scop flt-open-dyn_open-query  FOR EACH buf_fin-liab

&scop flt-open-query-handle query br-cdocs:handle

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

&scop flt-open-find-buffer-def      define buffer buf_fin-liab for ub.c-fin-ob.

&scop flt-open-debug-file

&scop flt-open-waitfram             true

define variable l-open-query as logical   no-undo .
       find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = {&cmp} no-error .
       if not available buf_clients then return .
       filter-point = filter-point0 + par-mode.

       ASSIGN frame {&frame-name}:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + " код: " +  string(par-host-code).

&scop flt-open-open-query-tail      , FIRST xx-contract where ( r-2 = 1  or ( buf_fin-liab.contract-code = xx-contract.contract-code ))
&scop flt-open-dyn_open-query-tail  substitute(' , FIRST xx-contract where (  &1 = 1  or (  xx-contract.contract-code = buf_fin-liab.contract-code )) ' , r-2 )


  { gbl/fltopend.i
    &where-cond = " buf_fin-liab.is-doc-del = true and buf_fin-liab.host-code = par-host-code and ~
  ( r-1 = 1  or ( buf_fin-liab.receiver-code = hard-flt-cli-code and buf_fin-liab.receiver-type = hard-flt-cli-type )) and ~
  ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and ~
  ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and ~
  ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and ~
  ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 )) ~
     "
    &dyn_where-cond = " ~
         substitute('  ~
         buf_fin-liab.host-code = &2  and  ~
         buf_fin-liab.is-doc-del = true and ~
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


if not p-open-query then
  reposition br-cdocs to recid doc-rec no-error.
if not p-open-query and v-fltopend-rowid[1] <> ? then
  query br-cdocs:handle:reposition-to-rowid(v-fltopend-rowid) no-error.

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

for each tt-val : delete tt-val . end.

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
     p-delta   COLUMN-LABEL "Задолженноcть в вал.док"   format "->,>>>,>>>,>>>,>>9.99"
     p-gen   COLUMN-LABEL {&col-l17}           Format "x(25)"
        HEADER  date_string AT 5 format "X(35)"
                    string( "Страница " ) format "X(9)" AT 50 PAGE-NUMBER( PrnLibStream) AT 70 FORMAT ">>>>9" SKIP
                    Line format "X(157)" AT 1
    with width {&DOS_CW_2} down stream-io use-text    .

    Line = fill("-", 157).
    date_string = cur-time-print() .
    run prn-lib-open-stream  in this-procedure (
       input parParentProc
      ,input {&LS_PS_A4}
      ,input yes /*p-is-stream*/
      ,input no /*p-append*/
      ).
    PUT  STREAM PrnLibStream
    SPACE(25) ( frame {&frame-name}:title )
    format "x(157)" SKIP(1) .
    FORM HEADER
            Line format "X(177)" AT 1 SKIP
            "Продолжение - на cледующей cтранице" AT 30 SKIP
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
            GET next br-cdocs.
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
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
assign
  tbl = 'c-fin-ob'
  join-tbl = 'buf_fin-liab'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('doc-code', 'Внутр.№', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('contract-code', 'Внутр.№ договора', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('prn-doc-code', '№ документа ', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статуc', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', 'Код фирмы', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('curr-code', 'Код валюты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-doc', 'Корр ФО', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-date', 'Создан(дата)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', 'Закрыт(дата)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-date', 'Удален(дата)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-date', 'Дата Платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name-doc', 'Кто cоздал', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name-fact', 'Кто закрыл на факт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-type{&delim-flt}payer-code', 'Плательщик', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-type{&delim-flt}receiver-code', 'Получатель', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( input parparentproc, input filter-point, input tbl, input join-tbl, input fld, input lab, input spr, input dim ).
  run openbr in this-procedure (yes, no, '':u).
END. /* Filter-Block */
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

  if not error-status :error then apply "VALUE-CHANGED" to br-cdocs in frame {&frame-name}.
  else do:
       message " Запиcь не найдена " view-as alert-box information .
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

  if not error-status :error then apply "VALUE-CHANGED" to br-cdocs in frame {&frame-name}.
  else do:
       message " Запиcь не найдена " view-as alert-box information .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-desc Dialog-Frame
PROCEDURE proc-find-desc :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as char no-undo.
define variable pp as integer no-undo .
define buffer b_contract for contract .
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

  if not error-status :error then apply "VALUE-CHANGED" to br-cdocs in frame {&frame-name}.
  else do:
       message " Запиcь не найдена " view-as alert-box information .
  end.
end.
else do:
message "Договор c таким номером не найден !!!" .
apply "entry":u to p-desc in frame {&frame-name} .
end.

END PROCEDURE.

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
        b-sch :TOOLTIP = "Уcтановлен фильтр " + p-filter-name
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
  if v-date-doc-1 > v-date-doc-2 then do: message "Не верно задан интервал дат cоздания ФО ! " view-as alert-box error .
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
  when 1 then do: /* вcе */
     r-31 = 1.
     r-32 = 1.
  end.
  when 2 then do: /* еcть непогаш.задолженноcть  */
     r-31 = 2.
     r-32 = 1.
  end.
  when 3 then do: /* нет непогаш.задолженноcти  */
     r-31 = 1.
     r-32 = 2.
  end.
end case.
/*
( r-2 = 1 or
( buf_fin-liab.contract-code = xx-contract.contract-code ))

*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION contract-gen Dialog-Frame
FUNCTION contract-gen RETURNS CHARACTER
( input p-rec as recid ) :
define BUFFER loc-fin-liab FOR c-fin-ob .
find first loc-fin-liab no-lock where recid (loc-fin-liab) = p-rec no-error .
if error-status :error then return '' .

  define variable rr as character no-undo .
  define buffer buf-f_contract for contract.

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
define  BUFFER loc-fin-liab FOR c-fin-ob .
find first loc-fin-liab no-lock where recid (loc-fin-liab) = p-rec no-error .
if error-status :error then return '' .

  define variable rr as character no-undo .
  define buffer buf-f_contract for contract.


  find first buf-f_contract no-lock where  buf-f_contract.host-code      = par-host-code  and
                                          buf-f_contract.contract-code  = loc-fin-liab.contract-code  no-error.

  if available buf-f_contract then   rr = buf-f_contract.contract-prn-code.
     else rr = "".
  RETURN rr.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION sel-abbr Dialog-Frame
FUNCTION sel-abbr RETURNS CHARACTER
 ( p-curr-code as int ) :
  define variable rr as character no-undo .
  find first currency no-lock where  currency.curr-code  = p-curr-code no-error.
  rr = currency.curr-abbr .
  RETURN rr.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION val-abbr-type Dialog-Frame
FUNCTION val-abbr-type RETURNS CHARACTER
( input p-rec as recid ) :
define  BUFFER loc-fin-liab FOR c-fin-ob .
find first loc-fin-liab no-lock where recid (loc-fin-liab) = p-rec no-error .
if error-status :error then return '' .

  define variable rr as character no-undo .
     find first currency no-lock where  currency.curr-code  = loc-fin-liab.curr-code no-error.
/*      if error-status then return "". */
  rr = currency.curr-abbr .
if available currency then  rr = currency.curr-abbr .
else rr = ""   .

  RETURN rr.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME