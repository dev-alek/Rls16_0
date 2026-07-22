/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список неосновных цен ДНЦ

Автор: Чернова Светлана Александровна
Дата создания: 09/08/05
Author: Svetlana Chernova
Creation date: 09/08/05


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
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-doc-rec  as recid no-undo .
define input  parameter doc-mode as character no-undo .
define input  parameter mode     as character no-undo . /* основной код, если mode = code, scl-gds, par-gds, иначе ? */
define input  parameter p-b-code like ub.bar-code.b-code   no-undo.
define input-output parameter round-method as character    no-undo. /* способ округления */
define input-output parameter round-base   as decimal no-undo. /* база для округления / коэффициент */
define input-output parameter v-sec as integer   no-undo .

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список неосновных цен приказа переоценки".
{ cmp/vssrevis.i }

define buffer buf_price-doc-forming for ub.price-doc-forming  .
define new shared buffer buf_base_bar-code for ub.bar-code.                 /* буфер бар-кода основного */
define buffer buf_base_goods    for ub.goods.                    /* буфер товара основного */

define variable mark       as character                     no-undo. /* отметка в списке */
define variable mark-list  as character                     no-undo. /* список отметок */
define variable arg-base   like ub.price-doc-forming-gds.price-sale-doc no-undo. /* для вывода в список цены основного кода */
define variable calc-dtl   as character                     no-undo. /* для вывода в список детализации */
define variable main-bc-br like ub.bar-code.b-code       no-undo. /* для вывода в список глав. кода */
define variable v-base-b-code like ub.bar-code.b-code       no-undo. /* для вывода в список осн. кода */
define variable v-line-num   as integer   no-undo .
define variable ref-list  as character                     no-undo.
define variable code-rec  as recid                    no-undo.

define variable filter-point as character no-undo init "mpl-alt" .

{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ str/getctxtp.i def }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i get }
{ gbl/color.i    }

{ str/libbcrcn.i }
{ gbl/tax-name.i }
{ str/hvrdtax.i  }
{ str/lib-trn.i  }
{ ref/xobjgrp.i  }  /* список объектов  */
{ str/alt-calc.i func }
{ str/alt-calc.i "ver-modificator-price-is-null" }
{ str/alt-calc.i proc }
{ str/mpl-lib.i  }
{ trg/check-bc.i }
{ gbl/fltopend.i defproc }

define buffer l-price-doc-forming-gds for ub.price-doc-forming-gds.                /* для поиска  */

/* для дор налога */
define variable   rdtaxcdvalue  as character initial ? no-undo.
define variable   rdtaxcdtype   as character initial ? no-undo.
define buffer     rt_tax            for ub.tax.
define variable dor-nal as character no-undo .
define variable g#log as logical   no-undo .
define variable gds-rec as recid no-undo .
define variable rep-rec as recid no-undo .
define variable ref-rec as recid no-undo .

define new shared buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds.
define new shared buffer buf_bar-code   for ub.bar-code.
define new shared buffer buf_goods      for ub.goods.
define new shared buffer buf_gds-prt    for ub.gds-prt.

define new shared QUERY br-alt for buf_price-doc-forming-gds except, buf_bar-code, buf_goods, buf_gds-prt SCROLLING.

define variable sort-column-name as character no-undo .

&SCOP label-clmn_1-br-alt  '*'
&SCOP clmn_1-br-alt        fnc-mark (Buf_price-doc-forming-gds.b-code)
&SCOP dyn_clmn_1-br-alt    substitute('dynamic-function(&1fnc-mark&1,  Buf_price-doc-forming-gds.b-code )' , ~{&double-quote~})
&SCOP label-clmn_2-br-alt  'Тип'
&SCOP clmn_2-br-alt ~
      if buf_gds-prt.upper-code = buf_goods.prt-root then ~
        if buf_bar-code.in-code = '' then ~
          {&goods} ~
        else ~
          {&part} ~
      else ~
        {&property}
&SCOP label-clmn_3-br-alt  'Глав. код'
&SCOP clmn_3-br-alt        fnc-main-code (Buf_price-doc-forming-gds.b-code)
&SCOP dyn_clmn_3-br-alt    substitute('dynamic-function(&1fnc-main-code&1,  Buf_price-doc-forming-gds.b-code )' , ~{&double-quote~})
&SCOP label-clmn_4-br-alt  'Осн. код'
&SCOP clmn_4-br-alt        fnc-base-code (Buf_price-doc-forming-gds.b-code)
&SCOP dyn_clmn_4-br-alt    substitute('dynamic-function(&1fnc-base-code&1, Buf_price-doc-forming-gds.b-code )' , ~{&double-quote~})
&SCOP label-clmn_5-br-alt  'Код'
&SCOP clmn_5-br-alt         buf_bar-code.b-code
&SCOP label-clmn_6-br-alt  'Осн. цена'
&SCOP clmn_6-br-alt        fnc-base-price-doc (Buf_price-doc-forming-gds.b-code, recid(buf_price-doc-forming) )
&SCOP dyn_clmn_6-br-alt    substitute('dynamic-function(&1fnc-base-price-doc&1, ( Buf_price-doc-forming-gds.b-code ), (&1&2&1)) ' , ~{&double-quote~},  recid(buf_price-doc-forming) )
&SCOP label-clmn_7-br-alt  'Изм'
&SCOP clmn_7-br-alt        buf_goods.unit-base
&SCOP label-clmn_8-br-alt  'Коэф'
&SCOP clmn_8-br-alt        buf_bar-code.cli-base-rate
&SCOP label-clmn_9-br-alt  'Скидка'
&SCOP clmn_9-br-alt        buf_price-doc-forming-gds.d-pcnt
&SCOP label-clmn_10-br-alt  'Цена'
&SCOP clmn_10-br-alt        buf_price-doc-forming-gds.price-sale-doc
&SCOP label-clmn_11-br-alt 'Изм'
&SCOP clmn_11-br-alt        buf_bar-code.unit-cli

