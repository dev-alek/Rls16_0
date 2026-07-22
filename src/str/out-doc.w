&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-out-doc


/* Temp-Table and Buffer definitions                                    */
using ibs.th.gbl.storage.*.
using ibs.th.str.marking.sts.*.
using ibs.th.str.marking.handlers.*.

DEFINE BUFFER t-doc FOR trn-doc.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-out-doc
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка РН (заведение, редактирование)

Автор: Чернова Светлана Александровна
Дата создания: 10/05/06
Author: Svetlana Chernova
Creation date: 10/05/06

Корректируется UIB

иногда вставляется  вместо t-doc ub.trn-doc.discnt-type !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11


*/

define input         parameter parparentproc   as   handle                  no-undo.
define input-output  parameter pardoc-rec      as   recid                   no-undo.
define input         parameter pardoc-mode     as   character               no-undo.
define input         parameter parlist-mode    as   character               no-undo.
define input         parameter partype         as   character               no-undo.
define input         parameter parinternal     as   logical                 no-undo. /* при добавлении документа */
define input-output  parameter parnext-prev    as   logical                 no-undo.
define input         parameter parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define input         parameter paris-hold      as   logical                 no-undo.
define input-output  parameter line-rec        as   recid                   no-undo.
define input         parameter br-handle       as   handle                  no-undo.
define input         parameter bf-handle       as   handle                  no-undo.
define input         parameter parstat         as   character               no-undo.


define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Обработка РН (заведение, редактирование)":U .
{ gbl/objsrv.i }
define variable EDOParSec       as class     ibs.th.gbl.env.prmtrs.edo .
def    var      Marking     as class     mark no-undo .
{ cmp/vssrevis.i "substitute('&1|&2':u,parext-doc-type,paris-hold)" }
{ cmp/str-glbl.i  }
{ cmp/showinf.i   }
{ str/in-vatp.i def  }
{ str/get-pr.i  def  }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/doc-code.i }
{ str/trdcalib.i }
{ gbl/lineattr.i }
{ str/libbcrcn.i }
{ str/lib-calc.i }
/*{ str/prescan.i  }*/
{ str/lib-def.i  }
{ str/scr-neb.i  }
{ gbl/waitfram.i noprocess }
{ str/cntrcode.i }
{ str/attrlist.i }
{ ref/cgrplib.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i def }
{ str/getctxtp.i get }
{ cmp/gds-list.i tt-gds-list def  }
{ cmp/bb-list.i bb-list def " new shared " }
{ str/fact-bc.i }
{ str/lib-rvs.i }
{ str/out-ptrl.i  def all-line }
{ gbl/getsect.i  def }
{ str/cont-ms.i}
{ref/imagelist.i}
{ gbl/key-rec.i  }
{ibs/th/bge/egais/ab-egais.i 1 new shared}
{ str/marks.i         }
{ gbl/color.i }
{ gbl/color.i }

{ str/temp_upd.i }
{ utl/gtin.i }
{ str/utd-typemark.i }

&global-define is-fuel 1
&global-define is-lgas 2
&global-define is-lgas-corr 3
&global-define is-gds 0

&global-define store-type v-cntxt-obj-type
&global-define store-code v-cntxt-obj-code

&scop label-clmn_1-br-dtl   '*'
&scop sort-clmn_1-br-dtl    get-mark(BUFFER ub.gds-dtl)
&scop label-clmn_2-br-dtl   'П/П'
&scop sort-clmn_2-br-dtl    ub.doc-line.line-num
&scop label-clmn_3-br-dtl   'Бар-код'
&scop sort-clmn_3-br-dtl    ub.bar-code.b-code 
&scop label-clmn_4-br-dtl   'Артикул'
&scop sort-clmn_4-br-dtl    ub.gds-dtl.artic
&scop label-clmn_5-br-dtl   'Имя '
&scop sort-clmn_5-br-dtl    (if ub.gds-prt.node-name <> {&empty-scale} and ub.gds-prt.upper-code <> ub.goods.prt-root then ub.goods.gds-name + ' - ' + ub.gds-prt.f-name else ub.goods.gds-name)
&scop label-clmn_6-br-dtl   'По документу'
&scop sort-clmn_6-br-dtl    ub.gds-dtl.doc-qnty
&scop label-clmn_7-br-dtl   'Факт'
&scop sort-clmn_7-br-dtl    ub.gds-dtl.fact-qnty
&scop label-clmn_8-br-dtl   'Изм'
&scop sort-clmn_8-br-dtl    ub.goods.unit-base
&scop label-clmn_9-br-dtl   'Цена (вал.)'
&scop sort-clmn_9-br-dtl    ub.gds-dtl.price-base
&scop label-clmn_10-br-dtl   ''
&scop sort-clmn_10-br-dtl    ub.gds-dtl.ov
&scop label-clmn_11-br-dtl  'Сумма (вал.)'
&scop sort-clmn_11-br-dtl   (ub.gds-dtl.price-base * ub.gds-dtl.fact-qnty)
&scop label-clmn_12-br-dtl  'Скидка (вал.)'
&scop sort-clmn_12-br-dtl   (ub.gds-dtl.discnt-base * ub.gds-dtl.fact-qnty)
&scop label-clmn_13-br-dtl  'Итого (вал.).'
&scop sort-clmn_13-br-dtl   ((ub.gds-dtl.price-base - ub.gds-dtl.discnt-base) * ub.gds-dtl.fact-qnty)
&scop label-clmn_14-br-dtl  'Скидка %'
&scop sort-clmn_14-br-dtl   ub.gds-dtl.discnt-pc
&scop label-clmn_15-br-dtl  'Цена ({&abbr_rub}.)'
&scop sort-clmn_15-br-dtl   ub.gds-dtl.price-rubl
&scop label-clmn_16-br-dtl  'Сумма ({&abbr_rub}.)'
&scop sort-clmn_16-br-dtl   (ub.gds-dtl.price-rubl * ub.gds-dtl.fact-qnty)
&scop label-clmn_17-br-dtl  'Скидка ({&abbr_rub}.)'
&scop sort-clmn_17-br-dtl   (ub.gds-dtl.discnt-rubl * ub.gds-dtl.fact-qnty)
&scop label-clmn_18-br-dtl  'Итого ({&abbr_rub}.)'
&scop sort-clmn_18-br-dtl   ((ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl) * ub.gds-dtl.fact-qnty)
&scop label-clmn_19-br-dtl  'Признак'
&scop sort-clmn_19-br-dtl   (if ub.gds-prt.node-name = {&empty-scale} then '-' else if ub.gds-prt.upper-code = ub.goods.prt-root then '-------------------' else ub.gds-prt.f-name)
&scop label-clmn_20-br-dtl  'Факт, кг'
&scop sort-clmn_20-br-dtl   get-kg-fact-qnty(  buffer ub.gds-dtl )
&scop label-clmn_21-br-dtl  'Цена за кг (вал.)'
&scop sort-clmn_21-br-dtl   get-kg-sale-base(  buffer ub.gds-dtl )
&scop label-clmn_22-br-dtl  'Цена за кг ({&abbr_rub}.)'
&scop sort-clmn_22-br-dtl   get-kg-sale-rubl(  buffer ub.gds-dtl )
&scop label-clmn_23-br-dtl  'Итого, кг'
&scop sort-clmn_23-br-dtl   get-kg-after-qnty( buffer ub.gds-dtl )
&scop label-clmn_24-br-dtl  'ВСД'
&scop sort-clmn_24-br-dtl   get-vsdsts( buffer gds-dtl )
&scop label-clmn_25-br-dtl  'НДС'
&scop sort-clmn_25-br-dtl   ub.doc-line.vat-sum-rubl * ub.gds-dtl.fact-qnty / ub.doc-line.fact-qnty
&scop label-clmn_26-br-dtl  'НДС %'
&scop sort-clmn_26-br-dtl   ub.doc-line.vat-pc

define variable bar-str like ub.prod-bc.b-str  no-undo. /* строка для чтения бар-кода из файла       */
&undefine gds-list_i_def
{ cmp/gds-list.i gds-list def "new shared" }

define variable v-is-flora-ord as logical   no-undo initial false .

if lookup (parlist-mode , {&is-flor} + ","  + {&is-flor} + {&g___object} + ","  + {&is-flor} + {&status}   )  > 0 then do:
v-is-flora-ord = true .
end.

define buffer cli-buf    for ub.clients. /* чтоб не поломать покупателя */
define buffer t-d-b      for ub.trn-doc. /* при возврате */
define buffer old-line   for ub.doc-line.
define buffer d-l-b      for ub.doc-line.
define buffer l-doc-line for ub.doc-line. /* для поиска  */
define buffer gds-dtl    for ub.gds-dtl  .
define buffer reas_contract for ub.contract .
define buffer buf_contract-attr for ub.contract-attr .

{ cmp/titlmode.i }

define variable mark      as character                 no-undo.
define variable del-list  as character                 no-undo.
define variable ref-list  as character                 no-undo.
define variable chg-qnty  like ub.gds-dtl.doc-qnty init ? no-undo.
define variable add-sens  as log                       no-undo. /* активна ли кнопка добавить в документе : yes / no - вызов из документа*/
define variable b-c       as int                       no-undo. /* обрабатываемый бар-код                           */
define variable b-c-char  as character                 no-undo.
define variable rate      as dec                       no-undo. /* коэффициент для единиц из бар-кода        */
define variable ret-mode  as character                 no-undo. /*режим обработки бар-кода*/
define variable add-scan  as logical initial no        no-undo.
define variable work-mode as character                 no-undo.
define variable varhold   as character                 no-undo.
define variable varhold-type as character              no-undo.
define variable v-del                as logical   no-undo .
define variable v-add                as logical   no-undo .
define variable bcvalue   as character initial ?       no-undo.
define variable v-reasonm as logical   no-undo init false .
define variable v-reasonme as character no-undo .
define variable v-reasons-for-return as character no-undo .
define variable bctype         as character initial ? no-undo.
define variable prtvalue       as character initial ? no-undo.
define variable prttype        as character initial ? no-undo.
define variable v-is-pharm      as character no-undo .
define variable v-is-pharm-type as character no-undo .
define variable varartic       like ub.doc-line.artic      initial " " no-undo.
define variable is-petrolium   as logical   no-undo.
define variable is-pieces      as logical   no-undo.
define variable v-cond         as character no-undo init ?. /*режим вызова справочника товаров*/
define variable varr-b         as character no-undo.
define variable v-is-tsd       as character no-undo .
define variable v-is-tsd-type  as character no-undo .
define variable v-exist  as logical   no-undo .
define variable v-buket-gds-code as integer   no-undo .
define variable v-param as character no-undo .
define variable v-gds-name as character no-undo .
define variable parext-doc-mode as character no-undo.
define variable prev-pardoc-mode as character no-undo.
define variable varvalue as character no-undo.
define variable vartype  as character no-undo.
define variable is-contract-edo as logical no-undo init no .

define variable v-is-ptrl   as character no-undo.
define variable v-data-type as character no-undo.
define variable is-doc-hold as logical   no-undo.

define variable d-kg-price-rubl like ub.gds-dtl.price-rubl no-undo.
define variable d-kg-price-base like ub.gds-dtl.price-base no-undo.
define variable d-kg-fact-qnty  like ub.gds-dtl.fact-qnty  no-undo.
define variable d-kg-after-qnty like ub.gds-dtl.fact-qnty  no-undo.


define variable varlog         as logical   no-undo.
define variable gds-rec        as recid     no-undo.
define variable ref-rec        as recid     no-undo.
define variable prt-rec        as recid     no-undo.
define variable varline-mode   as character no-undo.
define variable varlns-cnt     as integer   no-undo.
define variable del-rec        as recid     no-undo.
define variable varprt-mode    as character no-undo.
define variable v-mercury-value as character no-undo .
define variable v-mercury-type  as character no-undo .
define variable vsdstrObj as class vsdtostorage no-undo.
define variable bcol as handle extent no-undo.
define variable hBrowse as handle no-undo.
define variable ii as integer no-undo.
define variable ch-vsd as character no-undo .
define variable trn-type as integer no-undo init 0.
define variable Tree                 as class     tree         no-undo .
define variable v-is-return          as logical   no-undo init no .
define variable varpart-rec          as   recid                      no-undo.
define variable vExist as logical no-undo.
define variable vOk    as logical no-undo.

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

/* Temp Table Definition */
function get-mark return character (buffer local-gds-dtl for ub.gds-dtl ).
   if lookup (string (recid (local-gds-dtl)), del-list) > 0  then return "*".
                                                             else return "".
end function.

function get-kg-sale-rubl returns decimal ( buffer local-gds-dtl for ub.gds-dtl ) :
  define variable d_out-kg-sale-price like ub.gds-dtl.price-rubl no-undo.

  run inv-line_price in this-procedure ( input recid( local-gds-dtl ), input yes, output d_out-kg-sale-price ) no-error.
  return ( if error-status :error then ? else d_out-kg-sale-price ).
end function. /* get-kg-sale-rubl */

function get-kg-sale-base returns decimal ( buffer local-gds-dtl for ub.gds-dtl ) :
  define variable d_out-kg-sale-price like ub.gds-dtl.price-rubl no-undo.

  run inv-line_price in this-procedure ( input recid( local-gds-dtl ), input  no, output d_out-kg-sale-price ) no-error.
  return ( if error-status :error then ? else d_out-kg-sale-price ).
end function. /* get-kg-sale-base */

function get-kg-fact-qnty returns decimal ( buffer local-gds-dtl for ub.gds-dtl ) :
  define variable d_out-qnty-kg like ub.gds-dtl.fact-qnty no-undo.

  run inv-line_qnty in this-procedure ( input recid( local-gds-dtl ),             output d_out-qnty-kg       ) no-error.
  return ( if error-status :error then ? else d_out-qnty-kg ).
end function. /* get-kg-fact-qnty */

function get-kg-after-qnty returns decimal ( buffer local-gds-dtl for ub.gds-dtl ) :
  define variable d_out-qnty-kg like ub.gds-dtl.fact-qnty no-undo.

  run after_qnty in this-procedure    ( input recid( local-gds-dtl ),             output d_out-qnty-kg       ) no-error.
  return ( if error-status :error then ? else d_out-qnty-kg ).
end function. /* get-kg-after-qnty */

FUNCTION get-vsdsts RETURNS CHARACTER
(buffer local-gds-dtl for ub.gds-dtl ):
  
  if parext-doc-type <> {&TDEDT_Pri_Perem}
  and not v-is-return
    then return "".
  
  def var v-mercury-prod as logical no-undo.
  def buffer bf_gds for ub.goods.
  
  find first bf_gds where 
        local-gds-dtl.artic = bf_gds.artic
    and local-gds-dtl.prod-type = bf_gds.prod-type
    and local-gds-dtl.prod-code = bf_gds.prod-code.
  
  if lookup(v-mercury-value, 'no':u) = 0
  then do:
    { gbl/gdscdat.i
      bf_gds.gds-code
      "'mercur_FGIS=request':u"
      v-mercury-prod
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Код товара" bf_gds.gds-code skip
        'mercur_FGIS=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-mercury-prod
    then do:
      vsdstrObj = new vsdtostorage ().
      if vsdstrObj:exsistvsd( buffer local-gds-dtl )
      then do:
        delete object vsdstrObj no-error.
        return "+".
      end.
      else do with frame {&FRAME-NAME}:
        delete object vsdstrObj no-error.
        return "-".
      end.
    end.
  end.

  return "".
  
end function.

define menu m-outs
    menu-item m-outs-1 label "Документы по объекту" accelerator "alt-1"
    menu-item m-outs-5 label "Заказы"               accelerator "alt-1"
    menu-item m-outs-2 label "Мобильный сканер"     accelerator "alt-2"
    menu-item m-outs-3 label "Остатки по списку товаров"    accelerator "alt-3"
    menu-item m-outs-6 label "Остатки по списку партий"     accelerator "alt-6"
    menu-item m-outs-4 label "Сброс"                accelerator "alt-4"
	menu-item m-outs-8 label "Импорт акцизных марок"                accelerator "alt-8"
    menu-item m-outs-9 label "УПД по объекту"                accelerator "alt-9"
    menu-item m-outs-10 label "Немаркированные остатки по списку товаров"                accelerator "alt-0"
.
DEFINE MENU m-marks 
  MENU-ITEM m_add-marks          LABEL "Добавить"      
/*  MENU-ITEM m_del-marks          LABEL "Удалить"*/
  MENU-ITEM m_lookup-marks       LABEL "Просмотр"      
  MENU-ITEM m_no-marks           LABEL "Немаркированная продукция"
.

define menu m-acc_price
    menu-item m-ap-1 label "без НДС"              accelerator "alt-1"
    menu-item m-ap-2 label "с НДС"                accelerator "alt-2"
    menu-item m-ap-3 label "без НДС (НДС 0 НП 0)" accelerator "alt-3"
.

define menu m-fixprice
    menu-item m-fp-1 label "Фиксировать цены"     accelerator "alt-1"
    menu-item m-fp-2 label "Расфиксировать цены"  accelerator "alt-2"
.

define menu m-print
    menu-item m-print-1   label "&Ценник"
    menu-item m-print-3   label "&Список кодов"
    .

define temp-table t-d-b-doc-line no-undo like lib-trn_ret-line.
define temp-table t-d-b-gds-dtl  no-undo like ub.gds-dtl.
define temp-table t-d-b-parts    no-undo like ub.parts.

/*define new shared temp-table tt-gds-for-return no-undo like ub.goods*/
/*  field qnty   as decimal                                           */
/*  field to-del as logical                                           */
/*  field order-num as integer                                        */
/*  field to-sel as logical                                           */
/*  index art  is primary unique artic prod-type prod-code            */
/*  index code is         unique gds-code                             */
/*  index oi order-num                                                */
/*  index isel to-sel                                                 */
/*.                                                                   */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-out-doc
&Scoped-define BROWSE-NAME br-dtl

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.doc-line ub.gds-dtl ub.gds-prt ub.goods ub.bar-code

/* Definitions for BROWSE br-dtl                                        */
&Scoped-define FIELDS-IN-QUERY-br-dtl {&sort-clmn_1-br-dtl} {&sort-clmn_2-br-dtl} {&sort-clmn_3-br-dtl} {&sort-clmn_4-br-dtl} {&sort-clmn_5-br-dtl} @ v-gds-name {&sort-clmn_6-br-dtl} {&sort-clmn_7-br-dtl} {&sort-clmn_8-br-dtl} {&sort-clmn_9-br-dtl} {&sort-clmn_10-br-dtl} {&sort-clmn_11-br-dtl} {&sort-clmn_12-br-dtl} {&sort-clmn_13-br-dtl} {&sort-clmn_14-br-dtl} {&sort-clmn_15-br-dtl} {&sort-clmn_16-br-dtl} {&sort-clmn_17-br-dtl} {&sort-clmn_18-br-dtl} {&sort-clmn_19-br-dtl} {&sort-clmn_20-br-dtl} @ d-kg-fact-qnty {&sort-clmn_21-br-dtl} @ d-kg-price-base {&sort-clmn_22-br-dtl} @ d-kg-price-rubl {&sort-clmn_23-br-dtl} @ d-kg-after-qnty {&sort-clmn_24-br-dtl} @ ch-vsd {&sort-clmn_25-br-dtl} @ vat-sum
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-dtl ub.gds-dtl.doc-qnty ub.gds-dtl.fact-qnty
&Scoped-define ENABLED-TABLES-IN-QUERY-br-dtl ub.gds-dtl
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-dtl ub.doc-line
&Scoped-define SELF-NAME br-dtl
&Scoped-define QUERY-STRING-br-dtl for each ub.doc-line where ~
       ub.doc-line.doc-code = t-doc.doc-code no-lock, ~
  each ub.gds-dtl where ~
       ub.gds-dtl.doc-code  = t-doc.doc-code ~
   and ub.gds-dtl.artic     = ub.doc-line.artic ~
   and ub.gds-dtl.prod-code = ub.doc-line.prod-code ~
   and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock, ~
  each ub.gds-prt where ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock, ~
  each ub.goods where ub.goods.artic = ub.gds-dtl.artic ~
   and ub.goods.prod-code = ub.gds-dtl.prod-code ~
   and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock, ~
  each ub.bar-code where ub.bar-code.gds-code = ub.goods.gds-code ~
   and ub.bar-code.node-code = ub.gds-dtl.prt-code ~
   and ub.bar-code.part-code = '' ~
   and ub.bar-code.in-code = '' ~
   and ub.bar-code.unit-cli = ub.goods.unit-base no-lock
&Scoped-define OPEN-QUERY-br-dtl open query br-dtl  ~
for each ub.doc-line where ~
       ub.doc-line.doc-code = t-doc.doc-code no-lock, ~
  each ub.gds-dtl where ~
       ub.gds-dtl.doc-code  = t-doc.doc-code ~
   and ub.gds-dtl.artic     = ub.doc-line.artic ~
   and ub.gds-dtl.prod-code = ub.doc-line.prod-code ~
   and ub.gds-dtl.prod-type = ub.doc-line.prod-type no-lock, ~
  each ub.gds-prt where ~
       ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock , ~
  each ub.goods where ~
       ub.goods.artic = ub.gds-dtl.artic ~
   and ub.goods.prod-code = ub.gds-dtl.prod-code ~
   and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock , ~
 each ub.bar-code no-lock where ~
      ub.bar-code.gds-code = ub.goods.gds-code ~
  and ub.bar-code.node-code = ub.gds-dtl.prt-code ~
  and ub.bar-code.part-code = '' ~
  and ub.bar-code.in-code = '' ~
  and ub.bar-code.unit-cli = ub.goods.unit-base


&Scoped-define TABLES-IN-QUERY-br-dtl ub.doc-line ub.gds-dtl ub.gds-prt ub.goods ub.bar-code
&Scoped-define FIRST-TABLE-IN-QUERY-br-dtl  ub.doc-line
&Scoped-define SECOND-TABLE-IN-QUERY-br-dtl ub.gds-dtl
&Scoped-define THIRD-TABLE-IN-QUERY-br-dtl  ub.gds-prt
&Scoped-define FOURTH-TABLE-IN-QUERY-br-dtl ub.goods
&Scoped-define FIFTH-TABLE-IN-QUERY-br-dtl  ub.bar-code


/* Definitions for DIALOG-BOX d-out-doc                                 */
&Scoped-define BUFFER-FIELDS-IN-QUERY-d-out-doc t-doc.print-rubl t-doc.discnt-type ~

&Scoped-define ENABLED-BUFFER-FIELDS-IN-QUERY-d-out-doc t-doc.print-rubl ~
 t-doc.discnt-type
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-out-doc ~
    ~{&OPEN-QUERY-br-dtl}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS t-doc.cli-code t-doc.cli-type ~
clients.obj-name t-doc.hold-obj-code t-doc.hold-obj-type t-doc.print-rubl ~
t-doc.doc-date t-doc.fact-date t-doc.shift-date t-doc.shift-name ~
t-doc.shift-num t-doc.d-card t-doc.discnt-pc t-doc.discnt-type ~
t-doc.out-code t-doc.base-rate t-doc.base-scale t-doc.tot-calc ~
t-doc.discnt-rubl t-doc.pay-code t-doc.wrkr t-doc.agnt t-doc.boss ~
t-doc.doc-qnty t-doc.fact-qnty ub.pay-type.obj-name t-doc.VAT-base ~
t-doc.VAT-rubl t-doc.tot-cli t-doc.reason-code
&Scoped-define ENABLED-TABLES t-doc ub.clients ub.pay-type
&Scoped-define FIRST-ENABLED-TABLE t-doc
&Scoped-define SECOND-ENABLED-TABLE ub.clients
&Scoped-define THIRD-ENABLED-TABLE ub.pay-type
&Scoped-Define ENABLED-OBJECTS b-exit rect-tot rect-prc b-cur b-arch ~
b-notes b-attr b-cnt b-fixprice b-re-price b-rsrv-doc-list b-dopinf ~
b-history b-help b-print b-prev b-next r-clients r-sht r-outs r-acc varpurch-chs ~
r-pay is-repay r-wrkr is-cons r-agnt is-storage is-oldcons r-boss r-reas ~
a-n-c loc-code loc-name loc-art varcontract-prn-code b-contr-lkp b-mark ~
b-add b-prt b-parts b-lkp b-chg b-del b-notes-line br-dtl sum-base ~
sum-rubl wrkr-name fact-base fact-rubl TEXT-RUBL agnt-name pay-rubl ~
boss-name rsn-name flora-PS
&Scoped-Define DISPLAYED-FIELDS t-doc.cli-code t-doc.cli-type ~
clients.obj-name t-doc.hold-obj-code t-doc.hold-obj-type t-doc.print-rubl ~
t-doc.doc-date t-doc.fact-date t-doc.shift-date t-doc.shift-name ~
t-doc.shift-num t-doc.d-card t-doc.discnt-pc t-doc.discnt-type ~
t-doc.out-code t-doc.base-rate t-doc.base-scale t-doc.tot-calc ~
t-doc.discnt-rubl t-doc.pay-code t-doc.wrkr t-doc.agnt t-doc.boss ~
t-doc.doc-qnty t-doc.fact-qnty ub.pay-type.obj-name t-doc.VAT-base ~
t-doc.VAT-rubl t-doc.tot-cli t-doc.reason-code
&Scoped-define DISPLAYED-TABLES t-doc ub.clients ub.pay-type
&Scoped-define FIRST-DISPLAYED-TABLE t-doc
&Scoped-define SECOND-DISPLAYED-TABLE ub.clients
&Scoped-define THIRD-DISPLAYED-TABLE ub.pay-type
&Scoped-Define DISPLAYED-OBJECTS varpurch-chs is-repay is-cons is-storage ~
is-oldcons a-n-c loc-code loc-name loc-art varcontract-prn-code sum-base ~
sum-rubl wrkr-name fact-base fact-rubl TEXT-RUBL agnt-name pay-rubl ~
boss-name rsn-name flora-PS

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-arch
     LABEL "Уч&ет":L
     SIZE 7 BY 1 TOOLTIP "Просмотр в учетных ценах".

DEFINE BUTTON b-attr
     LABEL "А&тр"
     SIZE 5 BY 1 TOOLTIP "Дополнительные атрибуты по документу".

DEFINE BUTTON b-bc
     LABEL "&БарКод":L
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-cnt
     LABEL "&ДогП":L
     SIZE 6 BY 1 TOOLTIP "Просмотр разбивки по договорам поставщиков".

DEFINE BUTTON b-contr-lkp
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Посмотреть договор".

DEFINE BUTTON b-cur
     LABEL "У&Цена"
     SIZE 7 BY 1 TOOLTIP "Простановка учетных цен".

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-dopinf
     LABEL "О заказе":L
     SIZE 9 BY 1 TOOLTIP "Дополнительная информация для заказа по наборам - нетоварным позицииям".

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход":L
     SIZE 8 BY 1.

DEFINE BUTTON b-fixprice
     LABEL "&ФиксЦ"
     SIZE 7 BY 1 TOOLTIP "Зафиксировать/расфикcировать цены".

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 2.5 BY 1.

DEFINE BUTTON b-print
     IMAGE-UP FILE "cmp/b-print.bmp":U
     LABEL "&Печать":L
     SIZE 3 BY 1.

DEFINE BUTTON b-history
     LABEL "&История"
     SIZE 3 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE 10 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1.

DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>":L
     SIZE 4 BY 1.

DEFINE IMAGE g-image
     /*FILENAME "adeicon/blank":U*/
     STRETCH-TO-FIT RETAIN-SHAPE
     SIZE 20.00 BY 5.
     
DEFINE BUTTON b-notes
     LABEL "При&мДок":L
     SIZE 8 BY 1.

DEFINE BUTTON b-notes-line
  LABEL "О наборе":L
  SIZE 10 BY 1 TOOLTIP "Дополнительная информация по набору - нетоварной позиции".

DEFINE BUTTON b-marks 
  LABEL "&Марки" 
  SIZE 10 BY 1.

DEFINE BUTTON b-parts
     LABEL "Па&ртии":L
     SIZE 10 BY 1.

DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<":L
     SIZE 4 BY 1.

DEFINE BUTTON b-prt
     LABEL "&Шкала":L
     SIZE 10 BY 1.

DEFINE BUTTON b-re-price
     LABEL "ПрсчЦены"
     SIZE 9 BY 1 TOOLTIP "Пересчитать цены по параметрам покупки".

DEFINE BUTTON b-revis DEFAULT
     LABEL "Сверки"
     SIZE 8 BY 1.

DEFINE BUTTON b-rsrv-doc-list
     LABEL "Резерв"
     SIZE 7 BY 1.

DEFINE BUTTON r-acc
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY 1.

DEFINE BUTTON r-agnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY 1.

DEFINE BUTTON r-boss
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY 1.

DEFINE BUTTON r-clients
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY 1.

DEFINE BUTTON r-outs
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY 1.

DEFINE BUTTON r-pay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY 1.

DEFINE BUTTON r-reas
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY 1 TOOLTIP "Основание(причина заведения документа)".

DEFINE BUTTON r-sht
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY 1.

DEFINE BUTTON r-wrkr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY 1.

DEFINE VARIABLE agnt-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 11 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE boss-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 11 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fact-base AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "К опл&."
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fact-rubl AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 20 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE flora-PS AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 98 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE loc-art AS CHARACTER FORMAT "x(16)"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 TOOLTIP "Начало артикула"
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE loc-code AS CHARACTER FORMAT "x(13)":U
     VIEW-AS FILL-IN
     SIZE 20 BY 1 TOOLTIP "Бар-код (весь)"
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE loc-name AS CHARACTER FORMAT "x(40)":U
     VIEW-AS FILL-IN
     SIZE 20 BY 1 TOOLTIP "Начало названия"
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE pay-rubl AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 20 BY .67 NO-UNDO.

DEFINE VARIABLE rsn-name AS CHARACTER FORMAT "x(60)":U
      VIEW-AS TEXT
     SIZE 45.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sum-base AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма"
      VIEW-AS TEXT
     SIZE 17 BY .67 NO-UNDO.

DEFINE VARIABLE sum-rubl AS DECIMAL FORMAT "->>,>>>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 20 BY .67 NO-UNDO.

DEFINE VARIABLE TEXT-RUBL AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 4.5 BY .79
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE varcontract-prn-code AS CHARACTER FORMAT "X(16)"
     LABEL "До&говор"
     VIEW-AS FILL-IN
     SIZE 15 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE wrkr-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 11 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE a-n-c AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&А", "art",
"&Н", "name",
"&К", "code"
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE varpurch-chs AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "&Все", 0,
"&Выборочно", 1
     SIZE 12 BY 1 NO-UNDO.

DEFINE RECTANGLE rect-prc
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 18 BY 5.

DEFINE RECTANGLE rect-tot
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 47 BY 5.

DEFINE VARIABLE edo-return    AS LOGICAL INITIAL no 
  LABEL "Возврат по ЭДО" 
  VIEW-AS TOGGLE-BOX
  SIZE 17 BY .67
  FGCOLOR 4 NO-UNDO.
  
DEFINE VARIABLE is-cons AS LOGICAL INITIAL no
     LABEL "консигнация"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE is-oldcons AS LOGICAL INITIAL no
     LABEL "ст. консигн."
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE is-repay AS LOGICAL INITIAL no
     LABEL "выкуп"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE is-storage AS LOGICAL INITIAL no
     LABEL "отв.хран."
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-dtl FOR
      ub.doc-line,
      ub.gds-dtl,
      ub.gds-prt,
      ub.goods,
      ub.bar-code SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-dtl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-dtl d-out-doc _FREEFORM
  QUERY br-dtl DISPLAY
  {&sort-clmn_1-br-dtl}                       column-label {&label-clmn_1-br-dtl}  format "x(1)"
  {&sort-clmn_2-br-dtl}                       column-label {&label-clmn_2-br-dtl}  format ">>>>>9"
  {&sort-clmn_3-br-dtl}                       column-label {&label-clmn_3-br-dtl}  format "99999999999" 
  {&sort-clmn_4-br-dtl}                       column-label {&label-clmn_4-br-dtl}
  {&sort-clmn_5-br-dtl}     @ v-gds-name      column-label {&label-clmn_5-br-dtl}  format "x(150)"
  {&sort-clmn_6-br-dtl}                       column-label {&label-clmn_6-br-dtl}  format ">>>,>>>,>>9.999"
  {&sort-clmn_7-br-dtl}                       column-label {&label-clmn_7-br-dtl}  format ">>>,>>>,>>9.999"
  {&sort-clmn_8-br-dtl}                       column-label {&label-clmn_8-br-dtl}  format "x(3)"
  {&sort-clmn_9-br-dtl}                       column-label {&label-clmn_9-br-dtl}
  {&sort-clmn_10-br-dtl}                      column-label {&label-clmn_10-br-dtl} format "+/-"
  {&sort-clmn_11-br-dtl}                      column-label {&label-clmn_11-br-dtl} format "->>,>>>,>>>,>>9.99"
  {&sort-clmn_12-br-dtl}                      column-label {&label-clmn_12-br-dtl} format "->>,>>>,>>>,>>9.99"
  {&sort-clmn_13-br-dtl}                      column-label {&label-clmn_13-br-dtl} format "->>,>>>,>>>,>>9.99"
  {&sort-clmn_14-br-dtl}                      column-label {&label-clmn_14-br-dtl} format "->>>9.99"
  {&sort-clmn_15-br-dtl}                      column-label {&label-clmn_15-br-dtl}
  {&sort-clmn_16-br-dtl}                      column-label {&label-clmn_16-br-dtl} format "->,>>>,>>>,>>>,>>9.99"
  {&sort-clmn_17-br-dtl}                      column-label {&label-clmn_17-br-dtl} format "->,>>>,>>>,>>>,>>9.99"
  {&sort-clmn_18-br-dtl}                      column-label {&label-clmn_18-br-dtl} format "->,>>>,>>>,>>>,>>9.99"
  {&sort-clmn_19-br-dtl}                      column-label {&label-clmn_19-br-dtl} format "x(30)"
  {&sort-clmn_20-br-dtl}    @ d-kg-fact-qnty  column-label {&label-clmn_20-br-dtl} format ">>>,>>>,>>9.999":U
  {&sort-clmn_21-br-dtl}    @ d-kg-price-base column-label {&label-clmn_21-br-dtl} format "->>,>>>,>>>,>>9.999":U
  {&sort-clmn_22-br-dtl}    @ d-kg-price-rubl column-label {&label-clmn_22-br-dtl} format "->,>>>,>>>,>>>,>>9.999":U
  {&sort-clmn_23-br-dtl}    @ d-kg-after-qnty column-label {&label-clmn_23-br-dtl} format "->,>>>,>>>,>>>,>>9.999":U
  {&sort-clmn_25-br-dtl}    @ Vat-sum         column-label {&label-clmn_25-br-dtl} format "->,>>>,>>>,>>>,>>9.999":U
  {&sort-clmn_26-br-dtl}                      column-label {&label-clmn_25-br-dtl} format "->>>,>>9.99999999":U
  enable ub.gds-dtl.doc-qnty ub.gds-dtl.fact-qnty
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 106.5 BY 8 ROW-HEIGHT-CHARS .6.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-out-doc
     b-exit AT ROW 1 COL 1
     b-cur AT ROW 1 COL 9
     b-arch AT ROW 1 COL 16
     b-notes AT ROW 1 COL 23
     b-attr AT ROW 1 COL 31
     b-cnt AT ROW 1 COL 36
     b-fixprice AT ROW 1 COL 42
     b-re-price AT ROW 1 COL 49
     b-rsrv-doc-list AT ROW 1 COL 58
     b-dopinf AT ROW 1 COL 65
     b-revis AT ROW 1 COL 74 WIDGET-ID 8
     b-history AT ROW 1 COL 94.5
     b-print AT ROW 1 COL 93
     b-help AT ROW 1 COL 97.5
     b-prev AT ROW 2 COL 1
     b-next AT ROW 2 COL 5
     t-doc.cli-code AT ROW 2 COL 20 COLON-ALIGNED
          LABEL "Контра&гент"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     t-doc.cli-type AT ROW 2 COL 30.25 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     r-clients AT ROW 2 COL 39.25
     ub.clients.obj-name AT ROW 2 COL 40 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 35 BY 1
          FGCOLOR 4
     t-doc.hold-obj-code AT ROW 2 COL 75.25 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     t-doc.hold-obj-type AT ROW 2 COL 85.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     t-doc.print-rubl AT ROW 2 COL 92
          VIEW-AS TOGGLE-BOX
          SIZE 8 BY 1 TOOLTIP "В какой валюте печатать"
          FGCOLOR 4 
     t-doc.doc-date AT ROW 3.04 COL 6.38 COLON-ALIGNED
          LABEL "&Дата"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
          FGCOLOR 4 
     t-doc.fact-date AT ROW 3.04 COL 21.38 COLON-ALIGNED
          LABEL "&Факт"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
          FGCOLOR 4 
     t-doc.shift-date AT ROW 3.04 COL 37.88 COLON-ALIGNED
          LABEL "&Смена"
          VIEW-AS FILL-IN
          SIZE 9 BY 1 TOOLTIP "Дата смены"
          FGCOLOR 4 
     t-doc.shift-name AT ROW 3.04 COL 49.88 COLON-ALIGNED
          LABEL "№"
          VIEW-AS FILL-IN
          SIZE 3 BY 1 TOOLTIP "Номер смены"
          FGCOLOR 4 
     t-doc.shift-num AT ROW 3.04 COL 56.88 COLON-ALIGNED
          LABEL "П"
          VIEW-AS FILL-IN
          SIZE 3 BY 1 TOOLTIP "Порядок смены"
          FGCOLOR 4
     r-sht AT ROW 3.04 COL 60.75
     t-doc.d-card AT ROW 3.04 COL 75.5 COLON-ALIGNED
          LABEL "Карта"
          VIEW-AS FILL-IN 
          SIZE 23 BY 1 TOOLTIP "Дисконтная карта"
     t-doc.discnt-pc AT ROW 4.04 COL 75.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          FGCOLOR 4
     t-doc.discnt-type AT ROW 4.04 COL 85.5 COLON-ALIGNED NO-LABEL FORMAT "X(12)"
          VIEW-AS COMBO-BOX INNER-LINES 6
          LIST-ITEMS "процент","карта","группа","сумма","строка","прайс-лист"
          DROP-DOWN-LIST
          SIZE 13 BY 1
     t-doc.out-code AT ROW 4.5 COL 6.5 COLON-ALIGNED
          LABEL "Ист-&к"
          VIEW-AS FILL-IN
          SIZE 15 BY 1 TOOLTIP "Источник"
     r-outs AT ROW 4.5 COL 23.5
     t-doc.base-rate AT ROW 5.88 COL 6.75 COLON-ALIGNED
          LABEL "Кур&с"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          FGCOLOR 4 
     t-doc.base-scale AT ROW 5.88 COL 23.38 COLON-ALIGNED
          LABEL "М-&б"
          VIEW-AS FILL-IN
          SIZE 4 BY 1 TOOLTIP "Масштаб"
          FGCOLOR 4 
     r-acc AT ROW 5.88 COL 29.75
     t-doc.tot-calc AT ROW 6.46 COL 47.13 COLON-ALIGNED
          LABEL "Скидка"
          VIEW-AS FILL-IN
          SIZE 17 BY 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE .

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME d-out-doc
     t-doc.discnt-rubl AT ROW 6.46 COL 64.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     varpurch-chs AT ROW 6.5 COL 89 NO-LABEL
     t-doc.pay-code AT ROW 6.88 COL 6.75 COLON-ALIGNED
          LABEL "&Опл"
          VIEW-AS FILL-IN
          SIZE 6 BY 1 TOOLTIP "Оплата"
     r-pay AT ROW 6.88 COL 29.75
     is-repay AT ROW 7.63 COL 89
     t-doc.wrkr AT ROW 8.13 COL 6.88 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
     r-wrkr AT ROW 8.13 COL 29.88
     is-cons AT ROW 8.29 COL 89
     is-storage AT ROW 9.04 COL 89
     t-doc.agnt AT ROW 9.13 COL 6.88 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
     r-agnt AT ROW 9.13 COL 29.88
     is-storage AT ROW 8.96 COL 89
     is-oldcons AT ROW 9.67 COL 89
     t-doc.boss AT ROW 10.13 COL 5.63 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     r-boss AT ROW 10.13 COL 29.88
     varcontract-prn-code AT ROW 11.5 COL 12 COLON-ALIGNED WIDGET-ID 4
     b-contr-lkp AT ROW 11.5 COL 29 WIDGET-ID 2
     r-reas AT ROW 12.75 COL 17.5
     edo-return at row 12.75 col 70
     a-n-c AT ROW 13.75 COL 2 NO-LABEL
     loc-art AT ROW 13.75 COL 12 COLON-ALIGNED NO-LABEL
     loc-code AT ROW 13.75 COL 12.13 COLON-ALIGNED NO-LABEL
     loc-name AT ROW 13.75 COL 12.13 COLON-ALIGNED NO-LABEL
     b-mark AT ROW 15 COL 1
     b-add AT ROW 15 COL 4
     b-bc AT ROW 15 COL 14
     b-prt AT ROW 15 COL 24
     b-parts AT ROW 15 COL 34
     b-lkp AT ROW 15 COL 44
     b-chg AT ROW 15 COL 54
     b-del AT ROW 15 COL 64
     b-notes-line AT ROW 15 COL 74
     br-dtl AT ROW 16 COL 1
     sum-base AT ROW 5.75 COL 47.5 COLON-ALIGNED
     sum-rubl AT ROW 5.75 COL 65 COLON-ALIGNED NO-LABEL
     pay-type.obj-name AT ROW 6.88 COL 13.13 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT 
          SIZE 15 BY 1
          FGCOLOR 4 
     t-doc.VAT-base AT ROW 7.5 COL 47.5 COLON-ALIGNED
           VIEW-AS TEXT 
          SIZE 17 BY .67
     t-doc.VAT-rubl AT ROW 7.5 COL 65 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT 
          SIZE 20 BY .67
     wrkr-name AT ROW 8.13 COL 17.25 COLON-ALIGNED NO-LABEL
     fact-base AT ROW 8.13 COL 47.5 COLON-ALIGNED
     fact-rubl AT ROW 8.13 COL 65 COLON-ALIGNED NO-LABEL
     TEXT-RUBL AT ROW 8.79 COL 65.5 COLON-ALIGNED NO-LABEL
     agnt-name AT ROW 9.13 COL 17.25 COLON-ALIGNED NO-LABEL
     t-doc.tot-cli AT ROW 9.58 COL 47.5 COLON-ALIGNED
          LABEL "Счет"
           VIEW-AS TEXT
          SIZE 17 BY .67
     pay-rubl AT ROW 9.58 COL 65.13 COLON-ALIGNED NO-LABEL
     boss-name AT ROW 10.13 COL 17.25 COLON-ALIGNED NO-LABEL
     b-marks AT ROW 15 COL 84 WIDGET-ID 10
     t-doc.reason-code AT ROW 12.75 COL 12 COLON-ALIGNED
          LABEL "Основание" FORMAT ">>>>"
           VIEW-AS TEXT
          SIZE 3.38 BY .67
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE .

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME d-out-doc
     rsn-name AT ROW 12.83 COL 19 COLON-ALIGNED NO-LABEL
     flora-PS AT ROW 24.75 COL 1.5 NO-LABEL
     "Тип приобретения" VIEW-AS TEXT
          SIZE 16 BY .67 AT ROW 5.75 COL 88.63
          FGCOLOR 4 
     "Баз.в." VIEW-AS TEXT
          SIZE 6.5 BY .79 AT ROW 8.79 COL 51
          BGCOLOR 3 FGCOLOR 15 
     rect-tot AT ROW 5.5 COL 41
     rect-prc AT ROW 5.5 COL 88
     g-image AT ROW 10.75 COL 87.25
     SPACE(0.49) SKIP(10.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "<insert dialog title>".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: t-doc B "?" NO-UNDO ub ub.trn-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-out-doc
   NOT-VISIBLE FRAME-NAME                                               */
/* BROWSE-TAB br-dtl b-notes-line d-out-doc */
ASSIGN
 FRAME d-out-doc:SCROLLABLE = FALSE
 FRAME d-out-doc:HIDDEN     = TRUE
 FRAME d-out-doc:SENSITIVE  = FALSE.

ASSIGN 
 b-marks:POPUP-MENU IN FRAME d-out-doc = MENU m-marks:HANDLE.
 
ASSIGN 
 b-marks:MENU-MOUSE = 1.
/* SETTINGS FOR BUTTON b-revis IN FRAME d-out-doc
   NO-ENABLE                                                            */
ASSIGN
       b-revis:HIDDEN IN FRAME d-out-doc           = TRUE.

/* SETTINGS FOR FILL-IN t-doc.base-rate IN FRAME d-out-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.base-scale IN FRAME d-out-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.cli-code IN FRAME d-out-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.d-card IN FRAME d-out-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.doc-date IN FRAME d-out-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.doc-qnty IN FRAME d-out-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.fact-date IN FRAME d-out-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.fact-qnty IN FRAME d-out-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN flora-PS IN FRAME d-out-doc
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN t-doc.out-code IN FRAME d-out-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.pay-code IN FRAME d-out-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.reason-code IN FRAME d-out-doc
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN t-doc.shift-date IN FRAME d-out-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.shift-name IN FRAME d-out-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.shift-num IN FRAME d-out-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.tot-calc IN FRAME d-out-doc
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN t-doc.tot-cli IN FRAME d-out-doc
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-dtl
/* Query rebuild information for BROWSE br-dtl
     _START_FREEFORM
open query br-dtl
  for each ub.gds-dtl where ub.gds-dtl.doc-code = t-doc.doc-code no-lock,
          each ub.gds-prt where ub.gds-prt.node-code = ub.gds-dtl.prt-code no-lock,
          each ub.goods where ub.goods.artic = ub.gds-dtl.artic
                                     and ub.goods.prod-code = ub.gds-dtl.prod-code
                                     and ub.goods.prod-type = ub.gds-dtl.prod-type no-lock,
          each ub.bar-code where ub.bar-code.gds-code = ub.goods.gds-code
                          and ub.bar-code.node-code = ub.gds-dtl.prt-code
                          and ub.bar-code.part-code = ''
                          and ub.bar-code.in-code = ''
                          and ub.bar-code.unit-cli = ub.goods.unit-base no-lock
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-dtl */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-out-doc
/* Query rebuild information for DIALOG-BOX d-out-doc
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-out-doc */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME g-image
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL g-image d-out-doc
ON MOUSE-SELECT-DBLCLICK OF g-image IN FRAME d-out-doc
DO:
  RUN ref/imagelist.w (PARPARENTPROC, "":U, ub.goods.gds-code,{&lookup}).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
&Scoped-define SELF-NAME d-out-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-out-doc d-out-doc
ON WINDOW-CLOSE OF FRAME d-out-doc /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-out-doc
ON CHOOSE OF b-add IN FRAME d-out-doc /* Добавить */
DO:
run local-add in this-procedure no-error.
if error-status :error then do:
  message "Ошибка при добавлении." skip
          return-value
  view-as alert-box error.
  return no-apply.
end.
run ui-on ("enable":u).
apply "entry" to b-add in frame {&frame-name}.

END.

on choose of menu-item m-print-1 in menu m-print do:
  {&stdbtn}
  if not available t-doc then return .
  define variable v-user-action       as character    no-undo.
  define variable v-printed           as logical      no-undo.
  run rep/tick-doc.p (parparentproc , recid(t-doc), 'trn' , 1 , no, no ) .
end.

on choose of menu-item m-print-3 in menu m-print do:
  {&stdbtn}
  if not available t-doc then return .
  define variable v-user-action       as character    no-undo.
  define variable v-printed           as logical      no-undo.
  run rep/mbb-doc.p (parparentproc , recid(t-doc), 'trn'  ) no-error .
  if error-status :error then message
    error-status :get-message(1) skip
    return-value skip
    "Вывод в список кодов"
    view-as alert-box error
  .
end.



/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_add-marks
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_add-marks d-out-doc
ON CHOOSE OF MENU-ITEM m_add-marks /* Добавить марки */
  DO:
    define buffer buf_marking-lines for ub.marking-lines .
    define buffer pri_marking-lines for ub.marking-lines .
    define buffer buf_marking       for ub.marking .
    define buffer buf_goods         for ub.goods .
    define buffer buf_doc-line      for ub.doc-line .
    define buffer buf_gds-dtl       for ub.gds-dtl .
    define buffer buf_parts         for ub.parts .
    define buffer bf_parts          for ub.parts .
    define buffer cpl_gds-dtl       for ub.gds-dtl .
    define buffer pri_trn-doc       for ub.trn-doc .
    define variable mark       as character no-undo .
    define variable ii         as integer   no-undo .
    define variable jj         as integer   no-undo .
    define variable v-GTIN     as character no-undo .
    define variable v-gds-code as integer   no-undo . 
    define variable ungroup    as logical   no-undo .
    define variable v-message  as character no-undo .
    define variable vIsExemplarGoods as logical no-undo .
    define variable varvalue        as character no-undo .
    define variable vartype         as character no-undo .
    define variable v-mark-weight as decimal no-undo .
    define variable v-isweighed as logical no-undo .
    define variable v-recid as recid no-undo .
    
    if lookup( string(t-doc.reason-code), v-reasons-for-return) > 0
    and t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
    and not v-is-return
    then do :
      if t-doc.out-code = ?
      or t-doc.out-code = ""
      or not can-find(pri_trn-doc no-lock where pri_trn-doc.doc-code = t-doc.out-code)
      then do :
        message "Сначала выберите корректный источник (ПН)" view-as alert-box .
        return no-apply.
      end.
    end .
    v-add = yes .
    
    if not avail ub.goods then
    do:
      message "Сначала добавьте товар в документ" view-as alert-box .
      return no-apply.
    end.
    
    v-recid = recid (ub.doc-line) .
    
    v-isweighed = WghProdVariable(t-doc.obj-type, t-doc.obj-code, ub.goods.gds-code) .
        
    run isExemplarGoods in this-procedure 
       (t-doc.obj-type, t-doc.obj-code, ub.goods.gds-code, output vIsExemplarGoods).
       
    if not vIsExemplarGoods /* not isExemplarType(ub.goods.gds-code) */
    and not v-isweighed
    then do:
      message "Для выбранного товара в документе не требуется ввод марок." skip
              "Выполняется ручное добавление товара и ввод количества." view-as alert-box .
      return no-apply.
    end.

    do while v-add:
    
    run str/chs-alcmarks.w (
      input parparentproc,
      input t-doc.doc-code,
      input {&add-def},
      input ub.goods.gds-code,
      input "",
      output mark) no-error.
    if error-status :error or mark = "" or mark = ? then 
    do: 
      return no-apply. 
    end.
    v-message = "" .
    /*Добавление марок не алкогольных*/
    find first marking where marking.mark begins mark
      no-lock no-error  .

    if available marking then
    do:
        find first buf_goods no-lock where recid(buf_goods) = recid(ub.goods) no-error .
        find first buf_doc-line exclusive-lock where buf_doc-line.doc-code = t-doc.doc-code
          and buf_doc-line.artic = buf_goods.artic and buf_doc-line.prod-code = buf_goods.prod-code
          and buf_doc-line.prod-type = buf_goods.prod-type no-error .
        if not available (buf_doc-line) then
        do:
        find first buf_marking-lines exclusive-lock where buf_marking-lines.out-code = {&free-code} and
          buf_marking-lines.gds-code = buf_goods.gds-code and buf_marking-lines.obj-code = t-doc.obj-code and buf_marking-lines.obj-type = t-doc.obj-type
          and buf_marking-lines.mark begins mark no-error .
        if available (buf_marking-lines) then
        do:
          /*разблокировка товара*/
          if buf_marking-lines.doc-level > 1 then
          do:
              if tree:UnGroupDoc(buf_marking-lines.mark, buf_marking-lines.in-code, buf_marking-lines.out-code, buf_marking-lines.obj-code, buf_marking-lines.obj-type) then
              do:
            end.
          end.
        end.
          if lookup( string(t-doc.reason-code), v-reasons-for-return) > 0
          and t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
          then do :
            if not can-find (pri_marking-lines no-lock where pri_marking-lines.out-code = t-doc.out-code
                                                         and pri_marking-lines.mark begins mark)
            then do :
              message "Марка " mark " не найдена в документе-источнике (" t-doc.out-code ")" view-as alert-box .
              return no-apply.
            end .                                             
            run str/out-add.p (parparentproc,
              recid(t-doc),
              ?,
              ?,
              recid(buf_goods),
              {&add-def} + {&delim-par} + "return",
              'scan-marks' + {&delim-key} + mark) no-error.
          end .
          else do :
            run str/out-add.p (parparentproc,
              recid(t-doc),
              ?,
              ?,
              recid(buf_goods),
              {&add-def},
              'scan-marks' + {&delim-key} + mark) no-error.
          end .

        /*          /*Добавляем товар в накладную*/                                                                                                                                                               */

        end.
        else 
        do:
        find first buf_marking-lines exclusive-lock where buf_marking-lines.out-code = {&free-code} and 
          buf_marking-lines.gds-code = buf_goods.gds-code and buf_marking-lines.obj-code = buf_doc-line.obj-code and buf_marking-lines.obj-type = buf_doc-line.obj-type 
          and buf_marking-lines.mark begins mark no-error .
        if available (buf_marking-lines) then 
        do:
          /*разблокировка товара*/
          if buf_marking-lines.doc-level > 1 then 
          do:
              if tree:UnGroupDoc(buf_marking-lines.mark, buf_marking-lines.in-code, buf_marking-lines.out-code, buf_marking-lines.obj-code, buf_marking-lines.obj-type) then 
              do:
            end.  
          end.   
       end.
       else do:
         v-message = "У марки нет свободной зоны" .
       end.  
          /*Увеличеваем кол-во товара в накладной*/
        find first cpl_gds-dtl exclusive-lock where cpl_gds-dtl.doc-code = buf_doc-line.doc-code
          and cpl_gds-dtl.artic = buf_doc-line.artic and buf_doc-line.prod-code = cpl_gds-dtl.prod-code
          and buf_doc-line.prod-type = cpl_gds-dtl.prod-type no-error.
 
          if lookup( string(t-doc.reason-code), v-reasons-for-return) > 0
          and t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
          then do :
            run str/out-add.p
              ( input parparentproc
              ,input recid(t-doc)
              ,input recid(buf_doc-line)
              ,input recid(cpl_gds-dtl)
              ,input recid (buf_goods)
              ,input {&update} + {&delim-par} + "return"
              ,input 'scan-marks' + {&delim-key} + mark)
              no-error.
          end .
          else do :
            run str/out-add.p
              ( input parparentproc
              ,input recid(t-doc)
              ,input recid(buf_doc-line)
              ,input recid(cpl_gds-dtl)
              ,input recid (buf_goods)
              ,input {&update}
              ,input 'scan-marks' + {&delim-key} + mark)
              no-error.
          end .

        end. 
    end.

    run ui-on in this-procedure ( input "line" ).
    reposition br-dtl to recid v-recid no-error.

    end.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/*&Scoped-define SELF-NAME m_del-marks                                                                                                                                            */
/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_del-marks d-out-doc                                                                                                                 */
/*ON CHOOSE OF MENU-ITEM m_del-marks /* Удаление */                                                                                                                               */
/*  DO:                                                                                                                                                                           */
/*    define buffer buf_marking-lines for ub.marking-lines .                                                                                                                      */
/*    define buffer bf_marking-lines  for ub.marking-lines .                                                                                                                      */
/*    define buffer buf_marking       for ub.marking .                                                                                                                            */
/*    define buffer buf_goods         for ub.goods .                                                                                                                              */
/*    define buffer buf_doc-line      for ub.doc-line .                                                                                                                           */
/*    define buffer buf_gds-dtl       for ub.gds-dtl .                                                                                                                            */
/*    define buffer buf_parts         for ub.parts .                                                                                                                              */
/*    define buffer buf_gds-obj       for ub.gds-obj .                                                                                                                            */
/*    define variable ii   as integer   no-undo .                                                                                                                                 */
/*    define variable jj   as integer   no-undo .                                                                                                                                 */
/*    define variable mark as character no-undo .                                                                                                                                 */
/*    define buffer buf_gds-prt for ub.gds-prt .                                                                                                                                  */
/*    define variable v-qnty      as decimal   no-undo .                                                                                                                          */
/*    define variable v-parts     as character no-undo .                                                                                                                          */
/*    define variable gds-rec     as recid     no-undo .                                                                                                                          */
/*    define variable v-gds-code  as integer   no-undo .                                                                                                                          */
/*    define variable v-host-code like sysconf.host-code no-undo.                                                                                                                 */
/*    define variable v-tax-date  as date      no-undo.                                                                                                                           */
/*    define variable v-vat-pc    like ub.doc-line.vat-pc no-undo.                                                                                                                */
/*    define variable v-slt-pc    like ub.doc-line.slt-pc no-undo.                                                                                                                */
/*    define variable ungroup     as logical   no-undo .                                                                                                                          */
/*    define variable v-message   as character no-undo .                                                                                                                          */
/*    define variable chg-qnty    as integer   no-undo .                                                                                                                          */
/*    define variable v-GTIN      as character no-undo .                                                                                                                          */
/*    define variable v-qnty-doc  as decimal   no-undo .                                                                                                                          */
/*    define variable v-qnty-fact as decimal   no-undo .                                                                                                                          */
/*    define variable v-in-code   as character no-undo .                                                                                                                          */
/*    define buffer bf_parts    for ub.parts .                                                                                                                                    */
/*    define buffer cpl_gds-prt for ub.gds-prt.                                                                                                                                   */
/*    define buffer cpl_prt-obj for ub.prt-obj.                                                                                                                                   */
/*    define variable v-sts as integer no-undo .                                                                                                                                  */
/*                                                                                                                                                                                */
/*v-del = yes .                                                                                                                                                                   */
/*do while v-del:                                                                                                                                                                 */
/*    if available (t-doc) then                                                                                                                                                   */
/*    do:                                                                                                                                                                         */
/*                                                                                                                                                                                */
/*      if not avail ub.goods then                                                                                                                                                */
/*      do:                                                                                                                                                                       */
/*        return no-apply.                                                                                                                                                        */
/*      end.                                                                                                                                                                      */
/*      if not isExemplarType(ub.goods.gds-code) then                                                                                                                             */
/*      do:                                                                                                                                                                       */
/*        message "Для выбранного товара в документе не требуется ввод марок." skip                                                                                               */
/*                "Выполняется ручное изменение количества товара." view-as alert-box .                                                                                           */
/*        return no-apply.                                                                                                                                                        */
/*      end.                                                                                                                                                                      */
/*                                                                                                                                                                                */
/*      run str/chs-alcmarks.w (                                                                                                                                                  */
/*        input parparentproc,                                                                                                                                                    */
/*        input t-doc.doc-code,                                                                                                                                                   */
/*        input {&update},                                                                                                                                                        */
/*        input v-message,                                                                                                                                                        */
/*        output mark) no-error.                                                                                                                                                  */
/*      if error-status :error or mark = "" or mark = ? then                                                                                                                      */
/*      do:                                                                                                                                                                       */
/*        return no-apply.                                                                                                                                                        */
/*      end.                                                                                                                                                                      */
/*      v-message = "" .                                                                                                                                                          */
/*                                                                                                                                                                                */
/*      find first marking where marking.mark begins mark                                                                                                                         */
/*        exclusive-lock no-error.                                                                                                                                                */
/*      if not available (marking) then do:                                                                                                                                       */
/*        v-message = "Марка не найдена" .                                                                                                                                        */
/*      end.                                                                                                                                                                      */
/*      v-gds-code = marking.gds-code .                                                                                                                                           */
/*                                                                                                                                                                                */
/*      find first buf_goods no-lock where buf_goods.gds-code = v-gds-code no-error .                                                                                             */
/*      if available (buf_goods) then                                                                                                                                             */
/*      do:                                                                                                                                                                       */
/*                                                                                                                                                                                */
/*        if t-doc.ext-doc-type = {&TDEDT_Pri_Perem} then v-sts = objSrv:Env:Marking:Sts:Mark:PendingVerification:KeyIntDB .                                                      */
/*        else v-sts = 99 .                                                                                                                                                       */
/*                                                                                                                                                                                */
/*                                                                                                                                                                                */
/*          find first buf_marking-lines exclusive-lock where buf_marking-lines.out-code = t-doc.doc-code                                                                         */
/*                                                        and buf_marking-lines.gds-code = buf_goods.gds-code                                                                     */
/*                                                        and buf_marking-lines.obj-code = t-doc.obj-code                                                                         */
/*                                                        and buf_marking-lines.obj-type = t-doc.obj-type                                                                         */
/*                                                        and buf_marking-lines.mark begins mark no-error .                                                                       */
/*          if available (buf_marking-lines) then                                                                                                                                 */
/*          do:                                                                                                                                                                   */
/*            if buf_marking-lines.doc-level = 1 then do:                                                                                                                         */
/*            if tree:LevelDownDoc(buf_marking-lines.mark, buf_marking-lines.obj-code, buf_marking-lines.obj-type, buf_marking-lines.in-code, buf_marking-lines.out-code) then    */
/*            do:                                                                                                                                                                 */
/*              tree:StatusDownDoc(buf_marking-lines.mark, buf_marking-lines.obj-code, buf_marking-lines.obj-type, buf_marking-lines.in-code, buf_marking-lines.out-code, v-sts) .*/
/*            end.                                                                                                                                                                */
/*            buf_marking-lines.sts = v-sts .                                                                                                                                     */
/*                                                                                                                                                                                */
/*            end.                                                                                                                                                                */
/*            else do:                                                                                                                                                            */
/*              v-message = "Марка входит в состав упаковки, просканируйте марку упаковки" .                                                                                      */
/*            end.                                                                                                                                                                */
/*          end.                                                                                                                                                                  */
/*          else                                                                                                                                                                  */
/*          do:                                                                                                                                                                   */
/*            v-message = "Марка " + mark + " отсутствует в документе" .                                                                                                          */
/*          end.                                                                                                                                                                  */
/*      end.                                                                                                                                                                      */
/*      else                                                                                                                                                                      */
/*      do:                                                                                                                                                                       */
/*        v-message = "Товар не найден" .                                                                                                                                         */
/*      end.                                                                                                                                                                      */
/*                                                                                                                                                                                */
/*                                                                                                                                                                                */
/*      if t-doc.ext-doc-type = {&TDEDT_Pri_Perem} and pardoc-mode <> {&lookup} then                                                                                              */
/*      do:                                                                                                                                                                       */
/*    ii = 0 .                                                                                                                                                                    */
/*                                                                                                                                                                                */
/*        for each buf_doc-line exclusive-lock where buf_doc-line.doc-code = t-doc.doc-code,                                                                                      */
/*          first buf_gds-dtl exclusive-lock where buf_gds-dtl.doc-code = buf_doc-line.doc-code and                                                                               */
/*                                                 buf_gds-dtl.artic = buf_doc-line.artic and                                                                                     */
/*                                                 buf_gds-dtl.prod-code = buf_doc-line.prod-code and                                                                             */
/*                                                 buf_gds-dtl.prod-type = buf_doc-line.prod-type:                                                                                */
/*          jj = 0 .                                                                                                                                                              */
/*                                                                                                                                                                                */
/*          find first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic and                                                                                           */
/*                                             buf_goods.prod-code = buf_doc-line.prod-code and                                                                                   */
/*                                             buf_goods.prod-type = buf_doc-line.prod-type no-error .                                                                            */
/*                                                                                                                                                                                */
/*          for each buf_marking-lines exclusive-lock where buf_marking-lines.obj-code = buf_doc-line.obj-code and                                                                */
/*                                                          buf_marking-lines.obj-type = buf_doc-line.obj-type and                                                                */
/*                                                          buf_marking-lines.out-code = buf_doc-line.doc-code and                                                                */
/*                                                          buf_marking-lines.gds-code = buf_goods.gds-code,                                                                      */
/*            first buf_marking no-lock where buf_marking.mark = buf_marking-lines.mark and                                                                                       */
/*                                            buf_marking.obj-code = buf_marking-lines.obj-code and                                                                               */
/*                                            buf_marking.obj-type = buf_marking-lines.obj-type and buf_marking.unit-ext = "UNIT":                                                */
/*          if buf_marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB then do:                                                                                     */
/*          jj = jj + 1 .                                                                                                                                                         */
/*          ii = ii + 1 .                                                                                                                                                         */
/*          end.                                                                                                                                                                  */
/*          buf_doc-line.fact-qnty = jj .                                                                                                                                         */
/*          buf_gds-dtl.fact-qnty = buf_doc-line.fact-qnty .                                                                                                                      */
/*          for first buf_parts exclusive-lock where buf_parts.out-code = buf_marking-lines.out-code and                                                                          */
/*                                                   buf_parts.artic = buf_doc-line.artic and                                                                                     */
/*                                                   buf_parts.prod-code = buf_doc-line.prod-code and                                                                             */
/*                                                   buf_parts.prod-type = buf_doc-line.prod-type and                                                                             */
/*                                                   buf_parts.obj-code = buf_marking-lines.obj-code and                                                                          */
/*                                                   buf_parts.obj-type = buf_marking-lines.obj-type and                                                                          */
/*                                                   buf_parts.part-code = buf_marking-lines.part-code and                                                                        */
/*                                                   buf_parts.in-code = buf_marking-lines.in-code and                                                                            */
/*                                                   buf_parts.prt-code = buf_marking-lines.prt-code:                                                                             */
/*            buf_parts.fact-qnty = buf_doc-line.fact-qnty .                                                                                                                      */
/*          end.                                                                                                                                                                  */
/*                                                                                                                                                                                */
/*          end.                                                                                                                                                                  */
/*                                                                                                                                                                                */
/*        t-doc.fact-qnty = ii .                                                                                                                                                  */
/*        end.                                                                                                                                                                    */
/*                                                                                                                                                                                */
/*      end.                                                                                                                                                                      */
/*      else                                                                                                                                                                      */
/*      do:                                                                                                                                                                       */
/*                                                                                                                                                                                */
/*        v-qnty = 0 .                                                                                                                                                            */
/*        jj = 0 .                                                                                                                                                                */
/*        find first bf_marking-lines where bf_marking-lines.obj-code = t-doc.obj-code                                                                                            */
/*                                      and bf_marking-lines.obj-type = t-doc.obj-type                                                                                            */
/*                                      and bf_marking-lines.out-code = t-doc.doc-code                                                                                            */
/*                                      and bf_marking-lines.sts <> 99                                                                                                            */
/*                                      and bf_marking-lines.gds-code = v-gds-code no-error .                                                                                     */
/*        if available (bf_marking-lines) then                                                                                                                                    */
/*        do:                                                                                                                                                                     */
/*          v-in-code = bf_marking-lines.in-code .                                                                                                                                */
/*                  for each buf_marking-lines exclusive-lock where buf_marking-lines.out-code = bf_marking-lines.out-code                                                        */
/*                                                     and buf_marking-lines.obj-code = bf_marking-lines.obj-code                                                                 */
/*                                                     and buf_marking-lines.obj-type = bf_marking-lines.obj-type                                                                 */
/*/*                                                     and buf_marking-lines.sts = 99*/                                                                                         */
/*                                                     and buf_marking-lines.gds-code = bf_marking-lines.gds-code:                                                                */
/*                                                                                                                                                                                */
/*          if  v-in-code <> buf_marking-lines.in-code then do:                                                                                                                   */
/*            message "Удаление марок по товару не возможно. Удалите полностью товар и просканируйте марки"                                                                       */
/*            view-as alert-box.                                                                                                                                                  */
/*            return no-apply .                                                                                                                                                   */
/*          end.                                                                                                                                                                  */
/*                 v-in-code = buf_marking-lines.in-code        .                                                                                                                 */
/*                  end.                                                                                                                                                          */
/*         for each buf_marking-lines exclusive-lock where buf_marking-lines.out-code = bf_marking-lines.out-code                                                                 */
/*/*                                                     and buf_marking-lines.in-code = bf_marking-lines.in-code*/                                                               */
/*                                                     and buf_marking-lines.obj-code = bf_marking-lines.obj-code                                                                 */
/*                                                     and buf_marking-lines.obj-type = bf_marking-lines.obj-type                                                                 */
/*                                                     and buf_marking-lines.sts = 99                                                                                             */
/*                                                     and buf_marking-lines.gds-code = bf_marking-lines.gds-code,                                                                */
/*            first buf_marking exclusive-lock where buf_marking.mark = buf_marking-lines.mark:                                                                                   */
/*            if buf_marking-lines.in-code = bf_marking-lines.in-code then do:                                                                                                    */
/*            if  buf_marking.unit-ext = "UNIT" then  jj = jj + 1 .                                                                                                               */
/*              buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .                                                                                                 */
/*              buf_marking-lines.out-code = {&free-code} .                                                                                                                       */
/*              buf_marking-lines.sts = objSrv:Env:Marking:Sts:Mark:PendingVerification:KeyIntDB .                                                                                */
/*            end.                                                                                                                                                                */
/*            else do:                                                                                                                                                            */
/*              buf_marking-lines.sts = objSrv:Env:Marking:Sts:Mark:PendingVerification:KeyIntDB .                                                                                */
/*            end.                                                                                                                                                                */
/*          end.                                                                                                                                                                  */
/*                                                                                                                                                                                */
/*          find first buf_goods no-lock where buf_goods.gds-code = v-gds-code no-error .                                                                                         */
/*          if available (buf_goods) then                                                                                                                                         */
/*          do:                                                                                                                                                                   */
/*            for first buf_doc-line exclusive-lock where buf_doc-line.doc-code = t-doc.doc-code and buf_doc-line.artic = buf_goods.artic and                                     */
/*              buf_doc-line.prod-code = buf_goods.prod-code and buf_doc-line.prod-type = buf_goods.prod-type,                                                                    */
/*              first ub.gds-dtl exclusive-lock where ub.gds-dtl.doc-code = buf_doc-line.doc-code and ub.gds-dtl.artic = buf_doc-line.artic and                                   */
/*              ub.gds-dtl.prod-code = buf_doc-line.prod-code and ub.gds-dtl.prod-type = buf_doc-line.prod-type:                                                                  */
/*              /*проверять на маркирование?*/                                                                                                                                    */
/*              if not t-doc.flag_ then                                                                                                                                           */
/*              do:                                                                                                                                                               */
/*                v-qnty = ub.gds-dtl.doc-qnty - jj .                                                                                                                             */
/*                ub.gds-dtl.doc-qnty:screen-value in browse {&browse-name} = string(v-qnty) .                                                                                    */
/*                if decimal( ub.gds-dtl.doc-qnty  :screen-value in browse {&browse-name} ) <> ub.gds-dtl.doc-qnty  then                                                          */
/*                do:                                                                                                                                                             */
/*                  { str/chg-qnty.i doc}                                                                                                                                         */
/*                end.                                                                                                                                                            */
/*              end.                                                                                                                                                              */
/*              else                                                                                                                                                              */
/*              do:                                                                                                                                                               */
/*                v-qnty = ub.gds-dtl.fact-qnty - jj .                                                                                                                            */
/*                ub.gds-dtl.fact-qnty:screen-value in browse {&browse-name} = string(v-qnty) .                                                                                   */
/*                if decimal( ub.gds-dtl.fact-qnty  :screen-value in browse {&browse-name} ) <> ub.gds-dtl.fact-qnty  then                                                        */
/*                do:                                                                                                                                                             */
/*                  { str/chg-qnty.i fact}                                                                                                                                        */
/*                end.                                                                                                                                                            */
/*              end.                                                                                                                                                              */
/*            end.                                                                                                                                                                */
/*          end.                                                                                                                                                                  */
/*        end.                                                                                                                                                                    */
/*        else                                                                                                                                                                    */
/*        do:                                                                                                                                                                     */
/*/*          prt-rec  = recid (gds-dtl) .*/                                                                                                                                      */
/*/*          find gds-dtl where recid (gds-dtl) = prt-rec exclusive.*/                                                                                                           */
/*                                                                                                                                                                                */
/*          find gds-dtl no-lock where gds-dtl.doc-code = t-doc.doc-code and                                                                                                      */
/*                                            gds-dtl.artic = buf_goods.artic and                                                                                                 */
/*                                            gds-dtl.prod-code = buf_goods.prod-code and                                                                                         */
/*                                            gds-dtl.prod-type = buf_goods.prod-type no-error.                                                                                   */
/*          if avail gds-dtl then                                                                                                                                                 */
/*          do:                                                                                                                                                                   */
/*          prt-rec  = recid (gds-dtl) .                                                                                                                                          */
/*          find gds-dtl where recid (gds-dtl) = prt-rec exclusive-lock.                                                                                                          */
/*          find doc-line where doc-line.doc-code = gds-dtl.doc-code                                                                                                              */
/*            and doc-line.prod-code = gds-dtl.prod-code                                                                                                                          */
/*            and doc-line.prod-type = gds-dtl.prod-type                                                                                                                          */
/*            and doc-line.artic     = gds-dtl.artic exclusive.                                                                                                                   */
/*          find goods where goods.prod-code = gds-dtl.prod-code                                                                                                                  */
/*            and goods.prod-type = gds-dtl.prod-type                                                                                                                             */
/*            and goods.artic     = gds-dtl.artic no-lock.                                                                                                                        */
/*          run str/out-add.p (parparentproc,                                                                                                                                     */
/*            recid(t-doc),                                                                                                                                                       */
/*            recid(doc-line),                                                                                                                                                    */
/*            recid(gds-dtl),                                                                                                                                                     */
/*            recid (goods),                                                                                                                                                      */
/*            "delete",                                                                                                                                                           */
/*            ?) no-error.                                                                                                                                                        */
/*          end.                                                                                                                                                                  */
/*        end.                                                                                                                                                                    */
/*                                                                                                                                                                                */
/*                                                                                                                                                                                */
/*      end.                                                                                                                                                                      */
/*                                                                                                                                                                                */
/*    end.                                                                                                                                                                        */
/*    run ui-on in this-procedure ( input "line" ).                                                                                                                               */
/*  end.                                                                                                                                                                          */
/*                                                                                                                                                                                */
/*  END.                                                                                                                                                                          */
/*                                                                                                                                                                                */
/*/* _UIB-CODE-BLOCK-END */                                                                                                                                                       */
/*&ANALYZE-RESUME                                                                                                                                                                 */

&Scoped-define SELF-NAME m_lookup-marks
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_lookup-marks d-out-doc
ON CHOOSE OF MENU-ITEM m_lookup-marks /* Просмотр */
  DO:
    define buffer bf_doc-line for ub.doc-line .
    define buffer bf_goods    for ub.goods.
    define variable par-alcohol as character no-undo .
    define variable par-type    as character no-undo .
    define variable p-alcohol   as logical   no-undo .
    define variable v-type      as integer   no-undo .
    define variable v-fact-qnty as decimal   no-undo .
    define variable v-fact-part as decimal   no-undo .
    define variable vGtin       as character no-undo .
    define variable vGtinQnty   as integer   no-undo .
    define variable v-mark-weight as decimal no-undo .
    define variable v-isweighed as logical   no-undo .
    
    define buffer buf_doc-line for ub.doc-line.
    define buffer buf_gds-dtl  for ub.gds-dtl.
    define buffer buf_parts    for ub.parts.
    
    if t-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem} or t-doc.ext-doc-type = {&TDEDT_Ras_Perem} then v-type = 0. else v-type = 2 .        
    for each bf_doc-line no-lock where bf_doc-line.doc-code = t-doc.doc-code :
      find first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic
        and bf_goods.prod-type = bf_doc-line.prod-type
        and bf_goods.prod-code = bf_doc-line.prod-code
        no-error .
      run gds-attr-value(
        bf_goods.gds-code,
        {&attr-alcohol-prod},
        output par-alcohol,
        output par-type
        ).
      if par-alcohol = "yes" then p-alcohol = yes . 
    end. 
    if p-alcohol then 
    do:
      run bge/egais-control-marks.w (input parparentproc).
    end.
    else 
    do:
      if available (t-doc) then 
      do:

        for each ub.marking-lines no-lock where
          ub.marking-lines.obj-type = t-doc.obj-type
          and ub.marking-lines.obj-code = t-doc.obj-code
          and ub.marking-lines.out-code = t-doc.doc-code
          and ub.marking-lines.gds-code = ub.goods.gds-code:
/*          if v-is-return                                     */
/*          then do :                                          */
/*            create tt-marking-lines.                         */
/*            buffer-copy ub.marking-lines to tt-marking-lines.*/
/*            tt-marking-lines.box-qnty = 1 .                  */
/*            tt-marking-lines.unit = "шт" .                   */
/*          end .                                              */
/*          else do :                                          */
            find first ub.marking no-lock where ub.marking.mark begins ub.marking-lines.mark and ub.marking.sts <> ObjSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB no-error.
            if available (ub.marking)
              then 
            do:
              find first tt-marking-lines no-lock where
                         tt-marking-lines.mark = ub.marking-lines.mark
                   no-error.
              if not avail tt-marking-lines or
                 ub.marking.unit-ext <> "unit" then
              do:   
                  if ub.marking.box-qnty = 0 then
                  do:
                    vGtin     = getGtinByDM(ub.marking.mark) .
                    vGtinQnty = getQntyCodeByGtin(vGtin).
                  end.
                  else
                    vGtinQnty = ub.marking.box-qnty.
                  
                  create tt-marking-lines.

                  buffer-copy ub.marking-lines to tt-marking-lines.
                  tt-marking-lines.sts = ub.marking.sts.
                  tt-marking-lines.stts = objSrv:Env:Marking:Sts:Mark:GetLabel(ub.marking.sts).
                  tt-marking-lines.sts-utd = ub.marking-lines.sts.
                  tt-marking-lines.stts-utd = objSrv:Env:Marking:Sts:Mark:GetLabel(ub.marking-lines.sts).
                  tt-marking-lines.box-qnty = vGtinQnty .
                  tt-marking-lines.unit = ub.marking.unit .
                  tt-marking-lines.unit-ext = ub.marking.unit-ext .
                  tt-marking-lines.doc-level = ub.marking-lines.doc-level.
                  tt-marking-lines.mark-parent = ub.marking.mark-parent.
              end.
            end.
/*          end .*/
        end.
      end.

      if available (tt-marking-lines) then
      do:
        run str/mark_browse.w (input parparentproc,
          input-output table tt-marking-lines by-reference,
          input if t-doc.ext-doc-type = {&TDEDT_Pri_Perem} then {&update} else {&lookup},
          input "Марки по: " + t-doc.doc-code + {&delim-par} + t-doc.ext-doc-type,
          input v-type,
          input "" /*тип продукции*/
          )  .

          if pardoc-mode <> {&lookup} and t-doc.ext-doc-type = {&TDEDT_Pri_Perem} then
          do:    /* для приход перемещение вычислим отсканированные марки */
             /* идем по партиям и учтем принятые марки в факт */
             v-isweighed = WghProdVariable(t-doc.obj-type, t-doc.obj-code, ub.goods.gds-code) .
             for each buf_parts exclusive-lock where
                      buf_parts.artic = ub.goods.artic
                  and buf_parts.prod-type = ub.goods.prod-type
                  and buf_parts.prod-code = ub.goods.prod-code
                  and buf_parts.obj-type = t-doc.obj-type
                  and buf_parts.obj-code = t-doc.obj-code
                  and buf_parts.out-code = t-doc.doc-code
                 : 
               v-fact-part = 0.
               for each tt-marking-lines no-lock where
                        tt-marking-lines.doc-level = 1
                    and tt-marking-lines.in-code = buf_parts.in-code
                    and tt-marking-lines.out-code = buf_parts.out-code
                    and tt-marking-lines.part-code = buf_parts.part-code
                    and tt-marking-lines.prt-code = buf_parts.prt-code
               :
                   if tt-marking-lines.sts-utd <> objSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB and
                      tt-marking-lines.sts-utd <> objSrv:Env:Marking:Sts:Mark:DeliveryControl:KeyIntDB
                   then do :
                     if v-isweighed
                     then do :
                       v-fact-part = v-fact-part + MarkWeight(tt-marking-lines.mark) .
                     end .
                     else do :
                       v-fact-part = v-fact-part + tt-marking-lines.box-qnty.
                     end .
                   end .
               end.
               if buf_parts.fact-qnty <> v-fact-part then
                 buf_parts.fact-qnty = v-fact-part.
               v-fact-qnty = v-fact-qnty + v-fact-part.
             end.
             if ub.gds-dtl.fact-qnty <> v-fact-qnty then
             do:
               find first buf_doc-line where rowid(buf_doc-line) = rowid(ub.doc-line) exclusive-lock.
               find first buf_gds-dtl where rowid(buf_gds-dtl) = rowid(ub.gds-dtl) exclusive-lock.
               assign
                 buf_doc-line.fact-qnty = v-fact-qnty
                 buf_gds-dtl.fact-qnty  = v-fact-qnty                
               . 
               br-dtl:refresh() in frame {&frame-name}.   
               for each bf_doc-line no-lock where
                        bf_doc-line.obj-type = t-doc.obj-type
                    and bf_doc-line.obj-code = t-doc.obj-code
                    and bf_doc-line.doc-code = t-doc.doc-code
               :
                 accum bf_doc-line.fact-qnty (total).  
               end.
               if t-doc.fact-qnty <> accum total bf_doc-line.fact-qnty then
               do:
                 t-doc.fact-qnty = accum total bf_doc-line.fact-qnty.
                 display t-doc.fact-qnty with frame {&frame-name}.
               end.  
             end.
          end.
      end.
      else 
      do:
        message "Нет марок для просмотра"
          view-as alert-box.
      end.  
      for each tt-marking-lines:
        delete tt-marking-lines.
      end.
    end.        
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_no-marks
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_no-marks d-out-doc
ON CHOOSE OF MENU-ITEM m_no-marks /* Просмотр */
  DO:
    define buffer bf_doc-line for ub.doc-line .
    define buffer bf_goods    for ub.goods.
    define buffer buf_marking-lines for ub.marking-lines .
    define buffer buf_marking       for ub.marking .
    define buffer buf_goods         for ub.goods .
    define buffer buf_doc-line      for ub.doc-line .
    define buffer buf_gds-dtl       for ub.gds-dtl .
    define buffer buf_parts         for ub.parts .
    define buffer bf_parts          for ub.parts .
    define buffer cpl_gds-dtl       for ub.gds-dtl .
    define variable mark       as character no-undo .
    define variable jj         as integer   no-undo .
    define variable v-GTIN     as character no-undo .
    define variable v-gds-code as integer   no-undo . 
    define variable ungroup    as logical   no-undo .
    define variable v-message  as character no-undo .
    
    define variable qnty-mark-doc as integer no-undo .
    define variable qnty-mark-fact as integer no-undo .
    define variable ii as integer no-undo .
    define variable v-ok as logical no-undo .
      if available (t-doc) then 
      do:
       for each bf_doc-line no-lock where bf_doc-line.doc-code = t-doc.doc-code,
        first bf_goods no-lock where bf_goods.artic = bf_doc-line.artic
                                 and bf_goods.prod-code = bf_doc-line.prod-code
                                 and bf_goods.prod-type = bf_doc-line.prod-type:
         qnty-mark-doc = 0 .
         qnty-mark-fact = 0 .                          
        for each ub.marking-lines no-lock where
          ub.marking-lines.obj-type = t-doc.obj-type
          and ub.marking-lines.obj-code = t-doc.obj-code
          and ub.marking-lines.out-code = t-doc.doc-code
          and ub.marking-lines.gds-code = bf_goods.gds-code
          and ub.marking-lines.mark begins {&tech-mark-prefix}:

          find first ub.marking no-lock where ub.marking.mark = ub.marking-lines.mark and ub.marking.unit-ext = "UNIT" no-error.
          if available (ub.marking)
            then 
          do:
            qnty-mark-doc = qnty-mark-doc + 1 .
            if ub.marking-lines.sts = Marking:Checked_:KeyIntDB then qnty-mark-fact = qnty-mark-fact + 1 . 
          end.
        end.
        if qnty-mark-doc > 0 then do:
        create tt-tech-mark.
        assign
          tt-tech-mark.doc-code  = bf_doc-line.doc-code 
          tt-tech-mark.line-num  = bf_doc-line.line-num
          tt-tech-mark.gds-code  = bf_goods.gds-code 
          tt-tech-mark.gds-name  = bf_goods.gds-name
          tt-tech-mark.qnty-doc  = qnty-mark-doc
          tt-tech-mark.qnty-fact = qnty-mark-fact
          .
          end.
      end.

      if available (tt-tech-mark) then
      do:
        run str/no_mark.w (input parparentproc,
          input-output table tt-tech-mark by-reference,
          input pardoc-mode,
          output v-ok
          ) 
          .
/*Сброс статусов технических марок*/
if v-ok then do:
for each ub.marking-lines exclusive-lock where
          ub.marking-lines.obj-type = t-doc.obj-type
          and ub.marking-lines.obj-code = t-doc.obj-code
          and ub.marking-lines.out-code = t-doc.doc-code
          and ub.marking-lines.mark begins {&tech-mark-prefix}:
          ub.marking-lines.sts = Marking:PendingVerification:KeyIntDB .  
end.
for each tt-tech-mark:
ii = 0 .
for each ub.marking-lines exclusive-lock where
          ub.marking-lines.obj-type = t-doc.obj-type
          and ub.marking-lines.obj-code = t-doc.obj-code
          and ub.marking-lines.out-code = tt-tech-mark.doc-code
          and ub.marking-lines.gds-code = tt-tech-mark.gds-code
          and ub.marking-lines.mark begins {&tech-mark-prefix}:
          ii = ii + 1 .
          if ii > tt-tech-mark.qnty-fact then leave .
          ub.marking-lines.sts = Marking:Checked_:KeyIntDB .
end.            
                  
end.   
    ii = 0 .

        for each buf_doc-line exclusive-lock where buf_doc-line.doc-code = t-doc.doc-code,
          first buf_gds-dtl exclusive-lock where buf_gds-dtl.doc-code = buf_doc-line.doc-code and 
                                                 buf_gds-dtl.artic = buf_doc-line.artic and
                                                 buf_gds-dtl.prod-code = buf_doc-line.prod-code and 
                                                 buf_gds-dtl.prod-type = buf_doc-line.prod-type:
          jj = 0 .        
          
          find first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic and
                                             buf_goods.prod-code = buf_doc-line.prod-code and
                                             buf_goods.prod-type = buf_doc-line.prod-type no-error .
          
          for each buf_marking-lines exclusive-lock where buf_marking-lines.obj-code = buf_doc-line.obj-code and 
                                                          buf_marking-lines.obj-type = buf_doc-line.obj-type and 
                                                          buf_marking-lines.out-code = buf_doc-line.doc-code and 
                                                          buf_marking-lines.gds-code = buf_goods.gds-code,
            first buf_marking no-lock where buf_marking.mark = buf_marking-lines.mark and 
                                            buf_marking.obj-code = buf_marking-lines.obj-code and
                                            buf_marking.obj-type = buf_marking-lines.obj-type and buf_marking.unit-ext = "UNIT": 
          if buf_marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB then do:
          jj = jj + 1 .
          ii = ii + 1 . 
          end.
          buf_doc-line.fact-qnty = jj .
          buf_gds-dtl.fact-qnty = buf_doc-line.fact-qnty .          
          for first buf_parts exclusive-lock where buf_parts.out-code = buf_marking-lines.out-code and 
                                                   buf_parts.artic = buf_doc-line.artic and
                                                   buf_parts.prod-code = buf_doc-line.prod-code and 
                                                   buf_parts.prod-type = buf_doc-line.prod-type and 
                                                   buf_parts.obj-code = buf_marking-lines.obj-code and
                                                   buf_parts.obj-type = buf_marking-lines.obj-type and
                                                   buf_parts.part-code = buf_marking-lines.part-code and 
                                                   buf_parts.in-code = buf_marking-lines.in-code :
            buf_parts.fact-qnty = buf_doc-line.fact-qnty .
          end. 
          
          end.
        
        t-doc.fact-qnty = ii .                                     
        end.               
        
 end.
 

 
      end.
      else 
      do:
        message "Нет технических марок"
          view-as alert-box.
      end.  
    
    end.
    empty temp-table tt-tech-mark .   
    run ui-on in this-procedure ( input "line" ).       
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-arch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-arch d-out-doc
ON CHOOSE OF b-arch IN FRAME d-out-doc /* Учет */
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_archive_cost':U
    {&cntxt-object}
    t-doc.host-code
    t-doc.obj-type
    t-doc.obj-code
    0
    0
    0
    true
    varlog
  }

  if varlog <> yes
  then do:
    return no-apply.
  end.
  run str/docsuppn.w
    (input parparentproc
    ,input recid( t-doc )
    ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-attr d-out-doc
ON CHOOSE OF b-attr IN FRAME d-out-doc /* Атр */
DO:
    run init-attr-general in this-procedure .
    if t-doc.status_ <> {&fact} then do:
      run str/doc-attr.w (input ParParentproc, input "b-lkp,b-chg,b-add,b-del", input t-doc.doc-code, input table tt-upd-attr) no-error.
    end.
    else do:
      run str/doc-attr.w (input ParParentproc, input "b-lkp,b-chg,b-add", input t-doc.doc-code, input table tt-upd-attr) no-error.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-bc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-bc d-out-doc
ON CHOOSE OF b-bc IN FRAME d-out-doc /* БарКод */
DO:
  run check-rate no-error.
if error-status :error then return no-apply.
/*Для внутреннего прихода работаем по новому списку*/
if t-doc.doc-type = {&income} and
   t-doc.internal = yes       and
   t-doc.status_  = {&wayb}   and
   t-doc.flag_                then do:

   if avail ub.bar-code then
   do:
     run checkTypeByBarCode in this-procedure (ub.bar-code.b-code, t-doc.ext-doc-type) no-error.
     if error-status:error then return no-apply.
   end.
   
   run fact-bc in this-procedure (t-doc.doc-code)  no-error.
   if error-status :error then do:
     message
       vss-workfile vss-revision vss-description skip
       "Ошибка при редактировании фактических количеств." skip
       return-value skip
       view-as alert-box error.
     undo, return no-apply.
   end.
end.
else do:
  assign
    v-cond = {&free}         /* режим вызова справочника */
    varline-mode = {&update}
    prt-rec = ?
    varlns-cnt = 1
    add-sens = b-add:sensitive
    b-c = 0
    gds-rec = ?.
  do while b-c <> ?:
     run str/chs-bc.w (parparentproc, "Строка накладной № " + t-doc.doc-code, add-sens, no, yes, output b-c-char, output rate, output ret-mode, input-output add-scan, input-output bar-str).
     b-c = integer(b-c-char).
     if b-c <> ? then do:
        run checkTypeByBarCode in this-procedure (b-c, t-doc.ext-doc-type) no-error.
        if error-status:error then next.
        
        do transaction on error undo, return no-apply :
           /*По факту добавляем сразу, если включен флаг: добавить со сканера.*/
           if t-doc.flag_ and t-doc.status_ = {&permitted} then do:
              run find-gds no-error.
              if error-status :error then undo, return no-apply.
           end.
           if add-scan and t-doc.flag_ and t-doc.status_ = {&permitted} then do:
              run add-rate no-error.
              if error-status :error then undo, return no-apply.
              { str/chg-qnty.i fact}
           end.
           else do:
              assign
                varline-mode = {&update}
                prt-rec   = ?
                line-rec  = ?.
              run str/out-add.p (parparentproc,
                             recid(t-doc),
                             ?,
                             ?,
                             ?,
                             "b-c",
                             string(b-c)             + "," +
                             string(rate)            + "," +
                             ret-mode                + "," +
                             string(b-add:sensitive) + "," +
                             string(add-scan)).
           end.
        end.
     end.
  end.
end.
/* в ui-on давятся пустые ub.doc-line */
run ui-on ("line").
if prt-rec <> ? then
  reposition br-dtl to recid prt-rec no-error.
return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg d-out-doc
ON CHOOSE OF b-chg IN FRAME d-out-doc /* Изменить */
DO:
define buffer bin_parts for ub.parts .
define buffer bout_parts for ub.parts .
define buffer buf_gen-attr for ub.gen-attr .
define variable v-recid as recid no-undo .
  if not available ub.gds-dtl then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
  v-recid = recid (ub.doc-line) .

  run check-rate in this-procedure
    no-error.
  if error-status :error then do:
    return no-apply.
  end.
  assign
    varline-mode = {&update}
  .
  run check-inv in this-procedure
    no-error.
  if error-status :error then do:
    return no-apply.
  end.
  find first ub.doc-line
    where ub.doc-line.doc-code  = ub.gds-dtl.doc-code
      and ub.doc-line.artic     = ub.gds-dtl.artic
      and ub.doc-line.prod-type = ub.gds-dtl.prod-type
      and ub.doc-line.prod-code = ub.gds-dtl.prod-code
    .
  if v-is-return
  then do :
    for first bout_parts no-lock where bout_parts.obj-type  = doc-line.obj-type
                                   and bout_parts.obj-code  = doc-line.obj-code
                                   and bout_parts.artic     = doc-line.artic
                                   and bout_parts.prod-type = doc-line.prod-type
                                   and bout_parts.prod-code = doc-line.prod-code
                                   and bout_parts.out-code  = doc-line.doc-code
    :
      find first buf_gen-attr no-lock where buf_gen-attr.table-name = {&table_parts}
                                        and buf_gen-attr.p-key      = {key/parts.i bout_parts } 
                                        and buf_gen-attr.attr-code  = "in-part-key"
                                        no-error .
      if available buf_gen-attr
      then do :
        find first bin_parts no-lock where bin_parts.obj-type  = entry(2, buf_gen-attr.attr-value, {&delim-key})
                                       and bin_parts.obj-code  = integer(entry(3, buf_gen-attr.attr-value, {&delim-key}))
                                       and bin_parts.artic     = entry(4, buf_gen-attr.attr-value, {&delim-key})
                                       and bin_parts.prod-type = entry(5, buf_gen-attr.attr-value, {&delim-key})
                                       and bin_parts.prod-code = integer(entry(6, buf_gen-attr.attr-value, {&delim-key}))
                                       and bin_parts.in-code   = entry(7, buf_gen-attr.attr-value, {&delim-key})
                                       and bin_parts.out-code  = entry(8, buf_gen-attr.attr-value, {&delim-key})
                                       and bin_parts.part-code = entry(9, buf_gen-attr.attr-value, {&delim-key})
                                       no-error .
      end .                                  
    end .  
    if available bin_parts
    then do :
      run str/out-add.p
        ( input parparentproc
        ,input recid(t-doc)
        ,input recid(doc-line)
        ,input recid(gds-dtl)
        ,input recid (goods)
        ,input varline-mode + {&delim-par} + "return=" + string(recid(bin_parts))
        ,input ?
        ) no-error.
      if error-status :error then 
      do:
        return no-apply.
      end.
    end .
    else do :
      run str/out-add.p
       ( input parparentproc
        ,input recid(t-doc)
        ,input recid(doc-line)
        ,input recid(gds-dtl)
        ,input recid (goods)
        ,input varline-mode + {&delim-par} + "return"
        ,input ?
        ) no-error.
      if error-status :error then 
      do:
        return no-apply.
      end.
    end .
  end .
  else
  if (lookup( string(t-doc.reason-code), v-reasons-for-return) > 0
  and t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh})
  then do :
    run str/out-add.p
      ( input parparentproc
      ,input recid(t-doc)
      ,input recid(ub.doc-line)
      ,input recid(ub.gds-dtl)
      ,input recid (ub.goods)
      ,input varline-mode + {&delim-par} + "return"
      ,input ?
      ) no-error.
    if error-status :error then do:
      return no-apply.
    end.
  end.
  else do :
    run str/out-add.p
      ( input parparentproc
      ,input recid(t-doc)
      ,input recid(ub.doc-line)
      ,input recid(ub.gds-dtl)
      ,input recid (ub.goods)
      ,input varline-mode
      ,input ?
      ) no-error.
    if error-status :error then do:
      return no-apply.
    end.
  end.
  if t-doc.ext-doc-type = {&TDEDT_Ras_Perem}
  then do :
    run local-cur in this-procedure (input 4) no-error.
    if error-status :error then return .
  end .
  run ui-on in this-procedure
    ( input "line"
    ).
  apply "entry" to br-dtl in frame {&frame-name} .
  reposition br-dtl to recid v-recid no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cnt d-out-doc
ON CHOOSE OF b-cnt IN FRAME d-out-doc /* ДогП */
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_archive_cost':U
    {&cntxt-object}
    t-doc.host-code
    t-doc.obj-type
    t-doc.obj-code
    0
    0
    0
    true
    varlog
  }
  if varlog <> yes then do: return no-apply. end.
  run str/scntdoc.w ( input t-doc.doc-code, input ( v-cntxt-db-num = ub.sysconf.firm-db-num ) ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-contr-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-contr-lkp d-out-doc
ON CHOOSE OF b-contr-lkp IN FRAME d-out-doc
DO:
 define buffer buf_contract for ub.contract  .
 if t-doc.contract-code <> 0 then do:
   if is-doc-hold then do:
      find first buf_contract no-lock where
            buf_contract.contract-code = t-doc.contract-code no-error .
     
   end.
   else do:
      find first buf_contract no-lock where
            buf_contract.host-code     = t-doc.host-code   and
            buf_contract.contract-code = t-doc.contract-code no-error .
   end.    
      if available buf_contract then do:
          run str/sh-contr.p
              ( input parParentProc ,
                input recid(buf_contract)
              ).
      end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del d-out-doc
ON CHOOSE OF b-del IN FRAME d-out-doc /* Удалить */
DO:
  run local-del no-error.
if error-status :error then return no-apply.
run ui-on ("enable":u).
apply "entry" to br-dtl in frame {&frame-name} .
prt-rec = del-rec.
if prt-rec <> ? then reposition br-dtl to recid prt-rec no-error.

IF mImagePh THEN
DO:
    DEFINE VARIABLE vImageList AS LONGCHAR    NO-UNDO.
    DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
if AVAILABLE goods then do:
    RUN gds-attr-value ( goods.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
    RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, goods.gds-code, OUTPUT vImageList).
    vCh = ENTRY (1, vImageList, {&ImageDelimiter}).
    g-image:LOAD-IMAGE (ENTRY (1, vCh)) NO-ERROR.
    ASSIGN
        g-image:HIDDEN     = NO
        g-image:VISIBLE    = YES
        g-image:SENSITIVE  = YES
        .
end.
else
      ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .   
END.
ELSE
    ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .
apply "value-changed" to br-dtl in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dopinf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dopinf d-out-doc
ON CHOOSE OF b-dopinf IN FRAME d-out-doc /* О заказе */
DO:
  run init-attr-flora .
  if pardoc-mode <> {&lookup} then do:
     run str/fl-atu.w (input {&update}, input t-doc.doc-code) no-error.
  end.
  else do:
     run str/fl-atu.w (input {&lookup}, input t-doc.doc-code) no-error.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp d-out-doc
ON CHOOSE OF b-lkp IN FRAME d-out-doc /* Просмотр */
DO:
  if not available ub.gds-dtl then do:
  message "Неправильно выбрана строка.".
  return no-apply.
end.
run local-lookup.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark d-out-doc
ON CHOOSE OF b-mark IN FRAME d-out-doc /* * */
DO:
  run mark-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-notes-line
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-notes-line d-out-doc
ON CHOOSE OF b-notes-line IN FRAME d-out-doc /* О наборе */
DO:
  define variable v-ps as character no-undo.
define variable  p-type     as character no-undo .
if not available t-doc then return .
if not available ub.goods then return .
    run lineattr-value (
      input   t-doc.doc-code ,
      input   ub.goods.gds-code ,
      input   {&lineattr-flora_ps},
      output  v-ps ,
      output  p-type      )
    .

run gbl/d-prompt.w (
        'title=':u + "Изменение атрибутов строки документа" + '\':u
      + 'text1=':u + "Примечание по позиции: " + ub.goods.gds-name + '\':u
      + 'format=' + "x(1000)" + '\':u
      + 'type=' + "edit" + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=60\':u
      + 'fillin_height=5\':u
      + 'max-chars=1000\':u     /*- максимальное количество символов для редактора*/
      + 'readonly=' + (if pardoc-mode = {&update} then 'no':u else 'yes':u) + '\':u
      , input-output v-ps
      ) no-error.
  if caps(return-value) = "TRUE"  then do:
  if pardoc-mode = {&update} then do:
    if not error-status :error then do:

      run  lineattr-write (
        input   t-doc.doc-code ,
        input   ub.goods.gds-code ,
        input   {&lineattr-flora_ps},
        input   v-ps )
      .
    end.
  end.
end.
apply "value-changed" to br-dtl in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-parts d-out-doc
ON CHOOSE OF b-parts IN FRAME d-out-doc /* Партии */
DO:
    define variable varloc-prt-rec as recid no-undo.

  if not available ub.doc-line then do:
    message "Неправильный выбор строки - партии недоступны." view-as alert-box.
    return no-apply.
  end.
  assign
    varloc-prt-rec = recid( ub.doc-line )
  .
  run local-parts in this-procedure no-error.
  if error-status :error then do:
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       ""
       view-as alert-box error
     .
     return no-apply.
  end.
  
  if t-doc.ext-doc-type = {&TDEDT_Ras_Perem}
  then do :
    run local-cur in this-procedure (input 4) no-error.
    if error-status :error then return .
  end .
/* в ui-on давятся пустые ub.doc-line */

  run ui-on in this-procedure ( input "line" ) .
  apply "ENTRY":U to br-dtl in frame {&frame-name}.
  reposition br-dtl to recid varloc-prt-rec no-error .
  if error-status :error then do: reposition br-dtl to row 1 no-error. end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prt d-out-doc
ON CHOOSE OF b-prt IN FRAME d-out-doc /* Шкала */
DO:
  if not available ub.gds-dtl then do:
  message "Неправильный выбор строки - шкала недоступна.".
  return no-apply.
end.
if pardoc-mode <> {&lookup} then do:
  run check-rate no-error.
  if error-status :error then return no-apply.
end.
run set-work-mode-prt no-error.
if error-status :error then return no-apply.
if pardoc-mode = {&lookup} then do:
  find first ub.doc-line where ub.doc-line.doc-code  = ub.gds-dtl.doc-code  and
                            ub.doc-line.artic     = ub.gds-dtl.artic     and
                            ub.doc-line.prod-type = ub.gds-dtl.prod-type and
                            ub.doc-line.prod-code = ub.gds-dtl.prod-code no-lock.
end.
else do:
  find first ub.doc-line where ub.doc-line.doc-code  = ub.gds-dtl.doc-code  and
                            ub.doc-line.artic     = ub.gds-dtl.artic     and
                            ub.doc-line.prod-type = ub.gds-dtl.prod-type and
                            ub.doc-line.prod-code = ub.gds-dtl.prod-code .
end.
prt-rec = recid(ub.doc-line).
find first ub.goods where ub.goods.artic     = ub.gds-dtl.artic     and
                       ub.goods.prod-type = ub.gds-dtl.prod-type and
                       ub.goods.prod-code = ub.gds-dtl.prod-code no-lock.

if lookup( string(t-doc.reason-code), v-reasons-for-return) > 0
and t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
then do :
  run str/out-add.p (parparentproc,
                 recid(t-doc),
                 recid(ub.doc-line),
                 recid(ub.gds-dtl),
                 recid (ub.goods),
                 work-mode + {&delim-par} + "return",
                 ?) no-error.
  if error-status :error then return no-apply.
end.
else do :
  run str/out-add.p (parparentproc,
                 recid(t-doc),
                 recid(ub.doc-line),
                 recid(ub.gds-dtl),
                 recid (ub.goods),
                 work-mode,
                 ?) no-error.
  if error-status :error then return no-apply.
end.
if varprt-mode = {&prt-def} then run ui-on ("line").
apply "entry" to br-dtl in frame {&frame-name} .
reposition br-dtl to recid prt-rec no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-re-price
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-re-price d-out-doc
ON CHOOSE OF b-re-price IN FRAME d-out-doc /* ПрсчЦены */
DO:
    if not available ub.gds-dtl then do:
    message "Неправильный выбор строки." view-as alert-box error.
    return no-apply.
  end.
  run proc-b-re-price in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-rsrv-doc-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rsrv-doc-list d-out-doc
ON CHOOSE OF b-rsrv-doc-list IN FRAME d-out-doc /* Резерв */
DO:
    define variable v-rsrv-doc-list      as character no-undo .
  define variable v-rsrv-doc-list-type as character no-undo .
  define variable v-new-rsrv-doc-list  as character no-undo .

  { str/tdat-val.i
      t-doc.doc-code
      {&trdcattr-rsrv-doc-list}
      v-rsrv-doc-list
      v-rsrv-doc-list-type
  }

  run str/doclsted.p
    (input  parparentproc       /* parparentproc       */
    ,input  t-doc.host-code     /* p-curr-host-code    */
    ,input  t-doc.obj-type      /* p-curr-obj-type     */
    ,input  t-doc.obj-code      /* p-curr-obj-code     */
    ,input  v-rsrv-doc-list     /* p-doc-code-list     */
    ,input  {&expense}          /* p-doc-type-list     */
    ,output v-new-rsrv-doc-list /* p-new-doc-code-list */
    ) .
  if v-new-rsrv-doc-list = ''
  then do:
    define variable v-attr-delete as logical   no-undo .
    { str/tdat-del.i
        t-doc.doc-code
        {&trdcattr-rsrv-doc-list}
        v-attr-delete
    }
  end.
  else do:
    { str/tdat-wrt.i
        t-doc.doc-code
        {&trdcattr-rsrv-doc-list}
        v-new-rsrv-doc-list
    }
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-dtl
&Scoped-define SELF-NAME br-dtl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dtl d-out-doc
ON row-display OF br-dtl IN FRAME d-out-doc
DO:
  run proc-row-display in this-procedure.
  run rowdisp .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dtl d-out-doc
ON row-leave OF br-dtl IN FRAME d-out-doc
DO:
    define variable var_is-petrol as logical no-undo .
  define variable var_is-pieces as logical no-undo .
  if available ub.gds-dtl  and
     (decimal( ub.gds-dtl.doc-qnty :screen-value in browse {&browse-name} ) <> ub.gds-dtl.doc-qnty or
      decimal( ub.gds-dtl.fact-qnty :screen-value in browse {&browse-name} ) <> ub.gds-dtl.fact-qnty ) then do:
    { str/is-petrl.i
      ub.gds-dtl.artic
      ub.gds-dtl.prod-type
      ub.gds-dtl.prod-code
      var_is-petrol
      var_is-pieces
    }
    if var_is-petrol = yes and
       var_is-pieces = no
    then do:
      if decimal( ub.gds-dtl.doc-qnty :screen-value in browse {&browse-name} ) <> ub.gds-dtl.doc-qnty
      then do:
        display ub.gds-dtl.doc-qnty with browse {&browse-name} .
        message substitute( 'В жидком топливе нельзя редактировать количество.&1'
                        , ( if b-chg :sensitive in frame {&frame-name}
                            then substitute( '&1Воспользуйтесь кнопкой "&2".'
                                           , {&new-line}
                                           , replace( b-chg :label in frame {&frame-name}, "&", "":U )
                                           )
                            else '':U )
                        )
        view-as alert-box error .
      end.
      else do:
        if decimal( ub.gds-dtl.fact-qnty :screen-value in browse {&browse-name} ) <> ub.gds-dtl.fact-qnty
        then do:
          display ub.gds-dtl.fact-qnty with browse {&browse-name} .
          message substitute( 'В жидком топливе нельзя редактировать фактическое количество.&1'
                            , ( if b-chg :sensitive in frame {&frame-name}
                                then substitute( '&1Воспользуйтесь кнопкой "&2".'
                                               , {&new-line}
                                               , replace( b-chg :label in frame {&frame-name}, "&", "":U )
                                               )
                                else '':U )
                            )
          view-as alert-box error .
        end.
      end.
      return no-apply.
    end.
    find first ub.goods no-lock where
               ub.goods.artic     = ub.gds-dtl.artic     and
               ub.goods.prod-type = ub.gds-dtl.prod-type and
               ub.goods.prod-code = ub.gds-dtl.prod-code .
    find first ub.units no-lock where ub.units.unit-name = ub.goods.unit-base .
    if decimal( ub.gds-dtl.doc-qnty :screen-value in browse {&browse-name} ) <> ub.gds-dtl.doc-qnty and
        lookup( {&twounit}, ub.units.type ) > 0 then do:
       message "Товар с двумя единицами измерения резервируется через партии." view-as alert-box.
       return no-apply.
    end.
    if decimal( ub.gds-dtl.doc-qnty  :screen-value in browse {&browse-name} ) <> ub.gds-dtl.doc-qnty  then do:
      { str/chg-qnty.i doc  }
      if v-is-ptrl = "yes":U then do:
        run inv-line_recalc-qty in this-procedure
          ( input ub.gds-dtl.doc-code
          ,input ub.gds-dtl.artic
          ,input ub.gds-dtl.prod-type
          ,input ub.gds-dtl.prod-code
          ,input false
          ,input decimal( ub.gds-dtl.doc-qnty  :screen-value in browse {&BROWSE-NAME} )
          ,input decimal( ub.gds-dtl.fact-qnty :screen-value in browse {&BROWSE-NAME} )
          ) no-error.
        if error-status :error then do: return no-apply. end.
      end. /* if v-is-ptrl = "yes" */
    end.
    if decimal( ub.gds-dtl.fact-qnty :screen-value in browse {&browse-name} ) <> ub.gds-dtl.fact-qnty then do:
      { str/chg-qnty.i fact }
      if v-is-ptrl = "yes":U then do:
        run inv-line_recalc-qty in this-procedure
          ( input ub.gds-dtl.doc-code
          ,input ub.gds-dtl.artic
          ,input ub.gds-dtl.prod-type
          ,input ub.gds-dtl.prod-code
          ,input true
          ,input decimal( ub.gds-dtl.doc-qnty  :screen-value in browse {&BROWSE-NAME} )
          ,input decimal( ub.gds-dtl.fact-qnty :screen-value in browse {&BROWSE-NAME} )
          ) no-error.
        if error-status :error then do: return no-apply. end.
      end. /* if v-is-ptrl = "yes" */
    end.
  end. /* if available ub.gds-dtl */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME {&sort-clmn_6-br-dtl}
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL {&sort-clmn_6-br-dtl} d-out-doc
ON LEAVE OF {&sort-clmn_6-br-dtl} IN BROWSE {&browse-name}
DO:
  define variable vIsExemplarGoods as logical no-undo .
  define variable vGtin     as character no-undo.
  define variable vGtinQnty as integer no-undo.
  define variable varvalue        as character no-undo .
  define variable vartype         as character no-undo .
  define variable v-mark-weight as decimal no-undo .
  define variable v-isweighed as logical no-undo .
  define buffer buf_marking-lines for ub.marking-lines.
  define buffer buf_marking       for ub.marking.
  define buffer buf_goods         for ub.goods.
  
  if available ub.gds-dtl
  then do :
    
    find first buf_goods where 
          buf_goods.artic     = ub.gds-dtl.artic
      and buf_goods.prod-type = ub.gds-dtl.prod-type
      and buf_goods.prod-code = ub.gds-dtl.prod-code.
    
    v-isweighed = WghProdVariable(t-doc.obj-type, t-doc.obj-code, buf_goods.gds-code) .
    
    run isExemplarGoods in this-procedure 
         (t-doc.obj-type, t-doc.obj-code, buf_goods.gds-code, output vIsExemplarGoods).
    
    if v-isweighed
    then do :
      for each buf_marking-lines no-lock where
               buf_marking-lines.out-code = t-doc.doc-code
           and buf_marking-lines.obj-type = t-doc.obj-type
           and buf_marking-lines.obj-code = t-doc.obj-code
           and buf_marking-lines.gds-code = buf_goods.gds-code
           and buf_marking-lines.doc-level = 1,
          first buf_marking no-lock where
                buf_marking.mark = buf_marking-lines.mark
      :
        v-mark-weight = v-mark-weight + MarkWeight(buf_marking.mark) .
      end.
      if v-mark-weight > decimal({&self-name}:screen-value IN BROWSE {&browse-name}) then 
      do:
        message "Нельзя ввести количество меньше, чем просканировано марок по товару" view-as alert-box. 
        {&self-name}:screen-value IN BROWSE {&browse-name} = string(v-mark-weight).
        return no-apply.  
      end. 
    end .
    else  
    if vIsExemplarGoods
    then do:  /* для поэкземплярного учета проверим: введенное кол-во не должно быть < просканированных марок */
      for each buf_marking-lines no-lock where
               buf_marking-lines.out-code = t-doc.doc-code
           and buf_marking-lines.obj-type = t-doc.obj-type
           and buf_marking-lines.obj-code = t-doc.obj-code
           and buf_marking-lines.gds-code = buf_goods.gds-code
           and buf_marking-lines.doc-level = 1,
          first buf_marking no-lock where
                buf_marking.mark = buf_marking-lines.mark
      :
        assign
          vGtin     = getGtinByDM(buf_marking.mark)
          vGtinQnty = vGtinQnty  + getQntyCodeByGtin(vGtin)
        .
      end.
      if vGtinQnty > int({&self-name}:screen-value IN BROWSE {&browse-name}) then 
      do:
        message "Нельзя ввести количество меньше, чем просканировано марок по товару" view-as alert-box. 
        {&self-name}:screen-value IN BROWSE {&browse-name} = string(vGtinQnty).
        return no-apply.  
      end.  
    end.
  end . /* if available gds-dtl */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME t-doc.discnt-pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-doc.discnt-pc d-out-doc
ON LEAVE OF t-doc.discnt-pc IN FRAME d-out-doc /* Скидка */
DO:
if input frame {&frame-name} t-doc.discnt-pc <> t-doc.discnt-pc then do:
if input frame {&frame-name} t-doc.discnt-pc = ? then do:
  message "Ошибка. Установлен неизвестный процент скидки."
  view-as alert-box error.
  display t-doc.discnt-pc with frame {&frame-name}.
  return no-apply.
end.
if available t-doc then do transaction:
  assign
    t-doc.discnt-pc = input frame {&frame-name} t-doc.discnt-pc.
  run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
  if error-status :error then do:
    undo, return no-apply.
  end.
  run ui-on ("line").
end.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME t-doc.fact-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-doc.fact-date d-out-doc
ON LEAVE OF t-doc.fact-date IN FRAME d-out-doc /* Факт */
DO:
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-avail-on-date   as logical   no-undo .
define variable v-avail-on-date-type as character no-undo .
define variable v-tth             as handle no-undo .

  delete object v-tth no-error.
  run adm/shattri.p (
      input "get":U
      ,input t-doc.obj-type
      ,input t-doc.obj-code
      ,input {&attr-nakl_par}
      ,input  "avail-on-date"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-avail-on-date
      ,output v-avail-on-date-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
      if error-status :error  then v-avail-on-date = false .
      delete object v-tth no-error.
      if v-avail-on-date = true  and not ( t-doc.fact-date:screen-value = "" or t-doc.fact-date:screen-value = string(t-doc.fact-date)) then do:
         if available ub.gds-dtl  then do:
            message " Установлен параметр проверки резервирования не раньше даты прихода, поэтому так как строки документа введены дату менять нельзя "  view-as alert-box information   .
            t-doc.fact-date:screen-value = string(t-doc.fact-date) .
            return no-apply .
         end.
      end.

    if input frame {&frame-name} t-doc.fact-date <> t-doc.fact-date then do:
    run chk-upd-date no-error.
    if error-status :error then return no-apply.
    assign frame {&frame-name} t-doc.fact-date.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-doc.fact-date d-out-doc
ON return OF t-doc.fact-date IN FRAME d-out-doc /* Факт */
DO:
    if t-doc.fact-date:sensitive in frame {&frame-name} then do:
    apply "entry" to t-doc.shift-date in frame {&frame-name}.
  end.
  else do:
    apply "entry" to b-add in frame {&frame-name}.
  end.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME edo-return
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL edo-return d-out-doc
ON VALUE-CHANGED OF edo-return IN FRAME d-out-doc /* возврат по ЭДО */
  DO:
    define variable vLog as logical no-undo .
    define variable vFlgGenAttr as logical no-undo .
    define buffer buf_doc-line  for ub.doc-line.
    define buffer parts         for ub.parts.
        
    if edo-return:screen-value = "no"
    then do :
      message "По договору с поставщиком осуществляется ЭДО, уверены в возврате без ЭДО?" view-as alert-box question buttons yes-no update vLog .
      if not vLog
      then do :
        edo-return:screen-value = "yes" .
        return no-apply .
      end .
    end .
    if (t-doc.reason-code = 25 or t-doc.reason-code = 23) 
        and edo-return:screen-value = "yes" 
    then do:   
       vFlgGenAttr = yes.    
       /* проверяем, что не завели еще товары по кнопке Баркод без партии */
       bdl:
       for each buf_doc-line where buf_doc-line.doc-code eq t-doc.doc-code 
           no-lock,
           each parts where parts.out-code  = buf_doc-line.doc-code
                        and parts.obj-type  = buf_doc-line.obj-type
                        and parts.obj-code  = buf_doc-line.obj-code
                        and parts.artic     = buf_doc-line.artic
                        and parts.prod-type = buf_doc-line.prod-type
                        and parts.prod-code = buf_doc-line.prod-code
           no-lock:
                   
           find first gen-attr where gen-attr.table-name = {&table_parts}
                                 and gen-attr.p-key      = {key/parts.i parts } 
                                 and gen-attr.attr-code  = "in-part-key"
              no-lock no-error.
           if available gen-attr 
              then vFlgGenAttr = yes.
           else do:
              vFlgGenAttr = no.
              leave bdl.
           end.                               
       end.                
       if vFlgGenAttr = yes then 
          disable b-bc with frame {&frame-name}.
       else do:
          message "Строки документа введены без указания возвращаемой партии." 
             skip "Удалите все строки документа, что бы установить признак 'Возврат по ЭДО'."
          view-as alert-box.
          edo-return:screen-value = "no" .
          return no-apply .
       end.      
    end.    
/*    else do:                                                                                                  */
/*       /*накл- запр- разр+ для всех внешних и внутреннего расхода*/                                           */
/*       if ((not t-doc.flag_ and t-doc.status_ = {&inquiry}  or                                                */
/*            not t-doc.flag_ and t-doc.status_ = {&wayb}     or                                                */
/*            t-doc.flag_ and t-doc.status_ = {&permitted}   ) and                                              */
/*            (not t-doc.internal or t-doc.doc-type = {&expense} and t-doc.internal)) or                        */
/*            /*накл+ внутреннего прихода*/                                                                     */
/*            (t-doc.doc-type = {&income} and t-doc.internal and t-doc.status_ = {&wayb} and t-doc.flag_) or    */
/*            /*запр- внутреннего прихода*/                                                                     */
/*            (t-doc.doc-type = {&income} and t-doc.internal and t-doc.status_ = {&inquiry} and not t-doc.flag_)*/
/*            then                                                                                              */
/*         enable b-bc with frame {&frame-name}.                                                                */
/*    end.                                                                                                      */
    assign edo-return .
    { str/tdat-wrt.i
      t-doc.doc-code
      {&trdcattr-edo-return}
      string(edo-return)
    }
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME is-cons
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL is-cons d-out-doc
ON VALUE-CHANGED OF is-cons IN FRAME d-out-doc /* консигнация */
DO:
  run val-chg-is-cons.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME is-oldcons
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL is-oldcons d-out-doc
ON VALUE-CHANGED OF is-oldcons IN FRAME d-out-doc /* ст. консигн. */
DO:
  run val-chg-is-oldcons.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME is-repay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL is-repay d-out-doc
ON VALUE-CHANGED OF is-repay IN FRAME d-out-doc /* выкуп */
DO:
  run val-chg-is-repay.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME is-storage
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL is-storage d-out-doc
ON VALUE-CHANGED OF is-storage IN FRAME d-out-doc /* отв.хран. */
DO:
  run val-chg-is-storage.
END.

on value-changed of t-doc.discnt-type in frame d-out-doc
do:
define variable g#log as logical   no-undo .
g#log = no.
run check-discnt no-error.
if error-status:error then return no-apply.
do transaction:
   run ch-discnt no-error.
   if return-value = "error" then do:
      if t-doc.discnt-type = {&percent} then do:
         run ui-on ("enable").
         apply "entry" to t-doc.discnt-pc in frame {&frame-name}.
         return no-apply.
      end.
      else undo, leave.
   end.
end. /*transaction*/
/*Чтобы в случае отката транзакции вернуть истинное значение в экранной форме*/
display t-doc.discnt-type with frame {&frame-name}.
run ui-on ("enable").
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-reas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-reas d-out-doc
ON CHOOSE OF r-reas IN FRAME d-out-doc /* r-acc */
DO:
  run select-reason in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-doc.shift-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-doc.shift-date d-out-doc
ON return OF t-doc.shift-date IN FRAME d-out-doc /* Смена */
DO: /* Секция триггеров обработки смены */
  apply "entry" to t-doc.shift-name in frame {&frame-name}.
  return no-apply.
end.

on return of t-doc.shift-name in frame {&frame-name} do:
  apply "entry" to b-add in frame {&frame-name}.
  return no-apply.
end.

on return of t-doc.shift-num in frame {&frame-name} do:
  apply "entry" to b-add in frame {&frame-name}.
  return no-apply.
end.

on choose of r-sht in frame {&frame-name} do:
  run proc-sht.
end.

on leave of t-doc.shift-num  in frame {&frame-name} do:
  run proc-shift-num no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.

on leave of t-doc.shift-name in frame {&frame-name} do:
  run proc-shift-name no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.

on leave of t-doc.shift-date in frame {&frame-name} do:
  if input frame {&frame-name} t-doc.shift-date <> t-doc.shift-date then do:
    assign
      t-doc.shift-name = ""
      t-doc.shift-num  = 0.
    display t-doc.shift-name t-doc.shift-num with frame {&frame-name}.
    apply "entry" to t-doc.shift-name in frame {&frame-name}.
    return no-apply.
  end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varpurch-chs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varpurch-chs d-out-doc
ON VALUE-CHANGED OF varpurch-chs IN FRAME d-out-doc
DO:
    define variable varchs-tg as logical no-undo.
  if varpurch-chs <> input frame {&frame-name} varpurch-chs then do:
    assign
      frame {&frame-name} varpurch-chs.
    if varpurch-chs = 0 then do:
      { str/tdat-wrt.i
          t-doc.doc-code
          {&trdcattr-purchlimit}
          "'no':U"
      }
      assign
        varchs-tg = no.
      if is-repay = no then do:
        assign
          is-repay  = yes
          varchs-tg = yes.
      end.
      if is-cons = no then do:
        assign
          is-cons   = yes
          varchs-tg = yes.
      end.
      if is-storage = no then do:
        assign
          is-storage  = yes
          varchs-tg = yes.
      end.
      if is-oldcons = no then do:
        assign
          is-oldcons  = yes
          varchs-tg = yes.
      end.
      if varchs-tg = yes then do:
        { str/tdat-wrt.i
            t-doc.doc-code
            {&trdcattr-purchcodelist}
            {&purchase-codes}
        }
        display is-repay is-cons is-storage is-oldcons with frame {&frame-name}.
      end.
      disable is-repay is-cons is-storage is-oldcons with frame {&frame-name}.
    end.
    else do:
      { str/tdat-wrt.i
          t-doc.doc-code
          {&trdcattr-purchlimit}
          "'yes':U"
      }
      enable is-repay is-cons is-storage is-oldcons with frame {&frame-name}.
    end.
    display varpurch-chs with frame {&frame-name}.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-out-doc


/* ************************  control triggers  ************************ */
define menu m-ptrl
    menu-item m-ptrl-1   label "Создать документы сверки и зафиксировать  книжное кол-во"  accelerator "alt-1"
    menu-item m-ptrl-2   label "Удалить документы сверки и расфиксировать книжное кол-во"  accelerator "alt-2".
{ gbl/f2.i br-dtl " " " " parparentproc }
{ gbl/hot-key.i b-mark }
{ str/sch-line.i doc-line br-dtl " " " " out-doc }

IF mImagePh THEN
DO:
    DEFINE VARIABLE vImageList AS LONGCHAR    NO-UNDO.
    DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
if AVAILABLE goods then do:
    RUN gds-attr-value ( goods.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
    RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, goods.gds-code, OUTPUT vImageList).
    vCh = ENTRY (1, vImageList, {&ImageDelimiter}).
    g-image:LOAD-IMAGE (ENTRY (1, vCh)) NO-ERROR.
    ASSIGN
        g-image:HIDDEN     = NO
        g-image:VISIBLE    = YES
        g-image:SENSITIVE  = YES
        .
end.        
END.
ELSE
    ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .
end.

on end-error of gds-dtl.doc-qnty in browse {&browse-name} do:
  display gds-dtl.doc-qnty with browse {&browse-name}.
  return no-apply.
end.

on end-error of ub.gds-dtl.fact-qnty in browse {&browse-name} do:
  display ub.gds-dtl.fact-qnty with browse {&browse-name}.
  return no-apply.
end.
Tree = ObjSrv:Lib:MarkingTree .     
  Marking = ObjSrv:Env:Marking:Sts:Mark .
/* общие триггеры и процедуры для РН и ПН */
{ str/trn-tr.i out }
on return, leave of t-doc.tot-calc in frame {&frame-name} do:
if input frame {&frame-name} t-doc.tot-calc <> t-doc.tot-calc then do:
  assign t-doc.tot-calc = input frame {&frame-name} t-doc.tot-calc.
  run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
  if error-status :error then undo, return no-apply.
  run ui-on ("line").
end.
end.

on return, leave of t-doc.discnt-rubl in frame {&frame-name} do:
  if input frame {&frame-name} t-doc.discnt-rubl <> t-doc.discnt-rubl then do:
    assign
      frame {&frame-name} t-doc.discnt-rubl.
    run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
    if error-status :error then do:
      undo, return no-apply.
    end.
    run ui-on ("line").
  end.
end.


on mouse-select-dblclick, return of t-doc.out-code in frame {&frame-name}
do:
define buffer tdb_doc-line for ub.doc-line.
define buffer tdb_gds-dtl  for ub.gds-dtl.
find t-d-b where t-d-b.doc-code = input frame {&frame-name} t-doc.out-code no-lock no-error.
if not available t-d-b then do:
  apply "choose" to r-outs in frame {&frame-name}.
  return no-apply.
end.


run ask-copy in this-procedure no-error .
if error-status :error then return no-apply .
end.

on choose of menu-item m-outs-1 do:
if not b-add:sensitive in frame {&frame-name} then do:
  message "Добавление строк для этого статуса запрещено.".
  return no-apply.
end.
/*Не убирать. Иначе не обновляются поля в updateble browse*/
apply "row-leave" to browse {&browse-name}.
if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
then do :
  if t-doc.reason-code <> ?
  and t-doc.reason-code > 0
  then do :
    if lookup( string(t-doc.reason-code), v-reasons-for-return) > 0
    and t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
    then do :
      /*Возврат*/
      if v-is-return
      then do :
        run local-outs-ret-doc no-error.
        if error-status :error then undo, return no-apply.
      end .
      else do :
        run local-m-outs-1-ret no-error.
        if error-status :error then undo, return no-apply.
      end .
    end.
    else do :
      run local-m-outs-1 no-error.
      if error-status :error then undo, return no-apply.
    end.
  end.
  else do :
    if v-reasonm and
    lookup( t-doc.ext-doc-type, v-reasonme) = 0 and
    lookup( t-doc.ext-doc-type, {&TDEDT_List-not-ver-reason}) = 0
    then do:
      message "Сначала укажите Основание" view-as alert-box .
      apply "choose" to r-reas in frame {&frame-name}.
    end.
    else do :
      run local-m-outs-1 no-error.
      if error-status :error then undo, return no-apply.
    end.
  end.
end.
else do :
  /* Список документов по объекту */
  run local-m-outs-1 no-error.
  if error-status :error then undo, return no-apply.
  if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}  then do:
     run str/ep-corrp.p (input parparentproc, input t-doc.doc-code ) no-error.
  end.
end.
run ui-on ("line").
apply "entry" to br-dtl in frame {&frame-name}.
end.

on choose of menu-item m-outs-10 
  do:
    define variable old-mode     as character no-undo.
    define variable old-handle   as handle    no-undo.
    define variable old-type     as character no-undo.
    define variable old-stat     as character no-undo.
    define variable old-flag     as logical   no-undo.
    define variable old-internal as logical   no-undo.
    if not b-add:sensitive in frame {&frame-name} then 
    do:
      message "Добавление строк для этого статуса запрещено.".
      return no-apply.
    end.
    /*Не убирать. Иначе не обновляются поля в updateble browse*/
    apply "row-leave" to browse {&browse-name}.
    /* Список товаров */
    do transaction:
      run check-rate no-error.
      if error-status :error then return no-apply.
      run str/gds-list.w (parparentproc, t-doc.host-code, t-doc.obj-type, t-doc.obj-code).
      pardoc-rec = recid (t-doc).   /* ломается в gds-list.w */
      run waitfram-show in this-procedure (input "ЖДИТЕ.  Список добавляется в документ...").
      run copy-lst in this-procedure (
        input t-doc.doc-code,
        input ub.sysconf.cash-pay,
        input v-cntxp-doc-prt,
        input table gds-list,
        input "tech-marks")
        no-error.
      if error-status :error then 
      do:
        apply "entry" to b-add in frame {&frame-name}.
        run waitfram-hide in this-procedure .
        return no-apply.
      end.
      run waitfram-hide in this-procedure .
      run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
      if error-status :error then 
      do:
        undo, return no-apply.
      end.
    end. /*transaction*/
    pardoc-mode = {&update}.
    run ui-on ("line").
    apply "entry" to br-dtl in frame {&frame-name}.
  end.

on choose of menu-item m-outs-5 do:
if not b-add:sensitive in frame {&frame-name} then do:
  message "Добавление строк для этого статуса запрещено.".
  return no-apply.
end.
/*Не убирать. Иначе не обновляются поля в updateble browse*/
apply "row-leave" to browse {&browse-name}.
/* Список документов по объекту */
run local-m-outs-5 no-error.
if error-status :error then undo, return no-apply.
if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}  then do:
   run str/ep-corrp.p (input parparentproc, input t-doc.doc-code ) no-error.
end.
run ui-on ("line").
apply "entry" to br-dtl in frame {&frame-name}.
end.


on choose of menu-item m-outs-2 do:
/*Не убирать. Иначе не обновляются поля в updateble browse*/
apply "row-leave" to browse {&browse-name}.
/* Мобильный сканер */
do transaction :
   if b-add:sensitive in frame {&frame-name} then do:
      run check-rate no-error.
      if error-status :error then return no-apply.
   end.
   /* #2785 */
   /*if pardoc-mode = {&update} then do:
     run prescan in this-procedure (input recid(t-doc)) no-error.
     if error-status :error then do:
       message "Ошибка при установке фактического количества перед сканированием." skip
            return-value
       view-as alert-box error.
       undo, return no-apply.
     end.
   end.*/
   run str/scan.p (parparentproc, b-add:sensitive , input recid(t-doc)  , input ?) no-error.
   if error-status :error then undo, return no-apply.
   if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}  then do:
      run str/ep-corrp.p ( input parparentproc, input t-doc.doc-code ) no-error.
    end.
   else do:
      run gbl/calc-trn.p ( input parparentproc, input recid(t-doc)) no-error.
   end.
   if error-status :error then do:
     undo, return no-apply.
   end.
end.
run ui-on ("line").
if prt-rec <> ? then reposition br-dtl to recid prt-rec no-error.
apply "entry" to br-dtl in frame {&frame-name}.
end.

on choose of menu-item m-outs-3 do:
define variable old-mode     as   character         no-undo.
define variable old-handle   as   handle            no-undo.
define variable old-type     as   character         no-undo.
define variable old-stat     as   character         no-undo.
define variable old-flag     as   logical           no-undo.
define variable old-internal as   logical           no-undo.
if not b-add:sensitive in frame {&frame-name} then do:
  message "Добавление строк для этого статуса запрещено.".
  return no-apply.
end.
/*Не убирать. Иначе не обновляются поля в updateble browse*/
apply "row-leave" to browse {&browse-name}.
/* Список товаров */
do transaction:
   run check-rate no-error.
   if error-status :error then return no-apply.
   varlog = yes.
   message "Добавить товары из списка в заполняемый документ ?" skip (2)
           "- добавляются, если доступны, ВСЕ ФАКТ количества по списку с текущего объекта;" skip
           "- цены ставятся текущие по объекту (кроме возврата поставщику и перемещения по цене магазина);" skip
           "- если цены нет или количество 0, товар пропускается."
                  view-as alert-box question buttons OK-Cancel update varlog.
   if varlog <> true then return no-apply.
   run str/gds-list.w (parparentproc, t-doc.host-code, t-doc.obj-type, t-doc.obj-code).
   pardoc-rec = recid (t-doc).   /* ломается в gds-list.w */
   run waitfram-show in this-procedure (input "ЖДИТЕ.  Список добавляется в документ...").
   run copy-lst in this-procedure (
     input t-doc.doc-code,
     input ub.sysconf.cash-pay,
     input v-cntxp-doc-prt,
     input table gds-list,
     input "")
     no-error.
   if error-status :error then do:
     apply "entry" to b-add in frame {&frame-name}.
     run waitfram-hide in this-procedure .
     return no-apply.
   end.
   run waitfram-hide in this-procedure .
   run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
   if error-status :error then do:
     undo, return no-apply.
   end.
end. /*transaction*/
pardoc-mode = {&update}.
run ui-on ("line").
apply "entry" to br-dtl in frame {&frame-name}.
end.

on choose of menu-item m-outs-6 do:
define variable old-mode     as   character         no-undo.
define variable old-handle   as   handle            no-undo.
define variable old-type     as   character         no-undo.
define variable old-stat     as   character         no-undo.
define variable old-flag     as   logical           no-undo.
define variable old-internal as   logical           no-undo.
if not b-add:sensitive in frame {&frame-name} then do:
  message "Добавление строк для этого статуса запрещено.".
  return no-apply.
end.
/*Не убирать. Иначе не обновляются поля в updateble browse*/
apply "row-leave" to browse {&browse-name}.
/* Список товаров */
do transaction:
   run check-rate no-error.
   if error-status :error then return no-apply.
   varlog = yes.
   message "Добавить партии из списка кодов  в заполняемый документ ?" skip (2)
           "- добавляются, если доступны, ВСЕ ФАКТ количества по списку с текущего объекта;" skip
           "- цены ставятся текущие по объекту (кроме возврата поставщику и перемещения по цене магазина);" skip
           "- если цены нет или количество 0, товар пропускается."
                  view-as alert-box question buttons OK-Cancel update varlog.
   if varlog <> true then return no-apply.
   run str/bb-list.w (parparentproc, t-doc.obj-type, t-doc.obj-code , "" ).
   pardoc-rec = recid (t-doc).   /* ломается в gds-list.w */
   run waitfram-show in this-procedure (input "ЖДИТЕ.  Список добавляется в документ...").

   run copy-bb-list in this-procedure no-error .
   if error-status :error then do:
     apply "entry" to b-add in frame {&frame-name}.
     run waitfram-hide in this-procedure .
     return no-apply.
   end.
   run waitfram-hide in this-procedure .
end. /*transaction*/
pardoc-mode = {&update}.
run ui-on ("line").
apply "entry" to br-dtl in frame {&frame-name}.
end.

on choose of menu-item m-outs-4 do:
varlog = no.
 message "Обнулить ФАКТ количества в документе ?"
         view-as alert-box question buttons yes-no update varlog.
if varlog then
do transaction :
   for each ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code:
     ub.doc-line.fact-qnty = 0.
   end.
   for each ub.gds-dtl where ub.gds-dtl.doc-code = t-doc.doc-code:
     ub.gds-dtl.fact-qnty = 0.
   end.
   for each ub.parts where ub.parts.out-code = t-doc.doc-code:
     ub.parts.fact-qnty = 0.
   end.
   for each ub.inv-line where ub.inv-line.doc-code = t-doc.doc-code:
     assign ub.inv-line.after-cli-qnty = ub.inv-line.after-cli-qnty - ub.inv-line.wast-cli-qnty
            ub.inv-line.wast-cli-qnty  = 0.
   end.
   run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
   if error-status :error then do:
     undo, return no-apply.
   end.
end.
else return no-apply.
run ui-on ("line").
apply "entry" to br-dtl in frame {&frame-name}.
end.


on choose of menu-item m-outs-8
do:
  {&stdbtn}
  if (t-doc.status_ = {&wayb} or t-doc.status_ = {&inquiry})
  then do:
    run proc-m-outs-8 in this-procedure no-error.
  end.
  else do:
/*    run err-status in this-procedure.*/
    return no-apply.
  end.
end.

on choose of menu-item m-outs-9
  do:
    if not b-add:sensitive in frame {&frame-name} then 
    do:
      message "Добавление строк для этого статуса запрещено.".
      return no-apply.
    end.
    /*Не убирать. Иначе не обновляются поля в updateble browse*/
    apply "row-leave" to browse {&browse-name}.
    
    run proc-m-outs-9 in this-procedure no-error.
  end.

on choose of menu-item m-ap-1 in menu m-acc_price  /*Простановка учетных цен без налогов*/
do:
  run local-cur in this-procedure ( input 1 ) no-error.
  if error-status :error then do: return no-apply. end.
  run UI-on in this-procedure ( input "enable" ).
end.

on choose of menu-item m-ap-2 in menu m-acc_price  /*Простановка учетных цен с налогами*/
do:
run local-cur in this-procedure (input 2) no-error.
if error-status :error then return no-apply.
run UI-on ("enable").
end.

on choose of menu-item m-ap-3 in menu m-acc_price  /*Простановка учетных цен с нулевыми налогами*/
do:
run local-cur in this-procedure (input 3) no-error.
if error-status :error then return no-apply.
run UI-on ("enable").
end.

on choose of menu-item m-fp-1 in menu m-fixprice
do:
 if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} then do:
   message "В возврате поставщику цены всегда определяются возвращаемыми партиями." view-as alert-box.
   return no-apply.
 end.

 if available ub.gds-dtl then do:
   assign prt-rec = recid(ub.gds-dtl).
 end.
 else do:
   assign prt-rec = ?.
 end.
 define buffer bf_gds-dtl for ub.gds-dtl.
 assign varlog = no.
 message "Если Вы зафиксируете цены, то при изменении цены в прайс-листе до закрытия документа она не проставится в документ." skip
         "Вы уверены?" view-as alert-box buttons yes-no update varlog.
 if varlog = yes then do:
   for each bf_gds-dtl where bf_gds-dtl.doc-code = t-doc.doc-code on error undo, return no-apply :
     assign
       bf_gds-dtl.ov = yes.
   end.
 end.
 run ui-on ("line").
 if prt-rec <> ?  then do:
   reposition br-dtl to recid prt-rec no-error.
 end.
end.

on choose of menu-item m-fp-2 in menu m-fixprice
do:
 if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} then do:
   message "В возврате поставщику цены всегда определяются возвращаемыми партиями." view-as alert-box.
   return no-apply.
 end.
 if available ub.gds-dtl then do:
   assign prt-rec = recid(ub.gds-dtl).
 end.
 else do:
   assign prt-rec = ?.
 end.
 define buffer bf_gds-dtl for ub.gds-dtl.
 assign varlog = no.
 message "Если Вы расфиксируете цены, то при изменении цены в прайс-листе до закрытия документа она проставится в документ." skip
         "Вы уверены?" view-as alert-box buttons yes-no update varlog.
 if varlog = yes then do:
   for each bf_gds-dtl where bf_gds-dtl.doc-code = t-doc.doc-code on error undo, return no-apply :
     assign
       bf_gds-dtl.ov = no.
   end.
 end.
 run ui-on ("line").
 if prt-rec <> ?  then do:
   reposition br-dtl to recid prt-rec no-error.
 end.
end.

on choose of menu-item m-ptrl-1 in menu m-ptrl do:
  {&stdbtn}

  apply "row-leave" to browse {&browse-name}.

  run cr-rvs-doc in this-procedure
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

  run UI-on in this-procedure ( input "line" ).

end.

on choose of menu-item m-ptrl-2 in menu m-ptrl do:
  {&stdbtn}

  apply "row-leave" to browse {&browse-name}.

  run del-rvs-doc in this-procedure
    ( input parparentproc
     ,input t-doc.doc-code
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при удалении документов сверок.") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.

  run UI-on in this-procedure ( input "line" ).

end.

assign
  br-dtl :num-locked-columns in frame {&frame-name} = 3
  frame {&frame-name} :scrollable = no
  r-outs     :popup-menu in frame {&frame-name} = menu m-outs :handle
  r-outs     :menu-mouse = 1
  b-cur      :popup-menu in frame {&frame-name} = menu m-acc_price :handle
  b-cur      :menu-mouse = 1
  b-fixprice :popup-menu in frame {&frame-name} = menu m-fixprice :handle
  b-fixprice :menu-mouse = 1
  b-revis    :popup-menu in frame {&frame-name} = menu m-ptrl :handle
  b-revis    :menu-mouse = 1
  b-print:popup-menu in frame {&frame-name}   = menu m-print:handle
  b-print:menu-mouse                          = 1
.
assign
  r-reas            :tooltip in frame {&FRAME-NAME} = "Основание (причина) создания документа"
  t-doc.reason-code :tooltip in frame {&FRAME-NAME} = "Основание (причина) создания документа"
  rsn-name          :tooltip in frame {&FRAME-NAME} = "Основание (причина) создания документа"
.

/* ***************************  Main Block  *************************** */

if valid-handle(active-window) and frame {&frame-name}:parent eq ?
then frame {&frame-name}:parent = active-window.

on window-close of frame {&frame-name} apply "end-error":u to self.

/*run gbl/inidebug.p.*/
{ gbl/app_help.i }
{ gbl/ed_date.i t-doc.fact-date }
{ gbl/ed_date.i t-doc.doc-date }

{ gbl/conf-rd.i  "'is-ptrl'" "''" "''" 0 "''" "''" "''" no v-is-ptrl v-data-type no-error }
if error-status :error or v-data-type <> "L" or lookup( v-is-ptrl, "yes,no" ) = 0 then do:
  assign
    v-is-ptrl = "no"
  .
end.
TEXT-RUBL = "{&abbr_rub_allshift }" .
t-doc.print-rubl:label = "{&abbr_rubli}".
display  TEXT-RUBL with frame {&frame-name} .
t-doc.discnt-type:list-items in frame {&frame-name}  = {&d-type-list} .
/* если нет МПЛ то прайс-листа не должно быть */
define variable only-main-pl as logical   no-undo .
{ gbl/glstmain.i only-main-pl}
if only-main-pl = true then do:
   hide b-re-price in frame {&frame-name} .
   t-doc.discnt-type:list-items in frame {&frame-name}  = "{&bef-percent},{&bef-card},{&bef-group},{&bef-amount},{&bef-row}" .
end.


{ gbl/conf-rd.i
  "'mercuri':u"
  "'':u"
  "'':u"
  0
  "'':u"
  "'':u"
  "'':u"
  no
  v-mercury-value
  v-mercury-type
  no-error
}
hbrowse = browse br-dtl:handle.
extent (bcol) = hbrowse:num-columns.
bcol[1] = hbrowse:first-column.
do ii = 1 to extent (bcol).  
  bcol[ii] = hbrowse:get-browse-column (ii).
end.
assign
  v-gds-name:resizable in browse {&browse-name}   = true
  v-gds-name:width     in browse {&browse-name}   = 40
  d-kg-after-qnty :visible in browse {&browse-name} = ( v-is-ptrl = "yes" )
  d-kg-fact-qnty  :visible in browse {&browse-name} = ( v-is-ptrl = "yes" )
  d-kg-price-base :visible in browse {&browse-name} = ( v-is-ptrl = "yes" )
  d-kg-price-rubl :visible in browse {&browse-name} = ( v-is-ptrl = "yes" )
.

  { gbl/srt-clmn.i
    &ext-col              = 23
    &frame-name           = {&frame-name}
    &browse-name          = {&browse-name}
    &table-name           = "ub.gds-dtl"
    &start-column         = 4
    &label-clmn_1         = "{&label-clmn_1-br-dtl}"
    &sort-clmn_1          = "{&sort-clmn_1-br-dtl}"
    &label-clmn_2         = "{&label-clmn_2-br-dtl}"
    &sort-clmn_2          = "{&sort-clmn_2-br-dtl}"
    &label-clmn_3         = "{&label-clmn_3-br-dtl}"
    &sort-clmn_3          = "{&sort-clmn_3-br-dtl}"
    &label-clmn_4         = "{&label-clmn_4-br-dtl}"
    &sort-clmn_4          = "{&sort-clmn_4-br-dtl}"
    &label-clmn_5         = "{&label-clmn_5-br-dtl}"
    &sort-clmn_5          = "{&sort-clmn_5-br-dtl}"
    &label-clmn_6         = "{&label-clmn_6-br-dtl}"
    &sort-clmn_6          = "{&sort-clmn_6-br-dtl}"
    &label-clmn_7         = "{&label-clmn_7-br-dtl}"
    &sort-clmn_7          = "{&sort-clmn_7-br-dtl}"
    &label-clmn_8         = "{&label-clmn_8-br-dtl}"
    &sort-clmn_8          = "{&sort-clmn_8-br-dtl}"
    &label-clmn_9         = "{&label-clmn_9-br-dtl}"
    &sort-clmn_9          = "{&sort-clmn_9-br-dtl}"
    &label-clmn_10        = "{&label-clmn_10-br-dtl}"
    &sort-clmn_10         = "{&sort-clmn_10-br-dtl}"
    &label-clmn_11        = "{&label-clmn_11-br-dtl}"
    &sort-clmn_11         = "{&sort-clmn_11-br-dtl}"
    &label-clmn_12        = "{&label-clmn_12-br-dtl}"
    &sort-clmn_12         = "{&sort-clmn_12-br-dtl}"
    &label-clmn_13        = "{&label-clmn_13-br-dtl}"
    &sort-clmn_13         = "{&sort-clmn_13-br-dtl}"
    &label-clmn_14        = "{&label-clmn_14-br-dtl}"
    &sort-clmn_14         = "{&sort-clmn_14-br-dtl}"
    &label-clmn_15        = "{&label-clmn_15-br-dtl}"
    &sort-clmn_15         = "{&sort-clmn_15-br-dtl}"
    &label-clmn_16        = "{&label-clmn_16-br-dtl}"
    &sort-clmn_16         = "{&sort-clmn_16-br-dtl}"
    &label-clmn_17        = "{&label-clmn_17-br-dtl}"
    &sort-clmn_17         = "{&sort-clmn_17-br-dtl}"
    &label-clmn_18        = "{&label-clmn_18-br-dtl}"
    &sort-clmn_18         = "{&sort-clmn_18-br-dtl}"
    &label-clmn_19        = "{&label-clmn_19-br-dtl}"
    &sort-clmn_19         = "{&sort-clmn_19-br-dtl}"
    &label-clmn_20        = "{&label-clmn_20-br-dtl}"
    &sort-clmn_20         = "{&sort-clmn_20-br-dtl}"
    &label-clmn_21        = "{&label-clmn_21-br-dtl}"
    &sort-clmn_21         = "{&sort-clmn_21-br-dtl}"
    &label-clmn_22        = "{&label-clmn_22-br-dtl}"
    &sort-clmn_22         = "{&sort-clmn_22-br-dtl}"
    &label-clmn_23        = "{&label-clmn_23-br-dtl}"
    &sort-clmn_23         = "{&sort-clmn_23-br-dtl}"
    &label-clmn_24        = "{&label-clmn_25-br-dtl}"
    &sort-clmn_24         = "{&sort-clmn_25-br-dtl}"
    &label-clmn_25        = "{&label-clmn_26-br-dtl}"
    &sort-clmn_25         = "{&sort-clmn_26-br-dtl}"
    &open-query           = "{&open-query-{&browse-name}}  by ~{&sort-clmn_~{&clmn_num~}~}  "
    &open-query-otherwise = "{&open-query-{&browse-name}} by {&sort-clmn_2-br-dtl} .  "
    &re-move-clmn         = "yes"
    &mv-brw-default       = "yes"
}
{ gbl/mv-clmn.i
    &ext-col              = 23
    &frame-name           = {&frame-name}
    &browse-name          = {&browse-name}
    &table-name           = "gds-dtl"
    &start-column         = 4
}
assign
  parext-doc-mode =
    ( if num-entries( pardoc-mode, '{&delim-flt}':U ) > 1 then entry( 2, pardoc-mode, '{&delim-flt}':U ) else '':U )
  pardoc-mode     = entry( 1, pardoc-mode, '{&delim-flt}':U )
.

/* зацикливание формы */
assign
  parnext-prev = yes
.
n-p:
do while parnext-prev :
main-block:
do on error   undo main-block, leave main-block :
assign 
   {&browse-name}:column-resizable in frame {&frame-name} = true.  
if available t-doc then do:
  find ub.sysconf where ub.sysconf.host-code = t-doc.host-code no-lock.
end.
else do:
  find ub.sysconf where ub.sysconf.host-code = v-cntxt-host-code-obj no-lock.
end.
{ gbl/conf-rd.i "'is-prt'"   0 "''" 0 "''" "''" "''" yes prtvalue      prttype        no-error }
{ gbl/conf-rd.i "'holding'"  0 "''" 0 "''" "''" "''" no  varhold       varhold-type   no-error }
{ gbl/conf-rd.i "'is-tsd'"   0 "''" 0 "''" "''" "''" no  v-is-tsd     v-is-tsd-type no-error }
{ gbl/getsect.i run "''" 0 {&attr-nakl-glob} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'is-bcdoc' then bcvalue = string(thbjattr_thbj-attr.property-value-logical) .
end.
{ gbl/getsect.i run v-cntxt-obj-type v-cntxt-obj-code {&attr-nakl_par} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = {&attr-nakl_par_reasonm}   then v-reasonm      = thbjattr_thbj-attr.property-value-logical .
    if thbjattr_thbj-attr.prop-code = {&attr-nakl_par_reasonme}  then v-reasonme     = thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = {&attr-nakl_par_reasons-for-return}  then v-reasons-for-return = thbjattr_thbj-attr.property-value-character .
end.
{ gbl/conf-rd.i "'is-pharm'" v-cntxt-host-code-obj v-cntxt-obj-type v-cntxt-obj-code "''" "''" "''" no  v-is-pharm    v-is-pharm-type no-error }

if v-is-pharm <> "yes" then do:
  assign
    v-is-pharm = "no"
  .
end.
else do:
  { str/opharm.i v-cntxt-obj-type v-cntxt-obj-code v-is-pharm }
end.

{ gbl/curr-r-b.i varr-b no-error }
 if error-status :error then do:
   assign
     parnext-prev = no.
   return error.
 end.
run mode-on in this-procedure no-error.
if error-status :error then do:
  assign
    parnext-prev = no.
  return error.
end.
{ gbl/hold-doc.i t-doc.doc-code is-doc-hold no-error }
if error-status :error or is-doc-hold = ? then do: assign is-doc-hold = no. end.
if v-is-tsd = "no" then do: menu-item m-outs-2 :sensitive in menu m-outs = no. end.
prev-pardoc-mode = pardoc-mode.
{ str/tdat-val.i
  t-doc.doc-code
  {&trdcattr-is-return}
  varvalue
  vartype
  no-error
}
if varvalue = "yes" then do:
  v-is-return = yes .
end.
EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t-doc.obj-type, t-doc.obj-code).

run ui-on in this-procedure ( input "enable" ) no-error.
if error-status :error then do:
  assign
    parnext-prev = no.
  return error.
end.
if prt-rec <> ? and pardoc-mode = {&lookup} then reposition br-dtl to recid prt-rec no-error.
if t-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem}
then do :
  disable r-outs with frame {&frame-name} .
end .
if t-doc.ext-doc-type = {&TDEDT_Pri_Perem} then 
do:
  menu-item m_no-marks:sensitive in menu m-marks = yes .
end.
else 
do:
  menu-item m_no-marks:sensitive in menu m-marks = no .
end.
      if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or
         t-doc.ext-doc-type = {&TDEDT_Pri_Perem} then 
      do:
        menu-item m_add-marks:sensitive in menu m-marks = no.
/*        menu-item m_del-marks:sensitive in menu m-marks = no.*/
      end .  
      
      if pardoc-mode = {&lookup} or t-doc.status_  <> {&wayb} and t-doc.status_ <> {&inquiry} then 
      do:
        menu-item m_add-marks:sensitive in menu m-marks = no.
/*        menu-item m_del-marks:sensitive in menu m-marks = no.*/
      end.
      
      if pardoc-mode = {&add-def} 
      and t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
      then do :
        message "Выполнить возврат поставщику?" view-as alert-box question buttons yes-no update varlog .
        if varlog
        then do :
          { str/tdat-wrt.i                                    
           t-doc.doc-code
           {&trdcattr-is-return}
           "yes" 
          no-error}
        end .
      end .
      
      { str/tdat-val.i
        t-doc.doc-code
        {&trdcattr-is-return}
        varvalue
        vartype
        no-error
      }
      if varvalue = "yes" then do:
        v-is-return = yes .
/*        menu-item m_add-marks:sensitive in menu m-marks = no.*/
/*        menu-item m_del-marks:sensitive in menu m-marks = no.*/
        disable b-bc with frame {&frame-name} .
        gds-dtl.doc-qnty:read-only in browse br-dtl = yes .
        gds-dtl.fact-qnty:read-only in browse br-dtl = yes .
      end.
      
      if v-is-return
      and pardoc-mode = {&add-def}
      then do :
        apply "choose" to r-clients in frame {&frame-name} .
        
        if t-doc.cli-code = ?
        then do :
          run proc-exit no-error .
          assign
            parnext-prev = no.
          return error.
        end .
        
        find first reas_contract where reas_contract.host-code     = t-doc.host-code  and
                                       reas_contract.contract-code = t-doc.contract-code no-lock no-error.
        if available reas_contract
        then do :                               
          find first trn-reason no-lock where trn-reason.reason-code = reas_contract.spec-check no-error.
          if available trn-reason then 
          do trans:
            assign  
              rsn-name          = trn-reason.reason-name
              t-doc.reason-code = trn-reason.reason-code
            .
            display t-doc.reason-code rsn-name with frame {&FRAME-NAME}.
            disable r-reas r-clients t-doc.cli-code b-cur r-outs with frame {&frame-name}.
          end .
          find first buf_contract-attr no-lock where buf_contract-attr.host-code = reas_contract.host-code
                                                 and buf_contract-attr.contract-code = reas_contract.contract-code
                                                 and buf_contract-attr.attr-code = "contract-edi"
                                                 no-error .
          if available buf_contract-attr
          and logical(buf_contract-attr.attr-value) = true
          then do :
            is-contract-edo = yes .
          end .
          else do :
            find first buf_contract-attr no-lock where buf_contract-attr.host-code = reas_contract.host-code
                                                   and buf_contract-attr.contract-code = reas_contract.contract-code
                                                   and buf_contract-attr.attr-code = "contract-diadoc"
                                                   no-error .
            if available buf_contract-attr
            and logical(buf_contract-attr.attr-value) = true
            then do :
              is-contract-edo = yes .
            end .
          end . 
          
          if is-contract-edo
          and EDOParSec:IsEdo
          then do :
            edo-return = yes .
            { str/tdat-wrt.i
              t-doc.doc-code
              {&trdcattr-edo-return}
              "yes"
              no-error     }
            if error-status :error then 
            do:
              message error-status :error error-status :get-message( 1 ) '"' + {&trdcattr-edo-return} + '"'
                view-as alert-box error.
            end.
          end .
          else do :
            edo-return = no .
            { str/tdat-wrt.i
              t-doc.doc-code
              {&trdcattr-edo-return}
              "no"
              no-error     }
            if error-status :error then 
            do:
              message error-status :error error-status :get-message( 1 ) '"' + {&trdcattr-edo-return} + '"'
                view-as alert-box error.
            end.
          end .
        end .
      end .
      
      if v-is-return
      then do :
        if t-doc.contract-code > 0
        then do :
          find first reas_contract where reas_contract.host-code     = t-doc.host-code  and
                                         reas_contract.contract-code = t-doc.contract-code no-lock no-error.
          if available reas_contract
          then do :
            find first buf_contract-attr no-lock where buf_contract-attr.host-code = reas_contract.host-code
                                                   and buf_contract-attr.contract-code = reas_contract.contract-code
                                                   and buf_contract-attr.attr-code = "contract-edi"
                                                   no-error .
            if available buf_contract-attr
            and logical(buf_contract-attr.attr-value) = true
            then do :
              is-contract-edo = yes .
            end .
            else do :
              find first buf_contract-attr no-lock where buf_contract-attr.host-code = reas_contract.host-code
                                                     and buf_contract-attr.contract-code = reas_contract.contract-code
                                                     and buf_contract-attr.attr-code = "contract-diadoc"
                                                     no-error .
              if available buf_contract-attr
              and logical(buf_contract-attr.attr-value) = true
              then do :
                is-contract-edo = yes .
              end .
            end . 
            
            if is-contract-edo
            and EDOParSec:IsEdo
            then do :
              { str/tdat-val.i
                t-doc.doc-code
                {&trdcattr-edo-return}
                varvalue
                vartype
                no-error
              }
              if varvalue = "yes"
              then do:
                edo-return = yes .
                disable b-bc with frame {&frame-name}.
              end.
              else do :
                edo-return = no .
              end .
              display edo-return with frame {&frame-name}.
              if pardoc-mode <> {&lookup}
              then do :
                enable edo-return with frame {&frame-name}.
              end .
            end .
            else do :
              edo-return = no .
              display edo-return with frame {&frame-name}.
              disable edo-return with frame {&frame-name}.
            end .
          end .
        end .
        if pardoc-mode <> {&add-def}
        then do :
          disable r-reas r-clients t-doc.cli-code b-cur r-outs with frame {&frame-name}.
        end .
      end .
  /* Если внутренний приход или расход, то предустанавливаем "Прочие перемещения НП" = yes */    
  if pardoc-mode = {&add-def} and
     (t-doc.ext-doc-type = {&TDEDT_Pri_Perem} or
      t-doc.ext-doc-type = {&TDEDT_Ras_Perem}) then do:
      run create-record in this-procedure (  input t-doc.doc-code
                                           , input {&trdcattr-othermoves}
                                           , input "yes":U
                                           , output vExist ) .
  end.      
if pardoc-mode = {&add-def} then do:
  wait-for go of frame {&frame-name} focus t-doc.cli-code.
end.
else do:
  wait-for go of frame {&frame-name} focus br-dtl.
end.
end.
end. /* do while */
run disable_ui in this-procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-doc-line-local d-out-doc
PROCEDURE add-doc-line-local :
define buffer bf_contract-specif for ub.contract-specif.
define buffer bf-hv_doc-line     for ub.doc-line.
define buffer bf_goods           for ub.goods.
define variable varschartic like ub.doc-line.artic initial " " no-undo.
define variable v-choice    as   integer                    no-undo.
define variable v-rid       as   integer                    no-undo.
define variable v-rid-list  as   char                       no-undo.
define variable i           as   integer                    no-undo.

do on stop undo, return error return-value :
  run corr-t-doc in this-procedure no-error.
  if error-status:error then do:
    return error return-value.
  end.
  v-choice = 0.
  if t-doc.contract-code <> 0 then do:
    find first bf_contract-specif where bf_contract-specif.host-code    = ( if is-doc-hold then t-doc.cli-code  else t-doc.host-code )      and
                                        bf_contract-specif.contract-num = t-doc.contract-code no-lock no-error.
    if available bf_contract-specif then do:
      run gbl/d-askw.w
        (input "Добавление товаров"
        ,input "Выберите один из пунктов для добавления в накладную" + {&new-line}
             + "товаров по спецификации к договору" + {&new-line}
        ,input "|"
        ,input "Все|Выборочно|По справочнику|Отказ"
        ,input "Все недобавленные товары по спецификации|"
             + "Выборочно товары по спецификации|"
             + "Выбор товаров из справочника|"
             + "Отказ от выполнения операции"
        ,input 1 /* значение возвращаемое при нажатии enter */
        ,input 4 /* значение возвращаемое при нажатии escape */
        ,output v-choice
        ).
      if v-choice = 4 then do:
        run UI-on in this-procedure ( input "line" ).
        return.
      end.
    end.
  end.
  if v-choice = 0 then
    v-choice = 3. /* Выбор из справочника */
define variable  varnotes  as character no-undo .
  assign
    /*line-mode = {&add-def}*/
    varnotes = '':u
    varlns-cnt = 1.

  case v-choice:
    when 1 then do: /* Все товары по спецификации */
      for each bf_contract-specif where bf_contract-specif.host-code    = ( if is-doc-hold then t-doc.cli-code  else t-doc.host-code )      and
                                        bf_contract-specif.contract-num = t-doc.contract-code no-lock
          on error undo, return error return-value :
        find first bf_goods where bf_goods.gds-code = bf_contract-specif.gds-code no-lock.
        find first bf-hv_doc-line where bf-hv_doc-line.doc-code  = t-doc.doc-code     and
                                        bf-hv_doc-line.artic     = bf_goods.artic     and
                                        bf-hv_doc-line.prod-type = bf_goods.prod-type and
                                        bf-hv_doc-line.prod-code = bf_goods.prod-code no-lock no-error.
        if not available bf-hv_doc-line then do:
          assign
            varnotes = varnotes + (if varnotes = '':u then '':u else ',':u) + string(recid(bf_goods)).
        end.
      end.
      if varnotes = '':u then do:
        message "Вы добавили уже все товары по спецификации."
        view-as alert-box.
      end.
    end.

    when 2 then do: /* Выборочно товары по спецификации */
      run str/contspec.w (input parparentproc,
                      input "b-sel,b-mark",
                      input {&lookup},
                      input ( if is-doc-hold then t-doc.cli-code  else t-doc.host-code ) ,
                      input t-doc.contract-code,
                      output v-rid-list) .
      if v-rid-list = '':u then do:
        message "Нет выбранных товаров по спецификации."
          view-as alert-box.
      end.
      /* Формируем список recid'ов товаров по выбранным строкам спецификации */
      do i = 1 to num-entries(v-rid-list):
        v-rid = integer(entry(i, v-rid-list)).

        find bf_contract-specif where recid(bf_contract-specif) = v-rid no-lock no-error.
        if available bf_contract-specif then do:
          find first bf_goods where bf_goods.gds-code = bf_contract-specif.gds-code no-lock.
          assign
            varnotes = varnotes + (if varnotes = '':u then '':u else ',':u) + string(recid(bf_goods)).
        end.
      end.
    end.

    when 3 then do: /* из справочника */
      run str/chs-gds.w ( input parparentproc
                    , input v-cntxt-obj-type
                    , input v-cntxt-obj-code
                    , input parlist-mode
                    , input t-doc.status_
                    , input "Строка ПН № " + t-doc.doc-code + " " + t-doc.status_ + " " + string (t-doc.flag_, "+/-")
                    , {&fact} /*режим вызова справочника товаров*/
                    , input t-doc.cli-type
                    , input t-doc.cli-code
                    , input t-doc.host-code
                    , input t-doc.ext-doc-type
                    , input-output varschartic
                    , output varnotes) no-error.
    end.
  end case.
  run cycle-add in this-procedure.
  run UI-on     in this-procedure ( input "line" ).
end. /* on stop */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-rate d-out-doc
PROCEDURE add-rate :
reposition {&browse-name} to recid recid(ub.doc-line).
display ub.gds-dtl.fact-qnty + rate @ ub.gds-dtl.fact-qnty with browse {&browse-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE after_qnty d-out-doc
PROCEDURE after_qnty :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define  input parameter p-gds-dtl-rec  as   recid                no-undo.
  define output parameter p-out-qnty-kg  like ub.gds-dtl.fact-qnty no-undo initial 0.0.

  define variable p-inv-line-rec as recid   no-undo.
  define variable is-petrol      as logical no-undo.
  define variable is-pieces      as logical no-undo.

  define buffer buf_inv-line for ub.inv-line.
  define buffer buf_gds-dtl  for ub.gds-dtl.

  do on error undo, return error return-value :
    find buf_gds-dtl        no-lock where recid( buf_gds-dtl ) = p-gds-dtl-rec no-error.
    if not available buf_gds-dtl then do:
      assign p-out-qnty-kg = ?.
      undo, return error "after_qnty: не найдена строка накладной".
    end.
    { str/is-petrl.i
        buf_gds-dtl.artic
        buf_gds-dtl.prod-type
        buf_gds-dtl.prod-code
        is-petrol
        is-pieces
        no-error
    }
    if error-status :error or v-is-ptrl <> "yes" or is-petrol <> yes or is-pieces <> no then do:
      undo, return error substitute( 'inv-line_price: &1 (произв. &2 &3) не топливный товар',
                                     buf_gds-dtl.artic, buf_gds-dtl.prod-type, buf_gds-dtl.prod-code ).
    end.

    find buf_inv-line          no-lock where
         buf_inv-line.doc-code  = buf_gds-dtl.doc-code  and
         buf_inv-line.artic     = buf_gds-dtl.artic     and
         buf_inv-line.prod-code = buf_gds-dtl.prod-code and
         buf_inv-line.prod-type = buf_gds-dtl.prod-type no-error.
    if available buf_inv-line then do:
      assign
        p-inv-line-rec = recid( buf_inv-line )
      .
      find buf_gds-dtl  exclusive-lock where recid( buf_gds-dtl  ) = p-gds-dtl-rec.
      find buf_inv-line exclusive-lock where recid( buf_inv-line ) = p-inv-line-rec.
      assign
        p-out-qnty-kg = buf_inv-line.after-cli-qnty
      .
      find buf_inv-line        no-lock where recid( buf_inv-line ) = p-inv-line-rec.
      find buf_gds-dtl         no-lock where recid( buf_gds-dtl  ) = p-gds-dtl-rec.

      release buf_inv-line.
      release buf_gds-dtl.
    end. /* if available buf_inv-line */
  end. /* on error */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ask-copy d-out-doc
PROCEDURE ask-copy :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

define buffer tdb_doc-line    for ub.doc-line.
define buffer tdb_gds-dtl     for ub.gds-dtl.
define buffer tdb_parts       for ub.parts .
define buffer buf_parts       for ub.parts .
define buffer buf-cli_clients for ub.clients  .

define variable v-num as integer initial 1 no-undo.

for each t-d-b-doc-line :
  delete t-d-b-doc-line.
end.
for each t-d-b-gds-dtl :
  delete t-d-b-gds-dtl.
end.
for each t-d-b-parts :
  delete t-d-b-parts.
end.

for each tdb_doc-line where tdb_doc-line.doc-code = t-d-b.doc-code on error undo, return no-apply :
  create t-d-b-doc-line.
  buffer-copy tdb_doc-line to t-d-b-doc-line.
end.
for each tdb_gds-dtl where tdb_gds-dtl.doc-code = t-d-b.doc-code on error undo, return no-apply :
  create t-d-b-gds-dtl.
  buffer-copy tdb_gds-dtl to t-d-b-gds-dtl.
end.

if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} then do:
  run gbl/d-askw.w
    (input "Вопрос"
    ,input "По каким количествам будем производить копирование?"
            + {&new-line} + (if t-d-b.status_ <> {&inquiry} then "Внимание ! Если добавляемое количество какого-либо товара недоступно, оно будет уменьшено." else "":U)
    ,input "|^"
    ,input "Фактическим|"
           + "Документарным|"
           + "Партии источн.|"
           +  "Отмена"
    ,input "Исходя из фактических количеств в строке документа. При этом берутся любые партии от этого поставщика|"
        + "Исходя из документарных количеств в строке документа. При этом берутся любые партии от этого поставщика|"
        + "Исходя из фактических количеств в партиях документа. Если свободное количество данной партии меньше чем в документе источнике, то берется все свободное количество.|"
        + "Отменить копирование."
    ,input 1
    ,input 4
    ,output v-num
    ).
  if v-num = 4 then do:
    return no-apply.
  end.
  if v-num = 3 then do:
    for each t-d-b-doc-line where t-d-b-doc-line.doc-code = t-d-b.doc-code on error undo, return no-apply :
      for each buf_parts
        where buf_parts.obj-type  = t-d-b-doc-line.obj-type
          and buf_parts.obj-code  = t-d-b-doc-line.obj-code
          and buf_parts.artic     = t-d-b-doc-line.artic
          and buf_parts.prod-type = t-d-b-doc-line.prod-type
          and buf_parts.prod-code = t-d-b-doc-line.prod-code
          and buf_parts.out-code  = t-d-b.doc-code
      on error undo, return no-apply
      :
        if buf_parts.supp-type = t-doc.cli-type
          and buf_parts.supp-code = t-doc.cli-code
        then do:
          find first tdb_parts
            where tdb_parts.obj-type  = buf_parts.obj-type
              and tdb_parts.obj-code  = buf_parts.obj-code
              and tdb_parts.artic     = buf_parts.artic
              and tdb_parts.prod-type = buf_parts.prod-type
              and tdb_parts.prod-code = buf_parts.prod-code
              and tdb_parts.in-code   = buf_parts.in-code
              and tdb_parts.out-code  = {&free-code}
              and tdb_parts.part-code = buf_parts.part-code
            no-error .
          if available tdb_parts then do:
            create t-d-b-parts.
            if tdb_parts.fact-qnty > buf_parts.fact-qnty then do:
              buffer-copy buf_parts to t-d-b-parts .
            end.
            else do:
              buffer-copy tdb_parts to t-d-b-parts
                assign
                  t-d-b-parts.out-code = t-d-b-doc-line.doc-code
                .
            end.
          end.
        end.
      end.
    end. /* for each t-d-b-doc-line */
  end.
end.

block_copy:
do transaction
on error undo, return error return-value
on stop  undo, return error "stop"
:
  if t-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_VP} then do:
    run gbl/d-askw.w
      (input "Вопрос"
      ,input "По каким количествам будем производить копирование?"
            + {&new-line} + (if t-d-b.status_ <> {&inquiry} then "Внимание ! Если добавляемое количество какого-либо товара недоступно, оно будет уменьшено." else "":U)
      ,input "|^"
      ,input "Фактическим|"
          + "Документарным|"
          + "По Партиям|"
          + "Отмена"
      ,input "Исходя из фактических количеств в признаках.|"
          + "Исходя из документарных количеств в признаках.|"
          + "Копировать партии источника.|"
          + "Отменить копирование."
      ,input 1
      ,input 4
      ,output v-num
      ).
    if v-num = 4 then do:
      undo, leave block_copy .
    end.
  if v-num = 3 then do:
    for each t-d-b-doc-line where t-d-b-doc-line.doc-code = t-d-b.doc-code on error undo, return no-apply :
      for each buf_parts
        where buf_parts.obj-type  = t-d-b-doc-line.obj-type
          and buf_parts.obj-code  = t-d-b-doc-line.obj-code
          and buf_parts.artic     = t-d-b-doc-line.artic
          and buf_parts.prod-type = t-d-b-doc-line.prod-type
          and buf_parts.prod-code = t-d-b-doc-line.prod-code
          and buf_parts.out-code  = t-d-b.doc-code
      on error undo, return no-apply
      :
          find first tdb_parts
            where tdb_parts.obj-type  = buf_parts.obj-type
              and tdb_parts.obj-code  = buf_parts.obj-code
              and tdb_parts.artic     = buf_parts.artic
              and tdb_parts.prod-type = buf_parts.prod-type
              and tdb_parts.prod-code = buf_parts.prod-code
              and tdb_parts.in-code   = buf_parts.in-code
              and tdb_parts.out-code  = {&free-code}
              and tdb_parts.part-code = buf_parts.part-code
            no-error .
          if available tdb_parts then do:
            create t-d-b-parts.
            if tdb_parts.fact-qnty > buf_parts.fact-qnty then do:
              buffer-copy buf_parts to t-d-b-parts .
            end.
            else do:
              buffer-copy tdb_parts to t-d-b-parts
                assign
                  t-d-b-parts.out-code = t-d-b-doc-line.doc-code
                .
            end.
        end.
      end.
    end. /* for each t-d-b-doc-line */
  end.

  end.

  { str/copy-ret.i
    parparentproc
    t-d-b.doc-code
    t-d-b.doc-type
    t-d-b.status_
    t-d-b.internal
    t-d-b.cli-type
    t-d-b.cli-code
    t-d-b.discnt-type
    t-d-b.tot-calc
    t-d-b.discnt-pc
    t-d-b.agnt
    t-d-b.boss
    t-d-b.wrkr
    t-d-b.base-rate
    t-d-b.base-scale
    t-d-b.exch-code
    t-d-b.vat-type
    t-doc.doc-code
    "t-doc.discnt-type:sensitive in frame {&frame-name}"
    "input frame {&frame-name} t-doc.discnt-pc"
    "input frame {&frame-name} t-doc.agnt"
    "input frame {&frame-name} t-doc.boss"
    "input frame {&frame-name} t-doc.wrkr"
    "input frame {&frame-name} t-doc.base-rate"
    "input frame {&frame-name} t-doc.base-scale"
    ub.sysconf.cash-pay
    ub.sysconf.base-code
    t-d-b-doc-line
    t-d-b-gds-dtl
    t-d-b-parts
    "(if v-num = 3 then yes else no)"
    "(if v-num = 3 then yes else no)"
    no
    "(if v-num = 1 or v-num = 3 then yes else no)"
    no-error }

  if error-status :error then do:
    message "Ошибка при копировании документа." skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2) skip
            error-status:get-message(3) skip
    view-as alert-box error.
    return error.
  end.
  run str/crdocpl.p
    ( input t-doc.doc-code
     ,input ?
     ,input "dens_doc-line":U
    ) no-error .
  if error-status :error then do:
    message
      "Ошибка при копировании документа (создание информации по складским местам)." skip
      return-value skip
      error-status:get-message(1) skip
      error-status:get-message(2) skip
      error-status:get-message(3) skip
      view-as alert-box error.
    return error .
  end.
  run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
  if error-status :error then do:
    message
      "Ошибка при копировании документа (расчет шапки документа)." skip
      return-value skip
      error-status:get-message(1) skip
      error-status:get-message(2) skip
      error-status:get-message(3) skip
      view-as alert-box error.
    return error .
  end.
end. /*transaction*/

for each t-d-b-doc-line :
  delete t-d-b-doc-line.
end.
for each t-d-b-gds-dtl :
  delete t-d-b-gds-dtl.
end.
for each t-d-b-parts :
  delete t-d-b-parts.
end.

pardoc-mode = {&update}.
run ui-on ("line").
apply "entry" to br-dtl in frame {&frame-name}.
END PROCEDURE.
procedure chg-purch-contract :
  /* message  "Проверка договора ?"  view-as alert-box . */
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ch-discnt d-out-doc
PROCEDURE ch-discnt :
define variable hist-list as character no-undo.
define buffer buf_c-dis-card for ub.c-dis-card.
define buffer buf_c-dc-hist for ub.c-dc-hist.
if input frame {&frame-name} t-doc.discnt-type = {&card} then do:
  run ref/discards.w (
                   input parparentproc
                  ,input "b-sel"
                  ,input "client":U
                  ,input t-doc.host-code
                  ,input t-doc.obj-type
                  ,input t-doc.obj-code
                  ,input '':U
                  ,input recid (ub.clients)
                  ,output ref-list).
  if ref-list = "" then do:
    display t-doc.discnt-type with frame {&frame-name}.
    return error.
  end.
  find ub.dis-card where recid (ub.dis-card) = integer (ref-list) no-lock.
  if ub.dis-card.status_ = {&nonused-status}
  or ub.dis-card.status_ = {&chown-status}
  then do:
    message
    substitute("Нельзя создать докуиент с картой &1&2" +
                "Карта имеет статус &3, &4"
                , ub.dis-card.d-card
                , {&new-line}
                , ub.dis-card.status_
                , (if ub.dis-card.status_ = {&nonused-status}
                    then "карта должна быть ОКОНЧАТЕЛЬНО удалена"
                    else "карта будет доступна по окончании процесса смены владельца")

                )
    view-as alert-box error .
    return error.
  end.
  assign
    t-doc.d-card    = ub.dis-card.d-card.
  assign varlog = yes.
  message "Текущий процент по дисконтной карте " ub.dis-card.d-card " равен " ub.dis-card.d-pcnt " ." skip
          "Будем оформлять накладную, исходя из данного процента?" view-as alert-box question buttons yes-no update varlog.
  if varlog then do:
    assign
      t-doc.discnt-pc = ub.dis-card.d-pcnt
      t-doc.d-card    = ub.dis-card.d-card.
  end.
  else do:
    run ref/cdchist.w (
                    INPUT  parparentproc
                    ,input t-doc.host-code
                    ,input t-doc.obj-type
                    ,input t-doc.obj-code
                    ,input "b-sel":U
                    ,input "subject":U
                    ,input ub.dis-card.d-card
                    ,input ub.dis-card.card-num
                    ,input t-doc.obj-type
                    ,input t-doc.obj-code
                    ,input t-doc.host-code
                    ,input v-cntxt-db-num
                    ,input "":U /*p-corr-user-name */
                    ,input {&table_dis-card} /*p-subject*/
                    ,input v-cntxt-db-num
                    /*записи в выборке*/
                    ,input-output hist-list
                 ) no-error .
    if error-status :error or
       hist-list = "" then do:
       message "Не смог взять процент из истории. Берем текущий процент."
       view-as alert-box information.
       assign
         t-doc.discnt-pc = ub.dis-card.d-pcnt
         t-doc.d-card    = ub.dis-card.d-card.
    end.
    else do:
      find first buf_c-dc-hist where
              recid(buf_c-dc-hist) = integer(hist-list) no-lock no-error.
      if available buf_c-dc-hist then do:
        find first buf_c-dis-card no-lock where
                  buf_c-dis-card.d-card           = buf_c-dc-hist.d-card
              AND buf_c-dis-card.chip-num         = buf_c-dc-hist.chip-num
              AND buf_c-dis-card.corr-user-db-num = buf_c-dc-hist.corr-user-db-num  no-error .
      end.
      if not available buf_c-dc-hist
      or not available buf_c-dis-card
      then do:
         message "Не смог взять процент из истории. Берем текущий процент."
         view-as alert-box information.
         assign
         t-doc.discnt-pc = ub.dis-card.d-pcnt
         t-doc.d-card    = ub.dis-card.d-card.
      end.
      else do:
        assign
        t-doc.discnt-pc = decimal(buf_c-dis-card.d-pcnt)
        t-doc.d-card    = ub.dis-card.d-card.
      end.
    end.
  end.
end.
else do:
  assign
    t-doc.d-card = ?.
end.
display t-doc.d-card t-doc.discnt-pc with frame {&frame-name}.

if input frame {&frame-name} t-doc.discnt-type = {&group} then do:
  define variable v-d-pcnt as decimal no-undo .
  run cgrplib-get-pcnt-value in this-procedure ( input ub.clients.grp-code , output v-d-pcnt) no-error .
  if error-status:error then do:
    message
    "Ошибка при установлениее скидки для группы клиентов."
    error-status:get-message(1) skip
    return-value
    view-as alert-box.
    display t-doc.discnt-type with frame {&frame-name}.
    return error.
  end.
  else do:
    if v-d-pcnt = ?
    or v-d-pcnt = 0 then do:
      message "Скидка для группы клиентов не установлена." view-as alert-box.
      display t-doc.discnt-type with frame {&frame-name}.
      return error.
    end.
  end.
  t-doc.discnt-pc = v-d-pcnt.
end.
assign t-doc.discnt-type.
run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
if error-status :error then return "error".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-discnt d-out-doc
PROCEDURE check-discnt :
varlog = no.
if input frame {&frame-name} t-doc.discnt-type = {&row} then
  if not v-cntxp-out-line-discnt then message "Скидки по строкам запрещены.".
  else message "Включение разных скидок по строкам. Вы уверены ?"
                          view-as alert-box question buttons ok-cancel update varlog.
  else message "Включение общей скидки для всего документа."
                        "Все скидки по строкам будут пересчитаны. Вы уверены ?"
                        view-as alert-box question buttons ok-cancel update varlog.
if varlog <> true then do:
  display t-doc.discnt-type with frame {&frame-name}.
  return error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-inv d-out-doc
PROCEDURE check-inv :
find ub.doc-line where ub.doc-line.doc-code         = t-doc.doc-code
                       and ub.doc-line.prod-code = ub.gds-dtl.prod-code
                       and ub.doc-line.prod-type = ub.gds-dtl.prod-type
                       and ub.doc-line.artic     = ub.gds-dtl.artic no-lock.
line-rec = recid (ub.doc-line).
find ub.goods where ub.goods.prod-code = ub.gds-dtl.prod-code
             and ub.goods.prod-type = ub.gds-dtl.prod-type
             and ub.goods.artic     = ub.gds-dtl.artic no-lock.
define variable l-inv-on as logical no-undo .

 { gbl/gdsobjat.i
   ub.doc-line.obj-type
   ub.doc-line.obj-code
   ub.doc-line.artic
   ub.doc-line.prod-type
   ub.doc-line.prod-code
   "'inv-on=request'"
   l-inv-on
   no-error }
if error-status :error then do:
  message
    "Ошибка получения признака товара на объекте" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return no-apply .
end.

if l-inv-on = yes and t-doc.status_ <> {&inquiry} then do:
  message "Артикул :" ub.doc-line.artic ub.goods.gds-name "- товар в инвентаризации." skip( 2 )
          "Операция невозможна."
  view-as alert-box error.
  return error.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-m-outs-8 d-out-doc 
PROCEDURE proc-m-outs-8 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer bf_trn-doc for ub.trn-doc.
define buffer bf_doc-line for ub.doc-line .
define buffer bf_goods for ub.goods .
define variable vardoc-code like ub.trn-doc.doc-code no-undo.
define variable par-alcohol as character no-undo .
define variable par-mark as character no-undo .
define variable par-type as character no-undo .
define variable v-is-alc as logical no-undo .
define variable v-mark-alchol     as logical no-undo .
define variable v-type as character no-undo .
define variable v-tth             as handle no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .

delete object v-tth no-error.
run adm/shattri.p (
   input "get":U
  ,input t-doc.obj-type
  ,input t-doc.obj-code
  ,input {&attr-nakl_par}
  ,input  "mark-alchol"
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-mark-alchol
  ,output v-type
  ,INPUT-OUTPUT table-handle v-tth
  ) no-error .
  delete object v-tth no-error.
if error-status:error then do:
  message "Ошибка при получение параметра mark-alchol"
  view-as alert-box.
  return error.
end.
if not v-mark-alchol
then do :
    message "В системе не включен помарочный учёт. Импорт акцизных марок невозможен." view-as alert-box .
    return.
end.

/*v-is-alc = false .                                                                                                          */
/*for each bf_doc-line no-lock where bf_doc-line.doc-code = t-doc.doc-code :                                                  */
/*    find first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic                                                */
/*                                  and bf_goods.prod-type = bf_doc-line.prod-type                                            */
/*                                  and bf_goods.prod-code = bf_doc-line.prod-code                                            */
/*                                  no-error .                                                                                */
/*                                                                                                                            */
/*    run gds-attr-value(                                                                                                     */
/*      bf_goods.gds-code,                                                                                                    */
/*      {&attr-alcohol-prod},                                                                                                 */
/*      output par-alcohol,                                                                                                   */
/*      output par-type                                                                                                       */
/*    ).                                                                                                                      */
/*    if par-alcohol = "" or par-alcohol = "no" then next .                                                                   */
/*    run gds-attr-value(                                                                                                     */
/*      bf_goods.gds-code,                                                                                                    */
/*      {&attr-mark},                                                                                                         */
/*      output par-mark,                                                                                                      */
/*      output par-type                                                                                                       */
/*    ).                                                                                                                      */
/*    if par-mark = "" or par-mark = "no" then next .                                                                         */
/*    v-is-alc = true .                                                                                                       */
/*end.                                                                                                                        */
/*                                                                                                                            */
/*if not v-is-alc                                                                                                             */
/*then do :                                                                                                                   */
/*    message "В накладной нет ни одного товара, подлежащего маркировке. Импорт акцизных марок не возможен" view-as alert-box.*/
/*    return .                                                                                                                */
/*end.                                                                                                                        */

do transaction:
    run str/imp-marks.p (parparentproc, t-doc.doc-code, "out") .    
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-m-outs-9 d-out-doc 
PROCEDURE proc-m-outs-9 :
  define variable chg-qnty    like gds-dtl.doc-qnty no-undo.
  define variable legal-node  like gds-prt.node-code no-undo.
  define variable varcount    as integer no-undo.
  define variable varchg-qnty like ub.gds-dtl.doc-qnty no-undo.
  define variable vardoc-qnty like ub.gds-dtl.doc-qnty no-undo.
  define variable v-is-petrol as logical no-undo.
  define variable v-is-pieces as logical no-undo.
  define variable var-kg-qnty like ub.gds-dtl.doc-qnty no-undo.
  define variable rr-inv-line as recid   no-undo.
  define variable v-rec-list as character no-undo .
  define variable ii as integer no-undo .

  define buffer cpl_goods    for ub.goods   .
  define buffer cpl_gds-obj  for ub.gds-obj .
  define buffer cpl_prt-obj  for ub.prt-obj .
  define buffer cpl_gds-prt  for ub.gds-prt .
  define buffer cpl_gds-dtl  for ub.gds-dtl .
  define buffer cpl_doc-line for ub.doc-line.
  define buffer cpl_inv-line for ub.inv-line.
  
  define buffer buf_utd       for ub.utd  .
  define buffer buf_utd-lines for ub.utd-lines .
  define variable vconnect as com-handle no-undo.  
  run str/UPD.w ( parparentproc, {&select}, 0,"" , input-output vconnect , output v-rec-list)  .
  if trim(v-rec-list) = ""
  or v-rec-list = ?
  then
  return .
  
  do ii = 1 to num-entries (v-rec-list) :
    find first buf_utd no-lock where recid(buf_utd) = integer(entry(ii,v-rec-list)) no-error .
    if not available buf_utd then next .
    c-l:
    do on error undo c-l, return error :
      r-l:
      for each buf_utd-lines no-lock where buf_utd-lines.db-num = buf_utd.db-num
                                       and buf_utd-lines.doc-id = buf_utd.doc-id,
      first cpl_goods no-lock where cpl_goods.gds-code = buf_utd-lines.gds-code :
        assign 
          varcount = varcount + 1
        .
        if varcount modulo 100 = 0 then 
        do:
          run waitfram-show in this-procedure (input "ЖДИТЕ.  Обработано строк списка : " + string (varcount)).
        end.        
                                 
        { str/crdoclno.i
         t-doc.doc-code
         t-doc.obj-type
         t-doc.obj-code
         cpl_goods.artic
         cpl_goods.prod-type
         cpl_goods.prod-code
         cpl_goods.gds-name
         cpl_goods.prt-root
         ?
         ?
         ub.sysconf.cash-pay
         no-error }
        if error-status :error then 
        do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при создании строки." skip
            return-value skip
            trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5)) skip
            view-as alert-box error.
          undo c-l, return error return-value.
        end.
        if return-value = "next" then 
        do:
          next r-l.
        end.
        find first cpl_doc-line where cpl_doc-line.doc-code  = t-doc.doc-code and
          cpl_doc-line.artic     = cpl_goods.artic      and
          cpl_doc-line.prod-type = cpl_goods.prod-type  and
          cpl_doc-line.prod-code = cpl_goods.prod-code .
        find first cpl_gds-prt where cpl_gds-prt.upper-code = cpl_goods.prt-root no-lock.
        find first  cpl_prt-obj where cpl_prt-obj.obj-type  = t-doc.obj-type
          and cpl_prt-obj.obj-code  = t-doc.obj-code
          and cpl_prt-obj.artic     = cpl_goods.artic
          and cpl_prt-obj.prod-type = cpl_goods.prod-type
          and cpl_prt-obj.prod-code = cpl_goods.prod-code no-error .
        if error-status :error then 
        do:
        /* создать */
        end.
  
        assign 
          legal-node = if available cpl_prt-obj then cpl_prt-obj.prt-code else cpl_gds-prt.node-code .
  
        { str/crgdsdtl.i
      t-doc.obj-code
      t-doc.obj-type
      t-doc.doc-code
      cpl_goods.artic
      cpl_goods.prod-code
      cpl_goods.prod-type
      legal-node
      yes
      no-error }
  
        find first cpl_gds-dtl where cpl_gds-dtl.doc-code  = t-doc.doc-code and
          cpl_gds-dtl.artic     = cpl_goods.artic      and
          cpl_gds-dtl.prod-code = cpl_goods.prod-code  and
          cpl_gds-dtl.prod-type = cpl_goods.prod-type  and
          cpl_gds-dtl.prt-code  = legal-node.
        assign
          cpl_gds-dtl.ov = no.
    /* подстановка цены, по цене магазина */
    /* если ошибка при установке цены переходим к следующему товару                 */
    { str/set-pr.i recid(cpl_gds-dtl) no ? no-error }
        if error-status :error then 
        do:
          message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            ""
            view-as alert-box error
            .
        /* undo, next r-l. */
        end.
        assign
          chg-qnty = buf_utd-lines.Quantity
        .
        run trg/rsrv-dtl.p (input parparentproc,
                            {&rsrv-dtl_action_reserv},
                            buffer cpl_gds-dtl,
                            input-output chg-qnty,
                            input-output cpl_doc-line.price-base,
                            input-output cpl_doc-line.price-rubl,
                            -1,
                            input ("copy-utd-line" + {&delim-par} + string(recid(buf_utd-lines)))) no-error.
        if error-status:error
        then do :
          message ("Ошибка при копировании товара " + string(cpl_goods.gds-code) + "  " + cpl_goods.gds-name + {&new-line} + return-value)
          view-as alert-box .
          undo c-l, return error.
        end .
        assign
          cpl_doc-line.doc-qnty  = cpl_doc-line.doc-qnty + chg-qnty
          cpl_gds-dtl.doc-qnty   = cpl_gds-dtl.doc-qnty  + chg-qnty
          cpl_gds-dtl.fact-qnty  = cpl_gds-dtl.doc-qnty
          cpl_doc-line.fact-qnty = cpl_doc-line.doc-qnty.
        /* считаем суммарное количество, которое удалось скопировать */
        assign
          varchg-qnty = varchg-qnty + chg-qnty
          vardoc-qnty = vardoc-qnty + cpl_gds-dtl.doc-qnty.
        if cpl_gds-dtl.doc-qnty = 0 then delete cpl_gds-dtl.
      end .
    end.
  end.

  run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
  if error-status :error then 
  do:
    message
      "Ошибка при копировании документа (расчет шапки документа)." skip
      return-value skip
      error-status:get-message(1) skip
      view-as alert-box error.
    return error .
  end.

  pardoc-mode = {&update}.
  run ui-on ("line").
  apply "entry" to br-dtl in frame {&frame-name}.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-reason d-out-doc
PROCEDURE check-reason :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable j_rsn-code like ub.trn-reason.reason-code no-undo.

  assign j_rsn-code = ( input frame {&FRAME-NAME} t-doc.reason-code ).
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = j_rsn-code no-error.
  if not available ub.trn-reason then do:
    if j_rsn-code <> ? and j_rsn-code <> 0 then do:
      message "Неверно указано основание (причина) создания документа." view-as alert-box error.
    end.
    assign  rsn-name = "".
    display rsn-name with frame {&FRAME-NAME}.
    if j_rsn-code = ? or j_rsn-code = 0 then do:
      assign t-doc.reason-code = 0.
      return.
    end.
    else do:
      return error.
    end.
  end.
  assign  rsn-name = ub.trn-reason.reason-name.
  display rsn-name with frame {&FRAME-NAME}.
  assign  frame {&FRAME-NAME} t-doc.reason-code.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-upd-date d-out-doc
PROCEDURE chk-upd-date :
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
if t-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh}          and
   t-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_VP}       and
   t-doc.ext-doc-type <> {&TDEDT_Vozvrat_Vnesh}      and
   t-doc.ext-doc-type <> {&TDEDT_Vozvrat_Vnesh_Kass} and
   t-doc.ext-doc-type <> {&TDEDT_Spi_Vnesh}          and
   t-doc.ext-doc-type <> {&TDEDT_Ras_Object}     then do:
   message "Дату факт можно редактировать только во внешнем расходе, внутриобъектном расходе, возврате поставщику, внешнем возврате, внешнем возврате через кассу или списании."
   view-as alert-box.
   display t-doc.fact-date with frame {&frame-name}.
   return error.
end.
{ gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code v-today }
if input frame {&frame-name} t-doc.fact-date > v-today then do:
   message "Дата больше сегодняшней даты на объекте." view-as alert-box error.
   display t-doc.fact-date with frame {&frame-name}.
   return error.
end.
if input frame {&frame-name} t-doc.fact-date < v-today - 7 then do:
   varlog = yes.
   message "Заведенная факт дата отличается более чем на 7 дней от сегодняшней даты на объекте."
           "Отказаться от заведения даты?" view-as alert-box question
           buttons yes-no update varlog.
   if varlog then do:
      display t-doc.fact-date with frame {&frame-name}.
      return error.
   end.
end.
if input frame {&frame-name} t-doc.fact-date <> t-doc.fact-date then do:
define variable v-value-character as character no-undo .
define variable v-value-date      as date no-undo .
define variable v-value-decimal   as decimal no-undo .
define variable v-value-integer   as integer no-undo .
define variable v-value-logical   as logical no-undo .
define variable v-tth             as handle no-undo .
define variable v-back-date as logical   no-undo .
define variable v-back-date-type as character no-undo .

      delete object v-tth no-error.
      run adm/shattri.p (
           input "get":U
          ,input v-cntxt-obj-type
          ,input v-cntxt-obj-code
          ,input {&attr-nakl_par}
          ,input  "back-date"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-back-date
          ,output v-back-date-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
          if error-status :error  then v-back-date = false .
          delete object v-tth no-error.
    if v-back-date <> true then do:
      message "Запрещено работать задним числом !" view-as alert-box information .
      display t-doc.fact-date with frame {&frame-name}.
      return error.
    end.

   varlog = no.
   case t-doc.doc-type
   :
     when {&income}
     then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_income_add-back-date':U
          {&cntxt-object}
          t-doc.host-code
          t-doc.obj-type
          t-doc.obj-code
          0
          0
          0
          true
          varlog
        }
     end.
     when {&expense}
     then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_expense_add-back-date':U
          {&cntxt-object}
          t-doc.host-code
          t-doc.obj-type
          t-doc.obj-code
          0
          0
          0
          true
          varlog
        }
     end.
     when {&return}
     then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_return_add-back-date':U
          {&cntxt-object}
          t-doc.host-code
          t-doc.obj-type
          t-doc.obj-code
          0
          0
          0
          true
          varlog
        }

     end.
     when {&write-off}
     then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_write-off_add-back-date':U
          {&cntxt-object}
          t-doc.host-code
          t-doc.obj-type
          t-doc.obj-code
          0
          0
          0
          true
          varlog
        }

     end.
     when {&inventory}
     then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_inventory_add-back-date':U
          {&cntxt-object}
          t-doc.host-code
          t-doc.obj-type
          t-doc.obj-code
          0
          0
          0
          true
          varlog
        }
     end.
     otherwise do:
       message
         vss-workfile vss-revision vss-description skip
         "Неизвестный тип документа" t-doc.doc-type skip
         "Документ" t-doc.doc-code skip
         view-as alert-box error .
       undo, return error return-value .
     end.
   end case .

   if varlog = no then do:
      display t-doc.fact-date with frame {&frame-name}.
      return error.
   end.
   varlog = no.
   message "Вы хотите изменить фактическую дату?" skip
           "Если дату задать как '?' она при закрытии на факт проставится днем закрытия."
   view-as alert-box question buttons yes-no update varlog.
   if not varlog then do:
      display t-doc.fact-date with frame {&frame-name}.
      return error.
   end.
   assign t-doc.fact-time = (24 * 60 * 60).
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE copy-lst d-out-doc
PROCEDURE copy-lst :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
  define input parameter parcash-pay like ub.sysconf.cash-pay no-undo.
  define input parameter pardoc-prt  as   logical             no-undo.
  define input parameter table for tt-gds-list.
  define input parameter p-marks-par as character no-undo .

  define variable chg-qnty    like ub.gds-dtl.doc-qnty    no-undo.
  define variable legal-node  like ub.gds-prt.node-code   no-undo.
  define variable varcount    as   integer             no-undo.
  define variable varchg-qnty like ub.gds-dtl.doc-qnty no-undo.
  define variable vardoc-qnty like ub.gds-dtl.doc-qnty no-undo.
  define variable v-is-petrol as   logical             no-undo.
  define variable v-is-pieces as   logical             no-undo.
  define variable var-kg-qnty like ub.gds-dtl.doc-qnty no-undo.
  define variable rr-inv-line as   recid               no-undo.
  define variable v-tech-marks-qnty like gds-dtl.doc-qnty no-undo.

  define buffer cpl_goods    for ub.goods.
  define buffer cpl_gds-obj  for ub.gds-obj.
  define buffer cpl_prt-obj  for ub.prt-obj.
  define buffer cpl_trn-doc  for ub.trn-doc.
  define buffer cpl_gds-prt  for ub.gds-prt.
  define buffer cpl_gds-dtl  for ub.gds-dtl.
  define buffer cpl_doc-line for ub.doc-line.
  define buffer cpl_inv-line for ub.inv-line.
  define buffer buf_marking-lines for ub.marking-lines .

c-l:
do on error undo c-l, return error :
find first cpl_trn-doc where cpl_trn-doc.doc-code = pardoc-code.
r-l:
for each tt-gds-list,
     each cpl_goods where cpl_goods.prod-type = tt-gds-list.prod-type
                      and cpl_goods.prod-code = tt-gds-list.prod-code
                      and cpl_goods.artic     = tt-gds-list.artic     no-lock :
  assign varcount = varcount + 1.
  if varcount modulo 100 = 0 then do:
    run waitfram-show in this-procedure (input "ЖДИТЕ.  Обработано строк списка : " + string (varcount)).
  end.
  if p-marks-par = "tech-marks"
  then do :
    assign
      v-tech-marks-qnty = 0
    .
    for each buf_marking-lines no-lock where buf_marking-lines.gds-code = cpl_goods.gds-code
                                         and buf_marking-lines.obj-type = cpl_trn-doc.obj-type
                                         and buf_marking-lines.obj-code = cpl_trn-doc.obj-code
                                         and buf_marking-lines.out-code = {&free-code}
                                         and buf_marking-lines.mark begins {&tech-mark-prefix}
                                         : 
      assign
        v-tech-marks-qnty = v-tech-marks-qnty + 1
      .
    end . 
    if v-tech-marks-qnty = 0 then next r-l.                                      
  end .
  find cpl_gds-obj where cpl_gds-obj.obj-type  = cpl_trn-doc.obj-type
                     and cpl_gds-obj.obj-code  = cpl_trn-doc.obj-code
                     and cpl_gds-obj.prod-type = cpl_goods.prod-type
                     and cpl_gds-obj.prod-code = cpl_goods.prod-code
                     and cpl_gds-obj.artic     = cpl_goods.artic    no-lock no-error.
  if not available cpl_gds-obj or cpl_gds-obj.fact-qnty = 0 then next r-l.
  { str/crdoclno.i
   cpl_trn-doc.doc-code
   cpl_trn-doc.obj-type
   cpl_trn-doc.obj-code
   cpl_goods.artic
   cpl_goods.prod-type
   cpl_goods.prod-code
   cpl_goods.gds-name
   cpl_goods.prt-root
   ?
   ?
   parcash-pay
   no-error }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании строки." skip
      return-value skip
      trim(error-status :get-message(1))
      trim(error-status :get-message(2))
      trim(error-status :get-message(3))
      trim(error-status :get-message(4))
      trim(error-status :get-message(5)) skip
      view-as alert-box error.
    undo c-l, return error return-value.
  end.
  if return-value = "next" then do:
    next r-l.
  end.
  find first cpl_doc-line where cpl_doc-line.doc-code  = cpl_trn-doc.doc-code and
                                cpl_doc-line.artic     = cpl_goods.artic      and
                                cpl_doc-line.prod-type = cpl_goods.prod-type  and
                                cpl_doc-line.prod-code = cpl_goods.prod-code .
  find first cpl_gds-prt where cpl_gds-prt.upper-code = cpl_goods.prt-root no-lock.
  for each cpl_prt-obj where cpl_prt-obj.obj-type  = cpl_trn-doc.obj-type
                         and cpl_prt-obj.obj-code  = cpl_trn-doc.obj-code
                         and cpl_prt-obj.artic     = cpl_goods.artic
                         and cpl_prt-obj.prod-type = cpl_goods.prod-type
                         and cpl_prt-obj.prod-code = cpl_goods.prod-code
                         and cpl_prt-obj.fact-qnty > 0              no-lock :
    if (pardoc-prt and not can-find (first cpl_gds-prt where cpl_gds-prt.upper-code = cpl_prt-obj.prt-code no-lock))
       /* узел терминальный и признаки включены */ or
       (not pardoc-prt and cpl_prt-obj.prt-code = cpl_gds-prt.node-code)
       /* узел корневой и признаки выключены */ then do:
      assign legal-node = cpl_prt-obj.prt-code.
      { str/crgdsdtl.i
        cpl_trn-doc.obj-code
        cpl_trn-doc.obj-type
        cpl_trn-doc.doc-code
        cpl_goods.artic
        cpl_goods.prod-code
        cpl_goods.prod-type
        legal-node
        yes
        no-error }
      if error-status :error then do:
         return error substitute("Ошибка при создании признака &1.", return-value).
      end.
      find first cpl_gds-dtl where cpl_gds-dtl.doc-code  = cpl_trn-doc.doc-code and
                                   cpl_gds-dtl.artic     = cpl_goods.artic      and
                                   cpl_gds-dtl.prod-code = cpl_goods.prod-code  and
                                   cpl_gds-dtl.prod-type = cpl_goods.prod-type  and
                                   cpl_gds-dtl.prt-code  = legal-node.
      assign
        cpl_gds-dtl.ov  = no.
      /* подстановка цены, в т.ч. возврат поставщику или перемещение по цене магазина */
      /* если ошибка при установке цены переходим к следующему товару                 */
      { str/set-pr.i recid(cpl_gds-dtl) no ? no-error }
      if error-status :error then undo, next r-l.
      assign
        chg-qnty = cpl_prt-obj.fact-qnty
      .
      if p-marks-par = "tech-marks"
      then do :
        assign
          chg-qnty = v-tech-marks-qnty
        .
      end .
      run trg/rsrv-dtl.p (input parparentproc,
                          {&rsrv-dtl_action_reserv},
                          buffer cpl_gds-dtl,
                          input-output chg-qnty,
                          input-output cpl_doc-line.price-base,
                          input-output cpl_doc-line.price-rubl,
                          -1,
                          input p-marks-par) no-error.      
      if error-status :error then undo c-l, return error.
      assign
        cpl_doc-line.doc-qnty  = cpl_doc-line.doc-qnty + chg-qnty
        cpl_gds-dtl.doc-qnty   = cpl_gds-dtl.doc-qnty  + chg-qnty
        cpl_gds-dtl.fact-qnty  = cpl_gds-dtl.doc-qnty
        cpl_doc-line.fact-qnty = cpl_doc-line.doc-qnty.
      /* считаем суммарное количество, которое удалось скопировать */
      assign
        varchg-qnty = varchg-qnty + chg-qnty
        vardoc-qnty = vardoc-qnty + cpl_gds-dtl.doc-qnty.
      if cpl_gds-dtl.doc-qnty = 0 then delete cpl_gds-dtl.
    end.
  end.
  { str/is-petrl.i
    cpl_goods.artic
    cpl_goods.prod-type
    cpl_goods.prod-code
    v-is-petrol
    v-is-pieces
  }
  if v-is-petrol = yes
    and v-is-pieces <> yes
  then do:
    find last cpl_inv-line no-lock
      where cpl_inv-line.obj-type   = cpl_gds-obj.obj-type
        and cpl_inv-line.obj-code   = cpl_gds-obj.obj-code
        and cpl_inv-line.prod-type  = cpl_gds-obj.prod-type
        and cpl_inv-line.prod-code  = cpl_gds-obj.prod-code
        and cpl_inv-line.artic      = cpl_gds-obj.artic
        and cpl_inv-line.status_    = {&fact}
        and cpl_inv-line.fact-order > 0
      use-index fact-order
      no-error.
    if available cpl_inv-line then do:
      assign
        var-kg-qnty = cpl_inv-line.after-cli-qnty
        cpl_doc-line.doc-density  = var-kg-qnty / varchg-qnty
        cpl_doc-line.fact-density = cpl_doc-line.doc-density
      .
      find first cpl_inv-line exclusive-lock
        where cpl_inv-line.doc-code  = cpl_doc-line.doc-code
          and cpl_inv-line.artic     = cpl_doc-line.artic
          and cpl_inv-line.prod-type = cpl_doc-line.prod-type
          and cpl_inv-line.prod-code = cpl_doc-line.prod-code
        no-error.
      if not available cpl_inv-line then do:
        { str/corinvln.i
          cpl_doc-line.doc-code
          cpl_doc-line.artic
          cpl_doc-line.prod-type
          cpl_doc-line.prod-code
          ?
          ?
          ?
          ?
          "vardoc-qnty * cpl_doc-line.doc-density"
          cpl_doc-line.doc-density
          rr-inv-line
        }
      end.
      else do:
        assign
          rr-inv-line = recid( cpl_inv-line )
          cpl_inv-line.wast-cli-qnty = vardoc-qnty * cpl_doc-line.doc-density
        .
      end.
    end.
  end.
end.
end.

if varchg-qnty > 0 then do:
  if varchg-qnty = vardoc-qnty then do:
    message "Все ФАКТ количества по списку товаров добавлены в документ успешно !".
  end.
  else do:
    message "Внимание !!!" skip (2)
                    "НЕ ВСЕ ФАКТ количество УДАЛОСЬ добавить в заполняемый документ !" skip (2)
                    "Общее количество в по списку на объекте : " varchg-qnty skip
                    "Удалось добавить в документ : " vardoc-qnty.
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cr-tt-upd d-out-doc
PROCEDURE cr-tt-upd :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do on error undo, return error return-value :
define variable v-other as character   no-undo.

for each tt-upd-attr : delete tt-upd-attr . end.

&scop create-record create tt-upd-attr. ~
 assign~
  tt-upd-attr.code =  ~{&~{&attr-code~}~}  . ~
                                        ~
~{ str/tdat-cod.i ~
     tt-upd-attr.code           ~
     tt-upd-attr.type-attr      ~
     tt-upd-attr.format-attr    ~
     tt-upd-attr.fillin_width   ~
     tt-upd-attr.fillin_height  ~
     tt-upd-attr.label-attr     ~
     tt-upd-attr.user-can-edit  ~
     tt-upd-attr.output-display ~
     v-other                    ~
     tt-upd-attr.proc-attr      ~
     tt-upd-attr.full-screen-val  ~
     tt-upd-attr.sort_  ~
     no-error               ~}  ~
 if error-status :error then do:    ~
   message "Ошибка при установке атрибутов документа." skip ~
    error-status :get-message(1) skip return-value view-as alert-box. ~
   return error. ~
 end.

&scop attr-code trdcattr-ord_time
{&create-record}
&scop attr-code trdcattr-frsrv-date
{&create-record}
&scop attr-code trdcattr-befpay
{&create-record}
&scop attr-code trdcattr-ord_Nchek
{&create-record}
&scop attr-code trdcattr-dchek
{&create-record}
&scop attr-code trdcattr-deliv
{&create-record}
&scop attr-code trdcattr-sumwrk
{&create-record}
/*
&scop attr-code trdcattr-sumsrk
{&create-record}
*/
&scop attr-code trdcattr-ord_adr
{&create-record}
&scop attr-code trdcattr-ord_hwo
{&create-record}
&scop attr-code trdcattr-ord_contact
{&create-record}
&scop attr-code trdcattr-ord_phone
{&create-record}
&scop attr-code trdcattr-ord_dl
{&create-record}
&scop attr-code trdcattr-delivery-date
{&create-record}
&scop attr-code trdcattr-delivery-time
{&create-record}
&scop attr-code trdcattr-zakaz-date
{&create-record}
&scop attr-code trdcattr-othermoves
{&create-record}

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cr-tt-upd-general d-out-doc
PROCEDURE cr-tt-upd-general :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do on error undo, return error return-value :
define variable v-other as character   no-undo.

for each tt-upd-attr : delete tt-upd-attr . end.

&scop create-record create tt-upd-attr. ~
 assign~
  tt-upd-attr.code =  ~{&~{&attr-code~}~}  . ~
                                        ~
~{ str/tdat-cod.i                   ~
     tt-upd-attr.code           ~
     tt-upd-attr.type-attr      ~
     tt-upd-attr.format-attr    ~
     tt-upd-attr.fillin_width   ~
     tt-upd-attr.fillin_height  ~
     tt-upd-attr.label-attr     ~
     tt-upd-attr.user-can-edit  ~
     tt-upd-attr.output-display ~
     v-other                    ~
     tt-upd-attr.proc-attr       ~
     tt-upd-attr.full-screen-val ~
     tt-upd-attr.sort_  ~
     no-error                   ~
~}                              ~
 if error-status :error then do:    ~
   message "Ошибка при установке атрибутов документа." skip ~
           error-status :get-message(1) skip return-value ~
   view-as alert-box. ~
   return error. ~
 end.

&scop attr-code trdcattr-qntyplace
{&create-record}
&scop attr-code trdcattr-place-storage
{&create-record}
&scop attr-code trdcattr-dispath
{&create-record}
&scop attr-code trdcattr-packer
{&create-record}
&scop attr-code trdcattr-nfindoc
{&create-record}
&scop attr-code trdcattr-dfindoc
{&create-record}
&scop attr-code trdcattr-ddov
{&create-record}
&scop attr-code trdcattr-ndov
{&create-record}
&scop attr-code trdcattr-ndog
{&create-record}
&scop attr-code trdcattr-ddog
{&create-record}
&scop attr-code trdcattr-recipient
{&create-record}
&scop attr-code trdcattr-auto
{&create-record}
&scop attr-code trdcattr-driver
{&create-record}
&scop attr-code trdcattr-print-num
{&create-record}
&scop attr-code trdcattr-idCountryContr
{&create-record}
&scop attr-code trdcattr-nsf
{&create-record}
&scop attr-code trdcattr-dsf
{&create-record}
&scop attr-code trdcattr-t_pass-fname
{&create-record}
&scop attr-code trdcattr-t_pass-position
{&create-record}
&scop attr-code trdcattr-t_accept-fname
{&create-record}
&scop attr-code trdcattr-t_accept-position
{&create-record}
&scop attr-code trdcattr-ndovwho
{&create-record}
&scop attr-code trdcattr-nosn
{&create-record}
&scop attr-code trdcattr-cargo-desc
{&create-record}
&scop attr-code trdcattr-carry-type
{&create-record}
&scop attr-code trdcattr-cargo-mass
{&create-record}
&scop attr-code trdcattr-exp-trans
{&create-record}
&scop attr-code trdcattr-zakaz-number
{&create-record}
&scop attr-code trdcattr-delivery-date
{&create-record}
&scop attr-code trdcattr-delivery-time
{&create-record}
&scop attr-code trdcattr-ord_adr
{&create-record}
&scop attr-code trdcattr-ord_contact
{&create-record}
&scop attr-code trdcattr-ord_phone
{&create-record}
&scop attr-code trdcattr-ord_dl
{&create-record}
&scop attr-code trdcattr-zakaz-date
{&create-record}
&scop attr-code trdcattr-othermoves
{&create-record}

if v-is-pharm = "yes":U then do:
  &scop attr-code trdcattr-ser_on_pack
  {&create-record}
end.

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-record d-out-doc
PROCEDURE create-record :
define  input parameter p-doc-code   like ub.trn-doc.doc-code    no-undo.
define  input parameter p-attr-code  like ub.doc-attr.attr-code  no-undo.
define  input parameter p-attr-value like ub.doc-attr.attr-value no-undo.
define output parameter p-exist      as   logical                no-undo.

  { str/tdat-xst.i
      p-doc-code
      p-attr-code
      p-exist }
  if p-exist = no then do:
    { str/tdat-wrt.i
        p-doc-code
        p-attr-code
        p-attr-value
        no-error     }
    if error-status :error then do:
      message error-status :error error-status :get-message( 1 ) '"' + p-attr-code + '"'
      view-as alert-box error.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-out-doc  _DEFAULT-DISABLE
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
  HIDE FRAME d-out-doc.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-out-doc  _DEFAULT-ENABLE
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
  DISPLAY varpurch-chs is-repay is-cons is-storage is-oldcons a-n-c loc-code
          loc-name loc-art varcontract-prn-code sum-base sum-rubl wrkr-name
          fact-base fact-rubl TEXT-RUBL agnt-name pay-rubl boss-name rsn-name
          flora-PS
      WITH FRAME d-out-doc.
  IF AVAILABLE ub.clients THEN
    DISPLAY ub.clients.obj-name
      WITH FRAME d-out-doc.
  IF AVAILABLE ub.pay-type THEN
    DISPLAY ub.pay-type.obj-name
      WITH FRAME d-out-doc.
  IF AVAILABLE t-doc THEN
    DISPLAY t-doc.cli-code t-doc.cli-type t-doc.hold-obj-code t-doc.hold-obj-type
          t-doc.print-rubl t-doc.doc-date t-doc.fact-date t-doc.shift-date
          t-doc.shift-name t-doc.shift-num t-doc.d-card t-doc.discnt-pc
          t-doc.discnt-type t-doc.out-code t-doc.base-rate t-doc.base-scale
          t-doc.tot-calc t-doc.discnt-rubl t-doc.pay-code t-doc.wrkr t-doc.agnt
          t-doc.boss t-doc.doc-qnty t-doc.fact-qnty t-doc.VAT-base
          t-doc.VAT-rubl t-doc.tot-cli t-doc.reason-code
      WITH FRAME d-out-doc.
  ENABLE b-exit rect-tot rect-prc b-cur b-arch b-notes b-attr b-cnt b-fixprice
         b-re-price b-rsrv-doc-list b-dopinf b-history b-help b-prev b-next
         t-doc.cli-code t-doc.cli-type r-clients ub.clients.obj-name
         t-doc.hold-obj-code t-doc.hold-obj-type t-doc.print-rubl
         t-doc.doc-date t-doc.fact-date t-doc.shift-date t-doc.shift-name
         t-doc.shift-num r-sht t-doc.d-card t-doc.discnt-pc t-doc.discnt-type
         t-doc.out-code r-outs t-doc.base-rate t-doc.base-scale r-acc
         t-doc.tot-calc t-doc.discnt-rubl varpurch-chs t-doc.pay-code r-pay
         is-repay t-doc.wrkr r-wrkr is-cons t-doc.agnt r-agnt is-storage
         is-oldcons t-doc.boss r-boss r-reas a-n-c loc-code loc-name loc-art
         varcontract-prn-code b-contr-lkp b-mark b-add b-prt b-parts b-lkp
         b-chg b-del b-notes-line br-dtl t-doc.doc-qnty t-doc.fact-qnty
         sum-base sum-rubl ub.pay-type.obj-name t-doc.VAT-base t-doc.VAT-rubl
         wrkr-name fact-base fact-rubl TEXT-RUBL agnt-name t-doc.tot-cli
         pay-rubl boss-name t-doc.reason-code rsn-name flora-PS b-marks
      WITH FRAME d-out-doc.
  {&OPEN-BROWSERS-IN-QUERY-d-out-doc} .
  FRAME d-out-doc:SENSITIVE = NO.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-gds d-out-doc
PROCEDURE find-gds :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
find ub.bar-code where ub.bar-code.b-code = b-c no-lock.
find ub.goods where ub.goods.gds-code = ub.bar-code.gds-code no-lock.
assign gds-rec = recid (ub.goods).
find first ub.gds-dtl where
     ub.gds-dtl.doc-code  = t-doc.doc-code     and
     ub.gds-dtl.artic     = ub.goods.artic     and
     ub.gds-dtl.prod-type = ub.goods.prod-type and
     ub.gds-dtl.prod-code = ub.goods.prod-code and
     ub.gds-dtl.prt-code  = ub.bar-code.node-code no-lock no-error.
if not available ub.gds-dtl then do:
   message "В накладной не найден товар по данному бар-коду."
    view-as alert-box error buttons ok.
    return error.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-attr-flora d-out-doc
PROCEDURE init-attr-flora :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do on error undo, return error return-value :

run cr-tt-upd in this-procedure no-error.

define variable varexist                  as logical   no-undo.

&scop create-record run create-record in this-procedure (  input t-doc.doc-code ~
                                                        ,  input ~{&~{&attr-code~}~} ~
                                                        ,  input  ~{&attr-val~} ~
                                                        , output varexist ) no-error.
&scop attr-val  string(today)
&scop attr-code trdcattr-frsrv-date
{&create-record}
&scop attr-val ""
&scop attr-code trdcattr-ord_time
{&create-record}
&scop attr-code trdcattr-befpay
{&create-record}
&scop attr-code trdcattr-ord_Nchek
{&create-record}
&scop attr-code trdcattr-deliv
{&create-record}
&scop attr-code trdcattr-sumwrk
{&create-record}
/*
&scop attr-code trdcattr-sumsrk
{&create-record}
*/
&scop attr-code trdcattr-ord_contact
{&create-record}
&scop attr-code trdcattr-ord_phone
{&create-record}
&scop attr-code trdcattr-ord_adr
{&create-record}
&scop attr-code trdcattr-ord_dl
{&create-record}
&scop attr-code trdcattr-delivery-date
{&create-record}
&scop attr-code trdcattr-delivery-time
{&create-record}
&scop attr-code trdcattr-zakaz-date
{&create-record}

define buffer buf_clients for ub.clients.
define buffer buf_person  for ub.person.
define buffer buf_firm    for ub.firm.
define variable v-adr as character no-undo init "" .
define variable v-h   as character no-undo init "" .
find first buf_clients no-lock where
           buf_clients.obj-code =  t-doc.cli-code  and
           buf_clients.obj-type =  t-doc.cli-type    no-error .
if  available buf_clients then do:
  v-h = buf_clients.obj-name .
  if t-doc.cli-type = {&cmp} then do:
    find first buf_firm no-lock where buf_firm.firm-code = t-doc.cli-code no-error .
         v-adr = trim ( buf_firm.post-addr1 ) .
    end.
    else do:
        find first buf_person no-lock where buf_person.psn-code = t-doc.cli-code no-error .
        v-adr = string(buf_person.ind) + " " + buf_person.city + " " + buf_person.address .
    end.
end.

&scop attr-val  string(t-doc.doc-date)
&scop attr-code trdcattr-dchek
{&create-record}


&scop attr-val  v-adr
&scop attr-code trdcattr-ord_adr
{&create-record}

&scop attr-val  v-h
&scop attr-code trdcattr-ord_hwo
{&create-record}

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-attr-general d-out-doc
PROCEDURE init-attr-general :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/* Атрибуты расходного документа */
do on error undo, return error return-value :
run cr-tt-upd-general .
define variable varexist                  as logical   no-undo.

&scop create-record run create-record in this-procedure (  input t-doc.doc-code ~
                                                        ,  input ~{&~{&attr-code~}~} ~
                                                        ,  input  ~{&attr-val~} ~
                                                        , output varexist ) no-error.
&scop attr-val  ""
&scop attr-code trdcattr-qntyplace
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-place-storage
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-dispath
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-packer
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-nfindoc
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-dfindoc
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-ddov
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-ndov
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-ndog
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-ddog
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-recipient
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-auto
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-driver
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-print-num
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-idCountryContr
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-nsf
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-dsf
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-t_pass-fname
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-t_pass-position
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-t_accept-fname
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-t_accept-position
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-ndovwho
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-nosn
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-cargo-desc
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-carry-type
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-cargo-mass
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-exp-trans
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-zakaz-number
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-ord_contact
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-ord_phone
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-ord_adr
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-ord_dl
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-delivery-date
{&create-record}
&scop attr-val  ""
&scop attr-code trdcattr-delivery-time
{&create-record}
&scop attr-code trdcattr-zakaz-date
{&create-record}
&scop attr-code trdcattr-othermoves
{&create-record}

if v-is-pharm = "yes":U then do:
  &scop attr-code trdcattr-ser_on_pack
  {&create-record}
end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE inv-line_price d-out-doc
PROCEDURE inv-line_price :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define  input parameter p-gds-dtl-rec  as   recid                 no-undo.
  define  input parameter p-print-rubl   as   logical               no-undo.
  define output parameter p-out-price-kg like ub.gds-dtl.price-rubl no-undo initial 0.0.

  define variable p-inv-line-rec as recid   no-undo.
  define variable is-petrol      as logical no-undo.
  define variable is-pieces      as logical no-undo.

  define buffer buf_inv-line for ub.inv-line.
  define buffer buf_gds-dtl  for ub.gds-dtl.

  do on error undo, return error return-value :
    find buf_gds-dtl        no-lock where recid( buf_gds-dtl ) = p-gds-dtl-rec no-error.
    if not available buf_gds-dtl then do:
      assign p-out-price-kg = ?.
      undo, return error "inv-line_price: не найдена строка накладной".
    end.
    { str/is-petrl.i
        buf_gds-dtl.artic
        buf_gds-dtl.prod-type
        buf_gds-dtl.prod-code
        is-petrol
        is-pieces
        no-error
    }
    if error-status :error or v-is-ptrl <> "yes" or is-petrol <> yes or is-pieces <> no then do:
      undo, return error substitute( 'inv-line_price: &1 (произв. &2 &3) не топливный товар',
                                     buf_gds-dtl.artic, buf_gds-dtl.prod-type, buf_gds-dtl.prod-code ).
    end.

    find buf_inv-line no-lock where
         buf_inv-line.doc-code  = buf_gds-dtl.doc-code  and
         buf_inv-line.artic     = buf_gds-dtl.artic     and
         buf_inv-line.prod-code = buf_gds-dtl.prod-code and
         buf_inv-line.prod-type = buf_gds-dtl.prod-type no-error.
    if available buf_inv-line then do:
      assign
        p-inv-line-rec = recid( buf_inv-line )
      .
      find buf_gds-dtl  exclusive-lock where recid( buf_gds-dtl  ) = p-gds-dtl-rec.
      find buf_inv-line exclusive-lock where recid( buf_inv-line ) = p-inv-line-rec.
      assign
        p-out-price-kg = ( if p-print-rubl = yes then buf_inv-line.wast-rubl else buf_inv-line.wast-base )
      .
      find buf_inv-line        no-lock where recid( buf_inv-line ) = p-inv-line-rec.
      find buf_gds-dtl         no-lock where recid( buf_gds-dtl  ) = p-gds-dtl-rec.

      release buf_inv-line.
      release buf_gds-dtl.
    end. /* if available buf_inv-line */
  end. /* on error */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE inv-line_qnty d-out-doc
PROCEDURE inv-line_qnty :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define  input parameter p-gds-dtl-rec as   recid                no-undo.
  define output parameter p-out-qnty-kg like ub.gds-dtl.fact-qnty no-undo initial 0.0.

  define variable is-petrol as logical no-undo.
  define variable is-pieces as logical no-undo.

  define buffer buf_inv-line for ub.inv-line.
  define buffer buf_gds-dtl  for ub.gds-dtl.

  do on error undo, return error return-value :
    find buf_gds-dtl no-lock where recid( buf_gds-dtl ) = p-gds-dtl-rec no-error.
    if not available buf_gds-dtl then do:
      assign p-out-qnty-kg = ?.
      undo, return error "inv-line_qnty: не найдена строка накладной".
    end.
    { str/is-petrl.i buf_gds-dtl.artic
                 buf_gds-dtl.prod-type
                 buf_gds-dtl.prod-code
                 is-petrol
                 is-pieces             no-error }
    if error-status :error or v-is-ptrl <> "yes" or is-petrol <> yes or is-pieces <> no then do:
      undo, return error substitute( 'inv-line_qnty: &1 (произв. &2 &3) не топливный товар',
                                     buf_gds-dtl.artic, buf_gds-dtl.prod-type, buf_gds-dtl.prod-code ).
    end.
    find buf_inv-line no-lock where
         buf_inv-line.doc-code  = buf_gds-dtl.doc-code  and
         buf_inv-line.artic     = buf_gds-dtl.artic     and
         buf_inv-line.prod-code = buf_gds-dtl.prod-code and
         buf_inv-line.prod-type = buf_gds-dtl.prod-type no-error.
    if available buf_inv-line then do: assign p-out-qnty-kg = buf_inv-line.wast-cli-qnty. end.
  end. /* on error */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE inv-line_recalc-qty d-out-doc
PROCEDURE inv-line_recalc-qty :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter p-doc-code  like ub.gds-dtl.doc-code  no-undo.
  define input parameter p-artic     like ub.gds-dtl.artic     no-undo.
  define input parameter p-prod-type like ub.gds-dtl.prod-type no-undo.
  define input parameter p-prod-code like ub.gds-dtl.prod-code no-undo.
  define input parameter p-is-fact   as   logical              no-undo.
  define input parameter p-doc-qnty  like ub.gds-dtl.doc-qnty  no-undo.
  define input parameter p-fact-qnty like ub.gds-dtl.fact-qnty no-undo.

  define variable is_OK     as logical no-undo.
  define variable is_petrol as logical no-undo.
  define variable is_pieces as logical no-undo.
  define variable r-inv-lin as recid   no-undo.
  define variable r-doc-lin as recid   no-undo.
  define variable d_doc-qty as decimal no-undo.

  define buffer buf_doc-line for ub.doc-line.
  define buffer buf_gds-dtl  for ub.gds-dtl.

  do on error undo, return return-value :
    if v-is-ptrl <> "yes" then do: undo, return. end.
    { str/is-petrl.i p-artic
                 p-prod-type
                 p-prod-code
                 is_petrol
                 is_pieces   no-error }
    if error-status :error or is_petrol <> yes or is_pieces <> no then do: undo, return. end.
    find first buf_doc-line no-lock where
               buf_doc-line.doc-code  = p-doc-code  and
               buf_doc-line.artic     = p-artic     and
               buf_doc-line.prod-type = p-prod-type and
               buf_doc-line.prod-code = p-prod-code no-error.
    if not available buf_doc-line then do: undo, return error "не найдена строка накладной". end.
    assign r-doc-lin = recid( buf_doc-line ).
    for each buf_gds-dtl no-lock where
             buf_gds-dtl.doc-code  = p-doc-code  and
             buf_gds-dtl.artic     = p-artic     and
             buf_gds-dtl.prod-type = p-prod-type and
             buf_gds-dtl.prod-code = p-prod-code :
      assign d_doc-qty = d_doc-qty + ( if buf_gds-dtl.doc-qnty = ? then 0 else buf_gds-dtl.doc-qnty ).
    end. /* for each buf_gds-dtl */
    if d_doc-qty * buf_doc-line.doc-density <> buf_doc-line.cli-qnty then do:
      find buf_doc-line exclusive-lock where recid( buf_doc-line ) = r-doc-lin.
      assign buf_doc-line.cli-qnty = d_doc-qty * buf_doc-line.doc-density.
      find buf_doc-line        no-lock where recid( buf_doc-line ) = r-doc-lin.
    end. /* cli-qnty */
    { str/corinvln.i p-doc-code
                 p-artic
                 p-prod-type
                 p-prod-code
                 0
                 0
                 0
                 0
                 "( if p-is-fact = yes then p-doc-qnty * buf_doc-line.doc-density else p-fact-qnty * buf_doc-line.fact-density )"
                 "( if p-is-fact = yes then buf_doc-line.doc-density else buf_doc-line.fact-density )"
                 r-inv-lin            no-error }
    if error-status :error then do: undo, return. end.
    assign is_OK = {&browse-name} :refresh( ) in frame {&frame-name}.
  end. /* on error */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-add d-out-doc
PROCEDURE local-add :
define buffer buf_assortment-matrix for ub.assortment-matrix  .
define buffer bf_contract-specif for ub.contract-specif.
define buffer bf-hv_doc-line     for ub.doc-line.
define buffer bf_goods           for ub.goods.
define buffer bf_parts           for ub.parts .
define buffer bf_doc-line        for ub.doc-line.
define buffer bf_gds-dtl         for ub.gds-dtl .
define buffer bf_marking-lines   for ub.marking-lines .
define buffer bf_gds-obj            for ub.gds-obj .
define variable varlog   as logical   no-undo.
define variable varnotes as character no-undo.
define buffer bbb_goods for ub.goods  .
define variable  var_is-petrol as logical   no-undo .
define variable  var_is-pieces as logical   no-undo .
define variable varvalue        as character no-undo .
define variable vartype         as character no-undo .
define variable vIsExemplarGoods as logical no-undo .

define variable v-type-mode-spr as character no-undo .
define variable varschartic like doc-line.artic initial " " no-undo.
define variable v-choice    as   integer                    no-undo.
define variable v-rid       as   integer                    no-undo.
define variable v-rid-list  as   char                       no-undo.
define variable i           as   integer                    no-undo.

define variable v-mark-weight as decimal no-undo .
define variable v-isweighed as logical no-undo .

do on error undo, return error return-value :
run check-rate no-error.
if error-status :error then do:
  message "Ошибка при проверке курса валют." skip
          return-value
  view-as alert-box error.
  return error return-value.
end.
.

if t-doc.reason-code <> ?
and t-doc.reason-code > 0
then do :
  if (lookup( string(t-doc.reason-code), v-reasons-for-return) > 0
    or v-is-return)
  and t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
  then do :
    /*Возврат*/
    v-choice = 5.
  end.
  else do :
    v-choice = 0.
  end.
end.
else do :
  v-choice = 0.
  if v-reasonm and
  lookup( t-doc.ext-doc-type, v-reasonme) = 0 and
  lookup( t-doc.ext-doc-type, {&TDEDT_List-not-ver-reason}) = 0
  then do:
    message "Сначала укажите Основание" view-as alert-box .
    apply "choose" to r-reas in frame {&frame-name}.
    return .
  end.
end.

  
if t-doc.contract-code <> 0 and v-choice <> 5 then do:
     {str/cont-slave-inc.i
          &FIND_FIRST = YES
          &BUFFER_SPECIF   = bf_contract-specif
          &P_HOST_CODE     = t-doc.host-code
          &P_CONTRACT_NUM  = t-doc.contract-code
          &NO_LOCK=YES
          &NO_ERROR=YES
     }

    if available bf_contract-specif and not t-doc.is-flora then do:
      run gbl/d-askw.w
        (input "Добавление товаров"
        ,input "Выберите один из пунктов для добавления в накладную" + {&new-line}
             + "товаров по спецификации к договору" + {&new-line}
        ,input "|"
        ,input "Все|Выборочно|По справочнику|Отказ"
        ,input "Все недобавленные товары по спецификации|"
             + "Выборочно товары по спецификации|"
             + "Выбор товаров из справочника|"
             + "Отказ от выполнения операции"
        ,input 1 /* значение возвращаемое при нажатии enter */
        ,input 4 /* значение возвращаемое при нажатии escape */
        ,output v-choice
        ).
      if v-choice = 4 then do:
        run UI-on in this-procedure ( input "line" ).
        return.
      end.
    end.
end.
  if v-choice = 0 then
    v-choice = 3. /* Выбор из справочника */

   assign
    varnotes = '':u
    varlns-cnt = 1.

  case v-choice:
    when 1 then do: /* Все товары по спецификации */

      {str/cont-slave-inc.i
           &FOR_ = YES
           &EACH_ = YES
           &BUFFER_SPECIF   =  bf_contract-specif
           &P_HOST_CODE     =  t-doc.host-code
           &P_CONTRACT_NUM  =  t-doc.contract-code
           &NO_LOCK=YES
           &NO_END=YES
      }

       on error undo, return error return-value :
    find first bf_goods where bf_goods.gds-code = bf_contract-specif.gds-code no-lock.
    find first bf-hv_doc-line where bf-hv_doc-line.doc-code  = t-doc.doc-code     and
                                    bf-hv_doc-line.artic     = bf_goods.artic     and
                                    bf-hv_doc-line.prod-type = bf_goods.prod-type and
                                    bf-hv_doc-line.prod-code = bf_goods.prod-code no-lock no-error.
    if not available bf-hv_doc-line then do:
      assign
        varnotes = varnotes + (if varnotes = '':u then '':u else ',':u) + string(recid(bf_goods)).
    end.
  end.
  if varnotes = '':u then do:
    message "Вы добавили уже все товары по спецификации."
    view-as alert-box.
    return error.
  end.
end.

    when 2 then do: /* Выборочно товары по спецификации */
      run str/contspec.w (input parparentproc,
                      input "b-sel,b-mark",
                      input {&lookup},
                  input t-doc.host-code,
                      input t-doc.contract-code,
                      output v-rid-list) .
      if v-rid-list = '':u then do:
        message "Нет выбранных товаров по спецификации."
          view-as alert-box.
      end.
      /* Формируем список recid'ов товаров по выбранным строкам спецификации */
      do i = 1 to num-entries(v-rid-list):
        v-rid = integer(entry(i, v-rid-list)).
        find bf_contract-specif where recid(bf_contract-specif) = v-rid no-lock no-error.
        if available bf_contract-specif then do:
          find first bf_goods where bf_goods.gds-code = bf_contract-specif.gds-code no-lock.
          assign
            varnotes = varnotes + (if varnotes = '':u then '':u else ',':u) + string(recid(bf_goods)).
        end.
      end.
    end.

    when 3 then do: /* из справочника */
    find first buf_assortment-matrix no-lock where
               buf_assortment-matrix.obj-code = v-cntxt-obj-code and
               buf_assortment-matrix.obj-type = v-cntxt-obj-type and
               buf_assortment-matrix.asmt-status = integer ({&current-status-int}) no-error .
                if available buf_assortment-matrix then do:
                    v-type-mode-spr = {&g___object} .
                end.
                else do:
                    v-type-mode-spr = {&all} .
                end.
      run str/chs-gds.w ( input parparentproc
                    , input v-cntxt-obj-type
                    , input v-cntxt-obj-code
                    , input parlist-mode
                    , input t-doc.status_
                    , input "Строка ПН № " + t-doc.doc-code + " " + t-doc.status_ + " " + string (t-doc.flag_, "+/-")
                    , input v-type-mode-spr  /*режим вызова справочника товаров*/
                    , input t-doc.cli-type
                    , input t-doc.cli-code
                    , input t-doc.host-code
                    , input t-doc.ext-doc-type
                    , input-output varschartic
                    , output varnotes) no-error.
    end.
    
    when 5 then do: /* из документа прихода (для оформления возврата через расход) */
      if v-is-return
	  then do :
	    run gbl/d-askw.w
	      (input "Добавление товаров"
	      ,input "Выберите один из пунктов для добавления в накладную" + {&new-line}
	      ,input "|"
	      ,input "По документам|По справочнику|Отказ"
	      ,input "Добавление товаров из конкретной ПН|"
	      + "Добавление товаров из справочника|"
	      + "Отказ от выполнения операции"
	      ,input 1 /* значение возвращаемое при нажатии enter */
	      ,input 3 /* значение возвращаемое при нажатии escape */
	      ,output v-choice
	      ).
	    if v-choice = 3 then 
	    do:
	      run UI-on in this-procedure ( input "line" ).
	      return.
	    end.
	    if v-choice = 1
	    then do :
	      define variable ret-doc-code as character no-undo .
	      run local-outs-ret-doc (output ret-doc-code) no-error .
	      if error-status :error then undo, return .
	      if ret-doc-code > ""
	      and can-find(ub.trn-doc no-lock where ub.trn-doc.doc-code = ret-doc-code)
	      then do :
	        run ref/nakl-gds-ch.w (input ret-doc-code, input edo-return, output varnotes) .
	      end .
	    end .
	    if v-choice = 2
	    then do :
	      find first buf_assortment-matrix no-lock where
	        buf_assortment-matrix.obj-code = v-cntxt-obj-code and
	        buf_assortment-matrix.obj-type = v-cntxt-obj-type and
	        buf_assortment-matrix.asmt-status = integer ({&current-status-int}) no-error .
	      if available buf_assortment-matrix then 
	      do:
	        v-type-mode-spr = {&g___object} .
	      end.
	      else 
	      do:
	        v-type-mode-spr = {&all} .
	      end.
	      run str/chs-gds.w ( input parparentproc
	        , input v-cntxt-obj-type
	        , input v-cntxt-obj-code
	        , input parlist-mode
	        , input t-doc.status_
	        , input "Строка ПН № " + t-doc.doc-code + " " + t-doc.status_ + " " + string (t-doc.flag_, "+/-")
	        , input v-type-mode-spr  /*режим вызова справочника товаров*/
	        , input t-doc.cli-type
	        , input t-doc.cli-code
	        , input t-doc.host-code
	        , input t-doc.ext-doc-type
	        , input-output varschartic
	        , output varnotes) no-error.
	    end .
	  end .
	  else do :
	    if t-doc.out-code = ?
	    or t-doc.out-code = ""
	    or not can-find(ub.trn-doc no-lock where ub.trn-doc.doc-code = t-doc.out-code)
	    then do :
	      message "Сначала выберите корректный источник (ПН)" view-as alert-box .
	      return.
	    end.
	    run ref/nakl-gds-ch.w (input t-doc.out-code, input ?, output varnotes) .
	  end .
    end.
  end case.

if varnotes = '' then return.
assign
  varline-mode = {&add-def}
  prt-rec = ?
  varlns-cnt = 1.
 if available ub.gds-dtl then do:
   assign prt-rec = recid(ub.gds-dtl).
 end.
 else do:
   assign prt-rec = ?.
 end.
add-goods_ :
do while varlns-cnt <= num-entries (varnotes):
  assign
    gds-rec = integer (entry (varlns-cnt, varnotes))
    varlns-cnt = varlns-cnt + 1.

  v-param = if v-exist then string(v-buket-gds-code)
              else ? .
  if t-doc.doc-type = {&expense} and
     t-doc.status_ = {&inquiry} then do:
     find first bbb_goods no-lock where
                recid(bbb_goods) = gds-rec .
     /* если бензин , то не добавляем в документ запр расход */
    { str/is-petrl.i
      bbb_goods.artic
      bbb_goods.prod-type
      bbb_goods.prod-code
      var_is-petrol
      var_is-pieces
    }
     if var_is-petrol = true then return error "Топливо нельзя продавать через ЗАПРОС ! " .
  end.
  
  find first bf_goods where recid(bf_goods) = gds-rec no-lock.
  RUN gds-attr-value (
          INPUT bf_goods.gds-code,
          INPUT {&attr-mark-type},
          OUTPUT varvalue,
          OUTPUT vartype
          ).
  
  if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
  then do :
    if EDOParSec:GetIsEDOForType(varvalue)
    or EDOParSec:GetIsArticForType(varvalue)
    or EDOParSec:GetIsMarkingForType(varvalue)
    then do :
      message "Товар " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " подлежит обязательной маркировке. Для возврата используйте документ Расход внешний"
      view-as alert-box .
      assign 
        varlns-cnt = varlns-cnt + 1.
      next.
    end .
  end .
  
  
  if varvalue > ""
  and EDOParSec:GetIsMarkingForType(varvalue)
  and not v-is-return
  then do :
    message "Товар:" bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " " skip
            "нельзя добавлять в ручном режиме, так как он подлежит маркировке и должен добавляться помарочно."
    view-as alert-box error.
    assign 
      varlns-cnt = varlns-cnt + 1.
    next.
  end .
  
  if v-is-return
  then do :
    find first bf_gds-obj no-lock where bf_gds-obj.obj-type  = t-doc.obj-type
                                    and bf_gds-obj.obj-code  = t-doc.obj-code
                                    and bf_gds-obj.artic     = bf_goods.artic
                                    and bf_gds-obj.prod-type = bf_goods.prod-type
                                    and bf_gds-obj.prod-code = bf_goods.prod-code
                                    no-error .
    if not available bf_gds-obj 
    then do:
      message "Критическая ошибка!" skip
              "Не найдена запись товара на объекте (gds-obj) " bf_goods.artic " " bf_goods.gds-name
      view-as alert-box error .
      assign 
        varlns-cnt = varlns-cnt + 1.
      next.
    end.
    
    if bf_gds-obj.free-qnty <= 0
    then do :
      message "Невозможно выполнить возврат товара " bf_goods.artic " " bf_goods.gds-name ", т.к. текущие свободные остатки равны 0."
      view-as alert-box .        
      assign 
        varlns-cnt = varlns-cnt + 1.
      next.
    end .
    if can-find(first bf_doc-line no-lock where bf_doc-line.doc-code = t-doc.doc-code
                                            and bf_doc-line.artic = bf_goods.artic
                                            and bf_doc-line.prod-code = bf_goods.prod-code
                                            and bf_doc-line.prod-type = bf_goods.prod-type)
    then do :
      message "Товар " bf_goods.artic " " bf_goods.gds-name
              " уже добавлен. Запрещено выбирать более одной партии в рамках одной накладной."
      view-as alert-box .        
      assign 
        varlns-cnt = varlns-cnt + 1.
      next.
    end .
    if v-choice = 1
    then do :
      run str/parts-l.w
      (  input parparentproc
       ,  input t-doc.obj-type            /* v-obj-type   */
       ,  input t-doc.obj-code            /* v-obj-code   */
       ,  input bf_goods.gds-code            /* p-gds-code   */
       ,  input ret-doc-code            /* p-doc-code   */
       ,  input {&lookup}              /* p-edit-mode  */
       ,  input {&parts-l_parts-document} /* p-r-parts    */
       ,  input {&parts-l_object-current} /* p-one-all    */
       ,  input {&parts-l_call-document} + {&delim-par} + "return"  /* p-call-point */
       , output varpart-rec                   /* part-recid   */
      ) .
    end .
    if v-choice = 2
    then do :
      run str/parts-l-ret.w
      (input ParParentProc
      ,input t-doc.obj-type            /* v-obj-type   */
      ,input t-doc.obj-code            /* v-obj-code   */
      ,input bf_goods.gds-code          /* p-gds-code   */
      ,input t-doc.doc-code            /* p-doc-code   */
      ,input {&lookup} /* p-edit-mode  */
      ,input {&parts-l_parts-document} /* p-r-parts    */
      ,input {&parts-l_object-current} /* p-one-all    */
      ,input {&parts-l_call-document}  /* p-call-point */
      ,output varpart-rec              /* part-recid   */
      ) no-error .
    end .
    find first bf_parts no-lock where recid(bf_parts) = varpart-rec no-error .
    if not available bf_parts
    then do :
      assign 
        varlns-cnt = varlns-cnt + 1.
      next.
    end . 
    
    if t-doc.reason-code = 25
    then do :
      if t-doc.out-code = ?
      or t-doc.out-code = ""
      then do :
        t-doc.out-code = bf_parts.in-code .
        display t-doc.out-code with frame {&frame-name}.
      end .
      else do :
        if t-doc.out-code <> bf_parts.in-code
        then do :
          message 'Для схемы возврата "Корректировка поступления" нельзя выбрать партии из разных ПН' view-as alert-box .
          assign 
            varlns-cnt = varlns-cnt + 1.
          next.
        end .
      end .
    end .
          
    if EDOParSec:GetIsEDOForType(varvalue)
    or EDOParSec:GetIsArticForType(varvalue)
    or EDOParSec:GetIsMarkingForType(varvalue)
    then do :
      find first bf_marking-lines no-lock where bf_marking-lines.gds-code  = bf_goods.gds-code
                                            and bf_marking-lines.obj-type  = bf_parts.obj-type
                                            and bf_marking-lines.obj-code  = bf_parts.obj-code
                                            and bf_marking-lines.in-code   = bf_parts.in-code
                                            and bf_marking-lines.out-code  = bf_parts.out-code
                                            and bf_marking-lines.part-code = bf_parts.part-code
                                            no-error .
      if available bf_marking-lines
      or (num-entries(bf_parts.part-code, "_") = 2 and length(entry(1, bf_parts.part-code, "_")) = 14)
/*      or t-doc.ext-doc-type = {&TDEDT_Spi_Vnesh}*/
      then do :
        message "Товар подлежит обязательной маркировке и прослеживаемости, для возврата поставщику необходимо просканировать КМ" view-as alert-box .
        
        run scanMark in this-procedure (recid(bf_parts), buffer bf_goods, output vOk) no-error.
        if not vOk then
          next add-goods_ .
      end .
      else do :
        if EDOParSec:GetIsTransitionalForType(varvalue)
        then do :
          message "Возвращаем маркированные упаковки товара?" view-as alert-box question buttons yes-no update varlog .
          if varlog
          then do :
            run scanMark in this-procedure (recid(bf_parts), buffer bf_goods, output vOk) no-error.
            if not vOk then
              next add-goods_ .
          end .
          else do :
            run str/out-add.p (parparentproc,
                recid(t-doc),
                ?,
                ?,
                gds-rec,
                {&add-def} + {&delim-par} + "return=" + string(recid(bf_parts)),
                "Transitional") no-error.
            if error-status :error then 
            do:
              next add-goods_ .
            end.
          end .
        end .
        else do :
          message "Товар подлежит обязательной маркировке и прослеживаемости, для возврата поставщику необходимо просканировать КМ" view-as alert-box .
          
          run scanMark in this-procedure (recid(bf_parts), buffer bf_goods, output vOk) no-error.
          if not vOk then
            next add-goods_ .
        end .
      end .
    end .
    else do :
      run str/out-add.p (parparentproc,
          recid(t-doc),
          ?,
          ?,
          gds-rec,
          {&add-def} + {&delim-par} + "return=" + string(recid(bf_parts)),
          v-param) no-error.
      if error-status :error then 
      do:
        next add-goods_ .
      end.
    end .
    
  end .
  else
  if v-choice = 5
  then do :
    run str/out-add.p (parparentproc,
                   recid(t-doc),
                   ?,
                   ?,
                   gds-rec,
                   {&add-def} + {&delim-par} + "return",
                   v-param) no-error.
    if error-status :error then do:
      next.
    end.
  end .
  else do : 
    run isExemplarGoods in this-procedure 
       (t-doc.obj-type, t-doc.obj-code, bf_goods.gds-code, output vIsExemplarGoods).
    v-isweighed = WghProdVariable(t-doc.obj-type, t-doc.obj-code, bf_goods.gds-code) .
    if vIsExemplarGoods
    or v-isweighed
    then do: 
      /* для списания требуется сканирование марок */
      message "Товар подлежит обязательной маркировке и прослеживаемости, для списания необходимо просканировать КМ" view-as alert-box .

      run scanMark in this-procedure (?, buffer bf_goods, output vOk) no-error.
      if not vOk then
        next add-goods_ .
    end.
    else
    do:    
        run str/out-add.p (parparentproc,
                       recid(t-doc),
                       ?,
                       ?,
                       gds-rec,
                       {&add-def},
                       v-param) no-error.
        if error-status :error then do:
          next.
        end.
    end. 
  end.
end.

if t-doc.ext-doc-type = {&TDEDT_Ras_Perem}
then do :
  run local-cur in this-procedure (input 4) no-error.
  if error-status :error then return .
end .
/* в ui-on давятся пустые ub.doc-line */
run ui-on ("line").
if prt-rec <> ? then do:
  reposition br-dtl to recid prt-rec no-error.
end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-check-gds d-out-doc
PROCEDURE local-check-gds :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable l-inv-on as logical no-undo .

  { gbl/gdsobjat.i
    ub.doc-line.obj-type
    ub.doc-line.obj-code
    ub.doc-line.artic
    ub.doc-line.prod-type
    ub.doc-line.prod-code
    "'inv-on=request'"
    l-inv-on
    no-error }
  if error-status :error then do:
    message
      "Ошибка получения признака товара на объекте" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return no-apply .
  end.

  if l-inv-on then do:
    message "Артикул :" ub.doc-line.artic ub.goods.gds-name
                    "- товар в инвентаризации."
                    skip (2) "Операция невозможна.".
    return error.
  end.
  if t-doc.status_ = {&inquiry} then do:
    message "Документ имеет статус ЗАПРОС. Изменение партий невозможно.".
    return error.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-cur d-out-doc
PROCEDURE local-cur :
define input parameter parwith-tax as integer no-undo.
define buffer cur-doc-line  for ub.doc-line.
define buffer cur-goods     for ub.goods.
define buffer cur-gds-dtl   for ub.gds-dtl.
define variable varpc       as decimal no-undo.
define variable varflag-ret as logical no-undo.
define variable round-base   as decimal no-undo. /* база для округления / коэффициент */
define variable round-method as character    no-undo. /* способ округления */
define variable varnew-price like ub.doc-line.price-base no-undo.

define variable v-vat-pc        like ub.doc-line.vat-pc    no-undo.
/*define variable v-slt-pc        like ub.doc-line.slt-pc    no-undo.*/
/*define variable v-have-slt-pc   as logical              no-undo.*/
define variable v-host-code     like ub.sysconf.host-code  no-undo.
  
   if parwith-tax <> 4
   then do :
     case t-doc.doc-type
     :
       when {&expense}
       then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_expense_price':U
            {&cntxt-object}
            t-doc.host-code
            t-doc.obj-type
            t-doc.obj-code
            0
            0
            0
            true
            varlog
          }
       end.
       when {&return}
       then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_return_price':U
            {&cntxt-object}
            t-doc.host-code
            t-doc.obj-type
            t-doc.obj-code
            0
            0
            0
            true
            varlog
          }
  
       end.
       when {&write-off}
       then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_write-off_price':U
            {&cntxt-object}
            t-doc.host-code
            t-doc.obj-type
            t-doc.obj-code
            0
            0
            0
            true
            varlog
          }
  
       end.
       otherwise do:
         message
           vss-workfile vss-revision vss-description skip
           "Неизвестный тип документа" t-doc.doc-type skip
           "Документ" t-doc.doc-code skip
           view-as alert-box error .
         undo, return error return-value .
       end.
     end case .
   end .
   
   if varlog = no then return error.
   for each cur-doc-line no-lock where
            cur-doc-line.doc-code = t-doc.doc-code
   :
        { str/is-petrl.i
            cur-doc-line.artic
            cur-doc-line.prod-type
            cur-doc-line.prod-code
            is-petrolium
            is-pieces
            no-error
        }
        if error-status :error then do:
          message "Ошибка при вызове процедуры lib-trn_is-petrl из файла out-doc.w."
          view-as alert-box.
          return error.
        end.
        if is-petrolium = yes then do: assign varlog = no. end.
   end.
   if varlog = no then do:
      message "В накладной есть топливо. Запрещено устанавливать учетные цены."
      view-as alert-box.
      return error.
   end.

   assign varpc       = 0.00
          varflag-ret = no.
   if parwith-tax <> 3
   and parwith-tax <> 4
   then do:
     run str/pc-ov.w (input  parwith-tax,
                  output varpc,
                  output varflag-ret,
                  output round-base,
                  output round-method) no-error.
     if error-status :error or
        varflag-ret <> yes then return error.
   end.
   if parwith-tax = 4
   then do :
     assign
       varpc = 0
       varflag-ret = yes
       round-base = 0
       round-method = "Отключено"
     .
     parwith-tax = 2 .
   end .
   
   run waitfram-show in this-procedure (input "Простановка учетных цен").
   tr:
   do transaction:
   for each  cur-doc-line where cur-doc-line.doc-code   = t-doc.doc-code         ,
       first cur-goods    where cur-goods.artic         = cur-doc-line.artic     and
                                cur-goods.prod-type     = cur-doc-line.prod-type and
                                cur-goods.prod-code     = cur-doc-line.prod-code no-lock,
       each  cur-gds-dtl  where cur-gds-dtl.doc-code    = cur-doc-line.doc-code  and
                                cur-gds-dtl.artic       = cur-doc-line.artic     and
                                cur-gds-dtl.prod-type   = cur-doc-line.prod-type and
                                cur-gds-dtl.prod-code   = cur-doc-line.prod-code no-lock:

       assign
       line-rec = recid(cur-doc-line)
       gds-rec  = recid(cur-goods)
       prt-rec  = recid(cur-gds-dtl).
       { str/in-vatp.i calc cur-doc-line. t-doc. g }

       { gbl/hostcode.i t-doc.obj-type t-doc.obj-code v-host-code }
       { gbl/pftxvalg.i cur-goods.gds-code {&vat-tax-code} ? v-host-code t-doc.obj-type t-doc.obj-code v-vat-pc no-error }
       case parwith-tax:
       when 1 then do:
         assign varnew-price = (if t-doc.print-rubl then ((price-rubl-with-tax-loc - road-tax-rubl-loc - vat-rubl-loc) * (100 + varpc) / 100 * (100 + v-vat-pc) / 100 + road-tax-rubl-loc)
                                                    else ((price-base-with-tax-loc - road-tax-base-loc - vat-base-loc) * (100 + varpc) / 100 * (100 + v-vat-pc) / 100 + road-tax-base-loc)).
       end.
       when 2 then do:
         assign varnew-price = (if t-doc.print-rubl then price-rubl-with-tax-loc * (100 + varpc) / 100
                                                    else price-base-with-tax-loc * (100 + varpc) / 100).
       end.
       when 3 then do:
         assign varnew-price = (if t-doc.print-rubl then (price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc)
                                                    else (price-base-with-tax-loc - vat-base-loc - slt-base-loc)).
       end.
       end case.
       /*округление*/
       if parwith-tax <> 3 then do:
         { str/pr-99.i varnew-price round-method round-base}
       end.
       if lookup( string(t-doc.reason-code), v-reasons-for-return) > 0
       and t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
       then do :
         run str/out-add.p (parparentproc,
                        recid(t-doc),
                        recid(cur-doc-line),
                        recid(cur-gds-dtl),
                        recid(cur-goods),
                        "update-sale-price" + {&delim-par} + "return",
                        string(varnew-price)) no-error.
         if error-status :error then do:
            message "Ошибка при вызове программы out-add.p" view-as alert-box.
            run waitfram-hide in this-procedure .
            undo tr, return error.
         end.
       end.
       else do :  
         run str/out-add.p (parparentproc,
                        recid(t-doc),
                        recid(cur-doc-line),
                        recid(cur-gds-dtl),
                        recid(cur-goods),
                        "update-sale-price",
                        string(varnew-price)) no-error.
         if error-status :error then do:
            message "Ошибка при вызове программы out-add.p" view-as alert-box.
            run waitfram-hide in this-procedure .
            undo tr, return error.
         end.
       end.
       if parwith-tax = 3 then do:
         assign
           cur-doc-line.vat-pc = 0
           cur-doc-line.slt-pc = 0.
       end.

       run waitfram-show in this-procedure (input "Простановка учетных цен по товару " + string(cur-goods.artic) + " " +
                        string(cur-goods.prod-type) + " " + string(cur-goods.prod-code)).
   end.
   if parwith-tax = 3 then do:
     run gbl/calc-trn.p (input parparentproc, input recid (t-doc)).
   end.
   end.
   run waitfram-hide in this-procedure .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-del d-out-doc
PROCEDURE local-del :
do on stop undo, return error:
  if del-list = "" then do:
    /* удаление 1 строки */
    if not available ub.gds-dtl then do:
      message "Неправильный выбор строки.".
      return error.
    end.
    varlog = no.
    message "Удалить строку накладной ?   Вы уверены ?"
                    view-as alert-box question buttons ok-cancel update varlog.
    if not varlog then return error.
    assign
      prt-rec = recid (ub.doc-line)
      del-list = string (recid (ub.gds-dtl)).
    get next br-dtl.
    if available ub.doc-line then del-rec = recid (ub.doc-line).
    else do:
      reposition br-dtl to recid prt-rec no-error.
      get prev br-dtl.
      del-rec = recid (ub.doc-line).
    end.
  end.
  else do:
    /* удаление отмеченных строк */
    varlog = no.
    message "УДАЛИТЬ  ВСЕ  ОТМЕЧЕННЫЕ  строки накладной ?   Вы уверены ?"
                    view-as alert-box question buttons ok-cancel update varlog.
    if not varlog then return error.
    del-rec = ?.
  end.
  assign
    varlns-cnt = 1.
  do while varlns-cnt <= num-entries (del-list):
    assign
      prt-rec = integer (entry (varlns-cnt, del-list))
      varlns-cnt = varlns-cnt + 1.
    find ub.gds-dtl where recid (ub.gds-dtl) = prt-rec exclusive.
    find ub.doc-line where ub.doc-line.doc-code = ub.gds-dtl.doc-code
                          and ub.doc-line.prod-code = ub.gds-dtl.prod-code
                          and ub.doc-line.prod-type = ub.gds-dtl.prod-type
                          and ub.doc-line.artic     = ub.gds-dtl.artic exclusive.

    define variable l-inv-on as logical no-undo .

    { gbl/gdsobjat.i
      ub.doc-line.obj-type
      ub.doc-line.obj-code
      ub.doc-line.artic
      ub.doc-line.prod-type
      ub.doc-line.prod-code
      "'inv-on=request'"
      l-inv-on
      no-error
    }
    if error-status :error then do:
      message
        "Ошибка получения признака товара на объекте" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return no-apply .
    end.
    if l-inv-on then do:
      message
        "Товар в инвентаризации." skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
        "Операция невозможна.".
      undo, return error.
    end.
    find ub.goods where ub.goods.prod-code = ub.gds-dtl.prod-code
                 and ub.goods.prod-type = ub.gds-dtl.prod-type
                 and ub.goods.artic     = ub.gds-dtl.artic no-lock.
    if lookup( string(t-doc.reason-code), v-reasons-for-return) > 0
    and t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
    then do :
      run str/out-add.p (parparentproc,
                     recid(t-doc),
                     recid(ub.doc-line),
                     recid(ub.gds-dtl),
                     recid (ub.goods),
                     "delete" + {&delim-par} + "return",
                     ?) no-error.
      if error-status :error then return error.
    end.
    else do :
      run str/out-add.p (parparentproc,
                     recid(t-doc),
                     recid(ub.doc-line),
                     recid(ub.gds-dtl),
                     recid (ub.goods),
                     "delete",
                     ?) no-error.
      if error-status :error then return error.
    end.
  end.
end. /* on stop */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-lookup d-out-doc
PROCEDURE local-lookup :
assign
varline-mode = {&lookup}
varprt-mode  = {&lookup}.
find ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code
                        and ub.doc-line.prod-code = ub.gds-dtl.prod-code
                        and ub.doc-line.prod-type = ub.gds-dtl.prod-type
                        and ub.doc-line.artic         = ub.gds-dtl.artic no-lock.
find ub.goods where ub.goods.prod-code = ub.gds-dtl.prod-code
             and ub.goods.prod-type = ub.gds-dtl.prod-type
             and ub.goods.artic     = ub.gds-dtl.artic no-lock.
run str/out-add.p (
    parparentproc,
    recid(t-doc),
    recid(ub.doc-line),
    recid(ub.gds-dtl),
    recid (ub.goods),
    varline-mode,
    ?)
    no-error.
    if error-status :error then return error return-value .
apply "entry" to br-dtl in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-m-outs-1 d-out-doc
PROCEDURE local-m-outs-1 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

define variable loc-ref-list     as character no-undo .
define variable v-hold           as logical   no-undo .
define variable v-ext-doc-type   as character no-undo .
define variable v-doc-rec        as recid     no-undo .
define variable v-stat           as character no-undo .
define variable v-type           as character no-undo .
define variable v-internal       as logical   no-undo .
define variable v-list-mode      as character no-undo .

assign
  v-list-mode = {&choose}
  v-stat = ?
  v-type = ?
  v-internal = ?
  v-doc-rec = ?
  v-hold = ?
  v-ext-doc-type = ?
  .

run str/all-docs.w
    ( input parparentproc,
      input t-doc.host-code ,
      input t-doc.obj-type ,
      input t-doc.obj-code ,
      input v-list-mode,
      input v-stat     ,
      input v-type     ,
      input     ?      ,
      input v-internal ,
      input "b-sel":u,
      input v-ext-doc-type,
      input v-hold,
      input v-doc-rec,
      output loc-ref-list).

find first t-d-b where recid (t-d-b) = integer (loc-ref-list) no-lock no-error.
if not available t-d-b then do:
  display ? @ t-doc.out-code with frame {&frame-name}.
  apply "entry" to b-add in frame {&frame-name}.
  return error.
end.
display t-d-b.doc-code @ t-doc.out-code with frame {&frame-name}.

run ask-copy in this-procedure no-error .
if error-status :error then return error return-value .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-m-outs-1-ret d-out-doc 
PROCEDURE local-outs-ret-doc :
  /*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define output parameter ret-doc-code   as character no-undo .
  define variable v-at-value     as character no-undo .
  define variable v-at-type      as character no-undo .
  
  run str/choose-docs-for-return.w
    ( input t-doc.reason-code ,
      input edo-return,
      input t-doc.doc-code ,
      output ret-doc-code).

  find first t-d-b where t-d-b.doc-code = ret-doc-code no-lock no-error.
  if not available t-d-b then 
  do:
    ret-doc-code = "" .
    return error.
  end.
  

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-m-outs-1-ret d-out-doc
PROCEDURE local-m-outs-1-ret :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

define variable loc-ref-list     as character no-undo .
define variable v-hold           as logical   no-undo .
define variable v-ext-doc-type   as character no-undo .
define variable v-doc-rec        as recid     no-undo .
define variable v-stat           as character no-undo .
define variable v-type           as character no-undo .
define variable v-internal       as logical   no-undo .
define variable v-list-mode      as character no-undo .

define variable v-at-value     as character no-undo .
define variable v-at-type      as character no-undo .

find first ub.clients no-lock where ub.clients.obj-type = t-doc.cli-type
                                and ub.clients.obj-code = t-doc.cli-code .

assign
  v-list-mode = "client-income":u
  v-stat = {&fact}
  v-type = ?
  v-internal = ?
  v-doc-rec = recid(ub.clients)
  v-hold = ?
  v-ext-doc-type = {&TDEDT_Pri_Vnesh}
.

run str/all-docs.w
    ( input parparentproc,
      input t-doc.host-code ,
      input t-doc.obj-type ,
      input t-doc.obj-code ,
      input v-list-mode,
      input v-stat     ,
      input v-type     ,
      input     ?      ,
      input v-internal ,
      input "b-sel":u,
      input v-ext-doc-type,
      input v-hold,
      input v-doc-rec,
      output loc-ref-list).

find first t-d-b where recid (t-d-b) = integer (loc-ref-list) no-lock no-error.
if not available t-d-b then do:
  display ? @ t-doc.out-code with frame {&frame-name}.
  apply "entry" to b-add in frame {&frame-name}.
  return error.
end.
{ str/tdat-val.i
  t-d-b.doc-code
  {&trdcattr-nsf}
  v-at-value
  v-at-type
}
{ str/tdat-wrt.i
  t-doc.doc-code
  {&trdcattr-nsf}
  v-at-value
  no-error     
}
{ str/tdat-val.i
  t-d-b.doc-code
  {&trdcattr-dsf}
  v-at-value
  v-at-type
}
{ str/tdat-wrt.i
  t-doc.doc-code
  {&trdcattr-dsf}
  v-at-value
  no-error     
}
assign t-doc.out-code = t-d-b.doc-code .
display t-doc.out-code with frame {&frame-name}.

/*empty temp-table tt-gds-for-return .                                     */
/*for each ub.doc-line no-lock where ub.doc-line.doc-code = t-d-b.doc-code,*/
/*first ub.goods no-lock where ub.goods.artic     = ub.doc-line.artic      */
/*                         and ub.goods.prod-type = ub.doc-line.prod-type  */
/*                         and ub.goods.prod-code = ub.doc-line.prod-code :*/
/*  create tt-gds-for-return .                                             */
/*  buffer-copy ub.goods to tt-gds-for-return                              */
/*  assign                                                                 */
/*    tt-gds-for-return.qnty = ub.doc-line.fact-qnty                       */
/*  .                                                                      */
/*end .                                                                    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-m-outs-1 d-out-doc
PROCEDURE local-m-outs-5 :
/*------------------------------------------------------------------------------
  Purpose:  ЗАКАЗЫ
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

define variable loc-ref-list     as character no-undo .
define variable v-hold           as logical   no-undo .
define variable v-ext-doc-type   as character no-undo .
define variable v-doc-rec        as recid     no-undo .
define variable v-stat           as character no-undo .
define variable v-type           as character no-undo .
define variable v-internal       as logical   no-undo .
define variable v-list-mode      as character no-undo .

define variable i as integer   no-undo .

run ref/all-zakz.w
    ( input  parParentProc
    ,input   ?
    ,input   ?
    ,input   "firmord"
    ,input   ""
    ,input   "b-sel,b-mark"
    ,input   ""
    ,output  loc-ref-list ) no-error .

   if loc-ref-list = "" or loc-ref-list = ? then do:
       message "Ни чего не отметили в списке заказов !"
       view-as alert-box information .
        display
            ? @ t-doc.out-code
        with frame {&frame-name}.
        apply "entry" to b-add in frame {&frame-name}.
        return no-apply.
   end.
    if num-entries( loc-ref-list ) = 0  or  loc-ref-list = ""  or error-status :error
    then do:
        display
            ? @ out-code
        with frame {&frame-name}.
        apply "entry" to b-add in frame {&frame-name}.
        return no-apply.
    end.
    else do:
     repeat i = 1 to  num-entries( loc-ref-list ) :
        find first ub.ord-doc no-lock
            where recid( ub.ord-doc ) = integer( entry( i , loc-ref-list ) )  no-error.
        display
            ub.ord-doc.doc-code @ t-doc.out-code
        with frame {&frame-name}.
             run ask-copy-ord  in this-procedure (
              input ub.ord-doc.doc-code,
              input ub.sysconf.cash-pay,
              input v-cntxp-doc-prt   )
              no-error .
              if error-status :error
              then do:
                  message
                          vss-workfile vss-revision vss-description
                      skip(1)
                      skip "Ошибка копирования заказа в документ ."
                      skip return-value
                      skip trim( error-status :get-message( 1 ) )
                  view-as alert-box error.
                  undo, return error return-value .
              end.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-parts d-out-doc
PROCEDURE local-parts :
do
  on error undo, return error return-value
  :
    define variable var_is-petrol as logical no-undo .
    define variable var_is-pieces as logical no-undo .
    { str/is-petrl.i
      ub.gds-dtl.artic
      ub.gds-dtl.prod-type
      ub.gds-dtl.prod-code
      var_is-petrol
      var_is-pieces
    }

    if pardoc-mode <> {&lookup} then do:
      run check-rate.
    end.
    find ub.doc-line where ub.doc-line.doc-code  = t-doc.doc-code
                    and ub.doc-line.prod-code = ub.gds-dtl.prod-code
                    and ub.doc-line.prod-type = ub.gds-dtl.prod-type
                    and ub.doc-line.artic     = ub.gds-dtl.artic .
    find ub.goods where ub.goods.prod-code = ub.gds-dtl.prod-code
                and ub.goods.prod-type = ub.gds-dtl.prod-type
                and ub.goods.artic     = ub.gds-dtl.artic      no-lock.
    if pardoc-mode = {&lookup} or (var_is-petrol = yes and var_is-pieces = no) or t-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem} then do:
      assign
        work-mode = "lookup-parts":U
      .
    end.
    else do:
      run local-check-gds.
      assign
        work-mode = "update-parts":U
      .
    end.
    if (lookup( string(t-doc.reason-code), v-reasons-for-return) > 0
    and t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh})
    or v-is-return
    then do :
      run str/out-add.p
        ( input parparentproc
         ,input recid(t-doc)
         ,input recid(ub.doc-line)
         ,input recid(ub.gds-dtl)
         ,input recid (ub.goods)
         ,input work-mode + {&delim-par} + "return"
         ,input ?
        ).
    end.
    else do :
      run str/out-add.p
        ( input parparentproc
         ,input recid(t-doc)
         ,input recid(ub.doc-line)
         ,input recid(ub.gds-dtl)
         ,input recid (ub.goods)
         ,input work-mode
         ,input ?
        ).
    end.
    if var_is-petrol = true
      and var_is-pieces = false
      and work-mode <> "lookup-parts"
    then do:
      run inv-line_recalc-qty in this-procedure
        ( input ub.gds-dtl.doc-code
          ,input ub.gds-dtl.artic
          ,input ub.gds-dtl.prod-type
          ,input ub.gds-dtl.prod-code
          ,input true
          ,input ub.gds-dtl.doc-qnty
          ,input ub.gds-dtl.fact-qnty
        ) .
    end. /* if v-is-ptrl = "yes" */
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mark-list d-out-doc
PROCEDURE mark-list :
if not available ub.gds-dtl then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
  { gbl/markstrn.i ub.gds-dtl del-list }
  {&browse-name}:refresh() in frame {&frame-name} .
  varlog = br-dtl:select-next-row () in frame {&frame-name}.
  apply "entry" to br-dtl in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-re-price d-out-doc
PROCEDURE proc-b-re-price :
/* Пересчитать цены если есть ТПЛ по суммовым группам */
  do
  on error undo, return error return-value
  :
define buffer bf_gds-dtl for ub.gds-dtl  .

  find first bf_gds-dtl no-lock where bf_gds-dtl.doc-code = t-doc.doc-code and bf_gds-dtl.ov = false  no-error .
  if not available bf_gds-dtl then do:
     message "Цены зафиксированы , пересчет цен невозможен." view-as alert-box information  .
     return .
  end.

/* расчет по  р у б  */

define variable p-update as logical   no-undo .
   run str/re-prsum.p
       (input parparentproc,
        input t-doc.doc-code,
        output p-update
       ) no-error .
        if error-status :error then message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "re-prsum.p"
          view-as alert-box error
        .

        if  p-update then do:
            run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
            if error-status :error then do:
              undo, return error.
            end.
            run ui-on ("line").
        end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-row-display d-out-doc
PROCEDURE proc-row-display :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
/* Покрасим не товар в другой цвет */
define variable v-ok as logical   no-undo .
 { str/grpnabor.i ub.goods.gds-code  v-ok }

 if v-ok then  do:
    assign
      {&sort-clmn_3-br-dtl}:fgcolor in browse {&browse-name} = 2
      {&sort-clmn_4-br-dtl}:fgcolor in browse {&browse-name} = 2
      v-gds-name :fgcolor in browse {&browse-name} = 2
      {&sort-clmn_6-br-dtl}:fgcolor in browse {&browse-name} = 2
      {&sort-clmn_7-br-dtl}:fgcolor in browse {&browse-name} = 2

    .
 end.

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-shift-name d-out-doc
PROCEDURE proc-shift-name :
define buffer bf_shift-obj   for ub.shift-obj.
  define variable varfind-shift as integer initial 0.
  define variable varshift-date like ub.shift-obj.shift-date no-undo.
  define variable varshift-num  like ub.shift-obj.shift-num  no-undo.

  if input frame {&frame-name} t-doc.shift-date <> ? then do:
    for each  bf_shift-obj where bf_shift-obj.obj-type   = t-doc.obj-type                             and
                                 bf_shift-obj.obj-code   = t-doc.obj-code                             and
                                 bf_shift-obj.shift-date = input frame {&frame-name} t-doc.shift-date and
                                 bf_shift-obj.shift-name = input frame {&frame-name} t-doc.shift-name no-lock on error undo, return error return-value :
      assign
        varfind-shift = varfind-shift + 1
        varshift-date = bf_shift-obj.shift-date
        varshift-num  = bf_shift-obj.shift-num.
    end.

    if varfind-shift = 0 or varfind-shift > 1 then do:
      if varfind-shift = 0 then do:
        message "Не найдена смена: " t-doc.obj-type " " t-doc.obj-code
                " Дата " input frame {&frame-name} t-doc.shift-date " Номер смены " input frame {&frame-name} t-doc.shift-name " ."
        view-as alert-box error.
      end.
      else do:
        message "Найдено более одной смены с одним номером в сменном дне. Объект: " t-doc.obj-type " " t-doc.obj-code
                " Дата " input frame {&frame-name} t-doc.shift-date " Номер смены " input frame {&frame-name} t-doc.shift-name " ."
        view-as alert-box error.
      end.
      display t-doc.shift-name with frame {&frame-name}.
      run proc-sht no-error.
      if error-status:error then do: return error. end.
    end.
    else do:
      assign frame {&frame-name}
        t-doc.shift-name.
      assign
        t-doc.shift-date = varshift-date
        t-doc.shift-num  = varshift-num.
      display t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame {&frame-name}.
      if t-doc.fact-date = ? then do: assign t-doc.fact-date = t-doc.shift-date t-doc.fact-time = (24 * 60 * 60). display t-doc.fact-date with frame {&frame-name}. end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-shift-num d-out-doc
PROCEDURE proc-shift-num :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define buffer bf_shift-obj   for ub.shift-obj.
  if input frame {&frame-name} t-doc.shift-date <> ? then do:
    find first bf_shift-obj where bf_shift-obj.obj-type   = t-doc.obj-type                             and
                                  bf_shift-obj.obj-code   = t-doc.obj-code                             and
                                  bf_shift-obj.shift-date = input frame {&frame-name} t-doc.shift-date and
                                  bf_shift-obj.shift-num  = input frame {&frame-name} t-doc.shift-num  no-lock no-error.
    if not available bf_shift-obj then do:
      message "Не найдена смена: " t-doc.obj-type " " t-doc.obj-code
              " Дата " input frame {&frame-name} t-doc.shift-date " Порядок смены " input frame {&frame-name} t-doc.shift-num " ."
      view-as alert-box error.
      display t-doc.shift-num with frame {&frame-name}.
      run proc-sht no-error.
      if error-status:error then do:
        return error.
      end.
    end.
    else do:
      assign
        t-doc.shift-date = bf_shift-obj.shift-date
        t-doc.shift-num  = bf_shift-obj.shift-num
        t-doc.shift-name = bf_shift-obj.shift-name.
      display t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame {&frame-name}.
      if t-doc.fact-date = ? then do:
        assign
          t-doc.fact-date = t-doc.shift-date
          t-doc.fact-time = (24 * 60 * 60).
        display t-doc.fact-date with frame {&frame-name}.
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sht d-out-doc
PROCEDURE proc-sht :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define buffer bf_shift-obj   for ub.shift-obj.
  define variable varrid-list as character no-undo.
  define variable varrecid    as recid     no-undo.
  assign
    varrid-list = "".
  run str/sht-all.w (parparentproc, t-doc.obj-type, t-doc.obj-code, 'b-sel', 'obj',t-doc.obj-type, t-doc.obj-code, '':u, input-output varrid-list) no-error.
  if error-status:error or varrid-list = "":u then do:
    return error.
  end.
  else do:
    assign
      varrecid = integer (entry(1, varrid-list)).
    find first bf_shift-obj where recid(bf_shift-obj) = varrecid no-lock no-error.
    if available bf_shift-obj then do:
      assign
        t-doc.shift-date = bf_shift-obj.shift-date
        t-doc.shift-num  = bf_shift-obj.shift-num
        t-doc.shift-name = bf_shift-obj.shift-name.
      display t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame {&frame-name}.
      if t-doc.fact-date = ? then do:
        assign
          t-doc.fact-date = t-doc.shift-date
          t-doc.fact-time = (24 * 60 * 60).
        display t-doc.fact-date with frame {&frame-name}.
      end.
/*      if t-doc.ext-doc-type = {&TDEDT_Ras_Object} and t-doc.fact-date <> TODAY then do :*/
/*        t-doc.fact-date = TODAY .                                                       */
/*        display t-doc.fact-date with frame {&frame-name}.                               */
/*      end.                                                                              */
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-reason d-out-doc
PROCEDURE select-reason :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable j-rsn-code like ub.trn-reason.reason-code no-undo.

  assign j-rsn-code = ( input frame {&FRAME-NAME} t-doc.reason-code ).
  run str/trn-reas.w ( input ParParentProc, input {&choose}, input-output j-rsn-code ).
  find first ub.trn-reason no-lock where ub.trn-reason.reason-code = j-rsn-code no-error.
  if available ub.trn-reason then do:
    if   t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} 
       and ( 
            (    lookup( string(     t-doc.reason-code), v-reasons-for-return) gt 0
             and lookup( string(ub.trn-reason.reason-code), v-reasons-for-return) eq 0)
       or   (    lookup( string(     t-doc.reason-code), v-reasons-for-return) eq 0
             and lookup( string(ub.trn-reason.reason-code), v-reasons-for-return) gt 0)
           )
    then do:
      if not v-is-return
      then do :
        message "Данное основание используется для возврата поставщику. Выберите другое основание из списка." view-as alert-box .
        return no-apply.
      end .
      assign  
        rsn-name          = ub.trn-reason.reason-name
        t-doc.reason-code = ub.trn-reason.reason-code
      .
      run check-cli in this-procedure no-error.
      if error-status :error then return no-apply.
    end.
    else do:
      assign  
        rsn-name          = ub.trn-reason.reason-name
        t-doc.reason-code = ub.trn-reason.reason-code
      .
    end.
    display t-doc.reason-code rsn-name with frame {&FRAME-NAME}.
  end.
  if lookup( string(t-doc.reason-code), v-reasons-for-return) > 0
  and t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
  then do :
    disable b-cur with frame {&frame-name}.
  end.
  else do:
    enable b-cur with frame {&frame-name}.
  end.

  /* если возврат или корректировка и признак ЭДО, 
  ** то нельзя вводить товар через Баркод */
  if (t-doc.reason-code = 23 or t-doc.reason-code = 25) 
     and edo-return = yes then
     disable b-bc with frame {&frame-name}.      

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-work-mode-prt d-out-doc
PROCEDURE set-work-mode-prt :
prt-rec = recid(ub.gds-dtl).
find ub.doc-line where ub.doc-line.doc-code  = t-doc.doc-code
                and ub.doc-line.prod-code = ub.gds-dtl.prod-code
                and ub.doc-line.prod-type = ub.gds-dtl.prod-type
                and ub.doc-line.artic     = ub.gds-dtl.artic no-lock.
line-rec = recid (ub.doc-line).
find ub.goods where ub.goods.prod-code = ub.gds-dtl.prod-code
             and ub.goods.prod-type = ub.gds-dtl.prod-type
             and ub.goods.artic     = ub.gds-dtl.artic no-lock.
gds-rec = recid  (ub.goods).
find ub.gds-prt where ub.gds-prt.upper-code = ub.goods.prt-root no-lock.
if ub.gds-prt.node-name = {&empty-scale} then do:
  message "Товар :" ub.goods.artic ub.goods.gds-name "не делится на признаки - шкала недoступна.".
  return error.
end.
if pardoc-mode = {&lookup} then do:
  assign
    varprt-mode  = {&lookup}
    varline-mode = {&lookup}
    work-mode    = "lookup-scale".
end.
else do:
  define variable l-inv-on as logical no-undo .

  { gbl/gdsobjat.i
     ub.doc-line.obj-type
     ub.doc-line.obj-code
     ub.doc-line.artic
     ub.doc-line.prod-type
     ub.doc-line.prod-code
     "'inv-on=request'"
     l-inv-on
     no-error }
  if error-status :error then do:
    message
      "Ошибка получения признака товара на объекте" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return no-apply .
  end.

  if l-inv-on then do:
    message "Артикул :" ub.doc-line.artic ub.goods.gds-name
                    "- товар в инвентаризации."
                    skip (2) "Операция невозможна.".
    return error.
  end.
  assign
    varprt-mode  = {&prt-def}
    varline-mode = {&update}
    work-mode = "update-scale".
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-on d-out-doc
PROCEDURE ui-on :
define input parameter fnc as character no-undo.
/* ----------------------------------------------------------- *\
 *                                                             *
 *  purpose:     включение интерфейса в нужном режиме          *
 *                                                             *
\* ----------------------------------------------------------- */

define variable varexist                  as logical   no-undo.
define variable varpurch-limit            as character no-undo.
define variable varpurch-limit-type       as character no-undo.
define variable varpurch-code-string      as character no-undo.
define variable varpurch-code-string-type as character no-undo.

define buffer bf_doc-line for ub.doc-line.
define buffer bf_contract for ub.contract.
assign
  del-list = "":U
  loc-art  = "":U
.

if fnc = "enable" then do:
  disable all with frame {&frame-name}.
  hide loc-art in frame {&frame-name} loc-name loc-code in frame {&frame-name}.
  enable b-exit b-lkp b-help br-dtl b-arch b-history a-n-c b-notes b-cnt b-attr with frame {&frame-name}.

  if  t-doc.status_      = {&wayb}
  and t-doc.flag_        = false
  and t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
  then do:
    enable b-rsrv-doc-list with frame {&frame-name} .
  end.
  if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
  then do:
    find first ub.global-state no-lock no-error .
    if pardoc-mode <> {&lookup} and available ub.global-state and  ub.global-state.pl-use-sum-group then do:
        enable b-re-price with frame {&frame-name} .
      end.
  end.
  else do:
    hide b-re-price in frame {&frame-name} .
  end.



  if t-doc.status_ = {&ready} or
     t-doc.status_ = {&rejected}
  then do:
     enable b-dopinf b-notes-line  with frame {&frame-name}.
  end.
  else do:
   if  v-is-flora-ord then  do:
            enable   b-dopinf  b-notes-line  with frame {&frame-name}.
       end.
       else hide  b-dopinf  b-notes-line  in frame {&frame-name}.

  end.

  enable b-parts b-marks with frame {&frame-name}.
  if prtvalue = "yes" and v-cntxp-doc-prt then enable b-prt with frame {&frame-name}.
  if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} then enable b-parts b-marks with frame {&frame-name}.
  if pardoc-mode = {&add-def} then do:
    run create-record in this-procedure (  input t-doc.doc-code
                                        ,  input {&trdcattr-purchlimit}
                                        ,  input "no":U
                                        , output varexist ) .
    if varexist = no then do:
      { str/tdat-wrt.i
          t-doc.doc-code
          {&trdcattr-purchcodelist}
          {&purchase-codes}
      }
    end.
  end.
  { str/tdat-val.i
      t-doc.doc-code
      {&trdcattr-purchlimit}
      varpurch-limit
      varpurch-limit-type
  }
  if varpurch-limit = "no":u then do:
    assign
      varpurch-chs = 0.
    assign
      is-repay   = yes
      is-cons    = yes
      is-storage = yes
      is-oldcons = yes.
  end.
  else do:
    assign
      varpurch-chs = 1.
    { str/tdat-val.i
        t-doc.doc-code
        {&trdcattr-purchcodelist}
        varpurch-code-string
        varpurch-code-string-type
    }
    if lookup ({&repayment-code}, varpurch-code-string) > 0 then do:
      assign
        is-repay = yes.
    end.
    if lookup ({&consignation-code}, varpurch-code-string) > 0 then do:
      assign
        is-cons = yes.
    end.
    if lookup ({&responsible-storage-code}, varpurch-code-string) > 0 then do:
      assign
        is-storage = yes.
    end.
    if lookup ({&old-consignation-code}, varpurch-code-string) > 0 then do:
      assign
        is-oldcons = yes.
    end.
  end.

  case t-doc.status_ :
       when {&wayb} then do:
           if t-doc.flag_ then assign ub.gds-dtl.doc-qnty:read-only  in browse {&browse-name} = yes.
           assign ub.gds-dtl.fact-qnty:read-only  in browse {&browse-name} = yes.
       end.
       when {&permitted} then assign ub.gds-dtl.doc-qnty:read-only  in browse {&browse-name} = yes.
       otherwise   assign ub.gds-dtl.doc-qnty:read-only  in browse {&browse-name} = yes
                          ub.gds-dtl.fact-qnty:read-only in browse {&browse-name} = yes.
  end case.

  case pardoc-mode :
    when {&lookup}  then do:
         assign ub.gds-dtl.doc-qnty:read-only  in browse {&browse-name} = yes
                ub.gds-dtl.fact-qnty:read-only in browse {&browse-name} = yes.
         if parext-doc-mode = "":U then do:
            if br-handle = ? then hide b-prev b-next in frame {&frame-name} .
                             else enable b-prev b-next with frame {&frame-name}.
         end.
         if parext-doc-mode = "reason-code" then do:
            enable r-reas t-doc.reason-code with frame {&frame-name}.
          end.
    end.
    when {&add-def} then do: enable t-doc.cli-code t-doc.cli-type r-clients with frame {&frame-name}. end.
    when {&update}  then do:
      if t-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem} then do:
         assign ub.gds-dtl.doc-qnty:read-only  in browse {&browse-name} = yes
                ub.gds-dtl.fact-qnty:read-only in browse {&browse-name} = yes.
      end.

      if lookup(t-doc.doc-type, {&expense_write-off}) > 0
      then do:
        varlog = no.
        case t-doc.doc-type
        :
          when {&expense}
          then do:
              { gbl/chk-actg.i
                v-cntxt-db-num
                v-cntxt-userid
                {&action-head-code-main}
                'actn_expense_price':U
                {&cntxt-object}
                t-doc.host-code
                t-doc.obj-type
                t-doc.obj-code
                0
                0
                0
                false
                varlog
              }
          end.
          when {&write-off}
          then do:
              { gbl/chk-actg.i
                v-cntxt-db-num
                v-cntxt-userid
                {&action-head-code-main}
                'actn_write-off_price':U
                {&cntxt-object}
                t-doc.host-code
                t-doc.obj-type
                t-doc.obj-code
                0
                0
                0
                false
                varlog
              }

          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Неизвестный тип документа" t-doc.doc-type skip
              "Документ" t-doc.doc-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end case .

        if t-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_VP}    and
         t-doc.status_  = {&wayb}                         and
         not t-doc.flag_                                  and
         varlog = yes                                     and
         (lookup( string(t-doc.reason-code), v-reasons-for-return) = 0
         and t-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh})
         then do:
           enable b-cur with frame {&frame-name}.
         end.
      end.

      if pardoc-mode <> {&lookup} then do:
        enable r-reas t-doc.reason-code with frame {&frame-name}.
      end.
      varlog = yes.
      if prev-pardoc-mode = pardoc-mode
      then do :
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_expense_doc-date':U
            {&cntxt-object}
            t-doc.host-code
            t-doc.obj-type
            t-doc.obj-code
            0
            0
            0
            false
            varlog
          }
      end.
      if varlog
      then do :
        enable t-doc.doc-date with frame {&frame-name}.
      end.
      else do:
        assign
          t-doc.doc-date :tooltip in frame {&FRAME-NAME} =  " Для пользователя недоступно право 'actn-expense-doc-date' ."
        .
      end.
      enable b-chg t-doc.wrkr
             t-doc.agnt t-doc.boss r-wrkr r-agnt r-boss
             t-doc.pay-code r-pay
             r-outs b-fixprice with frame {&frame-name}.

      if not (t-doc.status_ =  {&wayb}  or t-doc.status_ =  {&inquiry} )
      then
         disable t-doc.pay-code r-pay with frame {&frame-name} .

      varlog = no.

      case t-doc.doc-type
      :
        when {&income}
        then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_income_add-back-date':U
              {&cntxt-object}
              t-doc.host-code
              t-doc.obj-type
              t-doc.obj-code
              0
              0
              0
              false
              varlog
            }
        end.
        when {&expense}
        then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_expense_add-back-date':U
              {&cntxt-object}
              t-doc.host-code
              t-doc.obj-type
              t-doc.obj-code
              0
              0
              0
              false
              varlog
            }
        end.
        when {&return}
        then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_return_add-back-date':U
              {&cntxt-object}
              t-doc.host-code
              t-doc.obj-type
              t-doc.obj-code
              0
              0
              0
              false
              varlog
            }

        end.
        when {&write-off}
        then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_write-off_add-back-date':U
              {&cntxt-object}
              t-doc.host-code
              t-doc.obj-type
              t-doc.obj-code
              0
              0
              0
              false
              varlog
            }

        end.
        when {&inventory}
        then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_inventory_add-back-date':U
              {&cntxt-object}
              t-doc.host-code
              t-doc.obj-type
              t-doc.obj-code
              0
              0
              0
              false
              varlog
            }
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный тип документа" t-doc.doc-type skip
            "Документ" t-doc.doc-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .
      if t-doc.ext-doc-type = {&TDEDT_Pri_Perem}
      then do:
        def var conf-par as character no-undo.
        def var par-type as character no-undo.
        { gbl/conf-rd.i
          "'is-erpRN'"
          0
          "''"
          0
          "''"
          "''"
          "''"
          NO
          conf-par
          par-type
          no-error
          }
        if not error-status:error and conf-par = "yes":U 
        then do:
          enable t-doc.shift-date t-doc.shift-num t-doc.shift-name r-sht with frame {&frame-name}.
        end.
      end.
      if (t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}           or
          t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}        or
          t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}       or
          t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}  or
          t-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} )  and varlog then do:
          enable t-doc.fact-date with frame {&frame-name}.
         { gbl/objat.i
           t-doc.obj-type
           t-doc.obj-code
           "'shift-on=request'"
           varlog
           no-error
          }
         if error-status :error then do:
           message
           vss-workfile vss-revision vss-description skip
           "Ошибка при запуске процедуры objat" skip
           error-status :get-message(1) skip
           return-value skip
           view-as alert-box error .
           return error.
         end.
         if varlog then do:
          enable t-doc.shift-date t-doc.shift-num t-doc.shift-name r-sht with frame {&frame-name}.
         end.
      end.
/*      if bcvalue <> "no" and                                                                               */
/*         /*накл- запр- разр+ для всех внешних и внутреннего расхода*/                                      */
/*         ((not t-doc.flag_ and t-doc.status_ = {&inquiry}  or                                              */
/*           not t-doc.flag_ and t-doc.status_ = {&wayb}     or                                              */
/*               t-doc.flag_ and t-doc.status_ = {&permitted}   ) and                                        */
/*          (not t-doc.internal or t-doc.doc-type = {&expense} and t-doc.internal)) or                       */
/*         /*накл+ внутреннего прихода*/                                                                     */
/*         (t-doc.doc-type = {&income} and t-doc.internal and t-doc.status_ = {&wayb} and t-doc.flag_) or    */
/*         /*запр- внутреннего прихода*/                                                                     */
/*         (t-doc.doc-type = {&income} and t-doc.internal and t-doc.status_ = {&inquiry} and not t-doc.flag_)*/
/*         then do:                                                                                          */
/*         enable b-bc with frame {&frame-name}.                                                             */
/*      end.                                                                                                 */
      if not t-doc.internal then enable t-doc.print-rubl with frame {&frame-name}.
      if t-doc.status_ = {&wayb} and
         t-doc.flag_   = no      then do:
        find first bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code no-lock no-error.
        if varpurch-limit = "no":u then do:
          if not available bf_doc-line then do:
            enable varpurch-chs with frame {&frame-name}.
          end.
        end.
        else do:
          if not available bf_doc-line then do:
            enable varpurch-chs is-repay is-cons is-storage is-oldcons with frame {&frame-name}.
          end.
        end.
      end.
      if not t-doc.flag_ and t-doc.status_ <> {&permitted} then do:
        enable t-doc.out-code with frame {&frame-name}.
        if not t-doc.internal or t-doc.doc-type = {&expense} or t-doc.status_ = {&inquiry} then do:
                    t-doc.is-flora = v-is-flora-ord .
             enable b-add b-del b-mark with frame {&frame-name}.
           end.
        if can-do ({&expense_write-off_return}, t-doc.doc-type) and
           not t-doc.internal then do:
           enable t-doc.discnt-type with frame {&frame-name}.
           if t-doc.discnt-type = {&percent} then
              enable t-doc.discnt-pc with frame {&frame-name}.
           if t-doc.discnt-type = {&amount} then do:
             if varr-b = "base":u then do:
               enable  t-doc.tot-calc with frame {&frame-name}.
             end.
             else do:
               enable t-doc.discnt-rubl with frame {&frame-name}.
             end.
           end.
        end.
        if can-do ({&expense_write-off}, t-doc.doc-type) then do:
          enable t-doc.cli-code r-clients with frame {&frame-name}.
          if v-cntxp-out-rate then do:
             enable t-doc.base-rate t-doc.base-scale r-acc with frame {&frame-name}.
          end.
        end.

        if t-doc.doc-type = {&return} and v-cntxp-out-rate then
          enable t-doc.base-rate t-doc.base-scale r-acc with frame {&frame-name}.

        if t-doc.status_ = {&inquiry} and
           t-doc.doc-type = {&income} and
           t-doc.internal then
          enable t-doc.cli-code r-clients with frame {&frame-name}.
      end.
    end.
  end case. /* pardoc-mode */
  if t-doc.internal = yes then do:
    hide t-doc.tot-calc    in frame {&frame-name}
         t-doc.discnt-rubl in frame {&frame-name}
         t-doc.discnt-type in frame {&frame-name}
         t-doc.discnt-pc   in frame {&frame-name}
         t-doc.vat-rubl    in frame {&frame-name}
         t-doc.vat-base    in frame {&frame-name}
         fact-base         in frame {&frame-name}
         fact-rubl         in frame {&frame-name}.

    if  t-doc.status_      = {&wayb}
    and t-doc.flag_        = true
    and t-doc.ext-doc-type = {&TDEDT_Pri_Perem}
    then do:
      enable b-revis with frame {&frame-name} .
    end.
  end.
  if not can-do ({&fact_permitted}, t-doc.status_) and
     not (t-doc.status_ = {&wayb} and t-doc.flag_ and t-doc.doc-type = {&income}) then do:
    hide t-doc.fact-qnty t-doc.tot-cli pay-rubl in frame {&frame-name}.
    menu-item m-outs-4:sensitive in menu m-outs = no.
  end.
end.

if t-doc.internal then do:
  if can-do ({&fact_permitted}, t-doc.status_) or
     (t-doc.status_ = {&wayb} and t-doc.flag_ and t-doc.doc-type = {&income}) then
    display t-doc.tot-fact @ sum-base
            t-doc.tot-sale @ sum-rubl
            t-doc.fact-qnty  t-doc.fact-date t-doc.shift-date t-doc.shift-num t-doc.shift-name t-doc.tot-cli
            t-doc.tot-rubl @ pay-rubl with frame {&frame-name}.
  else
    display t-doc.tot-doc  @ sum-base
            t-doc.tot-rubl @ sum-rubl with frame {&frame-name}.
end.
else do:
  if can-do ({&fact_permitted}, t-doc.status_) then do:
    for each ub.gds-dtl where ub.gds-dtl.doc-code = t-doc.doc-code no-lock:
      accumulate (ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl) * ub.gds-dtl.doc-qnty (total).
    end.
    display t-doc.tot-fact - t-doc.tot-calc @ fact-base
            t-doc.tot-sale - t-doc.discnt-rubl @ fact-rubl
            t-doc.tot-fact @ sum-base
            t-doc.tot-sale @ sum-rubl
            t-doc.fact-qnty t-doc.fact-date t-doc.shift-date t-doc.shift-num t-doc.shift-name t-doc.tot-cli
            (accum total (ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl) * ub.gds-dtl.doc-qnty) @ pay-rubl with frame {&frame-name}.
  end.
  else do:
    display t-doc.tot-doc - t-doc.tot-calc @ fact-base
            t-doc.tot-rubl - t-doc.discnt-rubl @ fact-rubl
            t-doc.tot-doc @ sum-base
            t-doc.tot-rubl @ sum-rubl with frame {&frame-name}.
  end.
  if t-doc.discnt-type <> {&cash-desk} then do: display t-doc.discnt-type with frame {&frame-name}. end.
  display t-doc.discnt-pc t-doc.d-card t-doc.discnt-rubl t-doc.tot-calc t-doc.vat-base t-doc.vat-rubl with frame {&frame-name}.
  if not t-doc.internal             and
     t-doc.doc-type = {&return} then do:
     display t-doc.fact-date t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame {&frame-name}.
  end.
end.
if t-doc.out-code <> ? or t-doc.out-code:sensitive then
  display t-doc.out-code with frame {&frame-name}.
else hide t-doc.out-code in frame {&frame-name}.

find ub.trn-reason no-lock where
     ub.trn-reason.reason-code = t-doc.reason-code no-error.
assign
  rsn-name = ( if available ub.trn-reason then ub.trn-reason.reason-name else "":U )
.

display t-doc.cli-code t-doc.cli-type t-doc.doc-date t-doc.fact-date t-doc.shift-date t-doc.shift-num t-doc.shift-name t-doc.doc-qnty
        t-doc.base-rate t-doc.base-scale t-doc.pay-code varpurch-chs is-repay is-cons is-storage is-oldcons
        t-doc.reason-code rsn-name
with frame {&frame-name}.

if paris-hold = yes then do:
  display t-doc.hold-obj-type t-doc.hold-obj-code with frame {&frame-name}.
end.
display t-doc.print-rubl with frame {&frame-name}.
find ub.clients where ub.clients.obj-type = t-doc.cli-type and ub.clients.obj-code = t-doc.cli-code no-lock no-error.
if available ub.clients then
  display ub.clients.obj-name with frame {&frame-name}.
if parlist-mode = {&acc-office-all} or parlist-mode = {&acc-office-without} then do:
  find ub.clients where ub.clients.obj-type = t-doc.obj-type and ub.clients.obj-code = t-doc.obj-code no-lock.
  frame {&frame-name}:title = "(" + substring (ub.clients.obj-name, 1, 35) + ") : ".
end.
else frame {&frame-name}:title = t-doc.obj-type + " " + string (t-doc.obj-code, ">>>>9") + "  : ".

frame {&frame-name}:title = frame {&frame-name}:title + caps (func-get-name-from-ext-type ( t-doc.ext-doc-type, false  )) .

if t-doc.office then frame {&frame-name}:title = frame {&frame-name}:title + "УСЛУГ ".
frame {&frame-name}:title = frame {&frame-name}:title + " - " .

frame {&frame-name}:title = frame {&frame-name}:title
  + t-doc.status_ + " " + string (t-doc.flag_, "+/-") + " № " + t-doc.doc-code + "   - " .

  assign frame {&frame-name} :title = frame {&frame-name} :title +
    ( if parext-doc-mode = ""            then title-mode( pardoc-mode ) else ( caps( '{&bef-fact-edit}':U ) +
    ( if parext-doc-mode = "reason-code" then " кода основания"         else "":U ) ) ).

{ gbl/hold-doc.i t-doc.doc-code is-doc-hold no-error }

if paris-hold = yes then do:
find first bf_contract where bf_contract.contract-code = t-doc.contract-code no-lock no-error.
end.  
else do:
find first bf_contract where bf_contract.host-code     = ( if is-doc-hold then t-doc.cli-code  else t-doc.host-code )  and
                             bf_contract.contract-code = t-doc.contract-code no-lock no-error.
end.                             
if available bf_contract then do:
  assign
    varcontract-prn-code = bf_contract.contract-prn-code.
end.
else do:
  assign
    varcontract-prn-code = "БЕЗ ДОГОВОРА".
end.

display varcontract-prn-code with frame {&frame-name}.
/* подвинем батончик */

enable b-contr-lkp with frame {&frame-name} .
b-contr-lkp:column =  varcontract-prn-code:column + length(trim(varcontract-prn-code)) + 1 .

  if t-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} or
    t-doc.internal = true
  then do:
    hide varcontract-prn-code b-contr-lkp in frame {&frame-name} .
  end.
   
  if v-is-return
  then do :
    assign gds-dtl.doc-qnty:read-only  in browse {&browse-name} = yes.
    assign gds-dtl.fact-qnty:read-only  in browse {&browse-name} = yes.
    disable r-reas r-clients t-doc.cli-code b-cur r-outs with frame {&frame-name}.
    if available bf_contract
    then do :
      find first buf_contract-attr no-lock where buf_contract-attr.host-code = bf_contract.host-code
                                             and buf_contract-attr.contract-code = bf_contract.contract-code
                                             and buf_contract-attr.attr-code = "contract-edi"
                                             no-error .
      if available buf_contract-attr
      and logical(buf_contract-attr.attr-value) = true
      then do :
        is-contract-edo = yes .
      end .
      else do :
        find first buf_contract-attr no-lock where buf_contract-attr.host-code = bf_contract.host-code
                                               and buf_contract-attr.contract-code = bf_contract.contract-code
                                               and buf_contract-attr.attr-code = "contract-diadoc"
                                               no-error .
        if available buf_contract-attr
        and logical(buf_contract-attr.attr-value) = true
        then do :
          is-contract-edo = yes .
        end .
      end .  
      
      if is-contract-edo
      and EDOParSec:IsEdo
      then do :
        { str/tdat-val.i
          t-doc.doc-code
          {&trdcattr-edo-return}
          varvalue
          vartype
          no-error
        }
        if varvalue = "yes"
        then do:
          edo-return = yes .
          disable b-bc with frame {&frame-name}.
        end.
        else do :
          edo-return = no .
        end .
        display edo-return with frame {&frame-name}.
        if pardoc-mode <> {&lookup}
        then do :
          enable edo-return with frame {&frame-name}.
        end .
      end .
      else do :
        edo-return = no .
        display edo-return with frame {&frame-name}.
        disable edo-return with frame {&frame-name}.
      end .
    end .
    if not can-find(first doc-line no-lock where doc-line.doc-code = t-doc.doc-code)
    then do :
      t-doc.out-code = ? .
      display ? @ t-doc.out-code with frame {&frame-name}.
    end .
  end .
/*Расход внутриобъектный*/
if t-doc.ext-doc-type = {&TDEDT_Ras_Object} then do :
    if pardoc-mode <> {&lookup} then
    assign 
        t-doc.cli-type = t-doc.obj-type
        t-doc.cli-code = t-doc.obj-code
    .
    find clients where clients.obj-type = t-doc.cli-type and clients.obj-code = t-doc.cli-code no-lock .
    display clients.obj-name t-doc.cli-type t-doc.cli-code with frame {&frame-name}.
    disable t-doc.cli-type t-doc.cli-code r-clients b-fixprice b-cnt with frame {&frame-name}.
    enable
        t-doc.reason-code t-doc.doc-date                  
        t-doc.pay-code 
    with frame {&frame-name}.
    if pardoc-mode <> {&lookup} then
    enable
        b-add b-del b-mark b-chg
        t-doc.fact-date t-doc.out-code
        t-doc.wrkr t-doc.agnt t-doc.boss r-wrkr r-agnt r-boss
        r-outs r-pay r-reas
    with frame {&frame-name}.
    { gbl/objat.i
       t-doc.obj-type
       t-doc.obj-code
       "'shift-on=request'"
       varlog
       no-error
      }
    if error-status :error then do:
       message
       vss-workfile vss-revision vss-description skip
       "Ошибка при запуске процедуры objat" skip
       error-status :get-message(1) skip
       return-value skip
       view-as alert-box error .
       return error.
    end.
    if varlog and pardoc-mode <> {&lookup} then do:
      enable t-doc.shift-date t-doc.shift-num t-doc.shift-name r-sht with frame {&frame-name}.
    end.
    if t-doc.status_ = {&wayb} and t-doc.flag_ and pardoc-mode = {&update} then do :
      disable b-add b-del b-mark r-acc r-pay r-outs with frame {&frame-name}.
      hide t-doc.out-code in frame {&frame-name}.
    end.
end.
display t-doc.wrkr t-doc.agnt t-doc.boss with frame {&frame-name}.
{ str/psn-chk.i wrkr on t-doc ref-rec }
{ str/psn-chk.i agnt on t-doc ref-rec }
{ str/psn-chk.i boss on t-doc ref-rec }
if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} then do:
  disable t-doc.pay-code r-pay with frame {&frame-name}.
  if t-doc.discnt-pc = 0 then hide t-doc.discnt-type t-doc.discnt-pc t-doc.tot-calc t-doc.discnt-rubl in frame {&frame-name}.
end.
find ub.pay-type where ub.pay-type.obj-code = input frame {&frame-name} t-doc.pay-code no-lock no-error.
if available ub.pay-type then do: display     ub.pay-type.obj-name with frame {&frame-name}. end.
                      else do: display ? @ ub.pay-type.obj-name with frame {&frame-name}. end.
release ub.pay-type no-error.
{&open-query-br-dtl} by {&sort-clmn_2-br-dtl} .
IF mImagePh THEN
DO:
    DEFINE VARIABLE vImageList AS LONGCHAR    NO-UNDO.
    DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
if AVAILABLE goods then do:
    RUN gds-attr-value ( goods.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
    RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, goods.gds-code, OUTPUT vImageList).
    vCh = ENTRY (1, vImageList, {&ImageDelimiter}).
    g-image:LOAD-IMAGE (ENTRY (1, vCh)) NO-ERROR.
    ASSIGN
        g-image:HIDDEN     = NO
        g-image:VISIBLE    = YES
        g-image:SENSITIVE  = YES
        .
end.
else
      ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .   
END.
ELSE
    ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .
apply "value-changed" to br-dtl in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE val-chg-is-cons d-out-doc
PROCEDURE val-chg-is-cons :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable varstring as character no-undo.
do on error undo, return error return-value :
  if is-cons <> input frame {&frame-name} is-cons then do:
    if is-repay = no and
       input frame {&frame-name} is-cons = no and
       is-storage = no and
       is-oldcons = no then do:
       message "Не выбран ни один тип приобретения." view-as alert-box.
       display is-cons with frame {&frame-name}.
    end.
    assign
      frame {&frame-name} is-cons.

    assign
      varstring = "":u
    .
    if is-repay = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&repayment-code}.
    end.
    if is-cons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&consignation-code}.
    end.
    if is-storage = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&responsible-storage-code}.
    end.
    if is-oldcons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&old-consignation-code}.
    end.

    { str/tdat-wrt.i
        t-doc.doc-code
        {&trdcattr-purchcodelist}
        varstring
    }
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE val-chg-is-oldcons d-out-doc
PROCEDURE val-chg-is-oldcons :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable varstring as character no-undo.
do on error undo, return error return-value :
  if is-oldcons <> input frame {&frame-name} is-oldcons then do:
    if is-repay = no and
       is-cons = no and
       is-storage = no and
       input frame {&frame-name} is-oldcons = no then do:
       message "Не выбран ни один тип приобретения." view-as alert-box.
       display is-oldcons with frame {&frame-name}.
    end.
    assign
      frame {&frame-name} is-oldcons.

    assign
      varstring = "":u
    .
    if is-repay = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&repayment-code}.
    end.
    if is-cons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&consignation-code}.
    end.
    if is-storage = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&responsible-storage-code}.
    end.
    if is-oldcons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&old-consignation-code}.
    end.

    { str/tdat-wrt.i
        t-doc.doc-code
        {&trdcattr-purchcodelist}
        varstring
    }
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE val-chg-is-repay d-out-doc
PROCEDURE val-chg-is-repay :
define variable varstring as character no-undo.
do on error undo, return error return-value :
  if is-repay <> input frame {&frame-name} is-repay then do:
    if input frame {&frame-name} is-repay = no and
       is-cons    = no and
       is-storage = no and
       is-oldcons = no then do:
       message "Не выбран ни один тип приобретения." view-as alert-box.
       display is-repay with frame {&frame-name}.
    end.
    assign
      frame {&frame-name} is-repay.

    assign
      varstring = "":u
    .
    if is-repay = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&repayment-code}.
    end.
    if is-cons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&consignation-code}.
    end.
    if is-storage = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&responsible-storage-code}.
    end.
    if is-oldcons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&old-consignation-code}.
    end.

    { str/tdat-wrt.i
        t-doc.doc-code
        {&trdcattr-purchcodelist}
        varstring
    }
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE val-chg-is-storage d-out-doc
PROCEDURE val-chg-is-storage :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable varstring as character no-undo.
do on error undo, return error return-value :
  if is-storage <> input frame {&frame-name} is-storage then do:
    if is-repay = no and
       is-cons = no and
       input frame {&frame-name} is-storage = no and
       is-oldcons = no then do:
       message "Не выбран ни один тип приобретения." view-as alert-box.
       display is-storage with frame {&frame-name}.
    end.
    assign
      frame {&frame-name} is-storage.

    assign
      varstring = "":u
    .
    if is-repay = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&repayment-code}.
    end.
    if is-cons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&consignation-code}.
    end.
    if is-storage = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&responsible-storage-code}.
    end.
    if is-oldcons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&old-consignation-code}.
    end.

    { str/tdat-wrt.i
        t-doc.doc-code
        {&trdcattr-purchcodelist}
        varstring
    }
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ask-copy-ord d-out-doc
PROCEDURE ask-copy-ord :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-ord-code  as character no-undo .
  define input parameter parcash-pay like ub.sysconf.cash-pay no-undo.
  define input parameter pardoc-prt  as   logical             no-undo.

  define variable chg-qnty    like gds-dtl.doc-qnty    no-undo.
  define variable legal-node  like ub.gds-prt.node-code   no-undo.
  define variable varcount    as   integer             no-undo.
  define variable varchg-qnty like ub.gds-dtl.doc-qnty no-undo.
  define variable vardoc-qnty like ub.gds-dtl.doc-qnty no-undo.
  define variable v-is-petrol as   logical             no-undo.
  define variable v-is-pieces as   logical             no-undo.
  define variable var-kg-qnty like ub.gds-dtl.doc-qnty no-undo.
  define variable rr-inv-line as   recid               no-undo.

  define buffer cpl_goods    for ub.goods   .
  define buffer cpl_gds-obj  for ub.gds-obj .
  define buffer cpl_prt-obj  for ub.prt-obj .
  define buffer cpl_gds-prt  for ub.gds-prt .
  define buffer cpl_gds-dtl  for ub.gds-dtl .
  define buffer cpl_doc-line for ub.doc-line.
  define buffer cpl_inv-line for ub.inv-line.

  define buffer buf_ord-doc  for ub.ord-doc .
  define buffer buf_ord-line for ub.ord-line.

c-l:
do on error undo c-l, return error :
find first buf_ord-doc where buf_ord-doc.doc-code = p-ord-code.
r-l:
for each buf_ord-line where buf_ord-line.doc-code  = p-ord-code ,
     each cpl_goods where cpl_goods.prod-type = buf_ord-line.prod-type
                      and cpl_goods.prod-code = buf_ord-line.prod-code
                      and cpl_goods.artic     = buf_ord-line.artic     no-lock :
  assign varcount = varcount + 1.
  if varcount modulo 100 = 0 then do:
    run waitfram-show in this-procedure (input "ЖДИТЕ.  Обработано строк списка : " + string (varcount)).
  end.
  { str/crdoclno.i
   t-doc.doc-code
   t-doc.obj-type
   t-doc.obj-code
   cpl_goods.artic
   cpl_goods.prod-type
   cpl_goods.prod-code
   cpl_goods.gds-name
   cpl_goods.prt-root
   ?
   ?
   parcash-pay
   no-error }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании строки." skip
      return-value skip
      trim(error-status :get-message(1))
      trim(error-status :get-message(2))
      trim(error-status :get-message(3))
      trim(error-status :get-message(4))
      trim(error-status :get-message(5)) skip
      view-as alert-box error.
    undo c-l, return error return-value.
  end.
  if return-value = "next" then do:
    next r-l.
  end.
  find first cpl_doc-line where cpl_doc-line.doc-code  = t-doc.doc-code and
                                cpl_doc-line.artic     = cpl_goods.artic      and
                                cpl_doc-line.prod-type = cpl_goods.prod-type  and
                                cpl_doc-line.prod-code = cpl_goods.prod-code .
  find first cpl_gds-prt where cpl_gds-prt.upper-code = cpl_goods.prt-root no-lock.
  find first  cpl_prt-obj where cpl_prt-obj.obj-type  = t-doc.obj-type
                         and cpl_prt-obj.obj-code  = t-doc.obj-code
                         and cpl_prt-obj.artic     = cpl_goods.artic
                         and cpl_prt-obj.prod-type = cpl_goods.prod-type
                         and cpl_prt-obj.prod-code = cpl_goods.prod-code no-error .
   if error-status :error then do:
      /* создать */
   end.

  assign legal-node = if available cpl_prt-obj then cpl_prt-obj.prt-code else cpl_gds-prt.node-code .

      { str/crgdsdtl.i
        t-doc.obj-code
        t-doc.obj-type
        t-doc.doc-code
        cpl_goods.artic
        cpl_goods.prod-code
        cpl_goods.prod-type
        legal-node
        yes
        no-error }

      find first cpl_gds-dtl where cpl_gds-dtl.doc-code  = t-doc.doc-code and
                                   cpl_gds-dtl.artic     = cpl_goods.artic      and
                                   cpl_gds-dtl.prod-code = cpl_goods.prod-code  and
                                   cpl_gds-dtl.prod-type = cpl_goods.prod-type  and
                                   cpl_gds-dtl.prt-code  = legal-node.
      assign
        cpl_gds-dtl.ov  = no.
      /* подстановка цены, по цене магазина */
      /* если ошибка при установке цены переходим к следующему товару                 */
       { str/set-pr.i recid(cpl_gds-dtl) no ? no-error }
      if error-status :error then do:
         message
           vss-workfile vss-revision vss-description skip
           error-status :get-message(1) skip
           return-value skip
           ""
           view-as alert-box error
         .
         /* undo, next r-l. */
      end.
      assign
        chg-qnty = buf_ord-line.qnty
        .
      run trg/rsrv-dtl.p (input parparentproc, {&rsrv-dtl_action_reserv}, buffer cpl_gds-dtl, input-output chg-qnty, input-output cpl_doc-line.price-base, input-output cpl_doc-line.price-rubl, -1) no-error.
      if error-status :error then undo c-l, return error.
      assign
        cpl_doc-line.doc-qnty  = cpl_doc-line.doc-qnty + chg-qnty
        cpl_gds-dtl.doc-qnty   = cpl_gds-dtl.doc-qnty  + chg-qnty
        cpl_gds-dtl.fact-qnty  = cpl_gds-dtl.doc-qnty
        cpl_doc-line.fact-qnty = cpl_doc-line.doc-qnty.
      /* считаем суммарное количество, которое удалось скопировать */
      assign
        varchg-qnty = varchg-qnty + chg-qnty
        vardoc-qnty = vardoc-qnty + cpl_gds-dtl.doc-qnty.
      if cpl_gds-dtl.doc-qnty = 0 then delete cpl_gds-dtl.

  { str/is-petrl.i
    cpl_goods.artic
    cpl_goods.prod-type
    cpl_goods.prod-code
    v-is-petrol
    v-is-pieces
  }
  if v-is-petrol = yes
    and v-is-pieces <> yes
  then do:
    find last cpl_inv-line no-lock
      where cpl_inv-line.obj-type   = t-doc.obj-type
        and cpl_inv-line.obj-code   = t-doc.obj-code
        and cpl_inv-line.prod-type  = cpl_goods.prod-type
        and cpl_inv-line.prod-code  = cpl_goods.prod-code
        and cpl_inv-line.artic      = cpl_goods.artic
        and cpl_inv-line.status_    = {&fact}
        and cpl_inv-line.fact-order > 0
      use-index fact-order
      no-error.
    if available cpl_inv-line then do:
      assign
        var-kg-qnty = cpl_inv-line.after-cli-qnty
        cpl_doc-line.doc-density  = var-kg-qnty / varchg-qnty
        cpl_doc-line.fact-density = cpl_doc-line.doc-density
      .
      find first cpl_inv-line exclusive-lock
        where cpl_inv-line.doc-code  = cpl_doc-line.doc-code
          and cpl_inv-line.artic     = cpl_doc-line.artic
          and cpl_inv-line.prod-type = cpl_doc-line.prod-type
          and cpl_inv-line.prod-code = cpl_doc-line.prod-code
        no-error.
      if not available cpl_inv-line then do:
        { str/corinvln.i
          cpl_doc-line.doc-code
          cpl_doc-line.artic
          cpl_doc-line.prod-type
          cpl_doc-line.prod-code
          ?
          ?
          ?
          ?
          "vardoc-qnty * cpl_doc-line.doc-density"
          cpl_doc-line.doc-density
          rr-inv-line
        }
      end.
      else do:
        assign
          rr-inv-line = recid( cpl_inv-line )
          cpl_inv-line.wast-cli-qnty = vardoc-qnty * cpl_doc-line.doc-density
        .
      end.
    end.
  end.
end.
end.

  run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
  if error-status :error then do:
    message
      "Ошибка при копировании документа (расчет шапки документа)." skip
      return-value skip
      error-status:get-message(1) skip
      view-as alert-box error.
    return error .
  end.

pardoc-mode = {&update}.
run ui-on ("line").
apply "entry" to br-dtl in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE copy-bb-list W-Win
PROCEDURE copy-bb-list :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer tdb_doc-line    for ub.doc-line.
define buffer tdb_gds-dtl     for ub.gds-dtl.
define buffer tdb_parts       for ub.parts .
define buffer buf_parts       for ub.parts .
define buffer buf-cli_clients for ub.clients  .

define variable v-num as integer initial 1 no-undo.
define variable  v-fact-qnty  as decimal   no-undo .
define variable  v-cli-qnty   as decimal   no-undo .
define variable  v-root-node  as integer   no-undo .
define buffer doc_parts for ub.parts  .

for each t-d-b-doc-line :
  delete t-d-b-doc-line.
end.
for each t-d-b-gds-dtl :
  delete t-d-b-gds-dtl.
end.
for each t-d-b-parts :
  delete t-d-b-parts.
end.

 for each bb-list :
        for each doc_parts no-lock where
                 doc_parts.in-code    = bb-list.in-code and
                 doc_parts.part-code  = bb-list.part-code and
                 doc_parts.obj-type   = t-doc.obj-type and
                 doc_parts.obj-code   = t-doc.obj-code and
                 doc_parts.artic      = bb-list.artic and
                 doc_parts.prod-type  = bb-list.prod-type and
                 doc_parts.prod-code  = bb-list.prod-code and
                 doc_parts.out-code   = {&free-code}
        :
        find first  t-d-b-parts where
                 t-d-b-parts.in-code    = bb-list.in-code and
                 t-d-b-parts.part-code  = bb-list.part-code and
                 t-d-b-parts.obj-type   = t-doc.obj-type and
                 t-d-b-parts.obj-code   = t-doc.obj-code and
                 t-d-b-parts.artic      = bb-list.artic and
                 t-d-b-parts.prod-type  = bb-list.prod-type and
                 t-d-b-parts.prod-code  = bb-list.prod-code and
                 t-d-b-parts.out-code   = t-doc.doc-code no-error .
       if not available t-d-b-parts then do:
          create t-d-b-parts.
          buffer-copy doc_parts to t-d-b-parts
          assign
            t-d-b-parts.out-code   = t-doc.doc-code
          .
       end.
   end.
 end.

  for each t-d-b-parts :
      find first t-d-b-doc-line where
                t-d-b-doc-line.doc-code  =  t-doc.doc-code and
                t-d-b-doc-line.artic     =  t-d-b-parts.artic and
                t-d-b-doc-line.prod-type =  t-d-b-parts.prod-type and
                t-d-b-doc-line.prod-code =  t-d-b-parts.prod-code no-error .
      if not available t-d-b-doc-line then do:
        create t-d-b-doc-line.
        v-fact-qnty = 0.
        v-cli-qnty  = 0.
      end.
      else do:
        v-fact-qnty = t-d-b-doc-line.fact-qnty.
        v-cli-qnty  = t-d-b-doc-line.cli-qnty.
      end.
      buffer-copy t-d-b-parts except status_ to t-d-b-doc-line
      assign
          t-d-b-doc-line.doc-code   = t-doc.doc-code
          t-d-b-doc-line.doc-qnty   = t-d-b-parts.fact-qnty + v-fact-qnty
          t-d-b-doc-line.fact-qnty  = t-d-b-parts.fact-qnty + v-fact-qnty
          t-d-b-doc-line.cli-qnty   = t-d-b-parts.cli-qnty  + v-cli-qnty
      .
  end.
  for each  t-d-b-doc-line where
                t-d-b-doc-line.doc-code  =  t-doc.doc-code :
      find first t-d-b-gds-dtl where
                t-d-b-gds-dtl.doc-code  =  t-doc.doc-code and
                t-d-b-gds-dtl.artic     =  t-d-b-doc-line.artic and
                t-d-b-gds-dtl.prod-type =  t-d-b-doc-line.prod-type and
                t-d-b-gds-dtl.prod-code =  t-d-b-doc-line.prod-code no-error .

      if not available t-d-b-gds-dtl then do:
        create t-d-b-gds-dtl.
      end.
      { gbl/rootnode.i
      t-d-b-doc-line.artic
      t-d-b-doc-line.prod-type
      t-d-b-doc-line.prod-code
      v-root-node
      }

      buffer-copy t-d-b-doc-line to t-d-b-gds-dtl
      assign
        t-d-b-gds-dtl.doc-code  = t-doc.doc-code
        t-d-b-gds-dtl.prt-code  = v-root-node
      .
  end.


block_copy:
do transaction
on error undo, return error return-value
on stop  undo, return error "stop"
:

  { str/copy-ret.i
    parparentproc
    t-doc.doc-code
    t-doc.doc-type
    t-doc.status_
    t-doc.internal
    t-doc.cli-type
    t-doc.cli-code
    t-doc.discnt-type
    t-doc.tot-calc
    t-doc.discnt-pc
    t-doc.agnt
    t-doc.boss
    t-doc.wrkr
    t-doc.base-rate
    t-doc.base-scale
    t-doc.exch-code
    t-doc.vat-type
    t-doc.doc-code
    "t-doc.discnt-type:sensitive in frame {&frame-name}"
    "input frame {&frame-name} t-doc.discnt-pc"
    "input frame {&frame-name} t-doc.agnt"
    "input frame {&frame-name} t-doc.boss"
    "input frame {&frame-name} t-doc.wrkr"
    "input frame {&frame-name} t-doc.base-rate"
    "input frame {&frame-name} t-doc.base-scale"
    ub.sysconf.cash-pay
    ub.sysconf.base-code
    t-d-b-doc-line
    t-d-b-gds-dtl
    t-d-b-parts
    yes
    yes
    yes
    yes
    no-error }

  if error-status :error then do:
    message "Ошибка при копировании документа." skip
            return-value skip
            error-status:get-message(1) skip
            error-status:get-message(2) skip
            error-status:get-message(3) skip
    view-as alert-box error.
    return error.
  end.
  run str/crdocpl.p
    ( input t-doc.doc-code
     ,input ?
     ,input "dens_doc-line":U
    ) no-error .
  if error-status :error then do:
    message
      "Ошибка при копировании документа (создание информации по складским местам)." skip
      return-value skip
      error-status:get-message(1) skip
      error-status:get-message(2) skip
      error-status:get-message(3) skip
      view-as alert-box error.
    return error .
  end.
  run gbl/calc-trn.p (input parparentproc, input recid(t-doc)) no-error.
  if error-status :error then do:
    message
      "Ошибка при копировании документа (расчет шапки документа)." skip
      return-value skip
      error-status:get-message(1) skip
      error-status:get-message(2) skip
      error-status:get-message(3) skip
      view-as alert-box error.
    return error .
  end.
end. /*transaction*/

for each t-d-b-doc-line :
  delete t-d-b-doc-line.
end.
for each t-d-b-gds-dtl :
  delete t-d-b-gds-dtl.
end.
for each t-d-b-parts :
  delete t-d-b-parts.
end.

pardoc-mode = {&update}.
run ui-on ("line").
apply "entry" to br-dtl in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rowdisp d-in-doc 
procedure rowdisp :
  
  do ii = 1 to extent (bcol).  
    if valid-handle (bcol[ii]) 
    then do:
      assign
        bcol[ii]:bgcolor = RED_COLOR when get-vsdsts(buffer ub.gds-dtl) = "-".
    end.
  end.  
  
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE scanMark d-in-doc 
procedure scanMark :
  define input parameter iRecidParts as recid no-undo.
  define parameter buffer iBufGoods for goods.
  define output parameter oOk as logical no-undo init true.
  
  define variable vRightChngQntyCode as character no-undo .
  define variable vRightChngQnty     as logical   no-undo .
  define buffer buf_doc-line for ub.doc-line.
  define buffer bf_gds-dtl   for ub.gds-dtl.
  
  v-add = yes .
  do while v-add :

    run str/chs-alcmarks.w (
      input parparentproc,
      input t-doc.doc-code,
      input {&add-def},
      input iBufGoods.gds-code,
      input if iRecidParts <> ? then string(iRecidParts) else "",
      output mark) no-error.
    if error-status :error or mark = "" or mark = ? then 
    do: 
      oOk = false.
      find first buf_doc-line no-lock where 
                 buf_doc-line.doc-code = t-doc.doc-code
             and buf_doc-line.artic = iBufGoods.artic
             and buf_doc-line.prod-code = iBufGoods.prod-code
             and buf_doc-line.prod-type = iBufGoods.prod-type
           no-error .
      release bf_gds-dtl.
      if avail buf_doc-line then
          find first bf_gds-dtl no-lock where 
                     bf_gds-dtl.doc-code = buf_doc-line.doc-code
                 and bf_gds-dtl.artic = buf_doc-line.artic
                 and bf_gds-dtl.prod-type = buf_doc-line.prod-type
                 and bf_gds-dtl.prod-code = buf_doc-line.prod-code
               no-error.
      if not avail bf_gds-dtl and 
         (t-doc.ext-doc-type = {&TDEDT_Ras_Perem} or t-doc.ext-doc-type = {&TDEDT_Spi_Vnesh}) then
      do:  /* строка с товаром не найена, значит еще ничего не просканировали */
          vRightChngQntyCode = if t-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} 
                               then 'actn_write-off_add-no-mark':U
                               else 'actn_tdedt-ras-perem_add-no-mark':U.
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            vRightChngQntyCode
            {&cntxt-object}
            t-doc.host-code
            t-doc.obj-type
            t-doc.obj-code
            0
            0
            0
            false
            vRightChngQnty
          }
          if not vRightChngQnty then
          do:
            message "Товар не добавлен, т.к. не просканировано ни одой марки."
              view-as alert-box.
            return.  
          end. 
      end.
      run str/out-add.p (parparentproc,
          recid(t-doc),
          input recid(buf_doc-line),
          input (if available bf_gds-dtl then recid(bf_gds-dtl) else ?),
          gds-rec,
          (if available bf_gds-dtl then {&update} else {&add-def}) + 
          if iRecidParts <> ? then ({&delim-par} + "return=" + string(iRecidParts)) else "",
          '') no-error.
      return. 
    end.
    find first buf_doc-line exclusive-lock where buf_doc-line.doc-code = t-doc.doc-code
                                            and buf_doc-line.artic = iBufGoods.artic
                                            and buf_doc-line.prod-code = iBufGoods.prod-code
                                            and buf_doc-line.prod-type = iBufGoods.prod-type
                                            no-error .
    if not available (buf_doc-line)
    then do:
      run str/out-add.p (parparentproc,
          recid(t-doc),
          ?,
          ?,
          gds-rec,
          {&add-def} + 
          if iRecidParts <> ? then ({&delim-par} + "return=" + string(iRecidParts)) else "",
          'scan-marks' + {&delim-key} + mark) no-error.
      if error-status :error then 
      do:
        next .
      end.
      if return-value = "stop-add-marks"
      then do :
        v-add = no .
      end .
    end .
    else do :
      find first bf_gds-dtl exclusive-lock where bf_gds-dtl.doc-code = buf_doc-line.doc-code
                                             and bf_gds-dtl.artic = buf_doc-line.artic
                                             and bf_gds-dtl.prod-type = buf_doc-line.prod-type
                                             and bf_gds-dtl.prod-code = buf_doc-line.prod-code
                                             no-error.
      run str/out-add.p
        ( input parparentproc
        ,input recid(t-doc)
        ,input recid(buf_doc-line)
        ,input (if available bf_gds-dtl then recid(bf_gds-dtl) else ?)
        ,input gds-rec
        ,input {&update} + 
               if iRecidParts <> ? then ({&delim-par} + "return=" + string(iRecidParts)) else ""
        ,input 'scan-marks' + {&delim-key} + mark)
      no-error.
      if error-status :error then 
      do:
        return error.
      end.
      if return-value = "stop-add-marks"
      then do :
        v-add = no .
      end .
    end .
  end .
  
  
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME