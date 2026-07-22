/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список неосновных цен приказа переоценки

Автор: Чернова Светлана Александровна
Дата создания: 09/08/05
Author: Svetlana Chernova
Creation date: 09/08/05

Author: Исаков Андрей Валерьевич
created: 2.04.2001

*/

&Scop WINDOW-NAME d-pr-alt
&Scop FRAME-NAME d-pr-alt

/* Значения параметра mode:
   code    - неосновные цены по текущему коду
   scl-gds - неосновные цены по всем признакам текущего товара
   par-gds - неосновные цены по всем партиям текущего товара
   scl-doc - неосновные цены по всем признакам документа
   par-doc - неосновные цены по всем партиям документа
   doc     - неосновные цены по всему документу
*/
define input  parameter parParentProc as widget-handle no-undo.
define input  parameter doc-rec as recid no-undo .
define input  parameter doc-mode as character no-undo .
define input  parameter mode     as character no-undo . /* основной код, если mode = code, scl-gds, par-gds, иначе ? */
define input        parameter base-bc like ub.bar-code.b-code   no-undo.
define input-output parameter round-method as character     no-undo. /* способ округления */
define input-output parameter round-base   as decimal no-undo. /* база для округления / коэффициент */

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список неосновных цен приказа переоценки".
{ cmp/vssrevis.i }

define new shared buffer base-bar-code for bar-code.                 /* буфер бар-кода основного */
define buffer base-goods    for goods.                    /* буфер товара основного */

define variable mark       as character                      no-undo. /* отметка в списке */
define variable mark-list  as character                      no-undo. /* список отметок */
define variable arg-base   like price-list.price-sale no-undo. /* для вывода в список цены основного кода */
define variable calc-dtl   as character                      no-undo. /* для вывода в список детализации */
define variable main-bc-br like bar-code.b-code       no-undo. /* для вывода в список глав. кода */
define variable base-bc-br like bar-code.b-code       no-undo. /* для вывода в список осн. кода */

define variable ref-list  as character                      no-undo.
define variable code-rec  as recid                    no-undo.

define variable filter-point as character  no-undo init "pr-alt" .

{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i  }
{ str/getctxtp.i def }
{ gbl/getcntxt.i def }

{ gbl/getcntxt.i get }
{ str/getctxtp.i get }

{ gbl/color.i }
{ str/libbcrcn.i }
{ trg/check-bc.i }
{ gbl/fltopend.i defproc }

define buffer l-price-list for price-list.                /* для поиска  */

/* для дор налога */
define variable   rdtaxcdvalue  as character initial ? no-undo.
define variable   rdtaxcdtype   as character initial ? no-undo.
define buffer     rt_tax            for tax.
define variable dor-nal as character no-undo .
define variable g#log as logical   no-undo .
define variable gds-rec as recid no-undo .
define variable rep-rec as recid no-undo .
define variable ref-rec as recid no-undo .

define new shared buffer price-list for price-list.
define new shared buffer bar-code   for bar-code.
define new shared buffer goods      for goods.
define new shared buffer gds-prt    for gds-prt.
define new shared QUERY br-alt FOR price-list except, bar-code, goods, gds-prt SCROLLING.
define variable sort-column-name as character no-undo .

&SCOP label-clmn_1-br-alt  '*'
&SCOP clmn_1-br-alt        fnc-mark (price-list.b-code)
&SCOP dyn_clmn_1-br-alt    substitute('dynamic-function(&1fnc-mark&1,price-list.b-code )' , ~{&double-quote~})
&SCOP label-clmn_2-br-alt  'Тип'
&SCOP clmn_2-br-alt ~
      if gds-prt.upper-code = goods.prt-root then ~
        if bar-code.in-code = '' then ~
          {&goods} ~
        else ~
          {&part} ~
      else ~
        {&property}
&SCOP label-clmn_3-br-alt  'Глав. код'
&SCOP clmn_3-br-alt         fnc-main-code (price-list.b-code)
&SCOP dyn_clmn_3-br-alt     substitute('dynamic-function(&1fnc-main-code&1,price-list.b-code )' , ~{&double-quote~})
&SCOP label-clmn_4-br-alt  'Осн. код'
&SCOP clmn_4-br-alt         fnc-base-code (price-list.b-code)
&SCOP dyn_clmn_4-br-alt     substitute('dynamic-function(&1fnc-base-code&1,price-list.b-code )' , ~{&double-quote~})
&SCOP label-clmn_5-br-alt  'Код'
&SCOP clmn_5-br-alt bar-code.b-code
&SCOP label-clmn_6-br-alt  'Осн. цена'
&SCOP clmn_6-br-alt         fnc-base-price (price-list.b-code, price-list.doc-num)
&SCOP dyn_clmn_6-br-alt     substitute('dynamic-function(&1fnc-base-price&1,price-list.b-code )' , ~{&double-quote~})
&SCOP label-clmn_7-br-alt  'Изм'
&SCOP clmn_7-br-alt        goods.unit-base
&SCOP label-clmn_8-br-alt  'Коэф'
&SCOP clmn_8-br-alt         bar-code.cli-base-rate
&SCOP label-clmn_9-br-alt  'Скидка'
&SCOP clmn_9-br-alt         price-list.d-pcnt
&SCOP label-clmn_10-br-alt  'Цена'
&SCOP clmn_10-br-alt        price-list.price-sale
&SCOP label-clmn_11-br-alt 'Изм'
&SCOP clmn_11-br-alt        bar-code.unit-cli
&SCOP clmn_12-br-alt        price-list.road-tax
&SCOP label-clmn_13-br-alt  'Акциз'
&SCOP clmn_13-br-alt        price-list.excise
&SCOP NUM-LOCKED-COLUMNS-br-alt 1
&SCOP disp-list-color ~
{&clmn_1-br-alt}   @ mark                 COLUMN-LABEL {&label-clmn_1-br-alt}  FORMAT "x(1)" ~
{&clmn_2-br-alt}   @ calc-dtl             COLUMN-LABEL {&label-clmn_2-br-alt}  FORMAT "x(3)" ~
{&clmn_3-br-alt}   @ main-bc-br           COLUMN-LABEL {&label-clmn_3-br-alt}  ~
{&clmn_4-br-alt}   @ base-bc-br           COLUMN-LABEL {&label-clmn_4-br-alt}  ~
{&clmn_5-br-alt}                          COLUMN-LABEL {&label-clmn_5-br-alt}  ~
{&clmn_6-br-alt}   @ arg-base             COLUMN-LABEL {&label-clmn_6-br-alt} LABEL-FGCOLOR 15 LABEL-BGCOLOR 1 ~
{&clmn_7-br-alt}                          COLUMN-LABEL {&label-clmn_7-br-alt}  FORMAT "x(3)" LABEL-FGCOLOR 15 LABEL-BGCOLOR 1 ~
{&clmn_8-br-alt}                          COLUMN-LABEL {&label-clmn_8-br-alt}  ~
{&clmn_9-br-alt}                          COLUMN-LABEL {&label-clmn_9-br-alt}  ~
{&clmn_10-br-alt}                         COLUMN-LABEL {&label-clmn_10-br-alt} LABEL-FGCOLOR 15 LABEL-BGCOLOR 1 ~
{&clmn_11-br-alt}                         COLUMN-LABEL {&label-clmn_11-br-alt} FORMAT "x(3)" LABEL-FGCOLOR 15 LABEL-BGCOLOR 1 ~
{&clmn_12-br-alt}                          ~
{&clmn_13-br-alt}                         COLUMN-LABEL {&label-clmn_13-br-alt}

