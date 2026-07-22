/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/09/05
Author: Bakhtadze Natalya
Creation date: 09/09/05

{1} = goo-doc : browse строится по goods. Фильтр : {&all}.
{1} = gob-doc : browse строится по gds-obj. Фильтры : "объект, факт, свободно".
{2} = assortment-matrix : browse строится по gds-obj + assortment-matrix-goods. Фильтры : "объект, факт, свободно".

Author:  Андрей Исаков, мод-ции - Черных В.
Created: 15.08.96

g-rep - глобальный recid, здесь используется для репозиции на нужную запись
        как при входе в справочник извне (в т.ч. при переключении goo-doc<->gob-doc),
        так и при смене g-list (Справочник) или g-cond (Фильтр), т.е. всякий раз
        при open query (процедура openbr).

rid-list - вых. параметр, список выбранных recid'ов.

sch-rec - используется стандартно в include sch-line.i, = recid (текущей строки) только в
               случае поиска по артикулу.

*/
&if "{2}" = "assortment-matrix" &then
&scop table2    , gam-doc
&scop f-table2   no-lock , first gam-doc no-lock where ~
                                 gam-doc.gds-code = gob-doc.gds-code and ~
                                 gam-doc.asmg-status_    = 0 and ~
                                 gam-doc.obj-type = gob-doc.obj-type and ~
                                 gam-doc.obj-code = gob-doc.obj-code
&else
&scop table2
&scop f-table2
&endif

&scop cant-positioning ~
  find first pos_goods no-lock where ~
      recid( pos_goods ) = pos-rec no-error . ~
  message ~
    "Невозможно позиционироваться на товаре" skip ~
     string( if available pos_goods ~
             then  ( pos_goods.artic + ~{&space-char~} + pos_goods.prod-type + " ":U + ~
             string( pos_goods.prod-code ) + " ":U + pos_goods.gds-name ) ~
             else "":U ) skip ~
    "Товар был добавлен (или изменен или удален) -" skip ~
    "и теперь не попадает в текущую выборку" ~
  view-as alert-box WARNING.

&scop net-proc ~
if not available {1} then do: ~
  message ~
    "Неправильно выбран товар." ~
  view-as alert-box error. ~
  return no-apply. ~
end. ~
&if "{1}" = "gob-doc" &then ~
FIND FIRST goo-doc WHERE goo-doc.artic     = gob-doc.artic ~
                     AND goo-doc.prod-type = gob-doc.prod-type ~
                     AND goo-doc.prod-code = gob-doc.prod-code NO-LOCK. ~
&endif ~
assign ~
  gds-rec = recid( goo-doc ) ~
.


&scop net-proc-loc ~
if not available loc-{1} then do: ~
  message ~
    "Неправильно выбран товар." ~
  view-as alert-box error. ~
  return no-apply. ~
end. ~
&if "{1}" = "gob-doc" &then ~
FIND FIRST loc-goo-doc WHERE loc-goo-doc.artic     = loc-gob-doc.artic ~
                         AND loc-goo-doc.prod-type = loc-gob-doc.prod-type ~
                         AND loc-goo-doc.prod-code = loc-gob-doc.prod-code NO-LOCK. ~
&endif ~
assign ~
  gds-rec = recid( loc-goo-doc ) ~
.


&scop net-proc-proc ~
if not available {1} then do: ~
  message ~
    "Неправильно выбран товар." ~
  view-as alert-box error. ~
  return error. ~
end. ~
&if "{1}" = "gob-doc" &then ~
FIND FIRST goo-doc WHERE goo-doc.artic     = gob-doc.artic ~
                     AND goo-doc.prod-type = gob-doc.prod-type ~
                     AND goo-doc.prod-code = gob-doc.prod-code NO-LOCK. ~
&endif ~
assign ~
  gds-rec = recid( goo-doc ) ~
.

&scop net-proc-proc-loc ~
if not available loc-{1} then do: ~
  message ~
    "Неправильно выбран товар." ~
  view-as alert-box error. ~
  return error. ~
end. ~
&if "{1}" = "gob-doc" &then ~
FIND FIRST loc-goo-doc WHERE loc-goo-doc.artic     = loc-gob-doc.artic ~
                         AND loc-goo-doc.prod-type = loc-gob-doc.prod-type ~
                         AND loc-goo-doc.prod-code = loc-gob-doc.prod-code NO-LOCK. ~
&endif ~
assign ~
  gds-rec = recid( loc-goo-doc ) ~
.



&SCOPED-DEFINE WINDOW-NAME d-{1}-ref
&SCOPED-DEFINE FRAME-NAME  d-{1}-ref

DEFINE INPUT        PARAMETER parParentProc   AS   WIDGET-HANDLE       NO-UNDO.
DEFINE INPUT        PARAMETER bttns           AS   CHARACTER           NO-UNDO. /* список включенных батонов */
DEFINE INPUT-OUTPUT PARAMETER g-stat          AS   CHARACTER           NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER g-list          AS   CHARACTER           NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER g-cond          AS   CHARACTER           NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER g-rep           AS   RECID               NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER g-grp           LIKE ub.goods.grp-name   NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-producer-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-producer-code LIKE ub.clients.obj-code NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-obj-type      LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-obj-code      LIKE ub.clients.obj-code NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-gds-name-width as decimal              NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-grp-name-width as decimal              NO-UNDO.

/* на будущее */
define input-output parameter p-other as character no-undo .

define input-output parameter rid-list as character no-undo.

{ cmp/vssrevis.i "substitute('&1|&2':u,substitute('&1|&2|&3|&4|&5|&6':u,parParentProc,bttns,g-stat,g-list,g-cond,g-rep),substitute('&1|&2|&3|&4|&5|&6':u,g-grp,p-producer-type,p-producer-code,p-obj-type,p-obj-code,p-other))" }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
define variable v-curr-r-b as character no-undo .
{ gbl/flt-def.i  }
{ ref/gds-attr.i }
{ ref/gdshattr.i }
{ ref/gdsoattr.i }
{ gbl/ggoattr.i  }
{ gbl/usr-flt.i }
{ ref/gdsreffi.i {1} gds-ref }
{ ref/gdsrefto.i }
{ cmp/library.i  }
{ str/libbcrcn.i }
{ str/lib-trn.i  }
{ ref/grplibfn.i }
{ gbl/waitfram.i }
{ gbl/prepnamc.i }
{ gbl/key-rec.i }
{ cmp/ini-lib.i }
{ str/checkGroupAttr.i }
define buffer g-producer for ub.clients .

define variable g#log as logical no-undo .

define variable gds-rec as recid no-undo .
define variable line-rec as recid no-undo .
define variable flt-rec as recid no-undo .
define variable old-value-emrc as character no-undo .

define variable ref-list as character no-undo.
/*режим копирования товара*/
define variable copymode as logical no-undo.
/*вызов UI-on из openbr если "ДА"*/
define variable start as logical no-undo initial no.
/*вызов UI-on из b-sch*/
define variable from-b-sch as logical no-undo initial no.
define buffer cli-shops for ub.clients.

define variable for-title     as character no-undo.
define variable dopinf-option as character no-undo.

define variable v-host-code like ub.sysconf.host-code no-undo .

define variable v-doc-prt as logical no-undo.
define variable v-spis as character no-undo .

define variable v-is-ptrl   as character no-undo.
define variable v-data-type as character no-undo.
define variable filter-label0 as character no-undo .
define variable filter-label as character no-undo .
DEFINE VARIABLE filter-point as character no-undo .
DEFINE VARIABLE filter-point0 as character no-undo .
DEFINE VARIABLE sort-column-name as character no-undo .
define variable v-filter-name as character no-undo .
DEFINE VARIABLE mphcol AS LOGICAL INITIAL NO NO-UNDO.


{ arc/gds_inf.i def }
{ gbl/fltfield.i }
{ref/imagelist.i}


DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход":L
     SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-arch
     LABEL "Ар&хив":L
     SIZE 10 BY 1.

DEFINE BUTTON add-inf
     LABEL "Доп.инф":L
     SIZE 10 BY 1.

DEFINE BUTTON b-hist
     LABEL "История":L
     SIZE 10 BY 1.

DEFINE BUTTON b-price
     LABEL "&Цены":L
     SIZE 10 BY 1.

DEFINE BUTTON b-rest
     LABEL "&Остат":L
     SIZE 10 BY 1.

DEFINE BUTTON b-card
     LABEL "Оборот&ы":L
     SIZE 10 BY 1.

DEFINE BUTTON b-chk
     LABEL "&Чеки  ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просм":L
     SIZE 10 BY 1.

DEFINE BUTTON b-prt
     LABEL "&Шкала":L
     SIZE 10 BY 1.

DEFINE BUTTON b-parts
     LABEL "Пар&тии":L
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.

DEFINE BUTTON b-alt-bc
     LABEL "&Коды":L
     SIZE 10 BY 1.

DEFINE BUTTON b-mark
     LABEL " &* ":L
     SIZE 3 BY 1.

DEFINE BUTTON b-add
     LABEL "&Добав. товар":L
     SIZE 15 BY 1.

DEFINE BUTTON b-add-office
     LABEL "Добав. услугу":L
     SIZE 15 BY 1.

DEFINE BUTTON b-copy
     LABEL "Копи&я"
    SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Измен":L
     SIZE 10 BY 1.

DEFINE BUTTON b-grp
     LABEL "&Группа":L
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удал":L
     SIZE 10 BY 1.

DEFINE BUTTON B-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B-obj"
     SIZE 3 BY 1.

DEFINE BUTTON b-place
     LABEL "С.&места":L
     SIZE 10 BY 1.

DEFINE BUTTON b-dinamo
     LABEL "Динам.":L
     SIZE 10 BY 1.

DEFINE BUTTON b-recip
     LABEL "Рецепт":L
     SIZE 10 BY 1.

DEFINE BUTTON b-sch
     LABEL "Фил&ьтр":L
     SIZE 10 BY 1.

DEFINE BUTTON b-sert
     LABEL "&Сертиф":L
     SIZE 10 BY 1.

DEFINE BUTTON b-gdsreffi
     image file "cmp/b-must.bmp":u
     SIZE 3 BY 4.

DEFINE BUTTON b-extart
     LABEL "Внеш.Арт":L
     SIZE 10 BY 1.

DEFINE VARIABLE rs-list AS CHARACTER VIEW-AS RADIO-SET HORIZONTAL RADIO-BUTTONS
"Все",          {&all},
"Производитель",{&producer},
"Группа",       {&group}
     SIZE 30 BY 1 FGCOLOR 0 /* BGCOLOR 8 */ NO-UNDO.

DEFINE VARIABLE rs-stat AS CHARACTER VIEW-AS RADIO-SET HORIZONTAL RADIO-BUTTONS
"Текущие&+",   {&current},
"Все&!",       {&all},
"Неактив&-", {&deleted}
     SIZE 30 BY 1   FGCOLOR 0 /* BGCOLOR 8 */  NO-UNDO.

DEFINE VARIABLE rs-sort AS CHARACTER VIEW-AS RADIO-SET HORIZONTAL RADIO-BUTTONS
"Артикул",{&Article},
"Цена прод.",{&price},
"Количество",{&Quantity}
SIZE 35 BY 1 FGCOLOR 0 /* BGCOLOR 8 */ NO-UNDO.

DEFINE VARIABLE rs-cond AS CHARACTER VIEW-AS RADIO-SET HORIZONTAL RADIO-BUTTONS
"Все",{&all},
"Объект",{&g___object},
"Факт",{&fact},
"Свободно",{&free}
SIZE 32.5 BY 1 FGCOLOR 0 /* BGCOLOR 8 */ NO-UNDO.

define shared variable loc-art  as character view-as fill-in size 18 by 1 fgcolor 12 no-undo format "x(16)":U.
define shared variable loc-name as character view-as fill-in size 20 by 1 fgcolor 12 no-undo.
define shared variable loc-code as character view-as fill-in size 17 by 1 fgcolor 12 no-undo.

define variable NameContext as character view-as fill-in size 20 by 1 fgcolor 12 no-undo.

define shared variable a-n-c as character view-as radio-set horizontal radio-buttons
"Артик","art",
"Нач.назв","name",
"Нач.слова","context",
"Код","code",
"DM","DataMatrix"
size 39 by 1    fgcolor 0 /* bgcolor 8 */ no-undo.

DEFINE MENU m-add
       MENU-ITEM m-add-1 LABEL "Товар"   ACCELERATOR "ALT-1"
       MENU-ITEM m-add-2 LABEL "Услуга"  ACCELERATOR "ALT-2"
.
DEFINE MENU m-dopinf
       MENU-ITEM m-dopinf-1 LABEL "Доп.инфо по карточке товара"                                  ACCELERATOR "ALT-1"
       MENU-ITEM m-dopinf-2 LABEL "Фото"                                           				 ACCELERATOR "ALT-2"
       RULE
       MENU-ITEM m-dopinf-lgattr LABEL "Просмотр Глобальных атрибутов товара"                       ACCELERATOR "ALT-3"
       MENU-ITEM m-dopinf-lhattr LABEL "Просмотр Атрибутов товара на фирме"                         ACCELERATOR "ALT-4"
       MENU-ITEM m-dopinf-loattr LABEL "Просмотр Атрибутов товара на объекте"                       ACCELERATOR "ALT-5"
       MENU-ITEM m-dopinf-moattr LABEL "Просмотр Атрибутов товара на объектах фирмы"                ACCELERATOR "ALT-6"
       MENU-ITEM m-dopinf-lfgds  LABEL "Просмотр Атрибутов товара (РЕСТОРАН) на объекте"            ACCELERATOR "ALT-7"
       MENU-ITEM m-dopinf-ldgr   LABEL "Просмотр Скидок на товар, действующих на объекте"           ACCELERATOR "ALT-8"
       MENU-ITEM m-dopinf-mdgr   LABEL "Просмотр Скидок на товар, действующих на объектах фирмы"    ACCELERATOR "ALT-9"
       MENU-ITEM m-dopinf-lscoef LABEL "Просмотр Сезонных коэффициентов для товара в производстве"  ACCELERATOR "ALT-f1"
       MENU-ITEM m-dopinf-lprop  LABEL "Просмотр Индикаторов товара на объекте"                     ACCELERATOR "ALT-f2"
       MENU-ITEM m-dopinf-lprop-ord  LABEL "Просмотр Атрибутов на объекте для ЗАКАЗА"               ACCELERATOR "ALT-f3"
       MENU-ITEM m-dopinf-lprop-ordf LABEL "Просмотр Атрибутов на фирме   для ЗАКАЗА"
       RULE
       MENU-ITEM m-dopinf-cgattr LABEL "Изменение Глобальных атрибутов товара"                       ACCELERATOR "ALT-f4"
       MENU-ITEM m-dopinf-chattr LABEL "Изменение Атрибутов товара на фирме"                         ACCELERATOR "ALT-f5"
       MENU-ITEM m-dopinf-coattr LABEL "Изменение Атрибутов товара на объекте"                       ACCELERATOR "ALT-f6"
       MENU-ITEM m-dopinf-cfgds  LABEL "Изменение Атрибутов товара (РЕСТОРАН) на объекте"            ACCELERATOR "ALT-f7"
       MENU-ITEM m-dopinf-cdgr   LABEL "Изменение Скидок на товар, действующих на объекте"           ACCELERATOR "ALT-f8"
       MENU-ITEM m-dopinf-cscoef LABEL "Изменение Сезонных коэффициентов для товара в производстве"  ACCELERATOR "ALT-f9"
       MENU-ITEM m-dopinf-cprop  LABEL "Изменение Индикаторов товара на объекте"                     ACCELERATOR "ALT-f10"
       MENU-ITEM m-dopinf-cprop-ord LABEL "Изменение Атрибутов товара на объекте для ЗАКАЗА"                    ACCELERATOR "ALT-f11"
       MENU-ITEM m-dopinf-cprop-ordf LABEL "Изменение Атрибутов товара на фирме   для ЗАКАЗА"
       RULE
       MENU-ITEM m-dopinf-AM     LABEL "Вхождение в Ассортиментные матрицы"
       MENU-ITEM m-dopinf-CONTR  LABEL "Вхождение в Спецификации"
       RULE
       MENU-ITEM m-dopinf-msf    LABEL "Классификация мясных полуфабрикатов"
       RULE
       MENU-ITEM m-dopinf-alt-unit    LABEL "Дополнительные единицы измерения"
.

def MENU m-price
    MENU-ITEM m-price-1 LABEL "Цены"
    MENU-ITEM m-price-2 LABEL "Переоценки"
.


define shared variable sch-rec AS recid no-undo.

define variable free-q as decimal no-undo column-label "Свободно" format "->,>>>,>>>.<<<":U.
define variable fact-q as decimal no-undo column-label "Факт"     format "->,>>>,>>>.<<<":U.

define variable price          like ub.price-list.price-sale column-label "Цена"                              no-undo.
define variable for-cash-parts like ub.gds-obj.cash-parts    column-label "П"                 format "+/-":U.
define variable for-last-price like ub.gds-obj.last-rubl     column-label "Цена посл.прихода"                 no-undo.

define variable for-last-pcnt-str as character column-label "Торг.нацен.%" format "x(12)":U no-undo.

/*приходных цен и наценок по объекту*/
define variable v-lookup-cost as logical no-undo .

