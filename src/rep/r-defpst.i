/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обьявление переменных

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Дата создания: 08/16/01
*/

{ cmp/str-glbl.i  }
{ gbl/cur-time.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/r-gl.i     }
{ rep/rep-bt.i   }

dEF {&df}  shared  VAR    Select-Good   as   integer   no-undo.
DEF {&df}  shared  VAR    RetClassify   as   char      no-undo.
DEF {&df}  shared  VAR    RetSortType   as   char      no-undo.
DEF {&df}  shared  VAR    Sums-Only     as   logical   no-undo.
def {&df}  shared  var    Fact-order-1  like ub.stk-tot.Fact-order no-undo.
def {&df}  shared  var    Fact-order-2  like ub.stk-tot.Fact-order no-undo.
def {&df}  shared  var    Cli-art       as character no-undo .
def {&df}  shared  var    date1Rash     as date no-undo .
def {&df}  shared  var    date2Rash     as date no-undo .
def {&df}  shared  var    PostName      as character no-undo .
def {&df}  shared  var    xtogobj       as logical no-undo .
def {&df}  shared  var    t-in          as logical no-undo .
def {&df}  shared  var    RADIO-Anal    as logical no-undo .
def {&df}  shared  var    RADPost       as logical no-undo .
def {&df}  shared  var    ShowCliPrice  as logical no-undo .
def {&df}  shared  var    ShowParts     as logical no-undo .
def {&df}  shared  var    ShowCost      as log no-undo.
def {&df}  shared  var    ShowSale      as log no-undo.
def {&df}  shared  var    Show-Negativ  as log no-undo.
def {&df}  shared  var    Show-zero-ost as log no-undo.
DEF {&df}  shared  VAR    PayType       as   integer no-undo.
DEF {&df}  shared  VAR    Type-stor     as   integer no-undo.
DEF {&df}  shared  VAR    xLavel        as   integer no-undo.

def SHARED temp-table g#post NO-UNDO
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    INDEX pi IS UNIQUE PRIMARY obj-type obj-code.

define temp-table temp-t-post-stk-line no-undo like ub.stk-supp-line
field gds-code          like ub.goods.gds-code
field goods-grp-name    like ub.goods.grp-name
field clients-grp-name  like ub.clients.grp-name
field clients-obj-name like  ub.clients.obj-name
field prod-cli-obj-type like ub.clients.obj-type
field prod-cli-obj-code like ub.clients.obj-code
field prod-cli-obj-name like ub.clients.obj-name
field unit-base         like ub.goods.unit-base
field prt-root          like ub.goods.prt-root
field gds-type          like ub.goods.gds-type
field gds-name          like ub.goods.gds-name
field cont-num          like ub.contract.contract-code

INDEX  pi is UNIQUE  PRIMARY
   obj-type ASCENDING
   obj-code ASCENDING
   cli-type ASCENDING
   cli-code ASCENDING
   artic    ASCENDING
   prod-type  ASCENDING
   prod-code  ASCENDING
   fact-order ASCENDING

INDEX pi1
   cli-type ASCENDING
   cli-code ASCENDING
   artic    ASCENDING
   prod-type  ASCENDING
   prod-code  ASCENDING
   fact-order ASCENDING

INDEX pi2
   goods-grp-name
   cli-type ASCENDING
   cli-code ASCENDING
   artic    ASCENDING
   prod-type  ASCENDING
   prod-code  ASCENDING
   fact-order ASCENDING
/*
INDEX pi22
   goods-grp-name
   clients-grp-name
   cli-type ASCENDING
   cli-code ASCENDING
   artic    ASCENDING
   prod-type  ASCENDING
   prod-code  ASCENDING
   fact-order ASCENDING

INDEX pi223
   clients-grp-name
   goods-grp-name
   cli-type ASCENDING
   cli-code ASCENDING
   artic    ASCENDING
   prod-type  ASCENDING
   prod-code  ASCENDING
   fact-order ASCENDING
  */
INDEX pi3
   clients-grp-name
   cli-type ASCENDING
   cli-code ASCENDING
   artic    ASCENDING
   prod-type  ASCENDING
   prod-code  ASCENDING
   fact-order ASCENDING

INDEX articren
   prod-type ASCENDING
   prod-code ASCENDING
   artic     ASCENDING
   obj-type  ASCENDING
   obj-code  ASCENDING


INDEX fact-order
   obj-type ASCENDING
   obj-code ASCENDING
   fact-order ASCENDING
.


&glob Select-Good-3  and ~
 can-find(first G#cli where ~
 post-stk-line.prod-type = G#cli.obj-type and ~
 post-stk-line.prod-code = G#cli.obj-code ) = TRUE

&glob Select-Good-2 and ~
 can-find(first Tmp#grp where ~
 ub.goods.grp-name begins Tmp#grp.grp-name ) = TRUE

&glob Select-Good-45 and ~
 can-find(first gds-list where ~
 ub.goods.gds-code = gds-list.gds-code ) = TRUE

&glob id-Goods  (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code))

&glob id-clients   (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code))

&glob id-prod  "(temp-t-post-stk-line.prod-cli-obj-name + ' ('+ temp-t-post-stk-line.prod-cli-obj-type + ' ' + string(temp-t-post-stk-line.prod-cli-obj-code) + ')')"

&glob id-Goods1  (tmp-itog.tmp-artic + tmp-itog.tmp-prod-type + string(tmp-itog.tmp-prod-code))

&glob id-clients1   (tmp-itog.tmp-cli-type + string(tmp-itog.tmp-cli-code))

&glob id-prod1  "(tmp-itog.tmp-prod-cli-obj-name + ' ('+ tmp-itog.tmp-prod-cli-obj-type + ' ' + string(tmp-itog.tmp-prod-cli-obj-code) + ')')"

&glob lavel-goods-grp-name (n-lavel(temp-t-post-stk-line.goods-grp-name,xLavel))
&glob lavel-clients-grp-name (n-lavel(temp-t-post-stk-line.clients-grp-name,xLavel))