&SCOP clmn_12-br-alt        buf_price-doc-forming-gds.road-tax-doc
&SCOP label-clmn_13-br-alt  'Акциз'
&SCOP clmn_13-br-alt        buf_price-doc-forming-gds.excise-doc
&SCOP NUM-LOCKED-COLUMNS-br-alt 1
&SCOP disp-list-color ~
{&clmn_1-br-alt}   @ mark                 COLUMN-LABEL {&label-clmn_1-br-alt}  FORMAT "x(1)" ~
{&clmn_2-br-alt}   @ calc-dtl             COLUMN-LABEL {&label-clmn_2-br-alt}  FORMAT "x(3)" ~
{&clmn_3-br-alt}   @ main-bc-br           COLUMN-LABEL {&label-clmn_3-br-alt}  ~
{&clmn_4-br-alt}   @ v-base-b-code        COLUMN-LABEL {&label-clmn_4-br-alt}  ~
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
{&clmn_4-br-alt}   @ v-base-b-code        COLUMN-LABEL {&label-clmn_4-br-alt}  ~
{&clmn_5-br-alt}                          COLUMN-LABEL {&label-clmn_5-br-alt}  ~
{&clmn_6-br-alt}   @ arg-base             COLUMN-LABEL {&label-clmn_6-br-alt}  ~
{&clmn_7-br-alt}                          COLUMN-LABEL {&label-clmn_7-br-alt}  FORMAT "x(3)"  ~
{&clmn_8-br-alt}                          COLUMN-LABEL {&label-clmn_8-br-alt}  ~
{&clmn_9-br-alt}                          COLUMN-LABEL {&label-clmn_9-br-alt}  ~
{&clmn_10-br-alt}                         COLUMN-LABEL {&label-clmn_10-br-alt}  ~
{&clmn_11-br-alt}                         COLUMN-LABEL {&label-clmn_11-br-alt} FORMAT "x(3)"  ~
{&clmn_12-br-alt}                          ~
{&clmn_13-br-alt}                         COLUMN-LABEL {&label-clmn_13-br-alt} ~
buf_price-doc-forming-gds.price-sale-rubl  ~
buf_price-doc-forming-gds.price-sale-base


&SCOP enable-list ~
{&clmn_9-br-alt} ~{&extra-act~} ~
{&clmn_10-br-alt} ~{&extra-act~} ~
{&clmn_12-br-alt} ~{&extra-act~} ~
{&clmn_13-br-alt} ~{&extra-act~}

/* ---------------------------- FUNCTIONS --------------------------------- */
FUNCTION fnc-mark RETURN character (local-bc as integer).
define buffer local-price-doc-forming-gds for ub.price-doc-forming-gds.
  find first local-price-doc-forming-gds no-lock where
             local-price-doc-forming-gds.b-code     = local-bc and
             local-price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             local-price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
             local-price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             local-price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num
             no-error.
  if not available local-price-doc-forming-gds then  return (?).
  if lookup (string (recid (local-price-doc-forming-gds)), mark-list) > 0 then
    return "*".
  else
    return "".
END FUNCTION.

FUNCTION fnc-main-code RETURN integer (local-bc as integer).
define variable local-main-code like ub.bar-code.b-code no-undo.
   run prc-main-code (input local-bc, output local-main-code).
return (local-main-code).
END FUNCTION.

FUNCTION fnc-base-code RETURN integer (local-bc as integer).
define variable local-base-code like ub.bar-code.b-code no-undo.
run prc-base-code (input local-bc, output local-base-code).
return (local-base-code).
END FUNCTION.

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

define variable loc-art  AS character VIEW-AS fill-in size 14 by 1 fgcolor RED_COLOR no-undo.
define variable loc-name AS character VIEW-AS fill-in size 20 by 1 fgcolor RED_COLOR no-undo.
define variable loc-code AS character VIEW-AS fill-in size 20 by 1 fgcolor RED_COLOR no-undo.

define variable conf-par     as character no-undo.    /* для чтения параметра конфигурации */

define variable a-n-c AS character VIEW-AS RADIO-SET horizontal RADIO-BUTTONS
"&А","art",
"&Н","name",
"&К","code"
SIZE 12 BY 1 no-undo.

DEFINE BROWSE br-alt QUERY br-alt NO-LOCK
    DISPLAY {&disp-list-color}
    buf_price-doc-forming-gds.price-sale-rubl  COLUMN-LABEL  "Цена (нац.вал.)"
    buf_price-doc-forming-gds.price-sale-base  COLUMN-LABEL  "Цена (баз.вал.)"
&scop extra-act
    ENABLE {&enable-list}
    WITH SIZE 98 BY 10.5
    bgcolor WHITE_COLOR
    separators.

&scop OPEN-any-QUERY ~
  OPEN QUERY br-alt ~
    FOR EACH buf_price-doc-forming-gds no-lock WHERE ~
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and ~
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and ~
             buf_price-doc-forming-gds.plt-id         = buf_price-doc-forming.plt-id and ~
             buf_price-doc-forming-gds.plt-db-num     = buf_price-doc-forming.plt-db-num  ~
             , ~
        each buf_bar-code no-lock where ~
             buf_bar-code.b-code = buf_price-doc-forming-gds.b-code ~
             ~{&where-code~}, ~
        EACH buf_goods no-lock where ~
             buf_goods.gds-code = buf_bar-code.gds-code and ~
             buf_goods.unit-base <> buf_bar-code.unit-cli, ~
        EACH buf_gds-prt no-lock WHERE ~
             buf_gds-prt.node-code = buf_bar-code.node-code

&scop where-code                                   and ~
      buf_bar-code.gds-code  = buf_base_bar-code.gds-code
&scop OPEN-QUERY-code         {&OPEN-any-QUERY}

&scop where-code-old                               and ~
      buf_bar-code.gds-code  = buf_base_bar-code.gds-code  and ~
      buf_bar-code.node-code = buf_base_bar-code.node-code and ~
      buf_bar-code.in-code   = buf_base_bar-code.in-code   and ~
      buf_bar-code.part-code = buf_base_bar-code.part-code
&scop OPEN-QUERY-code-old         {&OPEN-any-QUERY}

&scop where-code                                   and ~
      buf_bar-code.gds-code  = buf_base_bar-code.gds-code  and ~
      buf_bar-code.node-code = buf_base_bar-code.node-code and ~
      buf_bar-code.in-code   = ""                      and ~
      buf_bar-code.part-code = ""
&scop OPEN-QUERY-scl-gds      {&OPEN-any-QUERY}

&scop where-code                                   and ~
      buf_bar-code.gds-code  = buf_base_bar-code.gds-code  and ~
      buf_bar-code.in-code   = ""                      and ~
      buf_bar-code.part-code = ""
&scop OPEN-QUERY-scl-gds-old     {&OPEN-any-QUERY}


&scop where-code                                   and ~
      buf_bar-code.gds-code  = buf_base_bar-code.gds-code  and ~
      buf_bar-code.in-code  <> ""
&scop OPEN-QUERY-par-gds      {&OPEN-any-QUERY}

&scop where-code                                   and ~
      buf_bar-code.in-code   = ""                      and ~
      buf_bar-code.part-code = ""
&scop OPEN-QUERY-scl-doc      {&OPEN-any-QUERY}