&SCOP disp-list ~
{&clmn_1-br-alt}   @ mark                 COLUMN-LABEL {&label-clmn_1-br-alt}  FORMAT "x(1)" ~
{&clmn_2-br-alt}   @ calc-dtl             COLUMN-LABEL {&label-clmn_2-br-alt}  FORMAT "x(3)" ~
{&clmn_3-br-alt}   @ main-bc-br           COLUMN-LABEL {&label-clmn_3-br-alt}  ~
{&clmn_4-br-alt}   @ base-bc-br           COLUMN-LABEL {&label-clmn_4-br-alt}  ~
{&clmn_5-br-alt}                          COLUMN-LABEL {&label-clmn_5-br-alt}  ~
{&clmn_6-br-alt}   @ arg-base             COLUMN-LABEL {&label-clmn_6-br-alt}  ~
{&clmn_7-br-alt}                          COLUMN-LABEL {&label-clmn_7-br-alt}  FORMAT "x(3)"  ~
{&clmn_8-br-alt}                          COLUMN-LABEL {&label-clmn_8-br-alt}  ~
{&clmn_9-br-alt}                          COLUMN-LABEL {&label-clmn_9-br-alt}  ~
{&clmn_10-br-alt}                         COLUMN-LABEL {&label-clmn_10-br-alt}  ~
{&clmn_11-br-alt}                         COLUMN-LABEL {&label-clmn_11-br-alt} FORMAT "x(3)"  ~
{&clmn_12-br-alt}                          ~
{&clmn_13-br-alt}                         COLUMN-LABEL {&label-clmn_13-br-alt}
&SCOP enable-list ~
{&clmn_9-br-alt} ~{&extra-act~} ~
{&clmn_10-br-alt} ~{&extra-act~} ~
{&clmn_12-br-alt} ~{&extra-act~} ~
{&clmn_13-br-alt} ~{&extra-act~}

/* ---------------------------- FUNCTIONS --------------------------------- */
FUNCTION fnc-mark RETURN char (local-bc as integer).
define buffer local-price-list for price-list.
  find local-price-list no-lock where
       local-price-list.b-code = local-bc and
       local-price-list.doc-num = price-doc.doc-num and
       local-price-list.price-type = "" no-error.
  if not available local-price-list then
    return (?).
  if lookup (string (recid (local-price-list)), mark-list) > 0 then
    return "*".
  else
    return "".
END FUNCTION.

FUNCTION fnc-main-code RETURN integer (local-bc as integer).
define variable local-main-code like bar-code.b-code no-undo.
run prc-main-code (input local-bc, output local-main-code).
return (local-main-code).
END FUNCTION.

FUNCTION fnc-base-code RETURN integer (local-bc as integer).
define variable local-base-code like bar-code.b-code no-undo.
run prc-base-code (input local-bc, output local-base-code).
return (local-base-code).
END FUNCTION.

{ str/alt-calc.i func }
{ str/alt-calc.i proc }
{ str/alt-calc.i "ver-modificator-price-is-null" }
{ str/doc-code.i }
/* ***********************  Control Definitions  ********************** */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход":L
     SIZE 8 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 6 BY 1.

DEFINE MENU m-add
       MENU-ITEM m-cur-add      LABEL "Список имеющихся спеццен"
       MENU-ITEM m-lst-add      LABEL "Список неосновных кодов"
       .

DEFINE BUTTON b-add
     LABEL "&Добав":L
     SIZE 8 BY 1.

DEFINE BUTTON b-discnt
     LABEL "С&кидка":L
     SIZE 8 BY 1.

DEFINE BUTTON b-chg
     LABEL "Рас&чет":L
     SIZE 8 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удал":L
     SIZE 8 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 8 BY 1.

define RECTANGLE rect-line EDGE-PIXELS 2 GRAPHIC-EDGE SIZE 98.5 BY 5.4 BGCOLOR GRAY_COLOR.

DEFINE VARIABLE calc-price AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" label "Цена расчет."
VIEW-AS TEXT SIZE 15 BY 0.79
tooltip "Цена, рассчитанная для данной единицы измерения через скидку и коэффициент"
no-undo.

define variable loc-art  as character  VIEW-AS fill-in size 14 by 1 fgcolor RED_COLOR no-undo.
define variable loc-name as character  VIEW-AS fill-in size 20 by 1 fgcolor RED_COLOR no-undo.
define variable loc-code as character  VIEW-AS fill-in size 20 by 1 fgcolor RED_COLOR no-undo.

define variable conf-par     as character  no-undo.    /* для чтения параметра конфигурации */
define variable par-type     as character  no-undo.    /* тип параметра конфигурации */

define variable a-n-c as character  VIEW-AS RADIO-SET horizontal RADIO-BUTTONS
"&А","art",
"&Н","name",
"&К","code"
SIZE 12 BY 1 no-undo.

DEFINE BROWSE br-alt QUERY br-alt NO-LOCK
    DISPLAY {&disp-list-color}
&scop extra-act
    ENABLE {&enable-list}
    WITH SIZE 98 BY 10.5
    bgcolor WHITE_COLOR
    separators.