def {&df}  shared   var gds-zap-unit-base     like ub.goods.unit-base    no-undo.
def {&df}  shared   var gds-zap-prt-root      like ub.goods.prt-root     no-undo .
def {&df}  shared   var gds-zap-gds-name      like ub.goods.gds-name     no-undo .
def {&df}  shared   var gds-zap-prod-type     like ub.goods.prod-type    no-undo .
def {&df}  shared   var gds-zap-prod-code     like ub.goods.prod-code    no-undo .
def {&df}  shared   var gds-zap-artic         like ub.goods.artic        no-undo .
def {&df}  shared   var gds-post-artic        like ub.ext-artic.ext-artic  no-undo .
def {&df}  shared   var gds-zap-b-code        like ub.bar-code.b-code    no-undo .
def {&df}  shared   var gds-type              as char no-undo.
def {&df}  shared   var gds-zap-type          like ub.goods.gds-type    no-undo .
def {&df}  shared   var gds-zap-grp-name      like ub.goods.grp-name    no-undo .
def {&df}  shared   var gds-zap-prod-name     like ub.clients.obj-name  no-undo .
def {&df}  shared   var gds-zap-price-base    like ub.stk-tot.sum-base  no-undo.
def {&df}  shared   var gds-zap-stoim-base    like ub.stk-tot.sum-base  no-undo.
def {&df}  shared   var gds-zap-qnty          like ub.stk-tot.fact-qnty no-undo.
def {&df}  shared   var gds-zap-Nds           like ub.stk-tot.sum-base  no-undo.
def {&df}  shared   var gds-zap-Np            like ub.stk-tot.sum-base  no-undo.
def {&df}  shared   var pos-cli-type          like ub.clients.obj-type  no-undo.
def {&df}  shared   var pos-cli-code          like ub.clients.obj-code  no-undo.
def {&df}  shared   var pos-cli-grp-name      like ub.clients.grp-name  no-undo.


def {&df}  shared   var ObjName           as   char  no-undo.
def {&df}  shared   var tPrintRubl        as   log   no-undo.
DEF {&df}  shared   VAR    Line           as   char        no-undo.
DEF {&df}  shared   VAR    old-name       as   char        no-undo.
DEF {&df}  shared   VAR    old-n          as   log init true  no-undo.
DEF {&df}  shared   VAR    i              as integer init 0  no-undo .
DEF {&df}  shared   VAR    Null-fact-order    as decimal init 0  no-undo .

def {&df}  shared   stream  OutStream.
 /* &message {&framename} */

def {&df}  shared  buffer temp-post-stk-line for  ub.stk-supp-line.
def {&df}  shared  buffer temp2-post-stk-line for  ub.stk-supp-line.
def {&df}  shared  buffer a-post-stk-line for  ub.stk-supp-line.
def {&df}  shared  buffer post-stk-line   for  ub.stk-supp-line.
def {&df}  shared  buffer prod-cli        for  ub.clients.
/*Состояние запасов по поставщикам -------------------------------------------------------------------------------------*/
&if {&framename} = 'zapas':U &then

def {&df}  shared  var F-ostatok-End     as   char  no-undo.
def {&df}  shared  var ostatok-End       as   decimal EXTENT 9 Format "->>>>>>>>>>>9.<<<" no-undo.
/* итог  по объекту */
def {&df} shared  var Tot-0-1 as decimal no-undo init 0.
def {&df} shared  var Tot-0-2 as decimal no-undo init 0.
def {&df} shared  var Tot-0-3 as decimal no-undo init 0.
def {&df} shared  var Tot-0-4 as decimal no-undo init 0.
def {&df} shared  var Tot-0-5 as decimal no-undo init 0.
/*общий итог*/
def {&df} shared  var Tot-1 as decimal no-undo init 0.
def {&df} shared  var Tot-2 as decimal no-undo init 0.
def {&df} shared  var Tot-3 as decimal no-undo init 0.
def {&df} shared  var Tot-4 as decimal no-undo init 0.
def {&df} shared  var Tot-5 as decimal no-undo init 0.

/* итог по группе 1 */
def {&df} shared  var Tot-1-1 as decimal no-undo init 0.
def {&df} shared  var Tot-1-2 as decimal no-undo init 0.
def {&df} shared  var Tot-1-3 as decimal no-undo init 0.
def {&df} shared  var Tot-1-4 as decimal no-undo init 0.
def {&df} shared  var Tot-1-5 as decimal no-undo init 0.


/* итог по группе 2 */
def {&df} shared  var Tot-2-1 as decimal no-undo init 0.
def {&df} shared  var Tot-2-2 as decimal no-undo  init 0.
def {&df} shared  var Tot-2-3 as decimal no-undo  init 0.
def {&df} shared  var Tot-2-4 as decimal no-undo init 0.
def {&df} shared  var Tot-2-5 as decimal no-undo init 0.
/* итог по группе 3 cli */
def {&df} shared  var Tot-3-1 as decimal no-undo init 0.
def {&df} shared  var Tot-3-2 as decimal no-undo  init 0.
def {&df} shared  var Tot-3-3 as decimal no-undo  init 0.
def {&df} shared  var Tot-3-4 as decimal no-undo init 0.
def {&df} shared  var Tot-3-5 as decimal no-undo init 0.

def  {&df}  shared  var tot_tqnty as decimal  no-undo.

