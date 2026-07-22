&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-gds-form
/*

$Revision: b39224d84de3, 3188, rls $
$Author: EShklyar $
$Date: 2022/12/27 12:54:26 $
$Workfile: gds-form.w $
$Archive: ref/gds-form.w $

Карточка товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

*/

/* ***************************  Definitions  ************************** */
define input parameter parparentproc  as widget-handle no-undo.
define input parameter mode           as character no-undo .
define input parameter p-obj-type     like ub.clients.obj-type no-undo .
define input parameter p-obj-code     like ub.clients.obj-code no-undo .
define input parameter p-call-prog as handle no-undo .
define input-output parameter gds-rec as recid no-undo .


define variable vss-revision    as character no-undo init "$Revision: b39224d84de3, 3188, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:26 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gds-form.w $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gds-form.w $":U .
define variable vss-description as character no-undo init "Карточка товара".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/showinf.i }
{ cmp/library.i }
{ cmp/t-tnved.i  }
{ arc/gds_inf.i def }
{ str/tt-tax.i "NEW SHARED" tt-tax full }
{ str/tt-tax.i new output-tax full }
{ cmp/titlmode.i }
{ trg/factord.i }
{ gbl/cur-time.i }
{ ref/grplibfn.i }
{ cmp/library.i }
{ gbl/usr-flt.i }
{ ref/fbrglib.i }
{ ref/gdsoattr.i }
{ ref/gdspoatr.i }
{ ref/gdshattr.i }
{ ref/gds-attr.i }
{ gbl/perproc.i }
{ gbl/getcntxt.i def }
{ gbl/thbj-def.i }
{ gbl/clntattr.i }
{ ref/imagelist.i }
{ gbl/ggoattr.i }
{ gbl/attr-lib.i }
{ cmp/ini-lib.i }

define temp-table temp-goods no-undo like ub.goods
field alc-prod as logical
field alc-mark as logical
field alc-choose-prod as integer.
define variable v-next-prev as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .



DEFINE NEW SHARED BUFFER goods for ub.goods.
DEFINE TEMP-TABLE tt0-dis-gds-rule NO-UNDO LIKE ub.dis-gds-rule.
define buffer locked_dis-gds-rule for ub.dis-gds-rule.
DEFINE TEMP-TABLE tt0-gds-obj-attr NO-UNDO LIKE ub.gds-obj-attr.
define buffer locked_gds-obj-attr for ub.gds-obj-attr.
DEFINE TEMP-TABLE tt0-gds-host-attr NO-UNDO LIKE ub.gds-host-attr.
define buffer locked_gds-host-attr for ub.gds-host-attr.
define temp-table tt0-fbr-gds-obj no-undo like ub.fbr-gds-obj.
define buffer locked_fbr-gds-obj for ub.fbr-gds-obj.
define temp-table tt0-s-coeff no-undo like ub.s-coeff.
define buffer locked_s-coeff for ub.s-coeff.
define temp-table tt0-gds-obj-prop no-undo like ub.gds-obj-prop.
define temp-table ttf-gds-obj-prop no-undo like ub.gds-obj-prop.
define temp-table ttj-gds-obj-prop no-undo like ub.gds-obj-prop.
define temp-table tt0-gds-obj-prop-attr no-undo like ub.gds-obj-prop-attr. /*пока пуста*/
define temp-table ttf-gds-obj-prop-attr no-undo like ub.gds-obj-prop-attr. /*пока пуста*/
define temp-table ttj-gds-obj-prop-attr no-undo like ub.gds-obj-prop-attr.

define buffer locked_gds-obj-prop for ub.gds-obj-prop.
define buffer locked_gds-obj-prop-attr for ub.gds-obj-prop-attr.
define temp-table tt0-gds-add-charges no-undo like ub.gds-add-charges.
define buffer locked_gds-add-charges for ub.gds-add-charges.

{ ref/g-attr-tt.i}
define buffer locked_goods-attr for ub.goods-attr.
define buffer locked_goods for ub.goods.
define variable v-cli-alc-producer as character no-undo .
define variable v-attr-type as character no-undo .

define variable ref-list as char no-undo.
define variable g#log as logical no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-base-code like ub.currency.curr-code no-undo .
define variable v-host-name like ub.clients.obj-name no-undo .
define variable v-doc-prt as logical no-undo .
define variable v-flag-dgr-entry as logical no-undo .
define variable v-update-dgr as logical no-undo .
define variable v-found-copy-dgr as logical no-undo .
define variable v-flag-attr-obj-entry as logical no-undo .
define variable v-update-attr-obj as logical no-undo .
define variable v-found-copy-atr-obj as logical no-undo .
define variable v-flag-attr-host-entry as logical no-undo .
define variable v-update-attr-host as logical no-undo .
define variable v-found-copy-atr-host as logical no-undo .
define variable v-flag-fbr-gds-entry as logical no-undo .
define variable v-update-fbr-gds as logical no-undo .
define variable v-found-copy-fbr-gds as logical no-undo .
define variable v-fbr-gds-obj-recid as recid no-undo .
define variable v-fbr-gds-obj-template    as character        no-undo.
define variable v-flag-s-coeff-entry as logical no-undo .
define variable v-update-s-coeff as logical no-undo .
define variable v-found-copy-s-coeff as logical no-undo .
define variable v-update-gds-prop as logical no-undo .
define variable v-update-add-prop as logical no-undo .
define variable v-found-copy-gds-prop as logical no-undo .
define variable v-found-copy-add-prop as logical no-undo .
define variable v-flag-gds-prop-entry as logical no-undo .
define variable v-flag-add-prop-entry as logical no-undo .
define variable v-flag-attr-gbl-entry as logical no-undo .
define variable v-update-attr-gbl as logical no-undo .
define variable v-found-copy-atr-gbl as logical no-undo .
define variable v-gds-prop-recid  as recid no-undo .
define variable v-add-prop-recid  as recid no-undo .
define variable v-attr-obj-par            as integer no-undo .
define variable v-attr-host-par           as integer no-undo .
define variable v-fbr-gds-par             as integer no-undo .
define variable v-s-coeff-par             as integer no-undo .
define variable v-gds-prop-par             as integer no-undo .
define variable v-add-prop-par             as integer no-undo .
define variable v-attr-gbl-par            as integer no-undo .
DEFINE VARIABLE v-gds-attr-type AS CHARACTER NO-UNDO .      
DEFINE VARIABLE v-gds-attr-value-old AS character NO-UNDO init "no".
DEFINE VARIABLE v-gds-attr-mark-value-old AS character NO-UNDO init "no".

/* переменные для импорта */
define variable f-name as char no-undo.
define variable impc as integer no-undo.
define variable impc-saved as integer no-undo.
define variable not-saved as character no-undo.
define variable text-string as char no-undo.
define variable p-artic     AS integer NO-UNDO init 1.
define variable p-name      AS integer NO-UNDO init 2.
define variable p-engl-name AS integer NO-UNDO.
define variable p-SLT-code  AS integer NO-UNDO.
define variable p-VAT-code  AS integer NO-UNDO.
define variable p-unit-base AS integer NO-UNDO.
define variable p-struct AS integer NO-UNDO.
define variable p-prod AS integer NO-UNDO.
define variable p-tnved as integer no-undo .
define variable p-attrib as integer no-undo .
define variable p-destin as integer no-undo .
define variable p-sert as integer no-undo .
define variable p-user-rule as integer no-undo .
define variable p-alpha1 as integer no-undo .
define variable p-grp-code as integer no-undo .
define variable p-service as integer no-undo .
define variable p-gds-code like ub.goods.gds-code no-undo .
define variable p-mark as integer  no-undo .
define variable i-artic as char no-undo.
define variable i-prod-type as character no-undo .
define variable i-prod-code as integer no-undo .
define variable i-gds-name as char no-undo.
define variable i-engl-name as char no-undo.
define variable i-SLT-code as integer no-undo.
define variable i-unit-base as char no-undo.
define variable i-VAT-code as integer no-undo.
define variable i-struct as character no-undo.
define variable i-tnved like ub.goods.tnved no-undo .
define variable i-attrib like ub.goods.attrib no-undo .
define variable i-destin like ub.goods.destin no-undo .
define variable i-sert like ub.goods.sert no-undo .
define variable i-user-rule like ub.goods.user-rule no-undo .
define variable i-alpha1 like ub.goods.alpha1 no-undo .
define variable i-grp-code like ub.goods.grp-code no-undo .
define variable i-service as logical no-undo .
define variable i-gds-code like ub.goods.gds-code no-undo .
define variable i-mark as integer  no-undo .

/*режим копирования обязательно не no-undo!*/
define variable copymode as logical.
/*хранит значение поля artic обязательно no-undo!*/
define variable prev-artic like ub.goods.artic no-undo.
define variable AvtArt      like ub.bar-code.b-code no-undo.

define variable add-another    as logical no-undo.
define variable igoods         as logical no-undo.
define variable inp-avrg-base  as logical no-undo.
define variable inp-avrg-rubl  as logical no-undo.
define variable InpSelf        as logical no-undo.
define variable CostEntered    as logical no-undo.
define variable FirstIter      as logical init TRUE no-undo.
define variable custvalue      as character no-undo.
define variable custtype       as character no-undo.
define variable fbrvalue       as character no-undo.
define variable fbrtype        as character no-undo.
define variable addch-value    as character no-undo.
define variable addtype        as character no-undo.


define variable avrg-rate as decimal init 1 no-undo .
define NEW SHARED stream gds-file.

define variable prev-rec as recid init ? no-undo .
/*используется при копировании товара*/
define buffer for-goods for ub.goods.
/*используем для отслеживания - ввел ли пользователь ДОПБК при вкл настройке dif-nam2*/
define buffer for-prodbc for ub.prod-bc.
define buffer bf-tt-tax for tt-tax.
/*как отслеживать изменение имени товара для исключения дублей*/
define variable dif-nam1 as logical no-undo init yes.
define variable dif-nam2 as logical no-undo init no.
define variable dif-pdbc as logical no-undo init no.
define variable v-gds-copy as character no-undo init '0,0,0,0,0,0,0':U.
define variable tnvedimp as logical no-undo init no.
/*настройка - уникальный цифровой артикул + ДОПБК = артикулу*/
define variable unq-artc as logical no-undo init no.
define variable is-prt  as logical no-undo .
define variable is-jwlr as logical no-undo.
define variable is-bttl as logical no-undo.
define variable is-ptrl as logical no-undo.
/*последнее сохраненное имя обязательно не no-undo*/
define variable saved-name like goods.gds-name .
define variable saved-name2 like goods.gds-name .
/*настройка код НДС и НП в системе*/
define new shared var vattaxcd as integer no-undo.
define new shared var slttaxcd as integer no-undo.
/*вспомогат*/
define variable conf-par as character no-undo format "X(250)".
define variable par-type as character no-undo format "X(1)".
define variable choice as integer no-undo.
define variable ArtDis as logical no-undo init no.
define variable BarDis as logical no-undo init no.
define variable nbc as integer no-undo.
define variable var-artic-disable like ub.sysconf.artic-disable no-undo.
define variable var-negative-rest like ub.sysconf.negative-rest no-undo.
define variable vArtbar-off as char no-undo init "Отключено".
define variable vArtbar-auto as char no-undo init "Автом. артик".
define variable vArtbar-BarCOde as char no-undo init "Артик=>Бар-код".
/*сохранение и выходв  справочник товаров*/
define variable one-good as logical no-undo init yes.
/*внутренний номер группы классифакатора по умолчанию*/
define variable dfltggrp AS INTEGER NO-UNDO init -1.
/*количество уровней шкалы*/
define variable levels as integer no-undo.
/*список доп полей для показа в форме*/
define variable gdsfrmfi as char no-undo.
define variable v-dop-inf as char no-undo.
define variable wh as widget-handle extent 4 no-undo.
define variable whb-tnved as widget-handle no-undo.
define variable whb-unit-cst as widget-handle no-undo.
define variable whb-cond-keep-code as widget-handle no-undo.
define variable whl as widget-handle extent 4 no-undo.
define variable wh-tnved-name as widget-handle no-undo.
define variable wh-cond-keep-name as widget-handle no-undo.
define variable whl-tnved-name as widget-handle no-undo.
define variable whl-cond-keep-name as widget-handle no-undo.
define variable wph as logical no-undo .
define variable jj-tnved as integer no-undo.
define variable jj-unit-cst as integer no-undo.
define variable jj-cst-base-rate as integer no-undo.
define variable jj-cond-keep as integer no-undo.
define variable main-code like ub.bar-code.b-code no-undo.
define variable altcd-option as char no-undo.
define variable dopinf-option as char no-undo.
define variable prodbc-option as char no-undo.
define variable p-list as character no-undo .
define variable fbr-grp-code_ like ub.goods.fbr-grp-code no-undo.
DEFINE VARIABLE v-is-alc AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-choose-alc-prod AS CHARACTER NO-UNDO. 
DEFINE variable v-alc-type-inner-code as integer no-undo .
define variable v-create-user-db-num  as integer no-undo .
/*флаг изменения в атрибутах товара или еще где-то внутри*/
define variable updated as logical no-undo.
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
define variable v-deleted as logical no-undo .
define variable v-err-mess as character no-undo .
/*Если это таможенный объект следует считать с диска справочник кодов ТНВЭД*/
{ gbl/conf-rd.i
 "'is-custm'"
 "''"
 "''"
 0
 "''"
 "''"
 "''"
 no
 custvalue
 custtype
 no-error
 }
{ gbl/conf-rd.i
 "'is-fbr'"
 "''"
 "''"
 0
 "''"
 "''"
 "''"
 no
 fbrvalue
 fbrtype
 no-error
 }
{ gbl/conf-rd.i
 "'is-addch'"
 "''"
 "''"
 0
 "''"
 "''"
 "''"
 no
 addch-value
 addtype
 no-error
 }

/* ***********************  Control Definitions  ********************** */

DEFINE BUTTON add-inf
     LABEL "Доп.инф.":L
     SIZE 10 BY 1
     BGCOLOR 8 FGCOLOR 0 .

DEFINE BUTTON b-altbc
     LABEL "&Коды"
     SIZE 10 BY 1.

DEFINE BUTTON b-altcd
     LABEL "&Неосн."
     SIZE 10 BY 1.

DEFINE BUTTON b-arch
     LABEL "Ар&хив":L
     SIZE 10 BY 1.

DEFINE BUTTON b-card
     LABEL "Уч&.карт.":L
     SIZE 10 BY 1.

DEFINE BUTTON b-chk
     LABEL "&Чеки  ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход "
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.

DEFINE BUTTON b-hist
     LABEL "Ис&тория":L
     SIZE 3 BY 1.

DEFINE BUTTON b-file
     LABEL "&Файл":L
     SIZE 10 BY 1.

DEFINE BUTTON b-inf
     LABEL "&Учет":L
     SIZE 10 BY 1.

DEFINE BUTTON b-next AUTO-GO
     LABEL ">&>":L
     SIZE 3 BY 1.

DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<":L
     SIZE 3 BY 1.

DEFINE BUTTON b-parts
     LABEL "&Партии":L
     SIZE 10 BY 1.

DEFINE BUTTON b-place
     LABEL "Скл.&места":L
     SIZE 10 BY 1.

DEFINE BUTTON b-prodbc
     LABEL "&Дополн.":L
     SIZE 10 BY 1.

DEFINE BUTTON b-price
     LABEL "&Цены":L
     SIZE 10 BY 1.

DEFINE BUTTON b-prt
     LABEL "&Шкала":L
     SIZE 10 BY 1.

DEFINE BUTTON b-recipe
     LABEL "Ре&цепт"
     SIZE 10 BY 1.

DEFINE BUTTON b-rest
     LABEL "&Остатки":L
     SIZE 10 BY 1.

DEFINE BUTTON b-sert
     LABEL "Серти&ф":L
     SIZE 10 BY 1
     BGCOLOR 8 FGCOLOR 0 .

DEFINE BUTTON b-tax
     LABEL "&<<":L
     SIZE 3 BY 4
     BGCOLOR 8 FGCOLOR 0 .

DEFINE BUTTON b-extart
     LABEL "Внеш.Арт":L
     SIZE 10 BY 1.

DEFINE BUTTON r-base
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-base"
     size 3 by 0.88.

DEFINE BUTTON r-alpha1
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-alpha1"
     size 3 by 0.88.

DEFINE BUTTON r-prod
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-prod"
     size 3 by 0.88.

DEFINE BUTTON r-supp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-supp"
     size 3 by 0.88.

DEFINE BUTTON r-fbr-grp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-fbr-grp"
     size 3 by 0.88.

DEFINE VARIABLE grp-full AS CHARACTER FORMAT "x(83)"
     LABEL "Группа"
     VIEW-AS FILL-IN
     size 85 by 1
     FGCOLOR 4 .

DEFINE VARIABLE country_name AS CHARACTER FORMAT "x(17)"
     LABEL ""
     VIEW-AS FILL-IN
     size 16.25 by 1
     FGCOLOR 4 .

DEFINE VARIABLE f-fbr-grp-name like ub.fbr-gds-grp.node-name FORMAT "X(30)"
     LABEL ""
     VIEW-AS FILL-IN
     size 28.75 by 1
     FGCOLOR 4 .


DEFINE VARIABLE Impmes AS CHARACTER FORMAT "X(12)":U INITIAL " ИМПОРТ"
      VIEW-AS TEXT
     size 15 by 0.67
     BGCOLOR 10 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE Infmes AS CHARACTER FORMAT "X(60)":U INITIAL " ТОВАР НЕ СОХРАНЕН В БАЗЕ ДАННЫХ"
      VIEW-AS TEXT
     size 45 by 0.67
     BGCOLOR 10 FGCOLOR 0  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     size 25.5 by 4.08.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     size 19.13 by 4.08.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     size 26.88 by 4.08.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     size 26 by 4.08.

DEFINE VARIABLE ArtBar AS CHARACTER  FORMAT "X(15)"
     VIEW-AS COMBO-BOX
     LIST-ITEMS ""
     size 18.25 by 1
     BGCOLOR 8 FGCOLOR 0
     NO-UNDO.

DEFINE VARIABLE NegRest AS LOGICAL INITIAL no
     LABEL "Отриц. остатки"
     VIEW-AS TOGGLE-BOX
     size 16.5 by 1
     BGCOLOR 8 FGCOLOR 0 .

DEFINE QUERY BR-tt-tax FOR
      tt-tax SCROLLING.

DEFINE BROWSE BR-tt-tax
  QUERY BR-tt-tax DISPLAY
      tt-tax.tax-name
      tt-tax.tax-type
      tt-tax.tax-code
      tt-tax.rate-code COLUMN-LABEL "Ставка"
      tt-tax.rate-value format "->>>,>>9.99"
      tt-tax.fact-date column-LABEL "Включена" format "99/99/9999"
      ENABLE
      tt-tax.rate-code
     WITH NO-ROW-MARKERS separators SIZE 51 BY 4.

DEFINE BUTTON b-copy-name-to-lbl
     LABEL "Назв.->этикетка":L
     size 18 by 1
     BGCOLOR 8 FGCOLOR 0 .

DEFINE VARIABLE for-obj-last-base like ub.gds-obj.last-base
     VIEW-AS FILL-IN
     size 16 by 1
     BGCOLOR 15 FGCOLOR 4.

DEFINE VARIABLE for-obj-last-rubl like ub.gds-obj.last-rubl
     VIEW-AS FILL-IN
     size 16 by 1
     BGCOLOR 15 FGCOLOR 4.

DEFINE VARIABLE for-obj-price-base like ub.gds-obj.price-base
     VIEW-AS FILL-IN
     size 17 by 1
     BGCOLOR 15 FGCOLOR 4
     FORMAT ">>>,>>>,>>9.9999"
     .

DEFINE VARIABLE for-obj-price-rubl like ub.gds-obj.price-rubl
     VIEW-AS FILL-IN
     size 17 by 1
     BGCOLOR 15 FGCOLOR 4
     FORMAT ">>>,>>>,>>9.9999"
     .

DEFINE VARIABLE name-uchet-base as char init "Б.вал.  :"
     VIEW-AS TEXT
     size 10 by 1
     BGCOLOR 8 FGCOLOR 4.

DEFINE VARIABLE name-uchet-rubl as char init "{&abbr_rub_firstshift}.    :"
     VIEW-AS TEXT
     size 10 by 1
     BGCOLOR 8 FGCOLOR 4.

DEFINE VARIABLE label-increase-pc as char init "Наценка:"
     VIEW-AS TEXT
     size 7.5 by 1
     BGCOLOR 8 FGCOLOR 0.

DEFINE VARIABLE label-min-rate as char FORMAT "X(17)" init
     "Min кол. в штуке" VIEW-AS TEXT
     size 16.25 by 0.88
     BGCOLOR 8 FGCOLOR 0.

DEFINE VARIABLE label-max-rate as char FORMAT "X(17)" init
     "Max кол. в штуке" VIEW-AS TEXT
     size 16.25 by 0.88
     BGCOLOR 8 FGCOLOR 0.

DEFINE BUTTON b-gdsfrmfi
     image file "cmp/b-must.bmp":u
     SIZE 3 BY 2.

DEFINE RECTANGLE RECT-label-name-1
     EDGE-PIXELS 0
     SIZE 0.2 BY 3.0
     BGCOLOR 12 .

DEFINE RECTANGLE RECT-label-name-2
     EDGE-PIXELS 0
     SIZE 0.2 BY 3.0
     BGCOLOR 12 .

def MENU m-altcd
    MENU-ITEM m-altcd-code-current    LABEL "Главный код - существующие неосновные цены"
    MENU-ITEM m-altcd-code-all        LABEL "Главный код - все неосновные коды"
    rule
    MENU-ITEM m-altcd-scl-gds-current LABEL "Товар - признаки - существующие неосновные цены"
    MENU-ITEM m-altcd-scl-gds-all     LABEL "Товар - признаки - все неосновные коды"
    rule
    MENU-ITEM m-altcd-par-gds-current LABEL "Товар - партии - существующие неосновные цены"
    MENU-ITEM m-altcd-par-gds-all     LABEL "Товар - партии - все неосновные коды"
.

def MENU m-dopinf
    MENU-ITEM m-dopinf-1 LABEL "Доп.инфо по карточке товара"  ACCELERATOR "ALT-2"
    MENU-ITEM m-dopinf-2 LABEL "Фото"  ACCELERATOR "ALT-2"
    MENU-ITEM m-dopinf-10 LABEL "Глобальные атрибуты товара"  ACCELERATOR "ALT-3"
    MENU-ITEM m-dopinf-3 LABEL "Атрибуты товара на фирме"  ACCELERATOR "ALT-4"
    MENU-ITEM m-dopinf-4 LABEL "Атрибуты товара на объекте"  ACCELERATOR "ALT-5"
    MENU-ITEM m-dopinf-5 LABEL "Атрибуты товара на объектах фирмы"  ACCELERATOR "ALT-6"
    MENU-ITEM m-dopinf-6 LABEL "Атрибуты товара (РЕСТОРАН) на объекте"  ACCELERATOR "ALT-7"
    MENU-ITEM m-dopinf-7 LABEL "Сезонные коэффициенты для товара в производстве"  ACCELERATOR "ALT-8"
    MENU-ITEM m-dopinf-11 LABEL "Скидки на товар, действующие на объекте"  ACCELERATOR "ALT-9"
    MENU-ITEM m-dopinf-12 LABEL "Скидки на товар, действующие на объектах фирмы"  ACCELERATOR "ALT-f1"
    MENU-ITEM m-dopinf-9 LABEL "Атрибуты товара на объекте для ЗАКАЗОВ"  ACCELERATOR "ALT-f3"
    MENU-ITEM m-dopinff-9 LABEL "Атрибуты товара на фирме   для ЗАКАЗОВ"
    MENU-ITEM m-dopinf-8 LABEL "Индикаторы товара на объекте"  ACCELERATOR "ALT-f2"
    MENU-ITEM m-dopinf-AM LABEL "Ассортиментные матрицы"
    MENU-ITEM m-dopinf-AC LABEL "Дополнительные расходы"
    MENU-ITEM m-dopinf-AU LABEL "Дополнительные единицы измерения"
.

def MENU m-prodbc
    MENU-ITEM m-prodbc-1 LABEL "По главному коду"  ACCELERATOR "ALT-2"
    MENU-ITEM m-prodbc-2 LABEL "По признакам"  ACCELERATOR "ALT-2"
    MENU-ITEM m-prodbc-3 LABEL "По партиям"  ACCELERATOR "ALT-3"
    rule
    MENU-ITEM m-prodbc-4 LABEL "Все по товару"  ACCELERATOR "ALT-4"
.

def MENU m-price
    MENU-ITEM m-price-1 LABEL "Цены"
    MENU-ITEM m-price-2 LABEL "Переоценки"
.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-gds-form
     b-exit AT ROW 1 COL 1
     b-arch AT ROW 1 COL 11
     b-price AT ROW 1 COL 21
     b-recipe AT ROW 1 COL 31
     b-card AT ROW 1 COL 41
     b-chk AT  ROW 1 COL 51
     b-prt AT ROW 1 COL 61
     b-parts AT ROW 1 COL 71
     b-place AT ROW 1 COL 81
     b-extart AT ROW 1 COL 91
     b-prev at row 2 col 1
     b-next at row 2 col 4
     b-altbc AT ROW 2 COL 11
     b-altcd AT ROW 2 COL 21
     b-prodbc AT ROW 2 COL 31
     b-rest AT ROW 2 COL 41
     b-inf AT ROW 2 COL 51
     b-file AT ROW 2 COL 61
     b-sert AT ROW 2 COL 71
     add-inf AT ROW 2 COL 81
     b-hist AT ROW 2 COL 92
     b-help AT ROW 2 COL 95
     grp-full at row 3.33 col 13 COLON-ALIGNED
     goods.artic at row 4.42 col 13 COLON-ALIGNED FORMAT "X(16)"
          VIEW-AS FILL-IN
          size 19.5 by 1
          BGCOLOR 3 FGCOLOR 15
     ArtBar at row 4.42 col 35.25 NO-LABEL
     ub.bar-code.b-code at row 4.42 col 43 COLON-ALIGNED FORMAT "9999999999"
          VIEW-AS FILL-IN
          size 10.5 by 1
          BGCOLOR 3 FGCOLOR 15
     ub.gds-prt.node-name at row 4.42 col 54 COLON-ALIGNED NO-LABEL FORMAT "X(25)"
          VIEW-AS FILL-IN
          size 43.38 by 1
          BGCOLOR 3 FGCOLOR 15
     ub.clients.obj-type at row 5.5 col 13 COLON-ALIGNED
          LABEL "Произв-ль"
          VIEW-AS FILL-IN
          size 4 by 1
          BGCOLOR 3 FGCOLOR 15
     ub.clients.obj-code at row 5.5 col 17.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          size 11 by 1
          BGCOLOR 3 FGCOLOR 15
     ub.clients.obj-name at row 5.5 col 34.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          size 62.88 by 1
          BGCOLOR 3 FGCOLOR 15
     r-prod at row 5.54 col 31.25
     ub.goods.gds-name at row 6.58 col 13 COLON-ALIGNED
          LABEL "Название" FORMAT "X(112)"
          VIEW-AS FILL-IN
          size 66.38 by 1
          BGCOLOR 3 FGCOLOR 15
     b-copy-name-to-lbl at row 6.58 col 81.38
     ub.goods.engl-name at row 7.63 col 13.13 COLON-ALIGNED
          LABEL "Англ. назв."
          VIEW-AS FILL-IN
          size 51.88 by 0.96
          FGCOLOR 4
     goods.alpha1 at row 7.63 col 73.5 COLON-ALIGNED
          LABEL "Страна"
          VIEW-AS FILL-IN
          size 4.38 by 1
     r-alpha1 at row 7.63 col 79.88
     country_name NO-LABEL at row 7.63 col 82.25
     rect-label-name-1 at row 7.63 col 40.38
     rect-label-name-2 at row 7.63 col 65.38
     goods.label-name at row 8.79 col 13.13 COLON-ALIGNED
          LABEL "Этикетка" FORMAT "X(112)"
          VIEW-AS FILL-IN
          size 84.38 by 0.96
          FGCOLOR 4
     goods.chk-name at row 9.92 col 13.13 COLON-ALIGNED
           LABEL "На  чеке" FORMAT "X(122)"
          VIEW-AS FILL-IN
          size 50.5 by 0.96
          FGCOLOR 4
     goods.okdp at row 9.88 col 70 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          FGCOLOR 4
     NegRest at row 9.88 col 82.75
     goods.unit-base at row 11.04 col 14.5 COLON-ALIGNED
          LABEL "Учет.ед.изм."
          VIEW-AS FILL-IN
          size 6.5 by 1
     r-base at row 11.04 col 23.25
     goods.unit-cli at row 11.92 col 14.5 COLON-ALIGNED
          LABEL "Ед.  пост-ка"
          VIEW-AS FILL-IN
          size 6.5 by 1
     r-supp at row 11.92 col 23.25
     goods.cli-base-rate
          at row 12.94 col 7.75 COLON-ALIGNED
          LABEL "Коэф."
          FORMAT " >>,>>9.9999999999"
          VIEW-AS FILL-IN
          size 16.25 by 1
     goods.min-rate
          at row 12.04 col 26  COLON-ALIGNED
          NO-LABEL
          FORMAT ">>,>>9.9999999999"
          VIEW-AS FILL-IN
          size 16.25 by 1
     goods.max-rate
          at row 13.92 col 26  COLON-ALIGNED
          NO-LABEL
          FORMAT ">>,>>9.9999999999"
          VIEW-AS FILL-IN
          size 16.25 by 1
     goods.qnty-cart at row 13.96 col 14 COLON-ALIGNED
          VIEW-AS FILL-IN
          size 10 by 1
     goods.wt-base at row 11.04 col 59.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          size 10 by 1
     goods.ms-base at row 11.92 col 59.5 COLON-ALIGNED
          LABEL "Объем штуки"
          VIEW-AS FILL-IN
          size 10 by 1
     goods.ms-cart at row 13.96 col 59.5 COLON-ALIGNED
          LABEL "Объем упак-ки"
          VIEW-AS FILL-IN
          size 10 by 1
     goods.wt-cart at row 12.94 col 59.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          size 10 by 1
     goods.calc-method at row 11.42 col 74.75 NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
          LIST-ITEMS
          {&pr-calc-methods}
          size 15 by 3.28
     label-increase-pc NO-LABEL
          at row 11.42 col 89.75
     goods.increase-pc format "->>9.99" at row 13.5 col 87.88 COLON-ALIGNED
          NO-LABEL
          VIEW-AS FILL-IN
          size 8.63 by 1
     name-uchet-base  at row 11.42 col 26 COLON-ALIGNED
          BGCOLOR 8 FGCOLOR 4
          NO-LABEL
     for-obj-price-base at row 11.42 col 47.5 COLON-ALIGNED
          LABEL "Учет.цена"
     for-obj-last-base at row 11.42 col 80 COLON-ALIGNED
          LABEL "Посл.прих.цена"
     name-uchet-rubl at row 12.54 col 26 COLON-ALIGNED
          BGCOLOR 8 FGCOLOR 4
          NO-LABEL
     for-obj-price-rubl at row 12.54 col 47.5 COLON-ALIGNED HELP
          ""
          LABEL "Учет.цена"
     for-obj-last-rubl at row 12.54 col 80 COLON-ALIGNED HELP
          ""
          LABEL "Посл.прих.цена"
     b-tax at row 15.17 col 1.13
     BR-tt-tax at row 15.17 col 4.25
