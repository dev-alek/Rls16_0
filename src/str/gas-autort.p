block-level on error undo, throw.
/*

$Revision: 220955104cd9, 2417, rls $
$Author: SSlivenko $
$Date: 2020/06/10 18:13:46 $
$Workfile: gas-autort.p $
$Archive: str/gas-autort.p $

Создание возвратного документа по документу возврата через кассу газа (ТГУ)

Автор: Кирюхин Сергей
Дата создания: 10/09/13
Author: SKiryxin
Creation date: 10/09/13

*/
using ibs.th.str.alcohol.*.

define input parameter parparentproc as widget-handle no-undo.
define input parameter p-log-handle as handle no-undo.
define input parameter log-file-name as character no-undo.
define input parameter p-auto as integer no-undo.
define input parameter p-inkas-code as character no-undo.
define input parameter v-curr-r-b as character no-undo.
define input parameter p-cli-type as character no-undo. /* из shattr */
define input parameter p-cli-code as integer no-undo. /* из shattr */
define output parameter p-doc-code as character no-undo.
define output parameter p-root-node as character no-undo.
/* документ продажи */
define parameter buffer buf-sale_trn-doc for ub.trn-doc.
/* линия возврата */
define parameter buffer buf-sale_doc-line for ub.doc-line.
/* создарнный документ прихода */
define parameter buffer buf-new_trn-doc for ub.trn-doc.

define variable chg-qnty      as   decimal no-undo .

define variable vss-revision as character no-undo init "$Revision: 220955104cd9, 2417, rls $":U .
define variable vss-author as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date as character no-undo init "$Date: 2020/06/10 18:13:46 $":U .
define variable vss-workfile as character no-undo init "$Workfile: gas-autort.p $":U .
define variable vss-archive as character no-undo init "$Archive: str/gas-autort.p $":U .
define variable vss-description as character no-undo init "Создание приходного документа техпролива по документу продажи газа (ТГУ)".
{cmp/vssrevis.i}

/* Inclides */
{cmp/trg-def.i}
{str/lib-trn.i}
{ gbl/getsect.i def }
{str/doc-code.i}
{ gbl/key-rec.i  }
{trg/partscr.i}
{ trg/partrqst.i }
{str/trdcalib.i}
{cmp/gds-list.i gds-list def "new shared"}
{ trg/partcopy.i }
{ trg/partrsrv.i }


/* Local variables */
define variable v-parts-recid as recid no-undo .
define variable v-vat-type as character no-undo.
define variable v-vat-pc as decimal no-undo.
define variable v-slt-type as character no-undo.
define variable v-slt-pc as decimal no-undo.
define variable v-doc-pl-rowid as rowid no-undo.
define variable varchg-inv as logical no-undo.
define variable v-cntxt-rsrv-time as integer no-undo.
define variable v-cntxt-load-time as integer no-undo.
define variable v-cntxt-holidays as character no-undo.
define variable v-goods-serial             as logical   no-undo .
define variable v-goods-twounit            as logical   no-undo .
define variable v-chg-qnty      like ub.parts.qnty      no-undo .
define variable v-node-code   like ub.gds-prt.node-code no-undo .
define variable v-wrkr    as integer no-undo .
define variable v-agnt    as integer no-undo .
define variable v-boss    as integer no-undo .
/* Buffers */
define buffer buf_clients for ub.clients.
define buffer buf-new_doc-line for ub.doc-line.
define buffer buf_parts for ub.parts.
define buffer buf_goods for ub.goods.
define buffer buf_pl-gds for ub.pl-gds.
define buffer buf-new_doc-pl for ub.doc-pl.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_sale-gds-dtl for ub.gds-dtl.
define buffer buf-new_sale-gds-dtl for ub.gds-dtl.
define buffer buf_gds-prt    for ub.gds-prt .
define buffer buf_prt-obj    for ub.prt-obj .
define buffer buf_gds-obj    for ub.gds-obj .

