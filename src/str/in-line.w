/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование строки ПН

Автор: Чернова Светлана Александровна
Дата создания: 02/15/07
Author: Svetlana Chernova
Creation date: 02/15/07

create : Суслов Алексей Юрьевич
Дата создания: 09/12/05

*/

using ibs.th.str.*.
using ibs.th.str.ptrl.forms.* from propath.

&scop FRAME-NAME     d-in-line

define  input parameter parparentproc   as   handle               no-undo .
define  input parameter parline-mode    as   character            no-undo .
define  input parameter pardoc-rec      as   recid                no-undo .
define  input-output parameter line-rec as   recid                no-undo .
define  input parameter pargds-rec      as   recid                no-undo .
define  input parameter parlns-cnt      as   integer              no-undo .
define output parameter parexit-cycle   as   logical              no-undo .
define  input parameter parqnty         like ub.doc-line.doc-qnty no-undo .
define  input parameter kind-qnty       as   character            no-undo .
define  input parameter parinplnsum     as   logical              no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Редактирование строки ПН":U .

define buffer t-doc     for ub.trn-doc.
define buffer buf_goods for ub.goods .
define buffer buf_contract-specif for ub.contract-specif .
define buffer bf_place-attr for ub.place-attr .
  
/* Временная таблица для организации интерфейса */
define temp-table tt-fr-doc-line no-undo like ub.doc-line
  field price-prod              like ub.doc-line.price-cli
  field price-prod-vat          like ub.doc-line.price-cli
  field price-sale              like ub.doc-line.price-cli
  field curr-abbr               like ub.currency.curr-abbr
  field unit-type               like ub.units.type
  field unit-base               like ub.units.unit-name
  field cli-art                 as character
  field gds-name                like ub.goods.gds-name
  field pl-code                 like ub.pl-gds.pl-code
  field state-measure-qnty      like ub.doc-line.doc-qnty
  field measure-qnty            like ub.doc-line.doc-qnty
  field state-measure-cli-qnty  like ub.doc-line.doc-qnty
  field measure-cli-qnty        like ub.doc-line.doc-qnty
  field trk-cli-qnty            like ub.doc-line.doc-qnty
  field obj-name                like ub.clients.obj-name
  field cst-code                like ub.parts.cst-code
  field last-num-day            as   integer
  field last-date               like ub.parts.last-date
  field contract-code           like ub.contract.contract-code
  field contract-prn-code       like ub.contract.contract-prn-code
  field type-inp-vat            as   logical
  field wt-place                as   decimal
  field froze-fact-qnty         as   logical  initial no
  field type-inp-sum            as   logical
  field tot-cli                 like ub.doc-line.price-cli
  field country-code            like ub.parts-attr.country-code
  field alpha1                  like ub.country.alpha1
  field short-name              like ub.country.short-name
  field fact-qnty-kg            like ub.doc-line.fact-qnty
  field alc-prod                as   logical
  field alc-part-code           as   character
  field alc-multi-parts         as   logical
  field alc-update              as   logical
  field alc-mark-db-num         as   integer
  field alc-mark-code           as   integer
  field alc-bottling-date       as   date
  field alc-ref-ab-path         as   character
  field alc-quality-certif-path as   character
  field alc-certif-path         as   character
  field alc-imp-type            as   character
  field alc-imp-code            as   integer
  field propan-perc             as   decimal format ">>9.9<<"
.

define new shared temp-table tt-doc-pl no-undo
field pl-code as integer format "99999999999"
field pl-code2 as integer format "99999999999"
field whole-send-news like ub.doc-pl.whole-send-news
field obj-type like ub.doc-pl.obj-type
field obj-code like ub.doc-pl.obj-code
field out-code like ub.doc-pl.out-code
field fact-qnty like ub.doc-pl.fact-qnty
field doc-qnty like ub.doc-pl.doc-qnty
field gds-code as integer format "99999999999"
field cli-qnty like ub.doc-pl.cli-qnty
field cli-fact-qnty like ub.doc-pl.cli-fact-qnty
field cli-doc-qnty like ub.doc-pl.cli-doc-qnty
field rest-af-qnty like ub.doc-pl.rest-af-qnty
field cli-rest-af-qnty like ub.doc-pl.cli-rest-af-qnty
field rest-bf-qnty like ub.doc-pl.rest-bf-qnty
field cli-rest-bf-qnty like ub.doc-pl.cli-rest-bf-qnty
index pi obj-type obj-code pl-code out-code gds-code
index doc out-code gds-code obj-code obj-type pl-code
index gds-code gds-code
.
define  variable v-is-looksec as logical no-undo .
if lookup ("autotrnqr2d", parline-mode, ",") > 0
then do:
  v-is-looksec = true.
  parline-mode = replace (parline-mode, ",autotrnqr2d", "").
end.

define temp-table tt-old-list-tank no-undo like ub.doc-line-attr .

define stream outstream.

{ cmp/vssrevis.i               }
{ cmp/str-glbl.i               }
{ cmp/showinf.i                }
{ cmp/library.i                }
{ gbl/dtm.i                    }
{ gbl/tax-name.i               }
{ cmp/croslist.i               }
{ str/hvrdtax.i                }
{ str/lib-trn.i                }
{ gbl/cur-time.i               }
{ trg/factord.i                }
{ str/tax-val.i                }
{ str/lib-calc.i               }
{ cmp/library.i                }
{ str/cpprclig.i               }
{ gbl/godendo.i                }
{ gbl/sel-date.i               }
{ gbl/lineattr.i               }
{ gbl/getcntxt.i def           }
{ gbl/getcntxt.i get           }
{ str/getctxtp.i def           }
{ str/getctxtp.i get           }
/*{ gbl/getsect.i  def           }*/
{ cmp/strcodec.i               }
{ gbl/integerm.i               }
{ gbl/alc-lib.i                }
{ str/prslnew.i "proc"         }
{ gbl/ptrlprop.i def           }
{ str/in-ptrl.i def one-line   }
{ gbl/thbj-def.i               }
{ ref/gdsoattr.i               }
{ gbl/clntattr.i               }
{ gbl/key-rec.i                }
{ cmp/ini-lib.i                }
{ str/trdcalib.i               }
{ str/pokmi-dyn.i              }
{ str/proc-pomi-rvs.i          }

define buffer type-inp-vat-attr for ub.doc-line-attr.
define buffer bf_sysconf        for ub.sysconf.

/* Если перед началом редактирования в doc-qnty-cli-qnty или fact-qnty сразу следует
   надбавить данную дельту */
define buffer buf_rvs-doc   for ub.rvs-doc .
define buffer d-l-b         for ub.doc-line.
define buffer bf-trn-doc    for ub.trn-doc.
define buffer next_doc-pl   for ub.doc-pl.

define buffer sep_auto-tank-attr  for ub.auto-tank-attr.
define buffer bf_place for ub.place .

define temp-table old-doc-line no-undo like ub.doc-line.
define temp-table tt-rvs-line  no-undo like ub.rvs-line.

define variable chg-qnty                    like ub.gds-dtl.doc-qnty         no-undo.
define variable custvalue                   as   character initial ?         no-undo.
define variable custtype                    as   character initial ?         no-undo.
define variable prtvalue                    as   character initial ?         no-undo.
define variable prttype                     as   character initial ?         no-undo.
define variable vat-sumvalue                as   character initial ?         no-undo.
define variable vat-sumtype                 as   character initial ?         no-undo.
define variable v-insalepr                  as   logical   initial ?         no-undo.
define variable v-attr-type                 as   character                   no-undo.
define variable v-attr-value                as   character                   no-undo.
define variable rdtaxcdvalue                as   character initial ?         no-undo.
define variable exctaxcdvalue               as   character initial ?         no-undo.
define variable vattaxcdvalue               as   character initial ?         no-undo.
define variable pr-genmrg                   as   character initial ?         no-undo.
define variable pr-naklvalue                as   logical                     no-undo.
define variable pr-nakltype                 as   character initial ?         no-undo.
define variable temp-mes                    as   character initial ?         no-undo.
define variable varroad-tax-label           as   character                   no-undo.
define variable is-petrolium                as   logical                     no-undo.
define variable is-pieces                   as   logical                     no-undo.
define variable v-ptrl-without-rvs          as   character                   no-undo.
define variable v-gds-ptrl-densities        as   character                   no-undo.
define variable v-min-dens                  as   decimal                     no-undo.
define variable v-max-dens                  as   decimal                     no-undo.
define variable dops                        as   character                   no-undo format "x(250)":U.
define variable dopst                       as   character                   no-undo format "x(1)":U.
define variable dop-slt                     as   character                   no-undo format "x(250)":U.
define variable dop-slt-st                  as   character                   no-undo format "x(1)":U.
define variable sum-vat                     like ub.doc-line.price-rubl      no-undo format "->>>,>>>,>>>,>>>,>>9.99":U.
define variable varrvs-place                as   logical                     no-undo.
define variable var-code-temp               like ub.place.pl-code            no-undo.
define variable rvs-recid                   as   recid                       no-undo.
define variable road-tax-cli                like ub.doc-line.road-tax        no-undo initial 0.
define variable parprice-sale               like ub.price-list.price-sale    no-undo.
define variable parprice-prod               as   decimal                     no-undo.
define variable parprice-prod-vat           as   decimal                     no-undo.
define variable varext-gds-type             as   character      initial ?    no-undo.
define variable varcli-qnty-input           as   logical        initial ?    no-undo. /* Может ли быть задано данное поле в интерфейсе */
define variable vardensity-input            as   logical        initial ?    no-undo.
define variable varcli-base-rate-input      as   logical        initial ?    no-undo.
define variable vardoc-qnty-input           as   logical        initial ?    no-undo.
define variable varfact-qnty-input          as   logical        initial ?    no-undo.
define variable varprice-cli-input          as   logical        initial ?    no-undo.
define variable varbase-price-input         as   logical        initial ?    no-undo.
define variable vartax-3-input              as   logical        initial ?    no-undo.
define variable varcli-qnty-calc            as   character      initial ?    no-undo. /* Какие поля пересчитываются после изменения данного поля */
define variable vardensity-calc             as   character      initial ?    no-undo.
define variable varcli-base-rate-calc       as   character      initial ?    no-undo.
define variable vardoc-qnty-calc            as   character      initial ?    no-undo.
define variable varfact-qnty-calc           as   character      initial ?    no-undo.
define variable vardensity-ist              as   decimal        initial ?    no-undo.
define variable varprice-cli-calc           as   character      initial ?    no-undo.
define variable varbase-price-calc          as   character      initial ?    no-undo.
define variable vartax-3-calc               as   character      initial ?    no-undo.
define variable varround                    as   integer        initial 3    no-undo. /*округление при вычислении ведомого количества*/
define variable varprice-cli                like ub.doc-line.price-rubl      no-undo.
define variable varprice-cli-unit-base      like ub.doc-line.price-rubl      no-undo.
define variable varprice-road-tax           like ub.doc-line.price-rubl      no-undo.
define variable varprice-other-exp          like ub.doc-line.price-rubl      no-undo.
define variable varprice-transport-exp      like ub.doc-line.price-rubl      no-undo.
define variable varprice-without-abs        like ub.doc-line.price-rubl      no-undo.
define variable varprice-slt                like ub.doc-line.price-rubl      no-undo.
define variable varprice-no-slt             like ub.doc-line.price-rubl      no-undo.
define variable varprice-vat                like ub.doc-line.price-rubl      no-undo.
define variable varprice-no-vat-slt         like ub.doc-line.price-rubl      no-undo.
define variable varprice-rubl               like ub.doc-line.price-rubl      no-undo.
define variable varprice-road-tax-rubl      like ub.doc-line.price-rubl      no-undo.
define variable varprice-other-exp-rubl     like ub.doc-line.price-rubl      no-undo.
define variable varprice-transport-exp-rubl like ub.doc-line.price-rubl      no-undo.
define variable varprice-without-abs-rubl   like ub.doc-line.price-rubl      no-undo.
define variable varprice-slt-rubl           like ub.doc-line.price-rubl      no-undo.
define variable varprice-no-slt-rubl        like ub.doc-line.price-rubl      no-undo.
define variable varprice-vat-rubl           like ub.doc-line.price-rubl      no-undo.
define variable varprice-no-vat-slt-rubl    like ub.doc-line.price-rubl      no-undo.
define variable varprice-base               like ub.doc-line.price-base      no-undo.
define variable varprice-road-tax-base      like ub.doc-line.price-base      no-undo.
define variable varprice-other-exp-base     like ub.doc-line.price-base      no-undo.
define variable varprice-transport-exp-base like ub.doc-line.price-base      no-undo.
define variable varprice-without-abs-base   like ub.doc-line.price-base      no-undo.
define variable varprice-slt-base           like ub.doc-line.price-base      no-undo.
define variable varprice-no-slt-base        like ub.doc-line.price-base      no-undo.
define variable varprice-vat-base           like ub.doc-line.price-base      no-undo.
define variable varprice-no-vat-slt-base    like ub.doc-line.price-base      no-undo.
define variable v-clcdoc-vat-pc             like ub.doc-line.vat-pc          no-undo.
define variable v-clcdoc-slt-pc             like ub.doc-line.slt-pc          no-undo.
define variable v-clcdoc-have-slt-pc        like ub.doc-line.slt-pc          no-undo.
define variable v-clcdoc-host-code          like ub.sysconf.host-code        no-undo.
define variable vargds-obj-fact-qnty        like ub.gds-obj.fact-qnty        no-undo label "Остаток".
define variable vargds-obj-price-sale       like ub.gds-obj.price-sale       no-undo label "ПродЦена".
define variable vargds-obj-pc-ov            as   decimal label "Наценка"     no-undo format "->>>,>>9.99%":U.
define variable vargds-obj-last-rubl        like ub.gds-obj.last-rubl        no-undo label "ПрихЦена".
define variable vargds-obj-cli-type         like ub.clients.obj-type         no-undo label "Последний поставщик".
define variable vargds-obj-cli-code         like ub.clients.obj-code         no-undo.
define variable vargds-obj-cli-name         as   character format "x(50)":U  no-undo.
define variable varr-b                      as   character                   no-undo.
define variable par-type                    as   character                   no-undo.
define variable rec-inv-line                as   recid                       no-undo.
define variable varlog                      as   logical                     no-undo.
define variable prt-mode                    as   character                   no-undo.
define variable varalc-prod                 as   character                   no-undo.
define variable is-density-ok               as   logical                     no-undo.
define variable v-hold-doc                  as   logical                     no-undo.
define variable v-change                    as   logical                     no-undo.
define variable v-car-num                   as   character                   no-undo.
define variable v-car-vol                   as   character                   no-undo.
define variable v-autoent-obj-type          as   character                   no-undo.
define variable v-autoent-obj-code          as   character                   no-undo.
define variable v-fio                       as   character                   no-undo.
define variable v-ptbotype                  as   character                   no-undo.
define variable v-ptbocode                  as   character                   no-undo.
define variable v-value-character           as   character                   no-undo.
define variable v-value-date                as   date                        no-undo.
define variable v-value-decimal             as   decimal                     no-undo.
define variable v-value-integer             as   integer                     no-undo.
define variable v-value-logical             as   logical                     no-undo.
define variable v-vat-goods                 as   logical                     no-undo.
define variable v-round-vat-sum             as logical                       no-undo .
define variable v-goods-ms-base             as decimal format ">>,>>9.999"   no-undo .
define variable rvslog                      as logical                       no-undo.
define variable varvalue                    as character                     no-undo .
define variable vartype                     as character                     no-undo .
define variable isEgais                     as logical                       no-undo .
define variable v-vid-action                as integer                       no-undo .
define variable v-vid-param                 as longchar                      no-undo .
define variable v-edit-fact-wayb            as logical                       no-undo .
define variable fq                          as character                     no-undo.
define variable cq                          as character                     no-undo.
define variable v-gds-null-price            as logical                       no-undo .
define variable is-fuel                     as logical                       no-undo .
define variable v-specif-unit-list          as character no-undo . /* ед.изм. из спецификации договора */
define variable v-specif-cli-base-rate      as decimal no-undo .   /* коэф. к базовой ЕИ для ЕИ из договора */ 
define variable l-repeat-asi                as logical                       no-undo .
define variable m-repeat-asi                as character                     no-undo.
define variable v-is-lgas                   as logical                       no-undo.
define variable v-is-lgas-corr              as logical                       no-undo.
define variable v-lgas-gds                  as logical                       no-undo.
define variable v-tth             as handle    no-undo.
define variable v-Param-Type      as character no-undo.
define variable list-pl           as character no-undo.

define variable infoSecObj        as class ibs.th.str.InfoSection no-undo .
define variable l-ok as logical   no-undo .
define variable ii as integer no-undo .
define variable disable-rvs as logical no-undo init no .
define variable isKPrvs as logical no-undo .
define variable v-KPrvs-secs      as character no-undo .
define variable v-KPrvs-doc-pl    as logical   no-undo .

define rectangle rect-tot  edge-pixels 2 graphic-edge size 99 by 1.5 bgcolor 8 dcolor 5.
define rectangle rect-tax1 edge-pixels 2 graphic-edge size 40 by 2.9 bgcolor 8 dcolor 5.
define rectangle rect-tax2 edge-pixels 2 graphic-edge size 61 by 2.9 bgcolor 8 dcolor 5.

{ref/imagelist.i}
/* ***********************  control definitions  ********************** */
DEFINE IMAGE g-image
     /*FILENAME "adeicon/blank":U*/
     STRETCH-TO-FIT RETAIN-SHAPE
     SIZE 18.75 BY 6.25.
DEFINE BUTTON b-choose-last-date
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-choose-last-date"
     SIZE 3 BY .88 TOOLTIP "Годен до".

DEFINE BUTTON b-corr-price-sale
     IMAGE-UP FILE "cmp/check.bmp":U
     IMAGE-DOWN FILE "cmp/check.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/check.bmp":U
     LABEL ""
     SIZE 2 BY 1 TOOLTIP "Была корректировка продажной цены".

define button b-save auto-go
     label "&Сохранить":l
     size 10 by 1.

define button b-quit auto-end-key
     label "Отмена":l
     size 10 by 1.

define button b-prt
     label "&Шкала":l
     size 10 by 1.

define button b-parts
   label "Пар&тии":l
   size 10 by 1.

define button b-help
   label "Помо&щь":l
   size 3 by 1.

define button b-exit-cycl
    label "СтопЦикл":l
    size 10 by 1.

define button b-rvs-bf
    label "Св.до"
    size 12 by 1.2.
define button b-rvs-af
    label "Св.после"
    size 12 by 1.2.

define menu m-rvs-bf
    menu-item m-rvs-bf-1 label "Сверка резервуара"  accelerator "alt-1"
    menu-item m-rvs-bf-2 label "Просмотр"           accelerator "alt-2"
    menu-item m-rvs-bf-3 label "Редактирование"     accelerator "alt-3".

define button b-addinf
    label "Доп.инф."
    size 10 by 1.

define button b-docsec
    label "По сек."
    size 9 by 1.

define button b-alc-attr
    label "АлкАтр"
    size 9 by 1 TOOLTIP "Атрибуты алкогольной продукции".

define button b-place label "Место &хр."
    size 10 by 1 tooltip "Список мест хранения".

define button r-dog
     image-up          file "btn-down-arrow"
     image-down        file "btn-down-arrow"
     image-insensitive file "btn-down-arrow"
     size 3 by .88.

define button r-country
     image-up          file "btn-down-arrow"
     image-down        file "btn-down-arrow"
     image-insensitive file "btn-down-arrow"
     size 3 by .88  TOOLTIP "Выбрать страну".

define menu m-rvs-af
    menu-item m-rvs-af-1 label "Сверка резервуара"  accelerator "alt-1"
    menu-item m-rvs-af-2 label "Просмотр"           accelerator "alt-2"
    menu-item m-rvs-af-3 label "Редактирование"     accelerator "alt-3".

define button r-units
     image-up          file "btn-down-arrow"
     image-down        file "btn-down-arrow"
     image-insensitive file "btn-down-arrow"
     size 3 by .88.

define variable tot-base as decimal format "->>>,>>>,>>>,>>>,>>>,>>>,>>>,>>9.99" initial 0
     view-as fill-in
     size 30 by 1 no-undo.

define variable tot-rubl as decimal format "->>>,>>>,>>>,>>>,>>>,>>>,>>>,>>9.99" initial 0
     view-as fill-in
     size 30 by 1 no-undo.

define variable prt-doc as decimal format "->>,>>>,>>9.999":u initial 0
     label "Шкала"
     view-as fill-in
     size 16 by 1 no-undo.

define variable prt-fact as decimal format "->>,>>>,>>9.999":u initial 0
     label "Факт"
     view-as fill-in
     size 16 by 1 no-undo.

define variable cb-connect-hoses as character init ""
   LABEL "Подключение рукавов при приеме СУГ" 
   VIEW-AS COMBO-BOX INNER-LINES 3
   LIST-ITEM-PAIRS "","empty",
   "Подключение рукавов было","yes",
   "Подключение рукавов не было","no"
   DROP-DOWN-LIST
   SIZE 31.5 BY 1 NO-UNDO.

define variable abr-rb as character format "x(3)":u no-undo .
define variable abr-rb2 as character format "x(3)":u no-undo .

/* ************************  frame definitions  *********************** */
define frame d-in-line
  tt-fr-doc-line.artic                 at row 1    col 15    colon-aligned label "&Артикул"           view-as fill-in size 18    by 1
  tt-fr-doc-line.gds-name              at row 1    col 35    colon-aligned no-label                   view-as text    size 48    by 1 fgcolor 4
  varalc-prod                          at row 1    col 86                  no-label                   view-as text    size 2     by 1 fgcolor 4
  
  tt-fr-doc-line.prod-code             at row 2    col 16    colon-aligned label "&Производитель"     view-as fill-in size 7     by 1
  tt-fr-doc-line.prod-type             at row 2    col 22    colon-aligned no-label                   view-as fill-in size 11.63 by 1
  tt-fr-doc-line.obj-name              at row 2    col 30    colon-aligned format "x(30)" no-label                   view-as text    size 35    by 1 fgcolor 4
  tt-fr-doc-line.last-date             at row 2    col 70    colon-aligned format "99/99/9999" label "Годен до"
  b-choose-last-date                   AT ROW 2    COL 83
  tt-fr-doc-line.last-num-day          at row 2    col 86    format "->>>>9" no-label
  
  tt-fr-doc-line.cli-art               at row 3    col 21    colon-aligned label "Артикул поставщика"   format "x(16)"
  v-goods-ms-base                      at row 3    col 42    label "Объем штуки"                                               fgcolor 4  
  tt-fr-doc-line.alpha1                at row 3    col 77    colon-aligned label "Страна"             view-as text    size 4    by 0.7
  r-country                            at row 3    col 83
  tt-fr-doc-line.short-name            at row 3    col 85    colon-aligned no-label                   view-as text    size 10    by 0.7 fgcolor 4
  
  tt-fr-doc-line.cli-qnty              at row 5    col 10.5  colon-aligned label "По &ТТН"            view-as fill-in size 16    by 1 fgcolor 4 format "->>,>>>,>>9.999":U
  tt-fr-doc-line.unit-cli              at row 5    col 26.5  colon-aligned no-label                   view-as fill-in size 7     by 1 fgcolor 4
  r-units                              at row 5    col 35.5                no-label
  tt-fr-doc-line.cst-code              at row 5    col 55    colon-aligned label "ГТД" FORMAT "X(31)"
  
  tt-fr-doc-line.doc-density           at row 6    col 10.5  colon-aligned format    ">>9.9999999999" label "Плотность"          VIEW-AS FILL-IN SIZE 16 BY 1 fgcolor 4
  tt-fr-doc-line.temperature           at row 6    col 30    colon-aligned format    "->9.99"         label "Т"                  VIEW-AS FILL-IN SIZE 7  BY 1 fgcolor 4
  tt-fr-doc-line.cli-base-rate         at row 6    col 40    colon-aligned format ">>,>>9.9999999999" no-label                   VIEW-AS FILL-IN SIZE 18 BY 1
  
  tt-fr-doc-line.doc-qnty  format ">>>,>>>,>>9.<<<"  at row 7    col 10.5  colon-aligned label "По &накл"           view-as fill-in size 16    by 1
  tt-fr-doc-line.unit-base             at row 7    col 26.5  colon-aligned no-label                   view-as text    size 7     by 1
  b-docsec                             at row 7    col 32  
  tt-fr-doc-line.fact-qnty    format ">>>,>>>,>>9.<<<"  at row 8    col 10.5  colon-aligned    label "&Факт"           view-as fill-in size 16    by 1
  tt-fr-doc-line.fact-density format ">>9.9999999999"   at row 8    col 27.0  colon-aligned no-label                   view-as fill-in size 16    by 1
  tt-fr-doc-line.fact-qnty-kg format ">>>,>>>,>>9.<<<"  at row 8    col 42.5  colon-aligned no-label                   view-as fill-in size 16    by 1
  tt-fr-doc-line.vat-pc                 at row 8    col 64    colon-aligned
  tt-fr-doc-line.type-inp-vat           at row 8    col 73    no-label                   view-as toggle-box size 2 by 1
  tt-fr-doc-line.slt-pc                 at row 9    col 50    colon-aligned
  tt-fr-doc-line.price-cli              at row 12   col 15    colon-aligned label "П&о ТТН" format "->>,>>>,>>>,>>9.9999999999" view-as fill-in size 20 by 1  fgcolor 4
  tt-fr-doc-line.price-base             at row 13   col 15    colon-aligned label "Учет"    format ">>,>>>,>>>,>>9.999"           view-as fill-in size 20    by 1
  tt-fr-doc-line.price-rubl             at row 14   col 15    colon-aligned label "Учет"               view-as fill-in size 20    by 1
  tt-fr-doc-line.new-price-sale         at row 15   col 50    colon-aligned label "Новая цена продажи" format ">>>,>>>,>>>,>>9.99" view-as fill-in size 15    by 1  fgcolor 4
  tt-fr-doc-line.price-prod             at row 16   col 21    colon-aligned label "Цена Производителя" format ">>>,>>>,>>>,>>9.99" view-as fill-in size 18    by 1  fgcolor 4
  tt-fr-doc-line.price-prod-vat         at row 16   col 52    colon-aligned label "Цена с НДС" format ">>>,>>>,>>>,>>9.99" view-as fill-in size 18    by 1  fgcolor 4
  tt-fr-doc-line.num-place              at row 16.2 col 1.5                 label "Кол-во мест"
  tt-fr-doc-line.wt-brutto              at row 16.2 col 68

  tt-fr-doc-line.road-tax               at row 16   col 2 fgcolor 4
  tt-fr-doc-line.excise                 at row 17   col 3 label "Акциз"                                               fgcolor 4
  tt-fr-doc-line.transport-base         at row 16   col 50    colon-aligned label "Тр.расх."                                    fgcolor 4
  tt-fr-doc-line.other-base             at row 17   col 50    colon-aligned label "Пр.расх."                                    fgcolor 4
  tt-fr-doc-line.transport-rubl         at row 16   col 80    colon-aligned label "Тр.расх."                                    fgcolor 4
  tt-fr-doc-line.other-rubl             at row 17   col 80    colon-aligned label "Пр.расх."                                    fgcolor 4
  tt-fr-doc-line.propan-perc            at row 18.5 col 3     label "Массовая доля пропана в смеси, %"  view-as fill-in size 8    by 1
  cb-connect-hoses                      at row 19.5 col 3
  prt-doc                               at row 9    col 10.5  colon-aligned
  prt-fact                              at row 10   col 10.5  colon-aligned
  "Сумма НДС(вал.постав.)"              at row 7    col 60                                             view-as text                     bgcolor 3 fgcolor 15
  sum-vat                               at row 8    col 73    colon-aligned no-label
  b-save                                at row 4.5  col 90
  b-quit                                at row 6    col 90
  b-prt                                 at row 9    col 90
  b-parts                               at row 10.5 col 90
  b-exit-cycl                           at row 12   col 90
  b-help                                at row 1    col 90
  b-addinf                              at row 12   col 90
  b-alc-attr                            at row 15   col 90
  "Сумма"                               at row 11   col 37  view-as text    size 23    by 1  bgcolor 3 fgcolor 15
  tt-fr-doc-line.tot-cli                at row 12   col 35.5  colon-aligned  no-label format "->>>,>>>,>>>,>>>,>>>,>>>,>>>,>>9.99" VIEW-AS FILL-IN SIZE 30 BY 1
  tot-base                              at row 13   col 35.5  colon-aligned no-label
  tot-rubl                              at row 14   col 35.5  colon-aligned no-label
  road-tax-cli                          at row 15   col 17 colon-aligned  view-as fill-in size 20 by 1 fgcolor 4
  rect-tot                              at row 16   col 1
  tt-fr-doc-line.wt-place               at row 16.2 col 40  label "Вес 1 места"
  rect-tax1                             at row 15.5 col 1
  rect-tax2                             at row 15.5 col 38
  "Вал"                                 at row 15.3 col 55                                    view-as text                     bgcolor 3 fgcolor 15
  "{&abbr_rub_firstshift}"              at row 15.3 col 85                                    view-as text                     bgcolor 3 fgcolor 15
  b-place                               at row 20.5 col 2
  tt-fr-doc-line.pl-code                at row 20.5 col 2                   label "Место хр."
  tt-fr-doc-line.measure-qnty           at row 20.5 col 27.5  colon-aligned label "Изм."
  tt-fr-doc-line.state-measure-qnty     at row 20.5 col 49    colon-aligned label "Кол-во"
  tt-fr-doc-line.state-measure-cli-qnty at row 20.5 col 67.5  colon-aligned label "Вес"
  b-rvs-bf                              at row 18.6 col 87
  b-rvs-af                              at row 20.1 col 87
  vargds-obj-fact-qnty                  at row 21.5 col 2
  vargds-obj-price-sale                 at row 21.5 col 24.5
  vargds-obj-pc-ov                      at row 21.5 col 51
  vargds-obj-last-rubl                  at row 21.5 col 73
  vargds-obj-cli-type                   at row 22.5 col 2
  vargds-obj-cli-code                   at row 22.5 col 28 no-label
  vargds-obj-cli-name                   at row 22.5 col 39 no-label  view-as text    size 30   by 1
  tt-fr-doc-line.trk-cli-qnty           at row 22.5 col 69  label "Масса реал-и"
  "Количество"                          at row 4    col 12.5                                           view-as text    size 17    by 1  bgcolor 3 fgcolor 15
  "Ед. изм."                            at row 4    col 28.5                                           view-as text    size 11    by 1  bgcolor 3 fgcolor 15
  "Коэффициент"                         at row 4    col 38.5                                           view-as text    size 16    by 1  bgcolor 3 fgcolor 15
  "Цена"                                at row 11   col 17                                             view-as text    size 20    by 1  bgcolor 3 fgcolor 15
  "Вал."                                at row 11   col 60.0                                           view-as text    size 7.5   by 1  bgcolor 3 fgcolor 15
  tt-fr-doc-line.curr-abbr              at row 12   col 60.0                no-label                   view-as text    size 7.5   by 1  bgcolor 4 fgcolor 15
  "Б.вал."                              at row 13   col 60.0                                           view-as text    size 7.5   by 1  bgcolor 3 fgcolor 15
  "{&abbr_rub_allshift}"                at row 14   col 60.0                                           view-as text    size 7.5   by 1  bgcolor 3 fgcolor 15
  abr-rb                                at row 15   col 60.0                no-label                   view-as text    size 7.5   by 1  bgcolor 1 fgcolor 15
  abr-rb2                               at row 16   col 60.0                no-label                   view-as text    size 7.5   by 1  bgcolor 1 fgcolor 15
  b-corr-price-sale                     at row 15   col 66
  g-image                               AT ROW 11   COL 68
with keep-tab-order view-as dialog-box
         side-labels three-d scrollable
         default-button b-save
         cancel-button  b-quit
.


{ gbl/ed_date.i
  tt-fr-doc-line.last-date
  " "
  " "
  "'Годен до (для товара)'"
  " "
}

/*or choose of b-choose-last-date in frame {&frame-name}*/
/* ***************  runtime attributes and uib settings  ************** */

assign frame d-in-line:scrollable                       = false .

function f-chekval RETURNS logical (input p-canval as char, input p-chkval as dec ):
  def var i as int.
  do i = 1 to num-entries(p-canval):
    if round(decimal(entry(i,p-canval)),1) = round(p-chkval,1) then return true.
  end.
  return no.
end function.

FUNCTION chk-asi-polling RETURNS logical
  ( is-bef as log ) :
    
  def buffer bf_rvs-doc for ub.rvs-doc .
  
  find first bf_rvs-doc no-lock
    where bf_rvs-doc.rvs-type = (if is-bef then {&rvs-before-doc} else {&rvs-after-doc}) 
      and bf_rvs-doc.out-code = t-doc.doc-code
      and num-entries(bf_rvs-doc.rvs-code, "-") = 2
      and bf_rvs-doc.state-measure-qnty <> ?
      no-error .
            
  if available (bf_rvs-doc) and not l-repeat-asi
    then 
  do:
    message
      m-repeat-asi
      view-as alert-box information title "".              
    return no .
  end.
  else return yes.

    
    
end.

/* ************************  control triggers  ************************ */

ON MOUSE-SELECT-DBLCLICK OF g-image IN FRAME {&FRAME-NAME}
DO:
    DEFINE VARIABLE v-main-code LIKE ub.bar-code.b-code NO-UNDO.
    IF AVAILABLE buf_goods THEN
    DO:
        { gbl/gdsbcode.i buf_goods.gds-code ? v-main-code }
        RUN ref/imagelist.w (parparentproc, "":U, v-main-code, {&lookup}).
    END.
END.
on choose of b-choose-last-date in frame {&frame-name}
do:
  { gbl/stdbtn.i }
  run sel-date in this-procedure
    ( input tt-fr-doc-line.last-date :handle
    , input "Годен до &1"
    ) .
end.

on choose of b-place in frame {&frame-name}
do:
  { gbl/stdbtn.i }

  if varrvs-place <> true
    or b-place :sensitive in frame {&frame-name} <> true
  then do:
    return .
  end.

  run edit-doc-pl in this-procedure
    ( input parline-mode
    ).
end.

on return of tt-fr-doc-line.cli-qnty in frame {&frame-name}
do:

  if tt-fr-doc-line.doc-density :sensitive in frame {&frame-name}
  then do:
    apply "entry" to tt-fr-doc-line.doc-density in frame {&frame-name} .
    return no-apply .
  end.
  if tt-fr-doc-line.doc-qnty :sensitive in frame {&frame-name}
  then do:
    apply "entry" to tt-fr-doc-line.doc-qnty in frame {&frame-name} .
    return no-apply .
  end.
  if tt-fr-doc-line.price-cli :sensitive in frame {&frame-name}
  then do:
    apply "entry" to tt-fr-doc-line.price-cli in frame {&frame-name} .
    return no-apply .
  end.
  if tt-fr-doc-line.tot-cli :sensitive in frame {&frame-name}
  then do:
    apply "entry" to tt-fr-doc-line.tot-cli in frame {&frame-name} .
    return no-apply .
  end.
  if tt-fr-doc-line.temperature :sensitive in frame {&frame-name}
  then do:
   apply "entry" to tt-fr-doc-line.temperature   in frame {&frame-name}.
   return no-apply.
  end.

  apply "entry" to b-save in frame {&frame-name} .
  return no-apply .

end.

on leave of tt-fr-doc-line.cli-qnty in frame {&frame-name}
do:

  define variable v-edit-doc-pl-mode as character no-undo .

  if keyfunction(lastkey) <> "end-error"
    and not ( last-event :event-type   = "progress":u
              and (last-event :widget-enter = b-quit :handle
                  or last-event :widget-enter = b-docsec :handle)
            )
  then do:
    /* 20/IX-2018 - проверка перенесена в check-frame() 
    if input frame {&frame-name} tt-fr-doc-line.cli-qnty = 0
      or input frame {&frame-name} tt-fr-doc-line.cli-qnty = ?
    then do:
      message
        "Не указано количество в единицах измерения поставщика."
        view-as alert-box error .
      display
        tt-fr-doc-line.type-inp-vat
        with frame {&frame-name} .
      apply "entry" to tt-fr-doc-line.cli-qnty in frame {&frame-name} .
      return no-apply .
    end.
    */
    if input frame {&frame-name} tt-fr-doc-line.cli-qnty <> tt-fr-doc-line.cli-qnty then do:
      assign
        frame {&frame-name} tt-fr-doc-line.cli-qnty
      .
      run calc-all    in this-procedure ( input varcli-qnty-calc ) no-error .
      if error-status :error then return no-apply.
      run calc-vat-pc in this-procedure.

      if varrvs-place = true
        and not ( last-event :event-type = "progress":u
                  and last-event :widget-enter = b-place :handle
                )
/*        and last-event :widget-enter <> tt-fr-doc-line.doc-density :handle*/
        and tt-fr-doc-line.cli-base-rate <> ?
        and tt-fr-doc-line.cli-base-rate <> 0
        then do:
        assign
          v-edit-doc-pl-mode = {&autoupdate}
        .
        if is-petrolium = yes
          and is-pieces = no
          and tt-fr-doc-line.cli-qnty :sensitive in frame {&frame-name}
          and tt-fr-doc-line.doc-qnty :sensitive in frame {&frame-name}
        then do:
          assign
            v-edit-doc-pl-mode = v-edit-doc-pl-mode + {&delim-par} + "update-dens-cli":U
          .
        end.
        run edit-doc-pl in this-procedure
          ( input v-edit-doc-pl-mode
          ).
      end.
    end.
  end.
  if vardensity-ist <> 0 and vardensity-ist <> ?
  then do:
    tt-fr-doc-line.doc-density:screen-value = string (vardensity-ist).
    apply "leave" to tt-fr-doc-line.doc-density in frame {&frame-name} .
    tt-fr-doc-line.doc-density:sensitive = false.
  end.

end.

on return of tt-fr-doc-line.doc-qnty in frame {&frame-name}
do:


  if tt-fr-doc-line.doc-density :sensitive in frame {&frame-name}
  then do:
    apply "entry" to tt-fr-doc-line.doc-density in frame {&frame-name} .
    return no-apply .
  end.

  if tt-fr-doc-line.temperature :sensitive in frame {&frame-name}
  then do:
   apply "entry" to tt-fr-doc-line.temperature   in frame {&frame-name}.
   return no-apply.
  end.

  if tt-fr-doc-line.price-cli :sensitive in frame {&frame-name}
  then do:
    apply "entry" to tt-fr-doc-line.price-cli in frame {&frame-name} .
    return no-apply .
  end.

  if tt-fr-doc-line.tot-cli :sensitive in frame {&frame-name}
  then do:
    apply "entry" to tt-fr-doc-line.tot-cli in frame {&frame-name} .
    return no-apply .
  end.

  if tt-fr-doc-line.price-rubl :sensitive in frame {&frame-name}
  then do:
    apply "entry" to tt-fr-doc-line.price-rubl in frame {&frame-name} .
    return no-apply .
  end.

  apply "entry" to b-save in frame {&frame-name} .
  return no-apply .
end.

on leave of tt-fr-doc-line.doc-qnty in frame {&frame-name}
do:

  define variable v-edit-doc-pl-mode as character no-undo .

  if keyfunction(lastkey) <> "end-error" and
     not ( last-event :event-type   = "progress":u and
           (last-event :widget-enter = b-quit :handle or 
           last-event :widget-enter = b-docsec :handle))
  then do:
    if input frame {&frame-name} tt-fr-doc-line.doc-qnty = 0 or
       input frame {&frame-name} tt-fr-doc-line.doc-qnty = ?
    then do:
      message "Не указано количество по документу." view-as alert-box error .
      apply "entry" to tt-fr-doc-line.doc-qnty in frame {&frame-name} .
      return no-apply .
    end.
    if input frame {&frame-name} tt-fr-doc-line.doc-qnty <> tt-fr-doc-line.doc-qnty then do:
      assign
        frame {&frame-name} tt-fr-doc-line.doc-qnty
      .
      run calc-all in this-procedure
        ( input vardoc-qnty-calc
        ) no-error.
      if error-status :error then do:
        return no-apply .
      end.
      if varrvs-place = true
        and not ( last-event :event-type = "progress":u
                  and last-event :widget-enter = b-place :handle
                )
        and tt-fr-doc-line.cli-base-rate <> ?
        and tt-fr-doc-line.cli-base-rate <> 0
      then do:
        assign
          v-edit-doc-pl-mode = {&autoupdate}
        .
        if is-petrolium = yes
          and is-pieces = no
          and tt-fr-doc-line.cli-qnty :sensitive in frame {&frame-name}
          and tt-fr-doc-line.doc-qnty :sensitive in frame {&frame-name}
        then do:
          assign
            v-edit-doc-pl-mode = v-edit-doc-pl-mode + {&delim-par} + "update-dens-base":U
          .
        end.
        run edit-doc-pl in this-procedure
          ( input v-edit-doc-pl-mode
          ).
      end.
    end.
  end.
end.

on return of tt-fr-doc-line.fact-qnty in frame {&frame-name}
do:

  if tt-fr-doc-line.price-cli :sensitive in frame {&frame-name}
  then do:
    apply "entry" to tt-fr-doc-line.price-cli in frame {&frame-name} .
    return no-apply .
  end.
  if tt-fr-doc-line.tot-cli :sensitive in frame {&frame-name}
  then do:
    apply "entry" to tt-fr-doc-line.tot-cli in frame {&frame-name} .
    return no-apply .
  end.

  apply "entry" to b-save in frame {&frame-name} .
  return no-apply .

end.

on leave of tt-fr-doc-line.fact-qnty in frame {&frame-name}
do:

  if keyfunction(lastkey) <> "end-error" and
     not ( last-event :event-type   = "progress":u and
           (last-event :widget-enter = b-quit :handle 
           or last-event :widget-enter = b-docsec :handle) )
  then do:

    if input frame {&frame-name} tt-fr-doc-line.fact-qnty < 0
      or input frame {&frame-name} tt-fr-doc-line.fact-qnty = ?
    then do:
      message "Неправильное факт. количество в учетных единицах." view-as alert-box error .
      apply "entry" to tt-fr-doc-line.fact-qnty in frame {&frame-name} .
      return no-apply .
    end.

    if input frame {&frame-name} tt-fr-doc-line.fact-qnty <> tt-fr-doc-line.fact-qnty then do:
      
/*      if v-lgas-gds                                                                                                         */
/*      then do:                                                                                                              */
/*        message "Для СУГ запрещено менять фактическое кол-во. Кол-во проставляется по документам сверки." view-as alert-box.*/
/*        assign                                                                                                              */
/*          tt-fr-doc-line.fact-qnty:screen-value = string (tt-fr-doc-line.fact-qnty)                                         */
/*        .                                                                                                                   */
/*                                                                                                                            */
/*        return no-apply.                                                                                                    */
/*      end.                                                                                                                  */
      
      assign
        frame {&frame-name} tt-fr-doc-line.fact-qnty
      .

      assign
        tt-fr-doc-line.fact-qnty-kg = tt-fr-doc-line.fact-qnty * tt-fr-doc-line.fact-density
      .

      display
        tt-fr-doc-line.fact-qnty-kg when tt-fr-doc-line.fact-qnty-kg :visible = true
        tt-fr-doc-line.fact-density when tt-fr-doc-line.fact-density :visible = true
        with frame {&frame-name} .

      run disp-total in this-procedure .

      if varrvs-place = true
        and not ( last-event :event-type   = "progress":u
                  and last-event :widget-enter = b-place :handle
                )
      then do:
        run edit-doc-pl in this-procedure
          ( input {&autoupdate}
          ).
      end.
    end.
  end.
end.

on return of tt-fr-doc-line.num-place in frame {&frame-name} do:
   apply "entry" to tt-fr-doc-line.wt-brutto in frame {&frame-name}.
   return no-apply.
end.

on leave of tt-fr-doc-line.num-place in frame {&frame-name} do:
  if keyfunction(lastkey) <> "end-error"
    and not ( last-event:event-type   = "progress":u
              and last-event:widget-enter = b-quit:handle
            )
  then do:
    if input frame {&frame-name} tt-fr-doc-line.num-place <> tt-fr-doc-line.num-place then do:
      assign
        frame {&frame-name} tt-fr-doc-line.num-place
      .
      assign
        tt-fr-doc-line.wt-brutto = tt-fr-doc-line.num-place * tt-fr-doc-line.wt-place
      .
      display
        tt-fr-doc-line.wt-brutto
        with frame {&frame-name}.
    end.
  end.
end.

on return of tt-fr-doc-line.wt-brutto in frame {&frame-name} do:
   apply "entry" to b-save in frame {&frame-name}.
   return no-apply.
end.

on leave of tt-fr-doc-line.wt-brutto in frame {&frame-name} do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type   = "progress":u and last-event:widget-enter = b-quit:handle) then do:
   if input frame {&frame-name} tt-fr-doc-line.wt-brutto <> tt-fr-doc-line.wt-brutto then do:
      assign frame {&frame-name} tt-fr-doc-line.wt-brutto.
      assign tt-fr-doc-line.wt-place = tt-fr-doc-line.wt-brutto / tt-fr-doc-line.num-place.
      display tt-fr-doc-line.wt-place with frame {&frame-name}.
   end.
end.
end.

on return of tt-fr-doc-line.wt-place in frame {&frame-name} do:
   apply "entry" to tt-fr-doc-line.wt-brutto in frame {&frame-name}.
   return no-apply.
end.

on leave of tt-fr-doc-line.wt-place in frame {&frame-name} do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type   = "progress":u and last-event:widget-enter = b-quit:handle) then do:
   if input frame {&frame-name} tt-fr-doc-line.wt-place <> tt-fr-doc-line.wt-place then do:
      assign frame {&frame-name} tt-fr-doc-line.wt-place.
      assign  tt-fr-doc-line.wt-brutto = tt-fr-doc-line.num-place * tt-fr-doc-line.wt-place.
      display tt-fr-doc-line.wt-brutto with frame {&frame-name}.
   end.
end.
end.

on return of road-tax-cli in frame {&frame-name} do:
   apply "entry" to b-save in frame {&frame-name}.
   return no-apply.
end.

on leave of road-tax-cli in frame {&frame-name} do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type   = "progress":u and last-event:widget-enter = b-quit:handle) then do:
   if input frame {&frame-name} road-tax-cli <> road-tax-cli then do:
      run check-price in this-procedure no-error.
      if error-status :error then do:
         display road-tax-cli with frame {&frame-name}.
         return no-apply.
      end.
      assign frame {&frame-name} road-tax-cli.
      run calc-all in this-procedure ( input vartax-3-calc ) no-error.
      if error-status :error then return no-apply.
   end.
end.
end.

on return of tt-fr-doc-line.doc-density in frame {&frame-name} do:
   apply "entry" to tt-fr-doc-line.temperature   in frame {&frame-name}.
   return no-apply.
end.

on leave of tt-fr-doc-line.doc-density in frame {&frame-name} do:

  if keyfunction(lastkey) <> "end-error"
    and not ( last-event :event-type   = "progress":u
              and (last-event :widget-enter = b-quit :handle 
              or last-event :widget-enter = b-docsec :handle)
            )
  then do:
    if input frame {&frame-name} tt-fr-doc-line.doc-density = 0 or
       input frame {&frame-name} tt-fr-doc-line.doc-density = ?
    then do:
      message "Укажите плотность вещества." view-as alert-box error .
      return no-apply .
    end.

    if Valid-Density( input frame {&frame-name} tt-fr-doc-line.doc-density, (buf_goods.unit-base = buf_goods.unit-cli)  ) <> true then do:
      message
        "Плотность должна быть в диапазоне больше 0 и меньше 1."
        view-as alert-box error .
      return no-apply .
    end.
    if v-gds-ptrl-densities <> "" and v-gds-ptrl-densities <> ? then do:
       if (input frame {&frame-name} tt-fr-doc-line.doc-density) < v-min-dens
       or (input frame {&frame-name} tt-fr-doc-line.doc-density) > v-max-dens
       then do:
          message
            substitute("Введенное значение плотности находится вне заданного диапазона: &1.",
            v-gds-ptrl-densities )
            view-as alert-box error .
          return no-apply .
       end.
    end.

    if input frame {&frame-name} tt-fr-doc-line.doc-density <> tt-fr-doc-line.doc-density then do:
      assign
        frame {&frame-name} tt-fr-doc-line.doc-density
      .
      assign
        tt-fr-doc-line.fact-density  = tt-fr-doc-line.doc-density
        tt-fr-doc-line.cli-base-rate = 1 / tt-fr-doc-line.doc-density
      .
      run calc-all in this-procedure
        ( input vardensity-calc
        ) no-error .
      if error-status :error then do:
        return no-apply .
      end.

      if varrvs-place = true
        and not ( last-event :event-type   = "progress":u
                  and last-event :widget-enter = b-place :handle
                )
      then do:
        find first tt-doc-pl
          no-error .
        if available tt-doc-pl then do:
          run edit-doc-pl in this-procedure
            ( input {&autoupdate} + {&delim-par} + "update-dens":U
            ).
        end.
        else do:
          run edit-doc-pl in this-procedure
            ( input {&autoupdate}
            ).
        end.
      end.
    end.
  end.
end.

on return of tt-fr-doc-line.temperature in frame {&frame-name} do:

  if tt-fr-doc-line.doc-qnty :sensitive in frame {&frame-name} then do:
    apply "entry" to tt-fr-doc-line.doc-qnty in frame {&frame-name} .
    return no-apply .
  end.

  if tt-fr-doc-line.price-cli:sensitive then do:
    apply "entry" to tt-fr-doc-line.price-cli in frame {&frame-name}.
    return no-apply.
  end.

  if tt-fr-doc-line.price-rubl :sensitive in frame {&frame-name} then do:
    apply "entry" to tt-fr-doc-line.price-rubl in frame {&frame-name} .
    return no-apply .
  end.

   if tt-fr-doc-line.tot-cli:sensitive then do:
     apply "entry" to tt-fr-doc-line.tot-cli in frame {&frame-name}.
     return no-apply.
   end.

  apply "entry" to b-save in frame {&frame-name}.
  return no-apply.
end.

on leave of tt-fr-doc-line.temperature in frame {&frame-name} do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type   = "progress":u and last-event:widget-enter = b-quit:handle) then do:
   assign frame {&frame-name} tt-fr-doc-line.temperature.
end.
end.

on return of tt-fr-doc-line.unit-cli in frame {&frame-name} do:
  apply "entry" to tt-fr-doc-line.cli-base-rate in frame {&frame-name}.
  return no-apply.
end.

on leave of tt-fr-doc-line.unit-cli in frame {&frame-name} do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type   = "progress":u and last-event:widget-enter = b-quit:handle) then do:
  if input frame {&frame-name} tt-fr-doc-line.unit-cli <> tt-fr-doc-line.unit-cli then do:
    run chg-unit in this-procedure no-error.
    if error-status :error then do:
      return no-apply.
    end.
  end .
end.
end.

on choose of r-units in frame {&frame-name}
do:
  { gbl/stdbtn.i }
  run proc-units in this-procedure .
  run chg-unit in this-procedure no-error.
  if error-status :error then do:
    return no-apply.
  end.
  else do :
    apply "entry":U to tt-fr-doc-line.cli-base-rate .
    apply "leave":U to tt-fr-doc-line.cli-base-rate . // чтобы пересчиталась закупочная цена
  end .
end.

on return of tt-fr-doc-line.cli-base-rate in frame {&frame-name} do:
  if tt-fr-doc-line.price-cli:sensitive in frame {&frame-name} then do:
    apply "entry" to tt-fr-doc-line.price-cli.
    return no-apply.
  end.
  if tt-fr-doc-line.tot-cli:sensitive in frame {&frame-name} then do:
    apply "entry" to tt-fr-doc-line.price-cli.
    return no-apply.
  end.
end.

on leave of tt-fr-doc-line.cli-base-rate in frame {&frame-name} do:

  if keyfunction(lastkey) <> "end-error"
    and not (last-event:event-type   = "progress":u and last-event:widget-enter = b-quit:handle)
  then do:
    if input frame {&frame-name} tt-fr-doc-line.cli-base-rate = 0
      or input frame {&frame-name} tt-fr-doc-line.cli-base-rate = ?
    then do:
      message "Не указан коэффициент пересчета единиц измерения." view-as alert-box.
      apply "entry" to tt-fr-doc-line.cli-base-rate in frame {&frame-name}.
      return no-apply.
    end.
    assign
      frame {&frame-name} tt-fr-doc-line.cli-base-rate
    .
    assign
      tt-fr-doc-line.doc-density = 1 / tt-fr-doc-line.cli-base-rate
    .
    run calc-all in this-procedure
      ( input varcli-base-rate-calc
      ) no-error.
    if error-status :error then do:
      return no-apply.
    end.
  end.
end.

on return of tt-fr-doc-line.vat-pc in frame {&frame-name} do:
  apply "entry" to b-save in frame {&frame-name}.
  return no-apply.
end.

on return of tt-fr-doc-line.slt-pc in frame {&frame-name} do:
  apply "entry" to b-save in frame {&frame-name}.
  return no-apply.
end.

on leave of tt-fr-doc-line.vat-pc or
   leave of tt-fr-doc-line.slt-pc in frame {&frame-name} do:
define variable v-new-vat-pc as decimal no-undo .
if keyfunction( lastkey ) <> "end-error" and
   not ( last-event :event-type = "progress":u and last-event :widget-enter = b-quit :handle ) then do:
  v-new-vat-pc = input frame {&frame-name} tt-fr-doc-line.vat-pc .
  if v-new-vat-pc <> tt-fr-doc-line.vat-pc or
     input frame {&frame-name} tt-fr-doc-line.slt-pc <> tt-fr-doc-line.slt-pc then do:
   if vat-sumvalue <> "yes" then do:
      run p-chk-vat in this-procedure (v-new-vat-pc) no-error .
      if error-status :error then do:
     display tt-fr-doc-line.vat-pc tt-fr-doc-line.slt-pc with frame {&frame-name}.
     apply "entry" to self in frame {&frame-name}.
     return no-apply.
      end.
   end.
   assign frame {&frame-name} tt-fr-doc-line.vat-pc
          frame {&frame-name} tt-fr-doc-line.slt-pc.
   run calc-all in this-procedure ( input ( if varprice-cli-input = yes then varprice-cli-calc
                                                                        else varbase-price-calc ) ) no-error.
   if error-status :error then do:
     display tt-fr-doc-line.vat-pc tt-fr-doc-line.slt-pc with frame {&frame-name}.
     apply "entry" to self in frame {&frame-name}.
     return no-apply.
   end.
  end.
     
end.
end.


on return of tt-fr-doc-line.new-price-sale in frame {&frame-name} do:
  apply "entry" to tt-fr-doc-line.new-price-sale in frame {&frame-name}.
  return no-apply.
end.

on return of tt-fr-doc-line.price-prod in frame {&frame-name} do:
  apply "entry" to tt-fr-doc-line.price-prod in frame {&frame-name}.
  return no-apply.
end.
on return of tt-fr-doc-line.price-prod-vat in frame {&frame-name} do:
  apply "entry" to tt-fr-doc-line.price-prod-vat in frame {&frame-name}.
  return no-apply.
end.



on leave of tt-fr-doc-line.new-price-sale in frame {&frame-name} do:
if keyfunction( lastkey ) <> "end-error" and
   not ( last-event :event-type = "progress":u and last-event :widget-enter = b-quit :handle ) then do:
  if input frame {&frame-name} tt-fr-doc-line.new-price-sale   <>  tt-fr-doc-line.new-price-sale  then do:
      run lineattr-write in this-procedure (
          t-doc.doc-code ,
          buf_goods.gds-code ,
          {&lineattr-corr-price-sale},
          string(tt-fr-doc-line.new-price-sale)
          ).
      tt-fr-doc-line.price-corr = 1.
     display b-corr-price-sale with frame {&frame-name} .
     assign tt-fr-doc-line.new-price-sale .
  end.
end.
end.

on leave of tt-fr-doc-line.price-prod in frame {&frame-name} do:
if keyfunction( lastkey ) <> "end-error" and
   not ( last-event :event-type = "progress":u and last-event :widget-enter = b-quit :handle ) then do:
  if input frame {&frame-name} tt-fr-doc-line.price-prod  <>  tt-fr-doc-line.price-prod  then do:
      run lineattr-write in this-procedure (
          t-doc.doc-code ,
          buf_goods.gds-code ,
          {&lineattr-price-prod},
          string(tt-fr-doc-line.price-prod)
          ).
     assign tt-fr-doc-line.price-prod .
  end.
end.
end.
on leave of tt-fr-doc-line.price-prod-vat in frame {&frame-name} do:
if keyfunction( lastkey ) <> "end-error" and
   not ( last-event :event-type = "progress":u and last-event :widget-enter = b-quit :handle ) then do:
  if input frame {&frame-name} tt-fr-doc-line.price-prod-vat  <>  tt-fr-doc-line.price-prod-vat  then do:
      run lineattr-write in this-procedure (
          t-doc.doc-code ,
          buf_goods.gds-code ,
          {&lineattr-price-prod-vat},
          string(tt-fr-doc-line.price-prod-vat)
          ).
     assign tt-fr-doc-line.price-prod-vat .
  end.
end.
end.




on return of sum-vat in frame {&frame-name} do:
   apply "entry" to b-save in frame {&frame-name}.
   return no-apply.
end.

on leave of sum-vat in frame {&frame-name} do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type   = "progress":u and last-event:widget-enter = b-quit:handle) then do:
   if input frame {&frame-name} sum-vat <> sum-vat and sum-vat <> ? then do:      /*проверка на вопрос, чтобы пока экран не прорисован не было проверок*/
     if tt-fr-doc-line.price-cli <> 0 and
        input frame {&frame-name} sum-vat >=
        (tt-fr-doc-line.cli-qnty * tt-fr-doc-line.price-cli -
         (if t-doc.vat-type = {&inc-vat} then input frame {&frame-name} sum-vat else 0))
        then do:
        message "НДС не может быть больше 99.999...%" skip
                "НДС:" input frame {&frame-name} sum-vat skip
                "Сумма:" tt-fr-doc-line.cli-qnty * tt-fr-doc-line.price-cli
                view-as alert-box error.
        display sum-vat with frame {&frame-name}.
        return no-apply.
     end.
     else do:
       if input frame {&frame-name} sum-vat = 0.00 then do:
          varlog = no.
          message "Вы хотите установить НДС в 0?"
          view-as alert-box question buttons yes-no update varlog.
          if varlog = yes then do:
             assign frame {&frame-name} sum-vat.
             run calc-vat-pc in this-procedure.
             run calc-all in this-procedure ( input ( if varprice-cli-input = yes then varprice-cli-calc
                                                                                  else varbase-price-calc ) ) no-error.
             if error-status :error then return no-apply.
          end.
          else do:
              display sum-vat with frame {&frame-name}.
              return no-apply.
          end.
       end.
       else do:
          assign frame {&frame-name} sum-vat.
          run calc-vat-pc in this-procedure.
          run p-chk-vat  in this-procedure (tt-fr-doc-line.vat-pc) .
          run calc-all in this-procedure ( input ( if varprice-cli-input = yes then varprice-cli-calc
                                                                               else varbase-price-calc ) ) no-error.
          if error-status :error then do:
            return no-apply.
          end.
       end.
     end.
   end.
end.
end.

on return of tt-fr-doc-line.price-cli  in frame {&frame-name} or
   return of tt-fr-doc-line.price-rubl in frame {&frame-name} or
   return of tt-fr-doc-line.tot-cli    in frame {&frame-name}
   do:
  if b-prt:sensitive in frame {&frame-name} then apply "entry" to b-prt in frame {&frame-name}.
  else do:
    if lookup({&serial}, tt-fr-doc-line.unit-type) > 0 and
       b-parts:sensitive in frame {&frame-name}     then
       apply "entry" to b-parts in frame {&frame-name}.
    else do:
      if custvalue = "yes" then
         apply "entry" to tt-fr-doc-line.wt-brutto in frame {&frame-name}.
         else do:
             if road-tax-cli:sensitive in frame {&frame-name} then apply "entry" to road-tax-cli in frame {&frame-name}.
                                                              else apply "entry" to b-save       in frame {&frame-name}.
         end.
    end.
  end.
  return no-apply.
end.

on leave of tt-fr-doc-line.price-cli in frame {&frame-name} do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type   = "progress":u and last-event:widget-enter = b-quit:handle) then do:
  if input frame {&frame-name} tt-fr-doc-line.price-cli <> tt-fr-doc-line.price-cli then do:
     run check-price in this-procedure no-error.
     if error-status :error then return no-apply.
     assign frame {&frame-name} tt-fr-doc-line.price-cli.
     run calc-all in this-procedure ( input varprice-cli-calc ) no-error.
     if error-status :error then return no-apply.
  end.
end.
end.

on leave of tt-fr-doc-line.tot-cli in frame {&frame-name} do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type   = "progress":u and last-event:widget-enter = b-quit:handle) then do:
  if input frame {&frame-name} tt-fr-doc-line.tot-cli <> tt-fr-doc-line.tot-cli then do:
     run check-price in this-procedure no-error.
     if error-status :error then return no-apply.
     assign frame {&frame-name} tt-fr-doc-line.tot-cli.
     assign
     tt-fr-doc-line.price-cli = tt-fr-doc-line.tot-cli / tt-fr-doc-line.cli-qnty.
     run calc-all in this-procedure ( input varprice-cli-calc ) no-error.
     if error-status :error then return no-apply.
  end.
end.
end.


on leave of tt-fr-doc-line.price-rubl in frame {&frame-name} do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type   = "progress":u and last-event:widget-enter = b-quit:handle) then do:
  if input frame {&frame-name} tt-fr-doc-line.price-rubl <> tt-fr-doc-line.price-rubl then do:
     run check-price in this-procedure no-error.
     if error-status :error then return no-apply.
     assign frame {&frame-name} tt-fr-doc-line.price-rubl.
     run calc-all in this-procedure ( input varbase-price-calc ) no-error.
     if error-status :error then return no-apply.
  end.
end.
end.

on leave of tt-fr-doc-line.cst-code in frame {&frame-name} do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type   = "progress":u and last-event:widget-enter = b-quit:handle) then do:
   if input frame {&frame-name} tt-fr-doc-line.cst-code <> tt-fr-doc-line.cst-code then do:
      assign frame {&frame-name} tt-fr-doc-line.cst-code.
   end.
end.
end.


on leave of tt-fr-doc-line.last-date in frame {&frame-name} do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type = "progress":u and last-event:widget-enter = b-quit:handle) then do:
   if input frame {&frame-name} tt-fr-doc-line.last-date <> tt-fr-doc-line.last-date then do:
      assign frame {&frame-name} tt-fr-doc-line.last-date.
      run godendo-date-to-offset in this-procedure (  input today,
                                                      input tt-fr-doc-line.last-date,
                                                     output tt-fr-doc-line.last-num-day ).
      display tt-fr-doc-line.last-num-day with frame {&frame-name}.
   end.
end.
end.

on leave of tt-fr-doc-line.last-num-day in frame {&frame-name} do:
if keyfunction(lastkey) <> "end-error" and
   not (last-event:event-type = "progress":u and last-event:widget-enter = b-quit:handle) then do:
   if input frame {&frame-name} tt-fr-doc-line.last-num-day <> tt-fr-doc-line.last-num-day then do:
      assign frame {&frame-name} tt-fr-doc-line.last-num-day.
      run godendo-offset-to-date in this-procedure (  input today,
                                                      input tt-fr-doc-line.last-num-day,
                                                     output tt-fr-doc-line.last-date ).
      display tt-fr-doc-line.last-date with frame {&frame-name}.
   end.
end.
end.


on choose of r-country in frame {&frame-name}
do:
  { gbl/stdbtn.i }
  run proc-country-code in this-procedure no-error.
end.

on value-changed of tt-fr-doc-line.type-inp-vat in frame {&frame-name} do:
if keyfunction( lastkey ) <> "end-error" and
   not (last-event :event-type = "progress":u and last-event :widget-enter = b-quit :handle ) then do:
   run v-c-type-inp-vat in this-procedure no-error.
   if error-status :error then do:
     display tt-fr-doc-line.type-inp-vat with frame {&frame-name}.
     return no-apply.
   end.
end.
end.


on choose of b-prt in frame d-in-line /* Шкала */
do:
  { gbl/stdbtn.i }

  run save-action in this-procedure
    ( input "light":U
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.
tr:
do transaction on error undo, leave:
   if parline-mode <> {&lookup} then do:
      find first ub.doc-line where recid(ub.doc-line) = line-rec.
      for each old-doc-line:
          delete old-doc-line.
      end.
      create old-doc-line.
      buffer-copy ub.doc-line to old-doc-line.
      release ub.doc-line.
   end.
   if t-doc.flag_ = no and t-doc.status_ <> {&fact} then
        run str/doc-p.p
            (parparentproc
            ,pardoc-rec
            ,line-rec
            ,recid(buf_goods)
            ,prt-mode )
            no-error.
      else run str/fac-p.p
            (parparentproc
            ,pardoc-rec
            ,line-rec
            ,recid(buf_goods)
            ,prt-mode )
            no-error.

   if error-status :error then undo tr, return no-apply.
   if parline-mode <> {&lookup} then do:
    /* Пересчитываем накладную */
    run update-doc-line in this-procedure no-error.
    if error-status :error then undo tr, return no-apply.
   end.
end.
run ui-on in this-procedure. /* должно стоять здесь, т.к. перерисовывает экранную форму */
if parline-mode <> {&lookup} then do:

  { str/prslnew.i
      "run"
      pr-genmrg
      pr-naklvalue
      t-doc.doc-code
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      tt-fr-doc-line.price-rubl
      tt-fr-doc-line.price-base
      tt-fr-doc-line.price-rubl
      tt-fr-doc-line.price-base
      tt-fr-doc-line.new-price-sale
      no-error }
      if error-status :error then
      message
        error-status :get-message(1) skip
        return-value skip
        "Нельзя рассчитать новую цену продажи"
        view-as alert-box error
      .
      run disp-total in this-procedure .
end.
if b-save :sensitive then apply "entry" to b-save in frame {&frame-name}.
else apply "entry" to b-quit in frame {&frame-name}.
end.

on choose of b-addinf in frame {&frame-name}
do:

  { gbl/stdbtn.i }
  
  define buffer bf_rvs-doc     for ub.rvs-doc .
  define buffer bf_rvs-line    for ub.rvs-line .

  define variable v-new-fact-qnty        like ub.doc-line.fact-qnty    no-undo .
  define variable v-new-density          like ub.doc-line.fact-density no-undo .
  define variable v-new-cli-fact-qnty    like ub.doc-line.fact-qnty    no-undo .
  define variable ii as integer no-undo .
  define variable choice as integer no-undo .
  define variable v-kpsecs as character no-undo .
  define variable v-kpsecs-nomeas as character no-undo .
  
  define variable vAccMethChoosed as logical no-undo .
  define variable v-need-measure as logical no-undo init no .

  assign
    v-new-fact-qnty     = tt-fr-doc-line.fact-qnty
    v-new-density       = tt-fr-doc-line.fact-density
    v-new-cli-fact-qnty = tt-fr-doc-line.fact-qnty-kg
  .
  infoSectionsTotal:DocQntyLine = tt-fr-doc-line.doc-qnty.
  infoSectionsTotal:DocDensLine = tt-fr-doc-line.doc-density.
  infoSectionsTotal:DocCliLine = tt-fr-doc-line.cli-qnty.
  infoSectionsTotal:FlagTrn = t-doc.flag_.
  
  if infoSectionsTotal:IsKP
  and parline-mode <> {&lookup}
  then do :
    vAccMethChoosed = yes .
    do ii = 1 to infoSectionsTotal:SectionNum : 
      infoSecObj = infoSectionsTotal:GetInfoSectionProp(ii) .
      if infoSecObj:IsKP
      then do :
        if infoSecObj:AccMeth = ?
        then do :
          vAccMethChoosed = no .
        end .
        assign v-kpsecs = v-kpsecs + infoSecObj:SectionName + " с " + buf_goods.gds-name + ", " .
      end .
      if infoSecObj:KPnoMeas
      then do :
        assign v-kpsecs-nomeas = v-kpsecs-nomeas + infoSecObj:SectionName + " с " + buf_goods.gds-name + ", " .
      end .
      if infoSectionsTotal:IsSGDKK
      then do :
        v-need-measure = no .
      end .
      else do :
        if not infoSecObj:KPnoMeas
        and (not (infoSecObj:TankWeight > 0)
        or infoSecObj:TankWeight = ?
        or infoSecObj:TankDensity = ?)
        then do :
          v-need-measure = yes .
        end .
      end .
    end .
    assign
      v-kpsecs = trim(v-kpsecs, ", ")
      v-kpsecs-nomeas = trim(v-kpsecs-nomeas, ", ")
    .
    if not vAccMethChoosed
    and infoSectionsTotal:IsActnComm
    then do :
      if v-kpsecs > ""
      then do :
        run gbl/d-askw.w (
           input "Выбор способа выполнения комиссионного приёма"
          ,input ("Для секций " + v-kpsecs + " требуется комиссионный прием. Каким способом будет выполняться комиссионный прием?")
          ,input "|^"
          ,input "Замеры в АЦ" + (if v-kpsecs-nomeas > "" then "^disable" else "") + "|По сверкам|Отмена"
          ,input "Выполнение комиссионного приёма стандартным способом по замерам в автоцистерне|Выполнение комиссионного приёма по данным сверок в резервуаре|Отказ от выбора способа"
          ,input 1
          ,input 3
          ,output choice).
        case choice :
          when 1
          then do :
/*            if v-kpsecs-nomeas > ""                                                                                                                                                                 */
/*            then do :                                                                                                                                                                               */
/*              message "Для секций " + v-kpsecs-nomeas + " установлен флаг «Переход к комиссионному приему НП без замеров секции АЦ». Невозможно провести замеры в АЦ. Выберите способ «По сверкам»!"*/
/*              view-as alert-box .                                                                                                                                                                   */
/*              return no-apply .                                                                                                                                                                     */
/*            end .                                                                                                                                                                                   */
            kpsecs_ :
            do ii = 1 to infoSectionsTotal:SectionNum :
              infoSecObj = infoSectionsTotal:GetInfoSectionProp(ii) .
              if infoSecObj:isKP
              then do :
                infoSecObj:AccMeth = 0 .
              end .
            end .
          end .
          when 2
          then do :
            kpsecs_ :
            do ii = 1 to infoSectionsTotal:SectionNum :
              infoSecObj = infoSectionsTotal:GetInfoSectionProp(ii) .
              if infoSecObj:isKP
              then do :
                infoSecObj:AccMeth = 1 .
                infoSectionsTotal:IsKPrvs = yes .
              end .
            end .
          end .
          when 3
          then do :
            return no-apply .
          end .
        end case .
      end .
      infoSectionsTotal:SaveDB() .
      
      find first buf_rvs-doc no-lock where buf_rvs-doc.out-code = t-doc.doc-code no-error.
      if not available buf_rvs-doc
      and not v-need-measure
      then do :
        run cr-rvs-doc in this-procedure:instantiating-procedure
          ( input parparentproc
           ,input t-doc.doc-code
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute("Ошибка при создании документов сверок.") skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
      end .
    end .
  end .
  
  
  run proc-b-addinfo in this-procedure
    ( input        parparentproc
     ,input        ( if parline-mode <> {&lookup} then {&update} else {&lookup} )
     ,input        tt-fr-doc-line.doc-code
     ,input        buf_goods.gds-code
     ,input        stfactplvalue
     ,input        varauto-tank
     ,input        varupd-fact-qnty
     ,input        tt-fr-doc-line.doc-qnty
     ,input        tt-fr-doc-line.doc-density
     ,input-output v-new-fact-qnty
     ,input-output v-new-density
     ,input-output v-new-cli-fact-qnty
     ,input-output infoSectionsTotal
     ,input-output v-prt-start-real-date
     ,input-output v-prt-start-real-time
     ,input-output v-prt-end-real-date
     ,input-output v-prt-end-real-time
    ) no-error .

  if error-status :error then do:
    message
      substitute("Ошибка при изменении дополнительной информации.") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return no-apply .
  end.

  if tt-fr-doc-line.fact-qnty <> v-new-fact-qnty
    or tt-fr-doc-line.fact-qnty-kg <> v-new-cli-fact-qnty
  then do:
    run correct-fact-qnty in this-procedure
      ( input v-new-fact-qnty
       ,input v-new-density
      ) no-error .
/*    if infoSectionsTotal:IsKPrvs then isKPrvsSet = yes .*/
  end.
  run display-b-rvs in this-procedure
    no-error .
  run display-measure in this-procedure
    no-error .

  display
    tt-fr-doc-line.fact-qnty
    tt-fr-doc-line.fact-qnty-kg when tt-fr-doc-line.fact-qnty-kg :visible = true
    tt-fr-doc-line.fact-density when tt-fr-doc-line.fact-density :visible = true
    with frame {&frame-name} .

end.

on choose of b-docsec in frame {&frame-name}
do:

  { gbl/stdbtn.i }

  define variable v-new-fact-qnty        like ub.doc-line.fact-qnty    no-undo .
  define variable v-new-density          like ub.doc-line.fact-density no-undo .
  define variable v-new-cli-fact-qnty    like ub.doc-line.fact-qnty    no-undo .
  define variable v-edit-doc-pl-mode as character no-undo .
  define variable d_fact-qnty     as decimal   no-undo initial 0.00 .
  define variable d_doc-qnty      as decimal   no-undo initial 0.00 .
  define variable d_cli-fact-qnty as decimal   no-undo initial 0.00 .
  define variable d_cli-doc-qnty  as decimal   no-undo initial 0.00 .
  
  define variable pl_fact-qnty     as decimal   no-undo initial 0.00 .
  define variable pl_doc-qnty      as decimal   no-undo initial 0.00 .
  define variable pl_cli-qnty      as decimal   no-undo initial 0.00 .
  define variable pl_doc-density   as decimal   no-undo initial 0.00 .
  define variable pl_fact-density  as decimal   no-undo initial 0.00 .
  define variable pl-list          as character no-undo initial "" .

  define variable v-log            as logical   no-undo .
  define variable pl-setted        as logical no-undo init false .
  define variable ii               as integer no-undo .
  define variable pl               as integer no-undo .
  
  define buffer tmp_doc-line-attr for ub.doc-line-attr .

  assign
    v-new-fact-qnty     = tt-fr-doc-line.fact-qnty
    v-new-density       = tt-fr-doc-line.fact-density
    v-new-cli-fact-qnty = tt-fr-doc-line.fact-qnty-kg
  .
  if parline-mode <> {&add-def}
  or v-is-looksec
  then
    infoSectionsTotal:GetDBAllAttr().

  empty temp-table tt-old-list-tank .
  for each tmp_doc-line-attr no-lock where tmp_doc-line-attr.doc-code = t-doc.doc-code
                                       and tmp_doc-line-attr.gds-code = buf_goods.gds-code
                                       and tmp_doc-line-attr.attr-code begins "list-tank" :
    create tt-old-list-tank .
    buffer-copy tmp_doc-line-attr to tt-old-list-tank .
  end .
  infoSectionsTotal:PlChanged = no .
  
  if not valid-object(tanksForm)
  then
    tanksForm = new ibs.th.str.ptrl.forms.tanksections(infoSectionsTotal).
  wait-for tanksForm:ShowDialog().

   
  /*run str/in-ladd.w
    ( input        parParentProc
     ,input        parline-mode
     ,input        infoSectionsTotal:TrnDocNum
     ,input        infoSectionsTotal:GdsCode
     ,input-output InfoSectionsTotal
     ,output was_setting
    ) no-error .
  if error-status :error then do:
    return no-apply.
  end.*/
  
  if v-is-looksec
  then do :
    if parline-mode ne {&lookup}
    then
       infoSectionsTotal:SaveDBNoCheck() .
    infoSectionsTotal:WasSetting = true . 
  end .

  if infoSectionsTotal:WasSetting = false 
  then infoSectionsTotal:GetDBAllAttr().
  else do:
  
    do ii = 1 to infoSectionsTotal:SectionNum :
      infoSectionsTotal:GetInfoSectionProp (ii).
      if infoSectionsTotal:FlagTrn = no
      then do :
        infoSectionsTotal:InfoSectionCurr:FactQnty = infoSectionsTotal:InfoSectionCurr:DocQnty.
        infoSectionsTotal:InfoSectionCurr:FactDensity = infoSectionsTotal:InfoSectionCurr:DocDensity.
      end .
      if lookup(infoSectionsTotal:InfoSectionCurr:ListTank, pl-list) = 0
      then do :
        pl-list = pl-list + "," + infoSectionsTotal:InfoSectionCurr:ListTank .
      end .
    end .
    pl-list = trim(pl-list, ",") .
    
    if infoSectionsTotal:PlChanged
    then do :
      for each tt-doc-pl :
        delete tt-doc-pl .
      end .
    end .
    
    infoSectionsTotal:CalculateTotal().

    if not infoSectionsTotal:CliQntyInput then do:
      tt-fr-doc-line.doc-density:screen-value = string (infoSectionsTotal:DocDensityAvg).
      tt-fr-doc-line.doc-qnty:screen-value = string (infoSectionsTotal:DocQntyTotal).
      if input frame {&frame-name} tt-fr-doc-line.doc-qnty <> tt-fr-doc-line.doc-qnty
      then do:
        assign
          frame {&frame-name} tt-fr-doc-line.doc-qnty
        .
        run calc-all in this-procedure
          ( input vardoc-qnty-calc
          ) no-error.
        if error-status :error then do:
          return no-apply .
        end.
        if trim(pl-list) = ""
        then do :
          run str/doc-pls.w
            ( input parparentproc
             ,input ({&autoupdate})
             ,input (if t-doc.status_ = {&wayb} and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input buf_goods.gds-code
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-density
             ,input tt-fr-doc-line.cli-qnty
             ,input tt-fr-doc-line.doc-qnty
             ,input tt-fr-doc-line.fact-qnty
             ,input tt-fr-doc-line.doc-qnty  * tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-qnty * tt-fr-doc-line.fact-density
             ,input ?
             ,input ?
             ,input ?
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при разбиении кол-ва по местам хранения." skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
        end .
        else
        do pl = 1 to num-entries(pl-list) :
          assign
            pl_cli-qnty   = 0
            pl_doc-qnty   = 0
            pl_fact-qnty  = 0
          .
          sect_ :
          do ii = 1 to infoSectionsTotal:SectionNum :
            infoSectionsTotal:GetInfoSectionProp (ii).
            if infoSectionsTotal:InfoSectionCurr:ListTank <> entry(pl, pl-list)
            then
              next sect_ .
              
            assign
              pl_cli-qnty   = pl_cli-qnty + (infoSectionsTotal:InfoSectionCurr:DocDensity * infoSectionsTotal:InfoSectionCurr:DocQnty)
              pl_doc-qnty   = pl_doc-qnty + infoSectionsTotal:InfoSectionCurr:DocQnty
              pl_fact-qnty  = pl_fact-qnty + infoSectionsTotal:InfoSectionCurr:FactQnty
            .
          end . 
          pl_doc-density = pl_cli-qnty / pl_doc-qnty .
          pl_fact-density = pl_cli-qnty / pl_fact-qnty no-error .
          
          run str/doc-pls.w
            ( input parparentproc
             ,input ({&autoupdate} + {&delim-par} + {&delim-par} + "place=" + entry(pl, pl-list))
             ,input (if t-doc.status_ = {&wayb} and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input infoSectionsTotal:GdsCode
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input pl_doc-density
             ,input (if pl_fact-density > 0 then pl_fact-density else pl_doc-density)
             ,input pl_cli-qnty
             ,input pl_doc-qnty
             ,input pl_fact-qnty
             ,input pl_doc-qnty * pl_doc-density
             ,input pl_fact-qnty * pl_fact-density
             ,input ?
             ,input ?
             ,input ?
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при разбиении кол-ва по местам хранения." skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
          pl-setted = yes .
        end .
      end .
      if input frame {&frame-name} tt-fr-doc-line.doc-density <> tt-fr-doc-line.doc-density
      then do:
        assign
          frame {&frame-name} tt-fr-doc-line.doc-density
        .
        assign
          tt-fr-doc-line.fact-density  = tt-fr-doc-line.doc-density
          tt-fr-doc-line.cli-base-rate = 1 / tt-fr-doc-line.doc-density
        .
        run calc-all in this-procedure
          ( input vardensity-calc
          ) no-error .
        if error-status :error then do:
          return no-apply .
        end.
        if trim(pl-list) = ""
        then do :
          run str/doc-pls.w
            ( input parparentproc
             ,input ({&autoupdate} + {&delim-par} + "update-dens":U)
             ,input (if t-doc.status_ = {&wayb} and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input buf_goods.gds-code
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-density
             ,input tt-fr-doc-line.cli-qnty
             ,input tt-fr-doc-line.doc-qnty
             ,input tt-fr-doc-line.fact-qnty
             ,input tt-fr-doc-line.doc-qnty  * tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-qnty * tt-fr-doc-line.fact-density
             ,input ?
             ,input ?
             ,input ?
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при разбиении кол-ва по местам хранения." skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
        end .
        else
        do pl = 1 to num-entries(pl-list) :
          assign
            pl_cli-qnty   = 0
            pl_doc-qnty   = 0
            pl_fact-qnty  = 0
          .
          sect_ :
          do ii = 1 to infoSectionsTotal:SectionNum :
            infoSectionsTotal:GetInfoSectionProp (ii).
            if infoSectionsTotal:InfoSectionCurr:ListTank <> entry(pl, pl-list)
            then
              next sect_ .
              
            assign
              pl_cli-qnty   = pl_cli-qnty + (infoSectionsTotal:InfoSectionCurr:DocDensity * infoSectionsTotal:InfoSectionCurr:DocQnty)
              pl_doc-qnty   = pl_doc-qnty + infoSectionsTotal:InfoSectionCurr:DocQnty
              pl_fact-qnty  = pl_fact-qnty + infoSectionsTotal:InfoSectionCurr:FactQnty
            .
          end . 
          pl_doc-density = pl_cli-qnty / pl_doc-qnty .
          pl_fact-density = pl_cli-qnty / pl_fact-qnty no-error .
          
          run str/doc-pls.w
            ( input parparentproc
             ,input ({&autoupdate} + {&delim-par} + "update-dens":U + {&delim-par} + "place=" + entry(pl, pl-list))
             ,input (if t-doc.status_ = {&wayb} and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input infoSectionsTotal:GdsCode
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-density
             ,input pl_cli-qnty
             ,input pl_doc-qnty
             ,input pl_fact-qnty
             ,input pl_doc-qnty * pl_doc-density
             ,input pl_fact-qnty * pl_fact-density
             ,input ?
             ,input ?
             ,input ?
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при разбиении кол-ва по местам хранения." skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
          pl-setted = yes .
        end .
      end .
    end.
    if not infoSectionsTotal:DensityInput then do:
      tt-fr-doc-line.doc-qnty:screen-value = string (infoSectionsTotal:DocQntyTotal).
      tt-fr-doc-line.cli-qnty:screen-value = string (infoSectionsTotal:CliQntyTotal).
      if input frame {&frame-name} tt-fr-doc-line.doc-qnty <> tt-fr-doc-line.doc-qnty
      then do:
        assign
          frame {&frame-name} tt-fr-doc-line.doc-qnty
        .
        run calc-all in this-procedure
          ( input vardoc-qnty-calc
          ) no-error.
        if error-status :error then do:
          return no-apply .
        end.
        if trim(pl-list) = ""
        then do :
          run str/doc-pls.w
            ( input parparentproc
             ,input ({&autoupdate})
             ,input (if t-doc.status_ = {&wayb} and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input buf_goods.gds-code
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-density
             ,input tt-fr-doc-line.cli-qnty
             ,input tt-fr-doc-line.doc-qnty
             ,input tt-fr-doc-line.fact-qnty
             ,input tt-fr-doc-line.doc-qnty  * tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-qnty * tt-fr-doc-line.fact-density
             ,input ?
             ,input ?
             ,input ?
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при разбиении кол-ва по местам хранения." skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
        end .
        else
        do pl = 1 to num-entries(pl-list) :
          assign
            pl_cli-qnty   = 0
            pl_doc-qnty   = 0
            pl_fact-qnty  = 0
          .
          sect_ :
          do ii = 1 to infoSectionsTotal:SectionNum :
            infoSectionsTotal:GetInfoSectionProp (ii).
            if infoSectionsTotal:InfoSectionCurr:ListTank <> entry(pl, pl-list)
            then
              next sect_ .
              
            assign
              pl_cli-qnty   = pl_cli-qnty + infoSectionsTotal:InfoSectionCurr:CliQnty
              pl_doc-qnty   = pl_doc-qnty + infoSectionsTotal:InfoSectionCurr:DocQnty
              pl_fact-qnty  = pl_fact-qnty + infoSectionsTotal:InfoSectionCurr:FactQnty
            .
          end . 
          pl_doc-density = pl_cli-qnty / pl_doc-qnty .
          pl_fact-density = pl_cli-qnty / pl_fact-qnty no-error .
          
          run str/doc-pls.w
            ( input parparentproc
             ,input ({&autoupdate} + {&delim-par} + {&delim-par} + "place=" + entry(pl, pl-list))
             ,input (if t-doc.status_ = {&wayb} and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input infoSectionsTotal:GdsCode
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input pl_doc-density
             ,input (if pl_fact-density > 0 then pl_fact-density else pl_doc-density)
             ,input pl_cli-qnty
             ,input pl_doc-qnty
             ,input pl_fact-qnty
             ,input pl_doc-qnty * pl_doc-density
             ,input pl_fact-qnty * pl_fact-density
             ,input ?
             ,input ?
             ,input ?
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при разбиении кол-ва по местам хранения." skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
          pl-setted = yes .
        end .
      end .
      if input frame {&frame-name} tt-fr-doc-line.cli-qnty <> tt-fr-doc-line.cli-qnty
      then do:
        assign
          frame {&frame-name} tt-fr-doc-line.cli-qnty
        .
        run calc-all    in this-procedure ( input varcli-qnty-calc ) no-error .
        if error-status :error then return no-apply.
        run calc-vat-pc in this-procedure.
        
        assign
          v-edit-doc-pl-mode = {&autoupdate}
        .
        if is-petrolium = yes
          and is-pieces = no
          and tt-fr-doc-line.cli-qnty :sensitive in frame {&frame-name}
          and tt-fr-doc-line.doc-qnty :sensitive in frame {&frame-name}
        then do:
          assign
            v-edit-doc-pl-mode = v-edit-doc-pl-mode + {&delim-par} + "update-dens-cli":U
          .
        end.
        else do :
          assign
            v-edit-doc-pl-mode = v-edit-doc-pl-mode + {&delim-par}
          .
        end .
        if trim(pl-list) = ""
        then do :
          v-edit-doc-pl-mode = trim(v-edit-doc-pl-mode, {&delim-par}) .
          run str/doc-pls.w
            ( input parparentproc
             ,input (v-edit-doc-pl-mode)
             ,input (if t-doc.status_ = {&wayb} and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input buf_goods.gds-code
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-density
             ,input tt-fr-doc-line.cli-qnty
             ,input tt-fr-doc-line.doc-qnty
             ,input tt-fr-doc-line.fact-qnty
             ,input tt-fr-doc-line.doc-qnty  * tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-qnty * tt-fr-doc-line.fact-density
             ,input ?
             ,input ?
             ,input ?
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при разбиении кол-ва по местам хранения." skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
        end .
        else
        do pl = 1 to num-entries(pl-list) :
          assign
            pl_cli-qnty   = 0
            pl_doc-qnty   = 0
            pl_fact-qnty  = 0
          .
          sect_ :
          do ii = 1 to infoSectionsTotal:SectionNum :
            infoSectionsTotal:GetInfoSectionProp (ii).
            if infoSectionsTotal:InfoSectionCurr:ListTank <> entry(pl, pl-list)
            then
              next sect_ .
              
            assign
              pl_cli-qnty   = pl_cli-qnty + infoSectionsTotal:InfoSectionCurr:CliQnty
              pl_doc-qnty   = pl_doc-qnty + infoSectionsTotal:InfoSectionCurr:DocQnty
              pl_fact-qnty  = pl_fact-qnty + infoSectionsTotal:InfoSectionCurr:FactQnty
            .
          end . 
          pl_doc-density = pl_cli-qnty / pl_doc-qnty .
          pl_fact-density = pl_cli-qnty / pl_fact-qnty no-error .
          
          run str/doc-pls.w
            ( input parparentproc
             ,input (v-edit-doc-pl-mode + {&delim-par} + "place=" + entry(pl, pl-list))
             ,input (if t-doc.status_ = {&wayb} and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input infoSectionsTotal:GdsCode
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input pl_doc-density
             ,input (if pl_fact-density > 0 then pl_fact-density else pl_doc-density)
             ,input pl_cli-qnty
             ,input pl_doc-qnty
             ,input pl_fact-qnty
             ,input pl_doc-qnty * pl_doc-density
             ,input pl_fact-qnty * pl_fact-density
             ,input ?
             ,input ?
             ,input ?
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при разбиении кол-ва по местам хранения." skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
          pl-setted = yes .
        end .
      end .
    end.
    if not infoSectionsTotal:DocQntyInput then do:
      tt-fr-doc-line.doc-density:screen-value = string (infoSectionsTotal:DocDensityAvg).
      tt-fr-doc-line.cli-qnty:screen-value = string (infoSectionsTotal:CliQntyTotal).
      if input frame {&frame-name} tt-fr-doc-line.cli-qnty <> tt-fr-doc-line.cli-qnty
      then do:
        assign
          frame {&frame-name} tt-fr-doc-line.cli-qnty
        .
        run calc-all    in this-procedure ( input varcli-qnty-calc ) no-error .
        if error-status :error then return no-apply.
        run calc-vat-pc in this-procedure.
        
        assign
          v-edit-doc-pl-mode = {&autoupdate}
        .
        if is-petrolium = yes
          and is-pieces = no
          and tt-fr-doc-line.cli-qnty :sensitive in frame {&frame-name}
          and tt-fr-doc-line.doc-qnty :sensitive in frame {&frame-name}
        then do:
          assign
            v-edit-doc-pl-mode = v-edit-doc-pl-mode + {&delim-par} + "update-dens-cli":U
          .
        end.
        else do :
          assign
            v-edit-doc-pl-mode = v-edit-doc-pl-mode + {&delim-par}
          .
        end .
        if trim(pl-list) = ""
        then do :
          v-edit-doc-pl-mode = trim(v-edit-doc-pl-mode, {&delim-par}) .
          run str/doc-pls.w
            ( input parparentproc
             ,input (v-edit-doc-pl-mode)
             ,input (if t-doc.status_ = {&wayb} and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input buf_goods.gds-code
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-density
             ,input tt-fr-doc-line.cli-qnty
             ,input tt-fr-doc-line.doc-qnty
             ,input tt-fr-doc-line.fact-qnty
             ,input tt-fr-doc-line.doc-qnty  * tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-qnty * tt-fr-doc-line.fact-density
             ,input ?
             ,input ?
             ,input ?
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при разбиении кол-ва по местам хранения." skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
        end .
        else
        do pl = 1 to num-entries(pl-list) :
          assign
            pl_cli-qnty   = 0
            pl_doc-qnty   = 0
            pl_fact-qnty  = 0
          .
          sect_ :
          do ii = 1 to infoSectionsTotal:SectionNum :
            infoSectionsTotal:GetInfoSectionProp (ii).
            if infoSectionsTotal:InfoSectionCurr:ListTank <> entry(pl, pl-list)
            then
              next sect_ .
              
            assign
              pl_cli-qnty   = pl_cli-qnty + infoSectionsTotal:InfoSectionCurr:CliQnty
              pl_doc-qnty   = pl_doc-qnty + infoSectionsTotal:InfoSectionCurr:DocQnty
              pl_fact-qnty  = pl_fact-qnty + infoSectionsTotal:InfoSectionCurr:FactQnty
            .
          end . 
          pl_doc-density = pl_cli-qnty / pl_doc-qnty .
          pl_fact-density = pl_cli-qnty / pl_fact-qnty no-error .
          
          run str/doc-pls.w
            ( input parparentproc
             ,input (v-edit-doc-pl-mode + {&delim-par} + "place=" + entry(pl, pl-list))
             ,input (if t-doc.status_ = {&wayb} and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input infoSectionsTotal:GdsCode
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input pl_doc-density
             ,input (if pl_fact-density > 0 then pl_fact-density else pl_doc-density)
             ,input pl_cli-qnty
             ,input pl_doc-qnty
             ,input pl_fact-qnty
             ,input pl_doc-qnty * pl_doc-density
             ,input pl_fact-qnty * pl_fact-density
             ,input ?
             ,input ?
             ,input ?
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при разбиении кол-ва по местам хранения." skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
          pl-setted = yes .
        end.
      end.
      if input frame {&frame-name} tt-fr-doc-line.doc-density <> tt-fr-doc-line.doc-density
      then do:
        assign
          frame {&frame-name} tt-fr-doc-line.doc-density
        .
        assign
          tt-fr-doc-line.fact-density  = tt-fr-doc-line.doc-density
          tt-fr-doc-line.cli-base-rate = 1 / tt-fr-doc-line.doc-density
        .
        run calc-all in this-procedure
          ( input vardensity-calc
          ) no-error .
        if error-status :error then do:
          return no-apply .
        end.
        if trim(pl-list) = ""
        then do :
          run str/doc-pls.w
            ( input parparentproc
             ,input ({&autoupdate} + {&delim-par} + "update-dens":U)
             ,input (if t-doc.status_ = {&wayb} and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input buf_goods.gds-code
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-density
             ,input tt-fr-doc-line.cli-qnty
             ,input tt-fr-doc-line.doc-qnty
             ,input tt-fr-doc-line.fact-qnty
             ,input tt-fr-doc-line.doc-qnty  * tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-qnty * tt-fr-doc-line.fact-density
             ,input ?
             ,input ?
             ,input ?
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при разбиении кол-ва по местам хранения." skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
        end .
        else
        do pl = 1 to num-entries(pl-list) :
          assign
            pl_cli-qnty   = 0
            pl_doc-qnty   = 0
            pl_fact-qnty  = 0
          .
          sect_ :
          do ii = 1 to infoSectionsTotal:SectionNum :
            infoSectionsTotal:GetInfoSectionProp (ii).
            if infoSectionsTotal:InfoSectionCurr:ListTank <> entry(pl, pl-list)
            then
              next sect_ .
              
            assign
              pl_cli-qnty   = pl_cli-qnty + infoSectionsTotal:InfoSectionCurr:CliQnty
              pl_doc-qnty   = pl_doc-qnty + infoSectionsTotal:InfoSectionCurr:DocQnty
              pl_fact-qnty  = pl_fact-qnty + infoSectionsTotal:InfoSectionCurr:FactQnty
            .
          end . 
          pl_doc-density = pl_cli-qnty / pl_doc-qnty .
          pl_fact-density = pl_cli-qnty / pl_fact-qnty no-error .
          
          run str/doc-pls.w
            ( input parparentproc
             ,input ({&autoupdate} + {&delim-par} + "update-dens":U + {&delim-par} + "place=" + entry(pl, pl-list))
             ,input (if t-doc.status_ = {&wayb} and t-doc.flag_ = false then "doc":U else "fact":U )
             ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
             ,input t-doc.doc-code
             ,input infoSectionsTotal:GdsCode
             ,input tt-fr-doc-line.unit-cli
             ,input tt-fr-doc-line.cli-base-rate
             ,input tt-fr-doc-line.doc-density
             ,input tt-fr-doc-line.fact-density
             ,input pl_cli-qnty
             ,input pl_doc-qnty
             ,input pl_fact-qnty
             ,input pl_doc-qnty * pl_doc-density
             ,input pl_fact-qnty * pl_fact-density
             ,input ?
             ,input ?
             ,input ?
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при разбиении кол-ва по местам хранения." skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
          pl-setted = yes .
        end .
      end .
    end.
    
    if infoSectionsTotal:PlChanged
    and not pl-setted
    and trim(pl-list) > ""
    then do :
      do pl = 1 to num-entries(pl-list) :
        assign
          pl_cli-qnty   = 0
          pl_doc-qnty   = 0
          pl_fact-qnty  = 0
        .
        sect_ :
        do ii = 1 to infoSectionsTotal:SectionNum :
          infoSectionsTotal:GetInfoSectionProp (ii).
          if infoSectionsTotal:InfoSectionCurr:ListTank <> entry(pl, pl-list)
          then
            next sect_ .
            
          assign
            pl_cli-qnty   = pl_cli-qnty + (infoSectionsTotal:InfoSectionCurr:DocDensity * infoSectionsTotal:InfoSectionCurr:DocQnty)
            pl_doc-qnty   = pl_doc-qnty + (infoSectionsTotal:InfoSectionCurr:DocDensity * infoSectionsTotal:InfoSectionCurr:DocQnty / tt-fr-doc-line.doc-density)
            pl_fact-qnty  = pl_fact-qnty + (infoSectionsTotal:InfoSectionCurr:FactDensity * infoSectionsTotal:InfoSectionCurr:FactQnty / tt-fr-doc-line.fact-density)
          .
        end . 
        pl_doc-density = pl_cli-qnty / pl_doc-qnty .
        pl_fact-density = pl_cli-qnty / pl_fact-qnty no-error .
        
        run str/doc-pls.w
          ( input parparentproc
           ,input ({&autoupdate} + {&delim-par} + {&delim-par} + "place=" + entry(pl, pl-list))
           ,input (if t-doc.status_ = {&wayb} and t-doc.flag_ = false then "doc":U else "fact":U )
           ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
           ,input t-doc.doc-code
           ,input infoSectionsTotal:GdsCode
           ,input tt-fr-doc-line.unit-cli
           ,input tt-fr-doc-line.cli-base-rate
           ,input pl_doc-density
           ,input (if pl_fact-density > 0 then pl_fact-density else pl_doc-density)
           ,input pl_cli-qnty
           ,input pl_doc-qnty
           ,input pl_fact-qnty
           ,input pl_doc-qnty * pl_doc-density
           ,input pl_fact-qnty * pl_fact-density
           ,input ?
           ,input ?
           ,input ?
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при разбиении кол-ва по местам хранения." skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        pl-setted = yes .
      end .
    end .
    
    if parline-mode <> {&lookup} then do:
  
      for each tt-doc-pl no-lock
      on error undo, return no-apply
      :
        assign
          d_fact-qnty     = d_fact-qnty     + tt-doc-pl.fact-qnty
          d_doc-qnty      = d_doc-qnty      + tt-doc-pl.doc-qnty
          d_cli-fact-qnty = d_cli-fact-qnty + tt-doc-pl.cli-fact-qnty
          d_cli-doc-qnty  = d_cli-doc-qnty  + tt-doc-pl.cli-doc-qnty
        .
      end. /* for each next_doc-pl */
  
      if tt-fr-doc-line.doc-qnty <> d_doc-qnty
        or
        ( tt-fr-doc-line.doc-qnty :sensitive in frame {&FRAME-NAME} = true
           and absolute( tt-fr-doc-line.cli-qnty - d_cli-doc-qnty ) < 0.0011
        )
        or
        ( tt-fr-doc-line.cli-qnty :sensitive in frame {&FRAME-NAME} = true
          and tt-fr-doc-line.cli-qnty <> d_cli-doc-qnty
        )
      then do:
          assign
            tt-fr-doc-line.doc-qnty = d_doc-qnty
            tt-fr-doc-line.cli-qnty = d_cli-doc-qnty
            tt-fr-doc-line.doc-density = tt-fr-doc-line.cli-qnty / tt-fr-doc-line.doc-qnty
          .
          display
            tt-fr-doc-line.doc-qnty
            tt-fr-doc-line.cli-qnty
            tt-fr-doc-line.doc-density
            with frame {&FRAME-NAME} .
      end.
  
      if varupd-fact-qnty = true
        and not( t-doc.status_ = {&wayb}
                 and t-doc.flag_ = false
               )
        and ( tt-fr-doc-line.fact-qnty <> d_fact-qnty
              or absolute( tt-fr-doc-line.fact-qnty-kg - d_cli-fact-qnty ) < 0.0011
            )
      then do:
          assign
            tt-fr-doc-line.fact-qnty    = d_fact-qnty
            tt-fr-doc-line.fact-qnty-kg = d_cli-fact-qnty
            tt-fr-doc-line.fact-density = tt-fr-doc-line.fact-qnty-kg / tt-fr-doc-line.fact-qnty
          .
          display
            tt-fr-doc-line.fact-qnty
            tt-fr-doc-line.fact-qnty-kg
            tt-fr-doc-line.fact-density
            with frame {&FRAME-NAME}
          .
      end.
  
      run check-place-rsrv in this-procedure
        no-error .
      if error-status :error
      then do:
        tanksForm:dispose() .
        if valid-object(tanksForm)
        and tanksForm:isDisposed
        then
          delete object tanksForm .
        return no-apply  .
      end.
  
    end. /* if line-mode <> {&lookup} */
/*    end .                                                                                  */
/*    else do :                                                                              */
/*      if not infoSectionsTotal:CliQntyInput then do:                                       */
/*        tt-fr-doc-line.doc-density:screen-value = string (infoSectionsTotal:DocDensityAvg).*/
/*        tt-fr-doc-line.doc-qnty:screen-value = string (infoSectionsTotal:DocQntyTotal).    */
/*        apply "leave" to tt-fr-doc-line.doc-qnty in frame {&frame-name} .                  */
/*        apply "leave" to tt-fr-doc-line.doc-density in frame {&frame-name} .               */
/*      end.                                                                                 */
/*      if not infoSectionsTotal:DensityInput then do:                                       */
/*        tt-fr-doc-line.doc-qnty:screen-value = string (infoSectionsTotal:DocQntyTotal).    */
/*        tt-fr-doc-line.cli-qnty:screen-value = string (infoSectionsTotal:CliQntyTotal).    */
/*        apply "leave" to tt-fr-doc-line.doc-qnty in frame {&frame-name} .                  */
/*        apply "leave" to tt-fr-doc-line.cli-qnty in frame {&frame-name} .                  */
/*      end.                                                                                 */
/*      if not infoSectionsTotal:DocQntyInput then do:                                       */
/*        tt-fr-doc-line.doc-density:screen-value = string (infoSectionsTotal:DocDensityAvg).*/
/*        tt-fr-doc-line.cli-qnty:screen-value = string (infoSectionsTotal:CliQntyTotal).    */
/*        apply "leave" to tt-fr-doc-line.cli-qnty in frame {&frame-name} .                  */
/*        apply "leave" to tt-fr-doc-line.doc-density in frame {&frame-name} .               */
/*      end.                                                                                 */
/*    end.                                                                                   */
  end.
  
/*     ,input-output v-new-fact-qnty*/
/*     ,input-output v-new-density*/
/*     ,input-output v-new-cli-fact-qnty*/


/*  display                                                                       */
/*    tt-fr-doc-line.fact-qnty                                                    */
/*    tt-fr-doc-line.fact-qnty-kg when tt-fr-doc-line.fact-qnty-kg :visible = true*/
/*    with frame {&frame-name} .                                                  */
  tanksForm:dispose() .
  if valid-object(tanksForm)
  and tanksForm:isDisposed
  then
    delete object tanksForm .
end.

/* Атрибуты алкогольной продукции */
on choose of b-alc-attr in frame {&frame-name} do:

  define variable save-flag  as logical   no-undo.
  define buffer buf_parts for ub.parts .
  { gbl/stdbtn.i }

  /* Если у строки накладной больше одной партии, то корректировка
     атрибутов алкогольной продукции разрешена только в списке партий */
  if tt-fr-doc-line.alc-multi-parts then do:
    message "Данная строка накладной содержит несколько партий." skip
            "Используйте режим корректировки партий для просмотра/изменения " +
            "атрибутов алкогольной продукции."
    view-as alert-box information.
    return no-apply.
  end.
find first buf_parts where buf_parts.obj-type  = t-doc.obj-type           and
                          buf_parts.obj-code  = t-doc.obj-code           and
                          buf_parts.prod-type = tt-fr-doc-line.prod-type and
                          buf_parts.prod-code = tt-fr-doc-line.prod-code and
                          buf_parts.artic     = tt-fr-doc-line.artic     and
                          buf_parts.out-code  = t-doc.doc-code           no-lock no-error.
                          
  do on error undo, return no-apply:
    run str/in-alc.w
      (input        parParentProc
      ,input        (if parline-mode <> {&lookup} then {&update} else {&lookup})
      ,input buf_goods.gds-code
      ,buffer buf_parts
      ,input-output tt-fr-doc-line.alc-mark-db-num
      ,input-output tt-fr-doc-line.alc-mark-code
      ,input-output tt-fr-doc-line.alc-bottling-date
      ,input-output tt-fr-doc-line.alc-ref-ab-path
      ,input-output tt-fr-doc-line.alc-quality-certif-path
      ,input-output tt-fr-doc-line.alc-certif-path
      ,input-output tt-fr-doc-line.alc-imp-type
      ,input-output tt-fr-doc-line.alc-imp-code
      ,output       save-flag
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> '':u
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры in-alc.w" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return no-apply .
    end.
  end.
end.

on choose of menu-item m-rvs-bf-1 in menu m-rvs-bf
do:
  { gbl/stdbtn.i b-rvs-bf }
  assign 
      rvslog = no.
  find first buf_rvs-doc 
    where buf_rvs-doc.rvs-type = {&rvs-before-doc}
      and buf_rvs-doc.out-code = t-doc.doc-code
      and num-entries(buf_rvs-doc.rvs-code, "-") = 2
      and buf_rvs-doc.state-measure-qnty <> ?
      no-error .

  if available buf_rvs-doc then 
  do: 
    if not chk-asi-polling (yes)
      then return no-apply .

    message
        "Сверка до уже выполнена. Вы уверены, что хотите ее изменить?"  skip
        view-as alert-box question buttons YES-NO update rvslog.
    if not rvslog then
      return no-apply.
  end.            

  disable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame {&frame-name} .
  if v-is-lgas or v-is-lgas-corr
  then do:
    hide b-addinf in frame {&frame-name}.
  end .
  run action-rvs-line in this-procedure
      ( input {&update}
      ,input "meas":U
      ,input {&rvs-before-doc}
      ,output var-code-temp
      ) no-error .
  if error-status :error then 
  do:
    enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame {&frame-name} .
    if v-is-lgas or v-is-lgas-corr
    then do:
      hide b-addinf in frame {&frame-name}.
    end .
    return.
  end.

  run adm/shattri.p (
     input "get":U
     ,input  v-cntxt-obj-type
     ,input  v-cntxt-obj-code
     ,input  {&attr-petrol}
     ,input  {&attr-petrol_block-nozzle} /*p-param-code*/
     ,output v-value-character
     ,output v-value-date
     ,output v-value-decimal
     ,output v-value-integer
     ,output v-value-logical
     ,output v-param-type
     ,INPUT-OUTPUT table-handle v-tth
     ) no-error .
  if v-value-logical then 
  do:
    list-pl = "" .
    for each tt-doc-pl where tt-doc-pl.pl-code = var-code-temp,
        each ub.pl-gds-pump no-lock where ub.pl-gds-pump.gds-code = tt-doc-pl.gds-code and
             ub.pl-gds-pump.obj-code = tt-doc-pl.obj-code and
             ub.pl-gds-pump.obj-type = tt-doc-pl.obj-type and
             ub.pl-gds-pump.pl-code = tt-doc-pl.pl-code,
        each ub.pl-pump-nozzle  no-lock where ub.pl-pump-nozzle.obj-code = ub.pl-gds-pump.obj-code and
             ub.pl-pump-nozzle.obj-type = ub.pl-gds-pump.obj-type and
             ub.pl-pump-nozzle.pl-code = ub.pl-gds-pump.pl-code and
             ub.pl-pump-nozzle.pump-code = ub.pl-gds-pump.pump-code:
      list-pl = substitute("&1&2&3:&4:&5", list-pl, 
                 if list-pl = "" then "" else ";",
                 ub.pl-pump-nozzle.nozzle-code,
                 ub.pl-pump-nozzle.pump-code,
                 ub.pl-pump-nozzle.pl-code).
    end.

    run str/diallog.w ( input parparentproc
        ,input this-procedure
        ,input 'str/get-block-nozzle.p':U
        ,input (v-cntxt-obj-type + {&delim-par} +
        string(v-cntxt-obj-code) + {&delim-par} +
        string(0) + {&delim-par} +  /*p-remote */
        string(0) + {&delim-par} + /*p-shft-close*/
        {&delim-par} +
        {&delim-par} +
        {&delim-par} +
        substitute("&1,&2"
        ,"block"
        ,list-pl))
        ,input yes
        ,input ''
        ,input 'Блокировка пистолетов')
        no-error.
    if error-status :error then 
    do:
      enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame {&frame-name} .
      if v-is-lgas or v-is-lgas-corr
      then do:
        hide b-addinf in frame {&frame-name}.
      end .
      return no-apply .
    end.
     

    if return-value begins "Для кассы" then 
    do:
      message return-value
      view-as alert-box question buttons yes-no update v-ok as logical  .
      if v-ok then run block-nozzle ( parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, list-pl ).
      else do:
        message "Сообщите в службу поддержки о неуспешной попытке блокировки пистолетов"
        view-as alert-box.
        enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame {&frame-name} .
        if v-is-lgas or v-is-lgas-corr
        then do:
          hide b-addinf in frame {&frame-name}.
        end .
        return no-apply.
      end.
    end.
    else 
    do:
      message "Блокировка пистолетов прошла успешно"
      view-as alert-box.
    end.   
  end.

  run display-measure in this-procedure
    no-error .

  enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame {&frame-name} .
  if v-is-lgas or v-is-lgas-corr
  then do:
    hide b-addinf in frame {&frame-name}.
  end .
  if b-save :sensitive in frame {&frame-name} then do:
    apply "ENTRY":U to b-save in frame {&frame-name} .
  end.
  else do:
    apply "ENTRY":U to b-quit in frame {&frame-name} .
  end.
end.


on choose of menu-item m-rvs-af-1 in menu m-rvs-af
do:
  { gbl/stdbtn.i b-rvs-af }

  if not chk-asi-polling (no)
    then return no-apply .

  disable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame {&frame-name} .
  if v-is-lgas or v-is-lgas-corr
  then do:
    hide b-addinf in frame {&frame-name}.
  end .
  run action-rvs-line in this-procedure
    ( input {&update}
     ,input "meas":U
     ,input {&rvs-after-doc}
     ,output var-code-temp
    ) no-error .
  if error-status :error then do:
    enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame {&frame-name} .
    if v-is-lgas or v-is-lgas-corr
    then do:
      hide b-addinf in frame {&frame-name}.
    end .
    return no-apply .
  end.
  
  run adm/shattri.p (
     input "get":U
     ,input  v-cntxt-obj-type
     ,input  v-cntxt-obj-code
     ,input  {&attr-petrol}
     ,input  {&attr-petrol_block-nozzle} /*p-param-code*/
     ,output v-value-character
     ,output v-value-date
     ,output v-value-decimal
     ,output v-value-integer
     ,output v-value-logical
     ,output v-param-type
     ,INPUT-OUTPUT table-handle v-tth
     ) no-error .
  
  if v-value-logical then 
  do:
    list-pl = "" .
    for each tt-doc-pl where tt-doc-pl.pl-code = var-code-temp,
      each ub.pl-gds-pump no-lock where ub.pl-gds-pump.gds-code = tt-doc-pl.gds-code and
      ub.pl-gds-pump.obj-code = tt-doc-pl.obj-code and
      ub.pl-gds-pump.obj-type = tt-doc-pl.obj-type and
      ub.pl-gds-pump.pl-code = tt-doc-pl.pl-code,
      each ub.pl-pump-nozzle  no-lock where ub.pl-pump-nozzle.obj-code = ub.pl-gds-pump.obj-code and
      ub.pl-pump-nozzle.obj-type = ub.pl-gds-pump.obj-type and
      ub.pl-pump-nozzle.pl-code = ub.pl-gds-pump.pl-code and
      ub.pl-pump-nozzle.pump-code = ub.pl-gds-pump.pump-code:
        list-pl = substitute("&1&2&3:&4:&5", list-pl, 
                   if list-pl = "" then "" else ";",
                   ub.pl-pump-nozzle.nozzle-code,
                   ub.pl-pump-nozzle.pump-code,
                   ub.pl-pump-nozzle.pl-code).
    end.


    run str/diallog.w ( input parparentproc
      ,input this-procedure
      ,input 'str/get-block-nozzle.p':U
      ,input (v-cntxt-obj-type + {&delim-par} +
      string(v-cntxt-obj-code) + {&delim-par} +
      string(0) + {&delim-par} +  /*p-remote */
      string(0) + {&delim-par} + /*p-shft-close*/
      {&delim-par} +
      {&delim-par} +
      {&delim-par} +
      substitute("&1,&2"
      ,"unblock"
      ,list-pl))
      ,input yes
      ,input ''
      ,input 'Разблокировка выбранных пистолетов') .
    if not error-status:error then 
    do:
      if return-value begins "Для кассы" then 
      do:
         message return-value
            view-as alert-box question buttons yes-no update v-ok as logical  .
         if v-ok then run unblock-nozzle ( parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, list-pl ).
         else message "Сообщите в службу поддержки о неуспешной попытке разблокировки пистолетов"
               view-as alert-box.
               
      end.
      else 
      do:
         message if return-value begins "Ошибка" then return-value else "Разблокировка пистолетов прошла успешно" 
           view-as alert-box.
      end.   

    end.
    else 
    do:
      enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame {&frame-name} .
      if v-is-lgas or v-is-lgas-corr
      then do:
        hide b-addinf in frame {&frame-name}.
      end .
      return no-apply .   
    end.
      
  end.

  run display-measure in this-procedure
    no-error .

  enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame {&frame-name} .
  if v-is-lgas or v-is-lgas-corr
  then do:
    hide b-addinf in frame {&frame-name}.
  end .
  if b-save :sensitive in frame {&frame-name} then do:
    apply "entry" to b-save in frame {&frame-name} .
  end.
  else do:
    apply "entry" to b-quit in frame {&frame-name} .
  end.
end.


on choose of menu-item m-rvs-bf-2 in menu m-rvs-bf
or choose of b-rvs-bf in frame {&frame-name}
do:
  { gbl/stdbtn.i b-rvs-bf }

  run action-rvs-line in this-procedure
    ( input {&lookup}
     ,input "edit":U
     ,input {&rvs-before-doc}
     ,output var-code-temp
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.
end.

on choose of menu-item m-rvs-af-2 in menu m-rvs-af
or choose of b-rvs-af in frame {&frame-name}
do:
  { gbl/stdbtn.i b-rvs-af }

  run action-rvs-line in this-procedure
    ( input {&lookup}
     ,input "edit":U
     ,input {&rvs-after-doc}
     ,output var-code-temp
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.

end.

on choose of menu-item m-rvs-bf-3 in menu m-rvs-bf
do:
  { gbl/stdbtn.i b-rvs-bf }
  disable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame {&frame-name} .
  if v-is-lgas or v-is-lgas-corr
  then do:
    hide b-addinf in frame {&frame-name}.
  end .
  run action-rvs-line in this-procedure
    ( input {&update}
     ,input "edit":U
     ,input {&rvs-before-doc}
     ,output var-code-temp
    ) no-error .
  if error-status :error then do:
    enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame {&frame-name} .
    if v-is-lgas or v-is-lgas-corr
    then do:
      hide b-addinf in frame {&frame-name}.
    end .
    return no-apply .
  end.
  
  run adm/shattri.p (
      input "get":U
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  {&attr-petrol}
      ,input  {&attr-petrol_block-nozzle} /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .

  if v-value-logical then 
  do:
  
    list-pl = "" .
    for each tt-doc-pl where tt-doc-pl.pl-code = var-code-temp,
       each ub.pl-gds-pump no-lock where ub.pl-gds-pump.gds-code = tt-doc-pl.gds-code and
       ub.pl-gds-pump.obj-code = tt-doc-pl.obj-code and
       ub.pl-gds-pump.obj-type = tt-doc-pl.obj-type and
       ub.pl-gds-pump.pl-code = tt-doc-pl.pl-code,
       each ub.pl-pump-nozzle  no-lock where ub.pl-pump-nozzle.obj-code = ub.pl-gds-pump.obj-code and
       ub.pl-pump-nozzle.obj-type = ub.pl-gds-pump.obj-type and
       ub.pl-pump-nozzle.pl-code = ub.pl-gds-pump.pl-code and
       ub.pl-pump-nozzle.pump-code = ub.pl-gds-pump.pump-code:
      list-pl = substitute("&1&2&3:&4:&5", list-pl, 
                 if list-pl = "" then "" else ";",
                 ub.pl-pump-nozzle.nozzle-code,
                 ub.pl-pump-nozzle.pump-code,
                 ub.pl-pump-nozzle.pl-code).
    end.

    run str/diallog.w ( input parparentproc
       ,input this-procedure
       ,input 'str/get-block-nozzle.p':U
       ,input (v-cntxt-obj-type + {&delim-par} +
       string(v-cntxt-obj-code) + {&delim-par} +
       string(0) + {&delim-par} +  /*p-remote */
       string(0) + {&delim-par} + /*p-shft-close*/
       {&delim-par} +
       {&delim-par} +
       {&delim-par} +
       substitute("&1,&2"
       ,"block"
       ,list-pl))
       ,input yes
       ,input ''
       ,input 'Блокировка пистолетов') .
    if not error-status:error then 
    do:
      if return-value begins "Для кассы" then 
      do:
        message return-value
           view-as alert-box question buttons yes-no update v-ok as logical  .
        if v-ok then run block-nozzle  in this-procedure ( parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, list-pl ).
        else message "Сообщите в службу поддержки о неуспешной попытке блокировки пистолетов"
              view-as alert-box.
      end.
      else 
      do:
        message if return-value begins "Ошибка" then return-value else "Блокировка пистолетов прошла успешно" 
        view-as alert-box.
      end.   
    end.
    else 
    do:
      enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame {&frame-name} .
      if v-is-lgas or v-is-lgas-corr
      then do:
        hide b-addinf in frame {&frame-name}.
      end .
      return no-apply .   
    end.
  end.
  run display-measure in this-procedure
    no-error .
  enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame {&frame-name} .
  if v-is-lgas or v-is-lgas-corr
  then do:
    hide b-addinf in frame {&frame-name}.
  end .
end.

on choose of menu-item m-rvs-af-3 in menu m-rvs-af
do:
  { gbl/stdbtn.i b-rvs-af }
  disable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame {&frame-name} .
  if v-is-lgas or v-is-lgas-corr
  then do:
    hide b-addinf in frame {&frame-name}.
  end .
  run action-rvs-line in this-procedure
    ( input {&update}
     ,input "edit":U
     ,input {&rvs-after-doc}
     ,output var-code-temp
    ) no-error .
  if error-status :error then do:
    enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame {&frame-name} .
    if v-is-lgas or v-is-lgas-corr
    then do:
      hide b-addinf in frame {&frame-name}.
    end .
    return no-apply .
  end.
  
  run adm/shattri.p (
      input "get":U
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  {&attr-petrol}
      ,input  {&attr-petrol_block-nozzle} /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .

  if v-value-logical then 
  do:
  
    list-pl = "" .
    for each tt-doc-pl where tt-doc-pl.pl-code = var-code-temp,
       each ub.pl-gds-pump no-lock where ub.pl-gds-pump.gds-code = tt-doc-pl.gds-code and
       ub.pl-gds-pump.obj-code = tt-doc-pl.obj-code and
       ub.pl-gds-pump.obj-type = tt-doc-pl.obj-type and
       ub.pl-gds-pump.pl-code = tt-doc-pl.pl-code,
       each ub.pl-pump-nozzle  no-lock where ub.pl-pump-nozzle.obj-code = ub.pl-gds-pump.obj-code and
       ub.pl-pump-nozzle.obj-type = ub.pl-gds-pump.obj-type and
       ub.pl-pump-nozzle.pl-code = ub.pl-gds-pump.pl-code and
       ub.pl-pump-nozzle.pump-code = ub.pl-gds-pump.pump-code:
      list-pl = substitute("&1&2&3:&4:&5", list-pl, 
                 if list-pl = "" then "" else ";",
                 ub.pl-pump-nozzle.nozzle-code,
                 ub.pl-pump-nozzle.pump-code,
                 ub.pl-pump-nozzle.pl-code).
    end.

    run str/diallog.w ( input parparentproc
       ,input this-procedure
       ,input 'str/get-block-nozzle.p':U
       ,input (v-cntxt-obj-type + {&delim-par} +
       string(v-cntxt-obj-code) + {&delim-par} +
       string(0) + {&delim-par} +  /*p-remote */
       string(0) + {&delim-par} + /*p-shft-close*/
       {&delim-par} +
       {&delim-par} +
       {&delim-par} +
       substitute("&1,&2"
       ,"unblock"
       ,list-pl))
       ,input yes
       ,input ''
       ,input 'Разблокировка выбранных пистолетов') .
    if not error-status:error then 
    do:
      if return-value begins "Для кассы" then 
      do:
        message return-value
           view-as alert-box question buttons yes-no update v-ok as logical  .
        if v-ok then run unblock-nozzle ( parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, list-pl ).
        else message "Сообщите в службу поддержки о неуспешной попытке разблокировки пистолетов"
              view-as alert-box.
      end.
      else 
      do: 
        message if return-value begins "Ошибка" then return-value else "Разблокировка пистолетов прошла успешно" 
          view-as alert-box.
      end.   
    end.
    else 
    do:
      enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame {&frame-name} .
      if v-is-lgas or v-is-lgas-corr
      then do:
        hide b-addinf in frame {&frame-name}.
      end .
      return no-apply .   
    end.
  end.
  run display-measure in this-procedure
    no-error .
  enable b-rvs-bf b-rvs-af b-save b-quit b-parts b-addinf b-place with frame {&frame-name} .
  if v-is-lgas or v-is-lgas-corr
  then do:
    hide b-addinf in frame {&frame-name}.
  end .
end.

on choose of b-parts in frame d-in-line /* Партии */ do:
  define variable varprt-rec as recid no-undo.

  define buffer buf_doc-line for ub.doc-line .

  { gbl/stdbtn.i }

  if tt-fr-doc-line.price-cli :sensitive then apply "leave" to tt-fr-doc-line.price-cli in frame {&frame-name}.
  if tt-fr-doc-line.tot-cli   :sensitive then apply "leave" to tt-fr-doc-line.tot-cli   in frame {&frame-name}.

  run save-action in this-procedure
    ( input "light":U
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.
tr:
do transaction on error undo, leave :
   /* Если это топливо без коррекции факт количества вручную, то меняем parline-mode */
   if parline-mode <> {&lookup} then do:
      for each old-doc-line: delete old-doc-line. end.
      find first ub.doc-line where recid(ub.doc-line) = line-rec.
      create old-doc-line.
      buffer-copy ub.doc-line to old-doc-line.
      release ub.doc-line.
   end.

   find first buf_doc-line no-lock
     where recid(buf_doc-line) = line-rec
     .
   run str/parts-l.w
     (input  parparentproc
     ,input  buf_doc-line.obj-type     /* v-obj-type   */
     ,input  buf_doc-line.obj-code     /* v-obj-code   */
     ,input  buf_goods.gds-code        /* p-gds-code   */
     ,input  buf_doc-line.doc-code     /* p-doc-code   */
     ,input  parline-mode              /* p-edit-mode  */
     ,input  {&parts-l_parts-document} /* p-r-parts    */
     ,input  {&parts-l_object-current} /* p-one-all    */
     ,input  {&parts-l_call-document}  /* p-call-point */
     ,output varprt-rec                /* part-recid   */
     ) no-error.
   if error-status :error then undo tr, return no-apply.
   if parline-mode <> {&lookup} then do:
      if parline-mode = "ЦИКЛ":u or
         parline-mode = {&add-def} then do:
         assign
           parline-mode = {&update}.
      end.
      /* Пересчитываем накладную */
      run update-doc-line-without-parts in this-procedure no-error.
      if error-status :error then undo tr, return no-apply.
   end.
end. /* transaction */
run ui-on in this-procedure.
if parline-mode <> {&lookup} then do:
  { str/prslnew.i
      "run"
      pr-genmrg
      pr-naklvalue
      t-doc.doc-code
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      tt-fr-doc-line.price-rubl
      tt-fr-doc-line.price-base
      tt-fr-doc-line.price-rubl
      tt-fr-doc-line.price-base
      tt-fr-doc-line.new-price-sale
      no-error }
      if error-status :error then
      message
        error-status :get-message(1) skip
        return-value skip
        "Нельзя рассчитать новую цену продажи(1)"
        view-as alert-box error
      .

      run disp-total in this-procedure .
end.
if b-save:sensitive then apply "entry" to b-save in frame {&frame-name}.
else apply "entry" to b-quit in frame {&frame-name}.
end.

on go of frame d-in-line
do:
  
  if valid-object (infoSectionsTotal) 
  then do:
    define variable ii as integer no-undo .
    define variable v-pokmi-dll-version as character no-undo .
    define variable rdc-dnstvalue as character no-undo.
    define variable rdc-dnsttype  as character no-undo.
    define variable v-tank-weight-rvs     like ub.doc-line.fact-qnty    no-undo .
    define variable v-tank-vol-pomi-rvs   like ub.doc-line.fact-density no-undo .
    define variable v-new-fact-qnty       like ub.doc-line.fact-qnty    no-undo .
    define variable v-new-density         like ub.doc-line.fact-density no-undo .
    define variable v-new-cli-fact-qnty   like ub.doc-line.fact-qnty    no-undo .
    define variable v-new-sec-fact-qnty-kg as decimal no-undo .
    define variable v-calc-density as decimal no-undo .
    define variable v-log as logical no-undo .
    define variable v-need-save as logical no-undo .
    define buffer bf_rvs-doc for ub.rvs-doc .
    
    define variable infoSectionObj as class InfoSection no-undo.
    
    run gbl/conf-rd.p ("rdc-dnst", "", "", 0, "", "", "", no, output rdc-dnstvalue, output rdc-dnsttype) no-error.
    
    if infoSectionsTotal:FlagTrn
    and rdc-dnstvalue = "pomi-rn"
    and not v-lgas-gds
    then do :
      v-need-save = no . 
      do ii = 1 to infoSectionsTotal:SectionNum :
        infoSectionObj = infoSectionsTotal:GetInfoSectionProp(ii) .
        
        find first bf_rvs-doc no-lock where bf_rvs-doc.out-code = infoSectionsTotal:TrnDocNum no-error .
        
        if (infoSectionObj:TankWeightRvs = ? or infoSectionObj:TankWeightRvs <= 0)
        and available bf_rvs-doc
        then do :
          run calc-pomi-rvs (input ii,
                             input t-doc.doc-code,
                             input buf_goods.gds-code,
                             input-output infoSectionsTotal,
                             output v-tank-weight-rvs,
                             output v-tank-vol-pomi-rvs)
                             no-error .
          if infoSectionObj:AccMeth = 1
          then do :
            v-need-save = yes .
            v-calc-density = v-tank-weight-rvs / v-tank-vol-pomi-rvs .
            if v-calc-density = ?
            or v-calc-density <= 0
            or v-calc-density >= 1
            then do :
              message substitute("По результатам расчёта модуля ПОкМИ плотность выходит за допустимые значения!&1Масса, кг: &2&1Объём, л: &3", {&new-line}, v-tank-weight-rvs, v-tank-vol-pomi-rvs)
              view-as alert-box error .
              return no-apply .
            end .
            infoSectionsTotal:RNAlgo (integer(infoSectionObj:SectionName), output v-new-sec-fact-qnty-kg).     
            infoSectionObj:FactQnty = v-new-sec-fact-qnty-kg / v-calc-density .
            infoSectionObj:FactDensity = v-calc-density .
          end .
        end .
      end .
      if v-need-save
      then do :
        infoSectionsTotal:SaveDB() .
        infoSectionsTotal:GetDBAllAttr().
        infoSectionsTotal:CalculateTotal().
        
        v-new-density = infoSectionsTotal:FactKgQntyTotal / infoSectionsTotal:FactQntyTotal.
        v-new-fact-qnty = infoSectionsTotal:FactQntyTotal.
        
        v-log = yes .
        if v-new-fact-qnty <> tt-fr-doc-line.fact-qnty
        or v-new-density <> tt-fr-doc-line.fact-density
        then do :
          if varupd-fact-qnty
          then do :
            message
              substitute( "По результатам измерения в резервуаре фактическое кол-во необходимо изменить." ) skip
              substitute( "Будем менять фактические" ) skip
              substitute( "количество на &1 (&2),", (v-new-fact-qnty * v-new-density), "кг" ) skip
              substitute( "плотность на &1 ?", v-new-density ) skip
            view-as alert-box question buttons yes-no update v-log .
          end .
          else do :
            message
              substitute( "По результатам измерения в резервуаре фактическое кол-во товара изменяется на &1 (&2),", (v-new-fact-qnty * v-new-density), "кг" ) skip
              substitute( "фактическая плотность на &1.", v-new-density ) skip
            view-as alert-box information .
          end .
        end .
        
        if v-log
        then do :
/*          isKPrvsSet = yes .*/
          run correct-fact-qnty in this-procedure
            ( input v-new-fact-qnty
             ,input v-new-density
            ) no-error .
        end .
        else do :
          return no-apply .
        end .
      end. /* if v-need-save */
    end .
        
    if infoSectionsTotal:FlagTrn
    and infoSectionsTotal:IsSGDKK
    then do :
      define variable v-sec-fields as character no-undo .
      
      run adm/shattri.p (
        input "get":U
        ,input t-doc.obj-type
        ,input t-doc.obj-code
        ,input {&attr-petrol}
        ,input {&attr-petrol_sec-fields}
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output par-type
        ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if not error-status:error
      then do :
        v-sec-fields = v-value-character .
      end .
      
      do ii = 1 to infoSectionsTotal:SectionNum :
        if not infoSectionsTotal:GetInfoSectionProp(ii):alarm-SGDKK
        then do :
          if v-sec-fields > ''
          and lookup("accessIDLowerLevel", v-sec-fields) > 0
          and length(trim(infoSectionsTotal:GetInfoSectionProp(ii):AukKey)) < 4
          then do :
            message substitute( "Некорректная длина идентификатора доступа (ключа) нижнего уровня. Проверьте введенное в секции &1 значение и скорректируйте." , infoSectionsTotal:GetInfoSectionProp(ii):SectionName)
            view-as alert-box .
            return no-apply .
          end .
        end .
        else do :
          if length(trim(infoSectionsTotal:GetInfoSectionProp(ii):AukKey)) < 4
          and infoSectionsTotal:IsActnComm
          then do :
            message substitute( "Некорректная длина идентификатора доступа (ключа) верхнего уровня или одноразового кода для разблокировки API-адаптера. Проверьте введенное в секции &1 значение и скорректируйте." , infoSectionsTotal:GetInfoSectionProp(ii):SectionName)
            view-as alert-box .
            return no-apply .
          end .
        end .
      end .
      
    end .
  end .

  run save-action in this-procedure
    ( input "hard":U
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.
  if valid-object (infoSectionsTotal) 
  then do:
    if parline-mode ne {&lookup}
    then
       infoSectionsTotal:SaveDB().
  
    if infoSectionsTotal:isFlagKPChg
    then do:
      define variable varobj-shift-date as date      no-undo.
      define variable varobj-shift-num  as integer   no-undo.
      define variable varobj-shift-name as character no-undo.
      
      { gbl/curshift.i
        bf-trn-doc.obj-type
        bf-trn-doc.obj-code
        varobj-shift-date
        varobj-shift-num
        varobj-shift-name
        no-error
      }
      
      v-vid-action = 68 .
      v-vid-param = "Initiator=" + "User" + {&delim-par} +
                    "ResponsiblePerson=" + bf-trn-doc.cli-name + {&delim-par} +
                    "SHOP_NUM=" + string(bf-trn-doc.obj-code) + {&delim-par} +
                    "Contractor=" + bf-trn-doc.cli-name + {&delim-par} +
                    "DocNum=" + string(bf-trn-doc.doc-code) + {&delim-par} +
                    "FactDate=" + (if string(bf-trn-doc.fact-date) = ? then '' else string(bf-trn-doc.fact-date)) + {&delim-par} +
                    "DocType=" + string(bf-trn-doc.doc-type) + {&delim-par} +
                    "SHIFT_NUM_DOC=" + (if string(bf-trn-doc.shift-num) = ? then '' else string(bf-trn-doc.shift-num)) + (if string(bf-trn-doc.shift-date) = ? then '' else string(bf-trn-doc.shift-date)) + {&delim-par} +
                    "SHIFT_NUM=" + (if string(varobj-shift-num) = ? then '' else string(varobj-shift-num)) + (if string(varobj-shift-date) = ? then '' else string(varobj-shift-date, "99999999")) + {&delim-par} +
                    "Status=" + string(bf-trn-doc.status_) + (if bf-trn-doc.flag then "+" else "-" ) + {&delim-par} +
                    "RESULT=1" + {&delim-par} + 
                    "Description=" + "Включен комиссионный прием нефтепродукта" no-error.
      
      
      if available (bf-trn-doc)
      then do:
      
        run trg/userlog.p (
              input {&nwsdochs_action_update_err}
            , input {&table_trn-doc}
            , input ( buffer bf-trn-doc :handle )
            , input v-vid-param
            , input v-vid-param
        ) no-error.
        
      end.
      
    end.
    
  end.
  
  delete object infoSecObj no-error .
  delete object infoSectionsTotal no-error.
  tanksForm:Dispose() no-error .
  delete object tanksForm no-error.

  if v-lgas-gds
  then do :
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock where buf_doc-line-attr.doc-code = t-doc.doc-code
                                                  and buf_doc-line-attr.gds-code = buf_goods.gds-code
                                                  and buf_doc-line-attr.attr-code = "propan-perc"
                                                  no-error .
    if not available buf_doc-line-attr
    then do :
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code = t-doc.doc-code    
        buf_doc-line-attr.gds-code = buf_goods.gds-code
        buf_doc-line-attr.attr-code = "propan-perc"    
      .
    end .
    assign
      buf_doc-line-attr.attr-value = string(tt-fr-doc-line.propan-perc)
    .
    
    for first tt-doc-pl :
      find first bf_place-attr no-lock where bf_place-attr.obj-type  = tt-doc-pl.obj-type 
                                         and bf_place-attr.obj-code  = tt-doc-pl.obj-code 
                                         and bf_place-attr.pl-code   = tt-doc-pl.pl-code
                                         and bf_place-attr.attr-code = "place-gate-valve"
                                         no-error .
      if available bf_place-attr
      and logical(bf_place-attr.attr-value)
      then do :
        find first buf_doc-line-attr exclusive-lock where buf_doc-line-attr.doc-code = t-doc.doc-code
                                                      and buf_doc-line-attr.gds-code = buf_goods.gds-code
                                                      and buf_doc-line-attr.attr-code = "connect-hoses"
                                                      no-error .
        if not available buf_doc-line-attr
        then do :
          create buf_doc-line-attr .
          assign
            buf_doc-line-attr.doc-code = t-doc.doc-code    
            buf_doc-line-attr.gds-code = buf_goods.gds-code
            buf_doc-line-attr.attr-code = "connect-hoses"
          .
        end .
        assign
          buf_doc-line-attr.attr-value = cb-connect-hoses
          buf_doc-line-attr.attr-value = ? when cb-connect-hoses = "empty"
        .
      end .
      else do :
        find first buf_doc-line-attr exclusive-lock where buf_doc-line-attr.doc-code = t-doc.doc-code
                                                      and buf_doc-line-attr.gds-code = buf_goods.gds-code
                                                      and buf_doc-line-attr.attr-code = "connect-hoses"
                                                      no-error .
        if available buf_doc-line-attr
        then do :
          delete buf_doc-line-attr .
        end .
      end .
    end .
  end .

end.

on choose of b-save in frame d-in-line /* Сохранить */
do:
  { gbl/stdbtn.i }
end.

on choose of b-exit-cycl in frame d-in-line do:
  { gbl/stdbtn.i }
   assign parexit-cycle = yes.
  apply "end-error" to frame {&frame-name}.
  return no-apply.
end.

on end-error, stop of frame {&frame-name} do:
  apply "choose" to b-quit in frame {&frame-name}.
  return no-apply.
end.

on choose of b-quit in frame {&frame-name}
do:
  { gbl/stdbtn.i }
  run proc-quit in this-procedure.
end.

/* стандартные для формы товара триггеры */
{ gbl/hot-key.i b-save }

if valid-handle(active-window) and frame {&frame-name}:parent eq ?
then frame {&frame-name}:parent = active-window.

{ gbl/app_help.i }

on window-close of frame {&frame-name} apply "end-error":u to self.

main-block:
do on error   undo main-block, leave main-block
   on end-key undo main-block, leave main-block
   on stop    undo main-block, leave main-block :

   /* Если выбрали добавление старого товара */
   vargds-obj-fact-qnty:tooltip =  "Текущий остаток"  .
   
   find t-doc where recid( t-doc ) = pardoc-rec.

     { str/tdat-val.i
        t-doc.doc-code
        {&trdcattr-is-lgas}
        varvalue
        vartype
        no-error 
    }
    if varvalue = "yes"
      then v-is-lgas = true.
    
    { str/tdat-val.i                                    
       t-doc.doc-code
       {&trdcattr-is-lgas-corr}
        varvalue
        vartype
        no-error
    }
    
    if varvalue = "yes"
      then v-is-lgas-corr = true.

   find first buf_goods no-lock
     where recid(buf_goods) = pargds-rec
   .
   { gbl/hold-doc.i t-doc.doc-code v-hold-doc }
  
    run gds-attr-value in this-procedure
      (  input buf_goods.gds-code
        ,input {&attr-fuel-type}
        ,output v-attr-value
        ,output v-attr-type
       ) .
    if v-attr-value = "lgas" then 
    do:
      v-lgas-gds = true.
    end.


   find first bf_sysconf no-lock
     where bf_sysconf.host-code = t-doc.host-code
   .

   if parline-mode = "ЦИКЛ":u or
      parline-mode = {&add-def} then do:

      find ub.doc-line where ub.doc-line.prod-code = buf_goods.prod-code and
                          ub.doc-line.prod-type = buf_goods.prod-type and
                          ub.doc-line.artic     = buf_goods.artic     and
                          ub.doc-line.doc-code  = t-doc.doc-code  no-error.
      if available ub.doc-line then do:
         varlog = no.
         message 'Товар "' + buf_goods.artic + ' ' + buf_goods.gds-name + '"' +
                 ' производителя "' + buf_goods.prod-type + ' ' + string(buf_goods.prod-code) + '"' +
                 ' уже есть в этой накладной. Вы хотите изменить его ?'
              view-as alert-box question buttons yes-no update varlog.
         if not varlog then return error.
         assign parline-mode = {&update}
                line-rec  = recid(ub.doc-line).
      end.
      else assign parline-mode = {&add-def}
                  line-rec = ? .
   end.
   { gbl/curr-r-b.i varr-b }
   { gbl/conf-rd.i "'is-custm'" 0 "''" 0 "''" "''" "''" no  custvalue     custtype     no-error }
   { gbl/conf-rd.i "'is-prt'"   0 "''" 0 "''" "''" "''" yes prtvalue      prttype      no-error }
   { gbl/conf-rd.i "'stfactpl'" 0 "''" 0 "''" "''" "''" no  stfactplvalue stfactpltype no-error }
   { gbl/conf-rd.i "'ptoldfil'" t-doc.host-code t-doc.obj-type t-doc.obj-code "''" "''" "''" no ptoldfilvalue ptoldfiltype no-error }

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_rvs-on-doc_repeat-asi':U
    {&cntxt-object}
    t-doc.host-code
    t-doc.obj-type
    t-doc.obj-code
    0
    0
    0
    false
    l-repeat-asi
  }
m-repeat-asi = return-value.

define variable par-1 as character no-undo .
define variable par-0 as logical   no-undo .
/* Получим из ТПЛ автопереоценок нужные переменные */
{ gbl/gtplmrgn.i
  parparentproc
  t-doc.obj-type
  t-doc.obj-code
  pr-genmrg
  par-1
  par-1
  no-error }
{ gbl/gtplpnakl.i
  parparentproc
  t-doc.obj-type
  t-doc.obj-code
  pr-naklvalue
  par-0
  par-0
  no-error }


{ gbl/getsect.i run "''" 0 {&attr-nakl-glob} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'vat-ext'   then  dops        = thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'slt-ext'   then  dop-slt     = thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'vat-sum'   then  vat-sumvalue= string(thbjattr_thbj-attr.property-value-logical, "yes/no") .
end.
empty temp-table thbjattr_thbj-attr.

   { str/is-petrl.i
     buf_goods.artic
     buf_goods.prod-type
     buf_goods.prod-code
     is-petrolium
     is-pieces
   }
   if is-petrolium = yes
     and is-pieces = no
   then do:
     { gbl/ptrlprop.i run t-doc.obj-type t-doc.obj-code }

     run gds-attr-value in this-procedure
       ( input  buf_goods.gds-code
        ,input  {&attr-ptrl-without-rvs}
        ,output v-ptrl-without-rvs
        ,output v-attr-type
       ) .
     run gds-attr-value in this-procedure
       ( input  buf_goods.gds-code
        ,input  {&attr-gds-ptrl-densities}
        ,output v-gds-ptrl-densities
        ,output v-attr-type
       ) .
       if v-gds-ptrl-densities <> "" and v-gds-ptrl-densities <> ? then do:
          assign
            v-min-dens = decimal(replace(entry(1, v-gds-ptrl-densities, "-":U ), "кг\л", "":U))
            v-max-dens = decimal(replace(entry(2, v-gds-ptrl-densities, "-":U ), "кг\л":U, "":U))
          no-error .
       end.
   end.
   else do:
   
    if t-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} and not t-doc.flag_ and t-doc.status_ = {&wayb}
    then do: 
      
      run adm/shattri.p (
          input "get":U
          ,input t-doc.obj-type
          ,input t-doc.obj-code
          ,input {&attr-nakl_par}
          ,input  "edit-fact-wayb"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-value-logical
          ,output par-type
          ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
        ) no-error .
        if error-status :error then .
        else v-edit-fact-wayb = v-value-logical.
    end.
   
     
   end.

   { gbl/gdsobjat.i
     t-doc.obj-type
     t-doc.obj-code
     buf_goods.artic
     buf_goods.prod-type
     buf_goods.prod-code
     "'insalepr=request'":U
     v-insalepr
   }

   { gbl/getsect.i run t-doc.obj-type t-doc.obj-code {&attr-nakl_par} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'vat-goods' then v-vat-goods = thbjattr_thbj-attr.property-value-logical .
        if thbjattr_thbj-attr.prop-code = 'round-vat-sum' then v-round-vat-sum = thbjattr_thbj-attr.property-value-logical .

    end.

     { str/tdat-val.i
        t-doc.doc-code
        {&trdcattr-negais}
        varvalue
        vartype
        }
     if varvalue <> ? and varvalue <> ""
       then isEgais = true.

    { str/tdat-val.i                                    
       t-doc.doc-code
       {&trdcattr-is-fuel}
       varvalue 
       vartype no-error} 
    
    if varvalue = "yes"
      then is-fuel = true.
      
    

   assign
     rdtaxcdvalue  = {&road-tax-code}
     exctaxcdvalue = {&excise-tax-code}
     vattaxcdvalue = {&vat-tax-code}.
   case parline-mode :
     /* 22/X-2018 - избавление от "ЦИКЛ":u и присвоение line-rec = ?. было выполнено в строке 1935
     when {&add-def} or when "ЦИКЛ":u then do:
       line-rec = ?.
     end.
     */
     when {&update} then do:
       find ub.doc-line where recid (ub.doc-line) = line-rec no-error.
       if not available ub.doc-line then do:
          message "Неправильный выбор строки." view-as alert-box.
          return error.
       end.
     end.
     when {&lookup} then do:
       b-quit:label = "Выход" .
       find ub.doc-line where recid (ub.doc-line) = line-rec no-lock no-error.
       if not available ub.doc-line then do:
          message "Неправильный выбор строки." view-as alert-box.
          return error.
       end.
     end.
   end.
   assign frame {&frame-name}:title = "Строка накладной № " + t-doc.doc-code + "    - " + parline-mode.

  /* для возможной проверки допустимости ед.изм поставщика, для топлива не берем из спецификации*/
  if t-doc.contract-code > 0 and not is-petrolium then do :
    find first buf_contract-specif no-lock
         where buf_contract-specif.host-code    = t-doc.host-code 
           and buf_contract-specif.contract-num = t-doc.contract-code
           and buf_contract-specif.gds-code     = buf_goods.gds-code no-error .
    if available buf_contract-specif then assign
      v-specif-unit-list     = buf_contract-specif.unit-cli
      v-specif-cli-base-rate = buf_contract-specif.cli-base-rate
    .
    else assign
      v-specif-unit-list     = ""
      v-specif-cli-base-rate = 1
    .
  end .

   run ui-on in this-procedure no-error.
   if error-status :error then do:
     message "Ошибка " skip
             return-value
     view-as alert-box error.
     return error.
   end.
   if v-is-looksec
   then do :
     define variable v-rvd-own-nb as logical no-undo .
     run adm/shattri.p (
          input "get":U
          ,input t-doc.obj-type
          ,input t-doc.obj-code
          ,input {&attr-petrol}
          ,input  "rvd-own-nb"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-value-logical
          ,output par-type
          ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
        ) no-error .
     if error-status :error then v-rvd-own-nb = false .
     else v-rvd-own-nb = v-value-logical.
     if v-rvd-own-nb = false
     and t-doc.cli-code > 0
     then do :
       find first ub.clients-attr no-lock where ub.clients-attr.obj-type = t-doc.cli-type
                                            and ub.clients-attr.obj-code = t-doc.cli-code
                                            and ub.clients-attr.attr-code = {&attr-owner-code}
                                            no-error .
       if available ub.clients-attr
       and ub.clients-attr.attr-value > ""
       then do :
         if ub.clients-attr.attr-value = "орг" + string(t-doc.host-code)
         then do :      
           disable b-quit with frame {&frame-name}.
         end .
       end .
     end .
     apply "choose" to b-docsec.
   end .
   case parline-mode:
     when {&lookup} then wait-for go of frame {&frame-name} focus b-quit.
     otherwise do:
       if not t-doc.flag_ and not isEgais then do:
         if tt-fr-doc-line.cli-qnty :sensitive in frame {&frame-name} then do:
           if tt-fr-doc-line.cli-qnty <> ?
             and tt-fr-doc-line.cli-qnty <> 0.0
             and tt-fr-doc-line.doc-density :sensitive in frame {&frame-name}
             and ( tt-fr-doc-line.doc-density = 0.0
                   or tt-fr-doc-line.doc-density = ?
                 )
           then do:
             wait-for go of frame {&frame-name} focus tt-fr-doc-line.doc-density.
           end.
           else do:
             wait-for go of frame {&frame-name} focus tt-fr-doc-line.cli-qnty.
           end.
         end.
         else do:
           if tt-fr-doc-line.doc-qnty :sensitive in frame {&frame-name} then do:
             if tt-fr-doc-line.doc-qnty <> ?
               and tt-fr-doc-line.doc-qnty <> 0.0
               and tt-fr-doc-line.doc-density :sensitive in frame {&frame-name}
               and ( tt-fr-doc-line.doc-density = 0.0
                     or tt-fr-doc-line.doc-density = ?
                   )
             then do:
               wait-for go of frame {&frame-name} focus tt-fr-doc-line.doc-density.
             end.
             else do:
               wait-for go of frame {&frame-name} focus tt-fr-doc-line.doc-qnty.
             end.
           end.
           else do:
             if tt-fr-doc-line.doc-density :sensitive in frame {&frame-name}
               and ( tt-fr-doc-line.doc-density = 0.0
                     or tt-fr-doc-line.doc-density = ?
                   )
             then do:
               wait-for go of frame {&frame-name} focus tt-fr-doc-line.doc-density.
             end.
             else do:
               wait-for go of frame {&frame-name}.
             end.
           end.
         end.
       end.
       else do:
         if isEgais
         then do:
           disable tt-fr-doc-line.unit-cli r-units tt-fr-doc-line.cli-qnty tt-fr-doc-line.doc-qnty tt-fr-doc-line.cli-base-rate with frame {&frame-name}.
         end.
         if varupd-fact-qnty = no then do:
           wait-for go of frame {&frame-name} focus b-save.
         end.
         else do:
           wait-for go of frame {&frame-name} focus tt-fr-doc-line.fact-qnty.
         end.
       end.
     end. /* otherwise */
   end case. /* parline-mode */
end. /* main-block */
run disable_ui in this-procedure.

/* **********************  internal procedures  *********************** */

procedure disable_ui :
  disable all with frame d-in-line.
  hide frame {&frame-name}.
end procedure.

procedure ui-on :
/* -----------------------------------------------------------
  purpose:     включение интерфейса в нужном режиме.
-------------------------------------------------------------*/
define buffer cst-parts         for ub.parts.
define buffer cst-parts-another for ub.parts.
define buffer last-line         for ub.doc-line.
define buffer gold-line         for ub.doc-line.
define buffer bf_units          for ub.units.
define buffer bf_doc-line-attr  for ub.doc-line-attr.
define buffer bf_parts          for ub.parts.
define buffer bf-another_parts  for ub.parts.
define buffer bf_contract       for ub.contract.
define buffer bf_gds-obj        for ub.gds-obj.
define buffer bf_trn-doc        for ub.trn-doc.
define buffer bf_trn-ist        for ub.trn-doc.
define buffer bf_doc-line-ist   for ub.doc-line.
define buffer bf_clients        for ub.clients.
define buffer bf_doc-line       for ub.doc-line.
define buffer buf_country       for ub.country.

do on error undo, return error return-value :

case parline-mode :
  when {&lookup}  then prt-mode = {&lookup}.
  when {&update}  then prt-mode = {&prt-def}.
  when {&add-def} then prt-mode = {&prt-def}.
  /* when "ЦИКЛ":u   then prt-mode = {&prt-def}. - было преобразовано в строке 1935 */
end.
disable all with frame {&frame-name}.
assign
  tt-fr-doc-line.doc-density            :visible = no
  tt-fr-doc-line.temperature            :visible = no
  tt-fr-doc-line.fact-density           :visible = no
  tt-fr-doc-line.num-place              :visible = no
  tt-fr-doc-line.wt-brutto              :visible = no
  tt-fr-doc-line.pl-code                :visible = no
  b-place                               :visible = no
  tt-fr-doc-line.measure-qnty           :visible = no
  tt-fr-doc-line.state-measure-qnty     :visible = no
  tt-fr-doc-line.state-measure-cli-qnty :visible = no
  tt-fr-doc-line.trk-cli-qnty           :visible = no
  road-tax-cli                          :visible = no
  rect-tot                              :visible = no
  tt-fr-doc-line.wt-place               :visible = no
  b-rvs-bf                              :visible = no
  b-rvs-af                              :visible = no
  b-addinf                              :visible = no
  b-docsec                              :visible = no
  b-alc-attr                            :visible = no
.

hide tt-fr-doc-line.propan-perc cb-connect-hoses in frame {&frame-name}.

/*---------------------------------------------------------*/
/*          Создадим экранную временную таблицу            */
/*---------------------------------------------------------*/
find t-doc where recid(t-doc) = pardoc-rec.
find first tt-fr-doc-line no-error.
if not available tt-fr-doc-line then do:
   { str/kndinpin.i
     buf_goods.gds-code
   t-doc.cli-type
   t-doc.cli-code
   t-doc.obj-type
   t-doc.obj-code
   varext-gds-type
   varcli-qnty-input
   vardensity-input
   varcli-base-rate-input
   vardoc-qnty-input
   varfact-qnty-input
   varprice-cli-input
   varbase-price-input
   vartax-3-input
   varcli-qnty-calc
   vardensity-calc
   varcli-base-rate-calc
   vardoc-qnty-calc
   varfact-qnty-calc
   varprice-cli-calc
   varbase-price-calc
   vartax-3-calc
   varround
     no-error }
   if error-status :error then return error "Ошибка при вызове процедуры kndinpin(in-line.w)" + return-value.

   if parline-mode = {&add-def} then do:
     run cr-tt-fr-doc-line in this-procedure
       ( input "create"
        ,input ?
       ) no-error.
     if error-status :error then return error.
   end.
   else do:
     run cr-tt-fr-doc-line in this-procedure
       ( input "no-create"
        ,input line-rec
       ) no-error.
     if error-status :error then return error.
   end.

end.
if v-is-lgas-corr
then do:

   { str/tdat-val.i
      t-doc.doc-code
      {&trdcattr-trn-lgas-corr}
      varvalue
      vartype
      }
  
  find first bf_trn-ist no-lock where bf_trn-ist.doc-code = varvalue no-error.
  if not available (bf_trn-ist)
    then return error "Не найден документ-источник: " + varvalue.
  find first bf_doc-line-ist where bf_doc-line-ist.doc-code = bf_trn-ist.doc-code and
    buf_goods.artic     = bf_doc-line-ist.artic     and
    buf_goods.prod-type = bf_doc-line-ist.prod-type and
    buf_goods.prod-code = bf_doc-line-ist.prod-code no-lock no-error.
  if not available (bf_trn-ist)
    then return error "Не найден товар в документе-источника: " + string (buf_goods.gds-code).    
  vardensity-ist = bf_doc-line-ist.fact-density.
end.

run tax-name in this-procedure
  ( input {&road-tax}
   ,output varroad-tax-label
  ) no-error.
assign
  tt-fr-doc-line.road-tax :label in frame {&frame-name} = varroad-tax-label
  road-tax-cli :label            in frame {&frame-name} = varroad-tax-label
.

/*Добавление*/
if /* 22/X-2018 parline-mode = "ЦИКЛ":u or */
   parline-mode = {&add-def} then do:
   /*Прием по продажной цене*/
   if v-insalepr = true then do:
     run calc-price-sale  in this-procedure no-error.
     if error-status :error then do:
        message "Ошибка при установке продажной цены." skip
                return-value
                view-as alert-box.
        return error.
     end.
   end.
   else do:
     if not( is-petrolium = yes  and is-pieces = no )
     then do:
        /* Для нетопливных товаров(!!!)
           по возможности подставляем цену из спецификации или
        последнюю приходную цену */
       run cpprclig in this-procedure   (
       input        t-doc.doc-code                      ,
       input        t-doc.cli-code                      ,
       input        t-doc.cli-type                      ,
       input        t-doc.host-code                     ,
       input        t-doc.base-rate                     ,
       input        t-doc.base-scale                    ,
       input        t-doc.exch-rate                     ,
       input        t-doc.exch-scale                    ,
       input        t-doc.vat-type                      ,
       input        t-doc.slt-type                      ,
       input        tt-fr-doc-line.artic                ,
       input        tt-fr-doc-line.prod-type            ,
       input        tt-fr-doc-line.prod-code            ,
       input        yes                                 ,
       input        tt-fr-doc-line.cli-base-rate        ,
       input        tt-fr-doc-line.transport-rubl       ,
       input        tt-fr-doc-line.other-rubl           ,
       output       tt-fr-doc-line.price-cli            ,
       output       tt-fr-doc-line.price-base           ,
       output       tt-fr-doc-line.price-rubl           ,
       input-output tt-fr-doc-line.vat-pc               ,
       input-output tt-fr-doc-line.slt-pc               ,
       input-output tt-fr-doc-line.road-tax             ,
       input-output tt-fr-doc-line.excise               ) no-error.
       if v-vat-goods = true
       and t-doc.vat-type <> {&without-vat}
       then do:
         { gbl/pftxvalg.i buf_goods.gds-code {&vat-tax-code} ? t-doc.host-code t-doc.obj-type t-doc.obj-code tt-fr-doc-line.vat-pc no-error }
       end.
       if tt-fr-doc-line.vat-pc = ?        and
          t-doc.vat-type <> {&without-vat} then do:
         { gbl/pftxvalg.i buf_goods.gds-code {&vat-tax-code} ? t-doc.host-code t-doc.obj-type t-doc.obj-code tt-fr-doc-line.vat-pc no-error }
       end.
      /* if vat-sumvalue <> "yes" then do: */

          if  dops > '' and  not f-chekval(input dops, input tt-fr-doc-line.vat-pc)   then do:
             message "Неверное значение НДС:" tt-fr-doc-line.vat-pc  skip
                 "Разрешенные значения: " dops "."
                 view-as alert-box error.
             return error.
          end.
          if dop-slt > '' and not f-chekval(input dop-slt , input tt-fr-doc-line.slt-pc) then do:
             message "Неверное значение НсП:" tt-fr-doc-line.slt-pc  skip
                 "Разрешенные значения: " dop-slt "."
                 view-as alert-box error.
             return error.
          end.
      /* end. */

       if tt-fr-doc-line.slt-pc = ? and
         t-doc.slt-type <> {&without-slt} then do:
        { gbl/pftxvalg.i buf_goods.gds-code {&slt-tax-code} ? t-doc.host-code t-doc.obj-type t-doc.obj-code tt-fr-doc-line.slt-pc no-error }
       end.
       display
         tt-fr-doc-line.price-cli
         tt-fr-doc-line.price-base
         tt-fr-doc-line.price-rubl
         tt-fr-doc-line.vat-pc
         tt-fr-doc-line.slt-pc
         tt-fr-doc-line.road-tax
         tt-fr-doc-line.excise
       with frame {&frame-name}.

       if can-do({&inquiry}, t-doc.status_ ) and
           (not t-doc.flag_) then do:
           find first ub.goods no-lock where recid(ub.goods)  = recid(buf_goods) .
           { str/stprqr.i tt-fr-doc-line.}
       end.
     end.
   end.
   run calc-all in this-procedure ( input ( if varprice-cli-input = yes then varprice-cli-calc
                                                                        else varbase-price-calc ) ) no-error.
   if error-status :error then return no-apply.
   if custvalue = "yes" then do:
     assign tt-fr-doc-line.num-place = 1.
     display tt-fr-doc-line.num-place with frame {&frame-name}.
   end.
   assign
     tt-fr-doc-line.alpha1 = buf_goods.alpha1 .
   find first buf_country no-lock where buf_country.alpha1 = tt-fr-doc-line.alpha1 no-error .
   if available buf_country then do:
    assign
      tt-fr-doc-line.country-code = buf_country.num-code
      tt-fr-doc-line.short-name   = buf_country.short-name
    .
   end.
   if is-petrolium = yes
     and is-pieces = no
     and buf_goods.unit-base = buf_goods.unit-cli
   then do:
     assign
       tt-fr-doc-line.doc-density   = 1.0
       tt-fr-doc-line.cli-base-rate = 1.0
     .
     display
       tt-fr-doc-line.doc-density
     with frame {&frame-name}.
   end.
end.
else do: /* не добавление (изменение и просмотр) */
  find ub.doc-line where recid( ub.doc-line ) = line-rec.
  find ub.inv-line where
       ub.inv-line.doc-code  = ub.doc-line.doc-code  and
       ub.inv-line.artic     = ub.doc-line.artic     and
       ub.inv-line.prod-type = ub.doc-line.prod-type and
       ub.inv-line.prod-code = ub.doc-line.prod-code no-error.
  assign
     tt-fr-doc-line.cli-qnty       = ub.doc-line.cli-qnty
     tt-fr-doc-line.doc-qnty       = ub.doc-line.doc-qnty
     tt-fr-doc-line.fact-qnty      = ub.doc-line.fact-qnty
     tt-fr-doc-line.fact-qnty-kg   = ub.doc-line.fact-qnty * ub.doc-line.fact-density
     tt-fr-doc-line.price-base     = ub.doc-line.price-base
     tt-fr-doc-line.price-rubl     = ub.doc-line.price-rubl
     tt-fr-doc-line.doc-density    = ub.doc-line.doc-density
     tt-fr-doc-line.fact-density   = ub.doc-line.fact-density
     tt-fr-doc-line.temperature    = ub.doc-line.temperature
     tt-fr-doc-line.road-tax       = ub.doc-line.road-tax
     tt-fr-doc-line.excise         = ub.doc-line.excise
     tt-fr-doc-line.transport-base = ub.doc-line.transport-base
     tt-fr-doc-line.other-base     = ub.doc-line.other-base
     tt-fr-doc-line.transport-rubl = ub.doc-line.transport-rubl
     tt-fr-doc-line.other-rubl     = ub.doc-line.other-rubl
     tt-fr-doc-line.wt-brutto      = ub.doc-line.wt-brutto
     tt-fr-doc-line.num-place      = ub.doc-line.num-place
     tt-fr-doc-line.wt-place       = ( tt-fr-doc-line.wt-brutto / tt-fr-doc-line.num-place )
  .
  if tt-fr-doc-line.doc-qnty  = tt-fr-doc-line.fact-qnty
    and tt-fr-doc-line.cli-qnty  = tt-fr-doc-line.fact-qnty-kg
    and tt-fr-doc-line.doc-density  <> tt-fr-doc-line.fact-density
  then do:
    assign
      tt-fr-doc-line.fact-density = tt-fr-doc-line.doc-density
    .
  end.
  
  if v-lgas-gds
  then do :
    find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = tt-fr-doc-line.doc-code and
                                      bf_doc-line-attr.gds-code  = buf_goods.gds-code and
                                      bf_doc-line-attr.attr-code = "propan-perc"
                                      no-error.
    if available bf_doc-line-attr
    then do :
      tt-fr-doc-line.propan-perc = decimal(bf_doc-line-attr.attr-value) no-error .
    end .
    find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = tt-fr-doc-line.doc-code and
                                      bf_doc-line-attr.gds-code  = buf_goods.gds-code and
                                      bf_doc-line-attr.attr-code = "connect-hoses"
                                      no-error.
    if available bf_doc-line-attr
    then do :
      if bf_doc-line-attr.attr-value = ?
      then cb-connect-hoses = "empty" .
      else cb-connect-hoses = bf_doc-line-attr.attr-value .
      display cb-connect-hoses with frame {&frame-name}.
    end .
  end .

  if parinplnsum = yes then do:
    find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = tt-fr-doc-line.doc-code and
                                      bf_doc-line-attr.gds-code  = buf_goods.gds-code and
                                      bf_doc-line-attr.attr-code = "tot-cli"               no-error.
    /*Если документ создавали копирование или это старый документ, то в нем не записан атрибут - "сумма в ценах поставщика".
      Запишем его.*/
    if not available bf_doc-line-attr then do:
     create bf_doc-line-attr.
     assign
     bf_doc-line-attr.doc-code  = t-doc.doc-code
     bf_doc-line-attr.gds-code  = buf_goods.gds-code
     bf_doc-line-attr.attr-code = "tot-cli".
     bf_doc-line-attr.attr-value = string(doc-line.cli-qnty * ub.doc-line.price-cli).
    end.
    assign
      tt-fr-doc-line.type-inp-sum = yes
      tt-fr-doc-line.tot-cli      = decimal (bf_doc-line-attr.attr-value)
      tt-fr-doc-line.price-cli    = tt-fr-doc-line.tot-cli / tt-fr-doc-line.cli-qnty.
  end.
  else do:
    assign
      tt-fr-doc-line.type-inp-sum = no
      tt-fr-doc-line.price-cli    = ub.doc-line.price-cli.
  end.
  display
   tt-fr-doc-line.cli-qnty
   tt-fr-doc-line.doc-qnty
   tt-fr-doc-line.price-cli
   tt-fr-doc-line.price-base
   tt-fr-doc-line.price-rubl
   tt-fr-doc-line.transport-base
   tt-fr-doc-line.other-base
   tt-fr-doc-line.transport-rubl
   tt-fr-doc-line.other-rubl
   with frame {&frame-name}.
  if custvalue = "yes" then display tt-fr-doc-line.wt-brutto
                                    tt-fr-doc-line.num-place
                                    tt-fr-doc-line.wt-place  with frame {&frame-name}.

  if t-doc.flag_ = yes or t-doc.status_ = {&fact} or v-edit-fact-wayb then do:
    display tt-fr-doc-line.fact-qnty with frame {&frame-name}.
    if is-petrolium = yes and is-pieces = no then do:
      display tt-fr-doc-line.fact-qnty-kg with frame {&frame-name}.
      display tt-fr-doc-line.fact-density with frame {&frame-name}.
    end.
  end.
  else do:
    hide
      tt-fr-doc-line.fact-qnty    in frame {&frame-name}
      tt-fr-doc-line.fact-qnty-kg in frame {&frame-name}
      tt-fr-doc-line.fact-density in frame {&frame-name}.
    .
  end.
  if is-petrolium = yes then do:
     if is-pieces = no then do:
        display
          tt-fr-doc-line.doc-density
          tt-fr-doc-line.temperature
        with frame {&frame-name}.
     end.
     display
       tt-fr-doc-line.excise
     with frame {&frame-name}.
  end.
  /* Проверяем есть ли у товара дополнительная компонента в цене */
  if hvrdtax (recid(buf_goods)) then do:
     display
        tt-fr-doc-line.road-tax
        with frame {&frame-name}.
     if varr-b = "rubl":u then do:
       assign  road-tax-cli = tt-fr-doc-line.road-tax / t-doc.exch-rate * t-doc.exch-scale * tt-fr-doc-line.cli-base-rate                             .
     end.
     else do:
       assign  road-tax-cli = tt-fr-doc-line.road-tax / t-doc.exch-rate * t-doc.exch-scale * tt-fr-doc-line.cli-base-rate
                              * t-doc.base-rate / t-doc.base-scale.
     end.
     display road-tax-cli with frame {&frame-name}.
  end.
end. /* не добавление (изменение и просмотр) */

IF mImagePh THEN
DO:
    IF AVAILABLE buf_goods THEN
    DO:
        DEFINE VARIABLE vImageList AS LONGCHAR    NO-UNDO.
        DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
        RUN gds-attr-value (buf_goods.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).       
        RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, INPUT buf_goods.gds-code ,OUTPUT vImageList).
        vCh = ENTRY (1, vImageList, {&ImageDelimiter}).
    END.
    g-image:LOAD-IMAGE (ENTRY (1, vCh)) NO-ERROR.
END.

IF mImagePh THEN
    ASSIGN
        g-image:HIDDEN     = NO
        g-image:VISIBLE    = YES
        g-image:SENSITIVE  = YES
        .
ELSE
    ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .
/* заполнение временных таблиц для учета по сладским местам */
run plgdsfnd in this-procedure
  ( input  no
   ,input  t-doc.obj-type
   ,input  t-doc.obj-code
   ,input  buf_goods.gds-code
   ,output varrvs-place
   ,output var-code-temp
  ) no-error.
if error-status :error then do:
  message
    "Ошибка при проверке привязки товара к складскому месту: " skip
    tt-fr-doc-line.artic " " tt-fr-doc-line.prod-type " " tt-fr-doc-line.prod-code skip
    return-value "." view-as alert-box error.
  return error.
end.

if varrvs-place = yes then do:

  run init-tt-doc-pl in this-procedure
    no-error .

  enable
    b-place
    with frame {&frame-name}
  .

  find first tt-doc-pl no-lock
    no-error.
  if not available tt-doc-pl
    and not ( parline-mode = "ЦИКЛ":u
              or parline-mode = {&add-def}
            )
  then do:
      message
        substitute( "Товар &1 &2 &3", tt-fr-doc-line.artic, tt-fr-doc-line.prod-type, tt-fr-doc-line.prod-code ) skip
        "не распределен по местам хранения."
        view-as alert-box.
      /* return error. */
  end.

  if is-petrolium = yes
    and is-pieces = no
  then do:

/*    if t-doc.status_ <> {&fact} then */   /* Убрано попутно к задаче ТН-3354 15.01.2015 Арн. */
    if parline-mode <> {&lookup} then         /* Добавл попутно к задаче ТН-3354 15.01.2015 Арн. */
    do:
      assign
        b-rvs-bf:popup-menu in frame {&frame-name} = menu m-rvs-bf:handle
        b-rvs-bf:menu-mouse = 1
        b-rvs-af:popup-menu in frame {&frame-name} = menu m-rvs-af:handle
        b-rvs-af:menu-mouse = 1
      .
    end.
    
    if not v-lgas-gds
    then 
      enable
        b-docsec
        with frame {&frame-name}.

    infoSectionsTotal = new InfoSectionsTotal(t-doc.doc-code, buf_goods.gds-code, parline-mode).
    
        
    if infoSectionsTotal:Mode = "ДОБАВЛЕНИЕ" and infoSectionsTotal:SectionNum = 0 then do:
      infoSectionsTotal:NewSection().
    end.
    
    if not (v-is-lgas or v-is-lgas-corr)  
    then do:  
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_income_petrol-сommission':U
          {&cntxt-object}
          t-doc.host-code
          t-doc.obj-type
          t-doc.obj-code
          0
          0
          0
          false
          l-ok
        }
    
       if l-ok = true
        then do:
          infoSectionsTotal:IsActnComm = true.
        end.
  
       { str/tdat-val.i
          t-doc.doc-code
          {&trdcattr-car-num}
          varcar-num
          vartype
          }
      
       { str/tdat-val.i
          t-doc.doc-code
          {&trdcattr-acc-ship}
          varvalue
          vartype
          }
      
      varrn-acc-ship = decimal (varvalue) no-error.
      if varrn-acc-ship = ?
        then varrn-acc-ship = 0.
    end.
    
    { gbl/ptrlprop.i
      run
      t-doc.obj-type
      t-doc.obj-code
    }
    
    if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-rvs)
    then run str/lib-rvs.p persistent no-error .

    assign
      infoSectionsTotal:CliQntyInput = varcli-qnty-input
      infoSectionsTotal:DensityInput = vardensity-input
      infoSectionsTotal:DocQntyInput = vardoc-qnty-input
      infoSectionsTotal:IsRNAlgo = if ptrlprop-algoincome = 2 then true else false
      infoSectionsTotal:PercAcc = varpercauto
      infoSectionsTotal:AccShip = varrn-acc-ship
      infoSectionsTotal:CarNum = varcar-num
      infoSectionsTotal:IsSGDKK = no
      infoSectionsTotal:FlagTrn = t-doc.flag_
      infoSectionsTotal:Sts = t-doc.status_
      infoSectionsTotal:Parentproc = parparentproc
      infoSectionsTotal:lRepeatAsi = l-repeat-asi
      infoSectionsTotal:mRepeatAsi = m-repeat-asi
      infoSectionsTotal:petrol_block-nozzle = ptrlprop-block-nozzle
      infoSectionsTotal:in-line-handle = this-procedure
    .
    
    find first sep_auto-tank-attr no-lock where sep_auto-tank-attr.auto-num = varcar-num
                                            and sep_auto-tank-attr.attr-code = "auto-sep"
                                            no-error.
    if available sep_auto-tank-attr
    and logical(sep_auto-tank-attr.attr-value)
    then do :
      infoSectionsTotal:IsSGDKK = yes .
    end .

    if parline-mode <> {&add-def} then do:
      infoSectionsTotal:GetDBAllAttr().
      v-prt-start-real-date = infoSectionsTotal:StartRealDate.
      v-prt-start-real-time = infoSectionsTotal:StartRealTime.
      v-prt-end-real-date = infoSectionsTotal:EndRealDate.
      v-prt-end-real-time = infoSectionsTotal:EndRealTime.
    end.
      
    if parline-mode <> {&add-def}
    then do :
      infoSectionsTotal:GetDBAllAttr().
      do ii = 1 to infoSectionsTotal:SectionNum :
        if infoSectionsTotal:GetInfoSectionProp(ii):IsKP
        then do :
          infoSectionsTotal:IsKP = yes .
          if infoSectionsTotal:GetInfoSectionProp(ii):AccMeth = 1
          then do :
            infoSectionsTotal:IsKPrvs = yes .
          end .
        end .
      end .
    end .
    
    run display-measure in this-procedure
    no-error .
    
/*    if infoSectionsTotal:IsKPrvs                           */
/*    and tt-fr-doc-line.fact-qnty <> tt-fr-doc-line.doc-qnty*/
/*    then do :                                              */
/*      isKPrvsSet = yes .                                   */
/*    end .                                                  */

    if t-doc.flag_ = true
      or t-doc.status_ = {&fact}
    then do:
      hide
        b-docsec
        in frame {&frame-name}.
      run display-b-rvs in this-procedure
        no-error .
      enable
        b-addinf
        with frame {&frame-name}.
      run display-measure in this-procedure
        no-error .
    end.
    else do:
      if parline-mode <> {&lookup} then do:
        if vardensity-input = true then do:
          enable
            tt-fr-doc-line.doc-density
            with frame {&frame-name}.
        end.
        enable
          tt-fr-doc-line.temperature
          with frame {&frame-name}.
      end.
    end.

    /*assign
      v-car-num          = infoSectionsTotal:CarNum
      v-car-vol          = string ( infoSectionsTotal:CarVolTotal )
      v-autoent-obj-type = v-prt-autoent-obj-type
      v-autoent-obj-code = v-prt-autoent-obj-code
      v-fio              = v-prt-fio
      v-ptbotype         = v-prt-ptbotype
      v-ptbocode         = v-prt-ptbocode
    .*/
    
    
    
    define variable NormWast as class ibs.th.ref.normwastsub no-undo.

    if stfactplvalue <> ""  then 
    do:
      { str/chkqtpl.i
         stfactplvalue
         varupd-fact-qnty
         varrevision
         varpercrev
         varauto-tank
         varpercauto
         varinv
         varpercinv
         varinv-set
         no-error
       }
      if error-status :error then 
      do:
        message
          vss-workfile vss-revision vss-description skip
          "Разборе строки параметра stfactpl" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return error .
      end.
    end.
    NormWast = new ibs.th.ref.normwastsub ().
    NormWast:ParGdsOAttr:GdsCode = buf_goods.gds-code.
    NormWast:ParGdsOAttr:ObjType = t-doc.obj-type.
    NormWast:ParGdsOAttr:ObjCode = t-doc.obj-code.
    NormWast:ParGdsOAttr:OnDate = today.

    run gds-o-normal-wastage-value in this-procedure
    ( input-output NormWast).
    
    infoSectionsTotal:NormalWastage = NormWast:NormalWastageTransDate .

/*    input buf_goods.gds-code         */
/*     , input t-doc.obj-type          */
/*     , input t-doc.obj-code          */
/*     , input today                   */
/*     , output v-normal-wastage-winter*/
/*     , output v-normal-wastage-summer*/
/*     , output v-normal-wastage       */

    if v-is-lgas or v-is-lgas-corr
    then do:
      hide
        b-docsec
        b-addinf
        in frame {&frame-name}.
      display tt-fr-doc-line.propan-perc with frame {&frame-name}.
      if parline-mode <> {&lookup}
      and not t-doc.flag_
      then do:
        enable tt-fr-doc-line.propan-perc with frame {&frame-name}.
        for first tt-doc-pl :
          find first bf_place-attr no-lock where bf_place-attr.obj-type  = tt-doc-pl.obj-type 
                                             and bf_place-attr.obj-code  = tt-doc-pl.obj-code 
                                             and bf_place-attr.pl-code   = tt-doc-pl.pl-code
                                             and bf_place-attr.attr-code = "place-gate-valve"
                                             no-error .
          if available bf_place-attr
          and logical(bf_place-attr.attr-value)
          then do :
            enable cb-connect-hoses with frame {&FRAME-NAME} .
          end .
          else do :
            disable cb-connect-hoses with frame {&FRAME-NAME} .
          end .
        end .
      end .
    end.
    else do :
      hide tt-fr-doc-line.propan-perc cb-connect-hoses in frame {&frame-name}.
    end .
      
    if parline-mode <> {&add-def} then infoSectionsTotal:GetDBAllAttr().

      
    tanksForm = new ibs.th.str.ptrl.forms.tanksections(infoSectionsTotal).
      
      /*run str/in-ladd.w
        ( input        parParentProc
         ,input        "get-attr":U
         ,input        t-doc.doc-code
         ,input        buf_goods.gds-code
         ,input-output infoSectionsTotal
         ,      output was_setting
        ) .*/
      
        /*IF  was_setting = YES
        AND (
              v-car-num          <> v-prt-car-num
           OR v-car-vol          <> v-prt-car-vol
           OR v-autoent-obj-type <> v-prt-autoent-obj-type
           OR v-autoent-obj-code <> v-prt-autoent-obj-code
           OR v-fio              <> v-prt-fio
           OR v-ptbotype         <> v-prt-ptbotype
           OR v-ptbocode         <> v-prt-ptbocode
            )
        THEN DO:
           assign
              v-change = TRUE
           .
        end.*/
  
     if stfactplvalue <> ""  then do:
       { str/chkqtpl.i
         stfactplvalue
         varupd-fact-qnty
         varrevision
         varpercrev
         varauto-tank
         varpercauto
         varinv
         varpercinv
         varinv-set
         no-error
       }
       if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Разборе строки параметра stfactpl" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return error .
       end.
     end.
  end.

end. /* if varrvs-place = yes */


/* показ новой продажной цены */
run new-price-s in this-procedure .
run new-price-prod in this-procedure .

find first bf_gds-obj where bf_gds-obj.obj-type  = t-doc.obj-type           and
                            bf_gds-obj.obj-code  = t-doc.obj-code           and
                            bf_gds-obj.artic     = tt-fr-doc-line.artic     and
                            bf_gds-obj.prod-type = tt-fr-doc-line.prod-type and
                            bf_gds-obj.prod-code = tt-fr-doc-line.prod-code no-lock no-error.
if t-doc.fact-order = 0 then do:
  find last bf_doc-line where bf_doc-line.obj-type     = t-doc.obj-type           and
                              bf_doc-line.obj-code     = t-doc.obj-code           and
                              bf_doc-line.prod-type    = tt-fr-doc-line.prod-type and
                              bf_doc-line.prod-code    = tt-fr-doc-line.prod-code and
                              bf_doc-line.artic        = tt-fr-doc-line.artic     and
                              bf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh}       and
                              bf_doc-line.status_      = {&fact}                  and
                              bf_doc-line.fact-order   > 0                        use-index dt-fo no-lock no-error.
end.
else do:
  find last bf_doc-line where bf_doc-line.obj-type     = t-doc.obj-type            and
                              bf_doc-line.obj-code     = t-doc.obj-code            and
                              bf_doc-line.prod-type    = tt-fr-doc-line.prod-type  and
                              bf_doc-line.prod-code    = tt-fr-doc-line.prod-code  and
                              bf_doc-line.artic        = tt-fr-doc-line.artic      and
                              bf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh}        and
                              bf_doc-line.status_      = {&fact}                   and
                              bf_doc-line.fact-order   < t-doc.fact-order          use-index dt-fo no-lock no-error.
end.

if available bf_doc-line then do:
  assign
    vargds-obj-last-rubl  = bf_doc-line.price-rubl.
  if available bf_gds-obj then do:
    assign
      vargds-obj-fact-qnty  = bf_gds-obj.fact-qnty
      vargds-obj-price-sale = bf_gds-obj.price-sale
      vargds-obj-pc-ov      = (if varr-b = "base" then (vargds-obj-price-sale / bf_gds-obj.last-base * 100 - 100) else (vargds-obj-price-sale / bf_gds-obj.last-rubl * 100 - 100)).
  end.
  else do:
    assign
      vargds-obj-fact-qnty  = ?
      vargds-obj-price-sale = ?
      vargds-obj-pc-ov      = ? .
  end.
  find first bf_trn-doc where bf_trn-doc.doc-code = bf_doc-line.doc-code no-lock no-error.
  if available bf_trn-doc then do:
    assign
      vargds-obj-cli-type = bf_trn-doc.cli-type
      vargds-obj-cli-code = bf_trn-doc.cli-code.

    find first bf_clients where bf_clients.obj-type = bf_trn-doc.cli-type and
                                bf_clients.obj-code = bf_trn-doc.cli-code no-lock no-error.
    if available bf_clients then do:
      assign vargds-obj-cli-name = bf_clients.obj-name.

    end.
  end.
  else do:
    assign
      vargds-obj-cli-type = ""
      vargds-obj-cli-code = ?
      vargds-obj-cli-name = ""
    .
  end.
end.
else do:
  assign
    vargds-obj-fact-qnty  = ?
    vargds-obj-last-rubl  = ?
    vargds-obj-price-sale = ?
    vargds-obj-pc-ov      = ?
    vargds-obj-cli-type   = ""
    vargds-obj-cli-code   = ?
    vargds-obj-cli-name   = ""
    .
  if available bf_gds-obj then do:
    assign
      vargds-obj-fact-qnty  = bf_gds-obj.fact-qnty
      vargds-obj-price-sale = bf_gds-obj.price-sale
      vargds-obj-pc-ov      = (if varr-b = "base" then (vargds-obj-price-sale / bf_gds-obj.last-base * 100 - 100) else (vargds-obj-price-sale / bf_gds-obj.last-rubl * 100 - 100)).
  end.
  else do:
    assign
      vargds-obj-fact-qnty  = ?
      vargds-obj-price-sale = ?
      vargds-obj-pc-ov      = ? .
  end.

end.
display vargds-obj-fact-qnty
        vargds-obj-price-sale
        vargds-obj-pc-ov
        vargds-obj-last-rubl
        vargds-obj-cli-name
        vargds-obj-cli-type
        vargds-obj-cli-code
        with frame {&frame-name}.

/*Выводим номер ГТД общий для всех партий в строке*/
find first cst-parts where cst-parts.obj-type  = t-doc.obj-type        and
                           cst-parts.obj-code  = t-doc.obj-code        and
                           cst-parts.prod-type = tt-fr-doc-line.prod-type and
                           cst-parts.prod-code = tt-fr-doc-line.prod-code and
                           cst-parts.artic     = tt-fr-doc-line.artic     and
                           cst-parts.out-code  = t-doc.doc-code  no-lock no-error.
if not available cst-parts then do:
   assign tt-fr-doc-line.cst-code = t-doc.cst-code.
   display tt-fr-doc-line.cst-code with frame {&frame-name}.
end.
else do:
  find first cst-parts-another where cst-parts-another.obj-type  =  t-doc.obj-type         and
                                     cst-parts-another.obj-code  =  t-doc.obj-code         and
                                     cst-parts-another.prod-type =  tt-fr-doc-line.prod-type  and
                                     cst-parts-another.prod-code =  tt-fr-doc-line.prod-code  and
                                     cst-parts-another.artic     =  tt-fr-doc-line.artic      and
                                     cst-parts-another.out-code  =  t-doc.doc-code         and
                                     cst-parts-another.cst-code  <> cst-parts.cst-code     no-lock no-error.
  if available cst-parts-another then do:
    assign tt-fr-doc-line.cst-code = ?.
    display tt-fr-doc-line.cst-code with frame {&frame-name}.
  end.
  else do:
    assign tt-fr-doc-line.cst-code = cst-parts.cst-code.
    display tt-fr-doc-line.cst-code with frame {&frame-name}.
  end.
end.
/*Выводим номер договора*/
find first bf_parts where bf_parts.obj-type  = t-doc.obj-type           and
                          bf_parts.obj-code  = t-doc.obj-code           and
                          bf_parts.prod-type = tt-fr-doc-line.prod-type and
                          bf_parts.prod-code = tt-fr-doc-line.prod-code and
                          bf_parts.artic     = tt-fr-doc-line.artic     and
                          bf_parts.out-code  = t-doc.doc-code           no-lock no-error.
if not available bf_parts then do:
  find first bf_contract where bf_contract.contract-code = t-doc.contract-code no-lock no-error.
  if available bf_contract then do:
    assign
      tt-fr-doc-line.contract-code     = bf_contract.contract-code
      tt-fr-doc-line.contract-prn-code = bf_contract.contract-prn-code.
    /*display tt-fr-doc-line.contract-prn-code with frame {&frame-name}.*/
  end.
end.
else do:
  find first bf-another_parts where bf-another_parts.obj-type        = t-doc.obj-type           and
                                    bf-another_parts.obj-code        = t-doc.obj-code           and
                                    bf-another_parts.prod-type       = tt-fr-doc-line.prod-type and
                                    bf-another_parts.prod-code       = tt-fr-doc-line.prod-code and
                                    bf-another_parts.artic           = tt-fr-doc-line.artic     and
                                    bf-another_parts.out-code        = t-doc.doc-code           and
                                    bf-another_parts.contract-code  <> bf_parts.contract-code   no-lock no-error.
  if available bf-another_parts then do:
    assign tt-fr-doc-line.contract-code     = ?
           tt-fr-doc-line.contract-prn-code = ?.
    /*display tt-fr-doc-line.contract-prn-code with frame {&frame-name}.*/
  end.
  else do:
    find first bf_contract where bf_contract.contract-code = bf_parts.contract-code no-lock no-error.
    if available bf_contract then do:
      assign
        tt-fr-doc-line.contract-code     = bf_contract.contract-code
        tt-fr-doc-line.contract-prn-code = bf_contract.contract-prn-code.
      /*display tt-fr-doc-line.contract-prn-code with frame {&frame-name}.*/
    end.
  end.
end.
/*Выводим срок хранения*/
find first bf_parts where bf_parts.obj-type  = t-doc.obj-type           and
                          bf_parts.obj-code  = t-doc.obj-code           and
                          bf_parts.prod-type = tt-fr-doc-line.prod-type and
                          bf_parts.prod-code = tt-fr-doc-line.prod-code and
                          bf_parts.artic     = tt-fr-doc-line.artic     and
                          bf_parts.out-code  = t-doc.doc-code           no-lock no-error.
if available bf_parts then do:
  find first bf-another_parts where bf-another_parts.obj-type     = t-doc.obj-type           and
                                    bf-another_parts.obj-code     = t-doc.obj-code           and
                                    bf-another_parts.prod-type    = tt-fr-doc-line.prod-type and
                                    bf-another_parts.prod-code    = tt-fr-doc-line.prod-code and
                                    bf-another_parts.artic        = tt-fr-doc-line.artic     and
                                    bf-another_parts.out-code     = t-doc.doc-code           and
                                    bf-another_parts.last-date   <> bf_parts.last-date       no-lock no-error.
  if available bf-another_parts then do:
    assign tt-fr-doc-line.last-date    = ?
           tt-fr-doc-line.last-num-day = ?.
    display tt-fr-doc-line.last-date tt-fr-doc-line.last-num-day with frame {&frame-name}.
  end.
  else do:
    assign
      tt-fr-doc-line.last-date    = bf_parts.last-date
      tt-fr-doc-line.last-num-day = bf_parts.last-date - today + 1.
    display tt-fr-doc-line.last-date tt-fr-doc-line.last-num-day with frame {&frame-name}.
  end.
end.

/* Атрибуты алкогольной продукции */
if tt-fr-doc-line.alc-prod then do:
  if available bf_parts then do:
    find first bf-another_parts where bf-another_parts.obj-type   = t-doc.obj-type           and
                                      bf-another_parts.obj-code   = t-doc.obj-code           and
                                      bf-another_parts.prod-type  = tt-fr-doc-line.prod-type and
                                      bf-another_parts.prod-code  = tt-fr-doc-line.prod-code and
                                      bf-another_parts.artic      = tt-fr-doc-line.artic     and
                                      bf-another_parts.out-code   = t-doc.doc-code           and
                                      recid(bf-another_parts)    <> recid(bf_parts) no-lock no-error.
    if available bf-another_parts then do:
      /* У строки накладной несколько партий - сохраняем код первой партии
         для резервирования */
      assign
        tt-fr-doc-line.alc-multi-parts = yes
        tt-fr-doc-line.alc-update      = no
        tt-fr-doc-line.alc-part-code   = bf_parts.part-code
      .
    end.
    else do:
      assign
        tt-fr-doc-line.alc-multi-parts         = no
        tt-fr-doc-line.alc-update              = yes
        tt-fr-doc-line.alc-part-code           = bf_parts.part-code
        tt-fr-doc-line.alc-mark-db-num         = bf_parts.mark-db-num
        tt-fr-doc-line.alc-mark-code           = bf_parts.mark-code
        tt-fr-doc-line.alc-bottling-date       = bf_parts.alc-bottling-date
        tt-fr-doc-line.alc-ref-ab-path         = bf_parts.alc-ref-ab-path
        tt-fr-doc-line.alc-quality-certif-path = bf_parts.alc-quality-certif-path
        tt-fr-doc-line.alc-certif-path         = bf_parts.alc-certif-path
        tt-fr-doc-line.alc-imp-type            = bf_parts.alc-imp-type
        tt-fr-doc-line.alc-imp-code            = bf_parts.alc-imp-code
      .
    end.
  end.
  else do: /* not available bf_parts */
    assign
      tt-fr-doc-line.alc-multi-parts = no
      tt-fr-doc-line.alc-update      = yes
      tt-fr-doc-line.alc-part-code   = ?
    .
  end.
end.

/* Страна */
define variable v-type as character no-undo .
define variable v-value as character no-undo .
define variable v-exist as logical   no-undo .

run lineattr-exist in this-procedure (
    input   t-doc.doc-code  ,
    input   buf_goods.gds-code  ,
    input   {&lineattr-country-code} ,
    output  v-exist       )
    no-error .
    if error-status :error then do:
       message vss-workfile vss-revision vss-description skip
               error-status :get-message( 1 )
               return-value
       view-as alert-box error .
       return error.
    end.


if not v-exist then do:
   find first buf_country no-lock where  buf_country.alpha1 = buf_goods.alpha1  no-error .
   if available buf_country then do:
    assign
      tt-fr-doc-line.alpha1       = buf_country.alpha1
      tt-fr-doc-line.country-code = buf_country.num-code
      tt-fr-doc-line.short-name   = buf_country.short-name
    .
   end.
end.
else do:
  run lineattr-value in this-procedure (
      input   t-doc.doc-code  ,
      input   buf_goods.gds-code  ,
      input   {&lineattr-country-code} ,
      output  v-value      ,
      output  v-type       )
      no-error .
      if error-status :error then do:
        message vss-workfile vss-revision vss-description skip
                error-status :get-message( 1 )
                return-value
        view-as alert-box error .
        return error.
      end.

   find first buf_country no-lock where  buf_country.num-code = int(v-value)  no-error .
   if available buf_country then do:
    assign
      tt-fr-doc-line.alpha1       = buf_country.alpha1
      tt-fr-doc-line.country-code = buf_country.num-code
      tt-fr-doc-line.short-name   = buf_country.short-name
    .
   end.
   else do:
      find first buf_country no-lock where  buf_country.alpha1 = buf_goods.alpha1  no-error .
      if available buf_country then do:
        assign
          tt-fr-doc-line.alpha1       = buf_country.alpha1
          tt-fr-doc-line.country-code = buf_country.num-code
          tt-fr-doc-line.short-name   = buf_country.short-name
        .
      end.
   end.
end.
display tt-fr-doc-line.alpha1
        tt-fr-doc-line.short-name
        with frame {&frame-name}.


/*Надбавим предварительную дельту*/

if parline-mode <> {&lookup} and
   parqnty   <> 0         then do:
   if line-rec <> ? then do:
     if kind-qnty = "doc" then do:
        assign  tt-fr-doc-line.cli-qnty = tt-fr-doc-line.cli-qnty + parqnty / tt-fr-doc-line.cli-base-rate
                tt-fr-doc-line.doc-qnty = tt-fr-doc-line.cli-qnty * tt-fr-doc-line.cli-base-rate.
     end.
     else do:
        assign  tt-fr-doc-line.fact-qnty = tt-fr-doc-line.fact-qnty + parqnty.
        if is-petrolium = yes and is-pieces = no then do:
          assign  tt-fr-doc-line.fact-qnty-kg = tt-fr-doc-line.fact-qnty * tt-fr-doc-line.fact-density.
        end.
     end.
   end.
   else do:
     if kind-qnty = "doc" then do:
        assign tt-fr-doc-line.cli-qnty = parqnty / tt-fr-doc-line.cli-base-rate
               tt-fr-doc-line.doc-qnty = tt-fr-doc-line.cli-qnty * tt-fr-doc-line.cli-base-rate.
     end.
     else do:
        assign  tt-fr-doc-line.fact-qnty = parqnty.
        if is-petrolium = yes and is-pieces = no then do:
          assign  tt-fr-doc-line.fact-qnty-kg = tt-fr-doc-line.fact-qnty * tt-fr-doc-line.fact-density.
        end.
     end.
   end.
   if kind-qnty = "doc" then do:
      display tt-fr-doc-line.cli-qnty tt-fr-doc-line.doc-qnty with frame {&frame-name}.
      hide    tt-fr-doc-line.fact-qnty    in frame {&frame-name}
              tt-fr-doc-line.fact-qnty-kg in frame {&frame-name}
              tt-fr-doc-line.fact-density in frame {&frame-name}
              .
   end.
   else do:
      display tt-fr-doc-line.fact-qnty with frame {&frame-name}.
      if is-petrolium = yes and is-pieces = no then do:
        display tt-fr-doc-line.fact-qnty-kg 
        tt-fr-doc-line.fact-density
        with frame {&frame-name}.
      end.
   end.

   /*Иначе повоторное добавление при вызове ui-on*/
   assign kind-qnty = ?
          parqnty   = 0.
end.

if is-petrolium = yes
  and is-pieces = no
then do:
  display tt-fr-doc-line.doc-density with frame {&frame-name}.
/*  if kind-qnty <> "doc" then do:*/
/*    display tt-fr-doc-line.fact-density with frame {&frame-name}.*/
/*  end.*/
end.


find ub.gds-prt where ub.gds-prt.upper-code = tt-fr-doc-line.prt-root no-lock.
for each ub.gds-dtl where ub.gds-dtl.prod-type = tt-fr-doc-line.prod-type and
                       ub.gds-dtl.prod-code = tt-fr-doc-line.prod-code and
                       ub.gds-dtl.artic     = tt-fr-doc-line.artic     and
                       ub.gds-dtl.doc-code  = t-doc.doc-code        and
                       ub.gds-dtl.prt-code <> ub.gds-prt.node-code
                       :
   accumulate ub.gds-dtl.doc-qnty (total) ub.gds-dtl.fact-qnty (total).
end.
assign
  prt-doc =  (accum total ub.gds-dtl.doc-qnty)
  prt-fact = (accum total ub.gds-dtl.fact-qnty).
/*enableим поля и кнопки*/
if prtvalue  = "yes"                   and
   ub.gds-prt.node-name <> {&empty-scale} and
   v-cntxp-doc-prt                     then enable b-prt with frame {&frame-name}.
if b-prt:sensitive and t-doc.status_ <> {&fact} then do:
  disp prt-doc with frame {&frame-name}.
  if t-doc.flag_ then disp prt-fact with frame {&frame-name}.
                 else hide prt-fact in   frame {&frame-name}.
end.

enable b-parts with frame {&frame-name}.
if parlns-cnt > 1 then enable b-exit-cycl with frame {&frame-name}.
if tt-fr-doc-line.alc-prod then enable b-alc-attr with frame {&frame-name}.

if parline-mode <> {&lookup} then do:
  enable b-save  with frame {&frame-name}.
  /*накл-*/
  if not t-doc.flag_ then do:
     enable tt-fr-doc-line.cst-code r-country /*tt-fr-doc-line.contract-prn-code r-dog*/ tt-fr-doc-line.last-date b-choose-last-date tt-fr-doc-line.last-num-day with frame {&frame-name}.
     if v-cntxp-inout-price = true
       and v-insalepr = false
     then do:
        if not cross-list({&twounit}, tt-fr-doc-line.unit-type, ?) and
           vat-sumvalue = "yes" then do:
            enable tt-fr-doc-line.type-inp-vat when t-doc.vat-type <> {&without-vat} with frame {&frame-name}.
            if tt-fr-doc-line.type-inp-vat then do:
              enable tt-fr-doc-line.vat-pc when t-doc.vat-type <> {&without-vat} with frame {&frame-name}.
            end.
            else do:
              enable sum-vat when t-doc.vat-type <> {&without-vat} with frame {&frame-name}.
              apply "leave" to sum-vat in frame {&frame-name}.
            end.
         end.
         else do:
           enable tt-fr-doc-line.vat-pc when t-doc.vat-type <> {&without-vat} with frame {&frame-name}.
         end.
         enable tt-fr-doc-line.slt-pc when t-doc.slt-type <> {&without-slt} with frame {&frame-name}.
     end.
     if custvalue = "yes" then do:
        enable tt-fr-doc-line.wt-brutto tt-fr-doc-line.wt-place tt-fr-doc-line.num-place with frame {&frame-name}.
     end.
     if varprice-cli-input = true
       and v-insalepr = false
     then do:
        if tt-fr-doc-line.type-inp-sum = yes then do:
          enable tt-fr-doc-line.tot-cli  with frame {&frame-name}.
        end.
        else do:
          enable tt-fr-doc-line.price-cli  with frame {&frame-name}.
        end.
     end.
     if varbase-price-input = true
       and v-insalepr = false
     then do:
       enable tt-fr-doc-line.price-rubl with frame {&frame-name}.
     end.
     if v-cntxp-unit-cli-perm then do:
        if varcli-base-rate-input then do:
          enable tt-fr-doc-line.cli-base-rate with frame {&frame-name}.
        end.
        if varext-gds-type <> {&gds-bottle} and
           varext-gds-type <> {&gds-gold}   and
           varext-gds-type <> {&gds-pcptrl} and
           varext-gds-type <> {&gds-kgptrl} and
           varext-gds-type <> {&gds-lptrl}  and
           varext-gds-type <> {&gds-serial} then do:
             enable tt-fr-doc-line.unit-cli r-units with frame {&frame-name}.
        end.
     end.
     if is-petrolium = yes
       and is-pieces = no
     then do:
       enable tt-fr-doc-line.temperature with frame {&frame-name}.
     end.
     if varcli-qnty-input   then enable tt-fr-doc-line.cli-qnty with frame {&frame-name}.
     if vardensity-input    then enable tt-fr-doc-line.doc-density with frame {&frame-name}.
     if vardoc-qnty-input   then enable tt-fr-doc-line.doc-qnty with frame {&frame-name}.
     if vartax-3-input      then enable road-tax-cli with frame {&frame-name}.
     if varcli-qnty-input then do:
       apply "entry" to tt-fr-doc-line.cli-qnty in frame {&frame-name}.
     end.
     else do:
        if varcli-base-rate-input then apply "entry" to tt-fr-doc-line.cli-base-rate in frame {&frame-name}.
        else do:
           if vardensity-input then apply "entry" to tt-fr-doc-line.doc-density in frame {&frame-name}.
           else do:
              if vardoc-qnty-input then do:
                apply "entry" to tt-fr-doc-line.doc-qnty  in frame {&frame-name}.
              end.
              else do:
                if tt-fr-doc-line.price-cli:sensitive in frame {&frame-name} then do:
                  apply "entry" to tt-fr-doc-line.price-cli in frame {&frame-name}.
                end.
                if tt-fr-doc-line.tot-cli:sensitive in frame {&frame-name} then do:
                  apply "entry" to tt-fr-doc-line.tot-cli in frame {&frame-name}.
                end.
              end.
           end.
        end.
     end.
  end.
  /*накл+*/
  else do:
     if varfact-qnty-input then enable tt-fr-doc-line.fact-qnty with frame {&frame-name}.
  end.
end.
if v-edit-fact-wayb
  then enable tt-fr-doc-line.fact-qnty with frame {&frame-name}.
enable b-quit b-help with frame {&frame-name}.
      assign
        frame {&frame-name} tt-fr-doc-line.fact-qnty
      .
run disp-total in this-procedure.
end.
if is-petrolium = yes and is-pieces = no and not v-lgas-gds then do:
  disable 
    tt-fr-doc-line.doc-density
    tt-fr-doc-line.fact-qnty
    tt-fr-doc-line.fact-qnty-kg
    tt-fr-doc-line.doc-qnty
    tt-fr-doc-line.cli-qnty
    tt-fr-doc-line.temperature
    tt-fr-doc-line.doc-density
    tt-fr-doc-line.fact-density 
    with frame {&frame-name}.
  hide tt-fr-doc-line.cli-base-rate tt-fr-doc-line.temperature tt-fr-doc-line.doc-density in frame {&frame-name}.
end.
end procedure. /* ui-on */

procedure check-frame:
define input parameter kind-check as character no-undo. /*В случае серийного товара кол-во будет наследоватьс
                                                          из партий и его не надо проверять*/
/*---------------------------------------------------*/
/*Проверка того, что отработали все триггера на leave*/
/*---------------------------------------------------*/
if tt-fr-doc-line.cli-art          :sensitive in frame {&frame-name} and input frame {&frame-name} tt-fr-doc-line.cli-art         <> tt-fr-doc-line.cli-art        then apply "leave" to tt-fr-doc-line.cli-art        in frame {&frame-name}.
if tt-fr-doc-line.cst-code         :sensitive in frame {&frame-name} and input frame {&frame-name} tt-fr-doc-line.cst-code        <> tt-fr-doc-line.cst-code       then apply "leave" to tt-fr-doc-line.cst-code       in frame {&frame-name}.
/*if tt-fr-doc-line.contract-prn-code:sensitive in frame {&frame-name} and input frame {&frame-name} tt-fr-doc-line.contract-prn-code <> tt-fr-doc-line.contract-prn-code       then apply "leave" to tt-fr-doc-line.contract-prn-code in frame {&frame-name}.*/

if tt-fr-doc-line.cli-qnty         :sensitive in frame {&frame-name} then do :
  if input frame {&frame-name} tt-fr-doc-line.cli-qnty = 0
  or input frame {&frame-name} tt-fr-doc-line.cli-qnty = ?
  then do:
    message "Не указано количество в единицах измерения поставщика." view-as alert-box error .
    display tt-fr-doc-line.type-inp-vat with frame {&frame-name} .
    apply "entry" to tt-fr-doc-line.cli-qnty in frame {&frame-name} .
    return error .
  end.
  if input frame {&frame-name} tt-fr-doc-line.cli-qnty <> tt-fr-doc-line.cli-qnty then
    apply "leave" to tt-fr-doc-line.cli-qnty       in frame {&frame-name}.
end .

if tt-fr-doc-line.unit-cli         :sensitive in frame {&frame-name} and input frame {&frame-name} tt-fr-doc-line.unit-cli        <> tt-fr-doc-line.unit-cli       then apply "leave" to tt-fr-doc-line.unit-cli       in frame {&frame-name}.
if tt-fr-doc-line.doc-density      :sensitive in frame {&frame-name} and input frame {&frame-name} tt-fr-doc-line.doc-density     <> tt-fr-doc-line.doc-density    then apply "leave" to tt-fr-doc-line.doc-density    in frame {&frame-name}.
if tt-fr-doc-line.temperature      :sensitive in frame {&frame-name} and input frame {&frame-name} tt-fr-doc-line.temperature     <> tt-fr-doc-line.temperature    then apply "leave" to tt-fr-doc-line.temperature    in frame {&frame-name}.
if tt-fr-doc-line.cli-base-rate    :sensitive in frame {&frame-name} and input frame {&frame-name} tt-fr-doc-line.cli-base-rate   <> tt-fr-doc-line.cli-base-rate  then apply "leave" to tt-fr-doc-line.cli-base-rate  in frame {&frame-name}.
if tt-fr-doc-line.doc-qnty         :sensitive in frame {&frame-name} and input frame {&frame-name} tt-fr-doc-line.doc-qnty        <> tt-fr-doc-line.doc-qnty       then apply "leave" to tt-fr-doc-line.doc-qnty       in frame {&frame-name}.
if tt-fr-doc-line.fact-qnty        :sensitive in frame {&frame-name} and input frame {&frame-name} tt-fr-doc-line.doc-qnty        <> tt-fr-doc-line.doc-qnty       then apply "leave" to tt-fr-doc-line.doc-qnty       in frame {&frame-name}.
if tt-fr-doc-line.unit-base        :sensitive in frame {&frame-name} and input frame {&frame-name} tt-fr-doc-line.unit-base       <> tt-fr-doc-line.unit-base      then apply "leave" to tt-fr-doc-line.unit-base      in frame {&frame-name}.
if tt-fr-doc-line.fact-qnty        :sensitive in frame {&frame-name} and input frame {&frame-name} tt-fr-doc-line.fact-qnty       <> tt-fr-doc-line.fact-qnty      then apply "leave" to tt-fr-doc-line.fact-qnty      in frame {&frame-name}.
if tt-fr-doc-line.vat-pc           :sensitive in frame {&frame-name} and input frame {&frame-name} tt-fr-doc-line.vat-pc          <> tt-fr-doc-line.vat-pc         then apply "leave" to tt-fr-doc-line.vat-pc         in frame {&frame-name}.
if tt-fr-doc-line.slt-pc           :sensitive in frame {&frame-name} and input frame {&frame-name} tt-fr-doc-line.slt-pc          <> tt-fr-doc-line.slt-pc         then apply "leave" to tt-fr-doc-line.slt-pc         in frame {&frame-name}.
if tt-fr-doc-line.price-cli        :sensitive in frame {&frame-name} and input frame {&frame-name} tt-fr-doc-line.price-cli       <> tt-fr-doc-line.price-cli      then apply "leave" to tt-fr-doc-line.price-cli      in frame {&frame-name}.
if tt-fr-doc-line.tot-cli          :sensitive in frame {&frame-name} and input frame {&frame-name} tt-fr-doc-line.tot-cli         <> tt-fr-doc-line.tot-cli        then apply "leave" to tt-fr-doc-line.tot-cli        in frame {&frame-name}.
if tt-fr-doc-line.num-place        :sensitive in frame {&frame-name} and input frame {&frame-name} tt-fr-doc-line.num-place       <> tt-fr-doc-line.num-place      then apply "leave" to tt-fr-doc-line.num-place      in frame {&frame-name}.
if tt-fr-doc-line.wt-brutto        :sensitive in frame {&frame-name} and input frame {&frame-name} tt-fr-doc-line.wt-brutto       <> tt-fr-doc-line.wt-brutto      then apply "leave" to tt-fr-doc-line.wt-brutto      in frame {&frame-name}.
if tt-fr-doc-line.road-tax         :sensitive in frame {&frame-name} and input frame {&frame-name} tt-fr-doc-line.road-tax        <> tt-fr-doc-line.road-tax       then apply "leave" to tt-fr-doc-line.road-tax       in frame {&frame-name}.
if tt-fr-doc-line.excise           :sensitive in frame {&frame-name} and input frame {&frame-name} tt-fr-doc-line.excise          <> tt-fr-doc-line.excise         then apply "leave" to tt-fr-doc-line.excise         in frame {&frame-name}.
if road-tax-cli                    :sensitive in frame {&frame-name} and input frame {&frame-name} road-tax-cli                   <> road-tax-cli                  then apply "leave" to road-tax-cli                  in frame {&frame-name}.
if tt-fr-doc-line.last-date        :sensitive in frame {&frame-name} and input frame {&frame-name} tt-fr-doc-line.last-date       <> tt-fr-doc-line.last-date      then apply "leave" to tt-fr-doc-line.last-date      in frame {&frame-name}.
if tt-fr-doc-line.last-num-day     :sensitive in frame {&frame-name} and input frame {&frame-name} tt-fr-doc-line.last-num-day    <> tt-fr-doc-line.last-num-day   then apply "leave" to tt-fr-doc-line.last-num-day   in frame {&frame-name}.
define buffer bf-units-cli for ub.units.

  if not (kind-check begins "light" and lookup({&serial}, tt-fr-doc-line.unit-type) > 0) and
     (tt-fr-doc-line.cli-qnty = 0 or tt-fr-doc-line.cli-qnty = ?) and not t-doc.flag_ then do:
    if kind-check <> "light-super" then
       message "Не указано количество в единицах поставщика." view-as alert-box error.

    if tt-fr-doc-line.cli-qnty:sensitive then apply "entry" to tt-fr-doc-line.cli-qnty in frame {&frame-name}.
                                      else apply "entry" to b-quit               in frame {&frame-name}.
    return error.
  end.
  if not (kind-check begins "light" and lookup({&serial}, tt-fr-doc-line.unit-type) > 0) and
     (tt-fr-doc-line.doc-qnty = 0 or tt-fr-doc-line.doc-qnty = ?) and not t-doc.flag_ then do:
    if kind-check <> "light-super" then
    message "Не указано количество по накладной в учетных единицах." view-as alert-box error.
    return error.
  end.
  if (tt-fr-doc-line.fact-qnty < 0 or tt-fr-doc-line.fact-qnty = ?) and t-doc.flag_ then do:
    if kind-check <> "light-super" then
    message "Неправильное факт. количество в учетных единицах." view-as alert-box error.
    apply "entry" to tt-fr-doc-line.fact-qnty in frame {&frame-name}.
    return error.
  end.
  if (tt-fr-doc-line.fact-qnty > tt-fr-doc-line.doc-qnty and
      v-hold-doc = true  ) then do:
    message "Данный документ был автоматически создан по перемещению от своей фирмы." skip
            "Нельзя указывать фактическое количество больше документарного."
    view-as alert-box error.
    apply "entry" to tt-fr-doc-line.fact-qnty in frame {&frame-name}.
    return error.
  end.

  find t-doc where recid( t-doc ) = pardoc-rec.
  if t-doc.flag_ = yes                                          and
     lookup( {&pieces}, tt-fr-doc-line.unit-type ) > 0          and
     truncate( tt-fr-doc-line.fact-qnty, 0 ) <> tt-fr-doc-line.fact-qnty
  then do:
      message "Базовая единица товара " tt-fr-doc-line.unit-base " - штучная." skip
              "Кол-во по факту должно быть целым."
      view-as alert-box error buttons ok.
      return error.
  end.

  find bf-units-cli where bf-units-cli.unit-name = tt-fr-doc-line.unit-cli no-lock no-error.
  if not available bf-units-cli then do:
    message "Неправильная единица измерения." view-as alert-box error.
    return error.
  end.
  /*Если единица поставщика штучная, то кол-во от поставщика должно указываться целым*/
  if lookup({&pieces}, bf-units-cli.type) > 0  and
      trunc(tt-fr-doc-line.cli-qnty, 0) <> tt-fr-doc-line.cli-qnty then do:
      message "Единица поставщика " tt-fr-doc-line.unit-cli " - штучная." skip
              "Должно быть указано целое количество в единицах поставщика."
      view-as alert-box error buttons ok.
      return error.
  end.
  release bf-units-cli.

  if tt-fr-doc-line.cli-base-rate = 0 or tt-fr-doc-line.cli-base-rate = ? then do:
    message "Не указан коэффициент пересчета единиц измерения." view-as alert-box error.
    return error.
  end.
  if tt-fr-doc-line.unit-cli = tt-fr-doc-line.unit-base and tt-fr-doc-line.cli-base-rate <> 1 then do:
    message "Коэффициент пересчета единиц измерения должен быть 1, т.к. единицы совпадают." view-as alert-box error.
    return error.
  end.
  /*Если кол-во в базовых единицах товара получается дробное, то ошибка.*/
  if lookup({&pieces}, tt-fr-doc-line.unit-type) > 0           and
     trunc(tt-fr-doc-line.doc-qnty, 0) <> tt-fr-doc-line.doc-qnty then do:
     message "Базовая единица товара " tt-fr-doc-line.unit-base " - штучная." skip
             "Кол-во по документу должно быть целым."
     view-as alert-box error buttons ok.
     return error.
  end.
  run gds-attr-value in this-procedure (input  buf_goods.gds-code
                                         ,input {&attr-null-price}
                                         ,output v-gds-null-price
                                         ,output v-attr-type ) no-error .                                         
  if t-doc.status_ <> {&inquiry} and  not v-gds-null-price then do:
    if tt-fr-doc-line.price-cli = 0 or tt-fr-doc-line.price-cli = ? then do:
      message "Не указана цена в валюте поставщика." view-as alert-box error.
      return error.
    end.
    if tt-fr-doc-line.price-base = 0 or tt-fr-doc-line.price-base = ? then do:
      message "Не указана цена в базовой валюте." view-as alert-box error.
      return error.
    end.       
    if tt-fr-doc-line.price-rubl = 0 or tt-fr-doc-line.price-rubl = ? then do:
      message "Не указана цена в {&abbr_rublyah}." view-as alert-box error.
      return error.
    end.
  end.    
  
  if v-lgas-gds
  then do :
    assign tt-fr-doc-line.propan-perc cb-connect-hoses .
    
    if tt-fr-doc-line.propan-perc <= 0
    or tt-fr-doc-line.propan-perc >= 100
    or tt-fr-doc-line.propan-perc = ?
    then do :
      message "Укажите массовую долю пропана в смеси, % из паспорта качества. Данная информация является обязательной!"
      view-as alert-box .
      return error .
    end .
    
    for first tt-doc-pl :
      find first bf_place-attr no-lock where bf_place-attr.obj-type  = tt-doc-pl.obj-type 
                                         and bf_place-attr.obj-code  = tt-doc-pl.obj-code 
                                         and bf_place-attr.pl-code   = tt-doc-pl.pl-code
                                         and bf_place-attr.attr-code = "place-gate-valve"
                                         no-error .
      if available bf_place-attr
      and logical(bf_place-attr.attr-value)
      then do :
        if cb-connect-hoses = "empty"
        then do :
          message "Внимание! Укажите Подключение рукавов при приеме СУГ!"
          view-as alert-box .
          return error .
        end .
      end .
    end .
  end .                                        
  /*
  if t-doc.status_ <> {&inquiry} then do:   
    if tt-fr-doc-line.price-cli < 0  then do:
      message "Нельзя указывать отрицательные цены в валюте поставщика." view-as alert-box error.
      return error.
    end.
    if tt-fr-doc-line.price-base < 0  then do:
      message "Отрицательная цена в базовой валюте."  view-as alert-box error.
      return error.
    end.
    if tt-fr-doc-line.price-base > 5000 and bf_sysconf.base-code = 1 then do:
      message "Внимание !!!" skip (2)
              "ВАЛЮТНАЯ цена превышает 5,000 !" skip (2)
              "Вы не ошиблись ?"  view-as alert-box question.
    end.

    if tt-fr-doc-line.price-rubl < 0 then do:
      message "Отрицательная цена в {&abbr_rublyah}."  view-as alert-box error.
      return error.
    end.
  end.
  */
end procedure.

procedure check-price:
  /*Проверка на то, что во всех партиях учетные цены одинаковые*/
  define variable p-same-price as  logical no-undo.
  run trg/doclnupd.p ( input  tt-fr-doc-line.doc-code,
                   input  t-doc.obj-type,
                   input  t-doc.obj-code,
                   input  tt-fr-doc-line.artic,
                   input  tt-fr-doc-line.prod-type,
                   input  tt-fr-doc-line.prod-code,
                   output p-same-price) no-error.
  if error-status :error then do:
     message "Ошибка при просмотре учетных цен в партиях." view-as alert-box error.
     display tt-fr-doc-line.price-rubl with frame {&frame-name}.
     return error.
  end.
  if p-same-price = false then do:
     message "Нельзя изменять цены в строке, т.к. имеются разные учетные в партиях."
     view-as alert-box error.
     return error.
  end.
end procedure.

procedure delete-doc-line:
do transaction
   on error   undo , return error
   on end-key undo , return error
   on stop    undo , return error :
    { str/clcintrn.i
      parparentproc
      ?
      ub.doc-line.doc-code
      ub.doc-line.artic
      ub.doc-line.prod-type
      ub.doc-line.prod-code
      ub.doc-line.price-cli
      ub.doc-line.price-rubl
      ub.doc-line.price-base
      ub.doc-line.cli-qnty
      ub.doc-line.cli-base-rate
      ub.doc-line.fact-qnty
      ub.doc-line.doc-qnty
      ub.doc-line.vat-pc
      ub.doc-line.slt-pc
      ub.doc-line.road-tax
      ub.doc-line.excise
      ub.doc-line.transport-rubl
      ub.doc-line.other-rubl
      "'delete'"
      "''"
      no-error
    }

end.
end procedure.

procedure update-doc-line:
do transaction  on error   undo , return error
   :
   find ub.doc-line where recid(ub.doc-line) = line-rec.
      { str/clcintrn.i
        parparentproc
        recid(ub.doc-line)
        ub.doc-line.doc-code
        ub.doc-line.artic
        ub.doc-line.prod-type
        ub.doc-line.prod-code
        old-doc-line.price-cli
        old-doc-line.price-rubl
        old-doc-line.price-base
        old-doc-line.cli-qnty
        old-doc-line.cli-base-rate
        old-doc-line.fact-qnty
        old-doc-line.doc-qnty
        old-doc-line.vat-pc
        old-doc-line.slt-pc
        old-doc-line.road-tax
        old-doc-line.excise
        old-doc-line.transport-rubl
        old-doc-line.other-rubl
        "'update'"
        "''"
      }
   release ub.doc-line.
end.
end procedure.

procedure update-doc-line-without-parts:
do transaction
   on error   undo , return error :
   find ub.doc-line where recid(ub.doc-line) = line-rec.
   { str/clcintrn.i
     parparentproc
     recid(doc-line)
     ub.doc-line.doc-code
     ub.doc-line.artic
     ub.doc-line.prod-type
     ub.doc-line.prod-code
     old-doc-line.price-cli
     old-doc-line.price-rubl
     old-doc-line.price-base
     old-doc-line.cli-qnty
     old-doc-line.cli-base-rate
     old-doc-line.fact-qnty
     old-doc-line.doc-qnty
     old-doc-line.vat-pc
     old-doc-line.slt-pc
     old-doc-line.road-tax
     old-doc-line.excise
     old-doc-line.transport-rubl
     old-doc-line.other-rubl
     "'update'"
     "''"
   }

   release ub.doc-line.
end.
end procedure.

procedure disp-total:
define variable varprice-cli-dt                like ub.doc-line.price-rubl no-undo.
define variable varprice-cli-unit-base-dt      like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-dt           like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-dt          like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-dt      like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-dt        like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-dt                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-dt             like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-dt                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-dt         like ub.doc-line.price-rubl no-undo.
define variable varprice-rubl-dt               like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-rubl-dt      like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-rubl-dt     like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-rubl-dt like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-rubl-dt   like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-rubl-dt           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-rubl-dt        like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-rubl-dt           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-rubl-dt    like ub.doc-line.price-rubl no-undo.
define variable varprice-base-dt               like ub.doc-line.price-base no-undo.
define variable varprice-road-tax-base-dt      like ub.doc-line.price-base no-undo.
define variable varprice-other-exp-base-dt     like ub.doc-line.price-base no-undo.
define variable varprice-transport-exp-base-dt like ub.doc-line.price-base no-undo.
define variable varprice-without-abs-base-dt   like ub.doc-line.price-base no-undo.
define variable varprice-slt-base-dt           like ub.doc-line.price-base no-undo.
define variable varprice-no-slt-base-dt        like ub.doc-line.price-base no-undo.
define variable varprice-vat-base-dt           like ub.doc-line.price-base no-undo.
define variable varprice-no-vat-slt-base-dt    like ub.doc-line.price-base no-undo.

  assign
  tot-base = tt-fr-doc-line.price-base * (if t-doc.flag_ or t-doc.status_ = {&fact} then tt-fr-doc-line.fact-qnty else tt-fr-doc-line.doc-qnty)
  tot-rubl = tt-fr-doc-line.price-rubl * (if t-doc.flag_ or t-doc.status_ = {&fact} then tt-fr-doc-line.fact-qnty else tt-fr-doc-line.doc-qnty).
  display tot-rubl tot-base with frame {&frame-name}.
  if tt-fr-doc-line.type-inp-sum = no then do:
    assign
      tt-fr-doc-line.tot-cli  = tt-fr-doc-line.cli-qnty   * tt-fr-doc-line.price-cli.
    display tt-fr-doc-line.tot-cli with frame {&frame-name}.
  end.
  else do:
    assign
      tt-fr-doc-line.price-cli = tt-fr-doc-line.tot-cli / tt-fr-doc-line.cli-qnty.
    display tt-fr-doc-line.tot-cli tt-fr-doc-line.price-cli with frame {&frame-name}.
  end.

  /*Расчет поля <<сумма НДС>>*/
  { str/in-vat.i
    t-doc.doc-code
    t-doc.base-rate
    t-doc.base-scale
    t-doc.exch-rate
    t-doc.exch-scale
    t-doc.vat-type
    t-doc.slt-type
    tt-fr-doc-line.artic
    tt-fr-doc-line.prod-type
    tt-fr-doc-line.prod-code
    tt-fr-doc-line.price-cli
    tt-fr-doc-line.cli-base-rate
    tt-fr-doc-line.price-rubl
    tt-fr-doc-line.vat-pc
    tt-fr-doc-line.slt-pc
    tt-fr-doc-line.road-tax
    tt-fr-doc-line.transport-rubl
    tt-fr-doc-line.other-rubl
    varprice-cli-dt
    varprice-cli-unit-base-dt
    varprice-road-tax-dt
    varprice-other-exp-dt
    varprice-transport-exp-dt
    varprice-without-abs-dt
    varprice-slt-dt
    varprice-no-slt-dt
    varprice-vat-dt
    varprice-no-vat-slt-dt
    varprice-rubl-dt
    varprice-road-tax-rubl-dt
    varprice-other-exp-rubl-dt
    varprice-transport-exp-rubl-dt
    varprice-without-abs-rubl-dt
    varprice-slt-rubl-dt
    varprice-no-slt-rubl-dt
    varprice-vat-rubl-dt
    varprice-no-vat-slt-rubl-dt
    varprice-base-dt
    varprice-road-tax-base-dt
    varprice-other-exp-base-dt
    varprice-transport-exp-base-dt
    varprice-without-abs-base-dt
    varprice-slt-base-dt
    varprice-no-slt-base-dt
    varprice-vat-base-dt
    varprice-no-vat-slt-base-dt
    no-error
  }
  if error-status :error then do:
    return error substitute ("Ошибка при пересчете линии документа: &1", return-value).
  end.

  assign sum-vat = varprice-vat-dt * tt-fr-doc-line.cli-qnty.
  display sum-vat with frame {&frame-name}.

  if vat-sumvalue = "yes" then do:
    if v-round-vat-sum and sum-vat <> 0 then do: /*принудительный перерасчет % НДС от округленного НДС*/
      assign
        sum-vat = round(varprice-vat-dt * tt-fr-doc-line.cli-qnty, 2 )
      .
      run calc-vat-pc in this-procedure.
    end.
  end.
  /* показ новой продажной цены */
  run new-price-s in this-procedure .
  run new-price-prod in this-procedure .

end procedure.


procedure save-action:
  define input parameter partype-check as character no-undo.

  zap:
  do transaction
  on error  undo zap, return error return-value
  on stop   undo zap, return error return-value
  on endkey undo zap, return error return-value
  :
    define variable v-ok as logical   no-undo .

    if parline-mode <> {&lookup} then do:
      assign
        frame {&frame-name}
        tt-fr-doc-line.price-prod
        tt-fr-doc-line.price-prod-vat
        tt-fr-doc-line.new-price-sale
      .

      assign
        v-ok = false
      .
      block_save:
      do while v-ok <> true
      on error  undo zap, return error return-value
      on stop   undo zap, return error return-value
      on endkey undo zap, return error return-value
      :

        run save-price-prod in this-procedure
          no-error.
        if error-status :error then do:
          undo zap, return error return-value.
        end.

        run check-frame in this-procedure
          ( input partype-check
          ) no-error.
        if error-status :error then do:
          undo zap, return error return-value.
        end.

        run save-place-rsrv in this-procedure
          ( input partype-check
           ,output v-ok
          ) no-error.
        if error-status :error then do:
          undo zap, return error return-value.
        end.
        if v-ok = true then do:
          run local-cor-line in this-procedure
            no-error.
          if error-status :error then do:
            undo zap, return error return-value.
          end.

          run save-country-code in this-procedure
            no-error.
          if error-status :error then do:
            undo zap, return error return-value.
          end.


          run init-tt-doc-pl in this-procedure
            no-error.
          if error-status :error then do:
            undo zap, return error return-value.
          end.
        end.
      end.
    end. /* parline-mode <> {&lookup} */
  end. /* zap: transaction */
  if parline-mode <> {&lookup} then do: assign parline-mode = {&update}. end.
  find t-doc where recid( t-doc ) = pardoc-rec.
/*  if v-change THEN DO:
     run chg-attr in THIS-PROCEDURE .
  END.*/
end procedure. /* save-action */

procedure local-cor-line:
  define variable v-part-code as character no-undo.
  define buffer lc_doc-line for ub.doc-line.
  /* Для алкогольной продукции - если у строки накладной еще нет партий,
     то сгенерируем для нее код */
  if tt-fr-doc-line.alc-prod and
    (tt-fr-doc-line.alc-part-code = ?)
  then do:
    run alc-lib_get-new-part-code in this-procedure
      (input  t-doc.obj-type
      ,input  t-doc.obj-code
      ,input  tt-fr-doc-line.prod-type
      ,input  tt-fr-doc-line.prod-code
      ,input  tt-fr-doc-line.artic
      ,input  t-doc.doc-code
      ,output v-part-code
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры alc-lib_get-new-part-code" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error.
    end.
    assign
      tt-fr-doc-line.alc-part-code = v-part-code
    .
  end.

  if v-edit-fact-wayb
  then do:
    fq = tt-fr-doc-line.fact-qnty:screen-value in frame {&frame-name}.
  end.

  def var ndq as character no-undo.
  
  if v-edit-fact-wayb and not t-doc.flag_
  then do:
    t-doc.flag_ = true.
    ndq = tt-fr-doc-line.doc-qnty:screen-value in frame {&frame-name}.
    tt-fr-doc-line.fact-qnty:screen-value in frame {&frame-name} = string (dec (cq) * tt-fr-doc-line.cli-base-rate).
    tt-fr-doc-line.cli-qnty:screen-value in frame {&frame-name} = cq.
    assign
      tt-fr-doc-line.fact-qnty
      tt-fr-doc-line.cli-qnty
      .
    run calc-all in this-procedure
      ( input varcli-qnty-calc
      ) no-error .
    if error-status :error then do:
      return no-apply.
    end.
    { str/cor-line.i "realy" }
    if error-status :error then do:
       message "Ошибка при вызове процедуры сохранения линии."
               return-value
               view-as alert-box.
       t-doc.flag_ = false.
       return error.
    end.
    t-doc.flag_ = false.
    tt-fr-doc-line.cli-qnty:screen-value in frame {&frame-name} = ndq.
    assign
      tt-fr-doc-line.cli-qnty.
    run calc-all in this-procedure
      ( input varcli-qnty-calc
      ) no-error .
    if error-status :error then do:
      return no-apply.
    end.
  end.

  
  { str/cor-line.i "realy" }
  if error-status :error then do:
     message "Ошибка при вызове процедуры сохранения линии."
             return-value
             view-as alert-box.
     return error.
  end.
  
  
  if v-edit-fact-wayb and not t-doc.flag_
  then do:
    tt-fr-doc-line.fact-qnty:screen-value in frame {&frame-name} = fq.
    assign
      tt-fr-doc-line.fact-qnty.
    t-doc.flag_ = true.
    { str/cor-line.i "realy" }
    if error-status :error then do:
      t-doc.flag_ = false.
       message "Ошибка при вызове процедуры сохранения линии."
               return-value
               view-as alert-box.
       return error.
    end.
    t-doc.flag_ = false.
  end.

  find first lc_doc-line where lc_doc-line.doc-code  = t-doc.doc-code           and
                               lc_doc-line.artic     = tt-fr-doc-line.artic     and
                               lc_doc-line.prod-type = tt-fr-doc-line.prod-type and
                               lc_doc-line.prod-code = tt-fr-doc-line.prod-code no-error.
  if available lc_doc-line then do:
    assign line-rec = recid( lc_doc-line ).
  end.
  if line-rec = ? then return . /* Линии еще нет */

  /* Т.к. изменилась линия следует подкорректировать ее по признакам */
  run str/chk-prt.p ( input line-rec, input (if last-event :widget-enter = b-save :handle in frame {&frame-name} then yes else no), buffer t-doc ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка про проверке разнесения строки по признакам" skip
      return-value skip
      view-as alert-box error .
      return error.
  end.
end procedure. /* local-cor-line */

procedure calc-vat-pc:
  if tt-fr-doc-line.tot-cli:sensitive in frame {&frame-name} then do:
    if  integer(tt-fr-doc-line.tot-cli:screen-value) <> 0
    then do : 
        assign tt-fr-doc-line.vat-pc = (sum-vat / (tt-fr-doc-line.tot-cli
                 * ( 1 - (if t-doc.slt-type = {&inc-slt} then (tt-fr-doc-line.slt-pc / (100 + tt-fr-doc-line.slt-pc)) else 0))
                - (if t-doc.vat-type =  {&inc-vat} then sum-vat else 0))) * 100.
        if tt-fr-doc-line.vat-pc = ? then
        assign 
          tt-fr-doc-line.vat-pc = v-clcdoc-vat-pc
          sum-vat = 0
        .
    end.    
  end.
  else do:
    assign tt-fr-doc-line.vat-pc = (sum-vat / (tt-fr-doc-line.cli-qnty * tt-fr-doc-line.price-cli
             * ( 1 - (if t-doc.slt-type = {&inc-slt} then (tt-fr-doc-line.slt-pc / (100 + tt-fr-doc-line.slt-pc)) else 0))
            - (if t-doc.vat-type =  {&inc-vat} then sum-vat else 0))) * 100.
    if tt-fr-doc-line.vat-pc = ? then tt-fr-doc-line.vat-pc = v-clcdoc-vat-pc.
  end.
  display tt-fr-doc-line.vat-pc sum-vat with frame {&frame-name}.
end procedure.

procedure cr-tt-fr-doc-line private:
  /*!!!Создание temporary-table!!!*/
  define input parameter parmode        as character no-undo.
  define input parameter parrecdoc-line as recid     no-undo.
  define variable v-alcohol-prod        as logical   no-undo.
  define variable v-alcohol-value       as character no-undo.
  define variable v-alcohol-type        as character no-undo.
  define variable v-new-price-sale      as decimal   no-undo.
  define variable v-price-prod          as decimal   no-undo.
  define variable v-price-prod-vat      as decimal   no-undo.
  define buffer bf-doc-line   for ub.doc-line.
  define buffer prev_doc-line for ub.doc-line.

  if parmode <> "create" then do:
    find first bf-doc-line no-lock
      where recid(bf-doc-line) = parrecdoc-line
    .
  end.
  if parline-mode <> {&lookup} then do:
     { str/goods-tr.i
       recid(t-doc)
       recid(buf_goods)
       no-error
     }
     if error-status :error then do:
       message
         error-status :get-message( 1 ) skip
         return-value
         view-as alert-box.
       return error.
     end.
  end.
  find ub.units where ub.units.unit-name  = buf_goods.unit-base no-lock.
  create tt-fr-doc-line.
  { str/st-sltpc.i  recid(buf_goods)  recid(t-doc)  bf_sysconf.cash-pay  v-clcdoc-slt-pc }
  { gbl/hostcode.i t-doc.obj-type t-doc.obj-code v-clcdoc-host-code }
  { gbl/pftxvalg.i buf_goods.gds-code {&vat-tax-code} ? v-clcdoc-host-code t-doc.obj-type t-doc.obj-code v-clcdoc-vat-pc no-error }

  assign
    tt-fr-doc-line.doc-code      = t-doc.doc-code
    tt-fr-doc-line.obj-type      = t-doc.obj-type
    tt-fr-doc-line.obj-code      = t-doc.obj-code
    tt-fr-doc-line.artic         = buf_goods.artic
    tt-fr-doc-line.prod-type     = buf_goods.prod-type
    tt-fr-doc-line.prod-code     = buf_goods.prod-code
    tt-fr-doc-line.gds-name      = buf_goods.gds-name
    v-goods-ms-base              = buf_goods.ms-base
    tt-fr-doc-line.unit-base     = buf_goods.unit-base
    tt-fr-doc-line.unit-type     = ub.units.type
    tt-fr-doc-line.prt-root      = buf_goods.prt-root
    tt-fr-doc-line.type-inp-sum  = (if parinplnsum = yes then yes else no)
  .

  if parmode = "create" then do:
    assign
  /* 22/X-2018 
      tt-fr-doc-line.unit-cli      = if v-specif-unit-list > "":U then v-specif-unit-list else  buf_goods.unit-cli
      tt-fr-doc-line.cli-base-rate = buf_goods.cli-base-rate
  */
      tt-fr-doc-line.unit-cli      = (if v-specif-unit-list > "" then v-specif-unit-list     else buf_goods.unit-cli)
      tt-fr-doc-line.cli-base-rate = (if v-specif-unit-list > "" then (v-specif-cli-base-rate) else buf_goods.cli-base-rate)
      tt-fr-doc-line.doc-density   = ?
      tt-fr-doc-line.fact-density  = ?
      tt-fr-doc-line.temperature   = ?
    .
    if is-petrolium = true
      and is-pieces = false
    then do:
      assign
        tt-fr-doc-line.cli-base-rate = 1 / tt-fr-doc-line.doc-density
      .
      if ptrlprop-olddens = true
        and vardensity-input = true
      then do: /* Плотность и температура из прошлого прихода на объект */
        find last prev_doc-line
          where prev_doc-line.obj-type     = t-doc.obj-type
            and prev_doc-line.obj-code     = t-doc.obj-code
            and prev_doc-line.prod-type    = buf_goods.prod-type
            and prev_doc-line.prod-code    = buf_goods.prod-code
            and prev_doc-line.artic        = buf_goods.artic
            and prev_doc-line.ext-doc-type = t-doc.ext-doc-type
            and prev_doc-line.status_      = {&fact}
          no-lock
        use-index dt-fo no-error.
        if available prev_doc-line then do:
          assign
            tt-fr-doc-line.doc-density   = prev_doc-line.fact-density
            tt-fr-doc-line.cli-base-rate = 1 / tt-fr-doc-line.doc-density
            tt-fr-doc-line.fact-density  = tt-fr-doc-line.doc-density
            tt-fr-doc-line.temperature   = prev_doc-line.temperature
          .
          display
            tt-fr-doc-line.doc-density
            tt-fr-doc-line.temperature
            with frame {&frame-name}.
        end.
      end.
    end.
  end.
  else do:
    assign
      tt-fr-doc-line.cli-base-rate = bf-doc-line.cli-base-rate
      tt-fr-doc-line.unit-cli      = bf-doc-line.unit-cli
    .
  end.
  assign
    tt-fr-doc-line.vat-pc = (if t-doc.vat-type = {&without-vat} then 0 else (if parmode = "create" then v-clcdoc-vat-pc else bf-doc-line.vat-pc))
    tt-fr-doc-line.slt-pc = (if t-doc.slt-type = {&without-slt} then 0 else (if parmode = "create" then v-clcdoc-slt-pc else bf-doc-line.slt-pc))
  .
 /* какая должна быть продажная цена */ .
   if parmode = "create" then do:
     { str/prslnew.i
      "run"
      pr-genmrg
      pr-naklvalue
      t-doc.doc-code
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      tt-fr-doc-line.price-rubl
      tt-fr-doc-line.price-base
      tt-fr-doc-line.price-rubl
      tt-fr-doc-line.price-base
      tt-fr-doc-line.new-price-sale
      no-error }
      if error-status :error then
      message
        error-status :get-message(1) skip
        return-value skip
        "Нельзя рассчитать новую цену продажи(2)"
        view-as alert-box error
      .

   end.
   else do:
    assign
      tt-fr-doc-line.new-price-sale = bf-doc-line.new-price-sale
    .
   end.
define variable v-type as character no-undo .
  run lineattr-value in this-procedure (
      input   t-doc.doc-code  ,
      input   buf_goods.gds-code  ,
      input   {&lineattr-price-prod} ,
      output  tt-fr-doc-line.price-prod ,
      output  v-type       )
      no-error .
  run lineattr-value in this-procedure (
      input   t-doc.doc-code  ,
      input   buf_goods.gds-code  ,
      input   {&lineattr-price-prod-vat} ,
      output  tt-fr-doc-line.price-prod-vat ,
      output  v-type       )
      no-error .


  v-alcohol-prod = no.
  { gbl/conf-rd.i
    "'alcohol':u"
    "0"
    "''"
    0
    "''"
    "''"
    "''"
    no
    v-alcohol-value
    v-alcohol-type
    no-error
  }
  if lookup(v-alcohol-value, 'true,yes':u) > 0 then do:
    /* Является ли товар алкогольной продукцией */
    { gbl/gdscdat.i
      buf_goods.gds-code
      "'alcohol-prod=request':u"
      v-alcohol-prod
    }
  end.

  assign
    tt-fr-doc-line.alc-prod = v-alcohol-prod
    /* Во фрейме покажем первую букву слова "Алкоголь" */
    varalc-prod             = string (v-alcohol-prod,
                                      substring("Алкоголь", 1, 1) + "/")
  .
  release buf_goods.
  find first buf_goods no-lock
    where recid(buf_goods) = pargds-rec
  .
  release ub.units.
  find ub.clients where ub.clients.obj-type = tt-fr-doc-line.prod-type
                    and ub.clients.obj-code = tt-fr-doc-line.prod-code no-lock.
  assign tt-fr-doc-line.obj-name = ub.clients.obj-name.
  release ub.clients.

  find first  ub.ext-artic where  ub.ext-artic.cli-type   = t-doc.cli-type
                        and  ub.ext-artic.cli-code   = t-doc.cli-code
                        and  ub.ext-artic.gds-code   = buf_goods.gds-code
                        and  ub.ext-artic.status_    <> {&deleted-status}
                        no-lock no-error.

  assign tt-fr-doc-line.cli-art = (if available  ub.ext-artic then  ub.ext-artic.ext-artic else ?).
  if available  ub.ext-artic then release  ub.ext-artic.
  find first ub.currency where ub.currency.curr-code = t-doc.exch-code no-lock.
  assign tt-fr-doc-line.curr-abbr = ub.currency.curr-abbr.
  release ub.currency.
  if parmode <> "create" then release bf-doc-line.
  if parmode = "create" then do:
    assign
      tt-fr-doc-line.type-inp-vat = yes
    .
  end.
  else do:
    find first type-inp-vat-attr no-lock
      where type-inp-vat-attr.doc-code   = t-doc.doc-code
        and type-inp-vat-attr.gds-code   = buf_goods.gds-code
        and type-inp-vat-attr.attr-code  = "type-inp-vat"
      no-error.
    if available type-inp-vat-attr then do:
      assign
        tt-fr-doc-line.type-inp-vat = (if type-inp-vat-attr.attr-value = "yes" then yes else no)
      .
    end.
    else do:
      assign
        tt-fr-doc-line.type-inp-vat = yes
      .
    end.
  end.



  display
    tt-fr-doc-line.artic
    tt-fr-doc-line.prod-type
    tt-fr-doc-line.prod-code
    tt-fr-doc-line.gds-name
    v-goods-ms-base
    tt-fr-doc-line.obj-name
    tt-fr-doc-line.unit-base
    tt-fr-doc-line.unit-cli
    tt-fr-doc-line.cli-art
    tt-fr-doc-line.curr-abbr
    tt-fr-doc-line.unit-cli
    tt-fr-doc-line.cli-base-rate
    tt-fr-doc-line.vat-pc
    tt-fr-doc-line.slt-pc
    varalc-prod
    with frame {&frame-name}.
 if v-cntxp-inout-price = true
   and v-insalepr = false
   and vat-sumvalue = "yes"
 then do:
   display
     tt-fr-doc-line.type-inp-vat
     with frame {&frame-name}.
 end.
end procedure.


procedure proc-quit:
  define buffer bf_doc-pl for ub.doc-pl.
  define buffer tmp_doc-line-attr for ub.doc-line-attr .

  do transaction
  on error undo, return error
  :
    /* В серийном товаре существует вариант выхода с 0 кол-вом */
    find first ub.doc-line
      where recid( ub.doc-line ) = line-rec
      no-error .
    if available ub.doc-line
      and ( ub.doc-line.cli-qnty = 0
            or ub.doc-line.cli-qnty = ?
          )
    then do:
      /* Пересчитаем накладную исходя из того, что удаляем строку(на случай если в шапке будут
          параметры не зависящие от cli-qnty */
      run delete-doc-line in this-procedure no-error .
      if error-status :error
      then do:
        undo, return error .
      end.
      message
        "Строка имеет нулевое кол-во по ТТН и удаляется!!!"
        view-as alert-box information .
      assign
        pardoc-rec = recid( t-doc )
      .
      delete ub.doc-line .
      find first t-doc where
          recid( t-doc ) = pardoc-rec .
    end.

    if parline-mode = "ЦИКЛ":U
      or parline-mode = {&add-def}
    then do:
      find first t-doc
        where recid( t-doc ) = pardoc-rec
      .

      for each tt-doc-pl
      :
        for each bf_doc-pl
          where bf_doc-pl.obj-type = t-doc.obj-type
            and bf_doc-pl.obj-code = t-doc.obj-code
            and bf_doc-pl.out-code = t-doc.doc-code
            and bf_doc-pl.gds-code = buf_goods.gds-code
        :
          delete bf_doc-pl.
        end. /* for each bf_doc-pl */
        delete tt-doc-pl.
      end.
    end.
    
    if valid-object(infoSectionsTotal)
    and infoSectionsTotal:PlChanged
    then do :
      for each tmp_doc-line-attr exclusive-lock where tmp_doc-line-attr.doc-code = t-doc.doc-code
                                                  and tmp_doc-line-attr.gds-code = buf_goods.gds-code
                                                  and tmp_doc-line-attr.attr-code begins "list-tank" :
        delete tmp_doc-line-attr .
      end .
      for each tt-old-list-tank :
        create tmp_doc-line-attr .
        buffer-copy tt-old-list-tank to tmp_doc-line-attr .
      end .
      empty temp-table tt-old-list-tank .
    end .
    
  end. /* transaction */

end procedure. /* proc-quit */

procedure calc-all :
  define input parameter parmode-on as character no-undo .

  define variable varbase-rate-ca                like ub.trn-doc.base-rate    no-undo .
  define variable varbase-scale-ca               like ub.trn-doc.base-scale   no-undo .
  define variable varexch-rate-ca                like ub.trn-doc.exch-rate    no-undo .
  define variable varexch-scale-ca               like ub.trn-doc.exch-scale   no-undo .
  define variable varvat-type-ca                 like ub.parts.vat-type       no-undo .
  define variable varslt-type-ca                 like ub.parts.slt-type       no-undo .
  define variable varartic-ca                    like ub.parts.artic          no-undo .
  define variable varprod-type-ca                like ub.parts.prod-type      no-undo .
  define variable varprod-code-ca                like ub.parts.prod-code      no-undo .
  define variable varpr-cli-ca                   like ub.parts.price-cli      no-undo .
  define variable varcli-base-rate-ca            like ub.parts.cli-base-rate  no-undo .
  define variable varpr-rubl-ca                  like ub.parts.price-rubl     no-undo .
  define variable varvat-pc-ca                   like ub.parts.slt-pc         no-undo .
  define variable varslt-pc-ca                   like ub.parts.slt-pc         no-undo .
  define variable varroad-tax-ca                 like ub.parts.road-tax-rubl  no-undo .
  define variable vartransport-rubl-ca           like ub.parts.transport-rubl no-undo .
  define variable varother-rubl-ca               like ub.parts.other-rubl     no-undo .
  define variable varprice-cli-ca                like ub.doc-line.price-rubl  no-undo .
  define variable varprice-cli-unit-base-ca      like ub.doc-line.price-rubl  no-undo .
  define variable varprice-road-tax-ca           like ub.doc-line.price-rubl  no-undo .
  define variable varprice-other-exp-ca          like ub.doc-line.price-rubl  no-undo .
  define variable varprice-transport-exp-ca      like ub.doc-line.price-rubl  no-undo .
  define variable varprice-without-abs-ca        like ub.doc-line.price-rubl  no-undo .
  define variable varprice-slt-ca                like ub.doc-line.price-rubl  no-undo .
  define variable varprice-no-slt-ca             like ub.doc-line.price-rubl  no-undo .
  define variable varprice-vat-ca                like ub.doc-line.price-rubl  no-undo .
  define variable varprice-no-vat-slt-ca         like ub.doc-line.price-rubl  no-undo .
  define variable varprice-rubl-ca               like ub.doc-line.price-rubl  no-undo .
  define variable varprice-road-tax-rubl-ca      like ub.doc-line.price-rubl  no-undo .
  define variable varprice-other-exp-rubl-ca     like ub.doc-line.price-rubl  no-undo .
  define variable varprice-transport-exp-rubl-ca like ub.doc-line.price-rubl  no-undo .
  define variable varprice-without-abs-rubl-ca   like ub.doc-line.price-rubl  no-undo .
  define variable varprice-slt-rubl-ca           like ub.doc-line.price-rubl  no-undo .
  define variable varprice-no-slt-rubl-ca        like ub.doc-line.price-rubl  no-undo .
  define variable varprice-vat-rubl-ca           like ub.doc-line.price-rubl  no-undo .
  define variable varprice-no-vat-slt-rubl-ca    like ub.doc-line.price-rubl  no-undo .
  define variable varprice-base-ca               like ub.doc-line.price-base  no-undo .
  define variable varprice-road-tax-base-ca      like ub.doc-line.price-base  no-undo .
  define variable varprice-other-exp-base-ca     like ub.doc-line.price-base  no-undo .
  define variable varprice-transport-exp-base-ca like ub.doc-line.price-base  no-undo .
  define variable varprice-without-abs-base-ca   like ub.doc-line.price-base  no-undo .
  define variable varprice-slt-base-ca           like ub.doc-line.price-base  no-undo .
  define variable varprice-no-slt-base-ca        like ub.doc-line.price-base  no-undo .
  define variable varprice-vat-base-ca           like ub.doc-line.price-base  no-undo .
  define variable varprice-no-vat-slt-base-ca    like ub.doc-line.price-base  no-undo .

  define variable varcli-base-rate like ub.doc-line.cli-base-rate no-undo .
  define variable vardensity       like ub.doc-line.doc-density   no-undo .
  define variable varcli-qnty      like ub.doc-line.cli-qnty      no-undo .
  define variable vardoc-qnty      like ub.doc-line.doc-qnty      no-undo .
  define variable varroad-tax      like ub.doc-line.road-tax      no-undo .
  define variable varmode-on       as   character                 no-undo .
  define variable vari             as   integer                   no-undo .

  do vari = 1 to num-entries( parmode-on ) :
    assign
      varmode-on = entry( vari, parmode-on )
    .
    if varmode-on <> "doc-qnty":u      and
       varmode-on <> "acc-price":u     and
       varmode-on <> "density":u       and
       varmode-on <> "cli-base-rate":u and
       varmode-on <> "cli-price":u     and
       varmode-on <> "road-tax":u      and
       varmode-on <> "cli-qnty":u
    then do:
      message "Неверный параметр пересчета для процедуры calc-all: "
              parmode-on " ."
      view-as alert-box error .
      return error .
    end.
  end.
  if lookup( "cli-qnty", parmode-on ) > 0
  then do:
    { str/clccliqt.i
        varext-gds-type
        tt-fr-doc-line.doc-qnty
        tt-fr-doc-line.cli-base-rate
        tt-fr-doc-line.doc-density
        varround
        varcli-qnty
        no-error
    }
    if error-status :error
    then do:
      message "Ошибка при пересчете клиентского количества." skip( 0 )
              return-value                                   skip( 0 )
              error-status :get-message( 1 )                 skip( 0 )
              error-status :get-message( 2 )
      view-as alert-box error .
      return error .
    end.
    assign
      tt-fr-doc-line.cli-qnty = varcli-qnty
    .
    display tt-fr-doc-line.cli-qnty with frame {&frame-name} .
  end.
  if lookup( "density", parmode-on ) > 0
  then do:
    if tt-fr-doc-line.cli-qnty <> ?
      and tt-fr-doc-line.doc-qnty <> ?
    then do:
      { str/clcdens.i
          varext-gds-type
          tt-fr-doc-line.cli-qnty
          tt-fr-doc-line.doc-qnty
          vardensity
          no-error
      }
      if error-status :error
      then do:
        message "Ошибка при пересчете плотности." skip( 0 )
                return-value                                   skip( 0 )
                error-status :get-message( 1 )                 skip( 0 )
                error-status :get-message( 2 )
        view-as alert-box error .
        return error .
      end.
      assign
        tt-fr-doc-line.doc-density  = vardensity
        tt-fr-doc-line.fact-density = tt-fr-doc-line.doc-density
      .
      display tt-fr-doc-line.doc-density with frame {&frame-name} .
    end.
  end.
  if lookup( "doc-qnty", parmode-on ) > 0
  then do:
    { str/clcdocqt.i
        varext-gds-type
        tt-fr-doc-line.cli-qnty
        tt-fr-doc-line.cli-base-rate
        tt-fr-doc-line.doc-density
        vardoc-qnty
        no-error
    }
    if error-status :error
    then do:
      message "Ошибка при пересчете количества в базовых единицах." skip( 0 )
              return-value                                          skip( 0 )
              error-status :get-message( 1 )                        skip( 0 )
              error-status :get-message( 2 )
      view-as alert-box .
      return error .
    end.
    assign
      tt-fr-doc-line.doc-qnty = vardoc-qnty
    .
    display tt-fr-doc-line.doc-qnty with frame {&frame-name} .
  end.
  if lookup( "cli-base-rate", parmode-on ) > 0
  then do:
    if ( ( varext-gds-type = {&gds-lptrl}
           or varext-gds-type = {&gds-kgptrl}
         )
        and tt-fr-doc-line.doc-density <> ?
       )
      or ( varext-gds-type <> {&gds-lptrl}
           and varext-gds-type <> {&gds-kgptrl}
         )
    then do:
      { str/clcclirt.i
          varext-gds-type
          tt-fr-doc-line.cli-qnty
          tt-fr-doc-line.doc-qnty
          tt-fr-doc-line.doc-density
          varround
          varcli-base-rate
          no-error
      }
      if error-status :error
      then do:
        message "Ошибка при расчете коэффициента поставщика." skip( 0 )
                return-value                                  skip( 0 )
                error-status :get-message( 1 )                skip( 0 )
                error-status :get-message( 2 )
        view-as alert-box error .
        return error .
      end.
      assign
        tt-fr-doc-line.cli-base-rate = varcli-base-rate
      .
      if tt-fr-doc-line.doc-density = ?
      then
      display tt-fr-doc-line.cli-base-rate with frame {&frame-name} .
    end.
  end.
  /* Дорналог надо пересчитывать перед общим пересчетом цены */
  if lookup( "road-tax", parmode-on ) > 0
  then do:
    { str/clcrdtax.i
        buf_goods.gds-code
        varext-gds-type
        tt-fr-doc-line.cli-base-rate
        tt-fr-doc-line.doc-qnty
        tt-fr-doc-line.doc-density
        road-tax-cli
        t-doc.base-rate
        t-doc.base-scale
        t-doc.exch-rate
        t-doc.exch-scale
        varroad-tax
        no-error
    }
    if error-status :error
    then do:
      message "Ошибка при пересчете дорожного налога" skip( 0 )
              return-value                            skip( 0 )
              error-status :get-message( 1 )          skip( 0 )
              error-status :get-message( 2 )
      view-as alert-box error .
      return error .
    end.
    assign
      tt-fr-doc-line.road-tax = varroad-tax
    .
    display tt-fr-doc-line.road-tax with frame {&frame-name} .
  end.
  if ( lookup( "cli-price", parmode-on ) > 0
      or lookup( "acc-price", parmode-on ) > 0
     )
     and tt-fr-doc-line.cli-base-rate <> ?
  then do:
    if v-insalepr = true then do:
      run calc-price-sale in this-procedure no-error .
      if error-status :error
      then do:
        message "Ошибка при установке продажной цены." skip( 0 )
                return-value
        view-as alert-box .
        return error .
      end.
    end.
    else do:
      if varbase-price-input = true then do:
        assign
          tt-fr-doc-line.price-cli = tt-fr-doc-line.price-rubl / t-doc.exch-rate * t-doc.exch-scale * tt-fr-doc-line.cli-base-rate
        .
      end.
    end.
    { str/in-vat.i
        t-doc.doc-code
        t-doc.base-rate
        t-doc.base-scale
        t-doc.exch-rate
        t-doc.exch-scale
        t-doc.vat-type
        t-doc.slt-type
        tt-fr-doc-line.artic
        tt-fr-doc-line.prod-type
        tt-fr-doc-line.prod-code
        tt-fr-doc-line.price-cli
        tt-fr-doc-line.cli-base-rate
        tt-fr-doc-line.price-rubl
        tt-fr-doc-line.vat-pc
        tt-fr-doc-line.slt-pc
        tt-fr-doc-line.road-tax
        tt-fr-doc-line.transport-rubl
        tt-fr-doc-line.other-rubl
        varprice-cli-ca
        varprice-cli-unit-base-ca
        varprice-road-tax-ca
        varprice-other-exp-ca
        varprice-transport-exp-ca
        varprice-without-abs-ca
        varprice-slt-ca
        varprice-no-slt-ca
        varprice-vat-ca
        varprice-no-vat-slt-ca
        varprice-rubl-ca
        varprice-road-tax-rubl-ca
        varprice-other-exp-rubl-ca
        varprice-transport-exp-rubl-ca
        varprice-without-abs-rubl-ca
        varprice-slt-rubl-ca
        varprice-no-slt-rubl-ca
        varprice-vat-rubl-ca
        varprice-no-vat-slt-rubl-ca
        varprice-base-ca
        varprice-road-tax-base-ca
        varprice-other-exp-base-ca
        varprice-transport-exp-base-ca
        varprice-without-abs-base-ca
        varprice-slt-base-ca
        varprice-no-slt-base-ca
        varprice-vat-base-ca
        varprice-no-vat-slt-base-ca
        no-error
    }
    if error-status :error
    then do:
      message "Ошибка при расчете цен."      skip( 0 )
              return-value                   skip( 0 )
              error-status :get-message( 1 ) skip( 0 )
              error-status :get-message( 2 )
      view-as alert-box error .
      return error .
    end.
    assign
      tt-fr-doc-line.price-cli  = varprice-cli-ca
      tt-fr-doc-line.price-base = varprice-base-ca
      tt-fr-doc-line.price-rubl = varprice-rubl-ca
    .
    display tt-fr-doc-line.price-cli
            tt-fr-doc-line.price-base
            tt-fr-doc-line.price-rubl
    with frame {&frame-name} .
  end.

  if parmode-on = vardensity-calc then do:
    for each tt-doc-pl
    on error undo, return error return-value
    :
      if tt-fr-doc-line.doc-qnty :sensitive in frame {&frame-name} then do:
        assign
          tt-doc-pl.cli-qnty      = tt-doc-pl.doc-qnty  / tt-fr-doc-line.cli-base-rate
          tt-doc-pl.cli-doc-qnty  = tt-doc-pl.doc-qnty  * tt-fr-doc-line.doc-density
          tt-doc-pl.cli-fact-qnty = tt-doc-pl.fact-qnty * tt-fr-doc-line.fact-density
        .
      end.
      if tt-fr-doc-line.cli-qnty :sensitive in frame {&frame-name} then do:
        assign
          tt-doc-pl.doc-qnty      = tt-doc-pl.cli-doc-qnty  / tt-fr-doc-line.doc-density
          tt-doc-pl.fact-qnty     = tt-doc-pl.cli-fact-qnty / tt-fr-doc-line.fact-density
        .
      end.
      if tt-fr-doc-line.fact-qnty :sensitive in frame {&frame-name} then do:
        assign
          tt-doc-pl.cli-fact-qnty = tt-doc-pl.fact-qnty * tt-fr-doc-line.fact-density
        .
      end.
      if tt-fr-doc-line.fact-qnty-kg :sensitive in frame {&frame-name} then do:
        assign
          tt-doc-pl.fact-qnty     = tt-doc-pl.cli-fact-qnty / tt-fr-doc-line.fact-density
        .
      end.
    end. /* for each tt-doc-pl */
  end. /* if parmode-on = vardensity-calc */

 if  pr-naklvalue = true  and pr-genmrg = {&typeprice_before-margin} and is-petrolium = false  then do:
  if not (( tt-fr-doc-line.price-rubl = 0  or tt-fr-doc-line.price-rubl = ? ) and
        ( parmode-on = "cli-qnty " or parmode-on = "doc-qnty" )) then do:

    run save-action in this-procedure
      ( input "light-super":U
      ) no-error .
    if error-status :error then do:
      return no-apply .
    end.

   { str/prslnew.i
      "run"
      pr-genmrg
      pr-naklvalue
      t-doc.doc-code
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      tt-fr-doc-line.price-rubl
      tt-fr-doc-line.price-base
      varprice-no-vat-slt-rubl-ca
      varprice-no-vat-slt-base-ca
      tt-fr-doc-line.new-price-sale
      no-error }
      if error-status :error then
      message
        error-status :get-message(1) skip
        return-value skip
        "Нельзя рассчитать новую цену продажи(4)"
        view-as alert-box error
      .

   end.
  end.
  run disp-total in this-procedure no-error .
  if error-status :error
  then do:
    return error .
  end.
end procedure. /* calc-all */

procedure proc-units:
// 20/IX-2018 в приходе и в спецификации можно указывать любую ЕИ, для которой на товаре задан коэфф.пересчёта к базовой ЕИ
// 28/IX-2018 в приходе по договору можно указать либо базовую ЕИ, либо ЕИ из спецификации договора
define buffer bf-r-units for ub.units.
define variable v-ret-unit-name  as character no-undo .
define variable v-ret-unit-coeff as decimal no-undo .
  
  run ref/alt-units.w (input parparentproc,
                       input {&select},
                       input buf_goods.gds-code,
                       input v-specif-unit-list, /* ограничение списка выбора */
                      output v-ret-unit-name,
                      output v-ret-unit-coeff) .
  if v-ret-unit-name > "" then do :
    if can-find (first bf-r-units where bf-r-units.unit-name = v-ret-unit-name) then do :
      tt-fr-doc-line.unit-cli      = v-ret-unit-name .
      tt-fr-doc-line.cli-base-rate = v-ret-unit-coeff .      
      display
        tt-fr-doc-line.unit-cli
        tt-fr-doc-line.cli-base-rate
      with frame {&frame-name}.
      /* Здесь мы имеем:
        - единицу измерения, в которой ввели количество, и за единицу которой указана цена;
        - коэффициент пересчёта к базовой единице измерения товара;
        - цену закупки можно сравнить с ценой спецификации, если такая проверка выполняется. 
      */
    end .
  end .
  else return error .
end procedure.

procedure v-c-type-inp-vat:
do on error undo, return error return-value:
assign frame {&frame-name} tt-fr-doc-line.type-inp-vat.
if tt-fr-doc-line.type-inp-vat = yes then do:
   enable  tt-fr-doc-line.vat-pc when t-doc.vat-type <> {&without-vat} with frame {&frame-name}.
   disable sum-vat with frame {&frame-name}.
   apply "leave" to tt-fr-doc-line.vat-pc in frame {&frame-name}.
end.
else do:
   enable sum-vat when t-doc.vat-type <> {&without-vat} with frame {&frame-name}.
   disable tt-fr-doc-line.vat-pc with frame {&frame-name}.
   apply "leave" to sum-vat in frame {&frame-name}.
end.
end.
end procedure.

/* 14/II-2019 - исключена, т.к. выдавала ошибку,
                сравнивая внутри p-chk-vat значение из tt-fr-doc-line вместо значения с экрана
procedure leave-pc:
do on error undo, return error return-value:
  if input frame {&frame-name} tt-fr-doc-line.vat-pc <> tt-fr-doc-line.vat-pc or
     input frame {&frame-name} tt-fr-doc-line.slt-pc <> tt-fr-doc-line.slt-pc then do:
    if vat-sumvalue <> "yes" then do:
      run p-chk-vat  .
    end.
   assign frame {&frame-name} tt-fr-doc-line.vat-pc
          frame {&frame-name} tt-fr-doc-line.slt-pc.
   run calc-all in this-procedure ( input ( if varprice-cli-input = yes then varprice-cli-calc
                                                                        else varbase-price-calc ) ) no-error.
   if error-status :error then return error.
end.

end.
end procedure.
*/
procedure chg-unit:
define variable v-unit-name as character no-undo .
define buffer buf_units    for ub.units .
define buffer buf_contract for ub.contract .
define buffer buf_contract-specif for ub.contract-specif .

  v-unit-name = input frame {&frame-name} tt-fr-doc-line.unit-cli .
  if not can-find (first buf_units where buf_units.unit-name = v-unit-name) then do:
    message
      substitute("Единица измерения поставщика [&1] отсутствует в справочнике единиц измерения", v-unit-name)
      view-as alert-box.
    display tt-fr-doc-line.unit-cli with frame {&frame-name}.
    apply "choose" to r-units.
    return no-apply.
  end.
  // 28/IX-2018 при создании ПН с договором можно указывать только базовую или ед. измерения по договору
  if t-doc.contract-code > 0 then do :
    if (buf_goods.unit-base = v-unit-name) or (v-specif-unit-list  = v-unit-name) then .
    else do :
      message
      substitute("Единицей измерения поставщика [&1] может быть или [&2] - базовая для товара, или [&3] - указанная в договоре",
                 v-unit-name, buf_goods.unit-base, v-specif-unit-list)
      view-as alert-box.
    display tt-fr-doc-line.unit-cli with frame {&frame-name}.
    apply "choose" to r-units.
    return no-apply.
    end .
  end .
    
  assign frame {&frame-name} tt-fr-doc-line.unit-cli.

end procedure.

procedure chs-dog :
do on error undo, return error return-value :
define variable varrid-list as character no-undo.
define variable varrecid    as recid     no-undo.

define buffer bf_contract for ub.contract.

run str/cont-all.w (input parparentproc,
                input t-doc.host-code,
                input "b-sel",
                input "firm-curr" ,
                input t-doc.cli-type,
                input t-doc.cli-code,
                input ?,
                input ?,
                input "current":u,
                input {&income},
                input-output varrid-list ) no-error.
assign
  varrecid = integer(entry(1, varrid-list)).
find first bf_contract where recid(bf_contract) = varrecid no-lock no-error.
if available bf_contract then do:
  if bf_contract.doc-type <> {&income} then do:
    message "Неверный тип контракта." view-as alert-box.
    return error.
  end.
  if bf_contract.cli-type <> t-doc.cli-type or
     bf_contract.cli-code <> t-doc.cli-code then do:
    message "Накладная оформляется на контрагента: " t-doc.cli-type " " t-doc.cli-code " ." skip
            "Договор по контрагенту: " bf_contract.cli-type " " bf_contract.cli-code " ."
    view-as alert-box error.
    return error.
  end.
  assign tt-fr-doc-line.contract-prn-code = bf_contract.contract-prn-code.
  /* display tt-fr-doc-line.contract-prn-code with frame {&frame-name}. */
  assign tt-fr-doc-line.contract-code = bf_contract.contract-code.
end.
end.
end procedure.

procedure calc-price-sale:
  assign parprice-sale = ?.
  run tax-val in this-procedure
    (input tt-fr-doc-line.artic,
    input tt-fr-doc-line.prod-type,
    input tt-fr-doc-line.prod-code,
    input tt-fr-doc-line.unit-base,
    input ?,
    input tt-fr-doc-line.unit-type,
    input ?,
    input no,
    input integer(rdtaxcdvalue),
    input integer(vattaxcdvalue),
    input integer(exctaxcdvalue),
    input no,
    input t-doc.host-code,
    input t-doc.obj-type,
    input t-doc.obj-code,
    input ?,
    input ?,
    output temp-mes,
    input-output parprice-sale) no-error.
  if error-status :error or return-value = "error" then do:
     message "Ошибка при вызове процедуры налогов." view-as alert-box.
     return error.
  end.
  if parprice-sale = ? then do:
     message "Нельзя найти продажную цену товара по объекту. " +
             "Артикул " +  tt-fr-doc-line.artic + " Производитель " +
             tt-fr-doc-line.prod-type + " " + string(tt-fr-doc-line.prod-code) " ."
     view-as alert-box.
     return error.
  end.
  /* Простановка доп. компоненты во фрейм */
  find first tt-tax where tt-tax.tax-code = integer(rdtaxcdvalue) no-error.
  if available tt-tax then do:
     assign  tt-fr-doc-line.road-tax = tt-tax.rate-value.
     display tt-fr-doc-line.road-tax with frame {&frame-name}.
  end.
  find first tt-tax where tt-tax.tax-code = integer(exctaxcdvalue) no-error.
  if available tt-tax then do:
     assign tt-fr-doc-line.excise = tt-tax.rate-value.
     display tt-fr-doc-line.excise with frame {&frame-name}.
  end.
  if varr-b = "rubl":u then do:
    assign
/*      tt-fr-doc-line.price-sale = (parprice-sale -  (if tt-fr-doc-line.road-tax = ? then 0 else tt-fr-doc-line.road-tax))*/
/*                                  * (if t-doc.vat-type = {&no-vat} then 100 / (100 + tt-fr-doc-line.vat-pc) else 1)*/
      tt-fr-doc-line.price-rubl = parprice-sale
      tt-fr-doc-line.price-base = tt-fr-doc-line.price-rubl / t-doc.base-rate * t-doc.base-scale
    .
  end.
  else do:
    assign
/*      tt-fr-doc-line.price-sale = (parprice-sale -  (if tt-fr-doc-line.road-tax = ? then 0 else tt-fr-doc-line.road-tax))*/
/*                                  * (if t-doc.vat-type = {&no-vat} then 100 / (100 + tt-fr-doc-line.vat-pc) else 1)*/
/*                                  * t-doc.base-rate /  t-doc.base-scale*/
      tt-fr-doc-line.price-base = parprice-sale
      tt-fr-doc-line.price-rubl = tt-fr-doc-line.price-base * t-doc.base-rate /  t-doc.base-scale
    .
  end.
  assign
    tt-fr-doc-line.price-cli  = tt-fr-doc-line.price-rubl / t-doc.exch-rate * t-doc.exch-scale * tt-fr-doc-line.cli-base-rate
    tt-fr-doc-line.type-inp-sum = no
  .
  display
    tt-fr-doc-line.price-cli
    tt-fr-doc-line.price-base
    tt-fr-doc-line.price-rubl
    with frame {&frame-name}.
end.

procedure proc-country-code :

  do
  on error undo, return error return-value
  :
define variable varrid-list as character no-undo.
define variable varrecid    as recid     no-undo.

define buffer bf_country for ub.country.

run ref/countris.w  (  input parparentproc
                 , input "b-sel"
                 , input-output varrid-list ) no-error.
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
             error-status :get-message( 1 )
     view-as alert-box.
     return .
     end.
if varrid-list = '' then return no-apply.
assign
  varrecid = integer(entry(1, varrid-list)).
find first bf_country no-lock where recid(bf_country) = varrecid no-error.
if available bf_country then do:
  assign tt-fr-doc-line.country-code  = bf_country.num-code
         tt-fr-doc-line.alpha1        = bf_country.alpha1
         tt-fr-doc-line.short-name    = bf_country.short-name
         .
  display
     tt-fr-doc-line.alpha1
     tt-fr-doc-line.short-name
     with frame {&frame-name}.
end.

  end.

end procedure. /* proc-country-code */

procedure save-country-code :

  do
  on error undo, return error return-value
  :

run lineattr-write in this-procedure (
  input   t-doc.doc-code  ,
  input   buf_goods.gds-code  ,
  input   {&lineattr-country-code} ,
  input   string(tt-fr-doc-line.country-code) )
  no-error .
    if error-status :error then do:
       message vss-workfile vss-revision vss-description skip
               error-status :get-message( 1 )
               return-value
       view-as alert-box error .
       return error.
    end.
end.

end procedure. /* save-country-code */

procedure edit-doc-pl :

  define input  parameter p-edit-doc-pl-mode as character no-undo .

  define variable d_fact-qnty     as decimal   no-undo initial 0.00 .
  define variable d_doc-qnty      as decimal   no-undo initial 0.00 .
  define variable d_cli-fact-qnty as decimal   no-undo initial 0.00 .
  define variable d_cli-doc-qnty  as decimal   no-undo initial 0.00 .

  define variable v-log           as logical   no-undo .
  
  define variable v-tmp-pl-code as integer no-undo .

  if varrvs-place = false then do:
    message
      substitute( "Товар &1 не привязывается к местам хранения.", buf_goods.gds-code )
      view-as alert-box.
    return .
  end.

  if parline-mode = {&lookup} then do:
    assign
      p-edit-doc-pl-mode = {&lookup}
    .
  end.
  else do:
    if t-doc.status_ = {&wayb}
      and t-doc.flag_ = false
    then do:
      if tt-fr-doc-line.cli-base-rate = 0
        or tt-fr-doc-line.cli-base-rate = ?
        or tt-fr-doc-line.doc-density = 0
        or tt-fr-doc-line.doc-density = ?
      then do:
        if tt-fr-doc-line.doc-density :sensitive in frame {&frame-name} then do:
          message
            "Не указана плотность"
            view-as alert-box information.
          apply "entry" to tt-fr-doc-line.doc-density in frame {&frame-name} .
          return error .
        end.
        else do:
          if tt-fr-doc-line.cli-base-rate :sensitive in frame {&frame-name} then do:
            message
              "Не указан коэффициент единиц измерения поставщика."
              view-as alert-box information.
              apply "entry" to tt-fr-doc-line.cli-base-rate in frame {&frame-name} .
            return error .
          end.
        end.
      end.
    end.
  end.
  
  if v-lgas-gds
  then
    for first tt-doc-pl :
      assign v-tmp-pl-code = tt-doc-pl.pl-code no-error .
    end .

  run str/doc-pls.w
    ( input parparentproc
     ,input p-edit-doc-pl-mode
     ,input (if t-doc.status_ = {&wayb} and t-doc.flag_ = false then "doc":U else "fact":U )
     ,input ( if varcli-qnty-input = true then "cli":U else "base":U )
     ,input t-doc.doc-code
     ,input buf_goods.gds-code
     ,input tt-fr-doc-line.unit-cli
     ,input tt-fr-doc-line.cli-base-rate
     ,input tt-fr-doc-line.doc-density
     ,input tt-fr-doc-line.fact-density
     ,input tt-fr-doc-line.cli-qnty
     ,input tt-fr-doc-line.doc-qnty
     ,input tt-fr-doc-line.fact-qnty
     ,input tt-fr-doc-line.doc-qnty  * tt-fr-doc-line.doc-density
     ,input tt-fr-doc-line.fact-qnty * tt-fr-doc-line.fact-density
     ,input ?
     ,input ?
     ,input ?
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при разбиении кол-ва по местам хранения." skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.

  if parline-mode <> {&lookup} then do:

    for each tt-doc-pl no-lock
    on error undo, return error return-value
    :
      assign
        d_fact-qnty     = d_fact-qnty     + tt-doc-pl.fact-qnty
        d_doc-qnty      = d_doc-qnty      + tt-doc-pl.doc-qnty
        d_cli-fact-qnty = d_cli-fact-qnty + tt-doc-pl.cli-fact-qnty
        d_cli-doc-qnty  = d_cli-doc-qnty  + tt-doc-pl.cli-doc-qnty
      .
    end. /* for each next_doc-pl */

    assign
      v-log = true
    .

    if tt-fr-doc-line.doc-qnty <> d_doc-qnty
      or
      ( tt-fr-doc-line.doc-qnty :sensitive in frame {&FRAME-NAME} = true
         and absolute( tt-fr-doc-line.cli-qnty - d_cli-doc-qnty ) > 0.001
      )
      or
      ( tt-fr-doc-line.cli-qnty :sensitive in frame {&FRAME-NAME} = true
        and tt-fr-doc-line.cli-qnty <> d_cli-doc-qnty
      )
    then do:
      message
        substitute( "Документарная сумма по местам хранения: &1 &2 (&3 &4)", d_doc-qnty, buf_goods.unit-base, d_cli-doc-qnty, buf_goods.unit-cli ) skip
        substitute( "Документарное кол-во по строке документа: &1 &2 (&3 &4)", tt-fr-doc-line.doc-qnty, buf_goods.unit-base, tt-fr-doc-line.doc-qnty * tt-fr-doc-line.doc-density, buf_goods.unit-cli ) skip(1)
        substitute( "Будем менять документарное количество по строке на &1 &2 (&3 &4)?", d_doc-qnty, buf_goods.unit-base, d_cli-doc-qnty, buf_goods.unit-cli )
        view-as alert-box question buttons yes-no update v-log.

      if v-log = true then do:
        assign
          tt-fr-doc-line.doc-qnty = d_doc-qnty
          tt-fr-doc-line.cli-qnty = d_cli-doc-qnty
          tt-fr-doc-line.doc-density = tt-fr-doc-line.cli-qnty / tt-fr-doc-line.doc-qnty
        .
        display
          tt-fr-doc-line.doc-qnty
          tt-fr-doc-line.cli-qnty
          tt-fr-doc-line.doc-density
          with frame {&FRAME-NAME} .
      end.
    end.
    
    if varupd-fact-qnty = true
      and not( t-doc.status_ = {&wayb}
               and t-doc.flag_ = false
             )
    then do :
      if absolute( tt-fr-doc-line.fact-qnty - d_fact-qnty ) <= 0.001
      then do :
        tt-fr-doc-line.fact-qnty = d_fact-qnty .
      end .
    end .
    if varupd-fact-qnty = true
      and not( t-doc.status_ = {&wayb}
               and t-doc.flag_ = false
             )
      and ( tt-fr-doc-line.fact-qnty <> d_fact-qnty
            or absolute( tt-fr-doc-line.fact-qnty-kg - d_cli-fact-qnty ) > 0.001
          )
    then do:
      message
        substitute( "Фактическая сумма по местам хранения: &1 &2 (&3 &4)", d_fact-qnty, buf_goods.unit-base, d_cli-fact-qnty, buf_goods.unit-cli ) skip
        substitute( "Фактическое кол-во по строке документа: &1 &2 (&3 &4)", tt-fr-doc-line.fact-qnty, buf_goods.unit-base, tt-fr-doc-line.fact-qnty * tt-fr-doc-line.fact-density, buf_goods.unit-cli ) skip(1)
        substitute( "Будем менять фактическое количество по строке на &1 &2 (&3 &4)?", d_fact-qnty, buf_goods.unit-base, d_cli-fact-qnty, buf_goods.unit-cli )
        view-as alert-box question buttons yes-no update v-log.

      if v-log = true then do:
        assign
          tt-fr-doc-line.fact-qnty    = d_fact-qnty
          tt-fr-doc-line.fact-qnty-kg = d_cli-fact-qnty
          tt-fr-doc-line.fact-density = tt-fr-doc-line.fact-qnty-kg / tt-fr-doc-line.fact-qnty
        .
        display
          tt-fr-doc-line.fact-qnty
          tt-fr-doc-line.fact-qnty-kg
          tt-fr-doc-line.fact-density
          with frame {&FRAME-NAME}
        .
      end.
    end.

    run check-place-rsrv in this-procedure
      no-error .
    if error-status :error then do:
      return error  .
    end.
    
    if v-lgas-gds
    then do :
      for first tt-doc-pl :
        if v-tmp-pl-code <> tt-doc-pl.pl-code
        then do :
          assign
            cb-connect-hoses = "empty"
          .
          display cb-connect-hoses with frame {&FRAME-NAME} .
        end .
        find first bf_place-attr no-lock where bf_place-attr.obj-type  = tt-doc-pl.obj-type 
                                           and bf_place-attr.obj-code  = tt-doc-pl.obj-code 
                                           and bf_place-attr.pl-code   = tt-doc-pl.pl-code
                                           and bf_place-attr.attr-code = "place-gate-valve"
                                           no-error .
        if available bf_place-attr
        and logical(bf_place-attr.attr-value)
        then do :
          enable cb-connect-hoses with frame {&FRAME-NAME} .
        end .
        else do :
          disable cb-connect-hoses with frame {&FRAME-NAME} .
        end .
      end .
    end .

  end. /* if line-mode <> {&lookup} */
end procedure. /* edit-doc-pl */

procedure check-place-rsrv :

  define variable d_fact-qnty     as decimal no-undo initial 0.00 .
  define variable d_doc-qnty      as decimal no-undo initial 0.00 .
  define variable d_cli-qnty      as decimal no-undo initial 0.00 .
  define variable d_cli-fact-qnty as decimal no-undo initial 0.00 .
  define variable d_cli-doc-qnty  as decimal no-undo initial 0.00 .
  define variable d_density       as decimal no-undo              .
  define variable j_pl-code       as integer no-undo              .

  do
  on error undo, return error return-value
  :

    if varrvs-place <> true
      or b-place :sensitive in frame {&frame-name} <> true
    then do:
      return .
    end.

    /*if not( t-doc.status_ = {&wayb}
            and t-doc.flag_ = false
          )
    then do:
      if tt-fr-doc-line.doc-qnty < tt-fr-doc-line.fact-qnty then do:
        message
          substitute( 'Фактическое количество в строке накладной (&1 &2) больше количества по документу (&3 &2).'
                      ,tt-fr-doc-line.fact-qnty
                      ,buf_goods.unit-base
                      ,tt-fr-doc-line.doc-qnty
                    )
          view-as alert-box error .
        undo, return error .
      end.
    end.*/

    assign
      d_fact-qnty     = 0.00
      d_doc-qnty      = 0.00
      d_cli-qnty      = 0.00
      d_cli-fact-qnty = 0.00
      d_cli-doc-qnty  = 0.00
    .
    for each tt-doc-pl no-lock
    on error undo, return error return-value
    :
      assign
        d_cli-qnty      = d_cli-qnty      + tt-doc-pl.cli-qnty
        d_fact-qnty     = d_fact-qnty     + tt-doc-pl.fact-qnty
        d_doc-qnty      = d_doc-qnty      + tt-doc-pl.doc-qnty
        d_cli-fact-qnty = d_cli-fact-qnty + tt-doc-pl.cli-fact-qnty
        d_cli-doc-qnty  = d_cli-doc-qnty  + tt-doc-pl.cli-doc-qnty
      .
    end. /* for each tt-doc-pl */

    if tt-fr-doc-line.doc-qnty <> d_doc-qnty then do:
      message
        substitute( 'Количество по документу в строке накладной: &1 &3'
                    + 'НЕ СОВПАДАЕТ с суммарным количеством по местам хранения: &2.&3'
                    , tt-fr-doc-line.doc-qnty
                    , d_doc-qnty
                    , {&new-line}
                  )
        view-as alert-box error .
      undo, return error .
    end.
    if ( tt-fr-doc-line.cli-qnty :sensitive in frame {&frame-name} = true
         and tt-fr-doc-line.cli-qnty <> d_cli-doc-qnty
       )
       or
       ( tt-fr-doc-line.cli-qnty :sensitive in frame {&frame-name} = false
         and absolute( tt-fr-doc-line.cli-qnty - d_cli-doc-qnty ) > 0.001
       )
    then do:
      message
        substitute( 'Количество по ТТН в ед.пост-ка в строке накладной: &1 &3'
                    + 'НЕ СОВПАДАЕТ с суммарным количеством в ед.пост-ка по местам хранения: &2.&3'
                    + 'Нажмите кнопку "&4" и исправьте количества по местам хранения&3'
                    + 'или исправьте количество по ТТН в строке накладной.'
                    , tt-fr-doc-line.cli-qnty
                    , d_cli-doc-qnty
                    , {&new-line}
                    , replace( b-place :label in frame {&frame-name}, "&", "":U )
                  )
        view-as alert-box error .
      undo, return error .
    end.
    if not( t-doc.status_ = {&wayb}
            and t-doc.flag_ = false
          )
      and tt-fr-doc-line.fact-qnty <> d_fact-qnty
    then do:
      message
        substitute( 'Фактическое количество в строке накладной: &1 &3'
                    + 'НЕ СОВПАДАЕТ &3 с суммарным фактическим количеством по местам хранения: &2.&3'
                    + 'Нажмите кнопку "&4" и исправьте количества по местам хранения&3'
                    + 'или исправьте фактическое количество в строке накладной.'
                    , tt-fr-doc-line.fact-qnty
                    , d_fact-qnty
                    , {&new-line}
                    , replace( b-place :label in frame {&frame-name}, "&", "":U )
                  )
        view-as alert-box error .
      undo, return error .
    end.
    if not( t-doc.status_ = {&wayb}
            and t-doc.flag_ = false
          )
      and absolute( tt-fr-doc-line.fact-qnty-kg - d_cli-fact-qnty ) > 0.001
    then do:
      message
        substitute( 'Фактическое количество в ед.пост-ка в строке накладной: &1 &3'
                    + 'НЕ СОВПАДАЕТ &3 с суммарным фактическим количеством в ед.пост-ка по местам хранения: &2.&3'
                    + 'Нажмите кнопку "&4" и исправьте фактические количества в ед.пост-ка по местам хранения&3'
                    + 'или исправьте фактическое количество в ед.пост-ка в строке накладной.'
                    , tt-fr-doc-line.fact-qnty-kg
                    , d_cli-fact-qnty
                    , {&new-line}
                    , replace( b-place :label in frame {&frame-name}, "&", "":U )
                  )
        view-as alert-box error .
      undo, return error .
    end.

    if buf_goods.unit-base <> buf_goods.unit-cli then do:
      assign
        d_density = d_cli-doc-qnty / d_doc-qnty
      .
      if Valid-Density( d_density, (buf_goods.unit-base = buf_goods.unit-cli)  ) <> true
        and ( tt-fr-doc-line.doc-qnty :sensitive in frame {&frame-name}
              or tt-fr-doc-line.cli-qnty :sensitive in frame {&frame-name}
            )
      then do:
        message
          substitute( 'Заявленная плотность топлива (&1) не соответствует ожидаемому. Кол-во: &2л и &3кг.'
                      , d_density
                      , d_doc-qnty
                      , d_cli-doc-qnty
                    )
          view-as alert-box error .
        undo, return error .
      end.
      if v-gds-ptrl-densities <> "" and v-gds-ptrl-densities <> ? then do:
        if d_density < v-min-dens
        or d_density > v-max-dens
        then do:
            message
              substitute("Заявленная плотность топлива (&1) находится вне заданного диапазона: &2."
              , d_density
              , v-gds-ptrl-densities )
              view-as alert-box error .
            undo, return error .
        end.
      end.

      assign
        d_density = d_cli-fact-qnty / d_fact-qnty
      .
      if Valid-Density( d_density, (buf_goods.unit-base = buf_goods.unit-cli)  ) <> true
        and tt-fr-doc-line.fact-qnty :sensitive in frame {&frame-name}
      then do:
        message
          substitute( 'Фактическая плотность топлива (&1) не соответствует ожидаемому. Кол-во: &2л и &3кг.'
                    , d_density
                    , d_fact-qnty
                    , d_cli-fact-qnty
                    )
          view-as alert-box error .
        undo, return error .
      end.
      if v-gds-ptrl-densities <> "" and v-gds-ptrl-densities <> ? then do:
        if d_density < v-min-dens
        or d_density > v-max-dens
        then do:
            message
              substitute("Фактическая плотность топлива (&1) находится вне заданного диапазона: &2."
              , d_density
              , v-gds-ptrl-densities )
              view-as alert-box error .
            undo, return error .
        end.
      end.
    end.
  end. /* on error */
end procedure. /* check-place-rsrv */

procedure display-b-rvs :
  if lookup(v-ptrl-without-rvs, 'true,yes':u) = 0 and not v-is-lgas-corr then do:
    enable
      b-rvs-bf
      b-rvs-af
      with frame {&frame-name}.
    if infoSectionsTotal:IsKP
    then do :
      
      for each tt-doc-pl,
        first bf_place no-lock where bf_place.pl-code = tt-doc-pl.pl-code
      :
        v-KPrvs-secs = "" .
        v-KPrvs-doc-pl = no .
        disable-rvs = no .
        do ii = 1 to infoSectionsTotal:SectionNum : 
          if infoSectionsTotal:GetInfoSectionProp(ii):ListTank = bf_place.loc1
          then do :
            if infoSectionsTotal:GetInfoSectionProp(ii):IsKP
            then do :
              v-KPrvs-doc-pl = yes .
            end .
            v-KPrvs-secs = v-KPrvs-secs + "," + infoSectionsTotal:GetInfoSectionProp(ii):SectionName .
          end .
        end .
        v-KPrvs-secs = trim(v-KPrvs-secs, ",") .
        if not v-KPrvs-doc-pl
        then do :
          disable-rvs = no .
          leave .
        end .
        if v-KPrvs-doc-pl
        and num-entries(v-KPrvs-secs) >= 1
        then do :
          disable-rvs = yes .
        end .
        
      end .
      if disable-rvs
      then do :
        disable
          b-rvs-bf
          b-rvs-af
        with frame {&frame-name}.
      end .
    end .
  end.
end procedure .

procedure display-measure :

  do
  on error undo, return error return-value
  :

    define buffer bef_rvs-doc  for ub.rvs-doc  .
    define buffer aft_rvs-doc  for ub.rvs-doc  .
    define buffer bef_rvs-line for ub.rvs-line .
    define buffer aft_rvs-line for ub.rvs-line .
    define buffer bef2_rvs-line for ub.rvs-line .
    define buffer aft2_rvs-line for ub.rvs-line .
    define buffer buf_rvs-line-pump for ub.rvs-line-pump .
    define buffer bf2_place    for ub.place .
    define buffer buf_c-place-attr for ub.c-place-attr .
    define buffer buf2_c-place-attr for ub.c-place-attr .
    define buffer buf_pl-gds-pump   for ub.pl-gds-pump .
    define buffer buf_c-pl-gds-pump for ub.c-pl-gds-pump .
    define buffer buf2_c-pl-gds-pump for ub.c-pl-gds-pump .
    
    define variable v-old-qnty as decimal no-undo .
    define variable v-old-cli-qnty as decimal no-undo .
    define variable v-trk-err as logical no-undo .
    define variable jj as integer no-undo .
    define variable v-pl-gds-pump-status_ as character no-undo .
    
    assign
      v-old-qnty = tt-fr-doc-line.state-measure-qnty
      v-old-cli-qnty = tt-fr-doc-line.state-measure-cli-qnty
    .
    
    assign
      tt-fr-doc-line.state-measure-qnty     = 0.00
      tt-fr-doc-line.measure-qnty           = 0.00
      tt-fr-doc-line.state-measure-cli-qnty = 0.00
      tt-fr-doc-line.measure-cli-qnty       = 0.00
      tt-fr-doc-line.trk-cli-qnty           = 0.00
    .
    
    empty temp-table tt-rvs-line-pump-delta .
    
    if infoSectionsTotal:IsKP
    then do :
      block-clc-rvs:
      for each tt-doc-pl
      on error undo, return error return-value
      :
        for each bef_rvs-doc no-lock
          where bef_rvs-doc.out-code  = t-doc.doc-code
            and bef_rvs-doc.rvs-type  = {&rvs-before-doc}
        :
          for each bef_rvs-line no-lock
            where bef_rvs-line.rvs-code = bef_rvs-doc.rvs-code
              and bef_rvs-line.obj-type = bef_rvs-doc.obj-type
              and bef_rvs-line.obj-code = bef_rvs-doc.obj-code
              and bef_rvs-line.pl-code  = tt-doc-pl.pl-code
              and bef_rvs-line.gds-code = tt-doc-pl.gds-code
          :
            assign
              tt-fr-doc-line.state-measure-qnty     = tt-fr-doc-line.state-measure-qnty     - bef_rvs-line.state-measure-qnty
              tt-fr-doc-line.measure-qnty           = tt-fr-doc-line.measure-qnty           - bef_rvs-line.measure-qnty
              tt-fr-doc-line.state-measure-cli-qnty = tt-fr-doc-line.state-measure-cli-qnty - bef_rvs-line.state-measure-cli-qnty
              tt-fr-doc-line.measure-cli-qnty       = tt-fr-doc-line.measure-cli-qnty       - bef_rvs-line.measure-cli-qnty
            .
            
            for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = bef_rvs-line.rvs-code
                                                 and buf_rvs-line-pump.obj-type = bef_rvs-line.obj-type
                                                 and buf_rvs-line-pump.obj-code = bef_rvs-line.obj-code
                                                 and buf_rvs-line-pump.pl-code  = bef_rvs-line.pl-code
                                                 and buf_rvs-line-pump.gds-code = bef_rvs-line.gds-code
            :
              if t-doc.status_ = {&fact}
              then do :
                find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                      and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and (buf_c-pl-gds-pump.corr-date < t-doc.fact-date
                                                        or buf_c-pl-gds-pump.corr-date = t-doc.fact-date and buf_c-pl-gds-pump.corr-time < t-doc.fact-time)
                                                      no-error .
              end .
              else do :
                find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                      and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and (buf_c-pl-gds-pump.corr-date < t-doc.sys-date
                                                        or buf_c-pl-gds-pump.corr-date = t-doc.sys-date and buf_c-pl-gds-pump.corr-time < t-doc.sys-time-int)
                                                      no-error .
              end .
              if available buf_c-pl-gds-pump
              then do :
                find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                        and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                        and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                        and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                        and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                        and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                        no-error .
                if available buf2_c-pl-gds-pump
                then do :
                  v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
                end .
                else do :
                  for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                  :
                    v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                  end .
                end .
              end .
              else do :
                for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                    and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                    and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                    and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                    and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                :
                  v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                end .
              end .
                
              if v-pl-gds-pump-status_ = {&current-status}
              then do :
                create tt-rvs-line-pump-delta .
                buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
                assign
                  tt-rvs-line-pump-delta.rvs-code = "before-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
                  tt-rvs-line-pump-delta.density = (bef_rvs-line.state-density / 2)
                .
                if tt-rvs-line-pump-delta.state-el-cnt = ?
                or tt-rvs-line-pump-delta.state-el-cnt <= 0
                then do :
                  tt-rvs-line-pump-delta.is-err = yes .
                end .
              end .
            end. /* for each bf_rvs-line-pump */
          end .
          
          if t-doc.status_ = {&fact}
          then do :
            find last buf_c-place-attr no-lock where buf_c-place-attr.obj-type  = tt-doc-pl.obj-type
                                                 and buf_c-place-attr.obj-code  = tt-doc-pl.obj-code
                                                 and buf_c-place-attr.pl-code   = tt-doc-pl.pl-code
                                                 and buf_c-place-attr.attr-code = {&place-com-tanks}
                                                 and (buf_c-place-attr.corr-date < t-doc.fact-date
                                                   or buf_c-place-attr.corr-date = t-doc.fact-date and buf_c-place-attr.corr-time < t-doc.fact-time)
                                                 no-error .
          end .
          else do :
            find last buf_c-place-attr no-lock where buf_c-place-attr.obj-type  = tt-doc-pl.obj-type
                                                 and buf_c-place-attr.obj-code  = tt-doc-pl.obj-code
                                                 and buf_c-place-attr.pl-code   = tt-doc-pl.pl-code
                                                 and buf_c-place-attr.attr-code = {&place-com-tanks}
                                                 and (buf_c-place-attr.corr-date < t-doc.sys-date
                                                   or buf_c-place-attr.corr-date = t-doc.sys-date and buf_c-place-attr.corr-time < t-doc.sys-time-int)
                                                 no-error .
          end .
          if available buf_c-place-attr
          then do :
            find first buf2_c-place-attr no-lock where buf2_c-place-attr.obj-type = buf_c-place-attr.obj-type
                                                   and buf2_c-place-attr.obj-code = buf_c-place-attr.obj-code
                                                   and buf2_c-place-attr.pl-code  = buf_c-place-attr.pl-code
                                                   and buf2_c-place-attr.attr-code = buf_c-place-attr.attr-code
                                                   and buf2_c-place-attr.chip-num > buf_c-place-attr.chip-num
                                                   no-error .
            if available buf2_c-place-attr
            then do :
              if buf2_c-place-attr.attr-value > ""
              then do :
                assign
                  v-ok = yes
                  varvalue = buf2_c-place-attr.attr-value
                .
              end .
            end .
            else do :
              run placelib_get-attr  ( input {&place-com-tanks}
                ,input tt-doc-pl.obj-code
                ,input tt-doc-pl.obj-type
                ,input tt-doc-pl.pl-code
                ,output varvalue
                ,output v-ok      ) no-error.
            end .
          end .
          else do :
            run placelib_get-attr  ( input {&place-com-tanks}
              ,input tt-doc-pl.obj-code
              ,input tt-doc-pl.obj-type
              ,input tt-doc-pl.pl-code
              ,output varvalue
              ,output v-ok      ) no-error.
          end .
          
          if v-ok
          and varvalue > ""
          then do :
            do jj = 1 to num-entries(varvalue) :
              find first bf2_place no-lock where bf2_place.obj-type = tt-doc-pl.obj-type
                                             and bf2_place.obj-code = tt-doc-pl.obj-code
                                             and bf2_place.loc1     = entry(jj, varvalue)
/*                                             and bf2_place.status_  = ""*/
                                             no-error .
              if available bf2_place
              then do :
                find first bef2_rvs-line no-lock
                  where bef2_rvs-line.rvs-code = bef_rvs-doc.rvs-code
                    and bef2_rvs-line.obj-type = bef_rvs-doc.obj-type
                    and bef2_rvs-line.obj-code = bef_rvs-doc.obj-code
                    and bef2_rvs-line.pl-code  = bf2_place.pl-code
                    and bef2_rvs-line.gds-code = tt-doc-pl.gds-code
                  no-error .
                if available bef2_rvs-line
                then do:
                  assign
                    tt-fr-doc-line.state-measure-qnty     = tt-fr-doc-line.state-measure-qnty     - bef2_rvs-line.state-measure-qnty
                    tt-fr-doc-line.measure-qnty           = tt-fr-doc-line.measure-qnty           - bef2_rvs-line.measure-qnty
                    tt-fr-doc-line.state-measure-cli-qnty = tt-fr-doc-line.state-measure-cli-qnty - bef2_rvs-line.state-measure-cli-qnty
                    tt-fr-doc-line.measure-cli-qnty       = tt-fr-doc-line.measure-cli-qnty       - bef2_rvs-line.measure-cli-qnty
                  .
                  for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = bef2_rvs-line.rvs-code
                                                       and buf_rvs-line-pump.obj-type = bef2_rvs-line.obj-type
                                                       and buf_rvs-line-pump.obj-code = bef2_rvs-line.obj-code
                                                       and buf_rvs-line-pump.pl-code  = bef2_rvs-line.pl-code
                                                       and buf_rvs-line-pump.gds-code = bef2_rvs-line.gds-code
                  :
                    if t-doc.status_ = {&fact}
                    then do :
                      find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                            and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and (buf_c-pl-gds-pump.corr-date < t-doc.fact-date
                                                              or buf_c-pl-gds-pump.corr-date = t-doc.fact-date and buf_c-pl-gds-pump.corr-time < t-doc.fact-time)
                                                            no-error .
                    end .
                    else do :
                      find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                            and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and (buf_c-pl-gds-pump.corr-date < t-doc.sys-date
                                                              or buf_c-pl-gds-pump.corr-date = t-doc.sys-date and buf_c-pl-gds-pump.corr-time < t-doc.sys-time-int)
                                                            no-error .
                    end .
                    if available buf_c-pl-gds-pump
                    then do :
                      find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                              and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                              and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                              and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                              and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                              and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                              no-error .
                      if available buf2_c-pl-gds-pump
                      then do :
                        v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
                      end .
                      else do :
                        for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                        :
                          v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                        end .
                      end .
                    end .
                    else do :
                      for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                          and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                          and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                          and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                          and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                      :
                        v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                      end .
                    end .
                    
                    if v-pl-gds-pump-status_ = {&current-status}
                    then do :
                      create tt-rvs-line-pump-delta .
                      buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
                      assign
                        tt-rvs-line-pump-delta.rvs-code = "before-doc"
                        tt-rvs-line-pump-delta.density = (bef2_rvs-line.state-density / 2)
                      .
                      if tt-rvs-line-pump-delta.state-el-cnt = ?
                      or tt-rvs-line-pump-delta.state-el-cnt <= 0
                      then do :
                        tt-rvs-line-pump-delta.is-err = yes .
                      end .
                    end .
                  end. /* for each bf_rvs-line-pump */
                end .
              end .
            end .
          end . /* place-com-tanks */
        end . /* for each bef_rvs-doc no-lock */
        
        for each aft_rvs-doc no-lock
          where aft_rvs-doc.out-code  = t-doc.doc-code
            and aft_rvs-doc.rvs-type  = {&rvs-after-doc}
        :
          for each aft_rvs-line no-lock
            where aft_rvs-line.rvs-code = aft_rvs-doc.rvs-code
              and aft_rvs-line.obj-type = aft_rvs-doc.obj-type
              and aft_rvs-line.obj-code = aft_rvs-doc.obj-code
              and aft_rvs-line.pl-code  = tt-doc-pl.pl-code
              and aft_rvs-line.gds-code = tt-doc-pl.gds-code
          :
            assign
              tt-fr-doc-line.state-measure-qnty     = tt-fr-doc-line.state-measure-qnty     + aft_rvs-line.state-measure-qnty
              tt-fr-doc-line.measure-qnty           = tt-fr-doc-line.measure-qnty           + aft_rvs-line.measure-qnty 
              tt-fr-doc-line.state-measure-cli-qnty = tt-fr-doc-line.state-measure-cli-qnty + aft_rvs-line.state-measure-cli-qnty
              tt-fr-doc-line.measure-cli-qnty       = tt-fr-doc-line.measure-cli-qnty       + aft_rvs-line.measure-cli-qnty
            .
            
            for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = aft_rvs-line.rvs-code
                                                 and buf_rvs-line-pump.obj-type = aft_rvs-line.obj-type
                                                 and buf_rvs-line-pump.obj-code = aft_rvs-line.obj-code
                                                 and buf_rvs-line-pump.pl-code  = aft_rvs-line.pl-code
                                                 and buf_rvs-line-pump.gds-code = aft_rvs-line.gds-code
            :
              if t-doc.status_ = {&fact}
              then do :
                find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                      and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and (buf_c-pl-gds-pump.corr-date < t-doc.fact-date
                                                        or buf_c-pl-gds-pump.corr-date = t-doc.fact-date and buf_c-pl-gds-pump.corr-time < t-doc.fact-time)
                                                      no-error .
              end .
              else do :
                find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                      and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and (buf_c-pl-gds-pump.corr-date < t-doc.sys-date
                                                        or buf_c-pl-gds-pump.corr-date = t-doc.sys-date and buf_c-pl-gds-pump.corr-time < t-doc.sys-time-int)
                                                      no-error .
              end .
              if available buf_c-pl-gds-pump
              then do :
                find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                        and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                        and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                        and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                        and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                        and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                        no-error .
                if available buf2_c-pl-gds-pump
                then do :
                  v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
                end .
                else do :
                  for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                  :
                    v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                  end .
                end .
              end .
              else do :
                for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                    and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                    and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                    and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                    and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                :
                  v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                end .
              end .
              
              if v-pl-gds-pump-status_ = {&current-status}
              then do :
                find first tt-rvs-line-pump-delta where tt-rvs-line-pump-delta.rvs-code    = "before-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
                                                    and tt-rvs-line-pump-delta.obj-type    = buf_rvs-line-pump.obj-type
                                                    and tt-rvs-line-pump-delta.obj-code    = buf_rvs-line-pump.obj-code
                                                    and tt-rvs-line-pump-delta.pl-code     = buf_rvs-line-pump.pl-code
                                                    and tt-rvs-line-pump-delta.gds-code    = buf_rvs-line-pump.gds-code
                                                    and tt-rvs-line-pump-delta.pump-code   = buf_rvs-line-pump.pump-code
                                                    and tt-rvs-line-pump-delta.nozzle-code = buf_rvs-line-pump.nozzle-code
                                                    no-error .
                if not available tt-rvs-line-pump-delta
                then do :
                  create tt-rvs-line-pump-delta .
                  buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
                  assign
                    tt-rvs-line-pump-delta.rvs-code = "after-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
                    tt-rvs-line-pump-delta.is-err = yes
                  .
                end .
                else do :
                  tt-rvs-line-pump-delta.find-pair = yes .
                  if tt-rvs-line-pump-delta.state-el-cnt > buf_rvs-line-pump.state-el-cnt
                  then do :
                    tt-rvs-line-pump-delta.is-err = yes .
                  end .
                  else do :
                    tt-rvs-line-pump-delta.deltaVol = buf_rvs-line-pump.state-el-cnt - tt-rvs-line-pump-delta.state-el-cnt .
                    tt-rvs-line-pump-delta.density = tt-rvs-line-pump-delta.density + (aft_rvs-line.state-density / 2) .
                  end .
                end .
              end .
            end . /* for each bf_rvs-line-pump */
          end .
          
          if t-doc.status_ = {&fact}
          then do :
            find last buf_c-place-attr no-lock where buf_c-place-attr.obj-type  = tt-doc-pl.obj-type
                                                 and buf_c-place-attr.obj-code  = tt-doc-pl.obj-code
                                                 and buf_c-place-attr.pl-code   = tt-doc-pl.pl-code
                                                 and buf_c-place-attr.attr-code = {&place-com-tanks}
                                                 and (buf_c-place-attr.corr-date < t-doc.fact-date
                                                   or buf_c-place-attr.corr-date = t-doc.fact-date and buf_c-place-attr.corr-time < t-doc.fact-time)
                                                 no-error .
          end .
          else do :
            find last buf_c-place-attr no-lock where buf_c-place-attr.obj-type  = tt-doc-pl.obj-type
                                                 and buf_c-place-attr.obj-code  = tt-doc-pl.obj-code
                                                 and buf_c-place-attr.pl-code   = tt-doc-pl.pl-code
                                                 and buf_c-place-attr.attr-code = {&place-com-tanks}
                                                 and (buf_c-place-attr.corr-date < t-doc.sys-date
                                                   or buf_c-place-attr.corr-date = t-doc.sys-date and buf_c-place-attr.corr-time < t-doc.sys-time-int)
                                                 no-error .
          end .
          if available buf_c-place-attr
          then do :
            find first buf2_c-place-attr no-lock where buf2_c-place-attr.obj-type = buf_c-place-attr.obj-type
                                                   and buf2_c-place-attr.obj-code = buf_c-place-attr.obj-code
                                                   and buf2_c-place-attr.pl-code  = buf_c-place-attr.pl-code
                                                   and buf2_c-place-attr.attr-code = buf_c-place-attr.attr-code
                                                   and buf2_c-place-attr.chip-num > buf_c-place-attr.chip-num
                                                   no-error .
            if available buf2_c-place-attr
            then do :
              if buf2_c-place-attr.attr-value > ""
              then do :
                assign
                  v-ok = yes
                  varvalue = buf2_c-place-attr.attr-value
                .
              end .
            end .
            else do :
              run placelib_get-attr  ( input {&place-com-tanks}
                ,input tt-doc-pl.obj-code
                ,input tt-doc-pl.obj-type
                ,input tt-doc-pl.pl-code
                ,output varvalue
                ,output v-ok      ) no-error.
            end .
          end .
          else do :
            run placelib_get-attr  ( input {&place-com-tanks}
              ,input tt-doc-pl.obj-code
              ,input tt-doc-pl.obj-type
              ,input tt-doc-pl.pl-code
              ,output varvalue
              ,output v-ok      ) no-error.
          end .
          
          if v-ok
          and varvalue > ""
          then do :
            do jj = 1 to num-entries(varvalue) :
              find first bf2_place no-lock where bf2_place.obj-type = tt-doc-pl.obj-type
                                             and bf2_place.obj-code = tt-doc-pl.obj-code
                                             and bf2_place.loc1     = entry(jj, varvalue)
                                             and bf2_place.status_  = ""
                                             no-error .
              if available bf2_place
              then do :
                find first aft2_rvs-line no-lock
                  where aft2_rvs-line.rvs-code = aft_rvs-doc.rvs-code
                    and aft2_rvs-line.obj-type = aft_rvs-doc.obj-type
                    and aft2_rvs-line.obj-code = aft_rvs-doc.obj-code
                    and aft2_rvs-line.pl-code  = bf2_place.pl-code
                    and aft2_rvs-line.gds-code = tt-doc-pl.gds-code
                  no-error .
                if available aft2_rvs-line
                then do:
                  assign
                    tt-fr-doc-line.state-measure-qnty     = tt-fr-doc-line.state-measure-qnty     + aft2_rvs-line.state-measure-qnty    
                    tt-fr-doc-line.measure-qnty           = tt-fr-doc-line.measure-qnty           + aft2_rvs-line.measure-qnty          
                    tt-fr-doc-line.state-measure-cli-qnty = tt-fr-doc-line.state-measure-cli-qnty + aft2_rvs-line.state-measure-cli-qnty
                    tt-fr-doc-line.measure-cli-qnty       = tt-fr-doc-line.measure-cli-qnty       + aft2_rvs-line.measure-cli-qnty      
                  .
                  
                  for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = aft2_rvs-line.rvs-code
                                                       and buf_rvs-line-pump.obj-type = aft2_rvs-line.obj-type
                                                       and buf_rvs-line-pump.obj-code = aft2_rvs-line.obj-code
                                                       and buf_rvs-line-pump.pl-code  = aft2_rvs-line.pl-code
                                                       and buf_rvs-line-pump.gds-code = aft2_rvs-line.gds-code
                  :
                    if t-doc.status_ = {&fact}
                    then do :
                      find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                            and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and (buf_c-pl-gds-pump.corr-date < t-doc.fact-date
                                                              or buf_c-pl-gds-pump.corr-date = t-doc.fact-date and buf_c-pl-gds-pump.corr-time < t-doc.fact-time)
                                                            no-error .
                    end .
                    else do :
                      find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                            and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and (buf_c-pl-gds-pump.corr-date < t-doc.sys-date
                                                              or buf_c-pl-gds-pump.corr-date = t-doc.sys-date and buf_c-pl-gds-pump.corr-time < t-doc.sys-time-int)
                                                            no-error .
                    end .
                    if available buf_c-pl-gds-pump
                    then do :
                      find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                              and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                              and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                              and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                              and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                              and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                              no-error .
                      if available buf2_c-pl-gds-pump
                      then do :
                        v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
                      end .
                      else do :
                        for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                        :
                          v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                        end .
                      end .
                    end .
                    else do :
                      for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                          and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                          and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                          and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                          and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                      :
                        v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                      end .
                    end .
                    
                    if v-pl-gds-pump-status_ = {&current-status}
                    then do :
                      find first tt-rvs-line-pump-delta where tt-rvs-line-pump-delta.rvs-code    = "before-doc"
                                                          and tt-rvs-line-pump-delta.obj-type    = buf_rvs-line-pump.obj-type
                                                          and tt-rvs-line-pump-delta.obj-code    = buf_rvs-line-pump.obj-code
                                                          and tt-rvs-line-pump-delta.pl-code     = buf_rvs-line-pump.pl-code
                                                          and tt-rvs-line-pump-delta.gds-code    = buf_rvs-line-pump.gds-code
                                                          and tt-rvs-line-pump-delta.pump-code   = buf_rvs-line-pump.pump-code
                                                          and tt-rvs-line-pump-delta.nozzle-code = buf_rvs-line-pump.nozzle-code
                                                          no-error .
                      if not available tt-rvs-line-pump-delta
                      then do :
                        create tt-rvs-line-pump-delta .
                        buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
                        assign
                          tt-rvs-line-pump-delta.rvs-code = "after-doc"
                          tt-rvs-line-pump-delta.is-err = yes
                        .
                      end .
                      else do :
                        tt-rvs-line-pump-delta.find-pair = yes .
                        if tt-rvs-line-pump-delta.state-el-cnt > buf_rvs-line-pump.state-el-cnt
                        then do :
                          tt-rvs-line-pump-delta.is-err = yes .
                        end .
                        else do :
                          tt-rvs-line-pump-delta.deltaVol = buf_rvs-line-pump.state-el-cnt - tt-rvs-line-pump-delta.state-el-cnt .
                          tt-rvs-line-pump-delta.density = tt-rvs-line-pump-delta.density + (aft2_rvs-line.state-density / 2) .
                        end .
                      end .
                    end .
                  end . /* for each bf_rvs-line-pump */
                end .
              end .
            end .
          end . /* place-com-tanks */
        end . /* for each aft_rvs-doc no-lock */
        
        assign
          tt-fr-doc-line.state-measure-qnty     = ? when tt-fr-doc-line.state-measure-qnty <= 0
          tt-fr-doc-line.measure-qnty           = ? when tt-fr-doc-line.measure-qnty <= 0
          tt-fr-doc-line.state-measure-cli-qnty = ? when tt-fr-doc-line.state-measure-cli-qnty <= 0
          tt-fr-doc-line.measure-cli-qnty       = ? when tt-fr-doc-line.measure-cli-qnty <= 0
        .
      end .
    end .
    else do :
      find first bef_rvs-doc no-lock
        where bef_rvs-doc.out-code  = t-doc.doc-code
          and bef_rvs-doc.rvs-type  = {&rvs-before-doc}
        no-error .
      find first aft_rvs-doc no-lock
        where aft_rvs-doc.out-code  = t-doc.doc-code
          and aft_rvs-doc.rvs-type  = {&rvs-after-doc}
        no-error .
      block-clc-rvs:
      for each tt-doc-pl
      on error undo, return error return-value
      :
        find first bef_rvs-line no-lock
          where bef_rvs-line.rvs-code = bef_rvs-doc.rvs-code
            and bef_rvs-line.obj-type = bef_rvs-doc.obj-type
            and bef_rvs-line.obj-code = bef_rvs-doc.obj-code
            and bef_rvs-line.pl-code  = tt-doc-pl.pl-code
            and bef_rvs-line.gds-code = tt-doc-pl.gds-code
          no-error .
        find first aft_rvs-line no-lock
          where aft_rvs-line.rvs-code = aft_rvs-doc.rvs-code
            and aft_rvs-line.obj-type = aft_rvs-doc.obj-type
            and aft_rvs-line.obj-code = aft_rvs-doc.obj-code
            and aft_rvs-line.pl-code  = tt-doc-pl.pl-code
            and aft_rvs-line.gds-code = tt-doc-pl.gds-code
          no-error .
        if available aft_rvs-line
        and available bef_rvs-line
        then do:
          assign
            tt-fr-doc-line.state-measure-qnty     = tt-fr-doc-line.state-measure-qnty     + aft_rvs-line.state-measure-qnty      - bef_rvs-line.state-measure-qnty
            tt-fr-doc-line.measure-qnty           = tt-fr-doc-line.measure-qnty           + aft_rvs-line.measure-qnty            - bef_rvs-line.measure-qnty
            tt-fr-doc-line.state-measure-cli-qnty = tt-fr-doc-line.state-measure-cli-qnty + aft_rvs-line.state-measure-cli-qnty  - bef_rvs-line.state-measure-cli-qnty
            tt-fr-doc-line.measure-cli-qnty       = tt-fr-doc-line.measure-cli-qnty       + aft_rvs-line.measure-cli-qnty        - bef_rvs-line.measure-cli-qnty
          .
          for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = bef_rvs-line.rvs-code
                                               and buf_rvs-line-pump.obj-type = bef_rvs-line.obj-type
                                               and buf_rvs-line-pump.obj-code = bef_rvs-line.obj-code
                                               and buf_rvs-line-pump.pl-code  = bef_rvs-line.pl-code
                                               and buf_rvs-line-pump.gds-code = bef_rvs-line.gds-code
          :
            if t-doc.status_ = {&fact}
            then do :
              find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                    and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                    and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                    and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                    and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                    and (buf_c-pl-gds-pump.corr-date < t-doc.fact-date
                                                      or buf_c-pl-gds-pump.corr-date = t-doc.fact-date and buf_c-pl-gds-pump.corr-time < t-doc.fact-time)
                                                    no-error .
            end .
            else do :
              find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                    and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                    and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                    and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                    and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                    and (buf_c-pl-gds-pump.corr-date < t-doc.sys-date
                                                      or buf_c-pl-gds-pump.corr-date = t-doc.sys-date and buf_c-pl-gds-pump.corr-time < t-doc.sys-time-int)
                                                    no-error .
            end .
            if available buf_c-pl-gds-pump
            then do :
              find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                      and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                      and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                      and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                      and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                      and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                      no-error .
              if available buf2_c-pl-gds-pump
              then do :
                v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
              end .
              else do :
                for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                    and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                    and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                    and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                    and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                :
                  v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                end .
              end .
            end .
            else do :
              for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                  and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                  and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                  and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                  and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
              :
                v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
              end .
            end .
            
            if v-pl-gds-pump-status_ = {&current-status}
            then do :
              create tt-rvs-line-pump-delta .
              buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
              assign
                tt-rvs-line-pump-delta.rvs-code = "before-doc"
                tt-rvs-line-pump-delta.density = (bef_rvs-line.state-density / 2)
              .
              if tt-rvs-line-pump-delta.state-el-cnt = ?
              or tt-rvs-line-pump-delta.state-el-cnt <= 0
              then do :
                tt-rvs-line-pump-delta.is-err = yes .
              end .
            end .
          end. /* for each bf_rvs-line-pump */
          
          for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = aft_rvs-line.rvs-code
                                               and buf_rvs-line-pump.obj-type = aft_rvs-line.obj-type
                                               and buf_rvs-line-pump.obj-code = aft_rvs-line.obj-code
                                               and buf_rvs-line-pump.pl-code  = aft_rvs-line.pl-code
                                               and buf_rvs-line-pump.gds-code = aft_rvs-line.gds-code
          :
            if t-doc.status_ = {&fact}
            then do :
              find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                    and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                    and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                    and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                    and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                    and (buf_c-pl-gds-pump.corr-date < t-doc.fact-date
                                                      or buf_c-pl-gds-pump.corr-date = t-doc.fact-date and buf_c-pl-gds-pump.corr-time < t-doc.fact-time)
                                                    no-error .
            end .
            else do :
              find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                    and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                    and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                    and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                    and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                    and (buf_c-pl-gds-pump.corr-date < t-doc.sys-date
                                                      or buf_c-pl-gds-pump.corr-date = t-doc.sys-date and buf_c-pl-gds-pump.corr-time < t-doc.sys-time-int)
                                                    no-error .
            end .
            if available buf_c-pl-gds-pump
            then do :
              find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                      and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                      and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                      and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                      and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                      and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                      no-error .
              if available buf2_c-pl-gds-pump
              then do :
                v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
              end .
              else do :
                for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                    and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                    and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                    and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                    and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                :
                  v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                end .
              end .
            end .
            else do :
              for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                  and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                  and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                  and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                  and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
              :
                v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
              end .
            end .
            
            if v-pl-gds-pump-status_= {&current-status}
            then do :
              find first tt-rvs-line-pump-delta where tt-rvs-line-pump-delta.rvs-code    = "before-doc"
                                                  and tt-rvs-line-pump-delta.obj-type    = buf_rvs-line-pump.obj-type
                                                  and tt-rvs-line-pump-delta.obj-code    = buf_rvs-line-pump.obj-code
                                                  and tt-rvs-line-pump-delta.pl-code     = buf_rvs-line-pump.pl-code
                                                  and tt-rvs-line-pump-delta.gds-code    = buf_rvs-line-pump.gds-code
                                                  and tt-rvs-line-pump-delta.pump-code   = buf_rvs-line-pump.pump-code
                                                  and tt-rvs-line-pump-delta.nozzle-code = buf_rvs-line-pump.nozzle-code
                                                  no-error .
              if not available tt-rvs-line-pump-delta
              then do :
                create tt-rvs-line-pump-delta .
                buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
                assign
                  tt-rvs-line-pump-delta.rvs-code = "after-doc"
                  tt-rvs-line-pump-delta.is-err = yes
                .
              end .
              else do :
                tt-rvs-line-pump-delta.find-pair = yes .
                if tt-rvs-line-pump-delta.state-el-cnt > buf_rvs-line-pump.state-el-cnt
                then do :
                  tt-rvs-line-pump-delta.is-err = yes .
                end .
                else do :
                  tt-rvs-line-pump-delta.deltaVol = buf_rvs-line-pump.state-el-cnt - tt-rvs-line-pump-delta.state-el-cnt .
                  tt-rvs-line-pump-delta.density = tt-rvs-line-pump-delta.density + (aft_rvs-line.state-density / 2) .
                end .
              end .
            end .
          end . /* for each bf_rvs-line-pump */
          
          if t-doc.status_ = {&fact}
          then do :
            find last buf_c-place-attr no-lock where buf_c-place-attr.obj-type  = tt-doc-pl.obj-type
                                                 and buf_c-place-attr.obj-code  = tt-doc-pl.obj-code
                                                 and buf_c-place-attr.pl-code   = tt-doc-pl.pl-code
                                                 and buf_c-place-attr.attr-code = {&place-com-tanks}
                                                 and (buf_c-place-attr.corr-date < t-doc.fact-date
                                                   or buf_c-place-attr.corr-date = t-doc.fact-date and buf_c-place-attr.corr-time < t-doc.fact-time)
                                                 no-error .
          end .
          else do :
            find last buf_c-place-attr no-lock where buf_c-place-attr.obj-type  = tt-doc-pl.obj-type
                                                 and buf_c-place-attr.obj-code  = tt-doc-pl.obj-code
                                                 and buf_c-place-attr.pl-code   = tt-doc-pl.pl-code
                                                 and buf_c-place-attr.attr-code = {&place-com-tanks}
                                                 and (buf_c-place-attr.corr-date < t-doc.sys-date
                                                   or buf_c-place-attr.corr-date = t-doc.sys-date and buf_c-place-attr.corr-time < t-doc.sys-time-int)
                                                 no-error .
          end .
          if available buf_c-place-attr
          then do :
            find first buf2_c-place-attr no-lock where buf2_c-place-attr.obj-type = buf_c-place-attr.obj-type
                                                   and buf2_c-place-attr.obj-code = buf_c-place-attr.obj-code
                                                   and buf2_c-place-attr.pl-code  = buf_c-place-attr.pl-code
                                                   and buf2_c-place-attr.attr-code = buf_c-place-attr.attr-code
                                                   and buf2_c-place-attr.chip-num > buf_c-place-attr.chip-num
                                                   no-error .
            if available buf2_c-place-attr
            then do :
              if buf2_c-place-attr.attr-value > ""
              then do :
                assign
                  v-ok = yes
                  varvalue = buf2_c-place-attr.attr-value
                .
              end .
            end .
            else do :
              run placelib_get-attr  ( input {&place-com-tanks}
                ,input tt-doc-pl.obj-code
                ,input tt-doc-pl.obj-type
                ,input tt-doc-pl.pl-code
                ,output varvalue
                ,output v-ok      ) no-error.
            end .
          end .
          else do :
            run placelib_get-attr  ( input {&place-com-tanks}
              ,input tt-doc-pl.obj-code
              ,input tt-doc-pl.obj-type
              ,input tt-doc-pl.pl-code
              ,output varvalue
              ,output v-ok      ) no-error.
          end .
          
          if v-ok
          and varvalue > ""
          then do : /* place-com-tanks */
            do jj = 1 to num-entries(varvalue) :
              find first bf2_place no-lock where bf2_place.obj-type = tt-doc-pl.obj-type
                                             and bf2_place.obj-code = tt-doc-pl.obj-code
                                             and bf2_place.loc1     = entry(jj, varvalue)
                                             and bf2_place.status_  = ""
                                             no-error .
              if available bf2_place
              then do :
                find first bef2_rvs-line no-lock
                  where bef2_rvs-line.rvs-code = bef_rvs-doc.rvs-code
                    and bef2_rvs-line.obj-type = bef_rvs-doc.obj-type
                    and bef2_rvs-line.obj-code = bef_rvs-doc.obj-code
                    and bef2_rvs-line.pl-code  = bf2_place.pl-code
                    and bef2_rvs-line.gds-code = tt-doc-pl.gds-code
                  no-error .
                find first aft2_rvs-line no-lock
                  where aft2_rvs-line.rvs-code = aft_rvs-doc.rvs-code
                    and aft2_rvs-line.obj-type = aft_rvs-doc.obj-type
                    and aft2_rvs-line.obj-code = aft_rvs-doc.obj-code
                    and aft2_rvs-line.pl-code  = bf2_place.pl-code
                    and aft2_rvs-line.gds-code = tt-doc-pl.gds-code
                  no-error .
                if available aft2_rvs-line
                and available bef2_rvs-line
                then do:
                  assign
                    tt-fr-doc-line.state-measure-qnty     = tt-fr-doc-line.state-measure-qnty     + aft2_rvs-line.state-measure-qnty      - bef2_rvs-line.state-measure-qnty
                    tt-fr-doc-line.measure-qnty           = tt-fr-doc-line.measure-qnty           + aft2_rvs-line.measure-qnty            - bef2_rvs-line.measure-qnty
                    tt-fr-doc-line.state-measure-cli-qnty = tt-fr-doc-line.state-measure-cli-qnty + aft2_rvs-line.state-measure-cli-qnty  - bef2_rvs-line.state-measure-cli-qnty
                    tt-fr-doc-line.measure-cli-qnty       = tt-fr-doc-line.measure-cli-qnty       + aft2_rvs-line.measure-cli-qnty        - bef2_rvs-line.measure-cli-qnty
                  .
                  for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = bef2_rvs-line.rvs-code
                                                       and buf_rvs-line-pump.obj-type = bef2_rvs-line.obj-type
                                                       and buf_rvs-line-pump.obj-code = bef2_rvs-line.obj-code
                                                       and buf_rvs-line-pump.pl-code  = bef2_rvs-line.pl-code
                                                       and buf_rvs-line-pump.gds-code = bef2_rvs-line.gds-code
                  :
                    if t-doc.status_ = {&fact}
                    then do :
                      find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                            and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and (buf_c-pl-gds-pump.corr-date < t-doc.fact-date
                                                              or buf_c-pl-gds-pump.corr-date = t-doc.fact-date and buf_c-pl-gds-pump.corr-time < t-doc.fact-time)
                                                            no-error .
                    end .
                    else do :
                      find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                            and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and (buf_c-pl-gds-pump.corr-date < t-doc.sys-date
                                                              or buf_c-pl-gds-pump.corr-date = t-doc.sys-date and buf_c-pl-gds-pump.corr-time < t-doc.sys-time-int)
                                                            no-error .
                    end .
                    if available buf_c-pl-gds-pump
                    then do :
                      find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                              and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                              and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                              and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                              and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                              and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                              no-error .
                      if available buf2_c-pl-gds-pump
                      then do :
                        v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
                      end .
                      else do :
                        for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                        :
                          v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                        end .
                      end .
                    end .
                    else do :
                      for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                          and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                          and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                          and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                          and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                      :
                        v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                      end .
                    end .
                    
                    if v-pl-gds-pump-status_ = {&current-status}
                    then do :
                      create tt-rvs-line-pump-delta .
                      buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
                      assign
                        tt-rvs-line-pump-delta.rvs-code = "before-doc"
                        tt-rvs-line-pump-delta.density = (bef_rvs-line.state-density / 2)
                      .
                      if tt-rvs-line-pump-delta.state-el-cnt = ?
                      or tt-rvs-line-pump-delta.state-el-cnt <= 0
                      then do :
                        tt-rvs-line-pump-delta.is-err = yes .
                      end .
                    end .
                  end. /* for each bf_rvs-line-pump */
                  
                  for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = aft2_rvs-line.rvs-code
                                                       and buf_rvs-line-pump.obj-type = aft2_rvs-line.obj-type
                                                       and buf_rvs-line-pump.obj-code = aft2_rvs-line.obj-code
                                                       and buf_rvs-line-pump.pl-code  = aft2_rvs-line.pl-code
                                                       and buf_rvs-line-pump.gds-code = aft2_rvs-line.gds-code
                  :
                    if t-doc.status_ = {&fact}
                    then do :
                      find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                            and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and (buf_c-pl-gds-pump.corr-date < t-doc.fact-date
                                                              or buf_c-pl-gds-pump.corr-date = t-doc.fact-date and buf_c-pl-gds-pump.corr-time < t-doc.fact-time)
                                                            no-error .
                    end .
                    else do :
                      find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                            and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and (buf_c-pl-gds-pump.corr-date < t-doc.sys-date
                                                              or buf_c-pl-gds-pump.corr-date = t-doc.sys-date and buf_c-pl-gds-pump.corr-time < t-doc.sys-time-int)
                                                            no-error .
                    end .
                    if available buf_c-pl-gds-pump
                    then do :
                      find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                              and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                              and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                              and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                              and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                              and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                              no-error .
                      if available buf2_c-pl-gds-pump
                      then do :
                        v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
                      end .
                      else do :
                        for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                            and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                            and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                            and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                            and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                        :
                          v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                        end .
                      end .
                    end .
                    else do :
                      for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                          and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                          and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                          and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                          and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                      :
                        v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                      end .
                    end .
                    
                    if v-pl-gds-pump-status_ = {&current-status}
                    then do :
                      find first tt-rvs-line-pump-delta where tt-rvs-line-pump-delta.rvs-code    = "before-doc"
                                                          and tt-rvs-line-pump-delta.obj-type    = buf_rvs-line-pump.obj-type
                                                          and tt-rvs-line-pump-delta.obj-code    = buf_rvs-line-pump.obj-code
                                                          and tt-rvs-line-pump-delta.pl-code     = buf_rvs-line-pump.pl-code
                                                          and tt-rvs-line-pump-delta.gds-code    = buf_rvs-line-pump.gds-code
                                                          and tt-rvs-line-pump-delta.pump-code   = buf_rvs-line-pump.pump-code
                                                          and tt-rvs-line-pump-delta.nozzle-code = buf_rvs-line-pump.nozzle-code
                                                          no-error .
                      if not available tt-rvs-line-pump-delta
                      then do :
                        create tt-rvs-line-pump-delta .
                        buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
                        assign
                          tt-rvs-line-pump-delta.rvs-code = "after-doc"
                          tt-rvs-line-pump-delta.is-err = yes
                        .
                      end .
                      else do :
                        tt-rvs-line-pump-delta.find-pair = yes .
                        if tt-rvs-line-pump-delta.state-el-cnt > buf_rvs-line-pump.state-el-cnt
                        then do :
                          tt-rvs-line-pump-delta.is-err = yes .
                        end .
                        else do :
                          tt-rvs-line-pump-delta.deltaVol = buf_rvs-line-pump.state-el-cnt - tt-rvs-line-pump-delta.state-el-cnt .
                          tt-rvs-line-pump-delta.density = tt-rvs-line-pump-delta.density + (aft_rvs-line.state-density / 2) .
                        end .
                      end .
                    end .
                  end . /* for each bf_rvs-line-pump */
                end .
              end .
            end .
          end . /* place-com-tanks */
        end.
        else do:
          assign
            tt-fr-doc-line.state-measure-qnty     = ?
            tt-fr-doc-line.measure-qnty           = ?
            tt-fr-doc-line.state-measure-cli-qnty = ?
            tt-fr-doc-line.measure-cli-qnty       = ?
          .
          if available bef_rvs-doc
            and available aft_rvs-doc
            and lookup(v-ptrl-without-rvs, 'true,yes':u) = 0
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Сверки по документу созданы неверно!" skip
              "Необходимо удалить сверки и создать из заново." skip
              view-as alert-box error .
          end.
          leave block-clc-rvs .
        end.
      end. /* for each tt-doc-pl */
    end .
    
    v-trk-err = no .
    find first tt-rvs-line-pump-delta where tt-rvs-line-pump-delta.is-err no-error .
    if available tt-rvs-line-pump-delta
    then do :
      v-trk-err = yes .
      tt-fr-doc-line.trk-cli-qnty = ? .
    end .
    else do :
      for each tt-rvs-line-pump-delta :
        assign
          tt-fr-doc-line.trk-cli-qnty = tt-fr-doc-line.trk-cli-qnty + (tt-rvs-line-pump-delta.deltaVol * tt-rvs-line-pump-delta.density)
        .
      end .
    end .

    display
      tt-fr-doc-line.state-measure-qnty
      tt-fr-doc-line.measure-qnty
      tt-fr-doc-line.state-measure-cli-qnty
      tt-fr-doc-line.trk-cli-qnty
    with frame {&frame-name} .
    
/*    if (v-old-qnty <> tt-fr-doc-line.state-measure-qnty        */
/*    or v-old-cli-qnty <> tt-fr-doc-line.state-measure-cli-qnty)*/
/*    and tt-fr-doc-line.fact-qnty = tt-fr-doc-line.doc-qnty     */
/*    then do :                                                  */
/*      if infoSectionsTotal:IsKPrvs then isKPrvsSet = no .      */
/*    end .                                                      */
    
  end. /* on error */
end procedure. /* display-measure */

procedure init-tt-doc-pl :

  define buffer buf_doc-pl for ub.doc-pl .

  for each tt-doc-pl
  on error undo, return error error-status :get-message(1)
  :
    delete tt-doc-pl .
  end.
  for each buf_doc-pl no-lock
    where buf_doc-pl.obj-type = t-doc.obj-type
      and buf_doc-pl.obj-code = t-doc.obj-code
      and buf_doc-pl.out-code = t-doc.doc-code
      and buf_doc-pl.gds-code = buf_goods.gds-code
  on error undo, return error error-status :get-message(1)
  :
    create tt-doc-pl .
    buffer-copy buf_doc-pl to tt-doc-pl .
  end.

end procedure.

procedure new-price-s :
/* продажная цена до закрытия прихода на факт */
  do
  on error undo, return error return-value
  :

if not ( pr-naklvalue = yes and pr-genmrg = {&typeprice_before-margin} and is-petrolium = false  ) then do:
   hide  tt-fr-doc-line.new-price-sale  in frame {&frame-name}
         abr-rb in frame {&frame-name}
         b-corr-price-sale in frame {&frame-name}
         .
   return.
end.

{ gbl/r-b-abbr.i t-doc.host-code abr-rb}

if parline-mode = {&lookup} then do:
end.
else do:
  /**/
  define variable l-ok as logical   no-undo .
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_income_price-sale':U
      {&cntxt-object}
      t-doc.host-code
      t-doc.obj-type
      t-doc.obj-code
      0
      0
      0
      false
      l-ok
    }
    if l-ok = true
    then do:
      enable tt-fr-doc-line.new-price-sale  with frame {&frame-name} .
    end.
end.

define variable p-exist   as logical  no-undo .
run lineattr-exist in this-procedure (
    input t-doc.doc-code  ,
    input buf_goods.gds-code    ,
    input {&lineattr-corr-price-sale} ,
    output p-exist ) .

if p-exist then display b-corr-price-sale with frame {&frame-name} .
           else hide    b-corr-price-sale in frame {&frame-name} .

tt-fr-doc-line.new-price-sale:tooltip = "Цена будет перенесена в переоценку до закрытия этой накладной до ФАКТ" .
display tt-fr-doc-line.new-price-sale abr-rb with frame {&frame-name} .


  end.

end procedure. /* new-price-s */

procedure save-place-rsrv :

  define input  parameter kind-check as character no-undo.
  define output parameter p-ok       as logical   no-undo .

  do
  on error  undo, return error substitute( "&1 (save-place-rsrv). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (save-place-rsrv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (save-place-rsrv). endkey", vss-workfile )
  :
    define buffer buf_doc-pl for ub.doc-pl .

    define variable v-new-fact-qnty        like ub.doc-line.fact-qnty    no-undo .
    define variable v-new-density          like ub.doc-line.fact-density no-undo .
    define variable v-new-cli-fact-qnty    like ub.doc-line.fact-qnty    no-undo .

    assign
      p-ok = true
    .

    if is-petrolium = yes
      and is-pieces = no
      and kind-check = "hard":U
      and not( t-doc.status_ = {&wayb}
               and t-doc.flag_ = false
             )
    then do:
      run chkdcrvs in this-procedure
        ( input  tt-fr-doc-line.doc-code
         ,input  buf_goods.gds-code
         ,output p-ok
        ) no-error .
      if error-status :error then do:
        return error return-value .
      end.
      if p-ok = true then do:
        assign
          v-new-fact-qnty     = tt-fr-doc-line.fact-qnty
          v-new-density       = tt-fr-doc-line.fact-density
          v-new-cli-fact-qnty = tt-fr-doc-line.fact-qnty-kg
        .
        run local-state-fact-rvs in this-procedure
          ( input        tt-fr-doc-line.doc-code
           ,input        buf_goods.gds-code
           ,input        stfactplvalue
           ,input        varrevision
           ,input        varupd-fact-qnty
           ,input        tt-fr-doc-line.doc-qnty
           ,input        tt-fr-doc-line.doc-density
           ,input-output v-new-fact-qnty
           ,input-output v-new-density
           ,input-output v-new-cli-fact-qnty
          ) no-error .
        if error-status :error then do:
          message
            "Ошибка при установке факт кол-ва (revision)." skip
            return-value
            view-as alert-box error .
          undo, return error .
        end. /* error */

        if tt-fr-doc-line.fact-qnty <> v-new-fact-qnty
          or tt-fr-doc-line.fact-qnty-kg <> v-new-cli-fact-qnty
        then do:
          run correct-fact-qnty in this-procedure
            ( input v-new-fact-qnty
             ,input v-new-density
            ) no-error .
        end.

        display
          tt-fr-doc-line.fact-qnty
          tt-fr-doc-line.fact-qnty-kg when tt-fr-doc-line.fact-qnty-kg :visible = true
          tt-fr-doc-line.fact-density when tt-fr-doc-line.fact-density :visible = true
          with frame {&frame-name} .

        run eq-qnty-rvs-pl in this-procedure
          ( input        tt-fr-doc-line.doc-code
           ,input        buf_goods.gds-code
           ,input        varupd-fact-qnty
           ,input-output v-new-fact-qnty
           ,input-output v-new-density
           ,input-output v-new-cli-fact-qnty
           ,output p-ok
          ) no-error .
        if error-status :error then do:
          message
            "Ошибка при установке факт кол-ва по местам хранения." skip
            return-value
            view-as alert-box error .
          undo, return error .
        end. /* error */

        if tt-fr-doc-line.fact-qnty <> v-new-fact-qnty
          or tt-fr-doc-line.fact-qnty-kg <> v-new-cli-fact-qnty
        then do:
          assign
            tt-fr-doc-line.fact-qnty    = v-new-fact-qnty
            tt-fr-doc-line.fact-density = v-new-density
            tt-fr-doc-line.fact-qnty-kg = v-new-cli-fact-qnty
          .
          display
            tt-fr-doc-line.fact-qnty
            tt-fr-doc-line.fact-qnty-kg when tt-fr-doc-line.fact-qnty-kg :visible = true
            tt-fr-doc-line.fact-density when tt-fr-doc-line.fact-density :visible = true
            with frame {&frame-name} .
        end.
        if p-ok = false then do:
          return .
        end.
      end.
      else do:
        assign
          p-ok = true
        .
      end.
    end.

    run check-place-rsrv in this-procedure
      no-error.
    if error-status :error then do:
      return error substitute( "&1 (save-place-rsrv). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
    end.


    for each buf_doc-pl
      where buf_doc-pl.obj-type = tt-fr-doc-line.obj-type
        and buf_doc-pl.obj-code = tt-fr-doc-line.obj-code
        and buf_doc-pl.out-code = tt-fr-doc-line.doc-code
        and buf_doc-pl.gds-code = buf_goods.gds-code
    on error undo, return error substitute( "&1 (save-place-rsrv). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      delete buf_doc-pl .
    end. /* for each buf_doc-pl */

    for each tt-doc-pl
    on error undo, return error substitute( "&1 (save-place-rsrv). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      create buf_doc-pl .
      buffer-copy tt-doc-pl to buf_doc-pl .
    end. /* for each tt-doc-pl */

    if b-addinf :sensitive in frame {&frame-name} = true then do:
      /*run str/in-ladd.w
        ( input        parParentProc
        ,input        "set-attr":U
        ,input        t-doc.doc-code
        ,input        buf_goods.gds-code
        ,input-output infoSectionsTotal
        ,output was_setting
        )  .
      if error-status :error then do:
        return error substitute( "&1 (save-place-rsrv). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
      end.*/
    end.
  end.

  return .

end procedure. /* save-place-rsrv */

procedure correct-fact-qnty :

  define input parameter p-newfact-qnty like ub.doc-line.fact-qnty   no-undo .
  define input parameter p-density      like ub.doc-line.doc-density no-undo .
  
  define variable infoSecObj  as class ibs.th.str.InfoSection no-undo .
  define variable ii          as integer no-undo .
  define variable v-correct-cli-fact-qnty as decimal no-undo .
  define variable v-correct-fact-qnty as decimal no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :

    define buffer buf-next_tt-doc-pl for tt-doc-pl .
    define buffer buf_place for ub.place .


    assign
      tt-fr-doc-line.fact-qnty    = p-newfact-qnty
      tt-fr-doc-line.fact-density = p-density
      tt-fr-doc-line.fact-qnty-kg = p-newfact-qnty * p-density
    .
    display
      tt-fr-doc-line.fact-qnty
      tt-fr-doc-line.fact-qnty-kg when tt-fr-doc-line.fact-qnty-kg :visible = true
      tt-fr-doc-line.fact-density when tt-fr-doc-line.fact-density :visible = true
      with frame {&frame-name} .

    find first tt-doc-pl no-lock
    .
    find first buf-next_tt-doc-pl no-lock
      where buf-next_tt-doc-pl.obj-type =  tt-doc-pl.obj-type
        and buf-next_tt-doc-pl.obj-code =  tt-doc-pl.obj-code
        and buf-next_tt-doc-pl.pl-code  <> tt-doc-pl.pl-code
      no-error .
    if available buf-next_tt-doc-pl then do:
      for each tt-doc-pl,
      first buf_place no-lock where buf_place.pl-code = tt-doc-pl.pl-code
      on error undo, return error return-value
      :
        tt-doc-pl.fact-qnty = 0 .
        tt-doc-pl.cli-fact-qnty = 0 .
        do ii = 1 to infoSectionsTotal:SectionNum :
          infoSecObj = infoSectionsTotal:GetInfoSectionProp(ii) .
          if infoSecObj:ListTank = buf_place.loc1
          then do :
            tt-doc-pl.fact-qnty = tt-doc-pl.fact-qnty + infoSecObj:FactQnty .
            tt-doc-pl.cli-fact-qnty = tt-doc-pl.cli-fact-qnty + (infoSecObj:FactQnty * infoSecObj:FactDensity) .
          end .
        end .
/*        assign                                                                       */
/*          tt-doc-pl.cli-fact-qnty = tt-doc-pl.fact-qnty * tt-fr-doc-line.fact-density*/
/*        .                                                                            */
      end. /* for each tt-doc-pl */
      v-correct-cli-fact-qnty = tt-fr-doc-line.fact-qnty-kg .
      v-correct-fact-qnty = tt-fr-doc-line.fact-qnty .
      for each tt-doc-pl :
        assign
          v-correct-cli-fact-qnty = v-correct-cli-fact-qnty - tt-doc-pl.cli-fact-qnty
          v-correct-fact-qnty = v-correct-fact-qnty - tt-doc-pl.fact-qnty
        .
        if absolute( v-correct-cli-fact-qnty ) <= 0.001 then do:
          assign
            tt-doc-pl.cli-fact-qnty = tt-doc-pl.cli-fact-qnty + v-correct-cli-fact-qnty
          .
        end.
        if absolute( v-correct-fact-qnty ) <= 0.001 then do:
          assign
            tt-doc-pl.fact-qnty = tt-doc-pl.fact-qnty + v-correct-fact-qnty
          .
        end.
      end .
      run edit-doc-pl in this-procedure
        ( input {&autoupdate}
        ) no-error .
      if error-status :error then do:
        return error return-value .
      end.
    end. /* if available buf-next_tt-doc-pl */
    else do: /* if not available buf-next_tt-doc-pl */
      assign
        tt-doc-pl.fact-qnty     = tt-fr-doc-line.fact-qnty
        tt-doc-pl.cli-fact-qnty = tt-fr-doc-line.fact-qnty-kg
      .
    end. /* if not available tt-doc-pl */
  end.

end procedure. /* correct-fact-qnty */

/*==========================================================================*/

/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chg-attr {&FRAME-NAME}
PROCEDURE chg-attr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:       20/IX-2018 уже было до этого закомментарено
------------------------------------------------------------------------------*/
define buffer old_goods          for ub.goods .
define buffer old_doc-line       for ub.doc-line .
define buffer old_doc-line-attr  for ub.doc-line-attr .

define variable v-ok          as logical      no-undo.
define variable v-ptrl-yes    as logical      no-undo.
define variable v-pcs-no      as logical      no-undo.
define variable v-gds-code    as integer      no-undo.

do
on error undo, return error
:
      message
         "Были изменены параметры перевозчика для топлива."
         skip "Применить эти изменения для других топливных строк этого документа?"
      view-as alert-box question
      BUTTONS YES-NO
      UPDATE v-ok
      .
      IF v-ok THEN DO:
         FOR EACH old_doc-line
            WHERE old_doc-line.doc-code   = tt-fr-doc-line.doc-code
              AND NOT
                ( old_doc-line.artic = tt-fr-doc-line.artic
              AND old_doc-line.prod-type  = tt-fr-doc-line.prod-type
              AND old_doc-line.prod-code  = tt-fr-doc-line.prod-code
                )
            no-lock
            :
         ASSIGN
            v-ptrl-yes = no
            v-pcs-no   = no
         .
         { str/is-petrl.i
            old_doc-line.artic
            old_doc-line.prod-type
            old_doc-line.prod-code
            v-ptrl-yes
            v-pcs-no
         }

         if  v-ptrl-yes = yes
         AND v-pcs-no   = no
         then do:
            find first old_goods
               where old_goods.artic      = old_doc-line.artic
                  and old_goods.prod-type = old_doc-line.prod-type
                  and old_goods.prod-code = old_doc-line.prod-code
               no-lock
               .
               assign
                  v-gds-code =  old_goods.gds-code
               .
                  IF v-car-num  <> v-prt-car-num  THEN DO:
                     find first old_doc-line-attr
                        where  old_doc-line-attr.doc-code     = t-doc.doc-code
                           and old_doc-line-attr.gds-code     = v-gds-code
                           and old_doc-line-attr.attr-code    = "car-num"
                           exclusive-lock
                           no-error .
                     if NOT available old_doc-line-attr then
                     DO:
                       create old_doc-line-attr.
                       assign
                          old_doc-line-attr.doc-code     = t-doc.doc-code
                          old_doc-line-attr.gds-code     = v-gds-code
                          old_doc-line-attr.attr-code    = "car-num"
                       .
                     END.
                     assign
                        old_doc-line-attr.attr-value = v-prt-car-num
                     .
                  END.
                  IF v-car-vol  <>  v-prt-car-vol THEN DO:
                     find  first old_doc-line-attr
                           where old_doc-line-attr.doc-code     = t-doc.doc-code
                           and old_doc-line-attr.gds-code     = v-gds-code
                           and old_doc-line-attr.attr-code    = "car-vol"
                           exclusive-lock
                           no-error .
                     if NOT available old_doc-line-attr then
                     DO:
                       create old_doc-line-attr.
                       assign
                          old_doc-line-attr.doc-code     = t-doc.doc-code
                          old_doc-line-attr.gds-code     = v-gds-code
                          old_doc-line-attr.attr-code    = "car-vol"
                       .
                     END.
                     assign
                        old_doc-line-attr.attr-value = v-prt-car-vol
                     .
                  END.
                  IF v-autoent-obj-type <> v-prt-autoent-obj-type THEN DO:
                     find first old_doc-line-attr
                        where old_doc-line-attr.doc-code     = t-doc.doc-code
                        and   old_doc-line-attr.gds-code     = v-gds-code
                        and   old_doc-line-attr.attr-code    = "autoent-obj-type"
                        exclusive-lock
                        no-error .
                     if NOT available old_doc-line-attr then
                     DO:
                       create old_doc-line-attr.
                       assign
                          old_doc-line-attr.doc-code     = t-doc.doc-code
                          old_doc-line-attr.gds-code     = v-gds-code
                          old_doc-line-attr.attr-code    = "autoent-obj-type"
                       .
                     END.
                     assign
                        old_doc-line-attr.attr-value = v-prt-autoent-obj-type
                     .
                  END.
                  IF v-autoent-obj-code <> v-prt-autoent-obj-code THEN DO:
                     find first old_doc-line-attr
                        where old_doc-line-attr.doc-code     = t-doc.doc-code
                        and   old_doc-line-attr.gds-code     = v-gds-code
                        and   old_doc-line-attr.attr-code    = "autoent-obj-code"
                        exclusive-lock
                        no-error.
                     if NOT available old_doc-line-attr then
                     DO:
                       create old_doc-line-attr.
                       assign
                          old_doc-line-attr.doc-code     = t-doc.doc-code
                          old_doc-line-attr.gds-code     = v-gds-code
                          old_doc-line-attr.attr-code    = "autoent-obj-code"
                       .
                     END.
                     assign
                        old_doc-line-attr.attr-value = v-prt-autoent-obj-code
                     .
                  END.
                  IF v-fio <> v-prt-fio THEN DO:
                     find first old_doc-line-attr
                        where old_doc-line-attr.doc-code     = t-doc.doc-code
                        and   old_doc-line-attr.gds-code     = v-gds-code
                        and   old_doc-line-attr.attr-code    = "fio"
                        exclusive-lock
                        no-error.
                     if NOT available old_doc-line-attr then
                     DO:
                       create old_doc-line-attr.
                       assign
                          old_doc-line-attr.doc-code     = t-doc.doc-code
                          old_doc-line-attr.gds-code     = v-gds-code
                          old_doc-line-attr.attr-code    = "fio"
                       .
                     END.
                     assign
                        old_doc-line-attr.attr-value = v-prt-fio
                     .
                  END.
                  IF v-ptbotype <> v-prt-ptbotype THEN DO:
                     find first old_doc-line-attr
                        where old_doc-line-attr.doc-code     = t-doc.doc-code
                        and   old_doc-line-attr.gds-code     = v-gds-code
                        and   old_doc-line-attr.attr-code    = "ptbotype"
                        exclusive-lock
                        no-error.
                     if NOT available old_doc-line-attr then
                     DO:
                       create old_doc-line-attr.
                       assign
                          old_doc-line-attr.doc-code     = t-doc.doc-code
                          old_doc-line-attr.gds-code     = v-gds-code
                          old_doc-line-attr.attr-code    = "ptbotype"
                       .
                     END.
                     assign
                        old_doc-line-attr.attr-value = v-prt-ptbotype
                     .
                  END.
                  IF v-ptbocode <> v-prt-ptbocode THEN DO:

                     find first old_doc-line-attr
                        where old_doc-line-attr.doc-code     = t-doc.doc-code
                           and old_doc-line-attr.gds-code     = v-gds-code
                           and old_doc-line-attr.attr-code    = "ptbocode"
                           exclusive-lock
                           no-error.
                     if NOT available old_doc-line-attr then
                     DO:
                       create old_doc-line-attr.
                       assign
                          old_doc-line-attr.doc-code     = t-doc.doc-code
                          old_doc-line-attr.gds-code     = v-gds-code
                          old_doc-line-attr.attr-code    = "ptbocode"
                       .
                     END.
                     assign
                        old_doc-line-attr.attr-value = v-prt-ptbocode
                     .
                  END.

            END. /* petrl */
      END. /* EACH old_doc-line */
   END. /* v-ok */
end.  /* do on error */
END PROCEDURE. /* chg-attr */*/

procedure new-price-prod :
/* продажная цена до закрытия прихода на факт */
define variable par-is-pharm  as character no-undo .
define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :

{ gbl/conf-rd.i "'is-pharm'" v-cntxt-host-code-obj v-cntxt-obj-type v-cntxt-obj-code "''" "''" "''" no  par-is-pharm  par-type no-error } .
if par-is-pharm <> "yes"  then par-is-pharm = "no" .
else do:
   { str/opharm.i v-cntxt-obj-type v-cntxt-obj-code par-is-pharm }
end.

if par-is-pharm <> "yes"   then do:
   hide  tt-fr-doc-line.price-prod     in frame {&frame-name}
         tt-fr-doc-line.price-prod-vat in frame {&frame-name}
         abr-rb2 in frame {&frame-name}
         .
   return.
end.

{ gbl/r-b-abbr.i t-doc.host-code abr-rb2}

if parline-mode = {&lookup} then do:
end.
else do:
  /**/
  define variable l-ok as logical   no-undo .

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_income_price-prod':U
      {&cntxt-object}
      t-doc.host-code
      t-doc.obj-type
      t-doc.obj-code
      0
      0
      0
      false
      l-ok
    }

   if l-ok = true
    then do:
      enable tt-fr-doc-line.price-prod  tt-fr-doc-line.price-prod-vat with frame {&frame-name} .
    end.
end.
   tt-fr-doc-line.price-prod:tooltip = "Цена Производителя товаров медицинского назначения" .
   tt-fr-doc-line.price-prod-vat:tooltip = "Цена Производителя С НДС товаров медицинского назначения" .
display tt-fr-doc-line.price-prod tt-fr-doc-line.price-prod-vat abr-rb2 with frame {&frame-name} .


  end.

end procedure. /* new-price-s */

procedure save-price-prod :

  do
  on error undo, return error return-value
  :

run lineattr-write in this-procedure (
  input   t-doc.doc-code  ,
  input   buf_goods.gds-code  ,
  input   {&lineattr-price-prod} ,
  input   string(tt-fr-doc-line.price-prod) )
  no-error .
    if error-status :error then do:
       message vss-workfile vss-revision vss-description skip
               error-status :get-message( 1 ) skip
               return-value skip
               "№1"
       view-as alert-box error .
       return error.
    end.

run lineattr-write in this-procedure (
  input   t-doc.doc-code  ,
  input   buf_goods.gds-code  ,
  input   {&lineattr-price-prod-vat} ,
  input   string(tt-fr-doc-line.price-prod-vat) )
  no-error .
    if error-status :error then do:
       message vss-workfile vss-revision vss-description skip
               error-status :get-message( 1 ) skip
               return-value skip
               "№2"
       view-as alert-box error .
       return error.
    end.

end.

end procedure. /* save-price-prod */
procedure p-chk-vat private:
define input parameter p-new-vat-pc as decimal no-undo .
      if dops > '' and not f-chekval(input dops, input p-new-vat-pc) then do:
         message "Неверное значение НДС:" p-new-vat-pc skip
                 "Разрешенные значения: " replace(dops, ",", "%, ") + "%."
                 view-as alert-box.
         display tt-fr-doc-line.vat-pc with frame {&frame-name}.
         return error.
      end.
      if  dop-slt > '' and not f-chekval(input dop-slt , input tt-fr-doc-line.slt-pc) then do:
         message "Неверное значение НсП."   skip
                 "Разрешенные значения: " dop-slt "."
                 view-as alert-box.
         display tt-fr-doc-line.slt-pc with frame {&frame-name}.
         return error.
      end.

end procedure.

/* _UIB-CODE-BLOCK-END */