.
/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME d-gds-form
     goods.PS at row 16.83 col 56 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
          size 43.38 by 2.33
          BGCOLOR 15 FGCOLOR 0
     Impmes AT ROW 2 COL 12 COLON-ALIGNED NO-LABEL
     Infmes at row 19.33 col 10 COLON-ALIGNED NO-LABEL
     RECT-1 at row 10.96 col 1.38
     RECT-2 at row 10.96 col 27.13
     RECT-3 at row 10.96 col 46.25
     RECT-4 at row 10.96 col 73.5
     label-min-rate at row 11.13 col 27.88
     NO-LABEL
     label-max-rate at row 13 col 27.88
     NO-LABEL
     "Прим." VIEW-AS TEXT
          size 5 by 0.75 at row 16 col 56
          BGCOLOR 8 FGCOLOR 0
     "Группа блюд" VIEW-AS TEXT
          size 11.25 by 0.75 at row 15 col 56
          BGCOLOR 8 FGCOLOR 0
    r-fbr-grp at row 15 col 67.25
    f-fbr-grp-name at row 15 col 70.25 NO-LABEL
    b-gdsfrmfi at row 20.5 col 1.13
    SKIP(0.25)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "".

{ ref/gdsfrmto.i }
{ ref/gdsfrmfi.i }


ASSIGN
       FRAME d-gds-form:SCROLLABLE       = FALSE.


ASSIGN b-altcd:POPUP-MENU IN FRAME {&frame-name} = MENU m-altcd:HANDLE.
ASSIGN b-altcd:MENU-MOUSE = 1.

ASSIGN add-inf:POPUP-MENU IN FRAME {&frame-name} = MENU m-dopinf:HANDLE.
ASSIGN add-inf:MENU-MOUSE = 1.

ASSIGN b-prodbc:POPUP-MENU IN FRAME {&frame-name} = MENU m-prodbc:HANDLE.
ASSIGN b-prodbc:MENU-MOUSE = 1.

ASSIGN b-price:POPUP-MENU IN FRAME {&frame-name} = MENU m-price:HANDLE.
ASSIGN b-price:MENU-MOUSE = 1.



/* ************************  Control Triggers  ************************ */

ON CHOOSE OF add-inf IN FRAME d-gds-form /* Доп.инф. */
DO:
  if dopinf-option = "" then do:
    run gbl/pop-up.p ( input self:handle
                      ,input no) no-error.
    if error-status:error then return no-apply.
  end.
 if dopinf-option = "" then return no-apply.
 run proc-b-add-inf(input-output dopinf-option) no-error.
 if error-status:error then return no-apply.
END.

ON VALUE-CHANGED OF ArtBar IN FRAME d-gds-form /* Автоматический */
do:
    assign ArtBar .
    if ArtBAr = vArtBar-Auto then do:
        if nbc = 0 then do:
        /*
            run gen-b-code IN THIS-PROCEDURE (input {&gbl-bc-code}, output nbc) no-error.
            if error-status:error then return no-apply.
    */
        end.
    end.
    run val-chg-ArtBar.
end.


ON VALUE-CHANGED OF goods.calc-method IN FRAME d-gds-form /* Автоматический */
do:
  if goods.calc-method:sensitive and goods.calc-method:visible in frame {&frame-name} then do:
    CASE input frame {&frame-name} goods.calc-method:screen-value:
      when {&pr-calc-grp} then do:
        hide
        label-increase-pc
        goods.increase-pc in frame {&frame-name}.
      end.
      otherwise do:
        display
        label-increase-pc
        with frame {&frame-name}.
        goods.increase-pc:visible in frame {&frame-name} = yes.
      end.
    END CASE.
  end.

end.

ON LEAVE OF goods.artic IN FRAME d-gds-form /* Артикул */
DO:
    HIDE Infmes in frame {&frame-name}.
END.

ON return OF goods.artic IN FRAME d-gds-form /* Артикул */
do:
    if input frame {&frame-name} goods.artic = "" then
        do:
            message "Артикул не может быть пустым !".
            apply "entry" to goods.artic in frame {&frame-name}.
            return no-apply.
        end.
    apply "entry" to ub.clients.obj-code in frame {&frame-name}.
    return no-apply.
end.

ON LEAVE OF for-obj-price-base IN FRAME d-gds-form /* Средн.уч.цена */
do:
    if ( input frame {&frame-name} for-obj-price-base <= 0 ) OR
       ( input frame {&frame-name} for-obj-price-base = ? ) then .
    else do:
      if v-base-code <> 0 then do:
        if NOT InpSelf then do:
          if avrg-rate = 1 then do:
            FIND LAST ub.curr-accnt WHERE
                              ub.curr-accnt.curr-code = v-base-code NO-ERROR.
            avrg-rate = ub.curr-accnt.exch-rate * ub.curr-accnt.exch-scale .
            run ref/avrgrate.w ( input "rubl"
                               , input-output avrg-rate ) .
          end.
          if avrg-rate = 1
            then
          InpSelf = TRUE .
          else do:
            if NOT CostEntered then do:
              DISPLAY
              ( input frame {&frame-name} for-obj-price-base ) * avrg-rate
                @ for-obj-price-rubl with frame {&frame-name}.
              CostEntered = TRUE .
            end.
            else do:
              g#log = no.
              if  ( input frame {&frame-name} for-obj-price-base ) * avrg-rate <>
                  input frame {&frame-name} for-obj-price-rubl then do:
                  message "Пересчитать ср.учетную цену в {&abbr_rub}.?" view-as alert-box
                  QUESTION buttons YES-NO update g#log.
                  if g#log then
                  DISPLAY
                      ( input frame {&frame-name} for-obj-price-base ) * avrg-rate
                              @ for-obj-price-rubl with frame {&frame-name}.
              end.
            end.
          end.
        end.
      end.
      else
      DISPLAY
      ( input frame {&frame-name} for-obj-price-base )
        @ for-obj-price-rubl with frame {&frame-name}.
      apply "entry" to for-obj-price-rubl in frame {&frame-name}.
    end.
end.

ON LEAVE OF for-obj-price-rubl IN FRAME d-gds-form /* Средн.уч.цена */
do:
    if ( input frame {&frame-name} for-obj-price-rubl <= 0 ) OR
       ( input frame {&frame-name} for-obj-price-rubl = ? ) then .
    else do:
    if v-base-code <> 0 then do:
      if NOT InpSelf then do:
        if avrg-rate = 1 then do:
          FIND LAST ub.curr-accnt WHERE
                            ub.curr-accnt.curr-code = v-base-code NO-ERROR.
          avrg-rate = ub.curr-accnt.exch-rate * ub.curr-accnt.exch-scale .
          run ref/avrgrate.w ( input "base"
                             , input-output avrg-rate ) .
        end.
        if avrg-rate = 1
        then
        InpSelf = TRUE .
        else do:
          if NOT CostEntered then do:
            DISPLAY
            ( input frame {&frame-name} for-obj-price-rubl ) / avrg-rate
             @ for-obj-price-base with frame {&frame-name}.
             CostEntered = TRUE .
          end.
          else do:
            g#log = no.
            if ( input frame {&frame-name} for-obj-price-rubl ) / avrg-rate <>
                 input frame {&frame-name} for-obj-price-base then do:
              message "Пересчитать ср.учетную цену в вал.?" view-as alert-box
              QUESTION buttons YES-NO update g#log.
              if g#log
                then
              DISPLAY
              ( input frame {&frame-name} for-obj-price-rubl ) / avrg-rate
                @ for-obj-price-base with frame {&frame-name}.
            end.
          end.
        end.
      end.
    end.
    else
    DISPLAY
    ( input frame {&frame-name} for-obj-price-rubl )
      @ for-obj-price-base with frame {&frame-name}.
    apply "entry" to for-obj-price-base in frame {&frame-name}.
  end.
end.

on choose of MENU-ITEM m-dopinf-1 in menu m-dopinf DO:
  dopinf-option = "dop-inf":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-dopinf-2 in menu m-dopinf DO:
  dopinf-option = "foto":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-dopinf-10 in menu m-dopinf DO:
  dopinf-option = "dop-inf-gbl":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-dopinf-3 in menu m-dopinf DO:
  dopinf-option = "dop-inf-host":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-dopinf-4 in menu m-dopinf DO:
  dopinf-option = "dop-inf-obj-one":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-dopinf-5 in menu m-dopinf DO:
  dopinf-option = "dop-inf-obj-cmp":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-dopinf-6 in menu m-dopinf DO:
  dopinf-option = "dop-inf-fbr-gds-obj":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-dopinf-7 in menu m-dopinf DO:
  dopinf-option = "dop-inf-s-coeff":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-dopinf-8 in menu m-dopinf DO:
  dopinf-option = "indicators":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-AM in menu m-dopinf DO:
  dopinf-option = "AM":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-AC in menu m-dopinf DO:
  dopinf-option = "add-charg":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-AU in menu m-dopinf DO:
  dopinf-option = "alt-units":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.


on choose of MENU-ITEM m-dopinf-9 in menu m-dopinf DO:
  dopinf-option = "orders":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinff-9 in menu m-dopinf DO:
  dopinf-option = "ordersf":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-dopinf-11 in menu m-dopinf DO:
  dopinf-option = "dop-inf-dgr-one":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-dopinf-12 in menu m-dopinf DO:
  dopinf-option = "dop-inf-dgr-cmp":U.
  run proc-b-add-inf(input-output dopinf-option) no-error.
  if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-altcd-code-current in menu m-altcd DO:
  altcd-option = "code-current":U.
  run proc-b-altcd(input-output altcd-option) no-error.
  if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-altcd-code-all in menu m-altcd DO:
 altcd-option = "code-all":U.
 run proc-b-altcd(input-output altcd-option) no-error.
 if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-altcd-scl-gds-current in menu m-altcd DO:
 altcd-option = "scl-gds-current":U.
 run proc-b-altcd(input-output altcd-option) no-error.
 if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-altcd-scl-gds-all in menu m-altcd DO:
 altcd-option = "scl-gds-all":U.
 run proc-b-altcd(input-output altcd-option) no-error.
 if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-altcd-par-gds-current in menu m-altcd DO:
  altcd-option = "par-gds-current":U.
 run proc-b-altcd(input-output altcd-option) no-error.
 if error-status:error then return no-apply.

end.
on choose of MENU-ITEM m-altcd-par-gds-all in menu m-altcd DO:
 altcd-option = "par-gds-all":U.
 run proc-b-altcd(input-output altcd-option) no-error.
 if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-price-1 in menu m-price DO:
  run proc-b-price(input 1) no-error.
  if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-price-2 in menu m-price DO:
  run proc-b-price(input 2) no-error.
  if error-status:error then return no-apply.
end.


on choose of MENU-ITEM m-prodbc-1 in menu m-prodbc DO:
  prodbc-option = "code-all":U.
  run proc-b-prodbc(input-output prodbc-option) no-error.
  if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-prodbc-2 in menu m-prodbc DO:
  prodbc-option = "scl-gds-all":U.
  run proc-b-prodbc(input-output prodbc-option) no-error.
  if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-prodbc-3 in menu m-prodbc DO:
  prodbc-option = "par-gds-all":U.
  run proc-b-prodbc(input-output prodbc-option) no-error.
  if error-status:error then return no-apply.
end.

on choose of MENU-ITEM m-prodbc-4 in menu m-prodbc DO:
  prodbc-option = "gds-all":U.
  run proc-b-prodbc(input-output prodbc-option) no-error.
  if error-status:error then return no-apply.
end.

ON CHOOSE OF b-altcd IN FRAME d-gds-form /* неосновные кОды */
DO:
  if altcd-option = "" then do:
    run gbl/pop-up.p ( input self:handle
                      ,input no) no-error.
    if error-status:error then return no-apply.
  end.
 if altcd-option = "" then return no-apply.
 run proc-b-altcd(input-output altcd-option) no-error.
 if error-status:error then return no-apply.
END.

ON CHOOSE OF b-prodbc IN FRAME d-gds-form /* ДОПОЛН */
DO:
  if prodbc-option = "" then do:
    run gbl/pop-up.p ( input self:handle
                      ,input no) no-error.
    if error-status:error then return no-apply.
  end.
 if prodbc-option = "" then return no-apply.
 run proc-b-prodbc(input-output prodbc-option) no-error.
 if error-status:error then return no-apply.
END.

ON CHOOSE OF b-altbc IN FRAME d-gds-form /* КОды */
DO:
  if mode <> {&add-def} then do:
    gds-rec = recid (goods).
    run ref/alt-bc.w ( input parparentproc
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input main-code ).
  end.
  else do:
    assign
    saved-name2 = saved-name
    one-good = no
    .
    RUN check-update-attr IN THIS-PROCEDURE(no) NO-ERROR.
    RUN check-add in this-procedure ( input 1) no-error.
    if error-status:error and NOT return-value = "next" then return no-apply.
    add-another = yes.
    VIEW Infmes in frame {&frame-name}.
    DISPLAY Infmes with frame {&frame-name}.
    run perproc-delete-from-parent( this-procedure , "").
    apply "go" to frame {&frame-name}.
  end.    /*mode = add-def*/
END.

ON choose OF b-arch IN FRAME d-gds-form /* Архив */
DO:
  if mode = {&add-def} then  do:    /* Сохр */
    one-good = no.
        if temp-goods.alc-prod = yes then 
do:
  if (input frame {&frame-name} ub.goods.ms-base = 0) then 
  do:
    message "Введите объем штуки в карточке товара" VIEW-AS ALERT-BOX .
    RETURN NO-APPLY. 
  end.
  run clntattr-value in this-procedure ( input clients.obj-type
                                       , input clients.obj-code
                                       , input {&attr-cli-alc-producer}
                                       , output v-cli-alc-producer
                                       , output v-attr-type
                                       ) .
  if v-cli-alc-producer = "no" then
  do:
    message "Производитель товара не является производителем алкогольной продукции, установите соответствующий атрибут в справочнике клиентов." VIEW-AS ALERT-BOX .
    return no-apply .
  end.
end. 
    RUN check-update-attr IN THIS-PROCEDURE(no) NO-ERROR.
    RUN check-add in this-procedure ( input 0) no-error.
    if error-status:error and NOT return-value = "next" then return no-apply.
    add-another = yes.
    run ref/add-matr.p ( input parParentProc
                        ,input goods.gds-code) no-error .
      if error-status :error then message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "Ошибка добавления в Ассортиментную матрицу - add-matr.p"
          view-as alert-box error
        .
    VIEW Infmes in frame {&frame-name}.
    DISPLAY Infmes with frame {&frame-name}.
    run perproc-delete-from-parent( this-procedure , "").
    apply "go" to frame {&frame-name}.
  end.
  else do:
    run local-gds_inf.
  end.
end.

ON choose OF b-card IN FRAME d-gds-form /* Уч.карт. */
DO:
    if f-name = "" then do:
        run rep/g-gdscrd.p (parParentProc ,
                      goods.artic,
                      goods.prod-type,
                      goods.prod-code,
                      ?,
                      ?,
                      p-obj-type,
                      p-obj-code
                      ) no-error.

        apply "entry" to b-card in frame {&frame-name}.
    end.
    else do:
        run next-good no-error.
        if error-status:error then return no-apply.
        /* если авт. артикул включен, импортируемый артикул будет забит автоматическим */
       if ArtDis then do:
           message "Для импорта требуется, чтобы автоматичекий артикул был выключен.".
           return.
       end.
       RUN next-good-display.
    end.
end.

ON choose OF b-chk IN FRAME d-gds-form /* Чеки */ DO:
  run proc-b-chk in this-procedure no-error.
  if error-status:error then do:
    apply "entry" to b-chk in frame {&frame-name}.
    return no-apply.
  end.
end.

ON choose OF b-exit IN FRAME d-gds-form /* Выход */
DO:
define variable prod-bc-added as logical init yes.
assign
v-next-prev = ?.

 
if can-do( {&update_add-def}, mode ) then  do:    /* Вых */
  assign
  one-good = yes
  saved-name2 = saved-name.
if temp-goods.alc-prod = yes then 
do:
  if temp-goods.alc-choose-prod = 0 then do:
        message "Введите вид алког. продукции в Доп. инфо" VIEW-AS ALERT-BOX .
        RETURN NO-APPLY. 
  end.
  if (input frame {&frame-name} ub.goods.ms-base = 0) then 
  do:
    message "Введите объем штуки в карточке товара" VIEW-AS ALERT-BOX .
    RETURN NO-APPLY. 
  end.
  run clntattr-value in this-procedure ( input clients.obj-type
                                       , input clients.obj-code
                                       , input {&attr-cli-alc-producer}
                                       , output v-cli-alc-producer
                                       , output v-attr-type
                                       ) .
  if v-cli-alc-producer = "no" then
  do:
    message "Производитель товара не является производителем алкогольной продукции, установите соответствующий атрибут в справочнике клиентов." VIEW-AS ALERT-BOX .
    return no-apply .
  end.
end. 
  RUN check-add in this-procedure ( input 2)  no-error.

  if error-status:error then
      return no-apply.
  if NOT f-name = "" then dO:
  message ("Импорт из файла " + f-name + " закончен" + {&new-line} + "прочитано " + string(impc) +
  ",  сохранено " + string(impc-saved) ) view-as alert-box
  INFORMATION.
  DISABLE
  b-card with frame {&frame-name}.
  display "" @ goods.artic with frame {&frame-name}.
  end.
end.
if mode = {&add-def} then DO:
    run ref/add-matr.p ( input parParentProc
                        ,input goods.gds-code) no-error .
    if error-status :error then message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "Ошибка добавления в Ассортиментную матрицу - add-matr.p"
      view-as alert-box error
    .

end.
                
run perproc-delete-from-parent( this-procedure , "").
end.

ON choose OF b-hist IN FRAME d-gds-form /* История */
DO:
define variable v-rid-list as character no-undo .
run ref/cgdshist.w (
                  input parparentproc
                , input v-host-code /*p-curr-host-code*/
                , input p-obj-type  /*p-curr-obj-type*/
                , input p-obj-code  /*p-curr-obj-code*/
                , input "":U /*bttns*/
                , input "one":U /*p-mode*/
                , input goods.gds-code
                , input ? /*p-host-code*/
                , input ? /*p-obj-type*/
                , input ? /*p-obj-code*/
                , input ? /* p-corr-user-db-num  */
                , input "":U /* p-corr-user-name  */
                , input "":U /* p-subject  */
                , input v-cntxt-db-num /* p-db-num */
                , input-output v-rid-list  ) no-error .
 apply "entry" to b-hist in frame {&frame-name}.
end.

ON choose OF b-file IN FRAME d-gds-form /* История */
DO:
  run start-import no-error.
  if error-status:error then return no-apply.
end.



ON choose OF b-inf IN FRAME d-gds-form /* Учет */
DO:
  def buffer for-gds-obj for ub.gds-obj.
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


  if NOT g#log then return no-apply.
  if mode <> {&add-def} AND NOT available ub.gds-obj then do:
    FIND FIRST for-gds-obj No-LOCK WHERE
               for-gds-obj.host-code = v-host-code AND
               for-gds-obj.artic = ub.goods.artic AND
               for-gds-obj.prod-type = ub.goods.prod-type AND
               for-gds-obj.prod-code = ub.goods.prod-code No-ERROR.
    if not avail for-gds-obj then do:
      if goods.gds-type = {&gds-goods}
        then
      message "Еще не было НИ ОДНОГО прихода" skip
              "данного товара в ТЕКУЩУЮ фирму" skip
              string( "( " + trim( v-host-name ) + " )." , "x(35)" )
      view-as alert-box INFORMATION .
        else
      message "Для данной УСЛУГИ не определены" skip
              "учетные цены в ТЕКУЩЕЙ фирме" skip
              string( "( " + trim( v-host-name ) + " )." , "x(35)" )
      view-as alert-box INFORMATION .
      return no-apply.
    end.
  end.
  if for-obj-price-base:visible then do:
      IF (avail ub.units and lookup({&twounit}, ub.units.type) > 0 ) then
      VIEW
      ub.goods.min-rate
      ub.goods.max-rate
      IN FRAME {&frame-name}.
      VIEW
      ub.goods.qnty-cart
      ub.goods.ms-base
      ub.goods.wt-base
      ub.goods.ms-cart
      ub.goods.wt-cart
      ub.goods.calc-method
      ub.goods.increase-pc
      label-increase-pc
      label-min-rate
      label-max-rate
      RECT-2
      RECT-3
      RECT-4
      IN frame {&frame-name}.
    HIDE
    name-uchet-base
    name-uchet-rubl
    for-obj-price-rubl
    for-obj-last-rubl
    for-obj-price-base
    for-obj-last-base
    in frame {&frame-name}.
    APPLY "Value-changed" to goods.calc-method in frame {&frame-name}.
  end.
  else do:
    IF igoods OR (avail ub.goods and ub.goods.gds-type = {&gds-goods}) then do: /*у нас товар!!*/
      HIDE
      ub.goods.min-rate
      ub.goods.max-rate
      ub.goods.qnty-cart
      ub.goods.ms-base
      ub.goods.wt-base
      ub.goods.ms-cart
      ub.goods.wt-cart
      ub.goods.calc-method
      ub.goods.increase-pc
      label-increase-pc
      label-min-rate
      label-max-rate
      RECT-2
      RECT-3
      RECT-4
      in frame {&frame-name}.
      DISPLAY
      name-uchet-base
      name-uchet-rubl
      (if avail gds-obj then ub.gds-obj.last-base else 0) @ for-obj-last-base
      (if avail gds-obj then ub.gds-obj.last-rubl else 0) @ for-obj-last-rubl
      (if avail gds-obj then ub.gds-obj.avrg-base else 0) @ for-obj-price-base
      (if avail gds-obj then ub.gds-obj.avrg-rubl else 0 ) @ for-obj-price-rubl
      WITH frame {&frame-name}.
      DISABLE
      for-obj-price-base
      for-obj-price-rubl
      for-obj-last-base
      for-obj-last-rubl
      WITH frame {&frame-name}.
      APPLY "Value-changed" to ub.goods.calc-method in frame {&frame-name}.
    end.
    else do:
      HIDE
      ub.goods.min-rate
      ub.goods.max-rate
      ub.goods.qnty-cart
      ub.goods.ms-base
      ub.goods.wt-base
      ub.goods.ms-cart
      ub.goods.wt-cart
      ub.goods.calc-method
      goods.increase-pc
      label-increase-pc
      label-min-rate
      label-max-rate
      RECT-2
      RECT-3
      RECT-4
      in frame {&frame-name}.
      if mode = {&update} OR MODE = {&add-def}
        then
      ENABLE
      for-obj-price-base
      for-obj-price-rubl
      WITH frame {&frame-name}.
      DISPLAY
      name-uchet-base
      name-uchet-rubl
      (if avail ub.gds-obj then ub.gds-obj.price-base else 0 ) @ for-obj-price-base
      (if avail ub.gds-obj then ub.gds-obj.price-rubl else 0 ) @ for-obj-price-rubl
      WITH frame {&frame-name}.
      HIDE
      for-obj-last-base
      for-obj-last-rubl
      IN frame {&frame-name}.
      APPLY "Value-changed" to goods.calc-method in frame {&frame-name}.
      apply "entry" to for-obj-price-base in frame {&frame-name}.
      return no-apply.
    END.
  end. /*зажечь*/
  apply "entry" to b-inf in frame {&frame-name}.
END.

ON choose OF b-parts IN FRAME d-gds-form /* Партии */
DO:
define variable prt-rec as recid no-undo .
define variable glog as logical no-undo .
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
      glog
    }
   IF NOT glog THEN DO:
     RETURN no-apply.
   END.

   run str/parts-l.w
     (
      INPUT parparentproc
     ,input p-obj-type               /* v-obj-type   */
     ,input p-obj-code               /* v-obj-code   */
     ,input goods.gds-code            /* p-gds-code   */
     ,input ""                        /* p-doc-code   */
     ,input {&lookup}                 /* p-edit-mode  */
     ,input {&parts-l_parts-rest}     /* p-r-parts    */
     ,input {&parts-l_object-current} /* p-one-all    */
     ,input {&parts-l_call-reference} /* p-call-point */
     ,output prt-rec                  /* part-recid   */
     ) .
    apply "entry" to b-parts in frame {&frame-name}.
END.
ON choose OF b-place IN FRAME d-gds-form /* Скл места */
DO:
  define variable rid-list as char no-undo.
  run ref/pl-gdss.w (  input parparentproc
                , input "":U
                , input p-obj-type
                , input p-obj-code
                , input {&goods} /*p-mode*/
                , input recid(goods)
                , input ?
                , output rid-list).
  apply "entry" to b-place in frame {&frame-name}.
END.

ON choose OF b-prt IN FRAME d-gds-form /* Шкала */
DO:
define variable ref-rec as recid no-undo .
    if mode = {&add-def} then
        do:    /* Выбор шкалы */
            run ref/gdsprts.w ( input parparentproc
                               ,input yes
                               ,output ref-rec).
            if ref-rec = ? then
                do:
                    apply "entry" to b-prt in frame {&frame-name}.
                    return no-apply.
                end.
            FIND ub.gds-prt WHERE recid (ub.gds-prt) = ref-rec.
            DISPLAY ub.gds-prt.node-name with frame {&frame-name}.
        end.
    else do:
      if available ub.goods
      then do:
        define variable v-sel-node-code as integer   no-undo .
        run str/prt-ref.w
          (input parparentproc
          ,input  ub.goods.gds-code   /* p-gds-code      */
          ,input  {&lookup}        /* p-mode          */
          ,input  p-obj-type       /* p-obj-type      */
          ,input  p-obj-code       /* p-obj-code      */
          ,input  ""               /* p-doc-code      */
          ,input  ""               /* p-search-code   */
          ,output v-sel-node-code  /* p-sel-node-code */
          ) .
      end.
      apply "entry" to b-prt in frame {&frame-name}.
    end.
end.

ON CHOOSE OF b-recipe IN FRAME d-gds-form /* Рецепт */
DO:
    FIND ub.units WHERE ub.units.unit-name = ub.goods.unit-base NO-LOCK .
    if can-do( ub.units.type, {&serial} ) then
        message "Для серийного товара" skip
                        "рецепт задать нельзя !" view-as alert-box INFORMATION .
    else
        do:
            FIND ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK .
            if can-do( {&empty-scale}, ub.gds-prt.node-name )
            then do:
                run ref/rcp-all.w (
                      input parParentProc
                    , input ( if mode = {&update} then "b-add" else "nb-del,nb-chg" )
                    , input ""
                    , input recid(goods)
                    , input p-obj-type
                    , input p-obj-code
                    , output ref-list
                ).
            end.
            else do:
                message
                    "Рецепт можно определить"
                    skip "только для товара БЕЗ ПРИЗНАКОВ."
                view-as alert-box information .
            end.
        end.
END.

ON choose OF b-rest IN FRAME d-gds-form /* Остатки */
DO:
  if mode = {&lookup}
  then do:
    find ub.gds-prt no-lock
      where ub.gds-prt.upper-code = ub.goods.prt-root
      .
    assign
      gds-rec = recid( ub.goods )
    .

    run rep/gds-objs.w
      (input parparentproc
      ,input ub.goods.artic
      ,input ub.goods.prod-type
      ,input ub.goods.prod-code
      ,input v-host-code
      ,input -1
      ).
    apply "entry" to b-rest in frame {&frame-name}.
  end.
  else do:
    RUN check-update-attr IN THIS-PROCEDURE(yes) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
    if mode = {&update} and not updated
    then gds-rec = ?.
    else if NOT f-name = "" then do:
        message ("Импорт из файла " + f-name + " закончен" + {&new-line} + "прочитано " + string(impc) +
          ",  сохранено " + string(impc-saved) ) view-as alert-box
          INFORMATION.
          display
          "" @ goods.artic
          with frame {&frame-name}.
          DISABLE
          b-card
          with frame {&frame-name}.
    end.
    run perproc-delete-from-parent( this-procedure , "").
    v-next-prev = ?.
    apply "go" to frame {&frame-name}.
  end.
end.

ON choose OF b-sert IN FRAME d-gds-form /* Сертификат */
DO:
  run proc-b-sert no-error.
  if error-status:error then return no-apply.
end.

ON return OF goods.gds-name IN FRAME d-gds-form /* Название */
DO:
    if input frame {&frame-name} goods.gds-name = "" then
        do:
            message "Название не может быть пустым !".
            apply "entry" to goods.gds-name in frame {&frame-name}.
            return no-apply.
        end.
    if input frame {&frame-name} goods.unit-base = "" then
        apply "entry" to goods.unit-base in frame {&frame-name}.
    else
        if mode = {&add-def} then
            apply "entry" to b-arch in frame {&frame-name}.
        else
            apply "entry" to b-exit in frame {&frame-name}.
    return no-apply.
end.

ON LEAVE OF goods.gds-name IN FRAME d-gds-form /* Название */
DO:
    run copy-name-to-lbl.
END.

ON CHOOSE OF b-copy-name-to-lbl IN FRAME d-gds-form /* Название */
DO:
    run copy-name-to-lbl.
END.

ON VALUE-CHANGED OF NegRest IN FRAME d-gds-form /* Отрицательные остатки */
do:
    assign NegRest .
end.

ON leave OF ub.clients.obj-code IN FRAME d-gds-form /* Объект */
do:
    FIND ub.clients WHERE ub.clients.obj-type = input frame {&frame-name} ub.clients.obj-type
                                and ub.clients.obj-code = input frame {&frame-name} ub.clients.obj-code
                                no-lock no-error.
    if available ub.clients then
        DISPLAY ub.clients.obj-name with frame {&frame-name}.
    HIDE Infmes in frame {&frame-name}.
end.

ON return OF ub.clients.obj-code IN FRAME d-gds-form /* Объект */
do:
  define variable ref-rec as recid no-undo .
  FIND ub.clients WHERE ub.clients.obj-type = input frame {&frame-name} ub.clients.obj-type
                              and ub.clients.obj-code = input frame {&frame-name} ub.clients.obj-code
                              no-lock no-error.
  if available ub.clients then
      do:
          DISPLAY ub.clients.obj-name with frame {&frame-name}.
          apply "entry" to ub.goods.gds-name in frame {&frame-name}.
          return no-apply.
      end.
  else  do:
    run ref/cli-all.w ( input parParentProc
                       ,input "b-add,b-sel"
                       ,input ?
                       ,input ?
                       ,input ?
                       ,input ?
                       ,input ?
                       ,input ?
                       ,output ref-list) .
    if ref-list = "" then do:
      apply "entry" to ub.clients.obj-code in frame {&frame-name}.
      return no-apply.
    end.
    ref-rec = integer (ref-list).
    FIND ub.clients WHERE recid (ub.clients) = ref-rec NO-LOCK .
    DISPLAY ub.clients.obj-type ub.clients.obj-code ub.clients.obj-name with frame {&frame-name}.
    apply "entry" to ub.goods.gds-name in frame {&frame-name}.
    return no-apply.
  end.
end.

ON LEAVE OF clients.obj-type IN FRAME d-gds-form /* Произв-ль */
DO:
    HIDE Infmes in frame {&frame-name}.