DEFINE {&df} shared FRAME zapas

        sym1 column-label ":!:" format "x(1)" space(0)
        gds-zap-b-code column-label  "Код       ! " space(0)
        sym2 column-label ":!:" format "x(1)"                space(0)
        gds-zap-artic column-label "Артикул! ":C16 format "X(16)" space(0)
        sym12 column-label ":!:" format "x(1)"                             space(0)
        gds-post-artic column-label "Артикул!поставщика":C16 format "X(16)" space(0)
        sym3 column-label ":!:" format "x(1)"                         space(0)
        gds-zap-gds-name column-label "Название товара! ":C40 format "X(40)" space(0)
        sym4 column-label ":!:" format "x(1)"                                     space(0)
        gds-zap-unit-base column-label "Ед.!изм" format "X(3)"                  space(0)
        sym5 column-label ":!:" format "x(1)"                                     space(0)
        gds-zap-qnty column-label "Количество! ":C12 format "->>>>>>9.999"          space(0)
        sym6 column-label ":!:" format "x(1)"                                          space(0)
        gds-zap-price-base column-label "Цена! ":C17 format "->>>>>>>>>>>9.99"            space(0)
        sym7 column-label ":!:" format "x(1)"                                          space(0)
        gds-zap-stoim-base column-label "Стоимость! ":C17 format "->>>>>>>>>>>>9.99"           space(0)
        sym8 column-label ":!:" format "x(1)"                                          space(0)
        gds-zap-Nds column-label "НДС! ":C16 format "->>>>>>>>>>>9.99" space(0)
        sym9 column-label ":!:" format "x(1)"                                             space(0)
        gds-zap-Np column-label "НП! ":C14 format "->>>>>>>>>9.99" space(0)
        sym10 column-label ":!:" format "x(1)"                                             space(0)
        tot_tqnty column-label "Сумма!без НДС":C16 format "->>>>>>>>>>>9.99"          space(0)
        sym11 column-label ":!:" format "x(1)"                             space(0)

    HEADER
        cur-time-print() AT 5 format "X(35)"
        "Цены указаны в" (if tPrintRubl then "{&abbr_rub_allshift}" else x-base-type )
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>9") ) AT 115 format "X(15)" SKIP
        Line format "X(189)" AT 1
    with width {&DOS_CW_2} down stream-io use-text NO-BOX.

define {&df} shared temp-table tmp-cli-gds no-undo
field Tot-3-1 as decimal
field Tot-3-2 as decimal
field Tot-3-4 as decimal
field Tot-3-5 as decimal
field Tot-3-3 as decimal
field cli-code like obj-list.obj-code
field cli-type like obj-list.obj-type
field Name     as character
field obj-code like obj-list.obj-code
field obj-type like obj-list.obj-type
.

&endif

/*оборотка по поставщикам new--------------------------------------------------------------------------------------------*/
&if {&framename} = 'oborot-doc':U &then
def SHARED temp-table g#post-f NO-UNDO
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    field grp-code like ub.clients.grp-code
    field grp-name like ub.clients.grp-name
    field lvl-num like  ub.cli-grp.lvl-num
    INDEX pi IS UNIQUE PRIMARY obj-type obj-code
    INDEX p1  obj-name
    .

/* переменные фрайма */
def {&df}  shared   var F-prih            as   char  no-undo.
def {&df}  shared   var F-rash            as   char  no-undo.
def {&df}  shared   var F-kassa           as   char  no-undo.
def {&df}  shared   var F-Inv             as   char  no-undo.
def {&df}  shared   var F-spis            as   char  no-undo.
def {&df}  shared   var F-vzvr            as   char  no-undo.
def {&df}  shared   var F-vzvr-post       as   char  no-undo.
def {&df}  shared   var F-ostatok-start   as   char  no-undo.
def {&df}  shared   var F-ostatok-End     as   char  no-undo.
/*суммы по товарам */
def {&df}  shared  var ostatok-start     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var ostatok-End       as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var prih              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var rash              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var kassa             as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var Inv2              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var Inv               as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var spis              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var vzvr              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var vzvr-post         as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
/* итоги по поставщикам */
def {&df}  shared  var p-ostatok-start     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var p-ostatok-End       as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var p-prih              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var p-rash              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var p-kassa             as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var p-Inv               as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var p-spis               as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var p-vzvr              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var p-vzvr-post         as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.

define {&df} shared temp-table tmp-cli-gds no-undo
field p-ostatok-start     as   decimal  EXTENT 10
field p-ostatok-End       as   decimal  EXTENT 10
field p-prih              as   decimal  EXTENT 10
field p-rash              as   decimal  EXTENT 10
field p-kassa             as   decimal  EXTENT 10
field p-Inv               as   decimal  EXTENT 10
field p-spis              as   decimal  EXTENT 10
field p-vzvr              as   decimal  EXTENT 10
field p-vzvr-post         as   decimal  EXTENT 10
field cli-code            like obj-list.obj-code
field cli-type            like obj-list.obj-type
field Name                as character
field obj-code            like obj-list.obj-code
field obj-type            like obj-list.obj-type
.

/* итоги по объекту */
def {&df}  shared  var o-ostatok-start     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var o-ostatok-End       as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var o-prih              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var o-rash              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var o-kassa             as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var o-Inv               as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var o-spis              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var o-vzvr              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var o-vzvr-post         as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
/* итоги по 1 брейку */
def {&df} shared var B1-prih                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B1-rash                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B1-kassa                    as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B1-Inv                      as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B1-spis                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B1-vzvr                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B1-vzvr-post                as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B1-ostatok-start            as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B1-ostatok-End              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.

/* итоги по 2 брейку */
def {&df} shared var B2-prih                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B2-rash                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B2-kassa                    as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B2-Inv                      as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B2-spis                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B2-vzvr                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B2-vzvr-post                as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B2-ostatok-start            as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B2-ostatok-End              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.

/* итоги по всем */
def {&df} shared var Bi-prih                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var Bi-rash                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var Bi-kassa                    as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var Bi-Inv                      as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var Bi-spis                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var Bi-vzvr                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var Bi-vzvr-post                as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var Bi-ostatok-start            as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var Bi-ostatok-End              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.