define variable val-VAT like ub.tax-rate-value.rate-value no-undo .
define variable val-SLT like ub.tax-rate-value.rate-value no-undo .

define variable free-q-cli as decimal no-undo column-label "Свободно (е.п.)" format "->>,>>>,>>>.<<<":U.
define variable fact-q-cli as decimal no-undo column-label "Факт (е.п.)"     format "->>,>>>,>>>.<<<":U.
define variable v-indicator-life-gds like  ub.gds-obj-prop.gdop-igt        column-label "ИЖТ" format "x(25)" no-undo .
define variable v-assort-min         like  ub.gds-obj-prop.gdop-assort-min column-label "AMin" format "*/ " no-undo .


define variable mark        as character no-undo.
define variable mark-recipe as character no-undo.
define variable mark-num    as integer   no-undo.
define variable contin      as logical   initial no.

define buffer l-goo-doc for ub.goods.   /* для поиска  */
define buffer l-gob-doc for ub.gds-obj. /* для поиска  */

define variable conf-par as character no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as character no-undo.

/*вспомогат*/
define variable dops      as character no-undo format "x(250)":U .
define variable dopst     as character no-undo format "x(1)":U .
define variable is-fbr    as logical   no-undo .
define variable is-prt    as logical   no-undo .

DEFINE NEW SHARED BUFFER gob-doc FOR ub.gds-obj.
DEFINE NEW SHARED BUFFER goo-doc FOR ub.goods.
DEFINE NEW SHARED BUFFER gam-doc FOR ub.assortment-matrix-goods.

define variable e-name like goo-doc.engl-name            no-undo.
define variable gds-n  like goo-doc.gds-name             no-undo.
define variable unit-b like goo-doc.unit-base            no-undo.
define variable qnty-c like goo-doc.qnty-cart            no-undo.
define variable VAT-p  like ub.tax-rate-value.rate-value no-undo.
define variable SLT-p  like ub.tax-rate-value.rate-value no-undo.
define variable gds-t  like goo-doc.gds-type             no-undo.
define variable choice as   integer                      no-undo.

/*список доп полей для показа в форме*/
define variable gdsreffi  as character no-undo.
define variable myto      as character no-undo extent 8.
define variable mypr      as character no-undo extent 8.
define variable main-code as integer   no-undo.
define variable v-chg-rec as recid     no-undo.

define variable FI-1 as character view-as text size 76 by 1 no-undo format "x(80)":U.
define variable FI-2 as character view-as text size 76 by 1 no-undo format "x(80)":U.
define variable FI-3 as character view-as text size 45 by 1 no-undo format "x(49)":U.
define variable FI-4 as character view-as text size 45 by 1 no-undo format "x(49)":U.
define variable FI-5 as character view-as text size 45 by 1 no-undo format "x(49)":U.
define variable FI-6 as character view-as text size 45 by 1 no-undo format "x(49)":U.
define variable FI-7 as character view-as text size 45 by 1 no-undo format "x(49)":U.
define variable FI-8 as character view-as text size 45 by 1 no-undo format "x(49)":U.

define variable v-obj-type as character view-as fill-in size  4 by 1 fgcolor 12 no-undo.
define variable v-obj-code as integer   view-as fill-in size  6 by 1 fgcolor 12 no-undo.
define variable v-obj-name as character view-as fill-in size 30 by 1 fgcolor 12 no-undo format "x(30)":U.



&if "{1}" = "goo-doc" &then

/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD Get-good Dialog-Frame
FUNCTION Get-good RETURNS CHARACTER
  ( BUFFER loc-goods FOR goo-doc, BUFFER loc-gds-obj FOR gob-doc )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&SCOPED-DEFINE BROWSE-NAME br-gds


DEFINE NEW SHARED QUERY {&BROWSE-NAME} FOR goo-doc SCROLLING.

DEFINE BROWSE {&BROWSE-NAME} QUERY {&BROWSE-NAME} NO-LOCK DISPLAY
 /* mark */ get-good( buffer goo-doc, buffer gob-doc )  format "x(1)":U column-label "*"
  (IF mphcol THEN "+":U ELSE "-":U) FORMAT "x(1)":U COLUMN-LABEL "Ф"
   ( if {1}.gds-type = {&gds-goods} then "-" else "+" ) format "x(1)":U column-label "У"
   mark-recipe format "x(1)":U column-label "Р"
  {1}.artic
  gds-n  format "x(112)":U column-label "Название"
  free-q  COLUMN-LABEL "Своб-но" format  "->>,>>>,>>>.<<<":U
  fact-q  COLUMN-LABEL "Факт" format  "->>,>>>,>>>.<<<":U
  price
  goo-doc.unit-base column-label  "Изм."
  goo-doc.qnty-cart column-label  "Кол. в упак."
  goo-doc.grp-name format "x(120)":U
  vat-p format ">9.99%":U column-label "НДС"
  SLT-p format ">9.99%":U column-label "НП"
  goo-doc.negative-rest column-label "-ост" format "  */   ":U
  goo-doc.engl-name format "x(40)":U
  for-cash-parts
  for-last-price
  for-last-pcnt-str
  free-q-cli COLUMN-LABEL "Своб-но (е.п.)" format  "->>,>>>,>>>.<<<":U
  fact-q-cli COLUMN-LABEL "Факт (е.п.)" format  "->>,>>>,>>>.<<<":U
  v-indicator-life-gds
  v-assort-min
  WITH SIZE 98 BY 11 SEPARATORS.
&else


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD Get-good Dialog-Frame
FUNCTION Get-good RETURNS CHARACTER
  ( buffer loc-goods for goo-doc, buffer loc-gds-obj for gob-doc )  FORWARD.



/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&SCOPED-DEFINE BROWSE-NAME br-gds


DEFINE NEW SHARED QUERY {&BROWSE-NAME} FOR gob-doc {&table2} SCROLLING.

DEFINE BROWSE {&BROWSE-NAME} QUERY {&BROWSE-NAME} NO-LOCK DISPLAY
  /*mark*/ get-good( buffer goo-doc, buffer gob-doc ) format "x(1)":U column-label "*"
  (IF mphcol THEN "+":U ELSE "-":U) FORMAT "x(1)":U COLUMN-LABEL "Ф"
  gds-t format "x(1)":U column-label "У"
  mark-recipe format "x(1)":U column-label "Р"
  {1}.artic
  gds-n format "x(48)":U column-label "Название"
  free-q  COLUMN-LABEL "Своб-но" format  "->>,>>>,>>>.<<<":U
  fact-q  COLUMN-LABEL "Факт" format  "->>,>>>,>>>.<<<":U
  price
  unit-b column-label  "Изм."
  qnty-c column-label  "Кол. в упак."
  {1}.grp-name format "x(120)":U
  VAT-p format ">9.99%":U column-label "НДС"
  SLT-p format ">9.99%":U column-label "НП"
  e-name format "x(40)":U
  for-cash-parts
  for-last-price
  for-last-pcnt-str
  free-q-cli COLUMN-LABEL "Своб-но (е.п.)" format  "->>,>>>,>>>.<<<":U
  fact-q-cli COLUMN-LABEL "Факт (е.п.)" format  "->>,>>>,>>>.<<<":U
  v-indicator-life-gds
  v-assort-min
  WITH SIZE 98 BY 11 SEPARATORS.

&endif

DEFINE RECTANGLE RECT-list
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 49 BY 2.4.

DEFINE RECTANGLE RECT-cond
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 49 BY 2.4.

DEFINE RECTANGLE RECT-gds-ref-fi
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 98 BY 4.5.
     
/*DEFINE RECTANGLE RECT-image
     EDGE-PIXELS 1 GRAPHIC-EDGE  NO-FILL
     SIZE 16.88 /*12.75*/ /*9.63*/ BY 4.25.*/
     
DEFINE IMAGE g-image
     /*FILENAME "adeicon/blank":U*/
     STRETCH-TO-FIT RETAIN-SHAPE
     SIZE 16.63 /*12.50*/ /*9.38*/ BY 4.17.

DEFINE MENU m-ostatki
       MENU-ITEM m-ostatki-1 LABEL "Остатки по объектам"     ACCELERATOR "ALT-1"
       MENU-ITEM m-ostatki-2 LABEL "Остатки по поставщикам"  ACCELERATOR "ALT-2"
    .

DEFINE MENU m-oborot
       MENU-ITEM m-oborot-1 LABEL "Оборотная ведомость"      ACCELERATOR "ALT-1"
       MENU-ITEM m-oborot-2 LABEL "Обороты по контрагентам"  ACCELERATOR "ALT-2"
    .

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME {&FRAME-NAME}
  b-exit at row 1 col 1
  b-sel at row 1 col 19
  b-arch at row 1 col 29
  b-price at row 1 col 39
  b-rest at row 1 col 49
  b-card at row 1 col 59
  b-dinamo at row 1 col 69
  b-sch at row 1 col 79
  b-help at row 1 col 89
  b-mark at row 1 col 13
  mark-num at row 2 col 1 colon-aligned no-label view-as fill-in size 9 by 1 fgcolor 4
  b-alt-bc at row 2 col 9
  b-recip at row 2 col 19
  b-extart at row 2 col 29
  b-chk at row 2 col 39
  b-prt at row 2 col 49
  b-parts at row 2 col 59
  b-place at row 2 col 69
  b-sert at row 2 col 79
  b-hist at row 2 col 89
  v-obj-type at row 3 col 2 No-LABEL
  v-obj-code at row 3 col 6 No-LABEL
  b-obj at row 3 col 12
  v-obj-name at row 3 col 15 No-LABEL
  b-add at row 3 col 9
  b-add-office at row 3 col 24
  b-copy at row 3 col 39
  b-lkp  at row 3 col 49
  b-chg at row 3 col 59
  b-del at row 3 col 69
  add-inf at row 3 col 79
  b-grp at row 3 col 89
  "Поиск по:" VIEW-AS TEXT SIZE 9 BY 1 fgcolor 4 AT ROW 4 COL 1
  a-n-c at row 4 col 10 no-label
  NameContext AT ROW 4 COL 56 COLON-ALIGNED label "Контекст" format "x(40)":U
  loc-art AT ROW 4 COL 56 COLON-ALIGNED no-label /* "Начало артикула" */
  loc-name AT ROW 4 COL 56 COLON-ALIGNED label "Нач. назв." format "x(40)":U
  loc-code AT ROW 4 COL 59 COLON-ALIGNED label "Код(весь)":U format "x(300)":U
  goo-doc.gds-code at row 4 col 82  colon-aligned label "Код" fgcolor 4 format "9999999999":U
  {&BROWSE-NAME} AT ROW 5 COL 1
  rect-gds-ref-fi at row 16.1 COL 1
  fi-1 at row 16.2 col 5 No-LABEL fgcolor 4
  b-gdsreffi AT ROW 16.25 col 1.5
  fi-2 at row 17.0 col 5 No-LABEL  fgcolor 4
  fi-3 at row 17.8 col 5 No-LABEL
  fi-4 at row 17.8 col 51 No-LABEL
  fi-5 at row 18.6 col 5 No-LABEL
  fi-6 at row 18.6 col 51 No-LABEL
  fi-7 at row 19.4 col 5 No-LABEL
  fi-8 at row 19.4 col 51 NO-LABEL
  rect-list at row 20.7 col 1
  rect-cond at row 20.7 col 50
  /*rect-image AT ROW 16.22 COL 81.75 /*85.88*/ /*89*/ */
  g-image AT ROW 16.27 COL 81.85 /*85.98*/ /*89.1*/
  "Справочник :" VIEW-AS TEXT SIZE 12 BY 1 fgcolor 4 AT ROW 20.9 COL 2
  rs-list at row 20.9 col 12 colon-aligned no-label
  "Фильтр :" VIEW-AS TEXT SIZE 9 BY 1 fgcolor 4 AT ROW 20.9 COL 51
  rs-cond at row 20.9 col 60 colon-aligned no-label
  "Статус :" VIEW-AS TEXT SIZE 9 BY 1 fgcolor 4 AT ROW 21.9 COL 2
  rs-stat at row 21.9 col 12 colon-aligned no-label
  "Сортировка :" VIEW-AS TEXT SIZE 13 BY 1 fgcolor 4 AT ROW 21.9 COL 51
  rs-sort at row 21.9 col 61 colon-aligned no-label
  SPACE(0) SKIP(0) WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE TITLE {&reference}.

/* ***************  Runtime Attributes and UIB Settings  ************** */

ASSIGN FRAME {&FRAME-NAME} :SCROLLABLE = FALSE.
ASSIGN {&BROWSE-NAME} :NUM-LOCKED-COLUMNS IN FRAME {&FRAME-NAME} = 4 .
ASSIGN b-rest  :POPUP-MENU IN FRAME {&FRAME-NAME} = MENU m-ostatki :HANDLE.
ASSIGN b-rest  :MENU-MOUSE = 1.
ASSIGN b-card  :POPUP-MENU IN FRAME {&FRAME-NAME} = MENU m-oborot  :HANDLE.
ASSIGN b-card  :MENU-MOUSE = 1.
ASSIGN add-inf :POPUP-MENU IN FRAME {&FRAME-NAME} = MENU m-dopinf  :HANDLE.
ASSIGN add-inf :MENU-MOUSE = 1.
ASSIGN b-price:POPUP-MENU IN FRAME {&frame-name} = MENU m-price:HANDLE.
ASSIGN b-price:MENU-MOUSE = 1.



/* ************************  Control Triggers  ************************ */

/* --------------------------------------- Поиск -------------------------------------------------------------------- */
/*перемещение колонок*/
&if "{1}" = "goo-doc" &then

{ gbl/mv-clmn.i
    &browse-name  = "{&BROWSE-NAME}"
    &frame-name   = "{&FRAME-NAME}"
    &ext-col      = 16
    &start-column = 6
}

&else

{ gbl/mv-clmn.i
    &browse-name  = "{&BROWSE-NAME}"
    &frame-name   = "{&FRAME-NAME}"
    &ext-col      = 15
    &start-column = 6
}

&endif

{ str/sch-line.i {1} {&BROWSE-NAME} }

&if "{1}" = "gob-doc" &then
FIND FIRST goo-doc NO-LOCK WHERE
           goo-doc.artic     = gob-doc.artic
       AND goo-doc.prod-code = gob-doc.prod-code
       AND goo-doc.prod-type = gob-doc.prod-type
       USE-INDEX pi NO-ERROR.
&endif

    if available {1} then do:
      assign
        g-rep = recid( {1} )
      .
    end.
    IF mImagePh THEN
    DO:
        IF AVAILABLE goo-doc THEN
        DO:
            DEFINE VARIABLE vImageList AS LONGCHAR    NO-UNDO.
            DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
            RUN gds-attr-value (goo-doc.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
            RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, goo-doc.gds-code, OUTPUT vImageList).
            vCh = ENTRY (1, vImageList, {&ImageDelimiter}).
        END.
        g-image:LOAD-IMAGE (ENTRY (1, vCh)) NO-ERROR.
        
    END.    
    if vCh <> "" then do:
      ASSIGN
        FI-4:FORMAT in frame {&frame-name} = "X(30)"
        FI-4:WIDTH-CHARS in frame {&frame-name} = 30
        FI-6:FORMAT in frame {&frame-name} = "X(30)"
        FI-6:WIDTH-CHARS in frame {&frame-name} = 30 
        FI-8:FORMAT in frame {&frame-name} = "X(30)"
        FI-8:WIDTH-CHARS in frame {&frame-name} = 30  
      .
    end.  
    else do:
     ASSIGN
        FI-4:FORMAT in frame {&frame-name} = "X(49)"
        FI-4:WIDTH-CHARS in frame {&frame-name} = 45
        FI-6:FORMAT in frame {&frame-name} = "X(49)"
        FI-6:WIDTH-CHARS in frame {&frame-name} = 45 
        FI-8:FORMAT in frame {&frame-name} = "X(49)"
        FI-8:WIDTH-CHARS in frame {&frame-name} = 45  
      .
    end.  
    RUN gds-ref-fi IN THIS-PROCEDURE ( BUFFER       goo-doc,
                                       BUFFER       gob-doc,
                                       INPUT        p-obj-type,
                                       INPUT        p-obj-code,
                                       INPUT        gdsreffi,
                                       input        no /*p-excel*/ ,
                                       INPUT-OUTPUT fi-1,
                                       INPUT-OUTPUT fi-2,
                                       INPUT-OUTPUT fi-3,
                                       INPUT-OUTPUT fi-4,
                                       INPUT-OUTPUT fi-5,
                                       INPUT-OUTPUT fi-6,
                                       INPUT-OUTPUT fi-7,
                                       INPUT-OUTPUT fi-8
                                     ) NO-ERROR.
    if available goo-doc then do:
      assign
        main-code = ?
      .
      { gbl/gdsbcode.i goo-doc.gds-code ? main-code }
    end.

    DISPLAY
      fi-1
      fi-2
      fi-3
      fi-4
      fi-5
      fi-6
      fi-7
      fi-8
      main-code @ goo-doc.gds-code
    WITH FRAME {&FRAME-NAME}.


end.    /* см. { str/sch-line.i {1} {&BROWSE-NAME} } */


/* --------------------------------------- Триггеры browse и общие ----------------------------------------------------- */