END.

ON choose OF r-base IN FRAME d-gds-form /* r-base */
do:
define variable ref-rec as recid no-undo .
    run ref/units.w ( input parparentproc
               , input yes
               , output ref-rec ).
    if ref-rec = ? then do:
            apply "entry" to r-base in frame {&frame-name}.
            return no-apply.
     end.
    FIND ub.units WHERE recid (ub.units) = ref-rec NO-LOCK.
    DISPLAY ub.units.unit-name @ goods.unit-base with frame {&frame-name}.
    if avail ub.gds-grp then do:
      run ref/dtaxgdss.p (
                    input no /*p-silent*/
                   ,input ub.goods.unit-base:screen-value
                   ,input  ub.gds-grp.node-code
                   ,input ?
                   ,input ?
                   ,input v-host-code
                   ,input p-obj-type
                   ,input p-obj-code
                    ) no-error.
      if error-status:error then return no-apply.
    end.
    run enable-max-min(goods.unit-base:screen-value) no-error.
    if error-status:error then return no-apply.
    OPEN QUERY br-tt-tax for each tt-tax NO-LOCK.
    if input frame {&frame-name} goods.unit-cli =
            input frame {&frame-name} goods.unit-base then
        do:
            DISPLAY 1 @ goods.cli-base-rate with frame {&frame-name}.
            DISABLE goods.cli-base-rate with frame {&frame-name}.
        end.
    else
        ENABLE goods.cli-base-rate with frame {&frame-name}.
    apply "entry" to goods.unit-cli in frame {&frame-name}.
end.

ON LEAVE OF goods.alpha1 IN FRAME d-gds-form /* alpha1 */
OR ENTER OF goods.alpha1 IN FRAME {&frame-name}
DO:
  if not can-FIND( ub.country where ub.country.alpha1 = input frame {&frame-name} ub.goods.alpha1 )
  and (ub.goods.alpha1:modified = yes or f-name = '':U)  then
  frame-value = "XX".
  FIND FIRST ub.COUNTRY WHERE ub.COUNTRY.alpha1 = frame-value No-LOCK No-ERROR.
  COUNTRY_name = if avail ub.country then ub.country.short-name else "".
  DISPLAY country_name with FRAME {&FRAME-NAME}.
END.

ON return OF ub.goods.alpha1 IN FRAME d-gds-form /* alpha1 */
do:
define variable rid-list as character no-undo .
  if not can-FIND( ub.country where
                            ub.country.alpha1 = input frame {&frame-name} goods.alpha1 ) then  do:
            run ref/countris.w ( input parparentproc
                                ,input "b-sel"
                                ,input-output rid-list ).
            if rid-list = '' then
                do:
                    apply "entry" to goods.alpha1 in frame {&frame-name}.
                    return no-apply.
                end.
            FIND ub.country WHERE recid (ub.country) = integer(rid-list) NO-LOCK.
            DISPLAY ub.country.alpha1 @ ub.goods.alpha1 with frame {&frame-name}.
        end.
    return no-apply.
end.

ON choose OF r-alpha1 IN FRAME d-gds-form /* r-alpha */
do:
define variable v-rid-list as character no-undo .
define buffer buf_country for ub.country.
find first buf_country no-lock where
         buf_country.alpha1 = (input frame {&frame-name}  goods.alpha1) no-error.
if available buf_country then do:
  v-rid-list = string(recid(buf_country)).
end.

    run ref/countris.w (  input parparentproc
                      ,input "b-sel":U
                      ,input-output v-rid-list ).
if v-rid-list = '' then  do:
            apply "entry" to r-alpha1 in frame {&frame-name}.
            return no-apply.
        end.
    FIND ub.country WHERE recid (ub.country) = integer(v-rid-list) NO-LOCK.
    DISPLAY ub.country.alpha1 @ ub.goods.alpha1
                    ub.country.short-name @ country_name with frame {&frame-name}.

end.

ON choose OF r-prod IN FRAME d-gds-form /* r-prod */
do:
define variable ref-rec as recid no-undo .
  run ref/cli-all.w ( input parParentProc
                     ,input "b-add,b-sel"
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,output ref-list) .
  if ref-list = "" then do:
    apply "entry" to r-prod in frame {&frame-name}.
    return no-apply.
  end.
  ref-rec = integer( ref-list ).
  FIND ub.clients WHERE recid (ub.clients) = ref-rec NO-LOCK .
  DISPLAY ub.clients.obj-type ub.clients.obj-code ub.clients.obj-name with frame {&frame-name}.
  apply "entry" to ub.goods.gds-name in frame {&frame-name}.
end.

ON choose OF r-supp IN FRAME d-gds-form /* r-supp */
do:
define variable ref-rec as recid no-undo .
    run ref/units.w (
                  input parparentproc
                 ,input yes
                 ,output ref-rec).
    if ref-rec = ? then
        do:
            apply "entry" to r-supp in frame {&frame-name}.
            return no-apply.
        end.
    FIND ub.units WHERE recid (ub.units) = ref-rec NO-LOCK.
    DISPLAY ub.units.unit-name @ ub.goods.unit-cli with frame {&frame-name}.
    if input frame {&frame-name} ub.goods.unit-cli =
            input frame {&frame-name} ub.goods.unit-base then
        do:
            DISPLAY 1 @ ub.goods.cli-base-rate with frame {&frame-name}.
            DISABLE ub.goods.cli-base-rate with frame {&frame-name}.
            apply "entry" to ub.goods.calc-method in frame {&frame-name}.
        end.
    else
        do:
            ENABLE ub.goods.cli-base-rate with frame {&frame-name}.
            apply "entry" to ub.goods.cli-base-rate in frame {&frame-name}.
        end.