DEFINE {&df} shared FRAME zapas
        gds-zap-b-code column-label  "Код!  ":C10 space(0)
        sym1 column-label ":!:" format "x(1)"       space(0)
        gds-zap-artic column-label "Артикул! ":C16 format "X(16)" space(0)
        sym2 column-label ":!:" format "x(1)"                         space(0)
        gds-zap-gds-name column-label "Название товара!  ":C30 format "X(30)" space(0)
        sym3 column-label ":!:" format "x(1)"                                 space(0)
        gds-zap-unit-base column-label "Ед.!изм" format "X(3)"                space(0)
        sym4 column-label ":!:" format "x(1)"                                 space(0)
        gds-type column-label "Тип!данных":C6 format "X(6)"                  space(0)
        sym5 column-label ":!:" format "x(1)" space(0)
        F-ostatok-start     column-label "Остаток!на начало":C13 format "x(13)"           space(0)
        sym6 column-label ":!:" format "x(1)" space(0)
        F-Prih       column-label "Приход!  ":C13     Format "x(13)"     space(0)
        sym7 column-label ":!:" format "x(1)" space(0)
        F-Rash       column-label "Расход!  ":C13  Format "x(13)"   space(0)
        sym8 column-label ":!:" format "x(1)" space(0)
        F-kassa             column-label "Касса!  ":C13  Format "x(13)"   space(0)
        sym9  column-label ":!:" format "x(1)" space(0)
        F-Inv               column-label "Инвента-!ризация ":C13  Format "x(13)"   space(0)
        sym10 column-label ":!:" format "x(1)" space(0)
        F-spis               column-label "Списание! ":C13  Format "x(13)"   space(0)
        sym11 column-label ":!:" format "x(1)" space(0)
        F-vzvr             column-label "Внешний!возврат":C13  Format "x(13)"   space(0)
        sym12  column-label ":!:" format "x(1)" space(0)
        F-vzvr-post         column-label "Возврат!поставщику":C13  Format "x(13)"   space(0)
        sym13 column-label ":!:" format "x(1)" space(0)
        F-ostatok-end     column-label "Остаток!на конец":C13 format "x(13)"           space(0)
    HEADER
        cur-time-print() AT 5 format "X(35)"
        "Цены указаны в" (if tPrintRubl then "{&abbr_rub_allshift}" else x-base-type )
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>9") ) AT 147 format "X(53)" SKIP
        Line format "X(194)" AT 1
   with width {&DOS_CW_2} down stream-io use-text NO-BOX.
&endif


/*оборотка по поставщикам -----------------------------------------------------------------------------------------------*/
&if {&framename} = 'oborot':U &then
def {&df}  shared  buffer post-ot-line    for  ub.ot-supp-line.

/* переменные фрайма */
def {&df}  shared   var F-prih            as   char  no-undo.
def {&df}  shared   var F-rash            as   char  no-undo.
def {&df}  shared   var F-kassa           as   char  no-undo.
def {&df}  shared   var F-Inv             as   char  no-undo.
def {&df}  shared   var F-spis            as   char  no-undo.
def {&df}  shared   var F-vzvr            as   char  no-undo.
def {&df}  shared   var F-vzvr-post       as   char  no-undo.
def {&df}  shared   var F-ostatok-start   as   char  no-undo.
def {&df}  shared   var F-ostatok-End     as   char  no-undo.
/*суммы по товарам */
def {&df}  shared  var ostatok-start     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var ostatok-End       as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var prih              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var rash              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var kassa             as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var Inv2              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var Inv               as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var spis              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var vzvr              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var vzvr-post         as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
/* итоги по поставщикам */
def {&df}  shared  var p-ostatok-start     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var p-ostatok-End       as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var p-prih              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var p-rash              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var p-kassa             as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var p-Inv               as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var p-spis               as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var p-vzvr              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var p-vzvr-post         as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.

define {&df} shared temp-table tmp-cli-gds no-undo
field p-ostatok-start     as   decimal  EXTENT 10
field p-ostatok-End       as   decimal  EXTENT 10
field p-prih              as   decimal  EXTENT 10
field p-rash              as   decimal  EXTENT 10
field p-kassa             as   decimal  EXTENT 10
field p-Inv               as   decimal  EXTENT 10
field p-spis              as   decimal  EXTENT 10
field p-vzvr              as   decimal  EXTENT 10
field p-vzvr-post         as   decimal  EXTENT 10
field cli-code            like obj-list.obj-code
field cli-type            like obj-list.obj-type
field Name                as character
field obj-code            like obj-list.obj-code
field obj-type            like obj-list.obj-type
.

/* итоги по объекту */
def {&df}  shared  var o-ostatok-start     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var o-ostatok-End       as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var o-prih              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var o-rash              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var o-kassa             as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var o-Inv               as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var o-spis              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var o-vzvr              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var o-vzvr-post         as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
/* итоги по 1 брейку */
def {&df} shared var B1-prih                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B1-rash                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B1-kassa                    as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B1-Inv                      as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B1-spis                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B1-vzvr                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B1-vzvr-post                as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B1-ostatok-start            as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B1-ostatok-End              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.

/* итоги по 2 брейку */
def {&df} shared var B2-prih                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B2-rash                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B2-kassa                    as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B2-Inv                      as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B2-spis                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B2-vzvr                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B2-vzvr-post                as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B2-ostatok-start            as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var B2-ostatok-End              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.

/* итоги по всем */
def {&df} shared var Bi-prih                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var Bi-rash                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var Bi-kassa                    as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var Bi-Inv                      as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var Bi-spis                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var Bi-vzvr                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var Bi-vzvr-post                as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var Bi-ostatok-start            as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def {&df} shared var Bi-ostatok-End              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.

DEFINE {&df} shared FRAME zapas
        gds-zap-b-code column-label  "Код!  ":C10 space(0)
        sym1 column-label ":!:" format "x(1)"       space(0)
        gds-zap-artic column-label "Артикул! ":C16 format "X(16)" space(0)
        sym2 column-label ":!:" format "x(1)"                         space(0)
        gds-zap-gds-name column-label "Название товара!  ":C30 format "X(30)" space(0)
        sym3 column-label ":!:" format "x(1)"                                 space(0)
        gds-zap-unit-base column-label "Ед.!изм" format "X(3)"                space(0)
        sym4 column-label ":!:" format "x(1)"                                 space(0)
        gds-type column-label "Тип!данных":C6 format "X(6)"                  space(0)
        sym5 column-label ":!:" format "x(1)" space(0)
        F-ostatok-start     column-label "Остаток!на начало":C13 format "x(13)"           space(0)
        sym6 column-label ":!:" format "x(1)" space(0)
        F-Prih       column-label "Приход!  ":C13     Format "x(13)"     space(0)
        sym7 column-label ":!:" format "x(1)" space(0)
        F-Rash       column-label "Расход!  ":C13  Format "x(13)"   space(0)
        sym8 column-label ":!:" format "x(1)" space(0)
        F-kassa             column-label "Касса!  ":C13  Format "x(13)"   space(0)
        sym9  column-label ":!:" format "x(1)" space(0)
        F-Inv               column-label "Инвента-!ризация ":C13  Format "x(13)"   space(0)
        sym10 column-label ":!:" format "x(1)" space(0)
        F-spis               column-label "Списание! ":C13  Format "x(13)"   space(0)
        sym11 column-label ":!:" format "x(1)" space(0)
        F-vzvr             column-label "Внешний!возврат":C13  Format "x(13)"   space(0)
        sym12  column-label ":!:" format "x(1)" space(0)
        F-vzvr-post         column-label "Возврат!поставщику":C13  Format "x(13)"   space(0)
        sym13 column-label ":!:" format "x(1)" space(0)
        F-ostatok-end     column-label "Остаток!на конец":C13 format "x(13)"           space(0)
    HEADER
        cur-time-print() AT 5 format "X(35)"
        "Цены указаны в" (if tPrintRubl then "{&abbr_rub_allshift}" else x-base-type )
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>9") ) AT 147 format "X(53)" SKIP
        Line format "X(194)" AT 1
   with width {&DOS_CW_2} down stream-io use-text NO-BOX.