&scop where-code                                   and ~
      buf_bar-code.in-code  <> ""
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
     br-alt        AT ROW 3    COL 1.5
     a-n-c         at row 1    col 88 no-label
     /* Информация по строке */
     rect-line     at row 13.6 col 1.5
     " Информация по строке " VIEW-AS TEXT SIZE 22 BY 0.8 AT ROW 13.1 COL 38
     buf_price-doc-forming-gds.price-sale-doc
                   AT ROW 14.1 COL 80 COLON-ALIGNED label "Цена" fgcolor BROWN_COLOR
                   view-as fill-in size 15 by 0.79
     calc-price    AT ROW 15.1 COL 80 COLON-ALIGNED
     buf_goods.artic   AT ROW 14.1 COL 10 COLON-ALIGNED label "Артикул"
                   view-as fill-in size 16 by 1
     buf_goods.gds-name
                   AT ROW 14.1 COL 27 COLON-ALIGNED no-label fgcolor BROWN_COLOR
                   view-as fill-in size 35 by 1
     buf_goods.prod-type
                   AT ROW 15.1 COL 10 COLON-ALIGNED label "Пр-тель"
                   view-as fill-in size 3 by 1
     buf_goods.prod-code
                   AT ROW 15.1 COL 13 COLON-ALIGNED no-label
                   view-as fill-in size 9 by 1
     clients.obj-name
                   AT ROW 15.1 COL 27 COLON-ALIGNED no-label fgcolor BROWN_COLOR
                   view-as fill-in size 35 by 1
     buf_gds-prt.f-name
                   AT ROW 16.1 COL 10 COLON-ALIGNED label "Признак" fgcolor BROWN_COLOR
                   view-as fill-in size 16 by 1
     buf_bar-code.in-code
                   AT ROW 16.1 COL 27 COLON-ALIGNED label "ПН" fgcolor BROWN_COLOR
                   view-as fill-in size 16 by 1
     buf_bar-code.part-code
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
&table-name           = "buf_price-doc-forming-gds"
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
{ gbl/f2.i br-alt  br-alt  goods  parParentProc }

&global-define store-type    p-obj-type
&global-define store-code    p-obj-code
&global-define parparentproc parParentProc


on end-error of buf_price-doc-forming-gds.price-sale-doc, buf_price-doc-forming-gds.road-tax-doc, buf_price-doc-forming-gds.excise-doc in browse br-alt do:
  display  {&disp-list} with browse br-alt.
  return no-apply.
end.

ON MOUSE-SELECT-DBLCLICK, return OF br-alt IN FRAME {&frame-name} DO:
apply "choose" to b-mark in frame {&frame-name}.
END.

ON CHOOSE OF b-mark IN FRAME {&frame-name} /* * */
DO:
{ gbl/stdbtn.i }
if not available buf_price-doc-forming-gds then
  return no-apply.
  { gbl/markstrn.i buf_price-doc-forming-gds mark-list }
br-alt :refresh ().
if last-event :function <> "mouse-select-dblclick" then
  br-alt :select-next-row ().
apply "entry" to br-alt in frame {&frame-name}.
END.

/* вывод строки в список */
on row-display of br-alt do:
  if sort-column-name <> "calc-dtl" /*:handle in browse br-alt*/ then
    /* сортировка по 1 столбцу не включена - раскрашиваем */
    if buf_gds-prt.upper-code = buf_goods.prt-root then
      if buf_bar-code.in-code = '' then
        calc-dtl :fgcolor in browse br-alt = BLACK_COLOR.
      else
        calc-dtl :fgcolor in browse br-alt = BLUE_COLOR.
    else
      calc-dtl :fgcolor in browse br-alt = DARK_GREEN_COLOR.
end.

on value-changed of br-alt in frame {&frame-name} do:
  if not available buf_price-doc-forming-gds then do:
    hide calc-price
         buf_price-doc-forming-gds.price-sale-doc
         buf_goods.artic
         buf_goods.gds-name
         buf_goods.prod-type
         buf_goods.prod-code
         clients.obj-name
         buf_gds-prt.f-name
         buf_bar-code.in-code
         buf_bar-code.part-code in frame {&frame-name}.
    return no-apply.
  end.
  if doc-mode = {&update} then do:
    calc-price = fnc-base-price-doc (buf_bar-code.b-code, recid (buf_price-doc-forming)) *
                buf_bar-code.cli-base-rate *
                (1 - buf_price-doc-forming-gds.d-pcnt / 100)
                .
    { str/pr-99.i
      calc-price
      "input frame {&frame-name} round-method"
      "input frame {&frame-name} round-base"
    }
    display  calc-price with frame {&frame-name}.
  end.
  else
    hide calc-price in frame {&frame-name}.
  find clients no-lock where
       clients.obj-type = buf_goods.prod-type and
       clients.obj-code = buf_goods.prod-code.
  display  buf_price-doc-forming-gds.price-sale-doc
       buf_goods.artic
       buf_goods.gds-name
       buf_goods.prod-type
       buf_goods.prod-code
       clients.obj-name with frame {&frame-name}.
  if buf_gds-prt.upper-code = buf_goods.prt-root then
    hide buf_gds-prt.f-name in frame {&frame-name}.
  else
    display  buf_gds-prt.f-name with frame {&frame-name}.
  if buf_bar-code.in-code = "" then
    hide buf_bar-code.in-code buf_bar-code.part-code in frame {&frame-name}.
  else
    display  buf_bar-code.in-code buf_bar-code.part-code with frame {&frame-name}.
end.