/*-----------------------------------------------------------------------------------------------------*/
tran_:
do transaction :
/* Получим код для новой накладной */
run doc-code in this-procedure (input "main",
                                input buf-sale_trn-doc.obj-type,
                                input buf-sale_trn-doc.obj-code,
                                input buf-sale_trn-doc.doc-code,
                                output p-doc-code) no-error.

/* Создадим шапку нового документа */


/* Отсюда возьмём суммы */
find first buf_sale-gds-dtl where buf_sale-gds-dtl.doc-code = buf-sale_doc-line.doc-code
                              and buf_sale-gds-dtl.artic = buf-sale_doc-line.artic
                              and buf_sale-gds-dtl.prod-code = buf-sale_doc-line.prod-code
                              and buf_sale-gds-dtl.prod-type = buf-sale_doc-line.prod-type no-lock.
                              
v-chg-qnty = - abs(buf-sale_doc-line.fact-qnty) .                              
                              
find first buf_parts no-lock where buf_parts.artic      = buf-sale_doc-line.artic
                               and buf_parts.prod-type  = buf-sale_doc-line.prod-type
                               and buf_parts.prod-code  = buf-sale_doc-line.prod-code
                               and buf_parts.out-code   = {&free-code}
                               and buf_parts.qnty       = abs(v-chg-qnty)
                               no-error.
if not available buf_parts
then do :
  find first buf_parts no-lock where buf_parts.artic      = buf-sale_doc-line.artic
                                 and buf_parts.prod-type  = buf-sale_doc-line.prod-type
                                 and buf_parts.prod-code  = buf-sale_doc-line.prod-code
                                 and buf_parts.out-code   = {&free-code}
                                 and buf_parts.qnty       > abs(v-chg-qnty)
                                 no-error.
end. 
if not available buf_parts
then do :
  message "Невозможно создать возврат поставщику для газа. Не найдена подходящая партия свободной зоны." skip
          "После закрытия продажи создайте возврат поставщику вручную." view-as alert-box warning.
  undo tran_, return error .
end.   

find first buf_clients where buf_clients.obj-type = buf_parts.supp-type
                         and buf_clients.obj-code = buf_parts.supp-code no-lock.                           

{str/crtrndoc.i
 ?
 ?
 buf-sale_trn-doc.base-rate
 buf-sale_trn-doc.base-scale
 buf_clients.obj-code
 buf_clients.obj-type
 buf_clients.obj-name
 buf-sale_trn-doc.cr-db-num
 g#userid
 {&percent}
 p-doc-code
 buf-sale_trn-doc.doc-date
 {&expense}
 false
 buf-sale_trn-doc.host-code
 false
 buf-sale_trn-doc.obj-code
 buf-sale_trn-doc.obj-type
 false
 buf-sale_trn-doc.pay-code
 '"Возврат поставщику для продажи природного газа"'
 true
 {&without-SLT}
 {&wayb}
 "{&inc-VAT}"
 {&TDEDT_Ras_Vnesh_VP}
 {&bef-repayment-code}
 no-error}

/* Встанем на созданный документ */
find first buf-new_trn-doc where buf-new_trn-doc.doc-code = p-doc-code exclusive-lock.