&endif

/*оборотка по клиентам --------------------------------------------------------------------------------------------------*/
&if {&framename} = 'oborot-cli':U &then

define {&df} shared temp-table tmp-cli-gds no-undo
field Tot-3-1 as decimal
field Tot-3-2 as decimal
field Tot-3-4 as decimal
field Tot-3-5 as decimal
field Tot-3-3 as decimal
field cli-code like obj-list.obj-code
field cli-type like obj-list.obj-type
field Name     as character
field obj-code like obj-list.obj-code
field obj-type like obj-list.obj-type
.

def {&df}  shared  buffer post-ot-line    for  ub.ot-supp-line.

def {&df}  shared  var prih              as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var rash              as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var vzvr              as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var vzvr-post         as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var discnt            as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.

def {&df}  shared   var F-prih            as   char  no-undo.
def {&df}  shared   var F-rash            as   char  no-undo.
def {&df}  shared   var F-vzvr            as   char  no-undo.
def {&df}  shared   var F-vzvr-post       as   char  no-undo.
def {&df}  shared   var F-discnt          as   char  no-undo.

DEFINE {&df} shared FRAME zapas
        sym1 column-label ":!:" format "x(1)" space(0)
        gds-zap-b-code column-label  "Код !  ":C10 space(0)
        sym2 column-label ":!:" format "x(1)"       space(0)
        gds-zap-artic column-label "Артикул!  ":C16 format "X(16)" space(0)
        sym3 column-label ":!:" format "x(1)"                     space(0)
        gds-zap-gds-name column-label "Название товара!  ":C38 format "X(38)" space(0)
        sym4 column-label ":!:" format "x(1)"                                space(0)
        gds-zap-unit-base column-label "Ед.!изм" format "X(3)"               space(0)
        sym5 column-label ":!:" format "x(1)"                                space(0)
        gds-type column-label "Тип!данных":C6 format "X(6)"                  space(0)
        sym6 column-label ":!:" format "x(1)" space(0)
        F-Prih       column-label "Внешний!приход":C15     Format "x(15)"     space(0)
        sym7 column-label ":!:" format "x(1)" space(0)
        F-Rash       column-label "Внешний!расход":C15  Format "x(15)"   space(0)
        sym8 column-label ":!:" format "x(1)" space(0)
        F-vzvr             column-label "Внешний!возврат":C15  Format "x(15)"   space(0)
        sym9  column-label ":!:" format "x(1)" space(0)
        F-vzvr-post         column-label "Возврат!поставщику":C15  Format "x(15)"   space(0)
        sym10 column-label ":!:" format "x(1)" space(0)
        F-discnt         column-label "Наценка!  ":C15  Format "x(15)"   space(0)
        sym11 column-label ":!:" format "x(1)" space(0)
    HEADER
        cur-time-print() AT 5 format "X(35)"
        "Цены указаны в" (if tPrintRubl then "{&abbr_rub_allshift}" else x-base-type )
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>9") ) AT 147 format "X(53)" SKIP
        Line format "X(194)" AT 1
   with width {&DOS_CW_2} down stream-io use-text NO-BOX.
&endif

/*Продажи по клиентам --------------------------------------------------------------------------------------------------*/
&if {&framename} = 'cli-sale':U &then

def {&df}  shared  buffer post-ot-line    for  ub.ot-supp-line.


def {&df}  shared   var f-Fullname       as char  no-undo .
def {&df}  shared   var f-sum-cost        as decimal  no-undo .
def {&df}  shared   var f-sum-sale        as decimal  no-undo.
def {&df}  shared   var f-sum-discnt      as decimal  no-undo.
def {&df}  shared   var F-eff             as decimal  no-undo.
def {&df}  shared   var F-payment         as decimal  no-undo.
def {&df}  shared   var F-proc            as decimal  no-undo.

DEFINE {&df} shared FRAME zapas
        sym1 column-label ":!:" format "x(1)" space(0)
        pos-cli-code column-label  "Код !  ":C9     format "x(9)"  space(0)
        sym2 column-label ":!:" format "x(1)"       space(0)
        F-Fullname column-label "Наименование! ":C40 format "X(40)" space(0)
        sym3 column-label ":!:" format "x(1)"                     space(0)
        f-sum-cost column-label "Сумма продаж в!учетных ценах":C15 format "->>>>>>>>>>9.99" space(0)
        sym4 column-label ":!:" format "x(1)"                                   space(0)
        f-sum-sale column-label "Сумма продаж в!прод. ценах":C15 format "->>>>>>>>>>9.99"              space(0)
        sym5 column-label ":!:" format "x(1)"                                   space(0)
        f-sum-discnt column-label "Сумма!скидок":C15 format "->>>>>>>>>>9.99"      space(0)
        sym6 column-label ":!:" format "x(1)"                                   space(0)
        F-eff       column-label "Эффективность! ":C15   format    "->>>>>>>>>>9.99"     space(0)
        sym7 column-label ":!:" format "x(1)"                                   space(0)
        F-payment     column-label "Поступление!денег на р/с":C15   format  "->>>>>>>>>>9.99"     space(0)
        sym8 column-label ":!:" format "x(1)"                                   space(0)
        F-proc             column-label "% от пост-я!денег на р/с":C15  format  "->>>>>>>>>>9.99"   space(0)
        sym9  column-label ":!:" format "x(1)" space(0)
    HEADER
        cur-time-print() AT 5 format "X(35)"
        "Цены указаны в" (if tPrintRubl then "{&abbr_rub_allshift}" else x-base-type )
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>9") ) AT 147 format "X(53)" SKIP
        Line format "X(194)" AT 1
   with width {&DOS_CW_2} down stream-io use-text NO-BOX.