end.
ON choose OF r-fbr-grp IN FRAME d-gds-form /* r-fbr-grp */
do:
define variable v-recid-list as character no-undo .
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
find first buf_fbr-gds-grp no-lock where
        buf_fbr-gds-grp.obj-type = "":U
    AND buf_fbr-gds-grp.obj-code = 0
    AND buf_fbr-gds-grp.node-code = fbr-grp-code_ no-error .
    if available buf_fbr-gds-grp then
    assign
    v-recid-list = string(recid(buf_fbr-gds-grp))
    .
    run ref/fbrggrp.w (
          input parparentproc
        , input p-obj-type
        , input p-obj-code
        , input ({&buttons-for-rubr-only} + {&comma-char} + {&button-sel-only} + {&comma-char} +  {&g#term})
        , input-output v-recid-list
    ).
    if v-recid-list <> ""
    then do:
        find first buf_fbr-gds-grp no-lock
             where recid( buf_fbr-gds-grp )  = integer( entry( 1, v-recid-list ) )
        no-error.
        if not available buf_fbr-gds-grp
        then do:
            return no-apply.
        end.
        assign
        f-fbr-grp-name = buf_fbr-gds-grp.node-name
        fbr-grp-code_ = buf_fbr-gds-grp.node-code
        .
        display
        f-fbr-grp-name
        with frame {&frame-name}.
    end.
end.
ON LEAVE OF goods.unit-base IN FRAME d-gds-form /* Учет.ед.изм. */
DO:
    run leave-unit-base(frame-value) no-error.
    if error-status:error then return no-apply.
END.

ON return OF goods.unit-base IN FRAME d-gds-form /* Учет.ед.изм. */
do:
define variable ref-rec as recid no-undo .
    if not can-FIND( ub.units where
                     ub.units.unit-name = input frame {&frame-name} ub.goods.unit-base ) then do:
        run ref/units.w (
                     input parparentproc
                    ,input yes
                    ,output ref-rec ).
        if ref-rec = ? then
            do:
                apply "entry" to ub.goods.unit-base in frame {&frame-name}.
                return no-apply.
            end.
        FIND ub.units WHERE recid (ub.units) = ref-rec NO-LOCK.
        DISPLAY ub.units.unit-name @ ub.goods.unit-base with frame {&frame-name}.
    end.
    apply "entry" to goods.unit-cli in frame {&frame-name}.
    return no-apply.
end.

ON CHOOSE OF b-tax IN FRAME d-gds-form /* << */
DO:
 run proc-b-tax no-error.
 if error-status:error then return no-apply.
END.

ON ROW-ENTRY OF BR-tt-tax IN FRAME d-gds-form
DO:
  if mode = {&update} then do :
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_reference_upd-gds-tax':U
      {&cntxt-global}
      0
      '':U
      0
      0
      goods.grp-code
      0
      true
      g#log
    }
    if not g#log then do:
      APPLY "ENTRY" TO goods.PS in frame {&frame-name}.
      return no-apply.
    end.
  end.
END.

ON ROW-LEAVE OF BR-tt-tax IN FRAME d-gds-form
DO:
    if
    NOT integer(tt-tax.rate-code:screen-value in browse br-tt-tax) = tt-tax.rate-code OR
    NOT decimal(tt-tax.rate-value:screen-value in browse br-tt-tax) = tt-tax.rate-value OR
    NOT date(tt-tax.fact-date:screen-value in browse br-tt-tax) = tt-tax.fact-date
    then do:
        run row-leave-br-tt-tax(integer(tt-tax.rate-code:screen-value in browse br-tt-tax)) no-error.
        if error-status:error then return no-apply.
    end.
END.

ON RETURN OF tt-tax.rate-code IN BROWSE BR-tt-tax DO:
    define variable rt as recid NO-UNDO.
    define variable tax-rate-rid as char no-undo init "".
    define variable taxvalue like ub.tax-rate-value.rate-value no-undo.
    DEFINE VARIABLE v-today as date no-undo .
    DEFINE VARIABLE v-time as integer no-undo .
    IF AVAIL tt-tax then do:
        if tt-tax.individual then do:
            if tt-tax.rate-code = ? then do:
                message "Ставка налога индивидуальна для каждого товара" skip
                                "и создается автоматически при создании товара!" view-as alert-box
                                WARNING.
                return no-apply.
            end.
            else do:
                message "Нельзя изменять ставку индивидуального налога!" view-as alert-box
                                ERROR.
                return no-apply.
            end.
        end.
        FIND FIRST ub.tax NO-LOCK WHERE ub.tax.tax-code = tt-tax.tax-code NO-ERROR.
        if not avail ub.tax then return no-apply.
        FIND FIRST ub.tax-rate NO-LOCK WHERE ub.tax-rate.tax-code = tt-tax.tax-code AND
                                                                       ub.tax-rate.rate-code = tt-tax.rate-code NO-ERROR.
        if not avail ub.tax-rate then return no-apply.
        assign
        rt = recid(ub.tax)
        tax-rate-rid = string(recid(ub.tax-rate))
        .
        run ref/tax-tree.w (
                        input parparentproc
                       ,input "b-seltax-rate":U
                       ,input "ALL-TAX-RATES":U
                       ,input v-host-code
                       ,input p-obj-type
                       ,input p-obj-code
                       ,input rt
                       ,input-output tax-rate-rid) no-error .
        if NOT tax-rate-rid = "" then do:
            FIND FIRST tax-rate NO-LOCK WHERE
                       recid(tax-rate) = integer(tax-rate-rid) NO-ERROR.
            if not avail tax-rate then return no-apply.
            { gbl/pftaxval.i integer(tax-rate-rid) tax-rate.tax-code tax-rate.rate-code ? v-host-code p-obj-type p-obj-code taxvalue no-error }
            if error-status:error or taxvalue = ? then return no-apply.
            if mode = {&add-def} and not copymode then v-today = 01/01/1990.
            else do:
              run cur-time in this-procedure(output v-today, output v-time).
            end.
            assign
            tt-tax.rate-code:screen-value in browse br-tt-tax = string(tax-rate.rate-code)
            tt-tax.rate-value:screen-value in browse br-tt-tax = string(taxvalue)
            tt-tax.fact-date:screen-value in browse br-tt-tax = string(v-today, "99/99/9999")
            .
         end.
     end.
END.


ON return OF goods.unit-cli IN FRAME d-gds-form /* Ед. пост-ка */
do:
define variable ref-rec as recid no-undo .
    if not can-find( ub.units where
                     ub.units.unit-name = input frame {&frame-name} ub.goods.unit-cli ) then do:
        run ref/units.w (
                     input parparentproc
                    ,input yes
                    ,output ref-rec ).
        if ref-rec = ? then do:
          apply "entry" to ub.goods.unit-cli in frame {&frame-name}.
          return no-apply.
        end.
        FIND ub.units WHERE recid (ub.units) = ref-rec NO-LOCK.
        DISPLAY ub.units.unit-name @ goods.unit-cli with frame {&frame-name}.
    end.
    if input frame {&frame-name} ub.goods.unit-cli =
           input frame {&frame-name} ub.goods.unit-base then
        do:
            DISPLAY 1 @ goods.cli-base-rate with frame {&frame-name}.
            DISABLE goods.cli-base-rate with frame {&frame-name}.
            apply "entry" to goods.calc-method in frame {&frame-name}.
        end.
    else
        do:
            ENABLE goods.cli-base-rate with frame {&frame-name}.
            apply "entry" to goods.cli-base-rate in frame {&frame-name}.
        end.
    return no-apply.
end.
on leave of goods.qnty-cart in frame {&frame-name}
do:
  define variable varlog as logical initial no no-undo.
  if (input frame {&frame-name} goods.ms-base <> 0 and input frame {&frame-name} goods.ms-base <> ? or
      input frame {&frame-name} goods.wt-base <> 0 and input frame {&frame-name} goods.wt-base <> ?   ) and
     (input frame {&frame-name} goods.ms-base * input frame {&frame-name} goods.qnty-cart <> input frame {&frame-name} goods.ms-cart or
      input frame {&frame-name} goods.wt-base * input frame {&frame-name} goods.qnty-cart <> input frame {&frame-name} goods.wt-cart   )
      then do:
    message "Вы хотите пересчитать вес и объем упаковки, исходя из количества в упаковке и веса и объема штуки?"
    view-as alert-box question button yes-no update varlog.
    if varlog = yes then do:
      display input frame {&frame-name} goods.ms-base * input frame {&frame-name} goods.qnty-cart @ goods.ms-cart
              input frame {&frame-name} goods.wt-base * input frame {&frame-name} goods.qnty-cart @ goods.wt-cart
      with frame {&frame-name}.
    end.
  end.
end.

on leave of goods.ms-base in frame {&frame-name}
do:
  define variable varlog as logical initial no no-undo.
  if input frame {&frame-name} goods.qnty-cart <> 0 and
     input frame {&frame-name} goods.qnty-cart <> ? and
     input frame {&frame-name} goods.ms-base * input frame {&frame-name} goods.qnty-cart <> input frame {&frame-name} goods.ms-cart
      then do:
    message "Вы хотите пересчитать объем упаковки, исходя из количества в упаковке и объема штуки?"
    view-as alert-box question button yes-no update varlog.
    if varlog = yes then do:
      display input frame {&frame-name} goods.ms-base * input frame {&frame-name} goods.qnty-cart @ goods.ms-cart
      with frame {&frame-name}.
    end.
  end.
end.

on leave of goods.wt-base in frame {&frame-name}
do:
  define variable varlog as logical initial no no-undo.
  if input frame {&frame-name} goods.qnty-cart <> 0 and
     input frame {&frame-name} goods.qnty-cart <> ? and
     input frame {&frame-name} goods.wt-base * input frame {&frame-name} goods.qnty-cart <> input frame {&frame-name} goods.wt-cart
      then do:
    message "Вы хотите пересчитать вес упаковки, исходя из количества в упаковке и веса штуки?"
    view-as alert-box question button yes-no update varlog.
    if varlog = yes then do:
      display input frame {&frame-name} goods.wt-base * input frame {&frame-name} goods.qnty-cart @ goods.wt-cart
      with frame {&frame-name}.
    end.
  end.
end.

on leave of goods.ms-cart in frame {&frame-name}
do:
  define variable varlog as logical initial no no-undo.
  if input frame {&frame-name} goods.qnty-cart <> 0 and
     input frame {&frame-name} goods.qnty-cart <> ? and
     input frame {&frame-name} goods.ms-base * input frame {&frame-name} goods.qnty-cart <> input frame {&frame-name} goods.ms-cart
      then do:
    message "Вы хотите пересчитать объем штуки, исходя из количества в упаковке и объема упаковки?"
    view-as alert-box question button yes-no update varlog.
    if varlog = yes then do:
      display input frame {&frame-name} goods.ms-cart / input frame {&frame-name} goods.qnty-cart @ goods.ms-base
      with frame {&frame-name}.
    end.
  end.
end.

on leave of goods.wt-cart in frame {&frame-name}
do:
  define variable varlog as logical initial no no-undo.
  if input frame {&frame-name} goods.qnty-cart <> 0 and
     input frame {&frame-name} goods.qnty-cart <> ? and
     input frame {&frame-name} goods.wt-base * input frame {&frame-name} goods.qnty-cart <> input frame {&frame-name} goods.wt-cart
      then do:
    message "Вы хотите пересчитать вес штуки, исходя из количества в упаковке и веса упаковки?"
    view-as alert-box question button yes-no update varlog.
    if varlog = yes then do:
      display input frame {&frame-name} goods.wt-cart / input frame {&frame-name} goods.qnty-cart @ goods.wt-base
      with frame {&frame-name}.
    end.
  end.
end.

on choose of b-gdsfrmfi in frame {&frame-name} do:
  if mode <> {&lookup} then return no-apply.
  run gdsfrmfi-description in this-procedure .
end.

ON WINDOW-CLOSE OF FRAME {&frame-name}
DO:
  APPLY "END-ERROR":U TO SELF.
END.

ON END-ERROR OF FRAME {&frame-name}
DO:
  RUN check-update-attr IN THIS-PROCEDURE (yes) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  run perproc-delete-from-parent( this-procedure , "").
  v-next-prev = ?.
END.

ON CHOOSE OF b-next IN FRAME {&frame-name}
DO:
run reposition-goods in this-procedure
  (input 'next':U
  ).
END.

ON CHOOSE OF b-prev IN FRAME {&frame-name}
DO:
run reposition-goods in this-procedure
  (input 'prev':U
  ).
END.

on choose of b-extart in frame {&FRAME-NAME} do:
  run proc-b-extart in this-procedure ( input goods.gds-code ) no-error .
  if error-status :error then do :
    return no-apply.
  end.
end.

/* ***************************  Main Block  *************************** */


IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

if LOOKUP({&add-def}, mode)  > 0 OR LOOKUP({&add-copy}, mode) > 0 then do:
  assign
  igoods = if entry(2, mode) = {&gds-goods} then yes else no
  no-error.
  if error-status:error then do:
    message "Выберите, что добавлять товар или услугу"
    view-as alert-box.
    return.
  end.
  mode = entry(1, mode).
end.

on alt-shift-f6 anywhere do:
  if available ub.goods
  then do:
    run gbl/d-infgds.p
      (input ub.goods.gds-code /* p-gds-code */
      ,input p-obj-type        /* p-obj-type */
      ,input p-obj-code        /* p-obj-code */
      ) .
  end.
end.
run proc-settings in this-procedure (
input-output var-artic-disable,
input-output var-negative-rest,
input-output unq-artc,
input-output dif-nam1,
input-output dif-nam2,
input-output dif-pdbc,
input-output tnvedimp,
input-output v-gds-copy,
input-output vattaxcd,
input-output slttaxcd,
input-output dfltggrp,
input-output gdsfrmfi
) no-error .
if error-status:error then undo, return error.

for each temp-goods:
  delete temp-goods.
end.
assign
ArtDis = var-artic-disable
ArtBAr:list-items = IF v-cntxt-db-num = 0
then (vArtBar-off + {&comma-char} + vArtBar-Auto + {&comma-char} + vArtBar-BarCode)
else (vArtBar-off + {&comma-char} + vArtBar-Auto)
ArtBar = if Artdis then vArtBar-Auto else vArtBar-off
f-name = ""
add-another = yes
.
if mode = {&add-copy} then do:
  copymode = yes.
  FIND FIRST for-goods where recid(for-goods) = gds-rec NO-LOCK NO-ERROR.
  if not avail for-goods then return.
  find first temp-goods no-error.
  if not available temp-goods then do:
    create temp-goods.
  end.
  buffer-copy for-goods to temp-goods.
  FIND FIRST clients WHERE
              clients.obj-type = temp-goods.prod-type AND
              clients.obj-code = temp-goods.prod-code NO-LOCK NO-ERROR.
  FIND FIRST gds-obj WHERE
              gds-obj.obj-type = p-obj-type
         AND  gds-obj.obj-code = p-obj-code
         AND  gds-obj.artic = for-goods.artic
         AND  gds-obj.prod-type = for-goods.prod-type
         AND  gds-obj.prod-code = for-goods.prod-code NO-ERROR .
  FIND gds-prt WHERE gds-prt.upper-code = for-goods.prt-root NO-LOCK.
  FIND FIRST ub.bar-code WHERE
        ub.bar-code.gds-code  = for-goods.gds-code AND
        ub.bar-code.node-code = gds-prt.node-code AND
        ub.bar-code.in-code = "" AND
        ub.bar-code.part-code = "" AND
        ub.bar-code.unit-cli = for-goods.unit-base NO-LOCK NO-ERROR.
  IF NOT AVAIL ub.bar-code then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найден главный код для товара " ub.goods.artic ub.goods.prod-type string(goods.prod-code)
    view-as alert-box ERROR.
    return error.
  end.
  FIND ub.gds-grp WHERE ub.gds-grp.node-code = for-goods.grp-code NO-LOCK.
  assign
  igoods = IF for-goods.gds-type = {&gds-goods}
            THEN yes
            else no
  mode = {&add-def}
  saved-name = temp-goods.gds-name.
  run fill-attr-tables in this-procedure ({&table_gds-host-attr}, mode) no-error.
  run fill-attr-tables in this-procedure ({&table_goods-attr}, mode) no-error.
  run fill-attr-tables in this-procedure ({&table_fbr-gds-obj}, mode) no-error .
  run fill-attr-tables in this-procedure ({&table_s-coeff}, mode) no-error .
  run fill-attr-tables in this-procedure ({&table_gds-obj-attr}, mode) no-error .
  run fill-attr-tables in this-procedure ({&table_gds-obj-prop}, mode) no-error.
  run fill-attr-tables in this-procedure ({&table_gds-obj-prop} + 'obj', mode) no-error.
  run fill-attr-tables in this-procedure ({&table_gds-obj-prop} + 'firm', mode) no-error.
  run fill-attr-tables in this-procedure ({&table_gds-add-charges}, mode) no-error.
  run fill-attr-tables in this-procedure ({&table_dis-gds-rule}, mode) no-error .
end.
if igoods = ? then return.
HIDE Infmes ImpMes in frame {&frame-name}.

add-cycle:
do while
add-another
or v-next-prev = '':U
:
  add-another = no.
  MAIN-BLOCK:
  DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
      if mode = {&update} then do:
        do TRANSACTION
        on error undo MAIN-BLOCK, return error
        on stop undo MAIN-BLOCK, return error:
        FIND first locked_goods Exclusive-lock WHERE recid (locked_goods) = gds-rec.
        find first goods where recid(goods) = recid(locked_goods).
        end.
      end.
      RUN enable-UI in this-procedure no-error.
      if error-status:error then do:
        v-next-prev = ?.
        undo main-block, return error .
      end.
      if wph = no then
      run gdsfrmfi-to  in this-procedure ( input gdsfrmfi
                                          ,input (if mode = {&lookup} then no else yes)
                                          ,OUTPUT v-dop-inf
                                        )  .
      run get-fields in this-procedure .
      if (mode = {&add-def})  then do:
          if ArtDis then do:
          end.
          if index(InfMes, "НЕ СОХРАНЕН") > 0 then
          display prev-artic @ goods.artic with frame {&frame-name}.
          else if ArtDIs then
          display /*string(nbc)*/ "" @ goods.artic with frame {&frame-name}.
          else if f-name = "" then
          display "" @ goods.artic with frame {&frame-name}.
      end.

  /* строка меню только для услуг и включенном параметре is-addch */
      if available goods then do: /* Просмотр и изменение */
          if mode = {&lookup} and  (goods.gds-type <> {&gds-goods}) then  apply "choose" to b-inf in frame {&frame-name}.
          if addch-value = 'yes' and (goods.gds-type <> {&gds-goods})
                      then MENU-ITEM m-dopinf-AC:SENSITIVE IN MENU m-dopinf = true  .
                      else MENU-ITEM m-dopinf-AC:SENSITIVE IN MENU m-dopinf = false .
      end.
      else do:  /* Добавление и копирование */
          if mode = {&add-def} and igoods = false then  apply "choose" to b-inf in frame {&frame-name}.
          if addch-value = 'yes' and igoods = false
                      then MENU-ITEM m-dopinf-AC:SENSITIVE IN MENU m-dopinf = true  .
                      else MENU-ITEM m-dopinf-AC:SENSITIVE IN MENU m-dopinf = false .
      end.

      IF mImagePh THEN MENU-ITEM m-dopinf-2:sensitive in MENU m-dopinf = true .
      ELSE MENU-ITEM m-dopinf-2:sensitive in MENU m-dopinf = false .

      case mode :
          when {&add-def} then
              if f-name = "" then
                  do:
                      if ArtDis then
                          WAIT-FOR GO OF FRAME {&FRAME-NAME} focus clients.obj-code.
                      else
                          WAIT-FOR GO OF FRAME {&FRAME-NAME} focus goods.artic.
                  end.
              else
                  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus b-arch.
          when {&update} then
              WAIT-FOR GO OF FRAME {&FRAME-NAME} focus goods.gds-name.
          when {&lookup} then
              if gds-prt.node-name = {&empty-scale} then
                  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus b-exit.
              else
                  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus b-prt.
      end case.
  END.
  release goods. /* выталкиваем уже добавленную запись */
end. /* add-cycle */
delete widget-pool "gdsfrmfi" no-error.
RUN disable_UI.
input stream gds-file close.

/* **********************  Internal Procedures  *********************** */

PROCEDURE check-add :
define input parameter pmode as integer no-undo.
DEFINE VARIABLE v-prev-rec as recid no-undo .
define variable choice-str as character no-undo .
define variable v-loc-update-dgr as logical no-undo .
define variable v-loc-update-attr-obj as logical no-undo .
define variable v-loc-update-attr-host as logical no-undo .
define variable v-loc-update-attr-gbl as logical no-undo .
define variable v-loc-update-fbr-gds as logical no-undo .
define variable v-loc-update-s-coeff as logical no-undo .
define variable v-loc-update-gds-prop as logical no-undo .
define variable v-loc-update-add-prop as logical no-undo .
define variable v-mess as character no-undo .
define buffer buf_bar-code for ub.bar-code .
run set-fields.
assign
prev-artic = input frame {&frame-name} goods.artic
NegRest
.
if NOT available ub.gds-prt then do:
  FIND first ub.gds-prt WHERE
            ub.gds-prt.node-name = {&empty-scale} NO-LOCK.
end.
if NOT ub.gds-prt.root then do:
  message
  "Шкала выбрана неправильно !"
  view-as alert-box error .
  return error.
end.

if input frame {&frame-name} ub.goods.unit-base = input frame {&frame-name} ub.goods.unit-cli then do:
  DISPLAY 1 @ ub.goods.cli-base-rate with frame {&frame-name}.
  DISABLE ub.goods.cli-base-rate with frame {&frame-name}.
end.
else do:
  ENABLE goods.cli-base-rate with frame {&frame-name}.
end.
assign
v-prev-rec = gds-rec
gds-rec = if mode = {&update}
          then recid(goods)
          else ?
.
choice-str = "yes".
if copymode and v-found-copy-atr-obj then v-update-attr-obj = yes.
if copymode and v-found-copy-atr-host then v-update-attr-host = yes.
if copymode and v-found-copy-atr-gbl then v-update-attr-gbl = yes.
if copymode and v-found-copy-fbr-gds then v-update-fbr-gds = yes.
if copymode and v-found-copy-s-coeff then v-update-s-coeff = yes.
if copymode and v-found-copy-gds-prop then v-update-gds-prop = yes.
if copymode and v-found-copy-add-prop then v-update-add-prop = yes.
if mode <> {&add-def} then do:
  /*еще раз проверим изменения*/
  RUN check-update-attr IN THIS-PROCEDURE(no) NO-ERROR.
end.
assign
v-loc-update-attr-obj = v-update-attr-obj
v-loc-update-attr-host = v-update-attr-host
v-loc-update-attr-gbl = v-update-attr-gbl
v-loc-update-fbr-gds = v-update-fbr-gds
v-loc-update-s-coeff = v-update-s-coeff
v-loc-update-gds-prop = v-update-gds-prop
v-loc-update-add-prop = v-update-add-prop
v-loc-update-dgr = v-update-dgr
.
if v-update-attr-obj
or v-update-attr-host
or v-update-attr-gbl
or v-update-fbr-gds
or v-update-s-coeff
or v-update-gds-prop
or v-update-add-prop
or v-update-dgr
then do:
  v-mess =    (
                       (if v-update-attr-gbl
                       then "Были изменены глобальные атрибуты товара"
                       else "":U) + {&new-line} +
                      (if v-found-copy-atr-host then " или наследуются глобальыне атрибуты товара" else "":U) + {&new-line} +
                       (if v-update-attr-host
                       then "Были изменены атрибуты товара на фирме"
                       else "":U) + {&new-line} +
                      (if v-found-copy-atr-host then " или наследуются атрибуты товара на фирме" else "":U) + {&new-line} +
                       (if v-update-attr-obj
                       then "Были изменены атрибуты товара на объекте"
                       else "":U) + {&new-line} +
                       (if v-found-copy-atr-obj then " или наследуются атрибуты товара на объекте" else "":U) + {&new-line} +
                       (if v-update-fbr-gds
                       then "Были изменены атрибуты РЕСТОРАН товара на объекте"
                       else "":U) + {&new-line} +
                       (if v-found-copy-fbr-gds then " или наследуются атрибуты РЕСТОРАН товара на объекте" else "":U) + {&new-line} +
                       (if v-update-s-coeff
                       then "Были изменены сезонные коэффициенты товара"
                       else "":U) + {&new-line} +
                       (if v-found-copy-s-coeff then " или наследуются сезонные коэффициенты товара" else "":U) + {&new-line} +
                       (if v-update-gds-prop
                       then "Были изменены индикаторы/атрибуты для заказа товара"
                       else "":U) + {&new-line} +
                       (if v-found-copy-gds-prop then " или наследуются индикаторы/атрибуты для заказа товара" else "":U) + {&new-line} +
                       (if v-update-add-prop
                       then "Были изменены Дополнительные расходы"
                       else "":U) + {&new-line} +
                       (if v-found-copy-add-prop then " или наследуются Дополнительные расходы" else "":U) + {&new-line}
                     ).
  v-mess = left-trim(v-mess, {&new-line}).
  run gbl/d-toggle.w (
                       input "Сохранение изменений"
                      ,input v-mess
                      ,input "|"
                      ,input substitute("Товар^disable|" +
                                      "Глобальные атрибуты&1|" +
                                      "Атрибуты на фирме&2|" +
                                      "Атрибуты на объекте&3|" +
                                      "Атрибуты РЕСТОРАН&4|" +
                                      "Сезонные коэффициенты&5|" +
                                      "Скидки товара на объекте&6|" +
                                      "Индикаторы товара&7|" +
                                      "Дополнительные расходы&8"
                                      , (if v-update-attr-gbl then "":U else "^disable":U)
                                      , (if v-update-attr-host then "":U else "^disable":U)
                                      , (if v-update-attr-obj then "":U else "^disable":U)
                                      , (if v-update-fbr-gds then "":U else "^disable":U)
                                      , (if v-update-s-coeff then "":U else "^disable":U)
                                      , (if v-update-dgr then "":U else "^disable":U)
                                      , (if v-update-gds-prop then "":U else "^disable":U)
                                      , (if v-update-add-prop then "":U else "^disable":U)
                              )
                      ,input ("Сохранить изменения собственно товара|" +
                              "Сохранить изменения глобальных атрибутов товара|" +
                              "Сохранить изменения атрибутов товара на фирме|" +
                              "Сохранить изменения атрибутов товара на объекте|" +
                              "Сохранить изменения атрибутов РЕСТОРАН товара на объекте|" +
                              "Сохранить изменения сезонных коэффициентов|" +
                              "Сохранить изменения скидок на товар на объекте|" +
                              "Сохранить изменения индикаторов/атрибутов для заказа товара|" +
                              "Сохранить изменения дополнительных расходов"
                              )
                      ,input substitute("&1|&2|&3|&4|&5|&6|&7|&8|&9"
                                        , yes
                                        , v-update-attr-gbl
                                        , v-update-attr-host
                                        , v-update-attr-obj
                                        , v-update-fbr-gds
                                        , v-update-s-coeff
                                        , v-update-dgr
                                        , v-update-gds-prop
                                        , v-update-add-prop
                                      )
                                      /*init*/
                      ,output choice-str) no-error .
  if choice-str = "":U then undo, return error .
  if not logical(entry(2, choice-str, "|":U))
  then v-loc-update-attr-gbl = no.
  if not logical(entry(3, choice-str, "|":U))
  then v-loc-update-attr-host = no.
  if not logical(entry(4, choice-str, "|":U))
  then v-loc-update-attr-obj = no.
  if not logical(entry(5, choice-str, "|":U))
  then v-loc-update-fbr-gds = no.
  if not logical(entry(6, choice-str, "|":U))
  then v-loc-update-s-coeff = no.
  if not logical(entry(7, choice-str, "|":U))
  then v-loc-update-dgr = no.
  if not logical(entry(8, choice-str, "|":U))
  then v-loc-update-gds-prop = no.
  if not logical(entry(9, choice-str, "|":U))
  then v-loc-update-add-prop = no.

end.
_main:
do transaction
on error undo, return error return-value
:

if logical(entry(1, choice-str, "|":U)) then do:
  run ref/goods01.p (
                input parparentproc
                ,input mode
                ,input copymode
                ,input pmode
                ,input yes /*par-manual*/
                ,input no /*par-silence*/
                ,input no /*import*/
                ,input (f-name <> "":U) /*par-file*/
                ,input one-good
                ,input v-host-code
                ,input p-obj-type
                ,input p-obj-code
                ,input igoods
                ,input (if copymode then recid(for-goods) else ?)
                ,input (if mode = {&add-def} then 0 else goods.gds-code)
                ,input frame {&frame-name} goods.artic
                ,input frame {&frame-name} ub.clients.obj-type
                ,input frame {&frame-name} ub.clients.obj-code
                ,input gds-prt.node-code
                ,input (if avail ub.gds-grp then ub.gds-grp.node-code else -1)
                ,input frame {&frame-name} ub.goods.gds-name
                ,input saved-name
                ,input frame {&frame-name} ub.goods.engl-name
                ,input frame {&frame-name} ub.goods.label-name
                ,input frame {&frame-name} ub.goods.chk-name
                ,(if not avail ub.country
                  then "XX":U
                  else input frame {&frame-name} ub.goods.alpha1
                )
                ,input frame {&frame-name} ub.goods.unit-base
                ,input frame {&frame-name} ub.goods.unit-cli
                ,INPUT FRAME {&frame-name} ub.goods.max-rate
                ,INPUT FRAME {&frame-name} ub.goods.min-rate
                ,INPUT FRAME {&frame-name} ub.goods.cli-base-rate
                ,input frame {&frame-name} ub.goods.qnty-cart
                ,input frame {&frame-name} ub.goods.ms-base
                ,input frame {&frame-name} ub.goods.wt-base
                ,input frame {&frame-name} ub.goods.ms-cart
                ,input frame {&frame-name} ub.goods.wt-cart
                ,input frame {&frame-name} goods.calc-method
                ,input frame {&frame-name} goods.increase-pc
                ,input NegRest
                ,input frame {&frame-name} for-obj-price-base
                ,input frame {&frame-name} for-obj-price-rubl
                ,input frame {&frame-name} goods.okdp
                ,input temp-goods.destin
                ,input temp-goods.attrib
                ,input temp-goods.user-rule
                ,input temp-goods.sert
                ,input temp-goods.struct
                ,input temp-goods.deadline
                ,input temp-goods.cond-keep-code
                ,input temp-goods.sort
                ,input temp-goods.proof
                ,input temp-goods.normal-wastage
                ,input temp-goods.normal-waste
                ,input temp-goods.tnved
                ,input temp-goods.nationality
                ,input temp-goods.unit-cst
                ,input temp-goods.cst-base-rate
                ,input temp-goods.fbr-grp-code
                ,input frame {&frame-name} goods.PS
                ,input unq-artc
                ,input is-jwlr
                ,input is-bttl
                ,input is-ptrl
                ,input custvalue
                ,input dif-nam1
                ,input dif-nam2
                ,input ArtDis
                ,input (if BarDis then 1 else 0)
                ,input-output gds-rec
                ,output nbc
                ) no-error .

  if error-status:error then do:
    assign
    gds-rec = if v-prev-rec <> ? and gds-rec = ?
              then v-prev-rec
              else gds-rec
    .
    CASE entry(1, return-value, {&delim-par}):
      when "unit-cli" then do:
        APPLY "ENTRY" to goods.unit-cli in frame {&frame-name}.
        undo _main, return error .
      end.
      when "min-rate":U then do:
        APPLY "ENTRY" to goods.min-rate in frame {&frame-name}.
        undo _main, return error .
      end.
      when "max-rate":U then do:
        APPLY "ENTRY" to goods.max-rate in frame {&frame-name}.
        undo _main, return error .
      end.
      when "artic|prod-type|prod-code":U then do:
        if f-name = "" then do:
          not-saved = input frame {&frame-name} goods.artic.
          Infmes = "ТОВАР " + not-saved + " НЕ СОХРАНЕН В БАЗЕ ДАННЫХ".
          undo _main, return error.
        end.
        else do:
          run gbl/d-askw.w (input "Внимание  !!",
                        input "Товар с таким артикулом и производителем УЖЕ есть в справочнике !",
                        input "|",
                        input "Перейти к СЛЕДУЮЩЕМУ|ВЫЙТИ из режима ИМПОРТА",
                        input "|",
                        input 1,
                        input 2,
                        output choice).
          if choice = 1 then g#log = YES.
          else g#log = no.
          case g#log:
            when YES then
            g#log = NOT g#log.
            when NO then
            g#log = ?.
          end case.
          if NOT g#log then do:
            not-saved = input frame {&frame-name} goods.artic.
            Infmes = "ТОВАР " + not-saved + " НЕ СОХРАНЕН В БАЗЕ ДАННЫХ".
            VIEW Infmes in frame {&frame-name}.
            DISPLAY Infmes with frame {&frame-name}.
          end.
          else  not-saved = "".
          if NOT g#log or g#log = ? then
          undo _main, return error (if not g#log then "next" else "").
        end. /*when artic|prod-type|prod-code*/
      END.
      when "artic|unq-artc":U then do:
        if NOT f-name = "" then do:
          g#log = NO.  
          return error "next".
          
        end.
        undo _main, return error.
      end.
      when "artic":U then do:
        not-saved = input frame {&frame-name} goods.artic.
        Infmes = "ТОВАР " + not-saved + " НЕ СОХРАНЕН В БАЗЕ ДАННЫХ".
        undo _main, return error.
      end.
      when "artic|next":U then do:
        not-saved = input frame {&frame-name} goods.artic.
        Infmes = "ТОВАР " + not-saved + " НЕ СОХРАНЕН В БАЗЕ ДАННЫХ".
        VIEW Infmes in frame {&frame-name}.
        DISPLAY Infmes with frame {&frame-name}.
        undo _main, return error "next":U.
      end.
      when "artic|quit":U then do:
        not-saved = "".
        return error "":U.
      end.
      otherwise do:
        undo _main, return error.
      end.
    END CASE.
  end.
end.

if mode = {&add-def} then do:
 
find first goods share-lock where recid(goods) = gds-rec .
  if not AVAILABLE goods then return no-apply.
  else do:
     if not v-loc-update-attr-gbl then 
     do:
        message "Не задан атрибут Признак предмета расчета!"
           view-as alert-box.
        undo _main, return error .                            
     end.
     else 
     do:    
        find first tt0-goods-attr no-lock where tt0-goods-attr.attr-code = {&attr-item-matter-mark} no-error .
        if not available (tt0-goods-attr) then
        do:
           message "Не задан атрибут Признак предмета расчета!"
              view-as alert-box.
           undo _main, return error .
        end.
     end.
    if temp-goods.alc-prod = yes then 
    do:
      run gds-attr-write IN THIS-PROCEDURE(
        input ub.goods.gds-code
        ,INPUT {&attr-alcohol-prod}
        ,INPUT temp-goods.alc-prod ) NO-ERROR.
      
      IF ERROR-STATUS:ERROR THEN 
      DO:
        assign
          v-err-mess = substitute("Ошибка при сохранении атрибута товара &1 &2 :&3&4 &5"
                                    , ub.goods.gds-code
                                    , {&attr-alcohol-prod}
                                    , {&new-line}
                                    ,error-status:get-message(1)
                                    ,return-value).
        undo _main, return error v-err-mess.
      END.
      if temp-goods.alc-mark = yes then do:
      run gds-attr-write IN THIS-PROCEDURE(
        input ub.goods.gds-code
        ,INPUT {&attr-mark}
        ,INPUT temp-goods.alc-mark ) NO-ERROR.
      
      IF ERROR-STATUS:ERROR THEN 
      DO:
        assign
          v-err-mess = substitute("Ошибка при сохранении атрибута товара &1 &2 :&3&4 &5"
                                    , ub.goods.gds-code
                                    , {&attr-mark}
                                    , {&new-line}
                                    ,error-status:get-message(1)
                                    ,return-value).
        undo _main, return error v-err-mess.
      END.
      end.  
        find first ub.alc-type-gds 
        where ub.alc-type-gds.gds-code = ub.goods.gds-code
        and ub.alc-type-gds.create-user-db-num = 0 EXCLUSIVE-LOCK no-error.
      if not available ub.alc-type-gds then 
      do :
        create ub.alc-type-gds.       
      end.
      else do:
        delete ub.alc-type-gds.
        create ub.alc-type-gds.     
      end.   
      assign
        ub.alc-type-gds.gds-code            = ub.goods.gds-code
        ub.alc-type-gds.alc-type-inner-code = temp-goods.alc-choose-prod
        ub.alc-type-gds.create-user-db-num  = 0
        ub.alc-type-gds.create-date = today
        .  
      end. /*if temp-goods.alc-prod = yes then */   
   end. /*else do:*/

   define variable v-value      as character no-undo .
   define variable v-type       as character no-undo .
   define buffer buf-grp for ub.gds-grp.
   define variable v-upper like  ub.gds-grp.node-code.
   find first buf-grp where buf-grp.node-code = ub.gds-grp.node-code no-lock no-error.
   do while v-value = '' and available buf-grp:
      v-upper = buf-grp.upper-code.
      run ggoattr-value(
                input buf-grp.node-code,
                input 0,
                input "",
                input 0,
                input {&ggoattr-sum-grps},
                output v-value,
                output v-type
              ) no-error.
        if v-value = '' then find first buf-grp where buf-grp.node-code = v-upper no-lock no-error.    
    /*Есть ли атрибут "Группа товаров на кассе" в группе товаров*/
         
        if v-value > "" then do:
          run gds-attr-write IN THIS-PROCEDURE(
              input ub.goods.gds-code
             ,INPUT {&attr-sum-grp-gl}
             ,INPUT v-value ) NO-ERROR.
        end. 

      run ggoattr-value(
                input buf-grp.node-code,
                input 0,
                input "",
                input 0,
                input {&ggoattr-mark-type},
                output v-value,
                output v-type
              ) no-error.
        if v-value = '' then find first buf-grp where buf-grp.node-code = v-upper no-lock no-error.    
      /*Есть ли атрибут "Группа товаров на кассе" в группе товаров*/
      if v-value > "" and v-value <> "not-type" then 
      do:
         run gds-attr-write IN THIS-PROCEDURE(
            input ub.goods.gds-code
            ,INPUT {&attr-mark-type}
            ,INPUT v-value ) NO-ERROR.

        
         for each buf_bar-code no-lock where buf_bar-code.gds-code = ub.goods.gds-code:   
            find first ub.prod-bc no-lock where ub.prod-bc.b-code = buf_bar-code.b-code and ub.prod-bc.bc-on-type = {&gtin} no-error .
            if not available (ub.prod-bc) then 
            do:
               message   "Для маркированного товара необходимо завести код с типом GTIN" 
                  view-as alert-box.
               undo _main, return error .
            end.
         end. 
      end.   
end.
end. /*if mode = {&add-def} then do:*/

if mode <> {&add-def} and mode <> {&lookup} then do:
   find first tt0-goods-attr no-lock where tt0-goods-attr.attr-code = {&attr-item-matter-mark} no-error .
   if not available (tt0-goods-attr) then
   do:
   find first ub.goods-attr no-lock where ub.goods-attr.attr-code = {&attr-item-matter-mark} no-error .
   if not available (ub.goods-attr) then do:
      message "Не задан атрибут Признак предмета расчета!"
         view-as alert-box.
      undo _main, return error .
   end.
   end.
   
find first goods share-lock where recid(goods) = gds-rec .
  if temp-goods.alc-prod <> logical (v-gds-attr-value-old) then 
  do:
    if temp-goods.alc-prod = yes then 
    do:
      run gds-attr-write IN THIS-PROCEDURE(
        input ub.goods.gds-code
        ,INPUT {&attr-alcohol-prod}
        ,INPUT temp-goods.alc-prod ) NO-ERROR.
      
      IF ERROR-STATUS:ERROR THEN 
      DO:
        assign
          v-err-mess = substitute("Ошибка при сохранении атрибута товара &1 &2 :&3&4 &5"
                                    , ub.goods.gds-code
                                    , {&attr-alcohol-prod}
                                    , {&new-line}
                                    ,error-status:get-message(1)
                                    ,return-value).

      END.

    end. /* temp-goods.alc-prod = yes */
    else   
    do: 
      RUN gds-attr-delete IN THIS-PROCEDURE (
        input ub.goods.gds-code
        ,INPUT {&attr-alcohol-prod}
        ,output v-deleted ) NO-ERROR.
      IF NOT v-deleted
        or error-status:error
        THEN 
      DO:
        assign
          v-err-mess = substitute("Ошибка при удалении атрибута товара &1 &2 :&3&4 &5"
                                  , ub.goods.gds-code
                                  , {&attr-alcohol-prod}
                                  , {&new-line}
                                  ,error-status:get-message(1)
                                  ,return-value
                                  ).

      END. /*tt0-goods-attr.attr-code*/
      find first ub.alc-type-gds 
        where ub.alc-type-gds.gds-code = goods.gds-code
        and ub.alc-type-gds.alc-type-inner-code = temp-goods.alc-choose-prod
        and ub.alc-type-gds.create-user-db-num = 0 no-error.
        if available ub.alc-type-gds then
        delete ub.alc-type-gds.
    end.   /* else */ 
  end. /* temp-goods.alc-prod <> logical (v-gds-attr-value-old) */
  if temp-goods.alc-prod = yes then 
    do:
      if temp-goods.alc-mark <> logical (v-gds-attr-mark-value-old) then do:
       
        run gds-attr-write IN THIS-PROCEDURE(
        input ub.goods.gds-code
        ,INPUT {&attr-mark}
        ,INPUT temp-goods.alc-mark ) NO-ERROR.
      
      IF ERROR-STATUS:ERROR THEN 
      DO:
        assign
          v-err-mess = substitute("Ошибка при сохранении атрибута товара &1 &2 :&3&4 &5"
                                    , ub.goods.gds-code
                                    , {&attr-mark}
                                    , {&new-line}
                                    ,error-status:get-message(1)
                                    ,return-value).

      END.

/*      else do:                                                                        */
/*        RUN gds-attr-delete IN THIS-PROCEDURE (                                       */
/*        input ub.goods.gds-code                                                       */
/*        ,INPUT {&attr-mark}                                                           */
/*        ,output v-deleted ) NO-ERROR.                                                 */
/*      IF NOT v-deleted                                                                */
/*        or error-status:error                                                         */
/*        THEN                                                                          */
/*      DO:                                                                             */
/*        assign                                                                        */
/*          v-err-mess = substitute("Ошибка при удалении атрибута товара &1 &2 :&3&4 &5"*/
/*                                  , ub.goods.gds-code                                 */
/*                                  , {&attr-mark}                                      */
/*                                  , {&new-line}                                       */
/*                                  ,error-status:get-message(1)                        */
/*                                  ,return-value                                       */
/*                                  ).                                                  */
/*                                                                                      */
/*      END. /*tt0-goods-attr.attr-code*/                                               */
/*      end.                                                                            */
      end.
        find first ub.alc-type-gds 
        where ub.alc-type-gds.gds-code = ub.goods.gds-code
        and ub.alc-type-gds.create-user-db-num = 0 EXCLUSIVE-LOCK no-error.
      if not available ub.alc-type-gds then 
      do :
        create ub.alc-type-gds.       
      end.
      else do:
        delete ub.alc-type-gds.
        create ub.alc-type-gds.     
      end.  
      assign
        ub.alc-type-gds.gds-code            = ub.goods.gds-code
        ub.alc-type-gds.alc-type-inner-code = temp-goods.alc-choose-prod
        ub.alc-type-gds.create-user-db-num  = 0
        ub.alc-type-gds.create-date = today
        .                

 end.
end.
end.
if v-loc-update-dgr then do:
/*сохраним изменения скидок*/
  run ref/disgdru1.p (
                     input mode
                    ,input ub.goods.gds-code
                    ,input p-obj-type
                    ,input p-obj-code
                    ,INPUT table tt0-dis-gds-rule
                    ) no-error .
  if error-status:error then do:
    message
    substitute("Ошибка при сохранении скидок товара на объекте:&1&2&1&3"
               , {&new-line}
               , error-status:get-message(1)
               , return-value )
    view-as alert-box
    error .
  end.
end.
if v-loc-update-attr-obj then do:
/*сохраним изменения атрибутов*/
  run ref/gdsoatr1.p (
                     input mode
                    ,input ub.goods.gds-code
                    ,input p-obj-type
                    ,input p-obj-code
                    ,INPUT table tt0-gds-obj-attr
                    ) no-error .
  if error-status:error then do:
    message
    substitute("Ошибка при сохранении атрибутов товара на объекте:&1&2&1&3"
               , {&new-line}
               , error-status:get-message(1)
               , return-value )
    view-as alert-box
    error .
  end.
end.
if v-loc-update-attr-host then do:
/*сохраним изменения атрибутов*/
  run ref/gdshatr1.p (
                     input mode
                    ,input goods.gds-code
                    ,input v-host-code
                    ,input p-obj-type
                    ,input p-obj-code
                    ,INPUT table tt0-gds-host-attr
                    ) no-error .
  if error-status:error then do:
    message
    substitute("Ошибка при сохранении атрибутов товара на фирме:&1&2&1&3"
               , {&new-line}
               , error-status:get-message(1)
               , return-value )
    view-as alert-box
    error .
  end.
end.
if v-loc-update-attr-gbl then do:
/*сохраним изменения атрибутов*/
  run ref/gds-atr1.p (
                     input mode
                    ,input goods.gds-code
                    ,INPUT table tt0-goods-attr
                    ) no-error .
  if error-status:error then do:
    message
    substitute("Ошибка при сохранении глобальных атрибутов товара на объекте:&1&2&1&3"
               , {&new-line}
               , error-status:get-message(1)
               , return-value )
    view-as alert-box
    error .
  end.
end.

if v-loc-update-fbr-gds then do:
    run ref/fgdsobj1.p (
                      input-output v-fbr-gds-obj-recid
                    , input (if available locked_fbr-gds-obj
                                then {&update}
                                else {&add-def})
                    , input no /*p-silent*/
                    , input goods.gds-code
                    , input p-obj-type
                    , input p-obj-code
                    , input integer(entry(9, v-fbr-gds-obj-template)) /*fbr-grp-code*/
                    , input entry(7, v-fbr-gds-obj-template)          /*fbr-obj-type*/
                    , input integer(entry(8, v-fbr-gds-obj-template)) /*fbr-obj-code*/
                    , input logical(entry(1, v-fbr-gds-obj-template)) /*is-cd*/
                    , input logical(entry(2, v-fbr-gds-obj-template)) /*is-menu*/
                    , input logical(entry(3, v-fbr-gds-obj-template)) /*is-modificator*/
                    , input logical(entry(4, v-fbr-gds-obj-template)) /*is-null-price*/
                    , input logical(entry(5, v-fbr-gds-obj-template)) /*is-season*/
                    , input logical(entry(6, v-fbr-gds-obj-template)) /*is-semifinished*/
                    ) no-error.
  if error-status:error then do:
    message
    substitute("Ошибка при сохранении атрибутов РЕСТОРАН товара на объекте:&1&2&1&3"
               , {&new-line}
               , error-status:get-message(1)
               , return-value )
    view-as alert-box
    error .
  end.
end.
if v-loc-update-s-coeff then do:
/*сохраним изменения атрибутов*/
  run ref/s-coeff1.p (
                     input mode
                    ,input goods.gds-code
                    ,input v-host-code
                    ,input p-obj-type
                    ,input p-obj-code
                    ,INPUT table tt0-s-coeff
                    ) no-error .
  if error-status:error then do:
    message
    substitute("Ошибка при сохранении сезонных коэффициентов товара:&1&2&1&3"
               , {&new-line}
               , error-status:get-message(1)
               , return-value )
    view-as alert-box
    error .
  end.
end.
if v-loc-update-gds-prop then do:
    find first ttf-gds-obj-prop no-error .
    if available ttf-gds-obj-prop then do:
    run ref/gds-ind1.p
        (input-output v-gds-prop-recid
        ,input goods.gds-code
        ,input ttf-gds-obj-prop.obj-type
        ,input ttf-gds-obj-prop.obj-code
        ,input ttf-gds-obj-prop.gdop-igt
        ,input ttf-gds-obj-prop.gdop-assort-min
        ,input ttf-gds-obj-prop.gdop-min-stock
        ,input ttf-gds-obj-prop.grop-level-always-presence
        ,input ttf-gds-obj-prop.grop-max-stock
        ,input ttf-gds-obj-prop.grop-min-order
        ,input table ttf-gds-obj-prop-attr
        ) no-error .
    end.
    find first tt0-gds-obj-prop no-error .
    if available tt0-gds-obj-prop then do:
    run ref/gds-ind1.p
        (input-output v-gds-prop-recid
        ,input goods.gds-code
        ,input tt0-gds-obj-prop.obj-type
        ,input tt0-gds-obj-prop.obj-code
        ,input tt0-gds-obj-prop.gdop-igt
        ,input tt0-gds-obj-prop.gdop-assort-min
        ,input ?
        ,input ?
        ,input ?
        ,input ?
        ,input table tt0-gds-obj-prop-attr
        ) no-error .
        if error-status:error then do:
          message
          substitute("Ошибка при сохранении индикаторов/атрибутов для заказа товара на объекте:&1&2&1&3"
                    , {&new-line}
                    , error-status:get-message(1)
                    , return-value )
          view-as alert-box
          error .
        end.
    end.

    find first ttj-gds-obj-prop no-error .
    if available ttj-gds-obj-prop then do:
    run ref/gds-ind1.p
        (input-output v-gds-prop-recid
        ,input goods.gds-code
        ,input ttJ-gds-obj-prop.obj-type
        ,input ttj-gds-obj-prop.obj-code
        ,input ?
        ,input ?
        ,input ttj-gds-obj-prop.gdop-min-stock
        ,input ttj-gds-obj-prop.grop-level-always-presence
        ,input ttj-gds-obj-prop.grop-max-stock
        ,input ttj-gds-obj-prop.grop-min-order
        ,input table ttj-gds-obj-prop-attr
        ) no-error .
        if error-status:error then do:
          message
          substitute("Ошибка при сохранении параметров заказа товара на объекте:&1&2&1&3"
                    , {&new-line}
                    , error-status:get-message(1)
                    , return-value )
          view-as alert-box
          error .
        end.
      end.
end.

if v-loc-update-add-prop then do:
    find first tt0-gds-add-charges no-error .
    if error-status :error then message error-status :get-message(1) .
    run ref/adcharg1.p
        (input-output v-add-prop-recid
        ,input goods.gds-code
        ,input tt0-gds-add-charges.algoritm
        ,input tt0-gds-add-charges.cost-include
        ) no-error .

  if error-status:error then do:
    message
    substitute("Ошибка при сохранении дополнительных расходов :&1&2&1&3"
               , {&new-line}
               , error-status:get-message(1)
               , return-value )
    view-as alert-box
    error .
  end.
end.

if mode = {&add-def} then do:
  AvtArt = nbc .
  DISPLAY string( AvtArt ) @ goods.artic with frame {&frame-name} .
  find first goods share-lock where
             recid(goods) = gds-rec .
  assign
  copymode = no
  saved-name = goods.gds-name
  Infmes = "Товар " + string(goods.artic) + " сохранен  - "  + string(goods.gds-code, "99999999999")
  impc-saved = impc-saved + 1
  nbc = 0
  .
end.
assign
temp-goods.cst-base-rate = goods.cst-base-rate
.

END PROCEDURE.

PROCEDURE disable_UI :
  HIDE FRAME d-gds-form.
END PROCEDURE.

PROCEDURE enable-UI :
define variable i-find as logical no-undo .
define variable ii as integer no-undo .
{ gbl/conf-rd.i
"'is-prt'"
0
"''"
0
"''"
"''"
"''"
no
conf-par
par-type
no-error
}
is-prt = (IF error-status:error or conf-par <> "yes" then no else yes).
{ gbl/objat.i p-obj-type p-obj-code 'doc-prt=request':U v-doc-prt no-error }

{ gbl/conf-rd.i
"'is-jwlr'"
"''"
"''"
0
"''"
"''"
"''"
no
conf-par
par-type
no-error
}
assign
is-jwlr = (conf-par = "yes":U) no-error
.

{ gbl/conf-rd.i
"'is-bttl'"
"''"
"''"
0
"''"
"''"
"''"
no
conf-par
par-type
no-error
}
assign
is-bttl = (conf-par = "yes":U) no-error
.
{ gbl/conf-rd.i
"'is-ptrl'"
"''"
"''"
0
"''"
"''"
"''"
no
conf-par
par-type
no-error
}
assign
is-ptrl = (conf-par = "yes":U) no-error
.
HIDE
frame {&frame-name} name-uchet-base
frame {&frame-name} name-uchet-rubl
frame {&frame-name} for-obj-price-base
frame {&frame-name} for-obj-last-base
frame {&frame-name} for-obj-price-rubl
frame {&frame-name} for-obj-last-rubl
frame {&frame-name} b-extart
in frame {&frame-name}.
CASE mode :
  when {&add-def} then do:
    if not copymode then do:
      find first temp-goods no-error.
      if not available temp-goods then do:
       create temp-goods.
      end.
    end.
    ENABLE
    b-exit
    b-arch WHEN not dif-nam2 /*если не включена настройка отслеживания изменения имени
                                                                            при вводе ДОПБК*/
    b-inf when not igoods
    /*b-price*/
    b-rest
    b-chk
    b-prt
    b-file when igoods
    b-help
    add-inf
    b-tax
    br-tt-tax
    ArtBar
    b-copy-name-to-lbl
    with frame {&frame-name}.
    assign
    b-card:label = "След.->"
    menu-item m-dopinf-2:sensitive in menu m-dopinf = no
    /*
    menu-item m-dopinf-3:sensitive in menu m-dopinf = no
    menu-item m-dopinf-4:sensitive in menu m-dopinf = no
    menu-item m-dopinf-5:sensitive in menu m-dopinf = no
    menu-item m-dopinf-6:sensitive in menu m-dopinf = no
    menu-item m-dopinf-7:sensitive in menu m-dopinf = no
    menu-item m-dopinf-8:sensitive in menu m-dopinf = no
    */

    .
    HIDE
    b-altcd
    b-prodbc
    ub.bar-code.b-code
    b-parts
    b-place
    b-recipe
    b-hist
    in frame {&frame-name}.
    if copymode and f-name = "" then do:
      run ref/dtaxgdss.p (
                       input no
                      ,input for-goods.unit-base
                      ,input for-goods.grp-code
                      ,input  ?
                      ,input recid(for-goods)
                      ,input v-host-code
                      ,input p-obj-type
                      ,input p-obj-code
                      ) no-error.
      if error-status:error then return error.
      run enable-max-min in this-procedure ( input for-goods.unit-base) no-error.
      if error-status:error then return no-apply.
          OPEN QUERY br-tt-tax for each tt-tax NO-LOCK.
      FIND FIRST ub.country where ub.country.alpha1 = for-goods.alpha1 No-LOCK No-ERROR.
      assign
      ub.goods.PS:screen-value = temp-goods.ps
      ub.goods.calc-method:screen-value = string(temp-goods.calc-method)
      FirstIter = no
      NegRest = if (temp-goods.negative-rest) then var-negative-rest else FALSE
      .
      if temp-goods.fbr-grp-code <> ? then do:
        find first buf_fbr-gds-grp no-lock where
                buf_fbr-gds-grp.obj-type = "":U
            AND buf_fbr-gds-grp.obj-code = 0
            AND buf_fbr-gds-grp.node-code = temp-goods.fbr-grp-code no-error .
        if available buf_fbr-gds-grp then
        assign
        fbr-grp-code_ = buf_fbr-gds-grp.node-code
        f-fbr-grp-name = buf_fbr-gds-grp.node-name
        .
      end.
      display
      temp-goods.gds-name @ goods.gds-name
      temp-goods.prod-type @ ub.clients.obj-type
      temp-goods.prod-code @ ub.clients.obj-code
      ub.clients.obj-name
      temp-goods.unit-base @ ub.goods.unit-base
      temp-goods.okdp @ ub.goods.okdp
      temp-goods.engl-name @  ub.goods.engl-name
      temp-goods.label-name @  ub.goods.label-name
      temp-goods.chk-name @  ub.goods.chk-name
      temp-goods.alpha1 @  ub.goods.alpha1
      (if length(temp-goods.grp-name) > 79 then
          ("..." + substr(temp-goods.grp-name, length(temp-goods.grp-name) - 79)) else
          temp-goods.grp-name) @  grp-full
      ub.gds-prt.node-name
      temp-goods.qnty-cart     @ goods.qnty-cart
      temp-goods.unit-cli      @ goods.unit-cli
      temp-goods.ms-base       @ goods.ms-base
      temp-goods.wt-base       @ goods.wt-base
      temp-goods.ms-cart       @ goods.ms-cart
      temp-goods.wt-cart       @ goods.wt-cart
      temp-goods.cli-base-rate @ goods.cli-base-rate
      temp-goods.increase-pc   @ goods.increase-pc
      if avail country then country.short-name else "" @ country_name
      f-fbr-grp-name
      with frame {&frame-name}.
      IF temp-goods.min-rate <> 0 then
      DISPLAY
      temp-goods.min-rate @ goods.min-rate
      with frame {&frame-name}.
      IF temp-goods.max-rate <> 0 then
      DISPLAY
      temp-goods.max-rate @ goods.max-rate
      with frame {&frame-name}.
    end.
    if FirstIter
      then
    assign
    FirstIter = FALSE
    CostEntered = FALSE
    InpSelf = FALSE
    NegRest = if igoods then var-negative-rest else FALSE .
      else
    assign
    CostEntered = FALSE
    InpSelf = FALSE
    avrg-rate = 1
    .
    if ArtDis
      then
    ArtBar:FGCOLOR = 10 .
      else
    ArtBar:FGCOLOR = 0 .
    DISPLAY ArtBar NegRest      with frame {&frame-name}.
    run val-chg-ArtBar in this-procedure .
    if f-name = "" then do:
     DISPLAY "" @ goods.artic with frame {&frame-name}.
    end.
    else do:
      DISPLAY ImpMes with frame {&frame-name}.
      assign
      i-artic = ";;;"
      i-find = no
      .  /* для первого входа в цикл */
      _i-artic:
      DO WHILE i-artic = ";;;" or i-find:
        run next-good no-error.
        if error-status:error then return.
        i-find =  can-find (goods where
                        goods.artic = i-artic AND
                        goods.prod-type = input frame {&frame-name} clients.obj-type AND
                        goods.prod-code = input frame {&frame-name} clients.obj-code no-lock).

        if i-find then next _i-artic.
      END.
      /* если авт. артикул включен, импортируемый артикул будет забит автоматическим */
      if ArtDis then do:
        message "Для импорта требуется, чтобы автоматичекий артикул был выключен.".
        return.
      end.
      RUN next-good-display in this-procedure .
    end.
    if available ub.gds-grp then do:
      grp-full = "".
      RUN grplib-get-full-name in this-procedure (input gds-grp.node-code, output grp-full).
      if length(grp-full) > 79
        then
      assign
      grp-full = "..." + substr(grp-full, length(grp-full) - 79).
      DISPLAY grp-full with frame {&frame-name}.
    end.
    if NOT igoods and NOT available clients
      then
    FIND clients WHERE
         clients.obj-type = {&cmp} and
         clients.obj-code = v-host-code no-error.
    if available clients
      then
    DISPLAY clients.obj-type clients.obj-code clients.obj-name with frame {&frame-name}.
      else
    DISPLAY {&cmp} @ clients.obj-type with frame {&frame-name}.
    if available gds-prt
      then
    DISPLAY gds-prt.node-name with frame {&frame-name}.
    if ArtDis
      then
    DISABLE goods.artic with frame {&frame-name}.
      else
    ENABLE goods.artic with frame {&frame-name}.
    ENABLE
    goods.okdp clients.obj-type clients.obj-code r-prod b-altbc
    goods.gds-name goods.engl-name goods.label-name goods.chk-name
    goods.alpha1
    goods.unit-base
    r-base goods.unit-cli r-supp goods.cli-base-rate r-alpha1 r-fbr-grp
    goods.qnty-cart goods.ms-base goods.ms-cart
    goods.wt-base goods.wt-cart goods.PS
    NegRest
    goods.calc-method
    goods.increase-pc
    label-increase-pc
    label-min-rate
    label-max-rate
    with frame {&frame-name}.
    if f-name = "" then do:
      run str/pr-listv.p (
                      input {&pr-calc-methods-list}
                    , {&pr-calc-grp}
                    , output p-list) .
      goods.calc-method:list-items in frame {&frame-name}  = p-list .
    end.
    if f-name = "" then
    assign
    goods.calc-method:screen-value = {&pr-calc-grp}.
     if not g#log and f-name = "" then do:
       goods.increase-pc:screen-value = string(0).
     end.
     APPLY "Value-changed" to goods.calc-method in frame {&frame-name}.
     if f-name <> "" then do:
       assign
       ArtBar:List-Items = If v-cntxt-db-num = 0
                           then (vArtBar-off + {&comma-char} + vArtBar-BarCOde)
                           else vArtBar-off
       .
       ENABLE b-card with frame {&frame-name}.
     end.
     else
     ArtBar:List-Items = If v-cntxt-db-num = 0
                         then (vArtBar-off + {&comma-char} + vArtBar-Auto + {&comma-char} + vArtBar-BarCode)
                         else (vArtBar-off + {&comma-char} + vArtBar-Auto)
     .
     DISPLAY ArtBar With FRAME {&frame-name}.
     run val-chg-ArtBar.
     assign
     b-exit:label = "&Ввод "
     b-arch:label = "Со&хр"
     b-altbc:label = "С+&Коды"
     b-rest:label = "&Отмена"
     b-chk:label = "&Группа"
     b-file:label = "&Импорт" .
     if copymode then do:
        if igoods then
        frame {&frame-name}:title = "КОПИЯ ТОВАРA " +
        string(for-goods.artic) + " " + for-goods.gds-name + " " + title-mode(mode).
        else
        frame {&frame-name}:title = "КОПИЯ УСЛУГИ " +
        string(for-goods.artic) + " " + for-goods.gds-name + " " + title-mode(mode).
     end.
     else do:
      if igoods
        then
      frame {&frame-name}:title = "Т О В А Р" + fill({&space-char}, 35) + title-mode(mode).
      else do:
            frame {&frame-name}:title = "У С Л У Г А" + fill({&space-char}, 34 ) + title-mode(mode).
            HIDE NegRest    in frame {&frame-name}.
      end.
    end.
    if dfltggrp >= 0 and
    (f-name = ""
      OR
      (f-name <> "":U and  impc = 1)
    )
    then do:
      FIND gds-grp WHERE gds-grp.node-code = dfltggrp NO-LOCK No-ERROR.
      if avail gds-grp then do:
        RUN grplib-get-full-name in this-procedure(input gds-grp.node-code, output grp-full).
        DISPLAY
        (if length(grp-full) > 79
        then
        ("..." + substr(grp-full, length(grp-full) - 79))
        else
        grp-full) @ grp-full
        with frame {&frame-name}.
      end.
      else do:
        message
        "Неверное значение настроечного параметра Код группы товаров по умолчанию (при создании нового товара)" skip
        "Нет группы товара с node-code=" dfltggrp
        "Обратитесь к администратору системы"
        view-as alert-box Warning.
        display
        "":U @ grp-full
        with frame {&frame-name}.
      end.
    end.
  end. /*when {&add-def}*/
  when {&update} then do:
    run str/pr-listv.p (
                     input {&pr-calc-methods-list}
                   , goods.calc-method
                   , output p-list) .
    goods.calc-method:list-items in frame {&frame-name}  = p-list .
    run ref/dtaxgdss.p (
                  input no
                 ,input goods.unit-base
                 ,input goods.grp-code
                 ,input gds-rec
                 ,input gds-rec
                 ,input v-host-code
                 ,input p-obj-type
                 ,input p-obj-code
                  ) no-error.
    if error-status:error then return error.
    run enable-max-min(goods.unit-base) no-error.
    if error-status:error then return no-apply.
    OPEN QUERY br-tt-tax for each tt-tax NO-LOCK.
    find first temp-goods no-error.
    if not available temp-goods then do:
      create temp-goods.
    end.

    buffer-copy goods to temp-goods.
    FIND clients WHERE
         clients.obj-type = goods.prod-type AND
         clients.obj-code = goods.prod-code NO-LOCK.
    FIND gds-prt WHERE gds-prt.upper-code = goods.prt-root NO-LOCK.
    /*
    { gbl/gdscr.i p-obj-type p-obj-code goods.artic goods.prod-type goods.prod-code gds-prt.node-code ub.gds-obj ub.prt-obj }
    */
    FIND FIRST ub.gds-obj share-lock WHERE
               ub.gds-obj.obj-type = p-obj-type AND
               ub.gds-obj.obj-code = p-obj-code AND
               ub.gds-obj.artic = ub.goods.artic AND
               ub.gds-obj.prod-type = ub.goods.prod-type AND
               ub.gds-obj.prod-code = ub.goods.prod-code NO-ERROR.

    FIND FIRST ub.bar-code WHERE
         ub.bar-code.gds-code  = ub.goods.gds-code AND
         ub.bar-code.node-code = ub.gds-prt.node-code AND
         ub.bar-code.in-code = "" AND
         ub.bar-code.part-code = ""  AND
        ub.bar-code.unit-cli = ub.goods.unit-base NO-LOCK NO-ERROR.
    IF ERROR-status:error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найден главный код для товара " ub.goods.artic ub.goods.prod-type string(goods.prod-code)
      view-as alert-box ERROR.
      return error.
    end.
    FIND gds-grp WHERE gds-grp.node-code = ub.goods.grp-code NO-LOCK.
    FIND country WHERE country.alpha1 = ub.goods.alpha1 No-LOCK NO-ERROR.
    if ub.goods.fbr-grp-code <> ? then do:
      find first buf_fbr-gds-grp no-lock where
                buf_fbr-gds-grp.obj-type = "":U
            AND buf_fbr-gds-grp.obj-code = 0
            AND buf_fbr-gds-grp.node-code = ub.goods.fbr-grp-code no-error .
        if available buf_fbr-gds-grp then
        assign
        fbr-grp-code_ = buf_fbr-gds-grp.node-code
        f-fbr-grp-name = buf_fbr-gds-grp.node-name
        .
    end.
    assign
    b-exit:label = "&Ввод"
    b-rest:label = "&Отмена"
    b-chk:label = "&Группа"
    NegRest = ub.goods.negative-rest
    main-code = bar-code.b-code
    .
    DISPLAY
    (if length(goods.grp-name) > 79
       then ("..." + substr(goods.grp-name, length(goods.grp-name) - 79))
       else  ub.goods.grp-name)
    @ grp-full
    ub.goods.artic ub.goods.okdp bar-code.b-code gds-prt.node-name
    clients.obj-type clients.obj-code clients.obj-name
    ub.goods.gds-name ub.goods.engl-name ub.goods.label-name ub.goods.chk-name
    ub.goods.alpha1
    ub.goods.unit-base ub.goods.unit-cli ub.goods.cli-base-rate
    ub.goods.calc-method ub.goods.increase-pc ub.goods.qnty-cart ub.goods.ms-base ub.goods.ms-cart label-increase-pc
    label-min-rate
    label-max-rate
    ub.goods.wt-base
    ub.goods.wt-cart ub.goods.PS
    NegRest
    (if avail country
      then country.short-name
      else "")
      @ country_name
    ub.goods.min-rate when ub.goods.min-rate <> 0
    ub.goods.max-rate when ub.goods.max-rate <> 0
    f-fbr-grp-name
    with frame {&frame-name}.
    HIDE
    b-arch b-rest b-card b-parts b-place
    b-inf r-base r-prod b-file
    ArtBar in frame {&frame-name}.
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_reference_calc-increase':U
      {&cntxt-global}
      0
      '':U
      0
      0
      ub.goods.grp-code
      0
      false
      g#log
    }
    assign
    menu-item m-dopinf-6:sensitive in menu m-dopinf = (fbrvalue = "yes")
    menu-item m-dopinf-7:sensitive in menu m-dopinf = (fbrvalue = "yes")
    .
    ENABLE
    b-exit
    b-altbc
    b-altcd
    b-prodbc
    /*b-price*/
    b-chk
    b-prt
    b-help
    add-inf
    b-recipe
    b-rest
    b-sert
    b-hist
    ub.goods.okdp
    ub.goods.gds-name
    ub.goods.engl-name
    ub.goods.label-name
    ub.goods.chk-name
    ub.goods.unit-cli
    ub.goods.alpha1
    r-supp
    r-fbr-grp
    ub.goods.cli-base-rate
    r-alpha1
    ub.goods.qnty-cart
    ub.goods.ms-base
    ub.goods.wt-base
    ub.goods.ms-cart
    ub.goods.wt-cart
    ub.goods.PS
    br-tt-tax
    b-tax
    NegRest
    ub.goods.calc-method when g#log
    ub.goods.increase-pc when g#log
    label-increase-pc
    label-min-rate
    label-max-rate
    b-copy-name-to-lbl
    ub.goods.min-rate when ub.goods.min-rate <> 0
    ub.goods.max-rate when ub.goods.max-rate <> 0
    with frame {&frame-name}.
    IF ub.goods.gds-type = {&gds-goods} then do: /*у нас товар!!*/
      frame {&frame-name}:title = "Т О В А Р".
    end.
    else do:
      frame {&frame-name}:title = "У С Л У Г А".
      /*найдем права на просмотр учетных цен*/
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
      if g#log then do:
        HIDE
        ub.goods.min-rate
        ub.goods.max-rate
        ub.goods.qnty-cart
        ub.goods.ms-base
        ub.goods.wt-base
        ub.goods.ms-cart
        ub.goods.wt-cart
        ub.goods.calc-method
        ub.goods.increase-pc
        label-increase-pc
        label-min-rate
        label-max-rate
        RECT-2
        RECT-3
        RECT-4
        in frame {&frame-name}.
        ENABLE
        for-obj-price-base
        for-obj-price-rubl
        WITH frame {&frame-name}.
        DISPLAY
        name-uchet-base
        name-uchet-rubl
        (if avail gds-obj then gds-obj.price-base else ?) @ for-obj-price-base
        (if avail gds-obj then gds-obj.price-rubl else ?) @ for-obj-price-rubl
        WITH frame {&frame-name}.
      end.
    END.
   APPLY "Value-changed" to ub.goods.calc-method in frame {&frame-name}.
   if ub.goods.stts = 1
   then frame {&frame-name}:title = frame {&frame-name}:title + "      {&status} :  УДАЛЕН".
   frame {&frame-name}:title = frame {&frame-name}:title + fill({&space-char}, 34) + title-mode(mode).
  end.
  when {&lookup} then do:
    display
      b-extart
    with frame {&frame-name}.
    ENABLE
    b-exit b-arch b-altbc b-altcd b-prodbc b-price b-rest
    b-card b-chk b-prt b-parts b-place b-hist b-inf
    b-recipe b-sert b-help add-inf
    b-gdsfrmfi
    b-tax b-next b-prev
    b-extart
    with frame {&frame-name}.
    FIND ub.goods WHERE recid (goods) = gds-rec NO-LOCK.
    find first temp-goods no-error.
    if not available temp-goods then do:
      create temp-goods.
    end.
    buffer-copy ub.goods to temp-goods.
    run str/pr-listv.p (
                     input {&pr-calc-methods-list}
                   , ub.goods.calc-method
                   , output p-list) .
    ub.goods.calc-method:list-items in frame {&frame-name}  = p-list .
    run ref/dtaxgdss.p (
                   input no
                  ,input ub.goods.unit-base
                  ,input ub.goods.grp-code
                  ,input gds-rec
                  ,input gds-rec
                  ,input v-host-code
                  ,input p-obj-type
                  ,input p-obj-code
                   ) no-error.
    if error-status:error then return error.
    assign
    tt-tax.rate-code:read-only in browse br-tt-tax = true.
    OPEN QUERY br-tt-tax for each tt-tax NO-LOCK.
    FIND FIRST gds-obj WHERE
               gds-obj.obj-type = p-obj-type AND
               gds-obj.obj-code = p-obj-code AND
               gds-obj.artic = ub.goods.artic AND
               gds-obj.prod-type = ub.goods.prod-type AND
               gds-obj.prod-code = ub.goods.prod-code
            NO-LOCK NO-ERROR .
    FIND FIRST clients WHERE
               clients.obj-type = ub.goods.prod-type AND
               clients.obj-code = ub.goods.prod-code NO-LOCK.
    FIND FIRST gds-prt WHERE
               gds-prt.upper-code = ub.goods.prt-root NO-LOCK.
    FIND FIRST bar-code WHERE
               bar-code.gds-code = ub.goods.gds-code AND
               bar-code.node-code = gds-prt.node-code AND
               bar-code.in-code = "" AND
               bar-code.part-code = "" AND
               bar-code.unit-cli = ub.goods.unit-base NO-LOCK NO-error.
    IF ERROR-status:error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найден главный код для товара " ub.goods.artic ub.goods.prod-type string(goods.prod-code)
      view-as alert-box error.
      return error.
    end.

    FIND FIRST country where
               country.alpha1 = ub.goods.alpha1 NO-LOCK No-ERROR.
    if ub.goods.fbr-grp-code <> ? then do:
      find first buf_fbr-gds-grp no-lock where
                buf_fbr-gds-grp.obj-type = "":U
            AND buf_fbr-gds-grp.obj-code = 0
            AND buf_fbr-gds-grp.node-code = ub.goods.fbr-grp-code no-error .
      if available buf_Fbr-gds-grp then
      assign
      fbr-grp-code_ = buf_fbr-gds-grp.node-code
      f-fbr-grp-name = buf_fbr-gds-grp.node-name
      .
    end.
    HIDE
    r-base r-supp r-prod r-alpha1 r-fbr-grp b-file
    ArtBar in frame {&frame-name}.
    NegRest = ub.goods.negative-rest .
    main-code = bar-code.b-code.
    assign
    menu-item m-dopinf-6:sensitive in menu m-dopinf = (fbrvalue = "yes")
    menu-item m-dopinf-7:sensitive in menu m-dopinf = (fbrvalue = "yes")
    .
    DISPLAY
    (if length(goods.grp-name) > 79
      then ("..." + substr(goods.grp-name, length(goods.grp-name) - 79))
      else ub.goods.grp-name)
      @ grp-full
    if avail country
      then country.short-name
      else "" @ country_name
    ub.goods.artic ub.goods.okdp bar-code.b-code clients.obj-type clients.obj-code
    clients.obj-name ub.goods.gds-name ub.goods.engl-name ub.goods.label-name ub.goods.chk-name
    ub.goods.unit-base ub.goods.unit-cli ub.goods.cli-base-rate ub.goods.alpha1
    ub.goods.calc-method ub.goods.increase-pc ub.goods.qnty-cart ub.goods.ms-base ub.goods.ms-cart label-increase-pc
    label-min-rate
    label-max-rate
    ub.goods.wt-base
    ub.goods.wt-cart ub.goods.PS NegRest
    ub.goods.min-rate when ub.goods.min-rate <> 0
    ub.goods.max-rate when ub.goods.max-rate <> 0
    f-fbr-grp-name
    with frame {&frame-name}.

    if gds-prt.node-name <> {&empty-scale}
    then
    DISPLAY gds-prt.node-name with frame {&frame-name}.
    if ub.goods.PS = ""
    then
    disable ub.goods.PS with frame {&frame-name}.
    if ub.goods.gds-type = {&gds-goods}
      then
    frame {&frame-name}:title = "Т О В А Р".
      else
    frame {&frame-name}:title = "У С Л У Г А".
    if ub.goods.stts = 1
      then
    frame {&frame-name}:title = frame {&frame-name}:title + "      {&status} :  УДАЛЕН".
    frame {&frame-name}:title = frame {&frame-name}:title + fill({&space-char}, 34) + title-mode(mode).
    APPLY "Value-changed" to ub.goods.calc-method in frame {&frame-name}.
  end.
end CASE .

/* Определение алкогольных атрибутов */       
  RUN gds-attr-value (
    INPUT temp-goods.gds-code,
    INPUT {&attr-alcohol-prod},
    OUTPUT v-gds-attr-value-old,
    OUTPUT v-gds-attr-type
    ).
    
     if v-gds-attr-value-old = "yes" then do:
     RUN gds-attr-value (
        INPUT temp-goods.gds-code,
        INPUT {&attr-mark},
        OUTPUT v-gds-attr-mark-value-old,
        OUTPUT v-gds-attr-type
        ).
     find first ub.alc-type-gds no-lock
     where ub.alc-type-gds.gds-code = temp-goods.gds-code and
     ub.alc-type-gds.create-user-db-num = 0 no-error. 
     if not AVAILABLE ub.alc-type-gds then do:
     assign
        temp-goods.alc-prod = no
        temp-goods.alc-mark = no 
        .  
     end.
     else   
     assign
        temp-goods.alc-choose-prod = ub.alc-type-gds.alc-type-inner-code
        temp-goods.alc-prod = yes
        .
     if v-gds-attr-mark-value-old = "yes" then temp-goods.alc-mark = yes .
     end. /*v-gds-attr-value-old = yes*/   

END PROCEDURE.

PROCEDURE copy-name-to-lbl:
   if mode = {&add-def} and ub.goods.label-name:screen-value IN FRAME {&frame-name} = ""
   or self:name = "b-copy-name-to-lbl"
   then
  DISPLAY ub.goods.gds-name:screen-value @ ub.goods.label-name with frame {&frame-name}.
  if mode = {&add-def} and ub.goods.chk-name:screen-value IN FRAME {&frame-name} = ""
  or self:name = "b-copy-name-to-lbl"
  then
  DISPLAY replace(replace(goods.gds-name:screen-value, chr(39), ""), '"', "") @ ub.goods.chk-name with frame {&frame-name}.
END.

PROCEDURE start-import:
    if ArtBar = vArtBar-Auto then
    assign
    ArtBar = vArtBar-Off.
    run val-chg-ArtBar.
    DiSPLAY ArtBar WITH FRAME {&Frame-name}.
    if NOT f-name = "" then do:
        message ("Импорт из файла " + f-name + " закончен" + {&new-line} + "прочитано " + string(impc) +
                         ",  сохранено " + string(impc-saved) )
                         view-as alert-box INFORMATION.
        assign
        f-name = ""
        not-saved = ''.
        display "" @ ub.goods.artic with frame {&frame-name}.
        DISABLE b-card WITH frame {&frame-name}.
    end.
    run ref/strtimp.w (
                           input parparentproc
                          ,input no
                          ,input vattaxcd
                          ,input slttaxcd
                          ,input custvalue
                          ,input tnvedimp
                          ,output f-name
                          ,output choice
                          ,output p-artic
                          ,output p-prod
                          ,OUTPUT p-name
                          ,OUTPUT p-engl-name
                          ,OUTPUT p-unit-base
                          ,OUTPUT p-VAT-code
                          ,OUTPUT p-SLT-code
                          ,OUTPUT p-struct
                          ,OUTPUT p-tnved
                          ,OUTPUT p-attrib
                          ,OUTPUT p-destin
                          ,OUTPUT p-sert
                          ,OUTPUT p-user-rule
                          ,OUTPUT p-alpha1
                          ,OUTPUT p-grp-code
                          ,OUTPUT p-service
                          ,OUTPUT p-gds-code
                          ,OUTPUT p-mark
                          ) no-error.
    if  error-status:error or f-name = "" then return error.
    CASE choice:
        WHEN 1 then do:
            input stream gds-file from value (f-name) convert source "1251".
        END.
        WHEN 2 then do:
            input stream gds-file from value (f-name) convert source "KOI8-R".
        END.
    END CASE.
    assign
    add-another = yes
    impc = 0
    impc-saved = 0.
    apply "go" to frame {&frame-name}.
END.


PROCEDURE next-good:
  
  assign
  v-flag-attr-obj-entry   = no
  v-flag-attr-host-entry  = no
  v-flag-fbr-gds-entry    = no
  v-flag-s-coeff-entry    = no
  v-flag-gds-prop-entry   = no
  v-flag-add-prop-entry   = no
  v-update-attr-obj       = no
  v-update-attr-host      = no
  v-update-fbr-gds        = no
  v-update-s-coeff        = no
  v-update-gds-prop       = no
  v-update-add-prop       = no
  v-found-copy-atr-obj    = no
  v-found-copy-atr-host   = no
  v-found-copy-fbr-gds    = no
  v-found-copy-s-coeff    = no
  v-found-copy-gds-prop   = no
  v-found-copy-add-prop   = no
  .
    i-artic = "".
    if g#log = ? then do:
        input stream gds-file close.
    end.
    else DO on endkey undo, leave on error undo, leave:
        run ref/nxtgdsi.p (   input vattaxcd
                             ,input slttaxcd
                             ,input custvalue
                             ,input p-artic
                             ,input p-prod
                             ,input p-name
                             ,input p-engl-name
                             ,input p-unit-base
                             ,input p-VAT-code
                             ,input p-SLT-code
                             ,input p-struct
                             ,input p-tnved
                             ,input p-attrib
                             ,input p-destin
                             ,input p-sert
                             ,input p-user-rule
                             ,input p-alpha1
                             ,input p-grp-code
                             ,input p-service
                             ,input p-gds-code
                             ,p-mark
                             ,input (impc + 1)
                             ,input-output i-artic
                             ,input-output i-prod-type
                             ,input-output i-prod-code
                             ,input-output i-gds-name
                             ,input-output i-engl-name
                             ,input-output i-unit-base
                             ,input-output i-VAT-code
                             ,input-output i-SLT-code
                             ,input-output i-struct
                             ,input-output i-tnved
                             ,input-output i-attrib
                             ,input-output i-destin
                             ,input-output i-sert
                             ,input-output i-user-rule
                             ,input-output i-alpha1
                             ,input-output i-grp-code
                             ,input-output i-service
                             ,input-output i-gds-code
                             ,input-output i-mark
                              ) .
        assign
        impc = impc + 1
        ImpMes = "ИМПОРТ " + string (impc , "99999")
        InfMes = "".
        Display ImpMes with frame {&frame-name}.
   END.
   IF ERROR-STATUS:ERROR OR g#log = ? THEN do:
     message ("Импорт из файла " + f-name + " закончен" + {&new-line} + "прочитано " + string(impc) +
                      ",  сохранено " + string(impc-saved) )
     view-as alert-box  INFORMATION.
     display "" @ ub.goods.artic with frame {&frame-name}.
     assign f-name = ""
     impc = 0
     impc-saved = 0
     ImpMes = "ИМПОРТ"
     not-saved = ""
     ArtBar:List-items = if v-cntxt-db-num = 0
                                    then (vArtBar-off + {&comma-char} + vArtBar-Auto + {&comma-char} + vArtBar-BarCode)
                                    else (vArtBar-off + {&comma-char} + vArtBar-Auto)
     .
     DISPLAY ArtBar With FRAME {&frame-name}.
     DISABLE b-card with frame {&frame-name}.
     Hide ImpMes in frame {&frame-name}.
     run val-chg-ArtBar.
     return error.
  END. /*ERROR-STATUS:ERROR OR g#log = ?*/
END. /*PROCEDURE*/


PROCEDURE val-chg-ArtBAr:
    Assign frame {&frame-name} ArtBar.
    Case ArtBar:
    When vArtBar-Auto then  do:
            assign
                ArtDis = yes
                BarDis = no
                ub.goods.artic:BGCOLOR in frame {&frame-name} = 8
                ArtBar:FGCOLOR = 10
                AvtArt = nbc
                .
            DISPLAY
                ( if AvtArt = 0 then "" else string( AvtArt)) @ ub.goods.artic with frame {&frame-name}.
            DISABLE ub.goods.artic b-file with frame {&frame-name}.
            apply "entry" to ub.goods.gds-name in frame {&frame-name}.
    end.
    WHEN vArtBar-Off then do:
            assign
                ArtDIs = no
                BarDis = no
                ub.goods.artic:BGCOLOR = 3
                ArtBar:FGCOLOR = 0 .
            ENABLE ub.goods.artic b-file with frame {&frame-name}.
            apply "entry" to ub.goods.artic in frame {&frame-name}.
    end.
    WHEN vArtBar-BarCode then do:
            assign
                ArtDIs = no
                BarDis = yes
                ub.goods.artic:BGCOLOR = 9
                ArtBar:FGCOLOR = 9 .
            ENABLE ub.goods.artic b-file with frame {&frame-name}.
            apply "entry" to ub.goods.artic in frame {&frame-name}.
    end.
    END CASE.
END PROCEDURE.


PROCEDURE next-good-display:
define buffer first_gds-grp for ub.gds-grp.
DISPLAY
i-artic           @ ub.goods.artic
i-gds-name  @ ub.goods.gds-name
i-engl-name @ ub.goods.engl-name
""                 @ ub.goods.label-name
""                 @ ub.goods.chk-name
i-unit-base   @ ub.goods.unit-base
i-unit-base   @ ub.goods.unit-cli
with frame {&frame-name}
.
if p-prod <> 0 then do:
  DISPLAY
  i-prod-type       @ ub.clients.obj-type
  i-prod-code       @ ub.clients.obj-code
  with frame {&frame-name}.
  apply "LEAVE" to ub.clients.obj-code in frame {&frame-name} .
end.
if p-alpha1 <> 0 then do:
  DISPLAY
  i-alpha1          @ ub.goods.alpha1
  with frame {&frame-name}.
  apply "LEAVE" to ub.goods.alpha1 in frame {&frame-name} .
end.

if p-grp-code <> 0 then do:
  find first ub.gds-grp no-lock where ub.gds-grp.node-code = i-grp-code no-error .
  if avail ub.gds-grp then do:
    RUN grplib-get-full-name in this-procedure(input ub.gds-grp.node-code, output grp-full).
    DISPLAY
    (if length(grp-full) > 79
    then
    ("..." + substr(grp-full, length(grp-full) - 79))
    else
    grp-full) @ grp-full
    with frame {&frame-name}.
  end.
end.

assign
temp-goods.attrib = i-attrib
temp-goods.destin = i-destin
temp-goods.sert = i-sert
temp-goods.user-rule = i-user-rule
temp-goods.struct = i-struct
.
if p-unit-base > 0 then do:
  run leave-unit-base(i-unit-base).
end.
find first first_gds-grp .
if p-VAT-code > 0 then do:
  FIND FIRST bf-tt-tax NO-LOCK where
            bf-tt-tax.tax-code = vattaxcd No-ERROR.
  if not avail bf-tt-tax then do:
    run ref/dtaxgdss.p (
                   input no
                  ,input i-unit-base
                  ,input (if available ub.gds-grp
                          then ub.gds-grp.node-code
                          else first_gds-grp.node-code)
                  ,input ?
                  ,input ?
                  ,input v-host-code
                  ,input p-obj-type
                  ,input p-obj-code
                  ) no-error.
    if error-status:error then return error.
    run enable-max-min(goods.unit-base:screen-value) no-error.
    if error-status:error then return error.
    OPEN QUERY br-tt-tax for each tt-tax NO-LOCK.
    FIND FIRST bf-tt-tax NO-LOCK where
              bf-tt-tax.tax-code = vattaxcd No-ERROR.
  end.
  if avail bf-tt-tax then do:
    REPOSITION br-tt-tax to recid recid(bf-tt-tax) No-ERROR.
    run ROW-LEAVE-BR-tt-tax(i-vat-code).
  end.
end.
if p-slt-code > 0 then do:
  FIND FIRST bf-tt-tax NO-LOCK where
            bf-tt-tax.tax-code = slttaxcd No-ERROR.
  if not avail bf-tt-tax then do:
    run ref/dtaxgdss.p (
                        input no
                       ,input i-unit-base
                       ,input (if available ub.gds-grp
                               then ub.gds-grp.node-code
                               else first_gds-grp.node-code)
                       ,input ?
                       ,input ?
                       ,input v-host-code
                       ,input p-obj-type
                       ,input p-obj-code
                  ) no-error.
    if error-status:error then return error.
    run enable-max-min(goods.unit-base:screen-value) no-error.
    if error-status:error then return error.
    OPEN QUERY br-tt-tax for each tt-tax NO-LOCK.
    FIND FIRST bf-tt-tax NO-LOCK where
              bf-tt-tax.tax-code = slttaxcd No-ERROR.
  end.
  if avail bf-tt-tax then do:
    REPOSITION br-tt-tax to recid recid(bf-tt-tax) No-ERROR.
    run ROW-LEAVE-BR-tt-tax(i-slt-code).
  end.
end.
if p-tnved > 0 then do:
  assign
  temp-goods.tnved = i-tnved
  .
  run get-fields in this-procedure no-error .
end.
END.


PROCEDURE leave-unit-base:
DEFINE INPUT PARAMETER fv as char no-undo.
define variable loc#log as logical no-undo .
define buffer base_units for ub.units.
FIND first base_units no-lock where
         base_units.unit-name = input frame {&frame-name} ub.goods.unit-base  no-error.
if not available base_units
then do:
  display "?" @ ub.goods.unit-base WITH FRAME {&FRAME-NAME}.
end.
if available base_units
and lookup( {&petrolium}, base_units.type) > 0 then do:
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_reference-petrolium_update':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  false
  loc#log
  }
  if not loc#log then do:
    display "?" @ ub.goods.unit-base WITH FRAME {&FRAME-NAME}.
  end.