&scop OPEN-any-QUERY ~
  OPEN QUERY br-alt ~
    FOR EACH price-list no-lock WHERE ~
             price-list.doc-num = price-doc.doc-num and ~
             price-list.price-type = '', ~
        each bar-code no-lock where ~
             bar-code.b-code = price-list.b-code ~
             ~{&where-code~}, ~
        EACH goods no-lock where ~
             goods.gds-code = bar-code.gds-code and ~
             goods.unit-base <> bar-code.unit-cli, ~
        EACH gds-prt no-lock WHERE ~
             gds-prt.node-code = bar-code.node-code

&scop where-code                                   and ~
      bar-code.gds-code  = base-bar-code.gds-code
&scop OPEN-QUERY-code         {&OPEN-any-QUERY}

&scop where-code-old                               and ~
      bar-code.gds-code  = base-bar-code.gds-code  and ~
      bar-code.node-code = base-bar-code.node-code and ~
      bar-code.in-code   = base-bar-code.in-code   and ~
      bar-code.part-code = base-bar-code.part-code
&scop OPEN-QUERY-code-old         {&OPEN-any-QUERY}

&scop where-code                                   and ~
      bar-code.gds-code  = base-bar-code.gds-code  and ~
      bar-code.node-code = base-bar-code.node-code and ~
      bar-code.in-code   = ""                      and ~
      bar-code.part-code = ""
&scop OPEN-QUERY-scl-gds      {&OPEN-any-QUERY}

&scop where-code                                   and ~
      bar-code.gds-code  = base-bar-code.gds-code  and ~
      bar-code.in-code   = ""                      and ~
      bar-code.part-code = ""
&scop OPEN-QUERY-scl-gds-old     {&OPEN-any-QUERY}


&scop where-code                                   and ~
      bar-code.gds-code  = base-bar-code.gds-code  and ~
      bar-code.in-code  <> ""
&scop OPEN-QUERY-par-gds      {&OPEN-any-QUERY}

&scop where-code                                   and ~
      bar-code.in-code   = ""                      and ~
      bar-code.part-code = ""
&scop OPEN-QUERY-scl-doc      {&OPEN-any-QUERY}

&scop where-code                                   and ~
      bar-code.in-code  <> ""
&scop OPEN-QUERY-par-doc      {&OPEN-any-QUERY}

&scop where-code
&scop OPEN-QUERY-doc          {&OPEN-any-QUERY}

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME {&frame-name}
     b-exit        AT ROW 1 COL 1
     b-mark        AT ROW 1 COL 9
     b-add         AT ROW 1 COL 15
     b-discnt      AT ROW 1 COL 23
     b-chg         AT ROW 1 COL 31
     b-del         AT ROW 1 COL 39
     b-help        AT ROW 1 COL 79
     round-method  AT ROW 2 COL 73 COLON-ALIGNED LABEL "Окру&гление"
        format "x(15)" VIEW-AS COMBO-BOX INNER-LINES 7 LIST-ITEMS
        {&pr-round-9end},
        {&pr-round-9-99end},
        {&pr-round-integer},
        {&pr-round-select},
        {&pr-round-up},
        {&pr-round-coef},
        {&pr-round-off} SIZE 15 BY 1  bgcolor WHITE_COLOR
     round-base    AT ROW 2    COL 88 COLON-ALIGNED no-LABEL
        format "->>,>>9.99" VIEW-AS FILL-IN SIZE 10 BY 1 bgcolor WHITE_COLOR
     loc-art       AT ROW 2.5  COL 39 COLON-ALIGNED label "Начало артикула"
     loc-name      AT ROW 2.5  COL 39 COLON-ALIGNED label "Начало названия" format "x(40)"
     loc-code      AT ROW 2.5  COL 39 COLON-ALIGNED label "Бар-код (весь)"  format "x(13)"
     br-alt       AT ROW 3    COL 1.5
     a-n-c         at row 1    col 78 no-label
     /* Информация по строке */
     rect-line     at row 13.6 col 1.5
     " Информация по строке " VIEW-AS TEXT SIZE 22 BY 0.8 AT ROW 13.1 COL 38
     price-list.price-sale
                   AT ROW 14.1 COL 80 COLON-ALIGNED label "Цена" fgcolor BROWN_COLOR
                   view-as fill-in size 15 by 0.79
     calc-price    AT ROW 15.1 COL 80 COLON-ALIGNED
     goods.artic   AT ROW 14.1 COL 10 COLON-ALIGNED label "Артикул"
                   view-as fill-in size 16 by 1
     goods.gds-name
                   AT ROW 14.1 COL 27 COLON-ALIGNED no-label fgcolor BROWN_COLOR
                   view-as fill-in size 35 by 1
     goods.prod-type
                   AT ROW 15.1 COL 10 COLON-ALIGNED label "Пр-тель"
                   view-as fill-in size 3 by 1
     goods.prod-code
                   AT ROW 15.1 COL 13 COLON-ALIGNED no-label
                   view-as fill-in size 9 by 1
     clients.obj-name
                   AT ROW 15.1 COL 27 COLON-ALIGNED no-label fgcolor BROWN_COLOR
                   view-as fill-in size 35 by 1
     gds-prt.f-name
                   AT ROW 16.1 COL 10 COLON-ALIGNED label "Признак" fgcolor BROWN_COLOR
                   view-as fill-in size 16 by 1
     bar-code.in-code
                   AT ROW 16.1 COL 27 COLON-ALIGNED label "ПН" fgcolor BROWN_COLOR
                   view-as fill-in size 16 by 1
     bar-code.part-code
                   AT ROW 16.1 COL 47 COLON-ALIGNED label "Партия" fgcolor BROWN_COLOR
                   view-as fill-in size 16 by 1
     SPACE(0) SKIP(0)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
         TITLE "Список неосновных цен":L
         DEFAULT-BUTTON b-exit
         bgcolor grey_color.

/* ***************  Runtime Attributes and UIB Settings  ************** */

ASSIGN
  FRAME {&frame-name}:SCROLLABLE = FALSE
  br-alt   :NUM-LOCKED-COLUMNS IN FRAME {&frame-name} = {&num-locked-columns-br-alt}
  b-add     :POPUP-MENU IN FRAME {&frame-name}         = MENU m-add  :HANDLE
  b-add     :MENU-MOUSE                                = 1
  .

/* ************************  Control Triggers  ************************ */
{ gbl/srt-clmd.i
&browse-name          = br-alt
&frame-name           = {&frame-name}
&table-name           = "price-list"
&ext-col              = 13
&start-column         = "{&num-locked-columns-br-alt} + 1"
&label-clmn_1         = "{&label-clmn_1-br-alt}"
&sort-clmn_1          = "{&clmn_1-br-alt}"
&dyn_sort-clmn_1      = "{&dyn_clmn_1-br-alt}"
&label-clmn_2         = "{&label-clmn_2-br-alt}"
&sort-clmn_2          = "{&clmn_2-br-alt}"
&label-clmn_3         = "{&label-clmn_3-br-alt}"
&sort-clmn_3          = "{&clmn_3-br-alt}"
&dyn_sort-clmn_3      = "{&dyn_clmn_3-br-alt}"
&label-clmn_4         = "{&label-clmn_4-br-alt}"
&sort-clmn_4          = "{&clmn_4-br-alt}"
&dyn_sort-clmn_4      = "{&dyn_clmn_4-br-alt}"
&label-clmn_5         = "{&label-clmn_5-br-alt}"
&sort-clmn_5          = "{&clmn_5-br-alt}"
&label-clmn_6         = "{&label-clmn_6-br-alt}"
&sort-clmn_6          = "{&clmn_6-br-alt}"
&dyn_sort-clmn_6      = "{&dyn_clmn_6-br-alt}"
&label-clmn_7         = "{&label-clmn_7-br-alt}"
&sort-clmn_7          = "{&clmn_7-br-alt}"
&label-clmn_8         = "{&label-clmn_8-br-alt}"
&sort-clmn_8          = "{&clmn_8-br-alt}"
&label-clmn_9         = "{&label-clmn_9-br-alt}"
&sort-clmn_9          = "{&clmn_9-br-alt}"
&label-clmn_10        = "{&label-clmn_10-br-alt}"
&sort-clmn_10         = "{&clmn_10-br-alt}"
&label-clmn_11        = "{&label-clmn_11-br-alt}"
&sort-clmn_11         = "{&clmn_11-br-alt}"
&label-clmn_12        = "dor-nal"
&sort-clmn_12         = "{&clmn_12-br-alt}"
&label-clmn_13        = "{&label-clmn_13-br-alt}"
&sort-clmn_13         = "{&clmn_13-br-alt}"
&before-sort          = " "
&open-query           = "run open-br."
&open-query-otherwise = "run open-br."
&sort-column-name     = "sort-column-name"
&re-move-clmn         = "no"
&mv-brw-default       = "no"
}

{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/f2.i br-alt  br-alt  goods  parParentProc  }

&global-define store-type    price-list.obj-type
&global-define store-code    price-list.obj-code
&global-define parparentproc parParentProc

{ str/sch-line.i price-list br-alt code-rec "l-price-list.doc-num = price-doc.doc-num and" }
end.

/* отключаем ненужные триггеры */
ON find OF goods DO: END.
ON find OF gds-obj DO: END.

on end-error of price-list.price-sale, price-list.road-tax, price-list.excise in browse br-alt do:
  disp {&disp-list} with browse br-alt.
  return no-apply.
end.

ON MOUSE-SELECT-DBLCLICK, return OF br-alt IN FRAME {&frame-name} DO:
apply "choose" to b-mark in frame {&frame-name}.
END.

ON CHOOSE OF b-mark IN FRAME {&frame-name} /* * */
DO:
{ gbl/stdbtn.i }
if not available price-list then
  return no-apply.
  { gbl/markstrn.i price-list mark-list }
br-alt :refresh ().
if last-event :function <> "mouse-select-dblclick" then
  br-alt :select-next-row ().
apply "entry" to br-alt in frame {&frame-name}.
END.

/* вывод строки в список */
on row-display of br-alt do:
  if sort-column-name <> "calc-dtl" /*:handle in browse br-alt*/ then
    /* сортировка по 1 столбцу не включена - раскрашиваем */
    if gds-prt.upper-code = goods.prt-root then
      if bar-code.in-code = '' then
        calc-dtl :fgcolor in browse br-alt = BLACK_COLOR.
      else
        calc-dtl :fgcolor in browse br-alt = BLUE_COLOR.
    else
      calc-dtl :fgcolor in browse br-alt = DARK_GREEN_COLOR.
end.

on value-changed of br-alt in frame {&frame-name} do:
  if not available price-list then do:
    hide calc-price
         price-list.price-sale
         goods.artic
         goods.gds-name
         goods.prod-type
         goods.prod-code
         clients.obj-name
         gds-prt.f-name
         bar-code.in-code
         bar-code.part-code in frame {&frame-name}.
    return no-apply.
  end.
  if doc-mode = {&update} then do:
    calc-price = fnc-base-price (bar-code.b-code, price-list.doc-num) *
                bar-code.cli-base-rate *
                (1 - price-list.d-pcnt / 100)
                .
    { str/pr-99.i
      calc-price
      "input frame {&frame-name} round-method"
      "input frame {&frame-name} round-base"
    }
    disp calc-price with frame {&frame-name}.
  end.
  else
    hide calc-price in frame {&frame-name}.
  find clients no-lock where
       clients.obj-type = goods.prod-type and
       clients.obj-code = goods.prod-code.
  disp price-list.price-sale
       goods.artic
       goods.gds-name
       goods.prod-type
       goods.prod-code
       clients.obj-name with frame {&frame-name}.
  if gds-prt.upper-code = goods.prt-root then
    hide gds-prt.f-name in frame {&frame-name}.
  else
    disp gds-prt.f-name with frame {&frame-name}.
  if bar-code.in-code = "" then
    hide bar-code.in-code bar-code.part-code in frame {&frame-name}.
  else
    disp bar-code.in-code bar-code.part-code with frame {&frame-name}.
end.

on leave of price-list.price-sale in browse br-alt or
   leave of price-list.d-pcnt     in browse br-alt or
   leave of price-list.road-tax   in browse br-alt or
   leave of price-list.excise     in browse br-alt do:
  if not available price-list then
    return.
  if decimal  (price-list.price-sale :screen-value in browse br-alt) <> price-list.price-sale or
     decimal  (price-list.d-pcnt     :screen-value in browse br-alt) <> price-list.d-pcnt or
     decimal  (price-list.road-tax   :screen-value in browse br-alt) <> price-list.road-tax or
     decimal  (price-list.excise     :screen-value in browse br-alt) <> price-list.excise then do:
    g#log = yes.
    message "Строка изменена. Записать это изменение?"
            view-as alert-box question buttons YES-NO update g#log.
    if g#log then
      run upd-br-field.
  end.
  /* в случае, если подтвердили, перевыводится уже новое значение;
     если нет - выводится старое и последующий assign (внутренний) перезапишет старое */
  disp {&disp-list} with browse br-alt.
  apply "value-changed" to br-alt in frame {&frame-name}.