ON ROW-DISPLAY OF {&BROWSE-NAME}  in frame {&FRAME-NAME} do:
      run assort-polit in this-procedure (  input  {1}.gds-code ,
                                            input  p-obj-type           ,
                                            input  p-obj-code           ,
                                            output v-indicator-life-gds ,
                                            output v-assort-min          )
                                            no-error.
                                            if error-status :error then  message error-status :get-message(1)  .
     case v-indicator-life-gds :
        when {&ass-izd-new} then do:
           v-indicator-life-gds:bgcolor  in browse {&browse-name}   = 14 . /* желтый */
        end.
        when {&ass-izd-del} then do:
           v-indicator-life-gds:bgcolor  in browse {&browse-name}   = 12 .  /* красный */
        end.
        when {&ass-izd-spec} then do:
           v-indicator-life-gds:bgcolor  in browse {&browse-name}   = 8 .  /* серый   */
        end.

     end case.

     v-indicator-life-gds:screen-value = v-indicator-life-gds .
     v-assort-min:screen-value = string(v-assort-min,"*/ ").
end.

on choose of b-gdsreffi in frame {&FRAME-NAME} do:
  run gds-ref-to-description in this-procedure .
end.

on value-changed of rs-list in frame {&FRAME-NAME} do:
  run proc-rs-list in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.

on value-changed of rs-cond in frame {&FRAME-NAME} do:
  run proc-vc-rs-cond in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.

ON value-changed OF rs-stat in frame {&FRAME-NAME}
DO:
  run proc-rs-stat in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
END.

ON value-changed OF rs-sort in frame {&FRAME-NAME}
DO:
  run proc-rs-sort in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
END.

on end-error, stop of frame {&FRAME-NAME} do:
  apply "choose":U to b-exit in frame {&FRAME-NAME}.
  return no-apply.
end.

on endkey of frame {&FRAME-NAME} do:
    run gbl/markqwa.p (
                            input b-mark :sensitive
                          , input rid-list          ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on return, MOUSE-SELECT-DBLCLICK of {&BROWSE-NAME} in frame {&FRAME-NAME} do:
  run proc-br-gds in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.

/* --------------------------------------- Батоны -------------------------------------------------------------------- */
on choose of MENU-ITEM m-price-1 in menu m-price DO:
  run proc-b-price(input 1 , buffer goo-doc, buffer gob-doc) no-error.
  if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-price-2 in menu m-price DO:
  run proc-b-price(input 2 , buffer goo-doc, buffer gob-doc) no-error.
  if error-status:error then return no-apply.
end.

on choose of b-exit in frame {&FRAME-NAME} do:
  run gbl/markqwa.p (
                            input b-mark :sensitive
                          , input rid-list          ) no-error.
  if error-status :error then do: return no-apply. end.
  run proc-b-exit in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of b-sel in frame {&FRAME-NAME} do:
  run proc-b-sel in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of b-arch in frame {&FRAME-NAME} do:
  if available goo-doc then do:
    run local-gds_inf in this-procedure.
  end.
end.

ON CHOOSE OF b-sch in frame {&FRAME-NAME} /* Фильтр */
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
END.

on choose of b-recip in frame {&FRAME-NAME} do:
  run b-recip-proc in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of b-rest in frame {&FRAME-NAME} do:
  run gbl/pop-up.p ( input self :handle, input no ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of MENU-ITEM m-ostatki-1 in menu m-ostatki DO:
  run proc-m-ostatki-1 in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of MENU-ITEM m-ostatki-2 in menu m-ostatki DO:
  run proc-m-ostatki-2 in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of b-card in frame {&FRAME-NAME} do:
  run gbl/pop-up.p ( input self :handle, input no ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of MENU-ITEM m-oborot-1 in menu m-oborot DO:
  run proc-m-oborot-1 in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of MENU-ITEM m-oborot-2 in menu m-oborot DO:
  run proc-m-oborot-2 in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of b-chk in frame {&FRAME-NAME} do:
  run b-chk-proc in this-procedure ( buffer goo-doc, buffer gob-doc ).
end.

on choose of b-sert in frame {&FRAME-NAME} do:
  run proc-b-sert in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of b-lkp in frame {&FRAME-NAME} do:
  run proc-b-lkp in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of b-prt in frame {&FRAME-NAME} do:
  run proc-b-prt in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of b-parts in frame {&FRAME-NAME} do:
  run b-parts-proc in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.


{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-lkp  }
{ gbl/hot-key.i b-add  }
{ gbl/hot-key.i b-chg  }
{ gbl/hot-key.i b-del  }
{ gbl/hot-key.i b-sel  }


on choose of b-mark in frame {&FRAME-NAME} do:

    run b-mark-proc in this-procedure .

end.

on choose of b-alt-bc in frame {&FRAME-NAME}
do:
  run b-alt-bc-proc in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
  apply "entry":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
end.

on choose of b-copy in frame {&FRAME-NAME}
do:
  run b-copy-proc in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of b-add in frame {&FRAME-NAME}
do:
  run proc-b-add in this-procedure ( buffer goo-doc, buffer gob-doc, input yes ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of b-add-office in frame {&FRAME-NAME}
do:
  run proc-b-add in this-procedure ( buffer goo-doc, buffer gob-doc, input no ) no-error.
  if error-status :error then do: return no-apply. end.
end.


on choose of b-chg in frame {&FRAME-NAME}
do:
  run proc-b-chg in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of b-grp in frame {&FRAME-NAME} do:
  run proc-b-grp in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of b-del in frame {&FRAME-NAME} do:
  run b-del-proc in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
  else do:
    run openbr in this-procedure ( input yes, input yes, input no, input '':U ).
  end.
end.

on choose of b-place in frame {&FRAME-NAME} do:
  run b-place-proc in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
  APPLY "ENTRY":U TO b-place IN FRAME {&FRAME-NAME}.
end.

on choose of b-dinamo in frame {&FRAME-NAME} do:
  run b-dinamo-proc in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
  APPLY "ENTRY":U TO b-dinamo IN FRAME {&FRAME-NAME}.
end.

on choose of b-hist in frame {&FRAME-NAME} do:
  run b-hist-proc in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
  APPLY "ENTRY":U TO b-hist IN FRAME {&FRAME-NAME}.
end.

ON CHOOSE OF add-inf IN FRAME {&FRAME-NAME}
DO:
  if dopinf-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if dopinf-option = "":U then do: return no-apply. end.
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, {&lookup} ) no-error.
  if error-status :error then do: return no-apply. end.
END.

on choose of MENU-ITEM m-dopinf-1 in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, {&lookup} ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of MENU-ITEM m-dopinf-2 in menu m-dopinf DO:
  assign
    dopinf-option = "foto":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, {&lookup} ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of MENU-ITEM m-dopinf-lgattr in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-gbl":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, {&lookup} ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of MENU-ITEM m-dopinf-lhattr in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-host":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, {&lookup} ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of MENU-ITEM m-dopinf-loattr in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-obj-one":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, {&lookup} ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-dopinf-ldgr in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-dgr-one":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, {&lookup} ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-dopinf-mdgr in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-dgr-cmp":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, {&lookup} ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of MENU-ITEM m-dopinf-moattr in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-obj-cmp":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, {&lookup} ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of MENU-ITEM m-dopinf-lfgds in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-fbr-gds-obj":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, {&lookup} ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of MENU-ITEM m-dopinf-lscoef in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-s-coeff":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, {&lookup} ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of MENU-ITEM m-dopinf-lprop in menu m-dopinf DO:
  assign
    dopinf-option = "indicators":U
  .
  run proc-b-add-inf  in this-procedure  (input-output dopinf-option, {&lookup}) no-error.
  if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-dopinf-AM in menu m-dopinf DO:
  assign
    dopinf-option = "AM":U
  .
  run proc-b-add-inf  in this-procedure  (input-output dopinf-option, {&lookup}) no-error.
  if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-dopinf-msf in menu m-dopinf DO:
  assign
    dopinf-option = "msf":U
  .
  run proc-b-add-inf  in this-procedure  (input-output dopinf-option, {&lookup}) no-error.
  if error-status:error then return no-apply.
end.


on choose of MENU-ITEM m-dopinf-contr in menu m-dopinf DO:
  assign
    dopinf-option = "contr":U
  .
  run proc-b-add-inf  in this-procedure  (input-output dopinf-option, {&lookup}) no-error.
  if error-status:error then return no-apply.
end.


on choose of MENU-ITEM m-dopinf-lprop-ord in menu m-dopinf DO:
  assign
    dopinf-option = "orders":U
  .
  run proc-b-add-inf  in this-procedure  (input-output dopinf-option, {&lookup}) no-error.
  if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-dopinf-lprop-ordf in menu m-dopinf DO:
  assign
    dopinf-option = "ordersf":U
  .
  run proc-b-add-inf  in this-procedure  (input-output dopinf-option, {&lookup}) no-error.
  if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-dopinf-cgattr in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-gbl":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, {&update} ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of MENU-ITEM m-dopinf-chattr in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-host":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, {&update} ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of MENU-ITEM m-dopinf-coattr in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-obj-one":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, {&update} ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-dopinf-cdgr in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-dgr-one":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, {&update} ) no-error.
  if error-status :error then do: return no-apply. end.
end.


on choose of MENU-ITEM m-dopinf-cfgds in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-fbr-gds-obj":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, {&update} ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of MENU-ITEM m-dopinf-cscoef in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-s-coeff":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, {&update} ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of MENU-ITEM m-dopinf-cprop in menu m-dopinf DO:
  assign
    dopinf-option = "indicators":U
  .
  run proc-b-add-inf  in this-procedure  (input-output dopinf-option, {&update}) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-cprop-ord in menu m-dopinf DO:
  assign
    dopinf-option = "orders":U
  .
  run proc-b-add-inf  in this-procedure  (input-output dopinf-option, {&update}) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-cprop-ordf in menu m-dopinf DO:
  assign
    dopinf-option = "ordersf":U
  .
  run proc-b-add-inf  in this-procedure  (input-output dopinf-option, {&update}) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-alt-unit in menu m-dopinf DO:
  assign
    dopinf-option = "alt-unit":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, {&update} ) no-error.
  if error-status :error then do: return no-apply. end.
end.



on choose of b-obj in frame {&FRAME-NAME} do:
  run proc-b-obj in this-procedure ( input "change":U ).
end.

on choose of b-extart in frame {&FRAME-NAME} do:
  run proc-b-extart in this-procedure ( buffer goo-doc , buffer gob-doc ) no-error .
  if error-status :error then do :
    return no-apply.
  end.
end.

ON ANY-KEY OF loc-code IN FRAME {&FRAME-NAME}
DO:
  if a-n-c = "DataMatrix" then
    if lastkey = 308 then
      return no-apply.
END.

ON MOUSE-SELECT-DBLCLICK OF g-image IN FRAME {&FRAME-NAME}
DO:
    DEFINE VARIABLE v-main-code LIKE ub.bar-code.b-code NO-UNDO.
    RUN ref/imagelist.w (parParentProc, "":U, goo-doc.gds-code, {&lookup}).
END.

/* ***************************  Main Block  *************************** */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/app_help.i }
{ gbl/brwrepos.i
&line-num=5
}
{ gbl/brwrefre.i
" if available goo-doc then gds-rec = recid(goo-doc). RUN openbr IN THIS-PROCEDURE ( INPUT YES, input yes, input no, input '' )."
}

{ gbl/setfltnm.i }

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  /* буфер g - p r o d u c e r мб поломан при откате в накладной */
 { gbl/getcntxt.i get }
  run main-block-proc in this-procedure no-error.
  if error-status :error then do: return error. end.

  WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS {&BROWSE-NAME}.
END.
assign
p-gds-name-width = gds-n:width in browse {&browse-name}
p-grp-name-width = {1}.grp-name:width in browse {&browse-name}
.
RUN disable_UI IN THIS-PROCEDURE.

/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME {&FRAME-NAME} NO-PAUSE.
END PROCEDURE.

PROCEDURE openbr :
define input parameter p-repos-message as logical no-undo .
define input parameter p-open-query as logical   no-undo .
define input parameter p-find-next as logical   no-undo .
define input parameter p-find-condition as character no-undo .


DEFINE VARIABLE pos-rec AS RECID NO-UNDO .

define buffer pos_goods for ub.goods.
define buffer cur-obj   for ub.clients.

FIND FIRST cur-obj NO-LOCK WHERE
          cur-obj.obj-type = p-obj-type
      AND cur-obj.obj-code = p-obj-code .
ASSIGN
FRAME {&FRAME-NAME} rs-sort
.

&if "{1}" = "goo-doc" &then
assign
  filter-point = "goo-doc" + "_" + string( g-stat )
  filter-label = "Все_товары" + "_" + string( g-stat )
.
&else
assign
  filter-point = "gob-doc" + "_" + string( g-stat )
  filter-label = "Все_товары_по_объекту" + "_" + string( g-stat )
.
&endif


&scop run-openbr   input  p-open-query ~
                        ,input  p-find-next ~
                        ,input  p-find-condition ~
                         ~
                        ,input a-n-c ~
                        ,input NameContext ~
                        ,input rs-sort ~
                        ,input g-cond  ~
                        ,input g-list  ~
                        ,input g-stat  ~
                        ,input g-grp   ~
                        ,input p-obj-type ~
                        ,input p-obj-code ~
                        ,buffer g-producer ~
                        ,buffer cur-obj    ~
                        ,output for-title  ~
                        ~
                        ,input filter-point  ~
                        ,input filter-point0 ~
                        ,input sort-column-name ~
                        ,output v-filter-name ~
                        ,input-output g-rep ~
                        ).