end.
if  NOT ub.goods.unit-base:screen-value = "?" and mode = {&add-def} and avail ub.gds-grp then do:
  run ref/dtaxgdss.p (
                       input no
                      ,input fv
                      ,input ub.gds-grp.node-code
                      ,input ?
                      ,input ?
                      ,input v-host-code
                      ,input p-obj-type
                      ,input p-obj-code
                      ) no-error.
  if error-status:error then return error.
  run enable-max-min(fv) no-error.
  if error-status:error then return no-apply.
  OPEN QUERY br-tt-tax for each tt-tax NO-LOCK.
  /*обновить browse*/
end.
END.

PROCEDURE row-leave-br-tt-tax.
DEFINE INPUT PARAMETER trc like ub.tax-rate.rate-code no-undo.
define variable taxvalue like ub.tax-rate-value.rate-value no-undo.
define variable var-fact-order like ub.tax-rate-value.fact-order no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
  { gbl/pftaxval.i ? tt-tax.tax-code trc ? v-host-code p-obj-type p-obj-code taxvalue no-error }
  if error-status:error or taxvalue = ? then do:
      assign
      tt-tax.rate-code:screen-value in browse br-tt-tax = string(tt-tax.rate-code)
      tt-tax.fact-date:screen-value in browse br-tt-tax = string(tt-tax.fact-date)
      .
      return error.
  end.
  if mode = {&add-def} and not copymode then v-today = 01/01/1990.
  else do:
    run cur-time in this-procedure(output v-today, output v-time).
  end.
  assign
  tt-tax.rate-value:screen-value in browse br-tt-tax = string(taxvalue)
  tt-tax.fact-date:screen-value in browse br-tt-tax = string(v-today, "99/99/9999")
  .
  FIND FIRST bf-tt-tax WHERE recid(bf-tt-tax) = recid(tt-tax) NO-ERROR.

  run factord-end-day in this-procedure (input date(tt-tax.fact-date:screen-value in browse br-tt-tax), output var-fact-order).
  assign
  bf-tt-tax.rate-code = integer(trc)
  bf-tt-tax.rate-value = decimal(tt-tax.rate-value:screen-value in browse br-tt-tax)
  bf-tt-tax.fact-date = date(tt-tax.fact-date:screen-value in browse br-tt-tax)
  bf-tt-tax.fact-order = var-fact-order
  .
  OPEN QUERY br-tt-tax for each tt-tax NO-LOCK.