&endif
/*оборотка по приходам -----------------------------------------------------------------------------------------------*/
&if {&framename} = 'oborot-pri':U &then

def {&df}  shared  buffer post-ot-line    for  ub.ot-supp-line.

def {&df}  shared  var    Fact-order-3  like ub.stk-tot.Fact-order no-undo.
def {&df}  shared  var    Fact-order-4  like ub.stk-tot.Fact-order no-undo.

def {&df}  shared   var     Show-cost-vat  as logical no-undo .
def {&df}  shared   var     Show-sale-vat  as logical no-undo .

def {&df}  shared   var F-prih            as   char  no-undo.
def {&df}  shared   var F-rash            as   char  no-undo.
def {&df}  shared   var F-kassa           as   char  no-undo.
def {&df}  shared   var F-Inv             as   char  no-undo.
def {&df}  shared   var F-Spis            as   char  no-undo.
def {&df}  shared  var F-vzvr   as   char  no-undo.
def {&df}  shared  var F-vzvr-post     as   char  no-undo.
def {&df}  shared  var F-sm        as   char  no-undo.

def {&df}  shared  var vzvr              as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var vzvr-post         as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var prih              as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var rash              as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var kassa             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var Inv               as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var Spis              as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var Sm                as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.

def  {&df}  shared  var B1-prih             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B1-rash             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B1-kassa            as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B1-Inv              as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B1-spis             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B1-vzvr             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B1-vzvr-post        as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B1-sm               as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.

def  {&df}  shared  var B2-prih             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B2-rash             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B2-kassa            as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B2-Inv              as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B2-spis             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B2-vzvr             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B2-vzvr-post        as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B2-sm               as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.

def  {&df}  shared  var Bi-prih             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var Bi-rash             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var Bi-kassa            as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var Bi-Inv              as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var Bi-spis             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var Bi-vzvr             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var Bi-vzvr-post        as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var Bi-sm               as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.

def  {&df}  shared  var o-prih             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var o-rash             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var o-kassa            as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var o-Inv              as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var o-spis             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var o-vzvr             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var o-vzvr-post        as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var o-sm               as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.

def  {&df}  shared  var p-prih             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var p-rash             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var p-kassa            as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var p-Inv              as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var p-spis             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var p-vzvr             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var p-vzvr-post        as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var p-sm               as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.

define {&df} shared temp-table tmp-cli-gds no-undo
field p-prih              as   decimal  EXTENT 10
field p-rash              as   decimal  EXTENT 10
field p-kassa             as   decimal  EXTENT 10
field p-Inv               as   decimal  EXTENT 10
field p-spis              as   decimal  EXTENT 10
field p-vzvr              as   decimal  EXTENT 10
field p-vzvr-post         as   decimal  EXTENT 10
field p-sm                as   decimal  EXTENT 10
field cli-code            like obj-list.obj-code
field cli-type            like obj-list.obj-type
field Name                as character
field obj-code            like obj-list.obj-code
field obj-type            like obj-list.obj-type
.


DEFINE {&df} shared FRAME zapas
        sym1 column-label ":!:!:" format "x(1)" space(0)
        gds-zap-b-code column-label  "Код ! ! ":C10 space(0)
        sym2 column-label ":!:!:" format "x(1)"       space(0)
        gds-zap-artic column-label "Артикул! ! ":C16 format "X(16)" space(0)
        sym3 column-label ":!:!:" format "x(1)"                     space(0)
        gds-zap-gds-name column-label "Название товара! ! ":C37 format "X(37)" space(0)
        sym4 column-label ":!:!:" format "x(1)"                                space(0)
        gds-zap-unit-base column-label "Ед.!изм! " format "X(3)"               space(0)
        sym5 column-label ":!:!:" format "x(1)"                                space(0)
        gds-type column-label "Тип!данных! ":C6 format "X(6)"                  space(0)
        sym6 column-label ":!:!:" format "x(1)" space(0)
        F-Prih column-label "Приход!внешний ! ":C14     Format "x(14)" space(0)
        sym7 column-label ":!:!:" format "x(1)" space(0)
        F-Rash column-label "Расход!внешний ! ":C14  Format "x(14)"   space(0)
        sym8 column-label ":!:!:" format "x(1)" space(0)
        F-kassa column-label "Касса! ! ":C14  Format "x(14)"          space(0)
        sym9  column-label ":!:!:" format "x(1)" space(0)
        F-vzvr column-label "Возврат!внешний! ":C14 format "x(14)"    space(0)
        sym10 column-label ":!:!:" format "x(1)" space(0)
        F-vzvr-post column-label "Возврат!поставщику! ":C14 format "x(14)"           space(0)
        sym11 column-label ":!:!:" format "x(1)" space(0)
        F-Inv column-label "Инвентаризация! ! ":C14  Format "x(14)"   space(0)
        sym12 column-label ":!:!:" format "x(1)" space(0)
        F-Spis column-label "Списание! ! ":C14  Format "x(14)"   space(0)
        sym13 column-label ":!:!:" format "x(1)" space(0)
        F-Sm column-label "Смена!типа!приобр. ":C14  Format "x(14)"   space(0)
        sym14 column-label ":!:!:" format "x(1)" space(0)

    HEADER
        cur-time-print() AT 5 format "X(35)"
        "Цены указаны в" (if tPrintRubl then "{&abbr_rub_allshift}" else x-base-type )
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>9") ) AT 147 format "X(53)" SKIP
        Line format "X(198)" AT 1
   with width {&DOS_CW_2} down stream-io use-text NO-BOX.
&endif

/*оборотка по расходам -----------------------------------------------------------------------------------------------*/
&if {&framename} = 'oborot-ras':U &then
def {&df}  shared  buffer post-ot-line    for  ub.ot-supp-line.