&if "{1}" = "goo-doc" &then
  run ref/gds-refo.p ( {&run-openbr}
&else
  &if "{2}" = "assortment-matrix" &then
  run ref/gds-refa.p ( {&run-openbr}
  &else
  run ref/gds-refb.p ( {&run-openbr}
  &endif
&endif
assign
frame {&FRAME-NAME} :title = for-title
.

if g-list = "ptrl"
or g-list = "lgas"
or g-list = "ptrlsug"
or g-list = "only-np"
then do:
  assign
  rs-list = {&all}
  rs-stat = {&current}  
  rs-cond = {&all}
  .
  DISPLAY
  rs-list rs-cond rs-stat
  WITH FRAME {&FRAME-NAME}.
  disable
  rs-list rs-cond rs-stat
  WITH FRAME {&FRAME-NAME}.

end.
else do:
  assign
  rs-list = g-list
  rs-stat = g-stat  
  rs-cond = g-cond
  .
  DISPLAY
  rs-list rs-cond rs-stat
  WITH FRAME {&FRAME-NAME}.

end.


run set-filter-name in this-procedure (INPUT v-filter-name) no-error .
if g-rep <> ? then do:
  reposition {&BROWSE-NAME} to recid g-rep no-error.
  if error-status :error then do:
    if p-repos-message and g-rep = v-chg-rec then do:
      pos-rec = g-rep.
      {&cant-positioning}
      v-chg-rec = ?.
    end.
    if num-results( "{&BROWSE-NAME}" ) <> 0 then do:
      g#log = {&BROWSE-NAME} :select-row( 1 ) .
      g#log = {&BROWSE-NAME} :scroll-to-selected-row( 1 ) .
    end.
  end.
end.
apply "entry":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
if available {1} then do:
  assign
    g#log = {&BROWSE-NAME} :SELECT-PREV-ROW( )
  .
  if g#log = yes then do:
    assign
      g#log = {&BROWSE-NAME} :SELECT-NEXT-ROW( )
    .
  end.
end.
apply "value-changed":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
if ( g-list = g-cond or ( g-cond = {&g___object} and g-list = {&all} ) ) and rs-sort = {&Article} then do:
  assign
    start = yes
  .
end.

if start and not from-b-sch then do:
  run UI-on in this-procedure.
  if v-chg-rec <> ? then do:
    reposition {&BROWSE-NAME} to recid v-chg-rec no-error.
    if error-status :error then do:
      if p-repos-message then do:
        pos-rec = v-chg-rec.
        {&cant-positioning}
      end.
      if num-results( "{&BROWSE-NAME}" ) <> 0 then do:
        assign
        g#log = {&BROWSE-NAME} :select-row( 1 )
        .
        assign
        g#log = {&BROWSE-NAME} :scroll-to-selected-row( 1 )
        .
      end.
    end.
    assign
    v-chg-rec = ?
    .
  end.
end.
RUN buttons IN THIS-PROCEDURE.
assign
start = no
.
END PROCEDURE.

PROCEDURE full-sch :
    &if "{1}" = "goo-doc" &then
        assign
          g-rep  = recid( l-{1} )
          g-list = {&all}
          g-stat = {&all}
        .
        RUN openbr IN THIS-PROCEDURE ( INPUT YES , input yes, input no, input '':U).
    &else
    /* формируем recid уже для goo-doc */
        FIND FIRST goo-doc NO-LOCK WHERE
                   goo-doc.artic     = l-{1}.artic     AND
                   goo-doc.prod-type = l-{1}.prod-type AND
                   goo-doc.prod-code = l-{1}.prod-code .
        assign
          g-rep = recid( goo-doc )
        .
    /* sch-rec при поиске по артикулу используется */
        if a-n-c = "art" then do:
          assign
            sch-rec = g-rep
          .
        end.
        assign
          g-stat = {&all}
          g-cond = {&all}
          g-list = {&all}
        .
        apply "go":U to frame {&FRAME-NAME}.
    &endif
END PROCEDURE.

PROCEDURE buttons :
  if lookup( "b-add", bttns ) > 0

  AND ub.db.add-goods AND NOT transaction and lookup( "no-object":U, p-other, {&delim-par} ) = 0
  /*
  AND lookup( g-list, {&all} ) > 0 AND lookup( g-cond, {&all} ) > 0 AND
      lookup( g-stat, {&deleted} ) = 0 AND flt-rec = ? AND NOT a-n-c = "context"
  */
  then do:
    enable
    b-add
    b-add-office
    b-grp
    b-del  /* when lookup( g-stat, {&all} ) > 0 */  b-copy b-chg
    with frame {&FRAME-NAME}.
  end.
  else do:
    disable
    b-add
    b-add-office
    b-grp
    b-del
    b-copy
    b-chg
    with frame {&FRAME-NAME}.
  end.
  if not ub.db.add-goods
  and v-cntxt-db-num = 0 then do:
    /*для ORA*/
    enable
    b-grp
    with frame {&frame-name} .

  end.
  if is-fbr = yes then do:
    enable
      b-recip
    with frame {&FRAME-NAME}.
  end.
  else do:
    disable
      b-recip
    with frame {&FRAME-NAME}.
  end.
  if is-fbr <> yes then do:
    assign
    menu-item m-dopinf-lfgds :sensitive in menu m-dopinf = no
    menu-item m-dopinf-lscoef :sensitive in menu m-dopinf = no
    menu-item m-dopinf-cfgds :sensitive in menu m-dopinf = no
    menu-item m-dopinf-cscoef :sensitive in menu m-dopinf = no
    .
  end.
END PROCEDURE.

PROCEDURE controls :
ENABLE
b-exit b-arch b-price b-rest b-card b-chk b-lkp b-prt b-parts b-gdsreffi b-place b-dinamo b-sert b-hist add-inf
b-alt-bc
b-help
rs-list rs-cond rs-stat rs-sort a-n-c {&BROWSE-NAME}
b-sch
b-sel  WHEN LOOKUP( "b-sel",  bttns ) > 0
b-mark WHEN LOOKUP( "b-mark", bttns ) > 0
b-extart
WITH FRAME {&FRAME-NAME}.
IF mImagePh THEN
    ASSIGN
        /* rect-image:HIDDEN  = YES
        rect-image:VISIBLE = NO */
        g-image:HIDDEN     = NO
        g-image:VISIBLE    = YES
        g-image:SENSITIVE  = YES
        .
ELSE
    ASSIGN
        /* rect-image:HIDDEN  = YES
        rect-image:VISIBLE = NO */
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .
if lookup( "no-object":U, p-other, {&delim-par} ) > 0 then do:
  if v-obj-name = "":U then do:
    run proc-b-obj in this-procedure ( input "":U ).
  end.
  hide
  b-add b-add-office
  b-grp b-del b-copy b-chg
  in frame {&FRAME-NAME} .
  display
  b-obj
  v-obj-type
  v-obj-code
  v-obj-name
  with frame {&FRAME-NAME} .
  enable
  b-obj
  with frame {&FRAME-NAME} .
end.
if a-n-c = "art" then do:
  display
  loc-art
  with frame {&FRAME-NAME}.
end.
else do:
  hide loc-art loc-name loc-code NameContext in frame {&FRAME-NAME}.
end.
CASE g-cond :
  when {&all} then do:
    assign
    rs-sort = {&Article}
    .
    display
    rs-sort
    with frame {&FRAME-NAME} .
    disable
    rs-sort
    with frame {&FRAME-NAME} .
  end.
  when {&g___object} then do:
    assign
    rs-sort = {&Article}
    .
    enable
    rs-sort
    with frame {&FRAME-NAME} .
    assign
    g#log = rs-sort :disable("Количество")
    .
    display
    rs-sort
    with frame {&FRAME-NAME} .
  end.
  otherwise do:
    enable
    rs-sort
    with frame {&FRAME-NAME} .
    assign
    g#log = rs-sort :enable("Количество")
    .
    display
    rs-sort
    with frame {&FRAME-NAME} .
  end.
END CASE .
END PROCEDURE.

PROCEDURE enable_UI :
RUN buttons  IN THIS-PROCEDURE.
RUN controls IN THIS-PROCEDURE.
RUN openbr  IN THIS-PROCEDURE ( INPUT NO, input yes, input no, input '':U).
END PROCEDURE.

PROCEDURE UI-on :
DEFINE VARIABLE var-disable-sort AS LOGICAL NO-UNDO .
&if "{1}" = "goo-doc" &then
if from-b-sch then do:
  RUN openbr IN THIS-PROCEDURE ( INPUT YES , input yes, input no, input '':U) .
end.
&else
if flt-rec <> ? then do:
  if var-disable-sort then do:
    DISABLE
    rs-sort
    WITH FRAME {&FRAME-NAME}.
  end.
  else do:
    ENABLE
    rs-sort
    WITH FRAME {&FRAME-NAME}.
  end.
end.
else do:
  ENABLE
  rs-sort
  WITH FRAME {&FRAME-NAME}.
  if from-b-sch then do:
    RUN openbr IN THIS-PROCEDURE ( INPUT YES, input yes, input no, input '' ) .
  end.
end.
&endif
apply "entry":U             to {&BROWSE-NAME} in frame {&FRAME-NAME}.
apply "value-changed":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
END PROCEDURE.

PROCEDURE b-mark-proc:
    {&net-proc}

    define variable v-num-entry as integer no-undo .

    assign
      v-num-entry = lookup( string( recid( goo-doc ) ), rid-list )
    .
    if v-num-entry > 0 then do:
      assign
        entry( v-num-entry, rid-list ) = "":U
      .
      assign
        rid-list = trim( replace( rid-list, {&comma-char} + {&comma-char}, {&comma-char} ), {&comma-char} )
      .
    end.
    else do:
      if num-entries( rid-list ) >= 4000 then do:
        message "Превышено максимально допустимое количество выбранных товаров"
                "Воспользуйстесь добавлением товаров через список товаров, если это возможно"
        view-as alert-box WARNING.
        undo, return error.
      end.
      assign
        rid-list = rid-list + ( if rid-list = "":U then "":U else {&comma-char} ) + string( recid( goo-doc) )
      .
    end.
    assign
      g#log = {&BROWSE-NAME} :refresh( ) in frame {&FRAME-NAME}
    .
    if num-entries( rid-list ) = 0 then do:
        hide
          mark-num in frame {&FRAME-NAME}.
    end.
    else do:
        display
          num-entries( rid-list ) @ mark-num
        with frame {&FRAME-NAME}.
    end.
    if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,Return" ) = 0 then
        do:
            assign
              g#log = {&BROWSE-NAME} :select-next-row () in frame {&FRAME-NAME}
            .
            apply "value-changed":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
        end.
    apply "entry":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.

END PROCEDURE.

PROCEDURE b-del-proc:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
  define variable v-stts like ub.goods.stts no-undo .
  define buffer loc_gds-obj for ub.gds-obj.

    {&net-proc-loc}
    assign
      g#log = FALSE
    .
    CASE loc-goo-doc.gds-type :
      when {&gds-goods} then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_reference_deletion':U
          {&cntxt-object}
          0
          '':U
          0
          0
          loc-goo-doc.grp-code
          0
          true
          g#log
        }
      end.
      when {&gds-office} then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_reference-services_deletion':U
          {&cntxt-object}
          0
          '':U
          0
          0
          loc-goo-doc.grp-code
          0
          true
          g#log
        }
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип товара" skip
          "Тип товара" loc-goo-doc.gds-type skip
          "Код товара" loc-goo-doc.gds-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    END CASE.
    if NOT g#log then do: return error . end.
    v-stts = ?.
    run ref/goods02.p (
                   input gds-rec
                  ,input no /*p-silent*/
                  ,input-output v-stts) no-error.
    if error-status:error then do:
      apply "entry":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
      return error.
    end.
    assign
    g-rep            = recid( loc-{1} )
    v-chg-rec        = g-rep.
END PROCEDURE.


PROCEDURE local-find:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.

  assign
    vat-p = ?
    SLT-p = ?
  .
  FIND FIRST loc-goo-doc NO-LOCK WHERE
             loc-goo-doc.artic     = loc-gob-doc.artic     AND
             loc-goo-doc.prod-code = loc-gob-doc.prod-code AND
             loc-goo-doc.prod-type = loc-gob-doc.prod-type
                                  USE-INDEX pi NO-ERROR.
  { gbl/pftxvalg.i loc-goo-doc.gds-code {&vat-tax-code} ? v-host-code p-obj-type p-obj-code vat-p no-error }
  { gbl/pftxvalg.i loc-goo-doc.gds-code {&slt-tax-code} ? v-host-code p-obj-type p-obj-code slt-p no-error }
&scop status-code string(loc-goo-doc.stts)
  assign
    e-name = loc-goo-doc.engl-name
    gds-n  = (if loc-goo-doc.stts = 0 then loc-goo-doc.gds-name else  (substring( loc-goo-doc.gds-name, 1, 15 ) + {&space-char} + '<':U + CAPS({&gds-status-int-name}) + '>':U  ))
    gds-t  = ( if loc-goo-doc.gds-type = {&gds-goods} then "-" else "+" )
    unit-b = loc-goo-doc.unit-base
    qnty-c = loc-goo-doc.qnty-cart
  .
END PROCEDURE.


PROCEDURE b-chk-proc:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.

  DEFINE VARIABLE rid-list    AS   CHARACTER          NO-UNDO .
  DEFINE VARIABLE v-main-code LIKE ub.bar-code.b-code NO-UNDO .

  DEFINE BUFFER buf_units FOR ub.units.

  do
  on error undo, return error
  :
    {&net-proc-loc}
    { gbl/gdsbcode.i loc-goo-doc.gds-code ? v-main-code }
    FIND FIRST ub.gds-prt NO-LOCK WHERE
               ub.gds-prt.upper-code = loc-goo-doc.prt-root.
    find first buf_units No-LOCK WHERE
               buf_units.unit-name = loc-goo-doc.unit-base .
    if ub.gds-prt.node-name = {&empty-scale}
    or not v-doc-prt = yes then do:
      if lookup( {&serial}, buf_units.type ) > 0 then do:
        run ref/gds-chks.w (  INPUT parparentproc
                       ,  INPUT RECID( loc-goo-doc )
                       ,  INPUT "":U
                       ,  INPUT {&g___object}
                       ,  INPUT ? /* pardoc-rec */
                       ,  INPUT p-obj-type
                       ,  INPUT p-obj-code
                       ,  INPUT "":U
                       ,  INPUT "":U
                       , OUTPUT rid-list
                       ) .
      end.
      else do:
        run ref/gds-chk.w (  INPUT parparentproc
                      ,  INPUT v-main-code
                      ,  INPUT "":U
                      ,  INPUT {&g___object}
                      ,  INPUT ? /*pardoc-rec*/
                      ,  INPUT p-obj-type
                      ,  INPUT p-obj-code
                      ,  INPUT "":U
                      ,  INPUT "":U
                      , OUTPUT rid-list
                      ) .
      end.
    end.
    else do:
      message
        "Товар делится на признаки - смотрите чеки через шкалу."
      view-as alert-box.
    end.
    apply "entry":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
  end.
END PROCEDURE.

PROCEDURE proc-m-ostatki-1:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.

    {&net-proc-proc-loc}
    FIND FIRST ub.gds-prt NO-LOCK WHERE
               ub.gds-prt.upper-code = loc-goo-doc.prt-root .
    run rep/gds-objs.w (
                     INPUT parparentproc,
                     INPUT loc-goo-doc.artic,
                     INPUT loc-goo-doc.prod-type,
                     INPUT loc-goo-doc.prod-code,
                     INPUT v-host-code,
                     INPUT -1
                   ).
    apply "entry":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
END PROCEDURE.

PROCEDURE proc-m-ostatki-2:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
  {&net-proc-proc-loc}
  run ref/cli-gdss.w
                 (input parparentproc
                 ,input {&goods-cmp_stock-cmp}
                 ,input recid( loc-goo-doc )
                 ,input ?
                 )
  .
  apply "entry":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
END PROCEDURE.

PROCEDURE proc-m-oborot-1:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.

  {&net-proc-proc-loc}
  assign
    g#log = no
  .
  message "Вывод отчета предполагает РАСЧЕТ АРХИВОВ по товарам" skip
          "Продолжать?"
  view-as alert-box QUESTION buttons YES-NO update g#log.
  if g#log = yes then do:
    run rep/e-good2.w ( input parParentProc,
                    input loc-{1}.artic,
                    input loc-{1}.prod-type,
                    input loc-{1}.prod-code,
                    input ?, /* start-date */
                    input ?, /* end-date   */
                    input p-obj-type,
                    input p-obj-code          ) no-error.
  end.
  apply "entry":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
END PROCEDURE.

PROCEDURE proc-m-oborot-2:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
  {&net-proc-proc-loc}
  run ref/cli-gdss.w (
                   input parparentproc
                 , input {&goods-cmp_balance-cmp}
                 , input recid( loc-goo-doc )
                 , input ?
                 ).
  apply "entry":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
END PROCEDURE.

PROCEDURE proc-b-sch:
run init-flt in this-procedure no-error.

if error-status :error then do:
  return error.
 end.

DO ON STOP UNDO, LEAVE :
  run gbl/filter.w ( INPUT parparentproc
                    ,INPUT (filter-point + {&delim-par} + filter-label)
                    ,INPUT tbl
                    ,INPUT join-tbl
                    ,INPUT fld
                    ,INPUT lab
                    ,INPUT spr
                    ,INPUT dim
                    )
                        .
  ASSIGN
  from-b-sch = YES
  .
  RUN UI-on IN THIS-PROCEDURE.
  /*RUN OpenBr in this-procedure ( yes, yes, no, '':U).*/
  ASSIGN
  from-b-sch = NO
  .
END.

run buttons in this-procedure.
END PROCEDURE.

PROCEDURE proc-find:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.

  define variable for-last-pcnt as decimal column-label "Торг.наценка" format "->>>,>>9.99%" no-undo.

  assign
    val-vat = ?
    val-SLT = ?
  .

  FIND FIRST ub.recipe NO-LOCK WHERE
             ub.recipe.prod-type = loc-goo-doc.prod-type
         AND ub.recipe.prod-code = loc-goo-doc.prod-code
         AND ub.recipe.artic     = loc-goo-doc.artic
&if "{1}" = "gob-doc"  &then
         AND
           (
           ( ub.recipe.obj-type  = loc-gob-doc.obj-type
         AND ub.recipe.obj-code  = loc-gob-doc.obj-code
           )
          OR
           ( ub.recipe.obj-type  = "":U
         AND ub.recipe.obj-code  = 0
           )
           )
&endif
         NO-ERROR.
    assign
      mark-recipe = ( if available ub.recipe then ub.recipe.recipe-type else "":U )
      mark        = ( if lookup( string( recid( loc-goo-doc ) ), rid-list ) > 0 then "*" else "":U )
    .
    { gbl/pftxvalg.i loc-goo-doc.gds-code {&vat-tax-code} ? v-host-code p-obj-type p-obj-code val-vat no-error }
    { gbl/pftxvalg.i loc-goo-doc.gds-code {&slt-tax-code} ? v-host-code p-obj-type p-obj-code val-slt no-error }
    &if "{1}" = "goo-doc" &then
        FIND FIRST loc-gob-doc WHERE
                   loc-gob-doc.obj-type  = p-obj-type            AND
                   loc-gob-doc.obj-code  = p-obj-code            AND
                   loc-gob-doc.prod-type = loc-goo-doc.prod-type AND
                   loc-gob-doc.prod-code = loc-goo-doc.prod-code AND
                   loc-gob-doc.artic     = loc-goo-doc.artic     NO-LOCK NO-ERROR.
    &endif
    if available loc-gob-doc then do:
      assign
        fact-q         = loc-gob-doc.fact-qnty
        free-q         = loc-gob-doc.free-qnty
        price          = loc-gob-doc.price-sale
        for-cash-parts = loc-gob-doc.cash-parts
        for-last-price = ( if v-lookup-cost then loc-gob-doc.last-base else ? )
        for-last-pcnt  = ( if v-lookup-cost then ( price /
                         ( if v-curr-r-b = {&r-b-base} then loc-gob-doc.last-base else loc-gob-doc.last-rubl ) *
                           100 - 100 )      else ? )
      .
      if abs( for-last-pcnt ) > 999999.99 then do:
        assign
          for-last-pcnt-str = "############":U
        .
      end.
      else do:
        assign
          for-last-pcnt-str = string( for-last-pcnt, "->>>,>>9.99%":U )
        .
      end.

      if v-is-ptrl = "yes" then do:
        run get-petrol-weight-qty in this-procedure ( buffer loc-goo-doc,
                                                      buffer loc-gob-doc,
                                                      output free-q-cli,
                                                      output fact-q-cli ) no-error.
        if error-status :error then do: return error return-value. end.
      end.
      /*run assort-polit in this-procedure (  input  loc-goo-doc.gds-code ,
                                            input  p-obj-type           ,
                                            input  p-obj-code           ,
                                            output v-indicator-life-gds ,
                                            output v-assort-min          )
                                            no-error.
      if error-status :error then do: return error return-value. end. */
    end.
    else do:
      assign
        fact-q         = 0
        free-q         = 0
        price          = 0
        for-cash-parts = no
        for-last-price = 0
        for-last-pcnt  = ?
        free-q-cli    = 0.0
        fact-q-cli    = 0.0
        v-indicator-life-gds = ""
        v-assort-min         = no
      .
    end.
END PROCEDURE.


PROCEDURE b-recip-proc:
DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.

if is-fbr then do:
  {&net-proc-loc}
  if loc-goo-doc.gds-type = {&gds-office} then do:
    BELL.
    return error.
  end.
  FIND FIRST ub.units NO-LOCK WHERE ub.units.unit-name = loc-goo-doc.unit-base .
  if lookup( ub.units.type, {&serial} ) > 0 then do:
    message "Для серийного товара" skip
            "рецепт задать нельзя !"
    view-as alert-box INFORMATION .
  end.
  else do:
    FIND FIRST ub.gds-prt NO-LOCK WHERE ub.gds-prt.upper-code = loc-goo-doc.prt-root .
    if lookup( ub.gds-prt.node-name, {&empty-scale} ) > 0 then do:
      run ref/rcp-all.w (
                      input parparentproc
                    , input ( if loc-goo-doc.stts = 0
                                  AND ub.db.add-goods
                                  AND NOT transaction
                                then "b-add"
                                else "":U )
                    , input {&all}
                    , input recid( loc-goo-doc )
                    , input p-obj-type
                    , input p-obj-code
                    , output ref-list
                    ) .

      FIND FIRST ub.recipe NO-LOCK WHERE
                  ub.recipe.prod-type = loc-goo-doc.prod-type
              AND ub.recipe.prod-code = loc-goo-doc.prod-code
              AND ub.recipe.artic     = loc-goo-doc.artic
  &if "{1}" = "gob-doc"  &then
              AND
                (
                ( ub.recipe.obj-type  = loc-gob-doc.obj-type
              AND ub.recipe.obj-code  = loc-gob-doc.obj-code
                )
              OR
                ( ub.recipe.obj-type  = "":U
              AND ub.recipe.obj-code  = 0
                )
                )
  &endif
              NO-ERROR.
      assign
        mark-recipe = ( if available ub.recipe then substring( ub.recipe.recipe-type, 1, 1 ) else " ":U )
      .
      DISPLAY
        mark-recipe
      WITH BROWSE {&BROWSE-NAME}.
    end.
    else do:
      message "Рецепт можно определить" skip
              "только для товара БЕЗ ПРИЗНАКОВ."
      view-as alert-box INFORMATION .
    end.
  end.
  apply "entry":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
end.
END PROCEDURE.


PROCEDURE proc-rs-list:
  define variable i-rs-list like rs-list no-undo .
  define variable ref-rec   as   recid   no-undo .
    assign
        i-rs-list = input frame {&FRAME-NAME} rs-list
    .
    CASE i-rs-list :
        when {&producer} then do:
          assign
            ref-list = "":U
          .
          run ref/cli-all.w (
                           input parparentproc
                        ,  input "b-sel"
                        ,  input {&pro}
                        ,  input {&all}
                        ,  input {&current}
                        ,  input ?
                        ,  input ",,,,,,NO,,,"
                        ,  input ?
                        , output ref-list
                        ) .
          if ref-list = "":U then do:
            assign
              g-list = {&all}
            .
            RUN enable_UI IN THIS-PROCEDURE.
            return error.
          end.
          ref-rec = integer( ref-list ).
          FIND FIRST g-producer NO-LOCK WHERE
              RECID( g-producer ) = ref-rec .
          if available g-producer then do:
            assign
              p-producer-type = g-producer.obj-type
              p-producer-code = g-producer.obj-code
            .
          end.
        end.
        when {&group} then do:
          ASSIGN
            g-grp = "":U
          .
          run ref/gds-grp.w ( input parparentproc
                          ,INPUT "b-sel"
                          , input p-obj-type
                          , input p-obj-code
                          , INPUT-OUTPUT g-grp ).
          IF g-grp = "":U THEN DO:
            ASSIGN
              g-list = {&all}
            .
            RUN enable_UI IN THIS-PROCEDURE.
            RETURN ERROR.
          END.
          FIND FIRST ub.gds-grp NO-LOCK WHERE
              RECID( ub.gds-grp ) = INTEGER( g-grp ) .
          ASSIGN
            g-grp = "":U
          .
          RUN grplib-get-full-name IN THIS-PROCEDURE ( INPUT gds-grp.node-code, OUTPUT g-grp ).
        end.
    END CASE .
    assign
      g-list = input frame {&FRAME-NAME} rs-list
      a-n-c :screen-value = "art"
    .
    apply "value-changed":U to a-n-c in frame {&FRAME-NAME} .
    RUN enable_UI IN THIS-PROCEDURE.
END PROCEDURE.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION Get-good Dialog-Frame
FUNCTION Get-good RETURNS CHARACTER
  ( buffer loc-goods for goo-doc, buffer loc-gds-obj for gob-doc ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  define variable for-last-pcnt as decimal column-label "Торг.наценка" format "->>>,>>9.99%" no-undo.
  DEFINE VARIABLE vImageList AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE vCh        AS CHARACTER  NO-UNDO.
  mphcol = NO.

&if "{1}" = "gob-doc"  &then
    FIND FIRST loc-goods NO-LOCK WHERE
               loc-goods.artic     = loc-gds-obj.artic     AND
               loc-goods.prod-code = loc-gds-obj.prod-code AND
               loc-goods.prod-type = loc-gds-obj.prod-type
                                    USE-INDEX pi NO-ERROR.
    if not available loc-goods then do:
      assign
        e-name         = "?"
        gds-n          = "?"
        gds-t          = "?"
        unit-b         = "?"
        qnty-c         = ?
        VAT-p          = ?
        SLT-p          = ?
        mark-recipe    = "":U
        mark           = "":U
        fact-q         = 0
        free-q         = 0
        price          = 0
        for-cash-parts = no
        for-last-price = 0
        for-last-pcnt  = ?
        free-q-cli    = 0.0
        fact-q-cli    = 0.0
        v-indicator-life-gds = ""
        v-assort-min         = no
      .
      RETURN MARK.
    END.
 


    assign
      e-name = loc-goods.engl-name
      gds-t  = ( if loc-goods.gds-type = {&gds-goods} then "-" else "+" )
      unit-b = loc-goods.unit-base
      qnty-c = loc-goods.qnty-cart
    .
    IF mImagePh THEN
    DO:
        RUN gds-attr-value (loc-goods.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
        mphcol = LENGTH (vImageList) > 0.
    END.
&endif
&scop status-code string(loc-goods.stts)
    gds-n  = (if loc-goods.stts = 0 then loc-goods.gds-name else  (substring( loc-goods.gds-name, 1, 15 ) + {&space-char} + '<':U + CAPS({&gds-status-int-name}) + '>':U )).
    FIND FIRST ub.recipe NO-LOCK WHERE
               ub.recipe.prod-type = loc-goods.prod-type
           AND ub.recipe.prod-code = loc-goods.prod-code
           AND ub.recipe.artic     = loc-goods.artic
&if "{1}" = "gob-doc"  &then
           AND
             (
             (
               ub.recipe.obj-type  = loc-gds-obj.obj-type
           AND ub.recipe.obj-code  = loc-gds-obj.obj-code
             )
            OR
             (
               ub.recipe.obj-type  = "":U
           AND ub.recipe.obj-code  = 0
             )
             )
&endif
               NO-ERROR.
    assign
      mark-recipe = ( if available ub.recipe then ub.recipe.recipe-type else "":U )
      mark        = ( if lookup( string( recid( loc-goods ) ), rid-list ) > 0 then "*" else "":U )
    .
    { gbl/pftxvalg.i loc-goods.gds-code {&vat-tax-code} ? v-host-code p-obj-type p-obj-code vat-p no-error }
    { gbl/pftxvalg.i loc-goods.gds-code {&slt-tax-code} ? v-host-code p-obj-type p-obj-code slt-p no-error }
    &if "{1}" = "goo-doc" &then
        FIND FIRST loc-gds-obj WHERE
                   loc-gds-obj.obj-type  = p-obj-type          AND
                   loc-gds-obj.obj-code  = p-obj-code          AND
                   loc-gds-obj.prod-type = loc-goods.prod-type AND
                   loc-gds-obj.prod-code = loc-goods.prod-code AND
                   loc-gds-obj.artic     = loc-goods.artic     NO-LOCK NO-ERROR.
    &endif
    if available loc-gds-obj then do:
      assign
        fact-q         = loc-gds-obj.fact-qnty
        free-q         = loc-gds-obj.free-qnty
        price          = loc-gds-obj.price-sale
        for-cash-parts = loc-gds-obj.cash-parts
        for-last-price = ( if v-lookup-cost then loc-gds-obj.last-base  else ? )
        for-last-pcnt  = ( if v-lookup-cost then ( price /
                         ( if v-curr-r-b = {&r-b-base} then loc-gds-obj.last-base else loc-gds-obj.last-rubl ) *
                                                            100 - 100 ) else ? )
      .
      if abs(for-last-pcnt) > 999999.99 then do:
        assign
          for-last-pcnt-str = "############":U
        .
      end.
      else do:
        assign
          for-last-pcnt-str = string( for-last-pcnt, "->>>,>>9.99%":U )
        .
      end.

      if v-is-ptrl = "yes" then do:
        run get-petrol-weight-qty in this-procedure ( buffer loc-goods,
                                                      buffer loc-gds-obj,
                                                      output free-q-cli,
                                                      output fact-q-cli ) no-error.
        if error-status :error then do: return error return-value. end.
      end.
      /*run assort-polit in this-procedure (  input  loc-goods.gds-code ,
                                            input  p-obj-type           ,
                                            input  p-obj-code           ,
                                            output v-indicator-life-gds ,
                                            output v-assort-min          )
                                            no-error.
      if error-status :error then do: return error return-value. end.*/
    end.
    else do:
      assign
        fact-q         = 0
        free-q         = 0
        price          = 0
        for-cash-parts = no
        for-last-price = 0
        for-last-pcnt  = ?
        fact-q-cli    = 0.0
        free-q-cli    = 0.0
        v-indicator-life-gds = ""
        v-assort-min         = no
      .
    end.
       IF mImagePh THEN
      DO:
        RUN gds-attr-value (loc-goods.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
        mphcol = LENGTH (vImageList) > 0.
      END.
    
 RETURN mark.
END FUNCTION.

PROCEDURE b-place-proc:
  define variable old-list-mode as character no-undo.
  define variable old-gds-rec   as recid     no-undo.
  define variable rid-list      as character no-undo.

  run ref/pl-gdss.w (
                 input parparentproc
                ,input "":U
                ,input p-obj-type
                ,input p-obj-code
                ,input {&goods}
                ,input recid(goo-doc)
                ,input ?
                ,output rid-list
                ).
END PROCEDURE.

PROCEDURE b-dinamo-proc:
  define variable old-list-mode as character no-undo.
  define variable old-gds-rec   as recid     no-undo.
  define variable rid-list      as character no-undo.

  run rep/g-dinamo.p ( input parparentproc
                 , input goo-doc.gds-code ) no-error .
END PROCEDURE.

PROCEDURE b-hist-proc:
  define variable v-rid-list  as   character            no-undo .
  define variable v-host-code like ub.sysconf.host-code no-undo .

  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  run ref/cgdshist.w (
                   input        parparentproc
                 , input        v-host-code   /* p-curr-host-code */
                 , input        p-obj-type    /* p-curr-obj-type  */
                 , input        p-obj-code    /* p-curr-obj-code  */
                 , input        "":U          /* bttns */
                 , input        "one":U       /* p-mode */
                 , input        goo-doc.gds-code
                 , input        ?             /* p-host-code */
                 , input        ?             /* p-obj-type*/
                 , input        ?             /* p-obj-code*/
                 , input        ?             /* p-corr-user-db-num */
                 , input        "":U          /* p-corr-user-name */
                 , input        "":U          /* p-subject */
                 , input        v-cntxt-db-num      /* p-db-num */
                 , input-output v-rid-list
                 ) no-error .
END PROCEDURE.

PROCEDURE proc-b-add-inf:
  DEFINE INPUT-OUTPUT PARAMETER loc-DOPINF-option AS CHARACTER NO-UNDO.
  define input parameter         loc-mode         as character no-undo .

  define variable destin_         like ub.goods.destin         no-undo .
  define variable attrib_         like ub.goods.attrib         no-undo .
  define variable user-rule_      like ub.goods.user-rule      no-undo .
  define variable sert_           like ub.goods.sert           no-undo .
  define variable struct_         like ub.goods.struct         no-undo .
  define variable deadline_       like ub.goods.deadline       no-undo .
  define variable sort_           like ub.goods.sort           no-undo .
  define variable proof_          like ub.goods.proof          no-undo .
  define variable tnved_          like ub.goods.tnved          no-undo format "x(10)":U .
  define variable unit-cst_       like ub.goods.unit-cst       no-undo .
  define variable cst-base-rate_  like ub.goods.cst-base-rate  no-undo .
  define variable nationality_    like ub.goods.nationality    no-undo .
  define variable normal-wastage_ like ub.goods.normal-wastage no-undo .
  define variable normal-waste_   like ub.goods.normal-waste   no-undo .
  define variable cond-keep-code_ like ub.goods.cond-keep-code no-undo .
  define variable is-alc          as logical                   no-undo .
  define variable is-alc-mark     as logical                   no-undo .
  define variable choose-alc-prod_ as integer                  no-undo .


  define variable prodaddress as character no-undo .
  define variable v-recid     as recid     no-undo .
  define variable v-template  as character no-undo .
  define variable loc#log     as logical no-undo .
  define variable v-update-attr as logical no-undo .
  define variable v-update-dgr as logical no-undo .
  define variable v-is-error as logical no-undo .


  define buffer loc-goods   for ub.goods.
  define buffer buf_clients for ub.clients.
  define buffer buf_firm    for ub.firm.
  define buffer buf_person  for ub.person.


  case LOC-DOPINF-option:
    when "dop-inf":U then do:
        if loc-mode = {&update} then do:
              { gbl/chk-actg.i
                v-cntxt-db-num
                v-cntxt-userid
                {&action-head-code-main}
                'actn_reference_update_dopinfo':U
                {&cntxt-object}
                v-cntxt-host-code-obj
                v-cntxt-obj-type
                v-cntxt-obj-code
                0
                goo-doc.grp-code
                0
                true
                g#log
              }
              if not g#log then do: return error . end.
        end.

      find first loc-goods no-lock where
                 loc-goods.gds-code = goo-doc.gds-code no-error .
      if available loc-goods then do:
        find first buf_clients no-lock where
                   buf_clients.obj-type = loc-goods.prod-type
              AND  buf_clients.obj-code = loc-goods.prod-code no-error .
        if available buf_clients then do:
          case buf_clients.obj-type :
            when {&cmp} then do:
              find first buf_firm no-lock where
                         buf_firm.firm-code = buf_clients.obj-code.
            end.
            when {&prs} then do:
              find first buf_person no-lock where
                         buf_person.psn-code = buf_clients.obj-code.
            end.
          end case.
        end.
      end.

        define VARIABLE v-attr-value as character no-undo .
        define VARIABLE v-attr-mark-value as character no-undo .
        define VARIABLE v-value as character no-undo .

  
        RUN gds-attr-value (
          INPUT loc-goods.gds-code,
          INPUT {&attr-alcohol-prod},
          OUTPUT v-attr-value,
          OUTPUT v-value
          ).
          if v-attr-value = "YES" then do:
            find first ub.alc-type-gds no-lock
              where ub.alc-type-gds.gds-code = loc-goods.gds-code and
              ub.alc-type-gds.create-user-db-num = 0 no-error.
            if available ub.alc-type-gds then do:
            assign
              choose-alc-prod_ = ub.alc-type-gds.alc-type-inner-code
              is-alc           = yes
              .
          
            RUN gds-attr-value (
              INPUT loc-goods.gds-code,
              INPUT {&attr-mark},
              OUTPUT v-attr-mark-value,
              OUTPUT v-value
              ).
              if v-attr-mark-value = "yes" then is-alc-mark = yes .
            end.
            if not available ub.alc-type-gds then do:
              assign
              is-alc = no
              is-alc-mark = no .
            end.
          end.
      
      if not available loc-goods or not available buf_clients then do:
        assign
          loc-dopinf-option = "":U
        .
        return error.
      end.
      assign
        destin_         = loc-goods.destin
        attrib_         = loc-goods.attrib
        user-rule_      = loc-goods.user-rule
        sert_           = loc-goods.sert
        struct_         = loc-goods.struct
        deadline_       = loc-goods.deadline
        sort_           = loc-goods.sort
        proof_          = loc-goods.proof
        tnved_          = loc-goods.tnved
        unit-cst_       = loc-goods.unit-cst
        cst-base-rate_  = loc-goods.cst-base-rate
        nationality_    = loc-goods.nationality
        normal-wastage_ = loc-goods.normal-wastage
        normal-waste_   = loc-goods.normal-waste
        cond-keep-code_ = loc-goods.cond-keep-code
        prodaddress     =
                          ( if buf_clients.obj-type = {&cmp}
                            then string( trim( buf_firm.city )    + " ":U +
                                         trim( buf_firm.addres1 ) + " ":U + trim( buf_firm.addres2 ) )
                            else string( trim( buf_person.city )  + " ":U + trim( buf_person.address ) ) )
      .
      run ref/p51121.w (
                     input        parparentproc
                   , input        p-obj-type
                   , input        p-obj-code
                   , input        {&lookup}
                   , input        loc-goods.gds-name
                   , input        buf_clients.obj-name
                   , input        prodaddress
                   , input        loc-goods.unit-base
                   , input-output destin_
                   , input-output attrib_
                   , input-output user-rule_
                   , input-output sert_
                   , input-output struct_
                   , input-output deadline_
                   , input-output sort_
                   , input-output tnved_
                   , input-output unit-cst_
                   , input-output cst-base-rate_
                   , input-output nationality_
                   , input-output normal-wastage_
                   , input-output normal-waste_
                   , input-output cond-keep-code_
                   , input-output proof_
                   , input-output is-alc
                   , INPUT-OUTPUT is-alc-mark
                   , input-output choose-alc-prod_
                   ) .
    end.
    WHEN "foto":U THEN DO:

      run ref/gds-ph.p
        (input parparentproc
        ,buffer goo-doc
		,input loc-mode
        ).
    END.
    WHEN "dop-inf-gbl":U THEN DO:
      do
      on error undo, return error
      :
      if loc-mode = {&update} then do:
              { gbl/chk-actg.i
                v-cntxt-db-num
                v-cntxt-userid
                {&action-head-code-main}
                'actn_reference_update_dopinfo_gbl':U
                {&cntxt-global}
                0
                '':U
                0
                0
                goo-doc.grp-code
                0
                true
                loc#log
              }
        end.
        else do:
           loc#log = false .
        end.

        run ref/g-attir.p (
                       input parparentproc
                      ,input (if loc#log
                              then {&update} else {&lookup})
                      ,input goo-doc.gds-code
                      ,input yes /*update on exit*/
                      ,output v-update-attr
                      ,output v-is-error
                      ) no-error .
        if error-status:error
        or v-is-error
        then do:
          message
          "Ошибка при вызове списка глобальных атрибутов товара" skip
          error-status:get-message(1) skip
          return-value
          view-as alert-box .

          assign
          loc-DOPINF-option = "":U
          .
          undo, return error.
        end.
      end. /*doe*/
    END.

    WHEN "dop-inf-host":U THEN DO:
      do
      on error undo, return error
      :
      if loc-mode = {&update} then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_reference_update_dopinfo_firm':U
          {&cntxt-firm}
          v-cntxt-host-code-obj
          '':U
          0
          0
          goo-doc.grp-code
          0
          true
          loc#log
        }
        end.
        else do:
        loc#log = false .
        end.

        run ref/gh-attir.p (
                       input parparentproc
                      ,input (if loc#log
                              then {&update} else {&lookup})
                      ,input goo-doc.gds-code
                      ,input v-host-code
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input yes /*update on exit*/
                      ,output v-update-attr
                      ,output v-is-error
                      ) no-error .
        if error-status:error
        or v-is-error
        then do:
          message
          "Ошибка при вызове списка атрибутов товара на фирме" skip
          error-status:get-message(1) skip
          return-value
          view-as alert-box .

          assign
          loc-DOPINF-option = "":U
          .
          undo, return error.
        end.
      end. /*doe*/
    END.
    WHEN "dop-inf-fbr-gds-obj":U then do:
        if loc-mode = {&update} then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_reference_update_dopinfo':U
          {&cntxt-object}
          v-cntxt-host-code-obj
          v-cntxt-obj-type
          v-cntxt-obj-code
          0
          goo-doc.grp-code
          0
          true
          loc#log
        }
      end.
      else do:
      loc#log = false .
      end.
      v-template = "":U.
      run ref/fgdsobji.w (
                       input parparentproc
                     , input  (if loc#log then {&update} else {&lookup})
                     , input  goo-doc.gds-code
                     , input  p-obj-type
                     , input  p-obj-code
                     , input  yes /*p-update-instantly*/
                     , input-output v-template
                     , output v-update-attr
                     , input-output v-recid
                     ) no-error.
      if error-status :error then do:
        assign
          loc-DOPINF-option = "":U
        .
        return error.
      end.
    END.
    WHEN "dop-inf-s-coeff":U then do:
       if loc-mode = {&update} then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_reference_update_dopinfo':U
          {&cntxt-object}
          v-cntxt-host-code-obj
          v-cntxt-obj-type
          v-cntxt-obj-code
          0
          goo-doc.grp-code
          0
          true
          loc#log
        }
        end.
        else do:
        loc#log = false .
        end.

      run ref/s-coeffr.p (
                      input parparentproc
                    ,input (if loc#log
                            then {&update} else {&lookup})
                    ,input goo-doc.gds-code
                    ,input v-host-code
                    ,input p-obj-type
                    ,input p-obj-code
                    ,input yes /*update on exit*/
                    ,output v-update-attr
                    ,output v-is-error
                    ) no-error .
      if error-status:error
      or v-is-error
      then do:
        message
        "Ошибка при вызове справочника сезонных коэффициентов товара" skip
        error-status:get-message(1) skip
        return-value
        view-as alert-box .

        assign
        loc-DOPINF-option = "":U
        .
        undo, return error.
      end.
    END.
    WHEN "dop-inf-obj-one":U
    or
    when "dop-inf-obj-cmp":U
    then do:
      do
      on error undo, return error

      :
      if loc-mode = {&update} then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_reference_update_dopinfo':U
          {&cntxt-object}
          v-cntxt-host-code-obj
          v-cntxt-obj-type
          v-cntxt-obj-code
          0
          goo-doc.grp-code
          0
          true
          loc#log
        }
        end.
        else do:
        loc#log = false .
        end.

        run ref/go-attir.p (
                       input parparentproc
                      ,input (if loc#log
                              and LOC-DOPINF-option = "dop-inf-obj-one":U
                              then {&update} else {&lookup})
                      ,input (if LOC-DOPINF-option = "dop-inf-obj-one":U
                              then {&g___object}
                              else {&cmp})
                      ,input goo-doc.gds-code
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input yes /*update on exit*/
                      ,output v-update-attr
                      ,output v-is-error
                      ) no-error .
        if error-status :error
        or v-is-error
        then do:
          message
          "Ошибка при вызове списка атрибутов товара на объекте" skip
          error-status:get-message(1) skip
          return-value
          view-as alert-box .
          assign
          loc-DOPINF-option = "":U
          .
          undo, return error.
        end.
      end. /*doe*/
      END. /*when gds-obj-attr*/
    WHEN "dop-inf-dgr-one":U
    or
    WHEN "dop-inf-dgr-cmp":U
    then do:
      do
      on error undo, return error:
        run ref/dgrattir.p (
                       input parparentproc
                      ,input (if loc-mode = {&update}
                              and LOC-DOPINF-option = "dop-inf-dgr-one":U
                              then {&update}
                              else {&lookup})
                      ,input (if LOC-DOPINF-option = "dop-inf-dgr-one":U
                                              then {&g___object}
                                              else {&cmp})
                      ,input goo-doc.gds-code
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input yes /*update on exit*/
                      ,output v-update-dgr
                      ,output v-is-error
                      ) no-error .
        if error-status :error
        or v-is-error
        then do:
          message
          "Ошибка при вызове списка скидок товара" skip
          error-status:get-message(1) skip
          return-value
          view-as alert-box .
          assign
          loc-DOPINF-option = "":U
          .
          undo, return error.
        end.
      end. /*doe*/
    END. /*when dis-gds-rule*/
    WHEN "indicators":U then do:
    if loc-mode = {&update} then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_reference_update_dopinfo':U
              {&cntxt-object}
              v-cntxt-host-code-obj
              v-cntxt-obj-type
              v-cntxt-obj-code
              0
              goo-doc.grp-code
              0
              true
              loc#log
            }
       end.
       else do:
            loc#log = false .
       end.

        run ref/gds-indr.p (
              input parparentproc
            ,input "indicators":U
            ,input (if loc#log
                    then {&update}
                    else {&lookup})
            ,input goo-doc.gds-code
            ,input v-host-code
            ,input p-obj-type
            ,input p-obj-code
            ,input yes /*update on exit*/
            ,output v-update-attr
            ,output v-is-error
          ) no-error.
        if error-status :error
        or v-is-error
        then do:
          assign
            loc-DOPINF-option = "":U
          .
          undo, return error.
        end.

      END.
    WHEN "AM":U then do:

        run ref/assmatrg.w
            (input parparentproc
            , "":U /* bttn */
            ,input goo-doc.gds-code
            ,input p-obj-type
            ,input p-obj-code
            ,input ?
            ,input ?
            ,input-output v-spis
          ) no-error.
        if error-status :error
        or v-is-error
        then do:
          assign
            loc-DOPINF-option = "":U
          .
          undo, return error.
        end.

      END.

    WHEN "contr":U then do:
        run str/gds-cnts.w
            (input parparentproc
            ,input goo-doc.gds-code
            , "":U /* bttn */
            ,output v-spis
          ) no-error.
        if error-status :error
        or v-is-error
        then do:
          assign
            loc-DOPINF-option = "":U
          .
          undo, return error.
        end.

      END.

      WHEN "orders":U then do:
      if loc-mode = {&update} then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_reference_update_dopinfo':U
          {&cntxt-object}
          v-cntxt-host-code-obj
          v-cntxt-obj-type
          v-cntxt-obj-code
          0
          goo-doc.grp-code
          0
          true
          loc#log
        }
        end.
        else do:
           loc#log = false .
        end.

        run ref/gds-indr.p
            (input parparentproc
            ,input "orders":U
            ,input (if loc#log
                    then {&update}
                    else {&lookup})
            ,input goo-doc.gds-code
            ,input v-host-code
            ,input p-obj-type
            ,input p-obj-code
            ,input yes /*update on exit*/
            ,output v-update-attr
            ,output v-is-error
          ) no-error.
        if error-status :error
        or v-is-error
        then do:
          assign
            loc-DOPINF-option = "":U
          .
          undo, return error.
        end.
      end.
      WHEN "ordersf":U then do:
          if loc-mode = {&update} then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_reference_update_dopinfo_firm':U
              {&cntxt-firm}
              v-cntxt-host-code-obj
              '':U
              0
              0
              goo-doc.grp-code
              0
              true
              loc#log
            }
        end.
        else do:
           loc#log = false .
        end.

        run ref/gds-indr.p (input parparentproc
                      , "ordersf":U
                      ,input (if loc#log
                              then {&update}
                              else {&lookup})
                      ,input goo-doc.gds-code
                      ,input v-host-code
                      ,input {&cmp}
                      ,input v-host-code
                      ,input yes /*update on exit*/
                      ,output v-update-attr
                      ,output v-is-error
                    ) no-error.
        if error-status :error
        or v-is-error
        then do:
          assign
            loc-DOPINF-option = "":U
          .
          undo, return error.
        end.

      END.
      WHEN "Msf":U then do:
        define variable v-uniq-key-rec as character no-undo .
        define variable v-rid-list as character no-undo .
        run gen-key-rec in this-procedure ( input {&table_goods}
                                           ,input (buffer goo-doc:handle)
                                           ,output v-uniq-key-rec).
        run ref/gds-msfs.w ( INPUT parparentproc
                            ,INPUT (if b-add:sensitive in frame {&frame-name} then 'b-add' else '') /*bttns*/
                            ,INPUT "uniq-key-rec" /*p-list-mode*/
                            ,INPUT 0
                            ,input v-uniq-key-rec
                            ,INPUT-OUTPUT v-rid-list) NO-ERROR.
        if error-status :error
        then do:
          assign
            loc-DOPINF-option = "":U
          .
          undo, return error.
        end.
      END.
      when "alt-unit" then do:       
        define variable v-ret-unit-name  as character no-undo .
        define variable v-ret-unit-coeff as decimal no-undo .
        run ref/alt-units.w (input parParentProc,
                             input {&update},
                             input goo-doc.gds-code,
                             input "", /* ограничение списка выбора */
                             output v-ret-unit-name,
                             output v-ret-unit-coeff) .
        if error-status :error
        then do:
          assign
            loc-DOPINF-option = "":U
          .
          undo, return error.
        end.
      end.
    end case.
  assign
  loc-DOPINF-option = "":U
  .
  if loc#log then do:
     run openbr in this-procedure ( input yes, input yes, input no, input '':U ).
  end.