on leave of buf_price-doc-forming-gds.price-sale-doc in browse br-alt or
   leave of buf_price-doc-forming-gds.d-pcnt     in browse br-alt or
   leave of buf_price-doc-forming-gds.road-tax-doc   in browse br-alt or
   leave of buf_price-doc-forming-gds.excise-doc     in browse br-alt do:
  if not available buf_price-doc-forming-gds then
    return.
  if decimal  (buf_price-doc-forming-gds.price-sale-doc :screen-value in browse br-alt) <> buf_price-doc-forming-gds.price-sale-doc or
     decimal  (buf_price-doc-forming-gds.d-pcnt     :screen-value in browse br-alt) <> buf_price-doc-forming-gds.d-pcnt or
     decimal  (buf_price-doc-forming-gds.road-tax-doc   :screen-value in browse br-alt) <> buf_price-doc-forming-gds.road-tax-doc or
     decimal  (buf_price-doc-forming-gds.excise-doc     :screen-value in browse br-alt) <> buf_price-doc-forming-gds.excise-doc then do:
    g#log = yes.
    message "Строка изменена. Записать это изменение?"
            view-as alert-box question buttons YES-NO update g#log.
    if g#log then do:
      if decimal  (buf_price-doc-forming-gds.d-pcnt     :screen-value in browse br-alt) <> buf_price-doc-forming-gds.d-pcnt then do:
        run upd-br-field.
        run calc-price-alt in this-procedure (
             input  buf_price-doc-forming-gds.b-code
            ,input recid(buf_price-doc-forming)
            ,input  d-pcnt
            ,input  round-method
            ,input  round-base
            ,output buf_price-doc-forming-gds.price-sale-base
            ,output buf_price-doc-forming-gds.price-sale-doc
            ,output buf_price-doc-forming-gds.price-sale-rubl
            ) no-error .
      end.
      else do:
        run upd-br-field.
        run calc-price-discnt in this-procedure (
            input recid(buf_price-doc-forming),
            input buf_bar-code.b-code
            ) no-error.
      end.
    end.
  end.
  /* в случае, если подтвердили, перевыводится уже новое значение;
     если нет - выводится старое и последующий assign (внутренний) перезапишет старое */
  display  {&disp-list} with browse br-alt.
  apply "value-changed" to br-alt in frame {&frame-name}.
end.

on return of buf_price-doc-forming-gds.price-sale-doc in browse br-alt or
   return of buf_price-doc-forming-gds.d-pcnt     in browse br-alt or
   return of buf_price-doc-forming-gds.road-tax-doc   in browse br-alt or
   return of buf_price-doc-forming-gds.excise-doc     in browse br-alt do:
  if decimal  (buf_price-doc-forming-gds.price-sale-doc :screen-value in browse br-alt) <> buf_price-doc-forming-gds.price-sale-doc or
     decimal  (buf_price-doc-forming-gds.d-pcnt     :screen-value in browse br-alt) <> buf_price-doc-forming-gds.d-pcnt or
     decimal  (buf_price-doc-forming-gds.road-tax-doc   :screen-value in browse br-alt) <> buf_price-doc-forming-gds.road-tax-doc or
     decimal  (buf_price-doc-forming-gds.excise-doc     :screen-value in browse br-alt) <> buf_price-doc-forming-gds.excise-doc then
      if decimal  (buf_price-doc-forming-gds.d-pcnt     :screen-value in browse br-alt) <> buf_price-doc-forming-gds.d-pcnt then do:
        run upd-br-field.
        run calc-price-alt in this-procedure (
             input  buf_price-doc-forming-gds.b-code
            ,input recid(buf_price-doc-forming)
            ,input  d-pcnt
            ,input  round-method
            ,input  round-base
            ,output buf_price-doc-forming-gds.price-sale-base
            ,output buf_price-doc-forming-gds.price-sale-doc
            ,output buf_price-doc-forming-gds.price-sale-rubl
            ) no-error .
      end.
      else do:
        run upd-br-field.
        run calc-price-discnt in this-procedure (
            input recid(buf_price-doc-forming),
            input buf_bar-code.b-code
            ) no-error.
      end.

  /* перевыводится уже новое значение */
  display  {&disp-list} with browse br-alt.
  apply "value-changed" to br-alt in frame {&frame-name}.
end.

ON CHOOSE OF b-exit in frame {&frame-name} DO:
{ gbl/stdbtn.i }
/*

бесполезно так ка скидка имеет формат в БД decimals 2

define variable v-sale-base  as decimal   no-undo .
define variable v-sale-doc   as decimal   no-undo .
define variable v-sale-rubl  as decimal   no-undo .
  for each buf_price-doc-forming-gds no-lock where
          buf_price-doc-forming-gds.b-code     <> p-b-code and
          buf_price-doc-forming-gds.artic      = buf_goods.artic and
          buf_price-doc-forming-gds.prod-type  = buf_goods.prod-type and
          buf_price-doc-forming-gds.prod-code  = buf_goods.prod-code and
          buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
          buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
          buf_price-doc-forming-gds.plt-id         = buf_price-doc-forming.plt-id and
          buf_price-doc-forming-gds.plt-db-num     = buf_price-doc-forming.plt-db-num
           :
        run calc-price-alt in this-procedure
            (input  buf_price-doc-forming-gds.b-code
            ,input recid(buf_price-doc-forming)
            ,input  buf_price-doc-forming-gds.d-pcnt
            ,input  round-method
            ,input  round-base
            ,output v-sale-base
            ,output v-sale-doc
            ,output v-sale-rubl
            ) no-error .
     if v-sale-doc <> buf_price-doc-forming-gds.price-sale-doc
     then do:
        message substitute("Проверьте строку c бар-кодом &1 на соответствие скидки &4   и суммы  &2  &3  !" ,
         buf_price-doc-forming-gds.b-code ,
         v-sale-doc ,
         buf_price-doc-forming-gds.price-sale-doc ,
         buf_price-doc-forming-gds.d-pcnt
         ) view-as alert-box title "Предупреждение".
     end.
  end.
  */
end.


ON CHOOSE OF b-discnt in frame {&frame-name} DO:
{ gbl/stdbtn.i }
if not available buf_price-doc-forming-gds then do:
  message "Неправильно выбрана строка."
          view-as alert-box error.
  return no-apply.
end.
run calc-price-discnt in this-procedure
    (
    input recid(buf_price-doc-forming),
    input buf_bar-code.b-code
    ) no-error.
display  {&disp-list} with browse br-alt.
apply "value-changed" to br-alt in frame {&frame-name}.
END.

ON CHOOSE OF b-chg in frame {&frame-name} DO:
{ gbl/stdbtn.i }
if not available buf_price-doc-forming-gds then do:
  message "Неправильно выбрана строка."
          view-as alert-box error.
  return no-apply.
end.
  find current buf_price-doc-forming-gds exclusive-lock no-error .
  run calc-price-alt in this-procedure
      (input  buf_price-doc-forming-gds.b-code
      ,input recid(buf_price-doc-forming)
      ,input  d-pcnt
      ,input  round-method
      ,input  round-base
      ,output buf_price-doc-forming-gds.price-sale-base
      ,output buf_price-doc-forming-gds.price-sale-doc
      ,output buf_price-doc-forming-gds.price-sale-rubl
      ).

display  {&disp-list} with browse br-alt.
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
 /*run add-alt ("scl-gds-all").*/

END.

ON CHOOSE OF b-del in frame {&frame-name} DO:
{ gbl/stdbtn.i }
if not available buf_price-doc-forming-gds then do:
  message "Неправильно выбрана строка."
          view-as alert-box error.
  return no-apply.
end.
assign
  code-rec = recid (buf_price-doc-forming-gds)
  g#log = no
  .