def {&df}  shared  var    Fact-order-3  like ub.stk-tot.Fact-order no-undo.
def {&df}  shared  var    Fact-order-4  like ub.stk-tot.Fact-order no-undo.

def {&df}  shared   var     Show-cost-vat  as logical no-undo .
def {&df}  shared   var     Show-sale-vat  as logical no-undo .

def {&df}  shared   var F-rash            as   char  no-undo.
def {&df}  shared   var F-kassa           as   char  no-undo.
def {&df}  shared   var F-Inv             as   char  no-undo.
def {&df}  shared   var F-Spis            as   char  no-undo.
def {&df}  shared  var F-vzvr   as   char  no-undo.
def {&df}  shared  var F-vzvr-post     as   char  no-undo.

def {&df}  shared  var vzvr              as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var vzvr-post         as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var rash              as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var kassa             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var Inv               as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def {&df}  shared  var Spis              as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.

def  {&df}  shared  var B1-rash             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B1-kassa            as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B1-Inv              as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B1-spis             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B1-vzvr             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B1-vzvr-post        as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.

def  {&df}  shared  var B2-rash             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B2-kassa            as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B2-Inv              as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B2-spis             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B2-vzvr             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var B2-vzvr-post        as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.

def  {&df}  shared  var Bi-rash             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var Bi-kassa            as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var Bi-Inv              as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var Bi-spis             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var Bi-vzvr             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var Bi-vzvr-post        as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.

def  {&df}  shared  var o-rash             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var o-kassa            as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var o-Inv              as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var o-spis             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var o-vzvr             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var o-vzvr-post        as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.

def  {&df}  shared  var p-rash             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var p-kassa            as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var p-Inv              as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var p-spis             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var p-vzvr             as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.
def  {&df}  shared  var p-vzvr-post        as   decimal EXTENT 10 Format "->>>>>>>>>>>9.<<<" no-undo.

define {&df} shared temp-table tmp-cli-gds no-undo
field p-prih              as   decimal  EXTENT 10
field p-rash              as   decimal  EXTENT 10
field p-kassa             as   decimal  EXTENT 10
field p-Inv               as   decimal  EXTENT 10
field p-spis              as   decimal  EXTENT 10
field p-vzvr              as   decimal  EXTENT 10
field p-vzvr-post         as   decimal  EXTENT 10
field cli-code            like obj-list.obj-code
field cli-type            like obj-list.obj-type
field Name                as character
field obj-code            like obj-list.obj-code
field obj-type            like obj-list.obj-type
.

DEFINE {&df} shared FRAME zapas
        sym1 column-label ":!:!:" format "x(1)" space(0)
        gds-zap-b-code column-label  "Код ! ! ":C10 space(0)
        sym2 column-label ":!:!:" format "x(1)"       space(0)
        gds-zap-artic column-label "Артикул! ! ":C16 format "X(16)" space(0)
        sym3 column-label ":!:!:" format "x(1)"                         space(0)
        gds-zap-gds-name column-label "Название товара! ! ":C37 format "X(37)" space(0)
        sym4 column-label ":!:!:" format "x(1)"                                  space(0)
        gds-zap-unit-base column-label "Ед.!изм! " format "X(3)"                 space(0)
        sym5 column-label ":!:!:" format "x(1)"                                  space(0)
        gds-type column-label "Тип!данных! ":C6 format "X(6)"                  space(0)
        sym6 column-label ":!:!:" format "x(1)" space(0)
        F-Rash  column-label "Расход!внешний ! ":C14  Format "x(14)"   space(0)
        sym7 column-label ":!:!:" format "x(1)" space(0)
        F-kassa  column-label "Касса! ! ":C14  Format "x(14)"   space(0)
        sym8  column-label ":!:!:" format "x(1)" space(0)
        F-vzvr  column-label "Возврат!внешний! ":C14 format "x(14)"           space(0)
        sym9  column-label ":!:!:" format "x(1)" space(0)
        F-vzvr-post column-label "Возврат!поставщику! ":C14 format "x(14)"           space(0)
        sym10 column-label ":!:!:" format "x(1)" space(0)
        F-Inv       column-label "Инвентаризация! ! ":C14  Format "x(14)"   space(0)
        sym11 column-label ":!:!:" format "x(1)" space(0)
        F-Spis      column-label "Списание!внешнее ! ":C14  Format "x(14)"   space(0)
        sym12 column-label ":!:!:" format "x(1)" space(0)
    HEADER
        cur-time-print() AT 5 format "X(35)"
        "Цены указаны в" (if tPrintRubl then "{&abbr_rub_allshift}" else x-base-type )
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>9") ) AT 147 format "X(53)" SKIP
        Line format "X(198)" AT 1
   with width {&DOS_CW_2} down stream-io use-text NO-BOX.
&endif

/*отчет по бонусам -----------------------------------------------------------------------------------------------*/
&if {&framename} = 'bonus':U &then
def {&df}  shared  buffer post-ot-line    for  ub.ot-supp-line.

def {&df}  shared  var    Fact-order-3  like ub.stk-tot.Fact-order no-undo.
def {&df}  shared  var    Fact-order-4  like ub.stk-tot.Fact-order no-undo.

def {&df}  shared   var F-bonus           as   char  no-undo.
def {&df}  shared   var F-price-sale      as   char  no-undo.
def {&df}  shared   var F-kassa           as   char  no-undo.
def {&df}  shared   var F-bonus-dohod     as   char  no-undo.
def {&df}  shared   var F-nacenka         as   char  no-undo.


def {&df}  shared  var    v-bonus            as decimal EXTENT 10 format ">>9.99"       no-undo.
def {&df}  shared  var    v-price-sale       as decimal EXTENT 10 format ">>>>>>>>9.99" no-undo.
def {&df}  shared  var    v-kassa            as decimal EXTENT 10 format "->>>>>>>>9.99" no-undo.
def {&df}  shared  var    v-bonus-dohod      as decimal EXTENT 10 format "->>>>>>>>9.99" no-undo.
def {&df}  shared  var    v-nacenka          as decimal EXTENT 10 format "->>9.99"       no-undo.
def {&df}  shared  var    s-kassa            as decimal EXTENT 10 format "->>>>>>>>9.99" no-undo.
def {&df}  shared  var    s-bonus-dohod      as decimal EXTENT 10 format "->>>>>>>>9.99" no-undo.
def {&df}  shared  var    s-nacenka          as decimal EXTENT 10 format "->>9.99"       no-undo.
def {&df}  shared  var    v-last-page        as integer                                 no-undo.