END.


PROCEDURE b-copy-proc:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.

    assign
      gds-rec  = recid( loc-goo-doc )
      copymode = yes
    .
    CASE loc-goo-doc.gds-type:
      when {&gds-goods} then do:
        apply "choose":U to b-add in frame {&FRAME-NAME}.
      end.
      when  {&gds-office} then do:
        apply "choose":U to b-add-office in frame {&FRAME-NAME}.
      end.
    END CASE.
    assign
      copymode = no
    .
END.

PROCEDURE b-parts-proc:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
  define variable v-prt-rec as recid no-undo .

  {&net-proc-loc}
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_archive_cost':U
    {&cntxt-object}
    v-host-code
    p-obj-type
    p-obj-code
    0
    0
    0
    true
    g#log
  }
   IF NOT g#log THEN DO: RETURN ERROR. END.
   run str/parts-l.w
     (
        input parparentproc
     ,  input p-obj-type                /* v-obj-type   */
     ,  input p-obj-code                /* v-obj-code   */
     ,  input loc-goo-doc.gds-code      /* p-gds-code   */
     ,  input "":U                      /* p-doc-code   */
     ,  input {&lookup}                 /* p-edit-mode  */
     ,  input {&parts-l_parts-rest}     /* p-r-parts    */
     ,  input {&parts-l_object-current} /* p-one-all    */
     ,  input {&parts-l_call-reference} /* p-call-point */
     , output v-prt-rec                   /* part-recid   */
     ) .
   apply "entry":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