/* пишем поля */
assign
buf-new_trn-doc.out-code = buf-sale_trn-doc.doc-code
buf-new_trn-doc.fact-date  = buf-sale_trn-doc.fact-date
buf-new_trn-doc.shift-date = buf-sale_trn-doc.shift-date
buf-new_trn-doc.shift-num  = buf-sale_trn-doc.shift-num
buf-new_trn-doc.shift-name = buf-sale_trn-doc.shift-name
buf-new_trn-doc.base-rate = buf-sale_trn-doc.base-rate
buf-new_trn-doc.base-scale = buf-sale_trn-doc.base-scale
buf-new_trn-doc.exch-scale = buf-sale_trn-doc.exch-scale
buf-new_trn-doc.exch-rate = buf-sale_trn-doc.exch-rate
buf-new_trn-doc.pay-code = buf-sale_trn-doc.pay-code
buf-new_trn-doc.tot-lines = 1
buf-new_trn-doc.tot-doc = buf_sale-gds-dtl.price-base * buf_sale-gds-dtl.fact-qnty
buf-new_trn-doc.tot-fact = buf_sale-gds-dtl.price-base * buf_sale-gds-dtl.fact-qnty
buf-new_trn-doc.tot-rubl = buf_sale-gds-dtl.price-base * buf_sale-gds-dtl.fact-qnty
buf-new_trn-doc.tot-sale = buf_sale-gds-dtl.price-base * buf_sale-gds-dtl.fact-qnty
buf-new_trn-doc.tot-cli = buf_sale-gds-dtl.price-base * buf_sale-gds-dtl.fact-qnty
buf-new_trn-doc.tot-calc = buf_sale-gds-dtl.price-base * buf_sale-gds-dtl.fact-qnty.

/* Создадим линию накладной */
{str/crdoclin.i
 buf-new_trn-doc.doc-code
 buf-sale_doc-line.artic
 buf-sale_doc-line.prod-type
 buf-sale_doc-line.prod-code
 buf-new_trn-doc.obj-type
 buf-new_trn-doc.obj-code
 "''"
 buf-new_trn-doc.ext-doc-type
 buf-sale_doc-line.prt-root
 buf-sale_doc-line.vat-pc
 buf-sale_doc-line.slt-pc
 buf-sale_doc-line.cons-vat-pc
 no-error}

/* Встанем на созданную линию */
find first buf-new_doc-line where buf-new_doc-line.doc-code = buf-new_trn-doc.doc-code  exclusive-lock.

/* Определим товар */
find first buf_goods where buf_goods.artic = buf-new_doc-line.artic
                       and buf_goods.prod-type = buf-new_doc-line.prod-type
                       and buf_goods.prod-code = buf-new_doc-line.prod-code no-lock.

/* И место */
find first buf_pl-gds where buf_pl-gds.obj-type = buf-new_trn-doc.obj-type
                        and buf_pl-gds.obj-code = buf-new_trn-doc.obj-code
                        and buf_pl-gds.gds-code = buf_goods.gds-code
                        and buf_pl-gds.status_ = {&current-status} no-lock.


/* Добавим всё нужное в линию */
assign
buf-new_doc-line.fact-density = buf-sale_doc-line.fact-density
buf-new_doc-line.cli-qnty = buf-sale_doc-line.fact-qnty * buf-sale_doc-line.fact-density
buf-new_doc-line.fact-qnty = buf-sale_doc-line.fact-qnty
buf-new_doc-line.doc-qnty = buf-sale_doc-line.fact-qnty
buf-new_doc-line.price-rubl = buf_sale-gds-dtl.price-rubl
buf-new_doc-line.price-base = buf_sale-gds-dtl.price-base
buf-new_doc-line.price-cli = buf_sale-gds-dtl.price-base / buf-sale_doc-line.fact-density
buf-new_doc-line.unit-cli = buf_goods.unit-cli
buf-new_doc-line.cli-base-rate = 1 / buf-sale_doc-line.fact-density
buf-new_doc-line.doc-density = buf-sale_doc-line.doc-density.


{str/crdocpl.i
 buf-new_trn-doc.doc-code
 buf_goods.gds-code
 buf_pl-gds.pl-code
 buf-new_trn-doc.obj-type
 buf-new_trn-doc.obj-code
 v-doc-pl-rowid
 no-error}

find first buf-new_doc-pl where rowid(buf-new_doc-pl) = v-doc-pl-rowid exclusive-lock.
assign
buf-new_doc-pl.doc-qnty = buf-new_doc-line.doc-qnty
buf-new_doc-pl.fact-qnty = buf-new_doc-line.fact-qnty
buf-new_doc-pl.cli-qnty = buf-new_doc-line.cli-qnty
buf-new_doc-pl.cli-doc-qnty = buf-new_doc-line.cli-qnty
buf-new_doc-pl.cli-fact-qnty = buf-new_doc-line.cli-qnty
buf-new_doc-pl.out-code = buf-new_doc-line.doc-code.