define {&df} shared temp-table tmp-itog no-undo
field tmp-gds-code           like ub.goods.gds-code
field tmp-artic              like ub.goods.artic
field tmp-gds-name           like ub.goods.gds-name
field tmp-goods-grp-name     like ub.goods.grp-name
field tmp-clients-grp-name   like ub.clients.grp-name
field tmp-fact-order         like ub.stk-tot.Fact-order
field tmp-prod-type          like ub.goods.prod-type
field tmp-prod-code          like ub.goods.prod-code
field tmp-cli-type           like obj-list.obj-type
field tmp-cli-code           like obj-list.obj-code
field tmp-prod-cli-obj-name  like ub.clients.obj-name
field tmp-prod-cli-obj-type  like ub.clients.obj-type
field tmp-prod-cli-obj-code  like ub.clients.obj-code
field bn-col                 as   integer
field bonus                  as   decimal  format ">>9.99"
field sum-kassa              as   decimal  format "->>>>>>>>9.99"
field sum-bonus-dohod        as   decimal  format "->>>>>>>>9.99"
field sum-nacenka            as   decimal  format "->>9.99"
.

define {&df} shared temp-table tmp-cli-gds no-undo
field p-prih              as   decimal  EXTENT 10
field p-rash              as   decimal  EXTENT 10
field p-kassa             as   decimal  EXTENT 10
field p-Inv               as   decimal  EXTENT 10
field p-spis              as   decimal  EXTENT 10
field p-vzvr              as   decimal  EXTENT 10
field p-vzvr-post         as   decimal  EXTENT 10
field cli-code            like obj-list.obj-code
field cli-type            like obj-list.obj-type
field Name                as   character
field obj-code            like obj-list.obj-code
field obj-type            like obj-list.obj-type
.

DEFINE {&df} shared FRAME zapas
        sym1             column-label  ":!:"                            format "x(1)"          space(0)
        gds-zap-b-code   column-label  "Код! !":C10                                            space(0)
        sym2             column-label  ":!:"                            format "x(1)"          space(0)
        gds-zap-artic    column-label  "Артикул! !":C16                 format "X(16)"         space(0)
        sym3             column-label  ":!:"                            format "x(1)"          space(0)
        gds-zap-gds-name column-label  "Название товара! !":C37         format "X(37)"         space(0)
        sym4             column-label  ":!:"                            format "x(1)"          space(0)
        F-bonus          column-label  "Значение!бонуса":C16            format "x(16)"         space(0)
        sym5             column-label  ":!:"                            format "x(1)"          space(0)
        F-price-sale     column-label  "Последняя цена!прихода":C16     format "x(16)"         space(0)
        sym6             column-label  ":!:"                            format "x(1)"          space(0)
        F-kassa          column-label  "Касса!Продажа-возврат":C16      format "x(16)"         space(0)
        sym7             column-label  ":!:"                            format "x(1)"          space(0)
        F-bonus-dohod    column-label  "Валовой!доход от бонуса":C16    format "x(16)"         space(0)
        sym8             column-label  ":!:"                            format "x(1)"          space(0)
        F-nacenka        column-label  "Фактический!% наценки":C16      format "x(16)"         space(0)
        sym9             column-label  ":!:"                            format "x(1)"          space(0)
    HEADER
        cur-time-print() AT 5 format "X(35)"
        "Цены указаны в" ( "{&abbr_rub_allshift}" )
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>9") ) AT 130 format "X(53)" SKIP
        Line format "X(152)" AT 1
   with width {&DOS_CW_2} down stream-io use-text NO-BOX.
&endif

procedure create-temp-t-post-stk-line :
    
    define variable str  as char      format "X(60)" no-undo.
    define variable str2 as char      no-undo.
    define variable v-r  as character no-undo init "" .
    define variable i#i  as int       no-undo.
 do
 on error undo, return error return-value
 :
 if available ub.goods and
    available ub.clients and
    available prod-cli then do:
  create temp-t-post-stk-line .
  BUFFER-COPY post-stk-line  TO temp-t-post-stk-line
  assign
    temp-t-post-stk-line.goods-grp-name    = ub.goods.grp-name
    temp-t-post-stk-line.gds-code          = ub.goods.gds-code
    temp-t-post-stk-line.unit-base         = ub.goods.unit-base
    temp-t-post-stk-line.prt-root          = ub.goods.prt-root
    temp-t-post-stk-line.gds-type          = ub.goods.gds-type
    temp-t-post-stk-line.gds-name          = if g#gds-engl then ub.goods.engl-name else ub.goods.gds-name
    temp-t-post-stk-line.clients-grp-name  = ub.clients.grp-name
    temp-t-post-stk-line.clients-obj-name  = ub.clients.obj-name
    temp-t-post-stk-line.prod-cli-obj-name = prod-cli.obj-name
    temp-t-post-stk-line.prod-cli-obj-code = prod-cli.obj-code
    temp-t-post-stk-line.prod-cli-obj-type = prod-cli.obj-type
  .

            if xlavel > 0 then 
            do: 
                
                repeat i#i =1 to xlavel:
                    if i#i =1 then str   = entry(1,ub.goods.grp-name, {&delim-grp}) .
                    else 
                    do:
                        str2 = entry(i#i,ub.goods.grp-name, {&delim-grp}) no-error.
                        if not error-status:error  and str2 <> "":u then
                            str = str +  {&delim-grp} +  entry(i#i,ub.goods.grp-name, {&delim-grp}) no-error .
                    end.
                end.
                if str <> ? then 
                do:
                    temp-t-post-stk-line.goods-grp-name = str + {&delim-grp} .
                end.
            end.
                
            else  
            do : 
                temp-t-post-stk-line.goods-grp-name = ub.goods.grp-name.
            end.
                
        end.
 end.
end procedure. /* create-temp-t-post-stk-line */

/* $Workfile$ e n d */