END.
PROCEDURE enable-max-min:
DEFINE INPUT PARAMETER fv as char no-undo.
DEFINE BUFFER loc-units for ub.units.
      FIND FIRST loc-units No-LOCK WHERE
                 loc-units.unit-name = fv NO-ERROR.
      IF not avail loc-units then return error.
      IF LOOKUP({&twounit}, loc-units.type) > 0 then do:
        DISPLAY
        label-min-rate
        Label-max-rate
        with frame {&frame-name}.
        ENABLE
        ub.goods.min-rate
        ub.goods.max-rate
        with frame {&frame-name}.
        DISPLAY
        0 @ ub.goods.min-rate
        0 @ ub.goods.max-rate
        with frame {&frame-name}.
      END.
      ELSE DO:
        DISABLE
        ub.goods.min-rate
        ub.goods.max-rate
        with frame {&frame-name}.
        HIDE
        label-min-rate
        Label-max-rate
        ub.goods.min-rate
        ub.goods.max-rate
        IN frame {&frame-name}.
      END.

END.

PROCEDURE proc-b-altcd :
  DEFINE INPUT-OUTPUT PARAMETER loc-altcd-option as char no-undo.
   run ref/alt-cds.w (
                   input parparentproc
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input loc-altcd-option
                  ,goods.gds-code
                  ,main-code
                  ,output ref-list).
  loc-altcd-option = "".
END PROCEDURE.

PROCEDURE proc-b-add-inf:
  DEFINE INPUT-OUTPUT PARAMETER loc-DOPINF-option as char no-undo.
  define variable v-recid as recid no-undo.
  DEFINE VARIABLE v-updated-now AS LOGICAL NO-UNDO.
  case LOC-DOPINF-option:
    WHEN "dop-inf":U then do:
      define variable goodsname as char no-undo .
      define variable prodname as char no-undo .
      define variable prodaddress as char no-undo .
      define variable goods-unit-base as char no-undo .
      define variable glog as logical no-undo.
      if NOT can-do( {&add-def}, mode ) then do:
        if ub.clients.obj-type = {&cmp} then
            FIND ub.firm WHERE ub.firm.firm-code = ub.clients.obj-code NO-LOCK .
        else
            FIND ub.person WHERE ub.person.psn-code = ub.clients.obj-code NO-LOCK .
        assign
            goodsname = ub.goods.gds-name
            prodname = ( trim( ub.clients.obj-name ) +
                                  "( " + ub.clients.obj-type + " " + string( ub.clients.obj-code ) + " )" )
            prodaddress = ( if ub.clients.obj-type = {&cmp}
                            then string( trim( firm.city ) + " " +
                                        trim( firm.addres1 ) + " " + trim( firm.addres2 ) )
                            else string( trim( person.city ) + " " + trim( person.address ) ) )
            goods-unit-base = input frame {&frame-name} goods.unit-base
            .
      end.
      assign
        glog = true
      .
      if mode <> {&add-def} and mode <> {&lookup} then do :
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_reference_update_dopinfo_gbl':U
          {&cntxt-object}
          0
          '':U
          0
          0
          ub.goods.grp-code
          0
          true
          glog
        }
      end.
      if glog then do :
        run set-fields.
        run ref/p51121.w (
                          input parparentproc
                        , input p-obj-type
                        , input p-obj-code
                        , input mode
                        , input goodsname
                        , input prodname
                        , input prodaddress
                        , input (input frame {&frame-name} goods.unit-base)
                        , input-output temp-goods.destin
                        , input-output temp-goods.attrib
                        , input-output temp-goods.user-rule
                        , input-output temp-goods.sert
                        , input-output temp-goods.struct
                        /* input-output prod-date_, */
                        , input-output temp-goods.deadline
                        , input-output temp-goods.sort
                        , input-output temp-goods.tnved
                        , input-output temp-goods.unit-cst
                        , input-output temp-goods.cst-base-rate
                        , input-output temp-goods.nationality
                        , input-output temp-goods.normal-wastage
                        , input-output temp-goods.normal-waste
                        , input-output temp-goods.cond-keep-code
                        , input-output temp-goods.proof
            , INPUT-OUTPUT temp-goods.alc-prod
            , INPUT-OUTPUT temp-goods.alc-mark
                        , INPUT-OUTPUT temp-goods.alc-choose-prod
                        ) .
        run get-fields in this-procedure .
      end.
    END.
    WHEN "foto":U then do:
      if mode = {&add-def} then do:
        BELL.
        loc-DOPINF-option = "".
        return error.
      end.
      run ref/gds-ph.p
        (input parparentproc
        ,buffer goods
        ,input mode
        ).
    end.
    WHEN "dop-inf-gbl":U then do:
      if not v-flag-attr-gbl-entry then do:
        run fill-attr-tables in this-procedure ({&table_goods-attr}, mode) no-error.
        if error-status:error then do:
          message
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
          undo, return error .
        end.
      end.
      run addGdsGrpAttr (if mode = {&add-def} then 0 else goods.gds-code, if avail gds-grp then gds-grp.node-code else -1 ).
      run ref/gds-atti.w (
                      input parparentproc
                     ,input mode
                     ,input (if mode = {&add-def} then 0 else goods.gds-code)
                     ,input no /*instant-update*/
                     ,output v-updated-now
                     ,input-output table tt0-goods-attr
                     ) no-error.
      if error-status:error then do:
        loc-DOPINF-option = "".
        undo, return error.
      end.
      ASSIGN
      v-update-attr-gbl = v-update-attr-gbl OR v-updated-now
      .
    END.
    WHEN "dop-inf-host":U then do:
      if not v-flag-attr-host-entry then do:
        run fill-attr-tables in this-procedure ({&table_gds-host-attr}, mode) no-error.
        if error-status:error then do:
          message
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
          undo, return error .
        end.
      end.
      run ref/gdshatti.w (
                      input parparentproc
                     ,input mode
                     ,input (if mode = {&add-def} then 0 else goods.gds-code)
                     ,input p-obj-type
                     ,input p-obj-code
                     ,input no /*instant-update*/
                     ,output v-updated-now
                     ,input-output table tt0-gds-host-attr
                     ) no-error.
      if error-status:error then do:
        loc-DOPINF-option = "".
        undo, return error.
      end.
      ASSIGN
      v-update-attr-host = v-update-attr-host OR v-updated-now
      .
    END.
    WHEN "dop-inf-fbr-gds-obj":U then do:
      if not v-flag-fbr-gds-entry then do:
        run fill-attr-tables in this-procedure ({&table_fbr-gds-obj}, mode) no-error .
        if error-status:error then do:
          message
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
          undo, return error .
        end.
      end.
      run ref/fgdsobji.w (
                     input parparentproc
                    ,input (if available locked_fbr-gds-obj
                            then mode
                            else (if mode = {&lookup} then {&lookup} else {&add-def})
                           )
                    ,input (if mode = {&add-def} then 0 else goods.gds-code)
                    ,input p-obj-type
                    ,input p-obj-code
                    ,input no /*p-update-instantly*/
                    ,input-output v-fbr-gds-obj-template
                    ,output v-updated-now
                    ,input-output v-recid
                     ) no-error.
      if error-status:error then do:
        loc-DOPINF-option = "".
        undo, return error.
      end.
      if v-updated-now then do:
        find first tt0-fbr-gds-obj where
                    tt0-fbr-gds-obj.obj-type = p-obj-type
                AND tt0-fbr-gds-obj.obj-code = p-obj-code no-error.
        if not available tt0-fbr-gds-obj then do:
          create tt0-fbr-gds-obj.
          assign
          tt0-fbr-gds-obj.gds-code = goods.gds-code
          tt0-fbr-gds-obj.obj-type = p-obj-type
          tt0-fbr-gds-obj.obj-code = p-obj-code
          .
        end.
        assign
        tt0-fbr-gds-obj.is-cd   = logical(entry(1, v-fbr-gds-obj-template))
        tt0-fbr-gds-obj.is-menu = logical(entry(2, v-fbr-gds-obj-template))
        tt0-fbr-gds-obj.is-modificator = logical(entry(3, v-fbr-gds-obj-template))
        tt0-fbr-gds-obj.is-null-price = logical(entry(4, v-fbr-gds-obj-template))
        tt0-fbr-gds-obj.is-season     = logical(entry(5, v-fbr-gds-obj-template))
        tt0-fbr-gds-obj.is-semi-finished  = logical(entry(6, v-fbr-gds-obj-template))
        tt0-fbr-gds-obj.fbr-obj-type      = entry(7, v-fbr-gds-obj-template)
        tt0-fbr-gds-obj.fbr-obj-code      = integer(entry(8, v-fbr-gds-obj-template))
        tt0-fbr-gds-obj.fbr-grp-code      = integer(entry(9, v-fbr-gds-obj-template))
        .
      end.
      ASSIGN
      v-update-fbr-gds = v-update-fbr-gds OR v-updated-now
      .
    END.
    WHEN "dop-inf-s-coeff":U then do:
      if not v-flag-s-coeff-entry then do:
        run fill-attr-tables in this-procedure ({&table_s-coeff}, mode) no-error .
        if error-status:error then do:
          message
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
          undo, return error .
        end.
      end.
      run ref/scoeffs.w (
                     input parparentproc
                    ,input mode
                    ,input (if mode = {&add-def} then 0 else goods.gds-code)
                    ,input p-obj-type
                    ,input p-obj-code
                    ,input no /*instant-update*/
                    ,output v-updated-now
                    ,input-output table tt0-s-coeff
                     ) no-error.
      if error-status:error then do:
        loc-DOPINF-option = "".
        undo, return error.
      end.
      ASSIGN
      v-update-s-coeff = v-update-s-coeff OR v-updated-now
      .
    END.
    WHEN "dop-inf-obj-one":U
    or
    when "dop-inf-obj-cmp":U
    then do:
      if not v-flag-attr-obj-entry then do:
        run fill-attr-tables in this-procedure  ({&table_gds-obj-attr}, mode) no-error .
        if error-status:error then do:
          message
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
          undo, return error .
        end.
      end.
      run ref/gdsoatti.w (
                     input parparentproc
                     ,input /*(if mode = {&add-def} then {&add-def} else {&lookup})*/ mode
                     ,input {&g___object}
                     ,input (if mode = {&add-def} then 0 else goods.gds-code)
                     ,input p-obj-type
                     ,input p-obj-code
                     ,input no /*instant-update*/
                     ,output v-updated-now
                     ,input-output table tt0-gds-obj-attr
                     ) no-error.
      if error-status:error then do:
        loc-DOPINF-option = "".
        undo, return error.
      end.
      ASSIGN
      v-update-attr-obj = v-update-attr-obj OR v-updated-now
      .
    END.
    WHEN "dop-inf-dgr-one":U
    or
    when "dop-inf-dgr-cmp":U
    then do:
      if mode = {&add-def} then do:
        message "Назначение скидки в режиме добавления запрещено. Сохраните товар, прежде чем назначить скидки." view-as alert-box error.
        undo, return error.
      end.
      if not v-flag-dgr-entry then do:
        run fill-attr-tables in this-procedure ( {&table_dis-gds-rule}, mode) no-error .
        if error-status:error then do:
          message
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
          undo, return error .
        end.
      end.
      run ref/dis-gdsi.w (
                     input parparentproc
                     ,input /*(if mode = {&add-def} then {&add-def} else {&lookup})*/ mode
                     ,input {&g___object}
                     ,input (if mode = {&add-def} then 0 else goods.gds-code)
                     ,input p-obj-type
                     ,input p-obj-code
                     ,input '':U
                     ,input no /*instant-update*/
                     ,output v-updated-now
                     ,input-output table tt0-dis-gds-rule
                     ) no-error.
      if error-status:error then do:
        loc-DOPINF-option = "".
        undo, return error.
      end.
      ASSIGN
      v-update-dgr = v-update-dgr OR v-updated-now
      .
    END.
    WHEN "indicators":U then do:
      if not v-flag-gds-prop-entry  or true then do:
        run fill-attr-tables in this-procedure  ({&table_gds-obj-prop}, mode) no-error.
        if error-status:error then do:
          message
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
          undo, return error .
        end.
      end.
      run ref/gds-ind.w (  input parparentproc
                     ,input mode
                     ,input (if mode = {&add-def} then 0 else goods.gds-code)
                     ,input v-host-code
                     ,input p-obj-type
                     ,input p-obj-code
                     ,input no /*instant-update*/
                     ,output v-updated-now
                     ,input-output table tt0-gds-obj-prop
                     ) no-error.
      if error-status:error then do:
        loc-DOPINF-option = "".
        undo, return error.

      end.
      ASSIGN
      v-update-gds-prop = v-update-gds-prop OR v-updated-now
      .
    END.
    when "AM":U then do:
       define variable v-spis as character no-undo .
        run ref/assmatrg.w
                      (input parparentproc
                      , "":U /* bttn */
                      ,input (if mode = {&add-def} then 0 else goods.gds-code)
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input ?
                      ,input ?
                      ,input-output v-spis
                    ) no-error.
      if error-status:error then do:
        loc-DOPINF-option = "".
        undo, return error.
      end.

    end.
    WHEN "add-charg":U then do:
      if not v-flag-gds-prop-entry then do:
        run fill-attr-tables in this-procedure ({&table_gds-add-charges}, mode) no-error.
        if error-status:error then do:
          message
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
          undo, return error .
        end.
      end.
      run ref/ad-charg.w (  input parparentproc
                     ,input mode
                     ,input (if mode = {&add-def} then 0 else goods.gds-code)
                     ,input no /*instant-update*/
                     ,output v-updated-now
                     ,input-output table tt0-gds-add-charges
                     ) no-error.
      if error-status:error then do:
        loc-DOPINF-option = "".
        undo, return error.

      end.
      ASSIGN
      v-update-add-prop = v-update-add-prop OR v-updated-now
      .
    END.
    WHEN "alt-units":U then do:
  define variable v-ret-unit-name  as character no-undo .
  define variable v-ret-unit-coeff as decimal no-undo .  
      run ref/alt-units.w (input parParentProc,
                           input mode,
                           input goods.gds-code,
                       input "", /* ограничение списка выбора */
                       output v-ret-unit-name,
                       output v-ret-unit-coeff) no-error . 
      if error-status :error
      then do:
        assign
          loc-DOPINF-option = "":U
        .
        undo, return error.
      end.
    END.
    WHEN "orders":U then do:
      if not v-flag-gds-prop-entry or true  then do:
        run fill-attr-tables in this-procedure  ({&table_gds-obj-prop} + 'obj' , mode) no-error.
        if error-status:error then do:
          message
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
          undo, return error .
        end.
      end.
      run ref/ord-ind.w (  input parparentproc
                     ,input mode
                     ,input (if mode = {&add-def} then 0 else goods.gds-code)
                     ,input v-host-code
                     ,input p-obj-type
                     ,input p-obj-code
                     ,input no
                     ,output v-updated-now
                     ,input-output table ttj-gds-obj-prop
                     ,input-output table ttj-gds-obj-prop-attr
                     ) no-error.
      if error-status:error then do:
        loc-DOPINF-option = "".
        undo, return error.

      end.
      ASSIGN
      v-update-gds-prop = v-update-gds-prop OR v-updated-now
      .
    END.
    WHEN "ordersf":U then do:
      if not v-flag-gds-prop-entry or true  then do:
        run fill-attr-tables in this-procedure  ({&table_gds-obj-prop} + 'firm', mode) no-error.
        if error-status:error then do:
          message
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
          undo, return error .
        end.
      end.

      run ref/ord-ind.w (  input parparentproc
                     ,input mode
                     ,input (if mode = {&add-def} then 0 else goods.gds-code)
                     ,input v-host-code
                     ,input {&cmp}
                     ,input v-host-code
                     ,input no
                     ,output v-updated-now
                     ,input-output table ttf-gds-obj-prop
                     ,input-output table ttf-gds-obj-prop-attr
                     ) no-error.
      if error-status:error then do:
        loc-DOPINF-option = "".
        undo, return error.

      end.
      ASSIGN
      v-update-gds-prop = v-update-gds-prop OR v-updated-now
      .
    END.

  end case.
  loc-DOPINF-option = "".
END.


procedure proc-b-price :
define input  parameter p-var as integer   no-undo .
define variable v-fact-order     as decimal no-undo .
define variable v-plt-id         as integer no-undo .
define variable v-plt-db-num     as integer no-undo .
define variable v-pdf-id         as integer no-undo .
define variable v-pdf-db-num     as integer no-undo .
define variable v-sale-price-doc as decimal no-undo .
  do
  on error undo, return error return-value
  :

    if p-var = 2 then do:
        run str/chg-sale.w
        ( input  parparentproc ,
          input  p-obj-type    ,
          input  p-obj-code    ,
          buffer goods ).
     end.
     else do:
        run str/chmplgds.w
        ( input  parparentproc ,
          input  goods.gds-code ,
          input  p-obj-type    ,
          input  p-obj-code    ,
          input  v-fact-order  ,
          output v-plt-id      ,
          output v-plt-db-num  ,
          output v-pdf-id      ,
          output v-pdf-db-num  ,
          output v-sale-price-doc ).
    end.

    apply "entry" to b-price in frame {&frame-name}.

  end.

end procedure. /* proc-b-price */

PROCEDURE proc-b-prodbc :
  DEFINE INPUT-OUTPUT PARAMETER loc-prodbc-option as char no-undo.
  run ref/prod-cds.w (input parparentproc
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input  loc-prodbc-option
                  ,input  goods.gds-code
                  ,input  main-code
                  ,output ref-list /* список рекидов */).
  loc-prodbc-option = "".
END PROCEDURE.

PROCEDURE proc-b-sert :
  run ref/gds-sert.w ( input parparentproc
                      ,input  p-obj-type
                      ,input p-obj-code
                      ,input mode
                      ,input "gds"
                      ,input goods.gds-code
                      ,input ?
                      ,input ?
                      ,input ?) no-error.
END PROCEDURE.

PROCEDURE proc-settings:
define input-output parameter par-artic-disable like ub.sysconf.artic-disable no-undo.
define input-output parameter par-negative-rest like ub.sysconf.negative-rest no-undo.
define input-output parameter par-unq-artc as logical no-undo.
define input-output parameter par-dif-nam1 as logical no-undo.
define input-output parameter par-dif-nam2 as logical no-undo.
define input-output parameter par-dif-pdbc as logical no-undo .
define input-output parameter par-tnvedimp as logical no-undo .
define input-output parameter par-gds-copy as character no-undo .
define input-output parameter par-vattaxcd like ub.tax.tax-code no-undo.
define input-output parameter par-slttaxcd like ub.tax.tax-code no-undo.
define input-output parameter par-dfltggrp like ub.gds-grp.node-code no-undo.
define input-output parameter par-gdsfrmfi as character no-undo.

do
on error undo, return error
:
define variable v-curr-obj-type like ub.clients.obj-type no-undo .
define variable v-curr-obj-code like ub.clients.obj-code no-undo .
define variable ii as integer no-undo .
  { gbl/getcntxt.i get }
if p-obj-type = ?
or p-obj-code = ? then do:

  assign
  p-obj-type = v-cntxt-obj-type
  p-obj-code = v-cntxt-obj-code
  .
end.
if p-obj-type = "":U
or p-obj-code = 0
or p-obj-type = ?
or p-obj-code = ? then do:
  message
  "Текущий объект не установлен" skip
  "Работа с карточкой товара в этом режиме еще не реализована"
  view-as alert-box error .
  undo, return error.
end.

{ gbl/hostname.i p-obj-type p-obj-code v-host-code v-host-name }
{ gbl/basecode.i v-host-code v-base-code }

FIND ub.sysconf WHERE
     ub.sysconf.host-code = v-host-code NO-LOCK .
assign
par-artic-disable = ub.sysconf.artic-disable
par-negative-rest = ub.sysconf.negative-rest
.




for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.

run adm/shattri.p (
      input "get":U
    ,input  '':U
    ,input  0
    ,input  {&attr-gds-ref}
    ,input  "":U /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .

IF error-status:error then do:
  delete object v-tth.
  message
  substitute("Ошибка при получении опций работы со справочником товаров:&1&2 &3"
            , {&new-line}
            , error-status:get-message(1)
            , return-value )
  view-as alert-box error .
  return error.
end.
for each thbjattr_thbj-attr  where
        thbjattr_thbj-attr.obj-type = '':U
    and thbjattr_thbj-attr.obj-code = 0
    and thbjattr_thbj-attr.upper-prop-code = {&attr-gds-ref}
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
  case thbjattr_thbj-attr.prop-code:
    when {&attr-gds-ref_dif-nam1} then do:
      par-dif-nam1 = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-gds-ref_dif-nam2} then do:
      par-dif-nam2 = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-gds-ref_dif-pdbc} then do:
      par-dif-pdbc = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-gds-ref_gds-copy} then do:
      par-gds-copy = thbjattr_thbj-attr.property-value-character.
    end.
    when {&attr-gds-ref_tnvedimp} then do:
      tnvedimp = thbjattr_thbj-attr.property-value-logical.
    end.
  end case.
end.
run adm/shattri.p (
      input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  {&attr-gds-ref_obj}
    ,input  {&attr-gds-ref_dfltggrp} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output par-dfltggrp
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .

IF error-status:error then do:
  delete object v-tth.
  message
  substitute("Ошибка при получении опций работы со справочником товаров на объекте &4&5:&1&2 &3"
            , {&new-line}
            , error-status:get-message(1)
            , return-value
            , p-obj-type
            , p-obj-code
            )
  view-as alert-box error .
  return error.
end.


do ii = 1 to num-entries(par-gds-copy):
  if ii = 1  then
  assign
  v-attr-obj-par = integer(entry(ii, par-gds-copy))
  no-error .
  if ii = 2  then
  assign
  v-attr-host-par = integer(entry(ii, par-gds-copy))
  no-error .
  if ii = 3 then
  assign
  v-fbr-gds-par = integer(entry(ii, par-gds-copy))
  no-error .
  if ii = 4 then
  assign
  v-s-coeff-par = integer(entry(ii, par-gds-copy))
  no-error .
  if ii = 5 then
  assign
  v-gds-prop-par = integer(entry(ii, par-gds-copy))
  no-error .
  if ii = 6 then
  assign
  v-attr-gbl-par = integer(entry(ii, par-gds-copy))
  no-error .
  if ii = 7 then
  assign
  v-add-prop-par = integer(entry(ii, par-gds-copy))
  no-error .
end.

assign
par-vattaxcd = integer({&vat-tax-code})
par-slttaxcd = integer({&slt-tax-code})
.

run uf-get in this-procedure (
    input {&uf-gdsfrmfi}
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
  par-gdsfrmfi = entry(1, v-uf-list_,  {&delim-par} ) no-error.
end.
end.
/*разберем этот параметр*/
END PROCEDURE.

PROCEDURE proc-b-tax:
DEFINE VARIABLE locfor-title as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer b_tt-tax for tt-tax.
DEFINE VARIABLE vtoday-fact-order as decimal no-undo .
if NOT can-find(first tt-tax No-LOCK ) then do:
  bell.
  return error.
end.
FOR EACH output-tax:
  DELETE output-tax.
END.
locfor-title =  "Ставки налогов и их значения: " +
                (if mode = {&add-def}
                 then frame {&frame-name}:title
                 else ( "товар с кодом " + string(goods.gds-code))
                 ).

run ref/taxgtree.w (
               input table tt-tax,
               output table output-tax,
               input parparentproc,
               input mode,
               input "GOODS":U,
               input (if mode = {&add-def}
                      then ? else
                      goods.gds-code),
               input ?,
               input v-host-code,
               input p-obj-type,
               input p-obj-code,
               input locfor-title) no-error .
if error-status:error then return error.
DO on error UNDO, return error:
  FOR EACH tt-tax break by tt-tax.tax-code:
    if first-of(tt-tax.tax-code) then do:
      if tt-tax.individual then next.
      if mode = {&add-def} and not copymode then v-today = 01/01/1990.
      else do:
        run cur-time in this-procedure(output v-today, output v-time).
      end.
      for each output-tax where
              output-tax.tax-code = tt-tax.tax-code:
        if output-tax.tax-rate-gds-rc <> ? then do:
          find first b_tt-tax where
                     b_tt-tax.tax-rate-gds-rc = output-tax.tax-rate-gds-rc .
          buffer-copy
          output-tax to b_tt-tax.
        end.
        else if mode = {&add-def} and not copymode then do:
          run factord-end-day in this-procedure (input 01/01/1990 , output vtoday-fact-order).
          find first b_tt-tax where
                     b_tt-tax.tax-code = output-tax.tax-code AND
                     b_tt-tax.fact-order = vtoday-fact-order NO-ERROR.
          if avail b_tt-tax then
          buffer-copy
          output-tax to b_tt-tax.
        end.
        if output-tax.tax-rate-gds-rc = ? and (output-tax.fact-date > v-today OR
                                               ( mode = {&add-def} and copymode AND
                                                 output-tax.fact-date = v-today )
                                              )
        /*and mode <> {&add-def}*/  then do:
          find first b_tt-tax where
                     b_tt-tax.tax-code = output-tax.tax-code and
                     b_tt-tax.fact-order = output-tax.fact-order no-error.
          if not avail b_tt-tax then create b_tt-tax.
          buffer-copy
          output-tax to b_tt-tax.
        end.
      end. /*for each output-tax*/
    end. /*if first-of */
  END. /*for each tt-tax*/
END.
OPEN QUERY br-tt-tax for each tt-tax NO-LOCK.
END PROCEDURE.

PROCEDURE proc-b-chk:
DEFINE VARIABLE rid-list as character no-undo .
define variable v-stat as character no-undo init ?.
define variable v-list as character no-undo init ?.
define variable v-cond as character no-undo init ?.
define variable v-grp  as character no-undo .
define variable v-old-code as integer no-undo .

define buffer buf_units for ub.units.

if lookup (mode, {&update_add-def}) > 0 then do:
  /* В этом режиме это кнопка Группа */
  if mode = {&update} then do:
    g#log = yes.
    message "Выберите группу, в которую нужно переместить данный товар."
            view-as alert-box question buttons OK-Cancel update g#log.
    if not g#log then do:
      return error.
    end.
  end.
  v-grp = "".
  run ref/gds-grp.w (
                  input parparentproc
                , input ({&g#term} + ',b-sel')
                , input p-obj-type
                , input p-obj-code
                , input-output v-grp).
  if v-grp = "" then do:
    return error.
  end.
  FIND ub.gds-grp WHERE recid (gds-grp) = integer (v-grp) No-ERROR.
  if not avail ub.gds-grp then do:
    return error.
  end.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reference_upd-group':U
    {&cntxt-global}
    0
    '':U
    0
    0
    ub.gds-grp.node-code
    0
    true
    g#log
  }
  if NOT g#log then return error.

   define variable v-value      as character no-undo .
   define variable v-type       as character no-undo .
   define buffer buf-grp for ub.gds-grp.
   define variable v-upper like  ub.gds-grp.node-code.
   find first buf-grp where buf-grp.node-code = ub.gds-grp.node-code no-lock no-error.
      v-value = ''.  
      run ggoattr-value(
                input buf-grp.node-code,
                input 0,
                input "",
                input 0,
                input {&ggoattr-alchol-grp},
                output v-value,
                output v-type
              ) no-error.
        if v-value = '' or v-value = "no" then find first buf-grp where buf-grp.node-code = v-upper no-lock no-error.    
        else temp-goods.alc-prod = yes .
        if v-value = "yes" then do:
     define variable v-value-mark as character no-undo .
      find first buf-grp where buf-grp.node-code = ub.gds-grp.node-code no-lock no-error.
      if available buf-grp then v-upper = buf-grp.upper-code.
      else message "Выберите группу товаров"
           view-as alert-box.
      run ggoattr-value(
                input buf-grp.node-code,
                input 0,
                input "",
                input 0,
                input {&ggoattr-mark-grp},
                output v-value-mark,
                output v-type
              ) no-error.
        
        if v-value-mark = "no" then temp-goods.alc-mark = no . else temp-goods.alc-mark = yes . 
        end.

     /*Проверка на атрибут ЕМЦ*/
     define variable v-value-emrc as character no-undo .
     define variable v-type-emrc  as character no-undo .
     define variable old-value-emrc as character no-undo .
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

        for first ub.gds-grp-obj-attr no-lock
           where ub.gds-grp-obj-attr.node-code   = ub.gds-grp.node-code
           and ub.gds-grp-obj-attr.host-code   = 0
           and ub.gds-grp-obj-attr.obj-type    = ""
           and ub.gds-grp-obj-attr.obj-code    = 0
           and ub.gds-grp-obj-attr.attr-code   = {&ggoattr-emrc-type}:
           v-value-emrc = ub.gds-grp-obj-attr.attr-value .
        end.

        define variable v-attr-emrc as character no-undo .
        define variable v-attr-type as character no-undo .
        define variable v-emrc-name as character no-undo .
        define variable v-del       as logical   no-undo .
        define buffer buf_goods-attr for ub.goods-attr .
        /*Значение атрибута товара*/
        for first buf_goods-attr no-lock where buf_goods-attr.attr-code = {&attr-emrc-type} and
           buf_goods-attr.gds-code = temp-goods.gds-code:
           v-attr-emrc = buf_goods-attr.attr-value .
        end.
        if v-value-emrc <> old-value-emrc and v-attr-emrc = "" then
        do:
           message "При переносе в группу " + string(ub.gds-grp.node-name) + " для товара " + string(temp-goods.gds-name) skip
              "будет наследоваться значение новой группы тип ЕМЦ-" + if v-value-emrc <> "" then v-value-emrc else "000" + ". " skip
              "При утвердительном ответе товар переносится в новую группу, значение тип ЕМЦ-" + string (if v-value-emrc <> "" then v-value-emrc else "000")
              view-as alert-box question buttons yes-no-cancel update choice as logical .
           CASE choice:
              WHEN TRUE THEN /* Yes */
                 DO:
                 END.
              WHEN FALSE THEN /* No */
                 DO:
                    run gds-attr-write IN THIS-PROCEDURE(
                       input temp-goods.gds-code
                       ,INPUT {&attr-emrc-type}
                       ,INPUT old-value-emrc ) .
                 END.
              OTHERWISE
              DO: /* Cancel */
                 return error.
              end.
           END CASE.
        end.
   define variable lChoice as integer no-undo .
   if v-value-emrc <> v-attr-emrc and v-attr-emrc <> "" then 
   do:
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
         ,output lChoice).          
      CASE lChoice:
         WHEN 1 THEN /* Yes */
            DO:
               if v-value-emrc = "" then 
               do:
                  run gds-attr-delete IN THIS-PROCEDURE(
                     input temp-goods.gds-code
                     ,INPUT {&attr-emrc-type}
                     ,output v-del ) .
               end.
               else 
               do:
                  run gds-attr-write IN THIS-PROCEDURE(
                     input temp-goods.gds-code
                     ,INPUT {&attr-emrc-type}
                     ,INPUT v-value-emrc ) NO-ERROR.
               end.
            END.
         WHEN 2 THEN /* No */
            DO:
               run gds-attr-write IN THIS-PROCEDURE(
                  input temp-goods.gds-code
                  ,INPUT {&attr-emrc-type}
                  ,INPUT v-attr-emrc ) .
            END.
         OTHERWISE 
         DO: /* Cancel */
            return error.
         end.
      END CASE.
   end.

  run chkgrp in this-procedure (buffer gds-grp) no-error .
  if error-status:error then return error.
  grp-full = "".
  RUN grplib-get-full-name in this-procedure (input ub.gds-grp.node-code, output grp-full).
  if length (grp-full) > 79 then
    grp-full = "..." + substr (grp-full, length (grp-full) - 79).
  run leave-unit-base(goods.unit-base:screen-value in frame {&frame-name}) no-error.
  if error-status:error then do:
    return error.
  end.
  DISPLAY grp-full with frame {&frame-name}.
  /* в goods группа будет подставлена при сохранении записи */
  if goods.artic:sensitive then
    apply "entry" to goods.artic in frame {&frame-name}.
  else
    apply "entry" to goods.gds-name in frame {&frame-name}.
end.
else do:
  /* А здесь это действительно кнопка Чеки */
    if ub.gds-prt.node-name = {&empty-scale} or not v-doc-prt then do:
      find first buf_units No-LOCK WHERE
                buf_units.unit-name = ub.goods.unit-base .
      if lookup({&serial}, buf_units.type ) > 0 then do:
        run ref/gds-chks.w (input parparentproc
                      ,input recid(goods)
                      ,input "":U
                      ,input {&g___object}
                      ,input ? /*pardoc-rec*/
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input "":U
                      ,input "":U
                      ,output rid-list
                        ).
      end.
      else do:
        run ref/gds-chk.w (
                       input parparentproc
                      ,input main-code
                      ,input "":U
                      ,input {&g___object}
                      ,input ? /*pardoc-rec*/
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input "":U
                      ,input "":U
                      ,output rid-list
                        ).
      end.
    end.
  else
    message "Товар делится на признаки - смотрите чеки через шкалу."
            view-as alert-box INFORMATION .
  return error.
end.
END PROCEDURE.

PROCEDURE chkgrp:
define parameter buffer buf_gds-grp for ub.gds-grp.
/*проверим на таксовость*/
run ref/dtaxgrps.p (buf_gds-grp.node-code,
               buf_gds-grp.upper-code,
               v-host-code,
               p-obj-type,
               p-obj-code) no-error.
if error-status:error then do:
  message
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  for each tt-tax:
    delete tt-tax.
  end.
  return error.
end.
for each tt-tax:
  delete tt-tax.
end.
/*проверим на метод расчета цены*/
if goods.calc-method:screen-value in frame {&frame-name}  = {&pr-calc-grp}  then do:
  if LOOKUP(buf_gds-grp.calc-method, goods.calc-method:list-items in frame {&frame-name}) = 0 or
     buf_gds-grp.calc-method = ? then do:
    message "Неверный способ расчета учетной цены для товаров группы"
    view-as alert-box error .
    return error.
  end.
end.
END PROCEDURE.

procedure fill-attr-tables :
define input parameter p-table as character no-undo .
define input parameter p-mode  as character no-undo .
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-range as integer no-undo .
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
define variable other-db-num  like ub.db.db-num no-undo .
define variable other-host-code    like ub.sysconf.host-code no-undo .
define variable v-copy         as logical no-undo .
define variable v-update-attr  as logical no-undo .
define variable v-is-error     as logical no-undo .
define variable v-id           as integer no-undo .
define variable v-proc-handle  as handle  no-undo .

define buffer buf_gds-obj-attr for ub.gds-obj-attr.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_s-coeff    for ub.s-coeff.

do
on error undo, return error return-value
on stop undo, return error return-value
:
  CASE p-mode:
     WHEN {&UPDATE} THEN DO:
        CASE p-table:
          when {&table_dis-gds-rule} then do:
            FOR EACH tt0-dis-gds-rule:
              DELETE tt0-dis-gds-rule.
            END.
             FOR EACH locked_dis-gds-rule EXCLUSIVE-LOCK where
                      locked_dis-gds-rule.gds-code = goods.gds-code
                  AND (
                       (locked_dis-gds-rule.obj-type = p-obj-type
                  AND locked_dis-gds-rule.obj-code = p-obj-code)
                  or   (v-cntxt-db-num = 0
                       and
                       (locked_dis-gds-rule.obj-type = {&cmp}
                  AND locked_dis-gds-rule.obj-code = v-host-code))
                  or  (v-cntxt-db-num = 0
                      and
                      (locked_dis-gds-rule.obj-type = '':U
                  AND locked_dis-gds-rule.obj-code = 0))
                  )
              on error undo, return error "Записи Атрибутов товара на объекте заняты"
              :
                if locked_dis-gds-rule.discnt-role = '':U
                and locked_dis-gds-rule.pos-type = '':U
                and locked_dis-gds-rule.nonunique = '':U then next.
                run trg/lock-dgr.p persistent set v-proc-handle (recid(locked_dis-gds-rule)) .
                run perproc-create-proc in this-procedure (
                                                                  input  this-procedure
                                                                  ,input  "trg/lock-dgr.p"
                                                                  ,input  v-proc-handle
                                                                  ,input  no
                                                                  ,input  "":u
                                                                  ,input v-cntxt-userid
                                                                  ,input 0
                                                                  ,output v-id) .
                CREATE tt0-dis-gds-rule.
                BUFFER-COPY locked_dis-gds-rule TO tt0-dis-gds-rule.
            END.
            v-flag-dgr-entry = yes.
            FOR EACH buf_dis-gds-rule no-lock where
                    buf_dis-gds-rule.gds-code = goods.gds-code
            on error undo, return error
            :
                if (buf_dis-gds-rule.obj-type = p-obj-type
                AND buf_dis-gds-rule.obj-code = p-obj-code)
                or (v-cntxt-db-num = 0
                    and
                    (buf_dis-gds-rule.obj-type = {&cmp}
                AND buf_dis-gds-rule.obj-code = v-host-code))
                or (v-cntxt-db-num = 0
                    and
                    (buf_dis-gds-rule.obj-type = '':U
                AND buf_dis-gds-rule.obj-code = 0))
                   then NEXT.
                CREATE tt0-dis-gds-rule.
                BUFFER-COPY buf_dis-gds-rule TO tt0-dis-gds-rule.
            END.
          end. /*when {&table_dis-gds-rule} then do:*/
          when {&table_gds-obj-attr} then do:
            FOR EACH tt0-gds-obj-attr:
              DELETE tt0-gds-obj-attr.
            END.
             FOR EACH locked_gds-obj-attr EXCLUSIVE-LOCK where
                      locked_gds-obj-attr.gds-code = goods.gds-code
                  AND locked_gds-obj-attr.obj-type = p-obj-type
                  AND locked_gds-obj-attr.obj-code = p-obj-code
              on error undo, return error "Записи Атрибутов товара на объекте заняты"
              :

                run trg/lock-goa.p persistent set v-proc-handle (recid(locked_gds-obj-attr)) .
                run perproc-create-proc in this-procedure (
                                                                  input  this-procedure
                                                                  ,input  "trg/lock-goa.p"
                                                                  ,input  v-proc-handle
                                                                  ,input  no
                                                                  ,input  "":u
                                                                  ,input v-cntxt-userid
                                                                  ,input 0
                                                                  ,output v-id) .
                CREATE tt0-gds-obj-attr.
                BUFFER-COPY locked_gds-obj-attr TO tt0-gds-obj-attr.
            END.
            v-flag-attr-obj-entry = yes.

            FOR EACH buf_gds-obj-attr no-lock where
                    buf_gds-obj-attr.gds-code = goods.gds-code
            on error undo, return error
            :
                if buf_gds-obj-attr.obj-type = p-obj-type
                AND buf_gds-obj-attr.obj-code = p-obj-code then NEXT.
                CREATE tt0-gds-obj-attr.
                BUFFER-COPY buf_gds-obj-attr TO tt0-gds-obj-attr.
            END.
          end. /*when {&table_gds-obj-attr} then do:*/

          when {&table_goods-attr} then do:
            FOR EACH tt0-goods-attr WHERE tt0-goods-attr.attr-code <> {&attr-alcohol-prod}:
              DELETE tt0-goods-attr.
            END.
            FOR EACH locked_goods-attr EXCLUSIVE-LOCK where
                    locked_goods-attr.gds-code = goods.gds-code
            on error undo, return error "Записи Глобальных Атрибутов товара на фирме заняты"
            :
                run trg/lock-ga.p persistent set v-proc-handle (recid(locked_goods-attr)) .
                run perproc-create-proc in this-procedure (
                                                                  input  this-procedure
                                                                  ,input  "trg/lock-ga.p"
                                                                  ,input  v-proc-handle
                                                                  ,input  no
                                                                  ,input  "":u
                                                                  ,input v-cntxt-userid
                                                                  ,input 0
                                                                  ,output v-id) .
                CREATE tt0-goods-attr.
                BUFFER-COPY locked_goods-attr TO tt0-goods-attr.
            END.
            v-flag-attr-gbl-entry = yes.
          end. /*en {&table_gds-gbl-attr} then do:*/
          when {&table_gds-host-attr} then do:
            FOR EACH tt0-gds-host-attr:
              DELETE tt0-gds-host-attr.
            END.
            FOR EACH locked_gds-host-attr EXCLUSIVE-LOCK where
                    locked_gds-host-attr.gds-code = goods.gds-code
                AND locked_gds-host-attr.host-code = v-host-code
            on error undo, return error "Записи Атрибутов товара на фирме заняты"
            :
                run trg/lock-gha.p persistent set v-proc-handle (recid(locked_gds-host-attr)) .
                run perproc-create-proc in this-procedure (
                                                                  input  this-procedure
                                                                  ,input  "trg/lock-gha.p"
                                                                  ,input  v-proc-handle
                                                                  ,input  no
                                                                  ,input  "":u
                                                                  ,input v-cntxt-userid
                                                                  ,input 0 /*p-rank-to-delete*/
                                                                  ,output v-id) .

                CREATE tt0-gds-host-attr.
                BUFFER-COPY locked_gds-host-attr TO tt0-gds-host-attr.
            END.
            v-flag-attr-host-entry = yes.
          end. /*en {&table_gds-host-attr} then do:*/
          when {&table_fbr-gds-obj} then do:
            FOR EACH tt0-fbr-gds-obj:
              DELETE tt0-fbr-gds-obj.
            END.
            FIND FIRST locked_fbr-gds-obj EXCLUSIVE-LOCK where
                    locked_fbr-gds-obj.gds-code = goods.gds-code
                AND locked_fbr-gds-obj.obj-type = p-obj-type
                AND locked_fbr-gds-obj.obj-code = p-obj-code NO-WAIT no-error.
            if not available locked_fbr-gds-obj then do:
              if locked locked_fbr-gds-obj then do:
                return error  "Запись атрибуты РЕСТОРАН товара на объекте занята".
              end.

            end.
            if available locked_fbr-gds-obj then do:
              assign
              v-fbr-gds-obj-recid = recid(locked_fbr-gds-obj).
              CREATE tt0-fbr-gds-obj.
              BUFFER-COPY locked_fbr-gds-obj TO tt0-fbr-gds-obj.
            end.
          v-flag-fbr-gds-entry = yes.
        end.
        when {&table_s-coeff} then do:
          FOR EACH tt0-s-coeff:
            DELETE tt0-s-coeff.
          END.
          find first locked_s-coeff exclusive-lock where
                      locked_s-coeff.gds-code = goods.gds-code
                AND locked_s-coeff.s-date = {&s-coeff-start-date}
                AND locked_s-coeff.host-code = 0
                AND locked_s-coeff.obj-type = "":U
                AND locked_s-coeff.obj-code = 0 no-wait no-error.
          if not available locked_s-coeff then do:
            if locked locked_s-coeff then do:
              return error  "Записи сезонных коэффициентов к товару сейчас заняты".
            end.
          end.
          FOR EACH buf_s-coeff no-lock where
                  buf_s-coeff.gds-code = goods.gds-code
          on error undo, return error
          :
              CREATE tt0-s-coeff.
              BUFFER-COPY buf_s-coeff TO tt0-s-coeff.
          END.
          v-flag-s-coeff-entry = yes.
        end.

        when {&table_gds-obj-prop} then do:
          FOR EACH tt0-gds-obj-prop:
            DELETE tt0-gds-obj-prop.
          END.
          FIND FIRST locked_gds-obj-prop EXCLUSIVE-LOCK where
                  locked_gds-obj-prop.gds-code = goods.gds-code
              AND locked_gds-obj-prop.obj-type = p-obj-type
              AND locked_gds-obj-prop.obj-code = p-obj-code NO-WAIT no-error.
          if not available locked_gds-obj-prop then do:
            if locked locked_gds-obj-prop then do:
              return error  "Запись индикаторов/атрибутов для заказа товара на объекте занята".
            end.
          end.
          if available locked_gds-obj-prop then do:
            assign
            v-gds-prop-recid = recid(locked_gds-obj-prop).
            CREATE tt0-gds-obj-prop.
            BUFFER-COPY locked_gds-obj-prop TO tt0-gds-obj-prop.
          end.
        v-flag-gds-prop-entry = yes.
      end.
        when {&table_gds-obj-prop} + 'obj' then do:
          FOR EACH ttj-gds-obj-prop:
            DELETE ttj-gds-obj-prop.
          END.
          FIND FIRST locked_gds-obj-prop EXCLUSIVE-LOCK where
                  locked_gds-obj-prop.gds-code = goods.gds-code
              AND locked_gds-obj-prop.obj-type = p-obj-type
              AND locked_gds-obj-prop.obj-code = p-obj-code NO-WAIT no-error.
          if not available locked_gds-obj-prop then do:
            if locked locked_gds-obj-prop then do:
              return error  "Запись индикаторов/атрибутов для заказа товара на объекте занята".
            end.
          end.
          if available locked_gds-obj-prop then do:
            assign
            v-gds-prop-recid = recid(locked_gds-obj-prop).
            CREATE ttj-gds-obj-prop.
            BUFFER-COPY locked_gds-obj-prop TO ttj-gds-obj-prop.
          end.
          for each locked_gds-obj-prop-attr no-lock where
                  locked_gds-obj-prop-attr.gds-code = goods.gds-code
              AND locked_gds-obj-prop-attr.obj-type = p-obj-type
              AND locked_gds-obj-prop-attr.obj-code = p-obj-code :
            if lookup(locked_gds-obj-prop-attr.attr-code, {&gdspoatr-list-spec}) > 0 then next.
            CREATE ttj-gds-obj-prop-attr.
            BUFFER-COPY locked_gds-obj-prop-attr TO ttj-gds-obj-prop-attr.
          end.
        v-flag-gds-prop-entry = yes.
      end.
        when {&table_gds-obj-prop} + 'firm' then do:
          FOR EACH ttf-gds-obj-prop:
            DELETE ttf-gds-obj-prop.
          END.
          /*а атрибутов gds-obj-prop-attr для фирмы (obj-type = {&cmp} пока НЕ БЫВАЕТ*/
          FIND FIRST locked_gds-obj-prop EXCLUSIVE-LOCK where
                  locked_gds-obj-prop.gds-code = goods.gds-code
              AND locked_gds-obj-prop.obj-type = {&cmp}
              AND locked_gds-obj-prop.obj-code = v-host-code NO-WAIT no-error.
          if not available locked_gds-obj-prop then do:
            if locked locked_gds-obj-prop then do:
              return error  "Запись параметров товара на фирме занята".
            end.
          end.
          if available locked_gds-obj-prop then do:
            assign
            v-gds-prop-recid = recid(locked_gds-obj-prop).
            CREATE ttf-gds-obj-prop.
            BUFFER-COPY locked_gds-obj-prop TO ttf-gds-obj-prop.
          end.
        v-flag-gds-prop-entry = yes.
      end.
        when {&table_gds-add-charges} then do:
          FOR EACH tt0-gds-add-charges:
            DELETE tt0-gds-add-charges.
          END.
          FIND FIRST locked_gds-add-charges EXCLUSIVE-LOCK where
                  locked_gds-add-charges.gds-code = goods.gds-code
              NO-WAIT no-error.
          if not available locked_gds-add-charges then do:
            if locked locked_gds-add-charges then do:
              return error  "Запись дополнитеотных расходов".
            end.
          end.
          if available locked_gds-add-charges then do:
            assign
            v-add-prop-recid = recid(locked_gds-add-charges).
            CREATE tt0-gds-add-charges.
            BUFFER-COPY locked_gds-add-charges TO tt0-gds-add-charges.
          end.
        v-flag-add-prop-entry = yes.
      end.

      END CASE.
    END.
    WHEN {&LOOKUP} THEN DO:
      CASE p-table:
        when {&table_dis-gds-rule} then do:
          FOR EACH tt0-dis-gds-rule:
            DELETE tt0-dis-gds-rule.
          END.
          FOR EACH locked_dis-gds-rule no-LOCK where
              locked_dis-gds-rule.gds-code = goods.gds-code:
              CREATE tt0-dis-gds-rule.
              BUFFER-COPY locked_dis-gds-rule TO tt0-dis-gds-rule.
          END.
        end.
        when {&table_gds-obj-attr} then do:
          FOR EACH tt0-gds-obj-attr:
            DELETE tt0-gds-obj-attr.
          END.
          FOR EACH locked_gds-obj-attr no-LOCK where
              locked_gds-obj-attr.gds-code = goods.gds-code:
              CREATE tt0-gds-obj-attr.
              BUFFER-COPY locked_gds-obj-attr TO tt0-gds-obj-attr.
          END.
        end.
        when {&table_goods-attr} then do:
          FOR EACH tt0-goods-attr:
            DELETE tt0-goods-attr.
          END.
          FOR EACH locked_goods-attr no-LOCK where
              locked_goods-attr.gds-code = goods.gds-code:
              CREATE tt0-goods-attr.
              BUFFER-COPY locked_goods-attr TO tt0-goods-attr.
          END.
        end.
        when {&table_gds-host-attr} then do:
          FOR EACH tt0-gds-host-attr:
            DELETE tt0-gds-host-attr.
          END.
          FOR EACH locked_gds-host-attr no-LOCK where
              locked_gds-host-attr.gds-code = goods.gds-code
            AND locked_gds-host-attr.host-code = v-host-code:
              CREATE tt0-gds-host-attr.
              BUFFER-COPY locked_gds-host-attr TO tt0-gds-host-attr.
          END.
        end.
        when {&table_fbr-gds-obj} then do:
          FOR EACH tt0-fbr-gds-obj:
            DELETE tt0-fbr-gds-obj.
          END.
          FOR EACH locked_fbr-gds-obj no-lock where
                  locked_fbr-gds-obj.gds-code = goods.gds-code
              AND locked_fbr-gds-obj.obj-type = p-obj-type
              AND locked_fbr-gds-obj.obj-code = p-obj-code
          on error undo, return error
          :
              CREATE tt0-fbr-gds-obj.
              BUFFER-COPY locked_fbr-gds-obj TO tt0-fbr-gds-obj.
          END.
        end.
        when {&table_s-coeff} then do:
          FOR EACH tt0-s-coeff:
            DELETE tt0-s-coeff.
          END.
        end.
        when {&table_gds-obj-prop} then do:
          FOR EACH tt0-gds-obj-prop:
            DELETE tt0-gds-obj-prop.
          END.
          FOR EACH locked_gds-obj-prop no-lock where
                  locked_gds-obj-prop.gds-code = goods.gds-code
              AND locked_gds-obj-prop.obj-type = p-obj-type
              AND locked_gds-obj-prop.obj-code = p-obj-code
          on error undo, return error
          :
              CREATE tt0-gds-obj-prop.
              BUFFER-COPY locked_gds-obj-prop TO tt0-gds-obj-prop.
          END.
        end.
        when {&table_gds-obj-prop} + 'obj' then do:
          FOR EACH ttj-gds-obj-prop:
            DELETE ttj-gds-obj-prop.
          END.
          FOR EACH ttj-gds-obj-prop-attr:
            DELETE ttj-gds-obj-prop-attr.
          END.
          FOR EACH locked_gds-obj-prop no-lock where
                  locked_gds-obj-prop.gds-code = goods.gds-code
              AND locked_gds-obj-prop.obj-type = p-obj-type
              AND locked_gds-obj-prop.obj-code = p-obj-code
          on error undo, return error
          :
              CREATE ttj-gds-obj-prop.
              BUFFER-COPY locked_gds-obj-prop TO ttj-gds-obj-prop.
          END.
          FOR EACH locked_gds-obj-prop-attr no-lock where
                  locked_gds-obj-prop-attr.gds-code = goods.gds-code
              AND locked_gds-obj-prop-attr.obj-type = p-obj-type
              AND locked_gds-obj-prop-attr.obj-code = p-obj-code
          on error undo, return error
          :
            if lookup(locked_gds-obj-prop-attr.attr-code, {&gdspoatr-list-spec}) > 0 then next.
            CREATE ttj-gds-obj-prop-attr.
            BUFFER-COPY locked_gds-obj-prop-attr TO ttj-gds-obj-prop-attr.
          END.
        end.
        when {&table_gds-obj-prop} + 'firm' then do:
          FOR EACH ttf-gds-obj-prop:
            DELETE ttf-gds-obj-prop.
          END.
          FOR EACH locked_gds-obj-prop no-lock where
                  locked_gds-obj-prop.gds-code = goods.gds-code
              AND locked_gds-obj-prop.obj-type = {&cmp}
              AND locked_gds-obj-prop.obj-code = v-host-code
          on error undo, return error
          :
              CREATE ttf-gds-obj-prop.
              BUFFER-COPY locked_gds-obj-prop TO ttf-gds-obj-prop.
          END.
        end.
        when {&table_gds-add-charges} then do:
          FOR EACH tt0-gds-add-charges:
            DELETE tt0-gds-add-charges.
          END.
          FOR EACH locked_gds-add-charges no-lock where
                  locked_gds-add-charges.gds-code = goods.gds-code
          on error undo, return error
          :
              CREATE tt0-gds-add-charges.
              BUFFER-COPY locked_gds-add-charges TO tt0-gds-add-charges.
          END.
        end.
      END CASE.
    END.
    WHEN {&ADD-def} THEN DO:
      if not copymode then return.
      CASE p-table:
        when {&table_gds-obj-attr} then do:
          FOR EACH tt0-gds-obj-attr:
            DELETE tt0-gds-obj-attr.
          END.
          /*
          v-attr-obj-par = 0 - не копировать
          v-attr-obj-par = 1 - в пределах объекта
          v-attr-obj-par = 2 - в пределах объектов фирмы на данной БД
          v-attr-obj-par = 3 - в пределах объектов всех фирмы на данной БД
          */

          if v-attr-obj-par <> 0 then do: /*в апарметре задано копировать атрибуты товара на объекте с разыми вариациями*/
            /*может быть только для копирования*/
            _gds-obj-attr:
            FOR EACH locked_gds-obj-attr no-lock where
                    locked_gds-obj-attr.gds-code = for-goods.gds-code: /*здесь можем быть только в copymode*/
              if v-attr-obj-par = 1
              and (locked_gds-obj-attr.obj-type <> p-obj-type
                  or
                  locked_gds-obj-attr.obj-code <> p-obj-code) then NEXT _gds-obj-attr.
              assign
              other-host-code = 0
              other-db-num = - 1
              .
              if v-attr-obj-par = 2
              or v-attr-obj-par = 3
              then do:
                { gbl/objdbnum.i locked_gds-obj-attr.obj-type locked_gds-obj-attr.obj-code other-db-num no-error}
                if other-db-num <> v-cntxt-db-num  then NEXT _gds-obj-attr.
                if v-attr-obj-par = 2 then do:
                  { gbl/hostcode.i locked_gds-obj-attr.obj-type locked_gds-obj-attr.obj-code other-host-code no-error }
                  if other-host-code <> v-host-code then next _gds-obj-attr.
                end.
              end.
              run gdsoattr-copy in this-procedure
                (input  locked_gds-obj-attr.attr-code           /* p-code           */
                ,output v-copy           /* p-type           */
                ) no-error .
              if error-status:error or not v-copy then next _gds-obj-attr.
              assign
              v-found-copy-atr-obj = yes.
              CREATE tt0-gds-obj-attr.
              BUFFER-COPY locked_gds-obj-attr EXCEPT gds-code TO tt0-gds-obj-attr.
            END.
          end. /* if v-attr-obj-par <> 0 then do: */
          v-flag-attr-obj-entry = yes.
        end.
        when {&table_goods-attr} then do:
          FOR EACH tt0-goods-attr:
            DELETE tt0-goods-attr.
          END.
          /*
          v-attr-gbl-par = 0 - не копировать
          v-attr-gbl-par = 1 - копировать
          */
          if v-attr-gbl-par <> 0 then do:  /*в апарметре задано копировать глоб атрибуты товара с разыми вариациями*/
            _goods-attr:
            FOR EACH locked_goods-attr no-lock where
                    locked_goods-attr.gds-code = (if copymode then for-goods.gds-code else 0):
              run gds-attr-copy in this-procedure
                (input  locked_goods-attr.attr-code           /* p-code           */
                ,output v-copy           /* p-type           */
                ) no-error .
              if error-status:error or not v-copy then next _goods-attr.
              assign
              v-found-copy-atr-gbl = yes.
              CREATE tt0-goods-attr.
              BUFFER-COPY locked_goods-attr EXCEPT gds-code TO tt0-goods-attr.
            END.
          end. /* if v-attr-obj-par <> 0 then do: */
          v-flag-attr-gbl-entry = yes.
        end.

        when {&table_gds-host-attr} then do:
            FOR EACH tt0-gds-host-attr:
              DELETE tt0-gds-host-attr.
            END.

          /*
          v-attr-host-par = 0 - не копировать
          v-attr-host-par = 1 - в пределах фирмы
          v-attr-host-par = 2 - в пределах всех фирм
          */
          if v-attr-host-par <> 0 then do:  /*в апарметре задано копировать атрибуты товара на фирме с разыми вариациями*/
            _gds-host-attr:
            FOR EACH locked_gds-host-attr no-lock where
                    locked_gds-host-attr.gds-code = for-goods.gds-code:
              if v-attr-host-par = 1
              and locked_gds-host-attr.host-code <> v-host-code then next _gds-host-attr.
              run gdshattr-copy in this-procedure
                (input  locked_gds-host-attr.attr-code           /* p-code           */
                ,output v-copy           /* p-type           */
                ) no-error .
              if error-status:error or not v-copy then next _gds-host-attr.
              assign
              v-found-copy-atr-host = yes.
              CREATE tt0-gds-host-attr.
              BUFFER-COPY locked_gds-host-attr EXCEPT gds-code TO tt0-gds-host-attr.
            END.
          end. /* if v-attr-obj-par <> 0 then do: */
          v-flag-attr-host-entry = yes.
        end.
        when {&table_fbr-gds-obj} then do:
          FOR EACH tt0-fbr-gds-obj:
            DELETE tt0-fbr-gds-obj.
          END.

          /*
          v-fbr-gds-par = 0 - не копировать
          v-fbr-gds-par = 1 - в пределах объекта
          v-fbr-gds-par = 2 - в пределах объектов фирмы на данной БД
          v-fbr-gds-par = 3 - в пределах объектов всех фирмы на данной БД
          */
          if v-fbr-gds-par <> 0 then do:
            _fbr-gds-obj:
            FOR EACH locked_fbr-gds-obj no-lock where
                  locked_fbr-gds-obj.gds-code = for-goods.gds-code:
              if v-fbr-gds-par = 1
              and (locked_fbr-gds-obj.obj-type <> p-obj-type
                  or
                  locked_fbr-gds-obj.obj-code <> p-obj-code) then NEXT _fbr-gds-obj.
              assign
              other-host-code = 0
              other-db-num = - 1
              .
              if v-fbr-gds-par = 2
              or v-fbr-gds-par = 3
              then do:
                { gbl/objdbnum.i locked_fbr-gds-obj.obj-type locked_fbr-gds-obj.obj-code other-db-num no-error}
                if other-db-num <> v-cntxt-db-num  then NEXT _fbr-gds-obj.
                if v-attr-obj-par = 2 then do:
                  { gbl/hostcode.i locked_gds-obj-attr.obj-type locked_gds-obj-attr.obj-code other-host-code no-error }
                  if other-host-code <> v-host-code then next _fbr-gds-obj.
                end.
              end.
              assign
              v-found-copy-fbr-gds = yes.
              CREATE tt0-fbr-gds-obj.
              BUFFER-COPY locked_fbr-gds-obj EXCEPT gds-code TO tt0-fbr-gds-obj.
            END.
          end.
          v-flag-fbr-gds-entry = yes.
        end.
        when {&table_s-coeff} then do:
          FOR EACH tt0-s-coeff:
            DELETE tt0-s-coeff.
          END.
          if v-s-coeff-par <> 0 then do:  /*в апарметре задано копировать сезонные коэфф товара с разыми вариациями*/
            _s-coeff:
            FOR EACH buf_s-coeff no-lock where
                    buf_s-coeff.gds-code = for-goods.gds-code
            on error undo, return error
            :
              if v-s-coeff-par = 1
              and buf_s-coeff.host-code <> 0
              and (buf_s-coeff.obj-type <> p-obj-type
                  or
                  buf_s-coeff.obj-code <> p-obj-code) then NEXT _s-coeff.
              assign
              other-host-code = 0
              other-db-num = - 1
              .
              if v-s-coeff-par = 2
              or v-s-coeff-par = 3
              then do:
                { gbl/objdbnum.i buf_s-coeff.obj-type buf_s-coeff.obj-code other-db-num no-error}
                if buf_s-coeff.host-code <> 0
                and other-db-num <> v-cntxt-db-num  then NEXT _s-coeff.
                if v-s-coeff-par = 2 then do:
                  if buf_s-coeff.host-code <> 0
                  And other-host-code <> buf_s-coeff.host-code then next _s-coeff.
                end.
              end.
              v-found-copy-s-coeff = yes.
              CREATE tt0-s-coeff.
              BUFFER-COPY buf_s-coeff except gds-code TO tt0-s-coeff.
            END.
            v-flag-s-coeff-entry = yes.
          end.
        end.
        when {&table_gds-obj-prop} then do:
          FOR EACH tt0-gds-obj-prop:
            DELETE tt0-gds-obj-prop.
          END.
          /*
          v-fbr-gds-par = 0 - не копировать
          v-fbr-gds-par = 1 - в пределах объекта
          v-fbr-gds-par = 2 - в пределах объектов фирмы на данной БД
          v-fbr-gds-par = 3 - в пределах объектов всех фирмы на данной БД
          */
          if v-gds-prop-par <> 0 then do:
            _gds-obj-prop:
            FOR EACH locked_gds-obj-prop no-lock where
                  locked_gds-obj-prop.gds-code = for-goods.gds-code:
              if v-gds-prop-par = 1
              and (locked_gds-obj-prop.obj-type <> p-obj-type
                  or
                  locked_gds-obj-prop.obj-code <> p-obj-code) then NEXT _gds-obj-prop.
              assign
              other-host-code = 0
              other-db-num = - 1
              .
              if v-gds-prop-par = 2
              or v-gds-prop-par = 3
              then do:
                { gbl/objdbnum.i locked_gds-obj-prop.obj-type locked_gds-obj-prop.obj-code other-db-num no-error}
                if other-db-num <> v-cntxt-db-num  then NEXT _gds-obj-prop.
                if v-attr-obj-par = 2 then do:
                  { gbl/hostcode.i locked_gds-obj-attr.obj-type locked_gds-obj-attr.obj-code other-host-code no-error }
                  if other-host-code <> v-host-code then next _gds-obj-prop.
                end.
              end.
              assign
              v-found-copy-gds-prop = yes.
              CREATE tt0-gds-obj-prop.
              BUFFER-COPY locked_gds-obj-prop EXCEPT gds-code TO tt0-gds-obj-prop.
            END.
          end.
          v-flag-gds-prop-entry = yes.
        end.
        when {&table_gds-obj-prop} + 'obj' then do:
          FOR EACH ttj-gds-obj-prop:
            DELETE ttj-gds-obj-prop.
          END.
          /*
          v-fbr-gds-par = 0 - не копировать
          v-fbr-gds-par = 1 - в пределах объекта
          v-fbr-gds-par = 2 - в пределах объектов фирмы на данной БД
          v-fbr-gds-par = 3 - в пределах объектов всех фирмы на данной БД
          */
          if v-gds-prop-par <> 0 then do:
            _gds-obj-prop:
            FOR EACH locked_gds-obj-prop no-lock where
                  locked_gds-obj-prop.gds-code = for-goods.gds-code:
              if v-gds-prop-par = 1
              and (locked_gds-obj-prop.obj-type <> p-obj-type
                  or
                  locked_gds-obj-prop.obj-code <> p-obj-code) then NEXT _gds-obj-prop.
              assign
              other-host-code = 0
              other-db-num = - 1
              .
              if v-gds-prop-par = 2
              or v-gds-prop-par = 3
              then do:
                { gbl/objdbnum.i locked_gds-obj-prop.obj-type locked_gds-obj-prop.obj-code other-db-num no-error}
                if other-db-num <> v-cntxt-db-num  then NEXT _gds-obj-prop.
                if v-attr-obj-par = 2 then do:
                  { gbl/hostcode.i locked_gds-obj-attr.obj-type locked_gds-obj-attr.obj-code other-host-code no-error }
                  if other-host-code <> v-host-code then next _gds-obj-prop.
                end.
              end.
              assign
              v-found-copy-gds-prop = yes.
              CREATE ttj-gds-obj-prop.
              BUFFER-COPY locked_gds-obj-prop EXCEPT gds-code TO ttj-gds-obj-prop.
            END.
          end. /*if v-gds-prop-par <> 0 then do:*/
          if v-gds-prop-par <> 0 then do:
            _gds-obj-prop-attr:
            FOR EACH locked_gds-obj-prop-attr no-lock where
                  locked_gds-obj-prop-attr.gds-code = for-goods.gds-code:
              if lookup(locked_gds-obj-prop-attr.attr-code, {&gdspoatr-list-spec}) > 0 then next.
              if v-gds-prop-par = 1
              and (locked_gds-obj-prop-attr.obj-type <> p-obj-type
                  or
                  locked_gds-obj-prop-attr.obj-code <> p-obj-code) then NEXT _gds-obj-prop-attr.
              assign
              other-host-code = 0
              other-db-num = - 1
              .
              if v-gds-prop-par = 2
              or v-gds-prop-par = 3
              then do:
                { gbl/objdbnum.i locked_gds-obj-prop-attr.obj-type locked_gds-obj-prop-attr.obj-code other-db-num no-error}
                if other-db-num <> v-cntxt-db-num  then NEXT _gds-obj-prop-attr.
                if v-attr-obj-par = 2 then do:
                  { gbl/hostcode.i locked_gds-obj-attr.obj-type locked_gds-obj-attr.obj-code other-host-code no-error }
                  if other-host-code <> v-host-code then next _gds-obj-prop-attr.
                end.
              end.
              assign
              v-found-copy-gds-prop = yes.
              CREATE ttj-gds-obj-prop-attr.
              BUFFER-COPY locked_gds-obj-prop-attr EXCEPT gds-code TO ttj-gds-obj-prop-attr.
          end.
          end. /*if v-gds-prop-par <> 0 then do:*/
          v-flag-gds-prop-entry = yes.
        end.
        when {&table_gds-obj-prop} + 'firm' then do:
          FOR EACH ttf-gds-obj-prop:
            DELETE ttf-gds-obj-prop.
          END.
          FOR EACH ttf-gds-obj-prop-attr:
            DELETE ttf-gds-obj-prop-attr.
          END.

          /*
          v-fbr-gds-par = 0 - не копировать
          v-fbr-gds-par = 1 - в пределах объекта
          v-fbr-gds-par = 2 - в пределах объектов фирмы на данной БД
          v-fbr-gds-par = 3 - в пределах объектов всех фирмы на данной БД
          */
          if v-gds-prop-par <> 0 then do:
            _gds-obj-prop:
            FOR EACH locked_gds-obj-prop no-lock where
                  locked_gds-obj-prop.gds-code = for-goods.gds-code:
              if v-gds-prop-par = 1
              and (locked_gds-obj-prop.obj-type <> {&cmp}
                  or
                  locked_gds-obj-prop.obj-code <> v-host-code) then NEXT _gds-obj-prop.
              assign
              other-host-code = 0
              other-db-num = - 1
              .
              if v-gds-prop-par = 2
              or v-gds-prop-par = 3
              then do:
                { gbl/objdbnum.i locked_gds-obj-prop.obj-type locked_gds-obj-prop.obj-code other-db-num no-error}
                if other-db-num <> v-cntxt-db-num  then NEXT _gds-obj-prop.
                if v-attr-obj-par = 2 then do:
                  { gbl/hostcode.i locked_gds-obj-attr.obj-type locked_gds-obj-attr.obj-code other-host-code no-error }
                  if other-host-code <> v-host-code then next _gds-obj-prop.
                end.
              end.
              assign
              v-found-copy-gds-prop = yes.
              CREATE ttf-gds-obj-prop.
              BUFFER-COPY locked_gds-obj-prop EXCEPT gds-code TO ttf-gds-obj-prop.
            END.
          end.
          v-flag-gds-prop-entry = yes.
        end.

      END CASE.
    END. /*when add-def*/
  END CASE.
end. /*doe*/

end procedure. /* fill-attr-tables */

procedure check-update-attr :
define input parameter p-exit-without-save as logical no-undo .
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
define variable v-updated as logical no-undo .
define variable v-created as logical no-undo .
define variable v-deleted as logical no-undo .
define variable v-updated-str as character no-undo .
define variable v-loc-update as logical no-undo .
do
on error undo, return error
  :
  /*если v-update-attr-obj = yes или v-update-attr-host = yes то это не значит что что-то изменилось*/
  /*это значит что то-то МЕНЯЛОСЬ - но может случиться что все вернули взад*/
  /*поэтому надо сравнивать tt0-gds-obj-attr c тем что в абзе лежит и нами залочено*/
  if mode <> {&add-def} then do:
    if v-update-attr-obj then do:
      v-loc-update = no.
      for each tt0-gds-obj-attr NO-LOCK where
              tt0-gds-obj-attr.obj-type = p-obj-type
            AND tt0-gds-obj-attr.obj-code = p-obj-code:
        find first locked_gds-obj-attr NO-LOCK WHERE
                locked_gds-obj-attr.gds-code = tt0-gds-obj-attr.gds-code
          AND   locked_gds-obj-attr.obj-type = tt0-gds-obj-attr.obj-type
          AND   locked_gds-obj-attr.obj-code = tt0-gds-obj-attr.obj-code
          AND   locked_gds-obj-attr.attr-code = tt0-gds-obj-attr.attr-code no-error.
        assign
        v-updated = no.
        if available  locked_gds-obj-attr then do:
          v-updated-str = "":U.
          BUFFER-COMPARE tt0-gds-obj-attr
                      TO locked_gds-obj-attr
                      case-sensitive
                      SAVE result IN v-updated-str.
          assign
          v-created = yes
          v-updated = (v-updated-str <> "":U)
          .
        end.
        else do:
          assign
          v-updated = yes.
        end.
        ASSIGN
        v-loc-update = (v-updated or v-loc-update).
      End.
      FOR EACH locked_gds-obj-attr where
              locked_gds-obj-attr.gds-code = goods.gds-code
          AND locked_gds-obj-attr.obj-type = p-obj-type
          AND locked_gds-obj-attr.obj-code = p-obj-code
              :
        FIND FIRST tt0-gds-obj-attr NO-LOCK WHERE
                  tt0-gds-obj-attr.gds-code = locked_gds-obj-attr.gds-code
              AND tt0-gds-obj-attr.obj-type = locked_gds-obj-attr.obj-type
              AND tt0-gds-obj-attr.obj-code = locked_gds-obj-attr.obj-code
              AND tt0-gds-obj-attr.attr-code = locked_gds-obj-attr.attr-code NO-ERROR.
          IF NOT AVAILABLE tt0-gds-obj-attr THEN DO:
            assign
            v-deleted = yes.
            ASSIGN
            v-loc-update = (v-deleted OR v-loc-update).
          END.
      END.
      v-update-attr-obj = v-loc-update.
    end.
    if v-update-dgr then do:
      v-loc-update = no.
      for each tt0-dis-gds-rule NO-LOCK where
                (tt0-dis-gds-rule.obj-type = p-obj-type
            AND tt0-dis-gds-rule.obj-code = p-obj-code)
            or  (v-cntxt-db-num = 0
                and
                (tt0-dis-gds-rule.obj-type = {&cmp}
            AND tt0-dis-gds-rule.obj-code = v-host-code))
            or  (v-cntxt-db-num = 0
                and
                (tt0-dis-gds-rule.obj-type = '':U
            AND tt0-dis-gds-rule.obj-code = 0))
            :
        find first locked_dis-gds-rule NO-LOCK WHERE
                locked_dis-gds-rule.gds-code = tt0-dis-gds-rule.gds-code
          AND   locked_dis-gds-rule.obj-type = tt0-dis-gds-rule.obj-type
          AND   locked_dis-gds-rule.obj-code = tt0-dis-gds-rule.obj-code
          AND   locked_dis-gds-rule.pos-type = tt0-dis-gds-rule.pos-type
          AND   locked_dis-gds-rule.discnt-role = tt0-dis-gds-rule.discnt-role
          AND   locked_dis-gds-rule.nonunique = tt0-dis-gds-rule.nonunique
           no-error.
        assign
        v-updated = no.
        if available  locked_dis-gds-rule then do:
          v-updated-str = "":U.
          BUFFER-COMPARE tt0-dis-gds-rule
                      TO locked_dis-gds-rule
                      case-sensitive
                      SAVE result IN v-updated-str.
          assign
          v-created = yes
          v-updated = (v-updated-str <> "":U)
          .
        end.
        else do:
          assign
          v-updated = yes.
        end.
        ASSIGN
        v-loc-update = (v-updated or v-loc-update).
      End.
      FOR EACH locked_dis-gds-rule where
              locked_dis-gds-rule.gds-code = goods.gds-code
           and  (
                (locked_dis-gds-rule.obj-type = p-obj-type
            AND locked_dis-gds-rule.obj-code = p-obj-code)
            or  (v-cntxt-db-num = 0
                and
                (locked_dis-gds-rule.obj-type = {&cmp}
            AND locked_dis-gds-rule.obj-code = v-host-code))
            or  (v-cntxt-db-num = 0
                and
                (locked_dis-gds-rule.obj-type = '':U
            AND locked_dis-gds-rule.obj-code = 0))
            )
              :
        FIND FIRST tt0-dis-gds-rule NO-LOCK WHERE
                  tt0-dis-gds-rule.gds-code = locked_dis-gds-rule.gds-code
              AND tt0-dis-gds-rule.obj-type = locked_dis-gds-rule.obj-type
              AND tt0-dis-gds-rule.obj-code = locked_dis-gds-rule.obj-code
              AND tt0-dis-gds-rule.pos-type = locked_dis-gds-rule.pos-type
              AND tt0-dis-gds-rule.discnt-role = locked_dis-gds-rule.discnt-role
              AND tt0-dis-gds-rule.nonunique = locked_dis-gds-rule.nonunique
                NO-ERROR.
          IF NOT AVAILABLE tt0-dis-gds-rule THEN DO:
            assign
            v-deleted = yes.
            ASSIGN
            v-loc-update = (v-deleted OR v-loc-update).
          END.
      END.
      v-update-dgr = v-loc-update.
    end.
    v-created = no.
    v-deleted = no.
    v-updated = no.
    if v-update-attr-host then do:
      v-loc-update = no.
      for each tt0-gds-host-attr NO-LOCK where
              tt0-gds-host-attr.gds-code = goods.gds-code
            AND tt0-gds-host-attr.host-code = v-host-code:
        find first locked_gds-host-attr NO-LOCK WHERE
                locked_gds-host-attr.gds-code = tt0-gds-host-attr.gds-code
          AND   locked_gds-host-attr.host-code = tt0-gds-host-attr.host-code
          AND   locked_gds-host-attr.attr-code = tt0-gds-host-attr.attr-code no-error.
        assign
        v-updated = no.
        if available  locked_gds-host-attr then do:
         v-updated-str = "":U.
          BUFFER-COMPARE tt0-gds-host-attr
                      TO locked_gds-host-attr
                      case-sensitive
                      SAVE result IN v-updated-str.
          assign
          v-created = yes
          v-updated = (v-updated-str <> "":U)
          .
        end.
        else do:
          assign
          v-updated = yes.
        end.
        ASSIGN
        v-loc-update = (v-loc-update or v-updated).
      End.
      FOR EACH locked_gds-host-attr where
              locked_gds-host-attr.gds-code = goods.gds-code
          AND locked_gds-host-attr.host-code = v-host-code
              :
        FIND FIRST tt0-gds-host-attr NO-LOCK WHERE
                  tt0-gds-host-attr.gds-code = locked_gds-host-attr.gds-code
              AND tt0-gds-host-attr.host-code = locked_gds-host-attr.host-code
              AND tt0-gds-host-attr.attr-code = locked_gds-host-attr.attr-code NO-ERROR.
          IF NOT AVAILABLE tt0-gds-host-attr THEN DO:
            assign
            v-deleted = yes.
            ASSIGN
            v-loc-update = (v-deleted OR v-loc-update).
          END.
      END.
      v-update-attr-host = v-loc-update.
    end.
    v-created = no.
    v-deleted = no.
    v-updated = no.
    if v-update-attr-gbl then do:
      v-loc-update = no.
      for each tt0-goods-attr NO-LOCK where
              tt0-goods-attr.gds-code = goods.gds-code:
        find first locked_goods-attr NO-LOCK WHERE
                locked_goods-attr.gds-code = tt0-goods-attr.gds-code
          AND   locked_goods-attr.attr-code = tt0-goods-attr.attr-code no-error.
        assign
        v-updated = no.
        if available  locked_goods-attr then do:
          v-updated-str = "":U.
          BUFFER-COMPARE tt0-goods-attr
                      TO locked_goods-attr
                      case-sensitive
                      SAVE result IN v-updated-str.
          assign
          v-created = yes
          v-updated = (v-updated-str <> "":U)
          .
        end.
        else do:
          assign
          v-updated = yes.
        end.
        ASSIGN
        v-loc-update = (v-loc-update or v-updated).
      End.
      FOR EACH locked_goods-attr where
              locked_goods-attr.gds-code = goods.gds-code:
        FIND FIRST tt0-goods-attr NO-LOCK WHERE
                  tt0-goods-attr.gds-code = locked_goods-attr.gds-code
              AND tt0-goods-attr.attr-code = locked_goods-attr.attr-code NO-ERROR.
          IF NOT AVAILABLE tt0-goods-attr THEN DO:
            assign
            v-deleted = yes.
            ASSIGN
            v-loc-update = (v-deleted OR v-loc-update ).
          END.
      END.
      v-update-attr-host = v-loc-update.
    end.
    v-created = no.
    v-deleted = no.
    v-updated = no.
    if v-update-fbr-gds then do:
      find first tt0-fbr-gds-obj no-error.
      if available locked_fbr-gds-obj
      and available tt0-fbr-gds-obj
      then do:
        v-updated-str = "":U.
        buffer-compare locked_fbr-gds-obj
        to tt0-fbr-gds-obj
        case-sensitive
        save result in v-updated-str.
        v-update-fbr-gds = (v-updated-str <> "":U).
      end.
      else do:
        if available tt0-fbr-gds-obj then
        v-update-fbr-gds = yes.
      end.
    end.
    if v-update-s-coeff then do:
      v-loc-update = no.
      for each tt0-s-coeff NO-LOCK:
        find first locked_s-coeff NO-LOCK WHERE
                locked_s-coeff.gds-code = tt0-s-coeff.gds-code
          AND   locked_s-coeff.host-code = tt0-s-coeff.host-code
          AND   locked_s-coeff.obj-type = tt0-s-coeff.obj-type
          AND   locked_s-coeff.obj-code = tt0-s-coeff.obj-code
          AND   locked_s-coeff.s-date   = tt0-s-coeff.s-date no-error.
        assign
        v-updated = no.
        if available  locked_s-coeff then do:
          BUFFER-COMPARE tt0-s-coeff
                      TO locked_s-coeff
                      case-sensitive
                      SAVE result IN v-updated-str.
          assign
          v-created = yes
          v-updated = (v-updated-str <> "":U)
          .
        end.
        else do:
          assign
          v-updated = yes.
        end.
        ASSIGN
        v-loc-update = (v-loc-update or v-updated).
      End.
      FOR EACH locked_s-coeff where
              locked_s-coeff.gds-code = goods.gds-code :
        FIND FIRST tt0-s-coeff NO-LOCK WHERE
                  tt0-s-coeff.gds-code = locked_s-coeff.gds-code
              AND tt0-s-coeff.host-code = locked_s-coeff.host-code
              AND tt0-s-coeff.obj-type = locked_s-coeff.obj-type
              AND tt0-s-coeff.obj-code = locked_s-coeff.obj-code
              AND tt0-s-coeff.s-date = locked_s-coeff.s-date NO-ERROR.
          IF NOT AVAILABLE tt0-s-coeff THEN DO:
            assign
            v-deleted = yes.
            ASSIGN
            v-loc-update = (v-deleted OR v-loc-update).
          END.
      END.
      v-update-s-coeff = v-loc-update.
    end.
    if v-update-gds-prop then do:
      find first tt0-gds-obj-prop no-error.
      if available locked_gds-obj-prop
      and available tt0-gds-obj-prop
      then do:
        v-updated-str = "":U.
        buffer-compare locked_gds-obj-prop
        to tt0-gds-obj-prop
        case-sensitive
        save result in v-updated-str.
        v-update-gds-prop = (v-updated-str <> "":U).
      end.
      else do:
        if available tt0-gds-obj-prop then
        v-update-gds-prop = yes.
      end.
      if v-update-gds-prop = false then do:
          find first ttf-gds-obj-prop no-error.
          if available locked_gds-obj-prop
          and available ttf-gds-obj-prop
          then do:
            v-updated-str = "":U.
            buffer-compare locked_gds-obj-prop
            to ttf-gds-obj-prop
            case-sensitive
            save result in v-updated-str.
            v-update-gds-prop = (v-updated-str <> "":U).
          end.
          else do:
            if available ttf-gds-obj-prop then
            v-update-gds-prop = yes.
          end.
            if v-update-gds-prop = false then do:
                find first ttj-gds-obj-prop no-error.
                if available locked_gds-obj-prop
                and available ttj-gds-obj-prop
                then do:
                  v-updated-str = "":U.
                  buffer-compare locked_gds-obj-prop
                  to ttj-gds-obj-prop
                  case-sensitive
                  save result in v-updated-str.
                  v-update-gds-prop = (v-updated-str <> "":U).
                end.
                else do:
                  if available ttj-gds-obj-prop then
                  v-update-gds-prop = yes.
                end.
          if v-update-gds-prop = false then do:
            for each ttj-gds-obj-prop-attr:
              if lookup(ttj-gds-obj-prop-attr.attr-code, {&gdspoatr-list-spec}) > 0 then next.
              find first locked_gds-obj-prop-attr share-lock where
                        locked_gds-obj-prop-attr.gds-code = ttj-gds-obj-prop-attr.gds-code
                   and  locked_gds-obj-prop-attr.obj-type = ttj-gds-obj-prop-attr.obj-type
                   and  locked_gds-obj-prop-attr.obj-code = ttj-gds-obj-prop-attr.obj-code
                   and  locked_gds-obj-prop-attr.attr-code = ttj-gds-obj-prop-attr.attr-code no-error.
              if available locked_gds-obj-prop-attr then do:
                 buffer-compare locked_gds-obj-prop-attr
                 to ttj-gds-obj-prop-attr
                 case-sensitive
                 save result in v-updated-str.
                 v-update-gds-prop = (v-update-gds-prop or (v-updated-str <> "":U)).
              end. /*if available locked_gds-obj-prop-attr then do:*/
              else do:
                 /*во временной таблице атрибут будет всегда - так устроена форма , но это не повод его создавать каждый раз
                 надо проверитт отличается ли значение от init-value
                 */
                /*получим начальное значение*/
                define variable v-format         as character no-undo .
                define variable v-label          as character no-undo .
                define variable v-user-can-edit  as logical   no-undo .
                define variable v-output-display as logical   no-undo .
                define variable v-other          as character no-undo .
                define variable v-type           as character no-undo .
                define variable jj as integer no-undo .
                define variable v-init-value as character no-undo .

                run gdspoatr-name in this-procedure
                  (input  locked_gds-obj-prop-attr.attr-code           /* p-code           */
                  ,output v-type           /* p-type           */
                  ,output v-format         /* p-format         */
                  ,output v-label          /* p-label          */
                  ,output v-user-can-edit  /* p-user-can-edit  */
                  ,output v-output-display /* p-output-display */
                  ,output v-other          /* p-other          */
                  ) no-error .
                if error-status :error then do:
                  undo, return error return-value .
              end.
                do jj = 1 to num-entries(v-other, {&slash-char}):
                  if entry(1, entry(jj, v-other, {&slash-char}), "=":U) = "init-value":U then do:
                    assign
                    v-init-value = string(entry(2, entry(jj, v-other, {&slash-char}), "=":U))
                    .
                  end.
                end. /*jj*/
                if ttj-gds-obj-prop-attr.attr-value <> v-init-value then do:
                  v-update-gds-prop = yes.
      end.
    end.
            end. /*            for each ttj-gds-obj-prop-attr:*/
          end. /*if v-update-gds-prop = false then do:*/
        end. /*if v-update-gds-prop = false then do*/
      end. /*if v-update-gds-prop = false then do:*/
    end. /*if v-update-gds-prop then do:*/
    if v-update-add-prop then do:
      find first tt0-gds-add-charges no-error.
      if available locked_gds-add-charges
      and available tt0-gds-add-charges
      then do:
        v-updated-str = "":U.
        buffer-compare locked_gds-add-charges
        to tt0-gds-add-charges
        case-sensitive
        save result in v-updated-str.
        v-update-add-prop = (v-updated-str <> "":U).
      end.
      else do:
        if available tt0-gds-add-charges then
        v-update-add-prop = yes.
      end.
    end.

  end. /*mode <> add-def*/
  if copymode and v-found-copy-atr-obj then v-update-attr-obj = yes.
  if copymode and v-found-copy-atr-host then v-update-attr-host = yes.
  if copymode and v-found-copy-atr-gbl then v-update-attr-gbl = yes.
  if copymode and v-found-copy-fbr-gds  then v-update-fbr-gds = yes.
  if copymode and v-found-copy-s-coeff  then v-update-s-coeff = yes.
  if copymode and v-found-copy-gds-prop  then v-update-gds-prop = yes.
  if copymode and v-found-copy-add-prop  then v-update-add-prop = yes.
  if copymode and v-found-copy-dgr       then v-update-dgr = yes.
  if mode = {&add-def} then return.
  if not p-exit-without-save then return.
  if v-update-attr-obj
  or v-update-attr-host
  or v-update-attr-gbl
  or v-update-fbr-gds
  or v-update-s-coeff
  or v-update-gds-prop
  or v-update-add-prop
  or v-update-dgr
  THEN DO:
       MESSAGE
      ( (if v-update-attr-obj
        then "Были изменены атрибуты товара на объекте"
        else "":U) + {&new-line} +
      (if v-found-copy-atr-obj then " или были унаследованы атрибуты товара на объекте" else "":U) + {&new-line} +
        (if v-update-attr-host
        then "Были изменены атрибуты товара на фирме"
        else "":U) + {&new-line} +
      (if v-found-copy-atr-host then " или были унаследованы атрибуты товара на фирме" else "":U) + {&new-line} +
      (if v-update-attr-gbl
        then "Были изменены глобальные атрибуты товара"
        else "":U) + {&new-line} +
      (if v-found-copy-atr-gbl then " или были унаследованы глобальные атрибуты товара" else "":U) + {&new-line} +
      ( if v-update-fbr-gds
        then "Были изменены атрибуты РЕСТОРАН товара на объекте"
        else "":U) + {&new-line} +
      (if v-found-copy-fbr-gds then " или были унаследованы атрибуты РЕСТОРАН товара на объекте" else "":U) + {&new-line} +
      ( if v-update-s-coeff
        then "Были изменены сезонные коэффициенты товара"
        else "":U) + {&new-line} +
      ( if v-update-dgr
        then "Были изменены скидки товара на объекте"
        else "":U) + {&new-line} +
      (if v-found-copy-s-coeff then " или были унаследованы сезонные коэффициенты товара" else "":U) + {&new-line} +
      ( if v-update-gds-prop
        then "Были изменены индикаторы/атрибуты для заказа товара"
        else "":U) + {&new-line} +
      (if v-found-copy-gds-prop then " или были унаследованы индикаторы/атрибуты для заказа товара" else "":U) + {&new-line} +
      ( if v-update-add-prop
        then "Были изменены дополнительные расходы"
        else "":U) + {&new-line} +
      (if v-found-copy-add-prop then " или были унаследованы дополнительные расходы" else "":U) + {&new-line}

      )
       "Сделанные изменения будут отменены" skip
       "Продолжить?"
       VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
       IF NOT glog  THEN RETURN error.
   END.
  end.
end procedure. /* check-update-attr */

procedure reposition-goods :
define input parameter p-direction as character no-undo .
define variable v-new-goods-recid as recid no-undo .
define buffer buf_goods for ub.goods.

do
on error undo, return error
:

  /*
  Возможные значения v-direction
  first,last,prev,next
  */
  if valid-handle(p-call-prog)
  then do:
    run reposition-goods in p-call-prog
      (input  p-direction
      ,output v-new-goods-recid
      ).

    if v-new-goods-recid <> ?
    then do:
      find first buf_goods no-lock
        where recid(buf_goods) = v-new-goods-recid
        no-error .
      assign
      gds-rec = v-new-goods-recid
      v-next-prev = '':U
      .
    end.
  end.
  else do:
    message "Список товаров не определен." view-as alert-box INFORMATION .
    undo, return.
  end.
end.

end procedure. /* reposition-goods */

procedure cb-for-struct-i : /*call-back для ref/struct-i.w   !!!!*/
define output parameter p-struct as character no-undo .

  do
  on error undo, return error
  :
    p-struct = temp-goods.struct.
  end.

end procedure. /* cd-for-struct-i */

procedure proc-b-extart:
  define input  parameter p-gds-code like ub.goods.gds-code no-undo .

  do
  on error undo, return error return-value
  :
    run ref/eartform.w ( input parParentProc
                       , input {&lookup}
                       , input p-gds-code
                       ) no-error .
    if error-status :error then do:
      message
        error-status :get-message(1)
      view-as alert-box information .
    end.
  end.

end procedure.

procedure proc-alc-attr:



end procedure.

{ arc/gds_inf.i calc goods p-obj-type p-obj-code }