end.

on return of price-list.price-sale in browse br-alt or
   return of price-list.d-pcnt     in browse br-alt or
   return of price-list.road-tax   in browse br-alt or
   return of price-list.excise     in browse br-alt do:
  if decimal  (price-list.price-sale :screen-value in browse br-alt) <> price-list.price-sale or
     decimal  (price-list.d-pcnt     :screen-value in browse br-alt) <> price-list.d-pcnt or
     decimal  (price-list.road-tax   :screen-value in browse br-alt) <> price-list.road-tax or
     decimal  (price-list.excise     :screen-value in browse br-alt) <> price-list.excise then
    run upd-br-field.
  /* перевыводится уже новое значение */
  disp {&disp-list} with browse br-alt.
  apply "value-changed" to br-alt in frame {&frame-name}.
end.

ON CHOOSE OF b-discnt in frame {&frame-name} DO:
{ gbl/stdbtn.i }
if not available price-list then do:
  message "Неправильно выбрана строка."
          view-as alert-box error.
  return no-apply.
end.
run calc-pr-discnt (input price-list.doc-num,
                    input bar-code.b-code) no-error.
disp {&disp-list} with browse br-alt.
apply "value-changed" to br-alt in frame {&frame-name}.
END.

ON CHOOSE OF b-chg in frame {&frame-name} DO:
{ gbl/stdbtn.i }
if not available price-list then do:
  message "Неправильно выбрана строка."
          view-as alert-box error.
  return no-apply.
end.
run calc-pr-alt (input price-list.doc-num,
                input bar-code.b-code,
                input round-method,
                input round-base) no-error.
disp {&disp-list} with browse br-alt.
apply "value-changed" to br-alt in frame {&frame-name}.
END.

ON return OF round-base IN FRAME {&frame-name} DO:
  apply "entry" to br-alt in frame {&frame-name}.
  return no-apply.
END.

on end-error, stop of frame {&frame-name} do:
  apply "choose" to b-exit in frame {&frame-name}.
  return no-apply.
end.

ON CHOOSE OF MENU-ITEM m-lst-add DO:
{ gbl/stdbtn.i b-add }
/* список всех неосновных кодов по основному */
run add-alt ("all").
END.

ON CHOOSE OF MENU-ITEM m-cur-add DO:
{ gbl/stdbtn.i b-add }
/* список неосновных кодов по основному, для которых уже есть цены */
run add-alt ("current").
END.

ON CHOOSE OF b-del in frame {&frame-name} DO:
{ gbl/stdbtn.i }
if not available price-list then do:
  message "Неправильно выбрана строка."
          view-as alert-box error.
  return no-apply.
end.
assign
  code-rec = recid (price-list)
  g#log = no
  .
message "Удалить строку документа?   Вы уверены?"
        view-as alert-box question buttons OK-Cancel update g#log.
if not g#log then
  return no-apply.
get next br-alt.
if available price-list then
  rep-rec = recid (price-list).
else do:
  reposition br-alt to recid code-rec no-error.
  get prev br-alt.
  if available price-list then
    rep-rec = recid (price-list).
end.
reposition br-alt to recid code-rec no-error.
find price-list where recid (price-list) = code-rec.
delete price-list.
code-rec = rep-rec.
doc-mode = {&update}.
run open-br.
END.

ON value-changed OF round-method IN FRAME {&frame-name} DO:
assign
  round-method.
run UI-on.
END.

ON LEAVE OF round-base IN FRAME {&frame-name} DO:
if input frame {&frame-name} round-base = 0 then do:
  if input frame {&frame-name} round-method = {&pr-round-select} then
    message "Такое округление невозможно - деление на 0."
            view-as alert-box error.
  else
    message "Пересчет по нулевому коэффициенту невозможен - получится 0."
            view-as alert-box error.
end.
else
  assign
    round-base.
disp round-base with frame {&frame-name}.
END.

/* ***************************  Main Block  *************************** */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ? THEN
  FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/app_help.i }

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

   run tax-name( input {&road-tax}, output  dor-nal) .
   assign {&clmn_12-br-alt} :label  = dor-nal.

  if doc-mode <> {&lookup} then
    code-rec = ?.                             /* reposition не нужен */
  find  price-doc no-lock where
        recid (price-doc) = doc-rec.
   define variable l-par as logical   no-undo .
   run chec-par in this-procedure (
         output l-par
        ,input  price-doc.host-code
        ,input  price-doc.obj-type
        ,input  price-doc.obj-code
      ) no-error .

/* основной код, если mode = code, scl-gds, par-gds, иначе не найдет */
  find  base-bar-code no-lock where
        base-bar-code.b-code = base-bc no-error.
  if available base-bar-code then
    find base-goods no-lock where
         base-goods.gds-code = base-bar-code.gds-code.
  case mode:
    when "code" then do:
    end.
    when "scl-gds" then do:
    end.
    when "par-gds" then do:
    end.
    when "scl-doc" then do:
    end.
    when "par-doc" then do:
    end.
    when "doc" then do:
    end.
  end case.
  run UI-on.
  run open-br.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-alt.
END.
RUN disable_UI.

/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME {&frame-name}.
END PROCEDURE.