message "Удалить строку документа?   Вы уверены?"
        view-as alert-box question buttons OK-Cancel update g#log.
if not g#log then
  return no-apply.
get next br-alt.
if available buf_price-doc-forming-gds then
  rep-rec = recid (buf_price-doc-forming-gds).
else do:
  reposition br-alt to recid code-rec no-error.
  get prev br-alt.
  if available buf_price-doc-forming-gds then
    rep-rec = recid (buf_price-doc-forming-gds).
end.
reposition br-alt to recid code-rec no-error.
find first buf_price-doc-forming-gds exclusive-lock where recid (buf_price-doc-forming-gds) = code-rec .
delete buf_price-doc-forming-gds.
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
display  round-base with frame {&frame-name}.
END.

/* ***************************  Main Block  *************************** */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ? THEN
  FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/app_help.i }

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  /* Параметры из секции ПЕРЕОЦЕНКА */
  define variable l-par as logical   no-undo .
    run chec-par in this-procedure (
          output l-par
          ,input  v-cntxt-host-code-obj
          ,input  v-cntxt-obj-type
          ,input  v-cntxt-obj-code
        ) no-error .

   run tax-name( input {&road-tax}, output  dor-nal) .
   assign {&clmn_12-br-alt} :label  = dor-nal.

  if doc-mode <> {&lookup} then
    code-rec = ?.                             /* reposition не нужен */
  find first buf_price-doc-forming no-lock where
        recid (buf_price-doc-forming) = p-doc-rec.
/* основной код, если mode = code, scl-gds, par-gds, иначе не найдет */
  find first buf_base_bar-code no-lock where
             buf_base_bar-code.b-code = p-b-code no-error.
  if available buf_base_bar-code then
    find first buf_base_goods no-lock where
               buf_base_goods.gds-code = buf_base_bar-code.gds-code.
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

disable all with frame {&frame-name}.
hide loc-art loc-name loc-code in frame {&frame-name}.
loc-art = "".
enable a-n-c b-exit b-help br-alt with frame {&frame-name}.
frame {&frame-name}:title = "Список неосновных цен ДНЦ № " + string(buf_price-doc-forming.pdf-id).
case mode:
  when "code"    then
    frame {&frame-name}:title = frame {&frame-name}:title +
                                "      Код: " + string (p-b-code, ">>>>>>>>9").
  when "scl-gds" then
    frame {&frame-name}:title = frame {&frame-name}:title +
                                "      Товар: " + buf_base_goods.artic + "  " + buf_base_goods.gds-name +
                                "      ПРИЗНАКИ".
  when "par-gds" then
    frame {&frame-name}:title = frame {&frame-name}:title +
                                "      Товар: " + buf_base_goods.artic + "  " + buf_base_goods.gds-name +
                                "      ПАРТИИ".
  when "scl-doc" then
    frame {&frame-name}:title = frame {&frame-name}:title +
                                "      ПРИЗНАКИ по ДНЦ".
  when "par-doc" then
    frame {&frame-name}:title = frame {&frame-name}:title +
                                "      ПАРТИИ по ДНЦ".
  when "doc"     then
    frame {&frame-name}:title = frame {&frame-name}:title +
                                "      Все по ДНЦ".
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
  display  round-method round-base with frame {&frame-name}.
  if lookup (mode, "code,scl-gds,par-gds") > 0 then
    enable b-add with frame {&frame-name}.
  enable b-mark b-discnt b-chg b-del round-method with frame {&frame-name}.
  if lookup( input frame {&frame-name} round-method, {&pr-rounds-need-coef} ) > 0 then do:
    enable round-base with frame {&frame-name}.
    display  round-base with frame {&frame-name}.
  end.
  else
    hide round-base in frame {&frame-name}.
end.
apply "entry" to br-alt in frame {&frame-name}.
END PROCEDURE.

PROCEDURE open-br :
/* ------------------------------------------------------------------------------------------------------------------------*/
define variable l-query-was-opened as logical no-undo .
define variable sort-column-phrase as character    no-undo .
define variable d-num like ub.price-doc-forming.pdf-id  no-undo.
define variable d-db  like ub.price-doc-forming.pdf-db  no-undo.

assign
  l-query-was-opened = false
  d-num = buf_price-doc-forming.pdf-id
  d-db = buf_price-doc-forming.pdf-db
  .

&scop flt-open-open-query open query br-alt  for each buf_price-doc-forming-gds no-lock

&scop flt-open-dyn_open-query  FOR EACH BUF_PRICE-DOC-FORMING-GDS

&scop flt-open-query-handle query br-alt:handle

&scop flt-open-find-buffer-name buf_price-doc-forming-gds

&scop flt-open-open-query-tail  , ~
        each buf_bar-code no-lock  where  ~
             buf_bar-code.b-code    = buf_price-doc-forming-gds.b-code , ~
        each buf_goods no-lock where ~
             buf_goods.gds-code = buf_bar-code.gds-code and ~
             buf_goods.unit-base <> buf_bar-code.unit-cli , ~
        each buf_gds-prt no-lock where ~
             buf_gds-prt.node-code = buf_bar-code.node-code