{gbl/rootnode.i
 buf-new_doc-line.artic
 buf-new_doc-line.prod-type
 buf-new_doc-line.prod-code
 p-root-node}

{str/crgdsdtl.i
 buf-new_trn-doc.obj-code
 buf-new_trn-doc.obj-type
 buf-new_trn-doc.doc-code
 buf-new_doc-line.artic
 buf-new_doc-line.prod-code
 buf-new_doc-line.prod-type
 p-root-node
 false}

find first buf-new_sale-gds-dtl where buf-new_sale-gds-dtl.doc-code = p-doc-code exclusive-lock.

assign
buf-new_sale-gds-dtl.price-base = buf-new_doc-line.price-base
buf-new_sale-gds-dtl.price-rubl = buf-new_doc-line.price-rubl
buf-new_sale-gds-dtl.doc-qnty = buf-new_doc-line.doc-qnty
buf-new_sale-gds-dtl.fact-qnty = buf-new_doc-line.fact-qnty.

{str/saledoc.i}

run saledoc-create in this-procedure (
    input p-inkas-code,
    input buf-sale_trn-doc.host-code,
    input buf-sale_trn-doc.obj-type,
    input buf-sale_trn-doc.obj-code,
    input {&sale-add-ret-nat-gas},
    input {&gds-goods},
    input no,
    input '':U,
    input '':U,
    input 0,
    buffer buf-new_trn-doc) no-error.

find first buf_sysconf where buf_sysconf.host-code = buf-new_trn-doc.host-code no-lock.

assign
v-cntxt-rsrv-time = buf_sysconf.rsrv-time
v-cntxt-load-time = buf_sysconf.load-time
v-cntxt-holidays = buf_sysconf.holidays.

{ gbl/gdscdat.i
  buf_goods.gds-code
  "'serial=request':u"
  v-goods-serial
  no-error
}
if error-status :error
then do:
/*  message                                                                          */
/*    vss-workfile vss-revision vss-description skip                                 */
/*    "Ошибка при получении атрибута товара" skip                                    */
/*    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip*/
/*    "serial=request" skip                                                          */
/*    view-as alert-box .                                                            */
  undo, return error .
end.

{ gbl/gdscdat.i
  buf_goods.gds-code
  "'twounit=request':u"
  v-goods-twounit
  no-error
}
if error-status :error
then do:
/*  message                                                                          */
/*    vss-workfile vss-revision vss-description skip                                 */
/*    "Ошибка при определении атрибута товара" skip                                  */
/*    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip*/
/*    'twounit=request':u skip                                                       */
/*    error-status :get-message(1) skip                                              */
/*    return-value skip                                                              */
/*    view-as alert-box error .                                                      */
  undo, return error .
end.

    
define variable v-real-chg-qnty like ub.parts.qnty no-undo .
run partrsrv in this-procedure
  (input  v-chg-qnty      /* p-chg-qnty      */
  ,input  v-goods-serial  /* p-goods-serial  */
  ,input  v-goods-twounit /* p-goods-twounit */
  ,input  false           /* p-unreserv-only */
  ,buffer buf_parts       /* buf_orig_parts  */
  ,buffer buf-new_trn-doc     /* buf_trn-doc     */
  ,output v-real-chg-qnty /* p-real-chg-qnty */
  ,output v-parts-recid   /* p-parts-recid   */
  ,input  ""
  ) no-error .
if error-status :error
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при резервировании партии" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.

find current buf_pl-gds exclusive-lock .
assign
  buf_pl-gds.free-qnty     = buf_pl-gds.free-qnty     - abs(v-real-chg-qnty)
  buf_pl-gds.cli-free-qnty = buf_pl-gds.cli-free-qnty - abs(v-real-chg-qnty) * buf-new_doc-line.fact-density