END.

PROCEDURE proc-vc-rs-cond:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.

    if rs-cond :screen-value in frame {&FRAME-NAME} = {&all}
    and dbtype("ub") = 'PROGRESS'
    then do:
      assign
        g#log = a-n-c :enable( "Нач.слова" )
      .
    end.
    else do:
      assign
        g#log = a-n-c :disable( "Нач.слова" )
      .
    end.
    DISPLAY
      a-n-c
    WITH FRAME {&FRAME-NAME} .
    if input frame {&FRAME-NAME} rs-cond = {&all} or g-cond = {&all} then do:
            assign
              g-cond = input frame {&FRAME-NAME} rs-cond
            .
    /* переобозначаем recid для reposition по другой таблице */
            &if "{1}" = "goo-doc" &then
                FIND FIRST loc-gob-doc NO-LOCK WHERE
                           loc-goo-doc.artic     = loc-gob-doc.artic     AND
                           loc-goo-doc.prod-type = loc-gob-doc.prod-type AND
                           loc-goo-doc.prod-code = loc-gob-doc.prod-code AND
                           loc-gob-doc.obj-type  = p-obj-type            AND
                           loc-gob-doc.obj-code  = p-obj-code            NO-ERROR.
                assign
                  g-rep = ( if available loc-gob-doc then recid( loc-gob-doc ) else g-rep )
                .
            &else
                FIND FIRST loc-goo-doc NO-LOCK WHERE
                           loc-goo-doc.artic     = loc-gob-doc.artic     AND
                           loc-goo-doc.prod-type = loc-gob-doc.prod-type AND
                           loc-goo-doc.prod-code = loc-gob-doc.prod-code NO-ERROR.
                assign
                  g-rep = ( if available loc-goo-doc then recid( loc-goo-doc ) else g-rep )
                .
            &endif
    /* инициируем переключатель - смена таблицы не в результате поиска */
            a-n-c = "".
            apply "go":U to frame {&FRAME-NAME}.
            return error.
        end.
    assign
        g-cond = input frame {&FRAME-NAME} rs-cond
        a-n-c :screen-value in frame {&FRAME-NAME} = "art"
    .
    apply "value-changed":U to a-n-c in frame {&FRAME-NAME} .
    RUN enable_UI IN THIS-PROCEDURE.


END PROCEDURE.


PROCEDURE proc-b-add:
DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.

DEFINE INPUT PARAMETER p-goods AS LOGICAL NO-UNDO .

define variable old-gds-rec as recid.
define variable v-handle as handle no-undo .

assign
  old-gds-rec = gds-rec
  g#log       = FALSE
.

CASE p-goods :
  when yes then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_reference_add':U
      {&cntxt-object}
      0
      '':U
      0
      0
      0
      0
      true
      g#log
    }
  end.
  when no  then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_reference-services_add':U
      {&cntxt-object}
      0
      '':U
      0
      0
      0
      0
      true
      g#log
    }
  end.
END CASE.
if NOT g#log then do:
  BELL.
  return error .
end.
run ref/gds-form.w ( input parparentproc,
                  input ( if copymode then {&add-copy}  else {&add-def}    ) + {&comma-char} +
                        ( if p-goods  then {&gds-goods} else {&gds-office} )
                , input p-obj-type
                , input p-obj-code
                , input v-handle
                , input-output gds-rec
                ) .
if gds-rec = ? then DO:
  apply "entry":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
end.
else if gds-rec <> old-gds-rec then do:
  assign
    g-rep     = gds-rec
    v-chg-rec = g-rep
  .
  RUN openbr IN THIS-PROCEDURE ( INPUT YES, input yes, input no, input '':U ).
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */

PROCEDURE b-alt-bc-proc:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.

  define variable r-bar-code like ub.bar-code.b-code no-undo.

  {&net-proc-loc}
  assign
    gds-rec = recid( loc-goo-doc )
  .
  { gbl/gdsbcode.i loc-goo-doc.gds-code ? r-bar-code no-error }
  run ref/alt-bc.w ( input parparentproc, input p-obj-type, input p-obj-code, input r-bar-code ).

END PROCEDURE.

PROCEDURE proc-b-chg:
DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.

define variable for-gds-name  like ub.goods.gds-name  no-undo.
define variable for-engl-name like ub.goods.engl-name no-undo.
define variable for-chk-name  like ub.goods.chk-name  no-undo.
define variable v-handle as handle no-undo .


{&net-proc-loc}
assign
  g#log = FALSE
.
CASE loc-goo-doc.gds-type :
  when {&gds-goods} then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_reference_update':U
      {&cntxt-object}
      0
      '':U
      0
      0
      loc-goo-doc.grp-code
      0
      true
      g#log
    }
  end.
  when {&gds-office} then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_reference-services_update':U
      {&cntxt-object}
      0
      '':U
      0
      0
      loc-goo-doc.grp-code
      0
      true
      g#log
    }
  end.
END CASE.
if NOT g#log or loc-goo-doc.stts <> 0 then do:
  BELL.
  return no-apply.
end.
assign
  gds-rec       = recid (loc-goo-doc)
  for-engl-name = loc-goo-doc.engl-name
  for-gds-name  = loc-goo-doc.gds-name
  for-chk-name  = loc-goo-doc.chk-name
.
run ref/gds-form.w (
                  input parparentproc
                , input {&update}
                , input p-obj-type
                , input p-obj-code
                , input v-handle
                , input-output gds-rec
                ) .
if gds-rec = ? then do:
  apply "entry":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
end.
else do:
&if "{1}" = "gob-doc" &then
  /* переобозначаем g-rep для reposition по gob-doc */
  FIND FIRST loc-goo-doc NO-LOCK WHERE RECID( loc-goo-doc ) = gds-rec NO-ERROR.
  if available loc-goo-doc then do:
    FIND FIRST loc-gob-doc NO-LOCK WHERE
                loc-goo-doc.artic     = loc-gob-doc.artic
            AND loc-goo-doc.prod-type = loc-gob-doc.prod-type
            AND loc-goo-doc.prod-code = loc-gob-doc.prod-code
            AND loc-gob-doc.obj-type  = p-obj-type
            AND loc-gob-doc.obj-code  = p-obj-code NO-ERROR.
    if available loc-gob-doc then do:
      assign
        g-rep     = recid( loc-gob-doc )
        v-chg-rec = g-rep
      .
    end.
    else do:
      assign
        v-chg-rec = ?
      .
    end.
  end.
&else
  assign
    g-rep     = gds-rec
    v-chg-rec = gds-rec
  .
&endif
  RUN openbr    IN THIS-PROCEDURE ( INPUT YES, input yes, input no, input '':U ).
  run gds-ref-fi IN THIS-PROCEDURE (   BUFFER       loc-goo-doc
                                      ,BUFFER       loc-gob-doc
                                      ,INPUT        p-obj-type
                                      ,INPUT        p-obj-code
                                      ,INPUT        gdsreffi
                                      ,input        no /*p-excel*/
                                      ,INPUT-OUTPUT fi-1
                                      ,INPUT-OUTPUT fi-2
                                      ,INPUT-OUTPUT fi-3
                                      ,INPUT-OUTPUT fi-4
                                      ,INPUT-OUTPUT fi-5
                                      ,INPUT-OUTPUT fi-6
                                      ,INPUT-OUTPUT fi-7
                                      ,INPUT-OUTPUT fi-8
                                    ) NO-ERROR.
  DISPLAY
    fi-1
    fi-2
    fi-3
    fi-4
    fi-5
    fi-6
    fi-7
    fi-8
    loc-goo-doc.gds-code @ goo-doc.gds-code
  WITH FRAME {&FRAME-NAME}.
end.
END PROCEDURE.

PROCEDURE proc-b-grp:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.

  define variable was-deleted as integer initial 0 no-undo.
  define variable loc_g-grp as character no-undo .
  define variable lns-cnt as integer no-undo .
  define variable v-ok as logical no-undo .
  define variable v-old-code as integer no-undo .

  define buffer buf_gds-grp for ub.gds-grp.


  {&net-proc-loc}
  assign
    g#log = FALSE
  .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reference_upd-group':U
    {&cntxt-object}
    0
    '':U
    0
    0
    loc-goo-doc.grp-code
    0
    true
    g#log
  }
  if NOT g#log then do:
    return no-apply .
  end.
  assign
    g#log = yes
  .
  v-old-code = loc-goo-doc.grp-code .
  message
    "Выберите группу, в которую нужно переместить товар(ы)."
  view-as alert-box question buttons OK-Cancel update g#log.
  if not g#log then do:
    apply "entry":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
    return no-apply.
  end.
  run ref/gds-grp.w (
                    input parparentproc
                  , input {&g#term} + ',b-sel'
                  , input p-obj-type
                  , input p-obj-code
                  , input-output loc_g-grp ).
  if loc_g-grp = "":U then do:
    apply "entry":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
    return no-apply.
  end.
  FIND FIRST buf_gds-grp WHERE RECID( buf_gds-grp ) = INTEGER( loc_g-grp ) .
  if rid-list = "":U then do:
    assign
      rid-list = string( recid( loc-goo-doc ) )
    .
  end.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reference_upd-group':U
    {&cntxt-object}
    0
    '':U
    0
    0
    buf_gds-grp.node-code
    0
    true
    g#log
  }
  if NOT g#log then do:
    return no-apply .
  end.
  assign
    g#log = yes
  .

  assign
    lns-cnt = 1
  .
  { gbl/working.i }
  DO TRANSACTION WHILE lns-cnt <= NUM-ENTRIES( rid-list ) :
    assign
      gds-rec = integer( entry( lns-cnt, rid-list ) )
    .
    
    FIND FIRST loc-goo-doc WHERE RECID( loc-goo-doc ) = gds-rec.
    IF loc-goo-doc.stts <> 0 then do:
      assign
        was-deleted = was-deleted + 1
        lns-cnt     = lns-cnt     + 1
      .
      next.
    end.

    FIND FIRST loc-goo-doc WHERE RECID( loc-goo-doc ) = gds-rec .
    assign
      lns-cnt   = lns-cnt + 1
      v-chg-rec = gds-rec
    .
    run recalc-assgds in this-procedure  ( input loc-goo-doc.gds-code, 
                                           input loc-goo-doc.grp-code,
                                           input buf_gds-grp.node-code,
                                           output v-ok    ) .

    if v-ok then loc-goo-doc.grp-code = buf_gds-grp.node-code. 
     /*проверка на запрет продажи группы*/
         if check-ban-sales-via-cd-grp(loc-goo-doc.grp-code) then do:
           run str/diallog.w (parparentproc, this-procedure, 'str/del-grp.p':U, string(v-cntxt-obj-code) + {&delim-par} + string(loc-goo-doc.grp-code), no,
                             'Прервать', 'Удаление товаров с касс') .
        end.   

     /*Проверка на атрибут ЕМЦ*/
     define variable v-value-emrc as character no-undo .
     define variable v-type-emrc  as character no-undo .
     old-value-emrc = "" .   
  
     /*Получение атрибута для старой группы*/
     for first ub.gds-grp-obj-attr no-lock
        where ub.gds-grp-obj-attr.node-code   = v-old-code
        and ub.gds-grp-obj-attr.host-code   = 0
        and ub.gds-grp-obj-attr.obj-type    = ""
        and ub.gds-grp-obj-attr.obj-code    = 0
        and ub.gds-grp-obj-attr.attr-code   = {&ggoattr-emrc-type}:
        old-value-emrc = ub.gds-grp-obj-attr.attr-value .
     end.
     /*Получение атрибута для новой группы*/
     for first ub.gds-grp exclusive-lock where ub.gds-grp.node-code = loc-goo-doc.grp-code:
        for first ub.gds-grp-obj-attr no-lock
           where ub.gds-grp-obj-attr.node-code   = loc-goo-doc.grp-code
           and ub.gds-grp-obj-attr.host-code   = 0
           and ub.gds-grp-obj-attr.obj-type    = ""
           and ub.gds-grp-obj-attr.obj-code    = 0
           and ub.gds-grp-obj-attr.attr-code   = {&ggoattr-emrc-type}:
           v-value-emrc = ub.gds-grp-obj-attr.attr-value .
        end.

        define variable v-attr-emrc as character no-undo .
        define variable v-attr-type as character no-undo .
        define variable v-del       as logical   no-undo .
        define buffer buf_goods-attr for ub.goods-attr .
        define variable v-emrc-name as character no-undo .
        
        /*Значение атрибута товара*/
        for first buf_goods-attr no-lock where buf_goods-attr.attr-code = {&attr-emrc-type} and
           buf_goods-attr.gds-code = loc-goo-doc.gds-code:
           v-attr-emrc = buf_goods-attr.attr-value .
        end.   
        if v-value-emrc <> old-value-emrc and v-attr-emrc = "" then 
        do:
           find first ub.code no-lock where ub.Code.parent = "EMC" and ub.Code.code = v-value-emrc no-error .
           if not available (ub.Code) then v-emrc-name = "Нет" .
           else v-emrc-name = ub.Code.CodeName .       
           message "При переносе в группу " + string(ub.gds-grp.node-name) + " для товара " + string(loc-goo-doc.gds-name) skip 
              "будет наследоваться значение новой группы тип ЕМЦ - " + v-emrc-name + ". " skip
              "При утвердительном ответе товар переносится в новую группу, значение тип ЕМЦ - " + v-emrc-name 
              view-as alert-box question buttons yes-no-cancel update choice as logical .
           CASE choice:
              WHEN TRUE THEN /* Yes */ 
                 DO:
                 END.
              WHEN FALSE THEN /* No */ 
                 DO:
                    run gds-attr-write IN THIS-PROCEDURE(
                       input loc-goo-doc.gds-code
                       ,INPUT {&attr-emrc-type}
                       ,INPUT old-value-emrc ) .
                 END.
              OTHERWISE 
              DO: /* Cancel */ 
                 loc-goo-doc.grp-code = v-old-code .
              end.
           END CASE.
        end.   
        if v-value-emrc <> v-attr-emrc and v-attr-emrc <> "" then do:
           define variable ichoice as integer no-undo .
           
           find first ub.code no-lock where ub.Code.parent = "EMC" and ub.Code.code = v-attr-emrc no-error .
           if not available (ub.Code) then v-emrc-name = "Нет" .
           else v-emrc-name = ub.Code.CodeName .            
                  run gbl/d-askw.w (
                     input "Сообщение"
                     ,input  "На товар установлен атрибут «тип ЕМЦ» - " + v-emrc-name + ". При переносе товара значение может быть изменено."
                     ,input "|"
                     ,input "Наследовать|Оставить|Отмена"
                     ,input "Наследовать атрибут от новой группы|Оставить текущее значение атрибута|Отмена"
                     ,input 1
                     ,input 3
                     ,output ichoice).               
/*           message "На товар установлен атрибут «тип ЕМЦ»-" + string(v-attr-emrc) + ". При переносе товара значение может быть изменено." skip*/
/*           skip                                                                                                                               */
/*           "Вариант действий:" skip                                                                                                           */
/*           "ДА - Наследовать атрибут от новой группы;" skip                                                                                   */
/*           "НЕТ - Оставить текущее значение атрибута;" skip                                                                                   */
/*           "ОТМЕНА - Отменить перенос товара в другую группу." skip                                                                           */
/*           view-as alert-box question buttons yes-no-cancel update lChoice as logical .                                                       */
           CASE iChoice:
              WHEN 1 THEN /* Yes */ 
                 DO:
              if v-value-emrc = "" then do:
              run gds-attr-delete IN THIS-PROCEDURE(
                 input loc-goo-doc.gds-code
                 ,INPUT {&attr-emrc-type}
                 ,output v-del ) .                 
              end.
              else do:
              run gds-attr-write IN THIS-PROCEDURE(
                 input loc-goo-doc.gds-code
                 ,INPUT {&attr-emrc-type}
                 ,INPUT v-value-emrc ) NO-ERROR.
              end.
                 END.
              WHEN 2 THEN /* No */ 
                 DO:
              run gds-attr-write IN THIS-PROCEDURE(
                 input loc-goo-doc.gds-code
                 ,INPUT {&attr-emrc-type}
                 ,INPUT v-attr-emrc ) .
                 END.
              OTHERWISE DO: /* Cancel */ 
              loc-goo-doc.grp-code = v-old-code .
              end.
           END CASE.
        end. 
     end.     
  END .
  { gbl/working.i }
  assign
    rid-list = "":U
    mark-num = 0
  .
  if was-deleted > 0 then do:
    message ("Из " + string(lns-cnt - 1) + " товаров удалось перенести в другую группу " +
            string (lns-cnt  - 1 - was-deleted) + {&comma-char}) skip
            "остальные товары являются неактивными -" skip
            "для них перенос ЗАПРЕЩЕН!"
    view-as alert-box WARNING.
  end.
  hide mark-num in frame {&FRAME-NAME}.
  RUN openbr IN THIS-PROCEDURE ( INPUT YES, input yes, input no, input '':U ).
END PROCEDURE.

PROCEDURE proc-rs-stat:
ASSIGN
FRAME {&FRAME-NAME}
rs-stat
g-stat = rs-stat
a-n-c :SCREEN-VALUE = "art"
.
APPLY "VALUE-CHANGED":U TO a-n-c IN FRAME {&FRAME-NAME}.
RUN openbr IN THIS-PROCEDURE ( INPUT YES, input yes, input no, input '':U ).
END PROCEDURE.

PROCEDURE proc-rs-sort:
assign
a-n-c :screen-value in frame {&FRAME-NAME} = "art"
.
apply "value-changed":U to a-n-c in frame {&FRAME-NAME} .
if rs-sort :screen-value <> {&Article} then do:
  message "При большой товарной номенклатуре" skip
          "по текущему объекту" skip
          "процесс сортировки товаров" skip
          "по выбранному Вами условию" skip
          "может занять длительное время." skip(1)
          "Продолжать ?" skip
          " "
  view-as alert-box INFORMATION buttons YES-NO update g#log .
  if g#log = yes then do:
    assign
      frame {&FRAME-NAME} rs-sort
    .
    RUN openbr IN THIS-PROCEDURE ( INPUT NO, input yes, input no, input '':U ).
  end.
  else do:
    assign
      rs-sort :screen-value in frame {&FRAME-NAME} = {&Article}
    .
  end.
end.
else do:
  assign
    frame {&FRAME-NAME} rs-sort
  .
  RUN openbr IN THIS-PROCEDURE ( INPUT NO, input yes, input no, input '':U ).
end.
END PROCEDURE.

PROCEDURE proc-br-gds:
  if b-sel :sensitive in frame {&FRAME-NAME} then do:
    /* закоментарено, т.к. в 12.3 эта ветка срабатывала только когда был G#user-online, а сейчас эту переменную вырезали вообще */
    /*
    if b-mark:sensitive then do:
      apply "choose":U to b-mark in frame {&FRAME-NAME}.
    end.
    else do:
    */
      apply "choose":U to b-sel in frame {&FRAME-NAME}.
  end.
  else do:
    if b-lkp :sensitive then do:
      apply "choose":U to b-lkp in frame {&FRAME-NAME}.
    end.
  end.

END PROCEDURE.

PROCEDURE proc-b-exit:
  assign
    a-n-c    = "вых":U
    rid-list = ""
  .
END PROCEDURE.

PROCEDURE proc-b-sel:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.

  if rid-list = "" then do:
    {&net-proc-loc}
    rid-list = string (recid (loc-goo-doc)).
  end.
  assign
    a-n-c = "вых":U
  .
END PROCEDURE.

PROCEDURE proc-b-price:

define input  parameter p-var as integer   no-undo .
define parameter buffer loc-goo-doc for ub.goods.
define parameter buffer loc-gob-doc for ub.gds-obj.

define variable v-fact-order     as decimal no-undo .
define variable v-plt-id         as integer no-undo .
define variable v-plt-db-num     as integer no-undo .
define variable v-pdf-id         as integer no-undo .
define variable v-pdf-db-num     as integer no-undo .
define variable v-sale-price-doc as decimal no-undo .

  {&net-proc-loc}
  if p-var = 2 then do:
  run str/chg-sale.w
   ( input parparentproc,
     input p-obj-type ,
     input p-obj-code ,
     BUFFER loc-goo-doc ).
  end.
  else do:
  run str/chmplgds.w
  ( input  parparentproc ,
    input  loc-goo-doc.gds-code ,
    input  p-obj-type    ,
    input  p-obj-code    ,
    input  v-fact-order  ,
    output v-plt-id      ,
    output v-plt-db-num  ,
    output v-pdf-id      ,
    output v-pdf-db-num  ,
    output v-sale-price-doc ).
  end.

  APPLY "ENTRY":U TO {&BROWSE-NAME} IN FRAME {&FRAME-NAME}.
END PROCEDURE.

PROCEDURE proc-b-lkp:
DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
define variable v-handle as handle no-undo .

{&net-proc-loc}
ASSIGN
gds-rec = RECID( loc-goo-doc )
v-handle = this-procedure :handle.
.
run ref/gds-form.w (
                  INPUT parparentproc
                , INPUT {&lookup}
                , INPUT p-obj-type
                , INPUT p-obj-code
                , input v-handle
                , input-output gds-rec
                ) .
APPLY "ENTRY":U TO {&BROWSE-NAME} IN FRAME {&FRAME-NAME}.
END PROCEDURE.

PROCEDURE proc-b-prt:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
  {&net-proc-loc}

  define variable v-sel-node-code as integer   no-undo .

  run str/prt-ref.w
    (
       input parparentproc
    ,  input loc-goo-doc.gds-code                          /* p-gds-code      */
    ,  input {&lookup}                                     /* p-mode          */
    ,  input p-obj-type                                    /* p-obj-type      */
    ,  input p-obj-code                                    /* p-obj-code      */
    ,  input "":U                                          /* p-doc-code      */
    ,  input ( if a-n-c = "code" then loc-code else "":U ) /* p-search-code   */
    , output v-sel-node-code                               /* p-sel-node-code */
    ) .
  apply "entry":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
END PROCEDURE.

{ arc/gds_inf.i calc goo-doc p-obj-type p-obj-code }

PROCEDURE proc-b-SErt:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.

  {&net-proc-loc}
   run ref/gds-sert.w (   input parparentproc
                    , input p-obj-type
                    , input p-obj-code
                    , input ( if NOT b-add :sensitive in frame {&FRAME-NAME} then {&lookup} else {&update} )
                    , input "gds"
                    , input loc-goo-doc.gds-code
                    , input ?
                    , input ?
                    , input ?
                    ) no-error.
END PROCEDURE.

procedure proc-b-extart:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
  {&net-proc-loc}
    run ref/eartform.w ( input parParentProc
                       , input {&update}
                       , input loc-goo-doc.gds-code
                       ) no-error .
 if error-status :error then do:
  message error-status :get-message(1) view-as alert-box information .
 end.
end procedure.

Procedure main-block-proc:
{ gbl/curr-r-b.i v-curr-r-b }
{ gbl/hostcode.i p-obj-type p-obj-code v-host-code }
FIND FIRST ub.db NO-LOCK WHERE ub.db.db-num = v-cntxt-db-num .
{ gbl/conf-rd.i
    "'is-prt'"
    0
    "''"
    0
    "''"
    "''"
    "''"
    no
    dops
    dopst
    no-error
}
assign
  is-prt = ( if error-status :error or dops <> "yes" then no else yes )
.
{ gbl/objat.i p-obj-type p-obj-code 'doc-prt=request':U v-doc-prt no-error }
assign
  v-doc-prt = ( is-prt and v-doc-prt )
.
{ gbl/conf-rd.i
    "'is-fbr'"
    "''"
    "''"
    0
    "''"
    "''"
    "''"
    no
    dops
    dopst
    no-error
}
assign
  is-fbr = ( dops = "yes" )
.

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_archive_cost':U
  {&cntxt-object}
  v-host-code
  p-obj-type
  p-obj-code
  0
  0
  0
  false
  v-lookup-cost
}
def var v-str-temp as character no-undo.
run uf-get in this-procedure (
    input {&uf-gdsreffi}
  ,input  v-cntxt-userid
  ,output v-uf-List_
  ,output v-uf-Naim
  ,output v-uf-print-graft
  ,output v-uf-sort-gr
  ,output v-uf-type-price
  ,output v-uf-type-val
  )  no-error.
if not error-status :error then do:
  assign
  gdsreffi = entry(1, v-uf-list_,  {&delim-par} ) no-error.
  v-str-temp = entry(2, v-uf-list_,  {&delim-par} ) no-error.
  if v-str-temp = "ptrl"
  or v-str-temp = "lgas"
  or v-str-temp = "ptrlsug"
  then do:
    entry(2, v-uf-list_,  {&delim-par} ) = {&current}.
  end.
end.
RUN gds-ref-to IN THIS-PROCEDURE (
                                     INPUT        gdsreffi
                                    ,INPUT-OUTPUT myto[1]
                                    ,INPUT-OUTPUT myto[2]
                                    ,INPUT-OUTPUT myto[3]
                                    ,INPUT-OUTPUT myto[4]
                                    ,INPUT-OUTPUT myto[5]
                                    ,INPUT-OUTPUT myto[6]
                                    ,INPUT-OUTPUT myto[7]
                                    ,INPUT-OUTPUT myto[8]
                                  ) NO-ERROR.
assign
fi-1 :tooltip in frame {&FRAME-NAME} = myto[1]
fi-2 :tooltip      = myto[2]
fi-3 :tooltip      = myto[3]
fi-4 :tooltip      = myto[4]
fi-5 :tooltip      = myto[5]
fi-6 :tooltip      = myto[6]
fi-7 :tooltip      = myto[7]
fi-8 :tooltip      = myto[8]
.
find first g-producer no-lock where
            g-producer.obj-type = p-producer-type
      AND  g-producer.obj-code = p-producer-code no-error.
if ( g-list = {&producer} ) AND ( NOT available g-producer ) then do:
  assign
    g-list = {&all}
  .
end.
if num-entries (rid-list) = 0 then do:
  hide mark-num in frame {&FRAME-NAME}.
end.
else do:
  display
    num-entries( rid-list ) @ mark-num
  with frame {&FRAME-NAME}.
end.
{&BROWSE-NAME} :SET-REPOSITIONED-ROW( 5, "CONDITIONAL":U ).

{ gbl/conf-rd.i
    "'is-ptrl'"
    "''"
    "''"
    0
    "''"
    "''"
    "''"
    no
    v-is-ptrl
    v-data-type
    no-error
}
if error-status :error or v-data-type <> "L" or lookup( v-is-ptrl, "yes,no" ) = 0 then do:
  assign
    v-is-ptrl = "no"
  .
end.
if v-is-ptrl <> "yes" then do:
  assign
    free-q-cli :visible in browse {&BROWSE-NAME} = no
    fact-q-cli :visible in browse {&BROWSE-NAME} = no
  .
end.
assign
gds-n:resizable in browse {&browse-name} = true
price:label in browse {&browse-name} = substitute("Цена (&1)", (if v-curr-r-b = {&r-b-rubl} then "нац.вал." else "баз.вал."))
gds-n:width in browse {&browse-name} = p-gds-name-width
{1}.grp-name:resizable in browse {&browse-name} = true
{1}.grp-name:width in browse {&browse-name} = p-grp-name-width
v-indicator-life-gds:resizable in browse {&browse-name} = true .
v-indicator-life-gds:width in browse {&browse-name} = 8 .
.
RUN enable_UI IN THIS-PROCEDURE.
RUN buttons   IN THIS-PROCEDURE. /* выключим кнопки если фильтр */
g#log = ( if rs-cond :screen-value in frame {&FRAME-NAME} = {&all}
          and dbtype("ub") = 'PROGRESS'
          then a-n-c :enable(  "Нач.слова" )
          else a-n-c :disable( "Нач.слова" ) ).
if a-n-c <> "вых" then do:
  /*меры против операторов, которые тыкают в выход не дожидаясб открытия формы*/
DISPLAY
  a-n-c
WITH FRAME {&FRAME-NAME} .
end.
END PROCEDURE.

PROCEDURE init-flt:
&if "{1}" = "goo-doc" &then
assign
  tbl = 'goods'
  join-tbl = "goo-doc"
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
.
run fltfield-add in this-procedure('artic', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('gds-name', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('gds-code', 'Код товара', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('engl-name', 'Название по-английски', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-name', 'Название на чеке', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('prod-type{&delim-flt}prod-code', 'Производитель', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('unit-base', '', 'unit',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('unit-cli', '', 'unit',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('grp-name', '', 'gdsgrp',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('prt-root', 'Шкала', 'prt',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('increase-pc', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('calc-method', 'Метод наценки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('qnty-cart', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('okdp', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('destin', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sert', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('struct', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sort', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('deadline', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('negative-rest', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cost-calc', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('gds-type', 'Услуга-товар', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tnved', 'Код ТНВЭД', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('nationality', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('unit-cst', 'Таможенная единица', 'unit',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('alpha1', 'Код страны изготовления', 'country',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('normal-wastage', 'Норма естест.убыли', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('normal-waste', 'Норма отходов', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('min-rate', 'Min кол-во в штуке', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('max-rate', 'Max кол-во в штуке', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ms-base', 'Объем штуки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ms-cart', 'Объем упаковки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('wt-base', 'Все штуки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('wt-cart', 'Веc упаковки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cond-keep-code', 'Условия хранения', 'cond-keep',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


&else
  assign
    tbl = 'gds-obj'
    join-tbl = 'gob-doc'
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
  .
  run fltfield-add in this-procedure('artic', '', ''
  , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('prod-type{&delim-flt}prod-code', 'Производитель', 'cli'
  , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('grp-name', '', 'gdsgrp'
  , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('free-qnty', 'Свободно (кол-во)', ''
  , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-qnty', 'Факт (кол-во)', ''
  , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-cli-qnty', 'Факт в ед.пост-ка', ''
  , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('price-sale', 'Продажная цена', ''
  , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cash-parts', 'Продажа по партиям', ''
  , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('place-rsrv', 'Резерв по скл.местам', ''
  , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_income_lookup':U
      {&cntxt-object}
      v-host-code
      p-obj-type
      p-obj-code
      0
      0
      0
      true
      g#log
    }
    if g#log = yes then do:
      run fltfield-add in this-procedure('in-code', 'Номер приходной накладной', ''
      , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
      run fltfield-add in this-procedure('in-date', 'Дата приходной накладной', ''
      , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    end.
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_archive_cost':U
      {&cntxt-object}
      v-host-code
      p-obj-type
      p-obj-code
      0
      0
      0
      true
      g#log
    }
    if g#log = yes then do:
      run fltfield-add in this-procedure('avrg-base', '', ''
      , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
      run fltfield-add in this-procedure('last-base', '', ''
      , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
      run fltfield-add in this-procedure('avrg-rubl', '', ''
      , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
      run fltfield-add in this-procedure('last-rubl', '', ''
      , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    end.
&endif

END PROCEDURE.

procedure proc-b-obj :
  define input parameter p-mode as character no-undo .

  define variable v-host-code   as integer   no-undo .
  define variable v-user-select as logical   no-undo .
  define variable v-obj-type    as character no-undo .
  define variable v-obj-code    as integer   no-undo .

  define buffer buf_clients  for ub.clients.

  do
  on error undo, return error
  :
    if p-mode = "change":U
    then do:
      { gbl/hostcode.i
        p-obj-type
        p-obj-code
        v-host-code
      }
      { gbl/uobjsone.i
        parparentproc
        v-cntxt-db-num
        v-cntxt-userid
        v-cntxt-host-code-obj
        v-cntxt-obj-type
        v-cntxt-obj-code
        v-user-select
        v-obj-type
        v-obj-code
      }
      if v-user-select <> true
      then do:
        return . /* --->>>--- */
      end.
    end.
    else do:
      assign
        v-obj-type = p-obj-type
        v-obj-code = p-obj-code
      .
    end.
    find first buf_clients no-lock
      where buf_clients.obj-type = v-obj-type
        and buf_clients.obj-code = v-obj-code
      no-error .
    if not available buf_clients
    then do:
      undo, return error.
    end.
    assign
      p-obj-type = buf_clients.obj-type
      p-obj-code = buf_clients.obj-code
      v-obj-type = buf_clients.obj-type
      v-obj-code = buf_clients.obj-code
      v-obj-name = buf_clients.obj-name
    .
    run main-block-proc in this-procedure .
  end.

end procedure. /* proc-b-obj */

procedure get-petrol-weight-qty :
  define        parameter buffer loc-goo-doc   for ub.goods.
  define        parameter buffer loc-gob-doc   for ub.gds-obj.
  define output parameter        p-free-q-cli as  decimal no-undo initial 0.0.
  define output parameter        p-fact-q-cli as  decimal no-undo initial 0.0.

  define variable is-petrol as logical no-undo.
  define variable is-pieces as logical no-undo.

  define buffer buf_pl-gds for ub.pl-gds .

  do on error undo, return error return-value :
    if available loc-goo-doc then do:
      assign
        p-free-q-cli = 0.0
        p-fact-q-cli = 0.0
      .
      if v-is-ptrl = "yes" then do:
        { str/is-petrl.i
          loc-goo-doc.artic
          loc-goo-doc.prod-type
          loc-goo-doc.prod-code
          is-petrol
          is-pieces
          no-error
        }
        if error-status :error then do:
          return error return-value.
        end.
        if is-petrol = true
          and is-pieces = false
        then do:
          for each buf_pl-gds no-lock
            where buf_pl-gds.gds-code = loc-goo-doc.gds-code
              and buf_pl-gds.obj-type = p-obj-type
              and buf_pl-gds.obj-code = p-obj-code
          on error undo, return error return-value
          :
            assign
              p-fact-q-cli = p-fact-q-cli + buf_pl-gds.cli-fact-qnty
              p-free-q-cli = p-free-q-cli + buf_pl-gds.cli-free-qnty
            .
          end.
        end. /* petrol */
      end.
    end. /* if available loc-goo-doc */
  end. /* on error */
end procedure. /* get-petrol-weight-qty */

procedure assort-polit :

do
on error undo, return error return-value
:

define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-indicator-life-gds like  ub.gds-obj-prop.gdop-igt                     no-undo .
define output parameter p-assort-min         like  ub.gds-obj-prop.gdop-assort-min format "*/ " no-undo .

 define variable p-gdop-min-stock              as decimal   no-undo .
 define variable p-grop-max-stock              as decimal   no-undo .
 define variable p-grop-level-always-presence  as decimal   no-undo .
 define variable p-grop-min-order              as decimal   no-undo .
if p-gds-code = 0 or p-gds-code = ? then message 444.
{ gbl/gdsobjpr.i
 p-obj-type
 p-obj-code
 ?
 ?
 ?
 p-gds-code
 p-assort-min
 p-indicator-life-gds
 p-gdop-min-stock
 p-grop-max-stock
 p-grop-level-always-presence
 p-grop-min-order
 }
end.

end procedure. /* assort-polit */


PROCEDURE reposition-goods :
define input  parameter p-direction   as character no-undo .
define output parameter p-recid as recid no-undo .

  /* перемещение на первую, последнюю, предыдущую, следующую */
  case p-direction :
    when "first":U
    then do:
      get first {&browse-name}.
    end.
    when "last":U
    then do:
      get last {&browse-name}.
    end.
    when "prev":U
    then do:
      get prev {&browse-name}.
      if not available {1} then do:
        message
        "Это первый товар списка"
        view-as alert-box.
      end.
    end.
    when "next":U
    then do:
      get next {&browse-name}.
      if not available {1} then do:
        message
        "Это последний товар списка"
        view-as alert-box.
      end.
    end.
  end case . /* p-direction */
  run reposition-query in this-procedure
    (input recid({1})
    ).
  assign
  p-recid = recid(goo-doc)
  .
END PROCEDURE.

PROCEDURE reposition-query :
define input parameter p-recid as recid no-undo .

if p-recid <> ?
then do:
  reposition {&BROWSE-NAME} to recid p-recid no-error.
end.

do with frame {&frame-name}:
  apply "entry":u to browse {&browse-name} .
  apply "VALUE-CHANGED":u to browse {&browse-name} .
end. /* do with frame */
END PROCEDURE.

procedure recalc-assgds :
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-old-grp as integer   no-undo .
define input  parameter p-new-grp as integer   no-undo .
define output parameter p-ok      as logical    no-undo .
define buffer buf_assortment-matrix       for ub.assortment-matrix  .
define buffer buf_assortment-matrix-goods for ub.assortment-matrix-goods  .
  do
  on error undo, return error return-value
  :
  find first buf_assortment-matrix-goods no-lock where
               buf_assortment-matrix-goods.gds-code =  p-gds-code and
               buf_assortment-matrix-goods.obj-type <> "" and
               buf_assortment-matrix-goods.asmg-status =  0 no-error.
  if not AVAILABLE buf_assortment-matrix-goods then do: p-ok = yes .
  end.
  else do:  
  for each buf_assortment-matrix-goods no-lock where
           buf_assortment-matrix-goods.gds-code =  p-gds-code and
           buf_assortment-matrix-goods.obj-type <> "" and
           buf_assortment-matrix-goods.asmg-status =  0 ,
      first buf_assortment-matrix no-lock where
            buf_assortment-matrix.asmt-status =  0 and
            buf_assortment-matrix.obj-type <> "" and
            buf_assortment-matrix.asmt-id = buf_assortment-matrix-goods.asmt-id  and
            buf_assortment-matrix.db-num  = buf_assortment-matrix-goods.db-num
           :
       run utl/uassmgrp.p ( p-old-grp, p-new-grp, buf_assortment-matrix.asmt-id , buf_assortment-matrix.db-num, output p-ok ) no-error.
  end.
  end.
  end.
end procedure. /* recalc-assgds */

/* $Workfile$   E n d */