&scop flt-open-dyn_open-query-tail substitute(' , each buf_bar-code no-lock where buf_bar-code.b-code = buf_price-doc-forming-gds.b-code  ~
 ,  each buf_goods no-lock where ~
         buf_goods.gds-code = buf_bar-code.gds-code and ~
         buf_goods.unit-base <> buf_bar-code.unit-cli , ~
    each buf_gds-prt no-lock where ~
         buf_gds-prt.node-code = buf_bar-code.node-code ', ~{&double-quote~})


if sort-column-name = "" then
  sort-column-phrase = "".
else
  sort-column-phrase = "by " + sort-column-name.

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-query-was-opened  l-query-was-opened
&scop flt-open-call-point filter-point
&scop flt-open-set-filter-name
&scop flt-open-table-name buf_price-doc-forming-gds
&scop flt-open-indexed-reposition
&scop flt-open-debug-file

if available buf_price-doc-forming-gds then
  code-rec = recid (buf_price-doc-forming-gds).
case mode:
  when 'code-old'    then do:

 &scop flt-open-open-query-tail , ~
        each buf_bar-code no-lock  where ~
              buf_bar-code.b-code    = buf_price-doc-forming-gds.b-code  and ~
              buf_bar-code.gds-code  = buf_base_bar-code.gds-code  and ~
              buf_bar-code.node-code = buf_base_bar-code.node-code and ~
              buf_bar-code.in-code   = buf_base_bar-code.in-code   and ~
              buf_bar-code.part-code = buf_base_bar-code.part-code , ~
        each buf_goods no-lock where ~
             buf_goods.gds-code = buf_bar-code.gds-code and ~
             buf_goods.unit-base <> buf_bar-code.unit-cli , ~
        each buf_gds-prt no-lock where ~
             buf_gds-prt.node-code = buf_bar-code.node-code

&scop flt-open-dyn_open-query-tail substitute(' , each buf_bar-code no-lock where buf_bar-code.b-code = buf_price-doc-forming-gds.b-code  ~
              buf_bar-code.gds-code  = &2 and ~
              buf_bar-code.node-code = &3 and ~
              buf_bar-code.in-code   = &1&4&1 and ~
              buf_bar-code.part-code = &1&5&1 , ~
 ,  each buf_goods no-lock where ~
         buf_goods.gds-code = buf_bar-code.gds-code and ~
         buf_goods.unit-base <> buf_bar-code.unit-cli , ~
    each buf_gds-prt no-lock where ~
         buf_gds-prt.node-code = buf_bar-code.node-code ', ~{&double-quote~} , ~
         buf_base_bar-code.gds-code , ~
         buf_base_bar-code.node-code , ~
         buf_base_bar-code.in-code ,  ~
         buf_base_bar-code.part-code  )


      { gbl/fltopend.i
        &where-cond     = " buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db  "
        &dyn_where-cond = " substitute(' buf_price-doc-forming-gds.pdf-id =  &1 and buf_price-doc-forming-gds.pdf-db =  &2 ' , d-num , d-db) "
        &use-ind = " "
        &by = " "
      }
  end.

  when 'code'    then do:
&scop flt-open-open-query-tail , ~
        each buf_bar-code no-lock where ~
            buf_bar-code.b-code    = buf_price-doc-forming-gds.b-code  and ~
            buf_bar-code.gds-code  = buf_base_bar-code.gds-code   ~
        , ~
        each buf_goods no-lock where ~
             buf_goods.gds-code = buf_bar-code.gds-code and ~
             buf_goods.unit-base <> buf_bar-code.unit-cli , ~
        each buf_gds-prt no-lock where ~
             buf_gds-prt.node-code = buf_bar-code.node-code

&scop flt-open-dyn_open-query-tail substitute(' , each buf_bar-code no-lock where buf_bar-code.b-code = buf_price-doc-forming-gds.b-code and buf_bar-code.gds-code  = &2 ~
 ,  each buf_goods no-lock where ~
         buf_goods.gds-code = buf_bar-code.gds-code and ~
         buf_goods.unit-base <> buf_bar-code.unit-cli , ~
    each buf_gds-prt no-lock where ~
         buf_gds-prt.node-code = buf_bar-code.node-code ', ~{&double-quote~} , buf_base_bar-code.gds-code  )

        { gbl/fltopend.i
        &where-cond     = " buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db  "
        &dyn_where-cond = " substitute(' buf_price-doc-forming-gds.pdf-id =  &1 and buf_price-doc-forming-gds.pdf-db =  &2 ' , d-num , d-db) "
        &use-ind = " "
        &by = " "
      }
  end.
  when 'scl-gds' then do:
&scop flt-open-open-query-tail , ~
        each buf_bar-code no-lock where ~
             buf_bar-code.b-code    = buf_price-doc-forming-gds.b-code  and ~
             buf_bar-code.gds-code  = buf_base_bar-code.gds-code  and ~
             buf_bar-code.node-code = buf_base_bar-code.node-code and ~
             buf_bar-code.in-code   = ''                          and ~
             buf_bar-code.part-code = ''    ~
        , ~
        each buf_goods no-lock where ~
             buf_goods.gds-code = buf_bar-code.gds-code and ~
             buf_goods.unit-base <> buf_bar-code.unit-cli , ~
        each buf_gds-prt no-lock where ~
             buf_gds-prt.node-code = buf_bar-code.node-code


&scop flt-open-dyn_open-query-tail substitute(' , each buf_bar-code no-lock where buf_bar-code.b-code = buf_price-doc-forming-gds.b-code and ~
         buf_bar-code.gds-code  = &3   and ~
         buf_bar-code.node-code = &4   and ~
         buf_bar-code.in-code   = &1&1 and ~
         buf_bar-code.part-code = &1&1 ~
 ,  each buf_goods no-lock where ~
         buf_goods.gds-code   = buf_bar-code.gds-code and ~
         buf_goods.unit-base <> buf_bar-code.unit-cli , ~
    each buf_gds-prt no-lock where ~
         buf_gds-prt.node-code = buf_bar-code.node-code ', ~{&double-quote~} , ~
         buf_base_bar-code.gds-code  , ~
         buf_base_bar-code.node-code ~
         )


      { gbl/fltopend.i
        &where-cond     = " buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db  "
        &dyn_where-cond = " substitute(' buf_price-doc-forming-gds.pdf-id =  &1 and buf_price-doc-forming-gds.pdf-db =  &2 ' , d-num , d-db) "
        &use-ind = " "
        &by = " "
      }
  end.

  when 'par-gds' then do:
&scop flt-open-open-query-tail , ~
        each buf_bar-code no-lock where ~
             buf_bar-code.b-code    = buf_price-doc-forming-gds.b-code  and ~
             buf_bar-code.gds-code  = buf_base_bar-code.gds-code  and ~
             buf_bar-code.in-code  <> '' ~
        , ~
        each buf_goods no-lock where ~
             buf_goods.gds-code = buf_bar-code.gds-code and ~
             buf_goods.unit-base <> buf_bar-code.unit-cli , ~
        each buf_gds-prt no-lock where ~
             buf_gds-prt.node-code = buf_bar-code.node-code

&scop flt-open-dyn_open-query-tail substitute(' , each buf_bar-code no-lock where buf_bar-code.b-code = buf_price-doc-forming-gds.b-code and ~
          buf_bar-code.gds-code  = and &2 ~
          buf_bar-code.in-code  <> &1&1 ~
 ,  each buf_goods no-lock where ~
         buf_goods.gds-code = buf_bar-code.gds-code and ~
         buf_goods.unit-base <> buf_bar-code.unit-cli , ~
    each buf_gds-prt no-lock where ~
         buf_gds-prt.node-code = buf_bar-code.node-code ' ,  ~{&double-quote~} , buf_base_bar-code.gds-code )

      { gbl/fltopend.i
        &where-cond     = " buf_price-doc-forming-gds.pdf-id = d-num and buf_price-doc-forming-gds.pdf-db = d-db  "
        &dyn_where-cond = " substitute(' buf_price-doc-forming-gds.pdf-id =  &1 and buf_price-doc-forming-gds.pdf-db =  &2 ' , d-num , d-db) "
        &use-ind = " "
        &by = " "
      }
  end.
  when 'scl-doc' then do:
&scop flt-open-open-query-tail , ~
        each buf_bar-code no-lock where ~
              buf_bar-code.b-code    = buf_price-doc-forming-gds.b-code and ~
              buf_bar-code.in-code   = ''                      and ~
              buf_bar-code.part-code = '' ~
        , ~
        each buf_goods no-lock where ~
             buf_goods.gds-code = buf_bar-code.gds-code and ~
             buf_goods.unit-base <> buf_bar-code.unit-cli , ~
        each buf_gds-prt no-lock where ~
             buf_gds-prt.node-code = buf_bar-code.node-code

&scop flt-open-dyn_open-query-tail substitute(' , each buf_bar-code no-lock where buf_bar-code.b-code = buf_price-doc-forming-gds.b-code  and ~
              buf_bar-code.in-code   = &1&1  and ~
              buf_bar-code.part-code = &1&1 ~
  ,  each buf_goods no-lock where ~
         buf_goods.gds-code = buf_bar-code.gds-code and ~
         buf_goods.unit-base <> buf_bar-code.unit-cli , ~
    each buf_gds-prt no-lock where ~
         buf_gds-prt.node-code = buf_bar-code.node-code ', ~{&double-quote~})

      { gbl/fltopend.i
        &where-cond     = " buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db  "
        &dyn_where-cond = " substitute(' buf_price-doc-forming-gds.pdf-id =  &1 and buf_price-doc-forming-gds.pdf-db =  &2 ' , d-num , d-db) "
        &use-ind = " "
        &by = " "
      }
  end.
  when 'par-doc' then do:

&scop flt-open-open-query-tail , ~
        each buf_bar-code no-lock where ~
             buf_bar-code.b-code    = buf_price-doc-forming-gds.b-code       and ~
             buf_bar-code.in-code  <> '' ~
        , ~
        each buf_goods no-lock where ~
             buf_goods.gds-code = buf_bar-code.gds-code and ~
             buf_goods.unit-base <> buf_bar-code.unit-cli , ~
        each buf_gds-prt no-lock where ~
             buf_gds-prt.node-code = buf_bar-code.node-code

&scop flt-open-dyn_open-query-tail substitute(' , each buf_bar-code no-lock where buf_bar-code.b-code = buf_price-doc-forming-gds.b-code and ~
    buf_bar-code.in-code  <> &1&1 ~
 ,  each buf_goods no-lock where ~
         buf_goods.gds-code = buf_bar-code.gds-code and ~
         buf_goods.unit-base <> buf_bar-code.unit-cli , ~
    each buf_gds-prt no-lock where ~
         buf_gds-prt.node-code = buf_bar-code.node-code ', ~{&double-quote~})

      { gbl/fltopend.i
        &where-cond     = " buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db  "
        &dyn_where-cond = " substitute(' buf_price-doc-forming-gds.pdf-id =  &1 and buf_price-doc-forming-gds.pdf-db =  &2 ' , d-num , d-db) "
        &use-ind = " "
        &by = " "
      }
  end.
  when 'doc'     then do:
&scop flt-open-open-query-tail , ~
        each buf_bar-code no-lock where ~
             buf_bar-code.b-code    = buf_price-doc-forming-gds.b-code ~
        , ~
        each buf_goods no-lock where ~
             buf_goods.gds-code = buf_bar-code.gds-code and ~
             buf_goods.unit-base <> buf_bar-code.unit-cli , ~
        each buf_gds-prt no-lock where ~
             buf_gds-prt.node-code = buf_bar-code.node-code

&scop flt-open-dyn_open-query-tail substitute(' , each buf_bar-code no-lock where buf_bar-code.b-code = buf_price-doc-forming-gds.b-code  ~
 ,  each buf_goods no-lock where ~
         buf_goods.gds-code = buf_bar-code.gds-code and ~
         buf_goods.unit-base <> buf_bar-code.unit-cli , ~
    each buf_gds-prt no-lock where ~
         buf_gds-prt.node-code = buf_bar-code.node-code ', ~{&double-quote~})

      { gbl/fltopend.i
        &where-cond     = " buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db  "
        &dyn_where-cond = " substitute(' buf_price-doc-forming-gds.pdf-id =  &1 and buf_price-doc-forming-gds.pdf-db =  &2 ' , d-num , d-db) "
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
define input parameter add-list as character no-undo.  /* current - список имеющихся, all - все неосновные */

define variable d-pcnt as decimal   no-undo .

define variable rec-list as character  no-undo.
define variable num-rec  as integer    no-undo.
define variable v-price-calc-base as decimal   no-undo .
define variable v-price-calc-doc  as decimal   no-undo .
define variable v-price-calc-rubl as decimal   no-undo .
define variable v-price-prev-base as decimal   no-undo .
define variable v-price-prev-doc  as decimal   no-undo .
define variable v-price-prev-rubl as decimal   no-undo .
define variable v-price-sale-base as decimal   no-undo .
define variable v-price-sale-doc  as decimal   no-undo .
define variable v-price-sale-rubl as decimal   no-undo .
define variable v-road-tax-base   as decimal   no-undo .
define variable v-road-tax-doc    as decimal   no-undo .
define variable v-road-tax-rubl   as decimal   no-undo .
define variable v-excise-base     as decimal   no-undo .
define variable v-excise-doc      as decimal   no-undo .
define variable v-excise-rubl     as decimal   no-undo .
define variable v-vat-pc          as decimal   no-undo .
define variable v-slt-pc          as decimal   no-undo .

define buffer bb_bar-code for ub.bar-code  .

/* список неосновных кодов
   добавление строк работает только если mode = code, scl-gds, par-gds (кнопка b-add enable)
   при этом buf_base_goods, p-b-code в порядке
*/
run ref/alt-cds.w
    ( parParentProc
    ,input p-obj-type
    ,input p-obj-code
    ,input (mode + "-" + add-list)
    ,input buf_base_goods.gds-code
    ,input p-b-code
    ,output rec-list).
apply "entry" to br-alt in frame {&frame-name}.
if rec-list = '' then
  return no-apply.
/* никуда не делать reposition */
code-rec = ?.

run last-num ( input recid(buf_price-doc-forming) , output v-line-num ) .
define variable v-nn as integer   no-undo .
v-nn = num-entries (rec-list) .
do num-rec = 1 to v-nn :
  ref-rec = integer (entry (num-rec, rec-list)).
  find first bb_bar-code no-lock where recid (bb_bar-code) = ref-rec .

/* d-pcnt ищется как последняя  */
define variable v-cur-dn as character no-undo .
define variable v-cur-pr as decimal no-undo .
define variable v-cur-rt as decimal no-undo .
define variable v-cur-ex as decimal no-undo .

{ gbl/bcodeprc.i
    p-obj-type
    p-obj-code
    bb_bar-code.b-code
    0
    0
    v-cur-dn
    v-cur-pr
    v-cur-rt
    v-cur-ex }

define buffer old1_price-list    for ub.price-list  .

find first old1_price-list no-lock where
           old1_price-list.doc-num     = v-cur-dn      and
           old1_price-list.price-type  = ""            and
           old1_price-list.b-code      = bb_bar-code.b-code
           no-error .

if available old1_price-list then do:
   d-pcnt = old1_price-list.d-pcnt .
end.
else do:
  d-pcnt = 0 .
end.

    run calc-price-alt in this-procedure
      ( input  bb_bar-code.b-code
      , input recid(buf_price-doc-forming)
      , input  d-pcnt
      , input  round-method
      , input  round-base
      , output v-price-sale-base
      , output v-price-sale-doc
      , output v-price-sale-rubl
        ).

    v-line-num = v-line-num + 1 .

    define buffer bb_price-doc-forming-gds for ub.price-doc-forming-gds  .

    find first bb_price-doc-forming-gds no-lock where
               bb_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
               bb_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id     and
               bb_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db     and
               bb_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id     and
               bb_price-doc-forming-gds.artic      = buf_base_goods.artic             and
               bb_price-doc-forming-gds.prod-type  = buf_base_goods.prod-type         and
               bb_price-doc-forming-gds.prod-code  = buf_base_goods.prod-code         no-error .
    if available bb_price-doc-forming-gds then
    assign
      v-vat-pc = bb_price-doc-forming-gds.vat-pc
      v-slt-pc = bb_price-doc-forming-gds.slt-pc
      .
    else
    assign
      v-vat-pc = 0
      v-slt-pc = 0
      .

    run create-line  in this-procedure (
       buf_price-doc-forming.plt-db-num
      ,buf_price-doc-forming.plt-id
      ,buf_price-doc-forming.pdf-db
      ,buf_price-doc-forming.pdf-id
      ,v-line-num
      ,bb_bar-code.b-code
      ,buf_base_goods.artic
      ,buf_base_goods.prod-type
      ,buf_base_goods.prod-code
      ,{&pr-calc-base}
      ,d-pcnt
      ,buf_price-doc-forming.have-start-period
      ,buf_price-doc-forming.start-date
      ,buf_price-doc-forming.start-shift-date
      ,buf_price-doc-forming.start-shift-name
      ,buf_price-doc-forming.start-shift-num
      ,buf_price-doc-forming.start-sys-date
      ,buf_price-doc-forming.start-sys-time
      ,buf_price-doc-forming.have-end-period
      ,buf_price-doc-forming.end-date
      ,buf_price-doc-forming.end-shift-date
      ,buf_price-doc-forming.end-shift-name
      ,buf_price-doc-forming.end-shift-num
      ,buf_price-doc-forming.end-sys-date
      ,buf_price-doc-forming.end-sys-time
      ,v-price-calc-base
      ,v-price-calc-doc
      ,v-price-calc-rubl
      ,v-price-prev-base
      ,v-price-prev-doc
      ,v-price-prev-rubl
      ,v-price-sale-base
      ,v-price-sale-doc
      ,v-price-sale-rubl
      ,v-road-tax-base
      ,v-road-tax-doc
      ,v-road-tax-rubl
      ,v-excise-base
      ,v-excise-doc
      ,v-excise-rubl
      ,v-vat-pc
      ,v-slt-pc
      ,""
      ,0
      ,input-output v-sec
      ) .

end.
run open-br.
END PROCEDURE.

procedure upd-br-field:
  find current buf_price-doc-forming-gds share-lock.
  if decimal  (buf_price-doc-forming-gds.price-sale-doc :screen-value in browse br-alt) <> buf_price-doc-forming-gds.price-sale-doc then do:
    /* изменилась цена - записываем, что она была изменена вручную */
    assign
      buf_price-doc-forming-gds.calc-method = {&pr-calc-no}
      buf_price-doc-forming-gds.price-calc-doc  = buf_price-doc-forming-gds.price-sale-doc
      buf_price-doc-forming-gds.price-sale-doc  = decimal  (buf_price-doc-forming-gds.price-sale-doc :screen-value in browse br-alt)
      buf_price-doc-forming-gds.price-sale-rubl = buf_price-doc-forming-gds.price-sale-doc * buf_price-doc-forming.exch-rate / buf_price-doc-forming.exch-scale .
      buf_price-doc-forming-gds.price-sale-base = buf_price-doc-forming-gds.price-sale-rubl / buf_price-doc-forming.base-rate * buf_price-doc-forming.base-scale .
      .

    if buf_price-doc-forming-gds.d-pcnt = ? then do:
      /*
      run calc-price-discnt (input recid(buf_price-doc-forming),
                             input price-doc-forming-gds.b-code) no-error.
      */
    end.
  end.
  else do:
    if decimal  (buf_price-doc-forming-gds.d-pcnt     :screen-value in browse br-alt) <> buf_price-doc-forming-gds.d-pcnt then do:
      /* изменилась скидка - записываем это изменение и пересчитываем цены */
      buf_price-doc-forming-gds.d-pcnt     = decimal  (buf_price-doc-forming-gds.d-pcnt     :screen-value in browse br-alt).
      if buf_price-doc-forming-gds.d-pcnt <> ? then do: /* пересчитаем если не ? */
        run calc-price-alt in this-procedure
            (input  buf_price-doc-forming-gds.b-code
            ,input recid(buf_price-doc-forming)
            ,input  buf_price-doc-forming-gds.d-pcnt
            ,input  round-method
            ,input  round-base
            ,output buf_price-doc-forming-gds.price-sale-base
            ,output buf_price-doc-forming-gds.price-sale-doc
            ,output buf_price-doc-forming-gds.price-sale-rubl
            ) no-error .
              if error-status:error then
                 return error.
      end.
    end.
    else
      /* изменены налоги */
      assign
        /* этот триггер срабатывает до присваивания */
        buf_price-doc-forming-gds.road-tax-doc   = decimal  (buf_price-doc-forming-gds.road-tax-doc   :screen-value in browse br-alt)
        buf_price-doc-forming-gds.excise-doc     = decimal  (buf_price-doc-forming-gds.excise-doc     :screen-value in browse br-alt)
        .
  end.
end procedure.