PROCEDURE UI-on :
/* ------------------------------------------------------------------------------------------------------------------------*/
doc-rec = recid (price-doc). /* может быть поломан вызываемыми программами */
disable all with frame {&frame-name}.
hide loc-art loc-name loc-code in frame {&frame-name}.
loc-art = "".
enable a-n-c b-exit b-help br-alt with frame {&frame-name}.
frame {&frame-name}:title = "Список неосновных цен переоценки № " + price-doc.doc-num.
case mode:
  when "code"    then
    frame {&frame-name}:title = frame {&frame-name}:title +
                                "      Код: " + string (base-bc, ">>>>>>>>9").
  when "scl-gds" then
    frame {&frame-name}:title = frame {&frame-name}:title +
                                "      Товар: " + base-goods.artic + "  " + base-goods.gds-name +
                                "      ПРИЗНАКИ".
  when "par-gds" then
    frame {&frame-name}:title = frame {&frame-name}:title +
                                "      Товар: " + base-goods.artic + "  " + base-goods.gds-name +
                                "      ПАРТИИ".
  when "scl-doc" then
    frame {&frame-name}:title = frame {&frame-name}:title +
                                "      ПРИЗНАКИ по переоценке".
  when "par-doc" then
    frame {&frame-name}:title = frame {&frame-name}:title +
                                "      ПАРТИИ по переоценке".
  when "doc"     then
    frame {&frame-name}:title = frame {&frame-name}:title +
                                "      Вся переоценка".
end.
frame {&frame-name}:title = frame {&frame-name}:title + "              " +
                            doc-mode.
if doc-mode = {&lookup} then do:
  assign
&scop extra-act :read-only in browse br-alt = yes
    {&enable-list}
    .
  hide round-method in frame {&frame-name}.
end.
else do:
  assign
&scop extra-act :read-only in browse br-alt = no
    {&enable-list}
    .
  disp round-method round-base with frame {&frame-name}.
  if lookup (mode, "code,scl-gds,par-gds") > 0 then
    enable b-add with frame {&frame-name}.
  enable b-mark b-discnt b-chg b-del round-method with frame {&frame-name}.
  if lookup( input frame {&frame-name} round-method, {&pr-rounds-need-coef} ) > 0 then do:
    enable round-base with frame {&frame-name}.
    disp round-base with frame {&frame-name}.
  end.
  else
    hide round-base in frame {&frame-name}.
end.
apply "entry" to br-alt in frame {&frame-name}.
END PROCEDURE.

PROCEDURE open-br :
/* ------------------------------------------------------------------------------------------------------------------------*/
define variable l-query-was-opened as logical no-undo .
define variable sort-column-phrase as character     no-undo .
define variable d-num like price-doc.doc-num  no-undo.

assign
  l-query-was-opened = false
  d-num = price-doc.doc-num
  .


&scop flt-open-open-query open query br-alt for each price-list no-lock

&scop flt-open-dyn_open-query  for each price-list

&scop flt-open-query-handle query br-alt:handle

&scop flt-open-find-buffer-name price-list

&scop flt-open-open-query-tail , ~
        each bar-code no-lock where ~
             bar-code.b-code  = price-list.b-code , ~
        each goods no-lock where ~
             goods.gds-code   = bar-code.gds-code and ~
             goods.unit-base <> bar-code.unit-cli, ~
        each gds-prt no-lock where ~
             gds-prt.node-code = bar-code.node-code

if sort-column-name = "" then
   sort-column-phrase = "" .
else
  sort-column-phrase = "by " + sort-column-name.

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-query-was-opened  l-query-was-opened
&scop flt-open-call-point filter-point
&scop flt-open-set-filter-name
&scop flt-open-indexed-reposition
&scop flt-open-debug-file

if available price-list then
  code-rec = recid (price-list).
case mode:
  when 'code-old'    then do:
&scop flt-open-open-query-tail , ~
        each bar-code no-lock where ~
             bar-code.b-code    = price-list.b-code and ~
             bar-code.gds-code  = base-bar-code.gds-code  and ~
             bar-code.node-code = base-bar-code.node-code and ~
             bar-code.in-code   = base-bar-code.in-code   and ~
             bar-code.part-code = base-bar-code.part-code ~
             , ~
        each goods no-lock where ~
             goods.gds-code   = bar-code.gds-code and ~
             goods.unit-base <> bar-code.unit-cli, ~
        each gds-prt no-lock where ~
             gds-prt.node-code = bar-code.node-code


&scop flt-open-dyn_open-query-tail substitute(' , ~
        each bar-code no-lock where ~
             bar-code.b-code    = price-list.b-code and ~
             bar-code.gds-code  = &2 and ~
             bar-code.node-code = &3 and ~
             bar-code.in-code   = &1&4&1 and ~
             bar-code.part-code = &1&5&1 ~
             , ~
        each goods no-lock where ~
             goods.gds-code   = bar-code.gds-code and ~
             goods.unit-base <> bar-code.unit-cli, ~
        each gds-prt no-lock where ~
             gds-prt.node-code = bar-code.node-code  ~
              ', ~{&double-quote~}     ~
              , base-bar-code.gds-code  ~
              , base-bar-code.node-code ~
              , base-bar-code.in-code   ~
              , base-bar-code.part-code )



      { gbl/fltopend.i
        &where-cond = " ~
             price-list.doc-num = d-num and ~
             price-list.price-type = '' "
        &dyn_where-cond = " ~
             substitute ( ' price-list.doc-num = &2&1&2 and ~
                            price-list.price-type = &2&2 ', d-num , ~{&double-quote~} ) "

        &use-ind = " "
        &by = " "
      }
  end.

  when 'code'    then do:
&scop flt-open-open-query-tail , ~
        each bar-code no-lock where ~
             bar-code.b-code    = price-list.b-code and ~
             bar-code.gds-code  = base-bar-code.gds-code   ~
             , ~
        each goods no-lock where ~
             goods.gds-code   = bar-code.gds-code and ~
             goods.unit-base <> bar-code.unit-cli, ~
        each gds-prt no-lock where ~
             gds-prt.node-code = bar-code.node-code


&scop flt-open-dyn_open-query-tail substitute(' , ~
        each bar-code no-lock where ~
             bar-code.b-code    = price-list.b-code and ~
             bar-code.gds-code  = &2  ~
             , ~
        each goods no-lock where ~
             goods.gds-code   = bar-code.gds-code and ~
             goods.unit-base <> bar-code.unit-cli, ~
        each gds-prt no-lock where ~
             gds-prt.node-code = bar-code.node-code  ~
              ', ~{&double-quote~}     ~
              , base-bar-code.gds-code  ~
              , base-bar-code.node-code ~
              , base-bar-code.in-code   ~
              , base-bar-code.part-code )


        { gbl/fltopend.i
        &where-cond = " ~
             price-list.doc-num = d-num and ~
             price-list.price-type = '' "
        &dyn_where-cond = " ~
             substitute ( ' price-list.doc-num = &2&1&2 and ~
                            price-list.price-type = &2&2 ', d-num , ~{&double-quote~} ) "
        &use-ind = " "
        &by = " "
      }
  end.
  when 'scl-gds' then do:
&scop flt-open-open-query-tail , ~
        each bar-code no-lock where ~
             bar-code.b-code    = price-list.b-code and ~
             bar-code.gds-code  = base-bar-code.gds-code  and ~
             bar-code.node-code = base-bar-code.node-code and ~
             bar-code.in-code   = ''   and ~
             bar-code.part-code = ''  ~
             , ~
        each goods no-lock where ~
             goods.gds-code   = bar-code.gds-code and ~
             goods.unit-base <> bar-code.unit-cli, ~
        each gds-prt no-lock where ~
             gds-prt.node-code = bar-code.node-code


&scop flt-open-dyn_open-query-tail substitute(' , ~
        each bar-code no-lock where ~
             bar-code.b-code    = price-list.b-code and ~
             bar-code.gds-code  = &2 and ~
             bar-code.node-code = &3 and ~
             bar-code.in-code   = &1&1 and ~
             bar-code.part-code = &1&1 ~
             , ~
        each goods no-lock where ~
             goods.gds-code   = bar-code.gds-code and ~
             goods.unit-base <> bar-code.unit-cli, ~
        each gds-prt no-lock where ~
             gds-prt.node-code = bar-code.node-code  ~
              ', ~{&double-quote~}     ~
              , base-bar-code.gds-code  ~
              , base-bar-code.node-code ~
              , base-bar-code.in-code   ~
              , base-bar-code.part-code )

      { gbl/fltopend.i
        &where-cond = " ~
             price-list.doc-num = d-num and ~
             price-list.price-type = '' "
        &dyn_where-cond = " ~
             substitute ( ' price-list.doc-num = &2&1&2 and ~
                            price-list.price-type = &2&2 ', d-num , ~{&double-quote~} ) "

        &use-ind = " "
        &by = " "
      }
  end.
  when 'par-gds' then do:
&scop flt-open-open-query-tail , ~
        each bar-code no-lock where ~
             bar-code.b-code    = price-list.b-code and ~
             bar-code.gds-code  = base-bar-code.gds-code  and ~
             bar-code.in-code   <> '' ~
             , ~
        each goods no-lock where ~
             goods.gds-code   = bar-code.gds-code and ~
             goods.unit-base <> bar-code.unit-cli, ~
        each gds-prt no-lock where ~
             gds-prt.node-code = bar-code.node-code


&scop flt-open-dyn_open-query-tail substitute(' , ~
        each bar-code no-lock where ~
             bar-code.b-code    = price-list.b-code and ~
             bar-code.gds-code  = &2 and ~
             bar-code.in-code   <> &1&&1 ~
             , ~
        each goods no-lock where ~
             goods.gds-code   = bar-code.gds-code and ~
             goods.unit-base <> bar-code.unit-cli, ~
        each gds-prt no-lock where ~
             gds-prt.node-code = bar-code.node-code  ~
              ', ~{&double-quote~}     ~
              , base-bar-code.gds-code  ~
              )

      { gbl/fltopend.i
        &where-cond = " ~
             price-list.doc-num = d-num and ~
             price-list.price-type = '' "
        &dyn_where-cond = " ~
             substitute ( ' price-list.doc-num = &2&1&2 and ~
                            price-list.price-type = &2&2 ', d-num , ~{&double-quote~} ) "
        &use-ind = " "
        &by = " "
      }
  end.
  when 'scl-doc' then do:
&scop flt-open-open-query-tail , ~
        each bar-code no-lock where ~
             bar-code.b-code    = price-list.b-code and ~
             bar-code.in-code   = '' and ~
             bar-code.part-code = ''  ~
             , ~
        each goods no-lock where ~
             goods.gds-code   = bar-code.gds-code and ~
             goods.unit-base <> bar-code.unit-cli, ~
        each gds-prt no-lock where ~
             gds-prt.node-code = bar-code.node-code


&scop flt-open-dyn_open-query-tail substitute(' , ~
        each bar-code no-lock where ~
             bar-code.b-code    = price-list.b-code and ~
             bar-code.in-code   = &1&4&1 and ~
             bar-code.part-code = &1&5&1 ~
             , ~
        each goods no-lock where ~
             goods.gds-code   = bar-code.gds-code and ~
             goods.unit-base <> bar-code.unit-cli, ~
        each gds-prt no-lock where ~
             gds-prt.node-code = bar-code.node-code  ~
              ', ~{&double-quote~}     ~
              , base-bar-code.gds-code  ~
              , base-bar-code.node-code ~
              , base-bar-code.in-code   ~
              , base-bar-code.part-code )

      { gbl/fltopend.i
        &where-cond = " ~
             price-list.doc-num = d-num and ~
             price-list.price-type = '' "
        &dyn_where-cond = " ~
             substitute ( ' price-list.doc-num = &2&1&2 and ~
                            price-list.price-type = &2&2 ', d-num , ~{&double-quote~} ) "

        &use-ind = " "
        &by = " "
      }
  end.
  when 'par-doc' then do:
&scop flt-open-open-query-tail , ~
        each bar-code no-lock where ~
             bar-code.b-code    = price-list.b-code and ~
             bar-code.in-code   <> '' ~
             , ~
        each goods no-lock where ~
             goods.gds-code   = bar-code.gds-code and ~
             goods.unit-base <> bar-code.unit-cli, ~
        each gds-prt no-lock where ~
             gds-prt.node-code = bar-code.node-code


&scop flt-open-dyn_open-query-tail substitute(' , ~
        each bar-code no-lock where ~
             bar-code.b-code    = price-list.b-code and ~
             bar-code.in-code   <> &1&&1 ~
             , ~
        each goods no-lock where ~
             goods.gds-code   = bar-code.gds-code and ~
             goods.unit-base <> bar-code.unit-cli, ~
        each gds-prt no-lock where ~
             gds-prt.node-code = bar-code.node-code  ~
              ', ~{&double-quote~}     ~
              , base-bar-code.gds-code  ~
              , base-bar-code.node-code ~
              , base-bar-code.in-code   ~
              , base-bar-code.part-code )

      { gbl/fltopend.i
        &where-cond = " ~
             price-list.doc-num = d-num and ~
             price-list.price-type = '' "
        &dyn_where-cond = " ~
             substitute ( ' price-list.doc-num = &2&1&2 and ~
                            price-list.price-type = &2&2 ', d-num , ~{&double-quote~} ) "

        &use-ind = " "
        &by = " "
      }
  end.
  when 'doc'     then do:
&scop flt-open-open-query-tail , ~
        each bar-code no-lock where ~
             bar-code.b-code    = price-list.b-code ~
             , ~
        each goods no-lock where ~
             goods.gds-code   = bar-code.gds-code and ~
             goods.unit-base <> bar-code.unit-cli, ~
        each gds-prt no-lock where ~
             gds-prt.node-code = bar-code.node-code

&scop flt-open-dyn_open-query-tail substitute(' , ~
        each bar-code no-lock where ~
             bar-code.b-code    = price-list.b-code ~
             , ~
        each goods no-lock where ~
             goods.gds-code   = bar-code.gds-code and ~
             goods.unit-base <> bar-code.unit-cli, ~
        each gds-prt no-lock where ~
             gds-prt.node-code = bar-code.node-code  ~
              ', ~{&double-quote~}     ~
              , base-bar-code.gds-code  ~
              , base-bar-code.node-code ~
              , base-bar-code.in-code   ~
              , base-bar-code.part-code )

      { gbl/fltopend.i
        &where-cond = " ~
             price-list.doc-num = d-num and ~
             price-list.price-type = '' "
        &dyn_where-cond = " ~
             substitute ( ' price-list.doc-num = &2&1&2 and ~
                            price-list.price-type = &2&2 ', d-num , ~{&double-quote~} ) "
        &use-ind = " "
        &by = " "
      }
  end.
end case.
if code-rec <> ? then
  reposition br-alt to recid code-rec no-error.
apply "entry" to br-alt in frame {&frame-name}.
apply "value-changed" to br-alt in frame {&frame-name}.
END PROCEDURE.

PROCEDURE add-alt :
/* ------------------------------------------------------------------------------------------------------------------------*/
/* добавление строк из списка неосновных кодов                                                                             */
/* ------------------------------------------------------------------------------------------------------------------------*/
define input  parameter add-list as character  no-undo.  /* current - список имеющихся, all - все неосновные */

define variable rec-list as character     no-undo.
define variable num-rec  as integer no-undo.

/* список неосновных кодов
   добавление строк работает только если mode = code, scl-gds, par-gds (кнопка b-add enable)
   при этом base-goods, base-bc в порядке
*/
run ref/alt-cds.w  ( parParentProc
                ,input price-doc.obj-type
                ,input price-doc.obj-code
                ,input (mode + "-" + add-list)
                ,input base-goods.gds-code
                ,input base-bc
                ,output rec-list).
apply "entry" to br-alt in frame {&frame-name}.
if rec-list = '' then
  return no-apply.
/* никуда не делать reposition */
code-rec = ?.

define variable v-1 as integer   no-undo .
v-1 = num-entries (rec-list) .
do num-rec = 1 to v-1 :
  ref-rec = integer (entry (num-rec, rec-list)).
  find bar-code no-lock where
       recid (bar-code) = ref-rec.
  run cre-pr-list (input  bar-code.b-code,
                   input  price-doc.doc-num,     /* номер заполняемой переоценки */
                   output code-rec) no-error.
  if error-status:error then do:
    message
      "Ошибка cre-pr-list." skip
      "Код:" bar-code.b-code
      view-as alert-box.
    next.
  end.
  run calc-pr-alt (input price-doc.doc-num,
                   input bar-code.b-code,
                   input round-method,
                   input round-base) no-error.
  if error-status:error then
    next.
end.
doc-mode = {&update}.
run open-br.
END PROCEDURE.

procedure upd-br-field:
  /* NO-LOCK !!! */
  find current price-list.
  if decimal  (price-list.price-sale :screen-value in browse br-alt) <> price-list.price-sale then do:
    /* изменилась цена - записываем, что она была изменена вручную */
    assign
      price-list.calc-method = {&pr-calc-no}
      price-list.price-calc = price-list.price-sale
      price-list.price-sale = decimal  (price-list.price-sale :screen-value in browse br-alt)
      .
    if price-list.d-pcnt = ? then do:
      /*
      run calc-pr-discnt (input price-list.doc-num,
                          input price-list.b-code) no-error.
      */
    end.
  end.
  else do:
    if decimal  (price-list.d-pcnt     :screen-value in browse br-alt) <> price-list.d-pcnt then do:
      /* изменилась скидка - записываем это изменение и пересчитываем цены */
      price-list.d-pcnt     = decimal  (price-list.d-pcnt     :screen-value in browse br-alt).
      if price-list.d-pcnt <> ? then do: /* пересчитаем если не ? */
          run calc-pr-alt (input price-doc.doc-num,
                           input price-list.b-code,
                           input round-method,
                           input round-base) no-error.
          if error-status:error then
             return error.
      end.
    end.
    else
      /* изменены налоги */
      assign
        /* этот триггер срабатывает до присваивания */
        price-list.road-tax   = decimal  (price-list.road-tax   :screen-value in browse br-alt)
        price-list.excise     = decimal  (price-list.excise     :screen-value in browse br-alt)
        .
  end.
end procedure.
procedure exp-prt:
  /* ------------------------------------------------------------------------------------------------------------------------
    разворачивание спеццен по главной цене, если есть настройки
    ------------------------------------------------------------------------------------------------------------------------*/
  define input  parameter  g-code  like ub.goods.gds-code    no-undo.
  define input  parameter  old-num like ub.price-doc.doc-num no-undo.
  define input  parameter  new-num like ub.price-doc.doc-num no-undo.
  define output parameter  new-rec as recid               no-undo.

  define buffer buf-bar-code   for ub.bar-code.
  define buffer buf-goods      for ub.goods.
  define buffer buf-price-list for ub.price-list.

  find buf-goods no-lock where
      buf-goods.gds-code = g-code.

  /* Добавлять имеющиеся неосновные цены */
  if par-pr-altex = "yes" and
     par-pr-notls = "yes" then do:
    { str/alt-calc.i pr-altex old-num new-num }
  end.

  /* Добавлять имеющиеся цены признаков */
  if par-pr-sclex = "yes" and
    par-pr-notls = "yes" then do:
    { str/alt-calc.i pr-sclex old-num new-num }
  end.
  end procedure.

{ gbl/tax-name.i }