.
if buf_pl-gds.free-qnty = buf_pl-gds.fact-qnty
  and absolute( buf_pl-gds.cli-free-qnty - buf_pl-gds.cli-fact-qnty ) <= 0.01
then do:
  /* корректируем т.к. из-за плотности у нас кол-во может гулять до +-0.001 */
  /* но при этом в базовой ед.изм. все должно быть точно                    */
  assign
    buf_pl-gds.cli-free-qnty = buf_pl-gds.cli-fact-qnty
  .
end.

{ gbl/termnode.i
  buf-new_sale-gds-dtl.prt-code
  v-node-code
  no-error
}
if error-status :error then do:
  message
    "Ошибка при определении первого терминального признака" skip
    "prt-code " buf-new_sale-gds-dtl.prt-code skip
    view-as alert-box error .
  undo, return error return-value .
end.

find first buf_gds-prt no-lock
  where buf_gds-prt.node-code = v-node-code
  .
do while available buf_gds-prt
on error undo, return error return-value
:
  { gbl/prtobjcr.i
    buf-new_doc-line.obj-type
    buf-new_doc-line.obj-code
    buf-new_doc-line.artic
    buf-new_doc-line.prod-type
    buf-new_doc-line.prod-code
    buf_gds-prt.node-code
    buf_prt-obj
  }
  find current buf_prt-obj exclusive-lock .

  assign
    buf_prt-obj.free-qnty = buf_prt-obj.free-qnty - abs(v-real-chg-qnty)
  .

  assign
    v-node-code = buf_gds-prt.upper-code
  .
  find first buf_gds-prt no-lock
    where buf_gds-prt.node-code = v-node-code
    no-error .
end.

find first buf_gds-obj exclusive-lock where buf_gds-obj.obj-type  = buf-new_doc-line.obj-type
                                        and buf_gds-obj.obj-code  = buf-new_doc-line.obj-code
                                        and buf_gds-obj.artic     = buf-new_doc-line.artic
                                        and buf_gds-obj.prod-type = buf-new_doc-line.prod-type
                                        and buf_gds-obj.prod-code = buf-new_doc-line.prod-code
                                        .
assign
  buf_gds-obj.free-qnty    = buf_gds-obj.free-qnty - abs(v-real-chg-qnty)
  buf_gds-obj.on-line-rest = buf_gds-obj.free-qnty
.                                        

{str/calc-out.i
 recid(buf-new_trn-doc)
 true
 this-procedure
 no-error}

{ gbl/getsect.i run buf-new_trn-doc.obj-type buf-new_trn-doc.obj-code {&attr-autosale} }
for each thbjattr_thbj-attr :
  if thbjattr_thbj-attr.prop-code = {&attr-autosale_wrkr} then assign v-wrkr = thbjattr_thbj-attr.property-value-integer .
  if thbjattr_thbj-attr.prop-code = {&attr-autosale_agnt} then assign v-agnt = thbjattr_thbj-attr.property-value-integer .
  if thbjattr_thbj-attr.prop-code = {&attr-autosale_boss} then assign v-boss = thbjattr_thbj-attr.property-value-integer .
end. 

assign
  buf-new_trn-doc.wrkr  = v-wrkr
  buf-new_trn-doc.agnt  = v-agnt
  buf-new_trn-doc.boss  = v-boss
. 

{ str/tdat-wrt.i                                    
   buf-new_trn-doc.doc-code
   {&trdcattr-is-auto-trn}
   "yes" 
no-error}

run str/trn-stat.p (
    input parparentproc,
    input this-procedure,
    input {&close-fact} ,
    input buf-new_trn-doc.doc-code,
    input false,
    input g#db-num,
    input false,
    input v-cntxt-rsrv-time,
    input v-cntxt-load-time,
    input v-cntxt-holidays,
    input false,
    output varchg-inv,
    output table gds-list) no-error.
if error-status:error then  message error-status:get-message(1) skip return-value view-as alert-box warning.

end. /* tran */
